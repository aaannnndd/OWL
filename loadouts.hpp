class CfgRoles
{
	class Commander
	{
		displayName = "Commander";
		icon = "a3\Ui_f\data\GUI\Cfg\Ranks\general_gs.paa";
	};
	class SquadLeader
	{
		displayName = "Squad Leader";
		icon = "a3\Ui_f\data\GUI\Cfg\Ranks\major_gs.paa";
	};
	class Assault
	{
		displayName = "Assault";
		icon = "a3\ui_f\data\map\vehicleicons\iconManMG_ca.paa";	
	};
	class Medic
	{
		displayName = "Medic";
		icon = "a3\ui_f\data\map\vehicleicons\iconManMedic_ca.paa";	
	};
	class Recon
	{
		displayName = "Recon";
		icon = "a3\ui_f\data\map\vehicleicons\iconManRecon_ca.paa";	
	};
	class Engineer
	{
		displayName = "Engineer";
		icon = "a3\ui_f\data\map\vehicleicons\iconManEngineer_ca.paa";	
	};
	class AntiVehicleSpecialist
	{
		displayName = "Anti Vehicle";
		icon = "a3\ui_f\data\map\vehicleicons\iconManAT_ca.paa";	
	};
};

class CfgRespawnInventory
{
	class B_Commander
	{
		displayName = "Commander";
		role = "Commander";
		icon = "\A3\ui_f\data\map\VehicleIcons\iconManLeader_ca.paa";
		weapons[] = {
			"arifle_MX_F",
			"Binocular",
			"hgun_P07_F"
		};
		magazines[] = {
			"SmokeShell",
			"SmokeShellGreen",
			"SmokeShellOrange",
			"16Rnd_9x21_Mag",
			"16Rnd_9x21_Mag",
			"30Rnd_65x39_caseless_mag",
			"30Rnd_65x39_caseless_mag",
			"30Rnd_65x39_caseless_mag",
			"30Rnd_65x39_caseless_mag",
			"30Rnd_65x39_caseless_mag",
			"30Rnd_65x39_caseless_mag",
			"30Rnd_65x39_caseless_mag",
			"HandGrenade",
			"HandGrenade"
		};
		items[] = {
			"FirstAidKit"
		};
		linkedItems[] = {
			"V_PlateCarrierGL_rgr",
			"H_HelmetB_desert",
			"optic_Hamr",
			"acc_pointer_IR",
			"NVGoggles",
			"B_UavTerminal",
			"ItemMap",
			"ItemCompass",
			"ItemWatch",
			"ItemRadio"
		};
		uniformClass = "U_B_CombatUniform_mcam_vest";
	};
	class O_Commander // Class of the respawn inventory, used by BIS_fnc_addRespawnInventory
	{
		displayName = "Commander";
		role = "Commander";
		icon = "\A3\ui_f\data\map\VehicleIcons\iconManLeader_ca.paa";
		weapons[] = {
			"arifle_Katiba_F",
			"Binocular",
			"hgun_Rook40_F"
		};
		magazines[] = {
			"SmokeShell",
			"SmokeShell",
			"16Rnd_9x21_Mag",
			"16Rnd_9x21_Mag",
			"16Rnd_9x21_Mag",
			"30Rnd_65x39_caseless_green",
			"30Rnd_65x39_caseless_green",
			"30Rnd_65x39_caseless_green",
			"30Rnd_65x39_caseless_green",
			"30Rnd_65x39_caseless_green",
			"30Rnd_65x39_caseless_green",
			"30Rnd_65x39_caseless_green",
			"30Rnd_65x39_caseless_green",
			"HandGrenade",
			"HandGrenade"
		};
		items[] = {
			"FirstAidKit"
		};
		linkedItems[] = {
			"V_TacVest_khk",
			"H_HelmetLeaderO_ocamo",
			"optic_Arco_blk_F",
			"acc_pointer_IR",
			"NVGoggles_OPFOR",
			"O_UavTerminal",
			"ItemMap",
			"ItemCompass",
			"ItemWatch",
			"ItemRadio"
		};
		uniformClass = "U_O_CombatUniform_ocamo";
	};
	
