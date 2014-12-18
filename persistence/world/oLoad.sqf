// ******************************************************************************************
// * This project is licensed under the GNU Affero GPL v3. Copyright © 2014 A3Wasteland.com *
// ******************************************************************************************
//	@file Version: 1.2
//	@file Name: oLoad.sqf
//	@file Author: JoSchaap, AgentRev, Austerror
//	@file Description: Basesaving load script

if (!isServer) exitWith {};

#include "functions.sqf"

_strToSide =
{
	switch (toUpper _this) do
	{
		case "WEST":  { BLUFOR };
		case "EAST":  { OPFOR };
		case "GUER":  { INDEPENDENT };
		case "CIV":   { CIVILIAN };
		case "LOGIC": { sideLogic };
		default       { sideUnknown };
	};
};

_isWarchestEntry = { [_variables, "a3w_warchest", false] call fn_getFromPairs };
_isBeaconEntry = { [_variables, "a3w_spawnBeacon", false] call fn_getFromPairs };

_maxLifetime = ["A3W_objectLifetime", 0] call getPublicVar;
_maxMineLifetime = ["A3W_mineLifetime", 0] call getPublicVar;

_exists = _fileName call PDB_exists; // iniDB_exists
_objectsCount = 0;

_savingMethod = ["A3W_savingMethod", 1] call getPublicVar;

