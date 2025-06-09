fx_version 'cerulean'
use_experimental_fxv2_oal 'yes'
lua54 'yes'
games { 'rdr3', 'gta5' }
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

name 'ox_lib'
author 'Overextended'
version '3.30.2'
license 'LGPL-3.0-or-later'
repository 'https://github.com/communityox/ox_lib'
description 'A library of shared functions to utilise in other resources.'

dependencies {
    '/server:7290',
    '/onesync',
    'oxmysql'
}

ui_page 'web/build/index.html'

files {
    'init.lua',
    'resource/settings.lua',
    'imports/**/client.lua',
    'imports/**/shared.lua',
    -- API Files
    'api/enums/**/*.lua',
    'api/**/init.lua',
    'api/**/shared.lua',
    'api/**/client.lua',
    -- Wrapper Files
    'wrappers/utils.lua',
    'wrappers/config.lua',
    'wrappers/**/**/shared.lua',
    'wrappers/**/**/client.lua',
    -- Web Files
    'web/build/index.html',
    'web/build/**/*',
    'locales/*.json',
}

shared_scripts {
    'resource/init.lua',
    'resource/**/shared.lua',
    -- API Shared Files
    'api/enums/*.lua',
    'api/**/shared.lua',
    'wrappers/utils.lua',
    'wrappers/config.lua',
    -- Wrapper Shared Files
    'wrappers/**/**/shared.lua',
    -- 'resource/**/shared/*.lua'
}

client_scripts {
    'resource/**/client.lua',
    'resource/**/client/*.lua',
    -- API Client Files
    'api/**/client.lua',
    -- Wrapper Client Files
    'wrappers/**/**/client.lua'
}

server_scripts {
    'imports/callback/server.lua',
    'imports/getFilesInDirectory/server.lua',
    'resource/**/server.lua',
    'resource/**/server/*.lua',
    -- API Server Files
    'api/**/**/server.lua',
    -- Wrapper Server Files
    'wrappers/**/**/server.lua'
}
