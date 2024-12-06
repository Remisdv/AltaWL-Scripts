ESX = exports['es_extended']:getSharedObject()

local function showNotification(text)
    lib.notify({
        title = 'Information',
        description = text,
        type = 'info',
        duration = 15000 -- 15 secondes
    })
end




-- menu de base
lib.addRadialItem({
    {
      id = 'commands_menu_item',
      label = 'Commandes',
      icon = 'shield-halved',
      menu = 'commands_menu'
    },
    {
        id = 'aide_menu_item',
        label = 'Touches',
        icon = 'briefcase',
        menu = 'keys_menu_1'
    }
  })


-- commande 


lib.registerRadial({
    id = 'commands_menu',
    items = {
        {
            label = 'Porter',
            icon = 'fa-solid fa-hand',
            onSelect = function()
                ExecuteCommand('porter')
            end
        },
        {
            label = 'Arme',
            icon = 'fa-solid fa-gun',
            onSelect = function()
                ExecuteCommand('arme')
            end
        },
        {
            label = 'Report',
            icon = 'fa-solid fa-paper-plane',
            onSelect = function()
                ExecuteCommand('report')
            end
        },
        {
            label = 'Réticule ON/OFF',
            icon = 'fa-solid fa-crosshairs',
            onSelect = function()
                ExecuteCommand('toggleCrosshair')
            end
        },
        {
            label = 'Page suivante',
            icon = 'fa-solid fa-arrow-right',
            menu = 'commands_menu_2'
        }
    }
})

lib.registerRadial({
    id = 'commands_menu_2',
    items = {
        {
            label = 'Mes infos',
            icon = 'fa-solid fa-hashtag',
            onSelect = 'myMenuHandler',
            onSelect = function()
                ExecuteCommand('info')
            end
        },
        {
            label ='Gang menu',
            icon = 'fa-solid fa-users',
            onSelect = function()
                ExecuteCommand('crew')
            end
        },
    }
})


--- touche




lib.registerRadial({
    id = 'keys_menu_1',
    items = {
        {
            label = 'Parler',
            icon = 'fa-solid fa-microphone',
            onSelect = function()
                showNotification('Parler --> N (ou la touche que vous avez configuré)')
            end
        },
        {
            label = 'Téléphone',
            icon = 'fa-solid fa-mobile',
            onSelect = function()
                showNotification('Ouvrir/Ranger le téléphone --> F1 (sinon changer dans les paramètres)')
            end
        },
        {
            label = 'Coffre Voiture',
            icon = 'fa-solid fa-archive',
            onSelect = function()
                showNotification('Coffre Voiture --> TAB')
            end
        },
        {
            label = 'Vérouiller/Dévérouiller',
            icon = 'fa-solid fa-lock',
            onSelect = function()
                showNotification('Vérouiller/Dévérouiller votre véhicule --> G')
            end
        },
        {
            label = 'Page suivante',
            icon = 'fa-solid fa-arrow-right',
            menu = 'keys_menu_2'
        }
    }
})

lib.registerRadial({
    id = 'keys_menu_2',
    items = {
        {
            label = 'Phares',
            icon = 'fa-solid fa-lightbulb',
            onSelect = function()
                showNotification('Phares --> H')
            end
        },
        {
            label = 'Klaxon',
            icon = 'fa-solid fa-bullhorn',
            onSelect = function()
                showNotification('Klaxon --> E')
            end
        },
        {
            label = 'Inventaire',
            icon = 'fa-solid fa-briefcase',
            onSelect = function()
                showNotification('Inventaire --> TAB')
            end
        },
        {
            label = 'Menu métier',
            icon = 'fa-solid fa-briefcase',
            onSelect = function()
                showNotification('Menu métier --> F6 si actif')
            end
        },
        {
            label = 'Page suivante',
            icon = 'fa-solid fa-arrow-right',
            menu = 'keys_menu_3'
        }
    }
})

lib.registerRadial({
    id = 'keys_menu_3',
    items = {
        {
            label = 'Menu animations',
            icon = 'fa-solid fa-theater-masks',
            onSelect = function()
                showNotification('Menu animations --> F3')
            end
        },
        {
            label = 'Lever les mains',
            icon = 'fa-solid fa-hand-paper',
            onSelect = function()
                showNotification('Lever les mains --> X')
            end
        },
        {
            label = 'Pointer du doigt',
            icon = 'fa-solid fa-hand-point-up',
            onSelect = function()
                showNotification('Pointer du doigt --> B')
            end
        },
        {
            label = 'Accroupie',
            icon = 'fa-solid fa-arrow-down',
            onSelect = function()
                showNotification('Accroupie --> CTRL')
            end
        },
        {
            label = 'Page suivante',
            icon = 'fa-solid fa-arrow-right',
            menu = 'keys_menu_4'
        }
    }
})

