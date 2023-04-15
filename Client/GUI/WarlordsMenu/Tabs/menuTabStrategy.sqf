/*
	Asset Allotmment
		5 Light Armor
		5 Armor
		3 Aircraft
		50 Infantry

	Defenses:

	Offense:
*/
params ["_display", "_tabIdx"];

private _cur_selected = uiNamespace getVariable ["OWL_UI_strategy_map_last_clicked", objNull];

if (!isNull (_display displayCtrl _tabIdx * 1000)) exitWith {
	private _asset_controls = uiNamespace getVariable ["OWL_UI_strategy_purchase_asset_controls", objNull];
	private _show = _cur_selected getVariable ["OWL_sectorSide", sideEmpty] == side player && !(_cur_selected getVariable ["OWL_sectorProtected", true]);
	{
		_x ctrlShow _show;
	} forEach _asset_controls;
};

OWL_fnc_UI_StrategyTab_onLocationSelected = {
	params ["_object"];

	_previousSector = uiNamespace getVariable ["OWL_UI_strategy_map_last_clicked", objNull];

	if (_previousSector == _object) exitWith {};

	uiNamespace setVariable ["OWL_UI_strategy_map_last_clicked", _object];

	private _button_ft = uiNamespace getVariable ["OWL_UI_strategy_button_ft", controlNull];
	private _button_scan = uiNamespace getVariable ["OWL_UI_strategy_button_scan", controlNull];
	private _button_vote = uiNamespace getVariable ["OWL_UI_strategy_button_vote", controlNull];
	private _label_reenforce = uiNamespace getVariable ["OWL_UI_strategy_reenforce_label", controlNull];
	if (isNull _object) exitWith {
		uiNamespace setVariable ["OWL_UI_strategy_map_last_clicked", objNull];
		_button_ft ctrlEnable false;
		_button_ft ctrlSetStructuredText parseText "<t size='0.5'>&#160;</t><br/><t font = 'PuristaLight' align = 'center' shadow = '2' size='1.5'>Fast Travel to Sector</t>";
		_button_ft ctrlCommit 0;
		_button_scan ctrlEnable false;
		_button_scan ctrlSetStructuredText parseText "<t size='0.2'>&#160;</t><br/><t size='1.25' align='center' valign='bottom'>Scan Sector</t>";
		_button_scan ctrlCommit 0;
		_label_reenforce ctrlSetText "";
		_label_reenforce ctrlCommit 0;
		_button_vote ctrlSetStructuredText parseText "<t size='0.2'>&#160;</t><br/><t size='1.25' align='center' valign='bottom'>Vote for Sector</t>";
		_button_vote ctrlEnable false;
		_button_vote ctrlCommit 0;
		call OWL_fnc_UI_updateStrategyLabel;

		{
			_x ctrlShow false;
		} forEach (uiNamespace getVariable "OWL_UI_strategy_purchase_asset_controls");
	};

	if (!(_object getVariable "OWL_sectorProtected")) then {
		{
			_x ctrlShow (_object getVariable "OWL_sectorSide" == side player);
		} forEach (uiNamespace getVariable "OWL_UI_strategy_purchase_asset_controls");
	};

	_button_scan ctrlSetStructuredText parseText "<t size='0.2'>&#160;</t><br/><t size='1.25' align='center' valign='bottom'>Scan Sector</t>";
	_button_scan ctrlCommit 0;

	_label_reenforce ctrlCommit 0;
	_button_vote ctrlSetStructuredText parseText "<t size='0.2'>&#160;</t><br/><t size='1.25' align='center' valign='bottom'>Vote for Sector</t>";
	_button_vote ctrlEnable ([_object, side player] call OWL_fnc_conditionSectorVote);
	_button_vote ctrlCommit 0;

	_button_ft ctrlEnable ([player, _object] call OWL_fnc_conditionFastTravel);
	_button_scan ctrlEnable ([_object, side player] call OWL_fnc_conditionSectorScan);

	private _tickets = [_object ,side player] call OWL_fnc_sectorTicketCount;
	if ( _tickets <= 0) then {
		_button_ft ctrlEnable false;
	};

	_button_ft ctrlSetStructuredText parseText format ["<t size='0.5'>&#160;</t><br/><t font = 'PuristaLight' align = 'center' shadow = '2' size='1.5'>Fast Travel to %1</t>", _object getVariable ["OWL_sectorName", "Sector"]];
	_button_ft ctrlCommit 0;

	_label_reenforce ctrlSetStructuredText parseText format ["<t size='1.5' align='center'>PURCHASE REENFORCEMENTS FOR <br/> %1</t>", toUpper (_object getVariable ["OWL_sectorName", ""])];
	_label_reenforce ctrlCommit 0;

	call OWL_fnc_UI_StrategyTab_sectorScanUpdate;
	call OWL_fnc_UI_updateStrategyLabel;
};

