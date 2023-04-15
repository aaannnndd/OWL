/*
	The below takes all units, and removes them from the list as each sector is iterated through.
	This will lessen the amount of checks, as most players are usually at main base or an airfield.

	This is the only constant function call/path of code execution that the server will process (Every 1 second)
	Optimize this and 'handleSectorSeizing' as much as possible.

	I got it 'working', but not much more.
*/

private _unitsCache = allUnits;
private _i = 0;
private _end = count _unitsCache;

// Combine both loops eventually. Original idea no longer makes sense with how ZR got set up

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

private _inAreaHashMap = createHashMap;
private _inAreaZRList = [];

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


		/* The below checks if a unit is within the main sector. If so, it adds them to the inArea list
		   If they aren't in the main zone, check the zone restriction area.

		   If a unit is found in either area, add them to the appropriate list(s) and remove them from
		   the unit cache. Main bases are index 0 and 1 in OWL_allSectors, so the list should shrink
		   very quickly, and less and less checks must happen.

		   *Improvements could be attained through an 'isPlayer' check/laze eval when dealing with zone restrictions.
		    This is unless we want to kill AI, which is currently lacking. (However move commands path them
			through cities so it's probably neccessary).
			Additionally, lazy evaluation might slow things down.
		*/

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


/* Players who were in restricted zones, but now are no longer.
   Potential improvement looping through old list, and 
   check if unit is in new list, instead of arrayDifference */
{
	// No longer kill the player.
	(_x#0) setVariable ["OWL_killTimer", nil];
	-1 remoteExec ["OWL_srZoneRestrictTimer", owner (_x#0)];
} forEach (OWL_inAreaZRList - _inAreaZRList);

/* Process zone restrictions 
   Go through current list of people in restricted zones.
   Check if they were in previous zone restriction list. */
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

// Update our 'Old List' for the next loop.
OWL_inAreaZRList = _inAreaZRList;

/* Handle sector seizing calculations for all sectors with units in them */
{
	[OWL_allSectors # _x, _y] call OWL_fnc_handleSectorSeizing;
} forEach _inAreaHashMap;