/*
	This file contains all the functions which are sent from the server to the client in response to a request they have sent.
	
	Could be as little as a UI update, or notification/play sound
*/


/* Any client info that needs to be sent over when the player is first initialized. */
OWL_fnc_srInitClient = {
	params ["_commandPoints", "_ownedAssets"];

	if (remoteExecutedOwner != 2) exitWith {};
	
	OWL_playerMates = []; // should be empty from the start.
	OWL_playerAssets = _ownedAssets;

	// Client specific info
	uiNamespace setVariable ["OWL_UI_dummyFunds", _commandPoints];
	OWL_ownedAssets = _ownedAssets;
	OWL_sideIndex = OWL_competingSides find playerSide;
	OWL_playerInitialized = true;
	localize "$STR_A3_OWL_warlords_init" spawn BIS_fnc_WLSmoothText;
	"BIS_WL_Initialized_WEST" call OWL_fnc_eventAnnouncer;

	if (OWL_gameState # OWL_sideIndex == "voting") then {
		"BIS_WL_Voting_WEST" call OWL_fnc_eventAnnouncer;
		localize "$STR_A3_OWL_sector_vote" spawn BIS_fnc_WLSmoothText;
		0 spawn {
			sleep 0.25;
			-1 call OWL_fnc_UI_hudUpdateVoting;
		};
	};
};

OWL_fnc_srSectorSeized = {
	params ["_sector", "_oldSide", "_newSide"];

	if (remoteExecutedOwner != 2) exitWith {};

	_sector call OWL_fnc_updateSectorMarker;
	// Do UI updates.

	if (_oldSide == playerSide) then {
		"BIS_WL_Lost_WEST" call OWL_fnc_eventAnnouncer;
		localize "$STR_A3_OWL_sector_lost" spawn BIS_fnc_WLSmoothText;
	} else {
		if (_newSide != playerSide) then {
			"THE ENEMY IS ADVANCING" spawn BIS_fnc_WLSmoothText;
			localize "$STR_A3_OWL_enemy_advancing" call OWL_fnc_eventAnnouncer;		
		} else {
			localize "$STR_A3_OWL_sector_seized" spawn BIS_fnc_WLSmoothText;
			"BIS_WL_Seized_WEST" call OWL_fnc_eventAnnouncer;
		};
	};

	0 call OWL_fnc_UI_hudUpdateCP; 

	with uiNamespace do {
		OWL_UI_hudSeizingBack ctrlShow false;
		OWL_UI_hudSeizingBar ctrlShow false;
		OWL_UI_hudSeizingLabel ctrlShow false;
	};
};

OWL_fnc_srCaptureUpdate = {
	params ["_sector", "_progress", "_endTime", "_capFor", "_capVelocity"];

	if (!OWL_playerInitialized) exitWith {};
	if (remoteExecutedOwner != 2) exitWith {};

	systemChat format ["Capture Progress Update: %1. Remaining: %2 (%5/120), CappingFor: %3, CapVelocity: %4", _sector getVariable "OWL_sectorName", _endTime-serverTime, _capFor, _capVelocity, _progress];

	//private _capSide = [WEST, EAST, RESISTANCE] # _capFor;
	//private _sectorSide = _sector getVariable "OWL_sectorSide";

	// update sector 'capfor' color and endTime.
	[_sector, _endTime, _capVelocity, _capFor, _progress] call OWL_fnc_UI_hudUpdateCapture;
};

/* Sound plays to know the airdrop was a success. All vehicles spawned serverside. */
/* Update OWL_ownedAssets for the client via whatever sent over through RE */
OWL_fnc_srAirdrop = {
	params ["_assets", "_infantry"];

	if (remoteExecutedOwner != 2) exitWith {
		[format ["Client recieved response remoteExec from non-server client: %1", remoteExecutedOwner]] call OWL_fnc_log;
	};

	systemChat format ["Assets successfully dropped: %1. Infantry Dropped: %2.", str _assets, str _infantry];

	OWL_playerAssets append _assets;
	//OWL_playerMates append _infantry; all will be put in player squad, don't really need this.
	{
		_x call OWL_fnc_newAssetAddedToPlayer;
	} forEach (_assets + _infantry);

	"BIS_WL_Airdrop_WEST" call OWL_fnc_eventAnnouncer;
	localize "$STR_A3_OWL_airdrop_incoming" spawn BIS_fnc_WLSmoothText; 
};

