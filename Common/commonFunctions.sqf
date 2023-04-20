OWL_fnc_sectorContestedFor = {
	params ["_sector", "_side"];

	private _sideIndex = OWL_playableSides find _side;
	_sector == (OWL_contestedSector # _sideIndex);
};

OWL_fnc_sectorTicketCount = {
	params ["_sector", "_side"];

	if (_sector getVariable "OWL_sectorSide" == _side && _sector getVariable "OWL_sectorProtected") exitWith {
		1e11;
	};

	private _sideIndex = OWL_playableSides find _side;
	(_sector getVariable "OWL_sectorTickets") # _sideIndex;
};

OWL_fnc_incomeCalculation = {
	params ["_side"];
	private _income = 0;
	{
		if (_x getVariable "OWL_sectorSide" == _side) then {
			_income = _income + (_x getVariable ["OWL_sectorIncome", 0]);
		};
	} forEach OWL_allSectors;
	_income;
};

OWL_fnc_isInFriendlyZone = {
	params ["_player"];

	private _sector = objNull;
	{
		if (_x getvariable "OWL_sectorSide" == side _player) then {
			if (position player inArea (_x getVariable "OWL_sectorAreaOld")) then {
				_sector = _x;
				break;
			};
		};
	} forEach OWL_allSectors;
	_sector;
};

OWL_fnc_sectorLinkedWithBase = {
	params ["_sector", "_side"];

	_base = OWL_mainBases # (OWL_competingSides find _side);
	_visited = [];
	
	fnc_search = { 
		params ["_n"];
		if (typeOf _n != "Logic") exitWith {};
		if (_n getVariable "OWL_sectorSide" != _side && _n != _sector) exitWith {};
		if (_n in _visited) exitWith {};
		if (_base in _visited) exitWith {break};
		_visited pushBack _n;
		if (_n == _base) exitWith {};
		{
			_x call fnc_search; 
		} forEach (synchronizedObjects _n);
	};
	_sector call fnc_search;
	_base in _visited;
};

OWL_fnc_log = {
	private _msg = "[OWL] " + _this#0;
	if (OWL_devMode && hasInterface) then {
		systemChat _msg;
	};
	diag_log _msg;
};

/* Checks if sector is seizable for a given side */
OWL_fnc_sectorSeizableForSide = {
	params ["_sector", "_side"];
	
	if (!(_side in OWL_competingSides)) exitWith {
		false;
	};

	private _sideIndex = OWL_competingSides find _side;

	if ((_sector getVariable "OWL_sectorProtected") && !(_sector != OWL_contestedSector # _sideIndex)) exitWith {
		false;
	};

	true;
};

/* Check if a sector is seizable for anyone */
OWL_fnc_sectorSeizable= {
	params ["_sector"];
	
	if ((_sector getVariable "OWL_sectorProtected") && !(_sector in OWL_contestedSector)) exitWith {
		false;
	};

	true;
};

OWL_fnc_hasAssetRequirement = {
	params ["_side", "_requirement"];
	private _success = false;
	{
		private _satisfied = (_x getVariable "OWL_sectorSide" == _side) && (_requirement in (_x getVariable "OWL_sectorParam_assetRequirements"));
		if (_satisfied) then {
			_success = true;
			break;
		};
	} forEach OWL_allSectors;
	_success;
};

OWL_fnc_getAssetRequirementName = {
	params ["_requirement"];

	["Runway", "Harbor", "Helipad"] select (["A", "W", "H"] find _requirement);
};

OWL_fnc_validateObjectPlacement = {
	params ["_object"];

	if (isNull _object) exitWith {false};
	if ((getPosASL _object)#2 < 0) exitWith {false};

	private _boundingBox = boundingBoxReal _object;
	private _posASL = getPosASL _object;
	private _dir = direction _object;

	private _corners = [];
	{
		private _cv = _boundingBox#1;
		_corners pushBack [_cv#0 * _x#0, _cv#1 * _x#1, _cv#2 * _x#2];
	} forEach [ [1,1,-1], [1,-1,-1], [-1,-1,-1], [-1,1,-1], [1,1,1], [1,-1,1], [-1,-1,1], [-1,1,1] ];

	private _edges = []; 

	for "_i" from 0 to 3 do {
		private _val = if (_i < 2) then {6} else {2};
		_edges pushBack [_corners#_i, _corners#(_i+4)];
		_edges pushBack [_corners#_i, _corners#(_i+_val)];
	};
	for "_i" from 0 to 6 step 2 do {
		private _low = if (_i < 4) then {1} else {5};
		private _high = if (_i <4) then {3} else {7};
		_edges pushBack [_corners#_i, _corners#(_low)];
		_edges pushBack [_corners#_i, _corners#(_high)];
	};

	private _intersects = false;
	{
		private _s = sin (-1 * _dir);
		private _c = cos (-1 * _dir);
		private _start = (_x#0);
		private _end = (_x#1);
		_start = [_c * (_start#0) - _s * (_start#1), _s * (_start#0) + _c * (_start#1), _start#2]; 
		_end = [_c * (_end#0) - _s * (_end#1), _s * (_end#0) + _c * (_end#1), _end#2]; 
		_start = _start vectorAdd _posASL;
		_end = _end vectorAdd _posASL;
		private _startATL = ASLToATL _start;
		private _endATL = ASLToATL _end;
		if (_startATL#2 < 0) then {
			_startATL set[2, 0.2];
		};
		if (_endATL#2 < 0) then {
			_endATL set[2, 0.2];
		};
		_start = ATLToASL _startATL;
		_end = ATLToASL _endATL;
		OWL_defenseVisualLines set [_forEachIndex, [_start, _end]];
		if (!_intersects) then {
			_intersects = count (lineIntersectsObjs [_start, _end, _object]) > 0;
		};
	} forEach _edges;
	
	!_intersects;
};