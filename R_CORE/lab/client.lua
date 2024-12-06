ESX = exports['es_extended']:getSharedObject()

local teleportPoints = {}
local currentPoint = nil
local warActive = false
local warStarter = nil

-- Cache the teleport points locally to avoid frequent server requests
local function refreshTeleportPoints()
    ESX.TriggerServerCallback('esx_teleport:getTeleportPoints', function(points)
        teleportPoints = points
    end)
end

Citizen.CreateThread(function()
    refreshTeleportPoints()
    -- Refresh teleport points every minute to keep them updated
    while true do
        Citizen.Wait(60000)
        refreshTeleportPoints()
    end
end)

-- Optimized distance check to avoid frequent distance calculations
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)  -- Check distance every second
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        
        local closestPoint = nil
        local closestDistance = 3.0
        
        for _, point in pairs(teleportPoints) do
            local distanceToTp = #(playerCoords - vector3(point.tp_x, point.tp_y, point.tp_z))
            local distanceToReturn = #(playerCoords - vector3(point.dest_x, point.dest_y, point.dest_z))
            
            if distanceToTp < closestDistance then
                closestDistance = distanceToTp
                closestPoint = {point = point, isReturn = false}
            end
            
            if distanceToReturn < closestDistance then
                closestDistance = distanceToReturn
                closestPoint = {point = point, isReturn = true}
            end
        end

        currentPoint = closestPoint
    end
end)

-- Handle teleportation interaction
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if currentPoint then
            local point = currentPoint.point
            local isReturn = currentPoint.isReturn
            local markerCoords = isReturn and vector3(point.dest_x, point.dest_y, point.dest_z) or vector3(point.tp_x, point.tp_y, point.tp_z)
            DrawMarker(1, markerCoords.x, markerCoords.y, markerCoords.z - 1.0, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, 0, 255, 0, 100, false, true, 2, false, nil, nil, false)
            ESX.ShowHelpNotification(isReturn and "Appuyez sur ~INPUT_CONTEXT~ pour retourner." or "Appuyez sur ~INPUT_CONTEXT~ pour interagir.")
            if IsControlJustReleased(1, 38) then -- E
                TriggerServerEvent('esx_teleport:handleTeleport', point.id, isReturn)
            end
        else
            Citizen.Wait(1000)  -- Wait longer if no point is nearby
        end
    end
end)

-- Handle player teleportation
RegisterNetEvent('esx_teleport:teleportPlayer')
AddEventHandler('esx_teleport:teleportPlayer', function(x, y, z)
    local playerPed = PlayerPedId()
    SetEntityCoords(playerPed, x, y, z, false, false, false, true)
end)

-- Set GPS for the player
RegisterNetEvent('esx_teleport:setGps')
AddEventHandler('esx_teleport:setGps', function(x, y, z)
    SetNewWaypoint(x, y)
end)

-- Validate the war declaration
RegisterNetEvent('ox_lib:validateWar')
AddEventHandler('ox_lib:validateWar', function(pointId)
    local alert = lib.alertDialog({
        header = 'Déclarer la guerre',
        content = 'Voulez-vous vraiment déclarer la guerre pour ce laboratoire ?',
        centered = true,
        cancel = true
    })
    if alert == 'confirm' then
        if lib.progressCircle({
            label = 'Déclaration de guerre en cours...',
            duration = 5000,
            position = 'bottom',
            useWhileDead = false,
            canCancel = true,
            disable = {
                car = true,
                move = true,
            },
        }) then 
            lib.notify({
                title = 'Déclaration de guerre',
                description = 'Vous avez déclaré une guerre de labo',
                type = 'success'
            })
        else 
            lib.notify({
                title = 'Déclaration de guerre',
                description = 'Vous avez annulé la déclaration de guerre de labo',
                type = 'error'
            })
        end
        TriggerServerEvent('esx_teleport:confirmWar', pointId)
    else
        lib.notify({
            title = 'Déclaration de guerre annulée',
            description = 'Vous avez annulé la déclaration de guerre.',
            type = 'error'
        })
    end
end)

