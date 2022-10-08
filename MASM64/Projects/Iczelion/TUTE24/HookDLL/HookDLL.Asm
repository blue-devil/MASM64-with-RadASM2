;  _______________________________________________________________________
; |  ______ __           ,.'   __.'.__  .   ______               ___      |
; | |      |  |          /b`  '-.   .-'  d\|      ;             |   |     |
; | |   __ |  |         .5h     /.'.\    =5|   _   \            |   |     |
; | |.  1 \|  |         (0=h    '   '    =C)   1\   \        .--:.  |     |
; | |   1_/|  |         ?3==,          .==7|   | \   \       |__|   |     |
; | |.     |  .-- -.-----{=`==oo____oo==`=}|   |  |.----.-- -.--:.  |     |
; | |.  __ |  |  V |  ^__|'"o58888888888,; |.  |  ||  ^_|  V |  |.  |     |
; | |:  1 \|__|____|_____| `?88P^\,?88^\P  |.  | / |____|\___|__|:  |___  |
; | |:  1_/   /             C8?\__d88\_/'  |:  1/   / .         |:  1   | |
; | |::.. .  /              `8o8888/\88P   |::.. . /            |::.. . | |
; | `-------'                '7oo88oo8P    `------'             `-------' |
; |                      Cooo##~\/\/\/~====>        github.com/blue-devil |
; |                                                  gitlab.com/bluedevil |
; | Freedom doesn't come from second-hand thoughts.       www.sctzine.com |
; |_______________________________________________________________________|
; | @author   : Blue DeviL <bluedevil@sctzine.com>                        |
; | @tester   : ErrorInside <errorinside@sctzine.com>                     |
; | @IDE      : RadASM v2.2.2.4                                           |
; | @template : Blue DeviL                                                |
; | @date     : 23/09/2022                                                |
; | @license  : n/a                                                       |
; |_______________________________________________________________________|
; |                                                                       |
; |            Iczelion's Win32 Assembly Tutorials with MASM64            |
; |                      Tutorial 24 - Windows Hooks                      |
; \_______________________________________________________________________/


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

; _________________________________________________________________________
; libraries

    includelib \masm64\lib64\kernel32.lib
    includelib \masm64\lib64\user32.lib

; _________________________________________________________________________
; function prototypes

    UninstallHook       PROTO
    InstallHook         PROTO   :HWND
    MouseProc           PROTO   :QWORD,:WPARAM,:LPARAM

; _________________________________________________________________________
; constant variables

.const
    WM_MOUSEHOOK        equ WM_USER+6
    
    MSLLHOOKSTRUCT STRUCT 
        pt              POINT <>
        mouseData       DWORD ?
        flags           DWORD ?
        time            DWORD ?
        dwExtraInfo     ULONG_PTR ?
    MSLLHOOKSTRUCT ENDS

; _________________________________________________________________________
; initialized variables

.data
    hInstance           HINSTANCE 0

; _________________________________________________________________________
; uninitialized variables

.data?
    hHook               HANDLE ?
    hWnd                HWND ?

.code

DllMain proc hinstDLL:HINSTANCE, fdwReason:DWORD, lpReserved :QWORD

    push    hinstDLL
    pop     hInstance
    
    mov eax, TRUE
    ret
    
DllMain endp

MouseProc proc nCode:QWORD, wParam:WPARAM,lParam:LPARAM

    LOCAL   ms:MSLLHOOKSTRUCT

    invoke CallNextHookEx, hHook, nCode, wParam, lParam
    mov rdx, lParam
    
    mov rax, [rdx]
    mov ms.pt.x, eax
    shr rax, 32
    mov ms.pt.y, eax
    invoke WindowFromPoint, ms.pt
    ;mov rcx, [rdx]
    ;call WindowFromPoint
    
    invoke PostMessage, hWnd, WM_MOUSEHOOK, rax, 0
    
    xor eax, eax
    ret
    
MouseProc endp

InstallHook proc hwnd:HWND
    
    push hwnd
    pop hWnd
    invoke SetWindowsHookEx, WH_MOUSE_LL, addr MouseProc, hInstance, 0
    mov hHook, rax
    
    ret

InstallHook endp

UninstallHook proc
    
    invoke UnhookWindowsHookEx, hHook
    
    ret

UninstallHook endp
end
