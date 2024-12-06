local MenuWaiter = 0
local isMenu = false
local MenuWeed = 1
local Weeds = {}
local disable_actions = false

function notify(text)
    lib.notify({
        title = text,
        description = text,
        type = 'warning'
    })
end


function StartSeed(seedType)
    local player = PlayerPedId()
    local coord = GetEntityCoords(player)
    local cSCoords = GetOffsetFromEntityInWorldCoords(player, 0.0, 0.0, -5.0)
    local spatulaspawn = CreateObject(GetHashKey(Config.Props["spatulamodel"]), cSCoords.x, cSCoords.y, cSCoords.z, true, true, true)

    if DoesEntityExist(spatulaspawn) then
        local netid = ObjToNet(spatulaspawn)

        TaskStartScenarioInPlace(player, "world_human_gardener_plant", 0, false)
        AttachEntityToEntity(spatulaspawn, player, GetPedBoneIndex(player, 28422), -0.005, 0.0, 0.0, 190.0, 190.0, -50.0, true, true, false, true, 1, true)
        disable_actions = true
        Citizen.Wait(Config.Wait["Seed"] * 1000)
        disable_actions = false
        DetachEntity(NetToObj(netid), true, true)
        DeleteEntity(NetToObj(netid))

        local plant = CreateObject(GetHashKey(Config.Props["Weed_Lvl1"]), coord.x, coord.y, coord.z - 1.0, true, true, true)
        if DoesEntityExist(plant) then
            PlaceObjectOnGroundProperly(plant)
            FreezeEntityPosition(plant, true)
            table.insert(Weeds, {
                lvl = 1,
                plant = plant,
                growth = 5,
                health = 10,
                water = 5,
                fertilizer = 5,
                coords = GetEntityCoords(plant),
                seedType = seedType
            })
        else
            notify("Failed to create plant object.")
        end
    else
        notify("Failed to create spatula object.")
    end
    ClearPedTasks(player)
end

function GetCorrespondingWeed(seedType)
    if seedType == "weed_white-widow_seed" then
        return "weed_white-widow-brut"
    elseif seedType == "weed_skunk_seed" then
        return "weed_skunk-brut"
    elseif seedType == "weed_purple-haze_seed" then
        return "weed_purple-haze-brut"
    elseif seedType == "weed_og-kush_seed" then
        return "weed_og-kush-brut"
    elseif seedType == "weed_amnesia_seed" then
        return "weed_amnesia-brut"
    elseif seedType == "weed_ak47_seed" then
        return "weed_ak47-brut"
    end
end

Citizen.CreateThread(function()
    while true do
        local sleep = 1500
        local playercoord = GetEntityCoords(PlayerPedId())
        if #Weeds >= 1 then  
            for k, v in pairs(Weeds) do
                local dst = #(playercoord - vector3(v.coords.x, v.coords.y, v.coords.z))
                if dst < 5 then 
                    sleep = 1
                    DrawText3D(v.coords.x, v.coords.y, v.coords.z + 1.0, Config.Langs["OpenWeed"])
                    if dst < 2.5 and IsControlJustReleased(0, 38) then
                        OpenMenu(k)
                    end
                end
            end
        end
        Citizen.Wait(sleep)
    end
end)

Citizen.CreateThread(function()
    while true do
        local sleep = 1000
        if disable_actions then 
            sleep = 0
            DisableAllControlActions(0)
        end
        Citizen.Wait(sleep)
    end
end)

Citizen.CreateThread(function()
    while true do
        if #Weeds >= 1 then  
            for k, v in pairs(Weeds) do
                if v.growth <= 0 then
                    DeleteEntity(v.plant)
                    table.remove(Weeds, k)
                    SendNUIMessage({action = "Close"})
                else
                    if v.health <= 0 then 
                        if v.water > 0 and v.fertilizer > 0 then 
                            Weeds[k].water = v.water - 1
                            Weeds[k].fertilizer = v.fertilizer - 1
                            Weeds[k].health = v.health + 0.5
                        else
                            Weeds[k].growth = v.growth - 0.5
                        end
                    else
                        if v.water > 0 and v.fertilizer > 0 then 
                            Weeds[k].water = v.water - 1
                            Weeds[k].fertilizer = v.fertilizer - 1
                            if Weeds[k].health >= 100 then 
                                Weeds[k].health = 100
                            else 
                                Weeds[k].health = v.health + 1
                            end
                        else
                            Weeds[k].health = v.health - 1
                        end
                    end
                    if v.health >= v.growth then 
                        if Weeds[k].growth >= 100 then 
                            Weeds[k].growth = 100
                        else 
                            Weeds[k].growth = v.growth + 1
                        end
                    else
                        Weeds[k].growth = v.growth - 0.5
                    end
                    if (v.growth >= 25 and v.lvl == 1) then
                        UpgradeWeed(k, 2)
                    elseif (v.growth >= 40 and v.lvl == 2) then 
                        UpgradeWeed(k, 3)
                    elseif (v.growth >= 65 and v.lvl == 3) then 
                        UpgradeWeed(k, 4)
                    elseif (v.growth >= 80 and v.lvl == 4) then 
                        UpgradeWeed(k, 5)
                    end
                    if isMenu then 
                        SendNUIMessage({
                            action="OpenMenu", 
                            growth = Weeds[MenuWeed].growth, 
                            health = Weeds[MenuWeed].health,
                            water = Weeds[MenuWeed].water,
                            fertilizer = Weeds[MenuWeed].fertilizer
                        })
                    end
                end
            end
        end
        Citizen.Wait(Config.Wait["Check"] * 1000)
    end
end)

