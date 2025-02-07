function events.KeyDown(t)
    if Game.CurrentScreen == 0 and t.Key == ID_MonsterButton and Game.Version < 7 and IdMonsterGM == 1 then
        local z = Mouse:GetTarget()
        if z.Kind == 3 then
            local msg = ""
            local mon = z:Get()
            local moncommon = Game.MonstersTxt[z:Get().Id]
            local monName = mon.Name
            msg = msg .. string.format("%s(%s)\n", monName, mon.Level)
            msg = msg .. string.format("Health: %s/%s, AC: %s, Exp: %s\n", mon.HP,mon.FullHP, mon.ArmorClass, mon.Exp)
            local dmin = mon.Attack1.DamageAdd + mon.Attack1.DamageDiceCount 
            local dmax = mon.Attack1.DamageAdd + mon.Attack1.DamageDiceCount * mon.Attack1.DamageDiceSides
            local kind = PaintKind(get_key_for_value(const.Damage,mon.Attack1.Type),get_key_for_value(const.Damage,mon.Attack1.Type))
            msg = msg .. string.format("Damage: %s-%s %s, Recovery: %s\n",dmin, dmax, kind, moncommon.AttackRecovery)
            if mon.Attack2.DamageAdd>0 then
             dmin = mon.Attack2.DamageAdd + mon.Attack2.DamageDiceCount 
             dmax = mon.Attack2.DamageAdd + mon.Attack2.DamageDiceCount * mon.Attack2.DamageDiceSides
             kind = PaintKind(get_key_for_value(const.Damage,mon.Attack2.Type),get_key_for_value(const.Damage,mon.Attack2.Type))
             msg = msg .. string.format("Damage: %s-%s %s\n",dmin, dmax, kind)
            end
            if mon.Spell>0 then                
            local knd = get_key_for_value(const.Damage,Game.SpellsTxt[mon.Spell].DamageType)
            local s,m = SplitSkill(mon.SpellSkill)
            msg = msg .. string.format("Spell: %s\n", PaintKind(get_key_for_value(const.Spells, mon.Spell) ..const.Mastery[m] .. s,knd))
                --objmsg = get_key_for_value(const.Spells, mon.Spell) .. const.Mastery[O.SpellMastery] .. O.SpellSkill  --get_key_for_value(const.Mastery, O.SpellMastery)
            end

            local function res2perc(res)
                if res == 200 then
                    return "Imm"
                else
                    p = 1 - 30 / (30 + res)
                    return tostring(100 - math.round(100 * (1 - p) + 50 * (1 - p) * p + 25 * (1 - p) * p ^ 2 + 12.5 * (1 - p) * p ^ 3 + 6.25 * p ^ 4)) .. "%";
                end
            end
            msg = msg .. string.format("%s\t%14s  %s\t%30s  %s\t%48s\n",PaintKind('Fire:', 'Fire'), res2perc(mon.Resistances[const.Damage.Fire]), PaintKind('Cold:', 'Cold'),res2perc(mon.Resistances[const.Damage.Cold]), PaintKind('Magic:', 'Magic') , res2perc(mon.Resistances[const.Damage.Magic]))
            msg = msg .. string.format("%s\t%14s  %s\t%30s  %s\t%48s",  PaintKind('Phys:', 'Phys'), res2perc(mon.Resistances[const.Damage.Phys]), PaintKind('Elec:', 'Elec'),res2perc(mon.Resistances[const.Damage.Elec]), PaintKind('Poison:', 'Poison'), res2perc(mon.Resistances[const.Damage.Poison]))
            -- msg = msg .. PaintKind('Fire:', 'Fire') .. string.format("\t%16s\n", res2perc(mon.Resistances[const.Damage.Fire]))
            -- msg = msg .. PaintKind('Elec:', 'Elec') .. string.format("\t%16s\n", res2perc(mon.Resistances[const.Damage.Elec]))
            -- msg = msg .. PaintKind('Cold:', 'Cold') .. string.format("\t%16s\n", res2perc(mon.Resistances[const.Damage.Cold]))
            -- msg = msg .. PaintKind('Poison:', 'Poison') .. string.format("\t%16s\n", res2perc(mon.Resistances[const.Damage.Poison]))
            -- msg = msg .. PaintKind('Magic:', 'Magic') .. string.format("\t%16s\n", res2perc(mon.Resistances[const.Damage.Magic]))
            -- msg = msg .. PaintKind('Phys:', 'Phys') .. string.format("\t%16s", res2perc(mon.Resistances[const.Damage.Phys]))
            
            Message(msg)
        end

    end

    if Game.CurrentScreen == 0 and t.Key == const.Keys.V and Keys.IsPressed(const.Keys.RBUTTON) then
        local z = Mouse:GetTarget()
        if z.Kind == 3 then
            local streetid = z:Get().NPC_ID
            if streetid>5000 and Game.Version>6 then
                Game.StreetNPC[streetid-5000].Profession = 1+Game.StreetNPC[streetid-5000].Profession%57
            elseif Game.Version==6 and streetid>0 then
                Game.StreetNPC[streetid-1].Profession = 1+Game.StreetNPC[streetid-1].Profession%57
            end  
        end

    end

