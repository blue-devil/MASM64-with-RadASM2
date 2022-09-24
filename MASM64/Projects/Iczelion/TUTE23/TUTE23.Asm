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
; | @date     : 25/09/2022                                                |
; | @license  : n/a                                                       |
; |_______________________________________________________________________|
; |                                                                       |
; |           Iczelion's Win32 Assembly Tutorials with MASM64             |
; |                        Tutorial 23 - Tray Icon                        |
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
    include \masm64\include64\shell32.inc

; _________________________________________________________________________
; libraries

    includelib \masm64\lib64\kernel32.lib
    includelib \masm64\lib64\user32.lib
    includelib \masm64\lib64\shell32.lib

NOTIFYICONDATAA STRUCT
    cbSize              DWORD   ?
    hwnd                HWND    ?
    uID                 DWORD   ?
    uFlags              DWORD   ?
    uCallbackMessage    DWORD   ?
    hIcon               HICON   ?
    szTip               BYTE    64 dup (?)
                        BYTE    128 dup (?)
    dwState             DWORD   ?
    dwStateMask         DWORD   ?
    szInfo              BYTE    256 dup(?)
    union DUMMYUNIONNAME
        uTimeout        DWORD   ?
        uVersion        DWORD   ?
    ends
    szInfoTitle         BYTE    64 dup(?)
    dwInfoFlags         DWORD   ?
    guidItem            GUID    <>
    hBalloonIcon        HICON   ?
NOTIFYICONDATAA ENDS

NOTIFYICONDATAW STRUCT
    cbSize              DWORD   ?
    hwnd                HWND    ?
    uID                 DWORD   ?
    uFlags              DWORD   ?
    uCallbackMessage    DWORD   ?
    hIcon               HICON   ?
    szTip               WORD    64 dup (?)
                        WORD    128 dup (?)
    dwState             DWORD   ?
    dwStateMask         DWORD   ?
    szInfo              WORD    256 dup(?)
    union DUMMYUNIONNAME
        uTimeout        DWORD   ?
        uVersion        DWORD   ?
    ends
    szInfoTitle         WORD    64 dup(?)
    dwInfoFlags         DWORD   ?
    guidItem            GUID    <>
    hBalloonIcon        HICON   ?
NOTIFYICONDATAW ENDS

IFDEF __UNICODE__
    NOTIFYICONDATA  equ  <NOTIFYICONDATAW>
ELSE
    NOTIFYICONDATA  equ  <NOTIFYICONDATAA>
ENDIF


; _________________________________________________________________________
; funtion prototypes

    WndProc             PROTO   :HWND,:UINT,:WPARAM,:LPARAM

; _________________________________________________________________________
; constant variables

.const
    WM_SHELLNOTIFY      equ WM_USER+5
    IDI_TRAY            equ 0
    IDM_RESTORE         equ 1000
    IDM_EXIT            equ 1010

; _________________________________________________________________________
; initialized variables

.data
    ClassName           db "TrayIconWin64Class", 0  ; the name of our window class
    AppName             db "x64 TrayIcon Demo", 0   ; the name of our window
    RestoreString       db "&Restore",0
    ExitString          db "E&xit Program",0

; _________________________________________________________________________
; uninitialized variables

.data?
    CommandLine LPSTR ?
    hInstance   HINSTANCE ?
    hIcon       HICON ?
    hCursor     HCURSOR ?
    note        NOTIFYICONDATA <>
    hPopupMenu	HANDLE ?

.code

WinMainCRTStartup proc
    
    invoke  GetModuleHandle, NULL
    mov     hInstance, rax
    
    invoke  GetCommandLine
    mov     CommandLine, rax
    
    invoke  WinMain, hInstance, NULL, CommandLine, SW_SHOWDEFAULT
    invoke  ExitProcess, eax
    
    ret

WinMainCRTStartup endp

WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD
    
    LOCAL   wcex:WNDCLASSEX
    LOCAL   msg:MSG
    LOCAL   hWnd:HWND
    
    invoke  LoadIcon, NULL, IDI_APPLICATION
    mov     hIcon, rax
    invoke  LoadCursor, NULL, IDC_ARROW
    mov     hCursor, rax
    
    mov     wcex.cbSize, sizeof WNDCLASSEX
    mov     wcex.style, CS_HREDRAW or CS_VREDRAW or CS_DBLCLKS
    lea     rdi, WndProc
    mov     wcex.lpfnWndProc, rdi;offset WndProc
    mov     wcex.cbClsExtra, NULL
    mov     wcex.cbWndExtra, NULL
    mov     rax, hInst
    mov     wcex.hInstance, rax
    mov     rax, hIcon
    mov     wcex.hIcon, rax;hIcon
    mov     rbx, hCursor
    mov     wcex.hCursor, rbx;hCursor
    mov     wcex.hbrBackground, COLOR_APPWORKSPACE
    mov     wcex.lpszMenuName, NULL
    lea     rdi, ClassName
    mov     wcex.lpszClassName, rdi;offset ClassName
    mov     wcex.hIconSm, rax;hIcon
    invoke  RegisterClassEx, addr wcex
    
    invoke  CreateWindowEx, \
                    WS_EX_CLIENTEDGE, \
                    addr ClassName, \
                    addr AppName, \
                    WS_OVERLAPPED or WS_CAPTION or WS_SYSMENU or WS_MINIMIZEBOX or WS_MAXIMIZEBOX or WS_VISIBLE, \
                    CW_USEDEFAULT, \
                    CW_USEDEFAULT, \
                    350, \
                    200, \
                    NULL, \
                    NULL, \
                    hInst, \
                    NULL
    mov     hWnd, rax
    
    invoke  ShowWindow, hWnd, SW_SHOWNORMAL
    invoke  UpdateWindow, hWnd
    
    .while TRUE
        invoke  GetMessage, addr msg, NULL, 0, 0
        .if (rax == 0)
            .break
        .endif
        invoke  TranslateMessage, addr msg
        invoke  DispatchMessage, addr msg
    .endw
    
    mov     rax, msg.wParam
    
    ret

WinMain endp

WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM

    LOCAL   pt:POINT
    
    .if uMsg==WM_CREATE
        invoke CreatePopupMenu
        mov hPopupMenu, rax
        
        invoke AppendMenu, hPopupMenu, MF_STRING, IDM_RESTORE, addr RestoreString
        invoke AppendMenu, hPopupMenu, MF_STRING, IDM_EXIT, addr ExitString
    .elseif uMsg==WM_COMMAND
    
    .elseif uMsg==WM_SIZE
        .if wParam==SIZE_MINIMIZED
            mov note.cbSize, sizeof NOTIFYICONDATA
            mov rax, hWnd
            mov note.hwnd, rax
            mov note.uID, IDI_TRAY
            mov note.uCallbackMessage, WM_SHELLNOTIFY
            
            invoke LoadIcon, NULL, IDI_WINLOGO
            mov note.hIcon, rax
            
            invoke lstrcpy, addr note.szTip, addr AppName
            invoke ShowWindow, hWnd, SW_HIDE
            invoke Shell_NotifyIcon, NIM_ADD, addr note
        .endif
    .elseif uMsg==WM_SHELLNOTIFY
        
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
