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
;  | @date     : 08/09/2022                                               |
;  | @license  : n/a                                                      |
;  |______________________________________________________________________|
;  |                                                                      |
;  |           Iczelion's Win32 Assembly Tutorials with MASM64            |
;  |                  Tutorial 13 - Memory Mapped Files                   |
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
    CloseMapFile        PROTO

; _________________________________________________________________________
; constant variables

.const
    IDM_OPEN    equ 1
    IDM_SAVE    equ 2
    IDM_EXIT    equ 3
    MAXSIZE     equ 260
; _________________________________________________________________________
; initialized variables

.data
    ClassName   db "Win64ASMFileMappingClass",0
    AppName     db "Win64 ASM File Mapping Example",0
    MenuName    db "FirstMenu",0
    ofn         OPENFILENAME <>
    FilterStr   db "All Files",0,"*.*",0
                db "Text Files",0,"*.txt",0,0
    buffer      db MAXSIZE dup(0)
    hMapFile    HANDLE 0

; _________________________________________________________________________
; uninitialized variables

.data?
    CommandLine LPSTR ?
    hInstance   HINSTANCE ?
    hIcon       HICON ?
    hCursor     HCURSOR ?
    hFileRead   HANDLE ?
    hFileWrite  HANDLE ?
    hMenu       HANDLE ?
    pMemory     QWORD ?
    SizeWritten QWORD ?

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
    
    LOCAL wcex:WNDCLASSEX
    LOCAL msg:MSG
    LOCAL hWnd:HWND
    
    invoke  LoadIcon,hInst,IDI_APPLICATION
    mov     hIcon, rax
    invoke  LoadCursor,hInst,IDC_ARROW
    mov     hCursor, rax
    
    mov     wcex.cbSize, sizeof WNDCLASSEX
    mov     wcex.style, CS_HREDRAW or CS_VREDRAW
    lea     rdi, WndProc
    mov     wcex.lpfnWndProc, rdi
    mov     wcex.cbClsExtra, 0
    mov     wcex.cbWndExtra, 0
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
                    NULL, \
                    addr ClassName, \
                    addr AppName, \
                    WS_OVERLAPPEDWINDOW, \
                    CW_USEDEFAULT, \
                    CW_USEDEFAULT, \
                    300, \
                    200, \
                    NULL, \
                    NULL, \
                    0, \
                    NULL
    mov     hWnd, rax
    
    invoke  ShowWindow,hWnd, SW_SHOWNORMAL
    invoke  UpdateWindow,hWnd
    
    .while TRUE
        invoke  GetMessage,addr msg, NULL,0,0
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
    
    .if uMsg==WM_CREATE
        invoke GetMenu, hWnd
        mov hMenu, rax
        
        mov ofn.lStructSize, sizeof ofn
        mov rax, hWnd
        mov ofn.hwndOwner, rax
        mov rax, hInstance
        mov ofn.lpstrFilter, rax
        lea rdi, FilterStr
        mov ofn.lpstrFilter, rdi
        lea rdi, buffer
        mov ofn.lpstrFile, rdi
        mov ofn.nMaxFile, MAXSIZE
    .elseif uMsg==WM_COMMAND
        mov rax, wParam
        .if lParam==0
            .if ax==IDM_OPEN
                mov ofn.Flags,  OFN_FILEMUSTEXIST or OFN_PATHMUSTEXIST or \
                                OFN_LONGNAMES or OFN_EXPLORER or OFN_HIDEREADONLY
                invoke GetOpenFileName, addr ofn
                .if rax==TRUE
                    invoke  CreateFile,addr buffer, \
                                    GENERIC_READ, \
                                    NULL, \
                                    OPEN_EXISTING, \
                                    FILE_ATTRIBUTE_ARCHIVE, \
                                    NULL
                    mov hFileRead, rax
                    invoke  CreateFileMapping,hFileRead,NULL,PAGE_READONLY,NULL,NULL,NULL
                    mov hMapFile, rax
                    lea rax, buffer
                    movzx edx, ofn.nFileOffset
                    add rax, rdx
                    
                    invoke SetWindowText,hWnd,rax
                    invoke EnableMenuItem,hMenu,IDM_OPEN,MF_GRAYED
                    invoke EnableMenuItem,hMenu,IDM_SAVE,MF_ENABLED
                .endif
            .elseif ax==IDM_SAVE
                mov ofn.Flags, OFN_LONGNAMES or OFN_EXPLORER or OFN_HIDEREADONLY
                invoke GetSaveFileName, addr ofn
                .if rax==TRUE
                    invoke  CreateFile,addr buffer, \
                                    GENERIC_READ or GENERIC_WRITE, \
                                    FILE_SHARE_READ or FILE_SHARE_WRITE, \
                                    NULL, \
                                    CREATE_NEW, \
                                    FILE_ATTRIBUTE_ARCHIVE, \
                                    NULL
                    mov hFileWrite, rax
                    invoke MapViewOfFile, hMapFile, FILE_MAP_READ, 0, 0, 0
                    mov pMemory, rax
                    invoke GetFileSize, hFileRead, NULL
                    invoke WriteFile, hFileWrite, pMemory, rax, addr SizeWritten, NULL
                    invoke CloseMapFile
                    invoke CloseHandle, hFileWrite
                    invoke SetWindowText, hWnd, addr AppName
                    invoke EnableMenuItem, hMenu, IDM_OPEN, MF_ENABLED
                    invoke EnableMenuItem, hMenu, IDM_SAVE, MF_GRAYED
                .endif
            .else
                invoke DestroyWindow, hWnd
            .endif
        .endif
    .elseif uMsg==WM_DESTROY
        .if hMapFile {} 0
            invoke CloseMapFile
        .endif
        invoke  PostQuitMessage,NULL
    .else
        invoke  DefWindowProc,hWnd,uMsg,wParam,lParam
        ret
    .endif
    xor eax,eax
    ret

WndProc endp

CloseMapFile proc
    
    invoke  CloseHandle, hMapFile
    mov     hMapFile, 0
    invoke  CloseHandle, hFileRead
    ret

CloseMapFile endp

end
