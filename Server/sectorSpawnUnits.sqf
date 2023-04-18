params ["_sector"];

/******************************************************
***********		Generate Unit Compositions	***********
******************************************************/

// TODO: Put these into config .hpp files + create for alternate side compositions

OWL_genericSquad = [
	"I_Soldier_LAT2_F",
	"I_Soldier_AR_F",
	"I_Soldier_medic_F",
	"I_Soldier_F",
	"I_Soldier_SL_F"
];

OWL_aaSquad = [
	"I_Soldier_AA_F",
	"I_Soldier_AA_F",
	"I_Soldier_AAA_F",
	"I_Soldier_SL_F"
];

OWL_atSquad = [
	"I_Soldier_AT_F",
	"I_Soldier_AT_F",
	"I_Soldier_AAT_F",
	"I_Soldier_SL_F"
];

OWL_techSquad = [
	"I_engineer_F",
	"I_Soldier_repair_F",
	"I_Soldier_F",
	"I_Soldier_SL_F"
];

OWL_specSquad = [
	"I_Soldier_M_F",
	"I_Soldier_M_F",
	"I_Sniper_F",
	"I_Spotter_F"
];

OWL_guerSquad = [
	"I_C_Soldier_Para_1_F",
	"I_C_Soldier_Para_4_F",
	"I_C_Soldier_Para_2_F",
	"I_C_Soldier_Para_4_F"	
];

OWL_eliteSquadA = [
	"I_E_Soldier_AR_F",
	"I_E_medic_F",
	"I_E_soldier_M_F",
	"I_E_Soldier_F",
	"I_E_Soldier_SL_F"
];

OWL_eliteSquadB = [
	"I_E_soldier_M_F",
	"I_E_Soldier_F",
	"I_E_Soldier_F",
	"I_E_Soldier_LAT2_F",
	"I_E_Soldier_SL_F"
];

OWL_logiVehicles = [
	"I_Truck_02_ammo_F",
	"I_Truck_02_fuel_F",
	"I_Truck_02_repair_F",
	"I_G_Van_01_fuel_F",
	"I_G_Offroad_01_repair_F"
];

OWL_mrapVehicles = [
	"I_MRAP_03_gmg_F",
	"I_MRAP_03_hmg_F",
	"I_G_Offroad_01_AT_F",
	"I_G_Offroad_01_armed_F",
	"I_C_Offroad_02_AT_F"
];

OWL_lavVehicles = [
	"I_APC_Wheeled_03_cannon_F",
	"I_APC_tracked_03_cannon_F",
	"I_LT_01_AA_F",
	"I_LT_01_scout_F",
	"I_LT_01_AT_F",
	"I_LT_01_cannon_F"
];

OWL_armorVehicles = [
	"I_MBT_03_cannon_F"
];

OWL_squadSequence = [
	OWL_genericSquad,
	OWL_genericSquad,
	OWL_techSquad,
	OWL_specSquad,
	OWL_atSquad,
	OWL_genericSquad,
	OWL_genericSquad,
	OWL_atSquad,
	OWL_aaSquad,
	OWL_eliteSquadA,

	OWL_eliteSquadA,
	OWL_eliteSquadA,
	OWL_eliteSquadB,
	OWL_eliteSquadB,
	OWL_atSquad,
	OWL_atSquad,
	OWL_aaSquad
];

private _sectorWidth = (_sector getVariable "OWL_sectorArea")#0;
private _sectorRadius = _sectorWidth*sqrt(2);
private _sectorPos = getPosATL _sector;

/******************************************************
***********		Generate Road Waypoints		***********
******************************************************/
private _roadNodes = [];

// Find all road intersections
private _roads = _sector nearRoads _sectorRadius;
{
	if (count (roadsConnectedTo _x) > 2) then {
		_roadNodes pushBackUnique _x;
	};
} forEach _roads;

