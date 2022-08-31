; _____________________________________________________________________________
; MASM64 macros

    include \masm64\macros64\vasily.inc     ; main macro file
    include \masm64\macros64\macros64.inc   ; auxillary macro file

; _____________________________________________________________________________
; include files

    include \masm64\include64\win64.inc     ; main include file
    include \masm64\include64\kernel32.inc
    include \masm64\include64\user32.inc
    include \masm64\include64\comctl32.inc
    include \masm64\include64\shell32.inc
    include \masm64\include64\gdi32.inc
    STACKFRAME                              ; create a default stack frame
; _____________________________________________________________________________
; libraries

    includelib \masm64\lib64\user32.lib
    includelib \masm64\lib64\kernel32.lib
    includelib \masm64\lib64\comctl32.lib
    includelib \masm64\lib64\shell32.lib
    includelib \masm64\lib64\gdý32.lib

; _____________________________________________________________________________
; funtion prototypes

    WndProc			    PROTO	:HWND,:UINT,:WPARAM,:LPARAM
    
; _____________________________________________________________________________
; constant variables

.const
    ; Main Dialog
    IDD_DIALOG		    EQU 1000

    IDM_MENU            EQU 10000
    IDM_FILE_EXIT		equ 10001
    IDM_HELP_ABOUT		equ 10101

; _____________________________________________________________________________
; initialized variables

.data
    ClassName			db 'DLGCLASS',0
    AppName				db 'Dialog as main',0
    AboutMsg			db 'MASM64 RadASM Dialog as main',13,10,'BlueDeviL//SCT 2022',0

; _____________________________________________________________________________
; uninitialized variables

.data?
    CommandLine         LPSTR ?
    hInstance			HINSTANCE ?
    hCursor             HCURSOR ?
    hIcon               HICON ?
    