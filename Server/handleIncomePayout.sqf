/*
	Game long loop for giving command points to players
*/

private _bankCount = [playableSlotsNumber (OWL_competingSides#0), playableSlotsNumber (OWL_competingSides#1)];

{
	private _player = _x call OWL_fnc_getPlayerFromOwnerId;
	private _amount = _y#0;
	private _side = side _player;
	
	_amount = _amount + (_side call OWL_fnc_incomeCalculation);

	private _idx = OWL_competingSides find _side;

	_bankCount set [_idx, (_bankCount # _idx) - 1];

	// TODO: could be problematic attaching to player object, even if it's only on the server.
	OWL_allWarlords set [_x, [_amount, _y#1]];

	_amount remoteExec ["OWL_fnc_srCPUpdate", owner _player];
} forEach OWL_allWarlords;

OWL_bankFunds set [0, (OWL_bankFunds#0)+(_bankCount#0)*((OWL_competingSides#0) call OWL_fnc_incomeCalculation)];
OWL_bankFunds set [1, (OWL_bankFunds#1)+(_bankCount#1)*((OWL_competingSides#1) call OWL_fnc_incomeCalculation)];
