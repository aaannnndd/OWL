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