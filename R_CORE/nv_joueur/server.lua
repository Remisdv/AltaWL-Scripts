-- Récupérer ESX avec la nouvelle méthode d'export
local ESX = exports['es_extended']:getSharedObject()

-- Configuration
local startingCash = 500   -- Montant d'argent en cash à donner
local startingBank = 800  -- Montant d'argent en banque à donner

-- Fonction pour vérifier la connexion complète du joueur
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000) -- Attente d'une seconde avant chaque vérification

        local players = ESX.GetPlayers()

        for _, playerId in ipairs(players) do
            local xPlayer = ESX.GetPlayerFromId(playerId)

            if xPlayer and xPlayer.getIdentifier() then
                local identifier = xPlayer.getIdentifier()

                MySQL.Async.fetchScalar("SELECT startingitem FROM users WHERE identifier = @identifier", {
                    ['@identifier'] = identifier
                }, function(startingitem)
                    if startingitem == 0 then  -- Vérifie si c'est la première connexion
                        -- Donne l'argent
                        xPlayer.addAccountMoney('money', startingCash)   -- Ajoute de l'argent en cash
                        xPlayer.addAccountMoney('bank', startingBank)  -- Ajoute de l'argent en banque

                        -- Met à jour la colonne startingitem
                        MySQL.Async.execute("UPDATE users SET startingitem = 1 WHERE identifier = @identifier", {
                            ['@identifier'] = identifier
                        })

                        print("Premier login détecté pour: " .. xPlayer.getName() .. ". Argent donné.")
                    end
                end)
                
                Citizen.Wait(1000) -- Petite pause avant la prochaine vérification pour le même joueur
            end
        end
    end
end)
