-- ============================================================
--  gio-newsbroadcast | server.lua
--  Framework: Auto-detects ESX or QBox at resource start
--  Version: 1.5.0
-- ============================================================

local ESX       = nil
local QBX       = nil
local Framework = nil

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

-- ── NOTIFICATION BRIDGE ──────────────────────────────────────
-- Sends error notifications using the correct method per framework
local function Notify(source, message)
    if not Framework then return end
    if Framework == 'ESX' then
        TriggerClientEvent('esx:showNotification', source, '~r~' .. message)
    else
        TriggerClientEvent('ox_lib:notify', source, {
            type        = 'error',
            title       = 'Error',
            description = message
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

-- ── COOLDOWN TRACKER ─────────────────────────────────────────
local playerCooldowns = {}  -- [source][type] = os.time() of last broadcast

AddEventHandler('playerDropped', function()
    playerCooldowns[source] = nil
end)

-- ── /announce COMMAND ─────────────────────────────────────────
RegisterCommand('announce', function(source, args)
    if not Framework then
        print('^1[gio-newsbroadcast] ^7Cannot process /announce — no framework loaded.')
        return
    end

    local type = args[1] and string.lower(args[1])

    -- Validate announcement type
    if not type or not Config.AnnouncementTypes[type] then
        Notify(source, 'Invalid type! Use: ambulance, police, gov, or event')
        return
    end

    -- Validate message length
    local message = table.concat(args, ' ', 2)
    if #message < 5 then
        Notify(source, 'Message is too short!')
        return
    end

    if #message > 300 then
        Notify(source, 'Message is too long! Maximum 300 characters.')
        return
    end

    local job, grade = GetPlayerJobData(source)

    if not job then
        Notify(source, 'Could not retrieve your player data. Try again.')
        return
    end

    local cfg = Config.AnnouncementTypes[type]

    -- Job check (skip if cfg.job is false)
    if cfg.job and job ~= cfg.job then
        Notify(source, 'You are not authorized for this announcement type!')
        return
    end

    -- Grade check (skip if job = false or grade = 0)
    if cfg.job and cfg.grade and cfg.grade > 0 and grade < cfg.grade then
        Notify(source, 'You do not have the required rank for this announcement!')
        return
    end

    -- Cooldown check
    if cfg.cooldown and cfg.cooldown > 0 then
        local now  = os.time()
        local last = (playerCooldowns[source] and playerCooldowns[source][type]) or 0
        local remaining = cfg.cooldown - (now - last)
        if remaining > 0 then
            Notify(source, ('You must wait %d more second(s) before broadcasting again.'):format(remaining))
            return
        end
        playerCooldowns[source]        = playerCooldowns[source] or {}
        playerCooldowns[source][type]  = now
    end

    local data = {
        header    = cfg.header,
        subheader = cfg.subheader,
        color     = cfg.color,
        message   = message,
        type      = type
    }

    TriggerClientEvent('gio-news:showAnnouncement', -1, data)

    print(string.format('^2[gio-newsbroadcast] ^7[%s] %s announcement from %s (grade %d): %s',
        Framework, type:upper(), GetPlayerName(source), grade, message))
end, false)

-- ── /clearticker COMMAND ──────────────────────────────────────
RegisterCommand('clearticker', function(source, args)
    if source ~= 0 and not IsPlayerAceAllowed(source, 'command.clearticker') then
        Notify(source, 'You are not authorized to use this command!')
        return
    end
    TriggerClientEvent('gio-news:clearTicker', -1)
    print(string.format('^2[gio-newsbroadcast] ^7Ticker cleared by %s', source == 0 and 'Console' or GetPlayerName(source)))
end, false)

print('^2[gio-newsbroadcast] ^7Dual Framework (ESX + QBox) loaded successfully!')
