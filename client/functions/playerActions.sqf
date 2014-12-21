// ******************************************************************************************
// * This project is licensed under the GNU Affero GPL v3. Copyright © 2014 A3Wasteland.com *
// ******************************************************************************************
//	@file Version: 1.2
//	@file Name: playerActions.sqf
//	@file Author: [404] Deadbeat, [404] Costlyy, [GoT] JoSchaap, AgentRev
//	@file Created: 20/11/2012 05:19

{ [player, _x] call fn_addManagedAction } forEach
[

	["<img image='client\icons\r3f_lock.paa'/> Lock Vehicle", "client\lockSystem\vehicle_lock.sqf", [], 1,false,false,"","[cursorTarget] call canVehicleLock"],
	["<img image='client\icons\r3f_unlock.paa'/> Unlock Vehicle", "client\lockSystem\vehicle_unlock.sqf", [], 1,false,false,"","[cursorTarget] call canVehicleUnlock"],
	
	["<t color='#FF66CC'>Give up!</t>",  "addons\Surrender\fn_surrender_request.sqf", [], 1,false,false,"","[cursorTarget] call canSuggestToSurrender"],	
	["<t color='#47B247'>Surrender</t>",  "addons\Surrender\fn_surrender_confirm.sqf", [], 1,false,false,"","[player] call wasSuggestedToSurrender"],	
	["<t color='#FF0000'>Extort</t>",  "addons\Surrender\fn_surrender_extort.sqf", [], 1,false,false,"","cursorTarget getVariable ['sur_isSurrendering',false] && (player distance cursorTarget) < 3"],	

	["Holster Weapon", { player action ["SwitchWeapon", player, player, 100] }, [], -11, false, false, "", "vehicle player == player && currentWeapon player != ''"],
	["Unholster Primary Weapon", { player action ["SwitchWeapon", player, player, 0] }, [], -11, false, false, "", "vehicle player == player && currentWeapon player == '' && primaryWeapon player != ''"],

    ["Heal Self", "addons\scripts\healSelf.sqf",0,0,false,false,"","((damage player)>0.01 && (damage player)<0.25499) && ('FirstAidKit' in (items player)) && (vehicle player == player)"],	
	["Resupply", "addons\scripts\fn_resupplytruck.sqf", [], 51, false, false, "", "!(vehicle player == player) and (cursortarget iskindof 'O_Truck_03_device_F') and (player distance cursortarget) < 10"],
    
	[format ["<img image='client\icons\playerMenu.paa' color='%1'/> <t color='%1'>[</t>Player Menu<t color='%1'>]</t>", "#FF8000"], "client\systems\playerMenu\init.sqf", [], -10, false], //, false, "", ""],

	["<img image='client\icons\money.paa'/> Pickup Money", "client\actions\pickupMoney.sqf", [], 1, false, false, "", "{_x getVariable ['owner', ''] != 'mission'} count (player nearEntities ['Land_Money_F', 5]) > 0"],

	["<img image='\a3\Ui_f\data\GUI\Cfg\CommunicationMenu\transport_ca.paa'/> <t color='#FFFFFF'>Cancel Action</t>", { doCancelAction = true }, [], 1, false, false, "", "mutexScriptInProgress"],

	["<img image='client\icons\repair.paa'/> Salvage", "client\actions\salvage.sqf", [], 1.1, false, false, "", "!isNull cursorTarget && !alive cursorTarget && {cursorTarget isKindOf 'AllVehicles' && !(cursorTarget isKindOf 'Man') && player distance cursorTarget <= (sizeOf typeOf cursorTarget / 3) max 2}"],

	["<img image='client\icons\bank.paa'/> Use ATM", "addons\atm\ATM.sqf", [], 1.1, false, false, "", "!isNull cursorTarget && {(cursorTarget getVariable['isATM',false])&&((cursorTarget distance player)<5)}"],		

	["[0]"] call getPushPlaneAction,
	["Push vehicle", "server\functions\pushVehicle.sqf", [2.5, true], 1, false, false, "", "[2.5] call canPushVehicleOnFoot"],
	["Push vehicle forward", "server\functions\pushVehicle.sqf", [2.5], 1, false, false, "", "[2.5] call canPushWatercraft"],
	["Push vehicle backward", "server\functions\pushVehicle.sqf", [-2.5], 1, false, false, "", "[-2.5] call canPushWatercraft"],

	["<t color='#FF0000'>Emergency eject</t>", "client\actions\forceEject.sqf", [], -9, false, true, "", "(vehicle player) isKindOf 'Air'"],
	["<t color='#FF00FF'>Open magic parachute</t>", "client\actions\openParachute.sqf", [], 20, true, true, "", "vehicle player == player && (getPos player) select 2 > 2.5"]
];


// Hehehe...
if !(288520 in getDLCs 1) then
{
	[player, ["<t color='#00FFFF'>Get in as Driver</t>", "client\actions\moveInDriver.sqf", [], 6, true, true, "", "cursorTarget isKindOf 'Kart_01_Base_F' && player distance cursorTarget < 3.4 && isNull driver cursorTarget"]] call fn_addManagedAction;
};
