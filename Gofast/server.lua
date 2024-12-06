ESX = exports['es_extended']:getSharedObject()

local activeMissions = {}

RegisterNetEvent('goFast:startMission')
AddEventHandler('goFast:startMission', function(drug, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if not xPlayer then
        ----print("Erreur: xPlayer est nil dans goFast:startMission pour l'ID source: " .. tostring(source))
        TriggerClientEvent('ox_lib:notify', source, {type = 'error', text = 'Erreur dans la mission. Contactez un administrateur.'})
        return
    end
    
    local missionLocation = Config.MissionLocations[math.random(#Config.MissionLocations)]
    local missionID = math.random(100000, 999999)
    
    activeMissions[missionID] = {
        player = xPlayer.identifier,
        drug = drug,
        amount = amount,
        location = missionLocation.coords,
        time = missionLocation.time,
        startTime = os.time()
    }
    
    TriggerClientEvent('goFast:missionStarted', source, missionID, missionLocation.coords, missionLocation.time, drug, amount)
    TriggerClientEvent('goFast:missionStartedProgress', source, missionLocation.time)
end)

RegisterNetEvent('goFast:completeMission')
AddEventHandler('goFast:completeMission', function(missionID, drug, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if not xPlayer then
        ----print("Erreur: xPlayer est nil dans goFast:completeMission pour l'ID source: " .. tostring(source))
        TriggerClientEvent('ox_lib:notify', source, {type = 'error', text = 'Erreur dans la mission. Contactez un administrateur.'})
        return
    end
    
    if activeMissions[missionID] then
        local mission = activeMissions[missionID]
        local price = Config.DrugPrices[drug]

        if price and amount then
            local totalPrice = price * amount
            xPlayer.removeInventoryItem(drug, amount)
            xPlayer.addAccountMoney('money', totalPrice)
            TriggerClientEvent('goFast:missionComplete', xPlayer.source, missionID)
            TriggerClientEvent('ox_lib:notify', xPlayer.source, {type = 'success', text = 'Mission accomplie !'})
            TriggerClientEvent('ox_lib:cancelProgress', xPlayer.source)  -- Fermer toutes les barres de progression
            activeMissions[missionID] = nil
        else
            TriggerClientEvent('ox_lib:notify', xPlayer.source, {type = 'error', text = 'Erreur dans la mission. Contactez un administrateur.'})
        end
    end
end)

RegisterNetEvent('goFast:failMission')
AddEventHandler('goFast:failMission', function(missionID)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if not xPlayer then
        --print("Erreur: xPlayer est nil dans goFast:failMission pour l'ID source: " .. tostring(source))
        TriggerClientEvent('ox_lib:notify', source, {type = 'error', text = 'Erreur dans la mission. Contactez un administrateur.'})
        return
    end
    
    if activeMissions[missionID] then
        TriggerClientEvent('ox_lib:notify', xPlayer.source, {type = 'error', text = 'Mission échouée !'})
        activeMissions[missionID] = nil
    end
end)

ESX.RegisterServerCallback('goFast:getDrugCount', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if not xPlayer then
        --print("Erreur: xPlayer est nil dans goFast:getDrugCount pour l'ID source: " .. tostring(source))
        cb({})
        return
    end
    
    local drugCounts = {}
    for _, drug in ipairs(Config.Drugs) do
        local count = xPlayer.getInventoryItem(drug).count
        drugCounts[drug] = count
    end
    cb(drugCounts)
end)

ESX.RegisterServerCallback('goFast:getLSPDCount', function(source, cb)
    local xPlayers = ESX.GetPlayers()
    local lspdCount = 0

    for _, playerId in ipairs(xPlayers) do
        local xPlayer = ESX.GetPlayerFromId(playerId)
        
        if not xPlayer then
            --print("Erreur: xPlayer est nil dans goFast:getLSPDCount pour l'ID playerId: " .. tostring(playerId))
        elseif xPlayer.job.name == 'lspd' then
            lspdCount = lspdCount + 1
        end
    end

    cb(lspdCount)
end)
