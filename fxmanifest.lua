author 'ilv-scripts'
version '1.0'


fx_version 'cerulean'
game 'gta5'

lua54 'yes'



client_script {
    'client.lua'
}

server_script {
	'server.lua'

}

shared_scripts {
    'config.lua',
    'bridge.lua'
}
server_scripts {
    'server.lua'
}
client_scripts {
    'client.lua'
}

-- Optional framework dependencies (ensure one of them is running if selected in config)
-- dependency 'qb-core'
-- dependency 'es_extended'
