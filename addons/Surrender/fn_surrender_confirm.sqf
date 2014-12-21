//@file Version: 0.9
//@file Name: surrender.sqf
//@file Author: BadVolt
//@file Created: 20/12/2014
//@file Description: Surrender for X seconds

//Surrender longs for
#define DURATION 60

[] spawn {
	player setUnitPos "up";
	player setVariable ["sur_isSurrendering", true, true];
	while {player getVariable ["sur_isSurrendering", false]} do {
		player action ["Surrender", player];
		sleep 0.5;
		if (!alive player) then {
			player setVariable ["sur_isSurrendering", false, true];
			player setVariable ["sur_gotSuggestion",false,true];
			player setVariable ["sur_suggestorName",nil,true];
		};
	};
};

[] spawn {
	sleep DURATION;
	player setVariable ["sur_isSurrendering", false, true];
	player setVariable ["sur_gotSuggestion",false,true];
	player setVariable ["sur_suggestorName",nil,true];
	[player, ""] call switchMoveGlobal;
};