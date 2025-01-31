-- Segment stats reset and export
function events.KeyDown(t)
    if Game.CurrentScreen == const.Screens.Inventory and Game.CurrentCharScreen == const.CharScreens.Stats then
        if t.Key == DamageMeterResetButton then -- "r" key
            Game.ShowStatusText(string.format("Segment data reset, press Y to continue reset"))
            segment_data_reset_confirmation = 1;
        end
        if t.Key == DamageMeterExportButton then -- "e" key
            Game.ShowStatusText(string.format("Damage and DPS data export, press Y to continue..."))
            data_export_confirmation = 1;
        end

        if (t.Key ~= const.Keys.Y) and (t.Key ~= DamageMeterResetButton) and (segment_data_reset_confirmation == 1) then -- not "y" key
            segment_data_reset_confirmation = 0; -- aborting reset without confirmation
        end

        if (t.Key ~= const.Keys.Y) and (t.Key ~= DamageMeterExportButton) and (data_export_confirmation == 1) then -- not "y" key
            data_export_confirmation = 0; -- aborting export without confirmation
        end

        if t.Key == const.Keys.Y and (segment_data_reset_confirmation == 1) then -- "y" key
            Game.ShowStatusText(string.format("Segment data reset."))
            segment_data_reset_confirmation = 0;
            local i
            for i = 0, Party.High do
                vars.damagemeter1[i]={Damage = 0, Damage_Melee = 0, Damage_Ranged = 0, Damage_Spell = 0,Damage_Received=0, ActiveTime = 1, ActiveTime_Melee = 1, ActiveTime_Ranged = 1,ActiveTime_Spell = 1}
                vars.timestamps[i].SegmentStart = Game.Time          
            end
            vars.Max1 = {Melee = {Dmg = 0, Player = 0}, Ranged = {Dmg = 0, Player = 0}, Spell = {Dmg = 0, Player = 0}} 
        end
        if t.Key == const.Keys.Y and (data_export_confirmation == 1) then -- "y" key
			Game.ShowStatusText(string.format("Exporting stats data to file: %s",StatsOutputFile))
            data_export_confirmation = 0; 
			
			file = io.open(StatsOutputFile,"a")
			
			file:write(string.format("Data exported: %s/%s/%s at %s:%s (%s)",Game.Year,Game.Month,Game.DayOfMonth,Game.Hour,Game.Minute, os.date("%Y/%m/%d %H:%M")) )
			file:write(string.format("\nSegment: %s game min. since reset\n",GameTimePassed()) .. DamageMeterCalculation(vars.damagemeter1,1))
			file:write(string.format("\nCurrent map data: %s\n",Game.MapStats[Game.Map.MapStatsIndex].Name) .. DamageMeterCalculation(mapvars.damagemeter,1))
			file:write(string.format("\nFull game data\n") .. DamageMeterCalculation(vars.damagemeter,1))
			file:write("\n")
       
			file:close()			
        end
    end

	if Game.CurrentScreen == const.Screens.Game and t.Key == MiniLogButton and not(Keys.IsPressed(const.Keys.ALT)) then

	Message(MinilogText())

	end


