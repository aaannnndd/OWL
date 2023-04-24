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
	["cfKicks", "Hide vote kick messages"]
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

if (call BIS_fnc_admin == 2) exitWith {
	private _bug_list = _display ctrlCreate ["RscListBox", _tabIdx call OWL_fnc_TabIDC];
	_bug_list ctrlSetPosition [_xrel+15*_wb, _yrel+_hb*4.25, _wb*8, _hb*7];
	_bug_list ctrlSetStructuredText parseText "Assets";
	_bug_list ctrlCommit 0;

	private _bug_text = _display ctrlCreate ["RscEditMulti", _tabIdx call OWL_fnc_TabIDC];
	_bug_text ctrlSetPosition [_xrel+23*_wb, _yrel+_hb*4.25, _wb*8, _hb*7];
	_bug_text ctrlSetText "BugReport description";
	_bug_text ctrlCommit 0;

	private _delete_bug_reports = _display ctrlCreate ["RscButtonMenu", _tabIdx call OWL_fnc_TabIDC];
	_delete_bug_reports ctrlSetText "Clear Bug Reports";
	_delete_bug_reports ctrlSetPosition [_xrel+15*_wb, _yrel+_hb*11.25, _wb*8, _hb*1];
	_delete_bug_reports ctrlCommit 0;

	_delete_bug_reports ctrlAddEventHandler ["ButtonClick", {
		remoteExec ["OWL_fnc_crClearBugReports", 2];
	}];

	uiNamespace setVariable ["OWL_UI_options_bug_report_text", _bug_text];
	uiNamespace setVariable ["OWL_UI_options_bug_report_list", _bug_list];
	remoteExec ["OWL_fnc_crReadBugReport", 2];
};

_display displayRemoveAllEventHandlers "KeyUp";

private _options_button_report_bug = _display ctrlCreate ["RscButtonMenu", _tabIdx call OWL_fnc_TabIDC];
_options_button_report_bug ctrlSetPosition [_xrel+_wb*15, _yrel+_hb*3, _wb*10, _hb*1];
_options_button_report_bug ctrlSetStructuredText parseText "Submit Bug Report/Feedback";
_options_button_report_bug ctrlCommit 0;

private _options_input_report_bug = _display ctrlCreate ["RscEditMulti", _tabIdx call OWL_fnc_TabIDC];
_options_input_report_bug ctrlSetPosition [_xrel+_wb*15, _yrel+_hb*4, _wb*10, _hb*10];
_options_input_report_bug ctrlSetStructuredText parseText "<t align='left' valign='top'>tesT</t>";
_options_input_report_bug ctrlCommit 0;

uiNamespace setVariable ["_options_input_report_bug", _options_input_report_bug];

_options_button_report_bug ctrlAddEventHandler ["ButtonClick", {
	private _bug_text = uiNamespace getVariable "_options_input_report_bug";
	(ctrlText _bug_text) remoteExec ["OWL_fnc_crBugReport", 2];
	_bug_text ctrlSetText "";
	systemChat "Bug report sent! Thank you!";
	(ctrlParent (_this#0)) displayAddEventHandler ["KeyUp", {
		_key = _this # 1;
		if (_key == OWL_key_menu) then {
			(uiNamespace getVariable ["OWL_commandMenu", displayNull]) closeDisplay 1;
			uiNamespace setVariable ["OWL_commandMenu", displayNull];
		};
	}];
}];