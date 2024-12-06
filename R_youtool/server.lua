-- server/main.lua
ESX = exports["es_extended"]:getSharedObject()

RegisterServerEvent('esx_youtool:completeMission')
AddEventHandler('esx_youtool:completeMission', function(reward, item)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if xPlayer.job.name == 'youtool' then
        xPlayer.addMoney(reward)
        TriggerClientEvent('esx:showNotification', xPlayer.source, 'Mission complétée! Vous avez reçu ' .. reward .. '$.')
        
        -- Ajouter 20 dollars à l'entreprise
        local societyAccount = nil
        TriggerEvent('esx_addonaccount:getSharedAccount', 'society_youtool', function(account)
            societyAccount = account
            if societyAccount then
            
              societyAccount.addMoney(30)
          end
        end)
        
    end
end)

