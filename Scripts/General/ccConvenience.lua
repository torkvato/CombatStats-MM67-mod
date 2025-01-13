function events.Tick()
	    -- ID monster GM with Alt
		if Game.CurrentScreen == 0 and Keys.IsPressed(const.Keys.ALT) and Keys.IsPressed(const.Keys.RBUTTON) and not(id_monster_GM_set) and AltIdMonsterGM==1 then
			id_monster_GM_set = true
			last_id_moster_skill = Party[Game.CurrentPlayer].Skills[const.Skills.IdentifyMonster]
			Party[Game.CurrentPlayer].Skills[const.Skills.IdentifyMonster] = JoinSkill(10,const.GM)
		elseif Game.CurrentScreen == 0 and id_monster_GM_set and not(Keys.IsPressed(const.Keys.ALT)) then
			id_monster_GM_set = false
			Party[Game.CurrentPlayer].Skills[const.Skills.IdentifyMonster] = last_id_moster_skill
		end
	
		--Shared ID item
		if Game.CurrentScreen == 7  and Game.CurrentCharScreen == 103 and not(id_item_party) and Keys.IsPressed(const.Keys.RBUTTON) and SharedIdentifyItem==1 then
			id_item_party = true
			id_item_skill_saved = {[0]=Party[0].Skills[const.Skills.IdentifyItem],[1]=Party[1].Skills[const.Skills.IdentifyItem],[2]=Party[2].Skills[const.Skills.IdentifyItem],[3]=Party[3].Skills[const.Skills.IdentifyItem]}
			maxskill = 0
			for _, pl in Party do
				local sk = pl.Skills[const.Skills.IdentifyItem]
				if maxskill<sk then maxskill = sk end
			end
			Party[Game.CurrentPlayer].Skills[const.Skills.IdentifyItem] = maxskill 
		elseif not(Keys.IsPressed(const.Keys.RBUTTON)) and id_item_party then
			id_item_party = false
			Party[0].Skills[const.Skills.IdentifyItem] = id_item_skill_saved[0]
			Party[1].Skills[const.Skills.IdentifyItem] = id_item_skill_saved[1]
			Party[2].Skills[const.Skills.IdentifyItem] = id_item_skill_saved[2]
			Party[3].Skills[const.Skills.IdentifyItem] = id_item_skill_saved[3]
		end

				--Shared Repair
		if Game.CurrentScreen == 7  and Game.CurrentCharScreen == 103 and not(repair_party) and Keys.IsPressed(const.Keys.RBUTTON) and SharedRepair==1 then
			repair_party = true
			repair_skill_saved = {[0]=Party[0].Skills[const.Skills.Repair],[1]=Party[1].Skills[const.Skills.Repair],[2]=Party[2].Skills[const.Skills.Repair],[3]=Party[3].Skills[const.Skills.Repair]}
			maxskill = 0
			for _, pl in Party do
				local sk = pl.Skills[const.Skills.Repair]
				if maxskill<sk then maxskill = sk end
			end
			Party[Game.CurrentPlayer].Skills[const.Skills.Repair] = maxskill 
		elseif not(Keys.IsPressed(const.Keys.RBUTTON)) and repair_party then
			repair_party = false
			Party[0].Skills[const.Skills.Repair] = repair_skill_saved[0]
			Party[1].Skills[const.Skills.Repair] = repair_skill_saved[1]
			Party[2].Skills[const.Skills.Repair] = repair_skill_saved[2]
			Party[3].Skills[const.Skills.Repair] = repair_skill_saved[3]
		end

		if Game.CurrentScreen == const.Screens.SelectTarget then
		Game.EscMessage('Gotcha!')
		end

end

--function events.KeyDown(t)
	--if t.Key == 75 then
-- function events.LoadMap()
		
