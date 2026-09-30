-- Run from the resource root: lua test/smoke/queue_facade.lua
-- Optional resource path supports an isolated original-source control.
local resource = arg[1] or '.'
local function provider()
    local p = { joins = {}, adds = {}, removes = {} }
    function p:OnJoin(cb, owner) self.joins[#self.joins + 1] = { cb = cb, owner = owner } end
    function p:AddPriority(id, power, temp)
        self.adds[#self.adds + 1] = { id = id, power = power, temp = temp }
        return true
    end
    function p:RemovePriority(id) self.removes[#self.removes + 1] = id; return true end
    return p
end
local active, state, loads = provider(), 'started', 0
local function facade(name)
    local env, handlers, timers = {}, {}, {}
    for key, value in pairs(_G) do env[key] = value end
    env.GetCurrentResourceName = function() return name end
    env.GetResourceState = function(which) assert(which == 'qbqueue'); return state end
    env.Citizen = { Wait = function(ms) return coroutine.yield(ms) end }
    env.AddEventHandler = function(event, cb) handlers[event] = cb end
    env.SetTimeout = function(ms, cb) assert(ms == 1); timers[#timers + 1] = cb end
    env.exports = { qbqueue = { GetQueueExports = function()
        assert(state == 'started', 'provider exports requested before ready')
        loads = loads + 1
        return active
    end } }
    assert(loadfile(resource .. '/connectqueue.lua', 't', env))()
    return env.Queue, handlers, timers
end
local function resume(co)
    local ok, result = coroutine.resume(co)
    assert(ok, result)
    return result
end

local queue, events, timers = facade('smoke-consumer')
local queued, late = 0, 0
local hook = function(_, allow) allow() end
assert(not queue.IsReady() and queue.Exports == nil and #timers == 1)
queue.OnReady(nil)
queue.OnJoin(nil)
assert(queue.AddPriority('license:test', 42, 60) == nil)
assert(queue.RemovePriority('license:test') == nil)
assert(#active.adds == 0 and #active.removes == 0)
queue.OnReady(function() queued = queued + 1; queue.OnJoin(hook) end)
assert(queued == 0 and #queue.ReadyCbs == 1)
timers[1]()
assert(queue.IsReady() and queue.Exports == active and loads == 1 and queued == 1)
assert(#active.joins == 1 and active.joins[1].cb == hook and active.joins[1].owner == 'smoke-consumer')
queue.OnReady(function() late = late + 1 end)
assert(late == 1 and #queue.ReadyCbs == 1, 'late OnReady callback stays immediate and unretained')
assert(queue.AddPriority('license:test', 42, 60) == nil, 'facade preserves nil return')
assert(queue.RemovePriority('license:test') == nil, 'facade preserves nil return')
assert(#active.adds == 1 and active.adds[1].id == 'license:test')
assert(active.adds[1].power == 42 and active.adds[1].temp == 60)
assert(#active.removes == 1 and active.removes[1] == 'license:test')

local old = active
state = 'stopped'
events.onResourceStop('qbqueue')
assert(not queue.IsReady() and queue.Exports == nil, 'provider stop must invalidate facade')
queue.AddPriority('blocked', 99)
queue.RemovePriority('blocked')
assert(#old.adds == 1 and #old.removes == 1, 'stopped facade must not forward priority calls')
active, state = provider(), 'starting'
local start = coroutine.create(function() events.onResourceStart('qbqueue') end)
assert(resume(start) == 0 and loads == 1 and not queue.IsReady())
state = 'started'
assert(resume(start) == 1 and loads == 1 and not queue.IsReady())
resume(start)
assert(coroutine.status(start) == 'dead')
assert(queue.IsReady() and queue.Exports == active and queue.Exports ~= old and loads == 2)
assert(queued == 2 and late == 1, 'only retained OnReady callbacks replay after provider restart')
assert(#active.joins == 1 and active.joins[1].cb == hook and active.joins[1].owner == 'smoke-consumer')
queue.AddPriority('license:new', 0, false)
queue.RemovePriority('license:new')
assert(#active.adds == 1 and active.adds[1].id == 'license:new')
assert(active.adds[1].power == 0 and active.adds[1].temp == false)
assert(#active.removes == 1 and active.removes[1] == 'license:new')

for _, other in ipairs({ 'unrelated', 'connectqueue' }) do
    events.onResourceStop(other)
    events.onResourceStart(other)
    assert(queue.IsReady() and queue.Exports == active and loads == 2 and queued == 2 and late == 1)
end
for _, owner in ipairs({ 'qbqueue', 'connectqueue' }) do
    local self, selfEvents, selfTimers = facade(owner)
    assert(self.CurResource == owner and self.Ready == false and self.Exports == nil)
    assert(next(selfEvents) == nil and #selfTimers == 0, 'provider self guard must skip facade setup')
end
print('queue_facade: provider restart, retained/late callbacks, hook owner, priority forwarding, unrelated resources and self guards passed')
