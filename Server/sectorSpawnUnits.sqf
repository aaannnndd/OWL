params ["_sector"];

private _side = _sector getVariable "OWL_sectorSide";
private _assets = _sector getVariable "OWL_sectorAssets";

private _roads = _sector nearRoads ((_sector getVariable "OWL_sectorArea")#0)*sqrt(2);
private _intersections = [];
{
	if (count (roadsConnectedTo _x) > 2) then {
		_intersections pushBack _x;
	};
} forEach _roads;

if (!(_side in OWL_competingSides)) exitWith {
	private _team = OWL_unitGroupMap get _side;
	{
		private _name = _x#0;
		private _units = _x#1;
		private _grp = createGroup _side;
		private _position = (selectRandom _roads);
		{
			_grp createUnit [_x, _position, [], 20, "FORM"];
		} forEach _units;
		_wp = _grp addWaypoint [_position, 10];
		_wp setWaypointType "MOVE";
		_wp = _grp addWaypoint [getPosATL (selectRandom _intersections),10];
		_wp setWaypointType "SAD";
		_wp = _grp addWaypoint [_position, 10];
		_wp setWaypointType "CYCLE";
	} forEach _team;
};