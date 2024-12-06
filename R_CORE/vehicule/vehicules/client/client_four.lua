ESX = exports['es_extended']:getSharedObject()

local poundCoords = vector3(216.23295593262, -810.02966308594, 30.720155715942)
local spawnCoords = {
    vector4(219.45950317383, -808.78350830078, 30.688886642456, 246.66325378418),
    vector4(220.72196960449, -806.64837646484, 30.686986923218, 257.12225341797),
    vector4(221.90243530273, -804.10601806641, 30.679203033447, 250.24378967285),
    vector4(222.77317810059, -801.69146728516, 30.666576385498, 240.42053222656),
    vector4(223.61528015137, -799.22253417969, 30.662517547607, 241.50344848633),
    vector4(224.64392089844, -796.59954833984, 30.665767669678, 247.51889038086),
    vector4(225.33242797852, -794.13751220703, 30.67248916626, 243.85992431641),
    vector4(226.12121582031, -791.68585205078, 30.67970085144, 257.55493164062),
    vector4(226.12121582031, -791.68585205078, 30.67970085144, 257.55493164062),
    vector4(228.09439086914, -786.61083984375, 30.69965171814, 246.64147949219),
    vector4(229.07040405273, -784.29034423828, 30.705402374268, 254.8974609375),
    vector4(230.06991577148, -781.35748291016, 30.702981948853, 238.55191040039)
}
local pedCoords = vector4(215.72755432129, -810.58251953125, 29.720121383667, 252.33609008789)

-- Blip pour la fourrière
Citizen.CreateThread(function()
    local blip = AddBlipForCoord(poundCoords)
    SetBlipSprite(blip, 67)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.4)
    SetBlipColour(blip, 3)
    SetBlipAsShortRange(blip, true)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Fourrière")
    EndTextCommandSetBlipName(blip)
end)

-- Créer le ped
Citizen.CreateThread(function()
    RequestModel(GetHashKey("mp_m_waremech_01"))
    while not HasModelLoaded(GetHashKey("mp_m_waremech_01")) do
        Wait(1)
    end

    local ped = CreatePed(4, GetHashKey("mp_m_waremech_01"), pedCoords.x, pedCoords.y, pedCoords.z, pedCoords.w, false, true)
    SetEntityAsMissionEntity(ped, true, true)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
end)

-- Fonction pour ouvrir le menu de la fourrière
function OpenPoundMenu()
    TriggerServerEvent('getOwnedVehicles')
end

RegisterNetEvent('receiveOwnedVehicles')
AddEventHandler('receiveOwnedVehicles', function(vehicles)
    local menu = {}

    for _, vehicle in ipairs(vehicles) do
        local data = json.decode(vehicle.vehicle)
        local vehicleModel = GetDisplayNameFromVehicleModel(data.model)
        table.insert(menu, {
            title = vehicleModel .. ' (' .. data.plate .. ')',
            description = data.model,
            event = 'retrieveVehicle',
            args = vehicle
        })
    end
    
    lib.registerContext({
        id = 'pound_menu',
        title = 'Fourrière',
        options = menu
    })

    lib.showContext('pound_menu')
end)

RegisterNetEvent('retrieveVehicle')
AddEventHandler('retrieveVehicle', function(vehicle)
    ESX.TriggerServerCallback('pound:payFee', function(success)
        if success then
            local spawnCoord = GetFreeSpawnPoint()
            SpawnVehicle(vehicle, spawnCoord)
            DeleteExistingVehicle(vehicle)
            TriggerServerEvent('retrieveVehicle', vehicle, spawnCoord)
            lib.notify({
                title = 'Fourrière',
                description = 'Vous avez payé 200$ pour récupérer votre véhicule.',
                type = 'success'
            })
        else
            lib.notify({
                title = 'Fourrière',
                description = 'Vous n\'avez pas assez d\'argent.',
                type = 'error'
            })
        end
    end, 800)
end)

function GetFreeSpawnPoint()
    for _, coords in ipairs(spawnCoords) do
        if not IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, 3.0) then
            return coords
        end
    end
    return spawnCoords[1] -- Default to the first spawn point if all are occupied
end

-- Fonction pour faire spawn le véhicule
function SpawnVehicle(vehicle, coords)
    local data = json.decode(vehicle.vehicle)
    RequestModel(data.model)
    while not HasModelLoaded(data.model) do
        Wait(1)
    end
   
    local spawnedVehicle = CreateVehicle(data.model, coords.x, coords.y, coords.z, coords.w, true, true)
    SetVehicleNeedsToBeHotwired(vehicle, false)
    SetVehicleHasBeenOwnedByPlayer(vehicle, true)
    SetEntityAsMissionEntity(vehicle, true, true)
    SetVehicleIsStolen(vehicle, false)
    SetVehicleIsWanted(vehicle, false)
    SetVehRadioStation(vehicle, 'OFF')
    Wait(100)
    lib.setVehicleProperties(spawnedVehicle, data)
    local count = 0
    while not DoesEntityExist(spawnedVehicle) do
        Wait(1000)
        count = count + 1
        if DoesEntityExist(spawnedVehicle) then
            lib.setVehicleProperties(spawnedVehicle, data)
            break
        else
            print('Failed to spawn vehicle with plate ' .. vehicle.plate)
        end
    end
end

-- Fonction pour vérifier et supprimer un véhicule existant
function DeleteExistingVehicle(vehicle)
    local data = json.decode(vehicle.vehicle)
    local coord = vehicle.position and json.decode(vehicle.position) or nil
    if coord then
        local existingVehicle = GetClosestVehicle(coord.x, coord.y, coord.z, 3.0, data.model, 70)
        SetEntityAsMissionEntity(existingVehicle, true, true)
        DeleteVehicle(existingVehicle)
    else
        print('Vehicle position not found for deletion.')
    end
end

-- Interaction avec la fourrière
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        local playerCoords = GetEntityCoords(PlayerPedId())
        if #(playerCoords - poundCoords) < 3.0 then
            while #(playerCoords - poundCoords) < 3.0 do
                Citizen.Wait(5)
                playerCoords = GetEntityCoords(PlayerPedId())
                lib.showTextUI("[E] - Fourrière")
                if IsControlJustReleased(0, 38) then
                    lib.hideTextUI()
                    OpenPoundMenu()
                end
            end
            lib.hideTextUI()
        end
    end
end)
