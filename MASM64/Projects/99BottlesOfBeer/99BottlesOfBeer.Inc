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
    include \masm64\include64\user32.inc
    include \masm64\include64\shell32.inc
    include \masm64\include64\msvcrt.inc

; _________________________________________________________________________
; libraries

    includelib \masm64\m64lib\m64lib.lib    ; m64lib library
    includelib \masm64\lib64\kernel32.lib
    includelib \masm64\lib64\user32.lib
    includelib \masm64\lib64\shell32.lib
    includelib \masm64\lib64\msvcrt.lib

; _________________________________________________________________________
; funtion prototypes

    externdef           printf  : near
    externdef           sprintf  : near
    externdef           _kbhit  : near
    externdef           exit    : near
    main                PROTO   :DWORD,:LPSTR

; _________________________________________________________________________
; constant variables

.const
    

; _________________________________________________________________________
; initialized variables

.data
    sverse1 db "%s bottle%s of beer on the wall, %s bottle%s of beer.", 13, 10, 0
    sverse2 db "Take one down and pass it around, %s bottle%s of beer on the wall.", 13, 10, 13, 10, 0
    sverse3 db "Go to the store and buy some more, 99 bottles of beer on the wall.", 13, 10, 13, 10, 0
    nBeer   dq 99
    empty   db 0

; _________________________________________________________________________
; uninitialized variables

.data?
    CommandLine LPSTR ?
    hInstance   HINSTANCE ?
    NumArgs     DWORD ?
    sBeer1      db 3 dup(?)
    sBeer2      db 3 dup(?)
