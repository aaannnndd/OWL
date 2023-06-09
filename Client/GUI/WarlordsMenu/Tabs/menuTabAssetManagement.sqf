params ["_display", "_tabIdx"];

private _curIdc = _tabIdx * 1000;

if (!isNull (_display displayCtrl _curIdc)) exitWith {};

_pos = ctrlPosition (_display displayCtrl 98);
_pos params ["_xrel", "_yrel", "_wrel", "_hrel"];
_wb = _wrel / 40;
_hb = _hrel / 25;

/***********************************************
***************[ Manage Assets ]****************
***********************************************/

/*
	1). Sector Selection to manage a sectors assets / purchase for sector
	2). Asset management section for personal vehicles.
	3). Lock/Unlock Asset
	4). Delete Asset
	5). Turn on/off Engine
	6). Turn on/off lights
	7). Turn on/off Radar
	8). Add asset to sector re-enforcements.
	9). Ability to 'take out' vehicles from the sector re-enforcements if you purchased them.
*/

/*
	[Squad][Assets]					Sector Name

	[List	]			|		[dropdown sector select]
	[list	]			|   [asset list]	purchase
	[list	]			|	[asset list]	asset x/3
	[list	]			|	[asset list]	asset x/10
	[delete]			|	[asset list]	asset x/30
	[lock]				|	[asset list]	
	[lights]			|		[dropdown menu asset]
	[radar]				|			[purchase asset]
	[>>	addtosector >>	|	<< removefromsector	<<		]
*/

private _asset_mgmt_button_squad = _display ctrlCreate ["RscButtonMenu", _tabIdx call OWL_fnc_TabIDC];
_asset_mgmt_button_squad ctrlSetPosition [_xrel+0.5*_wb, _yrel+_hb*3, _wb*3.95, _hb*1];
_asset_mgmt_button_squad ctrlSetStructuredText parseText "Squad";
_asset_mgmt_button_squad ctrlCommit 0;

private _asset_mgmt_button_assets = _display ctrlCreate ["RscButtonMenu", _tabIdx call OWL_fnc_TabIDC];
_asset_mgmt_button_assets ctrlSetPosition [_xrel+0.5*_wb+_wb*4, _yrel+_hb*3, _wb*4, _hb*1];
_asset_mgmt_button_assets ctrlSetStructuredText parseText "Assets";
_asset_mgmt_button_assets ctrlCommit 0;

private _asset_mgmt_asset_list = _display ctrlCreate ["RscListBox", _tabIdx call OWL_fnc_TabIDC];
_asset_mgmt_asset_list ctrlSetPosition [_xrel+0.5*_wb, _yrel+_hb*4.25, _wb*8, _hb*7];
_asset_mgmt_asset_list ctrlCommit 0;

_asset_mgmt_asset_list lbAdd "Select Squad Or Assets";

uiNamespace setVariable ["OWL_UI_asset_mgmt_asset_list", _asset_mgmt_asset_list];

OWL_fnc_UI_assetControlHandle = {
	params ["_asset", "_controlName", "_control"];

	private _res = false;

	if (isNull _asset) exitWith {false};

	switch (_controlName) do {
		case "delete":
		{
			_res = (owner _asset == owner player);
		};
		case "lock":
		{
			_control ctrlSetStructuredText parseText (if (locked _asset == 2) then {localize "STR_A3_cfgvehicles_miscunlock_f_0"} else {localize "STR_A3_cfgvehicles_misclock_f_0"});	
			_res = (owner _asset == owner player);
		};
		case "lights":
		{	
			_control ctrlSetStructuredText parseText (if (isLightOn _asset) then {"Lights off"} else {"Lights on"});		
			_res = (owner _asset == owner player);
		};
		case "engine":
		{
			_control ctrlSetStructuredText parseText (if (isEngineOn _asset) then {"Engine off"} else {"Engine on"});	
			_res = (owner _asset == owner player);
		};
		case "radar":
		{
			private _radarComponent =  (_asset isVehicleSensorEnabled "ActiveRadarSensorComponent");
			if (count _radarComponent > 0) then {
				_radarComponent = _radarComponent#0#1;
			} else {
				_radarComponent = false;
			};

			_res = (owner _asset == owner player) && !isNull (effectiveCommander _asset) && _radarComponent;
		};
		case "kick":
		{
			private _toKick = false;
			{
				if (group _x != group player) then {
					_toKick = true;
				};
			} forEach crew _asset;
			_res = (owner _asset == owner player) && _toKick;
		};
		case "clear":
		{
			_res = (owner _asset == owner player);
		};
	};
	_control ctrlCommit 0;
	_res;
};

