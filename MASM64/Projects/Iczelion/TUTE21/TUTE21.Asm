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
; |                          Tutorial 21 - Pipe                           |
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
    include \masm64\include64\gdi32.inc

; _________________________________________________________________________
; libraries

    includelib \masm64\lib64\kernel32.lib
    includelib \masm64\lib64\user32.lib
    includelib \masm64\lib64\gdi32.lib

; _________________________________________________________________________
; function prototypes

    WndProc             PROTO   :HWND,:UINT,:WPARAM,:LPARAM

; _________________________________________________________________________
; constant variables

.const
    IDR_MAINMENU        equ 101
    IDM_ASSEMBLE        equ 40001
    Black               equ 00000000h
    Yellow              equ 0000FFFFh

; _________________________________________________________________________
; initialized variables

.data
    ClassName           db "PipeWin64Class", 0              ; the name of our window class
    AppName             db "x64 One-way Pipe Example", 0    ; the name of our window
    EditClass           db "EDIT", 0
    CreatePipeError     db "Error during pipe creation", 0
    CreateProcessError  db "Error during process creation", 0
    ; MASM64 SDK must be installed under C:\masm64
    ; Also if ml64 is in PATH the string below can be shortened
    CmdLine64           db "\masm64\bin64\ml64 /Cp test.asm /link /subsystem:windows", 0

; _________________________________________________________________________
; uninitialized variables

.data?
    CommandLine LPSTR ?
    hInstance   HINSTANCE ?
    hIcon       HICON ?
    hCursor     HCURSOR ?
    hwndEdit    HANDLE ?

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
    mov     wcex.hbrBackground, COLOR_WINDOW + 1
    mov     wcex.lpszMenuName, IDR_MAINMENU
    lea     rdi, ClassName
    mov     wcex.lpszClassName, rdi;offset ClassName
    mov     wcex.hIconSm, rax;hIcon
    invoke  RegisterClassEx, addr wcex
    
    invoke  CreateWindowEx, \
                    WS_EX_CLIENTEDGE, \
                    addr ClassName, \
                    addr AppName, \
                    WS_OVERLAPPEDWINDOW or WS_VISIBLE, \
                    CW_USEDEFAULT, \
                    CW_USEDEFAULT, \
                    400, \
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

    LOCAL   rect:RECT
    LOCAL   hRead:QWORD
    LOCAL   hWrite:QWORD
    LOCAL   startupInfo:STARTUPINFO
    LOCAL   pInfo:PROCESS_INFORMATION
    LOCAL   buffer[1024]:BYTE
    LOCAL   bytesRead:QWORD
    LOCAL   hdc:HDC
    LOCAL   sat:SECURITY_ATTRIBUTES
    LOCAL   nWidth:INT32
    LOCAL   nHeight:INT32
    
    .if uMsg==WM_CREATE
        invoke  CreateWindowEx, \
                        NULL, \
                        addr EditClass, \
                        NULL, \
                        WS_CHILD or WS_VISIBLE or ES_MULTILINE or \
                        ES_AUTOHSCROLL or ES_AUTOVSCROLL, \
                        0, 0, 0, 0, \
                        hWnd, \
                        NULL, \
                        hInstance, \
                        NULL
        mov hwndEdit, rax
    .elseif uMsg==WM_CTLCOLOREDIT
        invoke SetTextColor, wParam, Yellow
        invoke SetBkColor, wParam, Black
        invoke GetStockObject,BLACK_BRUSH
        ret
    .elseif uMsg==WM_SIZE
        mov rax, lParam
        mov rdx, rax
        and rax, 0FFFFh
        mov nWidth, eax
        shr rdx, 16
        and rdx, 0FFFFh
        mov nHeight, edx
        invoke MoveWindow, hwndEdit, 0, 0, nWidth, nHeight, TRUE
    .elseif uMsg==WM_COMMAND
        .if lParam==0
            mov rax, wParam
            .if ax==IDM_ASSEMBLE
                mov sat.nLength, sizeof SECURITY_ATTRIBUTES
                mov sat.lpSecurityDescriptor, NULL
                mov sat.bInheritHandle, TRUE
                
                invoke CreatePipe, addr hRead, addr hWrite, addr sat, NULL
                .if rax==NULL
                    invoke MessageBox, hWnd, addr CreatePipeError, addr AppName, MB_OK or MB_ICONERROR
                .else
                    mov startupInfo.cb, sizeof STARTUPINFO
                    invoke GetStartupInfo, addr startupInfo
                    mov rax, hWrite
                    mov startupInfo.hStdOutput, rax
                    mov startupInfo.hStdError, rax
                    mov startupInfo.dwFlags, STARTF_USESHOWWINDOW or STARTF_USESTDHANDLES
                    mov startupInfo.wShowWindow, SW_HIDE
                    ;__________________________________
                    ; Create Process
                    ;__________________________________
                    invoke CreateProcess, \
                                    NULL, \
                                    addr CmdLine64, \
                                    NULL, NULL, TRUE, NULL, NULL, NULL, \
                                    addr startupInfo, \
                                    addr pInfo
                    .if rax==NULL
                        invoke MessageBox, hWnd, addr CreateProcessError, addr AppName, MB_OK or MB_ICONERROR
                    .else
                        invoke CloseHandle, hWrite
                        .while TRUE
                            invoke RtlZeroMemory, addr buffer, 1024
                            invoke ReadFile, hRead, addr buffer, 1023, addr bytesRead, NULL
                            .if rax==NULL
                                .break
                            .else
                                invoke SendMessage, hwndEdit, EM_SETSEL, -1, 0
                                invoke SendMessage, hwndEdit, EM_REPLACESEL, FALSE, addr buffer
                            .endif
                        .endw
                    .endif
                    invoke CloseHandle, hRead
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
