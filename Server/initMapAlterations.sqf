// When you need to simulate heavy CPU load on the server, this is good to use.

private _list = nearestObjects [ [15000,15000,0] , [], 20000];

{
	_stringInterpretation = str _x;
	_obj = _x;
	{
		if (_x in _stringInterpretation) then {
			hideObjectGlobal _obj;
		};
	} forEach ["b_ficusc2d_f.p3d", "wired_fence_8m_f.p3d", "wired_fence_4m_f.p3d","powerpolewooden_small_f.p3d","powerpolewooden_f.p3d"];
																																																					
	if ( (typeOf _x) in ["Land_HighVoltageColumn_F", "Land_HighVoltageColumnWire_F", "Land_HighVoltageTower_large_F", "Land_PowerWireBig_direct_F","Land_PowerWireBig_direct_short_f","Land_PowerWireBig_end_F", "Land_PowerWireBig_direct_short_F", "Land_HighVoltageTower_largeCorner_F", "Land_PowerWireBig_right_F", "Land_PowerWireBig_left_F"] ) then { 
    	hideObjectGlobal _x; 
	};

} forEach _list;

/* "Land_spp_Mirror_F", "mil_wiredfence_f.p3d", "mil_wiredfenced_f.p3d"
This is if we want to re-do MPP to be more infantry friendly.
{
	_strInterp = str _x;
	if ("mil_wiredfence_f.p3d" in _strInterp || "mil_wiredfenced_f.p3d" in _strInterp) then {
		hideObjectGlobal _x;
	};
	if ( (typeOf _x) in ["Land_spp_Mirror_F"] ) then { 
    	hideObjectGlobal _x; 
	};
} forEach _list;*/
