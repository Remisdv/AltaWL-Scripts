ESX = exports['es_extended']:getSharedObject()

-- Fetch zone data from the database
RegisterServerEvent('fetchZoneData')
AddEventHandler('fetchZoneData', function()
    local _source = source
    MySQL.Async.fetchAll('SELECT * FROM zones', {}, function(result)
        if result then
            TriggerClientEvent('receiveZoneData', _source, result)
        end
    end)
end)
