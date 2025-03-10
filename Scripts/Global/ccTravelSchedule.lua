-- Travel schedule table as a Seer Notes
if Game.Version < 7 then

    if TravelScheduleAutoNote == 1 or TeachersTableAutoNote == 1 or AlchemyRecipesAutoNote == 1 then
        for i = 108, 116 do
            Party.AutonotesBits[i] = false -- clear seer messages
        end
    end

    if TravelScheduleAutoNote == 1 then
        local msg = ""
        msg = msg .. string.format('    \t%11sMON \t%20sTUE \t%29sWED \t%38sTHU \t%47sFRI \t%56sSAT\n', '|', '|', '|', '|', '|', '|')
        msg = msg .. string.format('Sor \t%11sIro2\t%20sMis3\t%29sIro2\t%38sMis3\t%47sIro2\t%56sMis3\n', '|', '|', '|', '|', '|', '|')
        msg = msg .. string.format('Iro \t%11sSor2\t%20sFH4\t%29sSor2\t%38sSor2\t%47sSor2\t%56sFH4\n', '|', '|', '|', '|', '|', '|')
        msg = msg .. string.format('    \t%11sMis2\t%20sSor2\t%29sMis2\t%38s    \t%47sMis2\t%56sSor2\n', '|', '|', '|', '|', '|', '|')
        msg = msg .. string.format('    \t%11s   \t%20sBoo3\t%29s    \t%38s    \t%47sBoo3\t%56s\n', '|', '|', '|', '|', '|', '|')

        msg = msg .. string.format('FH \t%11sSC4\t%20sIro4\t%29sMir5\t%38sSC3\t%47sIro4\t%56sMir5\n', '|', '|', '|', '|', '|', '|')
        msg = msg .. string.format('    \t%11sBla3\t%20sKri3\t%29sFro3\t%38sBla3\t%47sKri3\t%56sFro3\n', '|', '|', '|', '|', '|', '|')
        msg = msg .. string.format('    \t%11sMis4\t%20sSC3\t%29sIro5\t%38sMis4\t%47s    \t%56s\n', '|', '|', '|', '|', '|', '|')

        msg = msg .. string.format('Mis \t%11sIro2\t%20sBoo2\t%29sIro2\t%38sSC3\t%47sIro2\t%56sBoo2\n', '|', '|', '|', '|', '|', '|')
        msg = msg .. string.format('    \t%11sSC3\t%20s   \t%29s   \t%38sBoo2\t%47s    \t%56s\n', '|', '|', '|', '|', '|', '|')

        msg = msg .. string.format('SC \t%11sFH4\t%20sFH3\t%29sEel1\t%38sMis3\t%47sFH4\t%56sMis3\n', '|', '|', '|', '|', '|', '|')
        msg = msg .. string.format('    \t%11sMis3\t%20s  \t%29s   \t%38sEel2\t%47sFH3\t%56s\n', '|', '|', '|', '|', '|', '|')

        msg = msg .. string.format('Eel \t%11sSC2\t%20s\t%29s\t%38s\t%47s\t%56s\n', '|', '|', '|', '|', '|', '|')
        msg = msg .. string.format('Bla \t%11s \t%20sFH3\t%29s\t%38s\t%47sFH3\t%56s\n', '|', '|', '|', '|', '|', '|')
        msg = msg .. string.format('Fro\t%11sFH3\t%20s\t%29s\t%38sFH3\t%47s\t%56s\n', '|', '|', '|', '|', '|', '|')
        msg = msg .. string.format('Boo \t%11s\t%20sIro4\t%29s\t%38sIro4\t%47s\t%56s\n', '|', '|', '|', '|', '|', '|')
        msg = msg .. string.format('Mir \t%11sFH5\t%20s\t%29s\t%38s\t%47sFH5\t%56s', '|', '|', '|', '|', '|', '|')

        Autonote(':SeerTravelSchedule', 3, msg)
        SuppressSound(true) -- disable annoying ding
        AddAutonote(':SeerTravelSchedule')
        SuppressSound(false)
    end
    
    if TeachersTableAutoNote == 1 then

        local msg2 = string.format('\t%36s\n\n', 'Teachers')
        msg2 = msg2 .. string.format('SWOR\t%13sAXE\t%22sSPEAR\t%32sMACE\t%41sSTAF\t%50sDAGG\t%61sBOW\n', '|', '|', '|', '|', '|', '|')
        msg2 = msg2 .. string.format('e Iro\t%13sIro\t%22sMis\t%32sMir\t%41sSor\t%50sIro\t%61sIro\n', '|', '|', '|', '|', '|', '|')
        msg2 = msg2 .. string.format('e FH\t%13sMir\t%22sSC\t%32sFro\t%41sMis\t%50sFH\t%61sFro\n', '|', '|', '|', '|', '|', '|')
        msg2 = msg2 .. string.format('m Bla\t%13sMir\t%22sMir\t%32sBla\t%41sSC\t%50sFro\t%61sKri\n', '|', '|', '|', '|', '|', '|')
        msg2 = msg2 .. '\n'
        msg2 = msg2 .. string.format('FIRE \t%13sAIR\t%22sWATR\t%32sERTH\t%41sSPIRT\t%50sMIND\t%61sBODY\n', '|', '|', '|', '|', '|', '|')
        msg2 = msg2 .. string.format('e Sor\t%13sSor\t%22sSor\t%32sSor\t%41sSor\t%50sSor\t%61sSor\n', '|', '|', '|', '|', '|', '|')
        msg2 = msg2 .. string.format('e FH\t%13sFH\t%22sFH\t%32sFH\t%41sFH\t%50sFH\t%61sFH\n', '|', '|', '|', '|', '|', '|')
        msg2 = msg2 .. string.format('m Mis\t%13sMis\t%22sMis\t%32sMis\t%41sIro\t%50sSC\t%61sSC\n', '|', '|', '|', '|', '|', '|')
        msg2 = msg2 .. '\n'
        msg2 = msg2 .. string.format('PLT\t%13sCHN\t%22sLTHR\t%32sSHLD\t%41sBLST\t%50sLIGHT\t%61sDARK\n', '|', '|', '|', '|', '|', '|')
        msg2 = msg2 .. string.format('e Iro\t%13sIro\t%22sIro\t%32sIro\t%41sSor\t%50sKri\t%61sBla\n', '|', '|', '|', '|', '|', '|')
        msg2 = msg2 .. string.format('e FH\t%13sBoo\t%22sMis\t%32sFH\t%41sEel\t%50sSC\t%61sFro\n', '|', '|', '|', '|', '|', '|')
        msg2 = msg2 .. string.format('m FH\t%13sMir\t%22sFro\t%32sBla\t%41sPar\t%50sEel\t%61sPar\n', '|', '|', '|', '|', '|', '|')

        Autonote(':SeerTeachers1', 3, msg2)
        SuppressSound(true) -- disable annoying ding
        AddAutonote(':SeerTeachers1')
        SuppressSound(false)

        local msg3 = string.format('\t%36s\n\n', 'Teachers')
        msg3 = msg3 .. string.format('BB\t%13sMEDT\t%22sPERC\t%32sID.I.\t%41sREP\t%50sDISA\t%61sMERCH\n', '|', '|', '|', '|', '|', '|')
        msg3 = msg3 .. string.format('e Sor\t%13sSor\t%22sSor\t%32sSor\t%41sMis\t%50sIro\t%61sMir\n', '|', '|', '|', '|', '|', '|')
        msg3 = msg3 .. string.format('e Iro\t%13sSC\t%22sBoo\t%32sIro\t%41sSC\t%50sFH\t%61sFH\n', '|', '|', '|', '|', '|', '|')
        msg3 = msg3 .. string.format('m FH\t%13sMis\t%22sMir\t%32sFH\t%41sFro\t%50sFro\t%61sSC\n', '|', '|', '|', '|', '|', '|')
        msg3 = msg3 .. '\n'
        msg3 = msg3 .. string.format('DIPL\t%13sLRNG\t%22s \t%32s \t%41s \t%50s\t%61s \n', '|', '|', '|', '|', '|', '|')
        msg3 = msg3 .. string.format('e IRO\t%13sSor\t%22s\t%32s\t%41s\t%50s\t%61s\n', '|', '|', '|', '|', '|', '|')
        msg3 = msg3 .. string.format('e FH\t%13sIro\t%22s\t%32s\t%41s\t%50s\t%61s\n', '|', '|', '|', '|', '|', '|')
        msg3 = msg3 .. string.format('m Fro\t%13sSC\t%22s\t%32s\t%41s\t%50s\t%61s\n\n\n\n\n\n', '|', '|', '|', '|', '|', '|')

        Autonote(':SeerTeachers2', 3, msg3)
        SuppressSound(true) -- disable annoying ding
        AddAutonote(':SeerTeachers2')
        SuppressSound(false)
    end
    if AlchemyRecipesAutoNote == 1 then
        local msg = string.format('\t%36s\n', 'Alchemy Recipes')
        msg = msg .. string.format('White\n')
        msg = msg .. string.format('Restoration:GP  Sup.Resistance:GB  Exr.Energy:OY  ')
        msg = msg .. string.format('Heroism:OR  StoneSkin:OB  Sup.Protect:OG  ')
        msg = msg .. string.format('Haste:GY   Bless:PB\n')
        msg = msg .. string.format('Black\n')
        msg = msg .. string.format('Might:ROR  Intellect:BOB  Pers:GPB  Endurance:GOY  ')
        msg = msg .. string.format('Speed:GYR  Accuracy:BPY  Luck:BGP  Rejuv:OYG  ')
        msg = msg .. string.format('Div.Cure:GPO  Div.Magic:GBG  Div.Power:OYP\n\n\n')

        Autonote(':AlchRecipes', 3, msg)
        SuppressSound(true) -- disable annoying ding
        AddAutonote(':AlchRecipes')
        SuppressSound(false)
    end
