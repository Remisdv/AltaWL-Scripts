-- Fonction utilitaire pour obtenir le véhicule du joueur
local function GetPlayerVehicle()
    local playerPed = PlayerPedId()
    return GetVehiclePedIsIn(playerPed, false), playerPed
end

-- Commande pour changer de place dans le véhicule
RegisterCommand('seat', function(source, args)
    local vehicle, playerPed = GetPlayerVehicle()

    if vehicle ~= 0 then
        local seatIndex = tonumber(args[1]) - 1 -- Convertir le numéro de siège en index de siège (0-based)
        local maxSeats = GetVehicleMaxNumberOfPassengers(vehicle)

        if seatIndex >= -1 and seatIndex <= maxSeats then
            TaskWarpPedIntoVehicle(playerPed, vehicle, seatIndex)
        else
            print("Numéro de siège invalide !")
        end
    else
        print("Vous n'êtes pas dans un véhicule !")
    end
end, false)

-- Commande pour baisser ou remonter la vitre spécifique du véhicule
RegisterCommand('window', function(source, args)
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)

    if vehicle ~= 0 then
        local windowIndex = tonumber(args[1]) - 1 -- Convertir le numéro de la fenêtre en index de fenêtre (0-based)

        if windowIndex >= 0 and windowIndex <= 3 then
            if IsVehicleWindowIntact(vehicle, windowIndex) then
                RollDownWindow(vehicle, windowIndex)
                print("Vitre baissée pour la fenêtre: " .. (windowIndex + 1))
            else
                RollUpWindow(vehicle, windowIndex)
                print("Vitre remontée pour la fenêtre: " .. (windowIndex + 1))
            end
        else
            print("Numéro de fenêtre invalide !")
        end
    else
        print("Vous n'êtes pas dans un véhicule !")
    end
end, false)

-- Contrôles du clavier pour baisser ou remonter les vitres avec les touches 4, 5, 6, 8 du pavé numérique
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(30) -- 20ms d'attente pour réduire la charge

        local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)

        if vehicle ~= 0 then
            if IsControlJustPressed(0, 108) then -- Numpad 4
                local windowIndex = 0
                if IsVehicleWindowIntact(vehicle, windowIndex) then
                    RollDownWindow(vehicle, windowIndex)
                else
                    RollUpWindow(vehicle, windowIndex)
                end
            elseif IsControlJustPressed(0, 110) then -- Numpad 5
                local windowIndex = 1
                if IsVehicleWindowIntact(vehicle, windowIndex) then
                    RollDownWindow(vehicle, windowIndex)
                else
                    RollUpWindow(vehicle, windowIndex)
                end
            elseif IsControlJustPressed(0, 109) then -- Numpad 6
                local windowIndex = 2
                if IsVehicleWindowIntact(vehicle, windowIndex) then
                    RollDownWindow(vehicle, windowIndex)
                else
                    RollUpWindow(vehicle, windowIndex)
                end
            elseif IsControlJustPressed(0, 111) then -- Numpad 8
                local windowIndex = 3
                if IsVehicleWindowIntact(vehicle, windowIndex) then
                    RollDownWindow(vehicle, windowIndex)
                else
                    RollUpWindow(vehicle, windowIndex)
                end
            end
        end
    end
end)
