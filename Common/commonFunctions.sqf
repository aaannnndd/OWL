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
