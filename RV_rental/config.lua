Config = {}

Config.Debug = false -- Enable or disable debug messages

Config.InteractionMode = "textui" -- Choose between "ox_target" or "textui"

-- Language configuration
Config.Lang = {
    -- Textes généraux
    rent_vehicle = "Louer un véhicule",
    rent_vehicle_prompt_textui = "Appuyez sur [E] pour louer un véhicule",
    rent_vehicle_prompt_ox_target = 'Louer un véhicule',
    rent_vehicle_notification = "Votre période de location est terminée. Le véhicule est maintenant verrouillé.",
    not_enough_money = "Vous n'avez pas assez d'argent",
    
    -- Textes du menu
    select_duration = "Sélectionnez la durée de location",
    select_payment_method = "Sélectionnez le mode de paiement",
    cash = "Espèces",
    bank = "Banque",
    vehicle_rental_menu_title = "Location de véhicule",
    
    -- Notifications
    vehicle_locked = "Véhicule verrouillé : ",
    vehicle_deleted = "Véhicule supprimé : ",
}


Config.ShowVehicleImages = true -- Enable or disable vehicle images in the menu

Config.Locations = {
    {
        pos = vector4(214.79, -806.52, 30.81, 337.16), -- NPC position and orientation
        spawnPos = vector4(212.64, -797.12, 30.87, 339.09), -- Vehicle spawn position and orientation
        npcModel = 's_m_m_autoshop_01', -- NPC model
        vehicles = {
            {model = 'dilettante', basePrice = 300, prices = {1, 12, 24, 48}, image = 'https://gtamag.com/images/photo/gta-mag-Dilettante-426229.jpg'}, -- 1h, 12h, 24h, 48h
            {model = 'panto', basePrice = 150, prices = {1, 12, 24, 48, 72}, image = 'https://gtamag.com/images/photo/gta-mag-Panto-954733.jpg'}, -- 1h, 12h, 24h, 48h, 72h
            {model = 'scorcher', basePrice = 25, prices = {1, 12, 24, 48, 72}, image = 'https://static.wikia.nocookie.net/gtawiki/images/b/be/Scorcher-GTAV-front.png'}, -- 1h, 12h, 24h, 48h, 72h
            {model = 'faggio', basePrice = 75, prices = {1, 12, 24, 48, 72}, image = 'https://static.wikia.nocookie.net/gtawiki/images/5/50/FaggioSport-GTAO-front.png'}, -- 1h, 12h, 24h, 48h, 72h
        },
        blip = {
            enabled = false, -- Enable or disable the blip
            sprite = 225, -- Blip sprite ID
            color = 3, -- Blip color
            scale = 0.4, -- Blip scale
            text = "Locations", -- Blip text
        }
    },
    {
        pos = vec4(-1031.7385, -2734.2979, 20.1654, 327.4571), -- NPC position and orientation
        spawnPos = vec4(-1026.2330, -2734.0833, 20.0963, 245.7540), -- Vehicle spawn position and orientation
        npcModel = 's_m_m_autoshop_01', -- NPC model
        vehicles = {
            {model = 'dilettante', basePrice = 300, prices = {1, 12, 24, 48}, image = 'https://gtamag.com/images/photo/gta-mag-Dilettante-426229.jpg'}, -- 1h, 12h, 24h, 48h
            {model = 'panto', basePrice = 150, prices = {1, 12, 24, 48, 72}, image = 'https://gtamag.com/images/photo/gta-mag-Panto-954733.jpg'}, -- 1h, 12h, 24h, 48h, 72h
            {model = 'scorcher', basePrice = 25, prices = {1, 12, 24, 48, 72}, image = 'https://static.wikia.nocookie.net/gtawiki/images/b/be/Scorcher-GTAV-front.png'}, -- 1h, 12h, 24h, 48h, 72h
            {model = 'faggio', basePrice = 75, prices = {1, 12, 24, 48, 72}, image = 'https://static.wikia.nocookie.net/gtawiki/images/5/50/FaggioSport-GTAO-front.png'}, -- 1h, 12h, 24h, 48h, 72h
        },
        blip = {
            enabled = true, -- Enable or disable the blip
            sprite = 225, -- Blip sprite ID
            color = 3, -- Blip color
            scale = 0.4, -- Blip scale
            text = "Locations", -- Blip text
        }
    },
    -- Add other rental locations here
}