/* Client recives an update for how much money they have available on the server. */
OWL_fnc_srCPUpdate = {
	params ["_amount"];

	if (!OWL_playerInitialized) exitWith {};
	if (remoteExecutedOwner != 2) exitWith {};

	private _diff = uiNamespace getVariable ["OWL_UI_dummyFunds", 0];
	_diff = _amount - _diff;
	uiNamespace setVariable ["OWL_UI_dummyFunds", _amount];
	_diff call OWL_fnc_UI_hudUpdateCP;

	// Update the actual UI.

	_diff call OWL_fnc_UI_AssetTab_onCPChanged;

	// TODO
	with uiNamespace do {
		if (!isNil {OWL_UI_strategy_menu_footer}) then {
			OWL_UI_strategy_menu_footer ctrlSetStructuredText parseText format ["<t size='0.25'>&#160;</t><br/><t size='1.25' align='center' valign='bottom'>%1 CP, Harbor, 6 Recruits Available</t>", missionNamespace getVariable "OWL_UI_menuDummyFunds"];
			OWL_UI_strategy_menu_footer ctrlCommit 0;
		};
	};
};

/* Client receives notification to do FT effect as they will be teleported. */
OWL_fnc_srFastTravel = {
	params ["_sector", "_pos"];

	if (!OWL_playerInitialized) exitWith {};

	if (remoteExecutedOwner != 2) exitWith {
		[format ["Not processing. Server Reponse recieved from client %1", remoteExecutedOwner]] call OWL_fnc_log;
	};
	
	titleCut ["", "BLACK OUT", 0.5];
	"BIS_WL_Fast_Travel_WEST" call OWL_fnc_eventAnnouncer;
	format [localize "$STR_A3_OWL_fast_travel", toUpper (_sector getVariable "OWL_sectorName")] spawn BIS_fnc_WLSmoothText;

	_pos spawn {
		uiNamespace setVariable ["OWL_UI_blockMenu", TRUE];
		sleep 0.5;
		titleCut ["", "BLACK IN", 0.5];

		private _cam = "camera" camCreate (ASLToAGL eyePos player);
		_cam cameraEffect ["internal", "back"]; 
		_cam setVectorDirAndUp [vectorDir player, vectorUp player];
		showCinemaBorder false; 
		setDefaultCamera [_this, vectorDir player]; 
		_start = (getPos player) vectorAdd [0,0,150];
		_diffl = (_this vectorDiff (getPos player)); 
		_arcPoint = _start vectorAdd (_diffl vectorMultiply (1-( 100/(vectorMagnitude _diffl))));
		_cam camPrepareTarget _this;
		_cam camPreparePos ((getPosATL player) vectorAdd [0,0,75]);
		_cam camPrepareFov 1;
		_cam camCommitPrepared 1;
		camUseNVG (currentVisionMode player == 1);
		sleep 1;
		_cam camPreparePos _start;
		_cam camCommitPrepared 1;
		sleep 1;
		_cam camPreparePos (_arcPoint vectorAdd [0,2,150]);
		_cam camCommitPrepared 2;
		sleep 2;
		_cam camPreparePos _this;
		_cam camCommitPrepared 2; 
		sleep 2; 
		_cam cameraEffect ["terminate", "back"]; 
		camDestroy _cam;
		titleCut ["", "BLACK IN", 0.5];
		uiNamespace setVariable ["OWL_UI_blockMenu", FALSE];
	};
};

