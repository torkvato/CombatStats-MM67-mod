nextbuffdurationcheck = 0
nextalarmclockcheck = 0
concat_damage = 0

-- Color character page
if string.sub(Game.GlobalTxt[144], 1, 1) ~= '\012' then
    Game.GlobalTxt[144] = StrColor(255, 0, 0, Game.GlobalTxt[144])
    Game.GlobalTxt[116] = StrColor(255, 128, 0, Game.GlobalTxt[116])
    Game.GlobalTxt[163] = StrColor(0, 127, 255, Game.GlobalTxt[163])
    Game.GlobalTxt[75] = StrColor(0, 255, 0, Game.GlobalTxt[75])
    Game.GlobalTxt[1] = StrColor(250, 250, 0, Game.GlobalTxt[1])
    Game.GlobalTxt[211] = StrColor(160, 50, 255, Game.GlobalTxt[211])
    Game.GlobalTxt[136] = StrColor(255, 255, 255, Game.GlobalTxt[136])
    Game.GlobalTxt[108] = StrColor(0, 255, 0, Game.GlobalTxt[108])
    Game.GlobalTxt[212] = StrColor(0, 100, 255, Game.GlobalTxt[212])
    Game.GlobalTxt[12] = StrColor(230, 204, 128, Game.GlobalTxt[12])

    if Game.Version < 7 then
        Game.GlobalTxt[87] = string.sub(StrColor(255, 70, 70, Game.GlobalTxt[87]),1,-7)
        Game.GlobalTxt[71] = string.sub(StrColor(173, 216, 230, string.sub(Game.GlobalTxt[71],1,5)),1,-7)
        Game.GlobalTxt[43] = string.sub(StrColor(100, 180, 255, Game.GlobalTxt[43]),1,-7)
        Game.GlobalTxt[166] = string.sub(StrColor(0, 250, 0, Game.GlobalTxt[166]),1,-7)
        Game.GlobalTxt[138] = string.sub(StrColor(160, 50, 255, Game.GlobalTxt[138]),1,-7)

    else
        Game.GlobalTxt[87] = string.sub(StrColor(255, 70, 70, Game.GlobalTxt[87]),1,-7)
        Game.GlobalTxt[6] = string.sub(StrColor(173, 216, 230, Game.GlobalTxt[6]),1,-7)
        Game.GlobalTxt[240] = string.sub(StrColor(100, 180, 255, Game.GlobalTxt[240]),1,-7)
        Game.GlobalTxt[70] = string.sub(StrColor(153, 76, 0, Game.GlobalTxt[70]),1,-7)
        Game.GlobalTxt[142] = string.sub(StrColor(200, 200, 255, Game.GlobalTxt[142]),1,-7)
        Game.GlobalTxt[29] = string.sub(StrColor(255, 192, 203, Game.GlobalTxt[29]),1,-7)
    end
end
-- Table of average additional elem damage on weapons vs Bonus2 property value
const.bonus2damage = {
    [0] = 0,
    [4] = 3.5,
    [5] = 7,
    [6] = 10.5,
    [7] = 3.5,
    [8] = 7,
    [9] = 10.5,
    [10] = 3.5,
    [11] = 7,
    [12] = 10.5,
    [13] = 5,
    [14] = 8,
    [15] = 12,
    [46] = 15,
    [67] = 5,
    [68] = 7
}
const.Mastery = {
    [0] = "x",
    [1] = "N",
    [2] = "E",
    [3] = "M",
    [4] = "G"
}

function Stat2Modifier(stat)
    local StatsLimitValues = {0, 3, 5, 7, 9, 11, 13, 15, 17, 19, 21, 25, 30, 35, 40, 50, 75, 100, 125, 150, 175, 200, 225, 250, 275, 300, 350, 400, 500}
    local StatsEffectsValues = {-6, -5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 25, 30}
    local found
    local next
    for i1 = #StatsLimitValues, 1, -1 do
        if StatsLimitValues[i1] <= stat then
            found = StatsEffectsValues[i1]
            next = StatsLimitValues[i1 + 1]
            break
        end
    end
    next = next or "Max"
    return found, next
end

function PaintKind(msg, kind)
    local DamageColor
    if Game.Version < 7 then
        DamageColor = {
            Fire = {255, 70, 70},
            Elec = {173, 216, 230},
            Cold = {100, 180, 255},
            Poison = {0, 255, 0},
            Phys = {255, 255, 255},
            Magic = {160, 50, 255},
            Energy = {255, 0, 0}
        }
    else
        DamageColor = {
            Fire = {255, 70, 70},
            Air = {173, 216, 230},
            Water = {100, 180, 255},
            Earth = {153, 76, 0},

            Phys = {255, 255, 255},
            Magic = {0, 255, 0},

            Spirit = {100, 200, 255},
            Mind = {200, 115, 255},
            Body = {75, 255, 255},

            Light = {250, 250, 0},
            Dark = {127, 0, 255},
            Energy = {255, 0, 0}
        }
    end
    return StrColor(DamageColor[kind][1], DamageColor[kind][2], DamageColor[kind][3], msg)
end