if (!isNil "_exists" && {_exists}) then
{
	_objectsCount = [_fileName, "Info", "ObjCount", "NUMBER"] call PDB_read; // iniDB_read

	if (!isNil "_objectsCount") then
	{
		for "_i" from 1 to _objectsCount do
		{
			_objName = format ["Obj%1", _i];

			_class = [_fileName, _objName, "Class", "STRING"] call PDB_read; // iniDB_read
			_pos = [_fileName, _objName, "Position", "ARRAY"] call PDB_read; // iniDB_read
			_hoursAlive = [_fileName, _objName, "HoursAlive", "NUMBER"] call PDB_read; // iniDB_read

			if (!isNil "_class" && !isNil "_pos" && {!(_class call _isMine) && {_maxLifetime <= 0 || {_hoursAlive < _maxLifetime}}}) then 
			{
				_variables = [_fileName, _objName, "Variables", "ARRAY"] call PDB_read; // iniDB_read

				_allowed = switch (true) do
				{
					case (call _isWarchestEntry):       { _warchestSavingOn };
					case (call _isBeaconEntry):         { _beaconSavingOn };
					case (_class call _isBox):          { _boxSavingOn };
					case (_class call _isStaticWeapon): { _staticWeaponSavingOn };
					default                             { _baseSavingOn };
				};

				if (_allowed) then
				{
					_dir = [_fileName, _objName, "Direction", "ARRAY"] call PDB_read; // iniDB_read
					_damage = [_fileName, _objName, "Damage", "NUMBER"] call PDB_read; // iniDB_read
					_allowDamage = [_fileName, _objName, "AllowDamage", "NUMBER"] call PDB_read; // iniDB_read

					{ if (typeName _x == "STRING") then { _pos set [_forEachIndex, parseNumber _x] } } forEach _pos;

					_obj = createVehicle [_class, _pos, [], 0, "CAN_COLLIDE"];
                    _obj allowDamage false; //set damage to false immediately to avoid taking fall damage
					_obj setPosWorld ATLtoASL _pos;

					if (!isNil "_dir") then
					{
						_obj setVectorDirAndUp _dir;
					};

					[_obj] call vehicleSetup;

					_obj setVariable ["baseSaving_hoursAlive", _hoursAlive];
					_obj setVariable ["baseSaving_spawningTime", diag_tickTime];
					_obj setVariable ["objectLocked", true, true]; // force lock

					if (_allowDamage > 0) then
					{
						_obj setDamage _damage;
						_obj setVariable ["allowDamage", true];
					}
					else
					{
						_obj allowDamage false;
					};

					{
						_var = _x select 0;
						_value = _x select 1;

						switch (_var) do
						{
							case "side": { _value = _value call _strToSide };
							case "R3F_Side": { _value = _value call _strToSide };
							case "ownerName":
							{
								switch (typeName _value) do
								{
									case "ARRAY": { _value = toString _value };
									case "STRING":
									{
										if (_savingMethod == 2) then
										{
											_value = _value call iniDB_Base64Decode;
										};
									};
									default { _value = "[Beacon]" };
								};
							};
						};

						_obj setVariable [_var, _value, true];
					} forEach _variables;

					clearWeaponCargoGlobal _obj;
					clearMagazineCargoGlobal _obj;
					clearItemCargoGlobal _obj;
					clearBackpackCargoGlobal _obj;

					_unlock = switch (true) do
					{
						case (_obj call _isWarchest): { true };
						case (_obj call _isBeacon):
						{
							pvar_spawn_beacons pushBack _obj;
							publicVariable "pvar_spawn_beacons";
							true
						};
						default { false };
					};

					if (_unlock) exitWith
					{
						_obj setVariable ["objectLocked", false, true];
					};

					if (_boxSavingOn && {_class call _isBox}) then
					{
						_weapons = [_fileName, _objName, "Weapons", "ARRAY"] call PDB_read; // iniDB_read
						_magazines = [_fileName, _objName, "Magazines", "ARRAY"] call PDB_read; // iniDB_read
						_items = [_fileName, _objName, "Items", "ARRAY"] call PDB_read; // iniDB_read
						_backpacks = [_fileName, _objName, "Backpacks", "ARRAY"] call PDB_read; // iniDB_read

						if (!isNil "_weapons") then
						{
							{ _obj addWeaponCargoGlobal _x } forEach _weapons;
						};
						if (!isNil "_magazines") then
						{
							[_obj, _magazines] call processMagazineCargo;
						};
						if (!isNil "_items") then
						{
							{ _obj addItemCargoGlobal _x } forEach _items;
						};
						if (!isNil "_backpacks") then
						{
							{
								if !((_x select 0) isKindOf "Weapon_Bag_Base") then
								{
									_obj addBackpackCargoGlobal _x;
								};
							} forEach _backpacks;
						};
					};

					if (_staticWeaponSavingOn && {_class call _isStaticWeapon}) then
					{
						//AddAi to static weapon
						if (getNumber(configFile >> "CfgVehicles" >> _class >> "isUav") > 0) then{
							createVehicleCrew _obj;
						};
						
						_turretMags = [_fileName, _objName, "TurretMagazines", "ARRAY"] call PDB_read; // iniDB_read

						if (!isNil "_turretMags") then
						{
							_obj setVehicleAmmo 0;
							{ _obj addMagazine _x } forEach _turretMags;
						};
					};

					_ammoCargo = [_fileName, _objName, "AmmoCargo", "NUMBER"] call PDB_read; // iniDB_read
					_fuelCargo = [_fileName, _objName, "FuelCargo", "NUMBER"] call PDB_read; // iniDB_read
					_repairCargo = [_fileName, _objName, "RepairCargo", "NUMBER"] call PDB_read; // iniDB_read

					if (!isNil "_ammoCargo") then { _obj setAmmoCargo _ammoCargo };
					if (!isNil "_fuelCargo") then { _obj setFuelCargo _fuelCargo };
					if (!isNil "_repairCargo") then { _obj setRepairCargo _repairCargo };
				};
			};
                       
            if (!isNil "_class" && !isNil "_pos" && {_class call _isMine && {_maxMineLifetime <= 0 || {_hoursAlive < _maxMineLifetime}}}) then 
            {
				_variables = [_fileName, _objName, "Variables", "ARRAY"] call PDB_read; // iniDB_read

				_allowed = switch (true) do
				{
                    case (_class call _isMine):         { _mineSavingOn };
				};

				if (_allowed) then
				{
					_dir = [_fileName, _objName, "Direction", "ARRAY"] call PDB_read; // iniDB_read
					_damage = [_fileName, _objName, "Damage", "NUMBER"] call PDB_read; // iniDB_read
					_allowDamage = [_fileName, _objName, "AllowDamage", "NUMBER"] call PDB_read; // iniDB_read

					{ if (typeName _x == "STRING") then { _pos set [_forEachIndex, parseNumber _x] } } forEach _pos;
                    
                    _class = _class call _mineAmmo2Vehicle;
                    
                    _obj = createMine[_class, _pos, [], 0];
                    
					_obj setPosWorld ATLtoASL _pos;
					
					//restore hours alive. At missionNamespace
					_netId = netId _obj;
					_hours_alive = missionNamespace getVariable format["%1_hoursAlive", _netId];
					missionNamespace setVariable [format["%1_spawningTime",_netId], diag_tickTime];
					if (!isNil "_hours_alive") then {
						missionNamespace setVariable [format["%1_hoursAlive",_netId], 0];
					};
                    
                    if (!isNil "_dir") then {
                      //special handling for mines, because setVectorUpAndDir has local effects only ... on mines
                      [[_obj,_dir], "A3W_fnc_setVectorUpAndDir",true, true] call BIS_fnc_MP;
                    };
                    
					{
						_var = _x select 0;
						_value = _x select 1;

						switch (_var) do
						{
                            case "mineVisibility":
                            {
                                {
                                  _side = _x call _strToSide;
                                  _side revealMine _obj;
                                } forEach _value;
                            };
						};

						//_obj setVariable [_var, _value, true]; //Just useless for mines
					} forEach _variables;
                };
            };
		};
	};

	if (_warchestMoneySavingOn) then
	{
		pvar_warchest_funds_west = ([_fileName, "Info", "WarchestMoneyBLUFOR", "NUMBER"] call PDB_read) max 0; // iniDB_read
		publicVariable "pvar_warchest_funds_west";
		pvar_warchest_funds_east = ([_fileName, "Info", "WarchestMoneyOPFOR", "NUMBER"] call PDB_read) max 0; // iniDB_read
		publicVariable "pvar_warchest_funds_east";
	};
};

diag_log format ["A3Wasteland - world persistence loaded %1 objects from %2", _objectsCount, ["A3W_savingMethodName", "a rip in the fabric of space-time"] call getPublicVar];
