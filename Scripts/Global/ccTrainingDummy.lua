function events.KeyDown(t)
    if Game.CurrentScreen == 0 and t.Key == const.Keys.L and Keys.IsPressed(const.Keys.ALT) and TrainingDummy==1 then
        -- vars.MonGenerated = true and not(vars.MonGenerated)

        MonId = 106 -- monk master

        mon = SummonMonster(MonId, Party.X + 30, Party.Y, Party.Z)
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

        mon.ArmorClass = Party[0]:GetLevel() -- AC-Lvl as in DPS calculus
        -- mon.ArmorClass = -20 --sure hit

        mon.SpellBuffs[const.MonsterBuff.Paralyze]:Set(Game.Time + 3 * const.Minute * 100, 10)
        mon:ShowSpellEffect()
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
