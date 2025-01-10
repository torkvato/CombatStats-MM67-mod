-- Segment stats reset and export
function events.KeyDown(t)
    if Game.CurrentScreen == 7 and Game.CurrentCharScreen == 100 then
        if t.Key == DamageMeterResetButton then -- "r" key
            Game.ShowStatusText(string.format("Segment data reset, press Y to continue reset"))
            segment_data_reset_confirmation = 1;
        end
        if t.Key == DamageMeterExportButton then -- "u" key
            Game.ShowStatusText(string.format("Damage and DPS data export, press Y to continue..."))
            data_export_confirmation = 1;
        end

        if (t.Key ~= 89) and (t.Key ~= DamageMeterResetButton) and (segment_data_reset_confirmation == 1) then -- not "y" key
            segment_data_reset_confirmation = 0; -- aborting reset without confirmation
        end

        if (t.Key ~= 89) and (t.Key ~= DamageMeterExportButton) and (data_export_confirmation == 1) then -- not "y" key
            data_export_confirmation = 0; -- aborting export without confirmation
        end

        if t.Key == 89 and (segment_data_reset_confirmation == 1) then -- "y" key
            Game.ShowStatusText(string.format("Segment data reset."))
            segment_data_reset_confirmation = 0;
            local i
            for i = 0, Party.High do
                vars.damagemeter1[i]={Damage = 0, Damage_Melee = 0, Damage_Ranged = 0, Damage_Spell = 0, ActiveTime = 1, ActiveTime_Melee = 1, ActiveTime_Ranged = 1,ActiveTime_Spell = 1}
                vars.timestamps[i].SegmentStart = Game.Time          
            end
        end
        if t.Key == 89 and (data_export_confirmation == 1) then -- "y" key
			Game.ShowStatusText(string.format("Exporting stats data to file: %s",StatsOutputFile))
            data_export_confirmation = 0; 
			
			file = io.open(StatsOutputFile,"a")
			local gameminutes = math.floor((Game.Time - vars.timestamps[0].SegmentStart)/const.Minute)    
			file:write(string.format("Data exported: %s/%s/%s at %s:%s (%s)",Game.Year,Game.Month,Game.DayOfMonth,Game.Hour,Game.Minute, os.date("%Y/%m/%d %H:%M")) )
			file:write(string.format("\nSegment data (%s game minutes since last reset)\n",gameminutes) .. DamageMeterCalculation(vars.damagemeter1,1))
			file:write(string.format("\nCurrent map data: %s\n",Game.MapStats[Game.Map.MapStatsIndex].Name) .. DamageMeterCalculation(mapvars.damagemeter,1))
			file:write(string.format("\nFull game data\n") .. DamageMeterCalculation(vars.damagemeter,1))
			file:write("\n")
       
			file:close()			
        end
    end