_asset_mgmt_asset_list ctrlAddEventHandler ["LBSelChanged", {
	params ["_list", "_index"];

	private _selected = _list lbData _index;
	_selected = _selected call BIS_fnc_objectFromNetId;
	private _delete = uiNamespace getVariable ["OWL_UI_asset_mgmt_button_delete", controlNull];
	private _lock = uiNamespace getVariable ["OWL_UI_asset_mgmt_button_lock", controlNull];
	private _lights = uiNamespace getVariable ["OWL_UI_asset_mgmt_button_lights", controlNull];
	private _engine = uiNamespace getVariable ["OWL_UI_asset_mgmt_button_engine", controlNull];
	private _radar = uiNamespace getVariable ["OWL_UI_asset_mgmt_button_radar", controlNull];
	private _kick = uiNamespace getVariable ["OWL_UI_asset_mgmt_button_kick", controlNull];
	private _clear = uiNamespace getVariable ["OWL_UI_asset_mgmt_button_clear", controlNull];

	if (isNull _selected) then {
		_delete ctrlEnable false;
		_lock ctrlEnable false;
		_lights ctrlEnable false;
		_engine ctrlEnable false;
		_radar ctrlEnable false;
		_clear ctrlEnable false;
		_kick ctrlEnable false;

	} else {
		_delete ctrlEnable ([_selected, "delete", _delete] call OWL_fnc_UI_assetControlHandle);
		_lock ctrlEnable ([_selected, "lock", _lock] call OWL_fnc_UI_assetControlHandle);
		_lights ctrlEnable ([_selected, "lights", _lights] call OWL_fnc_UI_assetControlHandle);
		_engine ctrlEnable ([_selected, "engine", _engine] call OWL_fnc_UI_assetControlHandle);
		_radar ctrlEnable ([_selected, "radar", _radar] call OWL_fnc_UI_assetControlHandle);
		_kick ctrlEnable ([_selected, "kick", _kick] call OWL_fnc_UI_assetControlHandle);
		_clear ctrlEnable ([_selected, "clear", _clear] call OWL_fnc_UI_assetControlHandle);
	};
}];

_asset_mgmt_button_squad ctrlAddEventHandler ["ButtonClick", {

	private _list = uiNamespace getVariable ["OWL_UI_asset_mgmt_asset_list", controlNull];
	lbClear _list;
	private _arr = ((units group player) - [player]);
	{
		_list lbAdd getText (configFile >> "CfgVehicles" >> typeOf _x >> "displayName");
		_list lbSetValue [(lbSize _list) - 1, _forEachIndex];
		_list lbSetData [(lbSize _list) - 1, netId _x];
	} forEach _arr;
	if (count _arr == 0) then {
		_list lbAdd "No Squad Members";
	};
	_list ctrlCommit 0;
}];

_asset_mgmt_button_assets ctrlAddEventHandler ["ButtonClick", {
	private _list = uiNamespace getVariable ["OWL_UI_asset_mgmt_asset_list", controlNull];
	lbClear _list;
	{
		_list lbAdd getText (configFile >> "CfgVehicles" >> typeOf _x >> "displayName");
		_list lbSetValue [(lbSize _list) - 1, _forEachIndex];
		_list lbSetData [(lbSize _list) - 1, netId _x];
	} forEach OWL_playerAssets;
	if (count OWL_playerAssets == 0) then {
		_list lbAdd "No Owned Assets";
	};
	_list ctrlCommit 0;
}];

_asset_mgmt_asset_list ctrlCommit 0;

_asset_mgmt_button_delete = _display ctrlCreate ["RscButtonMenu", _tabIdx call OWL_fnc_TabIDC];
_asset_mgmt_button_lock = _display ctrlCreate ["RscButtonMenu", _tabIdx call OWL_fnc_TabIDC];
_asset_mgmt_button_lights = _display ctrlCreate ["RscButtonMenu", _tabIdx call OWL_fnc_TabIDC];
_asset_mgmt_button_engine = _display ctrlCreate ["RscButtonMenu", _tabIdx call OWL_fnc_TabIDC];
_asset_mgmt_button_radar = _display ctrlCreate ["RscButtonMenu", _tabIdx call OWL_fnc_TabIDC];
_asset_mgmt_button_kick = _display ctrlCreate ["RscButtonMenu", _tabIdx call OWL_fnc_TabIDC];
_asset_mgmt_button_clear = _display ctrlCreate ["RscButtonMenu", _tabIdx call OWL_fnc_TabIDC];

