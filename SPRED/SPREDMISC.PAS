function DoAlert(kind: alertKind; msg: pString) : boolean;
(* handle an alert box                                         *)
(*                                                             *)
(* parameters:                                                 *)
(*     kind - kind of alert                                    *)
(*     msg - alert message                                     *)
 
VAR
  message:      itemTemplate;
  button:       itemTemplate;     (*button & message items*)
  cancelButton: itemTemplate;     (*button & message items*)
  alertRec:     alertTemplate;    (*alert box*)
  chosenButton: integer;          (*for receiving NoteAlert value*)
  okString:     pString;
  cancelString: pString;
 
BEGIN
  okString := 'OK';
  cancelString := 'Cancel';

  SetForeColor(0);                     (*set text colors*)
  SetBackColor(15);

  WITH alertRec DO                (*initialize alert box*)
  BEGIN
    WITH atBoundsRect DO
    BEGIN
      v1 := 50;
      h1 := 20;
      v2 := 117;
      h2 := 300;
    END;

    atAlertID := 2;
    atStage1 := 128;
    atStage2 := 128;
    atStage3 := 128;
    atStage4 := 128;
    atItemList[1] := @button;

    if kind = caution then
    begin
        atItemList[2] := @cancelButton;
        atItemList[3] := @message;
        atItemList[4] := nil;
    end else begin
        atItemList[2] := @message;
        atItemList[3] := nil;
    end;
  END;

  WITH button DO                 (*initialize button item*)
  BEGIN
    itemID := 1;

    WITH itemRect DO 
    BEGIN
      v1 := 36;
      h1 := 15;
      v2 := 0;
      h2 := 0;
    END;

    itemType := buttonItem;
    itemDescr := @okString;
    itemValue := 0;
    itemFlag := 0;
    itemColor := nil;
  END;

  if kind = caution then
  begin
      WITH cancelButton DO                 (*initialize button item*)
      BEGIN
        itemID := 2;
    
        WITH itemRect DO 
        BEGIN
          v1 := 36;
          h1 := 190;
          v2 := 0;
          h2 := 0;
        END;
    
        itemType := buttonItem;
        itemDescr := @cancelString;
        itemValue := 0;
        itemFlag := 0;
        itemColor := nil;
      END;
  end;
  
  WITH message DO                 (*initialize message item*)
  BEGIN
    itemID := 100;

    WITH itemRect DO
    BEGIN
      v1 := 5;
      h1 := 100;
      v2 := 62;
      h2 := 310;
    END;

    itemType := itemDisable+statText;
    itemDescr := @msg;
    itemValue := 0;
    itemFlag := 0;
    itemColor := nil;
  END;

  CASE kind OF                         (*handle the alert*)
    norml:      chosenButton := Alert(alertRec, nil);
    stop:       chosenButton := StopAlert(alertRec, nil);
    note:       chosenButton := NoteAlert(alertRec, nil);
    caution:    chosenButton := CautionAlert(alertRec, nil);
    otherwise   chosenButton := 0;
  END; (*case*)
  
  DoAlert := (chosenButton = 1);
END;

Procedure CreateNewShape(SpriteNumber, ShapeNumber : Integer);
var
   h,i,j : Integer;
begin
   With SpriteFile.Sprite[SpriteNumber] do
   begin
       New(Shape[ShapeNumber]);
       For i := 1 to 8 do
           For h := 0 to 1 do
               For j := 1 to 16 do
                   Shape[ShapeNumber]^.Grid[j,i] :=
                       SetNibble(15,Shape[ShapeNumber]^.Grid[j,i],h);
   end;
end;

Procedure DeleteSprite(SpriteNumber : Integer);
var
   Count : Integer;
begin
   With SpriteFile.Sprite[SpriteNumber] do
       For Count := 1 to NumOfShapes do
           Dispose(Shape[Count]);

   With SpriteFile do
       If SpriteNumber < NumOfSprites then
           For Count := SpriteNumber to (NumOfSprites - 1) do
               Sprite[Count] := Sprite[Count + 1];
end;

Procedure ClearCurrentSpriteFile;
var
   SpriteNumber : Integer;
   Msg          : pString;
