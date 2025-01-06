# dc_scripts
Set of DC automation scripts

https://github.com/Malekitsu/MM6-MAW-Monster-Arts-and-Wonders

https://github.com/GrayFace/MMExtension

##Vitality (Effective HP)
Vitality is calculated by taking into account player physical hits avoidance chance (determined by AC) and magic resistances. 
Currently, AC effect is taken with 75% weight, elemental magic resistances have 5% each, Mind and Body resistances 2.5% each. These weights are suitable for a party engaging in melee and having a thief.
If you prefer traps that explode in your face and deal with with mobs from afar, surely the Elemental part should have a larger impact on the result. Alternative config is also included in the cmInit.lua file.  
