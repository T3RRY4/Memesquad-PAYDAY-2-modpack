Hooks:PostHook(PlayerManager, "on_killshot", "LuffyKillCounterHook1", function()
    KillLog.Box.kills = KillLog.Box.kills + 1
    KillLog.Box:SetKills()
end)
Hooks:PostHook(PlayerManager, "on_headshot_dealt", "LuffyKillCounterHook2", function()
    KillLog.Box._headshot = true
end)