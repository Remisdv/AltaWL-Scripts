ESX = exports["es_extended"]:getSharedObject()

RegisterCommand('openSelectCarMenu', function()
    if ESX.PlayerData.job and ESX.PlayerData.job.name == 'selectcar' then
        openSellMenu()
    end
end, false)

RegisterKeyMapping('openSelectCarMenu', 'Ouvrir le menu Select Car', 'keyboard', 'F4')

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
            children = {
                {
                    title = "ID Acheteur",
                    description = "Entrer l'ID de l'acheteur",
                    event = "selectcar:sellVehicle",
                    args = {}
                }
            }
        }
    }
    lib.registerContext({
        id = 'sell_menu',
        title = 'Menu Revente',
        options = menu
    })
    lib.showContext('sell_menu')
end

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

RegisterNetEvent('selectcar:sellVehicle')
AddEventHandler('selectcar:sellVehicle', function()
    local buyerId = lib.inputDialog("Vendre Véhicule", {"ID de l'acheteur", "Plaque du véhicule", "Prix de vente"})
    if buyerId and #buyerId == 3 then
        TriggerServerEvent('selectcar:sellVehicle', tonumber(buyerId[1]), buyerId[2], tonumber(buyerId[3]))
    end
end)