end
-- Combat logging
function events.CalcDamageToMonster(t)
    if t.Result > 0 then
        -- t.Damage : damage BEFORE monster resistances, t.Result : final damage after monster resistances, mapvars - map
        local data = WhoHitMonster()

        --if data.Player:GetIndex() > 0 then return end -- only one player logged

        if data and data.Player then

            i = data.Player:GetIndex()

            if t.Monster.NameId > 0 then monName = Game.PlaceMonTxt[t.Monster.NameId]  else monName = Game.MonstersTxt[t.Monster.Id].Name end
            monName = string.format("%s(%s)",monName,t.Monster.Level)
            -- DPS is calculated as total damage done, divided by total active time in real seconds
            -- In-game time: 2 real seconds equal 1 in-game minute, 1 real second = 30 in-game seconds
            -- 256 "Game.time" ticks = 1 in-game minute, (const.Minute = 256)
            -- 128 "Game.time" ticks = 30 in-game seconds = 1 real second (const.RTSecond = 128)
            -- 60 "weapon recovery" = 1 real second  = 30 in-game seconds = 128 ticks
            -- One turn-based round = 100 "weapon recovery" = 50 game seconds = 46.8750 Game.time ticks (!)
            -- Party[pl].RecoveryDelay = "recovery"/2.133333 = measured in Game.time ticks
            -- 1s = 60r = 128gt = 30gs;  r = 128/60*gt

            -- Active time - contuguous time when periods betwen successful hits less than 6 seconds
            local timedelta = Game.Time - vars.timestamps[i].LastTimeStamp;

            if timedelta < 6*const.RTSecond then
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

            -- Concatenate damage of different kinds with same timestamps
            local concatDmg=t.Result
			if timedelta==0 and (monName==vars.minilog[MinilogEntriesNumber].Mob) and (data.Player.Name==vars.minilog[MinilogEntriesNumber].Player) then	
				concatDmg = concatDmg + vars.minilog[MinilogEntriesNumber].Damage			
			end

            -- Update damage
            vars.damagemeter[i].Damage = vars.damagemeter[i].Damage + t.Result
            vars.damagemeter1[i].Damage = vars.damagemeter1[i].Damage + t.Result
            mapvars.damagemeter[i].Damage = mapvars.damagemeter[i].Damage + t.Result

            if not(data.Object) then
                vars.damagemeter[i].Damage_Melee = vars.damagemeter[i].Damage_Melee + t.Result
                vars.damagemeter1[i].Damage_Melee = vars.damagemeter1[i].Damage_Melee + t.Result
                mapvars.damagemeter[i].Damage_Melee = mapvars.damagemeter[i].Damage_Melee + t.Result
                CheckMax(concatDmg,i,1)
            elseif data.Object.Missile then
                vars.damagemeter[i].Damage_Ranged = vars.damagemeter[i].Damage_Ranged + t.Result
                vars.damagemeter1[i].Damage_Ranged = vars.damagemeter1[i].Damage_Ranged + t.Result
                mapvars.damagemeter[i].Damage_Ranged = mapvars.damagemeter[i].Damage_Ranged + t.Result
                CheckMax(concatDmg,i,2)
            else
                vars.damagemeter[i].Damage_Spell = vars.damagemeter[i].Damage_Spell + t.Result
                vars.damagemeter1[i].Damage_Spell = vars.damagemeter1[i].Damage_Spell + t.Result
                mapvars.damagemeter[i].Damage_Spell = mapvars.damagemeter[i].Damage_Spell + t.Result
                CheckMax(concatDmg,i,3)
            end

            objmsg = DamageTypeParsing(data)

			-- minilog update
			table.move(vars.minilog,1,#vars.minilog,1,vars.minilog)
			vars.minilog[MinilogEntriesNumber] = {Player = data.Player.Name, Hit = objmsg, Mob = monName, Damage = t.Result, Kind = get_key_for_value(const.Damage, t.DamageKind), Type = 0 }

            
            if t.Result>=t.Monster.HP then
                objmsg = objmsg .. CombatLogSeparator .. "killed"
            end

            if CombatLogEnabled>0 then
                local z = CombatLogSeparator
                playerid = string.format("%s%s%s(%s)%s%s", i, z, Game.ClassNames[data.Player.Class], data.Player:GetLevel(), z, data.Player.Name)
                -- Timestamp #Player Name(Lvl) TargetName Damage DamageKind DamageSource
                local msg = string.format("%s%s%s%s%s%s%s%s%s%s%s%s%s\n", Game.Time, z, playerid,  z,">>",z, monName, z, t.Result, z, get_key_for_value(const.Damage, t.DamageKind),z, objmsg)
                file = io.open(CombatLogFile, "a")
                file:write(msg)
                file:close()
            end
          

			
			
        end
    end
end

function events.CalcDamageToPlayer(t)
    --Damage,DamageKind,Player,PlayerIndex,Result
    if t.Result > 0 then        
        local data = WhoHitPlayer()
        if data then
            -- If a player is being attacked, returns t, PlayerSlot.
            -- t.Monster, t.MonsterIndex and t.MonsterAction fields are set if player is attacked by a monster.
            -- t.Object and t.ObjectIndex are set if player is hit by a missile.
            -- t.Spell, t.SpellSkill and t.SpellMastery are set if a spell is being used.
            -- Note that t.Object and t.Monster can be set at the same time if the projectile was fired by a monster. 

			if data.Monster then
				if data.Monster.NameId > 0 then monName = Game.PlaceMonTxt[data.Monster.NameId]  else monName = Game.MonstersTxt[data.Monster.Id].Name end
				monName = string.format("%s(%s)",monName,data.Monster.Level)
			elseif data.Player then
				monName = data.Player.Name
			else
				monName = "???"
			end
			
            objmsg = DamageTypeParsing(data)
			
			-- minilog update
			table.move(vars.minilog,1,#vars.minilog,1,vars.minilog)
			vars.minilog[MinilogEntriesNumber] = {Player = monName, Hit = objmsg, Mob = t.Player.Name, Damage = t.Result, Kind = get_key_for_value(const.Damage, t.DamageKind), Type = 1 }
			
            if t.Result>=t.Player.HP then
                objmsg = objmsg .. CombatLogSeparator .. "killed"
            end    

            vars.damagemeter[t.PlayerIndex].Damage_Received = vars.damagemeter[t.PlayerIndex].Damage_Received + t.Result
            vars.damagemeter1[t.PlayerIndex].Damage_Received = vars.damagemeter1[t.PlayerIndex].Damage_Received + t.Result
            mapvars.damagemeter[t.PlayerIndex].Damage_Received = mapvars.damagemeter[t.PlayerIndex].Damage_Received + t.Result

            if CombatLogEnabled==2 then
                local z = CombatLogSeparator
                playerid = string.format("%s%s%s(%s)%s%s", t.PlayerIndex, z, Game.ClassNames[t.Player.Class], t.Player:GetLevel(), z, t.Player.Name)
                -- Timestamp #Player Name(Lvl) TargetName Damage DamageKind DamageSource
                local msg = string.format("%s%s%s%s%s%s%s%s%s%s%s%s%s\n", Game.Time, z, playerid,  z, "<<",z,monName, z, t.Result, z, get_key_for_value(const.Damage, t.DamageKind),z, objmsg)
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
    out = out..string.format("\nMelee\t%11s%5s%%\t%24s%5s%%\t%37s%5s%%\t%50s%5s%%",'|',math.round(100 * V[0].Damage_Melee /party_damage_m),'|',math.round(100 * V[1].Damage_Melee /party_damage_m), '|',math.round(100 * V[2].Damage_Melee /party_damage_m), '|',math.round(100 * V[3].Damage_Melee /party_damage_m))
    out = out..string.format("\nRange\t%11s%5s%%\t%24s%5s%%\t%37s%5s%%\t%50s%5s%%",'|',math.round(100 * V[0].Damage_Ranged/party_damage_r),'|',math.round(100 * V[1].Damage_Ranged/party_damage_r), '|',math.round(100 * V[2].Damage_Ranged/party_damage_r), '|',math.round(100 * V[3].Damage_Ranged/party_damage_r))
    out = out..string.format("\nSpell\t%11s%5s%%\t%24s%5s%%\t%37s%5s%%\t%50s%5s%%",'|',math.round(100 * V[0].Damage_Spell /party_damage_s),'|',math.round(100 * V[1].Damage_Spell /party_damage_s), '|',math.round(100 * V[2].Damage_Spell /party_damage_s), '|',math.round(100 * V[3].Damage_Spell /party_damage_s))
    out = out .. StrColor(255, 100, 100,string.format("\nTotal\t%11s %4s%%\t%24s %4s%%\t%37s %4s%%\t%50s %4s%%",'|',math.round(100*V[0].Damage/party_damage),'|',math.round(100*V[1].Damage/party_damage),'|',math.round(100*V[2].Damage/party_damage),'|',math.round(100 * V[3].Damage/ party_damage)))
    out = out .. "\n\nDPS (damage per real second)"
    out = out..string.format("\nMelee\t%11s%5s\t%24s%5s\t%37s%5s\t%50s%5s",'|',player_dps_m[0],'|',player_dps_m[1], '|',player_dps_m[2], '|',player_dps_m[3])
    out = out..string.format("\nRange\t%11s%5s\t%24s%5s\t%37s%5s\t%50s%5s",'|',player_dps_r[0],'|',player_dps_r[1], '|',player_dps_r[2], '|',player_dps_r[3])
    out = out..string.format("\nSpell\t%11s%5s\t%24s%5s\t%37s%5s\t%50s%5s",'|',player_dps_s[0],'|',player_dps_s[1], '|',player_dps_s[2], '|',player_dps_s[3])
    out = out .. StrColor(255, 100, 100,string.format("\nTotal\t%11s%5s\t%24s%5s\t%37s%5s\t%50s%5s",'|',player_dps[0],'|',player_dps[1], '|',player_dps[2], '|',player_dps[3]))
    out = out .. StrColor(255, 255, 255,string.format("\n\nParty distribution, M/R/S: %s%% / %s%% / %s%%",math.round(100*party_damage_m/party_damage ),math.round(100*party_damage_r/party_damage ),math.round(100*party_damage_s/party_damage)))
    --out = out .. StrColor(255, 255, 255,string.format("\n\nParty DPS, M/R/S/Tot: %s / %s / %s / %s",player_dps_m[0]+player_dps_m[1]+player_dps_m[2]+player_dps_m[3],player_dps_r[0]+player_dps_r[1]+player_dps_r[2]+player_dps_r[3],player_dps_s[0]+player_dps_s[1]+player_dps_s[2]+player_dps_s[3],player_dps[0]+player_dps[1]+player_dps[2]+player_dps[3]))
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

    out = out..string.format("ReceivedDamage%s%s%s%s%s%s%s%s\n",z,V[0].Damage_Received,z,V[1].Damage_Received, z,V[2].Damage_Received, z,V[3].Damage_Received)
    out = out..string.format("ReceivedDPS%s%s%s%s%s%s%s%s\n",z,math.round(const.RTSecond * 10*V[0].Damage_Received/V[0].ActiveTime)/10,z,math.round(const.RTSecond * 10*V[1].Damage_Received/V[1].ActiveTime)/10, z,math.round(const.RTSecond * 10*V[2].Damage_Received/V[2].ActiveTime)/10, z,math.round(const.RTSecond * 10*V[3].Damage_Received/V[3].ActiveTime)/10)
    	
	end

    return out
end

function DamageTypeParsing(O)
    local objmsg
	if not(O.Object) then
		objmsg = 'hits'
	elseif O.Spell and not(O.Object.Missile) then
        objmsg = get_key_for_value(const.Spells, O.Spell) .. const.Mastery[O.SpellMastery] .. O.SpellSkill  --get_key_for_value(const.Mastery, O.SpellMastery)
    else
		objmsg = 'shoots' --.Spells Shoot = 100,ShootFire = 101,ShootBlaster = 102,        
    end   
    return objmsg
end

function CheckMax(concatDmg,i,mrs)
    if mrs==1 then --melee
        if concatDmg>vars.Max.Melee.Dmg then vars.Max.Melee.Dmg = concatDmg vars.Max.Melee.Player = i end
        if concatDmg>vars.Max1.Melee.Dmg then vars.Max1.Melee.Dmg = concatDmg vars.Max1.Melee.Player = i end
        if concatDmg>mapvars.Max.Melee.Dmg then mapvars.Max.Melee.Dmg = concatDmg mapvars.Max.Melee.Player = i end        
    elseif mrs==2 then --ranged
        if concatDmg>vars.Max.Ranged.Dmg then vars.Max.Ranged.Dmg = concatDmg vars.Max.Ranged.Player = i end
        if concatDmg>vars.Max1.Ranged.Dmg then vars.Max1.Ranged.Dmg = concatDmg vars.Max1.Ranged.Player = i end
        if concatDmg>mapvars.Max.Ranged.Dmg then mapvars.Max.Ranged.Dmg = concatDmg mapvars.Max.Ranged.Player = i end
    else --spell
        if concatDmg>vars.Max.Spell.Dmg then vars.Max.Spell.Dmg = concatDmg vars.Max.Spell.Player = i end
        if concatDmg>vars.Max1.Spell.Dmg then vars.Max1.Spell.Dmg = concatDmg vars.Max1.Spell.Player = i end
        if concatDmg>mapvars.Max.Spell.Dmg then mapvars.Max.Spell.Dmg = concatDmg mapvars.Max.Spell.Player = i end
    end
end    

function PartyRecordsTxt()
    local msg=StrColor(255, 100,100, "Record damage")
    msg = msg..StrColor(50, 255, 255,string.format("\nData\t%10sMelee\t%27sRanged\t%44sSpell",'|','|','|'))
    msg = msg .. string.format("\nMap \t%10s%s %s\t%27s%s %s\t%44s%s %s",'|',Party[mapvars.Max.Melee.Player].Name,mapvars.Max.Melee.Dmg,'|', Party[mapvars.Max.Ranged.Player].Name,mapvars.Max.Ranged.Dmg, '|', Party[mapvars.Max.Spell.Player].Name,mapvars.Max.Spell.Dmg)
    msg = msg .. string.format("\nSegm\t%10s%s %s\t%27s%s %s\t%44s%s %s",'|',Party[vars.Max1.Melee.Player].Name,vars.Max1.Melee.Dmg,'|', Party[vars.Max1.Ranged.Player].Name,vars.Max1.Ranged.Dmg, '|', Party[vars.Max1.Spell.Player].Name,vars.Max1.Spell.Dmg)
        msg = msg .. string.format("\nFull\t%10s%s %s\t%27s%s %s\t%44s%s %s",'|',Party[vars.Max.Melee.Player].Name,vars.Max.Melee.Dmg,'|', Party[vars.Max.Ranged.Player].Name,vars.Max.Ranged.Dmg, '|', Party[vars.Max.Spell.Player].Name,vars.Max.Spell.Dmg)

    local tsegm = vars.damagemeter1[0].Damage_Received + vars.damagemeter1[1].Damage_Received + vars.damagemeter1[2].Damage_Received + vars.damagemeter1[3].Damage_Received
    local tmap  = mapvars.damagemeter[0].Damage_Received + mapvars.damagemeter[1].Damage_Received + mapvars.damagemeter[2].Damage_Received + mapvars.damagemeter[3].Damage_Received
    local tfull = vars.damagemeter[0].Damage_Received + vars.damagemeter[1].Damage_Received + vars.damagemeter[2].Damage_Received + vars.damagemeter[3].Damage_Received
    
    msg = msg .. StrColor(255, 100,100, "\n\nDamage taken, Party %%")
    msg = msg..StrColor(50, 255, 255,string.format("\nData\t%10s%-9.9s\t%24s%-9.9s\t%37s%-9.9s\t%50s%-9.9s",'|',Game.ClassNames[Party[0].Class],'|',Game.ClassNames[Party[1].Class], '|',Game.ClassNames[Party[2].Class], '|',Game.ClassNames[Party[3].Class]))
    msg = msg..string.format("\nMap \t%10s%5s%%\t%24s%5s%%\t%37s%5s%%\t%50s%5s%%",'|',math.round(100*mapvars.damagemeter[0].Damage_Received/tmap),'|',math.round(100*mapvars.damagemeter[1].Damage_Received/tmap), '|',math.round(100*mapvars.damagemeter[2].Damage_Received/tmap), '|',math.round(100*mapvars.damagemeter[3].Damage_Received/tmap))
    msg = msg..string.format("\nSegm\t%10s%5s%%\t%24s%5s%%\t%37s%5s%%\t%50s%5s%%",'|',math.round(100*vars.damagemeter1[0].Damage_Received/tsegm),'|',math.round(100*vars.damagemeter1[1].Damage_Received/tsegm), '|',math.round(100*vars.damagemeter1[2].Damage_Received/tsegm), '|',math.round(100*vars.damagemeter1[3].Damage_Received/tsegm))
    msg = msg..string.format("\nFull\t%10s%5s%%\t%24s%5s%%\t%37s%5s%%\t%50s%5s%%",'|',math.round(100*vars.damagemeter[0].Damage_Received/tfull),'|',math.round(100*vars.damagemeter[1].Damage_Received/tfull), '|',math.round(100*vars.damagemeter[2].Damage_Received/tfull), '|',math.round(100*vars.damagemeter[3].Damage_Received/tfull))

    return msg
end

function MinilogText()
	local msg = ""
	local pl1 = ""
	local pl2 = ""
    local mob_db, pl_db

	for i=1, #vars.minilog do
	    local knd = StrColor(const.DamageColor[vars.minilog[i].Kind][1], const.DamageColor[vars.minilog[i].Kind][2], const.DamageColor[vars.minilog[i].Kind][3],  vars.minilog[i].Damage .. ' ' .. vars.minilog[i].Kind)
		mob_db = string.gsub(vars.minilog[i].Mob, "%s+", "")
        pl_db  = string.gsub(vars.minilog[i].Player, "%s+", "")
		if vars.minilog[i].Type==0 then
			pl1 = StrColor(135,245,135, pl_db)
			pl2 = StrColor(245,164,160, mob_db)
		else
			pl1 = StrColor(245,175,170, pl_db)
			pl2 = StrColor(140,245,140, mob_db)
		end		
		msg = msg .. string.format("%s %s %s %s\n", pl1, vars.minilog[i].Hit, pl2, knd)
	end
	return string.sub(msg,1,-2)
end

function events.LoadMap()
    --init combat stats if they are not yet filled
    vars.damagemeter = vars.damagemeter or {} -- overall game stats
	vars.damagemeter1 = vars.damagemeter1 or {} -- current segment stats
    mapvars.damagemeter = mapvars.damagemeter or {} -- current map stats
    
	vars.Max = vars.Max or {Melee = {Dmg = 0, Player = 0}, Ranged = {Dmg = 0, Player = 0}, Spell = {Dmg = 0, Player = 0}} -- max dmg per hit overall
    vars.Max1 = vars.Max1 or {Melee = {Dmg = 0, Player = 0}, Ranged = {Dmg = 0, Player = 0}, Spell = {Dmg = 0, Player = 0}} -- max dmg per hit overall
    mapvars.Max = mapvars.Max or {Melee = {Dmg = 0, Player = 0}, Ranged = {Dmg = 0, Player = 0}, Spell = {Dmg = 0, Player = 0}} -- max dmg per hit overall

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
        Damage_Received = 0,
        }
        vars.damagemeter1[i] = vars.damagemeter1[i] or {
        Damage = 0, ActiveTime = 1,
        Damage_Melee = 0, ActiveTime_Melee = 1, 
        Damage_Ranged = 0,ActiveTime_Ranged = 1,
        Damage_Spell = 0, ActiveTime_Spell = 1,         
        Damage_Received = 0,
        }
        mapvars.damagemeter[i] = mapvars.damagemeter[i] or {
        Damage = 0, ActiveTime = 1,
        Damage_Melee = 0, ActiveTime_Melee = 1, 
        Damage_Ranged = 0,ActiveTime_Ranged = 1,
        Damage_Spell = 0, ActiveTime_Spell = 1,
        Damage_Received = 0,
        }
    end

	vars.minilog = vars.minilog or {}
	for i = 1, MinilogEntriesNumber do
	vars.minilog[i] = vars.minilog[i] or {Player = "Nobody", Hit = "hits", Mob = "Me", Damage = 0, Kind = get_key_for_value(const.Damage, i%11), Type = 0}
	end

    --temp init for old tables compatibility
    for i = 0, Party.High do
        vars.damagemeter[i].Damage_Received = vars.damagemeter[i].Damage_Received or 0
        vars.damagemeter1[i].Damage_Received = vars.damagemeter1[i].Damage_Received or 0
        mapvars.damagemeter[i].Damage_Received = mapvars.damagemeter[i].Damage_Received or 0
    end


end
