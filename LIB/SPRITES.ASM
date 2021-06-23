;...............................................................
;
; Sprites library.
; ~~~~~~~~~~~~~~~~
;................................................................

         absaddr on
         keep sprites

         mload sprites.macro

;................................................................
;
; SpriteStartUp
; ~~~~~~~~~~~~~
; Initialise the line start table, which contains the address in
; memory that each super hires line starts.  (Note we are talking
; about the pixel map here.  The SCB's we shall leave to
; Quickdraw II unless it appears to be too slow also.
;................................................................


SpriteStartUp   start

         using SPRData

         ldx   #0
         lda   #$2000
ITloop   sta   Lstart,x
         inx
         inx
         clc
         adc   #$00a0
         cpx   #199*2
         bne   ITloop
         rtl

         end

;................................................................
;
; DRSprite.
; ~~~~~~~~
; DRSprite will draw a sprite on the SHR screen in 320*200 mode.
; It takes two parameters from the caller, which are passed
; via the stack, as follows :
;
;        Xcoordinate : X position on the SHR screen.            (2 bytes)
;        Ycoordinate : Y position on the SHR screen.            (2 bytes)
;
; A Sprite Record uses the following format :
;
;        Height   : Word sized integer, number of pixels high.  (2 bytes)
;        Width    : Word sized integer, width in bytes.         (2 bytes)
;        Image    : Pointer to Sprite image.                    (4 bytes)
;        Collin   : Line on which to do collision detection.    (2 bytes)
;        Colisn   : Flag indicating if a collision occured.     (2 bytes)
;        Mask     : Flag indicating if masking is to be used.   (2 bytes)
;................................................................

DrawSprite start

         using SPRData

Ycoord   equ   $00                       ;Ycoordinate of sprite.
SCOffset equ   $02                       ;Memory location of screen.
SColisn  equ   $04
DLSource equ   $06
DLDest   equ   $0a

         subroutine (2:SHeight,2:SWidth,4:SImage,2:SCollin,2:SMask,2:Line,2:XCoord),14

         stz   SColisn                  ;Zero collision flag.
         lda   SImage+2
         sta   DLSource+2
         lda   #$00e1
         sta   DLDest+2

         lda   Line                     ;Set initial value of Line.
         sta   Ycoord                   ;Save for end of loop check.

mloop    lda   Line                     ;Get current line being drawn on.
         cmp   #199                     ;Make sure we aren't drawing below
         bpl   findraw                  ;the physical screen.

         lda   Xcoord                   ;Set up parms for LOffset call.
         pha
         lda   Line
         pha
         jsr   LOffset                  ;Calculate screen address.
         pla                            ;Get result.
         sta   SCOffset

         lda   Smask                    ;Are we masking to the screen ?
         beq   notmask                  ; No.  Do normal transfer.
         cmp   #1                       ; Yes. AND mask this call ?
         beq   doand                    ;      Yes.
         jsr   DLineOR                  ;      No.  OR mask this call.
         bra   mloopchk                 ;           Go on with loop.

doand    jsr   DLineAND                 ;Call up AND routine.
         bra   mloopchk                 ;Go on with loop.

notmask  lda   SCollin                  ;Collision detection on this line ?
         bne   donorm                   ; No.  Do normal transfer.
         jsr   DLineCol                 ; Yes. Do collision detection.
         bra   mloopchk                 ;      Go on with loop.

donorm   jsr   DLine                    ;Normal transfer.

mloopchk lda   SImage                   ;Increment Addr to point at the
         clc                            ;next lines peice of data.
         adc   SWidth
         sta   SImage

         dec   SCollin                  ;Decrement collision line counter.

         inc   Line                     ;Move down the screen one line.
         lda   Line                     ;Now check if we have drawn all of
         sec                            ;the shape.
         sbc   Ycoord
         cmp   SHeight
         bne   mloop                    ; No.  More to go.

findraw  Return 2:SColisn               ; Yes. Return back to caller.

;................................................................
;
; LOffset
; ~~~~~~~
; LOffset determines the address in memory that the sprite starts
; at for a particular line of the sprite.
;
; The formula is as follows :
;
;        LineOffset = Lstart[Line number] + (Xcoordinate / 2)   (2 bytes)
;
;     where Lstart[Line number] is one entry in the Lstart table
;     pointing to the first byte of the appropriate line on the
;     super hires screen.
;
; LOffset is passed two parameters via the stack, in order :
;
;        Line Number : Y coordinate on the screen.              (2 bytes)
;        Pixel       : X coordinate on the screen.              (2 bytes)
;................................................................


LOffset  ply                            ;Preserve return address.

         pla                            ;Get Line number from stack.

         asl   a                        ;Produce index into Lstart.
         tax                            ;Put into index register.
         pla                            ;Get the x coordinate.
         lsr   a                        ;Divide by two.
         clc                            ;Prepare for addition
         adc   Lstart,x                 ;Produce result value.
         pha                            ;Put the result on the stack.
         phy
         rts

;................................................................
;
; DLine.
; ~~~~~~
; DLine will put one line of the sprite on the screen.
;
; It comes in four versions as follows :
;
;   DLine      : Does a direct transfer, no funny business.
;   DLineCol   : Does collision detection as well.
;   DLineAND   : AND's the pattern onto the screen.
;   DLineOR    : OR's the pattern onto the screen.
;
; The last two are used when we want to preseve the background in detail
; around the shape.  Special patterns are needed for these to work.
;................................................................

DLine    lda   SImage                   ;Get source address.
         sta   DLSource                 ;Store it in DP for speed in
;                                        the actual transfer.

         lda   SCOffset                 ;Put the screen address in the DP
         sta   DLDest                   ;also.  Note it is a long word
;                                       ;pointing to bank $e1.

         lda   SWidth                   ;Get sprites width in bytes.
         lsr   a                        ;Multiply by two as we are transfering
         tay                            ;a word at a time.

DLLoop   lda   [DLSource]               ;Get a word.
         sta   [DLDest]                 ;Store it.

         inc   DLDest                   ;Increment pointers.
         inc   DLDest
         inc   DLSource
         inc   DLSource

         dey                            ;Decrement word counter.
         bne   DLLoop                   ;If unfinished, go back.

         rts

;................................................................
;
; DLineCol.
; ~~~~~~~~~
; Handles collision detection by OR'ing the contents of the screen
; (before drawing) with SCOLISN, thus if anything was there, SCOLISN
; will be non-zero after the transfer.
;................................................................

DLineCol lda   SImage                   ;Get source address.
         sta   DLSource                 ;Store it in DP for speed in
;                                        the actual transfer.

         lda   SCOffset                 ;Put the screen address in the DP
         sta   DLDest                   ;also.  Note it is a long word
;                                       ;pointing to bank $e1.

         lda   SWidth                   ;Get sprites width in bytes.
         lsr   a                        ;Multiply by two as we are transfering
         tay                            ;a word at a time.

DLLoopC  lda   [DLDest]                 ;Get current screen contents.
         tsb   SColisn                  ;OR and STORE it at SColisn
         lda   [DLSource]               ;Get shape value.
         sta   [DLDest]                 ;Store it.

         inc   DLDest                   ;Increment pointers.
         inc   DLDest
         inc   DLSource
         inc   DLSource

         dey
         bne   DLLoopC

         rts

;................................................................
;
; DLineAND.
; ~~~~~~~~~
; AND the pattern with the current contents of the screen before
; storing it.
;................................................................

DLineAND lda   SImage                   ;Get source address.
         sta   DLSource                 ;Store it in DP for speed in
;                                        the actual transfer.

         lda   SCOffset                 ;Put the screen address in the DP
         sta   DLDest                   ;also.  Note it is a long word
;                                       ;pointing to bank $e1.

         lda   SWidth                   ;Get sprites width in bytes.
         lsr   a                        ;Multiply by two as we are transfering
         tay                            ;a word at a time.

DLLoopA  lda   [DLSource]               ;Get pattern data.
         and   [DLDest]                 ;AND it.
         sta   [DLDest]                 ;Store it.

         inc   DLDest                   ;Increment pointers.
         inc   DLDest
         inc   DLSource
         inc   DLSource

         dey
         bne   DLLoopA

         rts

;................................................................
;
; DLineOR.
; ~~~~~~~~
; OR the pattern with the current contents of the screen before
; storing it.
;................................................................


DLineOR  lda   SImage                   ;Get source address.
         sta   DLSource                 ;Store it in DP for speed in
;                                        the actual transfer.

         lda   SCOffset                 ;Put the screen address in the DP
         sta   DLDest                   ;also.  Note it is a long word
;                                       ;pointing to bank $e1.

         lda   SWidth                   ;Get sprites width in bytes.
         lsr   a                        ;Multiply by two as we are transfering
         tay                            ;a word at a time.

DLLoopO  lda   [DLSource]               ;Get pattern data.
         eor   [DLDest]                 ;Exclusive or it.
         sta   [DLDest]                 ;Store it.

         inc   DLDest                   ;Increment pointers.
         inc   DLDest
         inc   DLSource
         inc   DLSource

         dey
         bne   DLLoopO

         rts

         end


SPRData  data

Lstart   ds    199*2                    ;Table of screen line addresses.

         end

SetNibble start
          subroutine (2:value,2:inByte,2:nibble),6
         
mask     equ   $00     ; mask storage
adjValue equ   $02     ; the new nibble value
result   equ   $04     ; the output of the function

          LDA nibble   ; load nibble flag
          BEQ HiNibble ; handle the low nibble
          
LoNibble  LDA #$f0     ; load ACC with mask for low nibble
          STA mask     ; store mask
          LDA value    ; load ACC with value to set
          AND #$0f     ; ensure that the value has no extra bits
          STA adjValue ; store value to adjust
          BRA Finish   ; finish off

HiNibble  LDA #$0f     ; load ACC with mask for high nibble
          STA mask     ; store mask
          LDA value    ; load ACC with value to set
          ASL A        ; multiply by 16
          ASL A
          ASL A
          ASL A
          STA adjValue ; store value to adjust
          
Finish    LDA mask     ; load the mask to be used
          AND inByte      ; AND with current value to strip unwanted bits
          ORA adjValue ; OR with the new nibble value
          STA result   ; save the result

          return 2:result
          
          end


GetNibble start
          subroutine (2:inByte,2:nibble),6
         
mask     equ   $00     ; mask storage
adjValue equ   $02     ; the new nibble value
result   equ   $04     ; the output of the function

          LDA nibble   ; load nibble flag
          BEQ HiNibble ; handle the low nibble

LoNibble  LDA inByte   ; load ACC with value to get
          AND #$0f     ; ensure that the value has no extra bits
          BRA Finish   ; finish off

HiNibble  LDA inByte   ; load ACC with value to get
          LSR A        ; divide by 16
          LSR A
          LSR A
          LSR A          

Finish    STA result   ; save the result

          return 2:result
          
          end
