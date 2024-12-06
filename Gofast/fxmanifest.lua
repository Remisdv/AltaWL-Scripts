fx_version 'adamant'
game 'gta5'

author 'TonNom'
description 'Script de Go Fast'
version '1.0.0'
lua54 'yes'

shared_scripts {
    '@es_extended/imports.lua',
    'config.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}

client_scripts {
    '@ox_lib/init.lua',
    'client.lua'
}

dependencies {
    'es_extended',
    'ox_lib',
}