lib.registerRadial({
    id = 'keys_menu_4',
    items = {
        {
            label = 'Allonger',
            icon = 'fa-solid fa-bed',
            onSelect = function()
                showNotification('Allonger --> CTRL Droite')
            end
        },
        {
            label = 'Ouvrir la barre de commandes',
            icon = 'fa-solid fa-keyboard',
            onSelect = function()
                showNotification('Ouvrir la barre de commandes --> T')
            end
        },
        {
            label = 'Signaler un problème',
            icon = 'fa-solid fa-exclamation-triangle',
            onSelect = function()
                showNotification('Signaler quelconque problème en jeu --> /report')
            end
        },
        {
            label = 'Porter',
            icon = 'fa-solid fa-hand-holding',
            onSelect = function()
                showNotification('Porter --> /porter')
            end
        },
        {
            label = 'Page suivante',
            icon = 'fa-solid fa-arrow-right',
            menu = 'keys_menu_5'
        }
    }
})

lib.registerRadial({
    id = 'keys_menu_5',
    items = {
        {
            label = 'Activer la vente de drogue',
            icon = 'fa-solid fa-cannabis',
            onSelect = function()
                showNotification('Activer la vente de drogue --> /vente')
            end
        },
        {
            label = 'Simuler une action',
            icon = 'fa-solid fa-user-secret',
            onSelect = function()
                showNotification('Simuler une action impossible à réaliser --> /me suivit de votre message (Exemple : /me se gratte le nez va afficher : La personne se gratte le nez)')
            end
        },
        {
            label = 'Factures',
            icon = 'fa-solid fa-newspaper',
            onSelect = function()
                showNotification('Factures - F7')
            end
        },
        {
            label = 'Page précédente',
            icon = 'fa-solid fa-arrow-left',
            menu = 'keys_menu_4'
        }
    }
})



--- radial job lspd

lib.registerRadial({
    id = 'lspd_menu_radial',
    items = {
        {
            label = 'Panel',
            icon = 'fa-solid fa-shield-alt',
            onSelect = function()
                ExecuteCommand('panel')
            end
        },
        {
            label = 'Fouriere',
            icon = 'fa-solid fa-car',
            onSelect = function()
                ExecuteCommand('fouriere')
            end
        },
        {
            label = 'Open MDT',
            icon = 'fa-solid fa-laptop',
            onSelect = function()
                ExecuteCommand('Openmdt')
            end
        },
        {
            label = 'Binoculars',
            icon = 'fa-solid fa-binoculars',
            onSelect = function()
                ExecuteCommand('binoculars')
            end
        }
    }
})

--- radial job youtool
lib.registerRadial({
    id = 'youtool_menu_radial',
    items = {
        {
            label = 'Ouvrir le menu',
            icon = 'fa-solid fa-tools',
            onSelect = function()
                ExecuteCommand('vehicule')
            end
        }
    }
})

--- radial job burgershot
lib.registerRadial({
    id = 'burgershot_menu_radial',
    items = {
        {
            label = 'Prendre un plateau',
            icon = 'fa-solid fa-hamburger',
            onSelect = function()
                ExecuteCommand('e foodtrayb')
            end
        },
        {
            label = 'Prendre un BBQ',
            icon = 'fa-solid fa-hamburger',
            onSelect = function()
                ExecuteCommand('e bbq')
            end
        }
    }
})

--- radial job boite de nuit
lib.registerRadial({
    id = 'boite_menu',
    items = {
        {
            label = 'Champagne',
            icon = 'fa-solid fa-wine-glass',
            onSelect = function()
                ExecuteCommand('e champw')
            end
        },
        {
            label = 'Camera',
            icon = 'fa-solid fa-camera',
            onSelect = function()
                ExecuteCommand('e camera2')
            end
        },
        {
            label = 'Coffre',
            icon = 'fa-solid fa-box',
            onSelect = function()
                ExecuteCommand('e cbbox5')
            end
        },
        {
            label = 'Poubelle',
            icon = 'fa-solid fa-trash',
            onSelect = function()
                ExecuteCommand('e gbin4')
            end
        },
        {
            label = 'Guitare',
            icon = 'fa-solid fa-guitar',
            onSelect = function()
                ExecuteCommand('e guitarelectric')
            end
        },
        {
            label = 'Micro',
            icon = 'fa-solid fa-microphone',
            onSelect = function()
                ExecuteCommand('e microckd')
            end
        },
        {
            label = 'Page suivante',
            icon = 'fa-solid fa-arrow-right',
            menu = 'boite_menu_2'
        }
    }
})


