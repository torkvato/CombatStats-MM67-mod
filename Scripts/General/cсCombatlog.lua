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

            if t.Result>vars.Max.Dmg then vars.Max.Dmg = t.Result vars.Max.Player = i end
            if t.Result>vars.Max1.Dmg then vars.Max1.Dmg = t.Result vars.Max1.Player = i end
            if t.Result>mapvars.Max.Dmg then mapvars.Max.Dmg = t.Result mapvars.Max.Player = i end

            objmsg = DamageTypeParsing(data.Object)

            if CombatLogEnabled>0 then
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

function events.CalcDamageToPlayer(t)
    --Damage,DamageKind,Player,PlayerIndex,Result
    if t.Damage > 0 then        
        local data = WhoHitPlayer()
        if data and data.Player then
            -- If a player is being attacked, returns t, PlayerSlot.
            -- t.Monster, t.MonsterIndex and t.MonsterAction fields are set if player is attacked by a monster.
            -- t.Object and t.ObjectIndex are set if player is hit by a missile.
            -- t.Spell, t.SpellSkill and t.SpellMastery are set if a spell is being used.
            -- Note that t.Object and t.Monster can be set at the same time if the projectile was fired by a monster. 

            --if t.Monster.NameId > 0 then monName = Game.PlaceMonTxt[t.Monster.NameId]  else monName = Game.MonstersTxt[t.Monster.Id].Name end
            
           --objmsg = DamageTypeParsing(data.Object)

            if CombatLogEnabled==2 then
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

function events.LoadMap()
    --init combat stats if they are not yet filled
    vars.damagemeter = vars.damagemeter or {} -- overall game stats
    vars.MaxDmg = vars.MaxDmg or 0
    vars.Max = vars.Max or {Dmg = 0, Player = 0}
    vars.Max1 = vars.Max1 or {Dmg = 0, Player = 0}
    mapvars.Max = mapvars.Max or {Dmg = 0, Player = 0}

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
        MaxDmg = 0, MaxDmgPlayer = 0,
        }
        mapvars.damagemeter[i] = mapvars.damagemeter[i] or {
        Damage = 0, ActiveTime = 1,
        Damage_Melee = 0, ActiveTime_Melee = 1, 
        Damage_Ranged = 0,ActiveTime_Ranged = 1,
        Damage_Spell = 0, ActiveTime_Spell = 1,
        MaxDmg = 0, MaxDmgPlayer = 0,
        }
    end

end