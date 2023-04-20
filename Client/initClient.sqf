["Client initialization started"] call OWL_fnc_log;
OWL_playerInitialized = false;

OWL_fnc_sectorLocationName = compileFinal preprocessFileLineNumbers "Client\sectorLocationName.sqf";
OWL_fnc_eventAnnouncer = compileFinal preprocessFileLineNumbers "Client\eventAnnouncer.sqf";
OWL_fnc_updateSectorMarker = compileFinal preprocessFileLineNumbers "Client\sectorMarkerUpdate.sqf";
OWL_fnc_toggleMenu = compileFinal preprocessFileLineNumbers "Client\GUI\menuToggle.sqf";
OWL_fnc_handleDeployDefense = compileFinal preprocessFileLineNumbers "Client\handleDeployDefense.sqf";
call compileFinal preprocessFileLineNumbers "Client\serverResponse.sqf";

OWL_key_menu = 22;

waitUntil { missionNamespace getVariable ["OWL_serverInitialized", false] };
waitUntil { !isNull player };
waitUntil { isPlayer player };
waitUntil { local player };

/**************************************************************************
***********		Part 1: Preparing GUI and other local stuff		***********
**************************************************************************/

OWL_playerMates = [];
OWL_playerAssets = [];

remoteExec ["OWL_fnc_ICS", 2];
waitUntil { OWL_playerInitialized };

player addMPEventHandler ["MPRespawn", {
	params ["_unit", "_corpse"];

}];

/* "Disables" command view - find a nicer way, maybe make it a serverparam.
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

// Create sector markers, localize the sector names.
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

call compileFinal preprocessFileLineNumbers "Client\GUI\initGUI.sqf";

// Add event handler for the warlords menu.
0 spawn {
	sleep 1;
	(findDisplay 46) displayAddEventHandler ["KeyUp", {
		_key = _this # 1;
		if (_key == OWL_key_menu) then {
			call OWL_fnc_toggleMenu;
		};
	}];
};

/******************************************************
***********			Finishing up 			***********
******************************************************/

call compileFinal preprocessFileLineNumbers "Client\clientEventHandlers.sqf";
call compileFinal preprocessFileLineNumbers "Client\initPlayerTracking.sqf";

["Client initialization finished"] call OWL_fnc_log;

0 spawn {
	for "_i" from 0 to 5 do {
		sleep 30;
		systemChat "Press U to open menu. Free jets in 'Free Jets' tab";
	};
	systemChat "Work in Progress. Aircraft/Naval not working yet.";
};





