ESX = exports['es_extended']:getSharedObject()

Citizen.CreateThread(function()
    for _, location in pairs(Config.Locations) do
        -- Create the NPC
        RequestModel(location.npcModel)
        while not HasModelLoaded(location.npcModel) do
            Wait(1)
        end
        
        local npc = CreatePed(4, location.npcModel, location.pos.x, location.pos.y, location.pos.z - 1.0, location.pos.w, false, true)
        SetEntityInvincible(npc, true)
        FreezeEntityPosition(npc, true)
        SetBlockingOfNonTemporaryEvents(npc, true)
        
        if Config.Debug then
            print("NPC created at: " .. location.pos.x .. ", " .. location.pos.y .. ", " .. location.pos.z)
        end

        -- Create blip if enabled
        if location.blip and location.blip.enabled then
            local blip = AddBlipForCoord(location.pos.x, location.pos.y, location.pos.z)
            SetBlipSprite(blip, location.blip.sprite)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, location.blip.scale)
            SetBlipColour(blip, location.blip.color)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(location.blip.text)
            EndTextCommandSetBlipName(blip)

            if Config.Debug then
                print("Blip created for vehicle rental: " .. location.blip.text)
            end
        end

        -- Interaction mode check
        if Config.InteractionMode == "ox_target" then
            -- Interaction via ox_target
            exports.ox_target:addBoxZone({
                coords = vector3(location.pos.x, location.pos.y, location.pos.z),
                size = vec3(2, 2, 2),
                heading = location.pos.w,
                options = {
                    {
                        name = 'rent_vehicle',
                        event = 'esx_vehicle_rental:openMenu',
                        icon = 'fas fa-car',
                        label = Config.Lang.rent_vehicle_prompt_ox_target,
                        args = location
                    }
                },
            })
            if Config.Debug then
                print("ox_target zone added for vehicle rental.")
            end
        elseif Config.InteractionMode == "textui" then
            -- Interaction via textui
            local isInZone = false

            Citizen.CreateThread(function()
                while true do
                    local playerCoords = GetEntityCoords(PlayerPedId())
                    local distance = #(playerCoords - vector3(location.pos.x, location.pos.y, location.pos.z))
                    
                    if distance < 2.0 then
                        if not isInZone then
                            isInZone = true
                            lib.showTextUI(Config.Lang.rent_vehicle_prompt_textui, {
                                position = "right-center",
                                icon = 'car',
                            })

                            if Config.Debug then
                                print("Player is near the NPC to rent a vehicle.")
                            end

                            -- Start another thread to detect E key press
                            Citizen.CreateThread(function()
                                while isInZone do
                                    if IsControlJustReleased(0, 38) then -- E key
                                        if Config.Debug then
                                            print("E key pressed to open rental menu.")
                                        end
                                        TriggerEvent('esx_vehicle_rental:openMenu', location)
                                    end
                                    Citizen.Wait(10) -- Check every 10ms
                                end
                            end)
                        end
                    else
                        if isInZone then
                            isInZone = false
                            lib.hideTextUI()
                            if Config.Debug then
                                print("Player moved away from the NPC.")
                            end
                        end
                    end

                    Citizen.Wait(1000) -- Check distance every second
                end
            end)
        end
    end
end)

RegisterNetEvent('esx_vehicle_rental:openMenu')
AddEventHandler('esx_vehicle_rental:openMenu', function(location)
    local vehicleOptions = {}

    for _, vehicle in pairs(location.vehicles) do
        local vehicleOption = {
            title = GetDisplayNameFromVehicleModel(vehicle.model),
            description = Config.Lang.select_duration .. " & " .. Config.Lang.select_payment_method,
            event = 'esx_vehicle_rental:openInputDialog',
            args = {
                vehicle = vehicle,
                spawnPos = location.spawnPos
            }
        }

        if Config.ShowVehicleImages and vehicle.image then
            vehicleOption.image = vehicle.image
        end
        
        table.insert(vehicleOptions, vehicleOption)
    end
    
    lib.registerContext({
        id = 'vehicle_menu',
        title = Config.Lang.vehicle_rental_menu_title,
        options = vehicleOptions
    })

    lib.showContext('vehicle_menu')

    if Config.Debug then
        print("Vehicle selection menu opened.")
    end
end)

