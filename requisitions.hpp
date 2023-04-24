class CfgWLRequisitionPresets
{
	class OpenWarlords
	{
		class WEST
		{
			class Infantry
			{
				class B_Soldier_F 				{cost = 100;	requirements[]={};	};	// "Rifleman"
				class B_crew_F 					{cost = 100;	requirements[]={};	};	// "Crewman"
				class B_Helipilot_F 				{cost = 100;	requirements[]={};	};	// "Helicopter Pilot"
				class B_Pilot_F 				{cost = 100;	requirements[]={};	};	// "Pilot"
				class B_Soldier_GL_F 				{cost = 125;	requirements[]={};	};	// "Grenadier"
				class B_medic_F					{cost = 125;	requirements[]={};	};	// "Combat Life Saver"
				class B_soldier_AR_F				{cost = 150;	requirements[]={};	};	// "Autorifleman"
				class B_Soldier_A_F				{cost = 150;	requirements[]={};	};	// "Ammo Bearer"
				class B_soldier_M_F				{cost = 150;	requirements[]={};	};	// "Marksman"
				class B_soldier_repair_F			{cost = 200;	requirements[]={};	};	// "Repair Specialist"
				class B_HeavyGunner_F				{cost = 200;	requirements[]={};	};	// "Heavy Gunner"
				class B_soldier_LAT_F				{cost = 250;	requirements[]={};	};	// "Rifleman (AT)"
				class B_soldier_LAT2_F				{cost = 300;	requirements[]={};	};	// "Rifleman (Light AT)"
				class B_soldier_AT_F				{cost = 300;	requirements[]={};	};	// "Missile Specialist (AT)"
				class B_soldier_AA_F				{cost = 300;	requirements[]={};	};	// "Missile Specialist (AA)"
				class B_Sharpshooter_F				{cost = 300;	requirements[]={};	};	// "Sharpshooter"
				class B_sniper_F				{cost = 300;	requirements[]={};	};	// "Sniper"
			};
			class Vehicles
			{
				class B_Quadbike_01_F				{cost = 100;	requirements[]={};	};	// "Quad Bike"
				class B_LSV_01_unarmed_F			{cost = 350;	requirements[]={};	};	// "Prowler (Unarmed)"
				class B_MRAP_01_F				{cost = 500;	requirements[]={};	};	// "Hunter"
				class B_Truck_01_transport_F			{cost = 650;	requirements[]={};	};	// "HEMTT Transport"
				class B_Truck_01_fuel_F				{cost = 750;	requirements[]={};	};	// "HEMTT Fuel"
				class B_Truck_01_medical_F			{cost = 750;	requirements[]={};	};	// "HEMTT Medical"
				class B_LSV_01_armed_F				{cost = 1000;	requirements[]={};	};	// "Prowler (HMG)"
				class B_LSV_01_AT_F				{cost = 1250;	requirements[]={};	};	// "Prowler (AT)"
				class B_Truck_01_Repair_F			{cost = 1250;	requirements[]={};	};	// "HEMTT Repair"
				class B_Truck_01_ammo_F				{cost = 1250;	requirements[]={};	};	// "HEMTT Ammo"
				class B_MRAP_01_hmg_F				{cost = 1400;	requirements[]={};	};	// "Hunter HMG"
				class B_MRAP_01_gmg_F				{cost = 1600;	requirements[]={};	};	// "Hunter GMG"
				
				class B_APC_Wheeled_01_cannon_F			{cost = 3000;	requirements[]={};	};	// "AMV-7 Marshall"
				class B_APC_Tracked_01_rcws_F			{cost = 3500;	requirements[]={};	};	// "IFV-6c Panther"
				class B_APC_Tracked_01_AA_F			{cost = 4000;	requirements[]={};	};	// "IFV-6a Cheetah"
				class I_LT_01_AA_F					{cost = 4000;	requirements[]={};	};	// Nyx AA
				class B_MBT_01_cannon_F				{cost = 5000;	requirements[]={};	};	// "M2A1 Slammer"
				class B_MBT_01_TUSK_F				{cost = 5500;	requirements[]={};	};	// "M2A1 Slammer UP"
				class I_MBT_03_cannon_F				{cost = 6500;	requirements[]={};	};	// Kuma
				class B_AFV_Wheeled_01_cannon_F			{cost = 7000;	requirements[]={};	};	// "Rhino MGS"
				class B_AFV_Wheeled_01_up_cannon_F		{cost = 7500;	requirements[]={};	};	// "Rhino MGS UP"	
			};
			class Aircraft
			{
				class B_Heli_Light_01_F				{cost = 1000;	requirements[]={"H"};	};	// "MH-9 Hummingbird"
				class B_Heli_Light_01_dynamicLoadout_F		{cost = 2500;	requirements[]={"H"};	};	// "AH-9 Pawnee"
				class B_Heli_Transport_01_F			{cost = 3000;	requirements[]={"H"};	};	// "UH-80 Ghost Hawk"
				class B_Heli_Transport_03_F			{cost = 4500;	requirements[]={"H"};	};	// "CH-67 Huron"
				class B_Heli_Attack_01_dynamicLoadout_F		{cost = 6000;	requirements[]={"H"};	};	// "AH-99 Blackfoot"
				class B_T_VTOL_01_armed_F			{cost = 9000;	requirements[]={"H"};	};	// "V-44 X Blackfish (Armed)"
				class B_Plane_CAS_01_dynamicLoadout_F		{cost = 10500;	requirements[]={"A"};	};	// "A-164 Wipeout (CAS)"
				class B_Plane_Fighter_01_F			{cost = 13500;	requirements[]={"A"};	};	// "F/A-181 Black Wasp II";
			};
			class Naval
			{
				class B_Boat_Transport_01_F			{cost = 100;	requirements[]={"W"};	};	// "Assault Boat"
				class B_Boat_Armed_01_minigun_F			{cost = 750;	requirements[]={"W"};	};	// "Speedboat Minigun"
				class B_SDV_01_F				{cost = 900;	requirements[]={"W"};	};	// "SDV"
			};
			class Gear
			{
				class Box_NATO_Ammo_F				{cost = 200;	requirements[]={};	};	// "Basic Ammo [NATO]"
				class Box_NATO_Grenades_F			{cost = 200;	requirements[]={};	};	// "Grenades [NATO]"
				class Box_NATO_Wps_F				{cost = 250;	requirements[]={};	};	// "Basic Weapons [NATO]"
				class Box_NATO_AmmoOrd_F			{cost = 250;	requirements[]={};	};	// "Explosives [NATO]"
				class Box_NATO_WpsLaunch_F			{cost = 300;	requirements[]={};	};	// "Launchers [NATO]"
				class Box_NATO_WpsSpecial_F			{cost = 500;	requirements[]={};	};	// "Special Weapons [NATO]"
				class B_supplyCrate_F				{cost = 500;	requirements[]={};	};	// "Supply Box [NATO]"
				class Box_NATO_AmmoVeh_F			{cost = 500;	requirements[]={};	};	// "Vehicle Ammo [NATO]"
			};
			class Defences
			{
				class B_HMG_01_F				{cost = 250;	requirements[]={};	};	// "Mk30 HMG .50"
				class B_HMG_01_high_F				{cost = 250;	requirements[]={};	};	// "Mk30 HMG .50 (Raised)"
				class B_GMG_01_F				{cost = 250;	requirements[]={};	};	// "Mk32 GMG 20 mm"
				class B_GMG_01_high_F				{cost = 250;	requirements[]={};	};	// "Mk32 GMG 20 mm (Raised)"
				class B_static_AA_F				{cost = 500;	requirements[]={};	};	// "Static Titan Launcher (AA) [NATO]"
				class B_static_AT_F				{cost = 500;	requirements[]={};	};	// "Static Titan Launcher (AT) [NATO]"
				class B_SAM_System_03_F				{cost = 27500;	requirements[]={};	offset[]={0, 5.3, 0};};	// "MIM-145 Defender"
				class B_Radar_System_01_F			{cost = 8500;	requirements[]={};	offset[]={0, 5.3, 0};};	// "AN/MPQ-105 Radar"
			};
		};
		class EAST
		{
			class Infantry
			{
				class O_Soldier_F				{cost = 100;	requirements[]={};	};	// "Rifleman"
				class O_crew_F 					{cost = 100;	requirements[]={};	};	// "Crewman"
				class O_Helipilot_F 				{cost = 100;	requirements[]={};	};	// "Helicopter Pilot"
				class O_Pilot_F 				{cost = 100;	requirements[]={};	};	// "Pilot"
				class O_Soldier_GL_F				{cost = 125;	requirements[]={};	};	// "Grenadier"
				class O_medic_F					{cost = 125;	requirements[]={};	};	// "Combat Life Saver"
				class O_soldier_AR_F				{cost = 150;	requirements[]={};	};	// "Autorifleman"
				class O_Soldier_A_F				{cost = 150;	requirements[]={};	};	// "Ammo Bearer"
				class O_soldier_M_F				{cost = 150;	requirements[]={};	};	// "Marksman"
				class O_soldier_repair_F			{cost = 200;	requirements[]={};	};	// "Repair Specialist"
				class O_HeavyGunner_F				{cost = 200;	requirements[]={};	};	// "Heavy Gunner"
				class O_soldier_LAT_F				{cost = 250;	requirements[]={};	};	// "Rifleman (AT)"
				class O_soldier_AT_F				{cost = 300;	requirements[]={};	};	// "Missile Specialist (AT)"
				class O_Soldier_AA_F				{cost = 300;	requirements[]={};	};	// "Missile Specialist (AA)"
				class O_Sharpshooter_F				{cost = 300;	requirements[]={};	};	// "Sharpshooter"
				class O_sniper_F				{cost = 300;	requirements[]={};	};	// "Sniper"
				class O_soldier_HAT_F				{cost = 350;	requirements[]={};	};	// "Rifleman (Heavy AT)"
			};
			class Vehicles
			{
				class O_Quadbike_01_F				{cost = 100;	requirements[]={};	};	// "Quad Bike"
				class O_LSV_02_unarmed_F			{cost = 350;	requirements[]={};	};	// "Qilin (Unarmed)"
				class O_MRAP_02_F				{cost = 500;	requirements[]={};	};	// "Ifrit"
				class O_Truck_03_transport_F			{cost = 650;	requirements[]={};	};	// "Tempest Transport"
				class O_Truck_03_Fuel_F				{cost = 750;	requirements[]={};	};	// "Tempest Fuel"
				class O_Truck_03_medical_F			{cost = 750;	requirements[]={};	};	// "Tempest Medical"
				class O_LSV_02_armed_F				{cost = 1000;	requirements[]={};	};	// "Qilin (Minigun)"
				class O_LSV_02_AT_F				{cost = 1250;	requirements[]={};	};	// "Qilin (AT)"
				class O_Truck_03_Repair_F			{cost = 1250;	requirements[]={};	};	// "Tempest Repair"
				class O_Truck_03_ammo_F				{cost = 1250;	requirements[]={};	};	// "Tempest Ammo"
				class O_MRAP_02_hmg_F				{cost = 1400;	requirements[]={};	};	// "Ifrit HMG"
				class O_MRAP_02_gmg_F				{cost = 1600;	requirements[]={};	};	// "Ifrit GMG"
				class O_APC_Wheeled_02_rcws_v2_F		{cost = 3000;	requirements[]={};	};	// "MSE-3 Marid"
				class O_APC_Tracked_02_cannon_F			{cost = 3500;	requirements[]={};	};	// "BTR-K Kamysh"
				class O_APC_Tracked_02_AA_F			{cost = 4000;	requirements[]={};	};	// "ZSU-39 Tigris"
				class O_MBT_02_cannon_F				{cost = 5500;	requirements[]={};	};	// "T-100 Varsuk"
				class O_MBT_04_cannon_F				{cost = 6500;	requirements[]={};	};	// "T-140 Angara"
				class O_MBT_04_command_F			{cost = 7500;	requirements[]={};	};	// "T-140K Angara"
			};
			class Aircraft
			{
				class O_Heli_Light_02_unarmed_F			{cost = 1500;	requirements[]={"H"};	};	// "PO-30 Orca (Unarmed)"
				class O_Heli_Light_02_dynamicLoadout_F		{cost = 2500;	requirements[]={"H"};	};	// "PO-30 Orca"
				class O_Heli_Transport_04_F			{cost = 2750;	requirements[]={"H"};	};	// "Mi-290 Taru"
				class O_Heli_Transport_04_covered_F		{cost = 3000;	requirements[]={"H"};	};	// "Mi-290 Taru (Transport)"
				class O_Heli_Attack_02_dynamicLoadout_F		{cost = 6000;	requirements[]={"H"};	};	// "Mi-48 Kajman"
				class O_T_VTOL_02_infantry_dynamicLoadout_F	{cost = 7000;	requirements[]={"H"};	};	// "Y-32 Xi'an (Infantry Transport)"
				class O_Plane_CAS_02_dynamicLoadout_F		{cost = 10500;	requirements[]={"A"};	};	// "To-199 Neophron (CAS)"
				class O_Plane_Fighter_02_F			{cost = 13500;	requirements[]={"A"};	};	// "To-201 Shikra"
			};
			class Naval
			{
				class O_Boat_Transport_01_F			{cost = 100;	requirements[]={"W"};	};	// "Assault Boat"
				class O_Boat_Armed_01_hmg_F			{cost = 750;	requirements[]={"W"};	};	// "Speedboat HMG"
				class O_SDV_01_F				{cost = 900;	requirements[]={"W"};	};	// "SDV"
			};
			class Gear
			{
				class Box_East_Ammo_F				{cost = 200;	requirements[]={};	};	// "Basic Ammo [CSAT]"
				class Box_East_Grenades_F			{cost = 200;	requirements[]={};	};	// "Grenades [CSAT]"
				class Box_East_Wps_F				{cost = 250;	requirements[]={};	};	// "Basic Weapons [CSAT]"
				class Box_East_AmmoOrd_F			{cost = 250;	requirements[]={};	};	// "Explosives [CSAT]"
				class Box_East_WpsLaunch_F			{cost = 300;	requirements[]={};	};	// "Launchers [CSAT]"
				class Box_East_WpsSpecial_F			{cost = 500;	requirements[]={};	};	// "Special Weapons [CSAT]"
				class O_supplyCrate_F				{cost = 500;	requirements[]={};	};	// "Supply Box [CSAT]"
				class Box_East_AmmoVeh_F			{cost = 500;	requirements[]={};	};	// "Vehicle Ammo [CSAT]"
			};
			class Defences
			{
				class O_HMG_01_F				{cost = 250;	requirements[]={};	};	// "Mk30 HMG .50"
				class O_HMG_01_high_F				{cost = 250;	requirements[]={};	};	// "Mk30 HMG .50 (Raised)"
				class O_GMG_01_F				{cost = 250;	requirements[]={};	};	// "Mk32 GMG 20 mm"
				class O_GMG_01_high_F				{cost = 250;	requirements[]={};	};	// "Mk32 GMG 20 mm (Raised)"
				class O_static_AA_F				{cost = 500;	requirements[]={};	};	// "Static Titan Launcher (AA) [CSAT]"
				class O_static_AT_F				{cost = 500;	requirements[]={};	};	// "Static Titan Launcher (AT) [CSAT]"
				class O_SAM_System_04_F				{cost = 27500;	requirements[]={};	offset[]={0, 5.3, 0};};	// "S-750 Rhea"
				class O_Radar_System_02_F			{cost = 8500;	requirements[]={};	offset[]={0, 5.3, 0};};	// "R-750 Cronus Radar"
			};
		};
		class GUER
		{
			class Infantry
			{
				class I_Soldier_F 				{cost = 100;	requirements[]={};	};	// "Rifleman"
				class I_crew_F 					{cost = 100;	requirements[]={};	};	// "Crewman"
				class I_Helipilot_F 				{cost = 100;	requirements[]={};	};	// "Helicopter Pilot"
				class I_Pilot_F 				{cost = 100;	requirements[]={};	};	// "Pilot"
				class I_Soldier_GL_F 				{cost = 125;	requirements[]={};	};	// "Grenadier"
				class I_medic_F					{cost = 125;	requirements[]={};	};	// "Combat Life Saver"
				class I_soldier_AR_F				{cost = 150;	requirements[]={};	};	// "Autorifleman"
				class I_Soldier_A_F				{cost = 150;	requirements[]={};	};	// "Ammo Bearer"
				class I_soldier_M_F				{cost = 150;	requirements[]={};	};	// "Marksman"
				class I_soldier_repair_F			{cost = 200;	requirements[]={};	};	// "Repair Specialist"
				class I_soldier_LAT_F				{cost = 250;	requirements[]={};	};	// "Rifleman (AT)"
				class I_soldier_LAT2_F				{cost = 300;	requirements[]={};	};	// "Rifleman (Light AT)"
				class I_soldier_AT_F				{cost = 300;	requirements[]={};	};	// "Missile Specialist (AT)"
				class I_soldier_AA_F				{cost = 300;	requirements[]={};	};	// "Missile Specialist (AA)"
				class I_G_Sharpshooter_F				{cost = 300;	requirements[]={};	};	// "Sharpshooter"
				class I_sniper_F				{cost = 300;	requirements[]={};	};	// "Sniper"
			};
			class Vehicles
			{
				class I_Quadbike_01_F				{cost = 100;	requirements[]={};	};	// "Quad Bike"
				class I_G_Offroad_01_F			{cost = 350;	requirements[]={};	};	// "Prowler (Unarmed)"
				class I_MRAP_03_F				{cost = 500;	requirements[]={};	};	// "Hunter"
				class I_Truck_02_transport_F			{cost = 650;	requirements[]={};	};	// "HEMTT Transport"
				class I_Truck_02_fuel_F				{cost = 750;	requirements[]={};	};	// "HEMTT Fuel"
				class I_Truck_02_medical_F			{cost = 750;	requirements[]={};	};	// "HEMTT Medical"
				class I_G_Offroad_01_armed_F				{cost = 1000;	requirements[]={};	};	// "Prowler (HMG)"
				class I_G_Offroad_01_AT_F				{cost = 1250;	requirements[]={};	};	// "Prowler (AT)"
				class I_Truck_02_box_F			{cost = 1250;	requirements[]={};	};	// "HEMTT Repair"
				class I_Truck_02_ammo_F				{cost = 1250;	requirements[]={};	};	// "HEMTT Ammo"
				class I_MRAP_03_hmg_F				{cost = 1400;	requirements[]={};	};	// "Hunter HMG"
				class I_MRAP_03_gmg_F				{cost = 1600;	requirements[]={};	};	// "Hunter GMG"
				
				class I_APC_Wheeled_03_cannon_F			{cost = 3000;	requirements[]={};	};	// "AMV-7 Marshall"
				class I_LT_01_cannon_F			{cost = 3000;	requirements[]={};	};	// "IFV-6a Cheetah"
				class I_LT_01_scout_F			{cost = 3000;	requirements[]={};	};	// "IFV-6a Cheetah"
				class I_APC_Tracked_03_cannon_F			{cost = 3500;	requirements[]={};	};	// "IFV-6c Panther"
				class I_LT_01_AA_F			{cost = 4000;	requirements[]={};	};	// "IFV-6a Cheetah"
				class I_LT_01_AT_F			{cost = 4000;	requirements[]={};	};	// "IFV-6a Cheetah"
				class I_MBT_03_cannon_F				{cost = 5000;	requirements[]={};	};	// "M2A1 Slammer"
			};
			class Aircraft
			{
				class I_Heli_light_03_unarmed_F				{cost = 1000;	requirements[]={"H"};	};	// "MH-9 Hummingbird"
				class I_Heli_Light_03_dynamicLoadout_F		{cost = 2500;	requirements[]={"H"};	};	// "AH-9 Pawnee"
				class I_Heli_Transport_02_F			{cost = 2500;	requirements[]={"H"};	};	// "UH-80 Ghost Hawk"
				class I_Plane_Fighter_03_dynamicloadout_F			{cost = 10500;	requirements[]={"A"};	};	// "F/A-181 Black Wasp II";
				class I_Plane_Fighter_04_F			{cost = 13500;	requirements[]={"A"};	};	// "F/A-181 Black Wasp II";
			};
			class Naval
			{
				class I_Boat_Transport_01_F			{cost = 100;	requirements[]={"W"};	};	// "Assault Boat"
				class I_Boat_Armed_01_minigun_F			{cost = 750;	requirements[]={"W"};	};	// "Speedboat Minigun"
			};
			class Gear
			{
				class Box_IND_Ammo_F				{cost = 200;	requirements[]={};	};	// "Basic Ammo [NATO]"
				class Box_IND_Grenades_F			{cost = 200;	requirements[]={};	};	// "Grenades [NATO]"
				class Box_IND_Wps_F				{cost = 250;	requirements[]={};	};	// "Basic Weapons [NATO]"
				class Box_IND_AmmoOrd_F			{cost = 250;	requirements[]={};	};	// "Explosives [NATO]"
				class Box_IND_WpsLaunch_F			{cost = 300;	requirements[]={};	};	// "Launchers [NATO]"
				class Box_IND_WpsSpecial_F			{cost = 500;	requirements[]={};	};	// "Special Weapons [NATO]"
				class I_supplyCrate_F				{cost = 500;	requirements[]={};	};	// "Supply Box [NATO]"
				class Box_IND_AmmoVeh_F			{cost = 500;	requirements[]={};	};	// "Vehicle Ammo [NATO]"
			};
			class Defences
			{
				class I_HMG_01_F				{cost = 250;	requirements[]={};	};	// "Mk30 HMG .50"
				class I_HMG_01_high_F				{cost = 250;	requirements[]={};	};	// "Mk30 HMG .50 (Raised)"
				class I_GMG_01_F				{cost = 250;	requirements[]={};	};	// "Mk32 GMG 20 mm"
				class I_GMG_01_high_F				{cost = 250;	requirements[]={};	};	// "Mk32 GMG 20 mm (Raised)"
				class I_static_AA_F				{cost = 500;	requirements[]={};	};	// "Static Titan Launcher (AA) [NATO]"
				class I_static_AT_F				{cost = 500;	requirements[]={};	};	// "Static Titan Launcher (AT) [NATO]"
				class I_Mortar_01_F				{cost = 3000;	requirements[]={};	offset[]={0, 5.3, 0};};	// "MIM-145 Defender"
			};
		};
	};
};