end
-- Combat logging
function events.CalcDamageToMonster(t)
    if t.Damage > 0 then
        -- t.Damage : damage BEFORE monster resistances, t.Result : final damage after monster resistances, mapvars - map
        local data = WhoHitMonster()

        --if data.Player:GetIndex() > 0 then return end -- only one player logged

        if data and data.Player then

            i = data.Player:GetIndex()

            if t.Monster.NameId > 0 then monName = Game.PlaceMonTxt[t.Monster.NameId]  else monName = Game.MonstersTxt[t.Monster.Id].Name end
            
            -- DPS is calculated as total damage done, divided by total active time in real seconds
            -- In-game time: 2 real seconds equal 1 in-game minute, 1 real second = 30 in-game seconds
            -- 256 "Game.time" ticks = 1 in-game minute,  128 "Game.time" ticks = 30 in-game seconds = 1 real second (const.RTSecond)
            -- 60 "recovery" ticks = 1 real second  = 30 in-game seconds = 128 ticks
            
            -- Active time - contuguous time when periods betwen successful hits less than 5 seconds  (5*128)
            local timedelta = Game.Time - vars.timestamps[i].LastTimeStamp;

            if timedelta < 5*const.RTSecond then
                -- timedelta may be zero, in this case we do not modify time stats
                vars.damagemeter[i].ActiveTime = vars.damagemeter[i].ActiveTime + timedelta
                vars.damagemeter1[i].ActiveTime = vars.damagemeter1[i].ActiveTime + timedelta
                mapvars.damagemeter[i].ActiveTime = mapvars.damagemeter[i].ActiveTime + timedelta

                vars.timestamps[i].LastTimeStamp = Game.Time

                if not(data.Object) then
                    vars.damagemeter[i].ActiveTime_Melee = vars.damagemeter[i].ActiveTime_Melee + timedelta
                    vars.damagemeter1[i].ActiveTime_Melee = vars.damagemeter1[i].ActiveTime_Melee + timedelta
                    mapvars.damagemeter[i].ActiveTime_Melee = mapvars.damagemeter[i].ActiveTime_Melee + timedelta
                    vars.timestamps[i].LastTimeStamp_Melee = Game.Time                      
                elseif data.Object.Missile then
                    vars.damagemeter[i].ActiveTime_Ranged = vars.damagemeter[i].ActiveTime_Ranged + timedelta
                    vars.damagemeter1[i].ActiveTime_Ranged = vars.damagemeter1[i].ActiveTime_Ranged + timedelta
                    mapvars.damagemeter[i].ActiveTime_Ranged = mapvars.damagemeter[i].ActiveTime_Ranged + timedelta
                    vars.timestamps[i].LastTimeStamp_Ranged = Game.Time   
                else
                    vars.damagemeter[i].ActiveTime_Spell = vars.damagemeter[i].ActiveTime_Spell + timedelta
                    vars.damagemeter1[i].ActiveTime_Spell = vars.damagemeter1[i].ActiveTime_Spell + timedelta
                    mapvars.damagemeter[i].ActiveTime_Spell = mapvars.damagemeter[i].ActiveTime_Spell + timedelta
                    vars.timestamps[i].LastTimeStamp_Spell = Game.Time   
                end 

            else -- There was too large pause between hits, ignore the pause in active time statistics, but we may need to add last hit recovery for the sake of DPS accuracy               
                vars.timestamps[i].LastTimeStamp = Game.Time
                vars.damagemeter[i].ActiveTime = vars.damagemeter[i].ActiveTime + const.RTSecond-- Assume average hit delay about 1s 
                vars.damagemeter1[i].ActiveTime = vars.damagemeter1[i].ActiveTime + const.RTSecond
                mapvars.damagemeter[i].ActiveTime = mapvars.damagemeter[i].ActiveTime + const.RTSecond
                
                if not(data.Object) then
                    vars.timestamps[i].LastTimeStamp_Melee = Game.Time
                    vars.damagemeter[i].ActiveTime_Melee = vars.damagemeter[i].ActiveTime_Melee + const.RTSecond -- Assume average hit delay about 1s 
                    vars.damagemeter1[i].ActiveTime_Melee = vars.damagemeter1[i].ActiveTime_Melee + const.RTSecond
                    mapvars.damagemeter[i].ActiveTime_Melee = mapvars.damagemeter[i].ActiveTime_Melee + const.RTSecond
                elseif data.Object.Missile then
                    vars.timestamps[i].LastTimeStamp_Ranged = Game.Time
                    vars.damagemeter[i].ActiveTime_Ranged = vars.damagemeter[i].ActiveTime_Ranged + const.RTSecond -- Assume average hit delay about 1s 
                    vars.damagemeter1[i].ActiveTime_Ranged = vars.damagemeter1[i].ActiveTime_Ranged + const.RTSecond
                    mapvars.damagemeter[i].ActiveTime_Ranged = mapvars.damagemeter[i].ActiveTime_Ranged + const.RTSecond
                else
                    vars.timestamps[i].LastTimeStamp_Spell = Game.Time
                    vars.damagemeter[i].ActiveTime_Spell = vars.damagemeter[i].ActiveTime_Spell+ const.RTSecond -- Assume average hit delay about 1s 
                    vars.damagemeter1[i].ActiveTime_Spell = vars.damagemeter1[i].ActiveTime_Spell + const.RTSecond
                    mapvars.damagemeter[i].ActiveTime_Spell = mapvars.damagemeter[i].ActiveTime_Spell + const.RTSecond
                end 
                
            end

            -- Update damage
            vars.damagemeter[i].Damage = vars.damagemeter[i].Damage + t.Result
            vars.damagemeter1[i].Damage = vars.damagemeter1[i].Damage + t.Result
            mapvars.damagemeter[i].Damage = mapvars.damagemeter[i].Damage + t.Result
            if not(data.Object) then
                vars.damagemeter[i].Damage_Melee = vars.damagemeter[i].Damage_Melee + t.Result
                vars.damagemeter1[i].Damage_Melee = vars.damagemeter1[i].Damage_Melee + t.Result
                mapvars.damagemeter[i].Damage_Melee = mapvars.damagemeter[i].Damage_Melee + t.Result
            elseif data.Object.Missile then
                vars.damagemeter[i].Damage_Ranged = vars.damagemeter[i].Damage_Ranged + t.Result
                vars.damagemeter1[i].Damage_Ranged = vars.damagemeter1[i].Damage_Ranged + t.Result
                mapvars.damagemeter[i].Damage_Ranged = mapvars.damagemeter[i].Damage_Ranged + t.Result
            else
                vars.damagemeter[i].Damage_Spell = vars.damagemeter[i].Damage_Spell + t.Result
                vars.damagemeter1[i].Damage_Spell = vars.damagemeter1[i].Damage_Spell + t.Result
                mapvars.damagemeter[i].Damage_Spell = mapvars.damagemeter[i].Damage_Spell + t.Result
            end

            objmsg = DamageTypeParsing(data.Object)

            if CombatLogEnabled==1 then
                local z = CombatLogSeparator
                playerid = string.format("%s%s%s(%s)%s%s", i, z, Game.ClassNames[data.Player.Class], data.Player:GetLevel(), z, data.Player.Name)
                -- Timestamp #Player Name(Lvl) TargetName Damage DamageKind DamageSource
                local msg = string.format("%s%s%s%s%s%s%s%s%s%s%s\n", Game.Time, z, playerid,  z, monName, z, t.Result, z, get_key_for_value(const.Damage, t.DamageKind),z, objmsg)
                file = io.open(CombatLogFile, "a")
                file:write(msg)
                file:close()
            end
            
        end
    end
