/*
	Game long loop for giving command points to players
*/
// Manage team sides

private _bankCount = [playableSlotsNumber (OWL_competingSides#0), playableSlotsNumber (OWL_competingSides#1)];

{
	private _player = _x call OWL_fnc_getPlayerFromOwnerId;
	if (isNull _player) then {
		continue;
	};
	private _side = side _player;
	
	_amount = (_side call OWL_fnc_incomeCalculation);

	private _idx = OWL_competingSides find _side;

	_bankCount set [_idx, (_bankCount # _idx) - 1];

	[_x, _amount] call OWL_fnc_addFunds;
} forEach OWL_allWarlords;

OWL_bankFunds set [0, (OWL_bankFunds#0)+(_bankCount#0)*((OWL_competingSides#0) call OWL_fnc_incomeCalculation)];
OWL_bankFunds set [1, (OWL_bankFunds#1)+(_bankCount#1)*((OWL_competingSides#1) call OWL_fnc_incomeCalculation)];