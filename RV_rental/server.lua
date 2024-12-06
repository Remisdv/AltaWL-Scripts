ESX = exports['es_extended']:getSharedObject()

function getRandomChar()
    local randomChoice = math.random(1, 2)
    if randomChoice == 1 then
        return string.char(math.random(65, 90)) -- Generates an uppercase letter (A-Z)
    else
        return tostring(math.random(0, 9)) -- Generates a digit (0-9)
    end
end

function GeneratePlate()
    local plate = getRandomChar() .. getRandomChar() .. getRandomChar() .. " " .. getRandomChar() .. getRandomChar() .. getRandomChar()
    
    local result = MySQL.Sync.fetchAll('SELECT plate FROM owned_vehicles WHERE plate = @plate', {
        ['@plate'] = plate
    })

    while #result > 0 do
        plate = getRandomChar() .. getRandomChar() .. getRandomChar() .. " " .. getRandomChar() .. getRandomChar() .. getRandomChar()
        result = MySQL.Sync.fetchAll('SELECT plate FROM owned_vehicles WHERE plate = @plate', {
            ['@plate'] = plate
        })
    end

    if Config.Debug then
        print("Plate generated: " .. plate)
    end

    return plate
end

RegisterNetEvent('esx_vehicle_rental:rentVehicle')
AddEventHandler('esx_vehicle_rental:rentVehicle', function(model, price, duration, spawnPos, paymentMethod)
    local xPlayer = ESX.GetPlayerFromId(source)
    local moneyAvailable = paymentMethod == 'Cash' and xPlayer.getMoney() or xPlayer.getAccount('bank').money

    if moneyAvailable >= price then
        if paymentMethod == 'Cash' then
            xPlayer.removeMoney(price)
        else
            xPlayer.removeAccountMoney('bank', price)
        end

        local plate = GeneratePlate()
        local expirationTime = os.time() + (duration * 3600) -- Calculate expiration time in seconds

        MySQL.Async.execute('INSERT INTO owned_vehicles (owner, plate, vehicle, type, rent_duration) VALUES (@owner, @plate, @vehicle, @type, @rent_duration)', {
            ['@owner'] = xPlayer.identifier,
            ['@plate'] = plate,
            ['@vehicle'] = json.encode({model = model, plate = plate}),
            ['@type'] = 'car',
            ['@rent_duration'] = expirationTime
        })

        -- Spawn the vehicle
        TriggerClientEvent('esx_vehicle_rental:spawnVehicle', xPlayer.source, model, plate, spawnPos)

        if Config.Debug then
            print("Vehicle rented: " .. model .. " [" .. plate .. "] for " .. duration .. " hours.")
        end
    else
        TriggerClientEvent('esx:showNotification', xPlayer.source, Config.Lang.not_enough_money)

        if Config.Debug then
            print("Transaction declined: insufficient funds.")
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        local currentTime = os.time()

        -- Retrieve all vehicles whose rental period has expired and have a valid rent_duration
        MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE rent_duration IS NOT NULL AND rent_duration <= @currentTime', {
            ['@currentTime'] = currentTime
        }, function(vehicles)
            for _, vehicle in ipairs(vehicles) do
                -- Delete the vehicle from the database
                MySQL.Async.execute('DELETE FROM owned_vehicles WHERE plate = @plate', {
                    ['@plate'] = vehicle.plate
                })

                if Config.Debug then
                    print("Vehicle deleted from the database: " .. vehicle.plate)
                end

                -- Inform the player and stop the vehicle
                local xPlayers = ESX.GetPlayers()
                local playerFound = false

                for _, xPlayerId in ipairs(xPlayers) do
                    local xPlayer = ESX.GetPlayerFromId(xPlayerId)
                    if xPlayer.identifier == vehicle.owner then
                        playerFound = true
                        TriggerClientEvent('esx_vehicle_rental:endRental', xPlayer.source, vehicle.plate)
                        if Config.Debug then
                            print("Rental end event sent to player: " .. xPlayer.source)
                        end
                        break
                    end
                end

                -- If the player is not found or not connected, lock the vehicle if present on the map
                if not playerFound then
                    TriggerClientEvent('esx_vehicle_rental:lockVehicle', -1, vehicle.plate)
                    if Config.Debug then
                        print("No player found for the vehicle: " .. vehicle.plate .. ". Vehicle locked.")
                    end
                end
            end
        end)

        Citizen.Wait(60000) -- Check every minute
    end
end)

