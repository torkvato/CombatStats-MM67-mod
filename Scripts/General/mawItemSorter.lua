-- Borrowed from MAW with minor changes
function events.KeyDown(t)
    if Game.CurrentScreen == const.Screens.Inventory and Game.CurrentCharScreen == const.CharScreens.Inventory then
        if t.Key == PlayerInventorySortButton then
            sortInventory(false)
            Game.ShowStatusText("Inventory sorted")
        elseif t.Key == PartyInventorySortButton then
            sortInventory(true)
            Game.ShowStatusText("All inventories have been sorted")
        elseif t.Key == AlchemyPlayerSetButton then
            vars.alchemyPlayer = vars.alchemyPlayer or -1
            if vars.alchemyPlayer == Game.CurrentPlayer then
                vars.alchemyPlayer = -1
                Game.ShowStatusText("No alchemy preference when sorting")
            else
                vars.alchemyPlayer = Game.CurrentPlayer
                Game.ShowStatusText(Party[Game.CurrentPlayer].Name .. " will now take alchemy items when sorting")
            end
        elseif t.Key == IdentifyPlayerSetButton then
            vars.identifyPlayer = vars.identifyPlayer or -1
            if vars.identifyPlayer == Game.CurrentPlayer then
                vars.identifyPlayer = -1
                Game.ShowStatusText("No unidentified items preference when sorting")
            else
                vars.identifyPlayer = Game.CurrentPlayer
                Game.ShowStatusText(Party[Game.CurrentPlayer].Name .. " will now take unidentified items when sorting")
            end

        end
    end
end

