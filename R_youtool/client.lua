ESX = exports["es_extended"]:getSharedObject()
local PlayerData = {}




local destinations = {
    { name = "Livraison Nourriture", coords = vector3(1213.5396728516, -2983.443359375, 5.8653564453125), reward = 100, item = 'carton_nouriture' },
    { name = "Livraison Boisson", coords = vector3(-1057.9963378906, -2005.5258789062, 13.161578178406), reward = 100, item = 'carton_boisson' },
    { name = "Livraison Feraille", coords = vector3(-153.09954833984, -2388.0480957031, 5.9999990463257), reward = 100, item = 'carton_feraille' }
}

Citizen.CreateThread(function()
    while ESX == nil do
        Citizen.Wait(10)
    end

    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(10)
    end

    PlayerData = ESX.GetPlayerData()

    if PlayerData.job.name == 'youtool' then
        startMission()
    end
end)

local mission = false

function startMission()
    local missionActive = false
    local pointA = vector3(2676.7951660156, 3525.2475585938, 52.565414428711) -- Coordonnées de départ
    --local currentDestination = nil
    
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(5)
            if not missionActive then
                DrawMarker(27, pointA.x, pointA.y, pointA.z-0.9, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 0, 255, 0, 100, false, true, 2, nil, nil, false)
                if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), pointA, true) < 2.5 then
                    ESX.ShowHelpNotification("Appuyez sur ~INPUT_CONTEXT~ pour choisir une mission YouTool")
                    if IsControlJustReleased(0, 38) then
                        openMissionMenu()
                    end
                end
            end
        end
    end)
end

function openMissionMenu()
    local elements = {}
    for _, destination in ipairs(destinations) do
        table.insert(elements, { title = destination.name, description = 'Récompense: $' .. destination.reward, event = 'youtool:selectDestination', args = destination })
    end

    lib.registerContext({
        id = 'youtool_mission_menu',
        title = 'Choisissez une destination',
        options = elements
    })

    lib.showContext('youtool_mission_menu')
end

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    PlayerData.job = job

    if PlayerData.job.name == 'youtool' then
        startMission()
    end
end)

RegisterNetEvent('youtool:selectDestination')
AddEventHandler('youtool:selectDestination', function(destination)
    currentDestination = destination
    TriggerEvent('chat:addMessage', { args = { '[YouTool]', 'Allez au point indiqué sur votre GPS!' } })
    SetNewWaypoint(destination.coords.x, destination.coords.y)
    StartGpsMultiRoute(6, true, true)
    AddPointToGpsMultiRoute(destination.coords.x, destination.coords.y, destination.coords.z)
    SetGpsMultiRouteRender(true)
while not mission do
    Citizen.Wait(5)
    if currentDestination then
        DrawMarker(1, currentDestination.coords.x, currentDestination.coords.y, currentDestination.coords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 5.0, 5.0, 1.0, 255, 0, 0, 100, false, true, 2, nil, nil, false)
        if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), currentDestination.coords, true) < 5.0 then
            ESX.ShowHelpNotification("Appuyez sur ~INPUT_CONTEXT~ pour terminer la mission YouTool")
            if IsControlJustReleased(0, 38) then
                missionActive = false
                mission = false
                TriggerServerEvent('esx_youtool:completeMission', currentDestination.reward, currentDestination.item)
                currentDestination = nil
                SetGpsMultiRouteRender(false)
              end
          end
      end
    end

    --local currentDestination = true
end)


