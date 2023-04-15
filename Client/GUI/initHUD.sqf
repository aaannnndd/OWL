params ["_display"];

[safezoneX, safezoneY, safezoneW/40, safezoneH/25] params ["_xrel", "_yrel", "_wb", "_hb"];

waitUntil {OWL_playerInitialized};

private _iconTank = "a3\ui_f\data\map\vehicleicons\iconTank_ca.paa";
private _iconUnit = "a3\ui_f\data\GUI\Rsc\RscDisplayGarage\crew_ca.paa";

with uiNamespace do {
	OWL_UI_hudBackground = _display ctrlCreate ["RscText", -1];
	OWL_UI_hudBackground ctrlSetBackgroundColor [0,0,0,0];
	OWL_UI_hudBackground ctrlSetPosition [_xrel+_wb*32, _yrel+_hb*19.5, _wb*7, _hb*5];
	OWL_UI_hudBackground ctrlCommit 0;

	OWL_UI_hudStatus = _display ctrlCreate ["RscStructuredText", -1];
	OWL_UI_hudStatus ctrlSetPosition [_xrel+_wb*32, _yrel+_hb*18.5, _wb*7, _hb*1];
	OWL_UI_hudStatus ctrlSetBackgroundColor [0,0,0,0.5];
	OWL_UI_hudStatus ctrlSetStructuredText parseText "<t size='0.15'>&#160;</t><t size='1' font='PuristaMedium' align='center' color='#FFCCCCCC'>VOTING PHASE</t>";
	OWL_UI_hudStatus ctrlShow false;
	OWL_UI_hudStatus ctrlCommit 0;

	OWL_UI_hudProgress = _display ctrlCreate ["RscProgress", -1];
	OWL_UI_hudProgress ctrlSetPosition [_xrel+_wb*32, _yrel+_hb*19.375, _wb*7, _hb*0.125];
	OWL_UI_hudProgress ctrlSetTextColor [1,1,1,0.8];
	OWL_UI_hudProgress progressSetPosition 0;
	OWL_UI_hudProgress ctrlShow false;
	OWL_UI_hudProgress ctrlCommit 0;

	OWL_UI_hudIncome = _display ctrlCreate ["RscStructuredText", -1];
	OWL_UI_hudIncome ctrlSetPosition [_xrel+_wb*32, _yrel+_hb*19.5, _wb*7, _hb*1.5];
	OWL_UI_hudIncome ctrlSetStructuredText parseText format ["<t size='1' align='left'>%1 CP</t><t size='1' align='right' color='#FFCCCCCC'>+%2/min</t><br/><t size='0.7' color='#EEFFFFFF' align='center'>2 recruit(s) available</t><br/>", uiNamespace getVariable ["OWL_UI_dummyFunds", 0], with missionNamespace do {(side player) call OWL_fnc_incomeCalculation}];
	OWL_UI_hudIncome ctrlCommit 0;

	OWL_UI_hudSeizingBack = _display ctrlCreate ["RscText", -1];
	OWL_UI_hudSeizingBar = _display ctrlCreate ["RscProgress", -1];
	OWL_UI_hudSeizingLabel = _display ctrlCreate ["RscStructuredText", -1];
	OWL_UI_hudSeizingBar ctrlSetPosition [_xrel+_wb*32, _yrel+_hb*21.5, _wb*7, _hb*1];
	OWL_UI_hudSeizingBack ctrlSetPosition [_xrel+_wb*32, _yrel+_hb*21.5, _wb*7, _hb*1];
	OWL_UI_hudSeizingLabel ctrlSetPosition [_xrel+_wb*32, _yrel+_hb*21.5, _wb*7, _hb*1];
	OWL_UI_hudSeizingBar progressSetPosition 0.8;
	OWL_UI_hudSeizingBar ctrlSetTextColor [0.8,0.2,0,0.8];
	OWL_UI_hudSeizingBack ctrlSetBackgroundColor [0.1,0.1,0.8,0.8];
	OWL_UI_hudSeizingLabel ctrlCommit 0;
	OWL_UI_hudSeizingBar ctrlCommit 0;
	OWL_UI_hudSeizingBack ctrlCommit 0;
	OWL_UI_hudSeizingBack ctrlShow false;
	OWL_UI_hudSeizingLabel ctrlShow false;
	OWL_UI_hudSeizingBar ctrlShow false;

	/*OWL_UI_hudSeizingInfo = _display ctrlCreate ["RscStructuredText", -1];
	OWL_UI_hudSeizingInfo ctrlSetPosition [_xrel+_wb*32, _yrel+_hb*22.5, _wb*7, _hb*1];
	//OWL_UI_hudSeizingInfo ctrlSetStructuredText parseText format ["<img image = '%1' size = '1' align = 'left' shadow = '0' color='#FFDD1111'></img><t size='0.8' color='#FFDD1111'>x4</t>", _iconTank];
	private _fmt = format ["<img image = '%1' size = '1' align = 'left' shadow = '0' color='#FFDD1111'></img><t size='0.8' color='#FFDD1111'>x4</t>", _iconTank];
	_fmt = _fmt + format ["<img image = '%1' size = '1' align = 'left' shadow = '0' color='#FFDD1111'></img><t size='0.8' color='#FFDD1111'>x16</t>", _iconUnit];
	_fmt = _fmt + format ["<img image = '%1' size = '1' align = 'right' shadow = '0' color='#FF1111DD'></img><t size='0.8' align='right' color='#FF1111DD'>x4</t>", _iconTank];
	_fmt = _fmt + format ["<img image = '%1' size = '1' align = 'right' shadow = '0' color='#FF1111DD'></img><t size='0.8' align='right' color='#FF1111DD'>x16</t>", _iconUnit];
	OWL_UI_hudSeizingInfo ctrlSetStructuredText parseText _fmt;
	OWL_UI_hudSeizingInfo ctrlCommit 0;*/
};