ESX = exports['es_extended']:getSharedObject()

-- Commande pour ouvrir la carte
RegisterCommand("open", function()
    TriggerServerEvent('fetchZoneData')
    SetNuiFocus(true, true)
    SendNUIMessage({ action = "open" })
end, false)

-- Commande pour fermer la carte
RegisterNUICallback("close", function(data, cb)
    SetNuiFocus(false, false)
    SendNUIMessage({ action = "close" })
    cb('ok')
end)

-- Evénement pour ouvrir/fermer la carte
RegisterNetEvent('map:open')
AddEventHandler('map:open', function()
    SetNuiFocus(true, true)
    SendNUIMessage({ action = "open" })
end)

RegisterNetEvent('map:close')
AddEventHandler('map:close', function()
    SetNuiFocus(false, false)
    SendNUIMessage({ action = "close" })
end)

RegisterNetEvent('receiveZoneData')
AddEventHandler('receiveZoneData', function(zones)
    -- Send the data to the NUI (JavaScript)
    SendNUIMessage({
        action = 'updateZones',
        zones = zones
    })
end)


