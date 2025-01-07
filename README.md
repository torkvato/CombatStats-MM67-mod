# CombatStats and Convenience MM7 mod

## Mod do and do not
CombatStats and Convenience MM7 mod do not change the gameplay, the game mechanics or difficulties of the orignial game (well, Grayface-patched game)
This is the same good old vanilla MM7, without any attempts to improve the classic.

However, for the convenience and in-depth analyis of the party the following *informational* features were added:

- Enchanced character page
    - Barrel-Colored Attributes (thx MAW) with current modifier value and next attribute milestone in the tooltip
    - Elements-Colored Resistances with average resistance percentage
    - Full Melee and Ranged damage metrics, including hit accuracy and resulting DPS, for best weapon combination selection
    - Effective health ("Vitality"), employing HP, Armor Class (physical avoidance) and Magic resistances in single metric
    - [Optional] Skill tooltips, like total Merchant discount or current Disarm skill vs. area difficulty
- Combat log
    - Logging every [successful] damage dealt, with the timestamp, player, target, damage amount, kind and source (melee, ranged or specific spell)
    - CSV save format, customizable
    - You can do you own parsing and processing, but we already have some...
- In-game damage staticstics / log parsing
    - Accumulation of the damage data such as total damage dealt and average observed DPS for melee/ranged/magic
    - In-game tables for party members efficiency comparison
    - Selected segment / current map / overall game data in separate tables
    - Export of the statistics to the output file for future reference



## Damage Metrics

### Hit percentage is calculated on the base of current To-Hit modifier against the mob with AC equal to the current player level
 P = (15 + PlayerAttack*2)/(30 + PlayerAttack*2 + PlayerLvl)

### Estimated DPS is calculated on the base average damage per hit that take into account:
    - Weapons base damage with Str/Heroism already accounted (stated in the vanilla part of the char screen)
    - Constant and temporary elemental damages on both weapons (and three artifacts/relics)
    - Dagger Mastery tripling of the base weapon damage
    - Things are not taken into account: Weakness and Racial bonuses
Average Damage is divided by current Recovery value in seconds to get displayed DPS ()

https://github.com/malekitsu/maw-mod-mmmerge

https://github.com/Malekitsu/MM6-MAW-Monster-Arts-and-Wonders

https://github.com/GrayFace/MMExtension

## Vitality (Effective HP)
Vitality is calculated by taking into account player physical hits avoidance chance (determined by AC) and magic resistances. 
Currently, AC effect is taken with 65% weight, elemental magic resistances have 7.5% each, Mind and Body resistances 2.5% each. These weights are suitable for a party engaging in melee and having a thief.
If you prefer traps that explode in your face and deal with with mobs from afar, surely the Elemental part should have a larger impact on the result. Alternative config is also included in the cmInit.lua file.  