end


function events.GameInitialized2()

    Game.GlobalTxt[144] = StrColor(255, 0, 0, "Might")
    Game.GlobalTxt[116] = StrColor(255, 128, 0, "Intellect")
    Game.GlobalTxt[163] = StrColor(0, 127, 255, "Personality")
    Game.GlobalTxt[75] = StrColor(0, 255, 0, "Endurance")
    Game.GlobalTxt[1] = StrColor(250, 250, 0, "Accuracy")
    Game.GlobalTxt[211] = StrColor(127, 0, 255, "Speed")
    Game.GlobalTxt[136] = StrColor(255, 255, 255, "Luck")
    Game.GlobalTxt[108] = StrColor(0, 255, 0, "Hit Points")
    Game.GlobalTxt[212] = StrColor(0, 100, 255, "Spell Points")
    Game.GlobalTxt[12] = StrColor(230, 204, 128, "Armor Class")

    Game.GlobalTxt[87] = StrColor(255, 70, 70, "Fire")
    Game.GlobalTxt[6] = StrColor(173, 216, 230, "Air")
    Game.GlobalTxt[240] = StrColor(100, 180, 255, "Water")
    Game.GlobalTxt[70] = StrColor(153, 76, 0, "Earth")
    Game.GlobalTxt[142] = StrColor(200, 200, 255, "Mind")
    Game.GlobalTxt[29] = StrColor(255, 192, 203, "Body")

end

function events.LoadMap()
    --init combat stats if they are not yet filled
    vars.damagemeter = vars.damagemeter or {} -- overall game stats
    vars.damagemeter1 = vars.damagemeter1 or {} -- current segment stats
    mapvars.damagemeter = mapvars.damagemeter or {} -- current map stats
    vars.timestamps = vars.timestamps or {} -- last actions timestamps
    for i = 0, Party.High do
        vars.timestamps[i] = vars.timestamps[i] or {
        LastTimeStamp = 0,
        LastTimeStamp_Melee = 0,
        LastTimeStamp_Ranged = 0,
        LastTimeStamp_Spell = 0,
        SegmentStart = Game.Time
        }

        vars.damagemeter[i] = vars.damagemeter[i] or {  
        Damage = 0,       ActiveTime = 1,      
        Damage_Melee = 0, ActiveTime_Melee = 1, 
        Damage_Ranged = 0,ActiveTime_Ranged = 1,
        Damage_Spell = 0, ActiveTime_Spell = 1, 
        }
        vars.damagemeter1[i] = vars.damagemeter1[i] or {
        Damage = 0, ActiveTime = 1,
        Damage_Melee = 0, ActiveTime_Melee = 1, 
        Damage_Ranged = 0,ActiveTime_Ranged = 1,
        Damage_Spell = 0, ActiveTime_Spell = 1, 
        }
        mapvars.damagemeter[i] = mapvars.damagemeter[i] or {
        Damage = 0, ActiveTime = 1,
        Damage_Melee = 0, ActiveTime_Melee = 1, 
        Damage_Ranged = 0,ActiveTime_Ranged = 1,
        Damage_Spell = 0, ActiveTime_Spell = 1,
        }
    end

end