end

function events.Tick()
    if Game.Version > 6 and Game.CurrentScreen == 0 then
        -- ID monster GM with Alt
        if Keys.IsPressed(const.Keys.ALT) and Keys.IsPressed(const.Keys.RBUTTON) and not (id_monster_GM_set) and IdMonsterGM == 1 and Game.CurrentPlayer >= 0 then
            id_monster_GM_set = true
            last_id_moster_skill = Party[Game.CurrentPlayer].Skills[const.Skills.IdentifyMonster]
            Party[Game.CurrentPlayer].Skills[const.Skills.IdentifyMonster] = JoinSkill(10, const.GM)
        elseif id_monster_GM_set and not (Keys.IsPressed(const.Keys.ALT)) then
            id_monster_GM_set = false
            Party[Game.CurrentPlayer].Skills[const.Skills.IdentifyMonster] = last_id_moster_skill
        end
    end
    -- Shared ID item
    if Game.CurrentScreen == 7 and Game.CurrentCharScreen == 103 and not (id_item_party) and Keys.IsPressed(const.Keys.RBUTTON) and SharedIdentifyItem == 1 then
        id_item_party = true
        local s = const.Skills.IdentifyItem
        local maxskill = 0
        for _, pl in Party do
            if (pl.Eradicated + pl.Dead + pl.Stoned + pl.Paralyzed + pl.Unconscious + pl.Asleep) == 0 then
                local sk = pl.Skills[s]
                if maxskill < sk then
                    maxskill = sk
                end
            end
        end
        id_item_skill_saved = {
            [0] = Party[0].Skills[s],
            [1] = Party[1].Skills[s],
            [2] = Party[2].Skills[s],
            [3] = Party[3].Skills[s]
        }
        Party[Game.CurrentPlayer].Skills[s] = maxskill -- in mm6 there are no repair and id skill bonuses
    elseif not (Keys.IsPressed(const.Keys.RBUTTON)) and id_item_party then
        id_item_party = false
        Party[0].Skills[const.Skills.IdentifyItem] = id_item_skill_saved[0]
        Party[1].Skills[const.Skills.IdentifyItem] = id_item_skill_saved[1]
        Party[2].Skills[const.Skills.IdentifyItem] = id_item_skill_saved[2]
        Party[3].Skills[const.Skills.IdentifyItem] = id_item_skill_saved[3]
    end

    -- Shared Repair
    if Game.CurrentScreen == 7 and Game.CurrentCharScreen == 103 and not (repair_party) and Keys.IsPressed(const.Keys.RBUTTON) and SharedRepair == 1 then
        repair_party = true
        local s = const.Skills.Repair
        local maxskill = 0
        for _, pl in Party do
            if (pl.Eradicated + pl.Dead + pl.Stoned + pl.Paralyzed + pl.Unconscious + pl.Asleep) == 0 then
                local sk = pl.Skills[s]
                if maxskill < sk then
                    maxskill = sk
                end
            end
        end
        repair_skill_saved = {
            [0] = Party[0].Skills[s],
            [1] = Party[1].Skills[s],
            [2] = Party[2].Skills[s],
            [3] = Party[3].Skills[s]
        }
        Party[Game.CurrentPlayer].Skills[s] = maxskill -- in mm6 there are no repair and id skill bonuses
    elseif not (Keys.IsPressed(const.Keys.RBUTTON)) and repair_party then
        repair_party = false
        Party[0].Skills[const.Skills.Repair] = repair_skill_saved[0]
        Party[1].Skills[const.Skills.Repair] = repair_skill_saved[1]
        Party[2].Skills[const.Skills.Repair] = repair_skill_saved[2]
        Party[3].Skills[const.Skills.Repair] = repair_skill_saved[3]
    end

end

--for i=0,Game.StreetNPC.High do print(i,Game.StreetNPC[i].Name, get_key_for_value(const.NPCProfession,Game.StreetNPC[i].Profession)) end

