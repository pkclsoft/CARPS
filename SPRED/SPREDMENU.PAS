procedure HandleMenu(MenuNum : Integer);
var
   Junk : Integer;

   procedure AboutSpreditor;
   var
       Msg  : pString;                  {alert Message}
       Junk : Boolean;
   begin
       Msg := concat('Sprite Editor v1.0', chr(Return),
                     'Copyright 1987',     chr(Return),
                     'C.A.R.P.S, Inc.',    chr(Return),
                                           chr(Return),
                     'By Peter Easdown');
       Junk := DoAlert(Note,Msg);
   end;

   Procedure NewShape;
   begin
       With SpriteFile.Sprite[CurrentSprite] do
       begin
           If NumOfShapes < MaxShapes then
           begin
               NumOfShapes := NumOfShapes + 1;
               CreateNewShape(CurrentSprite,NumOfShapes);
               CurrentShape := NumOfShapes;
               RefreshDrawWindow;
               RefreshShapeWindow;
           end;
       end;
   end;

   Procedure ToggleAnimation;
   begin
       If AnimateOn
       then
           AnimateOn := Off
       else
           AnimateOn := On;

       SetAnimation(AnimateOn);
   end;

   Procedure NewSpriteFile;
   begin
       ClearCurrentSpriteFile;
       If Not SpriteNotSaved then
       begin
           InitData;
           RefreshDrawWindow;
           RefreshShapeWindow;
           RefreshTextWindow;
           RefreshMassWindow;
       end;
   end;

   Procedure CloseSpriteFile;
   var
       Msg    : pString;
       SaveIt : Boolean;
   begin
       Msg := concat('Save current Sprite', chr(Return),
                     'File before closing ?');
       If SpriteNotSaved then
           SaveIt := DoAlert(Caution,Msg);

       If SaveIt then
       begin
           SaveSpriteAs;
           If Not SpriteNotSaved then
               NewSpriteFile;
       end;
   end;

   Function QuitProgram : Boolean;
   var
       Msg : pString;                  {alert Message}

   begin
       If SpriteNotSaved
       then
           begin
               CloseSpriteFile;
               QuitProgram := not SpriteNotSaved;
           end
       else
           begin
               Msg := concat('Are you sure you',chr(Return),
                             'wish to quit ?');
               QuitProgram := DoAlert(Caution,Msg);
           end;
   end;

   Procedure NewSprite;
   begin
       With SpriteFile do
       begin
           If NumOfSprites < MaxSprites then
           begin
               AddNewSprite;
               CurrentSprite := NumOfSprites;
               CurrentShape := 1;
               SetAnimation(Off);
               SetMass(Off);
               RefreshDrawWindow;
               RefreshShapeWindow;
               RefreshTextWindow;
               RefreshMassWindow;
           end;
       end;
   end;

   Procedure ToggleEditWindow;
   var
       Count : Integer;
   begin
       If Not EditMode
       then
           begin
               SetAnimation(Off);
               ShowWindow(WindowHandle[EditWindow]);
               HideWindow(WindowHandle[TextWindow]);
               HideWindow(WindowHandle[DrawWindow]);
               HideWindow(WindowHandle[MassWindow]);
               HideWindow(WindowHandle[ShapeWindow]);
               SetMenuFlag($0080, ShapeMenu);
               SetMenuFlag($0080, SpriteMenu);
               For Count := FileNew to FileClose do
                   DisableMItem(Count);
               With SpriteFile do
               begin
                   Control[1].CurrValue := PaletteRec[CurrentColor] div 256;
                   Control[2].CurrValue := (PaletteRec[CurrentColor] & $00f0) div 16;
                   Control[3].CurrValue := PaletteRec[CurrentColor] & $000f;
                   For Count := 1 to 3 do
                   begin
                       Control[Count].LastValue := Control[Count].CurrValue;
                       SetCtlValue(Control[Count].CurrValue, Control[Count].CtrlHandle);
                   end;
               end;
           end
       else
           begin
               HideWindow(WindowHandle[EditWindow]);
               ShowWindow(WindowHandle[TextWindow]);
               ShowWindow(WindowHandle[DrawWindow]);
               ShowWindow(WindowHandle[MassWindow]);
               ShowWindow(WindowHandle[ShapeWindow]);
               SetMenuFlag($ff7f, ShapeMenu);
               SetMenuFlag($ff7f, SpriteMenu);
               For Count := FileNew to FileClose do
                   EnableMItem(Count);
               CurrentWindow := SystemWindow;
           end;

       EditMode := not(EditMode);
       CheckMItem(EditMode, FilePalette);
   end;

   Procedure ToggleMass;
   begin
       If MassOn
       then
           MassOn := Off
       else
           MassOn := On;

       SetMass(MassOn);
       RefreshMassWindow;
   end;

   Procedure SelectSprite;
   var
       NewSpriteNum : Integer;
   begin
       NewSpriteNum := ChooseSprite('Select new sprite to work with ...', On);

       If (NewSpriteNum > 0) and
          (NewSpriteNum <> CurrentSprite) and
          (NewSpriteNum <= SpriteFile.NumOfSprites) then
       begin
           CurrentSprite := NewSpriteNum;
           CurrentShape := 1;
           SetAnimation(Off);
           SetMass(Off);
           RefreshDrawWindow;
           RefreshShapeWindow;
           RefreshMassWindow;
       end;
   end;

   Procedure CopySprite;
   var
       NewSpriteNum : Integer;
   begin
       NewSpriteNum := ChooseSprite('Select sprite to copy from ...', Off);

       NewSpriteNum := ChooseSprite('Select new sprite to copy to ...', On);
   end;

begin
   case MenuNum of
       AppleAbout      :   AboutSpreditor;
       FileNew         :   NewSpriteFile;
       FileOpen        :   LoadSpriteAs;
       FileSave        :   SaveSpriteFile(SpriteFileName);
       FileSaveAs      :   SaveSpriteAs;
       FileClose       :   CloseSpriteFile;
       FilePalette     :   ToggleEditWindow;
       FileDefPalette  :   begin
                               SpriteFile.PaletteRec := DefPalette;
                               SetColorTable(15, SpriteFile.PaletteRec);
                           end;
       FileQuit        :   Done := QuitProgram;
       SpriteSelect    :   SelectSprite;
       SpriteNew       :   NewSprite;
       SpriteCopy      :   CopySprite;
       SpriteClear     :   ;
       SpriteDelete    :   ;
       SpriteAnimate   :   ToggleAnimation;
       SpriteMass      :   ToggleMass;
       ShapeNew        :   NewShape;
       otherwise       :   ;
   end;
   HilIteMenu(False,ConvL2I(LastEvent.TaskData).msw);
end;
