ESX = exports['es_extended']:getSharedObject()

local attackedLabs = {} -- Table pour suivre les laboratoires attaqués

-- Callback pour obtenir les points de téléportation
ESX.RegisterServerCallback('esx_teleport:getTeleportPoints', function(source, cb)
    MySQL.Async.fetchAll('SELECT * FROM labs', {}, function(results)
        if results then
            cb(results)
        else
            --print("Erreur: Aucun point de téléportation trouvé dans la base de données.")
            cb({})
        end
    end)
end)

-- Fonction pour vérifier si le joueur appartient à un gang
local function isPlayerInGang(identifier, gangId, callback)
    MySQL.Async.fetchScalar('SELECT 1 FROM gang_members WHERE user_id = @user_id AND gang_id = @gangId', {
        ['@user_id'] = identifier,
        ['@gangId'] = gangId
    }, function(result)
        callback(result ~= nil)
    end)
end

-- Fonction pour vérifier le nombre de membres connectés d'un gang
local function getConnectedGangMembers(gangId, callback)
    local connectedMembers = 0
    local players = ESX.GetPlayers()
    local checkedPlayers = 0

    for _, playerId in ipairs(players) do
        local xPlayer = ESX.GetPlayerFromId(playerId)
        if xPlayer then
            local identifier = xPlayer.getIdentifier()
            MySQL.Async.fetchScalar('SELECT 1 FROM gang_members WHERE user_id = @user_id AND gang_id = @gangId', {
                ['@user_id'] = identifier,
                ['@gangId'] = gangId
            }, function(result)
                if result then
                    connectedMembers = connectedMembers + 1
                end
                checkedPlayers = checkedPlayers + 1
                if checkedPlayers == #players then
                    callback(connectedMembers)
                end
            end)
        else
            checkedPlayers = checkedPlayers + 1
            if checkedPlayers == #players then
                callback(connectedMembers)
            end
        end
    end
end

-- Fonction pour envoyer des notifications continues aux membres du gang défenseur
local function notifyDefenderGang(gangId, message, x, y, z)
    local players = ESX.GetPlayers()

    for _, playerId in ipairs(players) do
        local xPlayer = ESX.GetPlayerFromId(playerId)
        if xPlayer then
            local identifier = xPlayer.getIdentifier()
            MySQL.Async.fetchScalar('SELECT 1 FROM gang_members WHERE user_id = @user_id AND gang_id = @gangId', {
                ['@user_id'] = identifier,
                ['@gangId'] = gangId
            }, function(result)
                if result then
                    TriggerClientEvent('ox_lib:notify', playerId, {
                        title = 'Alerte',
                        description = message,
                        type = 'warning'
                    })
                    TriggerClientEvent('esx_teleport:setGps', playerId, x, y, z)
                end
            end)
        end
    end
end

-- Déclaration de guerre
local function startWar(source, point)
    local attackerId = source
    local attackerGang = ESX.GetPlayerFromId(attackerId).job.name  -- Assurez-vous de vérifier la bonne clé ici
    local defenderGang = point.gang_id

    if attackedLabs[point.id] then
        TriggerClientEvent('ox_lib:notify', attackerId, {
            title = 'Déclaration de guerre échouée',
            description = 'Ce laboratoire est déjà attaqué.',
            type = 'error'
        })
        return
    end

    attackedLabs[point.id] = true

    -- Vérification du nombre de membres du gang défenseur connectés
    getConnectedGangMembers(defenderGang, function(connectedMembers)
        --print('connectedMembers: ' .. connectedMembers)
        if connectedMembers >= 5 then  -- Valeur modifiable
            -- Envoi des notifications au gang défenseur et mise en place du GPS
            notifyDefenderGang(defenderGang, 'Votre laboratoire est attaqué !', point.tp_x, point.tp_y, point.tp_z)

            -- Envoi des notifications répétées
            Citizen.CreateThread(function()
                while warActive do
                    notifyDefenderGang(defenderGang, 'Votre laboratoire est attaqué !', point.tp_x, point.tp_y, point.tp_z)
                    Citizen.Wait(10000)  -- Notification toutes les 10 secondes
                end
            end)

            -- Lancement du contrôle de la zone pendant 30 minutes
            TriggerClientEvent('esx_teleport:startWar', attackerId, point.id, attackerGang, defenderGang)
        else
            TriggerClientEvent('ox_lib:notify', attackerId, {
                title = 'Déclaration de guerre échouée',
                description = 'Pas assez de membres du gang défenseur connectés.',
                type = 'error'
            })
        end
    end)
end

