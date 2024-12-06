ESX = exports["es_extended"]:getSharedObject()

RegisterCommand('vehicule', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)

    if xPlayer.job.name == 'youtool' and (xPlayer.job.grade == 2 or xPlayer.job.grade == 3) then
        TriggerClientEvent('openVehicleMenu', source)
    else
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Accès refusé',
            description = "Vous n'avez pas accès à ce menu.",
            type = 'error'
        })
    end
end, false)

RegisterNetEvent('spawnVehicle')
AddEventHandler('spawnVehicle', function(model, price)
    local xPlayer = ESX.GetPlayerFromId(source)

    if xPlayer.getMoney() >= price then
        xPlayer.removeMoney(price)
        TriggerClientEvent('esx:spawnVehicle', source, model)
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Achat Réussi',
            description = "Vous avez acheté un " .. model .. " pour $" .. price,
            type = 'success'
        })
    else
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Fonds insuffisants',
            description = "Vous n'avez pas assez d'argent.",
            type = 'error'
        })
    end
end)

ESX.RegisterServerCallback('youtool:isPlateTaken', function(source, cb, plate)
    MySQL.scalar('SELECT plate FROM owned_vehicles WHERE plate = ?', {plate},
    function(result)
        cb(result ~= nil)
    end)
end)

RegisterNetEvent('youtool:giveVehicleKey')
AddEventHandler('youtool:giveVehicleKey', function(plate, model)
    local player = source
    local xPlayer = ESX.GetPlayerFromId(player)

    local item = "vehiclekeys"
    local metadata = {plate = plate, description = model}
    local count = 1
    local slot = nil

    -- Ajouter un objet avec métadonnées
    local success = exports['qs-inventory']:AddItem(player, item, count, slot, metadata)
    if success then
        TriggerClientEvent('ox_lib:notify', player, {title = "Succès", description = "Vous avez reçu une clé pour le véhicule : " .. model .. " [" .. plate .. "]", type = "success"})
    else
        TriggerClientEvent('ox_lib:notify', player, {title = "Erreur", description = "Erreur lors de l'ajout de l'item.", type = "error"})
    end
end)

RegisterNetEvent('youtool:buyVehicle')
AddEventHandler('youtool:buyVehicle', function(vehicle, spawnPosition)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    MySQL.Async.fetchAll("INSERT INTO owned_vehicles (owner, plate, vehicle, position) VALUES (@owner, @plate, @vehicle, @position)", { 
        ["@owner"] = xPlayer.identifier,
        ["@plate"] = vehicle.plate,
        ["@vehicle"] = json.encode(vehicle),
        ["@position"] = json.encode(spawnPosition)
    }, function(a)
    end)
    --TriggerClientEvent('stg_vehicleshop:buyVehicle', src, vehicle)
end)
