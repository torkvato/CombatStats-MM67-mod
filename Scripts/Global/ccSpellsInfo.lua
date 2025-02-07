function events.Tick()
    if Game.CurrentScreen == const.Screens.SpellBook then

        local function UpdMsg(id, m, dmg, form)
            if m > 0 then
                local pos = string.find(Game.SpellsTxt[id].Description, '\n')
                local delay = Game.Spells[id].Delay[m] / RecoveryItems(Party[Game.CurrentPlayer]) -- in vanilla MM6 speed and Haste do not affect recovery, but Recovery Items DO(!)
                local msg
                if form then
                    msg = string.format(form, dmg, dmg / Game.Spells[id].SpellPoints[m], 60 * dmg / delay)
                else
                    msg = string.format("Dmg: %s DPM: %.1f DPS: %.1f", dmg, dmg / Game.Spells[id].SpellPoints[m],
                        60 * dmg / delay)
                end
                if pos then
                    Game.SpellsTxt[id].Description = string.sub(Game.SpellsTxt[id].Description, 1, pos) .. '\n' ..
                                                         StrColor(230, 230, 0, msg)
                else
                    Game.SpellsTxt[id].Description = Game.SpellsTxt[id].Description .. '\n' ..
                                                         StrColor(230, 230, 0, msg)
                end
            end
        end

        local pl = Party[Game.CurrentPlayer]
        local dmg, dpm, id

        if Game.Version == 6 then

            local s, m = GetMagicSkill(pl, const.Skills.Fire)

            UpdMsg(const.Spells.ProtectionFromFire, m, m * s, "Effect: %s")
            UpdMsg(const.Spells.FireBolt, m, (1 + 4) / 2 * s)
            UpdMsg(const.Spells.Fireball, m, (1 + 6) / 2 * s)
            UpdMsg(const.Spells.RingOfFire, m, 6 + s)
            UpdMsg(const.Spells.FireBlast, m, (4 + 2 * s) * (3 + (m - 1) * 2))
            UpdMsg(const.Spells.MeteorShower, m, (8 + s) * (8 + (m - 1) * 2))
            UpdMsg(const.Spells.Inferno, m, 12 + s)
            UpdMsg(const.Spells.Incinerate, m, 15 + (1 + 15) / 2 * s)

            local s, m = GetMagicSkill(pl, const.Skills.Air)
            UpdMsg(const.Spells.ProtectionFromElectricity, m, m * s, "Effect: %s")
            UpdMsg(const.Spells.Sparks, m, (2 + 1 * s) * (3 + (m - 1) * 2))
            UpdMsg(const.Spells.LightningBolt, m, (1 + 8) / 2 * s)
            UpdMsg(const.Spells.Implosion, m, 10 + (1 + 10) / 2 * s)
            UpdMsg(const.Spells.Starburst, m, (20 + 1 * s) * (8 + (m - 1) * 4))

            local s, m = GetMagicSkill(pl, const.Skills.Water)
            UpdMsg(const.Spells.ProtectionFromCold, m, m * s, "Effect: %s")
            UpdMsg(const.Spells.PoisonSpray, m, (2 + 1.5 * s) * (1 + (m - 1) * 2))
            UpdMsg(const.Spells.IceBolt, m, 4 * s) -- Ice Bolt           
            UpdMsg(const.Spells.AcidBurst, m, 9 + 5 * s) -- Acid burst

            local s, m = GetMagicSkill(pl, const.Skills.Earth)
            UpdMsg(const.Spells.ProtectionFromMagic, m, m * s, "Effect: %s")
            UpdMsg(const.Spells.DeadlySwarm, m, (5 + (1 + 3) / 2 * s))
            UpdMsg(const.Spells.StoneSkin, m, 5 + s, "Effect: %s")
            UpdMsg(const.Spells.Blades, m, (1 + 5) / 2 * s)
            UpdMsg(const.Spells.RockBlast, m, (1 + 8) / 2 * s)

            local s, m = GetMagicSkill(pl, const.Skills.Spirit)
            UpdMsg(const.Spells.Bless, m, 5 + s, "Effect: %s")
            UpdMsg(const.Spells.Heroism, m, 5 + s, "Effect: %s")
            local h = {[1] = 5,[2] = 7,[3] = 9}
            UpdMsg(const.Spells.HealingTouch, m, h[m], "Heal: %s HPM: %.1f HPS: %.1f")

            local s, m = GetMagicSkill(pl, const.Skills.Mind)
            UpdMsg(const.Spells.MindBlast, m, (5 + (1 + 2) / 2 * s))
            UpdMsg(const.Spells.PsychicShock, m, (12 + (1 + 12) / 2 * s))

            local s, m = GetMagicSkill(pl, const.Skills.Body)
            local h = {[1] = 5,[2] = 7,[3] = 10}
            UpdMsg(const.Spells.FirstAid, m, h[m], "Heal: %s HPM: %.1f HPS: %.1f")
            UpdMsg(const.Spells.CureWounds, m, 5 + 2 * s, "Heal: %s HPM: %.1f HPS: %.1f")
            UpdMsg(const.Spells.Harm, m, (8 + (1 + 2) / 2 * s))
            UpdMsg(const.Spells.FlyingFist, m, (30 + (1 + 5) / 2 * s))
            UpdMsg(const.Spells.PowerCure, m, 4 * (10 + 2 * s), "Healx4: %s HPM: %.1f HPS: %.1f")

            local s, m = GetMagicSkill(pl, const.Skills.Light)
            UpdMsg(const.Spells.DestroyUndead, m, (16 + (1 + 16) / 2 * s))
            UpdMsg(const.Spells.DayOfTheGods, m, 10+(m + 1) * s, "Effect: %s")            
            UpdMsg(const.Spells.PrismaticLight, m, (25 + s))
            UpdMsg(const.Spells.HourOfPower, m, (5 + s), "Effect: %s")
            UpdMsg(const.Spells.SunRay, m, (20 + (1 + 20) / 2 * s))

            local s, m = GetMagicSkill(pl, const.Skills.Dark)
            UpdMsg(const.Spells.ToxicCloud, m, 25 + (1 + 10) / 2 * s)
            UpdMsg(const.Spells.DayOfProtection, m, (m + 1) * s, "Effect: %s")
            UpdMsg(const.Spells.Shrapmetal, m, (6 + (1 + 6) / 2 * s) * (3 + (m - 1) * 2))
            UpdMsg(const.Spells.DragonBreath, m, (1 + 25) / 2 * s)
            UpdMsg(const.Spells.Armageddon, m, 50 + s)

        elseif Game.Version == 7 then
            local s, m = GetMagicSkill(pl, const.Skills.Fire)
            UpdMsg(const.Spells.FireBolt, m, (1 + 3) / 2 * s)
            UpdMsg(const.Spells.FireResistance, m, m * s, "Effect: %s")
            UpdMsg(const.Spells.Fireball, m, (1 + 6) / 2 * s)
            UpdMsg(const.Spells.MeteorShower, m, (8 + s) * (16 + 2 * (m - 3)))
            UpdMsg(const.Spells.Inferno, m, 12 + s)
            UpdMsg(const.Spells.Incinerate, m, 15 + (1 + 15) / 2 * s)

            local s, m = GetMagicSkill(pl, const.Skills.Air)
            UpdMsg(const.Spells.AirResistance, m, m * s, "Effect: %s")
            UpdMsg(const.Spells.Sparks, m, (2 + 1 * s) * (3 + (m - 1) * 2))
            UpdMsg(const.Spells.LightningBolt, m, (1 + 8) / 2 * s)
            UpdMsg(const.Spells.Implosion, m, 10 + (1 + 10) / 2 * s)
            UpdMsg(const.Spells.Starburst, m, (20 + 1 * s) * 20)

            local s, m = GetMagicSkill(pl, const.Skills.Water)
            UpdMsg(const.Spells.WaterResistance, m, m * s, "Effect: %s")
            UpdMsg(const.Spells.PoisonSpray, m, (2 + 1.5 * s) * (1 + (m - 1) * 2))
            UpdMsg(const.Spells.IceBolt, m, (1 + 4) / 2 * s)
            UpdMsg(const.Spells.AcidBurst, m, 9 + (1 + 9) / 2 * s)

            local s, m = GetMagicSkill(pl, const.Skills.Earth)
            UpdMsg(const.Spells.EarthResistance, m, m * s, "Effect: %s")
            UpdMsg(const.Spells.DeadlySwarm, m, (5 + 2 * s))
            UpdMsg(const.Spells.StoneSkin, m, 5 + s, "Effect: %s")
            UpdMsg(const.Spells.Blades, m, (1 + 9) / 2 * s)
            UpdMsg(const.Spells.RockBlast, m, (1 + 8) / 2 * s)

            local s, m = GetMagicSkill(pl, const.Skills.Spirit)
            UpdMsg(const.Spells.Bless, m, 5 + s, "Effect: %s")
            UpdMsg(const.Spells.Heroism, m, 5 + s, "Effect: %s")
            UpdMsg(const.Spells.SpiritLash, m, (10 + (2 + 8) / 2 * s))

            local s, m = GetMagicSkill(pl, const.Skills.Mind)
            UpdMsg(const.Spells.MindResistance, m, m * s, "Effect: %s")
            UpdMsg(const.Spells.MindBlast, m, (3 + (1 + 3) / 2 * s))
            UpdMsg(const.Spells.PsychicShock, m, (12 + (1 + 12) / 2 * s))

            local s, m = GetMagicSkill(pl, const.Skills.Body)
            UpdMsg(const.Spells.Heal, m, 5 + (m + 1) * s, "Heal: %s HPM: %.1f HPS: %.1f")
            UpdMsg(const.Spells.BodyResistance, m, m * s, "Effect: %s")
            UpdMsg(const.Spells.Harm, m, (8 + (1 + 2) / 2 * s))
            UpdMsg(const.Spells.FlyingFist, m, (30 + (1 + 5) / 2 * s))
            UpdMsg(const.Spells.PowerCure, m, 4 * (10 + 5 * s), "Healx4: %s HPM: %.1f HPS: %.1f")

            local s, m = GetMagicSkill(pl, const.Skills.Light)
            UpdMsg(const.Spells.LightBolt, m, ((1 + 4) / 2 * s))
            UpdMsg(const.Spells.DestroyUndead, m, (16 + (1 + 16) / 2 * s))
            UpdMsg(const.Spells.DayOfTheGods, m, 10+(m + 1) * s, "Effect: %s")
            UpdMsg(const.Spells.DayOfProtection, m, (m + 1) * s, "Effect: %s")
            UpdMsg(const.Spells.PrismaticLight, m, (25 + s))
            UpdMsg(const.Spells.HourOfPower, m, (5 + s), "Effect: %s")
            UpdMsg(const.Spells.Sunray, m, (20 + (1 + 20) / 2 * s))

            local s, m = GetMagicSkill(pl, const.Skills.Dark)
            UpdMsg(const.Spells.ToxicCloud, m, 25 + (1 + 10) / 2 * s)
            UpdMsg(const.Spells.Shrapmetal, m, (6 + (1 + 6) / 2 * s) * (3 + (m - 1) * 2))
            UpdMsg(const.Spells.DragonBreath, m, (1 + 25) / 2 * s)
            UpdMsg(const.Spells.Armageddon, m, 50 + s)
            UpdMsg(const.Spells.Souldrinker, m, 25 + (1 + 8) / 2 * s)

        end

    end
