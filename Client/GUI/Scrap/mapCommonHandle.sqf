params ["_ctrlMap"];

// Generalize the 'map' functionality and draw handles across all the UI map components.
// Good idea, hurts my brain rn

_ctrlMap ctrlAddEventHandler ["MouseButtonDown", {
	params ["_map", "_button", "_xPos", "_yPos", "_shift", "_ctrl", "_alt"];
	_overItem = ctrlMapMouseOver (_map);

	if (_button != 0) exitWith {};

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
					//_sector call OWL_fnc_UI_StrategyTab_onLocationSelected;
					uiNamespace setVariable ["OWL_UI_main_map_last_clicked", _sector];
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
		systemChat "Nothing";//objNull call OWL_fnc_UI_StrategyTab_onLocationSelected;
		uiNamespace setVariable ["OWL_UI_main_map_last_clicked", objNull];
	};
}];

// This ugly rework
_ctrlMap ctrlAddEventHandler ["MouseMoving", {
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
				_tooltip ctrlSetPosition [_xpos, _ypos/*_pos#0+(safezoneW/40)*0.5, _pos#1*/, (safezoneW/40)*2.5, (safezoneH/25)*4];
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

_ctrlMap ctrlAddEventHandler ["Draw", {

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