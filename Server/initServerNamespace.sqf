// This will contain all variables we don't want changed by any clients/hacker. (all of them -.-)
// Not working, WIP

with localNamespace do {

	/************************************************
	**********[    CLIENT SYNCHRONIZED    ]**********
	************************************************/

	// Sector variables
	OWL_sectorPos = [];
	OWL_sectorName = [];
	OWL_sectorSide = [];
	OWL_sectorIncome = [];
	OWL_sectorFTEnabled = [];
	OWL_sectorBorderSize = [];
	OWL_sectorRequirements = [];
	OWL_sectorArea = []; 
	OWL_sectorScanCooldown = [];
	OWL_sectorTickets = [];
	OWL_sectorAreaOld = []; 
	OWL_sectorProtected = [];
	OWL_sectorAssets = [];
	OWL_sectorFTEnabled = [];
	OWL_sectorVotes = [];
	OWL_sectorCapInfo = [];
	OWL_sectorCapProgress = [];
	OWL_sectorAssets = [];

	/************************************************
	**********[       SECTOR INIT        ]***********
	************************************************/

	OWL_allSectors = [];
	OWL_candidateBases = [];
	OWL_mainBases = [];

	{
		private _sector = _x;
		private _syncedObjects = synchronizedObjects _sector;
		private _trigger = _syncedObjects findIf { typeOf _x == "EmptyDetector" };
		if (_trigger == -1) then {continue};

		_trigger = _syncedObjects # _trigger;

		/* Set up our sectors 'default/static values/variables' */
		// TODO clean up old dev's redudant vars
		private _canBeBase			= _sector getVariable "OWL_sectorParam_canBeBase";
		private _sectorName 		= _sector getVariable "OWL_sectorParam_name";
		private _useLocationName 	= _sector getVariable "OWL_sectorParam_useLocationName";
		private _sectorSide 		= _sector getVariable "OWL_sectorParam_side";
		private _sectorIncome 		= _sector getVariable "OWL_sectorParam_income";
		private _sectorFTEnabled	= _sector getVariable "OWL_sectorParam_fastTravelEnabled";
		private _sectorBorderSize	= _sector getVariable "OWL_sectorParam_borderSize";
		private _sectorRequirements = _sector getVariable "OWL_sectorParam_assetRequirements";

		private _sectorArea			= triggerArea _trigger;
		private _sectorPos			= getPosATL _sector;
		
		/* Clean up sectorArea info */
		_sectorArea deleteAt 2;
		_sectorArea deleteAt 2;

		_sectorSide = [sideEmpty, OWL_competingSides#0, OWL_competingSides#1, OWL_defendingSide] # _sectorSide;

		/* Set up our sectors dynamic variables from defaults */
		_sector setVariable ["OWL_sectorName",			_sectorName];
		_sector setVariable ["OWL_sectorSide",			_sectorSide, TRUE];
		_sector setVariable ["OWL_sectorIncome",		_sectorIncome, TRUE];
		_sector setVariable ["OWL_sectorFTEnabled",		_sectorFTEnabled, TRUE];
		_sector setVariable ["OWL_sectorBorderSize",	_sectorBorderSize, TRUE];
		_sector setVariable ["OWL_sectorRequirements",	_sectorRequirements, TRUE];
		_sector setVariable ["OWL_sectorArea", 			_sectorArea, TRUE];
		_sector setVariable ["OWL_sectorScanCooldown",	[0,0,0], TRUE];
		_sector setVariable ["OWL_sectorTickets",		[150,150], TRUE];
		_sector setVariable ["OWL_sectorAreaOld", 		[_sectorPos] + triggerArea _trigger, TRUE];
		_sector setVariable ["OWL_sectorProtected", true, TRUE];
		_sector setVariable ["OWL_sectorAssets", [[],[],[]], TRUE];

		/* Final housecleaning */
		_sector enableSimulationGlobal false;

		if (_canBeBase > 0) then {
			OWL_candidateBases pushBack _sector;
		};

		_sector setVariable ["OWL_sectorIndex",	OWL_allSectors pushBack _sector, TRUE];

		OWL_sectorPos = pushBack _sectorPos;
		OWL_sectorName = pushBack _sectorName;
		OWL_sectorSide = pushBack _sectorSide;
		OWL_sectorIncome = pushBack _sectorIncome;
		OWL_sectorFTEnabled = pushBack _sectorFTEnabled;
		OWL_sectorBorderSize = pushBack _sectorBorderSize;
		OWL_sectorRequirements = pushBack _sectorRequirements;
		OWL_sectorArea = pushBack _sectorArea; 
		OWL_sectorScanCooldown = pushBack [0,0,0];
		OWL_sectorTickets = pushBack [150,150];
		OWL_sectorAreaOld = pushBack ([_sectorPos] + (triggerArea _trigger)); 
		OWL_sectorProtected = pushBack true;
		OWL_sectorAssets = pushBack [[],[],[]];
		OWL_sectorCapProgress = 0;

		_trigger enableSimulationGlobal false;
		deleteVehicle _trigger;
	} forEach (entities "Logic");

	/************************************************
	**********[       SERVER ONLY         ]**********
	************************************************/

	OWL_persistentData = createHashMap;
	OWL_allWarlords = createHashMap;
	OWL_inAreaZRList = [];
	OWL_sectorVoteList = [[],[]];
	OWL_bankFunds = [0,0];
	OWL_voteTrigger = [false, false];

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

};

OWL_fnc_serverSectorSetVar = {
	params ["_sectorIndex", "_varName", "_varValue"];

	private _arr = localNamespace getVariable "_varName";
	_arr set [_sectorIndex, _varValue];
};

OWL_fnc_serverSectorGetVar = {
	params ["_sectorIndex", "_varName"];

	private _arr = localNamespace getVariable "_varName";
	_arr # _sectorIndex;
};

OWL_fnc_setVar = {
	params ["_varName", "_varValue"];
	uiNamespace setVariable [_varName, _varValue];
};

OWL_fnc_getVar = {
	params ["_varName"];
	uiNamespace getVariable _varName;
};