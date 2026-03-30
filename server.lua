-- ============================================================
--  gio-newsbroadcast | server.lua
--  Framework: Auto-detects ESX or QBox at resource start
--  Version: 1.5.0
-- ============================================================

local ESX              = nil
local QBX              = nil
local Framework        = nil
local AnnouncementTypes = nil  -- cached after Config loads

-- ── FRAMEWORK DETECTION ──────────────────────────────────────
if GetResourceState('es_extended') == 'started' then
    Framework = 'ESX'
    ESX       = exports['es_extended']:getSharedObject()
    print('^2[gio-newsbroadcast] ^7Detected: ^3ESX Framework^7')

elseif GetResourceState('qbx_core') == 'started' then
    Framework = 'QBOX'
    QBX       = exports['qbx_core']
    print('^2[gio-newsbroadcast] ^7Detected: ^3QBox Framework^7')

else
    print('^1[gio-newsbroadcast] ^7ERROR: Neither ESX nor QBox detected! Commands will not work.')
end

AnnouncementTypes = Config.AnnouncementTypes

-- ── NOTIFICATION BRIDGE ──────────────────────────────────────
-- Sends error notifications using the correct method per framework.
-- Falls back to chat:addMessage when framework is unavailable.
local function Notify(source, message)
    if source == 0 then return end  -- console has no client UI
    if Framework == 'ESX' then
        TriggerClientEvent('esx:showNotification', source, '~r~' .. message)
    elseif Framework == 'QBOX' and GetResourceState('ox_lib') == 'started' then
        TriggerClientEvent('ox_lib:notify', source, {
            type        = 'error',
            title       = 'Error',
            description = message
        })
    else
        -- Fallback: raw chat message when framework is nil or ox_lib unavailable
        TriggerClientEvent('chat:addMessage', source, {
            color     = { 255, 50, 50 },
            multiline = true,
            args      = { '[gio-news]', message }
        })
    end
end

-- ── PLAYER DATA BRIDGE ───────────────────────────────────────
-- Returns job name AND grade level regardless of framework
local function GetPlayerJobData(source)
    if Framework == 'ESX' and ESX then
        local xPlayer = ESX.GetPlayerFromId(source)
        if not xPlayer then return nil, nil end
        local job = xPlayer.getJob()
        return job.name, job.grade

    elseif Framework == 'QBOX' and QBX then
        local Player = QBX:GetPlayer(source)
        if not Player then return nil, nil end
        return Player.PlayerData.job.name,
               Player.PlayerData.job.grade.level
    end

    return nil, nil
end

-- ── LICENSE HELPER ───────────────────────────────────────────
-- Uses the Rockstar license as a persistent key so cooldowns
-- survive disconnect/reconnect attempts.
local function GetLicense(src)
    return GetPlayerIdentifierByType(src, 'license')
end

-- ── COOLDOWN TRACKER ─────────────────────────────────────────
-- Keyed by license (not source) — persists across rejoins intentionally.
-- Only expired entries are cleaned up on drop; active entries stay.
local playerCooldowns = {}

AddEventHandler('playerDropped', function()
    local license = GetLicense(source)
    if not license or not playerCooldowns[license] then return end
    local now     = os.time()
    local expired = {}
    for aType, lastTime in pairs(playerCooldowns[license]) do
        local cfg = AnnouncementTypes[aType]
        if cfg and cfg.cooldown and (now - lastTime) >= cfg.cooldown then
            expired[#expired + 1] = aType
        end
    end
    for i = 1, #expired do
        playerCooldowns[license][expired[i]] = nil
    end
    if not next(playerCooldowns[license]) then
        playerCooldowns[license] = nil
    end
end)

-- ── /announce COMMAND ─────────────────────────────────────────
RegisterCommand('announce', function(source, args)
    if not Framework then
        print('^1[gio-newsbroadcast] ^7Cannot process /announce — no framework loaded.')
        return
    end

    local announceType = args[1] and string.lower(args[1])

    -- Single lookup — result reused for both validation and field access (#5)
    local cfg = announceType and AnnouncementTypes[announceType]
    if not cfg then
        Notify(source, 'Invalid type! Use: ambulance, police, gov, or event')
        return
    end

    -- Trim leading/trailing whitespace, then validate length (#1)
    local message = (table.concat(args, ' ', 2)):match('^%s*(.-)%s*$') or ''
    if #message < 5 then
        Notify(source, 'Message is too short!')
        return
    end

    if #message > 300 then
        Notify(source, 'Message is too long! Maximum 300 characters.')
        return
    end

    -- Console bypass (#4): no job, grade, license, or cooldown checks needed
    if source == 0 then
        TriggerClientEvent('gio-news:showAnnouncement', -1, {
            header    = cfg.header,
            subheader = cfg.subheader,
            color     = cfg.color,
            message   = message,
            type      = announceType
        })
        print(string.format('^2[gio-newsbroadcast] ^7[CONSOLE] %s announcement: %s',
            announceType:upper(), message:gsub('%^%d', '')))
        return
    end

    -- Job check (skip if cfg.job is false)
    if cfg.job then
        local job, grade = GetPlayerJobData(source)

        if not job then
            Notify(source, 'Could not retrieve your player data. Try again.')
            return
        end

        if job ~= cfg.job then
            Notify(source, 'You are not authorized for this announcement type!')
            return
        end

        -- Grade check (skip if grade = 0)
        if cfg.grade and cfg.grade > 0 and grade < cfg.grade then
            Notify(source, 'You do not have the required rank for this announcement!')
            return
        end
    else
        -- No job required — enforce ACE permission if configured
        if cfg.ace and not IsPlayerAceAllowed(source, cfg.ace) then
            Notify(source, 'You are not authorized for this announcement type!')
            return
        end
    end

    -- Persistent license key — prevents cooldown bypass via relog
    local license = GetLicense(source)
    if not license then
        Notify(source, 'Could not verify your identity. Try again.')
        return
    end

    -- Cooldown check
    if cfg.cooldown and cfg.cooldown > 0 then
        local now       = os.time()
        local last      = (playerCooldowns[license] and playerCooldowns[license][announceType]) or 0
        local remaining = cfg.cooldown - (now - last)
        if remaining > 0 then
            Notify(source, ('You must wait %d more second(s) before broadcasting again.'):format(remaining))
            return
        end
        playerCooldowns[license]               = playerCooldowns[license] or {}
        playerCooldowns[license][announceType] = now
    end

    TriggerClientEvent('gio-news:showAnnouncement', -1, {
        header    = cfg.header,
        subheader = cfg.subheader,
        color     = cfg.color,
        message   = message,
        type      = announceType
    })

    -- Strip FiveM color codes from message before logging to prevent log spoofing
    print(string.format('^2[gio-newsbroadcast] ^7[%s] %s announcement from %s: %s',
        Framework, announceType:upper(), GetPlayerName(source), message:gsub('%^%d', '')))
end, false)

-- ── /clearticker COMMAND ──────────────────────────────────────
RegisterCommand('clearticker', function(source, _)
    if source ~= 0 and not IsPlayerAceAllowed(source, 'command.clearticker') then
        Notify(source, 'You are not authorized to use this command!')
        return
    end
    TriggerClientEvent('gio-news:clearTicker', -1)
    print(string.format('^2[gio-newsbroadcast] ^7Ticker cleared by %s', source == 0 and 'Console' or GetPlayerName(source)))
end, false)

print('^2[gio-newsbroadcast] ^7Dual Framework (ESX + QBox) loaded successfully!')
