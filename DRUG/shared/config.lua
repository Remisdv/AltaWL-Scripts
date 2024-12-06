	
Config = {}

Config.Inventory = "quasar" -- ox_inventory, quasar, default, other
Config.MaxWeed = 10 -- How many weeds can be grown at the same time?
Config.Harvest = 2.5 -- Harvest time should give a multiple of the size (for example, a size of 1.2 100% will give 12 weeds for harvest)
Config.Webhook = "https://discord.com/api/webhooks/1254935760105377843/6wJpIQw9hZd_UwnAG0heJWYlGpj6tBtUKtlbkYRTetSJ9taM-0NJvZg-oyEHcwJXAb6p" -- your webhook adress



Config.Items = {
    ["Seeds"] = {
        "weed_white-widow_seed",
        "weed_skunk_seed",
        "weed_purple-haze_seed",
        "weed_og-kush_seed",
        "weed_amnesia_seed",
        "weed_ak47_seed"
    },
    ["Water"] = "water_bottle",
    ["Fertilizer"] = "fertilizer",
    ["Dust"] = "dust",
    ["Weed"] = {
        "weed_white-widow-brut",
        "weed_skunk-brut",
        "weed_purple-haze-brut",
        "weed_og-kush-brut",
        "weed_amnesia-brut",
        "weed_ak47-brut"
    }
}


Config.Give = {
	["Water"] = 10, -- When you give 1 water, how many water % should be added?
	["Fertilizer"] = 10, -- When you give 1 Fertilizer, how many Fertilizer % should be added?
	["Dust"] = { -- When you use this powder, it has a very fast effect
		["Healt"] = 2, -- how much the plant's life will increase when using the powder 
		["Growth"] = 0, -- how much the plant will grow after using the powder 
	}, 
}

Config.Wait = {
	["Check"] = 60, -- Check every few seconds (this time is important because it determines how many seconds it will grow after watering, etc.).
	["Seed"] = 4, -- How many seconds should the seed planting animation last?
	["Harvest"] = 6, -- How many seconds should the harvest animation last?
}

Config.Langs = {
    ["Waiter"] = "Vous ne pouvez pas ouvrir le menu si rapidement, veuillez patienter un peu!",
    ["Blip"] = "Champ de Weed",
    ["MaxWeed"] = "Vous ne pouvez pas planter plus de graines d'affilée.",
    ["Distance"] = "Ce n'est pas un champ!",
    ["OpenWeed"] = "[E] - Vérifier l'état",
    ["Harvest"] = "Récolte réussie",
    ["Harvest_eror"] = "Récolte prématurée!",
}

Config.Props = {
	["Weed_Lvl1"] = "bkr_prop_weed_01_small_01c",
	["Weed_Lvl2"] = "bkr_prop_weed_01_small_01b",
	["Weed_Lvl3"] = "bkr_prop_weed_01_small_01a", 
	["Weed_Lvl4"] = "bkr_prop_weed_med_01a", 
	["Weed_Lvl5"] = "bkr_prop_weed_lrg_01a", 
	["spatulamodel"] = "bkr_prop_coke_spatula_04",
}