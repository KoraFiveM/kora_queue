Config = {}

-- priority list can be any identifier. (hex steamid, steamid32, ip) Integer = power over other people with priority
-- a lot of the steamid converting websites are broken rn and give you the wrong steamid. I use https://steamid.xyz/ with no problems.
-- you can also give priority through the API, read the examples/readme.
Config.Priority = {
    ["STEAM_0:1:0000####"] = 1,
    ["steam:110000######"] = 25,
    ["ip:127.0.0.0"] = 85
}

-- require people to run steam
Config.RequireSteam = false

-- "whitelist" only server
Config.PriorityOnly = false

-- disables hardcap, should keep this true
Config.DisableHardCap = true

-- will remove players from connecting if they don't load within: __ seconds; May need to increase this if you have a lot of downloads.
-- i have yet to find an easy way to determine whether they are still connecting and downloading content or are hanging in the loadscreen.
-- This may cause session provider errors if it is too low because the removed player may still be connecting, and will let the next person through...
-- even if the server is full. 10 minutes should be enough
Config.ConnectTimeOut = 600

-- will remove players from queue if the server doesn't recieve a message from them within: __ seconds
Config.QueueTimeOut = 90

-- will give players temporary priority when they disconnect and when they start loading in
Config.EnableGrace = false

-- how much priority power grace time will give
Config.GracePower = 5

-- how long grace time lasts in seconds
Config.GraceTime = 480

Config.AntiSpam = false
Config.AntiSpamTimer = 30
Config.PleaseWait = Kora.lang('queue.please_wait')

-- on resource start, players can join the queue but will not let them join for __ milliseconds
-- this will let the queue settle and lets other resources finish initializing
Config.JoinDelay = 30000

-- will show how many people have temporary priority in the connection message
Config.ShowTemp = false

-- simple localization
Config.Language = {
    joining = Kora.lang('queue.joining'),
    connecting = Kora.lang('queue.connecting'),
    idrr = Kora.lang('queue.identifiers_unavailable'),
    err = Kora.lang('queue.error'),
    pos = Kora.lang('queue.position'),
    connectingerr = Kora.lang('queue.connecting_error'),
    timedout = Kora.lang('queue.timed_out'),
    wlonly = Kora.lang('queue.whitelist_only'),
    steam = Kora.lang('queue.steam_required'),
}


-- Connection queue card shown while a player is waiting to join.
-- This uses FiveM's deferral Adaptive Card support, so it is visible before
-- the player has loaded into the server. Set enabled = false to use the
-- original text-only queue messages.
Config.Card = {
    enabled = true,
    fallbackToText = true,

    image = {
        enabled = false,
        url = "",
        size = "Large",
        horizontalAlignment = "Center"
    },

    title = "Kora",
    description = "Welcome to Kora. Please wait while we find you a slot.",

    show = {
        playerName = true,
        position = true,
        queueSize = true,
        queueTime = true,
        priority = true,
        serverName = true,
        maxPlayers = false
    },

    status = {
        enabled = true,
        label = "Status",
        waiting = "Waiting for a server slot...",
        joining = "Joining server...",
        connecting = "Connecting..."
    },

    footer = "Join our community to play.",

    -- Optional extra text blocks. Supported variables:
    -- ${playerName}, ${position}, ${queueSize}, ${queueTime}, ${priority},
    -- ${serverName}, ${maxPlayers}, ${status}
    extraText = {
        -- "Rules: Be respectful and have fun!",
    }
}
