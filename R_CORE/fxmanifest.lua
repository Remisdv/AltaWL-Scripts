fx_version 'cerulean'
game 'gta5'

author 'Remi'
description 'Script de persistance des véhicules'
version '1.0.0'
lua54 'yes'

--ui_page 'gang/gang_territoire/html/index.html'

shared_scripts {
    '@ox_lib/init.lua',
    '@es_extended/imports.lua'
}

-- files {
--     'gang/gang_territoire/html/index.html',
--     'gang/gang_territoire/html/css/style.css',
--     --'gang/gang_territoire/html/js/script.js',
--     --'gang/gang_territoire/html/map.png',
--     --'gang/gang_territoire/html/ALTA_RP.png'
--     -- 'gang/gang_territoire/html/zones.html',
--     -- 'gang/gang_territoire/html/zones.js'

-- }

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'vehicule/vehicules/server/server_pers.lua',
    'vehicule/vehicules/server/server_four.lua',
    'vehicule/key/server.lua',
    'vehicule/km/server.lua',
    -- 'gang/gang_territoire/server.lua',
    'gang/gang_menu/server.lua',
    'bank/server.lua',
    'lab/server.lua',
    'lab/config.lua',
    --'GOUV/server.lua'
    'command/server.lua',
    'nv_joueur/server.lua'
}

client_scripts {
    'vehicule/vehicules/client/client_pers.lua',
    'vehicule/vehicules/client/client_four.lua',
    'vehicule/key/client.lua',
    'vehicule/km/client.lua',
    'gang/gang_menu/client.lua',
    --'gang/gang_territoire/client.lua'
    --'gang/gang_territoire/client_zone.lua'
    'bank/client.lua',
    --'GOUV/client.lua'
    'lab/client.lua',
    'command/client.lua'
}

dependencies {
    'es_extended',
    'ox_lib',
    'mysql-async'
}
