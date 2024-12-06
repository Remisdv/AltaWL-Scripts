local DiscordWebhook = 'https://discord.com/api/webhooks/1260736344741777548/Amy3FJXcdOvRGy8Ka_zcTU9Rf4N-oCyztDvRPSE6Om-RlR3adYOfSehcg42xPSiAntwe'
local inProgress = false
local plateTable, nameTable, Charset, redeemedCars = {}, {}, {}, {}

RegisterCallback('nass_serverstore:redeemCheck', function(source, cb, model)
	local identifier = GetPlayerIdent(source)
	if redeemedCars[identifier] ~= nil then
		cb(true, GeneratePlate(), redeemedCars[identifier])
	else
		print('[nass_serverstore]: A player tried to exploit the vehicle spawn trigger! Identifier: '..identifier)
		SendToDiscord('Attempted Exploit Detected!', '**Identifier: **'..identifier..'\n**Comments:** Player has attempted to trigger the spawn vehicle event without a redemption code.', 3066993)
		DropPlayer(source, "Attempted exploit was detected")
		cb(false)
	end
end)

AddEventHandler('onResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
		local tebexConvar = GetConvar('sv_tebexSecret', '')
		if tebexConvar == '' then
			error('Tebex Secret Missing please set in server.cfg and try again. The script will not work without it.')
			StopResource(GetCurrentResourceName())
		end
		if not Config.DiscordLogs then
			print('^3Webhooks Disabled^0') -- ^3 is the yellow color code for the console, ^0 is white to reset the color for everything after this message
		end
	end
end)

