Procedure GridRect(x1, x2, y    : Integer;
                   var TmpRect  : Rect);
begin
    with TmpRect do
    begin
        h1 := 3 + ( ( ((x2 - 1)*2) + x1) * 6);
        h2 := h1 + 4;
        v1 := 3 + ((y - 1) * 6);
        v2 := v1 + 4;
    end;
end;

Procedure AnimateSprite;
var
   h,v,Junk : Integer;
begin
   AnimateTimer := AnimateTimer + 1;
   If AnimateTimer = 15 then
   begin
       h := ShapeRect[7].Local.h1 + ShapeWRect.h1 + 2;
       v := ShapeRect[7].Local.v1 + ShapeWRect.v1 + 2;

       With SpriteFile.Sprite[CurrentSprite] do
       begin
           Junk := DrawSprite(16,8,Shape[AnimateShape],-1,0,v,h);

           AnimateShape := AnimateShape + 1;
           If AnimateShape > NumOfShapes then
               AnimateShape := 1;

           If MassOn then
           begin
               h := 2;
               while h < 50 do
               begin
                   v := 2;
                   while v < 50 do
                   begin
                       Junk := DrawSprite(16,8,Shape[AnimateShape],-1,0,
                                          v + MassRect.v1,
                                          h + MassRect.h1);
                       v := v + 16;
                   end;
                   h := h + 16;
               end;
           end;
       end;

       AnimateTimer := 1;
   end;
end;

Procedure DoControls(CtrlFlag : Integer);
var
    Count : Integer;
begin
   DrawControls(WindowHandle[EditWindow]);

   For Count := 1 to 3 do
       With Control[Count] do
       begin
           CurrValue := GetCtlValue(CtrlHandle);
           HiliteControl(CtrlFlag, CtrlHandle);
       end;
end;
