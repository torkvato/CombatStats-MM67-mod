-- function events.GameInitialized2()
--     schedulenotealreadyadded = false
--     Game.GlobalTxt[144] = StrColor(255, 0, 0, Game.GlobalTxt[144])
--     Game.GlobalTxt[116] = StrColor(255, 128, 0, Game.GlobalTxt[116])
--     Game.GlobalTxt[163] = StrColor(0, 127, 255, Game.GlobalTxt[163])
--     Game.GlobalTxt[75] = StrColor(0, 255, 0, Game.GlobalTxt[75])
--     Game.GlobalTxt[1] = StrColor(250, 250, 0, Game.GlobalTxt[1])
--     Game.GlobalTxt[211] = StrColor(160, 50, 255, Game.GlobalTxt[211])
--     Game.GlobalTxt[136] = StrColor(255, 255, 255, Game.GlobalTxt[136])
--     Game.GlobalTxt[108] = StrColor(0, 255, 0, Game.GlobalTxt[108])
--     Game.GlobalTxt[212] = StrColor(0, 100, 255, Game.GlobalTxt[212])
--     Game.GlobalTxt[12] = StrColor(230, 204, 128, Game.GlobalTxt[12])
-- end

function events.Tick()
    if Game.CurrentCharScreen == 100 and Game.CurrentScreen == 7 then
        local pl = Party[Game.CurrentPlayer]
        local lvl = pl:GetLevel()
        local AC = pl:GetArmorClass()
        local monAC_LvL = math.min(100, 3 * lvl)
        local monster_hit_chance = (5 + monAC_LvL * 2) / (10 + monAC_LvL * 2 + AC)
    
        local attr = {}
        attr[0] = pl:GetMight()
        attr[1] = pl:GetIntellect()
        attr[2] = pl:GetPersonality()
        attr[3] = pl:GetEndurance()
        attr[4] = pl:GetAccuracy()
        attr[5] = pl:GetSpeed()
        attr[6] = pl:GetLuck()

        -- Stats modifiers
        local function UpdStatsMsg(msg, id)
            local pos = string.find(Game.StatsDescriptions[id], '\n')
            if pos then
                Game.StatsDescriptions[id] = string.format("%s\n%s: %d, next limit: %s",string.sub(Game.StatsDescriptions[id], 1, pos), msg,
                    Stat2Modifier(attr[id]))
            else
                Game.StatsDescriptions[id] = string.format("%s\n%s: %d, next limit: %s", Game.StatsDescriptions[id], msg, Stat2Modifier(attr[id]))
            end
        end
        UpdStatsMsg('ToDamage modifier', 0)
        UpdStatsMsg('Intellect modifier', 1)
        UpdStatsMsg('Personality modifier', 2)
        UpdStatsMsg('Health modifier', 3)
        UpdStatsMsg('ToHit modifier', 4)
        UpdStatsMsg('AC and Recovery modifier', 5)
        UpdStatsMsg('Resistances modifier', 6)

        -- Effective HP
        local vitality
        if Game.Version < 7 then
            vitality= ResistancesInfoMM6(pl,monster_hit_chance)
        else
            vitality = ResistancesInfoMM7(pl,monster_hit_chance)
        end
        -- Attack and DPS calculations	
        local dmg_m = 0
        local atk_m = pl:GetMeleeAttack()
        local delay_m = pl:GetAttackDelay()
        local slot = pl.ItemMainHand
        local it0 = (slot ~= 0 and pl.Items[slot])
        if (delay_m < Game.MinMeleeRecoveryTime) and (it0.Number ~= 65) and (it0.Number ~= 64) then -- Blasters
            delay_m = Game.MinMeleeRecoveryTime
        end
        local recoverycoeff = RecoveryItems(pl) -- Recovery items 1.1 coefficient
        delay_m = delay_m / recoverycoeff

        local meleerange = pl:GetMeleeDamageRangeText()
        local i1 = string.find(meleerange, "-")
        if i1 then
            dmg_m = (string.sub(meleerange, 1, i1 - 1) + string.sub(meleerange, i1 + 1, -1)) / 2
        else
            dmg_m = meleerange
        end

        local hitchance_m = (15 + atk_m * 2) / (30 + atk_m * 2 + monAC_LvL) -- monster AC treated equal to Player Lvl

        local dmg_r = 0
        local atk_r = pl:GetRangedAttack()
        local delay_r = pl:GetAttackDelay(true)
        delay_r = delay_r / recoverycoeff

        local rangedrange = pl:GetRangedDamageRangeText()
        local i1 = string.find(rangedrange, "-")
        if i1 then
            dmg_r = (string.sub(rangedrange, 1, i1 - 1) + string.sub(rangedrange, i1 + 1, -1)) / 2
        end -- (pl:GetRangedDamageMin() + pl:GetRangedDamageMax()) / 2        

        local hitchance_r = (15 + atk_r * 2) / (30 + atk_r * 2 + monAC_LvL)

        dmg_m = dmg_m + DaggerTriple(pl)
        local elem_m, elem_r = WeaponElemDamage(pl)
        
        local dps_m = (dmg_m + elem_m) * hitchance_m / (delay_m / 60)
        local dps_r = (dmg_r + elem_r) * hitchance_r / (delay_r / 60)

        Game.GlobalTxt[47] = string.format("M/R DPS: %s/%s\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n", StrColor(255, 0, 0, math.round(dps_m * 10) / 10),
            StrColor(255, 255, 50, math.round(dps_r * 10) / 10))
        Game.GlobalTxt[172] = string.format("Vit:%s Avoid:%s%%\n\n\n\n\n\n\n\n\n\n\n\n\n\n", StrColor(0, 255, 0, vitality), StrColor(230, 204, 128, math.round(1000 * (1 - monster_hit_chance)) / 10))

        Game.GlobalTxt2[2] = PartyRecordsTxt()

        if Keys.IsPressed(const.Keys.ALT) then
            Game.GlobalTxt2[3] = "Full stats since game beginning, [E] for export\n" .. DamageMeterCalculation(vars.damagemeter)
            Game.GlobalTxt2[4] = "Full stats since game beginning, [E] for export\n" .. DamageReceivedCalculation(vars.damagemeter)
        elseif Keys.IsPressed(const.Keys.CONTROL) then
            Game.GlobalTxt2[3] = string.format("Segment: %s since [R]eset\n", GameTimePassed()) .. DamageMeterCalculation(vars.damagemeter1)
            Game.GlobalTxt2[4] = string.format("Segment: %s since [R]eset\n", GameTimePassed()) .. DamageReceivedCalculation(vars.damagemeter1)
        else
            Game.GlobalTxt2[3] = string.format("Map: %s, [ALT]-Full, [CTRL]-Segment\n", Game.MapStats[Game.Map.MapStatsIndex].Name) .. DamageMeterCalculation(mapvars.damagemeter)
            Game.GlobalTxt2[4] = string.format("Map: %s, [ALT]-Full, [CTRL]-Segment\n", Game.MapStats[Game.Map.MapStatsIndex].Name) .. DamageReceivedCalculation(mapvars.damagemeter)
        end
        textsupdated = true