OWL_fnc_UI_StrategyTab_sectorScanUpdate = {
	if (uiNamespace getVariable "OWL_UI_lastTab" != 1) exitWith {};

	private _strategy_button_scan = uiNamespace getVariable ["OWL_UI_strategy_button_scan", controlNull];
	private _strategy_progress_scan = uiNamespace getVariable ["OWL_UI_strategy_progress_scan", controlNull];
	private _sector = uiNamespace getVariable ["OWL_UI_strategy_map_last_clicked", objNull];

	if (isNull _sector) exitWith {
		_strategy_progress_scan ctrlShow false;
		_strategy_button_scan ctrlSetStructuredText parseText "<t size='0.2'>&#160;</t><br/><t size='1.25' align='center' valign='bottom'>Scan Sector</t>";
		_strategy_button_scan ctrlCommit 0;
	};

	private _cdTimer = (_sector getVariable ["OWL_sectorScanCooldown", [0,0,0]]) # (OWL_competingSides find (side player));
	private _cooldown = _cdTimer - serverTime;
	private _percent = (_cooldown / 300);
	private _text = format ["Scan %1", _sector getVariable "OWL_sectorName"];
	if (_cooldown > 0) then {
		_text = _text + format [" (%1s)", _cooldown toFixed 0];
	} else {
		_percent = 0;
	};

	_strategy_progress_scan progressSetPosition _percent;
	_strategy_progress_scan ctrlShow (_cooldown > 0);
	_strategy_progress_scan ctrlSetTextColor (OWL_sideColor get (side player));
	_strategy_progress_scan ctrlCommit 0;

	_strategy_button_scan ctrlSetStructuredText parseText "<t size='0.2'>&#160;</t><br/><t size='1.25' align='center' valign='bottom'>Scan Sector</t>";
	_strategy_button_scan ctrlEnable ([_sector, side player] call OWL_fnc_conditionSectorScan);
	_strategy_button_scan ctrlCommit 0;
};

