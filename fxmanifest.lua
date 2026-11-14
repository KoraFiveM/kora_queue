fx_version 'bodacious'
version '0.2.1'
game 'common'
dependency 'kora_lib'
shared_script '@kora_lib/init.lua'

server_script "server/sv_queue_config.lua"
server_script "connectqueue.lua"

server_script "shared/sh_queue.lua"
client_script "shared/sh_queue.lua"

files { 'locales/*.lua' }

-- kora_qa: Gherkin test scenarios (converted legacy tests), see [kora]/kora_qa/README.md
qa_feature 'tests/*.feature'