function events.Tick()
    if Game.CurrentCharScreen == 100 and Game.CurrentScreen == 7 then
        local pl = Party[Game.CurrentPlayer]
        local lvl = pl:GetLevel()
        local AC = pl:GetArmorClass()
        local fullHP = pl:GetFullHP()
        local HP = pl.HP
        
        local might = pl:GetMight()
        local intel = pl:GetIntellect()
        local pers = pl:GetPersonality()
        local endu = pl:GetEndurance()
        local acc = pl:GetAccuracy()
        local speed = pl:GetSpeed()
        local luck = pl:GetLuck()

        -- Stats modifiers
        local addind = string.find(Game.StatsDescriptions[0], '\n')

        if addind then
            Game.StatsDescriptions[0] = string.format("%s\n ToDamage modifier: %d, next limit: %s", string.sub(Game.StatsDescriptions[0], 1, string.find(Game.StatsDescriptions[0], '\n')), Stat2Modifier(might))
            Game.StatsDescriptions[1] = string.format("%s\n Intellect modifier: %d, next limit: %s", string.sub(Game.StatsDescriptions[1], 1, string.find(Game.StatsDescriptions[1], '\n')), Stat2Modifier(intel))
            Game.StatsDescriptions[2] = string.format("%s\n Personality modifier: %d, next limit: %s", string.sub(Game.StatsDescriptions[2], 1, string.find(Game.StatsDescriptions[2], '\n')), Stat2Modifier(pers))
            Game.StatsDescriptions[3] = string.format("%s\n Health modifier: %d, next limit: %s", string.sub(Game.StatsDescriptions[3], 1, string.find(Game.StatsDescriptions[3], '\n')), Stat2Modifier(endu))
            Game.StatsDescriptions[4] = string.format("%s\n ToHit modifier: %d, next limit: %s", string.sub(Game.StatsDescriptions[4], 1, string.find(Game.StatsDescriptions[4], '\n')), Stat2Modifier(acc))
            Game.StatsDescriptions[5] = string.format("%s\n AC and Recovery modifier: %d, next limit: %s", string.sub(Game.StatsDescriptions[5], 1, string.find(Game.StatsDescriptions[5], '\n')), Stat2Modifier(speed))
            Game.StatsDescriptions[6] = string.format("%s\n Resistances modifier: %d, next limit: %s", string.sub(Game.StatsDescriptions[6], 1, string.find(Game.StatsDescriptions[6], '\n')), Stat2Modifier(luck))
        else
            Game.StatsDescriptions[0] = string.format("%s\n ToDamage modifier: %d, next limit: %s", Game.StatsDescriptions[0], Stat2Modifier(might))
            Game.StatsDescriptions[1] = string.format("%s\n Intellect modifier: %d, next limit: %s", Game.StatsDescriptions[1], Stat2Modifier(intel))
            Game.StatsDescriptions[2] = string.format("%s\n Personality modifier: %d, next limit: %s", Game.StatsDescriptions[2], Stat2Modifier(pers))
            Game.StatsDescriptions[3] = string.format("%s\n Health modifier: %d, next limit: %s", Game.StatsDescriptions[3], Stat2Modifier(endu))
            Game.StatsDescriptions[4] = string.format("%s\n ToHit modifier: %d, next limit: %s", Game.StatsDescriptions[4], Stat2Modifier(acc))
            Game.StatsDescriptions[5] = string.format("%s\n AC and Recovery modifier: %s, next limit: %d", Game.StatsDescriptions[5], Stat2Modifier(speed))
            Game.StatsDescriptions[6] = string.format("%s\n Resistances modifier: %d, next limit:                  %s", Game.StatsDescriptions[6], Stat2Modifier(luck))
        end

        -- Resistances
        FireRes = pl:GetResistance(10)
        AirRes = pl:GetResistance(11)
        WaterRes = pl:GetResistance(12)
        EarthRes = pl:GetResistance(13)
        MindRes = pl:GetResistance(14)
        BodyRes = pl:GetResistance(15)

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
            ResistancesPerc[i] = 100 - math.round(1000 * (1 - p) + 500 * (1 - p) * p + 250 * (1 - p) * p ^ 2 + 125 * (1 - p) * p ^ 3 + 62.5 * p ^ 4) / 10;
            R0[i] = (1 - p) + .5 * (1 - p) * p + .25 * (1 - p) * p ^ 2 + .125 * (1 - p) * p ^ 3 + .625 * p ^ 4;
        end

        Game.GlobalTxt[87] = StrColor(255, 70, 70, string.format("Fire\t            %s%%", ResistancesPerc[10]))
        Game.GlobalTxt[6] = StrColor(173, 216, 230, string.format("Air\t            %s%s ", ResistancesPerc[11], "%"))
        Game.GlobalTxt[240] = StrColor(100, 180, 255, string.format("Water\t            %s%s ", ResistancesPerc[12], "%"))
        Game.GlobalTxt[70] = StrColor(153, 76, 0, string.format("Earth\t            %s%s ", ResistancesPerc[13], "%"))
        Game.GlobalTxt[142] = StrColor(200, 200, 255, string.format("Mind\t            %s%s ", ResistancesPerc[14], "%"))
        Game.GlobalTxt[29] = StrColor(255, 192, 203, string.format("Body\t            %s%s ", ResistancesPerc[15], "%"))

        -- Effective HP
        local monster_hit_chance = (5 + lvl*2)/(10 + lvl*2 + AC) -- Monster level assumed to be equal player lvl

        local coeff = CheckPlateChain(pl)

        local avoidance = coeff * monster_hit_chance * EffectiveHitPointsWeights.Phys + R0[10]*EffectiveHitPointsWeights.Fire + R0[11]*EffectiveHitPointsWeights.Air + R0[12]*EffectiveHitPointsWeights.Water + R0[13]*EffectiveHitPointsWeights.Earth + R0[14]*EffectiveHitPointsWeights.Mind + R0[15]*EffectiveHitPointsWeights.Body
        local vitality = math.round(fullHP/avoidance)
        -- local hpstr = HP 
        -- if HP<fullHP then
        --     hpstr = StrColor(250, 250, 100, HP)     
        -- end
        --hpstr = hpstr .. "/" .. fullHP .. "," .. StrColor(0, 250, 0, vitality)
        --local HP_txt = StrColor(0, 255, 0, "HP,Vit ") .. string.format("%s/%s,%s\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n", hpstr,fullHP, StrColor(0, 250, 0, vitality))
        --local HP_txt = StrColor(0, 255, 0, "HP,Vit ") .. string.format("%s\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n", hpstr)
        --local acstr =  AC .. ', ' .. math.round(1000*(1-monster_hit_chance))/10
        --local AC_txt = StrColor(230, 204, 128, "AC/Miss% ") .. string.format("%s/%s%%\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n",AC,math.round(1000*(1-monster_hit_chance))/10)
        --local AC_txt = StrColor(230, 204, 128, "AC, Miss% ") .. string.format("%s%%\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n",acstr)
        --Game.GlobalTxt[108] = HP_txt
        --Game.GlobalTxt[12] = AC_txt

        -- Attack and DPS calculations	
        local atk_m = pl:GetMeleeAttack()
        local dmg_m = (pl:GetMeleeDamageMin() + pl:GetMeleeDamageMax()) / 2
        local delay_m = pl:GetAttackDelay()
        local hitchance_m = (15 + atk_m * 2) / (30 + atk_m * 2 + lvl)  --monster AC treated equal to Player Lvl

        local atk_r = pl:GetRangedAttack()
        local dmg_r = (pl:GetRangedDamageMin() + pl:GetRangedDamageMax()) / 2
        local delay_r = pl:GetAttackDelay(true)
        local hitchance_r = (15 + atk_r * 2) / (30 + atk_r * 2 + lvl)

        dmg_m = dmg_m + DaggerTriple(pl) -- Account Dagger master for chance to triple base weapon dmg

        -- Weapons element damage
        local slot = pl.ItemMainHand
        local it0 = (slot ~= 0 and pl.Items[slot])
        local slot = pl.ItemExtraHand
        local it1 = (slot ~= 0 and pl.Items[slot])
        local slot = pl.ItemBow
        local it2 = (slot ~= 0 and pl.Items[slot])

        local elem_m = 0
        local elem_r = 0
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

        local dps_m = (dmg_m + elem_m) * hitchance_m / (delay_m / 60)
        local dps_r = (dmg_r + elem_r) * hitchance_r / (delay_r / 60)

        --local dps_m_txt = string.format("Melee:Hit %s%%,DPS %s\n\n\n\n\n\n\n\n\n\n\n\n\n\n", StrColor(255, 0, 0, math.round(100 * hitchance_m)), StrColor(255, 50, 50, math.round(dps_m * 10) / 10))
        --local dps_r_txt = string.format("Range:Hit %s%%,DPS %s\n\n\n\n\n\n\n\n\n\n\n\n\n\n", StrColor(255, 0, 0, math.round(100 * hitchance_r)), StrColor(255, 50, 50, math.round(dps_r * 10) / 10))
        
        Game.GlobalTxt[47] = string.format("M/R DPS: %s/%s\n\n\n\n\n\n\n\n\n\n\n\n\n\n", StrColor(255, 0, 0, math.round(dps_m * 10) / 10), StrColor(255, 255, 50, math.round(dps_r * 10) / 10))
        Game.GlobalTxt[172] = string.format("Vit:%s Avoid:%s%%\n\n\n\n\n\n\n\n\n\n\n\n\n\n", StrColor(0, 255, 0, vitality),  StrColor(230, 204, 128,math.round(1000*(1-monster_hit_chance))/10))

        if Keys.IsPressed(const.Keys.ALT) then
            Game.GlobalTxt2[41] = "Full stats since game beginning\n" .. DamageMeterCalculation(vars.damagemeter)
            Game.GlobalTxt2[42] = Game.GlobalTxt2[41]
        else 

        local gameminutes = math.floor((Game.Time - vars.timestamps[0].SegmentStart)/const.Minute)    
        Game.GlobalTxt2[41] = string.format("Segment data (%s game minutes since [r]eset)\n",gameminutes) .. DamageMeterCalculation(vars.damagemeter1)
        Game.GlobalTxt2[42] = string.format("Current map: %s, [ALT] for full\n",Game.MapStats[Game.Map.MapStatsIndex].Name).. DamageMeterCalculation(mapvars.damagemeter)            
        end
        textsupdated = true

    elseif textsupdated and (Game.CurrentCharScreen ~= 100 or Game.CurrentScreen ~= 7) then
        Game.GlobalTxt[87] = StrColor(255, 70, 70, "Fire")
        Game.GlobalTxt[6] = StrColor(173, 216, 230, "Air")
        Game.GlobalTxt[240] = StrColor(100, 180, 255, "Water")
        Game.GlobalTxt[70] = StrColor(153, 76, 0, "Earth")
        Game.GlobalTxt[142] = StrColor(200, 200, 255, "Mind")
        Game.GlobalTxt[29] = StrColor(255, 192, 203, "Body")
        textsupdated = false
    end
    if Game.CurrentCharScreen == 101 and Game.CurrentScreen == 7 and SkillTooltipsEnabled then
        local pl = Party[Game.CurrentPlayer]
        local msg = StrColor(255, 255, 0,string.format("\nTotal Skill:%d, Map Reqired: %d",pl:GetDisarmTrapTotalSkill(),2*Game.MapStats[Game.Map.MapStatsIndex].Lock))
        local addind = string.find(Game.GlobalTxt2[29], '\n')        
        if addind then
            Game.GlobalTxt2[29] = string.sub(Game.GlobalTxt2[29], 1, string.find(Game.GlobalTxt2[29], '\n')) .. msg            
        else
            Game.GlobalTxt2[29] = Game.GlobalTxt2[29] .. msg           
        end
        local msg = StrColor(255, 255, 0,string.format("\nTotal merchant discount:%d",pl:GetMerchantTotalSkill()))
        local addind = string.find(Game.GlobalTxt2[22], '\n')        
        if addind then
            Game.GlobalTxt2[22] = string.sub(Game.GlobalTxt2[22], 1, string.find(Game.GlobalTxt2[22], '\n')) .. msg            
        else
            Game.GlobalTxt2[22] = Game.GlobalTxt2[22] .. msg           
        end
    end
