ESX = exports["es_extended"]:getSharedObject()

-- Function to use the item
function UseItem(source, seedType)
    if getitem(source, seedType) >= 1 then
        removeitem(source, seedType, 1)
        TriggerClientEvent("BakiTelli_weed:Seed", source, seedType)
        sendToDiscord(Config.Webhook, source, "Seed Planted!", "\n" .. GetPlayerName(source) .. "(" .. source .. ") \n\n**Seed Type : **" .. seedType, 15158332)
    end
end

RegisterNetEvent("BakiTelli_weed:giveSV")
AddEventHandler("BakiTelli_weed:giveSV", function (menu, id)
    local src = source
    if id == "Water" then
        if getitem(src, Config.Items["Water"]) >= 1 then 
            removeitem(source, Config.Items["Water"], 1)
            TriggerClientEvent("BakiTelli_weed:giveCl", src, menu, id)
        end
    elseif id == "Fertilizer" then 
        if getitem(src, Config.Items["Fertilizer"]) >= 1 then 
            removeitem(src, Config.Items["Fertilizer"], 1)
            TriggerClientEvent("BakiTelli_weed:giveCl", src, menu, id)
        end
    elseif id == "Dust" then 
        if getitem(src, Config.Items["Dust"]) >= 1 then 
            removeitem(src, Config.Items["Dust"], 1)
            TriggerClientEvent("BakiTelli_weed:giveCl", src, menu, id)
        end
    end
end)

RegisterNetEvent("BakiTelli_weed:Harvest")
AddEventHandler("BakiTelli_weed:Harvest", function(weedType, quantity)
    local src = source
    additem(src, weedType, quantity)
    sendToDiscord(Config.Webhook, src, "Harvest is done!", "\n" .. GetPlayerName(src) .. "(" .. src .. ") \n\n**Harvest quantity : **" .. quantity, 15158332)
end)



-- Other server-side code remains the same


function sendToDiscord(DiscordLog, source, title, des, color)
    local debuxIMG = ""
    local log = {
        {
            ["title"] = "R WEED",
            ["color"] = color,
            author = {
                name = "R WEED",
                icon_url = "",
                url = ""
            },
            ["fields"] = {
                {
                    ["name"] = "> Info:",
                    ["value"] = title,
                    ["inline"] = false
                },
                {
                    ["name"] = "> Version:",
                    ["value"] = "1.0",
                    ["inline"] = false
                },
                {
                    ["name"] = "> Detail:",
                    ["value"] = des,
                    ["inline"] = false
                },
                {
                    ["name"] = "> Website:",
                    ["value"] = '',
                    ["inline"] = true
                },
                {
                    ["name"] = "> Support:",
                    ["value"] = '',
                    ["inline"] = true
                },
            },
            ["thumbnail"] = {
                ["url"] = ""
            },
        },
    }
    Citizen.Wait(tonumber(1000))
    PerformHttpRequest(DiscordLog, function(err, text, headers) end, 'POST', json.encode({ username = "DebuX WorkShop", embeds = log, avatar_url = debuxIMG }), { ['Content-Type'] = 'application/json' })
end
