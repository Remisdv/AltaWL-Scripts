-- Fonction pour jouer une animation lors de l'utilisation de la clé
function playUnlockAnimation()
    local playerPed = PlayerPedId()
    RequestAnimDict("anim@mp_player_intmenu@key_fob@")
    while not HasAnimDictLoaded("anim@mp_player_intmenu@key_fob@") do
        Citizen.Wait(100)
    end
    TaskPlayAnim(playerPed, "anim@mp_player_intmenu@key_fob@", "fob_click", 8.0, -8.0, -1, 50, 0, false, false, false)
    Citizen.Wait(1000)  -- Attendre que l'animation se termine
    ClearPedTasks(playerPed)  -- Réinitialiser l'animation
end

-- Fonction pour vérifier si le joueur a une clé pour le véhicule à proximité
-- Fonction pour supprimer les espaces blancs en début et en fin de chaîne
function trim(s)
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function tryUnlockVehicle()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    -- Récupérer le véhicule le plus proche en utilisant ox_lib
    local vehicle = lib.getClosestVehicle(playerCoords, 3.0, false)

    if vehicle and DoesEntityExist(vehicle) then
        print('Véhicule trouvé')
        local vehiclePlate = GetVehicleNumberPlateText(vehicle)
        local vehicleModel = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))

        -- Récupérer l'inventaire du joueur
        local inventory = exports['qs-inventory']:getUserInventory()

        local hasKey = false

        -- Parcourir l'inventaire pour trouver les clés de voiture
        for slot, item in pairs(inventory) do
            if item.name == 'vehiclekeys' and item.info then
                local lowerItemPlate = string.lower(trim(item.info.plate))
                local lowerVehiclePlate = string.lower(trim(vehiclePlate))
                local lowerItemModel = string.lower(trim(item.info.description))
                local lowerVehicleModel = string.lower(trim(vehicleModel))
        
                print("Item:", item.name, "Info:", item.info, "Plate:", item.info.plate, "Model:", item.info.description)
                print(lowerItemPlate, '==', lowerVehiclePlate, lowerItemModel, '==', lowerVehicleModel)
        
                if lowerItemPlate == lowerVehiclePlate and lowerItemModel == lowerVehicleModel then
                    print('pagnan')
                    hasKey = true
                    break
                end
            end
        end
        

        if hasKey then
            print('ok4')
            playUnlockAnimation()
            ClearPedTasks(playerPed)
            local isLocked = GetVehicleDoorLockStatus(vehicle) > 1
            if isLocked then
                SetVehicleDoorsLocked(vehicle, 1)
                StartVehicleHorn(vehicle, 100, 'HELDDOWN', false)
                SetVehicleLights(vehicle, 2)
                SetVehicleIndicatorLights(vehicle, 0, true)
                SetVehicleIndicatorLights(vehicle, 1, true)
                Citizen.Wait(200)
                SetVehicleIndicatorLights(vehicle, 0, false)
                SetVehicleIndicatorLights(vehicle, 1, false)
                Citizen.Wait(200)
                SetVehicleIndicatorLights(vehicle, 0, true)
                SetVehicleIndicatorLights(vehicle, 1, true)
                Citizen.Wait(200)
                SetVehicleIndicatorLights(vehicle, 0, false)
                SetVehicleIndicatorLights(vehicle, 1, false)
                Citizen.Wait(200)
                SetVehicleLights(vehicle, 0)
            else
                SetVehicleDoorsLocked(vehicle, 2)
                StartVehicleHorn(vehicle, 100, 'HELDDOWN', false)
                Citizen.Wait(200)
                StartVehicleHorn(vehicle, 100, 'HELDDOWN', false)
                SetVehicleLights(vehicle, 2)
                SetVehicleIndicatorLights(vehicle, 0, true)
                SetVehicleIndicatorLights(vehicle, 1, true)
                Citizen.Wait(200)
                SetVehicleIndicatorLights(vehicle, 0, false)
                SetVehicleIndicatorLights(vehicle, 1, false)
                Citizen.Wait(200)
                SetVehicleIndicatorLights(vehicle, 0, true)
                SetVehicleIndicatorLights(vehicle, 1, true)
                Citizen.Wait(200)
                SetVehicleIndicatorLights(vehicle, 0, false)
                SetVehicleIndicatorLights(vehicle, 1, false)
                Citizen.Wait(200)
                SetVehicleLights(vehicle, 0)
            end
        else
            TriggerEvent('chat:addMessage', {
                args = {"System", "Vous n'avez pas la clé pour ce véhicule."}
            })
        end
    else
        TriggerEvent('chat:addMessage', {
            args = {"System", "Aucun véhicule à proximité."}
        })
    end
end


-- Détecter l'appui sur la touche "G"
lib.addKeybind({
    name = 'unlock_vehicle',
    description = 'Unlock Vehicle',
    defaultKey = 'G',
    onReleased = function()
        tryUnlockVehicle()
    end
})

RegisterNetEvent('qs-inventory:giveVehicleKey')
AddEventHandler('qs-inventory:giveVehicleKey', function(plate, model)
    TriggerServerEvent('qs-inventory:giveVehicleKey', plate, model)
end)

RegisterNetEvent('qs-inventory:useCreateKey')
AddEventHandler('qs-inventory:useCreateKey', function()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    -- Récupérer le véhicule le plus proche
    -- local vehicle = GetClosestVehicle(playerCoords.x, playerCoords.y, playerCoords.z, 5.0, 0, 70)
    local vehicle = lib.getClosestVehicle(playerCoords, 5.0, false)
    if vehicle then
        local vehiclePlate = GetVehicleNumberPlateText(vehicle)
        if vehiclePlate and vehiclePlate ~= "" then
            local vehicleModel = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))
            TriggerServerEvent('qs-inventory:createVehicleKey', vehiclePlate, vehicleModel)
        else
            lib.notify({
                title = "Erreur",
                description = "Impossible de trouver la plaque du véhicule.",
                type = "error"
            })
        end
    else
        lib.notify({
            title = "Erreur",
            description = "Aucun véhicule à proximité.",
            type = "error"
        })
    end
end)
