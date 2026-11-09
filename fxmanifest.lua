fx_version 'bodacious'
game 'common'
-- Keep the legacy resource name resolvable for exports['qbqueue'] callers.
provide 'qbqueue'

server_script "server/sv_queue_config.lua"
server_script "connectqueue.lua"

server_script "shared/sh_queue.lua"
client_script "shared/sh_queue.lua"

-- kora_qa: Gherkin test scenarios (converted legacy tests), see [kora]/kora_qa/README.md
qa_feature 'tests/*.feature'
