fx_version 'cerulean'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
game 'rdr3'

author 'Artmines & Qzip - Quantum Projects' 
description 'Quantum Farming | Dev: Artmines & Qzip'
quantum_discord 'https://discord.gg/kJ8ZrGM8TS'
version '1.0.1'

shared_scripts {
    '@ox_lib/init.lua',
    '@rsg-core/shared/locale.lua',
    'config.lua',
}

client_scripts {
    '@PolyZone/client.lua',
    '@PolyZone/BoxZone.lua',
    '@PolyZone/EntityZone.lua',
    '@PolyZone/CircleZone.lua',
    '@PolyZone/ComboZone.lua',
    'client/client.lua',
    'client/npcs.lua',
    'client/modules/placeprop.lua',
    'client/modules/collect_water.lua',
    'client/modules/collect_fertilizer.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/server.lua',
    
}

dependencies {
    'rsg-core',
    'ox_lib',
    'PolyZone'
}

lua54 'yes'
ui_page 'html/index.html'

files {
    'html/index.html',
    'html/css/style.css',
    'html/js/script.js',
    'html/imgs/*.png',
    'locales/*.json',
}