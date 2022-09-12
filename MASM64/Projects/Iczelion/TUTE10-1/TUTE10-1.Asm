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
;  | @date     : 06/09/2022                                               |
;  | @license  : n/a                                                      |
;  |______________________________________________________________________|
;  |                                                                      |
;  |           Iczelion's Win32 Assembly Tutorials with MASM64            |
;  |              Tutorial 10-1 - Dialog Box as Main Window               |
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

; _________________________________________________________________________
; libraries

    includelib \masm64\lib64\kernel32.lib
    includelib \masm64\lib64\user32.lib

; _________________________________________________________________________
; funtion prototypes

    WndProc             PROTO   :HWND,:UINT,:WPARAM,:LPARAM

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
    ClassName       db "DLGCLASS", 0      ; name of window class
    AppName         db "Our First Dialog Box",0 ; title of window
    DlgName         db "MyDialog",0
    MenuName        db "MyMenu",0
    TestString      db "Wow! I'm in an edit box now",0

; _________________________________________________________________________
; uninitialized variables

.data?
    CommandLine     LPSTR ?
    hInstance       HINSTANCE ?
    hIcon           HICON ?
    hCursor         HCURSOR ?
    buffer          db  512 dup(?)

.code

WinMainCRTStartup proc
    
    invoke  GetModuleHandle, NULL
    mov hInstance, rax
    
    invoke  GetCommandLine
    mov     CommandLine, rax
    
    invoke  WinMain, hInstance, NULL, CommandLine, SW_SHOWDEFAULT
    invoke  ExitProcess, eax
    
    ret

WinMainCRTStartup endp

WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD
    
    LOCAL wcex:WNDCLASSEX
    LOCAL msg:MSG
    LOCAL hDlg:HWND
    
    invoke  LoadIcon, NULL, IDI_APPLICATION
    mov     hIcon, rax
    invoke  LoadCursor, NULL, IDC_ARROW
    mov     hCursor, rax
    
    mov     wcex.cbSize, sizeof WNDCLASSEX
    mov     wcex.style, CS_HREDRAW or CS_VREDRAW
    lea     rdi, WndProc
    mov     wcex.lpfnWndProc, rdi
    mov     wcex.cbClsExtra, NULL
    mov     wcex.cbWndExtra, DLGWINDOWEXTRA
    mov     rax, hInst
    mov     wcex.hInstance, rax
    mov     rax, hIcon
    mov     wcex.hIcon, rax
    mov     rbx, hCursor
    mov     wcex.hCursor, rbx
    mov     wcex.hbrBackground, COLOR_WINDOW + 1
    lea     rdi, MenuName
    mov     wcex.lpszMenuName, rdi
    lea     rdi, ClassName
    mov     wcex.lpszClassName, rdi
    mov     wcex.hIconSm, rax
    invoke  RegisterClassEx, addr wcex
    
    invoke  CreateDialogParam, hInst, addr DlgName, NULL, NULL, NULL
    mov     hDlg, rax
    
    invoke  GetDlgItem, hDlg, IDC_EDIT
    invoke  SetFocus, hDlg, rax
    
    invoke  ShowWindow, hDlg, SW_SHOWNORMAL
    invoke  UpdateWindow, hDlg
    
    
    .while TRUE
        invoke  GetMessage, addr msg, NULL, 0, 0
        .if (rax == 0)
            .break
        .endif
        invoke IsDialogMessage, hDlg, addr msg
        .if(rax == FALSE)
            invoke  TranslateMessage, addr msg
            invoke  DispatchMessage, addr msg
        .endif
    .endw

    mov     rax, msg.wParam
    
    ret

WinMain endp

WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    
    .if uMsg==WM_CREATE
        invoke SetDlgItemText, hWnd, IDC_EDIT, addr AppName
    .elseif uMsg==WM_COMMAND
        mov rax, wParam
        .if lParam==0
            .if ax==IDM_GETTEXT
                invoke GetDlgItemText, hWnd, IDC_EDIT, addr buffer, 512
                invoke MessageBox, NULL, addr buffer, addr AppName, MB_OK
            .elseif ax==IDM_CLEAR
                invoke SetDlgItemText, hWnd, IDC_EDIT, NULL
            .else
                invoke DestroyWindow, hWnd
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
    .elseif uMsg==WM_DESTROY
        invoke  PostQuitMessage, NULL
    .else
        invoke  DefWindowProc, hWnd, uMsg, wParam, lParam
        ret
    .endif
    xor eax, eax
    ret

WndProc endp

end
