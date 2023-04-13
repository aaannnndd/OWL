#include "..\defines.hpp"

params ["_sound"];

// Add option to enable announcer?... just exitWith nothing here.

private _delayTimestamp = missionNamespace getVariable ["OWL_soundQueueDelay", time];
private _diffTime = _delayTimestamp - time;
private _length = getNumber (configFile >> "CfgSounds" >> _sound >> "duration");
if (_length == 0) then {_length = 2};

if (_diffTime > 0) exitWith {
	[_sound, _diffTime] spawn {
		params ["_sound", "_diffTime"];
		sleep _diffTime;
		playSound _sound;
	};

	OWL_soundQueueDelay = time + _length + _diffTime;
};

playSound _sound;
OWL_soundQueueDelay = time + _length;
