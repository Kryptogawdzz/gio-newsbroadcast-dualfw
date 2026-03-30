-- ============================================================
--  gio-newsbroadcast | client.lua
--  No framework calls needed client-side — NUI only
-- ============================================================

-- ── COMMAND SUGGESTIONS ───────────────────────────────────────
TriggerEvent('chat:addSuggestion', '/announce', 'Broadcast a news announcement to all players', {
    { name = 'type',    help = 'Announcement type: ambulance | police | gov | event' },
    { name = 'message', help = 'The message to broadcast (5-300 characters)' }
})

TriggerEvent('chat:addSuggestion', '/clearticker', 'Clear the news ticker for all players (requires permission)')

-- ── NET EVENTS ────────────────────────────────────────────────
RegisterNetEvent('gio-news:showAnnouncement', function(data)
    -- Nil-coalesce all server-supplied fields so the NUI never receives null values
    SendNUIMessage({
        action        = 'showTicker',
        header        = data.header    or 'NEWS',
        subheader     = data.subheader or '',
        color         = data.color     or '#cc0000',
        message       = data.message   or '',
        showFor       = Config.ShowFor,
        introDuration = Config.IntroDuration,
        scrollSpeed   = Config.ScrollSpeed,
        position      = Config.TickerPosition
    })

    if Config.Sound then
        PlaySoundFrontend(-1, 'Event_Start_Text', 'GTAO_FM_Events_Soundset', true)
    end
end)

RegisterNetEvent('gio-news:clearTicker', function()
    SendNUIMessage({ action = 'clearTicker' })
end)
