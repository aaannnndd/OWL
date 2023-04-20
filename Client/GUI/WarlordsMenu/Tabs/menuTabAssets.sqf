params ["_display", "_tabIdx"];

if (!isNull (_display displayCtrl _tabIdx * 1000)) exitWith {};

_pos = ctrlPosition (_display displayCtrl 98);
_pos params ["_xrel", "_yrel", "_wrel", "_hrel"];
_wb = _wrel / 40;
_hb = _hrel / 25;

/**********************************************/
/**************[UI Logic Events]***************/
/**********************************************/

OWL_fnc_UI_AssetRequestTriggered = {
	params ["_assets", "_type", "_location"];

	systemChat str _this;
	
	[_location, _assets, _type] remoteExec ["OWL_fnc_crAirdrop", 2];
};

OWL_fnc_UI_AssetTab_onAssetRequestDecision = {
	params ["_orderNumber", "_decision", "_reason"];

	// recieve from server.
};

OWL_fnc_UI_AssetTab_onAirdropButtonClick = {
	params ["_button"];

	_queue_list = uiNamespace getVariable ["OWL_UI_asset_list_queue", controlNull];
	_assets = [];
	if (!isNull _queue_list) then {
		for "_i" from 0 to (lbSize _queue_list - 1) do {
			_item = _queue_list lbData _i;
			_assets pushBack _item;
		};

		if ((lbSize _queue_list) == 0) then {
			_button ctrlEnable false;
			(uiNamespace getVariable ["OWL_UI_asset_button_clear_queue", controlNull]) ctrlEnable false;
			(uiNamespace getVariable ["OWL_UI_asset_button_airdrop_location", controlNull]) ctrlEnable false;
		};
	};

	_target = player;
	// TODO - if localization is added this needs fixing.
	if (_button == uiNamespace getVariable ["OWL_UI_asset_button_airdrop_location", controlNull]) then {
		_sector = uiNamespace getVariable ["OWL_UI_asset_map_last_clicked", objNull];
		if (isNull _sector) then {
			systemChat "Error I suck at programming";
		} else {
			_target = _sector;
		};
	};

	_type = "";
	_infInVehicles = cbChecked  (uiNamespace getVariable ["OWL_UI_asset_checkbox_place_crew", controlNull]);
	if(_infInVehicles) then {
		_type = "+";
	};
	[_assets, _type, _target] call OWL_fnc_UI_AssetRequestTriggered;
};

// Todo: put this in config class/localization strings
OWL_CATEGORY_INFO = createHashMapFromArray [
	["Aircraft", "Requesting aircraft requires control of a sector with the proper disposition (Helipad/Runway). Aircraft will be delivered to the selected sector upon purchase"],
	["Infantry", "You may have a squad of up to 6 soldiers which you can command. Requested infantry will be airdropped to the selected location."],
	["Naval", "Naval assets require at least one sector with a Harbor. Asset may only be requested on a water surface."],
	["Vehicles", "Maximum of 20 vehicles at one time. Requested vehicle assets will be airdropped to the selected location."],
	["Gear", "Airdrop supplies for vehicles and infantry at a the selected location."],
	["Defences", "Defences may be placed inside of controlled sectors. Enemies must be a sufficient distance away."]
];

OWL_fnc_UI_AssetTab_onCategoryChange = {
	//params ["_category_list", "_index"];

	// Do not clear the queue.
	// Change the 'Confirm Airdrop' visual based on selected sector and category
	// Enable / Disable the 'Add to Queue' button based on category
	// Enable / Disable the 'queue list'
	// Enable / Disable clear/remove queue buttons

	params ["_list_category", "_index"];

	_category = _list_category lbData _index;
	_assetInfo = (OWL_assetList get playerSide) get _category;

	_list_items = uiNamespace getVariable ["OWL_UI_asset_list_items", controlNull];
	lbClear _list_items;

	{
		 (OWL_assetInfo get _x) params ["_name", "_cost", "_requirements"];
		_list_items lbAdd _name;
		_list_items lbSetValue [_forEachIndex, _cost];
		_list_items lbSetData [_forEachIndex, _x];
	
		if (_x call OWL_fnc_UI_checkAssetRequirements == 0) then {
			_list_items lbSetColor [_forEachIndex, [1,1,1,1]];
		} else {
			_list_items lbSetColor [_forEachIndex, [1,1,1,0.1]];
		};
	} forEach _assetInfo;

	_list_items lbSetCurSel -1;
	_list_items ctrlCommit 0;

	_btn = uiNamespace getVariable ["OWL_UI_asset_button_request", controlNull];
	_btn ctrlEnable false;

	uiNamespace setVariable ["OWL_UI_lastCategory", _category];

	_info = uiNamespace getVariable "OWL_UI__asset_label_category_info";
	_info ctrlSetStructuredText parseText format ["<t size='0.8' align='center' valign='middle'>%1</t>", OWL_CATEGORY_INFO get _category];
};

