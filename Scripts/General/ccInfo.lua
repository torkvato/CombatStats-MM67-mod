function events.GameInitialized2()
    schedulenotealreadyadded = false
    Game.GlobalTxt[144] = StrColor(255, 0, 0,    Game.GlobalTxt[144])
    Game.GlobalTxt[116] = StrColor(255, 128, 0,  Game.GlobalTxt[116])
    Game.GlobalTxt[163] = StrColor(0, 127, 255,  Game.GlobalTxt[163])
    Game.GlobalTxt[75] = StrColor(0, 255, 0,     Game.GlobalTxt[75])
    Game.GlobalTxt[1] = StrColor(250, 250, 0,    Game.GlobalTxt[1] )
    Game.GlobalTxt[211] = StrColor(127, 0, 255,  Game.GlobalTxt[211])
    Game.GlobalTxt[136] = StrColor(255, 255, 255,Game.GlobalTxt[136])
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
        FireRes  = pl:GetResistance(10)
        AirRes   = pl:GetResistance(11)
        WaterRes = pl:GetResistance(12)
        EarthRes = pl:GetResistance(13)
        MindRes  = pl:GetResistance(14)
        BodyRes  = pl:GetResistance(15)

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
            R0[i] = (1 - p) + .5 * (1 - p) * p + .25 * (1 - p) * p ^ 2 + .125 * (1 - p) * p ^ 3 + .0625 * p ^ 4;
        end

        Game.GlobalTxt[87] = StrColor(255, 70, 70, string.format("Fire\t            %s%%", ResistancesPerc[10]))
        Game.GlobalTxt[6] = StrColor(173, 216, 230, string.format("Air\t            %s%s ", ResistancesPerc[11], "%"))
        Game.GlobalTxt[240] = StrColor(100, 180, 255, string.format("Water\t            %s%s ", ResistancesPerc[12], "%"))
        Game.GlobalTxt[70] = StrColor(153, 76, 0, string.format("Earth\t            %s%s ", ResistancesPerc[13], "%"))
        Game.GlobalTxt[142] = StrColor(200, 200, 255, string.format("Mind\t            %s%s ", ResistancesPerc[14], "%"))
        Game.GlobalTxt[29] = StrColor(255, 192, 203, string.format("Body\t            %s%s ", ResistancesPerc[15], "%"))

        --Bad things
        --Chance that an enemy will succeed in doing some bad thing to you is 30/(30 + LuckEffect + OtherEffect), where OtherEffect depends on that particular thing:
        local msg = StrColor(255, 70, 70,string.format("Bad things chances: Luck+additional stat:\n"))
        msg = msg.. string.format("Age, Disease, Sleep (End): %d%%\n",math.round(3000/(30+Stat2Modifier(luck)+Stat2Modifier(endu))))
        msg = msg.. string.format("Curse (Pers): - %d%%\n",math.round(3000/(30+Stat2Modifier(luck)+Stat2Modifier(pers))))
        msg = msg.. string.format("DrainSP, Dispel(Pers+Int) %d%%\n",math.round( 3000/(30+Stat2Modifier(luck)+(Stat2Modifier(pers)+Stat2Modifier(intel))/2) ))
        msg = msg.. string.format("Paralyze,Insane (Mind Res.): %d%%\n",math.round(3000/(30+Stat2Modifier(luck)+MindRes)))
        msg = msg.. string.format("Death, Eradication, Poison (Body Res.): %d%%\n",math.round(3000/(30+Stat2Modifier(luck)+BodyRes)))
        for i=0,5 do
        Game.GlobalTxt2[50+i] = msg
        end

        -- Effective HP
        local monAC_LvL = math.min(100,3*lvl)
        local monster_hit_chance = (5 + monAC_LvL*2)/(10 + monAC_LvL*2 + AC) 

        local coeff = CheckPlateChain(pl)

        --local AvoidanceWeights = {Phys = 0.65, Fire=0.075, Air=0.075, Water=0.075, Earth = 0.075, Mind=0.025,Body = .025} -- first try
        local AvoidanceWeights = {Phys = 0.45, Fire=0.25, Air=0.15, Water=0.8, Earth = 0.2, Mind=5,Body = 0}  -- on the base of full game damage percentages (TKPS party )
 
        local avoidance = coeff * monster_hit_chance * AvoidanceWeights.Phys + R0[10]*AvoidanceWeights.Fire + R0[11]*AvoidanceWeights.Air + R0[12]*AvoidanceWeights.Water + R0[13]*AvoidanceWeights.Earth + R0[14]*AvoidanceWeights.Mind + R0[15]*AvoidanceWeights.Body

        local vitality = math.round(0.5*fullHP + 0.5*fullHP/avoidance)  --full HP added to take into account unavoidable damage like Light, Energy and Dark

        -- Attack and DPS calculations	
        local atk_m = pl:GetMeleeAttack()
        local dmg_m = (pl:GetMeleeDamageMin() + pl:GetMeleeDamageMax()) / 2
        local delay_m = pl:GetAttackDelay()

        if delay_m < Game.MinMeleeRecoveryTime then delay_m = Game.MinMeleeRecoveryTime end
        
        local hitchance_m = (15 + atk_m * 2) / (30 + atk_m * 2 + monAC_LvL)  --monster AC treated equal to Player Lvl

        local atk_r = pl:GetRangedAttack()
        local dmg_r = (pl:GetRangedDamageMin() + pl:GetRangedDamageMax()) / 2
        local delay_r = pl:GetAttackDelay(true)
        local hitchance_r = (15 + atk_r * 2) / (30 + atk_r * 2 + monAC_LvL)

        dmg_m = dmg_m + DaggerTriple(pl) + HammerhandsExtra(pl)-- Account Dagger master for chance to triple base weapon dmg and Hammerhanda buff

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

        Game.GlobalTxt[47] = string.format("M/R DPS: %s/%s\n\n\n\n\n\n\n\n\n\n\n\n\n\n", StrColor(255, 0, 0, math.round(dps_m * 10) / 10), StrColor(255, 255, 50, math.round(dps_r * 10) / 10))
        Game.GlobalTxt[172] = string.format("Vit:%s Avoid:%s%%\n\n\n\n\n\n\n\n\n\n\n\n\n\n", StrColor(0, 255, 0, vitality),  StrColor(230, 204, 128,math.round(1000*(1-monster_hit_chance))/10))

        if Keys.IsPressed(const.Keys.ALT) then
            Game.GlobalTxt2[41] = PartyRecordsTxt()
            Game.GlobalTxt2[42] = "Full stats since game beginning, [E] for export\n" .. DamageMeterCalculation(vars.damagemeter)             
        else 
        
        Game.GlobalTxt2[41] = string.format("Current map: %s, [ALT] for more\n",Game.MapStats[Game.Map.MapStatsIndex].Name).. DamageMeterCalculation(mapvars.damagemeter)      
        Game.GlobalTxt2[42] = string.format("Segment: %s since [r]eset, [ALT] for full\n",GameTimePassed()) .. DamageMeterCalculation(vars.damagemeter1) 
        
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
        if pl.ItemMainHand>0 then 
			mh = pl.Items[pl.ItemMainHand]
        -- Skill% chance for triple base damage (double extra base)
			if mh:T().Skill ==  const.Skills.Dagger then
				extradamage = sdagger / 100 * 2 * (mh:T().Mod2 + (mh:T().Mod1DiceCount + mh:T().Mod1DiceCount * mh:T().Mod1DiceSides)/2)
			end
		end
		
        if pl.ItemExtraHand > 0 then 
			eh = pl.Items[pl.ItemExtraHand]
			if eh:T().Skill ==  const.Skills.Dagger then
				extradamage = extradamage + sdagger / 100 * 2 * (eh:T().Mod2 + (eh:T().Mod1DiceCount + eh:T().Mod1DiceCount * eh:T().Mod1DiceSides)/2)
			end
        end
    end
    return extradamage
