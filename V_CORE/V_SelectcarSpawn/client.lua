ESX = nil
local PlayerData = {}
local spawnedVehicles = {}
local selectedColor = {255, 255, 255} -- Couleur par défaut : blanc

CreateThread(function()
    while ESX == nil do
        ESX = exports['es_extended']:getSharedObject()
        Wait(100)
    end

    while not ESX.IsPlayerLoaded() do
        Wait(100)
    end

    PlayerData = ESX.GetPlayerData()
    InitializeTargets()
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    PlayerData = xPlayer
    InitializeTargets()
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    PlayerData.job = job
    InitializeTargets()
end)

function InitializeTargets()
    if PlayerData.job and PlayerData.job.name == 'selectcar' then
        for _, spawnPoint in ipairs(Config.SpawnPoints) do
            exports.ox_target:addSphereZone({
                coords = vector3(spawnPoint.x, spawnPoint.y, spawnPoint.z),
                radius = 2.0,
                options = {
                    {
                        name = 'spawn_vehicle',
                        label = 'Ouvrir le menu',
                        onSelect = function()
                            OpenVehicleMenu(spawnPoint)
                        end,
                        canInteract = function(entity, distance, coords)
                            return PlayerData.job and PlayerData.job.name == 'selectcar'
                        end
                    }
                }
            })
        end
    end
end

function OpenVehicleMenu(spawnPoint)
    local options = {}

    for _, vehicle in ipairs(Config.Vehicles) do
        table.insert(options, {
            label = vehicle,
            value = vehicle,
            description = 'Faire apparaître ' .. vehicle,
            onSelect = function()
                SpawnVehicle(vehicle, spawnPoint)
            end
        })
    end

    lib.registerContext({
        id = 'vehicle_menu',
        title = 'Spawn Vehicle',
        options = options,
        search = true -- Ajoute la fonctionnalité de recherche dans le menu
    })

    lib.showContext('vehicle_menu')
end

function SpawnVehicle(vehicleName, spawnPoint)
    local playerPed = PlayerPedId()

    ESX.Game.SpawnVehicle(vehicleName, spawnPoint, spawnPoint.w, function(vehicle)
        TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
        FreezeEntityPosition(vehicle, true)
        ESX.ShowNotification('Véhicule ~g~' .. vehicleName .. '~s~ spawné avec succès.')

        table.insert(spawnedVehicles, vehicle)
        AddColorChangeOption(vehicle)
        AddDeleteOption(vehicle)
    end)
end

function AddColorChangeOption(vehicle)
    exports.ox_target:addLocalEntity(vehicle, {
        {
            name = 'change_color',
            label = 'Changer la couleur',
            onSelect = function()
                OpenColorPicker(vehicle)
            end,
            canInteract = function(entity)
                return IsPedAPlayer(GetPedInVehicleSeat(entity, -1)) == false
            end
        }
    })
end

function OpenColorPicker(vehicle)
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'openColorPicker',
        vehicleNetId = NetworkGetNetworkIdFromEntity(vehicle)
    })
end

RegisterNUICallback('selectColor', function(data, cb)
    local hex = data.color
    local r, g, b = HexToRGB(hex)
    selectedColor = {r, g, b}
    local vehicle =     NetworkGetEntityFromNetworkId(data.vehicleNetId)
    SetVehicleCustomPrimaryColour(vehicle, selectedColor[1], selectedColor[2], selectedColor[3])
    SetVehicleCustomSecondaryColour(vehicle, selectedColor[1], selectedColor[2], selectedColor[3])
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('closeUI', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

function AddDeleteOption(vehicle)
    exports.ox_target:addLocalEntity(vehicle, {
        {
            name = 'delete_vehicle',
            label = 'Supprimer le véhicule',
            onSelect = function()
                ESX.ShowNotification('Véhicule supprimé.')
                DeleteEntity(vehicle)
                RemoveFromSpawnedVehicles(vehicle)
            end,
            canInteract = function(entity)
                return IsPedAPlayer(GetPedInVehicleSeat(entity, -1)) == false
            end
        }
    })
end

function RemoveFromSpawnedVehicles(vehicle)
    for i, spawnedVehicle in ipairs(spawnedVehicles) do
        if spawnedVehicle == vehicle then
            table.remove(spawnedVehicles, i)
            break
        end
    end
end

function HexToRGB(hex)
    hex = hex:gsub("#","")
    return tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6))
end

