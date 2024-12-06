ESX = exports['es_extended']:getSharedObject()

local isMenuOpen = false

function closeAllMenus()
    isMenuOpen = false
    lib.hideContext('gang_menu')
    lib.hideContext('gang_management_menu')
    lib.hideContext('management_menu')
    lib.hideContext('view_roles_menu')
    lib.hideContext('view_members_menu')
    lib.hideContext('gang_info_menu')
end

RegisterNetEvent('gangMenu:openMenu')
AddEventHandler('gangMenu:openMenu', function()
    closeAllMenus()
    if not isMenuOpen then
        isMenuOpen = true
        --print("Ouverture du menu de création de gang.")
        lib.registerContext({
            id = 'gang_menu',
            title = 'Menu Gang',
            options = {
                {
                    title = 'Créer un Gang',
                    event = 'gangMenu:createGang'
                },
                {
                    title = 'Fermer',
                    event = 'gangMenu:closeMenu'
                }
            }
        })
        lib.showContext('gang_menu')
    end
end)

RegisterNetEvent('gangMenu:openGangManagementMenu')
AddEventHandler('gangMenu:openGangManagementMenu', function(gangName)
    closeAllMenus()
    if not isMenuOpen then
        isMenuOpen = true
        --print("Ouverture du menu de gestion de gang pour le gang: " .. gangName)
        lib.registerContext({
            id = 'gang_management_menu',
            title = 'Gestion de Gang - ' .. gangName,
            options = {
                {
                    title = 'Gestion',
                    event = 'gangMenu:openManagementMenu',
                    args = { gangName = gangName }
                },
                {
                    title = 'Supprimer le Gang',
                    event = 'gangMenu:deleteGang',
                    args = { gangName = gangName }
                },
                {
                    title = 'Fermer',
                    event = 'gangMenu:closeMenu'
                }
            }
        })
        lib.showContext('gang_management_menu')
    end
end)

RegisterNetEvent('gangMenu:openManagementMenu')
AddEventHandler('gangMenu:openManagementMenu', function(data)
    closeAllMenus()
    local gangName = data.gangName
    --print("Ouverture du menu de gestion pour le gang: " .. gangName)
    lib.registerContext({
        id = 'management_menu',
        title = 'Gestion - ' .. gangName,
        options = {
            {
                title = 'Créer un Rôle',
                event = 'gangMenu:createRole',
                args = { gangName = gangName }
            },
            {
                title = 'Supprimer un Rôle',
                event = 'gangMenu:deleteRole',
                args = { gangName = gangName }
            },
            {
                title = 'Voir les Rôles',
                event = 'gangMenu:viewRoles',
                args = { gangName = gangName }
            },
            {
                title = 'Recruter le Joueur le Plus Proche',
                event = 'gangMenu:recruitNearestPlayer',
                args = { gangName = gangName }
            },
            {
                title = 'Voir les Membres',
                event = 'gangMenu:viewMembers',
                args = { gangName = gangName }
            },
            {
                title = 'Labo',
                event = 'gangMenu:labo',
                args = { gangName = gangName }
            },
            {
                title = 'Retour',
                event = 'gangMenu:openGangManagementMenu',
                args = { gangName = gangName }
            }
        }
    })
    lib.showContext('management_menu')
end)

RegisterNetEvent('gangMenu:labo')
AddEventHandler('gangMenu:labo', function(data)
    closeAllMenus()
    local gangName = data.gangName
    ESX.TriggerServerCallback('gang:getLabs', function(labs)
        if #labs == 0 then
            lib.notify({ title = 'Info', message = 'Votre gang ne possède aucun laboratoire.', type = 'info' })
            return
        end
        
        local options = {}
        for _, lab in ipairs(labs) do
            local status = lab.placed == 1 and 'Placé' or 'Non placé'
            table.insert(options, {
                title = 'Laboratoire #' .. lab.id .. ' - ' .. status,
                event = 'gangMenu:manageLab',
                args = { lab = lab }
            })
        end
        table.insert(options, {
            title = 'Retour',
            event = 'gangMenu:openManagementMenu',
            args = { gangName = gangName }
        })
        lib.registerContext({
            id = 'view_labs_menu',
            title = 'Laboratoires - ' .. gangName,
            options = options
        })
        lib.showContext('view_labs_menu')
    end, gangName)
end)

