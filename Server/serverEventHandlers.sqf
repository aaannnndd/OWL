/* All event handlers on the SERVER SIDE */

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
		_info set [2, [], side group _player];

		OWL_persistentData set [_uid, _info];
		[str _info] call OWL_fnc_log;
	};

	OWL_allWarlords deleteAt _owner;
}];

addMissionEventHandler ["OnUserClientStateChanged", {
	params ["_networkId", "_clientStateNumber", "_clientState"];

	[(str _this)] call OWL_fnc_log;
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
}];

addMissionEventHandler ["Ended", {
	params ["_endType"];

	saveProfileNamespace;
}];