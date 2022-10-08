;  _______________________________________________________________________ 
; |  ______ __          ,.'   __.'.__  .   ______               ___       |
; | |      |  |         /b`  '-.   .-'  d\|      ;             |   |      |
; | |   __ |  |        .5h     /.'.\    =5|   _   \            |   |      |
; | |.  1 \|  |        (0=h    '   '    =C)   1\   \        .--:.  |      |
; | |   1_/|  |        ?3==,          .==7|   | \   \       |__|   |      |
; | |.     | .-- -.-----{=`==oo____oo==`=}|   |  |.----.-- -.--:.  |      |
; | |.  __ | |  V |  ^__|'"o58888888888,; |.  |  ||  ^_|  V |  |.  |      |
; | |:  1 \|_|____|_____| `?88P^\,?88^\P  |.  | / |____|\___|__|:  |___   |
; | |:  1_/   /            C8?\__d88\_/'  |:  1/   / .         |:  1   |  |
; | |::.. .  /             `8o8888/\88P   |::.. . /            |::.. . |  |
; | `-------'               '7oo88oo8P    `------'             `-------'  |
; |                     Cooo##~\/\/\/~====>        github.com/blue-devil  |
; |                                                 gitlab.com/bluedevil  |
; | Freedom doesn't come from second-hand thoughts.      www.sctzine.com  |
; |_______________________________________________________________________|
; | @author   : Blue DeviL <bluedevil@sctzine.com>                        |
; | @tester   : ErrorInside <errorinside@sctzine.com>                     |
; | @IDE      : RadASM v2.2.2.4                                           |
; | @template : Blue DeviL                                                |
; | @date     : 26/09/2022                                                |
; | @license  : n/a                                                       |
; |_______________________________________________________________________|
; |                                                                       |
; |            Iczelion's Win32 Assembly Tutorials with MASM64            |
; |                     Tutorial 27 - Tooltip Control                     |
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
; function prototypes

    DlgProc             PROTO   :HWND, :UINT, :WPARAM, :LPARAM
    EnumChild           PROTO   :HANDLE,:LPARAM
    SetDlgToolArea      PROTO   :QWORD, :QWORD, :QWORD, :QWORD, :QWORD

; _________________________________________________________________________
; constant variables

.const
    IDD_MAINDIALOG      equ 101
    
    ; Tooltip flags
    TTF_IDISHWND        equ 01h
    TTF_CENTERTIP       equ 02h
    TTF_RTLREADING      equ 04h
    TTF_SUBCLASS        equ 10h
    ; Tooltip styles
    TTS_ALWAYSTIP       equ 1
    TTS_NOPREFIX        equ 2

; _________________________________________________________________________
; initialized variables

.data
    ToolTipsClassName   db "Tooltips_class32", 0
    MainDialogText1     db "This is the upper left area of the dialog", 0
    MainDialogText2     db "This is the upper right area of the dialog", 0
    MainDialogText3     db "This is the lower left area of the dialog", 0
    MainDialogText4     db "This is the lower right area of the dialog", 0

; _________________________________________________________________________
; uninitialized variables

.data?
    CommandLine LPSTR ?
    hInstance   HINSTANCE ?
    iccex       INITCOMMONCONTROLSEX <>
    hwndTool    HANDLE ?

.code

WinMainCRTStartup proc 
    
    invoke  GetModuleHandle, NULL
    mov     hInstance, rax
    
    invoke  GetCommandLine
    mov     CommandLine,rax
    
    invoke  InitCommonControls
    mov     iccex.dwSize, sizeof INITCOMMONCONTROLSEX
    mov     iccex.dwICC, ICC_COOL_CLASSES or ICC_STANDARD_CLASSES or ICC_WIN95_CLASSES
    invoke  InitCommonControlsEx, addr iccex
    
    invoke  WinMain, hInstance, NULL, CommandLine, SW_SHOWDEFAULT
    invoke  ExitProcess,eax
    
    ret

WinMainCRTStartup endp

WinMain proc hInst:HINSTANCE, hPrevInstance:HINSTANCE, lpCmdLine:LPSTR, nCmdShow:DWORD

    invoke DialogBoxParam, hInst, IDD_MAINDIALOG, NULL, addr DlgProc, NULL
    invoke ExitProcess, rax

WinMain endp

