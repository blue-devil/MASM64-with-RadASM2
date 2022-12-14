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
; | @date     : 07/09/2022                                                |
; | @license  : n/a                                                       |
; |_______________________________________________________________________|
; |                                                                       |
; |            Iczelion's Win32 Assembly Tutorials with MASM64            |
; |                Tutorial 11-3 - More about Dialog Box                  |
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
    include \masm64\include64\comdlg32.inc

; _________________________________________________________________________
; libraries

    includelib \masm64\lib64\kernel32.lib
    includelib \masm64\lib64\user32.lib
    includelib \masm64\lib64\comdlg32.lib

; _________________________________________________________________________
; function prototypes

    WndProc             PROTO   :HWND,:UINT,:WPARAM,:LPARAM

; _________________________________________________________________________
; constant variables

.const
    IDM_OPEN        equ 1
    IDM_EXIT        equ 2
    MAXSIZE         equ 260
    OUTPUTSIZE      equ 512

; _________________________________________________________________________
; initialized variables

.data
    ClassName       db "SimpleWin64Class", 0
    AppName         db "Our First Window", 0
    MenuName        db "FirstMenu",0
    Test_str        db "You selected Test menu item",0
    Hello_str       db "Hello, my friend",0
    Goodbye_str     db "See you again, bye",0
    OurTitle        db "-=Our First Open File Dialog Box=-: Choose the file to open",0
    FllPthName      db "The Full Filename with Path is: ",0
    FullName        db "The Filename is: ",0
    ExtName         db "The Extension is: ",0
    OutputStr       db OUTPUTSIZE dup(0)
    FilterStr       db "All Files",0,"*.*",0
                    db "Text Files",0,"*.txt",0,0
    buffer          db MAXSIZE dup(0)
    CrLf            db 0Dh,0Ah,0
    ofn             OPENFILENAME <>

; _________________________________________________________________________
; uninitialized variables

.data?
    CommandLine     LPSTR ?
    hInstance       HINSTANCE ?
    hIcon           HICON ?
    hCursor         HCURSOR ?

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
    mov     rax,hInst
    mov     wcex.hInstance, rax
    mov     rax, hIcon
    mov     wcex.hIcon, rax;hIcon
    mov     rbx, hCursor
    mov     wcex.hCursor, rbx;hCursor
    mov     wcex.hbrBackground, COLOR_WINDOW + 1
    lea     rdi, MenuName
    mov     wcex.lpszMenuName, rdi;offset MenuName
    lea     rdi, ClassName
    mov     wcex.lpszClassName, rdi;offset ClassName
    mov     wcex.hIconSm, rax;hIcon
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
    
    .while TRUE
        invoke  GetMessage, addr msg, NULL,0,0
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
    
    .if uMsg==WM_DESTROY
        invoke PostQuitMessage, NULL
    .elseif uMsg==WM_COMMAND
        mov rax, wParam
        .if eax==IDM_OPEN
            mov ofn.lStructSize, sizeof ofn
            mov rdi, hWnd
            mov ofn.hwndOwner, rdi
            push hInstance
            pop ofn.hInstance
            lea rdi,FilterStr
            mov ofn.lpstrFilter, rdi
            lea rdi, buffer
            mov ofn.lpstrFile, rdi 
            mov ofn.nMaxFile, MAXSIZE
            mov ofn.Flags,  OFN_FILEMUSTEXIST or \
                            OFN_PATHMUSTEXIST or OFN_LONGNAMES or\
                            OFN_EXPLORER or OFN_HIDEREADONLY
            lea rdi,OurTitle
            mov ofn.lpstrTitle, rdi 
            invoke GetOpenFileName, addr ofn
            .if eax==TRUE
                invoke lstrcat, addr OutputStr, addr FllPthName
                invoke lstrcat, addr OutputStr, ofn.lpstrFile
                invoke lstrcat, addr OutputStr, addr CrLf
                invoke lstrcat, addr OutputStr, addr FullName
                mov  rax, ofn.lpstrFile
                push rbx
                xor  rbx,rbx
                mov  bx, ofn.nFileOffset
                add  rax, rbx
                pop  rbx
                invoke lstrcat, addr OutputStr, rax
                invoke lstrcat, addr OutputStr, addr CrLf
                invoke lstrcat, addr OutputStr, addr ExtName
                mov rax, ofn.lpstrFile
                push rbx
                xor rbx, rbx
                mov bx, ofn.nFileExtension
                add rax, rbx
                pop rbx
                invoke lstrcat, addr OutputStr, rax
                invoke MessageBox, hWnd, addr OutputStr, ADDR AppName, MB_OK
                invoke RtlZeroMemory, addr OutputStr, OUTPUTSIZE
            .endif
        .else
            invoke  DestroyWindow, hWnd
        .endif
    .else
        invoke  DefWindowProc, hWnd, uMsg, wParam, lParam
        ret
    .endif
    xor eax, eax
    ret

WndProc endp

end
