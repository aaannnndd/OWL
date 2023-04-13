// https://community.bistudio.com/wiki/Arma_3:_CfgRemoteExec
class CfgRemoteExec
{
	class Functions
	{
		mode = 1;	//Whitelist only
		jip = 0;	//JIP flag not allowed

		class BIS_fnc_effectKilledAirDestruction	{ allowedTargets = 0; jip = 0; };
		class BIS_fnc_effectKilledSecondaries		{ allowedTargets = 0; jip = 0; };
		class BIS_fnc_objectVar						{ allowedTargets = 0; jip = 0; };
		class BIS_fnc_setCustomSoundController		{ allowedTargets = 0; jip = 0; };
		class BIS_fnc_debugConsoleExec				{ allowedTargets = 0; }; //Allow debug console
		
		class OWL_fnc_initClientServer				{ allowedTargets = 2; jip = 0; };
		class OWL_fnc_warlordInitCallback			{ allowedTargets = 0; jip = 0; };
		class OWL_fnc_clientRequestVoteForSector	{ allowedTargets = 2; jip = 0; };
	};
	
	class Commands
	{
		mode = 1;	//Whitelist only
		jip = 0;	//JIP flag not allowed
	};
};

// Will break the scenario if used in SP
// https://community.bistudio.com/wiki/Arma_3:_CfgDisabledCommands
class CfgDisabledCommands
{
	
};