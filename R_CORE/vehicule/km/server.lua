ESX = exports['es_extended']:getSharedObject()

-- Update the distance traveled
RegisterServerEvent('esx_vehicle:updateDistance')
AddEventHandler('esx_vehicle:updateDistance', function(plate, distance)
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.Async.execute('UPDATE owned_vehicles SET kilometrage = kilometrage + @distance WHERE plate = @plate', {
        ['@distance'] = distance,
        ['@plate'] = plate
    })
end)

-- Handle request for kilometers
RegisterServerEvent('esx_vehicle:requestKilometers')
AddEventHandler('esx_vehicle:requestKilometers', function(plate)
    local src = source
    MySQL.Async.fetchScalar('SELECT kilometrage FROM owned_vehicles WHERE plate = @plate', {
        ['@plate'] = plate
    }, function(kilometrage)
        if kilometrage then
            local km = kilometrage / 1000
            km = math.floor(km * 10) / 10 -- Round to 1 decimal place
            TriggerClientEvent('esx_vehicle:showKilometers', src, km)
        else
            TriggerClientEvent('esx_vehicle:showKilometers', src, 'N/A')
        end
    end)
end)

-- Generate numserie if empty
MySQL.ready(function()
    MySQL.Async.fetchAll('SELECT plate FROM owned_vehicles WHERE numserie IS NULL OR numserie = ""', {}, function(result)
        for i=1, #result, 1 do
            local numserie = 'NS' .. math.random(111111, 999999)
            MySQL.Async.execute('UPDATE owned_vehicles SET numserie = @numserie WHERE plate = @plate', {
                ['@numserie'] = numserie,
                ['@plate'] = result[i].plate
            })
        end
    end)
end)
