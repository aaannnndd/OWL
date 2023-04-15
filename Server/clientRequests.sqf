/*
	This file contains all functions the client will ask the server to execute 
	when requesting a certain asset/functionality.
*/


/******************************************************
***********			Initialization			***********
******************************************************/

OWL_fnc_ICS = {
	private _owner = remoteExecutedOwner;
	private _player = _owner call OWL_fnc_getPlayerFromOwnerId;

	if (isNull _player) exitWith {[format ["Tried to initialize null player for client %1", _owner]] call OWL_fnc_log};

	private _uid = getPlayerUID _player;
	// OWL_allWarlords [ownerId, [CommandPoints, OwnedAssets]]
	private _persistentData = OWL_persistentData getOrDefault [_uid,[0, []]];
	OWL_allWarlords set [_owner, _persistentData];

	_persistentData remoteExec ["OWL_fnc_srInitClient", _owner];
};

OWL_persistentData = createHashMap;

addMissionEventHandler ["PlayerDisconnected", {
	params ["_id", "_uid", "_name", "_jip", "_owner", "_idstr"];

	private _info = OWL_allWarlords getOrDefault [_owner, []];
	if (count _info > 0) then {
		OWL_persistentData set [_uid, _info];
	};

	OWL_allWarlords deleteAt _owner;
}];

/******************************************************
***********			Asset Business			***********
******************************************************/

