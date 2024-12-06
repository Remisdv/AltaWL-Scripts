ESX = exports['es_extended']:getSharedObject()

RegisterNetEvent('vehicle_rental:openRentalMenu')
AddEventHandler('vehicle_rental:openRentalMenu', function()
    print('Vehicle rental menu opened')

    local playerId = GetPlayerServerId(PlayerId())

    -- Check if the player already has a rented vehicle
    ESX.TriggerServerCallback('vehicle_rental:hasRentedVehicle', function(hasRentedVehicle)
        if hasRentedVehicle then
            lib.notify({
                type = 'error',
                title = Config.Lang.cant_rent_vehicle_title,
                description = Config.Lang.already_rented_vehicle
            })
        else
            -- Proceed to show the rental menu
            ESX.TriggerServerCallback('vehicle_rental:getOwnedVehicles', function(ownedVehicles)
                local vehicleOptions = {}

                for _, vehicle in pairs(ownedVehicles) do
                    table.insert(vehicleOptions, { label = vehicle.plate, value = vehicle.plate })
                end

                local input = lib.inputDialog(Config.Lang.select_vehicle, {
                    {
                        type = 'select',
                        label = Config.Lang.select_vehicle,
                        options = vehicleOptions
                    },
                    {
                        type = 'number',
                        label = Config.Lang.enter_price,
                        min = 0
                    },
                    {
                        type = 'number',
                        label = Config.Lang.enter_duration,
                        min = 1
                    }
                })

                if input then
                    local selectedVehicle = input[1]
                    local rentalPrice = input[2]
                    local rentalDuration = input[3]

                    local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

                    if closestPlayer ~= -1 and closestDistance <= 3.0 then
                        TriggerServerEvent('vehicle_rental:sendRentalOffer', GetPlayerServerId(closestPlayer), selectedVehicle, rentalPrice, rentalDuration)
                    else
                        lib.notify({
                            type = 'error',
                            title = Config.Lang.no_nearby_player_title,
                            description = Config.Lang.no_nearby_player
                        })
                    end
                end
            end, playerId)
        end
    end)
end)

RegisterNetEvent('vehicle_rental:receiveRentalOffer')
AddEventHandler('vehicle_rental:receiveRentalOffer', function(sourceId, vehiclePlate, rentalPrice, rentalDuration)
    local acceptOffer = lib.alertDialog({
        header = Config.Lang.offer_received .. vehiclePlate,
        content = "Price: " .. Config.Currency .. rentalPrice .. "\nDuration: " .. rentalDuration .. " hours",
        centered = true,
        cancel = true
    })

    if acceptOffer == 'confirm' then
        TriggerServerEvent('vehicle_rental:acceptRentalOffer', sourceId, vehiclePlate, rentalPrice, rentalDuration)
    else
        lib.notify({
            type = 'error',
            title = Config.Lang.offer_declined_title,
            description = Config.Lang.offer_declined
        })
    end
end)
