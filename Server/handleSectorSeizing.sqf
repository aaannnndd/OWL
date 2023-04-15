params ["_sector", "_unitList"];

/* If the sector isn't capturable don't even look */
if (!(_sector call OWL_fnc_sectorSeizable)) exitWith {};

/*  We are going to count up the number of:
	- ARMED VEHICLES
	- AT Soldiers
	- Infantry
	The logic is as follows.
	Each armed vehicle is worth 5 points.
	Each soldier is worth 1 point.
	When defending, your AT Soldiers can cancel out enemy armed vehicles (They are worth 5 points).
	If there are no armed vehicles to cancel, they are just worth 1 point.
	The 'Effective Force' of the defenders and attackers is how much assets/soldiers they have after cancelling out
	at soldiers / armed vehicles, and multiplying the remaining armed vehicles by 5.
	The difference in 'Effective Force' dictates who caps and how fast.
	If the defenders have more 'effective force', the cap goes down at a rate of 1 no matter what.
	If the attackers have more 'effective force', the cap progresses at a rate of (effective force / 5).
	This means caps can't be 'interuptted', just pushed back down. It also means you cannot capture a sector if you
	can technically be wiped out by the defenders inside.
	Adjustments will need to be made, but the fast travel ticket system should take care of most issues.
*/

private _numVehicles = [0,0,0];
private _numInfantry = [0,0,0];
private _numAT = [0,0,0];
{
	private _sideIndex = [WEST, EAST, RESISTANCE] find (side _x);
	if (vehicle _x != _x) then {
		private _vehicle = vehicle _x;
		if (getText (configFile >> "CfgVehicles" >> typeOf _vehicle >> "unitInfoType") != "RscUnitInfoNoWeapon") then {
			private _count = 0;
			{
				if (alive _x) then {
					_count = _count + 1;
				};
			} forEach crew _vehicle;
			if (_count > 0) then {
				_numVehicles set [_sideIndex, _numVehicles#_sideIndex +1];
			};
		};
	} else {
		if (_x isKindOf "Man") then {
			private _launcher = secondaryWeapon _x;
			if (!isNil{_launcher} && _launcher != "") then {
				// This counts AA soldiers currently, change later >.>
				if (getText (configFile >> "CfgWeapons" >> _launcher >> "reloadAction") == "ReloadRPG") then {
					_numAT set [_sideIndex, (_numAT#_sideIndex) + 1];
				};
			} else {
				_numInfantry set [_sideIndex, (_numInfantry#_sideIndex) + 1];
			};
		};
	};
} forEach _unitList;

// All lists below have values for each faction corresponding to WEST = index 0, EAST = 1, GUER = 2
// _sectorIndex = defending side. cancel out AT soldiers here.
private _sectorIndex = [WEST, EAST, RESISTANCE] find (_sector getVariable "OWL_sectorSide");
private _effectiveVehicles = [0,0,0];
{
	private _vehicleDiff = (_numVehicles # _x) - (_numVehicles # _sectorIndex);
	if (_vehicleDiff > 0) then {
		_vehicleDiff = _vehicleDiff - (_numAT # _sectorIndex);
		if (_vehicleDiff < 0) then {
			_numAT set [_sectorIndex, -1*_vehicleDiff];
			_vehicleDiff = 0;
		} else {
			_numAT set [_sectorIndex, 0];
		};
	} else {
		_vehicleDiff = 0;
	};
	_numInfantry set [_x, (_numInfantry#_x) + (_numAT#_x)];
	_effectiveVehicles set [_x, _vehicleDiff];
} forEach ([0,1,2] - [_sectorIndex]);

// _strengthOfSide is difference between defenders and attackers. If it's negative, you overpower the defenders.
private _strengthOfSide = [0,0,0];
{
	_strengthOfSide set [_x, ((_numInfantry#_sectorIndex) - (_numInfantry#_x)) + ((_numVehicles # _sectorIndex) - (_effectiveVehicles#_x))*5];
} forEach ([0,1,2]-[_sectorIndex]);

// _strengthOfSide # _capFor will always be 0.
private _capFor = _sectorIndex;
{
	if (_strengthOfSide # _x < _strengthOfSide # _capFor) then {
		_capFor = _x;
	};
} forEach ([0,1,2]-[_sectorIndex]);

// defending side can't capture sectors back.
//if (!(([WEST, EAST, RESISTANCE] # _capFor) in OWL_competingSides)) exitWith {};

private _capVelocity = floor((_strengthOfSide#_capFor)/5);
_capVelocity = _capVelocity * -1;
private _capInfo = _sector getVariable ["OWL_sectorCapInfo", [_capVelocity, _sectorIndex]];
private _capProgress = _sector getVariable ["OWL_sectorCapProgress", 0];

// Favor defenders in a 'stalemate'
if (_capVelocity == 0 && _capFor == _sectorIndex) then { 
	_capVelocity = -1;
};

_capProgress = _capProgress + _capVelocity;

// TODO: Set these up as 'seizing time variables' hardcoded at 2 minutes curretly.
if (_capProgress >= 120) exitWith {
	private _side = [WEST, EAST, RESISTANCE] # _capFor;
	[_sector, _side] call OWL_fnc_onSectorSeized;
};

if (_capProgress <= 0) then {
	_capProgress = 0;
};

_sector setVariable ["OWL_sectorCapProgress", _capProgress];
if (_capInfo isEqualTo [-1, _sectorIndex] && _capProgress == 0) exitWith {};
_sector setVariable ["OWL_sectorCapInfo", [_capVelocity, _capFor]];

private _playerList = [];
{
	if (isPlayer _x) then {
		_playerList pushBackUnique (owner _x);
	};
} forEach _unitList;

if (count _playerList < 1) exitWith {};

// Make it stand still in the middle. I doubt this will ever happen from previous check. TODO
if (_capVelocity == 0) exitWith {
	[_sector, _capProgress, 1e11, _capFor, 0] remoteExec ["OWL_fnc_srCaptureUpdate",_playerList];		
};

// Adjust this to deal with negative values.
private _endTime = (_capProgress) / (-1*_capVelocity);
if (_capVelocity > 0) then {
	_endTime = ((120-_capProgress) / _capVelocity);
};

_endTime = _endTime + serverTime;

[_sector, _capProgress, _endTime, _capFor, _capVelocity] remoteExec ["OWL_fnc_srCaptureUpdate",_playerList];