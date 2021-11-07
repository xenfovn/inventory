if Config.Trunk then 
    local vehicle = nil

    local function VehicleInFront()
        local pos = GetEntityCoords(GetPlayerPed(-1))
        local entityWorld = GetOffsetFromEntityInWorldCoords(GetPlayerPed(-1), 0.0, 4.0, 0.0)
        local rayHandle = CastRayPointToPoint(pos.x, pos.y, pos.z, entityWorld.x, entityWorld.y, entityWorld.z, 10, GetPlayerPed(-1), 0)
        local a, b, c, d, result = GetRaycastResult(rayHandle)
        return result
    end

    AddEventHandler('inventory:close', function()
        if vehicle then
            SetVehicleDoorShut(vehicle, 5, true)
            vehicle = nil
        end
    end)

    RegisterCommand('openTrunk', function()
        if IsEntityDead(PlayerPedId()) then return end

        if not IsPedInAnyVehicle(PlayerPedId(), false) then 
            vehicle = VehicleInFront()

            if DoesEntityExist(vehicle) then
                local plate = ESX.Math.Trim(GetVehicleNumberPlateText(vehicle))
                local type = GetVehicleClass(vehicle)
                local locked = GetVehicleDoorLockStatus(vehicle)

                if locked == 1 then
                    for k,v in pairs(Config.BlacklistedVehicleTypes) do
                        if type == v then
                            TriggerEvent('inventory:notify', 'error', 'Vehicle does not have a trunk')
                            return
                        end
                    end

                    
                    ESX.TriggerServerCallback("inventory:checkxe", function(owned)
                        print("haha", owned, plate)
                        if owned then
                            SetCarBootOpen(vehicle)
                            OpenInventory({
                                id = plate, 
                                type = 'trunk', 
                                title = 'Cốp xe - <b>' .. plate .. '</b>',
                                weight = Config.TrunkWeights[type], 
                                save = owned,
                                timeout = Config.TrunkTimeout
                            }) 
                        else
                            TriggerEvent('inventory:notify', 'error', 'Không phải xe của bạn!')
                        end
                    end, plate)
                else 
                    TriggerEvent('inventory:notify', 'error', 'Vehicle is Locked!')
                end
                
            end
        end
    end, true)
    RegisterKeyMapping('openTrunk', 'Open Trunk', 'keyboard', Config.TrunkKey)
end
