procedure DoMouseDown(MousePosition : Point);

   Procedure SelectColor;
   var
       Count   : Integer;
       Count2  : Integer;
   begin
       For Count := 0 to 15 do
       begin
           If PtInRect(MousePosition, ColorRect[Count].Actual) then
           begin
               If Count <> CurrentColor then
               begin
                   SetPort(WindowHandle[PaletteWindow]);

                   SetSolidPenPat(0);
                   FrameRect(ColorRect[CurrentColor].Border);

                   CurrentColor := Count;

                   SetSolidPenPat(7);
                   FrameRect(ColorRect[CurrentColor].Border);

                   MouseIsDown := False;

                   If EditMode then
                   begin
                       With SpriteFile do
                       begin
                           Control[1].CurrValue := PaletteRec[Count] div 256;
                           Control[2].CurrValue := (PaletteRec[Count] & $00f0) div 16;
                           Control[3].CurrValue := PaletteRec[Count] & $000f;
                           For Count2 := 1 to 3 do
                           begin
                               Control[Count2].LastValue := Control[Count2].CurrValue;
                               SetCtlValue(Control[Count2].CurrValue, Control[Count2].CtrlHandle);
                           end;
                           SelectWindow(WindowHandle[EditWindow]);
                           DoControls(0);
                           SelectWindow(WindowHandle[PaletteWindow]);
                       end;
                   end;
               end;
           end;
       end;
   end;

   Procedure SelectShape;
   var
       Count   : Integer;
   begin
       For Count := 0 to 6 do
       begin
           If PtInRect(MousePosition, ShapeRect[Count].Global) then
           begin
               With SpriteFile.Sprite[CurrentSprite] do
               begin
                   If ((Count + 1) <> CurrentShape) and
                      (Count <= (NumOfShapes - 1)) then
                   begin
                       SetPort(WindowHandle[ShapeWindow]);

                       SetSolidPenPat(0);
                       FrameRect(ShapeRect[CurrentShape - 1].Local);

                       CurrentShape := Count + 1;

                       SetSolidPenPat(7);
                       FrameRect(ShapeRect[CurrentShape - 1].Local);

                       RefreshDrawWindow;
                   end;
               end;
           end;
       end;
   end;

   Procedure DrawDot;
   var
       TmpRect      : Rect;
       h,i,j,v,Junk : Integer;
   begin
       i := MousePosition.h - DrawRect.h1 - 3;
       i := i div 6;
       h := (i mod 2);
       i := (i div 2) + 1;
       j := MousePosition.v - DrawRect.v1 - 3;
       j := (j div 6) + 1;

       If  (j < 17) and (i < 9) then
           With SpriteFile.Sprite[CurrentSprite] do
           begin
               SetPort(WindowHandle[DrawWindow]);
               Shape[CurrentShape]^.Grid[j,i] :=
                   SetNibble(CurrentColor,Shape[CurrentShape]^.Grid[j,i],h);
               GridRect(h,i,j,TmpRect);
               SetSolidPenPat(GetNibble(Shape[CurrentShape]^.Grid[j,i],h));
               PaintRect(TmpRect);
               h := ShapeRect[CurrentShape-1].Local.h1 + ShapeWRect.h1 + 2;
               v := ShapeRect[CurrentShape-1].Local.v1 + ShapeWRect.v1 + 2;
               Junk := DrawSprite(16,8,Shape[CurrentShape],-1,0,v,h);
           end;

       SpriteNotSaved := True;
   end;

   Procedure DoScrollBar;
   var
       theControl : ctlRecHndl;
       Count      : Integer;
       Part       : Integer;

   begin
       Part := FindControl(theControl, MousePosition.h, MousePosition.v,
                           WindowHandle[EditWindow]);

       If theControl <> Nil { Found } then
       begin
           Count := 1;
           While theControl <> Control[Count].CtrlHandle do
               Count := Count + 1;

           With Control[Count] do
           begin
               Part := TrackControl(MousePosition.h, MousePosition.v,
                                    @TrackValue, theControl);
               CurrValue := GetCtlValue(theControl);
               If CurrValue <> LastValue then
               begin
                   With SpriteFile do
                   begin
                       LastValue := PaletteRec[CurrentColor];
                       Case Count of
                           1   :   LastValue := (LastValue & $00ff) +
                                       (CurrValue * 256);
                           2   :   LastValue := (LastValue & $0f0f) +
                                       (CurrValue * 16);
                           3   :   LastValue := (LastValue & $0ff0) +
                                       CurrValue;
                       end;
                       PaletteRec[CurrentColor] := LastValue;
                       SetColorEntry(15, CurrentColor, LastValue);
                   end;

                   LastValue := CurrValue;
               end;
           end;
       end;
       MouseIsDown := False;
   end;

begin
   case CurrentWindow of
       PaletteWindow   :   SelectColor;
       ShapeWindow     :   SelectShape;
       DrawWindow      :   DrawDot;
       EditWindow      :   DoScrollBar;
       otherwise       :   ;
   end;
end;
