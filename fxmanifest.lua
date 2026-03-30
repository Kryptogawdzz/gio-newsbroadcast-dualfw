fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'DevGio'
description 'Gio Professional News Ticker - ESX & QBox Compatible'
version '1.5.1'

-- No hard dependency on either framework.
-- The resource auto-detects ESX or QBox at runtime.

shared_scripts {
    'config.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    'server.lua'
}

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}

ui_page 'html/index.html'

dependencies {
    'ox_lib'
}