lib.registerRadial({
    id = 'boite_menu_2',
    items = {
        {
            label = 'DJ',
            icon = 'fa-solid fa-headphones',
            onSelect = function()
                ExecuteCommand('e dj9')
            end
        }
    }
})

--- description entreprise
lib.registerRadial({
    id = 'unemployed_menu_1',
    items = {
        {
            label = 'Ambulance',
            icon = 'fa-solid fa-briefcase-medical',
            onSelect = function()
                showNotification('Ambulance - Service de secours.')
            end
        },
        {
            label = 'BeachClub',
            icon = 'fa-solid fa-umbrella-beach',
            onSelect = function()
                showNotification('BeachClub - Club de plage.')
            end
        },
        {
            label = 'BurgerShot',
            icon = 'fa-solid fa-hamburger',
            onSelect = function()
                showNotification('BurgerShot - Restaurant de burgers.')
            end
        },
        {
            label = 'Dynasty8',
            icon = 'fa-solid fa-building',
            onSelect = function()
                showNotification('Dynasty8 - Agence immobilière.')
            end
        },
        {
            label = 'Page suivante',
            icon = 'fa-solid fa-arrow-right',
            menu = 'unemployed_menu_2'
        }
    }
})

lib.registerRadial({
    id = 'unemployed_menu_2',
    items = {
        {
            label = 'Gouvernement',
            icon = 'fa-solid fa-landmark',
            onSelect = function()
                showNotification('Gouvernement - Services gouvernementaux.')
            end
        },
        {
            label = 'Hayes',
            icon = 'fa-solid fa-car-mechanic',
            onSelect = function()
                showNotification('Hayes - Garage et services automobiles.')
            end
        },
        {
            label = 'Japonais',
            icon = 'fa-solid fa-sushi',
            onSelect = function()
                showNotification('Japonais - Restaurant japonais.')
            end
        },
        {
            label = 'LSPD',
            icon = 'fa-solid fa-shield-alt',
            onSelect = function()
                showNotification('LSPD - Police de Los Santos.')
            end
        },
        {
            label = 'Page suivante',
            icon = 'fa-solid fa-arrow-right',
            menu = 'unemployed_menu_3'
        }
    }
})

lib.registerRadial({
    id = 'unemployed_menu_3',
    items = {
        {
            label = 'Matrix',
            icon = 'fa-solid fa-matrix',
            onSelect = function()
                showNotification('Matrix - Une boite de nuit underground.')
            end
        },
        {
            label = 'Benny\'s',
            icon = 'fa-solid fa-wrench',
            onSelect = function()
                showNotification('Benny\'s - Garage spécialisé.')
            end
        },
        {
            label = 'Pacific Bluffs',
            icon = 'fa-solid fa-spa',
            onSelect = function()
                showNotification('Pacific Bluffs - Un magnifique club.')
            end
        },
        {
            label = 'Pizzeria',
            icon = 'fa-solid fa-pizza-slice',
            onSelect = function()
                showNotification('Pizzeria - Restaurant italien.')
            end
        },
        {
            label = 'Page suivante',
            icon = 'fa-solid fa-arrow-right',
            menu = 'unemployed_menu_4'
        }
    }
})

lib.registerRadial({
    id = 'unemployed_menu_4',
    items = {
        {
            label = 'Rockford Records',
            icon = 'fa-solid fa-record-vinyl',
            onSelect = function()
                showNotification('Rockford Records - Maison de disques.')
            end
        },
        {
            label = 'Rhum',
            icon = 'fa-solid fa-wine-bottle',
            onSelect = function()
                showNotification('Rhum - Fabrication et distribution de rhum.')
            end
        },
        {
            label = 'Selectcar',
            icon = 'fa-solid fa-car',
            onSelect = function()
                showNotification('Selectcar - Concessionnaire automobile.')
            end
        },
        {
            label = 'Split Side',
            icon = 'fa-solid fa-theater-masks',
            onSelect = function()
                showNotification('Split Side - un magnifique club.')
            end
        },
        {
            label = 'Page suivante',
            icon = 'fa-solid fa-arrow-right',
            menu = 'unemployed_menu_5'
        }
    }
})