-- Gestion des téléportations et de la déclaration de guerre
RegisterServerEvent('esx_teleport:handleTeleport')
AddEventHandler('esx_teleport:handleTeleport', function(pointId, isReturn)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if not xPlayer then
        --print("Erreur: Impossible de récupérer le joueur.")
        return
    end

    local identifier = xPlayer.getIdentifier()

    MySQL.Async.fetchAll('SELECT * FROM labs WHERE id = @id', {
        ['@id'] = pointId
    }, function(results)
        if results and #results > 0 then
            local point = results[1]
            local dest_x, dest_y, dest_z

            if isReturn then
                dest_x, dest_y, dest_z = point.tp_x, point.tp_y, point.tp_z
            else
                dest_x, dest_y, dest_z = point.dest_x, point.dest_y, point.dest_z
            end

            if point.gang_id == nil then
                -- Vérifier si les coordonnées de destination ne sont pas nulles
                if dest_x and dest_y and dest_z then
                    -- Téléporter directement si aucun gang n'est requis
                    TriggerClientEvent('esx_teleport:teleportPlayer', _source, dest_x, dest_y, dest_z)
                    xPlayer.showNotification("Vous avez été téléporté.")
                else
                    --print("Erreur: Les coordonnées de destination sont nulles.")
                end
            else
                -- Vérifier l'appartenance au gang
                isPlayerInGang(identifier, point.gang_id, function(isInGang)
                    if isInGang then
                        -- Vérifier si les coordonnées de destination ne sont pas nulles
                        if dest_x and dest_y and dest_z then
                            TriggerClientEvent('esx_teleport:teleportPlayer', _source, dest_x, dest_y, dest_z)
                            xPlayer.showNotification("Vous avez été téléporté.")
                        else
                            --print("Erreur: Les coordonnées de destination sont nulles.")
                        end
                    else
                        -- Déclaration de guerre avec validation
                        --print("Déclenchement de la validation de guerre depuis le serveur")
                        TriggerClientEvent('ox_lib:validateWar', _source, point.id)
                    end
                end)
            end
        else
            --print("Erreur: Aucun point de téléportation trouvé avec l'ID spécifié.")
        end
    end)
end)

RegisterServerEvent('esx_teleport:confirmWar')
AddEventHandler('esx_teleport:confirmWar', function(pointId)
    local _source = source
    --print("Confirmation de la guerre reçue du client")

    MySQL.Async.fetchAll('SELECT * FROM labs WHERE id = @id', {
        ['@id'] = pointId
    }, function(results)
        if results and #results > 0 then
            local point = results[1]
            startWar(_source, point)
        else
            --print("Erreur: Aucun point de téléportation trouvé avec l'ID spécifié.")
        end
    end)
end)

-- Fin de la guerre
RegisterServerEvent('esx_teleport:endWar')
AddEventHandler('esx_teleport:endWar', function(pointId, attackerWon)
    warActive = false
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local identifier = xPlayer.getIdentifier()

    MySQL.Async.fetchAll('SELECT * FROM labs WHERE id = @id', {
        ['@id'] = pointId
    }, function(results)
        if results and #results > 0 then
            local point = results[1]
            local defenderGang = point.gang_id

            MySQL.Async.fetchScalar('SELECT gang_id FROM gang_members WHERE user_id = @user_id', {
                ['@user_id'] = identifier
            }, function(attackerGang)
                if not attackerGang then
                    --print("Erreur: Impossible de récupérer le gang de l'attaquant.")
                    return
                end

                if attackerWon then
                    -- Mettre à jour la propriété du labo et réinitialiser les coordonnées de téléportation
                    MySQL.Async.execute('UPDATE labs SET gang_id = @gangId, tp_x = 0, tp_y = 0, tp_z = 0, placed = 0 WHERE id = @id', {
                        ['@gangId'] = attackerGang,
                        ['@id'] = pointId
                    }, function(rowsChanged)
                        if rowsChanged > 0 then
                            TriggerClientEvent('ox_lib:notify', _source, {
                                title = 'Guerre de labo',
                                description = 'Votre gang a pris possession du laboratoire.',
                                type = 'success'
                            })
                        else
                            --print("Erreur: Mise à jour de la propriété du labo échouée.")
                        end
                    end)
                else
                    -- Notification de la défaite
                    TriggerClientEvent('ox_lib:notify', _source, {
                        title = 'Guerre de labo',
                        description = 'Votre gang a perdu la guerre pour le laboratoire.',
                        type = 'error'
                    })
                end

                -- Réinitialiser l'état du laboratoire attaqué
                attackedLabs[pointId] = nil
            end)
        else
            --print("Erreur: Aucun point de téléportation trouvé avec l'ID spécifié.")
        end
    end)
end)

-- Notification pour les membres du gang défenseur
RegisterNetEvent('esx_teleport:notifyDefenders')
AddEventHandler('esx_teleport:notifyDefenders', function(defenderGang, x, y, z)
    notifyDefenderGang(defenderGang, 'Votre laboratoire est attaqué !', x, y, z)
end)
