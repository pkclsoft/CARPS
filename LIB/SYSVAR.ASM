;...............................................................
;
; System Variable Routines.
; ~~~~~~~~~~~~~~~~~~~~~~~~~
;................................................................

         absaddr on
         keep sysvar

         mload sysvar.macro

;................................................................
;
; SetSysVar.
; ~~~~~~~~~~
; Will save the supplied pointer in the pointer table, in the
; specified position.
;................................................................

SetSysVar start

         using SysTab

         subroutine (2:VarNum,4:PtrVal),0

         lda   VarNum                   ;Get number of pointer to save.
         asl   a                        ;Turn it into an index into our
         asl   a                        ;table.
         tax
         lda   PtrVal                   ;Get lsw of the pointer.
         sta   SysVarTab,x              ;Save it.
         lda   PtrVal+2                 ;Get msw of the pointer.
         sta   SysVarTab+2,x

         Return

         end

;................................................................
;
; GetSysVar.
; ~~~~~~~~~~
; Will return the pointer from the pointer table, in the
; specified position.
;................................................................

GetSysVar start

         using SysTab

RetVal   equ   $00

         subroutine (2:VarNum),4

         lda   VarNum                   ;Get number of pointer to save.
         asl   a                        ;Turn it into an index into our
         asl   a                        ;table.
         tax
         lda   SysVarTab,x
         sta   RetVal
         lda   SysVarTab+2,x
         sta   RetVal+2

         Return 4:RetVal

         end

SysTab   data

SysVarTab ds   4*16

         end

;...............................................................
;
; Stack
; ~~~~~
; Return the value of the stack pointer.
;................................................................

Stack    start

         TSC
         RTL

         end
