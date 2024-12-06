ESX = exports["es_extended"]:getSharedObject()

-- Register each seed item as usable for ESX
for _, seedItem in ipairs(Config.Items["Seeds"]) do
    ESX.RegisterUsableItem(seedItem, function(source)
        UseItem(source, seedItem)
    end)
end

-- Register the usable item for OX Inventory
RegisterNetEvent('ox_inventory:onUseItem')
AddEventHandler('ox_inventory:onUseItem', function(item)
    if item == Config.Items["Seed"] then
        UseItem(source)
    end
end)

-- Function to get the player from ESX
function getplayer()
    return ESX.GetPlayerFromId
end

-- Function to send a notification to the player
function notify(source, text)
    local xPlayer = getplayer()(source)
    xPlayer.showNotification(text)
end

-- Function to remove an item from the inventory
function removeitem(source, item, count)
    local src = source
    if Config.Inventory == "default" then
        local xPlayer = getplayer()(src)
        xPlayer.removeInventoryItem(item, count)
    elseif Config.Inventory == "ox_inventory" then 
        exports.ox_inventory:RemoveItem(src, item, count)
    elseif Config.Inventory == "quasar" then 
        exports['qs-inventory']:RemoveItem(src, item, count)
    end
end

-- Function to get the item count from the inventory
function getitem(source, item)
    local src = source
    local count = 0
    if Config.Inventory == "default" then
        local xPlayer = getplayer()(src)
        count = xPlayer.getInventoryItem(item).count
    elseif Config.Inventory == "ox_inventory" then 
        count = exports.ox_inventory:GetItemCount(src, item)
    elseif Config.Inventory == "quasar" then 
        count = exports['qs-inventory']:GetItemTotalAmount(src, item)
    end
    return count
end

-- Function to add an item to the inventory
function additem(source, item, count)
    local src = source
    if Config.Inventory == "default" then
        local xPlayer = getplayer()(src)
        xPlayer.addInventoryItem(item, count)
    elseif Config.Inventory == "ox_inventory" then 
        exports.ox_inventory:AddItem(src, item, count)
    elseif Config.Inventory == "quasar" then 
        exports['qs-inventory']:AddItem(src, item, count)
    end
end