// Find all roads exiting the sector boundaries. Do it in steps of 7 radius 10. Add overlap as needed
private _step = 7;
private _steps = _sectorWidth*2 / _step;
{
	private _corner = _sectorPos vectorAdd [(_x#0)*_sectorWidth, (_x#1)*_sectorWidth, 0];
	private _stepvec = [0, _step, 0];
	if (_forEachIndex%2 == 1) then {
		_stepvec = [_step, 0, 0];
	};
	for "_i" from 0 to _steps do {
	 	private _pos = _corner vectorAdd (_stepvec vectorMultiply _i);
	 	private _roads = _pos nearRoads 10;

	 	if (count _roads > 0) then {
	  		_roadNodes pushBackUnique (_roads#0);
		};
	};
} forEach [[-1,-1], [-1,-1], [1,-1], [-1,1]];

/******************************************************
***********		Spawn Vehicles in Sector	***********
******************************************************/

private _side = _sector getVariable "OWL_sectorSide";
private _assets = _sector getVariable "OWL_sectorAssets";

private _sectorGroups = [];
private _sectorVehicles = [];

private _numArmor = 0;
private _numLAV = 0;
private _numLogi = 0;
private _numMRAP = 0;
private _numSquads = 0;

// Spawn editor placed assets (AI Sectors)
{
	_x params ["_vehicleClass", "_pos", "_dir", "_oldGrp"];

	private _veh = _vehicleClass createVehicle _pos;
	_veh setPos [_pos# 0, _pos # 1, 0];
	_veh setDir _dir;
	createVehicleCrew _veh;
	_veh allowCrewInImmobile TRUE;
	private _newGrp = group effectiveCommander _veh;
	_newGrp setFormDir _dir;

	private _vc = getText (configFile >> "CfgVehicles" >> _vehicleClass >> "vehicleClass");
	private _isTank = _veh isKindOf "Tank";
	private _isLogi = _vc == "Support";
	private _isArmored = _vc == "Armored";

	if (_isArmored) then {
		if (_isTank) then {
			_numArmor = _numArmor - 1;
		} else {
			_numLAV = _numLav - 1;
		};
	} else {
		if (_isLogi) then {
			_numLogi = _numLogi - 1;
		} else {
			_numMRAP = _numMRAP - 1;
		};
	};

	if ((count waypoints _oldGrp) > 1) then {
		_newGrp copyWaypoints _oldGrp;
	} else {
		private _wp = _newGrp addWaypoint [selectRandom _roadNodes, 0];
		_wp setWaypointType "SAD";
		_wp = _newGrp addWaypoint [selectRandom _roadNodes, 0];
		_wp setWaypointType "SAD";
		_wp = _newGrp addWaypoint [selectRandom _roadNodes, 0];
		_wp setWaypointType "CYCLE";
	};
	deleteGroup _oldGrp;
	_sectorGroups pushBack _newGrp;
	_sectorVehicles pushBack _veh;
} forEach _assets;

private _reqs = _sector getVariable "OWL_sectorRequirements";
if ("H" in _reqs && "A" in _reqs) then {
	_numArmor = _numArmor + 1;
	_numMRAP = _numMRAP + 2;
	_numLAV = _numLAV + 2;
	_numLogi = _numLogi + 1;
	_numSquads = 12;
} else {
	_numArmor = _numArmor + floor (_sectorWidth / 150);
	_numMRAP = _numMRAP + floor (_sectorWidth / 100);
	_numLAV = _numLav + floor (_sectorWidth / 100);
	_numLogi = _numLogi + floor (_sectorWidth / 200);
	_numSquads = floor (_sectorWidth / 25);
};

for "_i" from 0 to (_numSquads-1) do {
	private _squad = OWL_squadSequence # _i;
	private _grp = createGroup RESISTANCE;
	private _pos = selectRandom _roadNodes;
	if (count _roadNodes == 0) then {
		_pos =  [_sectorPos, 40, _sectorWidth*1.4, 3, 0, 20, 0] call BIS_fnc_findSafePos;

		private _cnt = 0;
		while {count _pos == 0} do {
			_pos = _sectorPos findEmptyPosition [20+_cnt*10, _sectorWidth*2];
		};
	};

	{
		_grp createUnit [_x, _pos, [], 20, "FORM"];
	} forEach _squad;

	private _wp = _grp addWaypoint [_pos, _sectorWidth];
	_wp setWaypointType "SAD";
	_wp = _grp addWaypoint [_sectorPos, _sectorWidth];
	_wp setWaypointType "SAD";
	_wp = _grp addWaypoint [_sectorPos, _sectorWidth];
	_wp setWaypointType "CYCLE";
	_sectorGroups pushBack _grp;
};

if (_numMRAP > 0) then {
	for "_i" from 0 to (_numMRAP-1) do {
		private _vehClass = selectRandom OWL_mrapVehicles;
		private _pos = _sectorPos findEmptyPosition [30, _sectorWidth*2, _vehClass];

		private _cnt = 0;
		while {count _pos == 0} do {
			_pos = _sectorPos findEmptyPosition [30+_cnt*10, _sectorWidth*2, _vehClass];
		};

		private _vehicle = _vehClass createVehicle _pos;
		createVehicleCrew _vehicle;
		private _grp = group effectiveCommander _vehicle;

		private _wp = _grp addWaypoint [_pos, _sectorWidth];
		_wp setWaypointType "SAD";
		_wp = _grp addWaypoint [_sectorPos, _sectorWidth];
		_wp setWaypointType "SAD";
		_wp = _grp addWaypoint [_sectorPos, _sectorWidth];
		_wp setWaypointType "CYCLE";
		_sectorGroups pushBack _grp;

		_sectorVehicles pushBack _vehicle;
	};
};

if (_numLAV > 0) then {
	for "_i" from 0 to (_numLAV-1) do {
		private _vehClass = selectRandom OWL_lavVehicles;
		private _pos = _sectorPos findEmptyPosition [20, _sectorWidth*2, _vehClass];

		private _cnt = 0;
		while {count _pos == 0} do {
			_pos = _sectorPos findEmptyPosition [20+_cnt*10, _sectorWidth*2, _vehClass];
		};

		private _vehicle = _vehClass createVehicle _pos;
		createVehicleCrew _vehicle;
		private _grp = group effectiveCommander _vehicle;

		private _wp = _grp addWaypoint [_pos, _sectorWidth];
		_wp setWaypointType "SAD";
		_wp = _grp addWaypoint [_sectorPos, _sectorWidth];
		_wp setWaypointType "SAD";
		_wp = _grp addWaypoint [_sectorPos, _sectorWidth];
		_wp setWaypointType "CYCLE";
		_sectorGroups pushBack _grp;
		_sectorVehicles pushBack _vehicle;
	};
};

if (_numLogi > 0) then {
	
	for "_i" from 0 to (_numLogi-1) do {
		private _vehClass = selectRandom OWL_logiVehicles;
		private _pos = _sectorPos findEmptyPosition [10, _sectorWidth*2, _vehClass];

		private _cnt = 0;
		while {count _pos == 0} do {
			_pos = _sectorPos findEmptyPosition [10+_cnt*10, _sectorWidth*2, _vehClass];
		};

		private _adjSector = objNull;
		{
			if (typeOf _x == "Logic" && _x getVariable "OWL_sectorSide" == RESISTANCE) then {
				_adjSector = _x;
				break;
			};
		} forEach (synchronizedObjects _sector);

		private _vehicle = _vehClass createVehicle _pos;
		createVehicleCrew _vehicle;
		private _grp = group effectiveCommander _vehicle;
		if (!isNull _adjSector) then {
			private _wp = _grp addWaypoint [getPosATL _adjSector, 50];
			_wp setWaypointType "MOVE";
			_wp = _grp addWaypoint [_pos, 0];
			_wp setWaypointType "MOVE";
			_wp = _grp addWaypoint [_pos, 0];
			_wp setWaypointType "CYCLE";
			systemChat str _adjSector;
		} else {
			private _wp = _grp addWaypoint [_sectorPos, _sectorWidth*3];
			_wp setWaypointType "MOVE";
			_wp = _grp addWaypoint [_sectorPos, _sectorWidth*3];
			_wp setWaypointType "MOVE";
			_wp  = _grp addWaypoint [_sectorPos, _sectorWidth*3];
			_wp setWaypointType "CYCLE";
		};
		_sectorGroups pushBack _grp;
		_sectorVehicles pushBack _vehicle;
	};
};

if (_numArmor > 0) then {
	for "_i" from 0 to (_numArmor-1) do {
		private _vehClass = selectRandom OWL_armorVehicles;
		private _pos = _sectorPos findEmptyPosition [30, _sectorWidth*2, _vehClass];
		private _vehicle = _vehClass createVehicle _pos;
		createVehicleCrew _vehicle;
		private _grp = group effectiveCommander _vehicle;

		private _wp = _grp addWaypoint [_pos, _sectorWidth];
		_wp setWaypointType "SAD";
		_wp = _grp addWaypoint [_sectorPos, _sectorWidth*1.4];
		_wp setWaypointType "SAD";
		_wp = _grp addWaypoint [_sectorPos, _sectorWidth];
		_wp setWaypointType "CYCLE";

		_sectorGroups pushBack _grp;
		_sectorVehicles pushBack _vehicle;
	};
};

if (random 100 > 66) then {
	private _adjSector = objNull;
	{
		if (typeOf _x == "Logic" && _x getVariable "OWL_sectorSide" == RESISTANCE) then {
			_adjSector = _x;
			break;
		};
	} forEach (synchronizedObjects _sector);

	private _units = OWL_eliteSquadA + OWL_atSquad + OWL_eliteSquadB +OWL_aaSquad + OWL_eliteSquadB;
	if(!isNull _adjSector) then {
		private _safePos = (getPosATL _adjSector) nearRoads 200;
		_safePos = getPosATL (_safePos#0);
		private _veh = createVehicle ["I_Truck_02_transport_F", _safePos findEmptyPosition [0,50,"I_Truck_02_transport_F"]];
		createVehicleCrew _veh;
		private _grp = group (effectiveCommander _veh);
		for "_i" from 0 to ((_veh emptyPositions "") - 1) do {
			private _unit = _grp createUnit [_units # _i, position _veh, [], 0, "FORM"];
			_unit moveInAny _veh;			
		};
		private _wp = 0;
		if (count _roadNodes > 0) then {
			_wp = _grp addWaypoint [selectRandom _roadNodes, 0];
		} else {
			if (count _roads > 0) then {
				_wp = _grp addWaypoint [getPosATL (selectRandom _roads), 0];
			} else {
				_wp = _grp addWaypoint [_sectorPos, 100];
			};
		};
		_wp setWaypointType "GETOUT";
		private _wp = _grp addWaypoint [_sectorPos, 100];
		_wp setWaypointType "SAD";
		private _wp = _grp addWaypoint [_sectorPos, 100];
		_wp setWaypointType "SAD";
		private _wp = _grp addWaypoint [_sectorPos, 100];
		_wp setWaypointType "CYCLE";

		_sectorGroups pushBack _grp;
		_sectorVehicles pushBack _veh;
	};
};

// WHen sector is captured, use these to send them elsewhere / center of sector.
_sector setVariable ["OWL_sectorGroups", _sectorGroups];
_sector setVariable ["OWL_sectorVehicles", _sectorVehicles];
/******************************************************
***********		Generate Unit Compositions	***********
******************************************************/

// I_E_Heli_light_03_unarmed_F

/*

// Vehicles

OWL_lavVehicles = [
	"I_APC_Wheeled_03_cannon_F",
	"I_APC_tracked_03_cannon_F"
];

OWL_armorVehicles = [
	"I_MBT_03_cannon_F"
];

I_APC_Wheeled_03_cannon_F // gorgon
I_APC_tracked_03_cannon_F // mora

I_LT_01_AA_F // nyxaa
I_LT_01_scout_F // nyx radar

I_LT_01_AT_F // nyxat
I_LT_01_cannon_F // nyx autocannon

I_MBT_03_cannon_F // kuma

I_MRAP_03_gmg_F
I_MRAP_03_hmg_F

// AAF
I_Soldier_A_F
I_Soldier_AAT_F
I_Soldier_AAA_F
I_medic_F
I_engineer_F
I_Soldier_exp_F
I_Soldier_M_F
I_Soldier_AA_F
I_Soldier_AT_F
I_Soldier_repair_F
I_Soldier_F
I_Soldier_LAT2_F
I_Soldier_SL_F

I_Sniper_F
I_Spotter_F

I_Truck_02_ammo_F
I_Truck_02_fuel_F
I_Truck_02_repair_F
I_G_Van_01_fuel_F
I_G_Offroad_01_repair_F

I_Truck_02_transport_F
I_Heli_light_03_unarmed_F
// FIA
I_G_Soldier_A_F
I_G_Soldier_AR_F
I_G_medic_F
I_G_engineer_F
I_G_Soldier_exp_F
I_G_Soldier_M_F
I_G_Soldier_LAT_F
I_G_Soldier_LAT2_F
I_G_Sharpshooter_F
I_G_Soldier_SL_F

I_G_Van_01_fuel_F
I_G_Offroad_01_AT_F
I_G_Offroad_01_armed_F
I_G_Offroad_01_repair_F
I_G_Van_02_vehicle_F // transport

// LDF

I_E_Soldier_AAA_F
I_E_Soldier_AAT_F
I_E_Soldier_AR_F
I_E_Soldier_AR_F
I_E_medic_F
I_E_engineer_F
I_E_Soldier_Exp_F
I_E_soldier_M_F
I_E_Soldier_AT_F
I_E_Soldier_AA_F
I_E_Soldier_F
I_E_Soldier_LAT2_F
I_E_Soldier_SL_F

// Syndicate

I_C_Offroad_02_AT_F
I_C_Offroad_02_LMG_F
I_C_Offroad_02_unarmed_F

I_C_Heli_Light_01_civil_F

I_C_Soldier_Para_1_F // rifle
I_C_Soldier_Para_4_F // mg
I_C_Soldier_Para_2_F // rifle
I_C_Soldier_Para_4_F // launcher
 */

 /*0 spawn {
  private _sector = (OWL_allSectors # 44); 
  private _sectorWidth = (_sector getVariable "OWL_sectorArea")#0; 
  private _sectorPos = getPosATL _sector;  
  private _intersections = [];  
  {  
   private _corner = _sectorPos vectorAdd [(_x#0)*_sectorWidth, (_x#1)*_sectorWidth, 0];  
   private _step = [0, 10, 0];  
   if (_forEachIndex%2 == 1) then {  
    _step = [10, 0, 0];  
   };  
   for "_i" from 0 to (_sectorWidth/5) do {  
    private _pos = _corner vectorAdd (_step vectorMultiply _i);  
    private _roads = _pos nearRoads 10;
    _marker = createMarkerLocal [str _pos, _pos];
    _marker setMarkerSizeLocal [5,5];
    _marker setMarkerColorLocal "ColorWhite";
    _marker setMarkerAlphaLocal 1;
    _marker setMarkerBrushLocal "Solid";
    _marker setMarkerShapeLocal "ELLIPSE";
  
    if (count _roads > 0) then {  
     _intersections pushBackUnique (_roads#0);
    };  
   };  
  } forEach [[-1,-1], [-1,-1], [1,-1], [-1,1]];

  {
	sleep 2;
	player setPosATL (getPosATL _X);
  } forEach _intersections;
};*/

/* 
_pos = getPosASL player findEmptyPosition [11, 50, "B_MBT_01_TUSK_F"];
createVehicle ["B_MBT_01_TUSK_F", _pos, [], 20, "NONE"];

allowCrewInImmobile -> will dismount when immobilized
*/