else
    -- Travel schedule table as a Seer Notes
    if TravelScheduleAutoNote == 1 then
        local msg = ""
        msg = msg .. string.format('    \t%11sMON \t%20sTUE \t%29sWED \t%38sTHU \t%47sFRI \t%56sSAT \t%65sSUN \n', '|', '|', '|', '|', '|', '|', '|')
        msg = msg .. string.format('Har \t%11sEra2\t%20sTul2\t%29sEra2\t%38sTul2\t%47sEra2\t%56sTul2\t%65sAre4\n', '|', '|', '|', '|', '|', '|', '|')
        msg = msg .. string.format('Era \t%11sTat2\t%20sHar2\t%29sTat2\t%38sDey3\t%47sTat2\t%56sHar2\t%65s    \n', '|', '|', '|', '|', '|', '|', '|')
        msg = msg .. string.format('    \t%11sDey2\t%20sTat2\t%29sBra3\t%38sHar2\t%47sAvl4\t%56sBra3\t%65sEve7\n', '|', '|', '|', '|', '|', '|', '|')
        msg = msg .. string.format('    \t%11sAvl4\t%20s    \t%29sBra6\t%38s    \t%47s    \t%56sTat2\t%65s    \n', '|', '|', '|', '|', '|', '|', '|')

        msg = msg .. string.format('Tul \t%11sAvl3\t%20sHar2\t%29sAvl3\t%38sHar2\t%47sAvl3\t%56sHar2\t%65sDey2\n', '|', '|', '|', '|', '|', '|', '|')
        msg = msg .. string.format('    \t%11sBra6\t%20sDey2\t%29sBra6\t%38sAvl3\t%47sDey2\t%56sAvl3\t%65sEve7\n', '|', '|', '|', '|', '|', '|', '|')
        msg = msg .. string.format('    \t%11s    \t%20sAvl3\t%29s    \t%38s    \t%47s    \t%56s    \t%65s    \n', '|', '|', '|', '|', '|', '|', '|')

        msg = msg .. string.format('Avl \t%11sTul3\t%20sTul3\t%29sDey5\t%38sTul3\t%47sTul3\t%56sTul3\t%65sDey5\n', '|', '|', '|', '|', '|', '|', '|')
        msg = msg .. string.format('    \t%11s    \t%20sEra4\t%29sTul3\t%38sTat5\t%47s    \t%56sEra4\t%65s    \n', '|', '|', '|', '|', '|', '|', '|')

        msg = msg .. string.format('Bra \t%11sEra3\t%20sHar5\t%29sEra3\t%38sEve1\t%47sEra3\t%56sHar5\t%65sEra3\n', '|', '|', '|', '|', '|', '|', '|')
        msg = msg .. string.format('    \t%11sTat4\t%20sEve1\t%29sTat4\t%38s    \t%47sTat4\t%56sEra6\t%65sTul6\n', '|', '|', '|', '|', '|', '|', '|')

        msg = msg .. string.format('Dey \t%11sEra3\t%20sTul2\t%29sEra3\t%38sTul2\t%47sEra3\t%56sTul2\t%65s    \n', '|', '|', '|', '|', '|', '|', '|')

        msg = msg .. string.format('Tat \t%11sBra4\t%20sEra2\t%29sBra4\t%38sEra2\t%47s    \t%56sEra2\t%65sEve5\n', '|', '|', '|', '|', '|', '|', '|')
        msg = msg .. string.format('    \t%11s    \t%20sEra2\t%29s    \t%38sEra2\t%47s    \t%56sAvl5\t%65s    \n', '|', '|', '|', '|', '|', '|', '|')

        msg = msg .. string.format('Eve \t%11sTat4\t%20s    \t%29sTat4\t%38s    \t%47sTat4\t%56sTul6\t%65s    ', '|', '|', '|', '|', '|', '|', '|')

        Autonote(':SeerTravelSchedule', 3, msg)
        SuppressSound(true) -- disable annoying ding
        AddAutonote(':SeerTravelSchedule')
        SuppressSound(false)
    end
    -- s = ""
    -- for i=14,255 do
    -- s = s .. string.char(i)
    -- if (i%40)==0 then s = s .. "\n" end
    -- Message(s)
    if MapAutoNote == 1 then -- Add World Map to Seer Autonotes
        local msg1 = ""
        msg1 = msg1 .. "\n\n\n                [Shoals]-[Avlee]"
        msg1 = msg1 .. "\n                                   |"
        msg1 = msg1 .. "\n[The Pit ]-[Deyja]-[Tularean]  [LandGiants]"
        msg1 = msg1 .. "\n                    |              |                  |"
        msg1 = msg1 .. "\n[Tatalia ]-[Erathia]-[Harmondale] [Nighon]"
        msg1 = msg1 .. "\n                    |              |                  |"
        msg1 = msg1 .. "\n[Celeste]-[Bracada]-[Burrows]-[StoneCity]\n\n\n\n\n"
        Autonote(':SeerWorldMap', 3, msg1)
        SuppressSound(true) -- disable annoying ding
        AddAutonote(':SeerWorldMap')
        SuppressSound(false)
    end

    if TeachersTableAutoNote == 1 then -- Add Teachers Table to Seer Autonotes

        local msg2 = ""
        msg2 = msg2 .. string.format('SWOR\t%13sAXE \t%22sSPEAR\t%32sMACE\t%41sSTAF\t%50sDAGG\t%61sBOW\n', '|', '|', '|', '|', '|', '|')
        msg2 = msg2 .. string.format('e Era\t%13sHar\t%22sTat\t%32sEra\t%41sHar\t%50sTul\t%61sTul\n', '|', '|', '|', '|', '|', '|')
        msg2 = msg2 .. string.format('e Tat\t%13sAvl\t%22sAvl\t%32sSto\t%41sNig\t%50sBra\t%61sBra\n', '|', '|', '|', '|', '|', '|')
        msg2 = msg2 .. string.format('m Dey\t%13sSto\t%22sTul\t%32sTat\t%41sBra\t%50sNig\t%61sNig\n', '|', '|', '|', '|', '|', '|')
        msg2 = msg2 .. string.format('g Har\t%13sTat\t%22sSto\t%32sDey\t%41sAvl\t%50sTat\t%61sHar\n', '|', '|', '|', '|', '|', '|')
        msg2 = msg2 .. '\n'
        msg2 = msg2 .. string.format('FIRE \t%13sAIR\t%22sWATR\t%32sERTH\t%41sSPIRT\t%50sMIND\t%61sBODY\n', '|', '|', '|', '|', '|', '|')
        msg2 = msg2 .. string.format('e Tul\t%13sTul\t%22sTul\t%32sHar\t%41sHar\t%50sEra\t%61sHar\n', '|', '|', '|', '|', '|', '|')
        msg2 = msg2 .. string.format('e Tat\t%13sTat\t%22sAvl\t%32sSto\t%41sTat\t%50sNig\t%61sEra\n', '|', '|', '|', '|', '|', '|')
        msg2 = msg2 .. string.format('m Har\t%13sAvl\t%22sNig\t%32sTul\t%41sEra\t%50sAvl\t%61sTat\n', '|', '|', '|', '|', '|', '|')
        msg2 = msg2 .. string.format('g Era\t%13sBra\t%22sHar\t%32sDey\t%41sTul\t%50sTat\t%61sAvl\n', '|', '|', '|', '|', '|', '|')
        msg2 = msg2 .. '\n'
        msg2 = msg2 .. string.format('ARMS \t%13sDISA\t%22sMRCH\t%32sALCH\t%41sID.IT\t%50sID.M\t%61sRep\n', '|', '|', '|', '|', '|', '|')
        msg2 = msg2 .. string.format('e Tat\t%13sTul,Er\t%22sTul\t%32sTul\t%41sHar\t%50sTul\t%61sHar\n', '|', '|', '|', '|', '|', '|')
        msg2 = msg2 .. string.format('e Dey\t%13sTat\t%22sSto\t%32sBra\t%41sNig\t%50sNig\t%61sSto\n', '|', '|', '|', '|', '|', '|')
        msg2 = msg2 .. string.format('m Avl\t%13sHar\t%22sEve\t%32sNig\t%41sBra\t%50sAvl\t%61sTat\n', '|', '|', '|', '|', '|', '|')
        msg2 = msg2 .. string.format('g LoG\t%13sNig\t%22sBra\t%32sAvl\t%41sTul\t%50sHar\t%61sEra\n', '|', '|', '|', '|', '|', '|')

        Autonote(':SeerTeachers1', 3, msg2)
        SuppressSound(true) -- disable annoying ding
        AddAutonote(':SeerTeachers1')
        SuppressSound(false)

        local msg3 = ""
        msg3 = msg3 .. string.format('LTHR\t%13sCHN\t%22sPLATE\t%32sSHLD\t%41sBB\t%50sUNRM\t%61sDODG\n', '|', '|', '|', '|', '|', '|')
        msg3 = msg3 .. string.format('e Har\t%13sTul\t%22sTat\t%32sEra\t%41sBra\t%50sHar\t%61sHar\n', '|', '|', '|', '|', '|', '|')
        msg3 = msg3 .. string.format('e Avl\t%13sTat\t%22sSto\t%32s\t%41sSto\t%50sBra\t%61sBra\n', '|', '|', '|', '|', '|', '|')
        msg3 = msg3 .. string.format('m Nig\t%13sAvl\t%22sEra\t%32sTat\t%41sDey\t%50sEve\t%61sEve\n', '|', '|', '|', '|', '|', '|')
        msg3 = msg3 .. string.format('g Tul\t%13sDey\t%22sBra\t%32sEve\t%41sNig\t%50sEra\t%61sEra\n', '|', '|', '|', '|', '|', '|')
        msg3 = msg3 .. '\n'
        msg3 = msg3 .. string.format('LIGHT\t%13sDARK\t%22sMEDT\t%32sLRNG\t%41sPERC\t%50sSTEAL\t%61sBLSTR\n', '|', '|', '|', '|', '|', '|')
        msg3 = msg3 .. string.format('e Bra\t%13sDey\t%22sDey\t%32sBra\t%41sHar  \t%50sHar,Er   \t%61sCel,Pt\n', '|', '|', '|', '|', '|', '|')
        msg3 = msg3 .. string.format('e    \t%13s\t%22sNig\t%32sNig\t%41sDey\t%50sNig   \t%61sCel,Pt\n', '|', '|', '|', '|', '|', '|')
        msg3 = msg3 .. string.format('m Cel\t%13sPit\t%22sBra\t%32sNig\t%41sTul  \t%50sDey   \t%61sCel,Pt\n', '|', '|', '|', '|', '|', '|')
        msg3 = msg3 .. string.format('g Cel\t%13sPit\t%22sAvl\t%32sEve\t%41sDey  \t%50sTat   \t%61sCel,Pt\n\n\n\n\n\n', '|', '|', '|', '|', '|', '|')

        Autonote(':SeerTeachers2', 3, msg3)
        SuppressSound(true) -- disable annoying ding
        AddAutonote(':SeerTeachers2')
        SuppressSound(false)
    end
    if AlchemyRecipesAutoNote == 1 then -- Add recipes schedule to Seer Autonote
        local msg = ""
        msg = msg .. string.format('EXPERT-LAYERED\n')
        msg = msg .. string.format('Harden:GY\t%20sBless:GR\t%38sHeroism:PR\t%56sHaste:OR\n', '|', '|', '|')
        msg = msg .. string.format('WaterB:PY\t%20sPresrv:OB\t%38sStoneS:OY\t%56sRechrg:GB\n', '|', '|', '|')
        msg = msg .. string.format('Shield:PB\t%20sC.Insn:GO\t%38sR.Fear:PO\t%56sR.Curse:PG\n', '|', '|', '|')
        msg = msg .. string.format('MASTER-WHITE\n')
        msg = msg .. string.format('Mght:PR-P\t%20sInt:GY-G\t%38sPers:GB-G\t%56sEnd:PB-P\n', '|', '|', '|')
        msg = msg .. string.format('Acc:OY-O\t%20sSpd:OR-O\t%38sLck:PB-PR\t%56sShck:PR-O\n', '|', '|', '|')
        msg = msg .. string.format('Swft:GB-P\t%20sSwft:PB-G\t%38sNoxi:GY-P\t%56sNoxi:GB-O\n', '|', '|', '|')
        msg = msg .. string.format('Frz:PB-O\t%20sFlm:OY-P\t%38sFlm:OR-P\t%56sFlm:OR-G\n', '|', '|', '|')
        msg = msg .. string.format('Cur:OY-OR\t%20sRst:OR-OY\t%38sRest:GY-PR\t%56sPwr:GB-GY\n', '|', '|', '|')
        msg = msg .. string.format('Prlz:OY-G\t%20sPrlz:GY-O\t%38sBod:OY-GB\t%56sMnd:GB-PR\n', '|', '|', '|')
        msg = msg .. string.format('Fire:OR-GY\t%20sAir:OR-PB\t%38sWtr:GY-PB\t%56sErth:OY-PR\n', '|', '|', '|')
        msg = msg .. string.format('GRAND-BLACK\n')
        msg = msg .. string.format('Mght:PR-P-O\t%26sInt:GY-G-O\t%48sPers:GB-G-P\n', '|', '|')
        msg = msg .. string.format('Endr:PB-P-G\t%26sAcc:OY-O-G\t%48sSpd:OR-O-P\n', '|', '|')
        msg = msg .. string.format('Lck:PB-PR-OY\t%26sStone2Fl:(OY-G,GY-O)-PR\n', '|')
        msg = msg .. string.format('DrgnSlay:(OY-P,OR-P,OR-G)-PB\nRejuv:(OR-OY,GY-PR)-(OB,GR)')

        Autonote(':AlchRecipes', 3, msg)
        SuppressSound(true) -- disable annoying ding
        AddAutonote(':AlchRecipes')
        SuppressSound(false)

    end

end
