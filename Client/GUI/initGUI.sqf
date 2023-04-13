/***************************************************
**********[     Init UI Variables      ]************
************************************************* */

uiNamespace setVariable ["OWL_UI_lastTab", 1];
uiNamespace setVariable ["OWL_UI_controlList", createHashMap];

OWL_ASSET_LIST = createHashMap;
OWL_ASSET_INFO = createHashMap;

OWL_MENU_TABS = [
	"Strategy",
	"Assets",
	"Asset Management",
	"Commander",
	"DickMeasuring",
	"Options"
];

// Register any cutRsc layers

/***************************************************
**********[       Process Assets       ]************
************************************************* */

private _side = playerSide;
_array = configProperties [missionConfigFile >> "CfgWLRequisitionPresets" >> "OpenWarlords" >> str _side, "true", true];
_path = missionConfigFile >> "CfgWLRequisitionPresets" >> "OpenWarlords" >> str _side;

{
	_category = configName _x;
	_assetType = configProperties [_path >> _category, "true", true];
	_assetArr = [];
	{
		_assetClass = configName _x;
		_assetName = getText (configFile >> "CfgVehicles" >> _assetClass >> "displayName");
		_assetCost = getNumber (_path >> _category >> _assetClass >> "cost");
		_requirements = getArray (_path >> _category >> _assetClass >> "requirements");

		_assetArr pushBack _assetClass;
		OWL_ASSET_INFO set [_assetClass, [_assetName, _assetCost, _requirements]];
	} forEach _assetType;

	OWL_ASSET_LIST set [_category, _assetArr];
} forEach _array;

/***************************************************
**************[      Functions      ]***************
************************************************* */

OWL_fnc_uiGetControl = {
	params ["_name"];

	(uiNamespace getVariable "OWL_UI_controlList") get _name;
};

OWL_fnc_uiSetControl = {
	params ["_name", "_ctrl"];

	_old = (uiNamespace getVariable "OWL_UI_controlList") getOrDefault [_name, controlNull];
	if ( !(_old isEqualTo controlNull) ) then {
		ctrlDelete _old;
	};

	(uiNamespace getVariable "OWL_UI_controlList") set [_name, _ctrl];
};

OWL_fnc_TabIDC = {
	params ["_curTab"];
	OWL_IDC_COUNTER set [_curTab-1, (OWL_IDC_COUNTER select (_curTab-1))+1];
	(OWL_IDC_COUNTER select _curTab-1)-1;
};

