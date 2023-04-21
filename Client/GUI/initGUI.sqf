/***************************************************
**********[     Init UI Variables      ]************
************************************************* */

call compileFinal preprocessFileLineNumbers "Client\GUI\initGUIFunctions.sqf";
call compileFinal preprocessFileLineNumbers "Client\GUI\WarlordsMenu\initMenu.sqf";

// Create our Warlords HUD
("OWL_hudLayer" call BIS_fnc_rscLayer) cutRsc ["OWL_RscMainHUD", "PLAIN"];

/***************************************************
**************[      Functions      ]***************
************************************************* */

OWL_fnc_UI_mapDrawCommon = {
	params ["_ctrlMap"];

	_eh = _ctrlMap getVariable ["OWL_UI_mapEH", []];
	if (count _eh == 0) then {
		_eh = _ctrlMap ctrlAddEventHandler ["Draw", {
			/*_this select 0 drawIcon [
				getMissionPath "data\aircraft_carrier.paa",
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
			];*/
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
					private _sector = _x;
					{
						private _color = [1,1,1,0.8];
						if (typeOf _x == "Logic") then {
							_this select 0 drawLine [
								getPos _sector,
								getPos _x,
								_color
							];
						};
					} forEach (synchronizedObjects _sector);
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

private _mainMap = (findDisplay 12) displayCtrl 51;
_mainMap call OWL_fnc_UI_mapDrawCommon;

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
		//objNull call OWL_fnc_UI_onMainMapLocationClicked;
		//uiNamespace setVariable ["OWL_UI_main_map_last_clicked", objNull];
		//(uiNamespace getVariable ["OWL_UI_mainmap_label_selected", controlNull]) ctrlSetStructuredText parseText "<t size='2' align='center'>Select a Sector</t>";
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
			"\a3\ui_f\data\Map\GroupIcons\selector_selectedFriendly_ca.paa",
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
			"\a3\ui_f\data\Map\GroupIcons\selector_selectedMission_ca.paa", 
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
	OWL_UI_mainmap_progress_ss = _mapDisplay ctrlCreate ["RscProgress", -1];

	OWL_UI_main_map_last_clicked = uiNamespace getVariable ["OWL_UI_main_map_last_clicked", objNull];

	OWL_UI_mainmap_label_selected ctrlSetPosition [_xrel, _yrel+_hb*21, _wb*40, _hb*1.5];
	OWL_UI_mainmap_label_selected ctrlSetStructuredText parseText format ["<t size='1.5' align='center'>%1</t>", if(isNull OWL_UI_main_map_last_clicked) then {"Select a Sector"} else {OWL_UI_main_map_last_clicked getVariable "OWL_sectorName"}];

	OWL_UI_mainmap_button_ft ctrlSetPosition [_xrel+_wb*5.125, _yrel+_hb*23, _wb*9.875, _hb*1.5];
	OWL_UI_mainmap_button_ss ctrlSetPosition [_xrel+_wb*15.125, _yrel+_hb*23, _wb*9.875, _hb*1.5];
	OWL_UI_mainmap_progress_ss ctrlSetPosition [_xrel+_wb*15.125, _yrel+_hb*23, _wb*9.875, _hb*1.5];
	OWL_UI_mainmap_button_vote ctrlSetPosition [_xrel+_wb*25.125, _yrel+_hb*23, _wb*9.875, _hb*1.5];

	OWL_UI_mainmap_button_ft ctrlSetStructuredText parseText "<t size='2' align='center'>Fast Travel</t>";
	OWL_UI_mainmap_button_ss ctrlSetStructuredText parseText "<t size='2' align='center'>Sector Scan</t>";
	OWL_UI_mainmap_button_vote ctrlSetStructuredText parseText "<t size='2' align='center'>Vote Sector</t>";

	if (!isNull OWL_UI_main_map_last_clicked) then {
		private _cdArr = OWL_UI_main_map_last_clicked getVariable "OWL_sectorScanCooldown";
		private _cd = _cdArr # (OWL_competingSides find playerSide);
		if (_cd > serverTime) then {
			_cd = ((_cd - serverTime) / 300);
		} else {
			_cd = 0;
		};
		OWL_UI_mainmap_progress_ss progressSetPosition _cd;
	} else {
		OWL_UI_mainmap_progress_ss progressSetPosition 0;
	};

	OWL_UI_mainmap_button_ft ctrlSetBackgroundColor [0.2, 0.2, 0.2, 0.8];
	OWL_UI_mainmap_button_ss ctrlSetBackgroundColor [0.2, 0.2, 0.2, 0.8];
	OWL_UI_mainmap_button_vote ctrlSetBackgroundColor [0.2, 0.2, 0.2, 0.8];
	OWL_UI_mainmap_progress_ss ctrlSetTextColor [0.8,0.6,0,0.5];

	OWL_UI_mainmap_progress_ss ctrlCommit 0;
	OWL_UI_mainmap_button_ft ctrlCommit 0;
	OWL_UI_mainmap_button_ss ctrlCommit 0;
	OWL_UI_mainmap_button_vote ctrlCommit 0;
	OWL_UI_mainmap_label_selected ctrlCommit 0;

	OWL_UI_mainmap_button_ft ctrlAddEventHandler ["ButtonClick", {
		_sector = uiNamespace getVariable ["OWL_UI_main_map_last_clicked", objNull];
		if (!([player, _sector] call OWL_fnc_conditionFastTravel)) exitWith {
			systemChat "Fast travel unavailable.";
		};

		_cd = uiNamespace getVariable ["OWL_UI_requestCooldown", -1];
		if (_cd - serverTime > 0) exitWith {playSound "AddItemFailed"};
		uiNamespace setVariable ["OWL_UI_requestCooldown", serverTime+10];

		playSound "AddItemOK";

		if (!isNull _sector) then {
			_sector remoteExec ["OWL_fnc_crFastTravel", 2];
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

	private _button_ft = uiNamespace getVariable "OWL_UI_mainmap_button_ft";
	private _button_ss = uiNamespace getVariable "OWL_UI_mainmap_button_ss";
	private _button_vote = uiNamespace getVariable "OWL_UI_mainmap_button_vote";

	_button_ft ctrlEnable ([player, _object] call OWL_fnc_conditionFastTravel);
	_button_ss ctrlEnable ([_object, playerSide] call OWL_fnc_conditionSectorScan);
	_button_vote ctrlEnable ([_object, playerSide] call OWL_fnc_conditionSectorVote);
};

(uiNamespace getVariable ["OWL_UI_main_map_last_clicked", objNull]) call OWL_fnc_UI_onMainMapLocationClicked;

OWL_fnc_UI_AssetTab_onCPChanged = {
	params ["_amount"];

	// Update the queue list - check if player can afford -> if not black out the airdrop locations.
	// Update selected items - if player cannot afford - grey out item, request button.
	// Update the CP counter at the bottom

	_asset_list_items = uiNamespace getVariable ["OWL_UI_asset_list_items", controlNull];
	_request_button = uiNamespace getVariable ["OWL_UI_asset_button_request", controlNull];

	if (isNull _asset_list_items || isNull _request_button) exitWith {};

	OWL_UI_menuDummyFunds = missionNamespace getVariable ["OWL_UI_menuDummyFunds", uiNamespace getVariable ["OWL_UI_dummyFunds", 0]];
	OWL_UI_menuDummyFunds = OWL_UI_menuDummyFunds + _amount;

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
		_class call OWL_fnc_UI_AssetTab_updateAssetPreview;
	};

	_menu_asset_footer = uiNamespace getVariable ["OWL_UI_asset_menu_footer", controlNull];
	_menu_asset_footer ctrlSetStructuredText parseText format ["<t size='0.25'>&#160;</t><br/><t size='1.25' align='center' valign='bottom'>%1 CP, Harbor, 6 Recruits Available</t>", OWL_UI_menuDummyFunds];
};

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