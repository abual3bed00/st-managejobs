fx_version 'cerulean'
game 'gta5'

author 'YourName'
description 'Job & Gang Manager UI'
version '1.0.0'

ui_page 'html/index.html'

files {
  'html/index.html',
  'html/style.css',
  'html/script.js'
}

client_scripts {
  'client.lua'
}

server_scripts {
  '@qb-core/shared/locale.lua',
  'server.lua'
}

dependencies {
  'qb-core'
}