elseif textsupdated and (Game.CurrentScreen ~= 7 or Game.CurrentCharScreen == 101) then
    if Game.Version>6 then
    Game.GlobalTxt[87]  = StrColor(255, 70, 70, "Fire")
    Game.GlobalTxt[6]   = StrColor(173, 216, 230, "Air")
    Game.GlobalTxt[240] = StrColor(100, 180, 255, "Water")
    Game.GlobalTxt[70]  = StrColor(153, 76, 0, "Earth")
    Game.GlobalTxt[142] = StrColor(200, 200, 255, "Mind")
    Game.GlobalTxt[29]  = StrColor(255, 192, 203, "Body")
    else
        Game.GlobalTxt[138] = 'Magic'
    end
    textsupdated = false
    end

    -- if Game.CurrentCharScreen == 101 and Game.CurrentScreen == 7 and textsupdated then
        
    --     textsupdated = false
    -- end

    if Game.CurrentCharScreen == 101 and Game.CurrentScreen == 7 and SkillTooltipsEnabled then
        SkillToolTips()
    end
end

function ResistancesInfoMM6(pl, monster_hit_chance)
    local fullHP = pl:GetFullHP()
    local luck = pl:GetLuck()
    
    local Resistances = {}
    local ResistancesPerc = {}
    local R0 = {}

    Resistances[1] = pl:GetFireResistance()
    Resistances[2] = pl:GetElectricityResistance()
    Resistances[3] = pl:GetColdResistance()
    Resistances[4] = pl:GetPoisonResistance()
    Resistances[5] = pl:GetMagicResistance()

    for i = 1, 5 do
        if Resistances[i] > 0 then
            p = 1 - 30 / (30 + Resistances[i] + Stat2Modifier(luck))
        else
            p = 0;
        end
        ResistancesPerc[i] = 100 - math.round(100 * (1 - p) + 50 * (1 - p) * p + 25 * (1 - p) * p ^ 2 + 12.5 * (1 - p) * p ^ 3 + 6.25 * p ^ 4);
        R0[i] = (1 - p) + .5 * (1 - p) * p + .25 * (1 - p) * p ^ 2 + .125 * (1 - p) * p ^ 3 + .0625 * p ^ 4;
    end

    Game.GlobalTxt[87] = StrColor(255, 70, 70, string.format("Fire\t%15s%%", ResistancesPerc[1]))
    Game.GlobalTxt[71] = StrColor(173, 216, 230, string.format("Elec\t%15s%%", ResistancesPerc[2]))
    Game.GlobalTxt[43] = StrColor(100, 180, 255, string.format("Cold\t%15s%%", ResistancesPerc[3]))
    Game.GlobalTxt[166] = StrColor(0, 250, 0, string.format("Poison\t%15s%%", ResistancesPerc[4]))
    Game.GlobalTxt[138] = StrColor(160, 50, 255, string.format("Magic\t%15s%%", ResistancesPerc[5]))

    -- --Bad things TODO -ma
    -- --Chance that an enemy will succeed in doing some bad thing to you is 30/(30 + LuckEffect + OtherEffect), where OtherEffect depends on that particular thing:
    -- local msg = StrColor(255, 70, 70,string.format("Bad things chances: Luck+additional stat:\n"))
    -- msg = msg.. string.format("Age, Disease, Sleep (End): %d%%\n",math.round(3000/(30+Stat2Modifier(luck)+Stat2Modifier(endu))))
    -- msg = msg.. string.format("Curse (Pers): - %d%%\n",math.round(3000/(30+Stat2Modifier(luck)+Stat2Modifier(pers))))
    -- msg = msg.. string.format("DrainSP, Dispel(Pers+Int) %d%%\n",math.round( 3000/(30+Stat2Modifier(luck)+(Stat2Modifier(pers)+Stat2Modifier(intel))/2) ))
    -- msg = msg.. string.format("Paralyze,Insane (Mind Res.): %d%%\n",math.round(3000/(30+Stat2Modifier(luck)+MindRes)))
    -- msg = msg.. string.format("Death, Eradication, Poison (Body Res.): %d%%\n",math.round(3000/(30+Stat2Modifier(luck)+BodyRes)))
    -- for i=0,5 do
    -- Game.GlobalTxt2[50+i] = msg
    -- end

    local coeff = 1

    local AW = {
        Phys = 0.5,
        Fire = 0.05,
        Electricity = 0.05,
        Cold = 0.05,
        Poison = 0.05,
        Magic = .30
    }

    local avoidance = coeff * monster_hit_chance * AW.Phys + R0[1] * AW.Fire + R0[2] * AW.Electricity + R0[3] * AW.Cold + R0[4] * AW.Poison + R0[5] * AW.Magic
    local vitality = math.round(0.5 * fullHP + 0.5 * fullHP / avoidance) -- full HP added to take into account unavoidable damage like Light, Energy and Dark

    return vitality