end

function DamageMeterCalculation(V,mode)
    V = V or {}
    local out = ""
    local party_damage = 0
    local party_damage_m = 0
    local party_damage_r = 0
    local party_damage_s = 0

    local player_dps_m = {[0]=0,[1]=0,[2]=0,[3]=0}
    local player_dps_r = {[0]=0,[1]=0,[2]=0,[3]=0}
    local player_dps_s = {[0]=0,[1]=0,[2]=0,[3]=0}
    local player_dps   = {[0]=0,[1]=0,[2]=0,[3]=0}


    
    for i = 0, Party.High do
        player_dps[i]   = math.round(const.RTSecond * 10*V[i].Damage / V[i].ActiveTime)/10
        player_dps_m[i] = math.round(const.RTSecond * 10*V[i].Damage_Melee / V[i].ActiveTime_Melee)/10
        player_dps_r[i] = math.round(const.RTSecond * 10*V[i].Damage_Ranged / V[i].ActiveTime_Ranged)/10
        player_dps_s[i] = math.round(const.RTSecond * 10*V[i].Damage_Spell / V[i].ActiveTime_Spell)/10

        party_damage   = party_damage   + V[i].Damage
        party_damage_m = party_damage_m + V[i].Damage_Melee
        party_damage_r = party_damage_r + V[i].Damage_Ranged
        party_damage_s = party_damage_s + V[i].Damage_Spell
    end

	if not(mode) then
    out = out .. "\nDamage done (% to party's total)"
    out = out..StrColor(50, 255, 255,string.format("\nClass\t%11s%-9.9s\t%24s%-9.9s\t%37s%-9.9s\t%50s%-9.9s",'|',Game.ClassNames[Party[0].Class],'|',Game.ClassNames[Party[1].Class], '|',Game.ClassNames[Party[2].Class], '|',Game.ClassNames[Party[3].Class]))
    out = out..string.format("\nMelee\t%11s%5s%%\t%24s%5s%%\t%37s%5s%%\t%50s%5s%%",'|',math.round(1000 * V[0].Damage_Melee /party_damage_m)/10,'|',math.round(1000 * V[1].Damage_Melee /party_damage_m)/10, '|',math.round(1000 * V[2].Damage_Melee /party_damage_m)/10, '|',math.round(1000 * V[3].Damage_Melee /party_damage_m)/10)
    out = out..string.format("\nRange\t%11s%5s%%\t%24s%5s%%\t%37s%5s%%\t%50s%5s%%",'|',math.round(1000 * V[0].Damage_Ranged/party_damage_r)/10,'|',math.round(1000 * V[1].Damage_Ranged/party_damage_r)/10, '|',math.round(1000 * V[2].Damage_Ranged/party_damage_r)/10, '|',math.round(1000 * V[3].Damage_Ranged/party_damage_r)/10)
    out = out..string.format("\nSpell\t%11s%5s%%\t%24s%5s%%\t%37s%5s%%\t%50s%5s%%",'|',math.round(1000 * V[0].Damage_Spell /party_damage_s)/10,'|',math.round(1000 * V[1].Damage_Spell /party_damage_s)/10, '|',math.round(1000 * V[2].Damage_Spell /party_damage_s)/10, '|',math.round(1000 * V[3].Damage_Spell /party_damage_s)/10)
    out = out .. StrColor(255, 100, 100,string.format("\nTotal\t%11s %4s%%\t%24s %4s%%\t%37s %4s%%\t%50s %4s%%",'|',math.round(1000*V[0].Damage/party_damage)/10,'|',math.round(1000*V[1].Damage/party_damage)/10,'|',math.round(1000*V[2].Damage/party_damage)/10,'|',math.round(1000 * V[3].Damage/ party_damage)/10))
    out = out .. StrColor(255, 255, 255,string.format("\n\nParty DMG, M/R/S: %s%% / %s%% / %s%%",math.round(100*party_damage_m/party_damage ),math.round(100*party_damage_r/party_damage ),math.round(100*party_damage_s/party_damage)))
    out = out .. "\n\nDPS (damage per real second)"
    out = out..string.format("\nMelee\t%11s%5s\t%24s%5s\t%37s%5s\t%50s%5s",'|',player_dps_m[0],'|',player_dps_m[1], '|',player_dps_m[2], '|',player_dps_m[3])
    out = out..string.format("\nRange\t%11s%5s\t%24s%5s\t%37s%5s\t%50s%5s",'|',player_dps_r[0],'|',player_dps_r[1], '|',player_dps_r[2], '|',player_dps_r[3])
    out = out..string.format("\nSpell\t%11s%5s\t%24s%5s\t%37s%5s\t%50s%5s",'|',player_dps_s[0],'|',player_dps_s[1], '|',player_dps_s[2], '|',player_dps_s[3])
    out = out .. StrColor(255, 100, 100,string.format("\nTotal\t%11s%5s\t%24s%5s\t%37s%5s\t%50s%5s",'|',player_dps[0],'|',player_dps[1], '|',player_dps[2], '|',player_dps[3]))
    out = out .. StrColor(255, 255, 255,string.format("\n\nParty DPS, M/R/S/Tot: %s / %s / %s / %s",player_dps_m[0]+player_dps_m[1]+player_dps_m[2]+player_dps_m[3],player_dps_r[0]+player_dps_r[1]+player_dps_r[2]+player_dps_r[3],player_dps_s[0]+player_dps_s[1]+player_dps_s[2]+player_dps_s[3],player_dps[0]+player_dps[1]+player_dps[2]+player_dps[3]))
    else
	-- Output to file preparation
	local z = CombatLogSeparator
	out = out..string.format("Stat\\Class%s%s(%s)%s%s(%s)%s%s(%s)%s%s(%s)\n",z,Game.ClassNames[Party[0].Class],Party[0]:GetLevel(),z,Game.ClassNames[Party[1].Class],Party[1]:GetLevel(), z,Game.ClassNames[Party[2].Class],Party[2]:GetLevel(), z,Game.ClassNames[Party[3].Class],Party[3]:GetLevel())
    out = out..string.format("Melee DPS%s%s%s%s%s%s%s%s\n",z,player_dps_m[0],z,player_dps_m[1], z,player_dps_m[2], z,player_dps_m[3])
	out = out..string.format("RangedDPS%s%s%s%s%s%s%s%s\n",z,player_dps_r[0],z,player_dps_r[1], z,player_dps_r[2], z,player_dps_r[3])
	out = out..string.format("Spell DPS%s%s%s%s%s%s%s%s\n",z,player_dps_s[0],z,player_dps_s[1], z,player_dps_s[2], z,player_dps_s[3])
	out = out..string.format("Total DPS%s%s%s%s%s%s%s%s\n",z,player_dps[0],z,player_dps[1], z,player_dps[2], z,player_dps[3])
        
    out = out..string.format("Melee %%%%%s%s%s%s%s%s%s%s\n",z,math.round(1000 * V[0].Damage_Melee /party_damage_m)/10,z,math.round(1000 * V[1].Damage_Melee /party_damage_m)/10, z,math.round(1000 * V[2].Damage_Melee /party_damage_m)/10, z,math.round(1000 * V[3].Damage_Melee /party_damage_m)/10)
    out = out..string.format("Ranged%%%%%s%s%s%s%s%s%s%s\n",z,math.round(1000 * V[0].Damage_Ranged /party_damage_r)/10,z,math.round(1000 * V[1].Damage_Ranged /party_damage_r)/10, z,math.round(1000 * V[2].Damage_Ranged /party_damage_r)/10, z,math.round(1000 * V[3].Damage_Ranged /party_damage_r)/10)
	out = out..string.format("Spell %%%%%s%s%s%s%s%s%s%s\n",z,math.round(1000 * V[0].Damage_Spell /party_damage_s)/10,z,math.round(1000 * V[1].Damage_Spell /party_damage_s)/10, z,math.round(1000 * V[2].Damage_Spell /party_damage_s)/10, z,math.round(1000 * V[3].Damage_Spell /party_damage_s)/10)
	out = out..string.format("Total %%%%%s%s%s%s%s%s%s%s\n",z,math.round(1000 * V[0].Damage /party_damage)/10,z,math.round(1000 * V[1].Damage /party_damage)/10, z,math.round(1000 * V[2].Damage /party_damage)/10, z,math.round(1000 * V[3].Damage /party_damage)/10)
    
	out = out..string.format("Melee Dmg%s%s%s%s%s%s%s%s\n",z,V[0].Damage_Melee,z,V[1].Damage_Melee, z,V[2].Damage_Melee, z,V[3].Damage_Melee)
    out = out..string.format("RangedDmg%s%s%s%s%s%s%s%s\n",z,V[0].Damage_Ranged,z,V[1].Damage_Ranged, z,V[2].Damage_Ranged, z,V[3].Damage_Ranged)
	out = out..string.format("Spell Dmg%s%s%s%s%s%s%s%s\n",z,V[0].Damage_Spell,z,V[1].Damage_Spell, z,V[2].Damage_Spell, z,V[3].Damage_Spell)
	out = out..string.format("Total Dmg%s%s%s%s%s%s%s%s\n",z,V[0].Damage,z,V[1].Damage, z,V[2].Damage, z,V[3].Damage)
	
	out = out..string.format("ActiveTime%s%s%s%s%s%s%s%s\n",z,math.round(V[0].ActiveTime/const.RTSecond),z,math.round(V[1].ActiveTime/const.RTSecond), z,math.round(V[2].ActiveTime/const.RTSecond), z,math.round(V[3].ActiveTime/const.RTSecond))
    
    	
	end

    return out
