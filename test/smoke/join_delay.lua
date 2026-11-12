-- Run from the resource root: lua test/smoke/join_delay.lua
-- An optional resource path supports isolated original-source controls.
local resource = arg[1] or '.'

-- Inert Lua host. Threads are recorded; no service/native/database calls.
local function host(startup, duration)
    local clock = { now = startup }
    local handlers, threads, registered = {}, {}, {}
    local env = {}
    for key, value in pairs(_G) do env[key] = value end
    env.IsDuplicityVersion = function() return true end
    env.GetCurrentResourceName = function() return 'kora_queue' end
    env.GetGameTimer = function() return clock.now end
    env.GetConvarInt = function(_, fallback) return fallback end
    env.GetConvar = function(name) return name == 'sv_hostname' and 'default FXServer' or 'false' end
    env.GetPlayerIdentifiers = function() return { 'license:review' } end
    env.GetPlayerEndpoint = function() return '127.0.0.1' end
    env.GetPlayerName = function() return 'Review' end
    env.AddEventHandler = function(name, callback)
        handlers[name] = handlers[name] or {}; table.insert(handlers[name], callback)
    end
    env.RegisterServerEvent = function() end
    env.StopResource = function() end
    env.CancelEvent = function() end
    env.SetConvar = function() end
    env.Citizen = {
        CreateThread = function(callback) threads[#threads + 1] = callback end,
        Wait = function(ms) return coroutine.yield(ms) end,
    }
    env.exports = function(name, callback) registered[name] = callback end
    assert(loadfile(resource .. '/server/sv_queue_config.lua', 't', env))()
    env.Config.DisableHardCap = false
    env.Config.Card.enabled = false
    env.Config.JoinDelay = duration
    local loaded, err = pcall(function() assert(loadfile(resource .. '/shared/sh_queue.lua', 't', env))() end)
    if not loaded then return nil, err end
    return { env = env, clock = clock, handlers = handlers, threads = threads,
        queue = assert(registered.GetQueueExports)() }
end

local function resume(co)
    local ok, wait = coroutine.resume(co)
    assert(ok, wait)
    return wait
end

local function connect(f)
    f.env.source = 41
    local done = 0
    local deferrals = {
        defer = function() end,
        update = function() end,
        done = function(reason) assert(reason == nil); done = done + 1 end,
    }
    local callback = assert(f.handlers.playerConnecting)[1]
    local co = coroutine.create(function() callback('Review', function() end, deferrals) end)
    return co, function() return done end
end

for _, startup in ipairs({ 60000, 10000, 0 }) do
    -- First-player admission must wait the full delay after this resource starts.
    local f = assert(host(startup, 30000))
    local co, done = connect(f)
    assert(resume(co) == 500)
    f.clock.now = startup + 500
    assert(resume(co) == 500)
    assert(f.queue:ConnectingSize() == 0, 'initial admission bypassed resource startup delay')
    assert(done() == 0)

    -- The waiting-loop admission uses the same deadline, including its boundary.
    f.clock.now = startup + 29999
    assert(resume(co) == 500)
    assert(f.queue:ConnectingSize() == 0, 'waiting player admitted before resource startup delay')
    assert(done() == 0)
    f.clock.now = startup + 30000
    assert(resume(co) == 500)
    assert(f.queue:ConnectingSize() == 1, 'waiting player not admitted at delay deadline')
    f.clock.now = startup + 30500
    assert(resume(co) == 500)
    f.clock.now = startup + 31000
    resume(co)
    assert(done() == 1, 'waiting deferral completes once')

    -- A new first player arriving after startup delay passes the initial gate.
    f = assert(host(startup, 30000))
    f.clock.now = startup + 30000
    co, done = connect(f)
    assert(resume(co) == 500)
    f.clock.now = startup + 30500
    assert(resume(co) == 500)
    assert(f.queue:ConnectingSize() == 1, 'elapsed startup delay still blocks initial admission')
    f.clock.now = startup + 31000
    resume(co)
    assert(done() == 1, 'initial deferral completes once')

    -- Zero and omitted delay preserve immediate admission at any server uptime.
    for _, missing in ipairs({ false, true }) do
        local duration = 0
        if missing then duration = nil end
        f = assert(host(startup, duration))
        co, done = connect(f)
        assert(resume(co) == 500)
        f.clock.now = startup + 500
        assert(resume(co) == 500)
        assert(f.queue:ConnectingSize() == 1, 'zero/omitted delay blocks initial admission')
        f.clock.now = startup + 1000
        resume(co)
        assert(done() == 1, 'zero/omitted delay deferral completes once')
    end
end
print('join_delay: initial/waiting admission, positive/zero/nil delay, and startup uptimes 60000/10000/0 passed')
