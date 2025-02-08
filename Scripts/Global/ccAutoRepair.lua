function events.Regeneration(t)
    if SharedRepair == 2 then
        local s = const.Skills.Repair
        local maxskill = 0
        local sk
        for _, pl in Party do
            if (pl.Eradicated + pl.Dead + pl.Stoned + pl.Paralyzed + pl.Unconscious + pl.Asleep) == 0 then
                if Game.Version < 7 then
                    sk = pl.Skills[s]
                else
                    sk = pl:GetSkill(s)
                end
                if maxskill < sk then
                    maxskill = sk
                end
            end
        end
        if maxskill == 0 then
            return
        end
        local rep, mas = SplitSkill(maxskill)
        local msg = ''
        for _, it in t.Player.Items do
            if it.Broken and it:T().IdRepSt <= rep * mas then
                it.Broken = false
                msg = msg .. it:T().Name .. ', '
                --Game.ShowStatusText(it:T().Name .. ' repaired!', 1)                            
            end
        end
        if msg~='' then 
        Game.ShowStatusText(StrColor(230,230,0,'Repaired:' .. string.sub(msg,1,-3), 3))
        end
    end
end

