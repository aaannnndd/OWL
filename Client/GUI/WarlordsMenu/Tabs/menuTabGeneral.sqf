params ["_display", "_tabIdx"];

private _curIdc = _tabIdx * 1000;

if (!isNull (_display displayCtrl _curIdc)) exitWith {};

_pos = ctrlPosition (_display displayCtrl 98);
_pos params ["_xrel", "_yrel", "_wrel", "_hrel"];
_wb = _wrel / 40;
_hb = _hrel / 25;

_label = _display ctrlCreate ["RscStructuredText", _curIdc+0];
_label ctrlSetPosition [_xrel+_wb*0.5, _yrel+_hb*2, _wb*9.5, _hb*1.25];
_label ctrlSetStructuredText parseText "<t size='1' align='center' valign='middle'>Whatever</t>";
_label ctrlCommit 0;

_button = _display ctrlCreate ["RscButtonMenu", _tabIdx call OWL_fnc_TabIDC];
_button ctrlSetText "Place me in aircraft";
_button ctrlSetPosition [_xrel+_wb*0.5, _yrel+_hb*3, _wb*8, _hb*2];
_button ctrlCommit 0;

private _jets = [
	"I_Plane_Fighter_03_dynamicloadout_F",
	"I_Plane_Fighter_04_F",
	"O_Plane_CAS_02_dynamicLoadout_F",
	"O_Plane_Fighter_02_F",
	"O_T_VTOL_02_infantry_dynamicLoadout_F",
	"B_Plane_CAS_01_dynamicLoadout_F",
	"B_Plane_Fighter_01_F"];

_list = _display ctrlCreate ["RscListBox", _tabIdx call OWL_fnc_TabIDC];
_list ctrlSetPosition [_xrel+_wb*0.5, _yrel+_hb*5, _wb*8, _hb*14];
{
	_list lbAdd getText (configFile >> "CfgVehicles" >> _x >> "displayName");
	_list lbSetValue [(lbSize _list) - 1, _forEachIndex];
	_list lbSetData [(lbSize _list) - 1, _x];
} forEach _jets;
_list ctrlCommit 0;

uiNamespace setVariable ["OWL_UI_General_list", _list];

_button ctrlAddEventHandler ["ButtonClick", {
	private _list = uiNamespace getVariable ["OWL_UI_General_list", controlNull];
	_cur = lbCurSel _list;
	private _data = _list lbData _cur;

	if (_data != "") then {
		if (vehicle player != player) then {
			private _t = vehicle player;
			moveOut player;
			deleteVehicle _t;
		};

		player moveInDriver createVehicle [_data, ((position player) vectorAdd [0,0,200]), [], 0, "FLY"];
		if(_data == "O_T_VTOL_02_infantry_dynamicLoadout_F") then {
			_pilot = (group player) createUnit [format ["%1_Pilot_F", if (side player == WEST) then {"B"} else {"O"}], position player, [], 0, "FORM"];
			_pilot moveInGunner (vehicle player);
		};
		(vehicle player) setPosATL _pos; 
		(vehicle player) setDir _dir;
		(vehicle player) setVelocityModelSpace [0,194,0];
	};
}];