	class B_SquadLeader // Class of the respawn inventory, used by BIS_fnc_addRespawnInventory
	{
		displayName = "Squad Leader"; // Name of the respawn inventory
		role = "SquadLeader"; // Role the respawn inventory is assigned to
		icon = "\A3\ui_f\data\map\VehicleIcons\iconManLeader_ca.paa"; // Icon shown next to the role
		weapons[] = {
			"arifle_MX_F",
			"Binocular",
			"hgun_P07_F"
		};
		magazines[] = {
			"SmokeShell",
			"SmokeShell",
			"16Rnd_9x21_Mag",
			"16Rnd_9x21_Mag",
			"16Rnd_9x21_Mag",
			"30Rnd_65x39_caseless_mag",
			"30Rnd_65x39_caseless_mag",
			"30Rnd_65x39_caseless_mag",
			"30Rnd_65x39_caseless_mag",
			"30Rnd_65x39_caseless_mag",
			"30Rnd_65x39_caseless_mag",
			"30Rnd_65x39_caseless_mag",
			"30Rnd_65x39_caseless_mag",
			"30Rnd_65x39_caseless_mag",
			"HandGrenade",
			"HandGrenade"
		};
		items[] = { // Useable items
			"FirstAidKit"
		};
		linkedItems[] = {
			"V_PlateCarrierGL_rgr",
			"H_HelmetB_desert",
			"optic_Hamr",
			"acc_pointer_IR",
			"NVGoggles",
			"ItemGPS",
			"ItemMap",
			"ItemCompass",
			"ItemWatch",
			"ItemRadio"
		};
		uniformClass = "U_B_CombatUniform_mcam_vest";
	};
	
	class O_SquadLeader
	{
		displayName = "Squad Leader"; 
		role = "SquadLeader";
		icon = "\A3\ui_f\data\map\VehicleIcons\iconManLeader_ca.paa"; 
		weapons[] = {
			"arifle_Katiba_F",
			"Binocular",
			"hgun_Rook40_F"
		};
		magazines[] = {
			"SmokeShell",
			"SmokeShell",
			"16Rnd_9x21_Mag",
			"16Rnd_9x21_Mag",
			"16Rnd_9x21_Mag",
			"30Rnd_65x39_caseless_green",
			"30Rnd_65x39_caseless_green",
			"30Rnd_65x39_caseless_green",
			"30Rnd_65x39_caseless_green",
			"30Rnd_65x39_caseless_green",
			"30Rnd_65x39_caseless_green",
			"30Rnd_65x39_caseless_green",
			"30Rnd_65x39_caseless_green",
			"HandGrenade",
			"HandGrenade"
		};
		items[] = {
			"FirstAidKit"
		};
		linkedItems[] = {
			"V_TacVest_khk",
			"H_HelmetLeaderO_ocamo",
			"optic_Arco_blk_F",
			"acc_pointer_IR",
			"NVGoggles_OPFOR",
			"ItemGPS",
			"ItemMap",
			"ItemCompass",
			"ItemWatch",
			"ItemRadio"
		};
		uniformClass = "U_O_CombatUniform_ocamo";
	};
	
	class B_Medic
	{
		displayName = "Medic"; 
		role = "Medic";
		icon = "\A3\ui_f\data\map\VehicleIcons\iconManLeader_ca.paa";
		weapons[] = {
			"arifle_MX_F",
			"Binocular",
			"hgun_P07_F"
		};
		magazines[] = {
			"SmokeShell",
			"SmokeShell",
			"SmokeShell",
			"SmokeShell",
			"16Rnd_9x21_Mag",
			"16Rnd_9x21_Mag",
			"30Rnd_65x39_caseless_mag",
			"30Rnd_65x39_caseless_mag",
			"30Rnd_65x39_caseless_mag",
			"30Rnd_65x39_caseless_mag",
			"30Rnd_65x39_caseless_mag",
			"30Rnd_65x39_caseless_mag",
			"30Rnd_65x39_caseless_mag"
		};
		items[] = { // Useable items
			"Medkit"
		};
		linkedItems[] = {
			"V_PlateCarrierGL_rgr",
			"H_HelmetB_desert",
			"optic_Hamr",
			"acc_pointer_IR",
			"NVGoggles",
			"ItemGPS",
			"ItemMap",
			"ItemCompass",
			"ItemWatch",
			"ItemRadio"
		};
		uniformClass = "U_B_CombatUniform_mcam_tshirt";
		backpack = "B_AssaultPack_rgr_Medic";
	};
	
