fx_version 'cerulean'
game 'gta5'

lua54 'yes'

author 'VhK'
description 'Script de revente d\'occasion pour FiveM'
version '1.0.0'



------SELECTCAR--------

shared_script '@es_extended/imports.lua'
shared_script '@ox_lib/init.lua'

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'V_Selectcar/server.lua'
}

client_scripts {
    'V_Selectcar/client.lua',
    'V_Selectcar/menu.lua'
}

dependencies {
    'es_extended',
    'mysql-async',
    'ox_lib'
}


-------------SELECTCARSPAWN------------

shared_scripts {
    'V_SelectcarSpawn/config.lua',
}

client_scripts {
    'V_SelectcarSpawn/client.lua',
}

files {
    'V_SelectcarSpawn/colorpicker.html',
}

ui_page 'V_SelectcarSpawn/colorpicker.html'

dependencies {
    'ox_lib',
    'ox_target',
    'es_extended'
}
