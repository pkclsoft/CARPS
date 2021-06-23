   procedure CheckWindows(MousePosition : Point);
   { Will check the cursor position, and ensure that the window it is in
     is the active window, thus we don't have to click twice in any
     window to do anything. }
   var
       Count       : Integer;
       CurWindow   : grafPortPtr;
       OldWindow   : Integer;
   begin
       OldWindow := CurrentWindow;
       CurWindow := FrontWindow;

       If GetWKind(CurWindow) = SystemWindow
       then
           If EditMode
           then
               Count := MaxWindows
           else
               Count := MaxWindows - 1
       else
           begin
               Count := 0;
               CurrentWindow := SystemWindow;
           end;

       While Count > 0 do
       begin
           If PtInRect(MousePosition, WindowRecord[Count].wPosition) then
           begin
               If (Count <> CurrentWindow) then
               begin
                   SelectWindow(WindowHandle[Count]);
                   CurrentWindow := Count;
                   MouseIsDown := False;
               end;
               Count := 1;
           end;
           Count := Count - 1;
       end;

       If (OldWindow <> CurrentWindow) and
          (OldWindow = SystemWindow) then
       begin
           If CurrentWindow <> EditWindow then
               SelectWindow(WindowHandle[EditWindow]);
           DoControls(0);
           If CurrentWindow <> EditWindow then
               SelectWindow(WindowHandle[CurrentWindow]);
       end;
   end;

   Procedure BringAllToFront(RefreshWindow : Integer);
   var
       Count : Integer;
   begin
       If CurrentWindow <> SystemWindow then
       begin
           For Count := 1 to MaxWindows do
               If Count <> RefreshWindow then
                   BringToFront(WindowHandle[Count]);
       end;
   end;

   Procedure RefreshEditWindow;
   var
       TmpRect : Rect;
       Count   : Integer;
       PartNum : Integer;
   begin
       SetPort(WindowHandle[EditWindow]);
       SetSolidPenPat(14);
       GetPortRect(TmpRect);
       PaintRect(TmpRect);

       DoControls(0);

       SetForeColor(0);
       SetBackColor(14);

       For Count := 0 to 2 do
       begin
           moveto(0,(Count * 30) + 20);
           Case Count of
               0   :   Write('R');
               1   :   Write('G');
               2   :   Write('B');
           end;
       end;

       BringAllToFront(ShapeWindow);
   end;

   Procedure RefreshShapeWindow;
   var
       Count   : Integer;
       TmpRect : Rect;
       h,v     : Integer;
       Junk    : Integer;
   begin
       SetPort(WindowHandle[ShapeWindow]);
       GetPortRect(TmpRect);
       SetSolidPenPat(14);
       PaintRect(TmpRect);

       SetSolidPenPat(0);
       For Count := 0 to 7 do
           PaintRect(ShapeRect[Count].Local);

       With SpriteFile.Sprite[CurrentSprite] do
       begin
           For Count := 0 to (NumOfShapes - 1) do
           begin
               h := ShapeRect[Count].Local.h1 + ShapeWRect.h1 + 2;
               v := ShapeRect[Count].Local.v1 + ShapeWRect.v1 + 2;
               Junk := DrawSprite(16,8,Shape[Count+1],-1,0,v,h);
           end;
       end;

       SetSolidPenPat(7);
       FrameRect(ShapeRect[CurrentShape - 1].Local);

       BringAllToFront(ShapeWindow);
   end;

   Procedure RefreshMassWindow;
   var
       TmpRect : Rect;
       h,v     : Integer;
       Junk    : Integer;
   begin
       SetPort(WindowHandle[MassWindow]);
       SetSolidPenPat(0);
       GetPortRect(TmpRect);
       PaintRect(TmpRect);

       If MassOn then
       begin
           h := 2;
           while h < 50 do
           begin
               v := 2;
               while v < 50 do
               begin
                   With SpriteFile.Sprite[CurrentSprite] do
                       Junk := DrawSprite(16,8,Shape[1],-1,0,
                                          v + MassRect.v1,
                                          h + MassRect.h1);
                   v := v + 16;
               end;
               h := h + 16;
           end;
       end;

       BringAllToFront(MassWindow);
   end;

   Procedure RefreshTextWindow;
   var
       TmpRect : Rect;
   begin
       SetPort(WindowHandle[TextWindow]);
       SetSolidPenPat(14);
       GetPortRect(TmpRect);
       PaintRect(TmpRect);

       SetForeColor(0);
       SetBackColor(14);
       MoveTo(5,10);
       writeln('Filename : ',SpriteFileName);
       writeln('Sprites  : ',SpriteFile.NumOfSprites:3);
       writeln;
       writeln('Current Sprite   : ',CurrentSprite:3);
       writeln('Number of shapes : ',SpriteFile.Sprite[CurrentSprite].NumOfShapes:3);

       BringAllToFront(TextWindow);
   end;

   Procedure RefreshDrawWindow;
   var
       h,i,j   : Integer;
       TmpRect : Rect;
   begin
       SetPort(WindowHandle[DrawWindow]);
       SetSolidPenPat(0);
       GetPortRect(TmpRect);
       PaintRect(TmpRect);

       With SpriteFile.Sprite[CurrentSprite] do
           For i := 1 to 8 do
               For h := 0 to 1 do
                   For j := 1 to 16 do
                   begin
                       GridRect(h,i,j,TmpRect);
                       SetSolidPenPat(GetNibble(Shape[CurrentShape]^.Grid[j,i],h));
                       PaintRect(TmpRect);
                   end;

       BringAllToFront(DrawWindow);
   end;

   Procedure RefreshPaletteWindow;
   var
       Count : Integer;
       TmpRect : Rect;
   begin
       SetPort(WindowHandle[PaletteWindow]);
       For Count := 0 to 15 do
       begin
           SetSolidPenPat(0);
           FrameRect(ColorRect[Count].Border);
           SetSolidPenPat(Count);
           PaintRect(ColorRect[Count].Area);
       end;

       SetSolidPenPat(7);
       FrameRect(ColorRect[CurrentColor].Border);

       BringAllToFront(PaletteWindow);
   end;
