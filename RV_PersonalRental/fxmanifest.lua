fx_version 'cerulean'
game 'gta5'

author 'R&V'
description 'Vehicle Rental Script with Player Interaction and Database Management'
version '1.0.0'
lua54 'yes'

-- Dependencies
dependencies {
    'es_extended',   -- ESX framework
    'ox_lib'         -- ox_lib for UI and input dialogs
}

-- Shared scripts
shared_scripts {
    '@ox_lib/init.lua',   -- Initialize ox_lib
    'config.lua'          -- Configuration file
}

-- Server scripts
server_scripts {
    '@mysql-async/lib/MySQL.lua',  -- MySQL Async library for database operations
    'server.lua'                   -- Main server-side logic
}

-- Client scripts
client_scripts {
    'client.lua'                   -- Main client-side logic
}

