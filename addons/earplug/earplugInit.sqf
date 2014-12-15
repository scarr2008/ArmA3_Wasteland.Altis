if (wakDisableSmplEp) exitWith {};
wakAct = ["<t color='#ffff33'>Earplugs</t>","addons\earplug\actionManager.sqf",[],-90,false,true,"","_target == vehicle player"];
{_x addAction wakAct;
_x addEventHandler ["Respawn",{
	1 fadeSound 1;
	(_this select 0) addAction wakAct;
}];
} forEach playableUnits;