-- if not(schedulenotealreadyadded) then
--  	schedulenotealreadyadded = true
	-- local msg = ""
	-- msg = msg .. string.format('    \t%11sMON \t%20sTUE \t%29sWED \t%38sTHU \t%47sFRI \t%56sSAT \t%65sSUN \n','|','|','|','|','|','|','|')
	-- msg = msg .. string.format('Har \t%11sEra2\t%20sTul2\t%29sEra2\t%38sTul2\t%47sEra2\t%56sTul2\t%65sAre4\n','|','|','|','|','|','|','|')
	-- msg = msg .. string.format('Era \t%11sTat2\t%20sHar2\t%29sTat2\t%38sDey3\t%47sTat2\t%56sHar2\t%65s    \n','|','|','|','|','|','|','|')
	-- msg = msg .. string.format('    \t%11sDey2\t%20sTat2\t%29sBra3\t%38sHar2\t%47sAvl4\t%56sBra3\t%65sEve7\n','|','|','|','|','|','|','|')
	-- msg = msg .. string.format('    \t%11sAvl4\t%20s    \t%29sBra6\t%38s    \t%47s    \t%56sTat2\t%65s    \n','|','|','|','|','|','|','|')
	-- msg = msg .. string.format('Tul \t%11sTat2\t%20sHar2\t%29sTat2\t%38sDey3\t%47sTat2\t%56sHar2\t%65s    \n','|','|','|','|','|','|','|')
	-- msg = msg .. string.format('    \t%11sDey2\t%20sTat2\t%29sBra3\t%38sHar2\t%47sAvl4\t%56sBra3\t%65sEve7\n','|','|','|','|','|','|','|')
	-- msg = msg .. string.format('    \t%11sAvl4\t%20s    \t%29sBra6\t%38s    \t%47s    \t%56sTat2\t%65s    \n','|','|','|','|','|','|','|')
	-- msg = msg .. string.format('Avl \t%11sTul3\t%20sTul3\t%29sDey5\t%38sTul3\t%47sTul3\t%56sTul3\t%65sDey5\n','|','|','|','|','|','|','|')
	-- msg = msg .. string.format('    \t%11s    \t%20sEra4\t%29sTul3\t%38sTat5\t%47s    \t%56sEra4\t%65s    \n','|','|','|','|','|','|','|')
	
	-- msg = msg .. string.format('Bra \t%11sEra3\t%20sHar5\t%29sEra3\t%38sEve1\t%47sEra3\t%56sHar5\t%65sEra3\n','|','|','|','|','|','|','|')
	-- msg = msg .. string.format('    \t%11sTat4\t%20sEve1\t%29sTat4\t%38s    \t%47sTat4\t%56sEra6\t%65sTul6\n','|','|','|','|','|','|','|')
	
	-- msg = msg .. string.format('Dey \t%11sEra3\t%20sTul2\t%29sEra3\t%38sTul2\t%47sEra3\t%56sTul2\t%65s    \n','|','|','|','|','|','|','|')
	
	-- msg = msg .. string.format('Tat \t%11sBra4\t%20sEra2\t%29sBra4\t%38sEra2\t%47s    \t%56sEra2\t%65sEve5\n','|','|','|','|','|','|','|')
	-- msg = msg .. string.format('    \t%11s    \t%20sEra2\t%29s    \t%38sEra2\t%47s    \t%56sAvl5\t%65s    \n','|','|','|','|','|','|','|')
	
	-- msg = msg .. string.format('Eve \t%11sTat4\t%20s    \t%29sTat4\t%38s    \t%47sTat4\t%56sTul6\t%65s    ','|','|','|','|','|','|','|')
 	-- Autonote(':SeerTravelSchedule', 3, msg)
 	-- SuppressSound(true)
 	-- AddAutonote(':SeerTravelSchedule')
 	-- SuppressSound(false)
-- end
-- end
-- if TravelScheduleAutoNote == 1 and not(CheckAutonote('SeerTravelSchedule')) then
-- 	AddAutonote('SeerTravelSchedule')
-- end
-- end
-- function events.LoadMap()

-- 	if TravelScheduleAutoNote == 1 and not(CheckAutonote('SeerTravelSchedule')) then
-- 	AddAutonote('SeerTravelSchedule')
-- 	end
-- end