OWL_fnc_UI_mapDrawCommon = {
	params ["_ctrlMap"];

	_eh = _ctrlMap getVariable ["OWL_UI_mapEH", []];
	if (count _eh == 0) then {
		_eh = _ctrlMap ctrlAddEventHandler ["Draw", {
			_this select 0 drawIcon [
				getMissionPath "aa.paa", // custom images can also be used: getMissionPath "\myFolder\myIcon.paa"
				[1,1,1,1],
				getPosASLVisual asd,
				(9.05)*(1/(ctrlMapScale (_this select 0))),
				2.2525*(1/(ctrlMapScale (_this select 0))),
				((getDirVisual asd)+90.5)%360,
				"",
				1,
				0.03,
				"TahomaB",
				"right"	
			];
			if (OWL_gameState # OWL_sideIndex == "voting") then {
				private _voteList = OWL_sectorVoteList # OWL_sideIndex;
				private _maxVotes = 0;
				_voteList apply { _maxVotes = _maxVotes + _x#1};
				{
					_x params ["_sectorIndex", "_count"];
					private _color = [1,1,1,_count/_maxVotes];
					private _sector = OWL_allSectors # _sectorIndex;
					_this select 0 drawIcon [
						"A3\ui_f\data\map\groupicons\selector_selectedMission_ca.paa",
						_color,
						_sector,
						50,
						50,
						if (side group player == WEST) then {0} else {45},
						str _count,
						if (side group player == WEST) then {2} else {1}
					];
				} forEach _voteList;

				{
					if ([_x, playerSide] call OWL_fnc_conditionSectorVote) then {
						_this select 0 drawIcon [
							"A3\ui_f\data\map\groupicons\selector_selectedMission_ca.paa",
							[1,1,1,0.5],
							_x,
							40,
							40,
							(time*60)%360,
							str _count,
							if (side group player == WEST) then {2} else {1}
						];	
					};
				} forEach OWL_allSectors;
			};
			{
				if (_x == "attacking") then {
					private _sector = OWL_contestedSector # _forEachIndex;
					private _color = OWL_sideColor get (OWL_competingSides # _forEachIndex);
					_color set [3, 0.5];
					if (isNull _sector) exitWith {};
					_this select 0 drawIcon [
						"A3\ui_f\data\map\groupicons\selector_selectedMission_ca.paa",
						_color,
						_sector,
						40,
						40,
						if (_forEachIndex == 0) then {0} else {45},
						"",
						if (_forEachIndex == 0) then {2} else {1}
					];
				};
			} forEach OWL_gameState;
		}];

		_ctrlMap setVariable ["OWL_UI_mapEH", _eh];
	};
};

(findDisplay 12) displayCtrl 51 call OWL_fnc_UI_mapDrawCommon;

private _mainMap = (findDisplay 12) displayCtrl 51;

_mainMap ctrlAddEventHandler ["MouseButtonDown", {
	params ["_map", "_button", "_xPos", "_yPos", "_shift", "_ctrl", "_alt"];
	_overItem = ctrlMapMouseOver (_map);

	if (_button != 0) exitWith {};

	/*private _queue_button = uiNamespace getVariable ["OWL_UI_strategy_button_request", controlNull];
	if (ctrlText _queue_button == "Cancel") then {
		if (surfaceIsWater ( _map ctrlMapScreenToWorld[_xPos, _yPos]) ) then {
			_queue_button ctrlSetText "Select Location";
			_map ctrlMapCursor ["", "Arrow"];
		};
	};*/

	if (count _overItem > 0) then {
		_overItem params ["_type", "_object"];

		switch (_type) do {
			case "marker":
			{
				if ("OWL" in _object) then {
					_idx = -1;
					_idx = (_object splitString "_") # 2;
					_idx = parseNumber _idx;

					_sector = OWL_allSectors # _idx;
					systemChat (_sector getVariable "OWL_sectorName");
					_sector call OWL_fnc_UI_onMainMapLocationClicked;
					uiNamespace setVariable ["OWL_UI_main_map_last_clicked", _sector];
					(uiNamespace getVariable ["OWL_UI_mainmap_label_selected", controlNull]) ctrlSetStructuredText parseText format ["<t size='2' align='center'>%1</t>", _sector getVariable "OWL_sectorName"];
				};
			};
			case "vehicleGroup":
			{
				systemChat str name _object;
			};
			default
			{

			};
		};
	} else {
		objNull call OWL_fnc_UI_onMainMapLocationClicked;
		uiNamespace setVariable ["OWL_UI_main_map_last_clicked", objNull];
		(uiNamespace getVariable ["OWL_UI_mainmap_label_selected", controlNull]) ctrlSetStructuredText parseText "<t size='2' align='center'>Select a Sector</t>";
	};
}];

// This ugly rework
_mainMap ctrlAddEventHandler ["MouseMoving", {
	params ["_map", "_xpos", "_ypos", "_mouseOver"];
	_overItem = ctrlMapMouseOver (_map);

	if (count _overItem > 0) then {
		_overItem params ["_type", "_marker"];
		if (_type == "marker") then {

			if ("OWL" in _marker) then {
				_idx = -1;
				_idx = (_marker splitString "_") # 2;
				_idx = parseNumber _idx;

				_sector = OWL_allSectors # _idx;
				private _tooltip = (findDisplay 12) displayCtrl 2999;
				if (isNull _tooltip) then {
					_tooltip = (findDisplay 12) ctrlCreate ["RscStructuredText", 2999, _map];
					_tooltip ctrlEnable false;
				};

				private _struct = format ["<t size='0.8' align='center' valign='middle' shadow='2'>%1</t></br><t size='0.5' align='left' ", _sector getVariable "OWL_sectorName"];
				_struct = _struct + "ok";
				_tooltip ctrlSetStructuredText parseText _struct;
				_pos = _map ctrlMapWorldToScreen (position _sector);
				_tooltip ctrlSetPosition [_xpos, _ypos, (safezoneW/40)*2.5, (safezoneH/25)*4];
				_tooltip ctrlSetBackgroundColor [0,0,0,0];
				_tooltip ctrlCommit 0;
				uiNamespace setVariable ["OWL_UI_main_map_last_sector", _sector];
			} else {
				_update = _update + _marker;
			};
		} else {
			_tooltip = (findDisplay 12) displayCtrl 2999;
			ctrlDelete _tooltip;
			uiNamespace setVariable ["OWL_UI_main_map_last_sector", objNull];
		};
	} else {
		_tooltip = (findDisplay 12) displayCtrl 2999;
		ctrlDelete _tooltip;
		_map ctrlSetTooltip "";
		uiNamespace setVariable ["OWL_UI_main_map_last_sector", objNull];
	};

	if ( ctrlText (uiNamespace getVariable ["OWL_UI_strategy_button_request", controlNull]) == "Cancel") then {
		_map ctrlMapCursor ["", (if (surfaceIsWater ( _map ctrlMapScreenToWorld[_xpos, _ypos])) then {'HC_move'} else {'HC_unsel'})];
	};
}];

_mainMap ctrlAddEventHandler ["Draw", {

	private _selected = uiNamespace getVariable ["OWL_UI_main_map_last_sector", objNull];
	private _clicked  = uiNamespace getVariable ["OWL_UI_main_map_last_clicked", objNull];
	if(!isNull _selected) then {
		_this select 0 drawIcon [
			"\a3\ui_f\data\Map\GroupIcons\selector_selectedFriendly_ca.paa", // custom images can also be used: getMissionPath "\myFolder\myIcon.paa"
			[1,1,1,1],
			getPosASLVisual _selected,
			32,
			32,
			((time % 4) / 4)*360,
			"",
			1,
			0.03,
			"TahomaB",
			"right"
		];
	};

	if(!isNull _clicked) then {
		_this select 0 drawIcon [
			"\a3\ui_f\data\Map\GroupIcons\selector_selectedMission_ca.paa", // custom images can also be used: getMissionPath "\myFolder\myIcon.paa"
			[0,1,0,1],
			getPosASLVisual _clicked,
			32,
			32,
			((time % 4) / 4)*360,
			"",
			1,
			0.03,
			"TahomaB",
			"right"
		];
	};
}];

private _mapDisplay = (findDisplay 12);
_pos = ctrlPosition _mainMap;
_pos params ["_xrel", "_yrel", "_wrel", "_hrel"];
_wb = _wrel / 40;
_hb = _hrel / 25;

with uiNamespace do {
	OWL_UI_mainmap_button_ft = _mapDisplay ctrlCreate ["RscButtonMenu", -1];
	OWL_UI_mainmap_button_ss = _mapDisplay ctrlCreate ["RscButtonMenu", -1]; 
	OWL_UI_mainmap_button_vote = _mapDisplay ctrlCreate ["RscButtonMenu", -1];
	OWL_UI_mainmap_label_selected = _mapDisplay ctrlCreate ["RscStructuredText", -1];

	OWL_UI_main_map_last_clicked = uiNamespace getVariable ["OWL_UI_main_map_last_clicked", objNull];

	OWL_UI_mainmap_label_selected ctrlSetPosition [_xrel, _yrel+_hb*1, _wb*40, _hb*1.5];
	OWL_UI_mainmap_label_selected ctrlSetStructuredText parseText format ["<t size='2' align='center'>%1</t>", if(isNull OWL_UI_main_map_last_clicked) then {"Select a Sector"} else {OWL_UI_main_map_last_clicked getVariable "OWL_sectorName"}];

	OWL_UI_mainmap_button_ft ctrlSetPosition [_xrel+_wb*5.125, _yrel+_hb*23, _wb*9.875, _hb*1.5];
	OWL_UI_mainmap_button_ss ctrlSetPosition [_xrel+_wb*15.125, _yrel+_hb*23, _wb*9.875, _hb*1.5];
	OWL_UI_mainmap_button_vote ctrlSetPosition [_xrel+_wb*25.125, _yrel+_hb*23, _wb*9.875, _hb*1.5];

	OWL_UI_mainmap_button_ft ctrlSetStructuredText parseText "<t size='2' align='center'>Fast Travel</t>";
	OWL_UI_mainmap_button_ss ctrlSetStructuredText parseText "<t size='2' align='center'>Sector Scan</t>";
	OWL_UI_mainmap_button_vote ctrlSetStructuredText parseText "<t size='2' align='center'>Vote Sector</t>";

	OWL_UI_mainmap_button_ft ctrlCommit 0;
	OWL_UI_mainmap_button_ss ctrlCommit 0;
	OWL_UI_mainmap_button_vote ctrlCommit 0;
	OWL_UI_mainmap_label_selected ctrlCommit 0;

	OWL_UI_mainmap_button_ft ctrlAddEventHandler ["ButtonClick", {
		_sector = uiNamespace getVariable ["OWL_UI_main_map_last_clicked", objNull];
		if (!([player, _sector] call OWL_fnc_conditionFastTravel)) exitWith {
			systemChat "Fast travel unavailable.";
		};

		_cd = uiNamespace getVariable "OWL_UI_requestCooldown";
		if (_cd - serverTime > 0) exitWith {playSound "AddItemFailed"};
		uiNamespace setVariable ["OWL_UI_requestCooldown", serverTime+10];

		playSound "AddItemOK";

		if (!isNull _sector) then {
			[player, _sector] remoteExec ["OWL_fnc_crFastTravel", 2];
		};
	}];

	OWL_UI_mainmap_button_ss ctrlAddEventHandler ["ButtonClick", {
		private _sector = uiNamespace getVariable ["OWL_UI_main_map_last_clicked", objNull];

		_sector remoteExec ["OWL_fnc_crSectorScan", 2]
	}];

	OWL_UI_mainmap_button_vote ctrlAddEventHandler ["ButtonClick", {
		private _sector = uiNamespace getVariable ["OWL_UI_main_map_last_clicked", objNull];

		_sector remoteExec ["OWL_fnc_crSectorVote", 2];
	}];
};

OWL_fnc_UI_onMainMapLocationClicked = {
	params ["_object"];


};

/**OWL_fnc_drawAircraftCarrier = {
	params ["_ctrlMap"];

	_eh = _ctrlMap getVariable ["OWL_UI_mapEH", []];
	if (count _eh == 0) then {
		_eh = _ctrlMap ctrlAddEventHandler ["Draw", {
			_this select 0 drawIcon [
				getMissionPath "aa.paa", // custom images can also be used: getMissionPath "\myFolder\myIcon.paa"
				[1,1,1,1],
				getPosASLVisual asd,
				(10.73-(0.0985))*(1/(ctrlMapScale (_this select 0))),
				2.70*(1/(ctrlMapScale (_this select 0))),
				((getDirVisual asd)+90.45)%360,
				"",
				1,
				0.03,
				"TahomaB",
				"right"	
			];
		}];

		_ctrlMap setVariable ["OWL_UI_mapEH", _eh];
	};
}; */

OWL_fnc_UI_AssetTab_onCPChanged = {
	params ["_amount"];

	// Update the queue list - check if player can afford -> if not black out the airdrop locations.
	// Update selected items - if player cannot afford - grey out item, request button.
	// Update the CP counter at the bottom

	_asset_list_items = uiNamespace getVariable ["OWL_UI_asset_list_items", controlNull];
	_request_button = uiNamespace getVariable ["OWL_UI_asset_button_request", controlNull];

	if (isNull _asset_list_items || isNull _request_button) exitWith {};

	OWL_UI_FLOATING_FUNDS = missionNamespace getVariable ["OWL_UI_FLOATING_FUNDS", uiNamespace getVariable ["OWL_UI_dummyFunds", 0]];
	OWL_UI_FLOATING_FUNDS = OWL_UI_FLOATING_FUNDS + _amount;

	for "_i" from 0 to (lbSize _asset_list_items - 1) do {
		_class = _asset_list_items lbData _i;

		private _errorCode = _class call OWL_fnc_UI_checkAssetRequirements;

		if (_errorCode == 0) then {
			_asset_list_items lbSetColor [_i, [1,1,1,1]];
		} else {
			_asset_list_items lbSetColor [_i, [1,1,1,0.1]];
		};
	};

	if (lbCurSel _asset_list_items != -1) then {
		_class = _asset_list_items lbData (lbCurSel _asset_list_items);
		private _errorCode = _class call OWL_fnc_UI_checkAssetRequirements;
		_request_button ctrlEnable (_errorCode == 0);
		_request_button ctrlSetTooltip (_errorCode call OWL_fnc_UI_assetRequestTooltip);
		_class call OWL_fnc_updateAssetPreview;
	};

	_menu_asset_footer = uiNamespace getVariable ["OWL_UI_asset_menu_footer", controlNull];
	_menu_asset_footer ctrlSetStructuredText parseText format ["<t size='0.25'>&#160;</t><br/><t size='1.25' align='center' valign='bottom'>%1 CP, Harbor, 6 Recruits Available</t>", OWL_UI_FLOATING_FUNDS];
};

/*
	BIS_WL_sectorColors = [
		[profileNamespace getVariable ["Map_OPFOR_R", 0], profileNamespace getVariable ["Map_OPFOR_G", 1], profileNamespace getVariable ["Map_OPFOR_B", 1], 0.8],
		[profileNamespace getVariable ["Map_BLUFOR_R", 0], profileNamespace getVariable ["Map_BLUFOR_G", 1], profileNamespace getVariable ["Map_BLUFOR_B", 1], 0.8],
		[profileNamespace getVariable ["Map_Independent_R", 0], profileNamespace getVariable ["Map_Independent_G", 1], profileNamespace getVariable ["Map_Independent_B", 1], 0.8]
	];
*/

addMissionEventHandler ["Draw3D", {
	private _curSector = OWL_contestedSector # (OWL_competingSides find playerSide);
	if !(isNull _curSector) then {
		_color = OWL_sideColor get (_curSector getVariable "OWL_sectorSide");
		_dist = player distance _curSector;
		_units = "m";
		_dist = round _dist;
		if (_dist > 1000) then {_dist = _dist / 100; _dist = round _dist; _dist = _dist / 10; _units = "km"};
		drawIcon3D [
			"\A3\ui_f\data\map\markers\nato\o_installation.paa",
			[_color#0, _color#1, _color#2, 0.5],
			[(position _curSector) # 0, (position _curSector) # 1, 3],
			1,
			1,
			0,
			"",
			0,
			0,
			"PuristaSemibold",
			"center",
			TRUE
		];
		drawIcon3D [
			"",
			[1, 1, 1, 0.5],
			[(position _curSector) # 0, (position _curSector) # 1, 3],
			0,
			0.5,
			0,
			format ["%1%2 %3", _dist, if (_dist % 1 == 0 && _units == "km") then {".0"} else {""}, if (_units == "m") then {"m"} else {"km"}],
			2,
			0.0325,
			"PuristaSemibold"
		];
	};
}];