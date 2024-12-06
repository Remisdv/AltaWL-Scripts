ESX = exports["es_extended"]:getSharedObject()

local carsForSale = {}

RegisterServerEvent('selectcar:sellVehicle')
AddEventHandler('selectcar:sellVehicle', function(buyerId, plate, price)
    local xPlayer = ESX.GetPlayerFromId(source)
    local xBuyer = ESX.GetPlayerFromId(buyerId)

    if xBuyer then
        TriggerClientEvent('selectcar:confirmPurchase', buyerId, source, plate, price)
    else
        TriggerClientEvent('esx:showNotification', source, "Acheteur non trouvé.")
    end
end)

RegisterServerEvent('selectcar:confirmPurchase')
AddEventHandler('selectcar:confirmPurchase', function(sellerId, plate, price, confirmed)
    local xPlayer = ESX.GetPlayerFromId(source)
    local xSeller = ESX.GetPlayerFromId(sellerId)

    if confirmed then
        if xPlayer.getMoney() >= price then
            xPlayer.removeMoney(price)
            xSeller.addMoney(price)

            MySQL.Async.execute('UPDATE owned_vehicles SET owner = @newOwner WHERE plate = @plate', {
                ['@newOwner'] = xPlayer.identifier,
                ['@plate'] = plate
            }, function(rowsChanged)
                if rowsChanged > 0 then
                    TriggerClientEvent('esx:showNotification', xSeller.source, "Véhicule vendu avec succès.")
                    TriggerClientEvent('esx:showNotification', xPlayer.source, "Véhicule acheté avec succès.")
                else
                    TriggerClientEvent('esx:showNotification', xSeller.source, "Erreur lors du transfert du véhicule.")
                    TriggerClientEvent('esx:showNotification', xPlayer.source, "Erreur lors du transfert du véhicule.")
                end
            end)
        else
            TriggerClientEvent('esx:showNotification', source, "Vous n'avez pas assez d'argent.")
        end
    else
        TriggerClientEvent('esx:showNotification', xSeller.source, "L'acheteur a refusé l'achat.")
    end
end)


-----------------------KEVLAR---------------

ESX.RegisterUsableItem('armor25', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    TriggerEvent('my_custom_scripts:addShield', source, 25) -- Ajoute 25 de shield
    xPlayer.removeInventoryItem('armor25', 1)
    TriggerClientEvent('esx:showNotification', source, 'Vous avez utilisé un kevlar et gagné 25 de shield')
end)

-- Kevlar qui donne 50 de shield
ESX.RegisterUsableItem('armor50', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    TriggerEvent('my_custom_scripts:addShield', source, 50) -- Ajoute 50 de shield
    xPlayer.removeInventoryItem('armor50', 1)
    TriggerClientEvent('esx:showNotification', source, 'Vous avez utilisé un kevlar et gagné 50 de shield')
end)

-- Kevlar qui donne 100 de shield
ESX.RegisterUsableItem('armor100', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    TriggerEvent('my_custom_scripts:addShield', source, 100) -- Ajoute 100 de shield
    xPlayer.removeInventoryItem('armor100', 1)
    TriggerClientEvent('esx:showNotification', source, 'Vous avez utilisé un kevlar et gagné 100 de shield')
end)

-- Ajouter du shield (côté serveur)
RegisterServerEvent('my_custom_scripts:addShield')
AddEventHandler('my_custom_scripts:addShield', function(source, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    local playerPed = GetPlayerPed(source)
    local currentArmour = GetPedArmour(playerPed)
    SetPedArmour(playerPed, math.min(currentArmour + amount, 100))
end)


