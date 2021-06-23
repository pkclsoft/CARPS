Procedure SaveSpriteFile(MyFileName : PathName);
var
   OutFile      : File of Byte;
   SpriteNumber : Integer;
   ShapeNumber  : Integer;
   Count        : Integer;
   XAxis        : Integer;
   YAxis        : Integer;
begin
   rewrite(OutFile, MyFileName);

   With SpriteFile do
   begin
       For Count := 0 to 15 do
       begin
           Write(OutFile,ConvI2B(PaletteRec[Count]).lsb);
           Write(OutFile,ConvI2B(PaletteRec[Count]).msb);
       end;

       Write(OutFile,ConvI2B(NumOfSprites).lsb);
       Write(OutFile,ConvI2B(NumOfSprites).msb);

       For SpriteNumber := 1 to NumOfSprites do
           With Sprite[SpriteNumber] do
           begin
               Write(OutFile,ConvI2B(NumOfShapes).lsb);
               Write(OutFile,ConvI2B(NumOfShapes).msb);

               For ShapeNumber := 1 to NumOfShapes do
                   For YAxis := 1 to 16 do
                       For XAxis := 1 to 8 do
                           With Shape[ShapeNumber]^ do
                               Write(OutFile,Grid[YAxis,XAxis]);
           end;
   end;

   SpriteNotSaved := False;

end;

Procedure LoadSpriteFile(MyFileName : PathName);
var
   InFile       : File of Byte;
   SpriteNumber : Integer;
   ShapeNumber  : Integer;
   Count        : Integer;
   XAxis        : Integer;
   YAxis        : Integer;
   ByteValue    : Byte;
   WordValue    : Integer;
begin
   reset(InFile, MyFileName);

   With SpriteFile do
   begin
       For Count := 0 to 15 do
       begin
           Read(InFile,ByteValue);
           WordValue := ByteValue;
           PaletteRec[Count] := WordValue;
           Read(InFile, ByteValue);
           WordValue := ByteValue;
           PaletteRec[Count] := PaletteRec[Count] + (WordValue << 8);
       end;

       Read(InFile, ByteValue);
       NumOfSprites := ByteValue;
       Read(InFile, ByteValue);
       WordValue := ByteValue;
       NumOfSprites := NumOfSprites + (WordValue << 8);

       For SpriteNumber := 1 to NumOfSprites do
       begin
           With Sprite[SpriteNumber] do
           begin
               Read(InFile,ByteValue);
               WordValue := ByteValue;
               NumOfShapes := WordValue;
               Read(InFile,ByteValue);
               WordValue := ByteValue;
               NumOfShapes := NumOfShapes + (WordValue << 8);

               For ShapeNumber := 1 to NumOfShapes do
               begin
                   New(Shape[ShapeNumber]);
                   For YAxis := 1 to 16 do
                   begin
                       For XAxis := 1 to 8 do
                       begin
                           With Shape[ShapeNumber]^ do
                           begin
                               Read(InFile,Grid[YAxis,XAxis]);
                           end;
                       end;
                   end;
               end;
           end;
       end;
   end;

   Close(InFile);
end;

Procedure SaveSpriteAs;
var
   MyReply : replyRecord;
begin
   SFPutFile(30, 20, @'Save sprite file as:', @SpriteFilename, 15, MyReply);

   With MyReply do
   begin
       If Good then
       begin
           SaveSpriteFile(FullPathName);

           If Filename <> SpriteFileName then
               SpriteFileName := FileName;
       end;
   end;
end;

Procedure LoadSpriteAs;
var
   MyReply      : replyRecord;
   TList        : typeList;
begin
   ClearCurrentSpriteFile;

   If not SpriteNotSaved then
   begin
       TList.NumEntries := 1;
       TList.FileType[1] := $06;

       SFGetFile(30, 20, @'Load which Sprite File :', Nil, @TList, MyReply);

       With MyReply do
       begin
           If Good then
           begin
               LoadSpriteFile(MyReply.FullPathName);

               SpriteFileName := FileName;
               CurrentSprite := 1;
               CurrentShape := 1;
               SetAnimation(Off);
               SetColorTable(15, SpriteFile.PaletteRec);
               RefreshShapeWindow;
               RefreshMassWindow;
           end;
       end;
   end;
end;
