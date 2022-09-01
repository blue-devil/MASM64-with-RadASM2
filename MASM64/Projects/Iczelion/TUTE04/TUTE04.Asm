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
;  | @date     : 28/08/2022                                               |
;  | @license  : n/a                                                      |
;  |______________________________________________________________________|
;  |                                                                      |
;  |           Iczelion's Win32 Assembly Tutorials with MASM64            |
;  |                   Tutorial 4 - Painting With Text                    |
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

; _________________________________________________________________________
; initialized variables

.data
    ClassName   db "SimpleWin64Class", 0    ; the name of our window class
    AppName     db "Our First Window", 0    ; the name of our window
    OurText     db "Win64 assembly is great and easy!",0

; _________________________________________________________________________
; uninitialized variables

.data?
    CommandLine LPSTR ?
    hInstance   HINSTANCE ?
    hIcon       HICON ?
    hCursor     HCURSOR ?

.code

WinMainCRTStartup proc
    
    invoke  GetModuleHandleEx,0,0,hInstance
    .if(rax {} 0)
        invoke  ExitProcess,NULL
    .endif
    
    invoke  GetCommandLine
    mov     CommandLine,rax
    
    invoke  WinMain,hInstance, NULL, CommandLine, SW_SHOWDEFAULT
    invoke  ExitProcess,eax
    
    ret

WinMainCRTStartup endp

WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD
    
    LOCAL   wcex:WNDCLASSEX
    LOCAL   msg:MSG
    LOCAL   hWnd:HWND
    
    invoke  LoadIcon,hInst,IDI_APPLICATION
    mov     hIcon, rax
    invoke  LoadCursor,hInst,IDC_ARROW
    mov     hCursor, rax
    
    mov     wcex.cbSize, sizeof WNDCLASSEX
    mov     wcex.style, CS_HREDRAW or CS_VREDRAW
    lea     rdi, WndProc
    mov     wcex.lpfnWndProc, rdi;offset WndProc
    mov     wcex.cbClsExtra, 0
    mov     wcex.cbWndExtra, 0
    mov     rax, hInst
    mov     wcex.hInstance, rax
    mov     rax, hIcon
    mov     wcex.hIcon, rax;hIcon
    mov     rbx, hCursor
    mov     wcex.hCursor, rbx;hCursor
    mov     wcex.hbrBackground, COLOR_WINDOW + 1
    mov     wcex.lpszMenuName, 0
    lea     rdi, ClassName
    mov     wcex.lpszClassName, rdi;offset ClassName
    mov     wcex.hIconSm, rax;hIcon
    invoke  RegisterClassEx, addr wcex
    
    invoke  CreateWindowEx, \
                    NULL, \
                    addr ClassName, \
                    addr AppName, \
                    WS_OVERLAPPEDWINDOW, \
                    CW_USEDEFAULT, \
                    CW_USEDEFAULT, \
                    CW_USEDEFAULT, \
                    CW_USEDEFAULT, \
                    NULL, \
                    NULL, \
                    0, \
                    NULL
    mov     hWnd, rax
    
    invoke  ShowWindow,hWnd, SW_SHOWNORMAL
    invoke  UpdateWindow,hWnd
    
    .while TRUE
        invoke GetMessage,addr msg, NULL,0,0
        .if (rax == 0)
            .break
        .endif
        invoke  TranslateMessage,addr msg
        invoke  DispatchMessage,addr msg
    .endw
    
    mov     rax, msg.wParam
    
    ret

WinMain endp

WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    
    LOCAL   hdc:HDC
    LOCAL   ps:PAINTSTRUCT
    LOCAL   rect:RECT
    
    .if uMsg==WM_DESTROY
        invoke  PostQuitMessage,NULL
    .elseif uMsg==WM_PAINT
        invoke  BeginPaint, hWnd, addr ps
        mov     hdc, rax
        invoke  GetClientRect, hWnd, addr rect
        invoke  DrawText, \
                        hdc, \
                        addr OurText, \
                        -1, \
                        addr rect, \
                        DT_SINGLELINE or DT_CENTER or DT_VCENTER
        invoke  EndPaint, hWnd, addr ps
    .else
        invoke  DefWindowProc,hWnd,uMsg,wParam,lParam       
        ret
    .endif
    xor eax,eax
    
    ret

WndProc endp

end
