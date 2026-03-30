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
    SendNUIMessage({
        action        = 'showTicker',
        header        = data.header,
        subheader     = data.subheader,
        color         = data.color,
        message       = data.message,
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