end

function ResistancesInfoMM7(pl,monster_hit_chance)
    local fullHP = pl:GetFullHP()
    local luck = pl:GetLuck()

    local Resistances = {}
    local ResistancesPerc = {}
    local R0 = {}

    for i = 10, 15 do
        Resistances[i] = pl:GetResistance(i)

        if Resistances[i] > 0 then
            p = 1 - 30 / (30 + Resistances[i] + Stat2Modifier(luck))
        else
            p = 0;
        end
        
        ResistancesPerc[i] = 100 - math.round(100 * (1 - p) + 50 * (1 - p) * p + 25 * (1 - p) * p ^ 2 + 12.5 * (1 - p) * p ^ 3 + 6.25 * p ^ 4);
        R0[i] = (1 - p) + .5 * (1 - p) * p + .25 * (1 - p) * p ^ 2 + .125 * (1 - p) * p ^ 3 + .0625 * p ^ 4;
    end

    Game.GlobalTxt[87] = StrColor(255, 70, 70, string.format("Fire\t%15s%%", ResistancesPerc[10]))
    Game.GlobalTxt[6] = StrColor(173, 216, 230, string.format("Air\t%15s%%", ResistancesPerc[11]))
    Game.GlobalTxt[240] = StrColor(100, 180, 255, string.format("Water\t%15s%%", ResistancesPerc[12]))
    Game.GlobalTxt[70] = StrColor(153, 76, 0, string.format("Earth\t%15s%%", ResistancesPerc[13]))
    Game.GlobalTxt[142] = StrColor(200, 200, 255, string.format("Mind\t%15s%%", ResistancesPerc[14]))
    Game.GlobalTxt[29] = StrColor(255, 192, 203, string.format("Body\t%15s%%", ResistancesPerc[15]))

    -- Bad things
    -- Chance that an enemy will succeed in doing some bad thing to you is 30/(30 + LuckEffect + OtherEffect), where OtherEffect depends on that particular thing:
    local msg = StrColor(255, 70, 70, string.format("Bad things chances: Luck+additional stat:\n"))
    msg = msg .. string.format("Age, Disease, Sleep (End): %d%%\n", math.round(3000 / (30 + Stat2Modifier(luck) + Stat2Modifier(pl:GetEndurance()))))
    msg = msg .. string.format("Curse (Pers): - %d%%\n", math.round(3000 / (30 + Stat2Modifier(luck) + Stat2Modifier(pl:GetPersonality()))))
    msg = msg .. string.format("DrainSP, Dispel(Pers+Int) %d%%\n", math.round(3000 / (30 + Stat2Modifier(luck) + (Stat2Modifier(pl:GetPersonality()) + Stat2Modifier(pl:GetIntellect())) / 2)))
    msg = msg .. string.format("Paralyze,Insane (Mind Res.): %d%%\n", math.round(3000 / (30 + Stat2Modifier(luck) + Resistances[14]))) -- mind
    msg = msg .. string.format("Death, Eradication, Poison (Body Res.): %d%%\n", math.round(3000 / (30 + Stat2Modifier(luck) + Resistances[15]))) -- body

    for i = 0, 5 do
        Game.GlobalTxt2[50 + i] = msg
    end

    local coeff = CheckPlateChain(pl)

    -- local AW = {Phys = 0.65, Fire=0.075, Air=0.075, Water=0.075, Earth = 0.075, Mind=0.025,Body = .025} -- first try
    local AW = {
        Phys = 0.45,
        Fire = 0.25,
        Air = 0.15,
        Water = 0.8,
        Earth = 0.2,
        Mind = 5,
        Body = 0
    } -- on the base of full game damage percentages (TKPS party )
    local avoidance = coeff * monster_hit_chance * AW.Phys + R0[10] * AW.Fire + R0[11] * AW.Air + R0[12] * AW.Water + R0[13] * AW.Earth + R0[14] * AW.Mind + R0[15] * AW.Body
    local vitality = math.round(0.5 * fullHP + 0.5 * fullHP / avoidance) -- full HP added to take into account unavoidable damage like Light, Energy and Dark

    return vitality
