ESX = exports['es_extended']:getSharedObject()

-- Callback pour obtenir les véhicules possédés
RegisterServerEvent('getOwnedVehicles')
AddEventHandler('getOwnedVehicles', function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local identifier = xPlayer.getIdentifier()
    
    MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE owner = @owner', {
        ['@owner'] = identifier
    }, function(result)
        TriggerClientEvent('receiveOwnedVehicles', _source, result)
    end)
end)

RegisterServerEvent('retrieveVehicle')
AddEventHandler('retrieveVehicle', function(vehicle)

    local xPlayer = ESX.GetPlayerFromId(source)
    local amount = 50
    -- Vérifiez si le joueur a assez d'argent
    xPlayer.removeAccountMoney('bank', amount)
end)

ESX.RegisterServerCallback('pound:payFee', function(source, cb, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.getMoney() >= 50 then
        xPlayer.removeMoney(50)
        cb(true)
    else
        cb(false)
    end
end)

RegisterServerEvent('retrieveVehicle')
AddEventHandler('retrieveVehicle', function(vehicle, spawnCoord)
    local xPlayer = ESX.GetPlayerFromId(source)
    local plate = vehicle.plate
    local position = json.encode({
        x = spawnCoord.x,
        y = spawnCoord.y,
        z = spawnCoord.z,
        heading = spawnCoord.w
    })

    MySQL.Async.execute('UPDATE owned_vehicles SET position = @position, stored = 0 WHERE plate = @plate AND owner = @owner', {
        ['@position'] = position,
        ['@plate'] = plate,
        ['@owner'] = xPlayer.identifier
    }, function(rowsChanged)
    end)
end)

ESX.RegisterServerCallback('getOwnedVehicles', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE owner = @owner', {
        ['@owner'] = xPlayer.identifier
    }, function(result)
        cb(result)
    end)
end)