RegisterCommand('boutique', function(source, _, rawCommand)
	local tbxid = rawCommand:sub(10) -- rawCommand:sub(8) = remove the first 8 characters from the command
	local identifier = GetPlayerIdent(source)
	local xName = getName(source)
	MySQL.query('SELECT * FROM codes WHERE code = @playerCode', {['@playerCode'] = tbxid}, function(result)
		print(#result)	
		if result[1] then
			-- print(result[1])
			local boughtPackages = json.decode(result[1].packagename)
			for _, i in pairs(boughtPackages) do
				-- print('i',i)
				local packageFound = false
				if Config.Packages[i] ~= nil then
					for h, j in pairs(Config.Packages[i].Items) do
						-- print('j',j.type)
						if j.type == 'vip1' then
							exports['VIP']:addVIP(identifier, j.type, j.temps)
						elseif j.type == 'vip2' then
							exports['VIP']:addVIP(identifier, j.type, j.temps)
						elseif j.type == 'vip3' then
							exports['VIP']:addVIP(identifier, j.type, j.temps)
						elseif j.type == 'car' then
							TriggerClientEvent('tebex:spawnVehicle', source, j.model)
							Wait(500)	
						end
						Wait(100)
					end
					TriggerClientEvent('nass_serverstore:notify', source, "Vous avez bien récupéré votre achat: " .. tbxid)
					SendToDiscord('Code Redeemed', '**Package Name: **'..i..'\n**Character Name: **'..xName..'\n**Identifier: **'..identifier, 3066993)
				else
					TriggerClientEvent('nass_serverstore:notify', source, "The "..i.." ERROR: achat non trouvé, faites un ticket")
				end	
			end
			MySQL.query.await('DELETE FROM codes WHERE code = @playerCode', {['@playerCode'] = tbxid})
		else
			TriggerClientEvent('nass_serverstore:notify', source, "Code invalid, Si vous l'avez acheté, réessayer plus tard")
		end
	end)
end, false)

RegisterCommand('purchase_package_tebex', function(source, args)
	if source == 0 then
		local dec = json.decode(args[1])
		local tbxid = dec.transid
		local packTab = {}
		while inProgress do
			Wait(1000)
		end
		inProgress = true
		MySQL.query('SELECT * FROM codes WHERE code = @playerCode', {['@playerCode'] = tbxid}, function(result)
			if result[1] then
				local packagetable = json.decode(result[1].packagename)
				packagetable[#packagetable+1] = dec.packagename
				MySQL.update('UPDATE codes SET packagename = ? WHERE code = ?', {json.encode(packagetable), tbxid}, function(rowsChanged)
					if rowsChanged > 0 then
						SendToDiscord('Purchase', '`'..dec.packagename..'` was just purchased and inserted into the database under redeem code: `'..tbxid..'`.', 1752220)
					else
						SendToDiscord('Error', '`'..tbxid..'` was not inserted into database. Please check for errors!', 15158332)
					end
				end)
			else
				packTab[#packTab+1] = dec.packagename
				MySQL.insert("INSERT INTO codes (code, packagename) VALUES (?, ?)", {tbxid, json.encode(packTab)}, function(rowsChanged)
					SendToDiscord('Purchase', '`'..dec.packagename..'` was just purchased and inserted into the database under redeem code: `'..tbxid..'`.', 1752220)
					print('^2Purchase '..tbxid..' was succesfully inserted into the database.^0')
				end)
			end
			inProgress = false
		end)
	else
		print(GetPlayerName(source)..' tried to give themself a store code.')
		SendToDiscord('Attempted Exploit', GetPlayerName(source)..' tried to give themself a store code!', 15158332)
	end
end, false)

RegisterNetEvent('nass_serverstore:setVehicle', function (vehicleProps, model, vehType)
	local src = source
	local identifier = GetPlayerIdent(src)
	if redeemedCars[identifier] == model then
		addVehtoDB(src, vehicleProps, model, vehType)
	else
		print('[nass_serverstore]: A player tried to exploit the vehicle spawn trigger! Identifier: '..identifier)
		SendToDiscord('Attempted Exploit Detected!', '**Identifier: **'..identifier..'\n**Comments:** Player has attempted to trigger the spawn vehicle event without a redemption code.', 3066993)
		DropPlayer(src, "Attempted exploit was detected")
	end
end)


RegisterCallback("nass_serverstore:hasAccess", function(source, cb, accType)
	local identifier = GetPlayerIdent(source)
	if accType == "plate" then
		cb(plateTable[identifier])
	elseif accType == "name" then
		cb(nameTable[identifier])
	else
		SendToDiscord(accType, GetPlayerName(source)..' has been caught cheating .', 1752220)
		DropPlayer(source, "Attempted exploit was detected")
		cb(false)
	end
end)





local DISCORD_NAME = "nass_serverstore"
local DISCORD_IMAGE = "https://i.imgur.com/Q72RWcB.png"

function SendToDiscord(name, message, color)
	if not Config.DiscordLogs then return end
	if DiscordWebhook == "CHANGE_WEBHOOK" then
		print(message)
	else
		local connect = {
			{
				["color"] = color,
				["title"] = "**".. name .."**",
				["description"] = message,
				["footer"] = {
					["text"] = "Nass Tebexstore",
				},
			}
		}
		PerformHttpRequest(DiscordWebhook, function() end, 'POST', json.encode({username = DISCORD_NAME, embeds = connect, avatarrl = DISCORD_IMAGE}), { ['Content-Type'] = 'application/json' })
	end
end


----------REMI


ESX.RegisterServerCallback('tebex:isPlateTaken', function(source, cb, plate)
    MySQL.scalar('SELECT plate FROM owned_vehicles WHERE plate = ?', {plate},
    function(result)
        cb(result ~= nil)
    end)
end)


RegisterNetEvent('tebex:buyVehicle')
AddEventHandler('tebex:buyVehicle', function(vehicle, spawnPosition)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    MySQL.Async.fetchAll("INSERT INTO owned_vehicles (owner, plate, vehicle, position, isVIP) VALUES (@owner, @plate, @vehicle, @position, @isVIP)", { 
        ["@owner"] = xPlayer.identifier,
        ["@plate"] = vehicle.plate,
        ["@vehicle"] = json.encode(vehicle),
        ["@position"] = json.encode(spawnPosition),
		["@isVIP"] = 1

    }, function(a)
    end)
    -- TriggerClientEvent('stg_vehicleshop:buyVehicle', src, vehicle)
end)




RegisterNetEvent('tebex:giveVehicleKey')
AddEventHandler('tebex:giveVehicleKey', function(plate, model)
    local player = source
    local xPlayer = ESX.GetPlayerFromId(player)

    local item = "vehiclekeys"
    local metadata = {plate = plate, description = model}
    local count = 1
    local slot = nil

    -- Ajouter un objet avec métadonnées
    local success = exports['qs-inventory']:AddItem(player, item, count, slot, metadata)
    if success then
        TriggerClientEvent('ox_lib:notify', player, {title = "Succès", description = "Vous avez reçu une clé pour le véhicule : " .. model .. " [" .. plate .. "]", type = "success"})
    else
        TriggerClientEvent('ox_lib:notify', player, {title = "Erreur", description = "Erreur lors de l'ajout de l'item.", type = "error"})
    end
end)
