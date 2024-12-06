ESX = exports['es_extended']:getSharedObject()

local distanceTraveled = 0
local isSpeedLimited = false

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000) -- Check every second

        local playerPed = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(playerPed, false)

        if DoesEntityExist(vehicle) then
            local plate = GetVehicleNumberPlateText(vehicle)
            local currentPosition = GetEntityCoords(vehicle)
            if previousPosition then
                local distance = Vdist(previousPosition.x, previousPosition.y, previousPosition.z, currentPosition.x, currentPosition.y, currentPosition.z)
                distanceTraveled = distanceTraveled + distance
                if distanceTraveled >= Config.tousles then
                    -- Request the server to check and update the vehicle's wear
                    TriggerServerEvent('checkAndUpdateUsure', plate)
                    distanceTraveled = 0 -- Reset the distance traveled
                end
            end
            previousPosition = currentPosition
        else
            previousPosition = nil
            distanceTraveled = 0 -- Reset the distance traveled if the player is not in a vehicle
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(60000) -- Check every minute

        local playerPed = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(playerPed, false)

        if DoesEntityExist(vehicle) then
            local plate = GetVehicleNumberPlateText(vehicle)
            TriggerServerEvent('checkusure', plate)
        end
    end
end)

RegisterNetEvent('notifusure')
AddEventHandler('notifusure', function()
    lib.notify({
        title = 'Attention',
        description = 'Attention il faut bientôt faire votre révision',
        type = 'warning'
    })
end)


RegisterNetEvent('usefiltreahuile')
AddEventHandler('usefiltreahuile', function()
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local closestVehicle, closestDistance = ESX.Game.GetClosestVehicle(coords)

    if closestVehicle ~= 0 and closestDistance <= 5.0 then
        -- Show progress bar
        if lib.progressCircle({
            duration = 10000,
            position = 'bottom',
            useWhileDead = false,
            canCancel = true,
            disable = {
                car = true,
            },
            anim = {
                dict = "mini@repair",
                clip = "fixing_a_ped"
            },
            label = 'Changement du filtre à huile en cours...',
        
        }) then TriggerServerEvent('resetUsure', GetVehicleNumberPlateText(closestVehicle)) else ESX.ShowNotification('Changement du filtre à huile annulé.') end
    end
end)



local usure = 0

RegisterNetEvent('updateVehicleWear')
AddEventHandler('updateVehicleWear', function(wear)
    usure = wear
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5000) -- Notification every 5 seconds

        local playerPed = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(playerPed, false)

        if DoesEntityExist(vehicle) and usure >= Config.MaxWear then
            lib.notify({
                title = 'Urgent',
                description = 'Votre véhicule a besoin d\'une révision de toute urgence!',
                type = 'error'
            })
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000) -- Check every second

        local playerPed = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(playerPed, false)

        if DoesEntityExist(vehicle) then
            local plate = GetVehicleNumberPlateText(vehicle)
            TriggerServerEvent('checkVehicleWear', plate)

            if usure >= Config.MaxWear then
                -- Limit the vehicle speed to 50 km/h
                local maxSpeed = Config.SpeedLimit / 3.6 -- Convert km/h to m/s
                SetEntityMaxSpeed(vehicle, maxSpeed)
                isSpeedLimited = true
            else
                -- If wear is below the threshold, restore the normal max speed
                SetEntityMaxSpeed(vehicle, GetVehicleHandlingFloat(vehicle, "CHandlingData", "fInitialDriveMaxFlatVel"))
                isSpeedLimited = false
            end
        else
            if isSpeedLimited then
                isSpeedLimited = false
            end
        end
    end
end)


RegisterNetEvent('useVidange')
AddEventHandler('useVidange', function()
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local closestVehicle, closestDistance = ESX.Game.GetClosestVehicle(coords)

    if closestVehicle ~= 0 and closestDistance <= 5.0 then
        -- Show progress bar
        if lib.progressCircle({
            duration = 10000,
            position = 'bottom',
            useWhileDead = false,
            canCancel = true,
            disable = {
                car = true,
            },
            anim = {
                dict = "mini@repair",
                clip = "fixing_a_ped"
            },
            label = 'Vidange en cours...',
        
        }) then TriggerServerEvent('resetUsure', GetVehicleNumberPlateText(closestVehicle)) else ESX.ShowNotification('Vidange annulée.') end
    end


end)
RegisterNetEvent('esx_teleport:teleport')
AddEventHandler('esx_teleport:teleport', function(x, y, z)
    local playerPed = PlayerPedId()
    SetEntityCoords(playerPed, x, y, z, false, false, false, true)
end)






