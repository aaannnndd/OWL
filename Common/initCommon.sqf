/******************************************************
***********		Init Common Functions		***********
******************************************************/

call compileFinal preprocessFileLineNumbers "Common\clientRequestConditions.sqf";
call compileFinal preprocessFileLineNumbers "Common\commonFunctions.sqf";

if (isMultiplayer) then {
  OWL_fnc_syncedTime = { serverTime };
}
else {
  OWL_fnc_syncedTime = { time };
};

/** TODO 
[] spawn {
	waitUntil {!isNil "BIS_WL_arsenalSetupDone"};
	call BIS_fnc_WLArsenalFilter;
};
 */

/******************************************************
***********		Init Common Globals			***********
******************************************************/

OWL_competingSides = [[WEST, EAST], [WEST, RESISTANCE], [EAST, RESISTANCE]] # (["Combatants"] call BIS_fnc_getParamValue);
OWL_defendingSide = [RESISTANCE, EAST, WEST, RESISTANCE] # (["Combatants"] call BIS_fnc_getParamValue);

OWL_defendersPlayable = (["DefendersPlayable"] call BIS_fnc_getParamValue) == 1;

OWL_playableSides = +OWL_competingSides;
if (OWL_defendersPlayable) then { OWL_playableSides pushBack OWL_defendingSide; };

// Variations on these for quicker access in 'draw' handlers.
OWL_sideColor = createHashMapFromArray [
	[WEST, [0,0.2,0.8,0.8]],
	[EAST, [0.8,0.1,0.1,0.8]],
	[RESISTANCE, [0,0.8,0.2,0.8]]
];

OWL_sideColorByIndex = [[0,0.2,0.8,0.8],
					[0.8,0.1,0.1,0.8],
					[0,0.8,0.2,0.8]];

OWL_sideByIndex = [WEST, EAST, RESISTANCE];

/******************************************************
***********		Init Config Info			***********
******************************************************/

// All assets orderable by players.
OWL_reenforceAssetList = createHashMap;
private _cfg = missionConfigFile >> "CfgWLSectorAssetPreset" >> "OpenWarlords";
{
	private _side = configName _x;
	private _subArr = [];
	{
		private _cat = configName _x;
		private _list = [];
		{
			private _asset = configName _x;
			_list pushBack _asset;
		} forEach (configProperties [(_cfg >> _side >> _cat), "true", true]);
		_subArr pushBack _list;
	} forEach (configProperties [ (_cfg >> _side), "true", true]);
	OWL_reenforceAssetList set [_side, _subArr];
} forEach (configProperties [(_cfg), "true", true]);

// All loadouts usable by players
OWL_loadoutRequirements = createHashMap;
_cfg = missionConfigFile >> "CfgLoadoutCost" >> "OpenWarlords";
{
	private _side = configName _x;
	private _arr = [];
	{
		private _class = configName _x;
		private _name = getText (_cfg >> _side >> _class >> "name");
		private _req = getArray (_cfg >> _side >> _class >> "req");
		private _amt = getNumber (_cfg >> _side >> _class >> "amount");
		private _cst = getNumber (_cfg >> _side >> _class >> "cost");
		private _reqstr = getText (_cfg >> _side >> _class >> "reqstr");

		_arr pushBack [_class, _name, _cst, _reqstr, _amt, _req];
	} forEach (configProperties [_cfg >> _side, "true", true]);
	OWL_loadoutRequirements set [_side, _arr];
} forEach (configProperties [_cfg, "true", true]);

OWL_loadoutProgress = [];
{
	private _side = str _x;
	private _arr = [];
	{
		private _class = _x#0;
		_arr pushBack (getNumber (_cfg >> _side >> _class >> "progress"));
	} forEach (OWL_loadoutRequirements get _side);
	OWL_loadoutProgress pushBack _arr;
} forEach OWL_competingSides;