class CfgWLSectorAssetPreset
{
	class OpenWarlords
	{
		class WEST
		{
			class Infantry
			{
				class B_Soldier_F 				{cost = 100;	requirements[]={};	};	// "Rifleman"
				class B_soldier_AR_F			{cost = 150;	requirements[]={};	};	// "Autorifleman"
				class B_soldier_M_F				{cost = 150;	requirements[]={};	};	// "Marksman"
				class B_HeavyGunner_F			{cost = 200;	requirements[]={};	};	// "Heavy Gunner"
				class B_soldier_LAT2_F			{cost = 300;	requirements[]={};	};	// "Rifleman (Light AT)"
				class B_soldier_AT_F			{cost = 300;	requirements[]={};	};	// "Missile Specialist (AT)"
				class B_soldier_AA_F			{cost = 300;	requirements[]={};	};	// "Missile Specialist (AA)"
				class B_Sharpshooter_F			{cost = 300;	requirements[]={};	};	// "Sharpshooter"
			};
			class LAV
			{
				class B_LSV_01_AT_F				{cost = 1250;	requirements[]={};	};	// "Prowler (AT)"
				class B_MRAP_01_hmg_F				{cost = 1400;	requirements[]={};	};	// "Hunter HMG"
				class B_MRAP_01_gmg_F				{cost = 1600;	requirements[]={};	};	// "Hunter GMG"
				class B_APC_Wheeled_01_cannon_F			{cost = 3000;	requirements[]={};	};	// "AMV-7 Marshall"
				class B_APC_Tracked_01_rcws_F			{cost = 3500;	requirements[]={};	};	// "IFV-6c Panther"
				class B_APC_Tracked_01_AA_F			{cost = 4000;	requirements[]={};	};	// "IFV-6a Cheetah"
			};
			class Armor
			{
				class B_MBT_01_cannon_F				{cost = 5000;	requirements[]={};	};	// "M2A1 Slammer"
				class B_MBT_01_TUSK_F				{cost = 5500;	requirements[]={};	};	// "M2A1 Slammer UP"
				class B_AFV_Wheeled_01_cannon_F			{cost = 7000;	requirements[]={};	};	// "Rhino MGS"
				class B_AFV_Wheeled_01_up_cannon_F		{cost = 7500;	requirements[]={};	};	// "Rhino MGS UP"
			};
		};
		class EAST
		{
			class Infantry
			{
				class O_Soldier_F				{cost = 100;	requirements[]={};	};	// "Rifleman"
				class O_soldier_AR_F				{cost = 150;	requirements[]={};	};	// "Autorifleman"
				class O_soldier_M_F				{cost = 150;	requirements[]={};	};	// "Marksman"
				class O_HeavyGunner_F				{cost = 200;	requirements[]={};	};	// "Heavy Gunner"
				class O_soldier_LAT_F				{cost = 250;	requirements[]={};	};	// "Rifleman (AT)"
				class O_soldier_AT_F				{cost = 300;	requirements[]={};	};	// "Missile Specialist (AT)"
				class O_Soldier_AA_F				{cost = 300;	requirements[]={};	};	// "Missile Specialist (AA)"
				class O_Sharpshooter_F				{cost = 300;	requirements[]={};	};	// "Sharpshooter"
			};
			class LAV
			{
				class O_LSV_02_AT_F				{cost = 1250;	requirements[]={};	};	// "Qilin (AT)"
				class O_MRAP_02_hmg_F				{cost = 1400;	requirements[]={};	};	// "Ifrit HMG"
				class O_MRAP_02_gmg_F				{cost = 1600;	requirements[]={};	};	// "Ifrit GMG"
				class O_APC_Wheeled_02_rcws_v2_F		{cost = 3000;	requirements[]={};	};	// "MSE-3 Marid"
				class O_APC_Tracked_02_cannon_F			{cost = 3500;	requirements[]={};	};	// "BTR-K Kamysh"
				class O_APC_Tracked_02_AA_F			{cost = 4000;	requirements[]={};	};	// "ZSU-39 Tigris"
			};
			class Armor
			{
				class O_MBT_02_cannon_F				{cost = 5500;	requirements[]={};	};	// "T-100 Varsuk"
				class O_MBT_04_cannon_F				{cost = 6500;	requirements[]={};	};	// "T-140 Angara"
				class O_MBT_04_command_F			{cost = 7500;	requirements[]={};	};	// "T-140K Angara"
			};
		};
		class GUER
		{
			class Infantry
			{
				class I_Soldier_F 				{cost = 100;	requirements[]={};	};	// "Rifleman"
				class I_soldier_AR_F				{cost = 150;	requirements[]={};	};	// "Autorifleman"
				class I_soldier_M_F				{cost = 150;	requirements[]={};	};	// "Marksman"
				class I_soldier_LAT2_F				{cost = 300;	requirements[]={};	};	// "Rifleman (Light AT)"
				class I_soldier_AT_F				{cost = 300;	requirements[]={};	};	// "Missile Specialist (AT)"
				class I_soldier_AA_F				{cost = 300;	requirements[]={};	};	// "Missile Specialist (AA)"
				class I_G_Sharpshooter_F				{cost = 300;	requirements[]={};	};	// "Sharpshooter"
			};
			class LAV
			{
				class I_G_Offroad_01_AT_F				{cost = 1250;	requirements[]={};	};	// "Prowler (AT)"
				class I_MRAP_03_hmg_F				{cost = 1400;	requirements[]={};	};	// "Hunter HMG"
				class I_MRAP_03_gmg_F				{cost = 1600;	requirements[]={};	};	// "Hunter GMG"
				class I_APC_Wheeled_03_cannon_F			{cost = 3000;	requirements[]={};	};	// "AMV-7 Marshall"
				class I_LT_01_cannon_F			{cost = 3000;	requirements[]={};	};	// "IFV-6a Cheetah"
				class I_LT_01_scout_F			{cost = 3000;	requirements[]={};	};	// "IFV-6a Cheetah"
				class I_APC_Tracked_03_cannon_F			{cost = 3500;	requirements[]={};	};	// "IFV-6c Panther"
				class I_LT_01_AA_F			{cost = 4000;	requirements[]={};	};	// "IFV-6a Cheetah"
				class I_LT_01_AT_F			{cost = 4000;	requirements[]={};	};	// "IFV-6a Cheetah"
			};
			class Armor
			{
				class I_MBT_03_cannon_F				{cost = 5000;	requirements[]={};	};	// "M2A1 Slammer"
			};
		};
	};
};