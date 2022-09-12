;   ______________________________________________________________________
;  |  ______ __          ,.'   __.'.__  .   ______               ___      |
;  | |      |  |         /b`  '-.   .-'  d\|      ;             |   |     |
;  | |   __ |  |        .5h     /.'.\    =5|   _   \            |   |     |
;  | |.  1 \|  |        (0=h    '   '    =C)   1\   \        .--:.  |     |
;  | |   1_/|  |        ?3==,          .==7|   | \   \       |__|   |     |
;  | |.     | .-- -.-----{=`==oo____oo==`=}|   |  |.----.-- -.--:.  |     |
;  | |.  __ | |  V |  ^__|'"o58888888888,; |.  |  ||  ^_|  V |  |.  |     |
;  | |:  1 \|_|____|_____| `?88P^\,?88^\P  |.  | / |____|\___|__|:  |___  |
;  | |:  1_/   /            C8?\__d88\_/'  |:  1/   / .         |:  1   | |
;  | |::.. .  /             `8o8888/\88P   |::.. . /            |::.. . | |
;  | `-------'               '7oo88oo8P    `------'             `-------' |
;  |                     Cooo##~\/\/\/~====>        github.com/blue-devil |
;  |                                                 gitlab.com/bluedevil |
;  | Freedom doesn't come from second-hand thoughts.      www.sctzine.com |
;  |______________________________________________________________________|
;  | @author   : Blue DeviL <bluedevil@sctzine.com>                       |
;  | @tester   : ErrorInside <errorinside@sctzine.com>                    |
;  | @IDE      : RadASM v2.2.2.4                                          |
;  | @template : Blue DeviL                                               |
;  | @date     : 12/09/2022                                               |
;  | @license  : GPLv3                                                    |
;  |______________________________________________________________________|
;  |                                                                      |
;  |               MASM64 Programming Helpful Code Sniplets               |
;  |                  Basic DialogBoxParam Code Sniplet                   |
;  \______________________________________________________________________/


    OPTION DOTNAME                          ; required for macro files
    option casemap:none                     ; case sensitive

; _________________________________________________________________________
; MASM64 macros

    include \masm64\include64\win64.inc     ; main include file
    include \masm64\macros64\vasily.inc     ; main macro file
    include \masm64\macros64\macros64.inc   ; auxillary macro file

    STACKFRAME                              ; create a default stack frame

; _________________________________________________________________________
; include files

    include \masm64\include64\kernel32.inc
    include \masm64\include64\user32.inc
    include \masm64\include64\comctl32.inc

; _________________________________________________________________________
; libraries

    includelib \masm64\lib64\kernel32.lib
    includelib \masm64\lib64\user32.lib
    includelib \masm64\lib64\comctl32.lib

; _________________________________________________________________________
; funtion prototypes

    DlgProc             PROTO   :HWND,:UINT,:WPARAM,:LPARAM

; _________________________________________________________________________
; constant variables

.const

; _________________________________________________________________________
; initialized variables

.data
    DlgName     db "MyDialog",0

; _________________________________________________________________________
; uninitialized variables

.data?
    CommandLine LPSTR ?
    hInstance   HINSTANCE ?
    iccex       INITCOMMONCONTROLSEX <>
    buffer      db  512 dup(?)

.code

WinMainCRTStartup proc 
    
    invoke  GetModuleHandle, NULL
    mov hInstance, rax
    
    invoke  GetCommandLine
    mov     CommandLine,rax
    
    invoke  InitCommonControls
    mov     iccex.dwSize, sizeof INITCOMMONCONTROLSEX
    mov     iccex.dwICC, ICC_COOL_CLASSES or ICC_STANDARD_CLASSES or ICC_WIN95_CLASSES
    invoke  InitCommonControlsEx, addr iccex
    
    invoke  WinMain, hInstance, NULL, CommandLine, SW_SHOWDEFAULT
    invoke  ExitProcess,eax
    
    ret

WinMainCRTStartup endp

WinMain proc hInst:HINSTANCE, hPrevInstance:HINSTANCE, lpCmdLine:LPSTR, nCmdShow:DWORD

    invoke DialogBoxParam, hInst, addr DlgName, NULL, addr DlgProc, NULL
    invoke ExitProcess, rax

WinMain endp

DlgProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    
    .if uMsg==WM_INITDIALOG
        ; Process WM_INITDIALOG message here.
    .elseif uMsg==WM_CLOSE
        invoke EndDialog, hWnd, 0
    .elseif uMsg==WM_COMMAND
        ; Process WM_COMMAND message here.
    .else
        mov rax,FALSE
        ret
    .endif
    mov rax, TRUE
    ret

DlgProc endp

end

comment *

#include "\masm64\include64\Resource.h"

MyDialog DIALOG 10, 10, 205, 60
STYLE 0x0004 | DS_CENTER | WS_CAPTION | WS_MINIMIZEBOX |
WS_SYSMENU | WS_VISIBLE | WS_OVERLAPPED | DS_MODALFRAME | DS_3DLOOK
CAPTION "[SCT] DialogBoxParam App"
BEGIN
END

*