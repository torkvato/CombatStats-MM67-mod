function events.KeyDown(t)
    if Game.CurrentScreen == 0 and t.Key == const.Keys.L and Keys.IsPressed(const.Keys.ALT) and TrainingDummy==1 then
        -- vars.MonGenerated = true and not(vars.MonGenerated)
        vars.CombatLogFile = 'cl_dummy.csv'
        vars.StatsOutputFile = 'stats_dummy.csv'
	Game.ShowStatusText('Combat log file changed to: ' .. vars.CombatLogFile, 3)

        local MonId = 106 -- monk master / minotaur
        local anglerad = Party.Direction/2048*2*3.1415
        local mon = SummonMonster(MonId, Party.X + 70*math.cos(anglerad), Party.Y + 70*math.sin(anglerad), Party.Z)
        mon.Group = 0
        mon.Hostile = false
        mon.ShowAsHostile = false
        mon.HostileType = 0
        mon.NoFlee = true
        mon.GuardRadius = 0
        mon.Velocity = 0
        mon.AIState = 15

        mon.Exp = 0

        -- mon.HitPoints = 100
        mon.FullHP = 32000
        mon.HP = 32000

        for i = 0, 10 do
            mon.Resistances[i] = 0
        end

        --mon.ArmorClass = Party[0]:GetLevel() -- AC-Lvl as in DPS calculus
        mon.ArmorClass = -20
        -- mon.ArmorClass = -20 --sure hit

        mon.SpellBuffs[const.MonsterBuff.Paralyze]:Set(Game.Time + 3 * const.Minute * 100, 10)
    end

--    if Game.CurrentScreen == 0 and t.Key==const.Keys.K and  Keys.IsPressed(const.Keys.ALT)  then
--        mon = SummonMonster(155, Party.X+30, Party.Y, Party.Z)
--        Party.Reputation = 0
--    end
end

-- for i, v in Game.MonstersTxt do
--     print(i, v.Name )
-- end
-- --
-- DoBadThing(20, mon)
