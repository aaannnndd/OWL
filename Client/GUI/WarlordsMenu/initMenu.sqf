/*
   Init functions here so null functions aren't being called when UI updates if the player hasn't opened their menu yet.
   Will use execVM "FileName.sqf" while in development for realtime editing/updates.
*/

OWL_UI_menuTabClicked = compileFinal preprocessFileLineNumbers "Client\GUI\WarlordsMenu\menuTabClicked.sqf";

OWL_UI_menuTabAssetManagement = compileFinal preprocessFileLineNumbers "Client\GUI\WarlordsMenu\Tabs\menuTabAssetManagement.sqf";
OWL_UI_menuTabAssets = compileFinal preprocessFileLineNumbers "Client\GUI\WarlordsMenu\Tabs\menuTabAssets.sqf";
OWL_UI_menuTabCommander = compileFinal preprocessFileLineNumbers "Client\GUI\WarlordsMenu\Tabs\menuTabCommander.sqf";
OWL_UI_menuTabGeneral = compileFinal preprocessFileLineNumbers "Client\GUI\WarlordsMenu\Tabs\menuTabGeneral.sqf";
OWL_UI_menuTabOptions = compileFinal preprocessFileLineNumbers "Client\GUI\WarlordsMenu\Tabs\menuTabOptions.sqf";
OWL_UI_menuTabStrategy = compileFinal preprocessFileLineNumbers "Client\GUI\WarlordsMenu\Tabs\menuTabStrategy.sqf";

uiNamespace setVariable ["OWL_UI_lastTab", 1];

// TODO clean this up
OWL_ASSET_LIST = createHashMap;
OWL_ASSET_INFO = createHashMap;

OWL_MENU_TABS = [
	"Strategy",
	"Assets",
	"Free Jets"
];

OWL_fnc_TabIDC = {
	params ["_curTab"];
	OWL_IDC_COUNTER set [_curTab-1, (OWL_IDC_COUNTER select (_curTab-1))+1];
	(OWL_IDC_COUNTER select _curTab-1)-1;
};