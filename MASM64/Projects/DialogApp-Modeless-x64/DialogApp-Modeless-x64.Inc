; _________________________________________________________________________
; MASM64 macros

    include \masm64\macros64\vasily.inc     ; main macro file
    include \masm64\macros64\macros64.inc   ; auxillary macro file

; _________________________________________________________________________
; include files

    include \masm64\include64\win64.inc     ; main include file
    include \masm64\include64\kernel32.inc
    include \masm64\include64\user32.inc
    include \masm64\include64\comctl32.inc
    include \masm64\include64\shell32.inc
    include \masm64\include64\gdi32.inc
    STACKFRAME                              ; create a default stack frame
; _________________________________________________________________________
; libraries

    includelib \masm64\lib64\user32.lib
    includelib \masm64\lib64\kernel32.lib
    includelib \masm64\lib64\comctl32.lib
    includelib \masm64\lib64\shell32.lib
    includelib \masm64\lib64\gdý32.lib

; _________________________________________________________________________
; funtion prototypes

    DlgProc             PROTO   :HWND,:UINT,:WPARAM,:LPARAM

; _________________________________________________________________________
; constant variables

.const
    ; Main Dialog
    IDD_DIALOG          EQU 1000

; _________________________________________________________________________
; initialized variables

.data
    ClassName           db 'DLGCLASS',0
    AppName             db 'Modeless Dialog App x64',0

; _________________________________________________________________________
; uninitialized variables

.data?
    CommandLine         LPSTR ?
    hInstance           HINSTANCE ?
    hCursor             HCURSOR ?
    hIcon               HICON ?