	class O_Medic
	{
		displayName = "Medic"; 
		role = "Medic";
		icon = "\A3\ui_f\data\map\VehicleIcons\iconManLeader_ca.paa"; 
		weapons[] = {
			"arifle_Katiba_F",
			"Binocular",
			"hgun_Rook40_F"
		};
		magazines[] = {
			"SmokeShell",
			"SmokeShell",
			"SmokeShell",
			"SmokeShell",
			"16Rnd_9x21_Mag",
			"16Rnd_9x21_Mag",
			"30Rnd_65x39_caseless_green",
			"30Rnd_65x39_caseless_green",
			"30Rnd_65x39_caseless_green",
			"30Rnd_65x39_caseless_green",
			"30Rnd_65x39_caseless_green",
			"30Rnd_65x39_caseless_green",
			"30Rnd_65x39_caseless_green"
		};
		items[] = {
			"Medikit"
		};
		linkedItems[] = {
			"V_TacVest_khk",
			"H_HelmetLeaderO_ocamo",
			"optic_Arco_blk_F",
			"acc_pointer_IR",
			"NVGoggles_OPFOR",
			"ItemGPS",
			"ItemMap",
			"ItemCompass",
			"ItemWatch",
			"ItemRadio"
		};
		uniformClass = "U_O_CombatUniform_ocamo";
		backpack = "B_FieldPack_ocamo_Medic";
	};
	
	class B_Engineer
	{
		displayName = "Engineer";
		role = "Engineer";
		icon = "\A3\ui_f\data\map\VehicleIcons\iconManLeader_ca.paa";
		weapons[] = {
			"arifle_MX_F",
			"Binocular",
			"hgun_P07_F"
		};
		magazines[] = {
			"SmokeShell",
			"16Rnd_9x21_Mag",
			"16Rnd_9x21_Mag",
			"30Rnd_65x39_caseless_mag",
			"30Rnd_65x39_caseless_mag",
			"30Rnd_65x39_caseless_mag",
			"30Rnd_65x39_caseless_mag",
			"30Rnd_65x39_caseless_mag",
			"30Rnd_65x39_caseless_mag",
			"HandGrenade"
		};
		items[] = { // Useable items
			"FirstAidKit",
			"ToolKit",
			"MineDetector"
		};
		linkedItems[] = {
			"V_Chestrig_rgr",
			"H_HelmetB_desert",
			"optic_Hamr",
			"acc_pointer_IR",
			"NVGoggles",
			"ItemGPS",
			"ItemMap",
			"ItemCompass",
			"ItemWatch",
			"ItemRadio"
		};
		uniformClass = "U_B_CombatUniform_mcam_vest";
		backpack = "B_Kitbag_mcamo_Eng";
	};
	
	class O_Engineer
	{
		displayName = "Engineer"; 
		role = "Engineer";
		icon = "\A3\ui_f\data\map\VehicleIcons\iconManLeader_ca.paa"; 
		weapons[] = {
			"arifle_Katiba_F",
			"Binocular",
			"hgun_Rook40_F"
		};
		magazines[] = {
			"SmokeShell",
			"SmokeShell",
			"16Rnd_9x21_Mag",
			"16Rnd_9x21_Mag",
			"16Rnd_9x21_Mag",
			"30Rnd_65x39_caseless_green",
			"30Rnd_65x39_caseless_green",
			"30Rnd_65x39_caseless_green",
			"30Rnd_65x39_caseless_green",
			"30Rnd_65x39_caseless_green",
			"30Rnd_65x39_caseless_green",
			"HandGrenade"
		};
		items[] = {
			"FirstAidKit",
			"ToolKit",
			"MineDetector"
		};
		linkedItems[] = {
			"V_HarnessO_brn",
			"H_HelmetLeaderO_ocamo",
			"optic_Arco_blk_F",
			"acc_pointer_IR",
			"NVGoggles_OPFOR",
			"ItemGPS",
			"ItemMap",
			"ItemCompass",
			"ItemWatch",
			"ItemRadio"
		};
		uniformClass = "U_O_CombatUniform_ocamo";
		backpack = "B_Carryall_ocamo_Eng";
	};
	
