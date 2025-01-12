# CombatStats and Convenience MM7 mod

## Mod features
CombatStats and Convenience MM7 mod do not affect the gameplay, the game mechanics or difficulties of the orignial game. \
Mod requires Grayface's patch and MMExtension, but adds nothing changing the game over this  
Mod can work with any saved game, no need to start a new. Saves will be intact if you remove mod (but why?).\
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
    - Elements-Colored Resistances with average resistance percentage
    - Final Melee and Ranged damage metric in the form of thoroughly [calculated] DPS, for best weapon combination selection
    - Effective health ("Vitality"), employing HP, Armor Class (physical avoidance) and Magic resistances in single metric
    - Skill tooltips, like total Merchant discount or current Disarm skill vs. area difficulty [Optional, enabled by default]   
- **Convenience features**	
    - Automatic items sorting. Borrowed from MAW MMMerge mod, with minor changes (alchemy/unidentified items sorting). 
    - Full Travel Schedule in Autonotes (Seer tab) [Optional, enabled by default]	
    - Sharing max ID Item and Repair skills over the party [Optional, disabled by default]
    - Grandmaster ID Monster info with ALT pressed [Optional, disabled by default]

## Installation
 - MM7 GOG version
 - Grayface latest MM7 patch: https://grayface.github.io/mm/#GrayFace-MM7-Patch
 - [Unreleased] MMExtension v2.3: https://github.com/GrayFace/MMExtension 
 - This mod: 
Instead of two last steps, one can download whole packege with last stable release

## Acknowledgments
This mod is the fulfillment of a long-standing dream, a dream to see in detail what is happening with a team of heroes, a dream to get real data for endless debates about who is better.\
For a long time, I had no idea how to approach this task, until I saw the MAW mod\
https://github.com/malekitsu/maw-mod-mmmerge

and fall into it's thrill enjoying both gameplay and new knowledges about modding.

The MAW mod developed by **Malekith** and his team was simply a revelation for me.
From there I borrowed many things that first appeared in MAW - attributes colors, display of DPS and Vitality stats and, of course, the wonderful inventory auto-sort, without which I now simply cannot play.\
But direct code snatching was not the main thing - the MAW mod showed me that everything is possible, and showed how it can be done, peeking into its code I discovered for myself both Lua and MMExtension.

Another great person who actually made any MM modding possible and **Grayface**, author of MMExtension. We just cant underestimate his impact on the MM community, both modders and gamers.




### Combat log
### In-game combat log
![image](https://github.com/user-attachments/assets/9d772466-850e-4028-a236-58e3fd3a6d5c)

### Observed damage statistics
**Damage done**
**Observed DPS**
![image](https://github.com/user-attachments/assets/fc77963c-196b-4448-b2b7-a148eb8a0734)

**Damage taken**
**Records**

### Calculated statistics
**Damage per second, DPS**
- Hit percentage is calculated on the base of current To-Hit modifier against the mob with AC equal to the current player level\
 *P = (15 + PlayerAttack * 2) / (30 + PlayerAttack * 2 + AC)*

- Estimated DPS is calculated on the base average damage that take into account
    - Weapons base damage with Str/Heroism already accounted (stated in the vanilla part of the char screen)
    - Constant and temporary elemental damages on both weapons (and three artifacts/relics)
    - Dagger Mastery base damage tripling chance
    - Hammerhands buff
    - Chance to miss against AC=CurrentLvl
    Things are not taken into account: Weakness, Racial featurs bonuses, Monster Resistances
    Average Damage is divided by current Recovery value in seconds to get the final displayed DPS, that include all factors that affect damage output, and thus can be used for weapons comparison

**Vitality (Effective HP)**
Vitality is calculated by taking into account player physical hits avoidance chance (determined by AC) and magic resistances. 
Currently, AC effect is taken with 65% weight, elemental magic resistances have 7.5% each, Mind and Body resistances 2.5% each. These weights are suitable for a party engaging in melee and having a thief.
If you prefer traps that explode in your face and deal with with mobs from afar, surely the Elemental part should have a larger impact on the result. Alternative config is also included in the cmInit.lua file.  
![image](https://github.com/user-attachments/assets/af850de2-4130-4086-9869-45d0ba30b621)


## Default keybinds

**Combat history**\
[H], as it was in MM9. This overlaps Wendell Tweed history notes, so if you can access them through book or rebind the key in the Menu
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
**Travel schedule**\
[N] - Travel schedule is added as Seer note and acessible via Seer tab in Autonotes   
**ID Monster**\
If corresponding option in mild cheats section is enabled, [ALT] while checking monster stats will give full GM information\
