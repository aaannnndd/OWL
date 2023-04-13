
/* Possible sector parameters

OWL_sectorParam_canBeBase
	0 - Can't be base
	1 - Can be base
	2 - Can be base and default base if randomization is disabled
	
OWL_sectorParam_name
	Any string to use as a sector name

OWL_sectorParam_side
	Indicates who owns the sector at the start of the game
	0 - Unclaimed
	1 - Competing side 1
	2 - Competing side 2
	3 - Defending side

OWL_sectorParam_income
OWL_sectorParam_hasHarbour
OWL_sectorParam_hasHelipad
OWL_sectorParam_hasRunway
OWL_sectorParam_fastTravelEnabled
OWL_sectorParam_borderSize

OWL_sectorParam_canBeBase
OWL_sectorParam_name
OWL_sectorParam_side
OWL_sectorParam_income
OWL_sectorParam_fastTravelEnabled
OWL_sectorParam_borderSize
OWL_sectorParam_assetRequirements = "AWH"   "Aircraft, Water, Helicopter"

*/

OWL_fnc_protectSector = {
	params ["_sector", "_forceMax"];

	if (isNull _sector) exitWith {};

	private _assetList = _sector getVariable ["OWL_sectorAssets", [[],[],[]]];

	/* I feel like I should verify this */
	private _concassets = [];
	(OWL_reenforceAssetList get (_sector getVariable "OWL_sectorSide")) apply {_concassets append _x};
	private _error = false;
	{
		{
			if (!(_x in _concassets)) then {
				_error = true;
			};
		} forEach _x;
	} forEach _assetList;

	_sector setVariable ["OWL_sectorProtected", true, TRUE];
};

OWL_fnc_spawnProtections = {
	params ["_sector"];
};

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
	_sector setVariable ["OWL_sectorTickets",		[150,150,150], TRUE];
	_sector setVariable ["OWL_sectorAreaOld", 		[_sectorPos] + triggerArea _trigger, TRUE];

	// TODO: ["DefaultTicketValuePerSector <-- or something like that"] call BIS_fnc_getParamValue

	/* Set up dynamic variables only */
	_sector setVariable ["OWL_sectorProtected", true, TRUE];
	_sector setVariable ["OWL_sectorAssets", [[],[],[]], TRUE];

	/* Final housecleaning */
	_sector enableSimulationGlobal false;

	if (_canBeBase > 0) then {
		OWL_candidateBases pushBack _sector;
	};

	_sector setVariable ["OWL_sectorIndex",	OWL_allSectors pushBack _sector, TRUE];
} forEach (entities "Logic");

{
	_side = _x;
	_mainBase = OWL_candidateBases findIf {_x getVariable "OWL_sectorSide" == _side};
	if (_mainBase != -1) then {
		OWL_mainBases set [_forEachIndex, OWL_candidateBases # _mainBase];
	};
} forEach OWL_competingSides;

publicVariable "OWL_allSectors";
publicVariable "OWL_mainBases";

call OWL_fnc_updateSpawnPoints;
