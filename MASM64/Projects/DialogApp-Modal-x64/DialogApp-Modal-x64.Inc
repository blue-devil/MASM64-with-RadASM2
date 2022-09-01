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
    
    STACKFRAME                              ; create a default stack frame
; _____________________________________________________________________________
; libraries
    includelib \masm64\lib64\user32.lib
    includelib \masm64\lib64\kernel32.lib
    includelib \masm64\lib64\comctl32.lib

; _____________________________________________________________________________
; funtion prototypes

    DlgProc			    PROTO	:HWND,:UINT,:WPARAM,:LPARAM
    
; _____________________________________________________________________________
; constant variables
.const
    ; Main Dialog
    IDD_DIALOG	        EQU 1000
    
; _____________________________________________________________________________
; initialized variables
.data


; _____________________________________________________________________________
; uninitialized variables

.data?
    CommandLine         LPSTR ?
    hInstance			HINSTANCE ?
    icc 				INITCOMMONCONTROLSEX <>