-- fxmanifest.lua

fx_version 'cerulean'
game 'gta5'

author 'RV'
description 'Gestion de l\'usure des véhicules pour FiveM'
version '1.0.0'
lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua',
    '@es_extended/imports.lua',
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'config.lua',
    'server.lua'
}

client_scripts {
    'config.lua',
    'client.lua'
}

dependencies {
    'es_extended'
}
