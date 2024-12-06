ESX = exports['es_extended']:getSharedObject()

local bankCoords = vector3(472.14956665039, -996.34442138672, 35.683685302734) -- Mettre les coordonnées souhaitées

-- Fonction pour ouvrir la page d'accueil du menu de gestion bancaire
local function openBankHomeMenu()
    lib.registerContext({
        id = 'bank_home_menu',
        title = 'Gestion bancaire',
        options = {
            {
                title = 'Voir tous les comptes',
                description = 'Afficher tous les comptes bancaires',
                event = 'ox_lib:client:openBankMenu'
            },
            {
                title = 'Rechercher par lettre',
                description = 'Rechercher les comptes par une lettre',
                event = 'ox_lib:client:searchByLetter'
            },
            {
                title = 'Trier par richesse',
                description = 'Afficher les comptes du plus riche au moins riche',
                event = 'ox_lib:client:sortByRichness'
            }
        }
    })
    lib.showContext('bank_home_menu')
end

-- Fonction pour ouvrir le menu de gestion bancaire
local function openBankMenu()
    ESX.TriggerServerCallback('getBankAccounts', function(accounts)
        local options = {}
        if accounts then
            for i=1, #accounts, 1 do
                local fullName = accounts[i].firstname .. ' ' .. accounts[i].lastname
                local bankAmount = tonumber(accounts[i].bank)
                if fullName and bankAmount then
                    --print('Ajout du compte :', fullName, bankAmount)
                    table.insert(options, {
                        title = fullName .. ' - $' .. bankAmount,
                        description = "Montant en banque: $" .. bankAmount,
                        event = 'ox_lib:client:manageAccount',
                        args = { identifier = accounts[i].identifier, bank = bankAmount }
                    })
                else
                    --print('Erreur : Données manquantes pour le compte', accounts[i])
                end
            end

            if #options > 0 then
                lib.registerContext({
                    id = 'bank_menu',
                    title = 'Comptes bancaires',
                    options = options
                })
                lib.showContext('bank_menu')
            else
                ESX.ShowNotification('Aucun compte trouvé.')
            end
        else
            ESX.ShowNotification('Aucun compte trouvé.')
        end
    end)
end

-- Fonction pour rechercher les comptes par une lettre
local function searchByLetter()
    local letter = lib.inputDialog('Rechercher par lettre', {'Lettre'})[1]
    if letter and letter:match("%a") then
        ESX.TriggerServerCallback('getBankAccounts', function(accounts)
            local options = {}
            if accounts then
                for i=1, #accounts, 1 do
                    local fullName = accounts[i].firstname .. ' ' .. accounts[i].lastname
                    local bankAmount = tonumber(accounts[i].bank)
                    if fullName and bankAmount and fullName:sub(1, 1):lower() == letter:lower() then
                        --print('Ajout du compte :', fullName, bankAmount)
                        table.insert(options, {
                            title = fullName .. ' - $' .. bankAmount,
                            description = "Montant en banque: $" .. bankAmount,
                            event = 'ox_lib:client:manageAccount',
                            args = { identifier = accounts[i].identifier, bank = bankAmount }
                        })
                    end
                end

                if #options > 0 then
                    lib.registerContext({
                        id = 'bank_menu',
                        title = 'Comptes bancaires',
                        options = options
                    })
                    lib.showContext('bank_menu')
                else
                    ESX.ShowNotification('Aucun compte trouvé pour la lettre '..letter..'.')
                end
            else
                ESX.ShowNotification('Aucun compte trouvé.')
            end
        end)
    else
        ESX.ShowNotification('Lettre invalide.')
    end
end

-- Fonction pour trier les comptes du plus riche au moins riche
local function sortByRichness()
    ESX.TriggerServerCallback('getBankAccounts', function(accounts)
        local options = {}
        if accounts then
            for i=1, #accounts, 1 do
                local fullName = accounts[i].firstname .. ' ' .. accounts[i].lastname
                local bankAmount = tonumber(accounts[i].bank)
                if fullName and bankAmount then
                    --print('Ajout du compte :', fullName, bankAmount)
                    table.insert(options, {
                        title = fullName .. ' - $' .. bankAmount,
                        description = "Montant en banque: $" .. bankAmount,
                        event = 'ox_lib:client:manageAccount',
                        args = { identifier = accounts[i].identifier, bank = bankAmount }
                    })
                else
                    --print('Erreur : Données manquantes pour le compte', accounts[i])
                end
            end

            table.sort(options, function(a, b)
                return (a.args.bank or 0) > (b.args.bank or 0)
            end)

            if #options > 0 then
                lib.registerContext({
                    id = 'bank_menu',
                    title = 'Comptes bancaires',
                    options = options
                })
                lib.showContext('bank_menu')
            else
                ESX.ShowNotification('Aucun compte trouvé.')
            end
        else
            ESX.ShowNotification('Aucun compte trouvé.')
        end
    end)