RegisterNetEvent('esx_vehicle_rental:openInputDialog')
AddEventHandler('esx_vehicle_rental:openInputDialog', function(data)
    -- Build duration options with prices
    local durationOptions = {}
    for i, multiplier in ipairs(data.vehicle.prices) do
        local durationHours = multiplier
        local price = data.vehicle.basePrice * multiplier
        table.insert(durationOptions, {
            value = durationHours,
            label = ('%dh - %s$'):format(durationHours, price)
        })
    end
    
    local input = lib.inputDialog(Config.Lang.select_duration .. " & " .. Config.Lang.select_payment_method, {
        {
            type = 'select',
            label = Config.Lang.select_duration,
            options = durationOptions
        },
        {
            type = 'select',
            label = Config.Lang.select_payment_method,
            options = {
                {label = Config.Lang.cash, value = 'Cash'},
                {label = Config.Lang.bank, value = 'Bank'}
            }
        }
    })

    if input then
        local selectedDuration = input[1]
        local selectedPaymentMethod = input[2]
        local price = data.vehicle.basePrice * selectedDuration
        TriggerServerEvent('esx_vehicle_rental:rentVehicle', data.vehicle.model, price, selectedDuration, data.spawnPos, selectedPaymentMethod)

        if Config.Debug then
            print(("Duration selected: %dh, Payment method: %s, Price: %s"):format(selectedDuration, selectedPaymentMethod, price))
        end
    end
end)

RegisterNetEvent('esx_vehicle_rental:spawnVehicle')
AddEventHandler('esx_vehicle_rental:spawnVehicle', function(model, plate, spawnPos)
    local playerPed = PlayerPedId()
    
    ESX.Game.SpawnVehicle(model, vector3(spawnPos.x, spawnPos.y, spawnPos.z), spawnPos.w, function(vehicle)
        SetVehicleNumberPlateText(vehicle, plate)
        SetVehicleFuelLevel(vehicle, 100.0)
        TaskWarpPedIntoVehicle(playerPed, vehicle, -1)

        if Config.Debug then
            print("Vehicle spawned successfully: " .. model .. " [" .. plate .. "]")
        end
    end)
end)

RegisterNetEvent('esx_vehicle_rental:endRental')
AddEventHandler('esx_vehicle_rental:endRental', function(plate)
    local playerPed = PlayerPedId()

    if Config.Debug then
        print("Rental end event received. Plate: " .. plate)
    end

    if IsPedInAnyVehicle(playerPed, false) then
        local playerVehicle = GetVehiclePedIsIn(playerPed, false)
        if GetPedInVehicleSeat(playerVehicle, -1) == playerPed then
            -- Stop the vehicle
            SetVehicleEngineOn(playerVehicle, false, true, true)
            -- Eject the player
            TaskLeaveVehicle(playerPed, playerVehicle, 0)
            Citizen.Wait(1000)
            -- Lock the vehicle to prevent re-entry
            SetVehicleDoorsLocked(playerVehicle, 2)
            Citizen.Wait(5000)

            ESX.Game.DeleteVehicle(playerVehicle)
            if Config.Debug then
                print(Config.Lang.vehicle_deleted .. plate)
            end
            -- Rental end notification
            lib.notify({
                title = Config.Lang.rent_vehicle_notification,
                description = Config.Lang.vehicle_locked .. plate,
                type = 'inform'
            })

            if Config.Debug then
                print("Player ejected from vehicle and vehicle locked.")
            end
        else
            if Config.Debug then
                print("Player is not in the vehicle or the plate does not match.")
            end
        end
    end
end)

RegisterNetEvent('esx_vehicle_rental:lockVehicle')
AddEventHandler('esx_vehicle_rental:lockVehicle', function(plate)
    -- Lock the vehicle if found on the map
    for _, vehicle in ipairs(GetAllVehicles()) do
        if GetVehicleNumberPlateText(vehicle) == plate then
            lib.notify({
                title = Config.Lang.rent_vehicle_notification,
                description = Config.Lang.vehicle_locked .. plate,
                type = 'inform'
            })
            SetVehicleDoorsLocked(vehicle, 2)
            if Config.Debug then
                print(Config.Lang.vehicle_locked .. plate)
            end
            return -- Exit loop once the vehicle is found and locked
        end
    end

    if Config.Debug then
        print("No vehicle found with the plate: " .. plate)
    end
end)
