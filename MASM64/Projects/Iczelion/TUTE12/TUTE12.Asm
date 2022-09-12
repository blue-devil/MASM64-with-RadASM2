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
;  |             Tutorial 12 - Memory Management and File I/O             |
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
    include \masm64\include64\comdlg32.inc

; _________________________________________________________________________
; libraries

    includelib \masm64\lib64\kernel32.lib
    includelib \masm64\lib64\user32.lib
    includelib \masm64\lib64\comdlg32.lib

; _________________________________________________________________________
; funtion prototypes

    WndProc             PROTO   :HWND,:UINT,:WPARAM,:LPARAM

; _________________________________________________________________________
; constant variables

.const
    IDM_OPEN        equ 1
    IDM_SAVE        equ 2
    IDM_EXIT        equ 3
    MAXSIZE         equ 260
    MEMSIZE         equ 65535
    
    EditID          equ 1

; _________________________________________________________________________
; initialized variables

.data
    ClassName       db "BaseWin64Class", 0
    AppName         db "Win64 ASM Edit",0
    EditClass       db "edit",0
    MenuName        db "FirstMenu",0
    FilterStr       db "All Files",0,"*.*",0
                    db "Text Files",0,"*.txt",0,0
    buffer          db MAXSIZE dup(0)
    ofn             OPENFILENAME <>

; _________________________________________________________________________
; uninitialized variables

.data?
    CommandLine     LPSTR ?
    hInstance       HINSTANCE ?
    hIcon           HICON ?
    hCursor         HCURSOR ?
    hEdit           HWND ?
    hFile           HANDLE ?
    hMemory         HANDLE ?
    pMemory         QWORD ?
    SizeReadWrite   QWORD ?

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
    
    LOCAL   nWidth:INT32
    LOCAL   nHeight:INT32
    
    .if uMsg==WM_CREATE
        mov r9d, WS_VISIBLE or WS_CHILD or ES_LEFT or ES_MULTILINE or WS_VSCROLL or WS_HSCROLL or ES_AUTOHSCROLL or ES_AUTOVSCROLL
        invoke  CreateWindowEx, NULL, \
                        addr EditClass, \
                        NULL, \
                        r9d, \
                        0, \
                        0, \
                        0, \
                        0, \
                        hWnd, \
                        EditID, \
                        hInstance, \
                        NULL
        mov hEdit, rax
        invoke SetFocus, hEdit
        
        mov ofn.lStructSize, sizeof ofn
        mov rax, hWnd
        mov ofn.hwndOwner, rax
        mov rax, hInstance
        mov ofn.hInstance, rax
        lea rdi, FilterStr
        mov ofn.lpstrFilter, rdi
        lea rdi, buffer
        mov ofn.lpstrFile, rdi
        mov ofn.nMaxFile, MAXSIZE
    .elseif uMsg==WM_SIZE
        mov rax, lParam
        mov rdx, rax
        and rax, 0FFFFh
        mov nWidth, eax
        shr rdx, 16
        and rdx, 0FFFFh
        mov nHeight, edx
        invoke MoveWindow, hEdit, 0, 0, nWidth, nHeight, TRUE
    .elseif uMsg==WM_COMMAND
        mov rax, wParam
        .if lParam==0
            .if ax==IDM_OPEN
                mov ofn.Flags, OFN_FILEMUSTEXIST or OFN_PATHMUSTEXIST or OFN_LONGNAMES or OFN_EXPLORER or OFN_HIDEREADONLY
                invoke GetOpenFileName, addr ofn
                .if rax==TRUE
                    invoke  CreateFile, addr buffer, \
                                    GENERIC_READ or GENERIC_WRITE, \
                                    FILE_SHARE_READ or FILE_SHARE_WRITE, \
                                    NULL, \
                                    OPEN_EXISTING, \
                                    FILE_ATTRIBUTE_ARCHIVE, \
                                    NULL
                    mov hFile, rax
                    
                    invoke GlobalAlloc, GMEM_MOVEABLE or GMEM_ZEROINIT, MEMSIZE
                    mov hMemory, rax
                    invoke GlobalLock, hMemory
                    mov pMemory, rax
                    
                    invoke ReadFile, hFile, pMemory, MEMSIZE-1, addr SizeReadWrite, NULL
                    invoke SendMessage,hEdit, WM_SETTEXT, NULL, pMemory
                    invoke CloseHandle, hFile
                    invoke GlobalUnlock, pMemory
                    invoke GlobalFree, hMemory
                .endif
                invoke SetFocus, hEdit
            .elseif ax==IDM_SAVE
                mov ofn.Flags, OFN_LONGNAMES or OFN_EXPLORER or OFN_HIDEREADONLY
                invoke GetSaveFileName,addr ofn
                .if rax==TRUE
                    invoke  CreateFile, addr buffer, \
                                    GENERIC_READ or GENERIC_WRITE, \
                                    FILE_SHARE_READ or FILE_SHARE_WRITE, \
                                    NULL, \
                                    CREATE_NEW, \
                                    FILE_ATTRIBUTE_ARCHIVE, \
                                    NULL
                    mov hFile, rax
                    
                    invoke  GlobalAlloc, GMEM_MOVEABLE or GMEM_ZEROINIT, MEMSIZE
                    mov hMemory, rax
                    invoke  GlobalLock, hMemory
                    mov pMemory, rax
                    
                    invoke SendMessage, hEdit, WM_GETTEXT, MEMSIZE-1, pMemory
                    invoke WriteFile, hFile, pMemory, rax, addr SizeReadWrite, NULL
                    invoke CloseHandle, hFile
                    invoke GlobalUnlock, pMemory
                    invoke GlobalFree, hMemory
                .endif
                invoke SetFocus, hEdit
            .else
                invoke DestroyWindow, hWnd
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
