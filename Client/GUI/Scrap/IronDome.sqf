addMissionEventHandler ["ProjectileCreated", { 
	params ["_projectile"];

	private _vel = velocity _projectile;
	private _pos = getPosASL _projectile;
	private _point = [3751.49,10448.7,19.2991];
	private _testp = _pos vectorAdd (_vel vectorMultiply 10000);
	private _radius = 150;

	private _perp = _pos vectorAdd ( 
		(_testp vectorDiff _pos) vectorMultiply (
				((_point vectorDiff _pos) vectorDotProduct (_testp vectorDiff _pos)) /
				((_testp vectorDiff _pos) vectorDotProduct (_testp vectorDiff _pos))
			)
	);

	if (_perp distance _point < _radius) then {
		private _dcb = _point distance _perp;
		private _subdist = sqrt(_radius^2 - _dcb^2);
		private _fulldist = _perp distance _pos;
		private _adjdist = _fulldist - _subdist;

		private _time = _adjdist / (vectorMagnitude _vel);
		// Projectiles accelerate, need to figure out equation for distance to get time and explode them at correct time.
		[_projectile, _time] spawn {
			sleep (_this#1);
			triggerAmmo (_this#0);
		};
	};


	//triggerAmmo _this;
}];