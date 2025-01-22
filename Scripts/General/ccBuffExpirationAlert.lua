function events.Tick()
    if Game.CurrentScreen == 0 and BuffExpirationAlert == 1 and Game.Time > nextbuffdurationcheck then

        local msg = ""
        local alert1 = 15 * const.RTSecond -- 15s alert
        local tm_min = 12800

        for _, buff in pairs(BuffListAlert) do
            -- Party Check
            if const.PartyBuff[buff] then
                if Party.SpellBuffs[const.PartyBuff[buff]].ExpireTime > 0 then
                    tm = (Party.SpellBuffs[const.PartyBuff[buff]].ExpireTime - Game.Time)
                    if tm < alert1 and tm < tm_min then
                        tm_min = tm
                        msg = string.format("\149\149\149 %s expiring in %ds \149\149\149", buff, math.round(tm / const.RTSecond))
                    end
                end
            end

            if const.PlayerBuff[buff] then
                for _, pl in Party do
                    if pl.SpellBuffs[const.PlayerBuff[buff]].ExpireTime > 0 then
                        tm = (pl.SpellBuffs[const.PlayerBuff[buff]].ExpireTime - Game.Time)
                        if tm < alert1 and tm < tm_min then
                            tm_min = tm
                            msg = string.format("\149\149\149 %s expiring on %s in %ds \149\149\149", buff, pl.Name, math.round(tm / const.RTSecond))
                        end
                    end
                end
            end

        end
        if tm_min < alert1 then
            Game.ShowStatusText(StrColor(200, 0, 0, msg), 1)
            nextbuffdurationcheck = Game.Time + math.floor(const.RTSecond * 1.1)
        end
    end

    --Alarmclock
    if Game.CurrentScreen == 0 and AlarmClockTime ~= "" and Game.Time > nextalarmclockcheck then
        local hh, mm, daytime, alarmtime

        _, _, hh, mm = string.find(AlarmClockTime, "(%d+):(%d+)")
        alarmtime = (hh * 60 + mm) * const.Minute -- alarmtime of the day in ticks
        daytime = Game.Time % (const.Minute * 24 * 60) -- current time of the day in ticks
        if math.abs(daytime - alarmtime) < 5 * const.RTSecond then
            Game.ShowStatusText(StrColor(200, 50, 100, "\149\149\149 " .. AlarmClockTime .. " \149\149\149"), 1)
            nextalarmclockcheck = Game.Time + const.RTSecond * 2
        else
            nextalarmclockcheck = math.floor(Game.Time / (const.Minute * 24 * 60)) + alarmtime
        end

    end

end
