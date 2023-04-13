/*
WARLORDS-SPECIFIC FUNCTION

Author: Josef Zem�nek

Description: Requested static weapon positionining routine.
*/

private _class = "SomeClass";
private _offset = [0, 1, 0];

if (visibleMap) then {
	titleCut ["", "BLACK IN", 0.5];
};
openMap [FALSE, FALSE];

private _def = createSimpleObject [_class, getPosWorld player, TRUE];

[_def, _offset] spawn {
	params ["_def", "_offset"];
	while {!isNull _def} do {
		_def setDir direction player;
		_def setPosASL ([getPosASL player, _offset # 1, direction player] call BIS_fnc_relPos);
		sleep 0.01;
	};
};

player reveal [_def, 4];

[BIS_WL_hintPrio_deployDefence, format ["[%1]: %2", localize "STR_dik_space", localize "STR_A3_assemble"] + "%1" + format ["[%1]: %2", localize "STR_dik_back", localize "STR_ca_cancel"], -1] spawn BIS_fnc_WLshowInfo;
[toUpper format [localize "STR_A3_WL_deploy_tip", localize "STR_dik_space"]] spawn BIS_fnc_WLSmoothText;

BIS_WL_spacePressed = FALSE;
BIS_WL_backspacePressed = FALSE;

[] spawn {
	disableSerialization;
	_spaceEH = (findDisplay 46) displayAddEventHandler ["KeyDown", {
		if (_this # 1 == 57) then {
			BIS_WL_spacePressed = TRUE;
			(findDisplay 46) displayRemoveEventHandler ["KeyDown", uiNamespace getVariable "BIS_WL_spaceEH"];
			uiNamespace setVariable ['BIS_fnc_titlecard_spaceEH', nil];
		};
		if (_this # 1 == 14) then {
			BIS_WL_backspacePressed = TRUE;
			(findDisplay 46) displayRemoveEventHandler ["KeyDown", uiNamespace getVariable "BIS_WL_spaceEH"];
			uiNamespace setVariable ['BIS_fnc_titlecard_spaceEH', nil];
		};
	}];
	uiNamespace setVariable ["BIS_WL_spaceEH", _spaceEH];
};

[] spawn {
	scriptName "WLDefenceSetup (area check)";
	while {BIS_WL_currentSelection != ""} do {
		_owned = BIS_WL_sectorsArrayFriendly # 0;
		if (_owned findIf {[player, _x, TRUE] call BIS_fnc_WLInSectorArea} == -1) exitWith {BIS_WL_backspacePressed = TRUE};
		sleep 5;
	};
};

_pos1 = [];
_pos2 = [];

waitUntil {_pos1 = getPosASL player; _pos1 vectorAdd [0, 0, 0.3]; _pos2 = [player, (_offset # 1) + 1, direction player] call BIS_fnc_relPos; _pos2 = ATLToASL _pos2; _pos2 vectorAdd [0, 0, 0.3]; lineIntersects [_pos1, _pos2, player, _def] || BIS_WL_spacePressed || BIS_WL_backspacePressed || (position _def) # 2 > 300 || (position _def) # 2 < 0.2 || vehicle player != player || !alive player || lifeState player == "INCAPACITATED"};

if (BIS_WL_spacePressed) then {
	_isFort = if (toLower getText (configFile >> "CfgVehicles" >> _class >> "simulation") == "house") then {TRUE} else {FALSE};
	deleteVehicle _def;
	_def = _class createVehicle position player;
	_def enableWeaponDisassembly FALSE;
	_def setPos position player;
	_def setDir direction player;
	player reveal [_def, 4];
	_def attachTo [player, _offset];
	_h = (position _def) # 2;
	detach _def;
	_offset_tweaked = [_offset select 0, _offset select 1, (_offset select 2) - _h];
	_def attachTo [player, _offset_tweaked];
	detach _def;
	_defPos = getPosATLVisual _def;
	if ((_defPos # 2) < 0) then {_def setPos [_defPos # 0, _defPos # 1, 0]};
	if !(_isFort) then {
		if (getNumber (BIS_WL_cfgVehs >> _class >> "isUav") == 1) then {
			createVehicleCrew _def;
			(effectiveCommander _def) setSkill 1;
			(group effectiveCommander _def) deleteGroupWhenEmpty TRUE;
			player setVariable ["BIS_WL_autonomousPool", (player getVariable ["BIS_WL_autonomousPool", []]) + [_def]];
		};
		[_def, BIS_WL_markerIndex, FALSE] spawn BIS_fnc_WLvehicleHandle;
		BIS_WL_markerIndex = BIS_WL_markerIndex + 1;
	};
	_def addAction [localize "STR_A3_WL_menu_remove_item", {_purchased = ((_this select 1) getVariable ["BIS_WL_pointer", objNull]) getVariable ["BIS_WL_purchased", []]; _purchased = _purchased - [_this select 0]; ((_this select 1) getVariable ["BIS_WL_pointer", objNull]) setVariable ["BIS_WL_purchased", _purchased, TRUE]; if (count crew (_this select 0) > 0) then {_grp = group effectiveCommander (_this select 0); {(_this select 0) deleteVehicleCrew _x} forEach crew (_this select 0); deleteGroup _grp}; deleteVehicle (_this select 0)}, [], -20, FALSE, TRUE, "", "vehicle _this != _target && _target in ((_this getVariable ['BIS_WL_pointer', objNull]) getVariable ['BIS_WL_purchased', []])", -1, FALSE];
	[_def, FALSE] call BIS_WL_vehicleLockCode;
	[toUpper format [localize "STR_A3_WL_deploy_done", getText (BIS_WL_cfgVehs >> _class >> "displayName")]] spawn BIS_fnc_WLSmoothText;
	playSound "assemble_target";
	(player getVariable "BIS_WL_pointer") setVariable ["BIS_WL_purchased", ((player getVariable "BIS_WL_pointer") getVariable "BIS_WL_purchased") + [_def], TRUE];
	_def setVariable ["BIS_WL_itemOwner", player];
	_ffProt = _def addEventHandler ["HandleDamage", BIS_WL_friendlyFireVehicleProtectionCode];
	[_def, _ffProt] spawn {
		params ["_item", "_ffProt"];
		sleep 10;
		if (((getPosATL _item) # 2) < -0.2 || ((getPosASL _item) # 2) < -0.2) then {
			_item setDamage 1;
		};
		sleep 170;
		_item removeEventHandler ["HandleDamage", _ffProt];
	};
	/*if ((toLower _class) in ["o_sam_system_04_f", "b_sam_system_03_f"]) then {
		[format ["WL SAM log: %1 spawned by %2 (%3) :: active SAMs: %4", _class, name player, getPlayerUID player, count (((allMissionObjects "o_sam_system_04_f") + (allMissionObjects "b_sam_system_03_f")) select {alive _x})]] remoteExec ["diag_log", 2];
		_def spawn {
			_class = typeOf _this;
			waitUntil {sleep 1; isNull _this || !alive _this};
			if (isNull _this) then {
				[format ["WL SAM log: %1 deleted :: active SAMs: %2", _class, count (((allMissionObjects "o_sam_system_04_f") + (allMissionObjects "b_sam_system_03_f")) select {alive _x})]] remoteExec ["diag_log", 2];
			} else {
				[format ["WL SAM log: %1 destroyed :: active SAMs: %2", _class, count (((allMissionObjects "o_sam_system_04_f") + (allMissionObjects "b_sam_system_03_f")) select {alive _x})]] remoteExec ["diag_log", 2];
			};
		};
	};*/
} else {
	if ((position _def) # 2 > 300) then {
		{deleteVehicle _x} forEach (position player nearObjects ["GroundWeaponHolder", 2]);
	};
	deleteVehicle _def;
	player setVariable ["BIS_WL_funds", ((player getVariable "BIS_WL_funds") + _cost) min BIS_WL_maxCP, TRUE];
	[toUpper localize "STR_A3_WL_deploy_canceled"] spawn BIS_fnc_WLSmoothText;
	playSound "AddItemFailed";
	"Canceled" call BIS_fnc_WLSoundMsg;
};

BIS_WL_currentSelection = "";

sleep 0.1;

[BIS_WL_hintPrio_deployDefence, "", -1] spawn BIS_fnc_WLshowInfo;
showCommandingMenu "";