function events.KeyDown(t)
    if Game.CurrentScreen == 0 and t.Key==const.Keys.L and not(MonGenerated) and Keys.IsPressed(const.Keys.ALT)  then
        MonGenerated = true

        
        MonId = 106 --monk master
        local mon = SummonMonster(MonId, Party.X+30, Party.Y, Party.Z)
		mon.Group = 0
		mon.Hostile = false
		mon.ShowAsHostile = false
		mon.HostileType = 0
        mon.NoFlee = true
        mon.GuardRadius = 0
        mon.Velocity = 0
        mon.AIState = 15

        mon.Exp = 0
        
        --mon.HitPoints = 100
        mon.FullHP = 32000
        mon.HP     = 32000
              

        for i = 0,10 do
            mon.Resistances[i] = 0
        end

    end
end


-- for i, v in Game.MonstersTxt do
--     print(i, v.Name )
-- end
-- --