// Request to aidrop a list of assets at an objects location.
OWL_fnc_crAirdrop = {
	params ["_target", "_assets", "_flags"];
	
	_para = createVehicle [if (_isMan) then {"Steerable_Parachute_F"} else {"B_Parachute_02_F"}, _finalPos, [], 0, "FLY"];
	_para setPos [_finalPos # 0, _finalPos # 1, if (_isMan) then {50 + random 50} else {150 + random 100}];
	_para setVariable ["finalPos", _finalPos]; 
	
	_item = group (_this # 0) createUnit [_x, position (_this # 0), [], 0, "NONE"];

	{
		_vehicle = createVehicle [_x, position _player, [], 0, "NONE"];
		//
	} forEach _vehicles;


	/* Server plays this sound */
	playSound3D ["A3\Data_F_Warlords\sfx\flyby.wss", objNull, FALSE, (position _player) vectorAdd [0, 0, 100]];
};

// Client requests to use a loadout
OWL_fnc_crLoadout = {
	params ["_player", "_loadout"];

};

// Client requests to fast travel. 
OWL_fnc_crFastTravel = {
	params ["_player", "_sector"];

	if (!(_this call OWL_fnc_conditionFastTravel)) exitWith {
		format ["Fast Travel Request from %1 (%2) does not meet conditions.", name _player] call OWL_fnc_log;
	};

	// Send back remoteExec to to a 'fade' effect, then add a delay here to line up the actual teleport.

	private _index = OWL_allSectors find _sector;
	private _spawnPos = OWL_sectorSpawnPoints # _index;
	private _pos = selectRandom _spawnPos;

	// TODO: deal with fast travel tickets.

	if ([_sector, side _player] call OWL_fnc_sectorContestedFor) then {
		_vdir = (position _sector) vectorFromTo (position _player);
		_pos = (position _sector) vectorAdd (_vdir vectorMultiply (((_sector getvariable "OWL_sectorArea")#0)*2));
		_pos set [2, 0];

		_orth = [_vdir#1, (_vdir#0)*-1, 0];
		_pos = _pos findEmptyPosition [0, 50];
	};

	[_sector, _pos] remoteExec ["OWL_fnc_srFastTravel", remoteExecutedOwner];
	[_player, _pos] spawn {
		sleep 4.5;
		(_this#0) setPosATL (_this#1);
	};
};

// Client requests sector scan for the team.
OWL_fnc_crSectorScan = {
	params ["_sector"];

	private _player = remoteExecutedOwner call OWL_fnc_getPlayerFromOwnerId;

	if(isNull _player) exitWith {
		[format ["Sector Scan Request from invalid client. Player not Initalized."]] call OWL_fnc_log;
	};

	if (!([_sector, side _player] call OWL_fnc_conditionSectorScan)) exitWith {
		[format ["Sector Scan Request from %1 does not meet conditions.", name _player]] call OWL_fnc_log;
	};

	private _arr = _sector getVariable "OWL_sectorScanCooldown";
	_arr set [(OWL_playableSides find( side _player)), serverTime+300];
	_sector setVariable ["OWL_sectorScanCooldown", _arr, TRUE];

	[_sector, serverTime+30] remoteExec ["OWL_fnc_srSectorScan", side _player];
};

// Requests to turn their dummy 'simpleObject' into a real object @ position.
OWL_fnc_crDeployDefense = {
	params ["_player", "_sector", "_asset"];

	if (!(_this call OWL_fnc_conditionDeployDefense)) exitWith {
		[format ["Defense Deployment Request from %1 (%2) does not meet conditions.", name _player]] call OWL_fnc_log;
	};	
};

// Requests to magically appear a boat in the water
OWL_fnc_crDeployNaval = {
	params ["_player", "_sector", "_asset"];

	if (!(_this call OWL_fnc_conditionDeployNaval)) exitWith {
		[format ["Naval/Boat Request from %1 (%2) does not meet conditions.", name _player]] call OWL_fnc_log;
	};	
};

// Requests to have class '_asset' deployed at '_sector'
OWL_fnc_crAircraftSpawn = {
	params ["_player", "_sector", "_asset"];

	if (!(_this call OWL_fnc_conditionAircraftSpawn)) exitWith {
		[format ["Aircraft Request from %1 (%2) does not meet conditions.", name _player]] call OWL_fnc_log;
	};	
};

// Request to have class '_asset' deployed with them flying in it
OWL_fnc_crAircraftSpawnFlying = {
	params ["_player", "_asset"];

	if (!(_this call OWL_fnc_conditionAircraftSpawnFlying)) exitWith {
		[format ["Aircraft Request from %1 (%2) does not meet conditions.", name _player]] call OWL_fnc_log;
	};	
};

// Requests to have an asset removed from the game.
OWL_fnc_crRemoveAsset = {
	params ["_player", "_asset"];

	if (!(_this call OWL_fnc_conditionRemoveAsset)) exitWith {
		[format ["Asset Deletion Request from %1 (%2) does not meet conditions.", name _player]] call OWL_fnc_log;
	};	
};

// Requests to purchase reenforcements for a sector
OWL_fnc_crPurchaseReenforcements = {
	params ["_player", "_sector", "_asset"];

	if (!(_this call OWL_fnc_conditionPurchaseReenforcements)) exitWith {
		[format ["Re-enforcement Purchase Request from %1 (%2) does not meet conditions.", name _player]] call OWL_fnc_log;
	};	
};

/* Re-do this at some point. Tacked a hacky fix onto old code at the end to make it work quickly */
// When a client sends in a vote for a new sector.
OWL_fnc_crSectorVote = {
	params ["_sector"];

	systemChat (_sector getVariable "OWL_sectorName");

	private _client = remoteExecutedOwner;
	private _player = _client call OWL_fnc_getPlayerFromOwnerId;
	if (isNull _player) exitWith {
		["OWL_fnc_CL_sectorVote: remoteExecutedOwner not found in player list."] call OWL_fnc_log;
	};

	if (!([_sector, side _player] call OWL_fnc_conditionSectorVote)) exitWith {};

	private _sideIndex = OWL_competingSides find (side _player);

	_voteTable = missionNamespace getVariable [format ["OWL_sectorVotes_%1", side _player], []];
	_entry = _voteTable findIf {_x#0 == _client};
	if (_entry != -1) then {
		if ((_voteTable # _entry) # 1 != (OWL_allSectors find _sector)) then {
			_voteTable set [_entry, [_client, OWL_allSectors find _sector]];
		};
	} else {
		_voteTable pushBack [_client, OWL_allSectors find _sector];
	};
	
	missionNamespace setVariable [format ["OWL_sectorVotes_%1", side _player], _voteTable];

	private _votes = []; 
	{ 
		private _client = _x#0;
		_sector = _x#1;
	
		private _idx = _votes findIf {_x#0 == _sector};
		if (_idx == -1) then { 
			_votes pushBack [_sector, 1]; 
		} else { 
			_votes set [_idx, [_sector, (_votes#_idx#1) + 1]]; 
		}; 
	} forEach _voteTable;

	OWL_sectorVoteList set [_sideIndex, _votes];
	publicVariable "OWL_sectorVoteList";

	// If it's the first vote cast of the voting session, initiate countdown + tell clients
	if (count _voteTable == 1 && !(OWL_voteTrigger#_sideIndex)) then {
		OWL_voteTrigger set [_sideIndex, true];
		private _endTime = serverTime+15;
		_endTime remoteExec ["OWL_fnc_srSectorVoteInit", side _player];
		[(side _player), _endTime] spawn OWL_fnc_delayedSectorSelection;
	};

	// Update the clients with new vote info
	remoteExec ["OWL_fnc_srSectorVoteUpdate", side _player];
};