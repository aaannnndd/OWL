_display = (uiNamespace getVariable ["OWL_commandMenu", displayNull]);

if (uiNamespace getVariable ["OWL_UI_blockMenu", FALSE]) exitWith {
	_display closeDisplay 1;
};

if (isNull _display) then {
	_display = (findDisplay 46) createDisplay "RscTabbedMenu";
	uiNamespace setVariable ["OWL_commandMenu", _display];
	_display displayAddEventHandler ["KeyUp", {
		_key = _this # 1;
		if (_key == OWL_key_menu) then {
			(uiNamespace getVariable ["OWL_commandMenu", displayNull]) closeDisplay 1;
			uiNamespace setVariable ["OWL_commandMenu", displayNull];
		};
	}];
} else {
	_display closeDisplay 1;
};