end


function HammerhandsExtra(pl)
    local extradamage = 0
    --both hands empty and buffed
    if pl.SpellBuffs[const.PlayerBuff.Hammerhands].ExpireTime>0 and  pl.ItemMainHand==0 and pl.ItemExtraHand==0 then
    
    extradamage = pl.SpellBuffs[const.PlayerBuff.Hammerhands].Power
    end
    return extradamage
end


function GameTimePassed()
local gameminutes = math.floor((Game.Time - vars.timestamps[0].SegmentStart)/const.Minute)
local days = math.floor(gameminutes/60/24)    
local hours = math.floor((gameminutes%(60*24))/60)
local mins = gameminutes%60
return string.format("%dd%02dh%02dm",days,hours,mins)
end


function get_key_for_value(t, value)
    for k, v in pairs(t) do
        if v == value then
            return k
        end
    end
    return nil
end

function pt(tbl)
    local msg = "{"
    for k, v in pairs(tbl) do
        msg = msg .. tostring(k) .. " = "
        if type(v) == "table" then
            pt(v)
        else
            msg = msg .. tostring(v)
        end
        msg = msg .. ", "
    end
    msg = msg .. "}"
    print(msg)
end


function ftable(vars)
	local file = io.open('debugout.txt','a')
	for k,v in pairs(vars) do
		file:write(tostring(k) .. ' ' .. tostring(v) .. '\n')
	end
	file:write('\n')
	file:close()
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
