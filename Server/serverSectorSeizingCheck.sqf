/*
	The below takes all units, and removes them from the list as each sector is iterated through.
	This will lessen the amount of checks, as most players are usually at main base or an airfield.
*/

private _unitsCache = allUnits;
private _i = 0;
private _end = count _unitsCache;

while {_i < _end} do {
	private _unit = (_unitsCache # _i);
	_inc = 1;
	if (side _unit == CIVILIAN) then {
		_unitsCache deleteAt _i;
		_end = _end - 1;
		_inc = 0;
	} else {
		if (vehicle _unit != _unit && (effectiveCommander (vehicle _unit)) != _unit) then {
			_unitsCache deleteAt _i;
			_end = _end - 1;
			_inc = 0;;
		};
	};
	_i = _i + _inc;
};

/*
	These are the map/array we will operate on to do seizing calculations and zone restriction kill timers.
*/

private _inAreaHashMap = createHashMap;
private _inAreaZRList = [];

/*
	The below takes all units, and removes them from the list as each sector is iterated through.
	This will lessen the amount of checks, as most players are usually at main base or an airfield.
*/

_end = (count _unitsCache);
{
	private _index = _forEachIndex;
	private _side = (OWL_allSectors # _index) getVariable "OWL_sectorSide";
	private _protected = (OWL_allSectors # _index) getVariable "OWL_sectorProtected";
	_i = 0;
	while {_i < _end} do {
		private _unit = _unitsCache # _i;
		private _unitPos = getPosATL _unit;
		private _diffLoc = (_unitPos vectorDiff _x) apply {abs(_x)};
		private _inArea = true;
		for "_j" from 0 to 1 do {
			if (_diffLoc#_j > (OWL_sectorAreaMatrix#_index)#_j) then {
				_inArea = false;
			}
		};
		if (_inArea) then {
			_unitsCache deleteAt _i;
			_end = _end - 1;
			if (isNil {_inAreaHashMap get _index}) then {
				_inAreaHashMap set [_index, []];
			};
			(_inAreaHashMap get _index) pushBack _unit;
			if (_side != side _unit && isPlayer _unit && _protected) then {
				if (OWL_contestedSector # (OWL_competingSides find (side _unit)) != (OWL_allSectors # _index)) then {
					_inAreaZRList pushBack [_unit, _index];
				};
			};
			continue;
		} else {
			private _inAreaZR = true;
			for "_j" from 0 to 1 do {
				if (_diffLoc#_j > (OWL_sectorAreaBorderMatrix#_index)#_j) then {
					_inAreaZR = false;
				};
			};
			if (_inAreaZR) then {
				_unitsCache deleteAt _i;
				_end = _end - 1;
				if (_side != (side _unit) && isPlayer _unit && _protected) then {
					if (OWL_contestedSector # (OWL_competingSides find (side _unit)) != (OWL_allSectors # _index)) then {
						_inAreaZRList pushBack [_unit, _index];
					};
				};
				continue;
			};
		};
		_i = _i + 1;
	};
} forEach OWL_sectorPositionMatrix;

/* Process zone restrictions */
{
	_unit = _x#0;
	if (_x in OWL_inAreaZRList) then {
		if (_unit getVariable ["OWL_killTimer", 1e11] < serverTime) then {
			_unit setVariable ["OWL_killTimer", nil];
			_unit setDamage 1;
		};
	} else {
		_unit setVariable ["OWL_killTimer", serverTime+30];
		(serverTime+30) remoteExec ["OWL_srZoneRestrictTimer", owner _unit];
	};
} forEach _inAreaZRList;

{
	// No longer kill the player.
	(_x#0) setVariable ["OWL_killTimer", nil];
	-1 remoteExec ["OWL_srZoneRestrictTimer", owner (_x#0)];
} forEach (OWL_inAreaZRList - _inAreaZRList);

OWL_inAreaZRList = _inAreaZRList;

/**


Things left to do before "working"
	- Asset Orders

**/

// Put this in different function so it's not redefined every loop.
OWL_fnc_handleSectorSeizing = {
	params ["_sector", "_unitList"];

	if (!(_sector call OWL_fnc_sectorSeizable)) exitWith {};

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
					if (getText (configFile >> "CfgWeapons" >> _launcher >> "reloadAction") == "ReloadRPG") then {
						_numAT set [_sideIndex, (_numAT#_sideIndex) + 1];
					};
				} else {
					_numInfantry set [_sideIndex, (_numInfantry#_sideIndex) + 1];
				};
			};
		};
	} forEach _unitList;

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

	private _strengthDefenders = [0,0,0];
	{
		_strengthDefenders set [_x, ((_numInfantry#_sectorIndex) - (_numInfantry#_x)) + ((_numVehicles # _sectorIndex) - (_effectiveVehicles#_x))*5];
	} forEach ([0,1,2]-[_sectorIndex]);

	private _capFor = _sectorIndex;
	{
		if (_strengthDefenders # _x < _strengthDefenders # _capFor) then {
			_capFor = _x;
		};
	} forEach ([0,1,2]-[_sectorIndex]);

	// defending side can't capture sectors back.
	//if (!(([WEST, EAST, RESISTANCE] # _capFor) in OWL_competingSides)) exitWith {};
	// if (_sector getVariable "OWL_sectorProtected" && _sector != (OWL_contestedSector # ([WEST, EAST, RESISTANCE] find _capFor))) exitWith {};

	private _capVelocity = floor(_strengthDefenders#_capFor/5);
	_capVelocity = _capVelocity * -1;
	private _capInfo = _sector getVariable ["OWL_sectorCapInfo", [_capVelocity, _sectorIndex]];
	private _capProgress = _sector getVariable ["OWL_sectorCapProgress", 0];
	if (_capVelocity == 0 && _capFor == _sectorIndex) then {
		_capVelocity = -1;
	};
	_capProgress = _capProgress + _capVelocity;

	if (_capProgress >= 120) exitWith {
		private _side = [WEST, EAST, RESISTANCE] # _capFor;
		[_sector, _side] call OWL_fnc_onSectorSeized;
	};

	if (_capProgress <= 0) then {
		_capProgress = 0;
	};

	_sector setVariable ["OWL_sectorCapProgress", _capProgress];

	private _playerList = [];
	{
		if (isPlayer _x) then {
			_playerList pushBackUnique (owner _x);
		};
	} forEach _unitList;

	if (_capInfo isEqualTo [-1, _sectorIndex] && _capProgress == 0) exitWith {};

	_sector setVariable ["OWL_sectorCapInfo", [_capVelocity, _capFor]];

	if (_capVelocity == 0) exitWith {
		[_sector, _capProgress, 1e11, _capFor, 0] remoteExec ["OWL_fnc_srCaptureUpdate",_playerList];		
	};

	// Adjust this to deal with negative values.
	private _endTime = (_capProgress) / (-1*_capVelocity);
	if (_capVelocity > 0) then {
		_endTime = ((120-_capProgress) / _capVelocity);
	};

	_endTime = _endTime + serverTime;

	systemChat str [_endTime, _capVelocity];

	[_sector, _capProgress, _endTime, _capFor, _capVelocity] remoteExec ["OWL_fnc_srCaptureUpdate",_playerList];
};

{
	[OWL_allSectors # _x, _y] call OWL_fnc_handleSectorSeizing;
} forEach _inAreaHashMap;