function sortInventory(all)
	local lastPlayer = Game.CurrentPlayer

    evt.Add("Items", 0)

    local itemList = {}
    local j = 0
    local low, high
    if all then
        low = 0
        high = Party.High
    else
        low = Game.CurrentPlayer
        high = Game.CurrentPlayer
    end

    for i = low, high do
        local pl = Party[i]

        removeList = {}
        for i = 0, 125 do
            if pl.Inventory[i] > 0 then
                if pl.Items[pl.Inventory[i]].BodyLocation == 0 then
                    removeList[-i - 1] = true
                end
                local it = pl.Items[pl.Inventory[i]]
                if it.Number > 0 then
                    j = j + 1
                    itemList[j] = {}
                    itemList[j]["Bonus"] = it.Bonus
                    itemList[j]["Bonus2"] = it.Bonus2
                    itemList[j]["BonusExpireTime"] = it.BonusExpireTime
                    itemList[j]["BonusStrength"] = it.BonusStrength
                    itemList[j]["Broken"] = it.Broken
                    itemList[j]["Charges"] = it.Charges
                    itemList[j]["Condition"] = it.Condition
                    itemList[j]["Hardened"] = it.Hardened
                    itemList[j]["Identified"] = it.Identified
                    itemList[j]["MaxCharges"] = it.MaxCharges
                    itemList[j]["Number"] = it.Number
                    itemList[j]["Owner"] = it.Owner
                    itemList[j]["Refundable"] = it.Refundable
                    itemList[j]["Stolen"] = it.Stolen
                    itemList[j]["TemporaryBonus"] = it.TemporaryBonus
                    itemList[j]["size"] = itemSizeMap[it.Number][2]
                    if itemList[j]["size"] == 1 and itemSizeMap[it.Number][1] > 1 then
                        itemList[j]["size"] = 1.5
                    end
                    pl.Inventory[i] = 0
                    it.Number = 0
                end
            end
        end

        for i = 0, 125 do
            if removeList[pl.Inventory[i]] then
                pl.Inventory[i] = 0
            end
        end

        vars.alchemyPlayer = vars.alchemyPlayer or -1
        vars.identifyPlayer = vars.identifyPlayer or -1
        table.sort(itemList, function(a, b)

            if vars.identifyPlayer >= 0 and (not (a["Identified"]) or not (b["Identified"])) then -- Ensure that Unidentified items go first, even before alchemy
                local aa = not (a["Identified"]) == true and 1 or not (a["Identified"]) == false and 0
                local bb = not (b["Identified"]) == true and 1 or not (b["Identified"]) == false and 0
                return aa * a["size"] > bb * b["size"]
            end

            if vars.alchemyPlayer >= 0 then
				--Put Items with Alchemy bonus to Alchemy player, just in case
				if a["Bonus"]==17 and b["Bonus"]==17 then
					return a["size"] > b["size"]
				elseif  a["Bonus"]==17 or b["Bonus"]==17 then
					return a["Bonus"]==17
				end
					
                -- Sorting according to alchemyItemsOrder
                local indexA = table.find(alchemyItemsOrder, a["Number"])
                local indexB = table.find(alchemyItemsOrder, b["Number"])
                if indexA and indexB then -- If both items are in the list
                    return indexA < indexB
                elseif indexA or indexB then -- If only one item is in the list, it goes first
                    return indexA ~= nil
                end

                -- Special sorting for items with number >= 220 and < 300
                local a0 = a["Number"] >= 200 and a["Number"] < 300
                local b0 = b["Number"] >= 200 and b["Number"] < 300
                if a0 or b0 then
                    -- Ensure that items in the specified range are sorted first and from biggest to smallest
                    if a0 and b0 then
                        return a["Number"] < b["Number"] -- Both in range, sort descending
                    else
                        return a0 -- Only one in range, it goes first
                    end
                end
            end

            -- Original sorting logic
            if a["size"] == b["size"] then
                -- When sizes are equal, compare by skill
                local skillA = Game.ItemsTxt[a["Number"]].Skill
                local skillB = Game.ItemsTxt[b["Number"]].Skill

                if skillA == skillB then
                    -- If skills are also equal, then sort by item number
                    return a["Number"] < b["Number"]
                else
                    -- Otherwise, sort by skill
                    return skillA < skillB
                end
            else
                -- Primary sort by size
                return a["size"] > b["size"]
            end
        end)

    end

    if itemList[1] then

        local alchemy_item_counter = 0
		local alchemy_space_counter = 0
        local partynext = {[0] = 1,[1] = 2,[2] = 3,[3] = 2}
        local temp_alchemy_player = vars.alchemyPlayer or -1

        for i = 1, #itemList do
            if vars.alchemyPlayer >= 0 then
                if table.find(alchemyItemsOrder, itemList[i].Number) or
                    (itemList[i].Number >= 200 and itemList[i].Number < 300) or itemList[i].Bonus==17 then
					alchemy_space_counter = alchemy_space_counter + itemList[i].size	
                    alchemy_item_counter = alchemy_item_counter + 1
                    if alchemy_item_counter > 111 - 1 or alchemy_space_counter>(9*14-2) then
						alchemy_item_counter = 0
						alchemy_space_counter = 0
						temp_alchemy_player = partynext[temp_alchemy_player]
					end
					Game.CurrentPlayer = temp_alchemy_player
                end
            elseif vars.identifyPlayer >= 0 and not (itemList[i].Identified) then
                Game.CurrentPlayer = vars.identifyPlayer
            end
			
            evt.Add("Items", itemList[i].Number)
            it = Mouse.Item
            it.Bonus = itemList[i].Bonus
            it.Bonus2 = itemList[i].Bonus2
            it.BonusExpireTime = itemList[i].BonusExpireTime
            it.BonusStrength = itemList[i].BonusStrength
            it.Broken = itemList[i].Broken
            it.Charges = itemList[i].Charges
            it.Condition = itemList[i].Condition
            it.Hardened = itemList[i].Hardened
            it.Identified = itemList[i].Identified
            it.MaxCharges = itemList[i].MaxCharges
            it.Owner = itemList[i].Owner
            it.Refundable = itemList[i].Refundable
            it.Stolen = itemList[i].Stolen
            it.TemporaryBonus = itemList[i].TemporaryBonus
			evt.Add("Items", 0) -- to give item to proper player 
			Game.CurrentPlayer = lastPlayer            
        end
         evt.Add("Inventory", 0)
    end
    table.clear(itemList)
end

-- Define the alchemyItemsOrder list for reference in sorting

-- Empty, cat, rby RBY RBY
  alchemyItemsOrder = { 220, 215, 216, 217, 218, 219, 200, 205, 210, 201, 206, 211, 202, 207, 212, 203, 208, 213, 204, 209, 214}
-- alchemyItemsOrder = {220, 215, 216, 217, 218, 219, 204, 209, 214, 203, 208, 213, 202, 207, 212, 201, 206, 211, 200, 205, 210}

-- for i=1,Game.ItemsTxt.High do print(i,Game.ItemsTxt[i].Name) end

