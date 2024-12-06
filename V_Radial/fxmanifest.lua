fx_version 'cerulean'
game 'gta5'

author 'RV'
description 'Radial Menu with ox_lib'
version '1.0.0'

lua54 'yes'


shared_scripts {
    '@ox_lib/init.lua',
    '@es_extended/imports.lua',
}
client_script 'client.lua'
server_script 'server.lua'