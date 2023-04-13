#include "defines.inc"

params ["_display"];

/*private _playerlist = _display ctrlCreate ["RscListNBoxFix", -1];
_playerlist ctrlSetPosition [safezoneX, safezoneY+(safezoneH/25)*4, safezoneW, safezoneH-(safezoneH/25)*8];

{
	_playerlist lnbAddRow [getText (_x >> "displayNameShort"), getText (_x >> "displayName")];
	_playerlist lnbSetPicture [[_foreachIndex, 0],getText (_x >> "texture")];
} forEach ("true" configClasses (configFile >> "CfgRanks"));
_playerlist lnbSetCurSelRow 0;

_playerlist ctrlSetBackgroundColor [1,1,1,1];
_playerlist ctrlCommit 0;*/

OWL_fnc_customGradient = {
	params ["_display", "_pos", "_colorStart", "_colorEnd", ["_hidden", false]];
	_pos params ["_xrel", "_yrel", "_width", "_height"];
	private _pixel = safeZoneW/(getResolution#0);
	private _num = floor (_width / _pixel);
	private _ctrlList = [];
	for "_i" from 1 to _num do {
		private _ctrl = _display ctrlCreate ["RscText", -1];
		private _ratio = _i / _num;
		private _color = ((_colorEnd vectorDiff _colorStart) vectorMultiply _ratio) vectorAdd _colorStart;
		if (_hidden) then {
			_color = [0,0,0,0];
		};
		_ctrl ctrlSetBackgroundColor _color;
		_ctrl ctrlSetPosition [_xrel+_pixel*_i, _yrel, _pixel, _height];
		_ctrl ctrlCommit 0;
		_ctrlList pushBack _ctrl;
	};
	[_pos, _colorStart, _colorEnd, _ctrlList];
};

OWL_fnc_customProgressBar = {
	params ["_display", "_pos", "_progress"];

	private _left  = _display ctrlCreate ["RscText", -1];
	private _right = _display ctrlCreate ["RscText", -1];

	_left setVariable ["OWL_posDefault", _pos];
	_left setVariable ["OWL_progress", _progress];

	_left ctrlSetPosition [_pos#0,_pos#1, _pos#2 * _progress, _pos#3];
	_right ctrlSetPosition [_pos#0+(_pos#2)*_progress, _pos#1, (1-_progress)*(_pos#2), _pos#3];

	_left ctrlSetBackgroundColor [0.8,0.1,0.1,0.9];
	_right ctrlSetBackgroundColor [0,0,0.8,0.9];

	_left ctrlCommit 0;
	_right ctrlCommit 0;

	[_left, _right];
};

#define SWAY_LEFT 1
#define SWAY_RIGHT 2
#define SWAY_NONE 3

OWL_fnc_setProgress = {
	params ["_progressBar", "_progress", ["_sway", 0]];
	_progressBar params ["_left", "_right", "_sway"];
	private _prevProg = _left getVariable ["OWL_progress", 1];
	private _pos = _left getVariable ["OWL_posDefault", []];

	if (count _pos == 0) exitWith {
		systemChat "controlDeleted";
	};

	switch (_sway) do {
		case SWAY_LEFT: {
			_left setVariable ["OWL_rizz", OWL_fnc_gradientRizz];
		};
		case SWAY_RIGHT: {
			_left setVariable ["OWL_rizz", OWL_fnc_gradientRizzReverse];
		};
		case SWAY_NONE:{
			_left setVariable ["OWL_rizz", OWL_fnc_gradientNoRizz];
		};
	};

	_left setVariable ["OWL_progress", _progress];
	_left ctrlSetPosition [_pos#0,_pos#1, _pos#2 * _progress, _pos#3];
	_right ctrlSetPosition [_pos#0+(_pos#2)*_progress, _pos#1, (1-_progress)*(_pos#2), _pos#3];
	_left ctrlCommit 0;
	_right ctrlCommit 0;
};

_progbar = [_display, [safeZoneX, safeZoneY, safezoneW/5, safezoneH/25], 0.75] call OWL_fnc_customProgressBar;

OWL_fnc_gradientNoRizz = {
	params ["_pos", "_colorStart", "_colorEnd", "_ctrls", "_cutoff"];
	_ctrls apply {_x ctrlSetBackgroundColor [0,0,0,0]; _x ctrlCommit 0;};
};

OWL_fnc_gradientRizz = {
	params ["_pos", "_colorStart", "_colorEnd", "_ctrls", "_cutoff"];
	_pos params ["_xrel", "_yrel", "_width", "_height"];

	private _pct = (time % 1) / 1;
	private _num = count _ctrls;
	private _oth = floor (_num*_pct*_cutoff);
	if (_oth > 0) then {
		for "_i" from 0 to _oth do {
			private _color = ((_colorEnd vectorDiff _colorStart) vectorMultiply (_i/_oth)) vectorAdd _colorStart;
			(_ctrls # _i) ctrlSetBackgroundColor _color;
			(_ctrls # _i) ctrlCommit 0;
		};
	};
	for "_i" from _oth+1 to _num-1 do {
		(_ctrls # _i) ctrlSetBackgroundColor [0,0,0,0];
		(_ctrls # _i) ctrlCommit 0;
	};
};

OWL_fnc_gradientRizzReverse = {
	params ["_pos", "_colorStart", "_colorEnd", "_ctrls", "_cutoff"];
	_pos params ["_xrel", "_yrel", "_width", "_height"];

	private _pct = (time % 1) / 1;
	private _num = count _ctrls;
	private _oth = floor (_num*_cutoff);
	_oth = _oth + (_num-_oth)*(1-_pct);

	for "_i" from (_num) to (_oth+1) step -1 do {
		private _ratio = (_num-1-_i) / (_num-_oth);
		private _color = ((_colorEnd vectorDiff _colorStart) vectorMultiply (_ratio)) vectorAdd _colorStart;
		(_ctrls # _i) ctrlSetBackgroundColor _color;
		(_ctrls # _i) ctrlCommit 0;
	};

	for "_i" from 0 to _oth do {
		(_ctrls # _i) ctrlSetBackgroundColor [0,0,0,0];
		(_ctrls # _i) ctrlCommit 0;		
	};
};

_gradient = [_display,  [safeZoneX, safeZoneY, safezoneW/5, safezoneH/25], [1,1,1,0], [1,1,1,0.25], true] call OWL_fnc_customGradient;

[_progbar, _gradient] spawn {
	params ["_progbar", "_gradient"];
	sleep 0.01;
	private _prog = 0;
	private _tmr = time+5;
	private _xx = 1;
	private _sway = 1;
	while {TRUE && !isNull(_gradient#3#0)} do {
		if (_tmr - time < 0) then {
			if (_prog == 0.5 || _prog == 0) then {
				_xx = _xx*-1;
			};
			_prog = 0.5 min (_prog + 0.1*_xx);
			_prog = 0 max _prog;
			_tmr = time + 5;
			[_progbar, _prog, _sway] call OWL_fnc_setProgress;
		};
		(_gradient+[_prog]) call ((_progbar#0) getVariable ["OWL_rizz", OWL_fnc_gradientNoRizz]);
	};
};