end

function GetMagicSkill(pl, sk)
    if Game.Version < 7 then
        local s, m = SplitSkill(pl.Skills[sk])
        local sk2bon = {
            [12] = 30,-- 30	of Fire Magic
            [13] = 26,-- 26	of Air Magic
            [14] = 34,-- 34	of Water Magic
            [15] = 29,-- 29	of Earth Magic
            [16] = 33,-- 33	of Spirit Magic
            [17] = 32,-- 32	of Mind Magic
            [18] = 27,-- 27	of Body Magic
            [19] = 31,-- 31	of Light Magic
            [20] = 28,-- 28	of Dark Magic
        }

        if CheckBonus2(pl, sk2bon[sk]) then
            s = math.floor(s * 1.5)
        end
        --  Artifacts 412LD, 413 BMS, 414 FAWE
        if (sk>=12 and sk<=15) and CheckItem(pl,414) then s = math.floor(s * 1.5) end
        if (sk>=16 and sk<=18) and CheckItem(pl,413) then s = math.floor(s * 1.5) end
        if (sk==19 or  sk==20) and CheckItem(pl,412) then s = math.floor(s * 1.5) end

        if s > 0 then
            if Party.HasNPCProfession(const.NPCProfession.Apprentice) then
                s = s + 2
            end
            if Party.HasNPCProfession(const.NPCProfession.Mystic) then
                s = s + 3
            end
            if Party.HasNPCProfession(const.NPCProfession.SpellMaster) then
                s = s + 4
            end
        end
        return s, m
    else
        return SplitSkill(pl:GetSkill(sk))
    end
end

-- for i=0,const.Spells.High do print(i,get_key_for_value(const.Spells,i)) end









