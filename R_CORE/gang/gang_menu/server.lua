ESX = exports['es_extended']:getSharedObject()

RegisterCommand('crew', function(source, args, user)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        local playerIdentifier = xPlayer.identifier
        --print("Identifiant du joueur : " .. playerIdentifier)

        -- Vérifiez si le joueur est dans un gang
        MySQL.Async.fetchAll('SELECT gangs.name AS gangName, gang_roles.name AS gangGradeName FROM gang_members JOIN gangs ON gang_members.gang_id = gangs.id JOIN gang_roles ON gang_members.role_id = gang_roles.id WHERE gang_members.user_id = @user_id', {
            ['@user_id'] = playerIdentifier
        }, function(result)
            if result[1] then
                local gangName = result[1].gangName
                local gangGradeName = result[1].gangGradeName
                --print("Joueur dans un gang : " .. gangName .. " avec le grade : " .. gangGradeName)
                
                -- Vérifiez si le joueur est le leader du gang
                MySQL.Async.fetchAll('SELECT * FROM gangs WHERE leader = @leader', {
                    ['@leader'] = playerIdentifier
                }, function(leaderResult)
                    if leaderResult[1] then
                        --print("Le joueur est le leader du gang.")
                        TriggerClientEvent('gangMenu:openGangManagementMenu', source, gangName)
                    else
                        --print("Le joueur n'est pas le leader du gang. Ouverture du menu d'information.")
                        TriggerClientEvent('gangMenu:openGangInfoMenu', source, gangName, gangGradeName)
                    end
                end)
            else
                --print("Aucun gang trouvé pour le joueur. Ouverture du menu de création.")
                TriggerClientEvent('gangMenu:openMenu', source)
            end
        end)
    end
end, false)


ESX.RegisterServerCallback('gang:create', function(source, cb, name, color)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        local playerIdentifier = xPlayer.identifier
        --print("Création du gang pour le joueur : " .. playerIdentifier)

        MySQL.Async.fetchScalar('SELECT gang_id FROM gang_members WHERE user_id = @user_id', {
            ['@user_id'] = playerIdentifier
        }, function(existingGangId)
            if existingGangId then
                --print("Le joueur est déjà dans un gang.")
                cb(false, 'Vous êtes déjà dans un gang.')
            else
                local label = string.gsub(name:lower(), "%s+", "")
                local leader = playerIdentifier

                MySQL.Async.insert('INSERT INTO gangs (name, label, color, leader) VALUES (@name, @label, @color, @leader)', {
                    ['@name'] = name,
                    ['@label'] = label,
                    ['@color'] = color,
                    ['@leader'] = leader
                }, function(id)
                    if id then
                        MySQL.Async.execute('INSERT INTO gang_roles (gang_id, name, grade) VALUES (@gang_id, @name, @grade)', {
                            ['@gang_id'] = id,
                            ['@name'] = 'Leader',
                            ['@grade'] = 0
                        }, function()
                            MySQL.Async.fetchScalar('SELECT id FROM gang_roles WHERE gang_id = @gang_id AND name = @name', {
                                ['@gang_id'] = id,
                                ['@name'] = 'Leader'
                            }, function(roleId)
                                MySQL.Async.execute('INSERT INTO gang_members (gang_id, user_id, role_id, grade) VALUES (@gang_id, @user_id, @role_id, @grade)', {
                                    ['@gang_id'] = id,
                                    ['@user_id'] = leader,
                                    ['@role_id'] = roleId,
                                    ['@grade'] = 0
                                }, function()
                                    -- Créer un rôle par défaut pour le gang
                                    MySQL.Async.execute('INSERT INTO gang_roles (gang_id, name, grade) VALUES (@gang_id, @name, @grade)', {
                                        ['@gang_id'] = id,
                                        ['@name'] = 'Lieutenant',
                                        ['@grade'] = 1
                                    }, function()
                                        --print("Gang et rôle par défaut créés avec succès.")
                                        cb(true)
                                        TriggerClientEvent('gangMenu:openGangManagementMenu', source, name)
                                    end)
                                end)
                            end)
                        end)
                    else
                        --print("Échec de la création du gang.")
                        cb(false, 'Échec de la création du gang.')
                    end
                end)
            end
        end)
    end
end)

ESX.RegisterServerCallback('gang:createRole', function(source, cb, gangName, roleName, grade)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        MySQL.Async.fetchScalar('SELECT id FROM gangs WHERE name = @name', {
            ['@name'] = gangName
        }, function(gangId)
            if gangId then
                MySQL.Async.execute('INSERT INTO gang_roles (gang_id, name, grade) VALUES (@gang_id, @name, @grade)', {
                    ['@gang_id'] = gangId,
                    ['@name'] = roleName,
                    ['@grade'] = grade
                }, function(rowsChanged)
                    if rowsChanged > 0 then
                        --print("Rôle créé avec succès.")
                        cb(true)
                    else
                        --print("Échec de la création du rôle.")
                        cb(false, 'Échec de la création du rôle.')
                    end
                end)
            else
                --print("Gang non trouvé.")
                cb(false, 'Gang non trouvé.')
            end
        end)
    end
end)

