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
; | @date     : 22/09/2022                                                |
; | @license  : n/a                                                       |
; |_______________________________________________________________________|
; |                                                                       |
; |            Iczelion's Win32 Assembly Tutorials with MASM64            |
; |                      Tutorial 22 - Superclassing                      |
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

    WndProc             PROTO   :HWND,:UINT,:WPARAM,:LPARAM
    EdtWndProc          PROTO   :HWND,:UINT,:WPARAM,:LPARAM

; _________________________________________________________________________
; constant variables

.const

; _________________________________________________________________________
; initialized variables

.data
    ClassName   db "SimpleWin64Class", 0        ; the name of our window class
    AppName     db "x64 Our First Window", 0    ; the name of our window
    EditClass   db "EDIT", 0
    OurClass    db "SUPEREDITCLASS", 0
    Message     db "You pressed the Enter key in the text box!", 0

; _________________________________________________________________________
; uninitialized variables

.data?
    CommandLine LPSTR ?
    hInstance   HINSTANCE ?
    hIcon       HICON ?
    hCursor     HCURSOR ?
    OldWndProc  HANDLE ?
    hwndEdit    HANDLE 6 dup(?)

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
    
    invoke  CreateWindowEx, WS_EX_CLIENTEDGE or WS_EX_CONTROLPARENT, \
                    addr ClassName, \
                    addr AppName, \
                    WS_OVERLAPPED or WS_CAPTION or WS_SYSMENU or WS_MINIMIZEBOX or WS_MAXIMIZEBOX or WS_VISIBLE, \
                    CW_USEDEFAULT, \
                    CW_USEDEFAULT, \
                    360, \
                    230, \
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
    
    LOCAL   wcex:WNDCLASSEX
    
    .if uMsg==WM_CREATE
        mov     wcex.cbSize, sizeof WNDCLASSEX
        invoke  GetClassInfoEx, NULL, addr EditClass, addr wcex
        push    wcex.lpfnWndProc
        pop     OldWndProc
        lea     rdi, EdtWndProc
        mov     wcex.lpfnWndProc, rdi
        mov     rax, hInstance
        mov     wcex.hInstance, rax
        lea     rdi, OurClass
        mov     wcex.lpszClassName, rdi
        invoke  RegisterClassEx, addr wcex
        
        xor     rbx, rbx
        mov     rdi, 20
        .while rbx { 6
            invoke  CreateWindowEx, WS_EX_CLIENTEDGE, \
                            addr OurClass, \
                            NULL, \
                            WS_CHILD or WS_VISIBLE or WS_BORDER, \
                            20, \
                            rdi, \
                            300, \
                            25, \
                            hWnd, \
                            rbx, \
                            hInstance, \
                            NULL
            ; 'ADDR32' relocation to 'hwndEdit' invalid without /LARGEADDRESSAWARE:NO
            ; for the following line to work we nee to add /LARGEADDRESSAWARE:NO to liner
            ; mov qword ptr [hwnEdit+ 8*rbx], rax
            ;
            ; But we can use lea for RIP relative addresing already:
            lea r15, hwndEdit
            mov qword ptr [r15+ 8*rbx], rax
            add rdi, 25
            inc rbx
        .endw
        invoke SetFocus, qword ptr [hwndEdit+8*0]
    .elseif uMsg==WM_DESTROY
        invoke  PostQuitMessage, NULL
    .else
        invoke  DefWindowProc, hWnd, uMsg, wParam, lParam
        ret
    .endif
    xor eax, eax
    ret

WndProc endp

EdtWndProc proc hEdit:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    
    .if uMsg==WM_CHAR
        mov rax, wParam
        .if (al }= "0" && al {= "9") || (al }= "A" && al {= "F") || (al }= "a" && al {= "f") || al==VK_BACK
            .if (al }= "a" && al {= "f")
                sub al, 20h
            .endif
            invoke CallWindowProc, OldWndProc, hEdit, uMsg, rax, lParam
            ret
        .endif
    .elseif uMsg==WM_KEYDOWN
        mov rax, wParam
        .if al==VK_RETURN
            invoke MessageBox, hEdit, addr Message, addr AppName, MB_OK or MB_ICONINFORMATION
            invoke SetFocus, hEdit
        .elseif al==VK_TAB
            invoke GetKeyState, VK_SHIFT
            test eax, 80000000
            .if ZERO?
                invoke GetWindow, hEdit, GW_HWNDNEXT
                .if rax==NULL
                    invoke GetWindow, hEdit, GW_HWNDFIRST
                .endif
            .else
                invoke GetWindow, hEdit, GW_HWNDPREV
                .if rax==NULL
                    invoke GetWindow, hEdit, GW_HWNDLAST
                .endif
            .endif
            invoke SetFocus, rax
            xor eax, eax
            ret
        .else
            invoke CallWindowProc, OldWndProc, hEdit, uMsg, wParam, lParam
            ret
        .endif
    .else
        invoke CallWindowProc, OldWndProc, hEdit, uMsg, wParam, lParam
        ret
    .endif
    xor eax, eax
    ret

EdtWndProc endp

end
