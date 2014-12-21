//@file Version: 0.9
//@file Name: surrender.sqf
//@file Author: BadVolt
//@file Created: 20/12/2014
//@file Description: Checks if this player was suggested to surrender

//Surrender suggest longs for...
#define WAITFOR 15

_result=false;
_target = _this select 0; //cursorTarget

switch (true) do {
	case (!isPlayer _target): {}; // Not a player
	case (!alive _target): {}; // Is dead
	case (!(vehicle _target == _target)): {}; //Is in vehicle
	case (_target getVariable ["sur_isSurrendering",false]): {}; //Had already surrendered
	case (_target getVariable ["sur_gotSuggestion",false]): {_result=true};
};

if (_result) then {
	_name = player getVariable ["sur_suggestorName",""];
	player groupChat format["You have been suggested to surrender by %1. You have %2 seconds to decide.", _name,WAITFOR];

	[] spawn {
		sleep WAITFOR;
		if !(player getVariable ["sur_isSurrendering",false]) then {
			player setVariable ["sur_gotSuggestion",false,true];
			player setVariable ["sur_suggestorName",nil,true];
		};
	};
};
(_result);