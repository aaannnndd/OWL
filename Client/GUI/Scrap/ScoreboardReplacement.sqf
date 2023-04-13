(findDisplay 46) displayAddEventHandler ["KeyDown", {
	_key = _this # 1;
	if (_key == 25) then {
		[] spawn {
			sleep 0.01;
			{
				if (ctrlIDD _x == 175) then {
					_x closeDisplay 2;
				};
			} forEach (uiNamespace getVariable "GUI_displays");
		};
	};
}];

(findDisplay 46) displayAddEventHandler ["KeyUp", {

	if (_this # 1 == 25) then {
		_display = (findDisplay 46) createDisplay "RscScoreboardMenu";
		uiNamespace setVariable ["OWL_scoreboard", _display];

		_display displayAddEventHandler ["KeyUp", {
			_key = _this # 1;
			if (_key == 25) then {
				(uiNamespace getVariable ["OWL_scoreboard", displayNull]) closeDisplay 1;
				uiNamespace setVariable ["OWL_scoreboard", displayNull];
			};
		}];

		_display displayAddEventHandler ["KeyDown", {
			if (_this # 1 == 25) then {
				[] spawn {
					sleep 0.01;
					{
						if (ctrlIDD _x == 175) then {
							_x closeDisplay 2;
						};
					} forEach (uiNamespace getVariable "GUI_displays");
				};
			};
		}];
	};
}];