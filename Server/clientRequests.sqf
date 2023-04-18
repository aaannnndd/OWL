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

/******************************************************
***********			Asset Business			***********
******************************************************/

// Request to aidrop a list of assets at an objects location.
OWL_fnc_crAirdrop = {
	params ["_target", "_assets", "_flags"];
	
	// TODO
	// 1). Validate all assets are orderable
	// 2). Validate price of all assets is affordable
	// done). For all resupply boxes, duplicate versions can be merged into 1 (double the cargo)
	// 4). For all Infantry / Vehicles, do position finding + parachute bs.
	// 5). Adjust player command points
	// 6). Adjust drop height based on proximity to sectors
	// 7). Better spread on paradrop units (Very close right now)
	// 8). Make a better command point transaction system
	// 9). Send back list of owned vehicles to player
	// 10). Allow managing assets of owned vehicles/squad
	
	private _ownedAssets = [];
	private _squadMates = [];
	_target = getPosATL _target;

	private _owner = remoteExecutedOwner;
	private _player = _owner call OWL_fnc_getPlayerFromOwnerId;

	/* Sort all of our assets into their groups */
	private _ammoCrates = [];
	private _ammoCrateCount = [];
	private _infantry = [];
	private _vehicles = [];
	{
		if (_x isKindOf "ReammoBox_F") then {
			if (getNumber (configFile >> "CfgVehicles" >> _x >> "transportAmmo") == 0) then {
				if (_x in _ammoCrates) then {
					private _index = _ammoCrates find _x;
					_ammoCrateCount set [_index, (_ammoCrateCount # _index) + 1];
				} else {
					_ammoCrates pushBack _x;
					_ammoCrateCount pushBack 1;
				};
			} else {
				_ammoCrates pushBack _x;
				_ammoCrateCount pushBack 1;			
			};
		};
		if (_x isKindOf "LandVehicle") then {
			_vehicles pushBack _x;
		};
		if (_x isKindOf "Man") then {
			_infantry pushBack _x;
		};
	} forEach _assets;

	/* Combine duplicate ammo crates into a single one with more cargo count */
	{
		private _finalPos = _target findEmptyPosition [0, 100, _x];
		private _crate = createVehicle [_x, _finalPos, [], 0, "CAN_COLLIDE"];

		private _para = createVehicle ["B_Parachute_02_F", _finalPos, [], 0, "FLY"];
		_para setPos [_finalPos # 0, _finalPos # 1, 100];

		private _bBox = boundingBoxReal _crate;
		private _bBoxCenter = (_bbox # 0) vectorAdd (_bBox # 1);
		_crate attachTo [_para, _bBoxCenter];

		if (getNumber (configFile >> "CfgVehicles" >> _x >> "transportAmmo") == 0) then {
			private _crateCount = (_ammoCrateCount#_forEachIndex);
			private _wpns = getWeaponCargo _crate;
			private _items = getItemCargo _crate;
			private _mags = getMagazineCargo _crate;
			private _back = getBackpackCargo _crate;

			{
				_crate addWeaponCargoGlobal [_x, ((_wpns#1)#_forEachIndex)*_crateCount];
			} forEach (_wpns#0);

			{
				_crate addItemCargoGlobal [_x, ((_items#1)#_forEachIndex)*_crateCount];
			} forEach (_items#0);

			{
				_crate addMagazineCargoGlobal [_x, ((_mags#1)#_forEachIndex)*_crateCount];
			} forEach (_mags#0);

			{
				_crate addBackpackCargoGlobal [_x, ((_back#1)#_forEachIndex)*_crateCount];
			} forEach (_back#0);
		};
		_ownedAssets pushBack _crate;
	} forEach _ammoCrates;

	/* Spawn all of our vehicles */
	{
		private _finalPos = _target findEmptyPosition [0, 100, _x];
		private _vehicle = createVehicle [_x, _finalPos, [], 0, "CAN_COLLIDE"];

		private _para = createVehicle ["B_Parachute_02_F", _finalPos, [], 0, "FLY"];
		_para setPos [_finalPos # 0, _finalPos # 1, 100];
		_para disableCollisionWith _vehicle;
		private _bBox = boundingBoxReal _vehicle;
		private _bBoxCenter = (_bbox # 0) vectorAdd (_bBox # 1);
		_bBoxCenter = [(_bBox#1)#0 + (_bBox#0)#0, (_bBox#1)#1 + (_bBox#0)#1, (_bBox#1)#2];
		_vehicle attachTo [_para, _bBoxCenter];

		_ownedAssets pushBack _vehicle;
	} forEach _vehicles;

	/* Spawn all of our infantry - combine with vehicles if flag is enabled */
	{
		private _finalPos = _target findEmptyPosition [0, 100, _x];
		private _para = createVehicle ["Steerable_Parachute_F", _finalPos, [], 0, "FLY"];
		_para setPos [_finalPos # 0, _finalPos # 1, 100];

		private _unit = group (_player) createUnit [_x, _target, [], 0, "NONE"];
		_unit assignAsDriver _para;
		_unit moveInDriver _para;

		_squadMates pushBack _unit;
	} forEach _infantry;

	/* Server plays this sound */
	playSound3D ["A3\Data_F_Warlords\sfx\flyby.wss", objNull, FALSE, _target vectorAdd [0, 0, 100]];
};

// Client requests to use a loadout
OWL_fnc_crLoadout = {
	params ["_player", "_loadout"];

};

OWL_fnc_removeFastTravelTicket = {
	params ["_sector", "_side"];

	private _ticketArr = _sector getVariable ["OWL_sectorTickets", [0,0]];
	private _sideIndex = OWL_competingSides find _side;
	_ticketArr set [_sideIndex, (_ticketArr # _sideIndex) - 1];
	_sector setVariable ["OWL_sectorTickets", _ticketArr, TRUE];
	// If 0 Notify cliets? Or just let them be unable to fast travel?
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

	[_sector, side _player] call OWL_fnc_removeFastTravelTicket;
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