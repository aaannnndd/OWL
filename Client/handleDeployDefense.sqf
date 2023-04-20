/*
WARLORDS-SPECIFIC FUNCTION

Author: Josef Zem�nek

Description: Requested static weapon positionining routine.
*/

params ["_class"];

// Create local object
private _def = createSimpleObject [_class, getPosWorld player, TRUE];
private _bbox = boundingBoxReal _def;
private _offset = [0, (_bbox#1#1)*1.35, 0];

// this is just to visual ingame (TODO remove once development is done)
OWL_defenseVisualLines = [];
for "_i" from 0 to 15 do {OWL_defenseVisualLines pushBack [0,0,0]};

OWL_defenceDrawEH = missionNamespace getVariable ["OWL_defenceDrawEH", -1];
if (OWL_defenceDrawEH != -1) then {
	removeMissionEventHandler["draw3D", OWL_defenceDrawEH];
};

OWL_defenceDrawEH = addMissionEventHandler ["draw3D",
{
	{
		drawLine3D [ASLToAGL (_x#0), ASLToAGL (_x#1), [1,0,1,1]
		];
	} forEach OWL_defenseVisualLines;
}];

[_def, _offset] spawn {
	params ["_def", "_offset"];
	private _time = serverTime + 20;

	while {!isNull _def && _time > serverTime} do {
		_def setDir direction player;
		private _npos = [getPosASL player, _offset # 1, direction player] call BIS_fnc_relPos;
		_npos = ASLToATL _npos;
		_def setPosATL [_npos#0, _npos#1, 0];
		
		if (!(_def call OWL_fnc_validateObjectPlacement)) then {
			playSound "AddItemFailed";
			deleteVehicle _def;
		};

		sleep 0.01;
	};

	if (!isNull _def) then {
		private _info = [(typeOf _def), getPosATL _def, getDir _def];
		deleteVehicle _def;
		systemChat str _info;
		_info remoteExec ["OWL_fnc_crDeployDefense", 2];
	};
};

/*

// this is just to visual ingame
OWL_LINES = [];
for "_i" from 0 to 11 do {OWL_LINES pushBack [0,0,0]};

OWL_defenceDrawEH = missionNamespace getVariable ["OWL_defenceDrawEH", -1];
if (OWL_defenceDrawEH != -1) then {
	removeMissionEventHandler["draw3D", OWL_defenceDrawEH];
};

OWL_defenceDrawEH = addMissionEventHandler ["draw3D",
{
	{
		drawLine3D [ASLToAGL (_x#0), ASLToAGL (_x#1), [1,0,1,1]
		];
	} forEach OWL_LINES;
}];

_lines pushBack [_corners#0, _corners#1];	// b tr -> b br	
_lines pushBack [_corners#0, _corners#3];	// b tr -> b tl
_lines pushBack [_corners#2, _corners#3];	// b bl -> b tl
_lines pushBack [_corners#2, _corners#1];	// b bl -> b br
_lines pushBack [_corners#4, _corners#5];	// t tr -> t br 
_lines pushBack [_corners#4, _corners#7];	// t tr -> t tl
_lines pushBack [_corners#6, _corners#7];	// t bl -> t tl
_lines pushBack [_corners#6, _corners#5];	// t bl -> t br
_lines pushBack [_corners#0, _corners#4];	// b tr -> t tr
_lines pushBack [_corners#1, _corners#5];	// b br -> t br
_lines pushBack [_corners#2, _corners#6];	// b bl -> t bl
_lines pushBack [_corners#3, _corners#7];	// b tl -> t tl
 */