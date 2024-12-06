fx_version 'adamant'
game 'gta5'

description 'ESX Vehicle Rental with ox_lib by R&V'

version '1.0.0'

author 'R&V'

lua54 'yes' 

shared_scripts {
    '@es_extended/imports.lua',
    'config.lua',
}

client_scripts {
    '@ox_lib/init.lua', -- ox_lib
    'client/client.lua'
}

server_scripts {
    '@mysql-async/lib/MySQL.lua', -- MySQL Async
    'server/server.lua'
}

dependencies {
    'es_extended',
    'ox_lib'
}

escrow_ignore {
    'config.lua',  -- Only ignore one file
  }