fx_version 'cerulean'
game 'gta5'

description 'CruiseControl System for ESX'

version '1.1'
legacyversion '1.9.1'

lua54 'yes'

client_scripts {
  '@es_extended/imports.lua',
  '@es_extended/locale.lua',
  'locales/*.lua',
  'config.lua',
  'client/main.lua',
  'client/seatbelt.lua'
}

dependencies {
  'es_extended'
}