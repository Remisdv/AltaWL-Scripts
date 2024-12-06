RegisterNetEvent('qs-inventory:giveVehicleKey')
AddEventHandler('qs-inventory:giveVehicleKey', function(plate, model)
    local player = source
    local xPlayer = ESX.GetPlayerFromId(player)

    local item = "vehiclekeys"
    local metadata = {plate = plate, description = model}
    local count = 1
    local slot = nil

    -- Ajouter un objet avec métadonnées
    local success = exports['qs-inventory']:AddItem(player, item, count, slot, metadata)
    if success then
        xPlayer.showNotification("Vous avez reçu une clé pour le véhicule : " .. model .. " [" .. plate .. "]")
    else
        xPlayer.showNotification("Erreur lors de l'ajout de l'item.")
    end
end)

ESX.RegisterUsableItem('createkey', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if xPlayer.job.name == 'selectcar' then -- Remplacez 'mechanic' par le nom de votre job spécifique
        TriggerClientEvent('qs-inventory:useCreateKey', source)
    else
        TriggerClientEvent('esx:showNotification', source, "Vous n'avez pas les permissions pour faire cela.")
    end
end)

RegisterNetEvent('qs-inventory:createVehicleKey')
AddEventHandler('qs-inventory:createVehicleKey', function(plate, model)
    local player = source
    local xPlayer = ESX.GetPlayerFromId(player)

    local item = "vehiclekeys"
    local metadata = {plate = plate, description = model}
    local count = 1
    local slot = nil

    -- Ajouter un objet avec métadonnées
    local success = exports['qs-inventory']:AddItem(player, item, count, slot, metadata)
    if success then
        xPlayer.showNotification("Vous avez reçu une clé pour le véhicule : " .. model .. " [" .. plate .. "]")
        xPlayer.removeInventoryItem('createkey', 1)
    else
        xPlayer.showNotification("Erreur lors de l'ajout de l'item.")
    end
end)