lib.registerRadial({
    id = 'unemployed_menu_5',
    items = {
        {
            label = 'Weazel News',
            icon = 'fa-solid fa-newspaper',
            onSelect = function()
                showNotification('Weazel News - Agence de presse.')
            end
        },
        {
            label = 'Youtool',
            icon = 'fa-solid fa-tools',
            onSelect = function()
                showNotification('Youtool - Magasin de bricolage et fournisseur des entreprises.')
            end
        },
        {
            label = 'Page précédente',
            icon = 'fa-solid fa-arrow-left',
            menu = 'unemployed_menu_4'
        }
    }
})

lib.registerRadial({
    id = 'selectcar_radial',
    items = {
        {
            label = 'Select Car',
            icon = 'fa-solid fa-newspaper',
            onSelect = function()
                ExecuteCommand('openSelectCarMenu')
            end
        }
    }
})

-- Fonction pour afficher une notification



function job(job)
    print(ESX.GetPlayerData().job.name)
    return ESX.GetPlayerData().job.name == job
end


function jobmenu()
    if job('lspd') then
        lib.addRadialItem({
            id = 'lspd_menu',
            icon = 'shield-halved',
            label = 'Police',
            menu = 'lspd_menu_radial'
          })
    elseif job('youtool') then
        lib.addRadialItem({
            id = 'youtool_menu',
            icon = 'fa-solid fa-tools',
            label = 'YouTool',
            menu = 'youtool_menu_radial'
          })
    elseif job('burgershot') then
        lib.addRadialItem({
            id = 'burgershot_menu',
            icon = 'fa-solid fa-hamburger',
            label = 'BurgerShot',
            menu = 'burgershot_menu_radial'
          })
    elseif job('matrix') then
        lib.addRadialItem({
            id = 'matrix_menu',
            icon = 'fa-solid fa-microchip',
            label = 'Matrix',
            menu = 'boite_menu'
          })
    elseif job('pacific') then
        lib.addRadialItem({
            id = 'pacific_menu',
            icon = 'fa-solid fa-cocktail',
            label = 'Pacific',
            menu = 'boite_menu'
          })
    elseif job('split') then
        lib.addRadialItem({
            id = 'split_menu',
            icon = 'fa-solid fa-cocktail',
            label = 'Split',
            menu = 'boite_menu'
          })
    elseif job('beachclub') then
        lib.addRadialItem({
            id = 'beachclub_menu',
            icon = 'fa-solid fa-cocktail',
            label = 'BeachClub',
            menu = 'boite_menu'
          })
    elseif job('unemployed') then
        lib.addRadialItem({
            id = 'unemployed_menu',
            icon = 'fa-solid fa-briefcase',
            label = 'Sans emploi',
            menu = 'unemployed_menu_1'
          })
    elseif job('selectcar') then
        lib.addRadialItem({
            id = 'selectcar_menu',
            icon = 'fa-solid fa-briefcase',
            label = 'SelectCar',
            menu = 'selectcar_radial'
            })
    end
end



local playerSpawned = false
local playerjob = nil

AddEventHandler('esx:playerLoaded', function(xPlayer)
    playerSpawned = true
    print('playerspawn',playerSpawned)
    playerjob = xPlayer.job.name
    Citizen.Wait(3000) -- Attendre 3 secondes après que le joueur puisse bouger
    jobmenu()
end)

Citizen.CreateThread(function()
    
    while true do
        Citizen.Wait(2000)
        -- print('ok')
        -- print('playerjob', playerjob)
        print(ESX.GetPlayerData().job.name)
        if playerjob ~= ESX.GetPlayerData().job.name then
            -- print('change job')
            lib.removeRadialItem(playerjob .. "_menu")
            jobmenu()
            playerjob = ESX.GetPlayerData().job.name
        end
    end
end)

------------------- Activer ou désactiver le réticule

crosshairEnabled = false -- État initial du réticule

RegisterCommand('toggleCrosshair', function()
    crosshairEnabled = not crosshairEnabled -- Inverser l'état du réticule
    if crosshairEnabled then
        showNotification('Reticule OFF')
        while true do 
            Citizen.Wait(0)
            if crosshairEnabled then
                HideHudComponentThisFrame(14)
            else
                break
            end
        end
    else
        showNotification('Reticule ON')
    end
end, false)

-- Citizen.CreateThread(function()
--     while true do
--         Citizen.Wait(9)
--         if not crosshairEnabled then
--             HideHudComponentThisFrame(14) -- Cache le réticule
--         end
--     end
-- end)

