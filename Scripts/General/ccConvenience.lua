function events.Tick()
	    -- ID monster GM with Alt
		if Game.CurrentScreen == 0 and Keys.IsPressed(const.Keys.ALT) and Keys.IsPressed(const.Keys.RBUTTON) and not(id_monster_GM_set) and AltIdMonsterGM==1 and Game.CurrentPlayer>=0 then
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

		-- if Game.CurrentScreen == const.Screens.SelectTarget then
		-- Game.EscMessage('Gotcha!')
		-- end

end
