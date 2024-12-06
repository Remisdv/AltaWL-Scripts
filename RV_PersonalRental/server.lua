ESX = exports['es_extended']:getSharedObject()

if Config.InventorySystem then
    if Config.Debug then
        print("Using inventory system")
    end
    ESX.RegisterUsableItem(Config.ItemName, function(source)
        TriggerClientEvent('vehicle_rental:openRentalMenu', source)
    end)
end

if Config.UseCommand then
    if Config.Debug then
        print("Using command system")
    end
    RegisterCommand(Config.CommandName, function(source)
        print('source command', source)
        TriggerClientEvent('vehicle_rental:openRentalMenu', source)
    end, false)
end

-- Server callback to get owned vehicles
ESX.RegisterServerCallback('vehicle_rental:getOwnedVehicles', function(source, cb, playerId)
    local xPlayer = ESX.GetPlayerFromId(source)

    MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE owner = @owner AND rental_expiration IS NULL', {
        ['@owner'] = xPlayer.identifier
    }, function(ownedVehicles)
        cb(ownedVehicles)
    end)
end)

-- Callback to check if the player already has a rented vehicle
ESX.RegisterServerCallback('vehicle_rental:hasRentedVehicle', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)

    MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE owner = @owner AND rental_expiration IS NOT NULL', {
        ['@owner'] = xPlayer.identifier
    }, function(rentedVehicles)
        cb(#rentedVehicles > 0) -- Return true if the player has rented vehicles
    end)
end)

-- Handle sending the rental offer
RegisterNetEvent('vehicle_rental:sendRentalOffer')
AddEventHandler('vehicle_rental:sendRentalOffer', function(targetId, vehiclePlate, rentalPrice, rentalDuration)
    local xPlayer = ESX.GetPlayerFromId(source)
    local targetPlayer = ESX.GetPlayerFromId(targetId)

    -- Check if the player already has a rented vehicle
    MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE owner = @owner AND rental_expiration IS NOT NULL', {
        ['@owner'] = xPlayer.identifier
    }, function(rentedVehicles)
        if #rentedVehicles > 0 then
            -- Notification with ox_lib if player already has a rented vehicle
            TriggerClientEvent('ox_lib:notify', xPlayer.source, {
                type = 'error',
                title = Config.Lang.cant_rent_vehicle,
                description = Config.Lang.already_rented_vehicle
            })
        else
            if targetPlayer and targetPlayer.getMoney() >= rentalPrice then
                TriggerClientEvent('vehicle_rental:receiveRentalOffer', targetId, xPlayer.source, vehiclePlate, rentalPrice, rentalDuration)
            else
                TriggerClientEvent('ox_lib:notify', xPlayer.source, {
                    type = 'error',
                    title = Config.Lang.not_enough_money_title,
                    description = Config.Lang.not_enough_money
                })
            end
        end
    end)
end)

-- Handle the acceptance of the rental offer
RegisterNetEvent('vehicle_rental:acceptRentalOffer')
AddEventHandler('vehicle_rental:acceptRentalOffer', function(sourceId, vehiclePlate, rentalPrice, rentalDuration)
    local xPlayer = ESX.GetPlayerFromId(source)
    local sourcePlayer = ESX.GetPlayerFromId(sourceId)

    if xPlayer.getMoney() >= rentalPrice then
        xPlayer.removeMoney(rentalPrice)
        sourcePlayer.addMoney(rentalPrice)

        if Config.InventorySystem then
            sourcePlayer.removeInventoryItem(Config.ItemName, 1)
        end

        local expirationTime = os.time() + (rentalDuration * 3600)

        MySQL.Async.execute('UPDATE owned_vehicles SET owner = @newOwner, rental_expiration = @rentalExpiration, original_owner = @originalOwner WHERE plate = @plate', {
            ['@newOwner'] = xPlayer.identifier,
            ['@plate'] = vehiclePlate,
            ['@rentalExpiration'] = expirationTime,
            ['@originalOwner'] = sourcePlayer.identifier
        })

        -- Notifications with ox_lib
        TriggerClientEvent('ox_lib:notify', xPlayer.source, {
            type = 'success',
            title = Config.Lang.offer_accepted_title,
            description = Config.Lang.offer_accepted
        })
        TriggerClientEvent('ox_lib:notify', sourcePlayer.source, {
            type = 'success',
            title = Config.Lang.vehicle_transferred_title,
            description = Config.Lang.vehicle_transferred .. vehiclePlate
        })
    else
        TriggerClientEvent('ox_lib:notify', xPlayer.source, {
            type = 'error',
            title = Config.Lang.not_enough_money_title,
            description = Config.Lang.not_enough_money
        })
    end
end)
