function SkillToolTips()
    local pl = Party[Game.CurrentPlayer]
    local s, m, msg

    local function UpdDsc(id, msg)
        local pos = string.find(Game.SkillDescriptions[id], '\n')
        if pos then
            Game.SkillDescriptions[id] = string.sub(Game.SkillDescriptions[id], 1, pos) .. msg
        else
            Game.SkillDescriptions[id] = Game.SkillDescriptions[id] .. msg
        end
    end

    -- Disarm

    ---In MM6 the condition for successful disarming is Lock*5 < player:GetDisarmTrapTotalSkill() + math.random(0, 9). In MM7+ the condition is Lock*2 <= player:GetDisarmTrapTotalSkill(). 
    -- Skill-5*Lock:> 0 .... diff 0 - 90% diff1 - 80% diff 8-10% diff 9 - 0% success
    if Game.Version == 6 then
        local ch = 9 - (5 * Game.MapStats[Game.Map.MapStatsIndex].Lock - pl:GetDisarmTrapTotalSkill());
        if ch > 10 then
            ch = 10
        end
        if ch < 0 then
            ch = 0
        end
        msg = StrColor(255, 255, 0,
            string.format("\nEffective Skill: %d, Map Requirements: %d, Success chance: %d%%", pl:GetDisarmTrapTotalSkill(), 5 * Game.MapStats[Game.Map.MapStatsIndex].Lock, ch * 10))
    else
        msg = StrColor(255, 255, 0, string.format("\nEffective Skill:%d, Map Reqired: %d", pl:GetDisarmTrapTotalSkill(), 2 * Game.MapStats[Game.Map.MapStatsIndex].Lock))
    end
    UpdDsc(const.Skills.DisarmTraps, msg)

    -- Merchant
    msg = StrColor(255, 255, 0, string.format("\nMerchant price changes: %d%%", pl:GetMerchantTotalSkill()))
    UpdDsc(const.Skills.Merchant, msg)

    -- Learning
    s, m = ccGetSkills(const.Skills.Learning, pl)
    msg = StrColor(255, 255, 0, string.format("\nTotal experience bonus: %d%%", s))
    UpdDsc(const.Skills.Learning, msg)

    -- Meditation
    s, m = SplitSkill(ccGetSkills(const.Skills.Meditation, pl))
    local spadd = s * m * Game.Classes.SPFactor[pl.Class]
    msg = StrColor(255, 255, 0, string.format("\nExtra spell points: %d (+%.1f%%)", spadd, 100 * spadd / pl:GetFullSP()))
    UpdDsc(const.Skills.Meditation, msg)

    -- BB
    s, m = SplitSkill(ccGetSkills(const.Skills.Bodybuilding, pl))
    local spadd = s * m * Game.Classes.HPFactor[pl.Class]
    msg = StrColor(255, 255, 0, string.format("\nExtra health points: %d (+%.1f%%)", spadd, 100 * spadd / pl:GetFullHP()))
    UpdDsc(const.Skills.Bodybuilding, msg)

end
