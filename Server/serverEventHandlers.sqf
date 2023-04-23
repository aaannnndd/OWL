/* All event handlers on the SERVER SIDE */
// TODO: swap this to 'clientStateChanged' since you can team switch and zzzz
addMissionEventHandler ["PlayerDisconnected", {
	params ["_id", "_uid", "_name", "_jip", "_owner", "_idstr"];

	private _info = OWL_allWarlords getOrDefault [_owner, [0, [], []]];
	if (count _info > 0) then {

		private _squadMembers = _info # 2;
		{
			if (!isNull _x) then {
				private _grp = group _x;
				deleteVehicle _x;

				if (!isNull (_grp) && (count (units _grp) == 0)) then {
					deleteGroup _grp;
				};
			};

		} forEach _squadMembers;
		_info set [2, []];

		_persistentData set [_uid, _info];
	};

	OWL_allWarlords deleteAt _owner;
}];

addMissionEventHandler ["OnUserClientStateChanged", {
	params ["_networkId", "_clientStateNumber", "_clientState"];

	systemChat str _this;
}];

addMissionEventHandler ["EntityRespawned", {
	params ["_unit", "_corpse"];

	// Limit to only one old corpse per player
	if (isPlayer _unit) then {
		private _oldCorpse = _corpse getVariable ["OWL_oldCorpse", objNull];
		_unit setVariable ["OWL_oldCorpse", _corpse];
		if (!isNull _oldCorpse) then {
			deleteVehicle _oldCorpse;
		};

		_unit setVariable ["OWL_killTimer", nil];
	};
}];

OWL_fnc_registerVehicleDatalink = {
	params ["_vehicle"];

	_vehicle setVehicleReportOwnPosition true;
	_vehicle setVehicleReportRemoteTargets true;
	_vehicle setVehicleReceiveRemoteTargets true;
};

addMissionEventHandler ["EntityCreated", {
	params ["_entity"];
	
	switch (typeOf _entity) do {
		case "B_MBT_01_TUSK_F":
		{
			_entity setMass 30000;
			_entity addWeaponTurret ["SmokeLauncher", [-1]];
			_entity addMagazineTurret ["SmokeLauncherMag", [-1]];
			_entity loadMagazine [[-1], "SmokeLauncher", "SmokeLauncherMag"];
		};
	};

	/*
		_objType = (typeOf cursorObject); 
		_colorName = ["Olive", "Indep_Olive"] # (["BLU_F", "IND_F"] find getText (configFile >> "CfgVehicles" >> _objType >> "faction"));
		systemChat str _colorName;
		_hidSel = getArray (configFile >> "CfgVehicles" >> _objType >> "TextureSources" >> _colorName >> "textures"); 
		{ 
			cursorObject setObjectTextureGlobal [_forEachIndex, _x]; 
		} forEach _hidSel; 

		// for kuma [cursorObject, false, ["showCamonetHull",1,"showCamonetTurret",1, "showCamonetCannon", 1, "showCamonetCannon1", 1]] call BIS_fnc_initVehicle;
	*/

	// if faction == "IND_F" / "BLU_T_F"
	// _textSel = "Indep_Olive" / "Olive"
}];