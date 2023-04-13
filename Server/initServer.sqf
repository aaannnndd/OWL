OWL_fnc_updateSpawnPoints = compileFinal preprocessFileLineNumbers "Server\updateSpawnPoints.sqf";
OWL_fnc_initSectors = compileFinal preprocessFileLineNumbers "Server\initSectors.sqf";
OWL_fnc_initVariables = compileFinal preprocessFileLineNumbers "Server\initVariables.sqf";

call compileFinal preprocessFileLineNumbers "Server\serverFunctions.sqf";
call compileFinal preprocessFileLineNumbers "Server\clientRequests.sqf";

call OWL_fnc_initSectors;
call OWL_fnc_initVariables;

call compileFinal preprocessFileLineNumbers "Server\incomePPM.sqf";

OWL_persistentData = createHashMap;
OWL_allWarlords = createHashMap;
OWL_inAreaZRList = [];

OWL_contestedSector = [objNull, objNull];
OWL_gameState = ["",""];
publicVariable "OWL_gameState";
OWL_sectorVoteList = [[],[]];
OWL_bankFunds = [0,0];

OWL_voteTrigger = [false, false];

// garbage for testing
OWL_loadoutProgress = [[0,0,0,0,0,0],[0,0,0,0,0,0]];
OWL_loadouts = [
	[],
	[],
	[],
	[],
	[]
];

publicVariable "OWL_contestedSector";

/*
	These are static arrays with the proper data - I think this is more performant than looking-up the 
	Area, Bordersize, and Position every loop.
*/

OWL_sectorPositionMatrix = [];
OWL_sectorAreaMatrix = [];
OWL_sectorAreaBorderMatrix = [];

{
	private _area = _x getVariable "OWL_sectorArea";
	private _border = _x getVariable "OWL_sectorBorderSize";

	OWL_sectorPositionMatrix pushBack (getPosATL _x);
	OWL_sectorAreaMatrix pushBack (_area);
	OWL_sectorAreaBorderMatrix pushBack (_area apply {_x + _border});
} forEach OWL_allSectors;

call compileFinal preprocessFileLineNumbers "Server\serverEventHandlers.sqf";

missionNamespace setVariable ["OWL_serverInitialized", true, true];
["Server initialization finished"] call OWL_fnc_log;

{
	_x call OWL_fnc_initSectorVote;
} forEach OWL_competingSides;

[] spawn {
	while {TRUE} do {
		sleep 1;
		execVM "Server\serverSectorSeizingCheck.sqf";
	};
};