RegisterNetEvent('gangMenu:manageLab')
AddEventHandler('gangMenu:manageLab', function(data)
    local lab = data.lab
    if lab.placed == 1 then
        SetNewWaypoint(lab.tp_x, lab.tp_y)
        lib.notify({ title = 'GPS', message = 'Point GPS défini sur le laboratoire.', type = 'success' })
    else
        local alert = lib.alertDialog({
            header = 'Placer le laboratoire',
            content = 'Voulez-vous vraiment placer ce laboratoire ici ?',
            centered = true,
            cancel = true
        })
        if alert == 'confirm' then
            local playerPed = PlayerPedId()
            local coords = GetEntityCoords(playerPed)
            TriggerServerEvent('gang:placeLab', lab.id, coords.x, coords.y, coords.z)
        else
            lib.notify({ title = 'Info', message = 'Placement du laboratoire annulé.', type = 'info' })
        end
    end
end)

-- Autres événements existants
RegisterNetEvent('gangMenu:openGangInfoMenu')
AddEventHandler('gangMenu:openGangInfoMenu', function(gangName, gangGrade)
    closeAllMenus()
    if not isMenuOpen then
        isMenuOpen = true
        --print("Ouverture du menu d'information de gang pour le gang: " .. gangName .. " avec le grade: " .. gangGrade)
        lib.registerContext({
            id = 'gang_info_menu',
            title = 'Info Gang - ' .. gangName,
            options = {
                {
                    title = 'Nom du Gang : ' .. gangName,
                },
                {
                    title = 'Votre Grade : ' .. gangGrade,
                },
                {
                    title = 'Quitter le Gang',
                    event = 'gangMenu:leaveGang',
                    args = { gangName = gangName }
                },
                {
                    title = 'Fermer',
                    event = 'gangMenu:closeMenu'
                }
            }
        })
        lib.showContext('gang_info_menu')
    end
end)

RegisterNetEvent('gangMenu:viewRoles')
AddEventHandler('gangMenu:viewRoles', function(data)
    closeAllMenus()
    local gangName = data.gangName
    ESX.TriggerServerCallback('gang:getRoles', function(roles)
        local options = {}
        for _, role in ipairs(roles) do
            table.insert(options, {
                title = role.name .. ' (Grade: ' .. role.grade .. ')'
            })
        end
        table.insert(options, {
            title = 'Retour',
            event = 'gangMenu:openManagementMenu',
            args = { gangName = gangName }
        })
        lib.registerContext({
            id = 'view_roles_menu',
            title = 'Rôles - ' .. gangName,
            options = options
        })
        lib.showContext('view_roles_menu')
    end, gangName)
end)

RegisterNetEvent('gangMenu:viewMembers')
AddEventHandler('gangMenu:viewMembers', function(data)
    closeAllMenus()
    local gangName = data.gangName
    ESX.TriggerServerCallback('gang:getMembers', function(members)
        local options = {}
        for _, member in ipairs(members) do
            table.insert(options, {
                title = member.name .. ' (Grade: ' .. member.grade .. ')',
                event = 'gangMenu:manageMember',
                args = { gangName = gangName, memberId = member.id, memberName = member.name }
            })
        end
        table.insert(options, {
            title = 'Retour',
            event = 'gangMenu:openManagementMenu',
            args = { gangName = gangName }
        })
        lib.registerContext({
            id = 'view_members_menu',
            title = 'Membres - ' .. gangName,
            options = options
        })
        lib.showContext('view_members_menu')
    end, gangName)
end)

