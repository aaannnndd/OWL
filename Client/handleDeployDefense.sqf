params ["_class"];

// Create local object
private _def = createSimpleObject [_class, getPosWorld player, TRUE];
private _bbox = boundingBoxReal _def;
private _offset = [0, (_bbox#1#1)*1.35, 0];

// TODO: HELPER BEGIN 
// REMOVE ONCE DEVELOPMENT IS DONE
// makes it too easy to see how you need to position objects to get them in bad places
OWL_defenseVisualLines = [];
for "_i" from 0 to 35 do {OWL_defenseVisualLines pushBack [0,0,0]};

OWL_defenceDrawEH = missionNamespace getVariable ["OWL_defenceDrawEH", -1];
if (OWL_defenceDrawEH != -1) then {
	removeMissionEventHandler["draw3D", OWL_defenceDrawEH];
};

OWL_defenceDrawEH = addMissionEventHandler ["draw3D",
{
	{
		drawLine3D [ASLToAGL (_x#0), ASLToAGL (_x#1), [1,0,1,0.7]
		];
	} forEach OWL_defenseVisualLines;
}];
// TODO: DEV HELPER END


// TODO: add 'press space' thing. Currently just sets it after 20 seconds
[_def, _offset] spawn {
	params ["_def", "_offset"];
	private _time = serverTime + 20;

	while {!isNull _def && _time > serverTime} do {
		_def setDir direction player;
		private _npos = [getPosASL player, _offset # 1, direction player] call BIS_fnc_relPos;
		_npos = ASLToATL _npos;
		_def setPosATL [_npos#0, _npos#1, 0];
		
		if (!(_def call OWL_fnc_validateObjectPlacement)) then {
			[toUpper localize "STR_A3_WL_deploy_canceled"] spawn BIS_fnc_WLSmoothText;
			playSound "AddItemFailed";
			deleteVehicle _def;
			break;
		};

		sleep 0.01;
	};

	if (!isNull _def) then {
		private _info = [(typeOf _def), getPosASL _def, getDir _def];
		deleteVehicle _def;
		systemChat str _info;
		_info remoteExec ["OWL_fnc_crDeployDefense", 2];
	};
};