_asset_mgmt_button_delete ctrlSetPosition [_xrel+0.5*_wb, _yrel+_hb*11.5, _wb*3.95, _hb*1];
_asset_mgmt_button_lock ctrlSetPosition [_xrel+4.5*_wb, _yrel+_hb*11.5, _wb*4, _hb*1];
_asset_mgmt_button_lights ctrlSetPosition [_xrel+0.5*_wb, _yrel+_hb*12.55, _wb*3.95, _hb*1];
_asset_mgmt_button_engine ctrlSetPosition [_xrel+4.5*_wb, _yrel+_hb*12.55, _wb*4, _hb*1];
_asset_mgmt_button_radar ctrlSetPosition [_xrel+0.5*_wb, _yrel+_hb*13.55, _wb*3.95, _hb*1];
_asset_mgmt_button_kick ctrlSetPosition [_xrel+4.5*_wb, _yrel+_hb*13.55, _wb*4, _hb*1];
_asset_mgmt_button_clear ctrlSetPosition [_xrel+0.5*_wb, _yrel+_hb*14.55, _wb*8, _hb*1];

_asset_mgmt_button_delete ctrlSetStructuredText parseText "Delete";
_asset_mgmt_button_lock ctrlSetStructuredText parseText "Lock/Unlock";
_asset_mgmt_button_lights ctrlSetStructuredText parseText "Lights on/off";
_asset_mgmt_button_engine ctrlSetStructuredText parseText "Engine on/off";
_asset_mgmt_button_radar ctrlSetStructuredText parseText "Radar on/off";
_asset_mgmt_button_kick ctrlSetStructuredText parseText "Kick crew";
_asset_mgmt_button_kick ctrlSetTooltip "Remove non-squad members from vehicle.";
_asset_mgmt_button_clear ctrlSetStructuredText parseText "Clear inv";
_asset_mgmt_button_clear ctrlSetTooltip "Clear all items from vehicle inventory.";

_asset_mgmt_button_delete ctrlCommit 0;
_asset_mgmt_button_lock ctrlCommit 0;
_asset_mgmt_button_lights ctrlCommit 0;
_asset_mgmt_button_engine ctrlCommit 0;
_asset_mgmt_button_radar ctrlCommit 0;
_asset_mgmt_button_kick ctrlCommit 0;
_asset_mgmt_button_clear ctrlCommit 0;

uiNamespace setVariable ["OWL_UI_asset_mgmt_button_delete", _asset_mgmt_button_delete];
uiNamespace setVariable ["OWL_UI_asset_mgmt_button_lock", _asset_mgmt_button_lock];
uiNamespace setVariable ["OWL_UI_asset_mgmt_button_lights", _asset_mgmt_button_lights];
uiNamespace setVariable ["OWL_UI_asset_mgmt_button_engine", _asset_mgmt_button_engine];
uiNamespace setVariable ["OWL_UI_asset_mgmt_button_radar", _asset_mgmt_button_radar];
uiNamespace setVariable ["OWL_UI_asset_mgmt_button_kick", _asset_mgmt_button_kick];
uiNamespace setVariable ["OWL_UI_asset_mgmt_button_clear", _asset_mgmt_button_clear];

OWL_fnc_UI_mgmt_getSelected = {
	private _list = uiNamespace getVariable ["OWL_UI_asset_mgmt_asset_list", controlNull];
	private _selected = lbCurSel _list;
	_selected = _list lbData _selected;
	_selected = _selected call BIS_fnc_objectFromNetId;
	if (!isNull _selected) exitWith {
		_selected;
	};
	objNull;
};

_asset_mgmt_button_delete ctrlAddEventHandler ["ButtonClick", {
	_selected = call OWL_fnc_UI_mgmt_getSelected;
	if (!isNull _selected) then {
		_selected remoteExec ["OWL_fnc_crRemoveAsset", 2];
	};
}];

