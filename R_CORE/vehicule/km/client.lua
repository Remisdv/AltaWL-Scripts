local previousPosition = nil

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000) -- Check every second
        local playerPed = PlayerPedId()
        if IsPedInAnyVehicle(playerPed, false) then
            local vehicle = GetVehiclePedIsIn(playerPed, false)
            if GetPedInVehicleSeat(vehicle, -1) == playerPed then
                local currentPosition = GetEntityCoords(vehicle)
                if previousPosition then
                    local distance = Vdist(previousPosition.x, previousPosition.y, previousPosition.z, currentPosition.x, currentPosition.y, currentPosition.z)
                    if distance > 0 then
                        local plate = GetVehicleNumberPlateText(vehicle)
                        TriggerServerEvent('esx_vehicle:updateDistance', plate, distance)
                    end
                end
                previousPosition = currentPosition
            else
                previousPosition = nil
            end
        else
            previousPosition = nil
        end
    end
end)

RegisterNetEvent('esx_vehicle:showKilometers')
AddEventHandler('esx_vehicle:showKilometers', function(kilometers)
    -- Use ox_lib notify to show the kilometers
    exports.ox_lib:notify({
        title = 'Kilométrage',
        description = 'Le véhicule a parcouru ' .. kilometers .. ' kilomètres.',
        type = 'success'
    })
end)

-- Command to show the kilometers
RegisterCommand('kilométrage', function()
    local playerPed = PlayerPedId()
    if IsPedInAnyVehicle(playerPed, false) then
        local vehicle = GetVehiclePedIsIn(playerPed, false)
        local plate = GetVehicleNumberPlateText(vehicle)
        TriggerServerEvent('esx_vehicle:requestKilometers', plate)
    else
        exports.ox_lib:notify({
            title = 'Kilométrage',
            description = 'Vous n\'êtes pas dans un véhicule.',
            type = 'error'
        })
    end
end, false)