end

function showAccountTransactions(data)
    local identifier = data.identifier
    ESX.TriggerServerCallback('getAccountTransactions', function(transactions)
        local transactionOptions = {}
        for i=1, #transactions, 1 do
            table.insert(transactionOptions, {
                title = transactions[i].date .. ' - $' .. transactions[i].value,
                description = transactions[i].type,
            })
        end

        lib.registerContext({
            id = 'transactions_menu',
            title = 'Transactions',
            options = transactionOptions
        })

        lib.showContext('transactions_menu')
    end, identifier)
end

function manageAccount(data)
    local identifier = data.identifier

    local manageOptions = {
        {
            title = 'Ajouter de l\'argent',
            description = 'Ajouter de l\'argent au compte',
            event = 'ox_lib:client:addMoney',
            args = { identifier = identifier }
        },
        {
            title = 'Retirer de l\'argent',
            description = 'Retirer de l\'argent du compte',
            event = 'ox_lib:client:removeMoney',
            args = { identifier = identifier }
        },
        {
            title = 'Voir les transactions',
            description = 'Voir les transactions',
            event = 'ox_lib:client:showAccountTransactions',
            args = { identifier = identifier }
        }
    }

    lib.registerContext({
        id = 'manage_menu',
        title = 'Gérer le compte',
        options = manageOptions
    })

    lib.showContext('manage_menu')
end

RegisterNetEvent('ox_lib:client:openBankMenu')
AddEventHandler('ox_lib:client:openBankMenu', function()
    openBankMenu()
end)

RegisterNetEvent('ox_lib:client:searchByLetter')
AddEventHandler('ox_lib:client:searchByLetter', function()
    searchByLetter()
end)

RegisterNetEvent('ox_lib:client:sortByRichness')
AddEventHandler('ox_lib:client:sortByRichness', function()
    sortByRichness()
end)

RegisterNetEvent('ox_lib:client:manageAccount')
AddEventHandler('ox_lib:client:manageAccount', function(data)
    manageAccount(data)
end)

RegisterNetEvent('ox_lib:client:showAccountTransactions')
AddEventHandler('ox_lib:client:showAccountTransactions', function(data)
    showAccountTransactions(data)
end)

RegisterNetEvent('ox_lib:client:addMoney')
AddEventHandler('ox_lib:client:addMoney', function(data)
    local identifier = data.identifier
    local amount = tonumber(lib.inputDialog('Ajouter de l\'argent', {'Montant'})[1])
    if amount and amount > 0 then
        TriggerServerEvent('bank:addMoney', identifier, amount)
    else
        ESX.ShowNotification('Montant invalide.')
    end
end)

RegisterNetEvent('ox_lib:client:removeMoney')
AddEventHandler('ox_lib:client:removeMoney', function(data)
    local identifier = data.identifier
    local amount = tonumber(lib.inputDialog('Retirer de l\'argent', {'Montant'})[1])
    if amount and amount > 0 then
        TriggerServerEvent('bank:removeMoney', identifier, amount)
    else
        ESX.ShowNotification('Montant invalide.')
    end
end)

local isPlayerEligible = false
local playerJobName = nil
local playerJobGrade = nil

-- Vérification du job et grade du joueur toutes les 10 secondes
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(10000)
        local playerData = ESX.GetPlayerData()
        playerJobName = playerData.job and playerData.job.name or nil
        playerJobGrade = playerData.job and playerData.job.grade or nil
        isPlayerEligible = (playerJobName == 'lspd' and playerJobGrade >= 12)
    end
end)

-- Vérification de la distance et affichage du menu bancaire
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        if isPlayerEligible then
            local playerCoords = GetEntityCoords(PlayerPedId())
            local distance = #(playerCoords - bankCoords)

            if distance < 3.0 then
                Citizen.Wait(1)
                lib.showTextUI('[E] - Accéder au menu bancaire', {
                    position = 'right-center',
                    icon = 'fas fa-bank',
                    style = {
                        borderRadius = 0,
                        color = 'white'
                    }
                })

                while distance < 2.0 do
                    Citizen.Wait(1)
                    playerCoords = GetEntityCoords(PlayerPedId())
                    distance = #(playerCoords - bankCoords)

                    if IsControlJustReleased(0, 38) then -- 38 is the key E
                        openBankHomeMenu()
                    end

                    if distance >= 2.0 then
                        lib.hideTextUI()
                    end
                end
            else
                lib.hideTextUI()
            end
        else
            Citizen.Wait(1000) -- Si le joueur n'est pas éligible, attendre plus longtemps avant de vérifier à nouveau
        end
    end
end)