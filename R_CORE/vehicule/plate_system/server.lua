ESX = exports['es_extended']:getSharedObject()

ESX.RegisterUsableItem('plate', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    local item = xPlayer.getInventoryItem('plate')
    if item then
        TriggerClientEvent('qs-inventory:usePlate', source, item)
    end
end)

ESX.RegisterUsableItem('originalplate', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    local item = xPlayer.getInventoryItem('originalplate')
    if item then
        TriggerClientEvent('qs-inventory:useOriginalPlate', source, item)
    end
end)

RegisterNetEvent('qs-inventory:givePlate')
AddEventHandler('qs-inventory:givePlate', function(plate)
    local player = source
    local xPlayer = ESX.GetPlayerFromId(player)

    local item = "plate"
    local metadata = {plate = plate}
    local count = 1
    local slot = nil

    -- Ajouter l'item 'plate' avec les métadonnées
    local success = exports['qs-inventory']:AddItem(player, item, count, slot, metadata)
    if success then
        xPlayer.showNotification("Vous avez reçu une plaque : " .. plate)
    else
        xPlayer.showNotification("Erreur lors de l'ajout de l'item.")
    end
end)

RegisterNetEvent('qs-inventory:giveOriginalPlate')
AddEventHandler('qs-inventory:giveOriginalPlate', function(oldPlate)
    local player = source
    local xPlayer = ESX.GetPlayerFromId(player)

    local item = "originalplate"
    local metadata = {originalPlate = oldPlate}
    local count = 1
    local slot = nil

    -- Ajouter l'item 'originalplate' avec les métadonnées
    local success = exports['qs-inventory']:AddItem(player, item, count, slot, metadata)
    if success then
        xPlayer.showNotification("Vous avez reçu la plaque d'origine : " .. oldPlate)
    else
        xPlayer.showNotification("Erreur lors de l'ajout de l'item.")
    end
end)

-- Supprimer l'item après utilisation
RegisterNetEvent('qs-inventory:removeItem')
AddEventHandler('qs-inventory:removeItem', function(itemName, count)
    local player = source
    local xPlayer = ESX.GetPlayerFromId(player)

    xPlayer.removeInventoryItem(itemName, count)
end)

RegisterNetEvent('qs-inventory:updateFakePlate')
AddEventHandler('qs-inventory:updateFakePlate', function(oldPlate, newPlate)
    local player = source
    local xPlayer = ESX.GetPlayerFromId(player)
    local identifier = xPlayer.getIdentifier()

    if oldPlate and newPlate then
        print("Updating Fakeplate from " .. oldPlate .. " to " .. newPlate .. " for player " .. identifier)

        MySQL.Async.execute('UPDATE owned_vehicles SET Fakeplate = @newPlate WHERE owner = @identifier AND plate = @oldPlate', {
            ['@newPlate'] = newPlate,
            ['@identifier'] = identifier,
            ['@oldPlate'] = oldPlate
        }, function(rowsChanged)
            if rowsChanged == 0 then
                print("Erreur lors de la mise à jour de la plaque.")
                xPlayer.showNotification("Erreur lors de la mise à jour de la plaque.")
            else
                print("La plaque du véhicule a été mise à jour.")
                xPlayer.showNotification("La plaque du véhicule a été mise à jour.")
            end
        end)
    else
        print("Erreur : oldPlate ou newPlate est nil")
    end
end)

RegisterNetEvent('qs-inventory:removeFakePlate')
AddEventHandler('qs-inventory:removeFakePlate', function(plate)
    local player = source
    local xPlayer = ESX.GetPlayerFromId(player)
    local identifier = xPlayer.getIdentifier()

    if plate then
        print("Removing Fakeplate for plate " .. plate .. " for player " .. identifier)

        MySQL.Async.execute('UPDATE owned_vehicles SET Fakeplate = NULL WHERE owner = @identifier AND plate = @plate', {
            ['@plate'] = plate,
            ['@identifier'] = identifier
        }, function(rowsChanged)
            if rowsChanged == 0 then
                print("Erreur lors de la suppression de la Fakeplate.")
                xPlayer.showNotification("Erreur lors de la suppression de la Fakeplate.")
            else
                print("La Fakeplate du véhicule a été supprimée.")
                xPlayer.showNotification("La Fakeplate du véhicule a été supprimée.")
            end
        end)
    else
        print("Erreur : plate est nil")
    end
end)
