player addEventHandler ["HandleRating", {
	params ["_unit", "_rating"];

	private _pts = _rating / 20;

	if (side _unit == sideEmpty) exitWith {};
	if (side _unit == playerSide) exitWith {};
	if (_pts <= 0) exitWith {};
	
	systemChat format ["%1 points awarded for killing an enemy.", _pts];
}];

player addEventHandler ["Respawn", { 
	group player selectLeader player; 

	if (uiNamespace getVariable ["OWL_UI_data_options_autoNVG", false] && (dayTime < 4 || dayTime > 20)) then {
		player action ["nvGoggles", player];
	};
}];

addMissionEventHandler ["HandleChatMessage", {
	params ["_channel", "_owner", "_from", "_text", "_person", "_name", "_strID", "_forcedDisplay", "_isPlayerMessage", "_sentenceType", "_chatMessageType"];

	_block = false;

	if (_channel == 16) then {
		if ( ["forced respawn",_text] call BIS_fnc_inString ) then {
			_block = true;
		};
		if ( ["incapacitated",_text] call BIS_fnc_inString ) then {
			_block = true;
		};
		if ( ["connected",_text] call BIS_fnc_inString ) then {
			_block = true;
		};
		if ( ["connecting",_text] call BIS_fnc_inString ) then {
			_block = true;
		};
		if ( ["connected",_text] call BIS_fnc_inString ) then {
			_block = true;
		};

		if (uiNamespace getVariable ["OWL_UI_data_options_cfKick", false]) then {
			if ( ["would like to kick",_text] call BIS_fnc_inString) then {
				_block = true;
			};
		};
	};

	if (!isNull _person) then {
		// This doesn't work ;(
		// If arma internally sets VoN volume to 0 when you mute a player ingame, this will easily filter out their chats as well.
		if (uiNamespace getVariable ["OWL_UI_data_options_cfMuted", false]) then {
			if (getPlayerVoNVolume _person == 0) then {
				_block = true;
			};
		};
	};

	_block;
}];