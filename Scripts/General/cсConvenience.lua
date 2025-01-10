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
end

function events.KeyDown(t)
if  Game.CurrentScreen == 0 and t.Key == 72 then -- "H" key

local msg = ""
msg = msg .. string.format('|\t%5sMon\t%10sTue |Wed |Thu |Fri |Sat |Sun |\n','|','|' )
msg = msg .. string.format('|Harm|Era2|Tul2|Era1|Tul2|Era2|Tul2|Are4|\n' )
msg = msg .. string.format('|Era |Tat2|Har2|Tat2|Dey3|Tat2|Har2|    |\n' )
msg = msg .. string.format('|Era |Dey2|Tat2|Bra3|Har2|Avl4|Bra3|Eve7|\n' )
msg = msg .. string.format('|Era |Avl4|    |Bra6|    |    |Tat2|    |\n' )
msg = msg .. string.format('|Tul |Tat2|Har2|Tat2|Dey3|Tat2|Har2|    |\n' )
msg = msg .. string.format('|Tul |Dey2|Tat2|Bra3|Har2|Avl4|Bra3|Eve7|\n' )
msg = msg .. string.format('|Tul |Avl4|    |Bra6|    |    |Tat2|    |\n' )




Message(msg)
end
end