-- 200	Widowsweep Berries -- 201	Crushed Rose Petals -- 202	Vial of Troll Blood -- 203	Ruby  -- 204	Dragon's Eye
-- 205	Phirna Root -- 206	Meteorite Fragment -- 207	Harpy Feather -- 208	Moonstone -- 209	Elvish Toadstool
-- 210	Poppysnaps -- 211	Fae Dust -- 212	Sulfur -- 213	Garnet -- 214	Vial of Devil Ichor
-- 215	Mushroom -- 216	Obsidian -- 217	Vial of Ooze Endoplasm -- 218	Mercury -- 219	Philosopher's Stone
-- 220	Potion Bottle
-- 221	Catalyst
-- 222	Cure Wounds
-- 223	Magic Potion
-- 224	Cure Weakness
-- 225	Cure Disease
-- 226	Cure Poison
-- 227	Awaken
-- 228	Haste
-- 229	Heroism
-- 230	Bless
-- 231	Preservation
-- 232	Shield
-- 233	Recharge Item
-- 234	Stoneskin
-- 235	Water Breathing
-- 236	Harden Item
-- 237	Remove Fear
-- 238	Remove Curse
-- 239	Cure Insanity
-- 240	Might Boost
-- 241	Intellect Boost
-- 242	Personality Boost
-- 243	Endurance Boost
-- 244	Speed Boost
-- 245	Accuracy Boost
-- 246	Flaming Potion
-- 247	Freezing Potion
-- 248	Noxious Potion
-- 249	Shocking Potion
-- 250	Swift Potion
-- 251	Cure Paralysis
-- 252	Divine Restoration
-- 253	Divine Cure
-- 254	Divine Power
-- 255	Luck Boost
-- 256	Fire Resistance
-- 257	Air Resistance
-- 258	Water Resistance
-- 259	Earth Resistance
-- 260	Mind Resistance
-- 261	Body Resistance
-- 262	Stone to Flesh
-- 263	Slaying Potion
-- 264	Pure Luck
-- 265	Pure Speed
-- 266	Pure Intellect
-- 267	Pure Endurance
-- 268	Pure Personality
-- 269	Pure Accuracy
-- 270	Pure Might
-- 271	Rejuvenation

