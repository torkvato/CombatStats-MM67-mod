function SkillToolTips()
    local pl = Party[Game.CurrentPlayer]
    ---In MM6 the condition for successful disarming is Lock*5 < player:GetDisarmTrapTotalSkill() + math.random(0, 9). In MM7+ the condition is Lock*2 <= player:GetDisarmTrapTotalSkill(). 
    -- Skill-5*Lock:> 0 .... diff 0 - 90% diff1 - 80% diff 8-10% diff 9 - 0% success
    local ch = 9 - (5 * Game.MapStats[Game.Map.MapStatsIndex].Lock - pl:GetDisarmTrapTotalSkill());
    if ch > 10 then
        ch = 10
    end
    if ch < 0 then
        ch = 0
    end
    local msg = StrColor(255, 255, 0,
        string.format("\nEffective Skill: %d, Map Requirements: %d, Success chance: %d%%", pl:GetDisarmTrapTotalSkill(), 5 * Game.MapStats[Game.Map.MapStatsIndex].Lock, ch * 10))
    local sd = Game.SkillDescriptions[const.Skills.DisarmTraps]
    local addind = string.find(sd, '\n')
    if addind then
        Game.SkillDescriptions[const.Skills.DisarmTraps] = string.sub(sd, 1, string.find(sd, '\n')) .. msg
    else
        Game.SkillDescriptions[const.Skills.DisarmTraps] = sd .. msg
    end

    local msg = StrColor(255, 255, 0, string.format("\nMerchant price changes: %d%%", pl:GetMerchantTotalSkill()))
    sd = Game.SkillDescriptions[const.Skills.Merchant]
    local addind = string.find(sd, '\n')
    if addind then
        Game.SkillDescriptions[const.Skills.Merchant] = string.sub(sd, 1, string.find(sd, '\n')) .. msg
    else
        Game.SkillDescriptions[const.Skills.Merchant] = sd .. msg
    end

    
    local lrn = ccGetSkills(const.Skills.Learning,pl)   
    local msg = StrColor(255, 255, 0, string.format("\nTotal experience bonus: %d%%", lrn))
    sd = Game.SkillDescriptions[const.Skills.Learning]
    local addind = string.find(sd, '\n')
    if addind then
        Game.SkillDescriptions[const.Skills.Learning] = string.sub(sd, 1, string.find(sd, '\n')) .. msg
    else
        Game.SkillDescriptions[const.Skills.Learning] = sd .. msg
    end
end
