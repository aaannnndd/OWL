params ["_display", "_tabIdx"];


if (!isNull (_display displayCtrl _tabIdx * 1000)) exitWith {};

_pos = ctrlPosition (_display displayCtrl 98);
_pos params ["_xrel", "_yrel", "_wrel", "_hrel"];
_wb = _wrel / 40;
_hb = _hrel / 25;

private _boolOptions = [
//	["optionName", "Description"]
	["autoNVG", "Auto-enable NVG on respawn at night time."],
	["ambientLife", "Disable Ambient Life (Seagulls, Rabbits, ect)"],
	["zrAudio", "Disable zone-restrictions air raid siren"],
	["cfMuted", "Hide chat messages of muted players"],
	["cfKicks", "Hide vote kick messages"],
	//["hideLocation", "Hide your location from team"],
	//["forceGetIn", "Force AI into vehicle when in range"]
];

{
	private _cb = _display ctrlCreate ["RscCheckBox", _tabIdx call OWL_fnc_TabIDC];
	_cb ctrlSetPosition [_xrel+_wb*0.5, _yrel+_hb*(3+_forEachIndex)+(_hb*0.25*_forEachIndex), _hb*1.5, _hb*1.5];
	private _checked = uiNamespace getVariable [format ["OWL_UI_data_options_%1", (_x#0)], false];
	_cb cbSetChecked _checked;
	_cb setVariable ["OWL_UI_dataRef", (_x#0)];
	_cb ctrlCommit 0;

	_cb ctrlAddEventHandler ["CheckedChanged", {
		params ["_control", "_checked"];
		uiNamespace setVariable [format ["OWL_UI_data_options_%1", _control getVariable "OWL_UI_dataRef"], _checked == 1];

		switch (_control getVariable "OWL_UI_dataRef") do {
			case "ambientLife":
			{
				enableEnvironment [(_checked == 0), true];
			};
		};
	}];

	private _desc = _display ctrlCreate ["RscStructuredText", _tabIdx call OWL_fnc_TabIDC];
	_desc ctrlSetPosition [_xrel+_wb*0.5+_wb*1.5, _yrel+_hb*(3+_forEachIndex)+(_hb*0.25*_forEachIndex), _wb*10, _hb*1.5];
	_desc ctrlSetStructuredText parseText format ["<t size='0.3'>&#160;</t><br/><t size='0.8' align='left'>%1</t>", _x#1];
	_desc ctrlCommit 0;
} forEach _boolOptions;