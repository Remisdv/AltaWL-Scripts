local spawnedVehicle = nil
local spawnedPlayers = {}

local vehiclesToSpawn = {}

local function isAnyPlayerNearby(x, y, z, radius)
    for _, playerId in ipairs(GetPlayers()) do
        local playerPed = GetPlayerPed(playerId)
        local playerCoords = GetEntityCoords(playerPed)
        local distance = #(playerCoords - vector3(x, y, z))

        if distance <= radius then
            return true
        end
    end
    return false
end

function Vehicleantidepop()
    MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE stored = 0', {}, function(vehicles)
        for _, vehicle in ipairs(vehicles) do
            local vehicleData = json.decode(vehicle.vehicle)
            local position = json.decode(vehicle.position)
            local plate = vehicle.plate:gsub("%s+", "")

            local allvehicle = GetAllVehicles()
            if allvehicle then
                local found = false
                local vehicleWithSamePlate = nil
                local vehicleCount = 0
                
                -- Check for vehicles with the same plate
                for _, veh in ipairs(allvehicle) do
                    local plate2 = GetVehicleNumberPlateText(veh):gsub("%s+", "")
                    
                    if plate == plate2 then
                        vehicleCount = vehicleCount + 1
                        if vehicleCount == 1 then
                            vehicleWithSamePlate = veh
                            found = true
                        elseif vehicleCount > 1 then
                            -- If there are more than one vehicle with the same plate, delete the excess one(s)
                            DeleteEntity(veh)
                        end
                    end
                end
                if not position or not position.x or not position.y or not position.z then
                        print("Position is null for vehicle with plate " .. plate)
                        return
                end
                if not found and position then
                    local x, y, z, heading = position.x, position.y, position.z, position.heading
                    if isAnyPlayerNearby(x, y, z, 100.0) then
                        local spawnedVehicle = CreateVehicle(vehicleData.model, x, y, z, heading, true, true)
                        local count = 0

                        while not DoesEntityExist(spawnedVehicle) do
                            Wait(100)
                            count = count + 1
                            if count > 10 then
                                break
                            end
                        end
                        
                        if DoesEntityExist(spawnedVehicle) then
                            local vehNetId = NetworkGetNetworkIdFromEntity(spawnedVehicle)
                            
                            TriggerClientEvent('ox_lib:setVehicleProperties', -1, vehNetId, vehicleData)
                        
                            SetVehicleDoorsLocked(spawnedVehicle, 2)
                        end
                    end
                end
            end
        end
    end)
end

Citizen.CreateThread(function()
    while true do
        Wait(10000) -- Attendre 5 secondes entre chaque vérification
        -- local allvehicle = GetAllVehicles()
        -- print('Véhicule antidepop')
        Vehicleantidepop()
    end
end)

RegisterServerEvent('saveVehiclePosition')
AddEventHandler('saveVehiclePosition', function(plate, position, data)
    --print('coord', json.encode(position), 'voiture', json.encode(data))
    MySQL.Async.execute('UPDATE owned_vehicles SET position = @position, vehicle = @vehicle WHERE plate = @plate', {
        ['@plate'] = plate,
        ['@position'] = json.encode(position),
        ['@vehicle'] = json.encode(data)
    }, function(innerRowsChanged)
        --print(innerRowsChanged)
        if innerRowsChanged == 0 then
            --print("Vehicle position not updated: Plate " .. plate)
        else
            --print("Vehicle position updated: Plate " .. plate)
        end
    end)
end)
