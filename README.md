[![english](https://img.shields.io/badge/lang-English-green.svg)](https://github.com/torkvato/CombatStats-MM7-mod/blob/master/README.md)
[![russian](https://img.shields.io/badge/lang-Russian-red.svg)](https://github.com/torkvato/CombatStats-MM7-mod/blob/master/README.ru.md)
[![MM6](https://img.shields.io/badge/MM6 version-yellow.svg)](https://github.com/torkvato/CombatStats-MM6-mod)

# CombatStats and Convenience MM7 mod

## Mod features
CombatStats and Convenience MM7 mod do not affect the gameplay, the game mechanics or difficulties of the original game. \
Mod requires Grayface's patch and MMExtension, but adds nothing changing the game over this  
Mod can work with any saved game, no need to start a new. Saves will be intact if you remove the mod (but why?).\
Basically,it is the same good old vanilla Might and Magic 7, without any attempts to make the eternal classic more difficult/interesting/new.

However, for the convenience and in-depth analyis of the party the following features were introduced:

- **Classic Combat log file**
    - Logging every damage dealt (and received), with the timestamp, player, target, damage amount, kind and source (melee, ranged or specific spell)
    - CSV save format, customizable
    - You can do you own parsing and processing, but essential things already implemented in-game
- **In-game combat history**
    -  MM9-style, showing the details of the last dozen party/monsters hits
    -  Colored for ease of use
- **In-game damage statistics processing**
    - Accumulation of the damage data such as total damage dealt and average [observed] DPS for melee/ranged/magic
    - In-game tables for party members efficiency comparison
    - Selected segment / current map / overall game data in separate tables
    - Export of the statistics to the output file for future reference
- **Enhanced character page**
    - Barrel-Colored Attributes (thx MAW) with current modifier value and next attribute milestone in the tooltip
    - Elements-Colored Resistances with average resistance percentage and "bad things" chances
    - Final Melee and Ranged damage metric in the form of thoroughly [calculated] DPS, for best weapon combination selection
    - Effective health ("Vitality"), employing HP, Armor Class (physical avoidance) and Magic resistances in single metric
    - Skill tooltips, like total Merchant discount or current Disarm skill vs. area difficulty [Optional]   
- **Convenience features**	
    - Automatic items sorting. Borrowed from MAW MMMerge mod, with minor changes (alchemy/unidentified items sorting). 
    - Full Travel Schedule / World map / Teachers / Alchemy Recipes table in Autonotes (Seer tab) [Optional]	
    - Sharing max ID Item and Repair skills over the party [Optional]
    - Grandmaster ID Monster info with ALT pressed [Optional]
    - Buff expiration alert (No more weakness from missed Haste) [Optional]

## Installation
 - MM7 GOG version (do not forget to set WinXP compatibility options)
 - Grayface latest MM7 patch (tested for 2.5.7): https://grayface.github.io/mm/#GrayFace-MM7-Patch
 - Unreleased MMExtension v2.3: https://github.com/GrayFace/MMExtension 
 - This mod. Latest version in the repository
 
Instead of two last steps, one can download whole package with last stable release\
**https://drive.google.com/file/d/1d-jrk6c59oIQVuf44gHe7W3GgHkodMEo**
  
**Important note: since minor fixes still issued, it is recommended to download latest version from repository, even if you downloaded full package**
- Uninstall: run ccUninst.bat in Scripts folder. The game flow is not affected by mod installation and deinstallation
- Bug reportin and support in the TG group - https://t.me/+WAc2jt1nvT1iMzIy


**Configuration**
You can check the available config options in the Scripts/General/ccInit.lua file

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

Since the game treat each case of damage separately, hitting with elementrary enchanted weapon will give two lines in combat log. Same with Shotgun/AoE spells (except Armageddon)

### In-game combat history
Besides output to the file, damage done and received can be viewed in MM9-style combat history (default key -[H] )
In-game combat log have less field due to lack of space, but currently shows the mod level for reference

![image](https://github.com/user-attachments/assets/9d772466-850e-4028-a236-58e3fd3a6d5c)

### Combat statists
**Damage done**\
Mod accumulates and stores damage dealt by party and monsters.\
Damage divided in the three categories: *Melee*, *Ranged* (bows and blasters) and *Spell*, each category processed individually per party member.

Also, there are three distinct accumulation pools: 
- Map/location data: specific for certain indoor/outdoor area, persists till map respawn (in 2 years or so)
- Full data: Overall stats from the very beginning
- Segment data: statistics since last manual reset ([R] in Character page)

Statistics summaries can be accessed by [Right=click] in the DPS/Vitality area of Character page\
Here you also can [E]xport this tables in the file for further usage.


**Observed DPS**\
DPS, or damage per second is the most important metric of the combat proficiency. Here we calculate is by a total damage inflicted by the player, divided by the total active time\
Calculation of active time can be tricky and controversial. Currently, active time is calculated from the first successful hit and ended if there are no successful hits within 5seconds.
DPS is calculated for each party member independently and over the same three data accumulation pools: map, full, and resettable segment.

![image](https://github.com/user-attachments/assets/fc77963c-196b-4448-b2b7-a148eb8a0734)

**Damage taken**
Damage taken per each party member is accumulated over map/full game/segment and shoun in one of the [ALT-Click] tables.
Currently it is divided between melee/ranged/spell.

Only damage originated from monsters (and fellow casters) is counted. 
Traps and fall damage have no "author" and is not [yet] included in the statictic.

**Records**
Mod will record best hits with melee, ranged and magic separately (also, independently for three data sets: map, full and segment)\
To overcome the problem of several damage kinds/several damage sources per hit, accumulation logic is added.\
Damage counted as one hit if it happens in the same timestamp, done by same player and against monster with the same name.\
So melee hit with Phys+Fire damage will be summed, Fireball against group of same-named monsters will be summed but againt group of different monsters not.

### Calculated statistics
**Damage per second, DPS**
- Hit percentage is calculated on the base of current To-Hit modifier against the mob with AC equal to the current player level\
 *P = (15 + PlayerAttack * 2) / (30 + PlayerAttack * 2 + AC)*\
For the calculation, we use rough monster progress skaling, and their AC (and Lvl) assumed to be 3x Party Lvl (but not larger than 100)

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
  
![image](https://github.com/user-attachments/assets/af850de2-4130-4086-9869-45d0ba30b621)

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
Each section can be independently enabled/disabled in the Scripts/ccInit.lua file.

**Id item and Repair skill share**

**Buffs expiration alarm**
List of tracked buffs can be configured in Scripts/ccInit.lua
Refer https://grayface.github.io/mm/ext/ref/#const.PartyBuff and https://grayface.github.io/mm/ext/ref/#const.PlayerBuff for exact name reference

**Simple alarm clock**
Set it in the init file with the simple 24h format, for example, "17:30". Leave it empty "" to disable

## Default keybinds

**Combat history**\
[H], as it was in MM9. This overlaps Wendell Tweed history notes, so if you really need his works, you can access them through book or rebind the key in the Menu
**Damage statistics**\
[Right-click] in the Player Stats screen: clicking on DPS stat will lead to segment data, clicking on Vitality will lead to map data\
[ALT]+[Right-click] lead to Full stat since the beginning of the game\
[E] followed by [Y] for export of the tables to file\
[R] followed by [Y] for segment data reset\
**Inventory management**\
[R] for sorting current player inventory\
[T] for sorting party inventory\
[Y] for select/unselect designated player for Alchemy\
[U] for select/unselect designated player for Unidentified items\
**Extra Notes**\
[N] Extra notes added to the Seer tab in Autonotes
- Travel schedule
- World Map
- Teachers table
- Alchemy recipes

**ID Monster**\
If corresponding option in mild cheats section is enabled, [ALT] while checking monster stats will give full GM information
![изображение](https://github.com/user-attachments/assets/3dab06e0-7dfb-44da-a8cd-d3c2e0be0c9f)

