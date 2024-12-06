ESX = exports["es_extended"]:getSharedObject()

RegisterNetEvent('openVehicleMenu')
AddEventHandler('openVehicleMenu', function()
    local categoryOptions = {}

    -- Register submenus for each category
    for category, vehicles in pairs(Config.Categories) do
        local vehicleOptions = {}

        -- Add a "Back" button to the submenu
        table.insert(vehicleOptions, {
            title = 'Retour',
            icon = 'arrow-left',
            onSelect = function()
                lib.showContext('vehicle_categories')
            end
        })

        for _, vehicle in ipairs(vehicles) do
            table.insert(vehicleOptions, {
                title = vehicle.name,
                description = 'Price: $' .. vehicle.price,
                icon = 'car',
                onSelect = function()
                    TriggerServerEvent('spawnVehicle', vehicle.model, vehicle.price)
                end
            })
        end

        lib.registerContext({
            id = category .. '_vehicles',
            title = category:sub(1, 1):upper() .. category:sub(2),
            options = vehicleOptions,
            canClose = true,
            onBack = function()
                lib.showContext('vehicle_categories')
            end
        })

        table.insert(categoryOptions, {
            title = category:sub(1, 1):upper() .. category:sub(2),
            icon = 'folder-open',
            onSelect = function()
                lib.showContext(category .. '_vehicles')
            end
        })
    end

    lib.registerContext({
        id = 'vehicle_categories',
        title = 'Select a Category',
        options = categoryOptions,
        canClose = true
    })

    lib.showContext('vehicle_categories')
end)
function GetRandomLetter(length)
    local result = ''
    for i = 1, length do
        result = result .. string.char(math.random(65, 90)) -- ASCII values for A-Z
    end
    return result
end

function GetRandomNumber(length)
    local result = ''
    for i = 1, length do
        result = result .. tostring(math.random(0, 9))
    end
    return result
end

function GeneratePlate()
    local generatedPlate
    local doBreak = false

    while true do
        Wait(0)
        math.randomseed(GetGameTimer())
        generatedPlate = string.upper(GetRandomLetter(3) .. ' ' .. GetRandomNumber(3))

        ESX.TriggerServerCallback('youtool:isPlateTaken', function(isPlateTaken)
            if not isPlateTaken then
                doBreak = true
            end
        end, generatedPlate)

        if doBreak then
            break
        end
    end

    return generatedPlate
end

function spawnVehicleyoutool(modelName, x, y, z, heading)
    local model = GetHashKey(modelName)

    -- Charger le modèle du véhicule
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(1)
    end

    -- Créer le véhicule
    local vehicle = CreateVehicle(model, x, y, z, heading, true, false)
    local plate = GeneratePlate()
    SetVehicleNumberPlateText(vehicle, plate)

    -- Assurer que le véhicule est contrôlé par le script
    SetEntityAsMissionEntity(vehicle, true, true)

    -- Libérer le modèle pour économiser la mémoire
    SetModelAsNoLongerNeeded(model)

    local vehicleProperties = ESX.Game.GetVehicleProperties(vehicle)
    local spawnPosition = {x = x, y = y, z = z, heading = heading}

    TriggerServerEvent('youtool:buyVehicle', vehicleProperties, spawnPosition)
    TriggerServerEvent('youtool:giveVehicleKey', plate, modelName)

    return vehicle
end

RegisterNetEvent('esx:spawnVehicle')
AddEventHandler('esx:spawnVehicle', function(modelName)
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local heading = GetEntityHeading(playerPed)

    -- Ajouter un léger décalage pour ne pas apparaître sur le joueur
    local spawnX = coords.x + 2
    local spawnY = coords.y
    local spawnZ = coords.z

    local vehicle = spawnVehicleyoutool(modelName, spawnX, spawnY, spawnZ, heading)
    TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
end)
