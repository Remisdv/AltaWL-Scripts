Config = {}

Config.Debug = false -- Enable or disable debug messages

Config.InventorySystem = false -- Choose between true or false
Config.ItemName = "contract" -- The name of the item that triggers the rental process
Config.UseCommand = true -- If true, use a command to start the rental process instead of an item
Config.CommandName = "rentvehicle" -- Command name to trigger the rental process

-- Language configuration
Config.Lang = {
    use_item_prompt = "Vous avez utilisé un contrat de location de véhicule.",
    select_vehicle = "Sélectionnez un véhicule",
    enter_price = "Entrez le prix de la location",
    enter_duration = "Entrez la durée de la location (en heures)",
    offer_sent = "Vous avez envoyé une offre de location.",
    offer_received = "Vous avez reçu une offre de location pour le véhicule : ",
    offer_accepted = "Votre offre de location a été acceptée.",
    offer_declined = "Votre offre de location a été refusée.",
    rental_end_notification = "La période de location est terminée. Le véhicule a été retourné.",
    no_nearby_player = "Aucun joueur à proximité pour envoyer l'offre.",
    not_enough_money = "Le joueur n'a pas assez d'argent.",
    vehicle_transferred = "Véhicule transféré pour la période de location : ",
    rent_duration_expired = "La période de location du véhicule a expiré. Le véhicule a été retourné.",
}


Config.Currency = "$" -- Currency symbol
