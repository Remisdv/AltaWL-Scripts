-- fxmanifest.lua

fx_version 'adamant'
game 'gta5'

author 'Remi'
description 'Script de mission pour le job YouTool'
version '1.0.0'
lua54 'yes'  

client_scripts {
    '@es_extended/locale.lua',
    '@ox_lib/init.lua',
    'client.lua',
    'client_vente.lua',
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    '@es_extended/locale.lua',
    'server.lua',
    'server_vente.lua',
}

dependencies {
    'es_extended',
}


shared_scripts {
    '@es_extended/imports.lua',
    'config.lua'
}