OWL_fnc_UI_updateStrategyLabel = {
	private _label = uiNamespace getVariable ["OWL_UI_strategy_label_sector_info", controlNull];
	private _sector = uiNamespace getVariable ["OWL_UI_strategy_map_last_clicked", objNull];

	private _text = ""; 
	if (isNull _sector) then {
		_text = _text + "<t size='1.5' align='center' valign='middle'>Select a Sector<br/></t><t size='1' align='center' color='#AAAAAAAA' valign='left'>Selecting a sector will allow you to fast travel, scan, or re-enforce that sector.</t>";
	} else {
		private _protected = _sector getVariable "OWL_sectorProtected";
		private _tickets = [_sector, side player] call OWL_fnc_sectorTicketCount;

		private _assets = _sector getVariable "OWL_sectorAssets";
		private _assetLimit = (_sector getVariable "OWL_sectorArea")#0;
		_assetLimit = _assetLimit * 2;
		_assetLimit = floor (_assetLimit / 100);
		_assetLimit = [_assetLimit*5,_assetLimit,floor (_assetLimit/2)];

		_text = "<t size='1.5' align='center' valign='middle'>%1<br/></t><t size='1' align='center' color='%2' valign='left'>%3</t><t size='1' align='center'><t size='1.25' align='center' valign='middle'><br/>Respawn Tickets: %4<br/></t><t size='1' align='center'><br/>Infantry: %5/%6<br/></t><t size='1' align='center'>Light Armor: %7/%8<br/></t><t size='1' align='center'>Armor: %9/%10<br/></t>";
		_text = format [_text, _sector getVariable "OWL_sectorName", if (_protected) then {"#00FF00"} else {"#FF0000"}, if (_protected) then {"Protected"} else {"Unprotected"}, if (_tickets > 1e10) then {"Unlimited"} else {_tickets}, count (_assets#0), _assetLimit#0, count (_assets#1), _assetLimit#1, count (_assets#2), _assetLimit#2];
	};

	_label ctrlSetStructuredText parseText _text;
	_label ctrlCommit 0;
};

_pos = ctrlPosition (_display displayCtrl 98);
_pos params ["_xrel", "_yrel", "_wrel", "_hrel"];
_wb = _wrel / 40;
_hb = _hrel / 25;

private _menu_strategy_header = _display ctrlCreate ["RscText", _tabIdx call OWL_fnc_TabIDC];
_menu_strategy_header ctrlSetPosition [_xrel, _yrel, _wb*40, _hb*2];
_menu_strategy_header ctrlSetBackgroundColor [0,0,0,0.2];
_menu_strategy_header ctrlCommit 0;

private _menu_strategy_footer = _display ctrlCreate ["RscStructuredText", _tabIdx call OWL_fnc_TabIDC];
_menu_strategy_footer ctrlSetPosition [_xrel, _yrel+_hb*23, _wb*40, _hb*2];
_menu_strategy_footer ctrlSetBackgroundColor [0,0,0,0.2];
_menu_strategy_footer ctrlSetStructuredText parseText format ["<t size='0.25'>&#160;</t><br/><t size='1.25' align='center' valign='bottom'>%1 CP, Harbor, 6 Recruits Available</t>", OWL_UI_FLOATING_FUNDS];
_menu_strategy_footer ctrlCommit 0;

uiNamespace setVariable ["OWL_UI_strategy_menu_footer", _menu_strategy_footer];

private _menu_label_strategy = _display ctrlCreate ["RscStructuredText", _tabIdx call OWL_fnc_TabIDC];
_menu_label_strategy ctrlSetPosition [_xrel+_wb*0.5, _yrel+_hb*0.5, _wb*11, _hb*1];
_menu_label_strategy ctrlSetStructuredText parseText "<t size='1' align='center' valign='middle'>Map</t>";
_menu_label_strategy ctrlCommit 0;

private _strategy_map = _display ctrlCreate ["RscMapControl", _tabIdx call OWL_fnc_TabIDC];
_strategy_map ctrlSetPosition [_xrel+_wb*0.5, _yrel+_hb*3, _wb*11, _hb*14];
_strategy_map ctrlMapSetPosition [_xrel+_wb*0.5, _yrel+_hb*3, _wb*11, _hb*14];
_strategy_map ctrlMapAnimAdd [0.5, 0.8, (if (isNull _cur_selected) then {position player} else {position _cur_selected})];
_strategy_map mapCenterOnCamera false;
_strategy_map ctrlCommit 0;
ctrlMapAnimCommit _strategy_map;

uiNamespace setVariable ["OWL_UI_strategy_map", _strategy_map];

private _strategy_button_scan = _display ctrlCreate ["RscButtonMenu", _tabIdx call OWL_fnc_TabIDC];
_strategy_button_scan ctrlSetPosition [_xrel+_wb*6.125, _yrel+_hb*20.25, _wb*5.375, _hb*2];
_strategy_button_scan ctrlEnable (!isNull _cur_selected && false);
_strategy_button_scan ctrlSetStructuredText parseText "<t size='0.2'>&#160;</t><br/><t size='1.25' align='center' valign='bottom'>Scan Sector</t>";
_strategy_button_scan ctrlCommit 0;

uiNamespace setVariable ["OWL_UI_strategy_button_scan", _strategy_button_scan];

private _strategy_progress_scan = _display ctrlCreate ["RscProgress", _tabIdx call OWL_fnc_TabIDC];
_strategy_progress_scan ctrlSetPosition [_xrel+_wb*6.125, _yrel+_hb*20.25, _wb*5.375, _hb*2];
_strategy_progress_scan ctrlCommit 0;

uiNamespace setVariable ["OWL_UI_strategy_progress_scan", _strategy_progress_scan];

[_strategy_button_scan, _strategy_progress_scan] spawn {
	params ["_strategy_button_scan", "_strategy_progress_scan"];
	while {!isNull _strategy_button_scan} do {
		sleep 0.05;
		call OWL_fnc_UI_StrategyTab_sectorScanUpdate;
	};
};

private _strategy_button_vote = _display ctrlCreate ["RscButtonMenu", _tabIdx call OWL_fnc_TabIDC];
_strategy_button_vote ctrlSetPosition [_xrel+_wb*0.5, _yrel+_hb*20.25, _wb*5.375, _hb*2];
_strategy_button_vote ctrlSetStructuredText parseText "<t size='0.2'>&#160;</t><br/><t size='1.25' align='center' valign='bottom'>Vote for Sector</t>";
_strategy_button_vote ctrlEnable ([_cur_selected, side player] call OWL_fnc_conditionSectorVote);
_strategy_button_vote ctrlCommit 0;

uiNamespace setVariable ["OWL_UI_strategy_button_vote", _strategy_button_vote];

private _strategy_button_ft = _display ctrlCreate ["RscButtonMenu", _tabIdx call OWL_fnc_TabIDC];
_strategy_button_ft ctrlSetPosition [_xrel+_wb*0.5, _yrel+_hb*17.25, _wb*11, _hb*2.75];
_strategy_button_ft ctrlSetStructuredText parseText format ["<t size='0.5'>&#160;</t><br/><t font = 'PuristaLight' align = 'center' shadow = '2' size='1.5'>Fast Travel to %1</t>", _cur_selected getVariable ["OWL_sectorName", "Sector"]];
_strategy_button_ft ctrlEnable ([player, _cur_selected] call OWL_fnc_conditionFastTravel);
_strategy_button_ft ctrlCommit 0;

_strategy_button_ft ctrlAddEventHandler ["ButtonClick", {
	_sector = uiNamespace getVariable ["OWL_UI_strategy_map_last_clicked", objNull];
	if (!([player, _sector] call OWL_fnc_conditionFastTravel)) exitWith {
		systemChat "Fast travel unavailable.";
	};

	_cd = uiNamespace getVariable "OWL_UI_requestCooldown";
	if (_cd - serverTime > 0) exitWith {playSound "AddItemFailed"};

	uiNamespace setVariable ["OWL_UI_requestCooldown", serverTime+2];
	playSound "AddItemOK";

	if (!isNull _sector) then {
		[player, _sector] remoteExec ["OWL_fnc_crFastTravel", 2];
	};
}];

_strategy_button_scan ctrlAddEventHandler ["ButtonClick", {
	private _sector = uiNamespace getVariable ["OWL_UI_strategy_map_last_clicked", objNull];

	_sector remoteExec ["OWL_fnc_crSectorScan", 2]
}];

_strategy_button_vote ctrlAddEventHandler ["ButtonClick", {
	private _sector = uiNamespace getVariable ["OWL_UI_strategy_map_last_clicked", objNull];

	_sector remoteExec ["OWL_fnc_crSectorVote", 2];
}];

uiNamespace setVariable ["OWL_UI_strategy_button_ft", _strategy_button_ft];

private _menu_label_reenforce = _display ctrlCreate ["RscStructuredText", _tabIdx call OWL_fnc_TabIDC];
_menu_label_reenforce ctrlSetPosition [_xrel+_wb*12, _yrel+_hb*0.5, _wb*11, _hb*1];
_menu_label_reenforce ctrlSetStructuredText parseText "<t size='1' align='center' valign='middle'>Sit-Rep</t>";
_menu_label_reenforce ctrlCommit 0;

private _strategy_label_sector_info = _display ctrlCreate ["RscStructuredText", _tabIdx call OWL_fnc_TabIDC];//&0x00009
_strategy_label_sector_info ctrlSetPosition [_xrel+_wb*12, _yrel+_hb*3, _wb*11, _hb*8];
_strategy_label_sector_info ctrlCommit 0;

uiNamespace setVariable ["OWL_UI_strategy_label_sector_info", _strategy_label_sector_info];

call OWL_fnc_UI_updateStrategyLabel;

private _strategy_progress_reenforce = _display ctrlCreate ["RscProgress", _tabIdx call OWL_fnc_TabIDC];
_strategy_progress_reenforce ctrlSetPosition [_xrel+_wb*12, _yrel+_hb*20.25, _wb*11, _hb*2];
_strategy_progress_reenforce progressSetPosition 0.4;
_strategy_progress_reenforce ctrlSetTextColor [0.9,0.8,0,1];
_strategy_progress_reenforce ctrlCommit 0;

private _asset_controls = [];

private _strategy_reenforce_label = _display ctrlCreate ["RscStructuredText", _tabIdx call OWL_fnc_TabIDC];
_strategy_reenforce_label ctrlSetPosition [_xrel+_wb*12, _yrel+_hb*11.75, _wb*11, _hb*3];
_strategy_reenforce_label ctrlSetStructuredText parseText format ["<t size='1.5' align='center'>PURCHASE REENFORCEMENTS FOR <br/> %1</t>", toUpper (_cur_selected getVariable ["OWL_sectorName", ""])];
_strategy_reenforce_label ctrlSetBackgroundColor [0,0,0,0.4];
_strategy_reenforce_label ctrlSetTooltip "Assets purchased will defend when the sector when it is attacked next by the enemy.\nFully reenforced sectors will re-gain a zone restriction vs the enemy.";
_strategy_reenforce_label ctrlCommit 0;

_asset_controls pushBack _strategy_reenforce_label;
_asset_controls pushBack _strategy_progress_reenforce;

uiNamespace setVariable ["OWL_UI_strategy_reenforce_label", _strategy_reenforce_label];

{
	private _category = ["Infantry", "LAV", "Armor"] # _forEachIndex;
	private _combo = _display ctrlCreate ["RscCombo", _tabIdx call OWL_fnc_TabIDC];
	_combo ctrlSetPosition [_xrel+_wb*16.125, _yrel+_hb*15+(_forEachIndex*_hb*1.75), _wb*6.875, _hb*1.5];
	{
		private _display = getText (configFile >> "CfgVehicles" >> _x >> "displayName");
		private _cost = getNumber (missionConfigFile >> "CfgWLSectorAssetPreset" >> "OpenWarlords" >> str(side player) >> _category >> _x >> "cost");
		_combo lbAdd format ["%1 (%2cp)", _display, _cost];
	} forEach _x;
	_combo ctrlCommit 0;

	private _button = _display ctrlCreate ["RscButtonMenu", _tabIdx call OWL_fnc_TabIDC];
	_button ctrlSetPosition [_xrel+_wb*12, _yrel+_hb*15+(_forEachIndex*_hb*1.75), _wb*4, _hb*1.5];
	_button ctrlSetStructuredText parseText format ["<t size='0.15'>&#160;</t><br/><t font = 'PuristaLight' align = 'center' shadow = '2'>BUY %1</t>", toUpper _category];
	_button ctrlCommit 0;

	_asset_controls pushBack _combo;
	_asset_controls pushBack _button;
} forEach (OWL_reenforceAssetList get str(side player));

private _strategy_progress_pct_reenforce = _display ctrlCreate ["RscStructuredText", _tabIdx call OWL_fnc_TabIDC];
_strategy_progress_pct_reenforce ctrlSetPosition [_xrel+_wb*12, _yrel+_hb*20.75, _wb*11, _hb*1];
_strategy_progress_pct_reenforce ctrlSetStructuredText parseText "<t size='1' align='center'>40%</t>";
_strategy_progress_pct_reenforce ctrlCommit 0;

_asset_controls pushBack _strategy_progress_pct_reenforce;

private _strategy_label_loadout = _display ctrlCreate ["RscStructuredText", _tabIdx call OWL_fnc_TabIDC];
_strategy_label_loadout ctrlSetPosition [_xrel+_wb*23, _yrel+_hb*0.5, _wb*17, _hb*1];
_strategy_label_loadout ctrlSetStructuredText parseText "<t size='1' align='center' valign='middle'>Loadout</t>";
_strategy_label_loadout ctrlCommit 0;

uiNamespace setVariable ["OWL_UI_strategy_purchase_asset_controls", _asset_controls];

private _show = _cur_selected getVariable ["OWL_sectorSide", sideEmpty] == side player && !(_cur_selected getVariable ["OWL_sectorProtected", true]);
{
	_x ctrlShow _show;
} forEach _asset_controls;

private _loadOuts = [
	["RIFLEMAN", 0, true, "", "SquadLeader"],
	["ENGINEER", 200, false, "Toolkit", "Engineer"],
	["MEDIC", 200, false, "Medikit", "Medic"],
	["ANTI-TANK", 250, true, "AT Launcher", "AT"],
	["ANTI-AIR", 250, false, "AA Launcher", "AA"],
	["*ARSENAL", 1000, true, "", "Arsenal"]
];

{
	private _button_loadout = _display ctrlCreate ["RscButtonMenu", _tabIdx call OWL_fnc_TabIDC];
	_button_loadout ctrlSetPosition [_xrel+_wb*23.5 + (_forEachIndex % 2)*8.125*_wb, _yrel+_hb*3 + floor (_forEachIndex / 2)*(_hb*3+(_wb*0.125)), _wb*8, _hb*3];
	_button_loadout ctrlSetStructuredText parseText format ["<t font = 'PuristaLight' align = 'center' shadow = '2'>%1</t>", _x#0];
	_button_loadout ctrlSetFontHeight _hb*2.5;
	_button_loadout ctrlCommit 0;
	private _tooltip = "";
	if (!isNull (player call OWL_fnc_isInFriendlyZone)) then {
		_button_loadout ctrlEnable true; 
	} else {
		_tooltip = "You must be in a friendly zone to change loadout.\n";
		_button_loadout ctrlEnable false; 
	};

	_button_loadout setVariable ["OWL_buttonLoadout",(["B_", "O_"] # ([WEST, EAST] find (side player))) + (_x#4)];

	private _unlocked = (_x#2);
	private _req = (_x#3);
	if (!_unlocked) then {
		private _prog_loadout = _display ctrlCreate ["RscProgressVertical", _tabIdx call OWL_fnc_TabIDC];
		private _percent = random 1;
		private _color = [(1-(_percent*0.5)), _percent, 0, 0.8];
		_prog_loadout ctrlSetPosition [_xrel+_wb*23.5 + (_forEachIndex % 2)*8.125*_wb, _yrel+_hb*3 + floor (_forEachIndex / 2)*(_hb*3+(_wb*0.125)), _wb*0.5, _hb*3];
		_prog_loadout progressSetPosition _percent;
		_prog_loadout ctrlSetTextColor _color;
		_prog_loadout ctrlCommit 0;
		_tooltip = _tooltip + format ["Progress: %2%3\nTeam must unlock this loadout\n - Bring more %1s back to the main base weapons cache.\n", _req,floor(_percent*100), "%"];
		_button_loadout ctrlEnable false;
	};

	private _label = _display ctrlCreate ["RscStructuredText", _tabIdx call OWL_fnc_TabIDC];
	_label ctrlSetPosition [_xrel+_wb*23.5 + (_forEachIndex % 2)*8.125*_wb, _yrel+_hb*5 + floor (_forEachIndex / 2)*(_hb*3+(_wb*0.125)), _wb*8, _hb*1];
	_label ctrlSetBackgroundColor [0,0,0,0];
	_cost = (_x#1);

	_color = if ((uiNamespace getVariable ["OWL_UI_dummyFunds", 0]) >= _cost) then {"#FF00EE00"} else {"#FFEE0000"};

	if (!_unlocked) then {
		_color = "#AAAAAAAA";
	};

	_label ctrlSetStructuredText parseText format ["<t font = 'PuristaLight' color='%2' size='0.7' align = 'right' shadow = '2'>%1</t>", if (_cost == 0) then {"Free"} else {format ["%1cp", _cost]}, _color];
	_label ctrlCommit 0;

	if ((uiNamespace getVariable ["OWL_UI_dummyFunds", 0]) < _cost && _unlocked) then {
		_tooltip = _tooltip + "Not enough funds";
		_button_loadout ctrlEnable false;		
	};

	_button_loadout ctrlSetTooltip _tooltip;

	_button_loadout ctrlAddEventHandler ["ButtonClick", {
		_lc = (_this#0) getVariable "OWL_buttonLoadout";
		if ("Arsenal" in _lc) then {
			["Open", [true]] spawn BIS_fnc_arsenal;
		} else {
			_loadout = [player, missionConfigFile >> "CfgRespawnInventory" >> _lc] call BIS_fnc_loadInventory;
		};
	}];
} forEach _loadOuts;

_strategy_map ctrlAddEventHandler ["MouseButtonDown", {
	params ["_map", "_button", "_xPos", "_yPos", "_shift", "_ctrl", "_alt"];
	_overItem = ctrlMapMouseOver (_map);

	if (_button != 0) exitWith {};

	private _queue_button = uiNamespace getVariable ["OWL_UI_strategy_button_request", controlNull];
	if (ctrlText _queue_button == "Cancel") then {
		if (surfaceIsWater ( _map ctrlMapScreenToWorld[_xPos, _yPos]) ) then {
			_queue_button ctrlSetText "Select Location";
			_map ctrlMapCursor ["", "Arrow"];
		};
	};

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
					_sector call OWL_fnc_UI_StrategyTab_onLocationSelected;
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
		objNull call OWL_fnc_UI_StrategyTab_onLocationSelected;
	};
}];

// This ugly rework
_strategy_map ctrlAddEventHandler ["MouseMoving", {
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
				private _tooltip = (findDisplay 10655) displayCtrl 2999;
				if (isNull _tooltip) then {
					_tooltip = (findDisplay 10655) ctrlCreate ["RscStructuredText", 2999, _map];
					_tooltip ctrlEnable false;
				};

				private _struct = format ["<t size='0.8' align='center' valign='middle' shadow='2'>%1</t></br><t size='0.5' align='left' ", _sector getVariable "OWL_sectorName"];
				_struct = _struct + "ok";
				_tooltip ctrlSetStructuredText parseText _struct;
				_pos = _map ctrlMapWorldToScreen (position _sector);
				_tooltip ctrlSetPosition [_xpos, _ypos/*_pos#0+(safezoneW/40)*0.5, _pos#1*/, (safezoneW/40)*2.5, (safezoneH/25)*4];
				_tooltip ctrlSetBackgroundColor [0,0,0,0];
				_tooltip ctrlCommit 0;
				uiNamespace setVariable ["OWL_UI_strategy_map_last_sector", _sector];
			} else {
				_update = _update + _marker;
			};
		} else {
			_tooltip = (findDisplay 99) displayCtrl 2999;
			ctrlDelete _tooltip;
			uiNamespace setVariable ["OWL_UI_strategy_map_last_sector", objNull];
		};
	} else {
		_tooltip = (findDisplay 10655) displayCtrl 2999;
		ctrlDelete _tooltip;
		_map ctrlSetTooltip "";
		uiNamespace setVariable ["OWL_UI_strategy_map_last_sector", objNull];
	};

	if ( ctrlText (uiNamespace getVariable ["OWL_UI_strategy_button_request", controlNull]) == "Cancel") then {
		_map ctrlMapCursor ["", (if (surfaceIsWater ( _map ctrlMapScreenToWorld[_xpos, _ypos])) then {'HC_move'} else {'HC_unsel'})];
	};
}];

_strategy_map ctrlAddEventHandler ["Draw", {

	private _selected = uiNamespace getVariable ["OWL_UI_strategy_map_last_sector", objNull];
	private _clicked  = uiNamespace getVariable ["OWL_UI_strategy_map_last_clicked", objNull];
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

_strategy_map call OWL_fnc_UI_mapDrawCommon;

// This is to keep focus off of the map.
_display displayAddEventHandler ["MouseButtonUp", {
	_focused = focusedCtrl (_this#0);
	if (ctrlClassName _focused  == "RscMapControl") then {
		ctrlSetFocus (uiNamespace getVariable "OWL_UI_dummy");
	};
}];