end

function DamageTypeParsing(O)
    local objmsg
    if not(O) then
        objmsg = 'hit'
    elseif O.Missile then
        objmsg = 'shoot' --.Spells Shoot = 100,ShootFire = 101,ShootBlaster = 102,
    else
        objmsg = get_key_for_value(const.Spells, O.Spell) .."_" .. O.SpellSkill .. const.Mastery[O.SpellMastery] --get_key_for_value(const.Mastery, O.SpellMastery)
    end
 
    return objmsg
end

function Stat2Modifier(stat)
    local StatsLimitValues = {0, 3, 5, 7, 9, 11, 13, 15, 17, 19, 21, 25, 30, 35, 40, 50, 75, 100, 125, 150, 175, 200, 225, 250, 275, 300, 350, 400, 500}
    local StatsEffectsValues = {-6, -5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 25, 30}
    local found
    local next
    for i1 = #StatsLimitValues, 1, -1 do
        if StatsLimitValues[i1] <= stat then
            found = StatsEffectsValues[i1]
            next = StatsLimitValues[i1+1]
            break
        end
    end
    next = next or "Max"
    return found, next
end

function StrColor(r, g, b, s)
    return ('\f%.5d'):format(b and RGB(r, g, b) or r) .. ((s or not b and g) and (s or g) .. StrColor(0) or '')