begin
   Msg := concat('Lose current Sprite', chr(Return), 'File ?');
   If SpriteNotSaved then
       SpriteNotSaved := not(DoAlert(Caution, Msg));

   If not SpriteNotSaved then
       For SpriteNumber := SpriteFile.NumOfSprites downto 1 do
           DeleteSprite(SpriteNumber);
end;

Procedure SetAnimation(State : Boolean);
begin
   AnimateOn := State;

   If AnimateOn
   then
       If SpriteFile.Sprite[CurrentSprite].NumOfShapes > 1
       then
           begin
               AnimateShape := 1;
               AnimateTimer := 1;
           end
       else
           AnimateOn := False;

   CheckMItem(AnimateOn, SpriteAnimate);
end;

procedure TrackValue(thePart : Integer;
                     theCtl  : ctlRecHndl);
var
   CurrValue : integer;
begin
   CurrValue := GetCtlValue(theCtl);

   case thePart of
       5   :   if CurrValue > 0 then                   { Up Arrow }
                   SetCtlValue(CurrValue - 1, theCtl);

       6   :   if CurrValue < 15 then                 { Down Arrow }
                   SetCtlValue(CurrValue + 1, theCtl);
       7   :   begin                                   { Page Up }
                   CurrValue := CurrValue - 1;
                   if CurrValue < 0 then
                       CurrValue := 0;
                   SetCtlValue(CurrValue, theCtl);
               end;
       8   :   begin                                   { Page Down }
                   CurrValue := CurrValue + 1;
                   If CurrValue > 15 then
                       CurrValue := 15;
                   SetCtlValue(CurrValue, theCtl);
               end;
     129   :   ;                                       { Thumb }
     Otherwise : ;
   end;
end;

Procedure SetMass(State : Boolean);
begin
   MassOn := State;

   CheckMItem(MassOn, SpriteMass);
end;

Procedure AddNewSprite;
begin
   With SpriteFile do
   begin
       If NumOfSprites < MaxSprites then
       begin
           NumOfSprites := NumOfSprites + 1;
           CreateNewShape(NumOfSprites, 1);
           Sprite[NumOfSprites].NumOfShapes := 1;
       end;
   end;
end;

function ScrollDialogBar(command : Integer;
                         dlog    : procPtr;
                         item    : Integer) : Integer; Extern;

Function ChooseSprite(Msg          : pString;
                      AddButtonOn  : Boolean) : Integer;
Const
   OkButton        = 1;
   CancelButton    = 2;
   MessageText     = 3;
   ScrollBar       = 4;
   AddButton       = 5;
var
   MyDialogTemplate    : dialogTemplate;
   DialogResult        : LongInt;

   itemHit             : Integer;
   TmpRect             : Rect;
   TmpGrid             : GridType;
   h,i                 : Integer;

   Procedure DrawScrollRegion(TopSprite : Integer);
   var
       h,i,j,k,v : Integer;
       Junk      : Integer;
       BlankRect : Rect;
   
   begin
       k := TopSprite;
       j := 0;
   
       with SpriteFile do
       begin
           while (j < 6) and
                 (k <= NumOfSprites) do
           begin
               For i := 1 to 7 do
               begin
                   h := TmpRect.h1 + TextRect.h1 + (i - 1) * 16 + 2;
                   v := TmpRect.v1 + TextRect.v1 + j * 16 + 1;
   
                   With Sprite[k] do
                       If i <= NumOfShapes
                       then
                           Junk := DrawSprite(16,8,Shape[i],-1,0,v,h)
                       else                        
                           Junk := DrawSprite(16,8,@TmpGrid,-1,0,v,h);
               end;
               j := j + 1;
               k := k + 1;
           end;
       end;
   
       If j < 6 then
       begin
           With BlankRect do
           begin
               v1 := TmpRect.v1 + j * 16 + 1;
               h1 := TmpRect.h1 + 1;
               h2 := TmpRect.h2 - 1;
               v2 := TmpRect.v2 - 1;
           end;
   
           SetSolidPenPat(15);
           PaintRect(BlankRect);
       end;
   end;
   