ESX.RegisterServerCallback('gang:deleteRole', function(source, cb, gangName, roleName)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        MySQL.Async.fetchScalar('SELECT id FROM gangs WHERE name = @name', {
            ['@name'] = gangName
        }, function(gangId)
            if gangId then
                MySQL.Async.execute('DELETE FROM gang_roles WHERE gang_id = @gang_id AND name = @name', {
                    ['@gang_id'] = gangId,
                    ['@name'] = roleName
                }, function(rowsChanged)
                    if rowsChanged > 0 then
                        --print("Rôle supprimé avec succès.")
                        cb(true)
                    else
                        --print("Échec de la suppression du rôle.")
                        cb(false, 'Échec de la suppression du rôle.')
                    end
                end)
            else
                --print("Gang non trouvé.")
                cb(false, 'Gang non trouvé.')
            end
        end)
    end
end)

ESX.RegisterServerCallback('gang:deleteGang', function(source, cb, gangName)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        MySQL.Async.fetchScalar('SELECT id FROM gangs WHERE name = @name', {
            ['@name'] = gangName
        }, function(gangId)
            if gangId then
                MySQL.Async.execute('DELETE FROM gang_members WHERE gang_id = @gang_id', {
                    ['@gang_id'] = gangId
                }, function()
                    MySQL.Async.execute('DELETE FROM gang_roles WHERE gang_id = @gang_id', {
                        ['@gang_id'] = gangId
                    }, function()
                        MySQL.Async.execute('DELETE FROM gangs WHERE id = @id', {
                            ['@id'] = gangId
                        }, function(rowsChanged)
                            if rowsChanged > 0 then
                                --print("Gang supprimé avec succès.")
                                cb(true)
                            else
                                --print("Échec de la suppression du gang.")
                                cb(false, 'Échec de la suppression du gang.')
                            end
                        end)
                    end)
                end)
            else
                --print("Gang non trouvé.")
                cb(false, 'Gang non trouvé.')
            end
        end)
    end
end)

ESX.RegisterServerCallback('gang:getRoles', function(source, cb, gangName)
    MySQL.Async.fetchAll('SELECT * FROM gang_roles WHERE gang_id = (SELECT id FROM gangs WHERE name = @name) ORDER BY grade ASC', {
        ['@name'] = gangName
    }, function(result)
        cb(result)
    end)
end)

ESX.RegisterServerCallback('gang:getMembers', function(source, cb, gangName)
    MySQL.Async.fetchAll('SELECT gang_members.user_id AS identifier, gang_members.grade, gang_members.id FROM gang_members WHERE gang_members.gang_id = (SELECT id FROM gangs WHERE name = @name) ORDER BY grade ASC', {
        ['@name'] = gangName
    }, function(result)
        local members = {}
        for _, member in ipairs(result) do
            MySQL.Async.fetchAll('SELECT firstname, lastname FROM users WHERE identifier = @identifier', {
                ['@identifier'] = member.identifier
            }, function(nameResult)
                local name = nameResult[1].firstname .. ' ' .. nameResult[1].lastname
                table.insert(members, {
                    id = member.id,
                    name = name,
                    grade = member.grade
                })
                if #members == #result then
                    cb(members)
                end
            end)
        end
    end)
end)

ESX.RegisterServerCallback('gang:assignRole', function(source, cb, gangName, memberId, roleId)
    print(gangName, memberId, roleId)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        -- Fetch the grade from gang_roles table
        MySQL.Async.fetchScalar('SELECT grade FROM gang_roles WHERE id = @roleId', {
            ['@roleId'] = roleId
        }, function(grade)
            if grade then
                -- Update the gang_members table with role_id and grade
                MySQL.Async.execute('UPDATE gang_members SET role_id = @role_id, grade = @grade WHERE id = @id', {
                    ['@role_id'] = roleId,
                    ['@grade'] = grade,
                    ['@id'] = memberId
                }, function(rowsChanged)
                    if rowsChanged > 0 then
                        print("Rôle attribué avec succès.")
                        cb(true)
                    else
                        print("Échec de l'attribution du rôle.")
                        cb(false, 'Échec de l\'attribution du rôle.')
                    end
                end)
            else
                print("Grade not found for roleId: " .. roleId)
                cb(false, 'Grade introuvable pour le rôle sélectionné.')
            end
        end)
    else
        cb(false, 'Joueur introuvable.')
    end
end)

ESX.RegisterServerCallback('gang:removeMember', function(source, cb, gangName, memberId)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        MySQL.Async.execute('DELETE FROM gang_members WHERE id = @id', {
            ['@id'] = memberId
        }, function(rowsChanged)
            if rowsChanged > 0 then
                --print("Membre viré avec succès.")
                cb(true)
            else
                --print("Échec du renvoi du membre.")
                cb(false, 'Échec du renvoi du membre.')
            end
        end)
    end
end)

