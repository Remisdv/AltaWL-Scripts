ESX = exports['es_extended']:getSharedObject()

ESX.RegisterServerCallback('getBankAccounts', function(source, cb)
    MySQL.Async.fetchAll('SELECT identifier, firstname, lastname, JSON_EXTRACT(accounts, "$.bank") AS bank FROM users', {}, function(accounts)
        if accounts then
            --print('Comptes bancaires récupérés : ', json.encode(accounts))
        else
            --print('Aucun compte bancaire trouvé')
        end
        cb(accounts)
    end)
end)

ESX.RegisterServerCallback('getAccountTransactions', function(source, cb, identifier)
    MySQL.Async.fetchAll('SELECT date, value, type FROM okokBanking_transactions WHERE sender_identifier = @identifier OR receiver_identifier = @identifier', {
        ['@identifier'] = identifier
    }, function(transactions)
        if transactions then
            --print('Transactions pour le compte ' .. identifier .. ' : ', json.encode(transactions))
        else
            --print('Aucune transaction trouvée pour le compte ' .. identifier)
        end
        cb(transactions)
    end)
end)

RegisterServerEvent('bank:addMoney')
AddEventHandler('bank:addMoney', function(identifier, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    local targetPlayer = ESX.GetPlayerFromIdentifier(identifier)
    local bankAccount = "society_lspd"

    if targetPlayer then
        -- Vérifier si la banque a suffisamment de fonds
        TriggerEvent('esx_addonaccount:getSharedAccount', bankAccount, function(account)
            if account.money >= amount then
                -- Retirer de l'argent du compte de l'entreprise
                account.removeMoney(amount)

                -- Ajouter de l'argent au compte du joueur
                targetPlayer.addAccountMoney('bank', amount)

                -- Enregistrer la transaction
                MySQL.Async.execute('INSERT INTO okokBanking_transactions (receiver_identifier, receiver_name, sender_identifier, sender_name, date, value, type) VALUES (@receiver_identifier, @receiver_name, @sender_identifier, @sender_name, NOW(), @value, @type)', {
                    ['@receiver_identifier'] = identifier,
                    ['@receiver_name'] = targetPlayer.getName(),
                    ['@sender_identifier'] = 'bank',
                    ['@sender_name'] = 'Bank Account',
                    ['@value'] = amount,
                    ['@type'] = 'transfer'
                })

                TriggerClientEvent('esx:showNotification', xPlayer.source, 'Ajouté $' .. amount .. ' au compte du joueur.')
            else
                TriggerClientEvent('esx:showNotification', xPlayer.source, 'La banque n\'a pas assez de fonds.')
            end
        end)
    else
        TriggerClientEvent('esx:showNotification', xPlayer.source, 'Le joueur cible n\'est pas en ligne.')
    end
end)

RegisterServerEvent('bank:removeMoney')
AddEventHandler('bank:removeMoney', function(identifier, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    local targetPlayer = ESX.GetPlayerFromIdentifier(identifier)
    local bankAccount = "society_lspd"

    if targetPlayer then
        -- Retirer de l'argent du compte du joueur
        targetPlayer.removeAccountMoney('bank', amount)

        -- Ajouter de l'argent au compte de l'entreprise
        TriggerEvent('esx_addonaccount:getSharedAccount', bankAccount, function(account)
            account.addMoney(amount)
        end)

        -- Enregistrer la transaction
        MySQL.Async.execute('INSERT INTO okokBanking_transactions (receiver_identifier, receiver_name, sender_identifier, sender_name, date, value, type) VALUES (@receiver_identifier, @receiver_name, @sender_identifier, @sender_name, NOW(), @value, @type)', {
            ['@receiver_identifier'] = 'bank',
            ['@receiver_name'] = 'Bank Account',
            ['@sender_identifier'] = identifier,
            ['@sender_name'] = targetPlayer.getName(),
            ['@value'] = amount,
            ['@type'] = 'transfer'
        })

        TriggerClientEvent('esx:showNotification', xPlayer.source, 'Retiré $' .. amount .. ' du compte du joueur.')
    else
        TriggerClientEvent('esx:showNotification', xPlayer.source, 'Le joueur cible n\'est pas en ligne.')
    end
end)