itemEquipStat = {
    [1] = 0,
    [2] = 1,
    [3] = 2,
    [4] = 3,
    [5] = 4,
    [6] = 5,
    [7] = 6,
    [8] = 7,
    [9] = 8,
    [10] = 9,
    [11] = 10,
    [12] = 11,
    [13] = 12,
    [14] = 13,
    [15] = 14,
    [16] = 15
}
itemSizeMap = {
    [1] = {1, 5},
    [2] = {1, 6},
    [3] = {1, 5},
    [4] = {1, 5},
    [5] = {1, 6},
    [6] = {1, 6},
    [7] = {2, 6},
    [8] = {2, 6},
    [9] = {1, 5},
    [10] = {1, 5},
    [11] = {1, 5},
    [12] = {1, 4},
    [13] = {1, 5},
    [14] = {1, 5},
    [15] = {1, 3},
    [16] = {1, 3},
    [17] = {1, 3},
    [18] = {1, 3},
    [19] = {1, 3},
    [20] = {1, 4},
    [21] = {1, 3},
    [22] = {1, 4},
    [23] = {1, 4},
    [24] = {2, 4},
    [25] = {1, 4},
    [26] = {1, 5},
    [27] = {2, 5},
    [28] = {2, 7},
    [29] = {2, 9},
    [30] = {1, 9},
    [31] = {1, 8},
    [32] = {1, 9},
    [33] = {1, 9},
    [34] = {1, 9},
    [35] = {1, 9},
    [36] = {2, 9},
    [37] = {2, 9},
    [38] = {2, 9},
    [39] = {1, 8},
    [40] = {1, 9},
    [41] = {2, 9},
    [42] = {2, 7},
    [43] = {2, 7},
    [44] = {2, 7},
    [45] = {2, 7},
    [46] = {3, 6},
    [47] = {2, 6},
    [48] = {1, 4},
    [49] = {2, 4},
    [50] = {1, 4},
    [51] = {1, 4},
    [52] = {1, 4},
    [53] = {1, 4},
    [54] = {2, 4},
    [55] = {1, 4},
    [56] = {2, 4},
    [57] = {2, 4},
    [58] = {1, 5},
    [59] = {1, 4},
    [60] = {1, 4},
    [61] = {1, 8},
    [62] = {1, 9},
    [63] = {1, 9},
    [64] = {1, 2},
    [65] = {1, 4},
    [66] = {3, 4},
    [67] = {3, 4},
    [68] = {3, 3},
    [69] = {3, 4},
    [70] = {4, 3},
    [71] = {3, 5},
    [72] = {3, 5},
    [73] = {3, 5},
    [74] = {4, 4},
    [75] = {3, 5},
    [76] = {4, 3},
    [77] = {4, 4},
    [78] = {4, 4},
    [79] = {3, 4},
    [80] = {3, 4},
    [81] = {3, 6},
    [82] = {3, 6},
    [83] = {3, 5},
    [84] = {2, 2},
    [85] = {3, 3},
    [86] = {3, 3},
    [87] = {3, 3},
    [88] = {3, 4},
    [89] = {1, 2},
    [90] = {1, 1},
    [91] = {2, 2},
    [92] = {2, 2},
    [93] = {2, 2},
    [94] = {2, 2},
    [95] = {2, 1},
    [96] = {1, 1},
    [97] = {2, 1},
    [98] = {2, 2},
    [99] = {2, 2},
    [100] = {2, 1},
    [101] = {2, 1},
    [102] = {2, 1},
    [103] = {2, 1},
    [104] = {2, 1},
    [105] = {2, 1},
    [106] = {2, 1},
    [107] = {2, 1},
    [108] = {2, 1},
    [109] = {2, 1},
    [110] = {1, 2},
    [111] = {1, 2},
    [112] = {1, 2},
    [113] = {1, 2},
    [114] = {1, 2},
    [115] = {2, 2},
    [116] = {2, 2},
    [117] = {3, 3},
    [118] = {2, 3},
    [119] = {2, 3},
    [120] = {1, 1},
    [121] = {1, 1},
    [122] = {1, 1},
    [123] = {1, 1},
    [124] = {1, 1},
    [125] = {1, 1},
    [126] = {1, 1},
    [127] = {1, 1},
    [128] = {1, 1},
    [129] = {1, 1},
    [130] = {1, 2},
    [131] = {1, 1},
    [132] = {1, 2},
    [133] = {1, 1},
    [134] = {1, 1},
    [135] = {1, 4},
    [136] = {1, 4},
    [137] = {1, 4},
    [138] = {1, 4},
    [139] = {1, 4},
    [140] = {1, 5},
    [141] = {1, 5},
    [142] = {1, 5},
    [143] = {1, 5},
    [144] = {1, 5},
    [145] = {1, 4},
    [146] = {1, 4},
    [147] = {1, 4},
    [148] = {1, 4},
    [149] = {1, 4},
    [150] = {1, 4},
    [151] = {1, 4},
    [152] = {1, 4},
    [153] = {1, 4},
    [154] = {1, 4},
    [155] = {2, 5},
    [156] = {2, 5},
    [157] = {2, 5},
    [158] = {2, 5},
    [159] = {2, 5},
    [160] = {2, 2},
    [161] = {2, 2},
    [162] = {2, 2},
    [163] = {2, 2},
    [164] = {2, 2},
    [165] = {2, 2},
    [166] = {2, 2},
    [167] = {2, 2},
    [168] = {2, 2},
    [169] = {2, 2},
    [170] = {2, 2},
    [171] = {2, 2},
    [172] = {2, 2},
    [173] = {2, 2},
    [174] = {2, 2},
    [175] = {2, 2},
    [176] = {2, 2},
    [177] = {2, 2},
    [178] = {2, 2},
    [179] = {2, 2},
    [180] = {2, 2},
    [181] = {2, 2},
    [182] = {2, 2},
    [183] = {2, 2},
    [184] = {2, 2},
    [185] = {2, 2},
    [186] = {1, 1},
    [187] = {1, 1},
    [188] = {1, 1},
    [189] = {1, 1},
    [190] = {1, 1},
    [191] = {1, 1},
    [192] = {1, 1},
    [193] = {1, 1},
    [194] = {1, 1},
    [195] = {1, 1},
    [196] = {1, 1},
    [197] = {2, 1},
    [198] = {3, 1},
    [199] = {3, 2},
    [200] = {1, 1},
    [201] = {1, 1},
    [202] = {1, 2},
    [203] = {1, 1},
    [204] = {1, 1},
    [205] = {1, 1},
    [206] = {1, 1},
    [207] = {1, 2},
    [208] = {1, 1},
    [209] = {1, 1},
    [210] = {1, 1},
    [211] = {1, 2},
    [212] = {1, 1},
    [213] = {1, 1},
    [214] = {1, 2},
    [215] = {1, 1},
    [216] = {1, 1},
    [217] = {1, 2},
    [218] = {1, 2},
    [219] = {1, 1},
    [220] = {1, 2},
    [221] = {1, 2},
    [222] = {1, 2},
    [223] = {1, 2},
    [224] = {1, 2},
    [225] = {1, 2},
    [226] = {1, 2},
    [227] = {1, 2},
    [228] = {1, 2},
    [229] = {1, 2},
    [230] = {1, 2},
    [231] = {1, 2},
    [232] = {1, 2},
    [233] = {1, 2},
    [234] = {1, 2},
    [235] = {1, 2},
    [236] = {1, 2},
    [237] = {1, 2},
    [238] = {1, 2},
    [239] = {1, 2},
    [240] = {1, 2},
    [241] = {1, 2},
    [242] = {1, 2},
    [243] = {1, 2},
    [244] = {1, 2},
    [245] = {1, 2},
    [246] = {1, 2},
    [247] = {1, 2},
    [248] = {1, 2},
    [249] = {1, 2},
    [250] = {1, 2},
    [251] = {1, 2},
    [252] = {1, 2},
    [253] = {1, 2},
    [254] = {1, 2},
    [255] = {1, 2},
    [256] = {1, 2},
    [257] = {1, 2},
    [258] = {1, 2},
    [259] = {1, 2},
    [260] = {1, 2},
    [261] = {1, 2},
    [262] = {1, 2},
    [263] = {1, 2},
    [264] = {1, 2},
    [265] = {1, 2},
    [266] = {1, 2},
    [267] = {1, 2},
    [268] = {1, 2},
    [269] = {1, 2},
    [270] = {1, 2},
    [271] = {1, 2},
    [272] = {2, 2},
    [273] = {2, 2},
    [274] = {2, 2},
    [275] = {2, 2},
    [276] = {2, 2},
    [277] = {2, 2},
    [278] = {2, 2},
    [279] = {2, 2},
    [280] = {2, 2},
    [281] = {2, 2},
    [282] = {2, 2},
    [283] = {2, 2},
    [284] = {2, 2},
    [285] = {2, 2},
    [286] = {2, 2},
    [287] = {2, 2},
    [288] = {2, 2},
    [289] = {2, 2},
    [290] = {2, 2},
    [291] = {2, 2},
    [292] = {2, 2},
    [293] = {2, 2},
    [294] = {2, 2},
    [295] = {2, 2},
    [296] = {2, 2},
    [297] = {2, 2},
    [298] = {2, 2},
    [299] = {2, 2},
    [300] = {2, 1},
    [301] = {2, 1},
    [302] = {2, 1},
    [303] = {2, 1},
    [304] = {2, 1},
    [305] = {2, 1},
    [306] = {2, 1},
    [307] = {2, 1},
    [308] = {2, 1},
    [309] = {2, 1},
    [310] = {2, 1},
    [311] = {2, 1},
    [312] = {2, 1},
    [313] = {2, 1},
    [314] = {2, 1},
    [315] = {2, 1},
    [316] = {2, 1},
    [317] = {2, 1},
    [318] = {2, 1},
    [319] = {2, 1},
    [320] = {2, 1},
    [321] = {2, 1},
    [322] = {2, 1},
    [323] = {2, 1},
    [324] = {2, 1},
    [325] = {2, 1},
    [326] = {2, 1},
    [327] = {2, 1},
    [328] = {2, 1},
    [329] = {2, 1},
    [330] = {2, 1},
    [331] = {2, 1},
    [332] = {2, 1},
    [333] = {2, 1},
    [334] = {2, 1},
    [335] = {2, 1},
    [336] = {2, 1},
    [337] = {2, 1},
    [338] = {2, 1},
    [339] = {2, 1},
    [340] = {2, 1},
    [341] = {2, 1},
    [342] = {2, 1},
    [343] = {2, 1},
    [344] = {2, 1},
    [345] = {2, 1},
    [346] = {2, 1},
    [347] = {2, 1},
    [348] = {2, 1},
    [349] = {2, 1},
    [350] = {2, 1},
    [351] = {2, 1},
    [352] = {2, 1},
    [353] = {2, 1},
    [354] = {2, 1},
    [355] = {2, 1},
    [356] = {2, 1},
    [357] = {2, 1},
    [358] = {2, 1},
    [359] = {2, 1},
    [360] = {2, 1},
    [361] = {2, 1},
    [362] = {2, 1},
    [363] = {2, 1},
    [364] = {2, 1},
    [365] = {2, 1},
    [366] = {2, 1},
    [367] = {2, 1},
    [368] = {2, 1},
    [369] = {2, 1},
    [370] = {2, 1},
    [371] = {2, 1},
    [372] = {2, 1},
    [373] = {2, 1},
    [374] = {2, 1},
    [375] = {2, 1},
    [376] = {2, 1},
    [377] = {2, 1},
    [378] = {2, 1},
    [379] = {2, 1},
    [380] = {2, 1},
    [381] = {2, 1},
    [382] = {2, 1},
    [383] = {2, 1},
    [384] = {2, 1},
    [385] = {2, 1},
    [386] = {2, 1},
    [387] = {2, 1},
    [388] = {2, 1},
    [389] = {2, 1},
    [390] = {2, 1},
    [391] = {2, 1},
    [392] = {2, 1},
    [393] = {2, 1},
    [394] = {2, 1},
    [395] = {2, 1},
    [396] = {2, 1},
    [397] = {2, 1},
    [398] = {2, 1},
    [399] = {2, 2},
    [400] = {2, 2},
    [401] = {2, 2},
    [402] = {2, 2},
    [403] = {2, 2},
    [404] = {2, 2},
    [405] = {2, 2},
    [406] = {2, 2},
    [407] = {2, 2},
    [408] = {2, 2},
    [409] = {2, 2},
    [410] = {2, 2},
    [411] = {2, 2},
    [412] = {2, 2},
    [413] = {2, 2},
    [414] = {2, 2},
    [415] = {2, 2},
    [416] = {2, 2},
    [417] = {2, 2},
    [418] = {2, 2},
    [419] = {2, 2},
    [420] = {2, 2},
    [421] = {2, 2},
    [422] = {2, 2},
    [423] = {2, 2},
    [424] = {2, 2},
    [425] = {2, 2},
    [426] = {2, 2},
    [427] = {2, 2},
    [428] = {2, 2},
    [429] = {2, 2},
    [430] = {2, 2},
    [431] = {2, 2},
    [432] = {2, 2},
    [433] = {2, 2},
    [434] = {2, 2},
    [435] = {2, 2},
    [436] = {2, 2},
    [437] = {2, 2},
    [438] = {2, 2},
    [439] = {2, 2},
    [440] = {2, 2},
    [441] = {2, 2},
    [442] = {2, 2},
    [443] = {2, 2},
    [444] = {2, 2},
    [445] = {2, 2},
    [446] = {2, 2},
    [447] = {2, 2},
    [448] = {2, 2},
    [449] = {2, 2},
    [450] = {2, 2},
    [451] = {2, 2},
    [452] = {2, 2},
    [453] = {2, 2},
    [454] = {2, 2},
    [455] = {2, 2},
    [456] = {2, 2},
    [457] = {2, 2},
    [458] = {2, 2},
    [459] = {2, 2},
    [460] = {2, 2},
    [461] = {2, 2},
    [462] = {2, 2},
    [463] = {2, 2},
    [464] = {2, 2},
    [465] = {2, 2},
    [466] = {2, 2},
    [467] = {2, 2},
    [468] = {2, 2},
    [469] = {2, 2},
    [470] = {2, 2},
    [471] = {2, 2},
    [472] = {2, 2},
    [473] = {2, 2},
    [474] = {2, 2},
    [475] = {2, 2},
    [476] = {2, 2},
    [477] = {2, 2},
    [478] = {2, 2},
    [479] = {2, 2},
    [480] = {2, 2},
    [481] = {2, 2},
    [482] = {2, 2},
    [483] = {2, 2},
    [484] = {2, 2},
    [485] = {2, 2},
    [486] = {2, 2},
    [487] = {2, 2},
    [488] = {2, 2},
    [489] = {2, 2},
    [490] = {2, 2},
    [491] = {2, 2},
    [492] = {2, 2},
    [493] = {2, 2},
    [494] = {2, 2},
    [495] = {2, 2},
    [496] = {2, 2},
    [497] = {2, 2},
    [498] = {2, 2},
    [499] = {2, 2},
    [500] = {2, 6},
    [501] = {1, 6},
    [502] = {1, 5},
    [503] = {1, 5},
    [504] = {3, 5},
    [505] = {4, 4},
    [506] = {2, 4},
    [507] = {3, 9},
    [508] = {1, 9},
    [509] = {2, 9},
    [510] = {2, 8},
    [511] = {1, 2},
    [512] = {3, 3},
    [513] = {1, 1},
    [514] = {1, 4},
    [515] = {2, 9},
    [516] = {4, 3},
    [517] = {1, 3},
    [518] = {2, 5},
    [519] = {4, 4},
    [520] = {3, 3},
    [521] = {2, 2},
    [522] = {2, 2},
    [523] = {2, 2},
    [524] = {2, 1},
    [525] = {2, 1},
    [526] = {2, 4},
    [527] = {2, 4},
    [528] = {2, 4},
    [529] = {2, 1},
    [530] = {2, 1},
    [531] = {2, 6},
    [532] = {2, 2},
    [533] = {3, 5},
    [534] = {1, 2},
    [535] = {2, 1},
    [536] = {1, 1},
    [537] = {1, 1},
    [538] = {1, 5},
    [539] = {1, 1},
    [540] = {1, 3},
    [541] = {1, 6},
    [542] = {2, 7},
    [543] = {2, 7},
    [544] = {2, 2},
    [545] = {1, 1},
    [546] = {1, 1},
    [547] = {2, 1},
    [548] = {2, 1},
    [549] = {1, 9},
    [550] = {2, 1},
    [551] = {2, 5},
    [552] = {1, 5},
    [553] = {2, 2},
    [554] = {2, 2},
    [555] = {2, 2},
    [556] = {2, 2},
    [557] = {2, 2},
    [558] = {2, 2},
    [559] = {2, 2},
    [560] = {2, 2},
    [561] = {2, 2},
    [562] = {2, 2},
    [563] = {2, 2},
    [564] = {2, 2},
    [565] = {2, 2},
    [566] = {2, 2},
    [567] = {2, 2},
    [568] = {2, 2},
    [569] = {2, 2},
    [570] = {2, 6},
    [571] = {2, 2},
    [572] = {2, 2},
    [573] = {2, 2},
    [574] = {2, 2},
    [575] = {2, 2},
    [576] = {2, 2},
    [577] = {2, 2},
    [578] = {2, 2},
    [579] = {2, 2},
    [580] = {2, 2},
    [581] = {2, 2},
    [582] = {2, 2},
    [583] = {2, 2},
    [584] = {2, 2},
    [585] = {2, 2},
    [586] = {2, 2},
    [587] = {2, 2},
    [588] = {2, 2},
    [589] = {2, 2},
    [590] = {2, 2},
    [591] = {2, 2},
    [592] = {2, 2},
    [593] = {2, 2},
    [594] = {2, 2},
    [595] = {2, 2},
    [596] = {2, 2},
    [597] = {2, 2},
    [598] = {2, 2},
    [599] = {2, 2},
    [600] = {1, 1},
    [601] = {1, 2},
    [602] = {4, 3},
    [603] = {1, 2},
    [604] = {3, 4},
    [605] = {1, 2},
    [606] = {1, 1},
    [607] = {2, 2},
    [608] = {2, 2},
    [609] = {2, 2},
    [610] = {2, 2},
    [611] = {2, 2},
    [612] = {2, 2},
    [613] = {2, 2},
    [614] = {2, 2},
    [615] = {1, 2},
    [616] = {2, 1},
    [617] = {1, 2},
    [618] = {2, 2},
    [619] = {2, 4},
    [620] = {2, 7},
    [621] = {2, 3},
    [622] = {2, 3},
    [623] = {2, 3},
    [624] = {1, 2},
    [625] = {1, 2},
    [626] = {1, 1},
    [627] = {2, 1},
    [628] = {1, 2},
    [629] = {1, 2},
    [630] = {1, 1},
    [631] = {2, 2},
    [632] = {2, 4},
    [633] = {2, 2},
    [634] = {1, 3},
    [635] = {2, 1},
    [636] = {2, 1},
    [637] = {2, 1},
    [638] = {2, 2},
    [639] = {3, 2},
    [640] = {2, 2},
    [641] = {2, 2},
    [642] = {4, 1},
    [643] = {4, 1},
    [644] = {3, 1},
    [645] = {3, 1},
    [646] = {1, 1},
    [647] = {1, 1},
    [648] = {1, 2},
    [649] = {2, 2},
    [650] = {2, 2},
    [651] = {1, 1},
    [652] = {1, 2},
    [653] = {1, 2},
    [654] = {1, 2},
    [655] = {1, 2},
    [656] = {1, 2},
    [657] = {1, 2},
    [658] = {3, 4},
    [659] = {1, 2},
    [660] = {1, 2},
    [661] = {1, 2},
    [662] = {1, 2},
    [663] = {1, 2},
    [664] = {1, 2},
    [665] = {1, 2},
    [666] = {1, 2},
    [667] = {1, 2},
    [668] = {1, 2},
    [669] = {1, 2},
    [670] = {1, 2},
    [671] = {2, 2},
    [672] = {2, 2},
    [673] = {2, 1},
    [674] = {2, 1},
    [675] = {1, 1},
    [676] = {1, 2},
    [677] = {1, 2},
    [678] = {2, 1},
    [679] = {2, 1},
    [680] = {2, 1},
    [681] = {2, 1},
    [682] = {2, 1},
    [683] = {2, 1},
    [684] = {2, 1},
    [685] = {2, 1},
    [686] = {1, 1},
    [687] = {1, 1},
    [688] = {1, 1},
    [689] = {1, 1},
    [690] = {1, 1},
    [691] = {1, 1},
    [692] = {4, 3},
    [693] = {4, 3},
    [694] = {4, 3},
    [695] = {4, 3},
    [696] = {4, 3},
    [697] = {4, 3},
    [698] = {2, 1},
    [699] = {2, 1},
    [700] = {2, 1},
    [701] = {2, 1},
    [702] = {2, 1},
    [703] = {2, 1},
    [704] = {2, 1},
    [705] = {2, 1},
    [706] = {2, 1},
    [707] = {2, 1},
    [708] = {2, 1},
    [709] = {2, 1},
    [710] = {2, 1},
    [711] = {2, 1},
    [712] = {2, 1},
    [713] = {2, 1},
    [714] = {2, 1},
    [715] = {2, 1},
    [716] = {2, 1},
    [717] = {2, 1},
    [718] = {2, 1},
    [719] = {2, 1},
    [720] = {2, 1},
    [721] = {2, 1},
    [722] = {2, 1},
    [723] = {2, 1},
    [724] = {2, 1},
    [725] = {2, 1},
    [726] = {2, 1},
    [727] = {2, 1},
    [728] = {2, 1},
    [729] = {2, 1},
    [730] = {2, 1},
    [731] = {2, 1},
    [732] = {2, 1},
    [733] = {2, 1},
    [734] = {2, 1},
    [735] = {2, 1},
    [736] = {2, 1},
    [737] = {2, 1},
    [738] = {2, 1},
    [739] = {2, 1},
    [740] = {2, 1},
    [741] = {2, 1},
    [742] = {2, 1},
    [743] = {2, 1},
    [744] = {2, 1},
    [745] = {2, 1},
    [746] = {2, 1},
    [747] = {2, 1},
    [748] = {2, 1},
    [749] = {2, 1},
    [750] = {2, 1},
    [751] = {2, 1},
    [752] = {2, 1},
    [753] = {2, 1},
    [754] = {2, 1},
    [755] = {2, 1},
    [756] = {2, 1},
    [757] = {2, 1},
    [758] = {2, 1},
    [759] = {2, 1},
    [760] = {2, 1},
    [761] = {2, 1},
    [762] = {2, 1},
    [763] = {2, 1},
    [764] = {2, 1},
    [765] = {2, 1},
    [766] = {2, 1},
    [767] = {2, 1},
    [768] = {2, 1},
    [769] = {2, 1},
    [770] = {2, 1},
    [771] = {2, 1},
    [772] = {2, 1},
    [773] = {2, 1},
    [774] = {2, 1},
    [775] = {2, 1},
    [776] = {2, 1},
    [777] = {2, 1},
    [778] = {2, 1},
    [779] = {2, 1},
    [780] = {2, 1},
    [781] = {2, 2},
    [782] = {2, 2},
    [783] = {2, 2},
    [784] = {2, 2},
    [785] = {2, 2},
    [786] = {2, 2},
    [787] = {2, 2},
    [788] = {2, 2},
    [789] = {2, 2},
    [790] = {2, 2},
    [791] = {2, 2},
    [792] = {2, 2},
    [793] = {2, 2},
    [794] = {2, 2},
    [795] = {2, 2},
    [796] = {2, 2},
    [797] = {2, 2},
    [798] = {2, 2}
}

-- Malekith's code for itemsize code creation
-- a=""
-- Mouse.Item.Number=1
-- for i=0,125 do
--     Party[0].Inventory[i]=0
-- end
-- for i=1,Game.ItemsTxt.High-1 do

--     evt.Add("Items", i+1)
--     x=0
--     y=0
--     while x<14 and Party[0].Inventory[x]~=0 do
--         x=x+1
--     end
--     while y<9 and Party[0].Inventory[y*14]~=0 do
--         y=y+1
--     end
--     a=string.format(a .. "    [" .. i .. "]" .. "={" .. x .. "," .. y .. "},\n")
--     for i=0,125 do
--         Party[0].Inventory[i]=0
--     end
--     for i=1,138 do
--         Party[0].Items[i].Number=0
--     end
-- end
-- Mouse.Item.Number=0
-- debug.Message(a)