-- Start the war
RegisterNetEvent('esx_teleport:startWar')
AddEventHandler('esx_teleport:startWar', function(pointId, attackerGang, defenderGang)
    warActive = true
    local startTime = GetGameTimer()
    local playerPed = PlayerPedId()
    local point = GetEntityCoords(playerPed)
    warStarter = playerPed

    Citizen.CreateThread(function()
        while warActive do
            Citizen.Wait(1000)  -- Vérification toutes les secondes

            local playerCoords = GetEntityCoords(playerPed)
            local distance = #(point - vector3(playerCoords.x, playerCoords.y, 0))

            if distance > 50.0 then
                warActive = false
                TriggerServerEvent('esx_teleport:endWar', pointId, false)
                lib.notify({
                    title = 'Alerte',
                    description = 'Vous avez quitté la guerre de labo!',
                    type = 'warning'
                })
                return
            end

            if IsEntityDead(playerPed) and playerPed == warStarter then
                warActive = false
                TriggerServerEvent('esx_teleport:endWar', pointId, false)
                lib.notify({
                    title = 'Alerte',
                    description = 'Le chef des attaquants est mort!',
                    type = 'error'
                })
                return
            end

            if GetGameTimer() - startTime > 1800000 then  -- 30 minutes
                warActive = false
                TriggerServerEvent('esx_teleport:endWar', pointId, true)
                return
            end
            if GetGameTimer() - startTime > 600000 then  -- 10 minutes
                lib.notify({
                    title = 'Guerre de labo',
                    description = 'Il reste 20 minutes avant la fin de la guerre.',
                    type = 'info'
                })
            end
            if GetGameTimer() - startTime > 1200000 then  -- 20 minutes
                lib.notify({
                    title = 'Guerre de labo',
                    description = 'Il reste 10 minutes avant la fin de la guerre.',
                    type = 'info'
                })
            end
            if GetGameTimer() - startTime > 1500000 then  -- 25 minutes
                lib.notify({
                    title = 'Guerre de labo',
                    description = 'Il reste 5 minutes avant la fin de la guerre.',
                    type = 'info'
                })
            end
            if GetGameTimer() - startTime > 1740000 then  -- 29 minutes
                lib.notify({
                    title = 'Guerre de labo',
                    description = 'Il reste 1 minute avant la fin de la guerre.',
                    type = 'info'
                })
            end
        end
    end)
end)

-- Handle player data retrieval
-- Citizen.CreateThread(function()
--     while true do
--         Citizen.Wait(10000)  -- Vérifier toutes les 10 secondes
--         local playerData = ESX.GetPlayerData()
--         if playerData and playerData.job then
--             local jobName = playerData.job.name
--             local jobGrade = playerData.job.grade_name

--             print('Le job du joueur est : ' .. jobName)
--             print('Le grade du joueur est : ' .. jobGrade)
            
--             if jobName == 'police' then
--                 print('Le joueur est un policier')
--             end
--         else
--             print('Impossible de récupérer les données du joueur')
--         end
--     end
-- end)

-- Simplified teleportation function
local function simpleTeleport(x, y, z)
    local playerPed = PlayerPedId()
    SetEntityCoords(playerPed, x, y, z, false, false, false, true)
end

-- Téléportation simplifiée vers un point de repère
RegisterNetEvent("esx:tpm")
AddEventHandler("esx:tpm", function()
    local blipMarker = GetFirstBlipInfoId(8)
    if not DoesBlipExist(blipMarker) then
        ESX.ShowNotification("Aucun point de repère trouvé.", true, false, 140)
        return
    end

    -- Fade screen to hide how clients get teleported.
    DoScreenFadeOut(650)
    while not IsScreenFadedOut() do
        Wait(0)
    end

    local playerPed = PlayerPedId()
    local coords = GetBlipInfoIdCoord(blipMarker)

    -- Simple teleport to blip coordinates
    simpleTeleport(coords.x, coords.y, coords.z + 1.0) -- Add 1.0 to Z to ensure player is above ground

    -- Remove black screen once the teleportation is done.
    DoScreenFadeIn(650)
    ESX.ShowNotification("Téléportation réussie.", true, false, 140)
end)
