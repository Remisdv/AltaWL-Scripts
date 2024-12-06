local currentMission = nil
local missionBlip = nil
local canStartMission = false

-- Fonction pour charger un modèle
function loadModel(model)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(1)
    end
end

-- Fonction pour afficher du texte en 3D
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
    DrawRect(_x, _y + 0.0150, 0.015 + factor, 0.03, 0, 0, 0, 75)
end

-- Vérifier le nombre de LSPD toutes les 10 secondes
CreateThread(function()
    while true do
        ESX.TriggerServerCallback('goFast:getLSPDCount', function(count)
            if count >= 1 then
                canStartMission = true
            else
                canStartMission = false
            end
        end)
        Wait(10000) -- Attendre 10 secondes
    end
end)

CreateThread(function()
    for _, loc in ipairs(Config.PNJLocations) do
        local pnjSpawned = false
        local ped = nil
        
        -- Thread pour gérer le spawn/despawn des PNJ
        CreateThread(function()
            while true do
                local playerPed = PlayerPedId()
                local playerCoords = GetEntityCoords(playerPed)
                local dist = #(playerCoords - vector3(loc.x, loc.y, loc.z))
                
                if dist < 50 and not pnjSpawned then
                    -- Charger le modèle avant de créer le PNJ
                    loadModel(`a_m_m_business_01`)
                    ped = CreatePed(4, `a_m_m_business_01`, loc.x, loc.y, loc.z, loc.w, false, true)
                    SetEntityAsMissionEntity(ped, true, true)
                    SetBlockingOfNonTemporaryEvents(ped, true)
                    FreezeEntityPosition(ped, true)
                    pnjSpawned = true
                elseif dist >= 50 and pnjSpawned then
                    DeleteEntity(ped)
                    pnjSpawned = false
                end
                
                Wait(1000)  -- Vérification toutes les secondes
            end
        end)
        
        -- Thread pour gérer l'interaction avec les PNJ
        CreateThread(function()
            while true do
                local playerPed = PlayerPedId()
                local playerCoords = GetEntityCoords(playerPed)
                local dist = #(playerCoords - vector3(loc.x, loc.y, loc.z))
                
                if pnjSpawned and dist < 2 then
                    while pnjSpawned and dist < 2 do
                        playerCoords = GetEntityCoords(playerPed)
                        dist = #(playerCoords - vector3(loc.x, loc.y, loc.z))
                        
                        DrawText3D(loc.x, loc.y, loc.z + 1.0, "Appuyez sur ~g~E~w~ pour parler")
                        if IsControlJustReleased(0, 38) then
                            if not currentMission then
                                if canStartMission then
                                    TriggerEvent('goFast:requestMission')
                                else
                                    lib.notify({
                                        title = 'GoFast',
                                        description = 'Il n\'y a pas assez de LSPD en service.',
                                        type = 'error'
                                    })
                                end
                            else
                                lib.notify({
                                    title = 'GoFast',
                                    description = 'Vous êtes déjà en mission.',
                                    type = 'error'
                                })
                            end
                        end
                        
                        Wait(0)  -- Vérification fréquente lorsque le joueur est proche
                    end
                else
                    Wait(1000)  -- Vérification toutes les secondes lorsque le joueur est loin
                end
            end
        end)
    end
end)

RegisterNetEvent('goFast:missionStarted')
AddEventHandler('goFast:missionStarted', function(missionID, location, time, drug, amount)
    currentMission = {
        id = missionID,
        drug = drug,
        amount = amount,
        location = location
    }

    -- Utiliser un point GPS de mission
    missionBlip = AddBlipForCoord(location.x, location.y, location.z)
    SetBlipSprite(missionBlip, 1)
    SetBlipColour(missionBlip, 1)
    SetBlipRoute(missionBlip, true)
    SetBlipRouteColour(missionBlip, 1)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Mission Go Fast")
    EndTextCommandSetBlipName(missionBlip)

    local ped = nil
    CreateThread(function()
        loadModel(`a_m_m_business_01`)
        ped = CreatePed(4, `a_m_m_business_01`, location.x, location.y, location.z, location.w, false, true)
        SetEntityAsMissionEntity(ped, true, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        FreezeEntityPosition(ped, true)
        while true do
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local dist = #(playerCoords - vector3(location.x, location.y, location.z))

            if dist < 2 then
                DrawText3D(location.x, location.y, location.z + 1.0, "Appuyez sur ~g~E~w~ pour vendre")
                if IsControlJustReleased(0, 38) then
                    TriggerServerEvent('goFast:completeMission', currentMission.id, currentMission.drug, currentMission.amount)
                    lib.cancelProgress()
                    if missionBlip then
                        RemoveBlip(missionBlip)
                    end
                    TaskWanderStandard(ped, 10.0, 10)  -- Fait partir le PNJ en marchant
                    SetEntityAsNoLongerNeeded(ped)  -- Définir l'entité comme non nécessaire
                    currentMission = nil
                    break
                end
            end

            Wait(0)
        end
    end)
end)

RegisterNetEvent('goFast:missionStartedProgress')
AddEventHandler('goFast:missionStartedProgress', function(time)
    if lib.progressBar({
        duration = time * 1000,
        position = 'bottom',
        label = string.format("Temps restant"),
        useWhileDead = false,
        canCancel = false,
        disable = {
            move = false,
            car = false,
            combat = false,
            mouse = false
        },
    }) then 
        -- Mission échouée
        lib.notify({
            title = 'GoFast',
            description = 'Mission échouée !',
            type = 'error'
        })
        TriggerServerEvent('goFast:failMission', currentMission.id)
        if missionBlip then
            RemoveBlip(missionBlip)
        end
        currentMission = nil
    else 
        --print('Do stuff when cancelled') 
    end
end)

RegisterNetEvent('goFast:missionCompleted')
AddEventHandler('goFast:missionCompleted', function()
    if currentMission then
        TriggerServerEvent('goFast:completeMission', currentMission.id, currentMission.drug, currentMission.amount)
        currentMission = nil
        TriggerEvent('ox_lib:cancelProgress')  -- Cancel progress bar when mission is completed
    end
end)

RegisterNetEvent('goFast:requestMission')
AddEventHandler('goFast:requestMission', function()
    if currentMission then
        lib.notify({
            title = 'GoFast',
            description = 'Vous êtes déjà en mission.',
            type = 'error'
        })
        return
    end

    ESX.TriggerServerCallback('goFast:getDrugCount', function(drugCounts)
        local options = {}
        for drug, count in pairs(drugCounts) do
            if count > 0 then
                local displayCount = count > 200 and 200 or count  -- Limiter à 100 unités maximum
                table.insert(options, {
                    title = drug,
                    description = 'Quantité: ' .. displayCount,
                    event = 'goFast:startMission',
                    args = {drug = drug, count = displayCount}  -- Passing arguments as key-value pairs
                })
            end
        end
        lib.registerContext({
            id = 'goFast_context',
            title = 'Go Fast',
            options = options
        })
        lib.showContext('goFast_context')
    end)
end)

RegisterNetEvent('goFast:startMission')
AddEventHandler('goFast:startMission', function(args)
    local drug = args.drug
    local amount = args.count
    --print('start mission', drug, amount)
    TriggerServerEvent('goFast:startMission', drug, amount)
end)

RegisterNetEvent('ox_lib:cancelProgress')
AddEventHandler('ox_lib:cancelProgress', function()
    -- lib.cancelProgress()  -- Cancel the progress bar
end)
