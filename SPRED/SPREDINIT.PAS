   procedure InitMenus;
   var
      Height       : Integer;
      MenuHand     : MenuHandle;
      MenuString   : TextPtr;
 
   begin
       new(MenuString);
       MenuString^ := concat('>> Shape \N4', chr(Return));
       MenuString^ := concat(MenuString^, '--New Shape\N400', chr(Return));
       MenuString^ := concat(MenuString^, '--Copy Shape\N401', chr(Return));
       MenuString^ := concat(MenuString^, '--Clear Shape\N402', chr(Return));
       MenuString^ := concat(MenuString^, '--Delete Shape\N403', chr(Return));
       MenuString^ := concat(MenuString^, '.',chr(Return));
       MenuHand    := NewMenu(MenuString);
       InsertMenu(MenuHand,0);

       new(MenuString);
       MenuString^ := concat('>> Sprite \N3', chr(Return));
       MenuString^ := concat(MenuString^, '--Select Sprite\N300V*Gg', chr(Return));
       MenuString^ := concat(MenuString^, '--New Sprite\N301', chr(Return));
       MenuString^ := concat(MenuString^, '--Copy Sprite\N302', chr(Return));
       MenuString^ := concat(MenuString^, '--Clear Sprite\N303', chr(Return));
       MenuString^ := concat(MenuString^, '--Delete Sprite\N304V', chr(Return));
       MenuString^ := concat(MenuString^, '--Animate Sprite\N305*Aa', chr(Return));
       MenuString^ := concat(MenuString^, '--Mass Sprite\N306*Mm', chr(Return));
       MenuString^ := concat(MenuString^, '.',chr(Return));
       MenuHand    := NewMenu(MenuString);
       InsertMenu(MenuHand,0);

       new(MenuString);
       MenuString^ := concat('>> Edit \N2', chr(Return));
       MenuString^ := concat(MenuString^, '--Undo\N250V*Zz', chr(Return));
       MenuString^ := concat(MenuString^, '--Cut\N251*Xx', chr(Return));
       MenuString^ := concat(MenuString^, '--Copy\N252*Cc', chr(Return));
       MenuString^ := concat(MenuString^, '--Paste\N253*Vv', chr(Return));
       MenuString^ := concat(MenuString^, '--Clear\N254', chr(Return));
       MenuString^ := concat(MenuString^, '.',chr(Return));
       MenuHand    := NewMenu(MenuString);
       InsertMenu(MenuHand,0);

       new(MenuString);
       MenuString^ := concat('>> File \N1', chr(Return));
       MenuString^ := concat(MenuString^, '--New\N500*Nn', chr(Return));
       MenuString^ := concat(MenuString^, '--Open\N501*Oo', chr(Return));
       MenuString^ := concat(MenuString^, '--Save\N502*Ss', chr(Return));
       MenuString^ := concat(MenuString^, '--Save as ...\N503', chr(Return));
       MenuString^ := concat(MenuString^, '--Close\N504V', chr(Return));
       MenuString^ := concat(MenuString^, '--Palette\N505*Pp', chr(Return));
       MenuString^ := concat(MenuString^, '--Default Palette\N506V', chr(Return));
       MenuString^ := concat(MenuString^, '--Quit\N507*Qq', chr(Return));
       MenuString^ := concat(MenuString^, '.', chr(Return));
       MenuHand    := NewMenu(MenuString);
       InsertMenu(MenuHand,0);

       new(MenuString);
       MenuString^ := concat('>>@\XN0', chr(Return));
       MenuString^ := concat(MenuString^, '--About Sprite Editor...\N257V',chr(Return));
       MenuString^ := concat(MenuString^, '.',chr(Return));
       MenuHand    := NewMenu(MenuString);
       InsertMenu(MenuHand,0);
       FixAppleMenu(0);

       Height := FixMenuBar;
       DrawMenuBar;
   end;

   Procedure InitAreas;
   var
       LineNumber  : Integer;
       XOffset     : Integer;
       Count       : Integer;
   begin

       DefPalette[0]  := $0000; { Black }
       DefPalette[1]  := $0777; { Dark Gray }
       DefPalette[2]  := $0841; { Brown }
       DefPalette[3]  := $072c; { Purple }
       DefPalette[4]  := $000f; { Blue }
       DefPalette[5]  := $0080; { Dark Green }
       DefPalette[6]  := $0f70; { Orange }
       DefPalette[7]  := $0d00; { Red }
       DefPalette[8]  := $0fa9; { Flesh }
       DefPalette[9]  := $0ff0; { Yellow }
       DefPalette[10] := $00e0; { Green }
       DefPalette[11] := $04df; { Light Blue }
       DefPalette[12] := $0daf; { Lilac }
       DefPalette[13] := $078f; { Periwinkle Blue }
       DefPalette[14] := $0ccc; { Light Gray }
       DefPalette[15] := $0fff; { White }

       with ShapeWRect do
       begin
           h1 := 10;
           h2 := 253;
           v1 := 168;
           v2 := 192;
       end;

       For Count := 0 to 7 do              { Now define and draw the frames }
       begin                               { for each of the shapes.        }
           XOffset := 6 + (30 * Count);
           With ShapeRect[Count].Local do
           begin
               h1 := XOffset;
               h2 := XOffset + 20;
               v1 := 2;
               v2 := 22;
           end;

           With ShapeRect[Count].Global do
           begin
               h1 := XOffset + ShapeWRect.h1;
               h2 := h1 + 20;
               v1 := 2 + ShapeWRect.v1;
               v2 := v1 + 20;
           end;
       end;

       with MassRect do                    { Define and draw the fram for }
       begin                               { the mass shape area.         }
           h1 := 258;
           h2 := 310;
           v1 := 140;
           v2 := 192;
       end;

       with PaletteRect do                 { We want the palette to appear }
       begin                               { within a "window".            }
           h1 := 10;
           h2 := 253;
           v1 := 140;
           v2 := 162;
       end;

       For Count := 0 to 15 do             { Define the palette color borders }
       begin                               { and fill areas, then draw them.  }
           with ColorRect[Count].Border do
           begin
               h1 := 2 + (Count * 15);
               h2 := h1 + 14;
               v1 := 2;
               v2 := 20;
           end;

           with ColorRect[Count].Actual do
           begin
               h1 := 2 + (Count * 15) + PaletteRect.h1;
               h2 := h1 + 14;
               v1 := 2 + PaletteRect.v1;
               v2 := v1 + 20;
           end;

           With ColorRect[Count].Area do
           begin
               h1 := ColorRect[Count].Border.h1 + 2;
               h2 := ColorRect[Count].Border.h2 - 2;
               v1 := ColorRect[Count].Border.v1 + 2;
               v2 := ColorRect[Count].Border.v2 - 2;
           end;
       end;

       With DrawRect do
       begin
           h1 := 210;
           h2 := 310;
           v1 := 30;
           v2 := 130;
       end;

       with TextRect do
       begin
           h1 := 10;
           h2 := 200;
           v1 := 30;
           v2 := 130;
       end;

       with EditRect do
       begin
           h1 := 10;
           h2 := 310;
           v1 := 30;
           v2 := 130;
       end;
   end;

   Procedure InitWindows;
   var
       Junk    : LongInt;
       Count   : Integer;

       Procedure StartUpWindow(WindowNumber    : Integer;
                               WindowRect      : Rect;
                               ContentProc     : Ptr);
       var
           TempRect    : Rect;
       begin
           With WindowRecord[WindowNumber] do
           begin
               paramLength := 78;
               wFrameBits := $0020;
               wTitle := Nil;
               wRefCon := 0;
               wZoom.h1 := 0;
               wZoom.h2 := 0;
               wZoom.v1 := 0;
               wZoom.v2 := 0;
               wColor := @SpriteFile.PaletteRec;
               wYOrigin := 0;
               wXOrigin := 0;
               wDataH := WindowRect.v2 - WindowRect.v1;
               wDataW := WindowRect.h2 - WindowRect.h1;
               wMaxH := WindowRect.v2 - WindowRect.v1;
               wMaxW := WindowRect.h2 - WindowRect.h1;
               wScrollVer := 0;
               wScrollHor := 0;
               wPageVer := 0;
               wPageHor := 0;
               wInfoRefCon := 0;
               wInfoHeight := 0;
               wFrameDefProc := nil;
               wInfoDefProc := nil;
               wContDefProc := ContentProc;
               wPosition := WindowRect;
               wPlane := pointer(topMost);
               wStorage := nil;
           end;

           WindowHandle[WindowNumber] := NewWindow(WindowRecord[WindowNumber]);
       end;

       procedure SetUpControls;
       var
           TmpRect : Rect;
           Count   : Integer;
       begin
           SetPort(WindowHandle[EditWindow]);

           with TmpRect do
           begin
               h1 := 20;
               h2 := EditRect.h2 - 20 - EditRect.h1;
           end;
        
           with myCtrlColor do
           begin
               barOutline   := $0000;
               barNorArrow  := $0054;
               barSelArrow  := $00bc;
               barArrowBack := $0700;
               barNorThumb  := $00b0;
               barSelThumb  := $0b00;
               barPageRgn   := $00e7;
               barInactive  := $0f00;
           end;
 
           For Count := 1 to 3 do
           begin
               With TmpRect do
               begin
                   v1 := (Count - 1) * 30 + 10;
                   v2 := v1 + 15;
               end;

               With Control[Count] do
               begin
                   CurrValue := 0;
                   LastValue := 0;
                   CtrlHandle := NewControl(WindowHandle[EditWindow],
                                            TmpRect,
                                            Nil,
                                            $001c,
                                            CurrValue,
                                            1,
                                            16,
                                            Pointer($06000000),
                                            0,
                                            @myCtrlColor);
               end;
           end;
           DrawControls(WindowHandle[EditWindow]);
       end;

   begin
       Junk := DeskTop(setDeskPat,$400000ef);

       SetColorTable(15, SpriteFile.PaletteRec);

       For Count := 13 to 199 do
           SetSCB(Count, 15);

       StartUpWindow(EditWindow,
                     EditRect,
                     @RefreshEditWindow);
       HideWindow(WindowHandle[EditWindow]);
       SetUpControls;

       StartUpWindow(TextWindow,
                     TextRect,
                     @RefreshTextWindow);

       StartUpWindow(DrawWindow,
                     DrawRect,
                     @RefreshDrawWindow);

       StartUpWindow(MassWindow,
                     MassRect,
                     @RefreshMassWindow);

       StartUpWindow(ShapeWindow,
                     ShapeWRect,
                     @RefreshShapeWindow);

       StartUpWindow(PaletteWindow,
                     PaletteRect,
                     @RefreshPaletteWindow);

       CurrentWindow := PaletteWindow;
       SelectWindow(WindowHandle[CurrentWindow]);

       CurrentColor := 15;
   end;

   Procedure InitData;
   begin
       With SpriteFile do
       begin
           PaletteRec := DefPalette;
           NumOfSprites := 1;
           TotalSprites := 1;
           Sprite[1].NumOfShapes := 1;
           CreateNewShape(1,1);
       end;

       CurrentSprite := 1;
       CurrentShape := 1;
       SpriteFileName := 'Untitled';

       SpriteNotSaved := False;
       SetAnimation(Off);
       SetMass(Off);
       EditMode := Off;
   end;

   Procedure InitSpreditor;
   begin
       SpriteStartup;
       InitAreas;
       InitData;
       InitMenus;
       InitWindows;
   end;
