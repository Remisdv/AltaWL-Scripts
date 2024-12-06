ESX = exports['es_extended']:getSharedObject()

local vipRewards = {
    vip1 = 175,
    vip2 = 300,
    vip3 = 600
}

local vipSlots = {
    vip2 = 2,
    vip3 = 3
}

-- Ajouter un VIP
function addVIP(identifier, vipType, duration)
    MySQL.Async.execute('INSERT INTO vip (identifier, vip_type, duration, date_added) VALUES (@identifier, @vip_type, @duration, CURRENT_TIMESTAMP) ON DUPLICATE KEY UPDATE vip_type = @vip_type, duration = @duration, date_added = CURRENT_TIMESTAMP', {
        ['@identifier'] = identifier,
        ['@vip_type'] = vipType,
        ['@duration'] = duration
    }, function(rowsChanged)
        if rowsChanged > 0 then
            print('VIP ajouté ou mis à jour avec succès.')
            -- Ajouter ou mettre à jour les slots de personnage si le VIP est VIP2 ou VIP3
            if vipSlots[vipType] then
                updateCharacterSlots(identifier, vipType)
            end
        else
            print('Erreur lors de l\'ajout ou la mise à jour du VIP.')
        end
    end)
end

-- Mettre à jour les slots de personnage en fonction du type de VIP
function updateCharacterSlots(identifier, vipType)
    local baseIdentifier = identifier:gsub("char%d:", "")
    local slots = vipSlots[vipType]

    MySQL.Async.execute('INSERT INTO multicharacter_slots (identifier, slots) VALUES (@identifier, @slots) ON DUPLICATE KEY UPDATE slots = @slots', {
        ['@identifier'] = baseIdentifier,
        ['@slots'] = slots
    }, function(rowsChanged)
        if rowsChanged > 0 then
            print('Slots de personnage mis à jour pour ' .. baseIdentifier .. ' avec ' .. slots .. ' slots.')
        else
            print('Erreur lors de la mise à jour des slots de personnage.')
        end
    end)
end

-- Exporter la fonction pour qu'elle soit disponible globalement
exports('addVIP', addVIP)

-- Vérifier et supprimer les VIP expirés
function checkAndRemoveExpiredVIPs()
    MySQL.Async.fetchAll('SELECT * FROM vip', {}, function(results)
        for i=1, #results, 1 do
            local vip = results[i]
            local dateAddedTable = vip.date_added / 1000
            print(dateAddedTable)

            if dateAddedTable then
                local durationInSeconds = vip.duration * 30 * 24 * 60 * 60  -- Nombre de mois converti en secondes
                print(os.time() - dateAddedTable)
                if (os.time() - dateAddedTable) > durationInSeconds then
                    MySQL.Async.execute('DELETE FROM vip WHERE identifier = @identifier', {
                        ['@identifier'] = vip.identifier
                    }, function(rowsChanged)
                        if rowsChanged > 0 then
                            print('VIP expiré supprimé: ' .. vip.identifier)
                        end
                    end)
                end
            else
                print('Erreur de conversion de la date pour le VIP: ' .. vip.identifier)
            end
        end
    end)
end

-- Donner des récompenses VIP toutes les 30 minutes
function giveVIPRewards()
    MySQL.Async.fetchAll('SELECT * FROM vip', {}, function(results)
        for i=1, #results, 1 do
            local vip = results[i]
            local xPlayer = ESX.GetPlayerFromIdentifier(vip.identifier)
            
            if xPlayer then
                local reward = vipRewards[vip.vip_type]
                if reward then
                    xPlayer.addMoney(reward)
                    xPlayer.showNotification('Vous avez reçu votre récompense VIP de ' .. reward .. ' $.')
                end
            end
        end
    end)
end

-- Fonction pour vérifier si un joueur est VIP
function isPlayerVIP(identifier, cb)
    MySQL.Async.fetchScalar('SELECT COUNT(*) FROM vip WHERE identifier = @identifier', {
        ['@identifier'] = identifier
    }, function(count)
        cb(count > 0)
    end)
end

-- Fonction pour obtenir le type de VIP d'un joueur
function getPlayerVIPType(identifier, cb)
    MySQL.Async.fetchScalar('SELECT vip_type FROM vip WHERE identifier = @identifier', {
        ['@identifier'] = identifier
    }, function(vipType)
        cb(vipType)
    end)
end

-- Exporter les fonctions pour qu'elles soient disponibles globalement
exports('isPlayerVIP', isPlayerVIP)
exports('getPlayerVIPType', getPlayerVIPType)

-- Chronomètre pour exécuter les fonctions périodiquement
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1800000)  -- 30 minutes en millisecondes
        checkAndRemoveExpiredVIPs()
        giveVIPRewards()
    end
end)

-- Fonctions vides pour ajouter votre propre logique
function customFunction1()
    -- Ajoutez votre logique ici
end

function customFunction2()
    -- Ajoutez votre logique ici
end


