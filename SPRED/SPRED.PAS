{$ keep 'Spred' }
Program SpriteEditor(Input, Output);

{ This program will allow the Game designer to create/edit sprites for use
  in the Computer Aided Role Playing System (C.A.R.P.S).  It will allow the
  creation of a file with a record structure that describes one Sprite.  A
  sprite may consist of one to seven shapes which can be used to produce
  internal animation by drawing each shape at the sam location.

  The Sprite library (Sprites.ASM), written in assembly language is used
  for the actual drawing of the sprites/shapes.  For more detail on this
  library, see it's source file.  Before the library can be used however,
  a call must be made to SpriteStartUp which will initialise a lookup table
  used by the library. }

uses Common, QuickDrawII, EventMgr, WindowMgr, ControlMgr, DeskMgr,
     DialogMgr, MenuMgr, MscToolSet, SFToolSet, CarpLib;

   {$ copy 'SpredData.pas' }
   {$ copy 'SpredMisc.pas' }
   {$ copy 'SpredDraw.pas' }
   {$ copy 'SpredWndw.pas' }
   {$ copy 'SpredFile.pas' }
   {$ copy 'SpredInit.pas' }

   Procedure EventLoop;
   var
       Done        : Boolean;          { tells if the program should Stop  }
       Event       : Integer;          { Event #; Returned by TaskMaster   }
       LastEvent   : EventRecord;      { last Event Returned in Event loop }
       Count       : Integer;

       {$ copy 'SpredMouse.pas' }
       {$ copy 'SpredMenu.pas' }

   begin
       Done := False;
       LastEvent.taskMask := $1FFF;
       Event := nullEvt;
       MouseIsDown := False;
       repeat
           CheckWindows(LastEvent.eventWhere);
           If MouseIsDown then
               DoMouseDown(LastEvent.eventWhere);
           Event := TaskMaster($076e, LastEvent);

           If AnimateOn then
               AnimateSprite;

           case LastEvent.eventWhat of
               MouseDownEvt    :   MouseIsDown := True;
               MouseUpEvt      :   MouseIsDown := False;
               ActivateEvt     :   begin
                                       SetPort(WindowHandle[EditWindow]);
                                       If CurrentWindow = SystemWindow
                                       then
                                           DoControls(255);
                                   end;
               otherwise       :   ;
           end;

           case Event of
               wInSpecial,
               wInMenuBar  :   HandleMenu(ConvL2I(LastEvent.taskData).lsw);
               otherwise   :   ;
           end; {case}
       until Done;
   end;

begin
   StartDesk(320);
   InitSpreditor;
   ShowCursor;

   EventLoop;

   EndDesk;
end.

{$ append 'spredbar.asm'}