function DaggerTriple(pl)
    local extradamage = 0
    local sdagger, mdagger = SplitSkill(ccGetSkills(const.Skills.Dagger, pl))
    if mdagger >= 3 then -- master or GM
        if pl.ItemMainHand > 0 then
            mh = pl.Items[pl.ItemMainHand]
            -- Skill% chance for triple base damage (double extra base)
            if mh:T().Skill == const.Skills.Dagger then
                extradamage = sdagger / 100 * 2 * (mh:T().Mod2 + (mh:T().Mod1DiceCount + mh:T().Mod1DiceCount * mh:T().Mod1DiceSides) / 2)
            end
        end

        if pl.ItemExtraHand > 0 then
            eh = pl.Items[pl.ItemExtraHand]
            if eh:T().Skill == const.Skills.Dagger then
                extradamage = extradamage + sdagger / 100 * 2 * (eh:T().Mod2 + (eh:T().Mod1DiceCount + eh:T().Mod1DiceCount * eh:T().Mod1DiceSides) / 2)
            end
        end
    end
    return extradamage
end

function RecoveryItems(pl)
    if Game.Version < 7 and CheckBonus2(pl, 17) then
        return 1.1
    end
    return 1
end

function CheckBonus2(pl, bonus2)
    for slot = 0, 15 do
        if pl.EquippedItems[slot] > 0 then
            if pl.Items[pl.EquippedItems[slot]].Bonus2 == bonus2 then
                return true
            end
        end
    end
    return false
end

function CheckItem(pl, itn)
    for slot = 0, 15 do
        if pl.EquippedItems[slot] > 0 then
            if pl.Items[pl.EquippedItems[slot]].Number == itn then
                return true
            end
        end
    end
    return false
end

function GetMonName(mon)
    local monName
    if Game.Version > 6 then
        if mon.NameId > 0 then
            monName = Game.PlaceMonTxt[mon.NameId]
        else
            monName = Game.MonstersTxt[mon.Id].Name
        end
    else
        monName = mon.Name
    end
    return string.format("%s(%s)", monName, mon.Level)
end

function GameTimePassed()
    local gameminutes = math.floor((Game.Time - vars.timestamps[0].SegmentStart) / const.Minute)
    local days = math.floor(gameminutes / 60 / 24)
    local hours = math.floor((gameminutes % (60 * 24)) / 60)
    local mins = gameminutes % 60
    return string.format("%dd%02dh%02dm", days, hours, mins)
end

function CheckPlateChain(pl) -- mm7 only
    local coeff = 1
    local s, mplate = SplitSkill(pl:GetSkill(const.Skills.Plate))
    local s, mchain = SplitSkill(pl:GetSkill(const.Skills.Chain))
    local equippedarmor = 0

    if pl.ItemArmor > 0 then
        equippedarmor = pl.Items[pl.ItemArmor]:T().Skill
    end

    if mplate >= 3 and equippedarmor == 11 then -- Plate mastery
        coeff = 0.5
    elseif mchain == 4 and equippedarmor == 10 then -- chain GM
        coeff = 2 / 3
    end
    return coeff
end

function HammerhandsExtra(pl) -- mm7 only
    local extradamage = 0
    -- both hands empty and buffed
    if pl.SpellBuffs[const.PlayerBuff.Hammerhands].ExpireTime > 0 and pl.ItemMainHand == 0 and pl.ItemExtraHand == 0 then

        extradamage = pl.SpellBuffs[const.PlayerBuff.Hammerhands].Power
    end
    return extradamage
end

function get_key_for_value(t, value)
    for k, v in pairs(t) do
        if v == value then
            return k
        end
    end
    return nil
end

function ccGetSkills(sk, pl)
    -- universal get skills for all game versions
    if Game.Version > 6 then
        if sk == const.Skills.Learning then
            return pl:GetLearningTotalSkill(sk)
        elseif sk == const.Skills.Perception then
            return pl:GetPerceptionTotalSkill(sk)
        else
            return pl:GetSkill(sk)
        end
    else
        local s = pl.Skills[sk]
        if sk == const.Skills.Dagger then
            if Party.HasNPCProfession(const.NPCProfession.ArmsMaster) then
                s = s + 2
            end
            if Party.HasNPCProfession(const.NPCProfession.WeaponsMaster) then
                s = s + 3
            end
            if Party.HasNPCProfession(const.NPCProfession.Squire) then
                s = s + 2
            end
        elseif sk == const.Skills.Learning then
            local ls, lm = SplitSkill(s)
            s = 9 + ls * lm
            if Party.HasNPCProfession(const.NPCProfession.Scholar) then
                s = s + 5
            end
            if Party.HasNPCProfession(const.NPCProfession.Teacher) then
                s = s + 10
            end
            if Party.HasNPCProfession(const.NPCProfession.Instructor) then
                s = s + 15
            end
        end
        return s
    end
end

function table_contains(tbl, x)
    found = false
    for _, v in pairs(tbl) do
        if v == x then
            found = true
        end
    end
    return found
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

function pa(tbl)
    for i = 0, tbl.High do
        print(i, tbl[i])
    end
end
