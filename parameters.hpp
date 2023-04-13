class Params
{
	class Combatants
	{
		title = "Combatants";
		values[] = {0, 1, 2};
		texts[] = {"WEST vs EAST", "WEST vs RESISTANCE", "EAST vs RESISTANCE"};
		default = 0;
	};
	class DefendersPlayable
	{
		title = "Defenders Playable";
		values[] = {0, 1};
		texts[] = {"Disabled", "Enabled"};
		default = 0;
	};
	class StartingFunds
	{
		title = "Starting CP";
		values[] = {50, 250, 500, 1000, 2000, 5000, 10000, 1000000};
		default = 500;
	};
	class IncomeCalculation
	{
		title = "Income Calculation";
		values[] = {0, 1};
		texts[] = {"Vanilla", "Advanced"};
		default = 1;
	};
	class SaveFunds
	{
		title = "CP Saving";
		values[] = {0, 1};
		texts[] = {"Disabled", "Enabled"};
		default = 1;
	};
};