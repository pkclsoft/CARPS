Const
   AppleMenu       = 0;
   AppleAbout      = 257;

   FileMenu        = 1;
   FileNew         = 500;
   FileOpen        = 501;
   FileSave        = 502;
   FileSaveAs      = 503;
   FileClose       = 504;
   FilePalette     = 505;
   FileDefPalette  = 506;
   FileQuit        = 507;

   EditMenu        = 2;
   EditUndo        = 250;
   EditCut         = 251;
   EditCopy        = 252;
   EditPaste       = 253;
   EditClear       = 254;

   SpriteMenu      = 3;
   SpriteSelect    = 300;
   SpriteNew       = 301;
   SpriteCopy      = 302;
   SpriteClear     = 303;
   SpriteDelete    = 304;
   SpriteAnimate   = 305;
   SpriteMass      = 306;

   ShapeMenu       = 4;
   ShapeNew        = 400;
   ShapeCopy       = 401;
   ShapeClear      = 402;
   ShapeDelete     = 403;

   Return          = 13;
 
   MaxWindows      = 6;

   SystemWindow    = 0;
   TextWindow      = 1;
   DrawWindow      = 2;
   PaletteWindow   = 3;
   ShapeWindow     = 4;
   MassWindow      = 5;
   EditWindow      = 6;
   
   On              = true;
   Off             = false;

Type
   ColorRType  = Record
                   Border  : Rect;
                   Actual  : Rect;
                   Area    : Rect;
                 end;

   ShapeRType  = Record
                   Local   : Rect;
                   Global  : Rect;
                 end;

   CtrlRecord  = Record
                   CtrlHandle  : ctlRecHndl;
                   CurrValue   : Integer;
                   LastValue   : Integer;
                 end;
                 
  alertKind = (norml, stop, note, caution); (*kinds of alerts*)

    ConvL2I         = record       { For splitting a longint into 2 integers  }
                        case Boolean of
                            True    : (long: longint);
                            False   : (lsw,msw: Integer);
                        end;
 
    ConvI2B         = record       { For splitting an integer into 2 bytes    }
                        case Boolean of
                            True    : (Int: Integer);
                            False   : (lsb,msb: Byte);
                        end;

var
   PaletteRect     : Rect;
   TextRect        : Rect;
   DrawRect        : Rect;
   MassRect        : Rect;
   ShapeWRect      : Rect;
   EditRect        : Rect;

   ColorRect       : Array [0..15] of ColorRType;
   ShapeRect       : Array [0..7] of ShapeRType;

   DefPalette      : ColorTable;

   CurrentColor    : Integer;
   CurrentWindow   : Integer;
   CurrentSprite   : Integer;
   CurrentShape    : Integer;
   AnimateShape    : Integer;
   AnimateTimer    : Integer;

   WindowRecord    : Array [1..MaxWindows] of ParamList;
   WindowHandle    : Array [1..MaxWindows] of grafPortPtr;

   SpriteNotSaved  : Boolean;
   MouseIsDown     : Boolean;
   AnimateOn       : Boolean;
   MassOn          : Boolean;
   EditMode        : Boolean;

   SpriteFile      : SpriteFType;
   TotalSprites    : Integer;      { Used exclusively for the ScrollDialogBar }
                                   { function, written in assembly since ORCA }
                                   { pascal does not support Apples function  }
                                   { result passing rules.                    }
   theValue        : Integer;      { Similar to TotalSprites.  Used in asm    }
                                   { function as initial, and ongoing value   }
                                   { for the scrollbar.                       }

   SpriteFileName  : PathName;

   myCtrlColor     : barColors;

   Control         : Array [1..3] of CtrlRecord;

   MyDialog        : grafPortPtr;
