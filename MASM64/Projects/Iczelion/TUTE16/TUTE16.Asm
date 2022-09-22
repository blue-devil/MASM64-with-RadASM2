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
; | @date     : 13/09/2022                                                |
; | @license  : n/a                                                       |
; |_______________________________________________________________________|
; |                                                                       |
; |           Iczelion's Win32 Assembly Tutorials with MASM64             |
; |                      Tutorial 16 - Event Object                       |
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
    IDM_START_THREAD    equ 1
    IDM_STOP_THREAD     equ 2
    IDM_EXIT            equ 3
    WM_FINISH           equ WM_USER+100h

; _________________________________________________________________________
; initialized variables

.data
    ClassName           db "Win64ASMEventClass", 0      ; the name of our window class
    AppName             db "Win64 ASM Event Example", 0 ; the name of our window
    MenuName            db "FirstMenu",0
    SuccessString       db "The calculation is completed!",0
    StopString          db "The thread is stopped",0
    EventStop           BOOL FALSE

; _________________________________________________________________________
; uninitialized variables

.data?
    CommandLine         LPSTR ?
    hInstance           HINSTANCE ?
    hIcon               HICON ?
    hCursor             HCURSOR ?
    hWindow             HWND ?
    hMenu               HMENU ?
    ThreadID            DWORD ?
    ExitCode            DWORD ?
    hThread             HANDLE ?
    hEventStart         HANDLE ?

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
    mov     wcex.hbrBackground, COLOR_WINDOW + 1
    lea     rdi, MenuName
    mov     wcex.lpszMenuName, rdi
    lea     rdi, ClassName
    mov     wcex.lpszClassName, rdi
    mov     wcex.hIconSm, rax
    invoke  RegisterClassEx, addr wcex
    
    invoke  CreateWindowEx, \
                    WS_EX_CLIENTEDGE, \
                    addr ClassName, \
                    addr AppName, \
                    WS_OVERLAPPEDWINDOW, \
                    CW_USEDEFAULT, \
                    CW_USEDEFAULT, \
                    300, \
                    200, \
                    NULL, \
                    NULL, \
                    hInst, \
                    NULL
    mov     hWindow, rax
    
    invoke  ShowWindow, hWindow, SW_SHOWNORMAL
    invoke  UpdateWindow, hWindow
    
    invoke  GetMenu, hWindow
    mov     hMenu, rax
    
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
    
    .if uMsg==WM_CREATE
        invoke CreateEvent, NULL, FALSE, FALSE, NULL
        mov hEventStart, rax
        mov rax, offset ThreadProc
        invoke  CreateThread, \
                        NULL, \
                        NULL, \
                        rax, \
                        NULL, \
                        NORMAL_PRIORITY_CLASS, \
                        addr ThreadID
        mov hThread, rax
    .elseif uMsg==WM_COMMAND
        mov rax, wParam
        .if lParam==0
            .if ax==IDM_START_THREAD
                invoke SetEvent, hEventStart
                invoke EnableMenuItem, hMenu, IDM_START_THREAD, MF_GRAYED
                invoke EnableMenuItem, hMenu, IDM_STOP_THREAD, MF_ENABLED
            .elseif ax==IDM_STOP_THREAD
                mov  EventStop, TRUE
                invoke EnableMenuItem, hMenu, IDM_START_THREAD, MF_ENABLED
                invoke EnableMenuItem, hMenu, IDM_STOP_THREAD, MF_GRAYED
            .else
                invoke DestroyWindow,hWindow
            .endif
        .endif
    .elseif uMsg==WM_FINISH
        invoke MessageBox, NULL, addr SuccessString, addr AppName, MB_OK
    .elseif uMsg==WM_DESTROY
        invoke  PostQuitMessage, NULL
    .else
        invoke  DefWindowProc, hWnd, uMsg, wParam, lParam
        ret
    .endif
    xor eax, eax
    ret

WndProc endp

ThreadProc proc uses rcx Param:DWORD
    
    invoke WaitForSingleObject, hEventStart, INFINITE
    mov rcx, 600000000
    
    .while rcx{}0
        .if EventStop==FALSE
            add eax, eax
            dec rcx
        .else
            invoke MessageBox, hWindow, addr StopString, addr AppName, MB_OK
            mov EventStop, FALSE
            jmp ThreadProc
        .endif
    .endw
    invoke PostMessage, hWindow, WM_FINISH, NULL, NULL
    invoke EnableMenuItem, hMenu, IDM_START_THREAD, MF_ENABLED
    invoke EnableMenuItem, hMenu, IDM_STOP_THREAD, MF_GRAYED
    jmp ThreadProc
    
    ret

ThreadProc endp

end