begin
   For h := 1 to 8 do
       For i := 1 to 16 do
           TmpGrid.Grid[i,h] := 0;
   
   With MyDialogTemplate do
   begin
       With dtBoundsRect do
       begin
           h1 := TextRect.h1;
           v1 := TextRect.v1;
           h2 := MassRect.h2;
           v2 := MassRect.v2;
       end;

       With TmpRect do
       begin
           h1 := ((dtBoundsRect.h2 - dtBoundsRect.h1) - 134) div 2;
           v1 := 34;
           h2 := h1 + 114;
           v2 := 132;
       end;

       dtVisible := True;

       dtRefCon := 1;

       new(dtItemList[OkButton]);
       With dtItemList[OkButton]^ do
       begin
           itemId := OkButton;

           with itemRect do
           begin
               h1 := 10;
               v1 := 140;
               h2 := 0;
               v2 := 0;
           end;

           itemType := buttonItem;
           itemDescr := @'Ok';
           itemValue := 0;
           itemFlag := 0;
           itemColor := Nil;
       end;

       new(dtItemList[CancelButton]);
       With dtItemList[CancelButton]^ do
       begin
           itemId := CancelButton;

           with itemRect do
           begin
               h1 := 70;
               v1 := 140;
               h2 := 0;
               v2 := 0;
           end;

           itemType := buttonItem;
           itemDescr := @'Cancel';
           itemValue := 0;
           itemFlag := 0;
           itemColor := Nil;
       end;

       new(dtItemList[MessageText]);
       With dtItemList[MessageText]^ do
       begin
           itemId := MessageText;

           with itemRect do
           begin
               h1 := 10;
               v1 := 10;
               h2 := 300;
               v2 := 20;
           end;

           itemType := statText;
           itemDescr := @Msg;
           itemValue := 0;
           itemFlag := 0;
           itemColor := Nil;
       end;

       new(dtItemList[ScrollBar]);
       With dtItemList[ScrollBar]^ do
       begin
           itemId := ScrollBar;

           with itemRect do
           begin
               h1 := TmpRect.h1 + 114;
               v1 := TmpRect.v1;
               h2 := h1 + 30;
               v2 := TmpRect.v2;
           end;

           itemType := scrollBarItem;
           itemDescr := @ScrollDialogBar;
           itemValue := 0;
           itemFlag := $03;
           itemColor := Nil;
       end;

       new(dtItemList[AddButton]);
       With dtItemList[AddButton]^ do
       begin
           itemId := AddButton;

           with itemRect do
           begin
               h1 := 160;
               v1 := 140;
               h2 := 0;
               v2 := 0;
           end;

           itemType := buttonItem;
           itemDescr := @'Add New Sprite';
           itemValue := 0;
           itemFlag := 0;
           itemColor := Nil;
       end;

       dtItemList[AddButton + 1] := Nil;
   end;

   theValue := CurrentSprite;
   TotalSprites := SpriteFile.NumOfSprites - 1;
   MyDialog := GetNewModalDialog(MyDialogTemplate);

   If AddButtonOn
   then
       ShowDItem(MyDialog, AddButton)
   else
       HideDItem(MyDialog, AddButton);

   SetPort(MyDialog);
   SetSolidPenPat(0);
   FrameRect(TmpRect);

   itemHit := CancelButton + 1;
   DrawScrollRegion(CurrentSprite);

   while (itemHit > CancelButton) do
   begin
       DialogResult := ModalDialog(Nil);

       itemHit := ConvL2I(DialogResult).lsw;

       If itemHit = AddButton then
       begin
           h := GetDItemValue(MyDialog, ScrollBar);
           AddNewSprite;
           TotalSprites := SpriteFile.NumOfSprites - 1;
           RemoveDItem(MyDialog, ScrollBar);
           GetNewDItem(MyDialog, MyDialogTemplate.dtItemList[ScrollBar]^);
           SetDItemValue(h, MyDialog, ScrollBar);
       end;

       DrawScrollRegion(GetDItemValue(MyDialog, ScrollBar) + 1);
   end;

   If itemHit = OkButton
   then
       ChooseSprite := GetDItemValue(MyDialog, ScrollBar) + 1
   else
       ChooseSprite := CurrentSprite;

   CloseDialog(MyDialog);
end;