end

function RGB(r, g, b)
    return r:And(248) * 256 + g:And(252) * 8 + math.floor(b / 8)
end

function get_key_for_value(t, value)
    for k, v in pairs(t) do
        if v == value then
            return k
        end
    end
    return nil
end
function ptable(vars)
for k,v in pairs(vars) do
    print(k,v)
end
end

function CheckPlateChain(pl)
local coeff = 1
local s,mplate = SplitSkill(pl:GetSkill(const.Skills.Plate))
local s,mchain = SplitSkill(pl:GetSkill(const.Skills.Chain))
local equippedarmor = 0

if pl.ItemArmor>0 then equippedarmor = pl.Items[pl.ItemArmor]:T().Skill end

if mplate>=3 and equippedarmor==11 then -- Plate mastery
    coeff = 0.5
elseif mchain==4 and equippedarmor==10 then --chain GM
    coeff = 2/3
end
return coeff
end

function DaggerTriple(pl)
    local extradamage = 0
    local sdagger,mdagger = SplitSkill(pl:GetSkill(const.Skills.Dagger))
    if mdagger>=3 then--master or GM
        if pl.ItemMainHand>0 then mh = pl.Items[pl.ItemMainHand] end
        -- 10% chance for triple base damage (double extra base)
        if mh:T().Skill ==  const.Skills.Dagger then
            extradamage = sdagger / 100 * 2 * (mh:T().Mod2 + (mh:T().Mod1DiceCount + mh:T().Mod1DiceCount * mh:T().Mod1DiceSides)/2)
        end

        if pl.ItemExtraHand > 0 then eh = pl.Items[pl.ItemExtraHand] end

        if eh:T().Skill ==  const.Skills.Dagger then
            extradamage = extradamage + sdagger / 100 * 2 * (eh:T().Mod2 + (eh:T().Mod1DiceCount + eh:T().Mod1DiceCount * eh:T().Mod1DiceSides)/2)
        end
        
    end
    return extradamage
end

-- function events.Action(t)
-- 		Game.ShowStatusText("t.Action" .. t.Action)
-- end

-- > a:GetMeleeDamageMin() > a:GetMeleeDamageMax()

-- file = io.open("test.txt", "w")
-- for i=1,400 do
-- 	file:write(string.format("%d - %s\n",i,Game.GlobalTxt[i]))
-- end
-- file:close()
-- 587 - Attack Bonus
-- 588 - Attack Damage
-- 589 - Shoot Bonus
-- 590 - Shoot Damage
-- Game.GlobalTxt[47]="Condition"
-- Game.GlobalTxt[172]="Quick Spell"

-- for k,v in pairs(tab) do
-- print(k)
-- end
--Party[Game.CurrentPlayer].MightBase
--mainhand = Party[Game.CurrentPlayer].Items[Party[Game.CurrentPlayer].ItemMainHand]