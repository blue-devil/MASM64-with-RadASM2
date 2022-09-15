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
; | @date     : 14/09/2022                                                |
; | @license  : n/a                                                       |
; |_______________________________________________________________________|
; |                                                                       |
; |           Iczelion's Win32 Assembly Tutorials with MASM64             |
; |                    Tutorial 18 - Common Controls                      |
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

    WndProc             PROTO   :HWND,:UINT,:WPARAM,:LPARAM

; _________________________________________________________________________
; constant variables

.const
    IDC_PROGRESS    	equ 1
    IDC_STATUS		    equ 2
    IDC_TIMER		    equ 3
    
    PBM_SETRANGE        equ WM_USER+1
    PBM_SETPOS          equ WM_USER+2
    PBM_DELTAPOS        equ WM_USER+3
    PBM_SETSTEP         equ WM_USER+4
    PBM_STEPIT          equ WM_USER+5

; _________________________________________________________________________
; initialized variables

.data
    ClassName           db "CommonControlWin64Class", 0    ; the name of our window class
    AppName             db "x64 Common Control Demo", 0    ; the name of our window
    ProgressClass 	    db "msctls_progress32",0
    Message		        db "Finished!",0
    TimerID		        dq 0

; _________________________________________________________________________
; uninitialized variables

.data?
    CommandLine         LPSTR ?
    hInstance           HINSTANCE ?
    hIcon               HICON ?
    hCursor             HCURSOR ?
    hProgress	        HANDLE ?
    hStatus	            HANDLE ?
    CurrentStep	        dq ?

.code

WinMainCRTStartup proc
    
    invoke  GetModuleHandle, NULL
    mov     hInstance, rax
    
    invoke  GetCommandLine
    mov     CommandLine, rax
    
    invoke  InitCommonControls
    
    invoke  WinMain, hInstance, NULL, CommandLine, SW_SHOWDEFAULT
    invoke  ExitProcess, eax
    
    ret

WinMainCRTStartup endp

WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD
    
    LOCAL wcex:WNDCLASSEX
    LOCAL msg:MSG
    LOCAL hWnd:HWND
    
    invoke  LoadIcon, NULL, IDI_APPLICATION
    mov     hIcon, rax
    invoke  LoadCursor, NULL, IDC_ARROW
    mov     hCursor, rax
    
    mov     wcex.cbSize, sizeof WNDCLASSEX
    mov     wcex.style, CS_HREDRAW or CS_VREDRAW
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
    
    invoke  CreateWindowEx, WS_EX_CLIENTEDGE, \
                    addr ClassName, \
                    addr AppName, \
                    WS_OVERLAPPED or WS_CAPTION or WS_SYSMENU or WS_MINIMIZEBOX or WS_MAXIMIZEBOX or WS_VISIBLE, \
                    CW_USEDEFAULT, \
                    CW_USEDEFAULT, \
                    CW_USEDEFAULT, \
                    CW_USEDEFAULT, \
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
    
    .if uMsg==WM_CREATE
        invoke CreateWindowEx, \
                        NULL, \
                        addr ProgressClass, \
                        NULL, \
                        WS_CHILD+WS_VISIBLE, \
                        100, \
                        200, \
                        300, \
                        20, \
                        hWnd, \
                        IDC_PROGRESS, \
                        hInstance, \
                        NULL
        mov hProgress, rax
        
        mov rax, 1000
        mov CurrentStep, rax
        shl rax, 16
        
        invoke SendMessage, hProgress, PBM_SETRANGE, 0, rax
        invoke SendMessage, hProgress, PBM_SETSTEP, 10, 0
        
        invoke CreateStatusWindow, WS_CHILD+WS_VISIBLE, NULL, hWnd, IDC_STATUS
        mov hStatus, rax
        invoke SetTimer, hWnd, IDC_TIMER, 100, NULL
        mov TimerID, rax
    .elseif uMsg==WM_DESTROY
        invoke  PostQuitMessage, NULL
        .if TimerID {} 0
            invoke KillTimer, hWnd, TimerID
        .endif
    .elseif uMsg==WM_TIMER
        invoke SendMessage, hProgress, PBM_STEPIT, 0, 0
        sub CurrentStep, 10
        .if CurrentStep==0
            invoke KillTimer, hWnd, TimerID
            mov TimerID, 0
            invoke SendMessage, hStatus, SB_SETTEXT, 0, addr Message
            invoke MessageBox, hWnd, addr Message, addr AppName, MB_OK+MB_ICONINFORMATION
            invoke SendMessage, hStatus, SB_SETTEXT, 0, 0
            invoke SendMessage, hProgress, PBM_SETPOS, 0, 0
        .endif
    .else
        invoke  DefWindowProc, hWnd, uMsg, wParam, lParam
        ret
    .endif
    xor eax, eax
    ret

WndProc endp

end
