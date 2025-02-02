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
        local rep,mas = SplitSkill(maxskill)

        for _, it in t.Player.Items do
            if it.Broken and  it:T().IdRepSt<=rep*mas then
                it.Broken = false
                Game.ShowStatusText(it:T().Name .. ' repaired!', 2)
            end
        end       
    end
end

