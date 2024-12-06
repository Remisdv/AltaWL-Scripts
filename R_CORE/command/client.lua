ESX = exports['es_extended']:getSharedObject()
RegisterNetEvent('spawnVehicle')
AddEventHandler('spawnVehicle', function(vehicleModel)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local playerHeading = GetEntityHeading(playerPed)
    local playerVehicle = GetVehiclePedIsIn(playerPed)

    if playerVehicle then
        DeleteEntity(playerVehicle)
    end

    RequestModel(vehicleModel)
    while not HasModelLoaded(vehicleModel) do
        Wait(0)
    end

    local vehicle = CreateVehicle(vehicleModel, playerCoords, playerHeading, true, false)
    TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
    SetModelAsNoLongerNeeded(vehicleModel)
end)
