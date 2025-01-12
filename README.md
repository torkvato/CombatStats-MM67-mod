# CombatStats and Convenience MM7 mod

## Mod features
CombatStats and Convenience MM7 mod do not affect the gameplay, the game mechanics or difficulties of the orignial game. \
Mod requires Grayface's patch and MMExtension, but adds nothing changing the game over this  
Mod can work with any saved game, no need to start a new. Saves will be intact if you remove mod (but why?).\
Basically,it is the same good old vanilla Might and Magic 7, without any attempts to make the eternal classic more difficult/interesting/new.

However, for the convenience and in-depth analyis of the party the following features were introduced:

- **Classic Combat log**
    - Logging every damage dealt (and received), with the timestamp, player, target, damage amount, kind and source (melee, ranged or specific spell)
    - CSV save format, customizable
    - You can do you own parsing and processing, but we already have some implemented in the mod for game stats
- **In-game mini combat log**
    -  MM9-style, showing the details of the last dozen party/monsters hits
    -  Colored for ease of use
- **In-game damage statistics processing**
    - Accumulation of the damage data such as total damage dealt and average [observed] DPS for melee/ranged/magic
    - In-game tables for party members efficiency comparison
    - Selected segment / current map / overall game data in separate tables
    - Export of the statistics to the output file for future reference
- **Enhanced character page**
    - Barrel-Colored Attributes (thx MAW) with current modifier value and next attribute milestone in the tooltip
    - Elements-Colored Resistances with average resistance percentage
    - Final Melee and Ranged damage metric in the form of thoroughly [calculated] DPS, for best weapon combination selection
    - Effective health ("Vitality"), employing HP, Armor Class (physical avoidance) and Magic resistances in single metric
    - Skill tooltips, like total Merchant discount or current Disarm skill vs. area difficulty [Optional, enabled by default]   
- **Convenience features**	
    - Automatic items sorting. Borrowed from MAW MMMerge mod, with minor changes.
    - Designated players can get alchemy ingredients and unidentified items in their packs  
    - Travel schedule in Autonotes (Seer tab) [Optional, enabled by default]	
    - Sharing max ID Item and Repair skills over the party [Optional, disabled by default]
    - Grandmaster ID Monster info with ALT pressed [Optional, disabled by default]
    

## Acknowledgments
This mod is the fulfillment of a long-standing dream, a dream to see in detail what is happening with a team of heroes, a dream to get real data for endless debates about who is better.\
For a long time, I had no idea how to approach this task, until I saw the MAW mod [https://github.com/malekitsu/maw-mod-mmmerge
] and fall into it's thrill for a long time.\
The MAW mod developed by **Malekith** and his team was simply a revelation for me.\
From there I borrowed many things that first appeared in MAW - attributes colors, display of DPS and Vitality stats and, of course, the wonderful inventory auto-sort, without which I now simply cannot play.\
But direct code snatching was not the main thing - the MAW mod showed me that everything is possible, and showed how it can be done, peeking into its code I discovered for myself both Lua and MMExtension.
So now I returning 
Another great person who actually made any MM modding possible and **Grayface**, author of MMExtension. We just cant underestimate his impact on the MM community, both modders and gamers.

## Illustrations
![image](https://github.com/user-attachments/assets/a9e3e856-e9e0-45f1-89d5-489c77e9db13)

## Detailed descriptions
### Calculated Damage Metrics

- Hit percentage is calculated on the base of current To-Hit modifier against the mob with AC equal to the current player level\
 P = (15 + PlayerAttack * 2) / (30 + PlayerAttack * 2 + PlayerLvl)

- Estimated DPS is calculated on the base average damage per hit that take into account:
    - Weapons base damage with Str/Heroism already accounted (stated in the vanilla part of the char screen)
    - Constant and temporary elemental damages on both weapons (and three artifacts/relics)
    - Dagger Mastery base damage tripling chance
    - Things are not taken into account: Weakness and Racial bonuses
Average Damage is divided by current Recovery value in seconds to get displayed DPS ()

### Estimated Damage metrics

https://github.com/malekitsu/maw-mod-mmmerge

https://github.com/Malekitsu/MM6-MAW-Monster-Arts-and-Wonders

https://github.com/GrayFace/MMExtension

### Vitality (Effective HP)
Vitality is calculated by taking into account player physical hits avoidance chance (determined by AC) and magic resistances. 
Currently, AC effect is taken with 65% weight, elemental magic resistances have 7.5% each, Mind and Body resistances 2.5% each. These weights are suitable for a party engaging in melee and having a thief.
If you prefer traps that explode in your face and deal with with mobs from afar, surely the Elemental part should have a larger impact on the result. Alternative config is also included in the cmInit.lua file.  

TODO
Встроенный комбат лог последних ударов
Полученные удары
Рекорды
Расписание