/* Client recieves notification to do the sector scans */
OWL_fnc_srSectorScan = {
	params ["_sector", "_endTime"];

	if (remoteExecutedOwner != 2) exitWith {};

	"BIS_WL_Scan_WEST" call OWL_fnc_eventAnnouncer;
	format [localize "$STR_A3_OWL_sector_scan", toUpper (_sector getVariable "OWL_sectorName")] spawn BIS_fnc_WLSmoothText;
	sleep 2;
	_this spawn {
		params ["_sector", "_endTime"];
		playSound "Beep_Target";
		private _mapDisplay = findDisplay 12;
		private _map = _mapDisplay displayCtrl 51;

		uiNamespace setVariable ["OWL_UI_scanned_sector_area", _sector getVariable "OWL_sectorAreaOld"];
		_eh = _map ctrlAddEventHandler ["Draw", {
			{
				if (side _x == side player) then {
					continue;
				};
				private _isMan = _x isKindOf "Man";
				_this select 0 drawIcon [
                    if (_isMan) then {"A3\ui_f\data\map\markers\military\dot_CA.paa"} else {"A3\ui_f\data\map\markers\military\box_CA.paa"},
                    [1, 0, 0, 0.5],
                    getPosVisual _x,
                    20,
                    20,
                    0,
                    format [" %1", if (_isMan) then {""} else {_x getVariable ["OWL_displayName", ""]}],
                    2,
                    0.05,
                    "RobotoCondensed",
                    "right"
                ];
			} forEach (allUnits inAreaArray (uiNamespace getVariable "OWL_UI_scanned_sector_area"));
		}];

		private _minimap = controlNull;
		{
			if (ctrlIDD _x == 311) then {
				{
					if (ctrlIDC _x == 101) then {
						_minimap = _x;
					};
				} forEach allControls _x;
			};
		} forEach (uiNamespace getVariable "IGUI_Displays");

		_eh2 = _minimap ctrlAddEventHandler ["Draw", {
			{
				if (side _x == side player) then {
					continue;
				};
				private _isMan = _x isKindOf "Man";
				_this select 0 drawIcon [
                    if (_isMan) then {"A3\ui_f\data\map\markers\military\dot_CA.paa"} else {"A3\ui_f\data\map\markers\military\box_CA.paa"},
                    [1, 0, 0, 0.5],
                    getPosVisual _x,
                    20,
                    20,
                    0,
                    format [" %1", if (_isMan) then {""} else {_x getVariable ["OWL_displayName", ""]}],
                    2,
                    0.05,
                    "RobotoCondensed",
                    "right"
                ];
			} forEach (allUnits inAreaArray (uiNamespace getVariable "OWL_UI_scanned_sector_area"));
		}];

		_strategyMap = uiNamespace getVariable ["OWL_UI_strategy_map", controlNull];

		_eh3 = _strategyMap ctrlAddEventHandler ["Draw", {
			{
				if (side _x == side player) then {
					continue;
				};
				private _isMan = _x isKindOf "Man";
				_this select 0 drawIcon [
                    if (_isMan) then {"A3\ui_f\data\map\markers\military\dot_CA.paa"} else {"A3\ui_f\data\map\markers\military\box_CA.paa"},
                    [1, 0, 0, 0.5],
                    getPosVisual _x,
                    20,
                    20,
                    0,
                    format [" %1", if (_isMan) then {""} else {_x getVariable ["OWL_displayName", ""]}],
                    2,
                    0.05,
                    "RobotoCondensed",
                    "right"
                ];
			} forEach (allUnits inAreaArray (uiNamespace getVariable "OWL_UI_scanned_sector_area"));
		}];

		sleep (_endTime - serverTime);
		_minimap ctrlRemoveEventHandler ["Draw", _eh2];
		_map ctrlRemoveEventHandler ["Draw", _eh];
		_strategyMap ctrlRemoveEventHandler ["Draw", _eh3];
		format [localize "$STR_A3_OWL_sector_scan_terminated", toUpper (_sector getVariable "OWL_sectorName")] spawn BIS_fnc_WLSmoothText;
		"BIS_WL_Scan_Terminated_WEST" call OWL_fnc_eventAnnouncer;
	};
};

/* Client sent position of their dummy object, server has verified and placed it for them */
OWL_fnc_srDeployDefense = {
	params ["_defense"];

	if (remoteExecutedOwner != 2) exitWith {
		[format ["Client recieved response remoteExec from non-server client: %1", remoteExecutedOwner]] call OWL_fnc_log;
	};

	OWL_playerAssets pushBack _defense;
	_defense call OWL_fnc_newAssetAddedToPlayer;
};

/* Client sent position of their dummy object, server has verified and placed it for them */
OWL_fnc_srDeployNaval = {
	params ["_boat"];
	if (remoteExecutedOwner != 2) exitWith {
		[format ["Client recieved response remoteExec from non-server client: %1", remoteExecutedOwner]] call OWL_fnc_log;
	};

	OWL_playerAssets pushBack _boat;
	_boat call OWL_fnc_newAssetAddedToPlayer;

	"BIS_WL_Airdrop_WEST" call OWL_fnc_eventAnnouncer;
	localize "$STR_A3_OWL_airdrop_incoming" spawn BIS_fnc_WLSmoothText;	
};

/* Aircraft will be landing at the specifed position. */
OWL_fnc_srAircraftSpawn = {
	params ["_aircraft"];

	if (remoteExecutedOwner != 2) exitWith {
		[format ["Client recieved response remoteExec from non-server client: %1", remoteExecutedOwner]] call OWL_fnc_log;
	};

	if (isNull _aircraft) exitWith {};

	OWL_playerAssets pushBack _aircraft;
	_aircraft call OWL_fnc_newAssetAddedToPlayer;
};

/* Client requested one of their assets be deleted. */
OWL_fnc_srRemoveAsset = {
	if (remoteExecutedOwner != 2) exitWith {
		[format ["Client recieved response remoteExec from non-server client: %1", remoteExecutedOwner]] call OWL_fnc_log;
	};
};

/* Client requests purchase of re-enforcements to bolster a sector */
OWL_fnc_crPurchaseReenforcements = {
	if (remoteExecutedOwner != 2) exitWith {
		[format ["Client recieved response remoteExec from non-server client: %1", remoteExecutedOwner]] call OWL_fnc_log;
	};
};

