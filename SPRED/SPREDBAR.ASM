ScrollDialogBar start

               mload     spredbar.macro

InitView       equ       1              ;Initialise view window size.
InitTotal      equ       2              ;Initialise total scroll region size.
InitValue      equ       3              ;Initialise the scroll bar value.
LineUp         equ       4              ;Up arrow part.
LineDown       equ       5              ;Down arrow part.
PageUp         equ       6              ;Page up part.
PageDown       equ       7              ;Page down part.
Thumb          equ       8              ;Thumber part.

               lda       4,s            ;Get item off stack.
               sta       item           ;Save it for our use.
               lda       6,s            ;Get dialog pointer from stack, and
               sta       dlog           ;save it for our use.
               lda       8,s
               sta       dlog+2
               lda       10,s           ;Get the command off the stack.
               sta       command
               tax
               lda       1,s            ;Now shift the return address down,
               sta       9,s            ;getting rid of the parameters, but
               lda       2,s            ;leaving the result space there.
               sta       10,s
               pla                      ;Pull off the old return address and anything
               pla                      ;else we don't want.
               pla
               pla

               cpx       #LineUp        ;If we are initialising anything, there is no
               bmi       dontgetvalue   ;need to get the current scroll bar value.

               pha                      ;Push the result space for the call.
               lda       dlog+2         ;Push the dialog's handle.
               pha
               lda       dlog
               pha
               lda       item           ;Push the item number.
               pha
               _GetDItemValue           ;Get the items value.
               pla

dontgetvalue   ldx       command
               cpx       #InitView      ;Do we want to initialise the view size ?
               bne       trytotal       ; No.  Try next command.
               lda       #0             ; Yes. View size of one unit.
               bra       gotvalue
trytotal       cpx       #InitTotal     ;Do we want to initialise the total ?
               bne       tryvalue       ; No.  Try next command.
               lda       TotalSprites   ; Yes. TotalSprites (set externally) has what we want.
               dec       a
               bra       gotvalue
tryvalue       cpx       #InitValue     ;Do we want to initialise the value ?
               bne       trylineup      ; No.  Try next command.
               lda       theValue       ; Yes. theValue is initialised externally.
               dec       a
               bra       gotvalue
trylineup      cpx       #LineUp        ;The up arrow been pressed ?
               bne       trylinedown    ; No.  Try next command.
               cmp       #0             ; Yes. Decrement value if > 0.
               beq       gotvalue
               dec       a
               bra       gotvalue
trylinedown    cpx       #LineDown      ;The down arrow been pressed ?
               bne       trypageup      ; No.  Try next command.
               cmp       TotalSprites   ; Yes. Increment value if < TotalSprites.
               bpl       gotvalue
               inc       a
               bra       gotvalue
trypageup      cpx       #PageUp        ;Region above thumber ?
               bne       trypagedown    ; No.  Try next command.
               cmp       #0             ; Yes. Decrement value if > 0.
               beq       gotvalue
               dec       a
               bra       gotvalue
trypagedown    cpx       #PageDown      ;Region below thumber ?
               bne       trythumb       ; No.  Try next command.
               cmp       TotalSprites   ; Yes. Increment value if < TotalSprite.
               bpl       gotvalue
               inc       a
               bra       gotvalue
trythumb       cmp       TotalSprites   ;Ensure that thumber is only allowed to
               bmi       gotvalue       ;give a value in the correct range.
               lda       TotalSprites
gotvalue       cpx       #LineUp        ;Don't set the value unless we are finished
               bmi       finish         ;initialising the scrollbar.
               sta       theValue       ;Save the new value.
               pha
               lda       dlog+2
               pha
               lda       dlog
               pha
               lda       item
               pha
               _SetDItemValue
               lda       theValue       ;Get the new value for the result.

finish         sta       4,s            ;Save the result in the result space on the stack.
               rtl                      ;Return to caller.

dlog           ds        4              ;Local copy of dialog pointer.
item           ds        2              ;Local copy of item number.
command        ds        2              ;Local copy of command number

               end
