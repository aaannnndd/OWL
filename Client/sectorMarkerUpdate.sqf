params ["_sector"];

OWL_sectorIcon = "\A3\ui_f\data\map\markers\nato\o_installation.paa";
OWL_sectorIconMarker = "o_installation";
OWL_baseIcon = "\A3\ui_f\data\map\markers\nato\b_hq.paa";
OWL_baseIconMarker = "b_hq";

private _isBase = _sector in OWL_mainBases;
private _sectorIcon = if (_isBase) then {OWL_baseIconMarker} else {OWL_sectorIconMarker};

private _sectorIndex = _sector getVariable "OWL_sectorIndex";
private _sectorArea = _sector getVariable "OWL_sectorArea";
private _sectorPos  = getPosATL _sector;
private _markerColor = ["ColorWEST", "ColorEAST", "ColorGUER"] # ([WEST, EAST, RESISTANCE] find (_sector getVariable "OWL_sectorSide"));
private _sectorMarkers = _sector getVariable ["OWL_sectorMarkers",[]];
private _showBorder = (_sector getVariable "OWL_sectorProtected") && (_sector getVariable "OWL_sectorSide" != playerSide) && (_sector != OWL_contestedSector # (OWL_competingSides find playerSide));

if (count _sectorMarkers > 0) exitWith {
	{
		_x setMarkerColorLocal _markerColor;
		if ( "OuterBorder" in _x) then {
			_x setMarkerAlpha (if(_showBorder) then {0.35} else {0});
		};
	} forEach _sectorMarkers;
};

private _markerIcon = format ["OWL_sectorMarkerIcon_%1", _sectorIndex];
createMarkerLocal [_markerIcon, getPosATL _sector];
_markerIcon setMarkerTypeLocal (_sectorIcon);
_markerIcon setMarkerSizeLocal [1, 1];
_markerIcon setMarkerColorLocal _markerColor;
_markerIcon setMarkerAlphaLocal 1;
_sectorMarkers pushBack _markerIcon;

private _markerBorderLine = format ["OWL_sectorMarkerBorderLine_%1", _sectorIndex];
createMarkerLocal [_markerBorderLine, getPosATL _sector];
_markerBorderLine setMarkerShapeLocal ("RECTANGLE");
_markerBorderLine setMarkerBrushLocal "Border";
_markerBorderLine setMarkerSizeLocal [_sectorArea#0, _sectorArea#1];
_markerBorderLine setMarkerColorLocal _markerColor;
_markerBorderLine setMarkerAlphaLocal 1;
_sectorMarkers pushBack _markerBorderLine;

private _borderSize = (_sector getVariable "OWL_sectorParam_borderSize");
private _halfBorderSize = _borderSize / 2;
_cx = _sectorPos # 0;
_cy = _sectorPos # 1;
{
	_px = _cx + (_x#0)*(_halfBorderSize + (_x#2)*(_sectorArea#0));
	_py = _cy + (_x#1)*(_halfBorderSize + (_x#3)*(_sectorArea#1));
	_ax = _halfBorderSize + (_x#3)*(_sectorArea#0);
	_ay = _halfBorderSize + (_x#2)*(_sectorArea#1);
	private _marker = format ["OWL_sectorMarkerOuterBorder_%1_%2", _sectorIndex, _forEachIndex];
	createMarkerLocal [_marker, [_px, _py]];
	_marker setMarkerSizeLocal [_ax, _ay];
	_marker setMarkerColorLocal _markerColor;
	_marker setMarkerAlphaLocal (if (_sector getVariable "OWL_sectorSide" == playerSide) then {0.175} else {0.35});
	_marker setMarkerBrushLocal "Solid";
	_marker setMarkerShapeLocal "RECTANGLE";
	
	_sectorMarkers pushBack _marker;
} forEach [ [1,1,0,1], [1,-1,1,0], [-1,1,1,0], [-1,-1,0,1] ];

_sector setVariable ["OWL_sectorMarkers", _sectorMarkers];