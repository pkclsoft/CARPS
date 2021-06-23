         absaddr on
         keep asmlib

TextCmds       data

leShadow       dc    h'04',h'01',c'S',i'$0010'
leOutline      dc    h'04',h'01',c'S',i'$0008'
leUnderline    dc    h'04',h'01',c'S',i'$0004'
leItalic       dc    h'04',h'01',c'S',i'$0002'
leBold         dc    h'04',h'01',c'S',i'$0001'
leNormal       dc    h'04',h'01',c'S',i'$0000'

leForground    dc    h'02',h'01',c'C'
leBackground   dc    h'02',h'01',c'B'

leFont         dc    h'02',h'01',c'F'

leLeftJustify  dc    h'04',h'01',c'J',i'$0000'
leCentJustify  dc    h'04',h'01',c'J',i'$0001'
leRightJustify dc    h'04',h'01',c'J',i'$ffff'
leFillJustify  dc    h'04',h'01',c'J',i'$0002'

leLeftMargin   dc    h'02',h'01',c'L'
leRightMargin  dc    h'02',h'01',c'M'

leExtraSpacing dc    h'02',h'01',c'X'

               end
