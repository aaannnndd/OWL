#include "defines.inc"

params ["_display"];

uiNamespace setVariable ["OWL_UI_requestCooldown", serverTime];
OWL_UI_menuDummyFunds = uiNamespace getVariable ["OWL_UI_dummyFunds", 0];

private _background = _display ctrlCreate ["RscText", 98];
_background ctrlSetPosition [safezoneX, safezoneY+(safezoneH/25)*4, safezoneW, safezoneH-(safezoneH/25)*8];
_background ctrlSetBackgroundColor [BACKGROUND_COLOR];
_background ctrlCommit 0;

private _dummy_focus = _display ctrlCreate ["RscButtonMenu", 97];
_dummy_focus ctrlSetPosition [0,0,0,0];
_dummy_focus ctrlCommit 0;
uiNamespace setVariable ["OWL_UI_dummy", _dummy_focus];

OWL_IDC_COUNTER = [];
{
	_tab = _display ctrlCreate ["RscTabButton", 101+_forEachIndex];
	_tab ctrlSetPosition [safezoneX + (safezoneW / (count OWL_MENU_TABS))*_forEachIndex, safezoneY+(safezoneH/25)*3, (safezonew / (count OWL_MENU_TABS)), safezoneH/25];
	_tab ctrlSetText _x;
	_tab ctrlSetFont "PuristaMedium";
	_tab ctrlCommit 0;
	OWL_IDC_COUNTER pushBack (1000*(_forEachIndex+1));
} forEach OWL_MENU_TABS;

private _currentTab = uiNamespace getVariable ["OWL_UI_lastTab", 1];
private _ctrlButton = _display displayCtrl (100 + _currentTab);

_ctrlButton execVM "Client\GUI\WarlordsMenu\menuTabClicked.sqf";