RegisterNetEvent('gangMenu:manageMember')
AddEventHandler('gangMenu:manageMember', function(data)
    closeAllMenus()
    local gangName = data.gangName
    local memberId = data.memberId
    local memberName = data.memberName
    --print("Ouverture du menu de gestion de membre pour: " .. memberName)
    lib.registerContext({
        id = 'manage_member_menu',
        title = 'Gestion de ' .. memberName,
        options = {
            {
                title = 'Attribuer un Rôle',
                event = 'gangMenu:assignRole',
                args = { gangName = gangName, memberId = memberId }
            },
            {
                title = 'Virer du Gang',
                event = 'gangMenu:removeMember',
                args = { gangName = gangName, memberId = memberId }
            },
            {
                title = 'Retour',
                event = 'gangMenu:viewMembers',
                args = { gangName = gangName }
            }
        }
    })
    lib.showContext('manage_member_menu')
end)

RegisterNetEvent('gangMenu:assignRole')
AddEventHandler('gangMenu:assignRole', function(data)
    local gangName = data.gangName
    local memberId = data.memberId
    ESX.TriggerServerCallback('gang:getRoles', function(roles)
        local inputOptions = {}
        for _, role in ipairs(roles) do
            table.insert(inputOptions, {
                label = role.name .. ' (Grade: ' .. role.grade .. ')',
                value = role.id
            })
        end
        local input = lib.inputDialog('Attribuer un Rôle', {
            { type = 'select', label = 'Sélectionnez un Rôle', options = inputOptions, required = true }
        })
        
        if input then
            local roleId = input[1]
            ESX.TriggerServerCallback('gang:assignRole', function(success, message)
                if success then
                    lib.notify({ title = 'Succès', message = 'Rôle attribué avec succès', type = 'success' })
                else
                    lib.notify({ title = 'Erreur', message = message or 'Échec de l\'attribution du rôle', type = 'error' })
                end
            end, gangName, memberId, roleId)
        end
    end, gangName)
end)

RegisterNetEvent('gangMenu:removeMember')
AddEventHandler('gangMenu:removeMember', function(data)
    local gangName = data.gangName
    local memberId = data.memberId
    ESX.TriggerServerCallback('gang:removeMember', function(success, message)
        if success then
            lib.notify({ title = 'Succès', message = 'Membre viré avec succès', type = 'success' })
        else
            lib.notify({ title = 'Erreur', message = message or 'Échec du renvoi du membre', type = 'error' })
        end
    end, gangName, memberId)
end)

RegisterNetEvent('gangMenu:closeMenu')
AddEventHandler('gangMenu:closeMenu', function()
    closeAllMenus()
    --print("Fermeture du menu.")
end)

RegisterNetEvent('gangMenu:createGang')
AddEventHandler('gangMenu:createGang', function()
    local input = lib.inputDialog('Créer un Gang', {
        { type = 'input', label = 'Nom du Gang', required = true },
        { type = 'color', label = 'Couleur', required = true }
    })
    
    if input then
        local name = input[1]
        local color = input[2]
        --print("Création du gang avec le nom: " .. name .. " et la couleur: " .. color)
        
        ESX.TriggerServerCallback('gang:create', function(success, message)
            if success then
                lib.notify({ title = 'Succès', message = 'Gang créé avec succès', type = 'success' })
                TriggerEvent('gangMenu:openGangManagementMenu', name)
            else
                lib.notify({ title = 'Erreur', message = message or 'Échec de la création du gang', type = 'error' })
            end
        end, name, color)
    end
end)

RegisterNetEvent('gangMenu:createRole')
AddEventHandler('gangMenu:createRole', function(data)
    local gangName = data.gangName
    local input = lib.inputDialog('Créer un Rôle', {
        { type = 'input', label = 'Nom du Rôle', required = true },
        { type = 'number', label = 'Grade', required = true }
    })
    
    if input then
        local roleName = input[1]
        local grade = input[2]
        --print("Création du rôle avec le nom: " .. roleName .. " et le grade: " .. grade .. " pour le gang: " .. gangName)
        
        ESX.TriggerServerCallback('gang:createRole', function(success, message)
            if success then
                lib.notify({ title = 'Succès', message = 'Rôle créé avec succès', type = 'success' })
                TriggerEvent('gangMenu:openManagementMenu', { gangName = gangName })
            else
                lib.notify({ title = 'Erreur', message = message or 'Échec de la création du rôle', type = 'error' })
            end
        end, gangName, roleName, grade)
    end
end)