	class B_AT
	{
		displayName = "Anti Tank";
		role = "AntiVehicleSpecialist";		
		icon = "\A3\ui_f\data\map\VehicleIcons\iconManLeader_ca.paa";
		weapons[] = {
			"arifle_MX_F",
			"Binocular",
			"launch_MRAWS_sand_F",
			"hgun_P07_F"
		};
		magazines[] = {
			"SmokeShell",
			"16Rnd_9x21_Mag",
			"16Rnd_9x21_Mag",
			"30Rnd_65x39_caseless_mag",
			"30Rnd_65x39_caseless_mag",
			"30Rnd_65x39_caseless_mag",
			"30Rnd_65x39_caseless_mag",
			"30Rnd_65x39_caseless_mag",
			"30Rnd_65x39_caseless_mag",
			"MRAWS_HEAT_F",
			"MRAWS_HE_F"
		};
		items[] = {
			"FirstAidKit"
		};
		linkedItems[] = {
			"V_PlateCarrier2_rgr",
			"H_HelmetB_sand",
			"optic_Hamr",
			"acc_pointer_IR",
			"NVGoggles",
			"ItemGPS",
			"ItemMap",
			"ItemCompass",
			"ItemWatch",
			"ItemRadio"
		};
		uniformClass = "U_B_CombatUniform_mcam";
		backpack = "B_AssaultPack_rgr_LAT2";
	};
	
	class O_AT
	{
		displayName = "Anti Tank";
		role = "AntiVehicleSpecialist";
		icon = "\A3\ui_f\data\map\VehicleIcons\iconManLeader_ca.paa"; 
		weapons[] = {
			"arifle_Katiba_F",
			"Binocular",
			"launch_RPG32_F",
			"hgun_Rook40_F"
		};
		magazines[] = {
			"SmokeShell",
			"SmokeShell",
			"16Rnd_9x21_Mag",
			"16Rnd_9x21_Mag",
			"16Rnd_9x21_Mag",
			"30Rnd_65x39_caseless_green",
			"30Rnd_65x39_caseless_green",
			"30Rnd_65x39_caseless_green",
			"30Rnd_65x39_caseless_green",
			"30Rnd_65x39_caseless_green",
			"30Rnd_65x39_caseless_green",
			"RPG32_F",
			"RPG32_HE_F"
		};
		items[] = {
			"FirstAidKit"
		};
		linkedItems[] = {
			"V_TacVest_khk",
			"H_HelmetO_ocamo",
			"optic_Arco_blk_F",
			"acc_pointer_IR",
			"NVGoggles_OPFOR",
			"ItemGPS",
			"ItemMap",
			"ItemCompass",
			"ItemWatch",
			"ItemRadio"
		};
		uniformClass = "U_O_CombatUniform_ocamo";
		backpack = "B_FieldPack_cbr_LAT";
	};

	class B_HAT
	{
		displayName = "Heavy Anti Tank";
		role = "AntiVehicleSpecialist";		
		icon = "\A3\ui_f\data\map\VehicleIcons\iconManLeader_ca.paa";
		weapons[] = {
			"arifle_MX_F",
			"Binocular",
			"launch_O_Vorona_brown_F",
			"hgun_P07_F"
		};
		magazines[] = {
			"SmokeShell",
			"16Rnd_9x21_Mag",
			"16Rnd_9x21_Mag",
			"30Rnd_65x39_caseless_mag",
			"30Rnd_65x39_caseless_mag",
			"30Rnd_65x39_caseless_mag",
			"30Rnd_65x39_caseless_mag",
			"30Rnd_65x39_caseless_mag",
			"30Rnd_65x39_caseless_mag",
			"Vorona_HEAT",
			"Vorona_HEAT"
		};
		items[] = {
			"FirstAidKit"
		};
		linkedItems[] = {
			"V_PlateCarrier2_rgr",
			"H_HelmetB_sand",
			"optic_Hamr",
			"acc_pointer_IR",
			"NVGoggles",
			"ItemGPS",
			"ItemMap",
			"ItemCompass",
			"ItemWatch",
			"ItemRadio"
		};
		uniformClass = "U_B_CombatUniform_mcam";
		backpack = "B_FieldPack_cbr_HAT";
	};

