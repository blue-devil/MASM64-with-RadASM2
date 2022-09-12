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
;  | @license  : n/a                                                      |
;  |______________________________________________________________________|
;  |                                                                      |
;  |           Iczelion's Win32 Assembly Tutorials with MASM64            |
;  |                        Tutorial 14 - Process                         |
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
    IDM_CREATE_PROCESS  equ 1
    IDM_TERMINATE       equ 2
    IDM_EXIT            equ 3
; _________________________________________________________________________
; initialized variables

.data
    ClassName       db "Win64ASMProcessClass", 0        ; name of window class
    AppName         db "Win64 ASM Process Example", 0   ; title of window
    MenuName        db "FirstMenu",0
    ProcessInfo     PROCESS_INFORMATION <>
    ProgramName     db "msgbox64.exe",0
    msgTitle        db "MASM64 Examples",0
    msgError        db "[ERROR] Process cannot created!",0

; _________________________________________________________________________
; uninitialized variables

.data?
    CommandLine     LPSTR ?
    hInstance       HINSTANCE ?
    hIcon           HICON ?
    hCursor         HCURSOR ?
    hMenu           HMENU ?
    ExitCode        DWORD ?

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
    LOCAL hWnd:HWND
    
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
    mov     hWnd, rax
    
    invoke  ShowWindow, hWnd, SW_SHOWNORMAL
    invoke  UpdateWindow, hWnd
    
    invoke  GetMenu, hWnd
    mov hMenu, rax
    
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

    LOCAL startInfo:STARTUPINFO
    
    .if uMsg==WM_DESTROY
        invoke  PostQuitMessage, NULL
    .elseif uMsg==WM_INITMENUPOPUP
        invoke GetExitCodeProcess, ProcessInfo.hProcess, addr ExitCode
        .if rax==TRUE
            .if ExitCode==STILL_ACTIVE
                invoke EnableMenuItem, hMenu, IDM_CREATE_PROCESS, MF_GRAYED
                invoke EnableMenuItem, hMenu, IDM_TERMINATE, MF_ENABLED
            .else
                invoke EnableMenuItem, hMenu, IDM_CREATE_PROCESS, MF_ENABLED
                invoke EnableMenuItem, hMenu, IDM_TERMINATE, MF_GRAYED
            .endif
        .else
            invoke EnableMenuItem, hMenu, IDM_CREATE_PROCESS, MF_ENABLED
            invoke EnableMenuItem, hMenu, IDM_TERMINATE, MF_GRAYED
        .endif
    .elseif uMsg==WM_COMMAND
        mov rax, wParam
        .if lParam==0
            .if ax==IDM_CREATE_PROCESS
                .if ProcessInfo.hProcess{}0
                    invoke CloseHandle, ProcessInfo.hProcess
                    mov ProcessInfo.hProcess, 0
                .endif
                invoke GetStartupInfo, addr startInfo
                invoke CreateProcess, addr ProgramName, \
                                NULL, \
                                NULL, \
                                NULL, \
                                FALSE, \
                                NORMAL_PRIORITY_CLASS, \
                                NULL, \
                                NULL, \
                                addr startInfo, \
                                addr ProcessInfo
                .if rax==0
                    invoke MessageBox, hWnd, addr msgError, addr msgTitle, MB_OK
                    invoke ExitProcess, 0
                .endif
                invoke  CloseHandle, ProcessInfo.hThread
            .elseif ax==IDM_TERMINATE
                invoke  GetExitCodeProcess, ProcessInfo.hProcess, addr ExitCode
                .if ExitCode==STILL_ACTIVE
                    invoke TerminateProcess, ProcessInfo.hProcess, 0
                .endif
                invoke  CloseHandle, ProcessInfo.hProcess
                mov ProcessInfo.hProcess, 0
            .else
                invoke  DestroyWindow, hWnd
            .endif
        .endif
    .else
        invoke  DefWindowProc, hWnd, uMsg, wParam, lParam
        ret
    .endif
    xor eax, eax
    ret

WndProc endp

end
