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

OWL_fnc_UI_hudUpdateCP = {
	params ["_amount"];

	with uiNamespace do {
		OWL_UI_hudIncome ctrlSetStructuredText parseText format ["<t size='1' align='left'>%1 CP</t><t size='1' align='right' color='#FFCCCCCC'>+%2/min</t><br/><t size='0.7' color='#EEFFFFFF' align='center'>2 recruit(s) available</t><br/>", uiNamespace getVariable ["OWL_UI_dummyFunds", 0], with missionNamespace do {(side player) call OWL_fnc_incomeCalculation}];
		OWL_UI_hudIncome ctrlCommit 0;

		if (_amount != 0) then {
			private _display = ctrlParent OWL_UI_hudIncome;
			private _tempText = _display ctrlCreate ["RscText", -1];
			private _pos = ctrlPosition OWL_UI_hudBackground;
			_tempText ctrlSetPosition [_pos#0, _pos#1-(_pos#3)*0.25, _pos#2, (_pos#3)*0.5];
			_tempText ctrlSetText format ["%1%2", if (_amount > 0) then {"+"} else {"-"}, _amount];
			_tempText ctrlSetTextColor (if (_amount > 0) then {[0,0.8,0,0.8]} else {[0.8,0,0,0.8]});
			_tempText ctrlCommit 0;

			[_tempText, _amount > 0] spawn {
				params ["_ctrl"];
				private _t = time+1;
				private _i = ((ctrlPosition _ctrl)#3);
				_i = _i / (100);
				while {time < _t} do {
					sleep 0.01;
					_ctrl ctrlSetPosition ((ctrlPosition _ctrl) vectorAdd [0,_i*-1,0, 0]);
					_ctrl ctrlCommit 0;
				};
				ctrlDelete _ctrl;
			};
		};
	};
};

OWL_fnc_UI_hudUpdateCapture = {
	params ["_sector", "_endTime", "_capVelocity", "_capFor", "_progress"];

	private _capSide = [WEST, EAST, RESISTANCE] # _capFor;
	private _sectorSide = _sector getVariable "OWL_sectorSide";
	private _ctrlBackground = uiNamespace getVariable "OWL_UI_hudSeizingBack";
	private _ctrlProgress = uiNamespace getVariable "OWL_UI_hudSeizingBar";
	private _ctrlLabel = uiNamespace getVariable "OWL_UI_hudSeizingLabel";

	_ctrlLabel ctrlSetStructuredText parseText format ["<t size='0.15'>&#160;</t><br/><t size='1' align='center'>%1</t>", _sector getVariable "OWL_sectorName"];

	private _handle = uiNamespace getVariable ["OWL_UI_seizingHandle", scriptNull];
	if (!isNull _handle) then {
		terminate _handle;
	};

	if (_capVelocity < 0 && _progress == 0) exitWith {
		_ctrlBackground ctrlShow false;
		_ctrlProgress ctrlShow false;
		_ctrlLabel ctrlShow false;		
	};

	_handle = [_progress, _endTime, _capVelocity, _sector] spawn {
		params ["_progress", "_endTime", "_capVelocity", "_sector"];
		private _ctrlProgress = uiNamespace getVariable "OWL_UI_hudSeizingBar";
		private _ctrlLabel = uiNamespace getVariable "OWL_UI_hudSeizingLabel";
		private _ctrlBackground = uiNamespace getVariable "OWL_UI_hudSeizingBack";
		private _area = _sector getVariable "OWL_sectorAreaOld";
		_progress = _progress / 120;
		private _frac = 1 - _progress;
		if (_capVelocity < 0) then {
			_frac = -1*_progress;
		};
		_startTime = serverTime;
		//systemChat str [serverTime, _endTime];
		while {serverTime < _endTime} do {
			sleep 0.01;
			_pctProgress = (serverTime-_startTime) / (_endTime-_startTime);
			_pctProgress = _pctProgress * _frac;
			_ctrlProgress progressSetPosition (_progress + _pctProgress);
			_ctrlProgress ctrlCommit 0;

			_ctrlBackground ctrlShow (player inArea _area);
			_ctrlProgress ctrlShow (player inArea _area);
			_ctrlLabel ctrlShow (player inArea _area);
		};
		if ((progressPosition _ctrlProgress) < 0.01) then {
			_ctrlBackground ctrlShow false;
			_ctrlProgress ctrlShow false;
			_ctrlLabel ctrlShow false;
		};
	};

	uiNamespace setVariable ["OWL_UI_seizingHandle", _handle];

	_ctrlBackground ctrlShow true;
	_ctrlProgress ctrlShow true;
	_ctrlLabel ctrlShow true;

	_ctrlBackground ctrlSetBackgroundColor (OWL_sideColor get _sectorSide);
	if (_capSide != _sectorSide) then {
		_ctrlProgress ctrlSetTextColor (OWL_sideColor get _capSide);
	};
	_ctrlProgress ctrlCommit 0;
	_ctrlBackground ctrlCommit 0;
};

OWL_fnc_UI_hudUpdateRecruits = {
	params ["_amount"];
};

OWL_fnc_UI_hudUpdateVoting = {
	params ["_endTime"];

	if (!OWL_playerInitialized) exitWith {};

	private _voteList = OWL_sectorVoteList # (OWL_competingSides find playerSide);
	private _mostVoted = -1;
	private _count = 0;
	{
		if (_x#1 > _count) then {
			_mostVoted = (_x#0);
			_count = (_x#1);
		};
	} forEach _voteList;

	if (_mostVoted != -1) then {
		_mostVoted = format ["Next: %1", (OWL_allSectors # _mostVoted) getVariable "OWL_sectorName"];
	} else {
		_mostVoted = "VOTING PHASE";
	};

	with uiNamespace do {
		private _state = (missionNamespace getVariable "OWL_gameState") # (missionNamespace getVariable "OWL_sideIndex");
		private _show = if (_state == "voting") then {true} else {false};
		OWL_UI_hudStatus ctrlSetBackgroundColor [0,0,0,0.5];
		OWL_UI_hudStatus ctrlSetStructuredText parseText format["<t size='0.15'>&#160;</t><t size='1' font='PuristaMedium' align='center' color='#FFCCCCCC'>%1</t>", toUpper _mostVoted];
		OWL_UI_hudStatus ctrlShow _show;
		OWL_UI_hudStatus ctrlCommit 0;
	};
};