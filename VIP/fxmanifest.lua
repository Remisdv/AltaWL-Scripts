fx_version 'cerulean'
game 'gta5'

author 'VotreNom'
description 'Gestion des VIP pour FiveM'
version '1.0.0'

shared_script '@es_extended/imports.lua'

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'server.lua'
}