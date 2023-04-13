["Client initialization started"] call OWL_fnc_log;
OWL_playerInitialized = false;

OWL_fnc_sectorLocationName = compileFinal preprocessFileLineNumbers "Client\sectorLocationName.sqf";
OWL_fnc_eventAnnouncer = compileFinal preprocessFileLineNumbers "Client\eventAnnouncer.sqf";
OWL_fnc_updateSectorMarker = compileFinal preprocessFileLineNumbers "Client\sectorMarkerUpdate.sqf";
call compileFinal preprocessFileLineNumbers "Client\serverResponse.sqf";

waitUntil { missionNamespace getVariable ["OWL_serverInitialized", false] };
waitUntil { !isNull player };
waitUntil { isPlayer player };
waitUntil { local player };

/**************************************************************************
***********		Part 1: Preparing GUI and other local stuff		***********
**************************************************************************/

player addMPEventHandler ["MPRespawn", {
	params ["_unit", "_corpse"];

	// Open the fast travel menu.
	//uiNamespace setVariable ["OWL_UI_lastTab", 1];
	//execVM "Client\GUI\UI_COMMAND_MENU.sqf";
}];

/* "Disables" command view
[] spawn {
	while {TRUE} do {
		sleep 0.1;
		if (cameraView == "GROUP") then {
			player switchCamera "EXTERNAL";
		};
	};
};*/

/******************************************************
***********			Display Init			***********
******************************************************/

waitUntil { !isNull (findDisplay 46) };
waitUntil { playerSide == side group player };

{
	private _sectorIndex = _forEachIndex;
	private _sectorName = _x getVariable ["OWL_sectorParam_name", ""];
	private _sectorSide = _x getVariable "OWL_sectorSide";

	if (_x in OWL_mainBases) then {
		_sectorName = format ["@STR_A3_OWL_sector_name_%1_base", toLower (str _sectorSide)]
	};

	// OWL_sectorName will be localization string on server, and actual name on client (for UI purposes).
	_x setVariable ["OWL_sectorName", (localize _sectorName)];
	
	_x call OWL_fnc_updateSectorMarker;
	
} forEach OWL_allSectors;

[] spawn {
	waitUntil {!isNull findDisplay 46};
	sleep 2;
	(findDisplay 46) displayAddEventHandler ["KeyUp", {
		_key = _this # 1;
		if (_key == 22) then {
			execVM "Client\GUI\UI_COMMAND_MENU.sqf";
		};
	}];
};

[] execVM "Client\GUI\initGUI.sqf";

("OWL_hudLayer" call BIS_fnc_rscLayer) cutRsc ["OWL_RscMainHUD", "PLAIN"];

/******************************************************
***********			Finishing up 			***********
******************************************************/

remoteExec ["OWL_fnc_ICS", 2];
waitUntil { OWL_playerInitialized };

[] spawn {
	for "_i" from 0 to 10 do {
		sleep 10;
		systemChat "Press 'U' to open the menu";
	};
};

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

["Client initialization finished"] call OWL_fnc_log;

/******************************************************
***********		Check the game state		***********
******************************************************/





