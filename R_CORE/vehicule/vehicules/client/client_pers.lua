Citizen.CreateThread(function()
    while true do
        Citizen.Wait(10)  -- Petite attente pour éviter une boucle trop rapide
        local playerPed = PlayerPedId()
        
        if IsPedInAnyVehicle(playerPed, false) then
            local playerVehicle = GetVehiclePedIsIn(playerPed, false)
            if GetPedInVehicleSeat(playerVehicle, -1) == playerPed then
                Citizen.Wait(0)
                local lastSavedTime = GetGameTimer()  -- Initialiser le dernier temps de sauvegarde

                while IsPedInAnyVehicle(playerPed, false) do
                    Citizen.Wait(1000)

                    -- Sauvegarder toutes les 10 secondes
                    if GetGameTimer() - lastSavedTime >= 5000 then
                        local plate = GetVehicleNumberPlateText(playerVehicle)
                        local position = GetEntityCoords(playerVehicle)
                        local heading = GetEntityHeading(playerVehicle)
                        local vehiclePos = {
                            x = position.x,
                            y = position.y,
                            z = position.z,
                            heading = heading
                        }
                        local data = lib.getVehicleProperties(playerVehicle)
                        if plate then
                            if data then
                                --print("Saving vehicle position every 5 seconds for plate: " .. plate)
                                TriggerServerEvent('saveVehiclePosition', plate, vehiclePos, data)
                                lastSavedTime = GetGameTimer()  -- Mettre à jour le dernier temps de sauvegarde
                            else
                                --print("Failed to get vehicle data for plate: " .. plate)
                            end
                        else
                            --print("Failed to get vehicle plate.")
                        end
                    end
                end

                -- Sauvegarder quand le joueur sort du véhicule
                local plate = GetVehicleNumberPlateText(playerVehicle)
                local position = GetEntityCoords(playerVehicle)
                local heading = GetEntityHeading(playerVehicle)
                local vehiclePos = {
                    x = position.x,
                    y = position.y,
                    z = position.z,
                    heading = heading
                }
                local data = lib.getVehicleProperties(playerVehicle)
                if plate then
                    if data then
                        --print(plate)
                        --print("Triggering saveVehiclePosition event for plate: " .. plate)
                        TriggerServerEvent('saveVehiclePosition', plate, vehiclePos, data)
                    else
                        --print(plate)
                        --print("Failed to get vehicle data for plate: " .. plate)
                    end
                else
                    --print("Failed to get vehicle plate.")
                end
            else
                --print("Player is not the driver.")
            end
        end
    end
end)

