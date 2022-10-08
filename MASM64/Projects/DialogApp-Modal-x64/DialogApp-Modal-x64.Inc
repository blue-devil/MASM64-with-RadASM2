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

    STACKFRAME                              ; create a default stack frame
; _________________________________________________________________________
; libraries
    includelib \masm64\lib64\user32.lib
    includelib \masm64\lib64\kernel32.lib
    includelib \masm64\lib64\comctl32.lib

; _________________________________________________________________________
; function prototypes

    DlgProc             PROTO   :HWND,:UINT,:WPARAM,:LPARAM

; _________________________________________________________________________
; constant variables
.const
    ; Main Dialog
    IDD_DIALOG          EQU 1000

; _________________________________________________________________________
; initialized variables
.data


; _________________________________________________________________________
; uninitialized variables

.data?
    CommandLine         LPSTR ?
    hInstance           HINSTANCE ?
    icc                 INITCOMMONCONTROLSEX <>
