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
msg1 = msg1 .. "\n\n\n                [Shoals]-[Avlee]"
msg1 = msg1 .. "\n                                   |"
msg1 = msg1 .. "\n[The Pit ]-[Deyja]-[Tularean]  [LandGiants]"
msg1 = msg1 .. "\n                    |              |                  |"
msg1 = msg1 .. "\n[Tatalia ]-[Erathia]-[Harmondale] [Nighon]"
msg1 = msg1 .. "\n                    |              |                  |"
msg1 = msg1 .. "\n[Celeste]-[Bracada]-[Burrows]-[StoneCity]\n\n\n"
Autonote(':SeerWorldMap', 3, msg1)
SuppressSound(true) -- disable annoying ding
AddAutonote(':SeerWorldMap')
SuppressSound(false)

local msg2 = ""
msg2 = msg2 .. string.format('SWOR\t%13sAXE \t%22sSPEAR\t%32sMACE\t%41sSTAF\t%50sDAGG\t%61sBOW\n','|','|','|','|','|','|')
msg2 = msg2 .. string.format('e Era\t%13sHar\t%22sTat\t%32sEra\t%41sHar\t%50sTul\t%61sTul\n','|','|','|','|','|','|')
msg2 = msg2 .. string.format('e Tat\t%13sAvl\t%22sAvl\t%32sSto\t%41sNig\t%50sBra\t%61sBra\n','|','|','|','|','|','|')
msg2 = msg2 .. string.format('m Dey\t%13sSto\t%22sTul\t%32sTat\t%41sBra\t%50sNig\t%61sNig\n','|','|','|','|','|','|')
msg2 = msg2 .. string.format('g Har\t%13sTat\t%22sSto\t%32sDey\t%41sAvl\t%50sTat\t%61sHar\n','|','|','|','|','|','|')
msg2 = msg2 .. '\n'
msg2 = msg2 .. string.format('FIRE \t%13sAIR\t%22sWATR\t%32sERTH\t%41sSPIRT\t%50sMIND\t%61sBODY\n','|','|','|','|','|','|')
msg2 = msg2 .. string.format('e Tul\t%13sTul\t%22sTul\t%32sHar\t%41sHar\t%50sEra\t%61sHar\n','|','|','|','|','|','|')
msg2 = msg2 .. string.format('e Tat\t%13sTat\t%22sAvl\t%32sSto\t%41sTat\t%50sNig\t%61sEra\n','|','|','|','|','|','|')
msg2 = msg2 .. string.format('m Har\t%13sAvl\t%22sNig\t%32sTul\t%41sEra\t%50sAvl\t%61sTat\n','|','|','|','|','|','|')
msg2 = msg2 .. string.format('g Era\t%13sBra\t%22sHar\t%32sDey\t%41sTul\t%50sTat\t%61sAvl\n','|','|','|','|','|','|')
msg2 = msg2 .. '\n'
msg2 = msg2 .. string.format('ARMS \t%13sDISA\t%22sMRCH\t%32sALCH\t%41sID.IT\t%50sID.M\t%61sRep\n','|','|','|','|','|','|')
msg2 = msg2 .. string.format('e Tat\t%13sTul,Er\t%22sTul\t%32sTul\t%41sHar\t%50sTul\t%61sHar\n','|','|','|','|','|','|')
msg2 = msg2 .. string.format('e Dey\t%13sTat\t%22sSto\t%32sBra\t%41sNig\t%50sNig\t%61sSto\n','|','|','|','|','|','|')
msg2 = msg2 .. string.format('m Avl\t%13sHar\t%22sEve\t%32sNig\t%41sBra\t%50sAvl\t%61sTat\n','|','|','|','|','|','|')
msg2 = msg2 .. string.format('g LoG\t%13sNig\t%22sBra\t%32sAvl\t%41sTul\t%50sHar\t%61sEra\n','|','|','|','|','|','|')

Autonote(':SeerTeachers1', 3, msg2)
SuppressSound(true) -- disable annoying ding
AddAutonote(':SeerTeachers1')
SuppressSound(false)

local msg3 = ""
msg3 = msg3 .. string.format('LTHR\t%13sCHN\t%22sPLATE\t%32sSHLD\t%41sBB\t%50sUNRM\t%61sDODG\n','|','|','|','|','|','|')
msg3 = msg3 .. string.format('e Har\t%13sTul\t%22sTat\t%32sEra\t%41sBra\t%50sHar\t%61sHar\n','|','|','|','|','|','|')
msg3 = msg3 .. string.format('e Avl\t%13sTat\t%22sSto\t%32s\t%41sSto\t%50sBra\t%61sBra\n','|','|','|','|','|','|')
msg3 = msg3 .. string.format('m Nig\t%13sAvl\t%22sEra\t%32sTat\t%41sDey\t%50sEve\t%61sEve\n','|','|','|','|','|','|')
msg3 = msg3 .. string.format('g Tul\t%13sDey\t%22sBra\t%32sEve\t%41sNig\t%50sEra\t%61sEra\n','|','|','|','|','|','|')
msg3 = msg3 .. '\n'
msg3 = msg3 .. string.format('LIGHT\t%13sDARK\t%22sMEDT\t%32sLRNG\t%41sPERC\t%50sSTEAL\t%61sBLSTR\n','|','|','|','|','|','|')
msg3 = msg3 .. string.format('e Bra\t%13sDey\t%22sDey\t%32sBra\t%41sHar  \t%50sHar,Er   \t%61sCel,Pt\n','|','|','|','|','|','|')
msg3 = msg3 .. string.format('e    \t%13s\t%22sAvl\t%32sNig\t%41sDey\t%50sNig   \t%61sCel,Pt\n','|','|','|','|','|','|')
msg3 = msg3 .. string.format('m Cel\t%13sPit\t%22sBra\t%32sNig\t%41sTul  \t%50sDey   \t%61sCel,Pt\n','|','|','|','|','|','|')
msg3 = msg3 .. string.format('g Cel\t%13sPit\t%22sAvl\t%32sEve\t%41sDey  \t%50sTat   \t%61sCel,Pt\n','|','|','|','|','|','|')

Autonote(':SeerTeachers2', 3, msg3)
SuppressSound(true) -- disable annoying ding
AddAutonote(':SeerTeachers2')
SuppressSound(false)



end
