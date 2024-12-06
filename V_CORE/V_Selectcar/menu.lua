ESX = exports["es_extended"]:getSharedObject()

-- Fonction pour ouvrir le menu principal
function openSellMenu()
    local menu = {
        {
            title = "Nettoyer Véhicule",
            description = "Nettoyer le véhicule actuel",
            event = "selectcar:cleanVehicle"
        },
        {
            title = "Vendre Véhicule",
            description = "Vendre un véhicule",
            event = "selectcar:sellVehicle"
        }
    }
    lib.registerContext({
        id = 'sell_menu',
        title = 'Menu Revente',
        options = menu
    })
    lib.showContext('sell_menu')
end

-- Commande pour ouvrir le menu avec F6
RegisterCommand('openSelectCarMenu', function()
    if ESX.PlayerData.job and ESX.PlayerData.job.name == 'selectcar' then
        openSellMenu()
    end
end, false)

RegisterKeyMapping('openSelectCarMenu', 'Ouvrir le menu Select Car', 'keyboard', 'F4')

-- Nettoyage du véhicule
RegisterNetEvent('selectcar:cleanVehicle')
AddEventHandler('selectcar:cleanVehicle', function()
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle then
        SetVehicleDirtLevel(vehicle, 0)
        ESX.ShowNotification("Véhicule nettoyé.")
    else
        ESX.ShowNotification("Vous devez être dans un véhicule.")
    end
end)

-- Vente du véhicule
RegisterNetEvent('selectcar:sellVehicle')
AddEventHandler('selectcar:sellVehicle', function()
    local input = lib.inputDialog("Vendre Véhicule", {
        {label = "ID de l'acheteur", type = 'number'},
        {label = "Plaque du véhicule", type = 'string'},
        {label = "Prix de vente", type = 'number'}
    })
    if input and #input == 3 then
        TriggerServerEvent('selectcar:sellVehicle', tonumber(input[1]), input[2], tonumber(input[3]))
    end
end)

-- Confirmation de l'achat
RegisterNetEvent('selectcar:confirmPurchase')
AddEventHandler('selectcar:confirmPurchase', function(sellerId, plate, price)
    local confirmed = lib.alertDialog({
        message = "Voulez-vous acheter ce véhicule pour $" .. price .. " ?",
        buttons = {
            {label = "Oui", value = true},
            {label = "Non", value = false}
        }
    })

    TriggerServerEvent('selectcar:confirmPurchase', sellerId, plate, price, confirmed)
end)