function UpgradeWeed(weed_id, lvl)
    local weed = Weeds[weed_id]
    lvl = tonumber(lvl)
    DeleteEntity(weed.plant)
    local obj
    if lvl == 2 then
        obj = CreateObject(Config.Props["Weed_Lvl2"], weed.coords, true)
    elseif lvl == 3 then 
        obj = CreateObject(Config.Props["Weed_Lvl3"], weed.coords, true)
    elseif lvl == 4 then 
        obj = CreateObject(Config.Props["Weed_Lvl4"], vector3(weed.coords.x, weed.coords.y, weed.coords.z - 2.5), true)
    elseif lvl == 5 then 
        obj = CreateObject(Config.Props["Weed_Lvl5"], vector3(weed.coords.x, weed.coords.y, weed.coords.z - 2.5), true)
    end
    FreezeEntityPosition(obj, true)
    Weeds[weed_id].plant = obj
    Weeds[weed_id].lvl = lvl
end

function OpenMenu(id)
    -- Menu opening logic
    SendNUIMessage({
        action = "OpenMenu",
        growth = Weeds[id].growth,
        health = Weeds[id].health,
        water = Weeds[id].water,
        fertilizer = Weeds[id].fertilizer
    })
    SetNuiFocus(true, true)
    isMenu = true
    MenuWeed = id
end

RegisterNUICallback("close", function ()
    MenuWaiter = GetGameTimer() + 2000
    SetNuiFocus(false, false)
    isMenu = false 
end)

function LoadProp()
    for k, v in pairs(Config.Props) do        
        if not HasModelLoaded(v) then
            RequestModel(v)
            while not HasModelLoaded(v) do
                Citizen.Wait(1)
            end
        end
    end
end

function Harvest(id)
    SendNUIMessage({action = "Close"})
    local weed = Weeds[id]
    local cSCoords = GetOffsetFromEntityInWorldCoords(GetPlayerPed(PlayerId()), 0.0, 0.0, -5.0)
    local spatulaspawn = CreateObject(GetHashKey(Config.Props["spatulamodel"]), cSCoords.x, cSCoords.y, cSCoords.z, true, true, true)
    local netid = ObjToNet(spatulaspawn)

    TaskStartScenarioInPlace(PlayerPedId(), "world_human_gardener_plant", 0, false)
    AttachEntityToEntity(spatulaspawn, GetPlayerPed(PlayerId()), GetPedBoneIndex(GetPlayerPed(PlayerId()), 28422), -0.005, 0.0, 0.0, 190.0, 190.0, -50.0, true, true, false, true, 1, true)
    disable_actions = true
    Citizen.Wait(Config.Wait["Harvest"] * 1000)
    disable_actions = false
    DetachEntity(NetToObj(netid), true, true)
    DeleteEntity(NetToObj(netid))
    ClearPedTasks(PlayerPedId())

    if weed.growth >= 50 then
        print(weed.growth)
        local GiveWeed = math.ceil(weed.growth * Config.Harvest / 10)
        local weedType = GetCorrespondingWeed(weed.seedType)
        TriggerServerEvent("BakiTelli_weed:Harvest", weedType, GiveWeed)
        notify(Config.Langs["Harvest"])
    else 
        lib.notify({
            title = 'Vous avez récolté trop tôt!',
            description = 'Vous avez récolté trop tôt!',
            type = 'warning'
        })
    end
    DeleteEntity(weed.plant)
    table.remove(Weeds, id)
    SendNUIMessage({action = "Close"})
end

AddEventHandler('onClientMapStop', function()
    for k, v in pairs(Weeds) do
        DeleteEntity(v.plant)
    end
end)

RegisterNUICallback("Give", function (data)
    if data.idx == "Harvest" then
        Harvest(MenuWeed)
    else 
        TriggerServerEvent("BakiTelli_weed:giveSV", MenuWeed, data.idx)
    end
end)

AddEventHandler("BakiTelli_weed:giveCl")
RegisterNetEvent("BakiTelli_weed:giveCl", function (MenuW, idx)
    if idx == "Water" then
        Weeds[MenuW].water = Weeds[MenuW].water + Config.Give["Water"]
    elseif idx == "Fertilizer" then 
        Weeds[MenuW].fertilizer = Weeds[MenuW].fertilizer + Config.Give["Fertilizer"]
    elseif idx == "Dust" then
        if Weeds[MenuW].health >= 100 then 
            Weeds[MenuW].growth = 100
        else 
            Weeds[MenuW].health = Weeds[MenuW].health + Config.Give.Dust["Healt"]
        end
        if Weeds[MenuW].growth >= 100 then 
            Weeds[MenuW].growth = 100
        else 
            Weeds[MenuW].growth = Weeds[MenuW].growth + Config.Give.Dust["Growth"]
        end
    end
    if isMenu then 
        SendNUIMessage({
            action="OpenMenu", 
            growth = Weeds[MenuW].growth, 
            health =  Weeds[MenuW].health,
            water = Weeds[MenuW].water,
            fertilizer = Weeds[MenuW].fertilizer
        })
    end
end)

RegisterNetEvent("BakiTelli_weed:Seed")
AddEventHandler("BakiTelli_weed:Seed", function(seedType)
    StartSeed(seedType)
end)

function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())
    
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x, _y)
    local factor = (string.len(text)) / 370
    DrawRect(_x, _y + 0.0150, 0.015 + factor, 0.03, 41, 11, 41, 68)
end
