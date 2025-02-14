[![english](https://img.shields.io/badge/lang-English-green.svg)](https://github.com/torkvato/CombatStats-MM7-mod/blob/master/README.md)
[![russian](https://img.shields.io/badge/lang-Russian-red.svg)](https://github.com/torkvato/CombatStats-MM7-mod/blob/master/README.ru.md)

# CombatStats and Convenience MM6-7 mod

## Mod features
CombatStats and Convenience MM67 mod do not affect the gameplay, the game mechanics or difficulties of the original game. \
Mod requires Grayface's patch and MMExtension, but adds nothing changing the game over this  
Mod can work with any saved game, no need to start a new. Saves will be intact if you remove the mod (but why?).\
Basically,it is the same good old vanilla Might and Magic 6/7, without any attempts to make the eternal classic more difficult/interesting/new.\
Mod works both on MM6 and MM7, with minor differences in features.
Mod introduces:

- **Classic Combat log file**
    - Logging every damage dealt (and received), with the timestamp, player, target, damage amount, kind and source (melee, ranged or specific spell)
    - CSV save format, customizable
    - You can do you own parsing and processing, but essential things already implemented in-game
    - You can manually set up different log files for different save games
- **In-game combat history**
    -  MM9-style, showing the details of the last dozen party/monsters hits
    -  Colored for ease of use
- **In-game damage statistics processing**
    - Accumulation of the damage data such as total damage dealt and received and average [observed] DPS for melee/ranged/magic
    - In-game tables for party members efficiency comparison
    - Selected segment / current map / overall game data in separate tables
    - Export of the statistics to the output file for future reference
- **Enhanced tooltips/info**
    - Barrel-Colored Attributes (thx MAW) with current modifier value and next attribute milestone in the tooltip
    - Elements-Colored Resistances with average resistance percentage and "bad things" chances
    - Final Melee and Ranged damage metric in the form of thoroughly [calculated] DPS, for best weapon combination selection
    - Effective health ("Vitality"), employing HP, Armor Class (physical avoidance) and Magic resistances in single metric
    - Skill tooltips, like total Merchant discount or current Disarm skill vs. area difficulty [Optional]
    - Average damage/healing, damager mana/damager per second in the SpellBook
- **Convenience features**	
    - Automatic items sorting. Borrowed from MAW MMMerge mod, with minor changes (alchemy/unidentified items sorting). 
    - Full Travel Schedule / World map / Teachers / Alchemy Recipes table in Autonotes (Seer tab) [Optional]	
    - Sharing max ID Item skill party [Optional]
    - Sharing Repair skill or even automatic repair with sufficient skill [Optional]
    - ID monser feature for MM6, Grandmaster ID Monster info with ALT pressed for MM7 [Optional]
    - Buff expiration alert (No more weakness from missed Haste) [Optional]
    - Alarm clock
    - [Some additional useful feaures, undisclosed]

## Installation
 - MM6/MM7 GOG version (do not forget to set WinXP compatibility options)
 - Grayface latest MM6/MM7 patch (tested for 2.5.7):
   - https://grayface.github.io/mm/#GrayFace-MM6-Patch
   - https://grayface.github.io/mm/#GrayFace-MM7-Patch
       
 - Unreleased MMExtension v2.3: https://github.com/GrayFace/MMExtension 
 - This mod. Latest version in the repository
 
Instead of two last steps, one can download whole package with last stable release\
**https://drive.google.com/file/d/1PTUgZI5dy_-i55jeMWRD7cmfDV2XDPN6**
  
**Important note: since minor fixes still issued, it is recommended to download latest version from repository, even if you downloaded full package**
- Uninstall: run ccUninst.bat in Scripts folder. The game flow is not affected by mod installation and deinstallation
- Bug reporting and support in the TG group - https://t.me/+WAc2jt1nvT1iMzIy


**Configuration**
You can check the available config options in the Scripts/Global/ccInit.lua file

## Acknowledgments
This mod is the fulfillment of a long-standing dream, a dream to see in detail what is happening with a team of heroes, a dream to get real data for endless debates about who is better.\
For a long time, I had no idea how to approach this task, until I saw the MAW mod\
https://github.com/malekitsu/maw-mod-mmmerge

and fall into it's thrill enjoying both gameplay and new knowledges about modding.

The MAW mod developed by **Malekith** and his team was simply a revelation for me.
From there I borrowed many things that first appeared in MAW - attributes colors, display of DPS and Vitality stats and, of course, the wonderful inventory auto-sort, without which I now simply cannot play.\
But direct code snatching was not the main thing - the MAW mod showed me that everything is possible, and showed how it can be done, peeking into its code I discovered for myself both Lua and MMExtension.

Another great person who actually made any MM modding possible and **Grayface**, author of MMExtension. We just cant underestimate his impact on the MM community, both modders and gamers.



## Detailed description

### Combat log
Enabling the combat log option will create the .csv file in the game directory, and log any [successful] hit in it.\
You can disable the combat log fully (CombatLogEnabled=0), log only party damage (CombatLogEnabled=1) and party and monsters damage (CombatLogEnabled=2)\
Also in config file you can specify the log separator, but changing the order and adding new data will require more detailed code changes

Combat log is constantly appended with new records, so it will keep everything even if you reload game or have a new party.\
Any log management should be done manually.

Fields are:
- Timestamp in game ticks. 256 ticks = 1 in-game minute = 2 realtime seconds = 120 "weapon recovery" points.
- Player# (0-3)
- Player class and lvl
- Player name 
- Hit direction indicator, point toward target
- Monster name
- Damage inflicted
- Damage kind (Fire, Air, Dark, etc)
- Damage source, either melee hit, ranged shoot (bow/blaster) or certain spell with its Skill and Mastery
- Hit outcome ("killed")

Since the game treat each case of damage separately, hitting with elementrary enchanted weapon will give two lines in combat log. Same with Shotgun/AoE spells (except Armageddon)

### In-game combat history
Besides output to the file, damage done and received can be viewed in MM9-style combat history (default key -[H] )

<center><img src="https://github.com/user-attachments/assets/9d772466-850e-4028-a236-58e3fd3a6d5c" alt="alt text" class="center" width="500"/></center>

### Combat statists
**Damage done**\
Mod accumulates and stores damage dealt by party and monsters.\
Damage divided in the three categories: *Melee*, *Ranged* (bows and blasters) and *Spell*, each category processed individually per party member.

Also, there are three distinct accumulation pools: 
- Map/location data: specific for certain indoor/outdoor area, persists till map respawn (in 2 years or so)
- Full data: Overall stats from the very beginning
- Segment data: statistics since last manual reset ([R] in Character page)

Statistics summaries can be accessed by [RightClick] in the "DPS" line of Character page\
Default is curren map data, [CTRL-RightClick] shows full game data, [ALT] for segment.
Here you also can [E]xport this tables in the file for further usage.

**Observed DPS**\
DPS, or damage per second is the most important metric of the combat proficiency. Here we calculate is by a total damage inflicted by the player, divided by the total active time\
Calculation of active time can be tricky and controversial. Currently, active time is calculated from the first successful hit and ended if there are no successful hits within 5seconds.
DPS is calculated for each party member independently and over the same three data accumulation pools: map, full, and resettable segment.

<img src="https://github.com/user-attachments/assets/fc77963c-196b-4448-b2b7-a148eb8a0734" alt="alt text" align="center" width="500"/>

**Damage taken**
Damage taken per each party member is accumulated over map/full game/segment and shown by [RightClick] on "Vitality" line
There is sorting by damage kind and also summary by party member.
Simularly, map-segment-full data is accessible with [ALT] and [CTRL]
Only damage originated from monsters (and fellow casters) and in-game traps (marked as "???") is counted. 
Chest traps and fall damage have no "author" and is not included in the statictic.

**Max Damage Records**
Mod will record best hits with melee, ranged and magic separately (also, independently for three data sets: map, full and segment)\
To overcome the problem of several damage kinds/several damage sources per hit, accumulation logic is added.\
Damage counted as one hit if it happens in the same timestamp by the same player several consequent hits.\
So melee hit with Phys+Elem damage will be summed, Fireball/Starburs against group of monsters will be accumulated.
Accessible by [RightClick] on the "Armor Class" line

<img src="https://github.com/user-attachments/assets/d948a054-1692-457a-b706-93c7b3841261" alt="alt text" class="center" width="500"/>


### Calculated statistics
**Damage per second, DPS**
For the calculation of the mobs armor class and level, we use rough monster progress scaling, and their AC/Lvl are assumed to be 3x Party Lvl (but not larger than 100)
- Hit percentage is calculated on the base of current To-Hit modifier against the mob AC
 *P = (15 + PlayerAttack * 2) / (30 + PlayerAttack * 2 + AC)*\

- Estimated DPS is calculated on the base average damage that take into account
    - Chance to miss
    - Weapons base damage with Str/Heroism already accounted (stated in the vanilla part of the char screen)
    - Constant and temporary elemental damage on both weapons (and artifacts/relics)
    - Dagger Mastery base damage tripling chance
    - Hammerhands buff\
    Things are not taken into account: Weakness, Racial featurs bonuses, Monster Resistances\
    Average Damage is divided by current Recovery value in seconds to get the final displayed DPS, that include all factors that affect damage output, and thus can be used for weapons comparison

**Vitality (Effective HP)**
Vitality is calculated by taking into account player physical hits avoidance chance (determined by AC) and magic resistances. 
Weights of the damage resistances are calculated on the base of the incoming damage analysis for the full game combat log with highly buffed party (light side TKPS)
To consider unavoidable damage types, like energy, dark and light, plain HP is also part of the final metric

<img src="https://github.com/user-attachments/assets/af850de2-4130-4086-9869-45d0ba30b621" alt="alt text" class="center" width="500"/>

## Inventory management
Very useful feature of the mod is one-button sorting of the whole party or single player inventory ([T] and [R] buttons)
Sorting rearrange the inventorty by putting largest items first and filling the gaps with smaller ones, allowing to free some space.
Additionally, one can set up designated player for alchemy-related items ([Y]).
Upon sorting, this player will get the following items in the following order:
1. Gear with +Alchemy bonus, if it is exist
2. Empty bottles, Catalyst bottles and all simple potions: R,B,Y,P,O,G
3. Catalysts in the order of increasing strenght
4. Ingredients in R-B-Y order
5. The rest of the potions - layered, white and black

If Alchemy player inventory is full (2 spaces is always saved), next player will get the items. For the last (fourth) player, next player will be the third

Those who do not want to use even "mild" cheats and share ID. Item skills among the party, can set player for them ([U])

## Additional convenience features

**Reference information**\
Useful information about game is summarized in the several convenient tables, including full Stables/Boats schedule, inter-regions travel map, techer locations (region only) and full Alchemy compendium.
Each section can be independently enabled/disabled in the Scripts/Global/ccInit.lua file.

<img src="https://github.com/user-attachments/assets/3dab06e0-7dfb-44da-a8cd-d3c2e0be0c9f" alt="alt text" class="center" width="500"/>

**Id item and Repair skill share**
Id and Repair skill is shared when you're in the inventory screen only.
Additionally, automatic repair can be enabled, repairing all items each regeneration tick. 
Appropriate message appears for the last item repaired.

**Buffs expiration alarm**
List of tracked buffs can be configured in Scripts/ccInit.lua
Refer https://grayface.github.io/mm/ext/ref/#const.PartyBuff and https://grayface.github.io/mm/ext/ref/#const.PlayerBuff for exact name reference

**Simple alarm clock**
Set it in the init file with the simple 24h format, for example, "17:30". Leave it empty "" to disable

**Training dummy**
[ALT-L] calls the training dummy in front of the party. 
Basically it is paralyzed monster with 32k HP, negative AC and zero resistances for sure hits.
Upon calling a dummy, combat log file is set to "cl_dummy.csv" to avoid interference with real game data. 
Note that if you save game after this, new name for combat log will be also saved, so dont save after calling a dummy unless you want to play with it more.

**Kill count**

<img src="https://github.com/user-attachments/assets/8d982ff7-f992-4d97-be5a-f388f1e4b57a" alt="alt text" class="center" width="500"/>

## Default keybinds

**Combat history**
- [H], as it was in MM9. This overlaps Wendell Tweed history notes, so if you really need his works, you can access them through book or rebind the key in the Menu
- [ALT-H] - Show kill count list on the screen (top 15 positions) and export whole killcount list to the killcount.txt in the game dir
- [CTRL-H] Runs the Lua parser that process the current csv log file
  
**Damage statistics**
- [Right-click] in the Player Stats screen: clicking on DPS stat will lead to segment data, clicking on Vitality will lead to map data\
- [ALT]+[Right-click] lead to Full stat since the beginning of the game
- [E] followed by [Y] for export of the tables to file
- [R] followed by [Y] for segment data reset
  
**Inventory management**
- [R] for sorting current player inventory
- [T] for sorting party inventory
- [Y] for select/unselect designated player for Alchemy
- [U] for select/unselect designated player for Unidentified items
  
**Extra Notes**
- [N] Extra notes added to the Seer tab in Autonotes
  - Travel schedule
  - World Map
  - Teachers table
  - Alchemy recipes

**ID Monster**
In MM7 [ALT] while checking monster stats will give full GM information

In MM6, pressing [G] while pointing to the monster will bring up similar (or even more detailed) table on the mob stats, resistances, damage and spells.

Both cheats can be fully disabled in the mild cheats section Scripts/Global/ccInit.lua

<img src="https://github.com/user-attachments/assets/fedc05cd-e62d-4b92-9ac0-c800243d727f" alt="alt text" class="center" width="500"/>


