/* Split this into it's own functions and folders as it gets unruly as the project grows. */

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

OWL_fnc_onSectorSeized = {
	params ["_sector", "_seizedBy"];

	private _oldSide = _sector getVariable "OWL_sectorSide";

	_sector setVariable ["OWL_sectorSide", _seizedBy, TRUE];
	_sector setVariable ["OWL_sectorTickets", [150,150,150], TRUE];

	// If you captured it from AAF, you get full infantry protection.
	if (!(_oldSide in OWL_competingSides)) then {
		// TODO fill list.
		_sector setVariable ["OWL_sectorAssets", [[],[],[]], TRUE];
	} else {
		_sector setVariable ["OWL_sectorProtected", false, TRUE];
		_sector setVariable ["OWL_sectorAssets", [[],[],[]], TRUE];
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
};

OWL_fnc_initSectorVote = {
	params ["_side"];

	remoteExec ["OWL_fnc_srSectorVoteNotify", _side];
	OWL_gameState set [OWL_competingSides find _side, "voting"];
	publicVariable "OWL_gameState";
};

OWL_fnc_onSectorSelected = {
	params ["_side", "_nextSector"];

	private _sideIndex = OWL_competingSides find _side;

	OWL_contestedSector set [_sideIndex, _nextSector];
	publicVariable "OWL_contestedSector";

	[_side, _nextSector] remoteExec ["OWL_fnc_srSectorSelected"];

	_nextSector execVM "Server\sectorSpawnUnits.sqf";
};

OWL_fnc_sectorSeizableForSide = {
	params ["_sector", "_side"];
	
	private _sideIndex = OWL_competingSides find _side;

	if ((_sector getVariable "OWL_sectorProtected") && !(_sector != OWL_contestedSector # _sideIndex)) exitWith {
		false;
	};

	true;
};

OWL_fnc_sectorSeizable= {
	params ["_sector"];
	
	if ((_sector getVariable "OWL_sectorProtected") && !(_sector in OWL_contestedSector)) exitWith {
		false;
	};

	true;
};

OWL_fnc_sectorSelectionReset = {
	params ["_side"];

	private _sector = OWL_contestedSector # (OWL_competingSides find _side);

	// Check for all friendly units of same '_side' that are owned by the server.
	// 'Despawn' them and put them back into the sectors 'Assets'.
	// Players can then top off the sector to put the zone restriction back.
};

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