// Tells player voting is now available
OWL_fnc_srSectorVoteNotify = {
	if (!OWL_playerInitialized) exitWith {};
	
	"BIS_WL_Voting_WEST" call OWL_fnc_eventAnnouncer;
	localize "$STR_A3_OWL_sector_vote" spawn BIS_fnc_WLSmoothText;
	-1 call OWL_fnc_UI_hudUpdateVoting;
};

// Tells client to update their vote count for each sector
OWL_fnc_srSectorVoteUpdate = {
	if (!OWL_playerInitialized) exitWith {};

	-1 call OWL_fnc_UI_hudUpdateVoting;	
};

// Tells client to start their timer for the vote period
OWL_fnc_srSectorVoteInit = {
	params ["_endTime"];

	if (!OWL_playerInitialized) exitWith {};
	if (remoteExecutedOwner != 2) exitWith {};

	_endTime call OWL_fnc_UI_hudUpdateVoting;
};


// Tells client they will be killed at '_endTime' if they don't leave the sector.
// -1 = you're good now, get rid of the warning
OWL_srZoneRestrictTimer = {
	params ["_endTime"];

	if (!OWL_playerInitialized) exitWith {};
	if (remoteExecutedOwner != 2) exitWith {};

	private _handle = missionNamespace getVariable ["OWL_zrHandle", scriptNull];

	if (_endTime == -1) exitWith {
		// terminate handle if exists.
		if (!isNull _handle) then {
			terminate _handle;

			private _background = uiNamespace getVariable ["OWL_UI_hudSeizingBack", controlNull];
			private _progress = uiNamespace getVariable ["OWL_UI_hudSeizingBar", controlNull];
			private _label = uiNamespace getVariable ["OWL_UI_hudSeizingLabel", controlNull];

			_background ctrlShow false;
			_progress ctrlShow false;
			_label ctrlShow false;
		};
	};

	_handle = _endTime spawn {
		params ["_timestamp"];

		private _background = uiNamespace getVariable ["OWL_UI_hudSeizingBack", controlNull];
		private _progress = uiNamespace getVariable ["OWL_UI_hudSeizingBar", controlNull];
		private _label = uiNamespace getVariable ["OWL_UI_hudSeizingLabel", controlNull];

		_background ctrlShow true;
		_progress ctrlShow true;
		_label ctrlShow true;

		_background ctrlSetBackgroundColor [0.2,0.2,0.2,0.8];
		_label ctrlSetStructuredText parseText format ["<t size='0.15'>&#160;</t><br/><t size='1' align='center'>RESTRICTED AREA</t>"];
		_progress ctrlSetTextColor [0.8, 0.2, 0, 0.8];

		localize "$STR_A3_OWL_zone_restriction" spawn BIS_fnc_WLSmoothText;
		if (!(uiNamespace getVariable ["OWL_UI_data_options_zrAudio", false])) then {
			playSound "air_raid";
		};

		while {_timestamp > serverTime} do {
			_progress progressSetPosition (1 - (_timestamp-serverTime) / 30);
		};

		_background ctrlShow false;
		_progress ctrlShow false;
		_label ctrlShow false;
	};
	missionNamespace setVariable ["OWL_zrHandle", _handle];
};

OWL_fnc_srSectorSelected = {
	params ["_side", "_sector"];

	if (!OWL_playerInitialized) exitWith {};
	if (remoteExecutedOwner != 2) exitWith {};

	if (_side == playerSide) then {
		"BIS_WL_Selected_WEST" call OWL_fnc_eventAnnouncer;
		format [localize "$STR_A3_OWL_sector_selected", toUpper (_sector getVariable "OWL_sectorName")] spawn BIS_fnc_WLSmoothText;
	} else {
		if (playerSide == _sector getVariable "OWL_sectorSide") then {
			"BIS_WL_Incoming_WEST" call OWL_fnc_eventAnnouncer;
			localize "$STR_A3_OWL_enemy_incoming" spawn BIS_fnc_WLSmoothText;
		};
	};

	-1 call OWL_fnc_UI_hudUpdateVoting;

	private _button_vote = uiNamespace getVariable ["OWL_UI_strategy_button_vote", controlNull];
	_button_vote ctrlEnable false;

	/* Update stuff */

	_sector call OWL_fnc_updateSectorMarker;
	_sector call OWL_fnc_UI_onMainMapLocationClicked;
};

OWL_fnc_srOnAssetDeleted = {
	// Update your asset list (check for objNull and remove)
	private _index = objNull find OWL_playerAssets;
	while {_index != -1} do {
		OWL_playerAssets deleteAt _index;
		_index = objNull find OWL_playerAssets;
	};
};