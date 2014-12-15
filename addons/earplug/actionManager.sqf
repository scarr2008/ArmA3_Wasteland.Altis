_p = _this select 1;
_i = _this select 2;
if (soundVolume != 0.1) then {
	1 fadeSound 0.1;
	_p setUserActionText [_i,"<t color='#FF0000'>Remove Earplugs</t>"];
	hint "Earplugs Worn";
} else {
	1 fadeSound 1;
	_p setUserActionText [_i,"<t color='#ADFF2F'>Wear Earplugs</t>"];
	hint "Earplugs Removed";
};