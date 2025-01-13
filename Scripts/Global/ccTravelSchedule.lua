-- Travel schedule table as a Seer Notes
if TravelScheduleAutoNote==1 then
local msg = ""
msg = msg .. string.format('    \t%11sMON \t%20sTUE \t%29sWED \t%38sTHU \t%47sFRI \t%56sSAT \t%65sSUN \n','|','|','|','|','|','|','|')
msg = msg .. string.format('Har \t%11sEra2\t%20sTul2\t%29sEra2\t%38sTul2\t%47sEra2\t%56sTul2\t%65sAre4\n','|','|','|','|','|','|','|')
msg = msg .. string.format('Era \t%11sTat2\t%20sHar2\t%29sTat2\t%38sDey3\t%47sTat2\t%56sHar2\t%65s    \n','|','|','|','|','|','|','|')
msg = msg .. string.format('    \t%11sDey2\t%20sTat2\t%29sBra3\t%38sHar2\t%47sAvl4\t%56sBra3\t%65sEve7\n','|','|','|','|','|','|','|')
msg = msg .. string.format('    \t%11sAvl4\t%20s    \t%29sBra6\t%38s    \t%47s    \t%56sTat2\t%65s    \n','|','|','|','|','|','|','|')
msg = msg .. string.format('Tul \t%11sTat2\t%20sHar2\t%29sTat2\t%38sDey3\t%47sTat2\t%56sHar2\t%65s    \n','|','|','|','|','|','|','|')
msg = msg .. string.format('    \t%11sDey2\t%20sTat2\t%29sBra3\t%38sHar2\t%47sAvl4\t%56sBra3\t%65sEve7\n','|','|','|','|','|','|','|')
msg = msg .. string.format('    \t%11sAvl4\t%20s    \t%29sBra6\t%38s    \t%47s    \t%56sTat2\t%65s    \n','|','|','|','|','|','|','|')
msg = msg .. string.format('Avl \t%11sTul3\t%20sTul3\t%29sDey5\t%38sTul3\t%47sTul3\t%56sTul3\t%65sDey5\n','|','|','|','|','|','|','|')
msg = msg .. string.format('    \t%11s    \t%20sEra4\t%29sTul3\t%38sTat5\t%47s    \t%56sEra4\t%65s    \n','|','|','|','|','|','|','|')
	
msg = msg .. string.format('Bra \t%11sEra3\t%20sHar5\t%29sEra3\t%38sEve1\t%47sEra3\t%56sHar5\t%65sEra3\n','|','|','|','|','|','|','|')
msg = msg .. string.format('    \t%11sTat4\t%20sEve1\t%29sTat4\t%38s    \t%47sTat4\t%56sEra6\t%65sTul6\n','|','|','|','|','|','|','|')
	
msg = msg .. string.format('Dey \t%11sEra3\t%20sTul2\t%29sEra3\t%38sTul2\t%47sEra3\t%56sTul2\t%65s    \n','|','|','|','|','|','|','|')
	
msg = msg .. string.format('Tat \t%11sBra4\t%20sEra2\t%29sBra4\t%38sEra2\t%47s    \t%56sEra2\t%65sEve5\n','|','|','|','|','|','|','|')
msg = msg .. string.format('    \t%11s    \t%20sEra2\t%29s    \t%38sEra2\t%47s    \t%56sAvl5\t%65s    \n','|','|','|','|','|','|','|')
	
msg = msg .. string.format('Eve \t%11sTat4\t%20s    \t%29sTat4\t%38s    \t%47sTat4\t%56sTul6\t%65s    ','|','|','|','|','|','|','|')

Autonote(':SeerTravelSchedule', 3, msg)
SuppressSound(true) -- disable annoying ding
AddAutonote(':SeerTravelSchedule')
SuppressSound(false)

-- s = ""
-- for i=14,255 do
-- s = s .. string.char(i)
-- if (i%40)==0 then s = s .. "\n" end
-- Message(s)
local msg1 = ""
msg1 = msg1 .. "\n                [Shoals]-[Avlee]"
msg1 = msg1 .. "\n                                   |"
msg1 = msg1 .. "\n[The Pit ]-[Deyja]-[Tularean]  [LandGiants]"
msg1 = msg1 .. "\n                    |              |                  |"
msg1 = msg1 .. "\n[Tatalia ]-[Erathia]-[Harmondale] [Nighon]"
msg1 = msg1 .. "\n                    |              |                  |"
msg1 = msg1 .. "\n[Celeste]-[Bracada]-[Burrows]-[StoneCity]"
Autonote(':SeerWorldMap', 3, msg1)
SuppressSound(true) -- disable annoying ding
AddAutonote(':SeerWorldMap')
SuppressSound(false)
end