OWL_fnc_UI_checkAssetRequirements = {
	params ["_class"];

	(OWL_assetInfo get _class) params ["_name", "_cost", "_requirements"];

	_errorCode = 0;

	if (_cost > OWL_UI_menuDummyFunds) then {
		_errorCode = _errorCode + 1;
	};

	if (count _requirements > 0) then {
		if (!([playerSide, _requirements#0] call OWL_fnc_hasAssetRequirement)) then {
			_errorCode = _errorCode + 2;
		};
	};

	_errorCode;
};

OWL_fnc_UI_assetRequestTooltip = {
	params ["_errorCode"];
	private _tooltip = "";
	if ([_errorCode, 1] call BIS_fnc_bitflagsCheck) then {
		_tooltip = "You're too poor! ";
	};
	if ([_errorCode, 2] call BIS_fnc_bitflagsCheck) then {
		_tooltip = _tooltip + "No sectors with asset requirement!";
	};
	_tooltip;
};

OWL_fnc_UI_AssetTab_onItemSelected = {
	// Change the 'Confirm Airdrop' visual based on selected sector and category and item requisition.
	params ["_list_items", "_index"];

	private _class = "";
	if (_index >= 0) then {
		_class = _list_items lbData _index;
	} else {
		// ???
	};

	_class call OWL_fnc_UI_AssetTab_updateAssetPreview;

	private _category_list = uiNamespace getVariable ["OWL_UI_asset_list_category", controlNull];
	private _idx = lbCurSel _category_list;
	private _category = _category_list lbData _idx;

	private _request_button = uiNamespace getVariable ["OWL_UI_asset_button_request", controlNull];
	private _button_airdrop_loc = uiNamespace getVariable ["OWL_UI_asset_button_airdrop_location", controlNull];
	private _button_airdrop_self = uiNamespace getVariable ["OWL_UI_asset_button_airdrop_self", controlNull];
	private _selected_location = uiNamespace getVariable ["OWL_UI_asset_map_last_clicked", objNull];

	private _errorCode = _class call OWL_fnc_UI_checkAssetRequirements;
	_request_button ctrlEnable (_errorCode == 0);
	
	private _tooltip = _errorCode call OWL_fnc_UI_assetRequestTooltip;
	_request_button ctrlSetTooltip _tooltip;
};

OWL_fnc_UI_AssetTab_onLocationSelected = {
	params ["_object"];

	_previousSector = uiNamespace getVariable ["OWL_UI_asset_map_last_clicked", objNull];

	private _selected_label = uiNamespace getVariable ["OWL_UI_asset_label_selected_location", controlNull];
	private _asset_list_queue = uiNamespace getVariable ["OWL_UI_asset_list_queue", controlNull];
	private _airdrop_button = uiNamespace getVariable ["OWL_UI_asset_button_airdrop_location", controlNull];

	if (isNull _object) exitWith {
		_selected_label ctrlSetStructuredText parseText "<t size='1' align='center' valign='middle'>Dispatch Location: <t size='1' color='#ff0000'>None</t></t>";
		uiNamespace setVariable ["OWL_UI_asset_map_last_clicked", objNull];
		_airdrop_button ctrlSetText "NONE";
		_airdrop_button ctrlEnable false;
	};

	_selected_label ctrlSetStructuredText parseText format ["<t size='1' align='center' valign='middle'>Dispatch Location: <t size='1' color='%2'>%1</t></t>", _sector getVariable "OWL_sectorName", ["#0000ff", "#ff0000", "#00ff00"] select ([WEST, EAST, RESISTANCE] find (_sector getVariable "OWL_sectorSide"))];
	_airdrop_button ctrlSetText toUpper (_sector getVariable "OWL_sectorName");
	_airdrop_button ctrlEnable (OWL_UI_menuDummyFunds >= 0) && ([player, _object] call OWL_fnc_conditionAirdropLocation);
	uiNamespace setVariable ["OWL_UI_asset_map_last_clicked", _sector];

	// Do the airdrop validity checks
};

OWL_fnc_UI_AssetTab_onQueueCleared = {
	params ["_button"];

	// Change the 'Confirm Airdrop' if the category is currently infantry/gear (enable/disable button + text)
	// Disable the clear queue buttons

	_queue_list = uiNamespace getVariable ["OWL_UI_asset_list_queue", controlNull];
	if (!(isNull _queue_list)) then {
		private _totalCost = 0;

		for "_i" from 0 to (lbSize _queue_list - 1) do {
			_item = _queue_list lbData _i;
			(OWL_assetInfo get _item) params ["_name", "_cost", "_requirements"];
			_totalCost = _totalCost + _cost;
		};

		_totalCost call OWL_fnc_UI_AssetTab_onCPChanged;

		lbClear _queue_list;

		_button ctrlEnable false;
		(uiNamespace getVariable ["OWL_UI_asset_button_remove_queue", controlNull]) ctrlEnable false;
		(uiNamespace getVariable ["OWL_UI_asset_button_airdrop_location", controlNull]) ctrlEnable false;
		(uiNamespace getVariable ["OWL_UI_asset_button_airdrop_self", controlNull]) ctrlEnable false;
	};
};

OWL_fnc_UI_AssetTab_onQueueRemove = {
	params ["_button"];

	_queue_list = uiNamespace getVariable ["OWL_UI_asset_list_queue", controlNull];
	if (!isNull _queue_list) then {
		_idx = lbCurSel _queue_list;
		_item = _queue_list lbData _idx;
		_queue_list lbDelete _idx;

		if ((lbSize _queue_list) == 0) then {
			_button ctrlEnable false;
			(uiNamespace getVariable ["OWL_UI_asset_button_clear_queue", controlNull]) ctrlEnable false;
			(uiNamespace getVariable ["OWL_UI_asset_button_airdrop_location", controlNull]) ctrlEnable false;
			(uiNamespace getVariable ["OWL_UI_asset_button_airdrop_self", controlNull]) ctrlEnable false;
		};

		(OWL_assetInfo get _item) params ["_name", "_cost", "_requirements"];
		_cost call OWL_fnc_UI_AssetTab_onCPChanged;

		if (OWL_UI_menuDummyFunds >= 0) then {
			(uiNamespace getVariable ["OWL_UI_asset_button_airdrop_location", controlNull]) ctrlEnable !isNull (uiNamespace getVariable ["OWL_UI_asset_map_last_clicked", objNull]);
			// TODO: adjust this for 'self airdrop' cost. Elsewhere as well.
			(uiNamespace getVariable ["OWL_UI_asset_button_airdrop_self", controlNull]) ctrlEnable (OWL_UI_menuDummyFunds > 1000);
		};
	};
};

OWL_fnc_UI_AssetTab_onRequestItemNaval = {
	params ["_asset"];

	// If we are confirming the request we have selected the point on the map.
	// Otherwise we are requesting the item on the map.
	
	// Confirm = modify the confirm button back to 'Selected Location'
	// 	Change confirm butto back to normal -> unselect current list item.
	// Request = modify the confirm button to 'Cancel'

	"BIS_WL_Destination_WEST" call OWL_fnc_eventAnnouncer;

	private _assetMap = uiNamespace getVariable ["OWL_UI_asset_map", controlNull];
	private _pos = ctrlPosition _assetMap;
	_pos = [_pos#0 + (_pos#2)*0.5, _pos#1 + (_pos#3)*0.5];
	private _start = getMousePosition;

	[_start, _pos] spawn {
		params ["_start", "_end"];
		for "_i" from 0 to 2000 do {
			setMousePosition [_start#0 + (_end#0 - _start#0)*(_i / 2000), _start#1 + (_end#1 - _start#1)*(_i / 2000)];
		};
	};

	uiNamespace setVariable ["OWL_UI_naval_asset", _asset];
	uiNamespace setVariable ["OWL_UI_asset_status", "Naval"];
};

OWL_fnc_UI_AssetTab_onRequestItemAircraft = {
	params ["_asset"];

	_sector = uiNamespace getVariable ["OWL_UI_asset_map_last_clicked", objNull];
	[player, _sector, _asset] remoteExec ["OWL_fnc_crAircraftSpawn", 2];
};

OWL_fnc_UI_AssetTab_onRequestItemAirdrop = {
	params ["_button", "_asset", "_category"];

	_asset_queue = uiNamespace getVariable ["OWL_UI_asset_list_queue", controlNull];
	_button_clear_queue = uiNamespace getVariable ["OWL_UI_asset_button_clear_queue", controlNull];
	_button_remove_queue = uiNamespace getVariable ["OWL_UI_asset_button_remove_queue", controlNull];
	_button_airdrop_loc = uiNamespace getVariable ["OWL_UI_asset_button_airdrop_location", controlNull];
	_button_airdrop_self = uiNamespace getVariable ["OWL_UI_asset_button_airdrop_self", controlNull];

	(OWL_assetInfo get _asset) params ["_name", "_cost", "_requirements"];

	if (OWL_UI_menuDummyFunds - _cost < 0) exitWith {
		_button ctrlEnable false;
	};

	_button_clear_queue ctrlEnable true;
	_button_remove_queue ctrlEnable true;

	_button_airdrop_loc	ctrlEnable !isNull (uiNamespace getVariable ["OWL_UI_asset_map_last_clicked", objNull]);
	_button_airdrop_self ctrlEnable (OWL_UI_menuDummyFunds - _cost >= 1000);

	_asset_queue lbAdd _name;
	_asset_queue lbSetData [lbSize _asset_queue - 1, _asset];
	_cost = _cost * -1;
	_cost call OWL_fnc_UI_AssetTab_onCPChanged;
};

OWL_fnc_UI_AssetTab_onRequestItemDefense = {
	params ["_asset"];

	systemChat _asset;
	_asset call OWL_fnc_handleDeployDefense;
};

OWL_fnc_UI_AssetTab_onSectorChanged = {
	// Update requisition assets (harbor, helipad, runway)
	// 
};

OWL_fnc_UI_AssetTab_updateAssetPreview = {
	params ["_class"];

	private _queue_button = uiNamespace getVariable ["OWL_UI_asset_button_request", controlNull];
	private _asset_label_details_display = uiNamespace getVariable ["OWL_UI_asset_label_details_display", controlNull];

	if (isNull _queue_button || isNull _asset_label_details_display) exitWith {
		systemChat "OWL_fnc_UI_AssetTab_updateAssetPreview: controlNull";
	};
	
	private _name = "";
	private _cost = 0;
	private _reqs = "";
	private _desc = "";
	private _pic = "\A3\EditorPreviews_F\Data\CfgVehicles\VR_Area_01_square_1x1_yellow_F.jpg";

	private _fmtBlock = "<img image = '%1' size = '7' align = 'center' shadow = '0'></img>";

	if (_class == "") then {
		_queue_button ctrlEnable false;
		_fmtBlock = _fmtBlock + "<t size='1' align='center' valign='middle'>%2<br/>";
	} else {
		_queue_button ctrlEnable true;
		_pic = getText (configFile >> "CfgVehicles" >> _class >> "editorPreview");
		_info = OWL_assetInfo get _class;
		_name = _info # 0;
		_cost = _info # 1;
		_reqs = _info # 2;
		
		if (_cost == 0) then {
			_fmtBlock = _fmtBlock + "<t size='1' align='center' valign='middle'>Free<br/>%2<br/>";
		} else {
			if (_cost > OWL_UI_menuDummyFunds) then {
				_fmtBlock = _fmtBlock + "<t size='1' align='center' valign='middle', color='#ff0000'>%3 CP<br/>%2<br/>";
				_queue_button ctrlEnable false;
			} else {
				_fmtBlock = _fmtBlock + "<t size='1' align='center' valign='middle'>%3 CP<br/>%2<br/>";
			};
		};

		_desc = getText (configFile >> "CfgVehicles" >> _class >> "Library" >> "libTextDesc");
		if (isLocalized _desc) then {
			_desc = localize _desc;
		};

		if (_desc == "") then {_desc = getText (configFile >> "CfgVehicles" >> _class >> "Armory" >> "description");};
		if (isLocalized _desc) then { _desc = localize _desc };

		if (_desc == "") then {
			_validClassArr = "toLower getText (_x >> 'vehicle') == toLower _class" configClasses (configFile >> "CfgHints" >> "VehicleList");
			if (count _validClassArr > 0) then {
				_hintLibClass = ("toLower getText (_x >> 'vehicle') == toLower _class" configClasses (configFile >> "CfgHints" >> "VehicleList")) # 0;
				_text = getText (_hintLibClass >> "description");
				if (count _text > 0) then {
					if (((toArray _text) # 0) == 37) then {
						_text = localize (((getArray (_hintLibClass >> "arguments")) # 1) # 0);
					};
				};
				_desc = _text;
			};
		};

		if (_desc == "") then {
			_validClassArr = "toLower getText (_x >> 'vehicle') == toLower _class" configClasses (configFile >> "CfgHints" >> "WeaponList");
			if (count _validClassArr > 0) then {
				_hintLibClass = ("toLower getText (_x >> 'vehicle') == toLower _class" configClasses (configFile >> "CfgHints" >> "WeaponList")) # 0;
				_text = getText (_hintLibClass >> "description");
				if (count _text > 0) then {
					if (((toArray _text) # 0) == 37) then {
						_text = localize (((getArray (_hintLibClass >> "arguments")) # 1) # 0);
					};
				};
				_desc = _text;
			};			
		};

		if (_desc == "") then {
			_text = "";
			_wpns = getArray (configFile >> "CfgVehicles" >> _class >> "weapons");
			_wpnArrPrimary = _wpns select {getNumber (configFile >> "CfgWeapons" >> _x >> "type") == 1};
			_wpnArrSecondary = _wpns select {getNumber (configFile >> "CfgWeapons" >> _x >> "type") == 4};
			_wpnArrHandgun = _wpns select {getNumber (configFile >> "CfgWeapons" >> _x >> "type") == 2};
			_wpn = if (count _wpnArrSecondary > 0) then {
				_wpnArrSecondary # 0;
			} else {
				if (count _wpnArrPrimary > 0) then {
					_wpnArrPrimary # 0;
				} else {
					if (count _wpnArrHandgun > 0) then {
						_wpnArrPrimary # 0;
					} else {
						""
					};
				};
			};
			{
				_text = _text + (getText (configFile >> "CfgWeapons" >> _x >> "displayName")) + "<br/>";
			} forEach (_wpnArrPrimary + _wpnArrSecondary + _wpnArrHandgun);
			if (_text != "") then {
				_text = _text + "<br/>";
			};
			_linked = getArray (configFile >> "CfgVehicles" >> _class >> "linkedItems");
			if (count _linked > 0) then {
				_text = _text + (getText (configFile >> "CfgWeapons" >> _linked # 0 >> "displayName")) + "<br/>";
			};
			_backpack = getText (configFile >> "CfgVehicles" >> _class >> "backpack");
			if (_backpack != "") then {_text = _text + (getText (configFile >> "CfgVehicles" >> _backpack >> "displayName"))};
			_desc = _text;
		};

		if (_desc == "") then {
			_text = "";
			_transportWeapons = (configFile >> "CfgVehicles" >> _class >> "TransportWeapons");
			_weaponsCnt = (count _transportWeapons);
			for [{_i = 0}, {_i < _weaponsCnt}, {_i = _i + 1}] do {
				_item = getText ((_transportWeapons select _i) >> "weapon");
				_text = _text + format ["%3%2x %1", getText (configFile >> "CfgWeapons" >> _item >> "displayName"), getNumber ((_transportWeapons select _i) >> "count"), if (_text == "") then {""} else {", "}];
			};
			_transportItems = (configFile >> "CfgVehicles" >> _class >> "TransportItems");
			_itemsCnt = (count _transportItems);
			for [{_i = 0}, {_i < _itemsCnt}, {_i = _i + 1}] do {
				_item = getText ((_transportItems select _i) >> "name");
				_text = _text + format ["%3%2x %1", getText (configFile >> "CfgWeapons" >> _item >> "displayName"), getNumber ((_transportItems select _i) >> "count"), if (_text == "") then {""} else {", "}];
			};
			_transportMags = (configFile >> "CfgVehicles" >> _class >> "TransportMagazines");
			_magsCnt = (count _transportMags);
			for [{_i = 0}, {_i < _magsCnt}, {_i = _i + 1}] do {
				_item = getText ((_transportMags select _i) >> "magazine");
				_text = _text + format ["%3%2x %1", getText (configFile >> "CfgMagazines" >> _item >> "displayName"), getNumber ((_transportMags select _i) >> "count"), if (_text == "") then {""} else {", "}];
			};
			_transportBPacks = (configFile >> "CfgVehicles" >> _class >> "TransportBackpacks");
			_bPacksCnt = (count _transportBPacks);
			for [{_i = 0}, {_i < _bPacksCnt}, {_i = _i + 1}] do {
				_item = getText ((_transportBPacks select _i) >> "backpack");
				_text = _text + format ["%3%2x %1", getText (configFile >> "CfgVehicles" >> _item >> "displayName"), getNumber ((_transportMags select _i) >> "count"), if (_text == "") then {""} else {", "}];
			};
			_desc = _text;
		};

		if (count _reqs > 0) then {
			_reqs = (_reqs#0);
			_color = '#ff0000';
			if ([playerSide, _reqs] call OWL_fnc_hasAssetRequirement) then {_color = '#00ff00';};
			_fmtBlock = _fmtBlock + format ["<t size='0.75' align='left' color='%1' valign='left'>*Requires %2<br/></t>", _color, _reqs call OWL_fnc_getAssetRequirementName];
		};
	};

	_fmtBlock = _fmtBlock + "</t><t size='0.75' align='left' valign='middle'>%4</t>";
	_asset_label_details_display ctrlSetStructuredText parseText format[_fmtBlock, _pic, _name, _cost, _desc];
	_asset_label_details_display ctrlCommit 0;
};

/**********************************************/
/************[Category+Item List]**************/
/**********************************************/

private _selected_location = uiNamespace getVariable ["OWL_UI_asset_map_last_clicked", objNull];

private _menu_asset_header = _display ctrlCreate ["RscText", _tabIdx call OWL_fnc_TabIDC];
_menu_asset_header ctrlSetPosition [_xrel, _yrel, _wb*40, _hb*2];
_menu_asset_header ctrlSetBackgroundColor [0,0,0,0.2];
_menu_asset_header ctrlCommit 0;

private _menu_asset_footer = _display ctrlCreate ["RscStructuredText", _tabIdx call OWL_fnc_TabIDC];
_menu_asset_footer ctrlSetPosition [_xrel, _yrel+_hb*23, _wb*40, _hb*2];
_menu_asset_footer ctrlSetBackgroundColor [0,0,0,0.2];
_menu_asset_footer ctrlSetStructuredText parseText format ["<t size='0.25'>&#160;</t><br/><t size='1.25' align='center' valign='bottom'>%1 CP, Harbor, 6 Recruits Available</t>", OWL_UI_menuDummyFunds];
_menu_asset_footer ctrlCommit 0;

uiNamespace setVariable ["OWL_UI_asset_menu_footer", _menu_asset_footer];

private _menu_label_assets = _display ctrlCreate ["RscStructuredText", _tabIdx call OWL_fnc_TabIDC];
_menu_label_assets ctrlSetPosition [_xrel+_wb*12, _yrel+_hb*0.5, _wb*11, _hb*1];
_menu_label_assets ctrlSetStructuredText parseText "<t size='1' align='center' valign='middle'>Assets</t>";
_menu_label_assets ctrlCommit 0;

private _menu_label_category_info = _display ctrlCreate ["RscStructuredText", _tabIdx call OWL_fnc_TabIDC];
_menu_label_category_info ctrlSetPosition [_xrel+_wb*12, _yrel+_hb*17.5, _wb*11, _hb*4];
_menu_label_category_info ctrlSetStructuredText parseText "<t size='0.8' align='center' valign='middle'>Information about the category you have selected</t>";
_menu_label_category_info ctrlCommit 0;

uiNamespace setVariable ["OWL_UI__asset_label_category_info", _menu_label_category_info];

private _asset_list_category = _display ctrlCreate ["RscListBox", _tabIdx call OWL_fnc_TabIDC];
_asset_list_category ctrlSetPosition [_xrel+_wb*12, _yrel+_hb*3, _wb*5, _hb*14];
{
	_category = _x;
	_asset_list_category lbAdd _x;
	_asset_list_category lbSetValue [(lbSize _asset_list_category) - 1, _forEachIndex];
	_asset_list_category lbSetData [(lbSize _asset_list_category) - 1, _x];
	
} forEach (OWL_assetList get playerSide);
_asset_list_category ctrlCommit 0;
uiNamespace setVariable ["OWL_UI_asset_list_category", _asset_list_category];

_asset_list_category ctrlAddEventHandler ["LBSelChanged", OWL_fnc_UI_AssetTab_onCategoryChange];

private _asset_list_items = _display ctrlCreate ["RscListBox", _tabIdx call OWL_fnc_TabIDC];
_asset_list_items ctrlSetPosition [_xrel+_wb*17, _yrel+_hb*3, _wb*6, _hb*14];
_asset_list_items ctrlCommit 0;
uiNamespace setVariable ["OWL_UI_asset_list_items", _asset_list_items];

_asset_list_items ctrlAddEventHandler ["LBSelChanged", OWL_fnc_UI_AssetTab_onItemSelected];

/**********************************************/
/************[Asset Information]***************/
/**********************************************/

private _menu_label_asset_details = _display ctrlCreate ["RscStructuredText", _tabIdx call OWL_fnc_TabIDC];
_menu_label_asset_details ctrlSetPosition [_xrel+_wb*23, _yrel+_hb*0.5, _wb*8.5, _hb*1];
_menu_label_asset_details ctrlSetStructuredText parseText "<t size='1' align='center' valign='middle'>Details</t>";
_menu_label_asset_details ctrlCommit 0;
// 455x256
_aspect_hack = (_wb*9.5)*0.725;

private _asset_label_details_display = _display ctrlCreate ["RscStructuredText", _tabIdx call OWL_fnc_TabIDC];
_asset_label_details_display ctrlSetPosition [_xrel+_wb*23, _yrel+_hb*3.05, _wb*8.5, _hb*21.95];
_asset_label_details_display ctrlCommit 0;
uiNamespace setVariable ["OWL_UI_asset_label_details_display", _asset_label_details_display];

/**********************************************/
/**********[Asset Queue Management]************/
/**********************************************/

private _asset_label_deploy = _display ctrlCreate ["RscStructuredText", _tabIdx call OWL_fnc_TABIDC];
_asset_label_deploy ctrlSetPosition [_xrel+_wb*31.5, _yrel+_hb*0.5, _wb*8, _hb*1];
_asset_label_deploy ctrlSetStructuredText parseText"<t size='1' align='center' valign='middle'>Deployment</t>";
_asset_label_deploy ctrlCommit 0;

private _asset_button_request = _display ctrlCreate ["RscButtonMenu", _tabIdx call OWL_fnc_TabIDC];
_asset_button_request ctrlSetPosition [_xrel+_wb*31.5, _yrel+_hb*3, _wb*8, _hb*2];
_asset_button_request ctrlSetText "REQUEST";
_asset_button_request ctrlEnable false;
_asset_button_request ctrlCommit 0;
uiNamespace setVariable ["OWL_UI_asset_button_request", _asset_button_request];

_asset_button_request ctrlAddEventHandler ["ButtonClick", {
	params ["_button"];

	private _asset_list = uiNamespace getVariable ["OWL_UI_asset_list_items", controlNull];
	private _asset = _asset_list lbData (lbCurSel _asset_list);

	private _category_list = uiNamespace getVariable ["OWL_UI_asset_list_category", controlNull];
	private _idx = lbCurSel _category_list;
	private _category = _category_list lbData _idx;

	switch (_category) do {
		case "Gear";
		case "Infantry";
		case "Vehicles":
		{
			[_button, _asset, _category] call OWL_fnc_UI_AssetTab_onRequestItemAirdrop;
		};
		case "Aircraft":
		{
			_asset call OWL_fnc_UI_AssetTab_onRequestItemAircraft;
		};
		case "Naval":
		{
			_asset call OWL_fnc_UI_AssetTab_onRequestItemNaval;
		};
		case "Defences":
		{
			_asset call OWL_fnc_UI_AssetTab_onRequestItemDefense;
		};
		default
		{
			["_asset_button_request:onButtonClick - Invalid Category!"] call OWL_fnc_log;
		};
	};
}];

private _asset_label_airdrop_queue = _display ctrlCreate ["RscStructuredText", _tabIdx call OWL_fnc_TabIDC];
_asset_label_airdrop_queue ctrlSetPosition [_xrel+_wb*31.5, _yrel+_hb*5.5, _wb*8, _hb*1];
_asset_label_airdrop_queue ctrlSetStructuredText parseText"<t size='0.8' align='center' valign='middle'>Airdrop Queue</t>";
_asset_label_airdrop_queue ctrlCommit 0;

private _asset_list_queue = _display ctrlCreate ["RscListBox", _tabIdx call OWL_fnc_TabIDC];
_asset_list_queue ctrlSetPosition [_xrel+_wb*31.5, _yrel+_hb*6.5, _wb*8, _hb*7];
_asset_list_queue ctrlCommit 0;
uiNamespace setVariable ["OWL_UI_asset_list_queue", _asset_list_queue];

private _asset_button_clear_queue = _display ctrlCreate ["RscButtonMenu", _tabIdx call OWL_fnc_TabIDC];
_asset_button_clear_queue ctrlSetPosition [_xrel+_wb*31.5, _yrel+_hb*13.75, _wb*3.98, _hb*1.25];
_asset_button_clear_queue ctrlSetText "Clear Queue";
_asset_button_clear_queue ctrlEnable false;
_asset_button_clear_queue ctrlCommit 0;
uiNamespace setVariable ["OWL_UI_asset_button_clear_queue", _asset_button_clear_queue];

_asset_button_clear_queue ctrlAddEventHandler ["ButtonClick", OWL_fnc_UI_AssetTab_onQueueCleared];

private _asset_button_remove_queue = _display ctrlCreate ["RscButtonMenu", _tabIdx call OWL_fnc_TabIDC];
_asset_button_remove_queue ctrlSetPosition [_xrel+_wb*35.5, _yrel+_hb*13.75, _wb*4, _hb*1.25];
_asset_button_remove_queue ctrlSetText "Clear Selected";
_asset_button_remove_queue ctrlEnable false;
_asset_button_remove_queue ctrlCommit 0;
uiNamespace setVariable ["OWL_UI_asset_button_remove_queue", _asset_button_remove_queue];

_asset_button_remove_queue ctrlAddEventHandler ["ButtonClick", OWL_fnc_UI_AssetTab_onQueueRemove];

private _asset_label_airdrop_location = _display ctrlCreate ["RscStructuredText", _tabIdx call OWL_fnc_TabIDC];
_asset_label_airdrop_location ctrlSetPosition [_xrel+_wb*31.5, _yrel+_hb*15.5, _wb*8, _hb*1];
_asset_label_airdrop_location ctrlSetStructuredText parseText"<t size='0.8' align='center' valign='middle'>Airdrop Location</t>";
_asset_label_airdrop_location ctrlCommit 0;

private _asset_label_selected_location = _display ctrlCreate ["RscStructuredText", _tabIdx call OWL_fnc_TabIDC];
_asset_label_selected_location ctrlSetPosition [_xrel+_wb*0.5, _yrel+_hb*17.5, _wb*11, _hb*1.5];
_asset_label_selected_location ctrlSetStructuredText parseText format ["<t size='1' align='center' valign='middle'>Dispatch Location: <t size='1' color='%2'>%1</t></t>", _selected_location getVariable ["OWL_sectorName", if (isNull _selected_location) then {"None"} else {"Your Location"}], _selected_location getVariable ["OWL_sectorColor", if (_selected_location == player) then {"#ffff00"} else {"#ff0000"}]];
_asset_label_selected_location ctrlCommit 0;
uiNamespace setVariable ["OWL_UI_asset_label_selected_location", _asset_label_selected_location];

private _asset_button_airdrop_location = _display ctrlCreate ["RscButtonMenu", _tabIdx call OWL_fnc_TabIDC];
_asset_button_airdrop_location ctrlSetPosition [_xrel+_wb*31.5, _yrel+_hb*16.5, _wb*8, _hb*2];
_asset_button_airdrop_location ctrlSetText format ["%1", toUpper (_selected_location getVariable ["OWL_sectorName", "None"])];
_asset_button_airdrop_location ctrlEnable false;
_asset_button_airdrop_location ctrlCommit 0;
uiNamespace setVariable ["OWL_UI_asset_button_airdrop_location", _asset_button_airdrop_location];

_asset_button_airdrop_location ctrlAddEventHandler ["ButtonClick", OWL_fnc_UI_AssetTab_onAirdropButtonClick];

private _asset_button_airdrop_self = _display ctrlCreate ["RscButtonMenu", _tabIdx call OWL_fnc_TabIDC];
_asset_button_airdrop_self ctrlSetPosition [_xrel+_wb*31.5, _yrel+_hb*18.75, _wb*8, _hb*2];
_asset_button_airdrop_self ctrlSetText "YOUR LOCATION";
_asset_button_airdrop_self ctrlEnable false;
_asset_button_airdrop_self ctrlCommit 0;
uiNamespace setVariable ["OWL_UI_asset_button_airdrop_self", _asset_button_airdrop_self];

_asset_button_airdrop_self ctrlAddEventHandler ["ButtonClick", OWL_fnc_UI_AssetTab_onAirdropButtonClick];

private _asset_checkbox_place_crew = _display ctrlCreate ["RscCheckBox", _tabIdx call OWL_fnc_TABIDC];
_asset_checkbox_place_crew ctrlSetPosition [_xrel+_wb*32, _yrel+_hb*21, _hb*1, _hb*1];
_asset_checkbox_place_crew cbSetChecked true;
_asset_checkbox_place_crew ctrlCommit 0;
uiNamespace setVariable ["OWL_UI_asset_checkbox_place_crew", _asset_checkbox_place_crew];

private _asset_label_checkbox_place_crew = _display ctrlCreate ["RscStructuredText", _tabIdx call OWL_fnc_TabIDC];
_asset_label_checkbox_place_crew ctrlSetPosition [_xrel+_wb*33, _yrel+_hb*21.1, _hb*8, _hb*1];
_asset_label_checkbox_place_crew ctrlSetStructuredText parseText "<t size='0.8' align='left' valign='middle'>Place queued infantry with vehicles</t>";
_asset_label_checkbox_place_crew ctrlCommit 0;

/**********************************************/
/***********[Asset Drop Location]**************/
/**********************************************/

private _asset_map = _display ctrlCreate ["RscMapControl", _tabIdx call OWL_fnc_TabIDC];
_asset_map ctrlSetPosition [_xrel+_wb*0.5, _yrel+_hb*3, _wb*11, _hb*14];
_asset_map ctrlMapSetPosition [_xrel+_wb*0.5, _yrel+_hb*3, _wb*11, _hb*14];
_asset_map ctrlMapAnimAdd [0.5, 0.8, position player];
_asset_map mapCenterOnCamera false;
_asset_map ctrlCommit 0;
ctrlMapAnimCommit _asset_map;

uiNamespace setVariable ["OWL_UI_asset_map", _asset_map];

private _asset_map_selected_label = _display ctrlCreate ["RscStructuredText", _tabIdx call OWL_fnc_TabIDC];
_asset_map_selected_label ctrlSetPosition [_xrel+_wb*0.5, _yrel+_hb*0.5, _wb*11, _hb*2];
_asset_map_selected_label ctrlSetStructuredText parseText "<t size='1' align='center' valign='middle'>Drop Location</t>";
_asset_map_selected_label ctrlCommit 0;

_asset_map ctrlAddEventHandler ["MouseButtonDown", {
	params ["_map", "_button", "_xPos", "_yPos", "_shift", "_ctrl", "_alt"];
	_overItem = ctrlMapMouseOver (_map);

	if (_button != 0) exitWith {};

	private _status = uiNamespace getVariable ["OWL_UI_asset_status", ""];
	if (_status == "Naval") exitWith {
		if (surfaceIsWater ( _map ctrlMapScreenToWorld[_xPos, _yPos]) ) then {
			_map ctrlMapCursor ["", "Arrow"];
			_map ctrlCommit 0;
			uiNamespace setVariable ["OWL_UI_asset_status", ""];
			private _loc = _map ctrlMapScreenToWorld[_xPos, _yPos];
			private _asset = uiNamespace getVariable ["OWL_UI_naval_asset", ""];
			[_loc, _asset] remoteExec ["OWL_fnc_crDeployNaval", 2];
		};
	};

	private _queue_button = uiNamespace getVariable ["OWL_UI_asset_button_request", controlNull];

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
					_sector call OWL_fnc_UI_AssetTab_onLocationSelected;
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
		objNull call OWL_fnc_UI_AssetTab_onLocationSelected;
	};
}];

// This ugly rework
_asset_map ctrlAddEventHandler ["MouseMoving", {
	params ["_map", "_xpos", "_ypos", "_mouseOver"];
	_overItem = ctrlMapMouseOver (_map);

	private _status = uiNamespace getVariable ["OWL_UI_asset_status", ""];
	if (_status == "Naval") exitWith {
		_map ctrlMapCursor ["", (if (surfaceIsWater ( _map ctrlMapScreenToWorld[_xpos, _ypos])) then {'HC_move'} else {'HC_unsel'})];
		_map ctrlCommit 0;
	};

	private _queue_button = uiNamespace getVariable ["OWL_UI_asset_button_request", controlNull];

	_update = "Over: ";
	if (count _overItem > 0) then {
		_overItem params ["_type", "_marker"];
		if (_type == "marker") then {

			if ("OWL" in _marker) then {
				_idx = -1;
				_idx = (_marker splitString "_") # 2;
				_idx = parseNumber _idx;

				_sector = OWL_allSectors # _idx;
				_update = _update + (_sector getVariable "OWL_sectorName");
				_tooltip = (findDisplay 99) displayCtrl 2999;
				ctrlDelete _tooltip;
				_tooltip = (findDisplay 99) ctrlCreate ["RscStructuredText", 2999, _map];
				_tooltip ctrlEnable false;

				_color = ['#0099ff', '#DD1111', '#00ff44'] # ([WEST, EAST, RESISTANCE] find (_sector getVariable "OWL_sectorSide"));
				_tooltip ctrlSetStructuredText parseText format ["<t size='0.8' align='center' color='%2' valign='middle'>%1</t></br><t size='0.5' align='left' ", _sector getVariable "OWL_sectorName", _color];

				_pos = _map ctrlMapWorldToScreen (position _sector);

				_tooltip ctrlSetPosition [_pos#0+(safezoneW/40)*0.5, _pos#1, (safezoneW/40)*2.5, (safezoneH/25)*4];
				_tooltip ctrlSetBackgroundColor [0,0,0,0.6];
				_tooltip ctrlCommit 0;
				uiNamespace setVariable ["OWL_UI_asset_map_last_sector", _sector];
			} else {
				_update = _update + _marker;
			};
		} else {
			_update = _update + "Unknown Marker";
			_tooltip = (findDisplay 99) displayCtrl 2999;
			ctrlDelete _tooltip;
			uiNamespace setVariable ["OWL_UI_asset_map_last_sector", objNull];
		};
	} else {
		_update = _update + "Nothing";
		_tooltip = (findDisplay 99) displayCtrl 2999;
		ctrlDelete _tooltip;
		uiNamespace setVariable ["OWL_UI_asset_map_last_sector", objNull];
	};
}];

_asset_map ctrlAddEventHandler ["Draw", {

	private _selected = uiNamespace getVariable ["OWL_UI_asset_map_last_sector", objNull];
	private _clicked  = uiNamespace getVariable ["OWL_UI_asset_map_last_clicked", objNull];
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
	}; //384m lon, 100m wide
}];

_asset_map call OWL_fnc_UI_mapDrawCommon;

// This is to keep focus off of the map.
_display displayAddEventHandler ["MouseButtonUp", {
	_focused = focusedCtrl (_this#0);
	if (ctrlClassName _focused  == "RscMapControl") then {
		ctrlSetFocus (uiNamespace getVariable "OWL_UI_dummy");
	};
}];

"" call OWL_fnc_UI_AssetTab_updateAssetPreview;
_asset_list_category lbSetCurSel 0;