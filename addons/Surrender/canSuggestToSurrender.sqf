//@file Version: 0.9
//@file Name: surrender.sqf
//@file Author: BadVolt
//@file Created: 20/12/2014
//@file Description: Checks if your current target can surrender

private ["_target"];

_target = _this select 0; //cursorTarget
_result=false;

switch (true) do {
	case (!isPlayer _target): {}; // Not a player
	case (!alive _target): {}; // Target is dead
	case (player getVariable ["sur_isSurrendering",false]): {}; // Player is surrendering
	case (side player == side _target): {}; // Is in the same team
	case (player distance _target > 350): {}; // It more then 350m
	case (_target getVariable ["sur_isSurrendering",false]): {hint format ["%1 is surrendering!",name _target]}; // Target is surrendering
	case (_target getVariable ["sur_gotSuggestion",false]): {hint format ["Waiting for %1 response...",name _target]}; // Target is suggested to surrender already
	default {hint ""; _result=true};
};
(_result);