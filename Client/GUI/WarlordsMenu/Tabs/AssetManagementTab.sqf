params ["_display", "_tabIdx"];

private _curIdc = _tabIdx * 1000;

if (!isNull (_display displayCtrl _curIdc)) exitWith {};

_pos = ctrlPosition (_display displayCtrl 98);
_pos params ["_xrel", "_yrel", "_wrel", "_hrel"];
_wb = _wrel / 40;
_hb = _hrel / 25;

/***********************************************
***************[               ]***************
********************************************** */

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
}];
