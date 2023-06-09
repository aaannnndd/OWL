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
			if (position _player inArea (_x getVariable "OWL_sectorAreaOld")) then {
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

/* Quick function to get name of helipad/harbor ect. Localize later */
OWL_fnc_getAssetRequirementName = {
	params ["_requirement"];

	["Runway", "Harbor", "Helipad"] select (["A", "W", "H"] find _requirement);
};

/* This will be called multiple times on the client while trying to place objects (defense) */
/* It will be called a single time on the server to verify the placement is in fact solid   */
OWL_fnc_validateObjectPlacement = {
	params ["_object"];

	if (isNull _object) exitWith {false};
	if ((getPosASL _object)#2 < 0) exitWith {false};

	private _boundingBox = boundingBoxReal _object;
	private _posASL = getPosWorld _object;
	private _dir = direction _object;

	// Makes lines on all edges of bounding box + x's across each face
	// Add additional 75% size bounding box inside to help catch collisions
	private _corners = [];
	private _scorner = [];
	{
		private _cv = _boundingBox#1;
		_corners pushBack [_cv#0 * _x#0, _cv#1 * _x#1, _cv#2 * _x#2];
		_scorner pushBack [_cv#0 * _x#0 * 0.75, _cv#1 * _x#1 * 0.75, _cv#2 * _x#2 * 0.75];
	} forEach [ [1,1,-1], [1,-1,-1], [-1,-1,-1], [-1,1,-1], [1,1,1], [1,-1,1], [-1,-1,1], [-1,1,1] ];

	private _edges = []; 

	// verticle edges
	for "_i" from 0 to 3 do {
		private _val = if (_i < 2) then {6} else {2};
		_edges pushBack [_corners#_i, _corners#(_i+4)];
		_edges pushBack [_scorner#_i, _scorner#(_i+4)];
	};

	// top/bottom edges
	for "_i" from 0 to 6 step 2 do {
		private _low = if (_i < 4) then {1} else {5};
		private _high = if (_i <4) then {3} else {7};
		_edges pushBack [_corners#_i, _corners#(_low)];
		_edges pushBack [_corners#_i, _corners#(_high)];
		_edges pushBack [_scorner#_i, _scorner#(_low)];
		_edges pushBack [_scorner#_i, _scorner#(_high)];
	};

	// X's across each face of the box
	_edges pushBack [_corners#4, _corners#6];
	_edges pushBack [_corners#7, _corners#5];
	_edges pushBack [_corners#0, _corners#2];
	_edges pushBack [_corners#3, _corners#1];
	_edges pushBack [_corners#4, _corners#1];
	_edges pushBack [_corners#5, _corners#0];
	_edges pushBack [_corners#7, _corners#2];
	_edges pushBack [_corners#6, _corners#3];
	_edges pushBack [_corners#6, _corners#1];
	_edges pushBack [_corners#5, _corners#2];
	_edges pushBack [_corners#7, _corners#0];
	_edges pushBack [_corners#4, _corners#3];

	// rotate points around object, add them to object position.
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

OWL_fnc_getAssetPurchaseSubtotal = {
	params ["_assets"];

	private _total = 0;
	{
		(OWL_assetInfo getOrDefault [_x, ["", 0, ""]]) params ["_name", "_cost", "_requiremets"];
		if (_name == "") then {
			continue;
		};

		_total = _total + _cost;
	} forEach _assets;

	_total;
};

OWL_fnc_validateAssetPurchase = {
	params ["_player", "_assets"];

	private _cost = [_assets] call OWL_fnc_getAssetPurchaseSubtotal;
	private _funds = _player call OWL_fnc_getFunds;

	if (_cost > _funds) exitWith {
		false;
	};

	private _assetForSide = [];
	{
		{
			_assetForSide pushBack _x;
		} forEach _y;
	} forEach (OWL_assetList get (side group _player));

	private _error = false;
	{
		if (!(_x in _assetForSide)) then {
			_error = true;
		};

		(OWL_assetInfo getOrDefault [_x, ["", 0, []]]) params ["_name", "_cost", "_requirements"];
		if (_name == "") then {
			_error = true;
		};

		{
			if (!([side group player, _x] call OWL_fnc_hasAssetRequirement)) then {
				_error = true;
			};
		} forEach (_requirements);
	} forEach _assets;

	if (_error) exitWith {
		false;
	};

	true;
};

OWL_fnc_getFunds = {
	params ["_player"];

	private _funds = 0;
	if (isServer) then {
		_funds = (OWL_allWarlords getOrDefault [(owner _player), [0,[],[]]])#0; 
	} else {
		_funds = uiNamespace getVariable "OWL_UI_dummyFunds";
	};
	_funds;
};

OWL_fnc_ownsAsset = {
	params ["_player", "_asset"];

	private _ownsAsset = false;
	if (isServer) then {
		private _info = OWL_allWarlords get (owner _player);
		if (_asset in (_info#1 + _info#2)) then {
			_ownsAsset = true;
		};
	} else {
		if (_asset in OWL_playerAssets) then {
			_ownsAsset = true;
		};
	};
	_ownsAsset;
};