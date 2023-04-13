_data regexFind ["(this setVariable [""OWL_sectorParam_hasHarbour"", )()", startOffset];

_output = "NoOutput"; 
all3DENEntities params ["_objects", "_groups", "_triggers", "_systems", "_waypoints", "_markers", "_layers", "_comments"]; 
{ 
 _data = (_x get3DENAttribute "init")#0;   
  
 _output = _data;
} forEach _systems;
_output;

all3DENEntities params ["_objects", "_groups", "_triggers", "_systems", "_waypoints", "_markers", "_layers", "_comments"]; 
{ 
 _data = (_x get3DENAttribute "init")#0;   

 _harbor = _data regexFind ["""OWL_sectorParam_hasHarbour"", (true|false)", 0];    
 _harbor = (((_harbor#0)#1)#0) == "true";  
 _helipad = _data regexFind ["""OWL_sectorParam_hasHelipad"", (true|false)", 0];    
 _helipad = (((_helipad#0)#1)#0) == "true";  
 _runway = _data regexFind ["""OWL_sectorParam_hasRunway"", (true|false)", 0];    
 _runway = (((_runway#0)#1)#0) == "true";

 _data = "this setVariable [""OWL_sectorParam_name"", ""Opfor Base""]"; 
_name_res = _data regexFind ['"OWL_sectorParam_name", "(.*?)"', 0]; 
(_name_res # 0 # 1) params ["_name", "_pos"];

 _start = _pos; 
 _end = count _name + _start;

_string_table_id = toLower ((_name splitString " ") joinString "_");
_string_table_id = format ["@STR_A3_OWL_sector_name_%1", _string_table_id];

 _output = (_data select [0, _start]) + _string_table_id + (_data select [_end, (count _data)-_end-1]); 
 
 _reqs = ""; 
 if (_runway) then {_reqs = _reqs + "A"}; 
 if (_harbor) then {_reqs = _reqs + "W"}; 
 if (_helipad) then {_reqs = _reqs + "H"}; 
 
 _output = _output + "
" + format ["this setVariable [""OWL_sectorParam_assetRequirements"", ""%1""]", _reqs];

 _x set3DENAttribute ["init", _output];
} forEach _systems;

all3DENEntities params ["_objects", "_groups", "_triggers", "_systems", "_waypoints", "_markers", "_layers", "_comments"]; 
{ 
 _data = (_x get3DENAttribute "init")#0;   
_name_res = _data regexFind ['"OWL_sectorParam_name", "(.*?)"', 0]; 
(_name_res # 0 # 1) params ["_name", "_pos"];

 _start = _pos; 
 _end = count _name + _start;

_string_table_id = toLower ((_name splitString " ") joinString "_");
_string_table_id = format ["@STR_A3_OWL_sector_name_%1", _string_table_id];

 _output = (_data select [0, _start]) + _string_table_id + (_data select [_end, (count _data)-_end]); 
 _x set3DENAttribute ["init", _output];
} forEach _systems;


/**
if(!isNil"testdisplay") then {testdisplay closeDisplay 0};
    testdisplay = findDisplay 46 createDisplay "RscDisplayEmpty";


testTableTexture = "table" + (diag_frameno toFixed 0);

testTable setObjectTexture [0, format["#(rgb,1024,1024,1)ui('RscDisplayEmpty','%1')", testTableTexture]];

onEachFrame {
    private _display = findDisplay testTableTexture;
    testdisplay = _display;

    if(isNull _display) exitWith {};

	for "_i" from 0 to 999 do {
		private _ctrlBackground = _display ctrlCreate ["RscText", -1];
		private _row = floor (_i / 40);
		private _col = floor (_i % 40);
		_ctrlBackground ctrlSetBackgroundColor [1,1,1,1];
		_ctrlBackground ctrlSetPosition [safezoneX+(safezoneW/40)*_col, safezoneY+(safezoneH/25)*_row, safezoneW/40, safezoneH/25];
		_ctrlBackground ctrlSetText format ["%2", _row, _col];
		_ctrlBackground ctrlCommit 0;
	};
//13:19
//9.5:30.5
	displayUpdate _display;
    //private _ctrl_map = _display ctrlCreate ["RscMapControl", -1];
    //_ctrl_map ctrlSetPosition [safezoneX+(safezoneH*0.5), safezoneY+safezoneH, safezoneH*0.5, safezoneH*0.5];
   // _ctrl_map ctrlCommit 0;
	//() params ["_xrel", "_yrel", "_w", "_h"];
	//_ctrl_map ctrlMapSetPosition [0, 0, 2, 2.5];

    //testmap = _ctrl_map;

    //_ctrl_map ctrlMapAnimAdd [0,1, mapcenter];
    //ctrlMapAnimCommit _ctrl_map;

    //displayUpdate _display;

    onEachFrame {
        testmap ctrlMapAnimAdd [0, linearConversion [-1, 1, cos((((-1 + diag_tickTime % 6)) max 0 min 5) / 5 * 360), 0.001, 1],mapcenter];
        ctrlMapAnimCommit testmap;
        displayUpdate testdisplay;
    };
}; */


mapcenter = [worldSize / 2, worldSize / 2, 0]; 
if(!isNil"testTable") then {deleteVehicle testTable}; 
testTable = createVehicle ["Land_BriefingRoomDesk_01_F", player modelToWorld [0, 2, 0], [], 0, "CAN_COLLIDE"]; 
testTable setDir (testTable getDir player); 
testTable enableSimulation false; 
testTable setObjectTexture [0, format["#(rgb,1024,1024,1)ui('RscDisplayEmpty','%1')", "tabletexture"]]; 
 
[] spawn {     
 sleep 1; 
 _display = findDisplay "tabletexture"; 
 _back = _display displayCtrl -1; 
 if (isNull _back) then { 
  _back = _display ctrlCreate ["RscText", -1]; 
 }; 
 _back ctrlSetBackgroundColor [1,0,0,1]; 
 _back ctrlSetPosition [0, 0.5, 1, 0.5]; 
 _back ctrlCommit 0;

 _map = _display displayCtrl 22;
 if(isNull _map) then {
  _map = _display ctrlCreate ["RscMapControl", 22];
  _map ctrlSetPosition [0.25, 0.5, 0.5, 0.5];
  _map ctrlSetScale 0.5;
  _map ctrlCommit 0;
 };
 systemChat str (_map ctrlMapWorldToScreen (getPosWorld player));
  //_map ctrlMapSetPosition [0.25,0.5,0.5,0.5];
  _map ctrlMapAnimAdd [0, 1, [4098,4098]]; 
 ctrlMapAnimCommit _map;
  _map ctrlCommit 0;
 sleep 0.1;
 displayUpdate _display; 
};

[] spawn {    
	sleep 1;
	_display = findDisplay "tabletexture";
	_back = _display displayCtrl -1;
	if (isNull _back) then {
		_back = _display ctrlCreate ["RscText", -1];
	};
	_back ctrlSetBackgroundColor [1,0,0,1];
	_back ctrlSetPosition [0.05, 0.290476, 0.952381, 0.571429];
	_back ctrlCommit 0;

    displayUpdate _display;
};



	for "_i" from 0 to 999 do {
		_col = (_i % 40);
		_row = floor (_i / 40);
		_background = _display ctrlCreate ["RscText", -1]; 
		_background ctrlSetBackgroundColor [1*(_col/40),1*(_col/40),1,1];
		_background ctrlSetPosition [safezoneX+(safezoneW/40)*_col,safezoneY+(safezoneH/25)*_row,safezoneW/40,safezoneH/25]; 
		_background ctrlSetText format ["%1", _row]; 
		_background ctrlCommit 0;
	};



_pos = position player vectorAdd [0,0,200];//[4418.87,20863.4,300.3113];
_dir = 0;//180.3;
_pos2 = [7656.433,17431.123,219.651];
if (!alive (vehicle player)) then {
    deleteVehicle (vehicle player);
    moveOut player;
};

if (vehicle player == player) then {
player moveInDriver createVehicle ["B_Plane_Fighter_01_F", _pos, [], 0, "FLY"];};

(vehicle player) setVehicleAmmo 1;
(vehicle player) allowDamage true;
(vehicle player) setDamage 0;

(vehicle player) setPosATL _pos; (vehicle player) setDir _dir;
(vehicle player) setVelocityModelSpace [0,194,0];
player allowDamage false;

_pos = [1190.65,20900.9,400.16]; 
_dir = 95;//180;//180.3; 
_pos2 = [7656.433,17431.123,219.651]; 
if (!alive (vehicle player)) then { 
    deleteVehicle (vehicle player); 
    moveOut player; 
}; 
 
if (vehicle player == player) then { 
player moveInDriver createVehicle ["B_Plane_Fighter_01_F", _pos, [], 0, "FLY"];}; 
 
(vehicle player) setVehicleAmmo 1; 
(vehicle player) allowDamage true; 
(vehicle player) setDamage 0; 
 
(vehicle player) setPosATL _pos; (vehicle player) setDir _dir; 
(vehicle player) setVelocityModelSpace [0,194,0]; 
player allowDamage false;

{
	_stringInterpretation = str _x;
	_obj = _x;
	{
		if (_x in _stringInterpretation) then {
			hideObjectGlobal _obj;
		};
	} forEach ["b_ficusc2d_f.p3d", "wired_fence_8m_f.p3d", "wired_fence_4m_f.p3d","powerpolewooden_small_f.p3d","powerpolewooden_f.p3d"];
																																																					
	if ( (typeOf _x) in ["Land_HighVoltageColumn_F", "Land_HighVoltageColumnWire_F", "Land_HighVoltageTower_large_F", "Land_PowerWireBig_direct_F","Land_PowerWireBig_direct_short_f","Land_PowerWireBig_end_F", "Land_PowerWireBig_direct_short_F", "Land_HighVoltageTower_largeCorner_F", "Land_PowerWireBig_right_F", "Land_PowerWireBig_left_F"] ) then { 
    	hideObjectGlobal _x; 
	};
} forEach (nearestObjects [position player,[],2000]);

_pos = getPosATL player;
_dir = getDir player;  
if (!alive (vehicle player)) then {  
    deleteVehicle (vehicle player);  
    moveOut player;  
};  
  
if (vehicle player == player) then {  
player moveInDriver createVehicle ["B_Plane_Fighter_01_F", _pos, [], 0, "FLY"];};  
  
(vehicle player) setVehicleAmmo 1;  
(vehicle player) allowDamage true;  
(vehicle player) setDamage 0;  
  
(vehicle player) setPosATL _pos; (vehicle player) setDir _dir;  
(vehicle player) setVelocityModelSpace [0,194,0];  
player allowDamage false;