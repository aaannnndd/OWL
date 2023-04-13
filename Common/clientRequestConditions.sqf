/*
	The purpose of these functions, is for visibility to the client for when they can and cannot request a certain function/requisition
	from the server. The server will also use this function on the player when it recieves the request to ensure it was sent fairly.

	Fast Travel to Paros -> Unavailable while condition is not met on the client.
		1). Client circumvents this functionality and asks server to fast travel.
		2). Server validates whether or not the client can actually fast travel upon recieving request.
		3). Server denies fast travel.
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

	private _sideIndex = OWL_competingSides find _side;
	private _sectorSide = _sector getVariable "OWL_sectorSide";
	private _cooldown = (_sector getVariable "OWL_sectorScanCooldown") # _sideIndex;
	private _protected = _sector getVariable "OWL_sectorProtected";
	// If it's on cooldown, and (server is back-cappable, OR you own the sector)
	(_cooldown <= serverTime && (!_protected || (_sectorSide == _side) || (_sector == (OWL_contestedSector # _sideIndex))));
};

OWL_fnc_conditionAirdrop = {
	params ["_player", "_sector", "_assets"];
    true;
};

OWL_fnc_conditionDeployDefense = {
	params ["_player", "_sector", "_asset"];
    true;
};

OWL_fnc_conditionDeployNaval = {
	params ["_player", "_sector", "_asset"];
    true;
};

OWL_fnc_conditionAircraftSpawn = {
	params ["_player", "_sector", "_asset"];
    true;
};

OWL_fnc_conditionRemoveAsset = {
	params ["_player", "_asset"];
    true;
};

OWL_fnc_conditionPurchaseReenforcements = {
	params ["_player", "_sector", "_asset"];
    true;
};