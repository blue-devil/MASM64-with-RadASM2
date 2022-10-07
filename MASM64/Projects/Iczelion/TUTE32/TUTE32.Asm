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
; | @date     : 07/10/2022                                                |
; | @license  : n/a                                                       |
; |_______________________________________________________________________|
; |                                                                       |
; |            Iczelion's Win32 Assembly Tutorials with MASM64            |
; |            Tutorial 32 - Multiple Document Interface (MDI)            |
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
; funtion prototypes

    WndProc             PROTO   :HWND,:UINT,:WPARAM,:LPARAM

; _________________________________________________________________________
; constant variables

.const
    IDR_MAINMENU                equ 101
    IDR_CHILDMENU               equ 102
    IDM_EXIT                    equ 40001
    IDM_TILEHORZ                equ 40002
    IDM_TILEVERT                equ 40003
    IDM_CASCADE                 equ 40004
    IDM_NEW                     equ 40005
    IDM_CLOSE                   equ 40006

; _________________________________________________________________________
; initialized variables

.data
    ClassName                   db "MDIASM64Class", 0    ; the name of our window class
    AppName                     db "Win64Asm MDI Demo", 0    ; the name of our window
    MDIClientName               db "MDICLIENT",0
    MDIChildClassName           db "MDICHILD",0
    MDIChildTitle               db "x64 MDI Child",0
    ClosePromptMessage          db "Are you sure you want to close this window?",0
    cc                          CLIENTCREATESTRUCT <0, 100>

; _________________________________________________________________________
; uninitialized variables

.data?
    CommandLine LPSTR ?
    hInstance   HINSTANCE ?
    hIcon       HICON ?
    hCursor     HCURSOR ?
    hMainMenu   HANDLE ?
    hwndClient  HANDLE ?
    hChildMenu  HANDLE ?
    mc          MDICREATESTRUCT <>
    hwndFrame   HANDLE ?
    rect        RECT <>

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
    mov     wcex.style, CS_HREDRAW or CS_VREDRAW
    lea     rdi, WndProc
    mov     wcex.lpfnWndProc, rdi
    mov     wcex.cbClsExtra, NULL
    mov     wcex.cbWndExtra, NULL
    mov     rax, hInst
    mov     wcex.hInstance, rax
    mov     rax, hIcon
    mov     wcex.hIcon, rax
    mov     rbx, hCursor
    mov     wcex.hCursor, rbx
    mov     wcex.hbrBackground, COLOR_APPWORKSPACE
    mov     wcex.lpszMenuName, IDR_MAINMENU
    lea     rdi, ClassName
    mov     wcex.lpszClassName, rdi
    mov     wcex.hIconSm, rax
    invoke  RegisterClassEx, addr wcex
    
    lea     rdi, ChildProc
    mov     wcex.lpfnWndProc, rdi
    mov     wcex.hbrBackground, COLOR_WINDOW + 1
    lea     rdi, MDIChildClassName
    mov     wcex.lpszClassName, rdi
    invoke  RegisterClassEx, addr wcex
    
    invoke  CreateWindowEx, \
                    NULL, \
                    addr ClassName, \
                    addr AppName, \
                    WS_OVERLAPPEDWINDOW or WS_CLIPCHILDREN or WS_VISIBLE , \
                    CW_USEDEFAULT, \
                    CW_USEDEFAULT, \
                    CW_USEDEFAULT, \
                    CW_USEDEFAULT, \
                    NULL, \
                    NULL, \
                    hInst, \
                    NULL
    mov     hwndFrame, rax
    
    invoke  LoadMenu, hInstance, IDR_CHILDMENU
	mov     hChildMenu, rax
	
	invoke  GetSubMenu, hChildMenu, 1
	mov     cc.hWindowMenu, rax
	
	invoke  GetClientRect, hwndFrame, addr rect
	
	
	invoke  CreateWindowEx, WS_EX_CLIENTEDGE, addr MDIClientName, NULL, \
	                WS_CHILD or WS_VISIBLE or WS_VSCROLL or WS_HSCROLL or WS_CLIPCHILDREN, \
	                CW_USEDEFAULT, \
	                CW_USEDEFAULT, \
	                rect.right, \
	                rect.bottom,\
	                hwndFrame, \
	                NULL, \
	                hInst, \
	                addr cc
	mov     hwndClient, rax
    
    ;invoke  ShowWindow, hwndFrame, SW_SHOWNORMAL
    ;invoke  UpdateWindow, hwndFrame
    
    .while TRUE
        invoke  GetMessage, addr msg, NULL, 0, 0
        .if (rax == 0)
            .break
        .endif
        invoke  TranslateMDISysAccel, hwndClient, addr msg
        .if rax==0
            invoke  TranslateMessage, addr msg
            invoke  DispatchMessage, addr msg
        .endif
    .endw
    
    invoke  DestroyMenu, hChildMenu
    
    mov     rax, msg.wParam
    
    ret

WinMain endp

WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM

    
    .if uMsg==WM_SIZE
        invoke GetClientRect,hWnd, addr rect
        invoke MoveWindow, hwndClient, 0, 0, rect.right, rect.bottom, 1
        
    .elseif uMsg==WM_COMMAND
        .if lParam==0
            mov rax, wParam
            .if ax==IDM_EXIT
                invoke SendMessage, hWnd, WM_CLOSE, 0, 0
                
            .elseif ax==IDM_TILEHORZ
                invoke SendMessage, hwndClient, WM_MDITILE, MDITILE_HORIZONTAL, 0
                
            .elseif ax==IDM_TILEVERT
                invoke SendMessage, hwndClient, WM_MDITILE, MDITILE_VERTICAL, 0
                
            .elseif ax==IDM_CASCADE
                invoke SendMessage, hwndClient, WM_MDICASCADE, MDITILE_SKIPDISABLED, 0
                
            .elseif ax==IDM_NEW
                invoke CreateWindowEx, \
                240h,\
                addr MDIChildClassName,\
                addr MDIChildTitle,\
                1,\
                CW_USEDEFAULT, \
                CW_USEDEFAULT, \
                CW_USEDEFAULT, \
                CW_USEDEFAULT, \
                hwndClient,\
                NULL, \
                hInstance, \
                NULL
                
            .elseif ax==IDM_CLOSE
                invoke SendMessage, hwndClient, WM_MDIGETACTIVE,0 , 0
                invoke SendMessage, rax, WM_CLOSE, 0, 0
            .else
                invoke  DefFrameProc, hWnd, hwndClient, uMsg, wParam, lParam
            .endif
        .endif
    
    .elseif uMsg==WM_DESTROY
        invoke  PostQuitMessage, NULL
    .else
        invoke  DefFrameProc, hWnd, hwndClient, uMsg, wParam, lParam
        ret
    .endif
    xor eax, eax
    ret

WndProc endp

ChildProc proc hChild:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    
    .if uMsg==WM_MDIACTIVATE
        ;
        
    .elseif uMsg==WM_CLOSE
        invoke MessageBox, hChild, addr ClosePromptMessage, addr AppName, MB_YESNO
        .if rax==IDYES
            invoke SendMessage, hwndClient, WM_MDIDESTROY, hChild, 0
        .endif
        
    .else
        invoke  DefMDIChildProc, hChild, uMsg, wParam, lParam
        ret
    .endif
    xor eax, eax
    ret

ChildProc endp

end
