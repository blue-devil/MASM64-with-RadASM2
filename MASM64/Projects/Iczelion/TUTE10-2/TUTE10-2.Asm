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
; | @date     : 06/09/2022                                                |
; | @license  : n/a                                                       |
; |_______________________________________________________________________|
; |                                                                       |
; |           Iczelion's Win32 Assembly Tutorials with MASM64             |
; |              Tutorial 10-2 - Dialog Box as Main Window                |
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
    IDC_EDIT        equ 3000
    IDC_BUTTON      equ 3001
    IDC_EXIT        equ 3002
    IDM_GETTEXT     equ 32000
    IDM_CLEAR       equ 32001
    IDM_EXIT        equ 32002

; _________________________________________________________________________
; initialized variables

.data
    DlgName         db "MyDialog",0
    AppName         db "Our Second Dialog Box",0        ; title of window
    TestString      db "Wow! I'm in an edit box now",0

; _________________________________________________________________________
; uninitialized variables

.data?
    CommandLine     LPSTR ?
    hInstance       HINSTANCE ?
    iccex           INITCOMMONCONTROLSEX <>
    buffer          db  512 dup(?)

.code

WinMainCRTStartup proc 
    
    invoke  GetModuleHandle, NULL
    mov hInstance, rax
    
    invoke  GetCommandLine
    mov     CommandLine, rax
    
    invoke  InitCommonControls
    mov     iccex.dwSize, sizeof INITCOMMONCONTROLSEX
    mov     iccex.dwICC, ICC_COOL_CLASSES or ICC_STANDARD_CLASSES or ICC_WIN95_CLASSES
    invoke  InitCommonControlsEx, addr iccex
    
    invoke  WinMain, hInstance, NULL, CommandLine, SW_SHOWDEFAULT
    invoke  ExitProcess, eax
    
    ret

WinMainCRTStartup endp

WinMain proc hInst:HINSTANCE, hPrevInstance:HINSTANCE, lpCmdLine:LPSTR, nCmdShow:DWORD

    invoke DialogBoxParam, hInst, addr DlgName, NULL, addr DlgProc, NULL
    invoke ExitProcess, rax

WinMain endp

DlgProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    
    .if uMsg==WM_INITDIALOG
        invoke GetDlgItem, hWnd, IDC_EDIT
        invoke SetFocus, rax
    .elseif uMsg==WM_CLOSE
        invoke SendMessage, hWnd, WM_COMMAND, IDM_EXIT, 0
    .elseif uMsg==WM_COMMAND
        mov rax, wParam
        .if lParam==0
            .if ax==IDM_GETTEXT
                invoke GetDlgItemText, hWnd, IDC_EDIT, addr buffer, 512
                invoke MessageBox, NULL, addr buffer, addr AppName, MB_OK
            .elseif ax==IDM_CLEAR
                invoke SetDlgItemText, hWnd, IDC_EDIT, NULL
            .elseif ax==IDM_EXIT
                invoke EndDialog, hWnd, NULL
            .endif
        .else
            mov rdx, wParam
            shr edx, 16
            .if dx==BN_CLICKED
                .if ax==IDC_BUTTON
                    invoke SetDlgItemText, hWnd, IDC_EDIT, addr TestString
                .elseif ax==IDC_EXIT
                    invoke SendMessage, hWnd, WM_COMMAND, IDM_EXIT, NULL
                .endif
            .endif
        .endif
    .else
        mov rax, FALSE
        ret
    .endif
    mov rax, TRUE
    ret

DlgProc endp

end