end

function WeaponElemDamage(pl)
    -- Weapons element damage
    local slot = pl.ItemMainHand
    local it0 = (slot ~= 0 and pl.Items[slot])
    local slot = pl.ItemExtraHand
    local it1 = (slot ~= 0 and pl.Items[slot])
    local slot = pl.ItemBow
    local it2 = (slot ~= 0 and pl.Items[slot])

    local elem_m = 0
    local elem_r = 0
    if Game.Version < 7 then

        if it0 and (it0.Number == 415) then
            elem_m = 20
        end -- Hades
        if it0 and (it0.Number == 416) then
            elem_m = 30
        end -- Ares
        if it1 and (it1.Number == 415) then
            elem_m = 20
        end -- Hades
        if it1 and (it1.Number == 416) then
            elem_m = 30
        end -- Ares
        if it2 and (it2.Number == 420) then
            elem_m = 20
        end -- Artemis

        if it0 and const.bonus2damage[it0.Bonus2] then
            elem_m = elem_m + const.bonus2damage[it0.Bonus2]
        end
        if it1 and const.bonus2damage[it1.Bonus2] then
            elem_m = elem_m + const.bonus2damage[it1.Bonus2]
        end
        if it2 and const.bonus2damage[it2.Bonus2] then
            elem_r = elem_r + const.bonus2damage[it2.Bonus2]
        end
    else
        if it0 and (it0.Number == 501 or it0.Number == 507 or it0.Number == 517) then
            elem_m = 10.5
        end -- Iron feather, Ghoulsbane, Old Nick
        if it1 and (it1.Number == 501 or it1.Number == 507 or it1.Number == 517) then
            elem_m = elem_m + 10.5
        end
        if it2 and (it2.Number == 510) then
            elem_r = 10.5
        end -- Ulysses artifact

        if it0 and const.bonus2damage[it0.Bonus2] then
            elem_m = elem_m + const.bonus2damage[it0.Bonus2]
        end
        if it1 and const.bonus2damage[it1.Bonus2] then
            elem_m = elem_m + const.bonus2damage[it1.Bonus2]
        end
        if it2 and const.bonus2damage[it2.Bonus2] then
            elem_r = elem_r + const.bonus2damage[it2.Bonus2]
        end
    end
return elem_m, elem_r
end
