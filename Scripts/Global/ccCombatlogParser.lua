function events.KeyDown(t)
    if (Game.CurrentScreen == 0 or Game.CurrentScreen == 7) and t.Key == MiniLogButton and Keys.IsPressed(const.Keys.ALT) then

        local mobs_dmg = {}
        local kinds_dmg = {}
        local timestamp, p, class, name, dir, mobname, dmg, kind, src
        local total_mobs_dmg = 0
        local player_dmg = {
            [0] = 0,
            [1] = 0,
            [2] = 0,
            [3] = 0
        }

        io.lines(vars.CombatLogFile)() -- discard first line with titles
        for line in io.lines(vars.CombatLogFile) do -- browse through logfile

            local x = string.gmatch(line, ".-" .. CombatLogSeparator)

            timestamp = tonumber(x()) -- timestamp
            p = tonumber(x()) -- player #
            class = string.sub(x(), 1, -2) -- Class(lvl)
            name = string.sub(x(), 1, -2) -- Name
            dir = string.sub(x(), 1, -2) -- '>>' or '<<'
            mobname = string.sub(x(), 1, -2) -- Mobname(lvl)
            dmg = tonumber(x()) -- dmg
            kind = string.sub(x(), 1, -2) -- Dmg kind
            -- src = string.sub(x(),1,-2) -- dmg source "hits"

            if dir == ">>" then
                player_dmg[p] = player_dmg[p] + dmg
            end

            if dir == "<<" then
                mobs_dmg[mobname] = mobs_dmg[mobname] or 0
                mobs_dmg[mobname] = mobs_dmg[mobname] + dmg

                kinds_dmg[kind] = kinds_dmg[kind] or 0
                kinds_dmg[kind] = kinds_dmg[kind] + dmg
                total_mobs_dmg = total_mobs_dmg + dmg
            end

        end

        local function sort_values(x)
            local y = {
                name = "",
                dmg = 0
            }
            for n, v in pairs(x) do
                table.insert(y, {
                    name = n,
                    dmg = v
                })
            end
            table.sort(y, function(a, b)
                return a.dmg > b.dmg
            end)
            return y
        end

        local msg = "Damage received (full log):\n"
        local msg1 = "Game directory Combat Log parsing\nDamage received by Kind:\n"

        local kd = sort_values(kinds_dmg)
        local md = sort_values(mobs_dmg)

        local coloredkd
        for i = 1, #kd do
            msg1 = string.format("%s%s%s%s%s%s%%\n", msg1, kd[i].name, CombatLogSeparator, kd[i].dmg, CombatLogSeparator, math.round(kd[i].dmg * 100 / total_mobs_dmg))
            coloredkd = PaintKind(kd[i].name,kd[i].name)
            msg = string.format("%s%s\t%18s\t%30s%%\n", msg, coloredkd, kd[i].dmg, math.round(kd[i].dmg * 100 / total_mobs_dmg))
        end
        msg = msg .. "Top mobs and their damage:\n"
        for i = 1, math.min(10,#md) do
            coloredkd = string.gsub(md[i].name, "%s+", "")
            msg = string.format("%s%s%s ", msg, StrColor(200, 200, 0, coloredkd), md[i].dmg)
        end

        Message(msg)
        Game.ShowStatusText("Exporting full data to " .. vars.StatsOutputFile, 6)

        msg1 = msg1 .. "\nMobs and their damage:\n"
        for i = 1, #md do

            msg1 = string.format("%s%s%s%s\n", msg1, md[i].name, CombatLogSeparator, md[i].dmg)
        end
        file = io.open(vars.StatsOutputFile, "a")

        file:write(string.format("\nData exported: %s/%s/%s at %s:%s (%s)", Game.Year, Game.Month, Game.DayOfMonth, Game.Hour, Game.Minute, os.date("%Y/%m/%d %H:%M")))
        file:write(string.format("\n%s\n", msg1))
        file:close()

    end
end

