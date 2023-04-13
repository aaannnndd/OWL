params ["_display", "_tabIdx"];
//execVM "Client\GUI\CommanderTab.sqf";

//isPiPEnabled;

/*_bar = _display ctrlCreate ["RscPicture", _tabIdx*1000];
_bar ctrlSetPosition [(0.3 * safezoneW + safezoneX), (0.2 * safezoneH + safezoneY), (0.4 * safezoneW), (0.4 * safezoneW)];
_bar ctrlSetText getMissionPath "aa.paa";//"#(argb,512,512,1)r2t(rtttexture_1,1)";
_bar ctrlCommit 0;*/

/*[] spawn {
	private _cam = "camera" camCreate (player modelToWorld [0,0,100]);
	_cam cameraEffect ["internal", "back"];
	_cam setVectorDirAndUp [[0,0,-1], [0,1,0]];	
	showCinemaBorder false;
	setDefaultCamera [ATLToASL (player modelToWorld [0, 0, 100]), [0, 0, -1]];
	_pos = position _cam;
	sleep 0.5;
	_cam camPreparePos ([(_pos#0)+10, (_pos#1), (_pos#2)]);
	_cam camCommitPrepared 2;
	sleep 2.5;
	_cam camPreparePos ([(_pos#0)+20, (_pos#1), (_pos#2)]);
	_cam camCommitPrepared 2;
	sleep 2.5;
	sleep 2;
	_cam cameraEffect ["terminate", "back"];
	camDestroy _cam;

	(findDisplay 46) displayAddEventHandler ["KeyUp", {
		_key = _this # 1;
		if (_key == 22) then {
			execVM "Client\GUI\UI_COMMAND_MENU.sqf";
		};
	}];
};*/

/*[] spawn { 
	private _cam = "camera" camCreate (ASLToAGL eyePos player);
	_cam cameraEffect ["internal", "back"]; 
	_cam setVectorDirAndUp [vectorDir player, vectorUp player];
	showCinemaBorder false; 
	setDefaultCamera [[5171.58,11102.2,0.00136566], vectorDir player]; 
	_pos = position _cam; 

	_q = [5171.58,11102.2,0.00136566];
	_dist = 200;
	_start = (getPos player) vectorAdd [0,0,150];
	_midTarget = _q vectorDiff (getPos player);
	_midTarget = _midTarget vectorMultiply 0.95;
	_midTarget = _start vectorAdd _midTarget;
	_cam camPrepareTarget _q;
	_cam camPreparePos ((getPosATL player) vectorAdd [0,0,75]);
	_cam camPrepareFov 1;
	_cam camCommitPrepared 1;
	camUseNVG (currentVisionMode player == 1);
	sleep 1;
	_cam camPreparePos _start;
	_cam camCommitPrepared 2;
	player setPos _q;
	sleep 2;
	_cam camPreparePos (_midTarget vectorAdd [0,2,150]);
	_cam camCommitPrepared 2;
	sleep 2.1;
	_cam camPreparePos (_q);
	_cam camCommitPrepared 2; 
	sleep 2; 
	_cam cameraEffect ["terminate", "back"]; 
	camDestroy _cam;
};*/

[] spawn {
	private _cam = "camera" camCreate (player modelToWorld [0,0,100]);
	_cam cameraEffect ["internal", "back"];//, "rtttexture_1"];
	_cam setVectorDirAndUp [[0,0,-1], [0,1,0]];
	showCinemaBorder false;
	_cam camCommit 1;

	_zoom = 0.75;
	_timer = time;

	while {!isNull _cam} do {

		sleep 0.005;
			_pos = position _cam;

			_move_step = 0.5;
			_vec = [0,0];

			_boost = 1;

			if (inputAction "turbo" == 1) then {
				_boost = 2;
			};

			if (inputAction "MoveForward" == 1) then {
				_vec set [1, 1];
			};

			if (inputAction "MoveBack" == 1) then {
				_vec set [1, (_vec#1)-1]
			};

			if (inputAction "TurnRight" == 1) then {
				_vec set [0, 1];
			};

			if (inputAction "TurnLeft" == 1) then {
				_vec set [0, (_vec#0)-1];
			};

			_vec = vectorNormalized _vec;
			_pos = _pos vectorAdd (_vec vectorMultiply _move_step*_boost);

			_cam setPos _pos;

		if (inputAction "zoomIn" == 1) then {
			_zoom = _zoom - 0.01;
			if (_zoom < 0.1) then {_zoom = 0.1};
		};
		if (inputAction "zoomOut" == 1) then {
			_zoom = _zoom + 0.01;
			if (_zoom > 0.75) then {_zoom = 0.75};
		};

		_cam camPrepareFov _zoom;
		_cam camCommitPrepared 0;

		if (_timer + 10 < time) then {
			_cam cameraEffect ["terminate", "back"];
			camDestroy _cam;
		};
	};
};