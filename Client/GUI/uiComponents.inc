#include "\a3\ui_f\hpp\defineCommonGrids.inc"
#include "\a3\ui_f\hpp\defineCommon.inc"
#include "defines.inc"

import RscControlsGroup;
import RscStructuredText;
import RscText;
import RscMap;
import RscButton;
import RscProgress;
import RscListBox;
import RscListNBox;

class RscCustomMap: RscMap
{
	idd = -1;
};

class RscTabButton: RscButton
{
	colorBackground[] = {TAB_UNFOCUS_COLOR};
	colorFocused[] = {TAB_UNFOCUS_COLOR};
	colorFocused2[] =  {TAB_UNFOCUS_COLOR};
	colorBackgroundActive[] = {TAB_UNFOCUS_COLOR};
	colorDisabled[] = {1,1,1,1};
	colorBackgroundDisabled[] = {BACKGROUND_COLOR};
	colorText[] = {1, 1, 1, 0.3};
	onButtonClick = "_this execVM 'Client\GUI\WarlordsMenu\menuTabClicked.sqf'";
};

class RscMenuTitle: RscText
{
	idc = -1;
	text = "";
	x = GUI_GRID_CENTER_X+GUI_GRID_CENTER_W*15;
	y = GUI_GRID_CENTER_Y+GUI_GRID_CENTER_H;
	w = GUI_GRID_CENTER_W*10;
	h = GUI_GRID_CENTER_H*1.5;
	sizeEx = GUI_TEXT_SIZE_LARGE;
	colorText[] = {1, 1, 1, 0.9};
	colorBackground[] = {0,0,0,0};
	style = 2;
};

class RscTabbedMenu
{
	idd = 10655;
	onLoad = "_this execVM 'Client\GUI\WarlordsMenu\menuOpened.sqf'";
};

class RscListNBoxFix: RscListNBox
{
	colorPicture[] = {1,1,1,1};
	colorPictureSelected[] = {1,1,1,1};
	colorPictureDisabled[] = {1,1,1,1};
};

class RscScoreboardMenu
{
	idd = 10656;
	onLoad = "_this execVM 'Client\GUI\SCOREBOARD_OPEN.SQF'";
};

class RscProgressVertical: RscProgress
{
	idc = -1;
	style = 0x01;
};

class RscTitles
{
	class OWL_RscMapTooltip
	{
		idd = 4000;
		onLoad = "uiNamespace setVariable ['OWL_RscMapTooltip', _this select 0];";
		duration = 1e+011;
		fadeIn = 0;
		fadeOut = 1;
		class Controls
		{
			class CenterText: RscStructuredText
			{
				text = "This text box will stay here for 10 seconds. You can still move and look around.";
				x = GUI_GRID_CENTER_X + 40 * GUI_GRID_CENTER_W;
				y = GUI_GRID_CENTER_Y + 2 * GUI_GRID_CENTER_H;
				w = 10 * GUI_GRID_CENTER_W;
				h = 12 * GUI_GRID_CENTER_H;
				colorBackground[] = {0,0,0,0.8};
			};
		};
	};

	class OWL_RscMainHUD
	{
		idd = 61466;
		fadein = 0;
		fadeout = 1;
		duration = 1e+011;
		onLoad = "_this execVM 'Client\GUI\initHUD.sqf'";
	};
};