local spawnedCars = {}

RegisterNetEvent('nass_serverstore:notify', function(message)
	notify(message)
end)

function notify(message)
    if GetResourceState('nass_notifications') == 'started' then
        exports["nass_notifications"]:ShowNotification("alert", "Info", message, 5000)
    else
        BeginTextCommandThefeedPost('STRING')
        AddTextComponentSubstringPlayerName(message)
        EndTextCommandThefeedPostTicker(0, 1)
    end
end

RegisterNetEvent('nass_serverstore:spawnveh', function(vehType)
	ServerCallback('nass_serverstore:redeemCheck', function(isLegit, newPlate, model)
		if not isLegit or not newPlate then return end
		local carExist = false
		if newPlate == "ESXNEEDSNEWPLATE" then
			newPlate = exports['esx_vehicleshop']:GeneratePlate()
		end

		NassSpawnVehicle(model, GetEntityCoords(PlayerPedId()) - vector3(0.0, 0.0, 10.0), 0.0, function(vehicle) -- Get vehicle info
			carExist = true

			SetEntityVisible(vehicle, false, false)
			SetEntityCollision(vehicle, false, false)
			FreezeEntityPosition(vehicle, true)

			local vehicleProps = GetVehicleProperties(vehicle)
			vehicleProps.plate = newPlate
			TriggerServerEvent('nass_serverstore:setVehicle', vehicleProps, model, vehType)

			SetEntityAsMissionEntity(vehicle)
			DeleteVehicle(vehicle)
		end, false)

		Wait(500)
		if carExist then return end
		TriggerServerEvent('nass_serverstore:carNotExist')
	end, model)
end)

--Taken from ESX


AddEventHandler('onResourceStop', function(resourceName)
	if (GetCurrentResourceName() ~= resourceName) then
	  return
	end
	
	for k, v in pairs(spawnedCars) do
        SetEntityAsMissionEntity(v)
		DeleteVehicle(v)
	end
end)



RegisterNetEvent('nass_serverstore:openPlateChange')
AddEventHandler('nass_serverstore:openPlateChange', function()
	ServerCallback('nass_serverstore:hasAccess', function(canUse)
		if canUse then
            local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
			if vehicle ~= 0 then
				local currPlate = GetVehicleNumberPlateText(vehicle)
				local input = lib.inputDialog('Plate Change', {'What would you like your new plate to be?'})
                if not input then return end

                local newPlate = tostring(input[1])
                local newPlateLength = #newPlate
				if newPlate then
                    newPlate = string.upper(newPlate)
                    if newPlateLength <= 0 then
                        notify('Plate is too short')
                    elseif 8 < newPlateLength then
                        notify('Plate is too long')
                    else
						ServerCallback('nass_serverstore:changeplate', function(shouldChange)
                            print(shouldChange)
							if shouldChange then
								SetVehicleNumberPlateText(vehicle, newPlate)
                                notify('Plate has been changed from ' .. currPlate .. ' to ' .. newPlate)
							end
						end, newPlate, currPlate)
                    end
				end
			else
				notify('You must be in a vehicle')
			end
		end
	end, "plate")
end)

RegisterNetEvent('nass_serverstore:openNameChange')
AddEventHandler('nass_serverstore:openNameChange', function()
	ServerCallback('nass_serverstore:hasAccess', function(canUse)
		if canUse then
			local input = lib.inputDialog('Name Change', {'First Name?', 'Last Name?'})
			if not input then return end
			local first = tostring(input[1])
			local last = tostring(input[2])

			ServerCallback('nass_serverstore:changename', function(shouldChange)
				if shouldChange then
					notify("You have changed your name to "..first.." "..last..".")
				end
			end, first, last)
		end
	end, "name")
end)







--- REMI

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

        ESX.TriggerServerCallback('tebex:isPlateTaken', function(isPlateTaken)
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




function spawnVehicletebex(modelName, x, y, z, heading)
    local model = GetHashKey(modelName)
	
    -- Charger le modèle du véhicule
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(1)
    end
	print("model loaded")
    -- Créer le véhicule
    local vehicle = CreateVehicle(model, x, y, z, heading, true, false)
    SetVehicleNeedsToBeHotwired(vehicle, false)
    SetVehicleHasBeenOwnedByPlayer(vehicle, true)
    SetEntityAsMissionEntity(vehicle, true, true)
    SetVehicleIsStolen(vehicle, false)
    SetVehicleIsWanted(vehicle, false)
    SetVehRadioStation(vehicle, 'OFF')
    local plate = GeneratePlate()
    SetVehicleNumberPlateText(vehicle, plate)
	print("Plate set")
    -- Assurer que le véhicule est contrôlé par le script
    SetEntityAsMissionEntity(vehicle, true, true)

    -- Libérer le modèle pour économiser la mémoire
    SetModelAsNoLongerNeeded(model)
	print("Model set as no longer needed")
    local vehicleProperties = ESX.Game.GetVehicleProperties(vehicle)
    local spawnPosition = {x = x, y = y, z = z, heading = heading}
	print("Vehicle properties set")
    TriggerServerEvent('tebex:buyVehicle', vehicleProperties, spawnPosition)
	print('Vehicle bought')
    TriggerServerEvent('tebex:giveVehicleKey', plate, modelName)
	print('Vehicle key given')
	

    return vehicle
end

RegisterNetEvent('tebex:spawnVehicle')
AddEventHandler('tebex:spawnVehicle', function(modelName)
    local playerPed = PlayerPedId()
	print('tebex:spawnVehicle')

    local vehicle = spawnVehicletebex(modelName, -30.9, -1090.3, 26.0, 338.8)
	TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
end)
