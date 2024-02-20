fx_version 'cerulean'
game 'gta5'

description 'Special VTC service UverX for QB-Core'
version '1.0.3'
author 'JiBiBi'

ui_page 'html/jbbvtc.html'


files {
    'html/css/*.css',
    'html/js/*.js',
    'html/jbbvtc.html',
}

shared_scripts {
    'config.lua'
}

server_script {
    '@oxmysql/lib/MySQL.lua',
    'server/bridge.lua',
    'server/main.lua',
    -- enable only if you need to generate hashes
    --'server/genhashes.lua',
}

client_scripts {
    'client/bridge.lua',
    'client/peds_hashes.lua',
    'client/main.lua',
    'client/uicontrol.lua',
    -- enable only if you need to generate hashes
    --'client/genhashes.lua',
}

lua54 'yes'
use_fxv2_oal 'yes'
