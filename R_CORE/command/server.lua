ESX = exports['es_extended']:getSharedObject()

local function hasPermission(xPlayer, allowedGroups)
    local playerGroup = xPlayer.getGroup()
    for _, group in ipairs(allowedGroups) do
        if group == playerGroup then
            return true
        end
    end
    return false
end



ESX.RegisterCommand('wipeid', {'admin', 'responsable'}, function(xPlayer, args, showError)
    if not hasPermission(xPlayer, {"admin", "responsable"}) then
        showError('You do not have permission to use this command.')
        return
    end
    local targetId = args.playerId
    WipePlayer(targetId)
end, false, {help = 'Wipe player by ID', validate = true, arguments = {{name = 'playerId', help = 'Player ID', type = 'number'}}})

ESX.RegisterCommand('wipe', {'admin', 'responsable'}, function(xPlayer, args, showError)
    if not hasPermission(xPlayer, {"admin", "responsable"}) then
        showError('You do not have permission to use this command.')
        return
    end
    local identifier = args.identifier
    WipePlayerByIdentifier(identifier)
end, false, {help = 'Wipe player by identifier', validate = true, arguments = {{name = 'identifier', help = 'Player identifier', type = 'string'}}})

function WipePlayer(targetId)
    local xTarget = ESX.GetPlayerFromId(targetId)
    if xTarget then
        local identifier = xTarget.identifier
        WipeData(identifier, targetId)
    else
        print("Player not found")
    end
end

function WipePlayerByIdentifier(identifier)
    local xTarget = ESX.GetPlayerFromIdentifier(identifier)
    if xTarget then
        local targetId = xTarget.source
        WipeData(identifier, targetId)
    else
        WipeData(identifier, nil)
    end
end

function WipeData(identifier, targetId)
    -- Change 'char' prefix and remove license prefix
    local charIdentifier = string.gsub(identifier, 'license:', 'char')
    
    MySQL.Async.execute('DELETE FROM users WHERE identifier = @identifier', {
        ['@identifier'] = identifier
    })
    -- MySQL.Async.execute('DELETE FROM user_accounts WHERE identifier = @identifier', {
    --     ['@identifier'] = identifier
    -- })
    -- MySQL.Async.execute('DELETE FROM user_inventory WHERE identifier = @identifier', {
    --     ['@identifier'] = identifier
    -- })
    -- MySQL.Async.execute('DELETE FROM phone_users_contacts WHERE identifier = @identifier', {
    --     ['@identifier'] = identifier
    -- })
    MySQL.Async.execute('DELETE FROM player_houses WHERE citizenid = @identifier', {
        ['@identifier'] = identifier
    })
    MySQL.Async.execute('DELETE FROM user_licenses WHERE owner = @identifier', {
        ['@identifier'] = identifier
    })
    
    MySQL.Async.execute('DELETE FROM owned_vehicles WHERE owner = @identifier AND isVIP = 0', {
        ['@identifier'] = identifier
    })

    print("All data wiped for identifier: " .. identifier)

    if targetId then
        DropPlayer(targetId, "You have been wiped from the server.")
    end
end

-- Ensure this function is run as a server script
if IsDuplicityVersion() then
    RegisterServerEvent('esx:wipePlayer')
    AddEventHandler('esx:wipePlayer', function(targetId)
        WipePlayer(targetId)
    end)
    
    RegisterServerEvent('esx:wipePlayerByIdentifier')
    AddEventHandler('esx:wipePlayerByIdentifier', function(identifier)
        WipePlayerByIdentifier(identifier)
    end)
end



-- Command to spawn a Sanchez
-- Command to spawn a Sanchez
ESX.RegisterCommand('sanchez', {"admin", "responsable", "mod", "helpeur"}, function(xPlayer, args, showError)
    if not xPlayer then
        return print('[^1ERROR^7] The xPlayer value is nil')
    end

    if not hasPermission(xPlayer, {"admin", "responsable", "mod", "helpeur"}) then
        showError('You do not have permission to use this command.')
        return
    end

    TriggerClientEvent('spawnVehicle', xPlayer.source, 'sanchez')
end, false, {help = 'Spawn a Sanchez and place the player in it', validate = false, arguments = {}})

-- Command to spawn a Sultan
ESX.RegisterCommand('sultan', {"admin", "responsable", "mod", "helpeur"}, function(xPlayer, args, showError)
    if not xPlayer then
        return print('[^1ERROR^7] The xPlayer value is nil')
    end

    if not hasPermission(xPlayer, {"admin", "responsable", "mod", "helpeur"}) then
        showError('You do not have permission to use this command.')
        return
    end

    TriggerClientEvent('spawnVehicle', xPlayer.source, 'sultan')
end, false, {help = 'Spawn a Sultan and place the player in it', validate = false, arguments = {}})


-- Command to give 'piece_arme' items
ESX.RegisterCommand('givepiece', {"admin", "responsable"}, function(xPlayer, args, showError)
    if not xPlayer then
        return print('[^1ERROR^7] The xPlayer value is nil')
    end

    if not hasPermission(xPlayer, {"admin", "responsable"}) then
        showError('You do not have permission to use this command.')
        return
    end

    local targetPlayer = args.playerId
    local count = tonumber(args.count)

    if not targetPlayer or not count or count <= 0 then
        showError('Invalid player ID or count.')
        return
    end

    local targetXPlayer = ESX.GetPlayerFromId(targetPlayer)
    if not targetXPlayer then
        showError('Player not found.')
        return
    end

    targetXPlayer.addInventoryItem('piece_arme', count)
    xPlayer.showNotification('You have given ' .. count .. ' pieces to ' .. targetXPlayer.name)
    targetXPlayer.showNotification('You have received ' .. count .. ' pieces from ' .. xPlayer.name)
end, false, {help = 'Give piece_arme items to a player', validate = true, arguments = {
    {name = 'playerId', help = 'The ID of the player to give items to', type = 'number'},
    {name = 'count', help = 'The number of items to give', type = 'number'}
}})
