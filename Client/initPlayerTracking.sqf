
// processDiaryLink createDiaryLink ["Map", player, ""]; -> how to open map
// openMap [true, false] 
// openMap [false, false] 

addMissionEventHandler ["Map", {
	params ["_mapIsOpened", "_mapIsForced"];

	_main_map = (findDisplay 12) displayCtrl 51;
	_eh = uiNamespace getVariable ["OWL_UI_playerTrackEH", []];

	if (eh != -1) then {
		_main_map ctrlRemoveEventHandler _eh;			
	};

	if (_mapIsOpened) then {
		_eh = _main_map ctrlAddEventHandler ["Draw", {
			{
				if (_x == player) then {
					continue;
				};
				
				(_this # 0) drawIcon [
					"\a3\ui_f\data\Map\GroupIcons\selector_selectedFriendly_ca.paa",
					[1,1,1,1],
					getPosASLVisual _x,
					16,
					16,
					((time % 30) / 30)*360,
					"",
					1,
					0.03,
					"TahomaB",
					"right"
				];
			} forEach (call BIS_fnc_listPlayers);
		}];
		uiNamespace setVariable ["OWL_UI_playerTrackEH", _eh];
	};
}];

// If we care about ingame nametags
/*addMissionEventHandler ["draw3D",
{
	{
		drawIcon3D
		[
			"\a3\ui_f\data\IGUI\Cfg\Radar\radar_ca.paa",
			[0,0,1,1],
			ASLToAGL (eyePos player vectorAdd [0,0,0.5]),
			2,
			2,
			getDirVisual player,
			"COMPASS",
			0,
			safezoneH*0.05,
			"PuristaMedium",
			"center",
			true
		];
	} forEach [1,2];
}];*/