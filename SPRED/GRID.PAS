{$ optimize 7}
{$ keep 'grid'}
program grid (input,output);

uses
   Common, QuickDrawII, WindowMgr, LineEdit, CarpLib;


var

   x, y : integer;
   s    : string;
   sh   : array [1..8] of GridType;
   h,i,j,k,junk : Integer;
begin

   StartGraph(320);
   SpriteStartUp;
   for h := 1 to 8 do
       for i := 1 to 10 do
           for j := 0 to 1 do
               for k := 1 to 16 do
                   sh[h].grid[k,i] := setnibble(h-1,sh[h].grid[k,i],j);

   h := 1;
   for i := 0 to 15 do
       for j := 0 to 9 do
       begin
           x := i*20;
           y := j*20;
           junk := drawsprite(16,8,pointer(@sh[h]),-1,0,y,x);
           h := h + 1;
           if h = 8 then h := 1;
       end;

   x := 1;

   for y := 1 to 500 do
   begin
       h := 1;
       for i := 0 to 15 do
           for j := 0 to 9 do
           begin
               if h = 1 then
                   junk := drawsprite(16,8,pointer(@sh[x]),-1,0,j*20,i*20);
               h := h + 1;
               if h = 8 then h := 1;
           end;
       x := x + 1;
       if x = 9 then x := 1;
   end;

   SetSolidPenPat(3);
   moveto(0,20);
   write('Press return : ');
   readln(s);

   EndGraph;
end.
