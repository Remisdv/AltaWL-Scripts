-- Fonction pour générer une plaque aléatoire au format XXX 123
function generateRandomPlate()
    local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    local numbers = "0123456789"
    local plate = ""

    for i = 1, 3 do
        plate = plate .. chars:sub(math.random(1, #chars), math.random(1, #chars))
    end

    plate = plate .. " "

    for i = 1, 3 do
        plate = plate .. numbers:sub(math.random(1, #numbers), math.random(1, #numbers))
    end

    return plate
end

-- Fonction pour jouer une animation lors de l'utilisation de la plaque
function playPlateChangeAnimation()
    local playerPed = PlayerPedId()
    RequestAnimDict("anim@amb@clubhouse@tutorial@bkr_tut_ig3@")
    while not HasAnimDictLoaded("anim@amb@clubhouse@tutorial@bkr_tut_ig3@") do
        Citizen.Wait(100)
    end
    TaskPlayAnim(playerPed, "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 8.0, -8.0, -1, 50, 0, false, false, false)
    Citizen.Wait(3000)  -- Attendre que l'animation se termine
    ClearPedTasks(playerPed)  -- Réinitialiser l'animation
end

-- Fonction pour utiliser l'item 'plate'
RegisterNetEvent('qs-inventory:usePlate')
AddEventHandler('qs-inventory:usePlate', function(item)
    if item then
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local vehicle = GetClosestVehicle(playerCoords.x, playerCoords.y, playerCoords.z, 3.0, 0, 70)
        
        if vehicle then
            local oldPlate = GetVehicleNumberPlateText(vehicle)
            local newPlate = item.info.plate or generateRandomPlate()

            -- Jouer l'animation
            playPlateChangeAnimation()

            -- Changer la plaque du véhicule visuellement
            SetVehicleNumberPlateText(vehicle, newPlate)

            -- Mettre à jour la Fakeplate localement
            TriggerServerEvent('qs-inventory:updateFakePlate', oldPlate, newPlate)

            -- Stocker l'ancienne plaque pour référence
            TriggerServerEvent('qs-inventory:giveOriginalPlate', oldPlate)

            -- Supprimer l'item 'plate' après utilisation
            TriggerServerEvent('qs-inventory:removeItem', 'plate', 1)

            TriggerEvent('chat:addMessage', {
                args = {"System", "La plaque du véhicule a été changée en " .. newPlate}
            })
        else
            TriggerEvent('chat:addMessage', {
                args = {"System", "Aucun véhicule à proximité."}
            })
        end
    else
        print("Erreur : l'item est nil")
    end
end)

-- Fonction pour utiliser l'item 'originalplate'
RegisterNetEvent('qs-inventory:useOriginalPlate')
AddEventHandler('qs-inventory:useOriginalPlate', function(item)
    if item then
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local vehicle = GetClosestVehicle(playerCoords.x, playerCoords.y, playerCoords.z, 3.0, 0, 70)
        
        if vehicle then
            local originalPlate = item.info.originalPlate

            -- Jouer l'animation
            playPlateChangeAnimation()

            -- Remettre la plaque originale du véhicule visuellement
            SetVehicleNumberPlateText(vehicle, originalPlate)

            -- Supprimer la Fakeplate localement
            TriggerServerEvent('qs-inventory:removeFakePlate', originalPlate)

            -- Supprimer l'item 'originalplate' après utilisation
            TriggerServerEvent('qs-inventory:removeItem', 'originalplate', 1)

            TriggerEvent('chat:addMessage', {
                args = {"System", "La plaque du véhicule a été remise à " .. originalPlate}
            })
        else
            TriggerEvent('chat:addMessage', {
                args = {"System", "Aucun véhicule à proximité."}
            })
        end
    else
        print("Erreur : l'item est nil")
    end
end)

-- Commande pour se donner une plaque avec un metadata aléatoire
RegisterCommand('giveplate', function()
    local plate = generateRandomPlate()
    TriggerServerEvent('qs-inventory:givePlate', plate)
end, false)