DlgProc proc hDlg:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    
    LOCAL   ti:TOOLINFO
    LOCAL   id:QWORD
    LOCAL   rect:RECT
    
    .if uMsg==WM_INITDIALOG
        invoke  CreateWindowEx, \
                        NULL, \
                        addr ToolTipsClassName, \
                        NULL, \
                        TTS_ALWAYSTIP, \
                        CW_USEDEFAULT, \
                        CW_USEDEFAULT, \
                        CW_USEDEFAULT, \
                        CW_USEDEFAULT, \
                        NULL, \
                        NULL, \
                        hInstance, \
                        NULL
        mov hwndTool, rax
        mov id, 0
        mov ti.cbSize, sizeof TOOLINFO
        mov ti.uFlags, TTF_SUBCLASS
        mov rax, hDlg
        mov ti.hwnd, rax
        invoke GetWindowRect, hDlg, addr rect
        
        invoke SetDlgToolArea, hDlg, addr ti, addr MainDialogText1, id, addr rect
        inc id
        invoke SetDlgToolArea, hDlg, addr ti, addr MainDialogText2, id, addr rect
        inc id
        invoke SetDlgToolArea, hDlg, addr ti, addr MainDialogText3, id, addr rect
        inc id
        invoke SetDlgToolArea, hDlg, addr ti, addr MainDialogText4, id, addr rect
        
        invoke EnumChildWindows, hDlg, addr EnumChild, addr ti
        
    .elseif uMsg==WM_CLOSE
        invoke EndDialog, hDlg, 0
        
    .elseif uMsg==WM_COMMAND
        ; Process WM_COMMAND message here.
    .else
        mov rax,FALSE
        ret
    .endif
    mov rax, TRUE
    ret

DlgProc endp

EnumChild proc hChild:HANDLE, lParam:LPARAM
    
    LOCAL   buffer[256]:BYTE
    
    mov rax, hChild
    mov rdi, lParam
    mov (TOOLINFO ptr [rdi]).uId, rax
    or (TOOLINFO ptr[rdi]).uFlags, TTF_IDISHWND
    
    invoke GetWindowText, hChild, addr buffer, 255
    lea rax, buffer
    mov (TOOLINFO ptr [rdi]).lpszText, rax
    
    invoke SendMessage, hwndTool, TTM_ADDTOOL, NULL, rdi
    
    xor rdi, rdi
    ret

EnumChild endp

SetDlgToolArea proc hDlg:QWORD, lpti:QWORD, lpText:QWORD, id:QWORD, lpRect:QWORD
    
    mov rdi, lpti
    mov rsi, lpRect
    
    .if id==0
        mov (TOOLINFO ptr [rdi]).rect.left, 0
        mov (TOOLINFO ptr [rdi]).rect.top, 0
        
        mov eax, (RECT ptr [rsi]).right
        sub eax, (RECT ptr [rsi]).left
        shr rax, 1
        mov (TOOLINFO ptr [rdi]).rect.right, eax
        
        mov eax, (RECT ptr [rsi]).bottom
        sub eax, (RECT ptr [rsi]).top
        shr rax, 1
        mov (TOOLINFO ptr [rdi]).rect.bottom, eax
    .elseif id==1
        mov eax, (RECT ptr [rsi]).right
        sub eax, (RECT ptr [rsi]).left
        shr rax, 1
        inc rax
        mov (TOOLINFO ptr [rdi]).rect.left, eax
        mov (TOOLINFO ptr [rdi]).rect.top, 0
        
        mov eax, (RECT ptr [rsi]).right
        sub eax, (RECT ptr [rsi]).left
        mov (TOOLINFO ptr [rdi]).rect.right, eax
        mov eax, (RECT ptr [rsi]).bottom
        sub eax, (RECT ptr [rsi]).top
        mov (TOOLINFO ptr [rdi]).rect.bottom, eax
    .elseif id==2
        mov (TOOLINFO ptr [rdi]).rect.left, 0
        mov eax, (RECT ptr [rsi]).bottom
        sub eax, (RECT ptr [rsi]).top
        shr rax, 1
        inc rax
        mov (TOOLINFO ptr [rdi]).rect.top, eax
        
        mov eax, (RECT ptr [rsi]).right
        sub eax, (RECT ptr [rsi]).left
        shr rax, 1
        mov (TOOLINFO ptr [rdi]).rect.right, eax
        
        mov eax, (RECT ptr [rsi]).bottom
        sub eax, (RECT ptr [rsi]).top
        mov (TOOLINFO ptr [rdi]).rect.bottom, eax
    .else
        mov eax, (RECT ptr [rsi]).right
        sub eax, (RECT ptr [rsi]).left
        shr rax, 1
        inc rax
        mov (TOOLINFO ptr [rdi]).rect.left, eax
        
        mov eax, (RECT ptr [rsi]).bottom
        sub eax, (RECT ptr [rsi]).top
        shr rax, 1
        inc rax
        mov (TOOLINFO ptr [rdi]).rect.top, eax
        
        mov eax, (RECT ptr [rsi]).right
        sub eax, (RECT ptr [rsi]).left
        mov (TOOLINFO ptr [rdi]).rect.right, eax
        
        mov eax, (RECT ptr [rsi]).bottom
        sub eax, (RECT ptr [rsi]).top
        mov (TOOLINFO ptr [rdi]).rect.bottom, eax
    .endif
    push lpText
    pop (TOOLINFO ptr [rdi]).lpszText
    invoke SendMessage, hwndTool, TTM_ADDTOOL, NULL, rdi
    
    xor rsi, rsi
    xor rdi, rdi
    ret

SetDlgToolArea endp

end
