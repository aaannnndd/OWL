/******************************************************
***********		Init Common Functions		***********
******************************************************/

call compileFinal preprocessFileLineNumbers "Common\clientRequestConditions.sqf";
call compileFinal preprocessFileLineNumbers "Common\commonFunctions.sqf";

OWL_fnc_log = {
	private _msg = "[OWL] " + _this#0;
	if (OWL_devMode && hasInterface) then {
		systemChat _msg;
	};
	diag_log _msg;
};

if (isMultiplayer) then {
  OWL_fnc_syncedTime = { serverTime };
}
else {
  OWL_fnc_syncedTime = { time };
};

/******************************************************
***********		Init Common Globals			***********
******************************************************/

OWL_competingSides = [[WEST, EAST], [WEST, RESISTANCE], [EAST, RESISTANCE]] # (["Combatants"] call BIS_fnc_getParamValue);
OWL_defendingSide = [RESISTANCE, EAST, WEST, RESISTANCE] # (["Combatants"] call BIS_fnc_getParamValue);
OWL_defendersPlayable = (["DefendersPlayable"] call BIS_fnc_getParamValue) == 1;
DefendersCanAttack = OWL_defendersPlayable && {(["DefendersCanAttack"] call BIS_fnc_getParamValue) == 1};

OWL_playableSides = +OWL_competingSides;
if (OWL_defendersPlayable) then { OWL_playableSides pushBack OWL_defendingSide; };
if (DefendersCanAttack) then { OWL_competingSides pushBack OWL_defendingSide; };

OWL_sideColor = createHashMapFromArray [
	[WEST, [0,0.2,0.8,0.8]],
	[EAST, [0.8,0.1,0.1,0.8]],
	[RESISTANCE, [0,0.8,0.2,0.8]]
];

#define REENFORCE_ASSET_INDEX_INF 0
#define REENFORCE_ASSET_INDEX_LAV 1
#define REENFORCE_ASSET_INDEX_ARM 2

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

OWL_loadoutRequirements = createHashMap;
_cfg = missionConfigFile >> "CfgLoadoutCost" >> "OpenWarlords";
{
	private _side = configName _x;
	private _arr = [];
	{
		private _class = configName _x;
		private _req = getArray (_cfg >> _side >> _class >> "req");
		private _amt = getNumber (_cfg >> _side >> _class >> "amount");
		private _cst = getNumber (_cfg >> _side >> _class >> "cost");

		_arr pushBack [_cst, _amt, _req];
	} forEach (configProperties [_cfg >> _side, "true", true]);
	OWL_loadoutRequirements set [_side, _arr];
} forEach (configProperties [_cfg, "true", true]);

private _confgGroups = [configFile >> "CfgGroups" >> "WEST" >> "BLU_F" >> "Infantry", configFile >> "CfgGroups" >> "EAST" >> "OPF_F" >> "Infantry", configFile >> "CfgGroups" >> "Indep" >> "IND_F" >> "Infantry"];
private _factions = [WEST, EAST, INDEPENDENT];
OWL_unitGroupMap = createHashMap;
{
	_squads = [];
	{
		_squad = [];
		{ 
			_squad pushBack getText (_x >> "vehicle")
  		} forEach configProperties [_x, "isClass _x", true];
		_squads pushBack [getText (_x >> "name") ,_squad];
	} forEach configProperties [(_confgGroups # _forEachIndex), "isClass _x", true];
	OWL_unitGroupMap set [_x, _squads]; 
} forEach _factions;