	class O_HAT
	{
		displayName = "Heavy Anti Tank";
		role = "AntiVehicleSpecialist";
		icon = "\A3\ui_f\data\map\VehicleIcons\iconManLeader_ca.paa"; 
		weapons[] = {
			"arifle_Katiba_F",
			"Binocular",
			"launch_O_Vorona_brown_F",
			"hgun_Rook40_F"
		};
		magazines[] = {
			"SmokeShell",
			"SmokeShell",
			"16Rnd_9x21_Mag",
			"16Rnd_9x21_Mag",
			"16Rnd_9x21_Mag",
			"30Rnd_65x39_caseless_green",
			"30Rnd_65x39_caseless_green",
			"30Rnd_65x39_caseless_green",
			"30Rnd_65x39_caseless_green",
			"30Rnd_65x39_caseless_green",
			"30Rnd_65x39_caseless_green",
			"Vorona_HEAT",
			"Vorona_HEAT"
		};
		items[] = {
			"FirstAidKit"
		};
		linkedItems[] = {
			"V_TacVest_khk",
			"H_HelmetO_ocamo",
			"optic_Arco_blk_F",
			"acc_pointer_IR",
			"NVGoggles_OPFOR",
			"ItemGPS",
			"ItemMap",
			"ItemCompass",
			"ItemWatch",
			"ItemRadio"
		};
		uniformClass = "U_O_CombatUniform_ocamo";
		backpack = "B_FieldPack_cbr_HAT";
	};
	
	class B_AA
	{
		displayName = "Anti Air";
		role = "AntiVehicleSpecialist";
		icon = "\A3\ui_f\data\map\VehicleIcons\iconManLeader_ca.paa";
		weapons[] = {
			"arifle_MX_F",
			"Binocular",
			"launch_B_Titan_F",
			"hgun_P07_F"
		};
		magazines[] = {
			"SmokeShell",
			"16Rnd_9x21_Mag",
			"16Rnd_9x21_Mag",
			"30Rnd_65x39_caseless_mag",
			"30Rnd_65x39_caseless_mag",
			"30Rnd_65x39_caseless_mag",
			"30Rnd_65x39_caseless_mag",
			"30Rnd_65x39_caseless_mag",
			"30Rnd_65x39_caseless_mag",
			"Titan_AA",
			"Titan_AA"
		};
		items[] = { // Useable items
			"FirstAidKit"
		};
		linkedItems[] = {
			"V_PlateCarrier2_rgr",
			"H_HelmetB_sand",
			"optic_Hamr",
			"acc_pointer_IR",
			"NVGoggles",
			"ItemGPS",
			"ItemMap",
			"ItemCompass",
			"ItemWatch",
			"ItemRadio"
		};
		uniformClass = "U_B_CombatUniform_mcam";
		backpack = "B_AssaultPack_mcamo_AA";
	};
	
	class O_AA
	{
		displayName = "Anti Air";
		role = "AntiVehicleSpecialist";
		icon = "\A3\ui_f\data\map\VehicleIcons\iconManLeader_ca.paa"; 
		weapons[] = {
			"arifle_Katiba_F",
			"Binocular",
			"launch_O_Titan_F",
			"hgun_Rook40_F"
		};
		magazines[] = {
			"SmokeShell",
			"SmokeShell",
			"16Rnd_9x21_Mag",
			"16Rnd_9x21_Mag",
			"16Rnd_9x21_Mag",
			"30Rnd_65x39_caseless_green",
			"30Rnd_65x39_caseless_green",
			"30Rnd_65x39_caseless_green",
			"30Rnd_65x39_caseless_green",
			"30Rnd_65x39_caseless_green",
			"30Rnd_65x39_caseless_green",
			"Titan_AA",
			"Titan_AA"
		};
		items[] = {
			"FirstAidKit"
		};
		linkedItems[] = {
			"V_TacVest_khk",
			"H_HelmetO_ocamo",
			"optic_Arco_blk_F",
			"acc_pointer_IR",
			"NVGoggles_OPFOR",
			"ItemGPS",
			"ItemMap",
			"ItemCompass",
			"ItemWatch",
			"ItemRadio"
		};
		uniformClass = "U_O_CombatUniform_ocamo";
		backpack = "B_FieldPack_ocamo_AA";
	};
};





