//@file Version: 0.9
//@file Name: surrender.sqf
//@file Author: BadVolt
//@file Created: 20/12/2014
//@file Description: Suggest player to surrender

//Surrender suggest longs for...
#define WAITFOR 15

_target = cursorTarget;

_target setVariable ["sur_gotSuggestion",true,true];
_target setVariable ["sur_suggestorName",name player,true];

//Suggested to surrender
[_target] spawn {
	_target = _this select 0;
	sleep WAITFOR; //Wait WAITFOR sec until surrender decision
	if (_target getVariable ["sur_isSurrendering",false]) then {
		_target setVariable ["sur_gotSuggestion",false,true];
		_target setVariable ["sur_suggestorName",nil,true];
	};
};

player groupChat format["You have suggested %1 to surrender. He has %2 seconds to decide.", name _target,WAITFOR];

