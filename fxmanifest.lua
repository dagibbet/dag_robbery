fx_version "adamant"
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
game "rdr3"

--ui_page('html/ui.html') 

this_is_a_map "yes"

client_scripts {
    'config.lua',
    'client.lua',
}
server_scripts {
    'config.lua',
    'server.lua',
	'@oxmysql/lib/MySQL.lua',
}

dependency  = {
	'objectloader',
}

files {
	'valsafes.xml', 
}
objectloader_maps {
   'valsafes.xml',   
}