RegisterNetEvent('gangMenu:deleteRole')
AddEventHandler('gangMenu:deleteRole', function(data)
    local gangName = data.gangName
    local input = lib.inputDialog('Supprimer un Rôle', {
        { type = 'input', label = 'Nom du Rôle', required = true }
    })
    
    if input then
        local roleName = input[1]
        --print("Suppression du rôle avec le nom: " .. roleName .. " pour le gang: " .. gangName)
        
        ESX.TriggerServerCallback('gang:deleteRole', function(success, message)
            if success then
                lib.notify({ title = 'Succès', message = 'Rôle supprimé avec succès', type = 'success' })
                TriggerEvent('gangMenu:openManagementMenu', { gangName = gangName })
            else
                lib.notify({ title = 'Erreur', message = message or 'Échec de la suppression du rôle', type = 'error' })
            end
        end, gangName, roleName)
    end
end)

RegisterNetEvent('gangMenu:deleteGang')
AddEventHandler('gangMenu:deleteGang', function(data)
    local gangName = data.gangName
    local input = lib.inputDialog('Supprimer le Gang', {
        { type = 'input', label = 'Confirmez le nom du Gang', required = true }
    })
    
    if input and input[1] == gangName then
        ESX.TriggerServerCallback('gang:deleteGang', function(success, message)
            if success then
                lib.notify({ title = 'Succès', message = 'Gang supprimé avec succès', type = 'success' })
                TriggerEvent('gangMenu:closeMenu')
            else
                lib.notify({ title = 'Erreur', message = message or 'Échec de la suppression du gang', type = 'error' })
            end
        end, gangName)
    else
        lib.notify({ title = 'Erreur', message = 'Le nom du gang ne correspond pas', type = 'error' })
    end
end)

RegisterNetEvent('gangMenu:recruitNearestPlayer')
AddEventHandler('gangMenu:recruitNearestPlayer', function(data)
    local gangName = data.gangName
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer(coords)
    
    if closestPlayer ~= -1 and closestDistance <= 3.0 then
        local targetId = GetPlayerServerId(closestPlayer)
        local targetName = GetPlayerName(closestPlayer)
        local input = lib.inputDialog('Recruter le Joueur', {
            { type = 'input', label = 'Confirmez le nom du joueur à recruter', default = targetName, required = true }
        })
        
        if input and input[1] == targetName then
            ESX.TriggerServerCallback('gang:recruitMember', function(success, message)
                if success then
                    lib.notify({ title = 'Succès', message = 'Joueur recruté avec succès', type = 'success' })
                else
                    lib.notify({ title = 'Erreur', message = message or 'Échec du recrutement du joueur', type = 'error' })
                end
            end, gangName, targetId)
        else
            lib.notify({ title = 'Erreur', message = 'Le nom du joueur ne correspond pas', type = 'error' })
        end
    else
        lib.notify({ title = 'Erreur', message = 'Aucun joueur à proximité', type = 'error' })
    end
end)

RegisterNetEvent('gangMenu:configTerritories')
AddEventHandler('gangMenu:configTerritories', function()
    --print("Configurer les territoires (fonctionnalité à implémenter).")
end)

RegisterNetEvent('gangMenu:leaveGang')
AddEventHandler('gangMenu:leaveGang', function(data)
    local gangName = data.gangName
    local input = lib.inputDialog('Quitter le Gang', {
        { type = 'input', label = 'Confirmez le nom du Gang', required = true }
    })

    if input and input[1] == gangName then
        ESX.TriggerServerCallback('gang:leaveGang', function(success, message)
            if success then
                lib.notify({ title = 'Succès', message = 'Vous avez quitté le gang avec succès', type = 'success' })
                TriggerEvent('gangMenu:closeMenu')
            else
                lib.notify({ title = 'Erreur', message = message or 'Échec de la sortie du gang', type = 'error' })
            end
        end, gangName)
    else
        lib.notify({ title = 'Erreur', message = 'Le nom du gang ne correspond pas', type = 'error' })
    end
end)

