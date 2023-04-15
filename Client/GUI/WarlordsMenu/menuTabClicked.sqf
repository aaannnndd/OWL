 #include "defines.inc"
 
 params ["_ctrlButton"];

_big = safezoneH / 25;
_small = _big*0.80;
_yc = safeZoneY + _big*3;

_display = ctrlParent _ctrlButton;
_title = _display displayCtrl 100;
_title ctrlSetText ctrlText _ctrlButton;
_pos = ctrlPosition _ctrlButton;
_ctrlButton ctrlEnable false;
_ctrlButton ctrlSetTextColor [1, 1, 1, 1];
_ctrlButton ctrlSetPosition [_pos#0, _yc, _pos#2, _big];
_ctrlButton ctrlCommit 0;
_curTab = (ctrlIDC _ctrlButton) - 100;

private _tabs = [];
{_tabs pushBack (_forEachIndex+101)} forEach OWL_MENU_TABS;

{
	_btn = _display displayCtrl _x;
	_btn ctrlEnable true;
	_btn ctrlSetBackgroundColor [TAB_UNFOCUS_COLOR];
	_pos = ctrlPosition _btn;
	_btn ctrlSetPosition [_pos#0, _yc+_big*0.20, _pos#2, _small];
	_btn ctrlSetTextColor [1, 1, 1, 0.3];
	_btn ctrlCommit 0;
} forEach (_tabs - [ctrlIDC _ctrlButton]);

private _ignore = uiNamespace getVariable ["OWL_UI_strategy_purchase_asset_controls", []];
{
	_idc = ctrlIDC _x;
	if ( _idc >= 1000) then {
		_x ctrlShow ( floor(_idc / 1000) == _curTab );
	};
} forEach (allControls _display);

uiNamespace setVariable ["OWL_UI_lastTab", _curTab];

switch (_curTab) do {
	case 1:
	{
		[_display, _curTab] execVM 'Client\GUI\WarlordsMenu\Tabs\menuTabStrategy.sqf';
	};
	case 2:
	{
		[_display, _curTab] execVM 'Client\GUI\WarlordsMenu\Tabs\menuTabAssets.sqf';
	};
	// case 3:
	// {
		// [_display, _curTab] execVM 'Client\GUI\WarlordsMenu\Tabs\menuTabAssetManagement.sqf';
	// };
	// case 4:
	// {
		// [_display, _curTab] execVM 'Client\GUI\WarlordsMenu\Tabs\menuTabCommander.sqf';
	// };
	case 3:
	{
		[_display, _curTab] execVM 'Client\GUI\WarlordsMenu\Tabs\menuTabGeneral.sqf';
	};
	// case 7:
	// {
		// [_display, _curTab] execVM 'Client\GUI\WarlordsMenu\Tabs\menuTabOptions.sqf';
	// };
};
