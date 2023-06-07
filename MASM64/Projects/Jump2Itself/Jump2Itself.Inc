; _________________________________________________________________________
; MASM64 macros

    include \masm64\include64\win64.inc     ; main include file
    include \masm64\macros64\macros64.inc   ; auxillary macro file

    STACKFRAME                              ; create a default stack frame

; _________________________________________________________________________
; include files

    include \masm64\include64\msvcrt.inc

; _________________________________________________________________________
; libraries

    includelib \masm64\lib64\msvcrt.lib

; _________________________________________________________________________
; funtion prototypes

    externdef           printf  : near

; _________________________________________________________________________
; constant variables

.const
    

; _________________________________________________________________________
; initialized variables

.data
    msg         db "[!] Unconditional branch to itself MASM64.", 0
    fmt         db "%s", 13, 10, 0

; _________________________________________________________________________
; uninitialized variables

.data?
