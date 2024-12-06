ESX = exports['es_extended']:getSharedObject()

-- Function to update the vehicle wear
function CheckAndUpdateUsure(plate)
    MySQL.Async.fetchAll('SELECT kilometrage, usure FROM owned_vehicles WHERE plate = @plate', {
        ['@plate'] = plate
    }, function(result)
        if result[1] then
            local kilometrage = result[1].kilometrage
            local usure = result[1].usure
            local userbase = result[1].usure
            
            if kilometrage <= Config.usurekm then
                usure = usure + 5
            elseif kilometrage <= Config.usurekm2 then
                usure = usure + 10
            elseif kilometrage <= Config.usurekm3 then
                usure = usure + 15
            elseif kilometrage <= Config.usurekm4 then
                usure = usure + 20
            elseif kilometrage > Config.usurekm4 then
                usure = usure + 50
            end
            
            if userbase < usure then
                MySQL.Async.execute('UPDATE owned_vehicles SET usure = @usure WHERE plate = @plate', {
                    ['@usure'] = usure,
                    ['@plate'] = plate
                })
            end
        end
    end)
end

RegisterServerEvent('checkAndUpdateUsure')
AddEventHandler('checkAndUpdateUsure', function(plate)
    CheckAndUpdateUsure(plate)
end)

RegisterServerEvent('checkusure')
AddEventHandler('checkusure', function(plate)
    local source = source
    MySQL.Async.fetchAll('SELECT kilometrage, usure FROM owned_vehicles WHERE plate = @plate', {
        ['@plate'] = plate
    }, function(result)
        if result[1] then
            local usure = result[1].usure
            if usure > 900 then 
                TriggerClientEvent('notifusure', source)
            end
        end
    end)
end)

RegisterServerEvent('checkVehicleWear')
AddEventHandler('checkVehicleWear', function(plate)
    local source = source
    MySQL.Async.fetchScalar('SELECT usure FROM owned_vehicles WHERE plate = @plate', {
        ['@plate'] = plate
    }, function(wear)
        if wear then
            TriggerClientEvent('updateVehicleWear', source, wear)
        end
    end)
end)


ESX.RegisterUsableItem('filtreahuile', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)

    if xPlayer.job.name == 'hayes' then
        TriggerClientEvent('usefiltreahuile', source)
        xPlayer.removeInventoryItem('filtreahuile', 1)
    else
        xPlayer.showNotification('Vous devez être un mécanicien de Hayes pour utiliser cet objet.')
    end
end)

RegisterServerEvent('resetUsure')
AddEventHandler('resetUsure', function(plate)
    MySQL.Async.execute('UPDATE owned_vehicles SET usure = 0 WHERE plate = @plate', {
        ['@plate'] = plate
    }, function(rowsChanged)
        if rowsChanged > 0 then
            --print('Usure reset for vehicle with plate: ' .. plate)
        end
    end)
end)

-- RegisterCommand('tp', function(source, args, rawCommand)
--     if source == 0 then
--         print("Cette commande ne peut pas être exécutée depuis la console.")
--         return
--     end

--     local xPlayer = ESX.GetPlayerFromId(source)

--     if xPlayer then
--         if #args == 3 then
--             local x = tonumber(args[1])
--             local y = tonumber(args[2])
--             local z = tonumber(args[3])

--             if x and y and z then
--                 TriggerClientEvent('esx_teleport:teleport', source, x, y, z)
--                 xPlayer.showNotification(string.format("Téléportation aux coordonnées: %f, %f, %f", x, y, z))
--             else
--                 xPlayer.showNotification("Coordonnées invalides. Utilisez /tp x y z.")
--             end
--         else
--             xPlayer.showNotification("Commande invalide. Utilisez /tp x y z.")
--         end
--     end
-- end, false)