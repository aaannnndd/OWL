// Generate all spawn points for sectors. Positions within buildings inside the sector, that have a roof over their head.
// Potentially add a custom spawn point list later. There will be open field sectors that will have not many positions.

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