ESX.RegisterServerCallback('gang:recruitMember', function(source, cb, gangName, playerId)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        local targetPlayer = ESX.GetPlayerFromId(playerId)
        if targetPlayer then
            local targetIdentifier = targetPlayer.identifier
            --print("Identifiant du joueur cible : " .. targetIdentifier)
            MySQL.Async.fetchScalar('SELECT gang_id FROM gang_members WHERE user_id = @user_id', {
                ['@user_id'] = targetIdentifier
            }, function(existingGangId)
                if existingGangId then
                    --print("Le joueur cible est déjà dans un gang.")
                    cb(false, 'Le joueur cible est déjà dans un gang.')
                else
                    MySQL.Async.fetchScalar('SELECT id FROM gangs WHERE name = @name', {
                        ['@name'] = gangName
                    }, function(gangId)
                        if gangId then
                            --print("Identifiant du gang : " .. gangId)
                            MySQL.Async.fetchScalar('SELECT id FROM gang_roles WHERE gang_id = @gang_id AND grade = 1', {
                                ['@gang_id'] = gangId
                            }, function(roleId)
                                if roleId then
                                    --print("Identifiant du rôle par défaut : " .. roleId)
                                    MySQL.Async.execute('INSERT INTO gang_members (gang_id, user_id, role_id, grade) VALUES (@gang_id, @user_id, @role_id, @grade)', {
                                        ['@gang_id'] = gangId,
                                        ['@user_id'] = targetIdentifier,
                                        ['@role_id'] = roleId,
                                        ['@grade'] = 5
                                    }, function(rowsChanged)
                                        if rowsChanged > 0 then
                                            --print("Membre recruté avec succès.")
                                            cb(true)
                                        else
                                            --print("Échec du recrutement du membre.")
                                            cb(false, 'Échec du recrutement du membre.')
                                        end
                                    end)
                                else
                                    --print("Aucun rôle par défaut trouvé.")
                                    cb(false, 'Aucun rôle par défaut trouvé.')
                                end
                            end)
                        else
                            --print("Gang non trouvé.")
                            cb(false, 'Gang non trouvé.')
                        end
                    end)
                end
            end)
        else
            --print("Joueur cible non trouvé.")
            cb(false, 'Joueur cible non trouvé.')
        end
    end
end)

ESX.RegisterServerCallback('gang:leaveGang', function(source, cb, gangName)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        local playerIdentifier = xPlayer.identifier
        MySQL.Async.fetchScalar('SELECT gang_id FROM gang_members WHERE user_id = @user_id', {
            ['@user_id'] = playerIdentifier
        }, function(gangId)
            if gangId then
                MySQL.Async.fetchScalar('SELECT name FROM gangs WHERE id = @id', {
                    ['@id'] = gangId
                }, function(name)
                    if name == gangName then
                        MySQL.Async.execute('DELETE FROM gang_members WHERE user_id = @user_id', {
                            ['@user_id'] = playerIdentifier
                        }, function(rowsChanged)
                            if rowsChanged > 0 then
                                --print("Le joueur a quitté le gang avec succès.")
                                cb(true)
                            else
                                --print("Échec de la sortie du gang.")
                                cb(false, 'Échec de la sortie du gang.')
                            end
                        end)
                    else
                        --print("Le nom du gang ne correspond pas.")
                        cb(false, 'Le nom du gang ne correspond pas.')
                    end
                end)
            else
                --print("Le joueur n\'est dans aucun gang.")
                cb(false, 'Vous n\'êtes dans aucun gang.')
            end
        end)
    end
end)

-- Ajouter la gestion des laboratoires

ESX.RegisterServerCallback('gang:getLabs', function(source, cb, gangName)
    MySQL.Async.fetchAll('SELECT * FROM labs WHERE gang_id = (SELECT id FROM gangs WHERE name = @name)', {
        ['@name'] = gangName
    }, function(result)
        cb(result)
    end)
end)

RegisterNetEvent('gang:placeLab')
AddEventHandler('gang:placeLab', function(labId, x, y, z)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        MySQL.Async.execute('UPDATE labs SET tp_x = @tp_x, tp_y = @tp_y, tp_z = @tp_z, placed = 1 WHERE id = @id', {
            ['@tp_x'] = x,
            ['@tp_y'] = y,
            ['@tp_z'] = z,
            ['@id'] = labId
        }, function(rowsChanged)
            if rowsChanged > 0 then
                TriggerClientEvent('ox_lib:notify', source, {
                    title = 'Laboratoire',
                    description = 'Le laboratoire a été placé avec succès.',
                    type = 'success'
                })
            else
                --print("Erreur: Mise à jour des coordonnées du laboratoire échouée.")
            end
        end)
    end
end)



