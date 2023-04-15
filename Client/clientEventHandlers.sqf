player addEventHandler ["HandleRating", {
	params ["_unit", "_rating"];

	private _pts = _rating / 20;
	
	systemChat format ["%1 points awarded for killing an enemy.", _pts];
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
	};
	_block;
}];