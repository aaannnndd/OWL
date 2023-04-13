
private _sectorArea = _this getVariable "OWL_sectorArea";
private _sectorPos = _sectorArea # 0;

// Find the nearest location with text 
private _nearestLocCfg = configNull;
private _nearestDist = -log 0;
{
	if (getText (_x >> "name") == "") then { continue; };
	
	private _dist = (getArray (_x >> "position")) distance2D _sectorPos;
	if (_dist < _nearestDist) then {
		_nearestLocCfg = _x;
		_nearestDist = _dist;
	};
} forEach ("true" configClasses (configFile >> "CfgWorlds" >> worldName >> "Names"));

// Return grid position if no suitable location exists
if (isNull _nearestLocCfg) exitWith {
	format [localize "STR_A3_BIS_fnc_locationDescription_grid", mapGridPosition _sectorPos];
};

// Capitalizing first letter of the name
forceUnicode 0;
private _name = getText (_nearestLocCfg >> "name");
private _firstLetter = _name select [0, 1];
_firstLetter = toUpper _firstLetter;
_name = _firstLetter + (_name select [1]);
forceUnicode -1;

private _locPos = getArray (_nearestLocCfg >> "position");
private _borderSize = _this getVariable "OWL_sectorParam_borderSize";

// Return location name if location is close
if (_locPos inArea [_sectorArea#0, _sectorArea#1 + _borderSize, _sectorArea#2 + _borderSize, _sectorArea#3, _sectorArea#4]) then {
	_name
}
else {	// Otherwise return location name with heading
	format [
		localize (switch (round ((_locPos getDir _sectorPos) % 360 / 45)) do 
		{
			default {"STR_A3_BIS_fnc_locationDescription_n"};
			case 1: {"STR_A3_BIS_fnc_locationDescription_ne"};
			case 2: {"STR_A3_BIS_fnc_locationDescription_e"};
			case 3: {"STR_A3_BIS_fnc_locationDescription_se"};
			case 4: {"STR_A3_BIS_fnc_locationDescription_s"};
			case 5: {"STR_A3_BIS_fnc_locationDescription_sw"};
			case 6: {"STR_A3_BIS_fnc_locationDescription_w"};
			case 7: {"STR_A3_BIS_fnc_locationDescription_nw"};
		}), 
		_name
	]
};
