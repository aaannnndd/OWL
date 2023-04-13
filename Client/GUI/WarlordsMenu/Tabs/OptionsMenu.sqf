params ["_display", "_tabIdx"];


if (!isNull (_display displayCtrl _tabIdx * 1000)) exitWith {};

_pos = ctrlPosition (_display displayCtrl 98);
_pos params ["_xrel", "_yrel", "_wrel", "_hrel"];
_wb = _wrel / 40;
_hb = _hrel / 25;

