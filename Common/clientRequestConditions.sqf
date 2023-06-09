/*
	The purpose of these functions, is for visibility to the client for when they can and cannot request a certain function/requisition
	from the server. The server will also use this function on the player when it recieves the request to verify again on the server

	Fast Travel to Paros -> Unavailable while condition is not met on the client.
		1). Client circumvents this functionality and asks server to fast travel.
		2). Server validates whether or not the client can actually fast travel upon recieving request.
		3). Server denies fast travel if conditions not met.

	TODO:
	Convert return values into:
	"" - valid
	"Condition not met 1\nCondition not met 2\nCondition not met 3" - error tooltip text to return.
*/

OWL_fnc_conditionFastTravel = {
	params ["_player", "_sector"];

	if (isNull _sector) exitWith {
		false;
	};
	
	if (_sector getVariable "OWL_sectorFTEnabled" == false) exitWith {
		false;
	};

	if (_sector getVariable "OWL_sectorSide" != side _player && !([_sector, side _player] call OWL_fnc_sectorContestedFor)) exitWith {
		false;
	};

	if ( [_sector, side _player] call OWL_fnc_sectorTicketCount <= 0 ) exitWith {
		false;
	};

	if (!([_sector, side _player] call OWL_fnc_sectorLinkedWithBase)) exitWith {
		false;
	};

	true;
};

OWL_fnc_conditionContestedFastTravel = {
	
	// A playar may be 'spawned' on if;
	// - They last fast traveled to a friendly SECTOR
	// - They are within 1KM of the contested zone.
	//
	//
	//
};

OWL_fnc_conditionSectorVote = {
	params ["_sector", "_side"];

	if (isNull _sector) exitWith {
		false;
	};

	if (_sector getVariable "OWL_sectorSide" == _side) exitWith {
		false;
	};

	if (!([_sector, _side] call OWL_fnc_sectorLinkedWithBase)) exitWith {
		false;
	};

	if ( (OWL_gameState # (OWL_competingSides find _side)) != "voting") exitWith {
		false;
	};

	true;
};

OWL_fnc_conditionTransferPoints = {
	true;
};

OWL_fnc_conditionSectorScan = {
	params ["_sector", "_side"];

	if (isNull _sector) exitWith {
		false;
	};

	private _sideIndex = OWL_competingSides find _side;
	private _sectorSide = _sector getVariable "OWL_sectorSide";
	private _cooldown = (_sector getVariable "OWL_sectorScanCooldown") # _sideIndex;
	private _protected = _sector getVariable "OWL_sectorProtected";
	// If it's on cooldown, and (server is back-cappable, OR you own the sector)
	(_cooldown <= serverTime && (!_protected || (_sectorSide == _side) || (_sector == (OWL_contestedSector # _sideIndex))));
};

OWL_fnc_subConditionAirdrop = {
	params ["_player", "_assets"];

	/* Check if have sufficient command points + viable asset list */
	true;
};

/* Check if you can airdrop at specific location */
OWL_fnc_conditionAirdropLocation = {
	params ["_player", "_target", "_assets"];

	if (isNull _target) exitWith {
		false;
	};

	if (_target != _player && _target getVariable "OWL_sectorSide" != (side _player)) exitWith {
		false;
	};

	private _commandPoints = uiNamespace getVariable ["OWL_dummyFunds", 0];
	if (isServer) then {
		_commandPoints = OWL_allWarlords get (owner _player);
		_commandPoints = _commandPoints # 0;
	};

	// get cost of assets and validate you can.

	true;
};

// Make sure an object can be placed.
// Object intersection checks will be kept serverside only.
OWL_fnc_conditionDeployDefense = {
	params ["_player", "_asset"];

	if (isNull _player) exitWith {
		false;
	};

	private _sector = _player call OWL_fnc_isInFriendlyZone;

	if (isNull _sector) exitWith {
		false;
	};

	if (_sector getVariable "OWL_sectorInCombat") exitWith {
		false;
	};

    true;
};

// Just check if it's a water surface
OWL_fnc_conditionDeployNaval = {
	params ["_player", "_asset", "_position"];

	if (!(surfaceIsWater _position)) exitWith {
		false;
	};
	
    true;
};

// Check if proper disposition
OWL_fnc_conditionAircraftSpawn = {
	params ["_player", "_sector", "_asset"];

	if (isNull _player) exitWith {
		false;
	};

	if (isNull _sector) exitWith {
		false;
	};

	if (!([_player, [_asset]] call OWL_fnc_validateAssetPurchase)) exitWith {
		false;
	};

    true;
};

OWL_fnc_conditionAircraftSpawnFlying = {
	params ["_player", "_asset"];
	true;
};

/********************/
/* ASSET MANAGEMENT */
/********************/

OWL_fnc_conditionRemoveAsset = {
	params ["_player", "_asset"];

	// TODO: use servers owned assets thing in OWL_allWarlords
	if (!([_player, _asset] call OWL_fnc_ownsAsset)) exitWith {
		false;
	};

	private _hasPlayer = false;
	{
		if (alive _x && isPlayer _x) then {
			_hasPlayer = true;
		};
	} forEach crew _asset;

	if (_hasPlayer) exitWith {
		false;
	};

	true;
};

OWL_fnc_conditionClearInventory = {
	params ["_player", "_asset"];

	if (!([_player, _asset] call OWL_fnc_ownsAsset)) exitWith {
		false;
	};

	private _hasPlayer = false;
	{
		if (alive _x && isPlayer _x) then {
			_hasPlayer = true;
		};
	} forEach crew _asset;

	if (_hasPlayer) exitWith {
		false;
	};

	true;
};

OWL_fnc_conditionLockAsset = {
	params ["_player", "_asset"];

	if (!([_player, _asset] call OWL_fnc_ownsAsset)) exitWith {
		false;
	};

	private _hasPlayer = false;
	{
		if (alive _x && isPlayer _x) then {
			_hasPlayer = true;
		};
	} forEach crew _asset;

	if (_hasPlayer) exitWith {
		false;
	};

	true;
};

OWL_fnc_conditionToggleLights = {
	params ["_player", "_asset"];
};

OWL_fnc_conditionToggleEngine = {
	params ["_player", "_asset"];
};

OWL_fnc_conditionToggleRadar = {
	params ["_player", "_asset"];
};

OWL_fnc_conditionAddAssetToSector = {
	params ["_player", "_asset", "_sector"];
};

OWL_fnc_conditioKickNonSquadMembers = {
	params ["_player", "_asset"];

	if (isNull _player) exitWith {false};
	if (isNull _asset) exitWith {false};

	private _ownsAsset = [_player, _asset] call OWL_fnc_ownsAsset;

	private _toKick = false;
	{
		if (group _x != group _player) then {
			_toKick = true;
		};
	} forEach crew _asset;

	_toKick && _ownsAsset;
};


// Make sure they exist so we aren't spawning VLS 
// On behalf of some hacker.
OWL_fnc_conditionPurchaseReenforcements = {
	params ["_player", "_sector", "_asset"];
    true;
};

// Loadout requirement for a player to get a loadout.
OWL_fnc_conditionLoadout = {
	params ["_player", "_loadout"];

	if (!(_player call OWL_fnc_isInFriendlyZone)) exitWith {false;};

	// check player has right $$$

	true;
};