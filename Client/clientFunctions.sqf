/*
	Generic gameplay functions on the client. If client is trusted with any gameplay related functionality it will be in here.

	If someone wants to hack to lock everyones vehicles....................
*/

OWL_fnc_vehicleLockOnAction = {
	params ["_asset", "_player", "_actionId", "_arguments"];

	_asset lock abs (locked _asset - 2);
	_asset setUserActionText [_actionId, if (locked _asset == 2) then {localize "STR_A3_cfgvehicles_miscunlock_f_0"} else {localize "STR_A3_cfgvehicles_misclock_f_0"}];
};

OWL_fnc_squadRemoveAssetOnAction = {
	params ["_asset", "_player", "_actionId", "_arguments"];

	_asset remoteExec ["OWL_fnc_crRemoveAsset", 2];
};

OWL_fnc_newAssetAddedToPlayer = {
	params ["_asset"];

	if (toLower getText (configFile >> "CfgVehicles" >> typeOf _asset >> "vehicleClass") != "ammo") then {
		_asset lock 2;
		_asset addAction [if (locked _asset == 2) then {localize "STR_A3_cfgvehicles_miscunlock_f_0"} else {localize "STR_A3_cfgvehicles_misclock_f_0"}, OWL_fnc_vehicleLockOnAction,[],-19,false,true,"","",50,false,"",""];
	};

	if (_asset isKindOf "Man") then {
		_asset addAction ["Dismiss subordinate", OWL_fnc_squadRemoveAssetOnAction, [],-19,false,true,"","",50,false,"",""];
	} else {
		_asset addAction ["Remove Asset", OWL_fnc_squadRemoveAssetOnAction, [],-19,false,true,"","",50,false,"",""];
	};
};