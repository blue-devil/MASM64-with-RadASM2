; _________________________________________________________________________
; MASM64 macros
;include \masm64\include64\masm64rt.inc
    include \masm64\include64\win64.inc     ; main include file
    include \masm64\macros64\vasily.inc     ; main macro file
    include \masm64\macros64\macros64.inc   ; auxillary macro file

    STACKFRAME                              ; create a default stack frame

; _________________________________________________________________________
; include files

    include \masm64\m64lib\m64lib.inc       ; include file for m64lib library
    include \masm64\include64\kernel32.inc

; _________________________________________________________________________
; libraries

    includelib \masm64\m64lib\m64lib.lib    ; m64lib library
    includelib \masm64\lib64\kernel32.lib

; _________________________________________________________________________
; funtion prototypes

    externdef           exit    : near
    main                PROTO

; _________________________________________________________________________
; constant variables

.const
    

; _________________________________________________________________________
; initialized variables

.data
    hw          db "Hello, world", 13, 10, 0
    len_hw      equ $-hw

; _________________________________________________________________________
; uninitialized variables

.data?
    hInstance   HINSTANCE ?
    hConsoleOutput  HANDLE ?
    errCode     DWORD ?