_asset_mgmt_button_lock ctrlAddEventHandler ["ButtonClick", {
	_selected = call OWL_fnc_UI_mgmt_getSelected;
	if (!isNull _selected) then {
		_selected lock abs (locked _selected - 2);
		(_this#0) ctrlSetStructuredText parseText (if (locked _selected == 2) then {localize "STR_A3_cfgvehicles_miscunlock_f_0"} else {localize "STR_A3_cfgvehicles_misclock_f_0"});	
	};
}];

_asset_mgmt_button_lights ctrlAddEventHandler ["ButtonClick", {
	_selected = call OWL_fnc_UI_mgmt_getSelected;
	if (!isNull _selected) then {
		_selected setPilotLight !(isLightOn _selected);
		(_this#0) ctrlSetStructuredText parseText (if (isLightOn _selected) then {"Lights off"} else {"Lights on"});	
		systemChat "lights";		
	};
}];

_asset_mgmt_button_engine ctrlAddEventHandler ["ButtonClick", {
	_selected = call OWL_fnc_UI_mgmt_getSelected;
	if (!isNull _selected) then {
		_selected engineOn !(isEngineOn _selected);
		(_this#0) ctrlSetStructuredText parseText (if (isEngineOn _selected) then {"Engine off"} else {"Engine on"});	
		systemChat "engine";		
	};
}];

_asset_mgmt_button_radar ctrlAddEventHandler ["ButtonClick", {
	_selected = call OWL_fnc_UI_mgmt_getSelected;
	if (!isNull _selected) then {
		// I am so confused. I don't know how to get this to work.
		(effectiveCommander _selected) action [if (isVehicleRadarOn _selected) then {"ActiveSensorsOff"} else {"ActiveSensorsOn"}, _selected];
		(_this#0) ctrlSetStructuredText parseText (if (isVehicleRadarOn _selected) then {"Radar off"} else {"Radar on"});	
	};
}];

_asset_mgmt_button_kick ctrlAddEventHandler ["ButtonClick", {
	_selected = call OWL_fnc_UI_mgmt_getSelected;
	if (!isNull _selected) then {
		_selected remoteExec ["OWL_fnc_crKickNonSquadMembers", 2];
	};
}];

_asset_mgmt_button_clear ctrlAddEventHandler ["ButtonClick", {
	_selected = call OWL_fnc_UI_mgmt_getSelected;
	if (!isNull _selected) then {
		_selected remoteExec ["OWL_fnc_crClearAssetInventory", 2];
	};
}];
/*
_owned_asset_map_title = _display ctrlCreate ["RscStructuredText", _tabIdx call OWL_fnc_TabIDC];
_owned_asset_map_title ctrlSetPosition [_xrel+_wb*0.5, _yrel+_hb*1, _wb*11, _hb*2];
_owned_asset_map_title ctrlSetStructuredText parseText "<t align='center'>Asset Locations</t>";
_owned_asset_map_title ctrlCommit 0;

_owned_asset_map = _display ctrlCreate ["RscMapControl", _tabIdx call OWL_fnc_TabIDC];
_owned_asset_map ctrlSetPosition [_xrel+_wb*0.5, _yrel+_hb*3, _wb*11, _hb*14];
_owned_asset_map ctrlMapSetPosition [_xrel+_wb*0.5, _yrel+_hb*3, _wb*11, _hb*14];
_owned_asset_map ctrlMapAnimAdd [0.5, 0.8, position player];
_owned_asset_map mapCenterOnCamera false;
_owned_asset_map ctrlCommit 0;
ctrlMapAnimCommit _owned_asset_map;

uiNamespace setVariable ["OWL_UI_owned_asset_map", _owned_asset_map];

if (isNil {DUMMY_ASSETS}) then {
	DUMMY_ASSETS = [];

	{
		DUMMY_ASSETS pushBack ("B_Plane_Fighter_01_F" createVehicle [((position player)#0)+_x, ((position player)#1)+_x, ((position player)#2)+_x*2]);
	} forEach ([10,20,30]);
};

_owned_asset_list_title = _display ctrlCreate ["RscStructuredText", _tabIdx call OWL_fnc_TabIDC];
_owned_asset_list_title ctrlSetPosition [_xrel+_wb*12, _yrel+_hb*1, _wb*8, _hb*2];
_owned_asset_list_title ctrlSetStructuredText parseText "<t align='center'>Purchased Assets</t>";
_owned_asset_list_title ctrlCommit 0;

_owned_asset_list = _display ctrlCreate ["RscListBox", _tabIdx call OWL_fnc_TabIDC];
_owned_asset_list ctrlSetPosition [_xrel+_wb*12, _yrel+_hb*3, _wb*8, _hb*14];
{
	_category = _x;
	_owned_asset_list lbAdd getText (configFile >> "CfgVehicles" >> typeOf _x >> "displayName");
	_owned_asset_list lbSetValue [(lbSize _owned_asset_list) - 1, _forEachIndex];
	_owned_asset_list lbSetData [(lbSize _owned_asset_list) - 1, netId _x];
} forEach DUMMY_ASSETS;

_owned_asset_list ctrlCommit 0;

uiNamespace setVariable ["OWL_UI__owned_asset_list", _owned_asset_list];

_assetmgmt_asset_unlock = _display ctrlCreate ["RscButtonMenu", _tabIdx call OWL_fnc_TabIDC];
_assetmgmt_asset_unlock ctrlSetPosition [_xrel+_wb*20.5, _yrel+_hb*3, _wb*8, _hb*1];
_assetmgmt_asset_unlock ctrlSetText "Unlock";
_assetmgmt_asset_unlock ctrlCommit 0;

_owned_asset_list ctrlAddEventHandler ["LBSelChanged", {
	params ["_ctrl", "_idx"];

	private _netId = _ctrl lbData _idx;
	_asset = _netId call BIS_fnc_objectFromNetId;
	_map = uiNamespace getVariable ["OWL_UI_owned_asset_map", controlNull];

	_map ctrlMapAnimAdd [0.5, 0.025, position _asset];
	ctrlMapAnimCommit _map ;
}];

_owned_asset_map ctrlAddEventHandler ["Draw", {
	params ["_map"];

	{
		_color = [0,1,0,0.8];
		if (netId _x == (((uiNamespace getVariable ["OWL_UI__owned_asset_list", controlNull]) lbData (lbCurSel (uiNamespace getVariable ["OWL_UI__owned_asset_list", controlNull]))))) then {
			_color = [0,1,1,0.8];
			_map drawIcon [
				"\a3\ui_f\data\Map\GroupIcons\selector_selectedFriendly_ca.paa", // custom images can also be used: getMissionPath "\myFolder\myIcon.paa"
				_color,
				getPosASLVisual _x,
				36,
				36,
				((time % 4) / 4)*360,
				format ["[%1]", mapGridPosition _x], 
				1,
				0.03,
				"TahomaB",
				"right"
			];		
		};
		_map drawIcon [
			getText (configFile >> "CfgVehicles" >> typeOf _x >> "icon"), // custom images can also be used: getMissionPath "\myFolder\myIcon.paa"
			_color,
			getPosASLVisual _x,
			24,
			24,
			getDirVisual _x,
			"",
			1,
			0.03,
			"TahomaB",
			"right"
		];
	} forEach DUMMY_ASSETS;


	_points = [ [10000, 10000], [10005, 10005], [10002, 10004], [10001, 10009], [9998, 10000], [9993, 9994] ];
	// make non-overlapping triangles?
	// step 1: find all triangles with no other points in the center
	// step 2: pick two points, find closest point to both of them.
	_triangles = [];
	_triangle = [];
	//{
		_p1 = _points#0;
		_min = 111111111;
		_p2 = 0;
		{
			if (_p1 distance2D _x < _min) then {
				_min = _p1 distance2D _x;
				_p2 = _x;
			};
		} forEach _points - [_x] - _triangle;
		_triangle pushBack _p1;
		_triangle pushBack _p2;

		{
			_triangle params ["_p1", "_p2"];
			_min = 11111111;
			_p3 = 0;
			if ( (_p1 vectorDiff _p2) distance2D _x < _min) then {
				_min = (_p1 vectorDiff _p2) distance2D _x;
				_p3 = _x;
			};
			_triangle pushBack _p3;
		} forEach _points - _triangle;

		_triangles pushBack _triangle;
	//} forEach _points;

	{
		_map drawEllipse [_x, 0.25, 0.25, 0, [0,1,0,0.5], "#(rgb,1,1,1)color(1,1,1,1)"];
	} forEach _points;

	_map drawTriangle [_triangle, [1,0,0,0.5], "#(rgb,1,1,1)color(1,1,1,1)"];
}];*/