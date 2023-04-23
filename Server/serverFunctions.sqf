/* Split this into it's own functions and folders as it gets unruly as the project grows. */

/* Find player based on their machine id */
OWL_fnc_getPlayerFromOwnerId = {
	params ["_ownerId"];

	_player = objNull;
	{
		if (owner _x == _ownerId) then {
			_player = _x;
		};
	} forEach (call BIS_fnc_listPlayers);
	_player;
};

/* Find most voted sector for a given side */
OWL_fnc_mostVotedSector = {
	params ["_side"];

	private _voteTable = missionNamespace getVariable [format ["OWL_sectorVotes_%1", _side], []];
	private _mostVoted = createHashMap;
	private _highCount = 0;
	private _highSector = objNull;
	{
		private _count = _mostVoted getOrDefault [_x#1, 0];
		_count = _count + 1;
		_mostVoted set [(_x#1), _count];

		if (_count > _highCount) then {
			_highCount = _count;
			_highSector = (_x#1);
		};
	} forEach _voteTable;

	OWL_allSectors # _highSector;
};

/* Handle logic for when a sector is seized by a side */
OWL_fnc_onSectorSeized = {
	params ["_sector", "_seizedBy"];

	private _oldSide = _sector getVariable "OWL_sectorSide";

	_sector setVariable ["OWL_sectorSide", _seizedBy, TRUE];
	_sector setVariable ["OWL_sectorTickets", [150,150], TRUE];

	// You only keep zone restriction if you capture a sector from AAF.
	// However you do not gain assets to protect it like in vanilla.

	// TODO: sector assets variable is placeholder, do whatever you want.
	if (!(_oldSide in OWL_competingSides)) then {
		_sector setVariable ["OWL_sectorAssetCount", [[],[],[]], TRUE];
	} else {
		_sector setVariable ["OWL_sectorProtected", false, TRUE];
		_sector setVariable ["OWL_sectorAssetCount", [[],[],[]], TRUE];
	};

	_sector setVariable ["OWL_sectorCapInfo", [0, [WEST, EAST, RESISTANCE] find _seizedBy]];
	_sector setVariable ["OWL_sectorCapProgress", 0];

	[_sector, _oldSide, _seizedBy] remoteExec ["OWL_fnc_srSectorSeized"];

	private _sideIndex = OWL_competingSides find _seizedBy;
	if (OWL_contestedSector # _sideIndex == _sector) then {
		OWL_contestedSector set [_sideIndex, objNull];
		publicVariable "OWL_contestedSector";

		_seizedBy call OWL_fnc_initSectorVote;
	};

	// Capturing base = 10xsector income bonus
	{
		[_x, (_sector getVariable "OWL_sectorIncome")*10] call OWL_fnc_addFunds;
	} forEach OWL_allWarlords;

	[_sector, _oldSide, _seizedBy] call OWL_fnc_rerouteAI;
};

/* Called when a vote begins */
OWL_fnc_initSectorVote = {
	params ["_side"];

	remoteExec ["OWL_fnc_srSectorVoteNotify", _side];
	OWL_gameState set [OWL_competingSides find _side, "voting"];
	publicVariable "OWL_gameState";
};

/* Called when a new sector is selected by a side */
OWL_fnc_onSectorSelected = {
	params ["_side", "_nextSector"];

	private _sideIndex = OWL_competingSides find _side;

	OWL_contestedSector set [_sideIndex, _nextSector];
	publicVariable "OWL_contestedSector";

	[_side, _nextSector] remoteExec ["OWL_fnc_srSectorSelected"];

	_nextSector execVM "Server\sectorSpawnUnits.sqf";
};

/* Placeholder for sector selection reset */
OWL_fnc_sectorSelectionReset = {
	params ["_side"];

	private _sector = OWL_contestedSector # (OWL_competingSides find _side);

	/* If the sector  */
};

/* This is executed when the first vote is cast */
OWL_fnc_delayedSectorSelection = {
	params ["_side", "_endTime"];
	
	waitUntil {_endTime <= serverTime};

	private _sideIndex = OWL_competingSides find _side;
	private _nextSector = _side call OWL_fnc_mostVotedSector;

	if (_nextSector getVariable "OWL_sectorSide" == _side) exitWith {
		// Sector was captured during the sector vote. "Extend the vote"
		private _endTime = serverTime+15;
		_endTime remoteExec ["OWL_fnc_srSectorVoteInit", _side];
		[_side, _endTime] spawn OWL_fnc_delayedSectorSelection;
	};

	missionNamespace setVariable [format ["OWL_sectorVotes_%1", _side], []];

	OWL_sectorVoteList set [_sideIndex, []];	
	publicVariable "OWL_sectorVoteList";

	OWL_gameState set [_sideIndex, "attacking"];
	publicVariable "OWL_gameState";

	OWL_voteTrigger set [_sideIndex, false];

	[_side, _nextSector] call OWL_fnc_onSectorSelected;
};

/* Protect the sector and update the clients */
OWL_fnc_protectSector = {
	params ["_sector"];

	if (isNull _sector) exitWith {};

	_sector setVariable ["OWL_sectorProtected", true, TRUE];
};

/* Tell all remaining AI to do something else */
OWL_fnc_rerouteAI = {
	params ["_sector", "_oldSide", "_seizedBy"];

	private _groups = _sector getVariable ["OWL_sectorGroups", []];
	private _vehicles = _sector getVariable ["OWL_sectorVehicles", []];

	{
		{
			deleteWaypoint _x;
		} forEach waypoints _x;

		// For now just be annoying and rush center of newly capped sector.
		private _wp = _x addWaypoint [getPosATL _sector, 50];
		_wp setWaypointType "SAD";
		_x setCurrentWaypoint _wp;
	} forEach _groups;

	{
		{
			if (!alive _x) then {
				deleteVehicle _x;
			};
		} forEach crew _x;
	} forEach _vehicles;
};

/* Helper to set serverside funds */
OWL_fnc_addFunds = {
	params ["_ownerId", "_amount"];

	private _data = OWL_allWarlords getOrDefault [_ownerId, [0, [], []]];
	private _funds = _data#0;

	_funds = _funds + _amount;

	if (_funds < 0) then {
		_funds = 0;
	};

	_data set [0, _funds];
	OWL_allWarlords set [_ownerId, _data];
	_funds remoteExec ["OWL_fnc_srCPUpdate", _ownerId];
	_funds;
};

/* Once purchase has been validated + spawned for the client, complete it and send updated command point balance */
OWL_fnc_completeAssetPurchase = {
	params ["_client", "_assets", "_inf"];

	private _assetsClass = _assets apply {typeOf _x};
	private _infClass = _inf apply {typeOf _x};
	private _cost = [_assetsClass + _infClass] call OWL_fnc_getAssetPurchaseSubtotal;

	private _data = OWL_allWarlords getOrDefault [_client, [0,[],[]]];
	private _funds = _data # 0;
	private _assArr = _data # 1;
	private _infArr = _data # 2;

	_assArr append _ownedAssets;
	_infArr append _squadMates;

	// Get rid of any null objects. This will happen on client as well.
	while {_assArr find objNull != - 1} do {
		_assArr deleteAt (_assArr find objNull);
	};
	while {_infArr find objNull != - 1} do {
		_infArr deleteAt (_infArr find objNull);
	};

	_data set [0, _funds - _cost];
	_data set [1, _assArr];
	_data set [2, _infArr];

	OWL_allWarlords set [_client, _data];
	(_funds - _cost) remoteExec ["OWL_fnc_srCPUpdate", _client];
};

/* Handle removal of fast travel tickets */
OWL_fnc_removeFastTravelTicket = {
	params ["_sector", "_side"];

	private _ticketArr = _sector getVariable ["OWL_sectorTickets", [0,0]];
	private _sideIndex = OWL_competingSides find _side;
	_ticketArr set [_sideIndex, (_ticketArr # _sideIndex) - 1];
	_sector setVariable ["OWL_sectorTickets", _ticketArr, TRUE];
	// If 0 Notify cliets? Or just let them be unable to fast travel?
};