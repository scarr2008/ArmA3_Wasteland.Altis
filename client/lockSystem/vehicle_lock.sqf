//@file Version: 1.2
//@file Name: vehiclesave.sqf
//@file Author: MercyfulFate edited by Gigatek && BadVolt
//@file Created: 06/09/2014
//@file Description: Lock vehicle

#define DURATION 5
#define ANIMATION "AinvPknlMstpSlayWrflDnon_medic"
#define ERR_IN_vehicle "Locking Failed! You can't do that in a vehicle."
#define ERR_DESTROYED "The vehicle is too damaged to lock."
#define ERR_TOO_FAR_AWAY "Locking Failed! You are too far away from the vehicle."
#define ERR_NOT_VEHICLE "Locking Failed! This is not a vehicle."
#define ERR_CANCELLED "Locking Cancelled!"

private ["_vehicle", "_checks", "_success", "_nearvehicle"];
_vehicle = cursorTarget;

_checks = {
    private ["_progress","_failed", "_text"];
    _progress = _this select 0;
    _vehicle = _this select 1;
    _text = "";
    _failed = true;
    switch (true) do {
        case (!alive player): {}; // player is dead, no need for a notification
        case (vehicle player != player): {_text = ERR_IN_vehicle};
        case (player distance _vehicle > (sizeOf typeOf _vehicle / 2) max 7): {_text = ERR_TOO_FAR_AWAY};
        case (!alive _vehicle): {_error = ERR_DESTROYED};
		case ({(typeOf _vehicle) isKindOf _x } count ['Air','Tank','Motorcycle','Car','Ship'] == 0 ): {_text = ERR_NOT_VEHICLE};
        case (doCancelAction): {_text = ERR_CANCELLED; doCancelAction = false;};
        default {
            _text = format["Vehicle Locking %1%2 Complete", round(100 * _progress), "%"];
            _failed = false;
        };
    };
    [_failed, _text];
};

_success = [DURATION, ANIMATION, _checks, [_vehicle]] call a3w_actions_start;

if (_success) then {
	[[netId _vehicle, 2], "A3W_fnc_setLockState", _vehicle] call A3W_fnc_MP; // Lock
	
	_vehicle setVariable ["R3F_Side", playerSide, true];
	_vehicle setVariable ["vehicleLocked", 2, true];
	_vehicle setVariable ["ownerUID", getPlayerUID player, true];
	
	player action ["engineOff", _vehicle];
	player action ["lightOff", _vehicle];

	["Vehicle Lock complete!", 5] call mf_notify_client;
};
_success;