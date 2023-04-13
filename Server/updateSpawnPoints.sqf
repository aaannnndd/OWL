// Getting the logic hammered out here. Can later chain this into 'onSectorSideChange' hook
{
	_sector = _x;
	_respawnArr = _sector getVariable ["OWL_respawnArr", []];
	_side = _sector getVariable "OWL_sectorSide";
	if (count _respawnArr == 0) exitWith {
		_respawnArr = [_side, getPosATL _sector, _sector getVariable "OWL_sectorParam_name"] call BIS_fnc_addRespawnPosition;
		_sector setVariable ["OWL_respawnArr", _respawnArr];
	};
	
	if ( _side != (_respawnArr # 0) ) then {
		_respawnArr call BIS_fnc_removeRespawnPosition; 
		_respawnArr = [_side, _sector, _sector getVariable "OWL_sectorParam_name"] call BIS_fnc_addRespawnPosition;
		_sector setVariable ["OWL_respawnArr", _respawnArr];
	};
} forEach OWL_allSectors;

// Generate all spawn points for sectors. Positions within buildings inside the sector, that have a roof over their head.
OWL_sectorSpawnPoints = [];
{
	private _positions = [];
	private _radius = (_x getVariable "OWL_sectorArea")#0;
	private _nearestBuildings = nearestObjects [_x, ["House", "Building"], _radius*sqrt(2), true];
	{
		{
			_pos = ATLToASL _x;
			if(lineIntersects [_pos, _pos vectorAdd [0,0,300]]) then {
				_positions pushBack _x;
			};
		} forEach (_x buildingPos -1);
	} forEach _nearestBuildings;
	OWL_sectorSpawnPoints pushBack _positions;
} forEach OWL_allSectors;