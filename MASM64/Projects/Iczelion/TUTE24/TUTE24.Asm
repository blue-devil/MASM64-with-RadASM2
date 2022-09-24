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
; | @date     : 23/09/2022                                                |
; | @license  : n/a                                                       |
; |_______________________________________________________________________|
; |                                                                       |
; |           Iczelion's Win32 Assembly Tutorials with MASM64             |
; |                      Tutorial 24 - Windows Hooks                      |
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
    include HookDLL.inc

; _________________________________________________________________________
; libraries

    includelib \masm64\lib64\kernel32.lib
    includelib \masm64\lib64\user32.lib
    includelib HookDLL.lib

; _________________________________________________________________________
; funtion prototypes

    DlgProc             PROTO   :HWND,:UINT,:WPARAM,:LPARAM

; _________________________________________________________________________
; constant variables

.const
    IDD_MAINDLG             equ 101
    IDC_CLASSNAME           equ 1000
    IDC_HANDLE              equ 1001
    IDC_WNDPROC             equ 1002
    IDC_HOOK                equ 1004
    IDC_EXIT                equ 1005
    WM_MOUSEHOOK            equ WM_USER+6

; _________________________________________________________________________
; initialized variables

.data
    HookFlag                dq FALSE
    HookText                db "&Hook", 0
    UnhookText              db "&Unhook", 0
    template                db "%016IX", 0

; _________________________________________________________________________
; uninitialized variables

.data?
    CommandLine LPSTR ?
    hInstance   HINSTANCE ?
    hHook       HANDLE ?

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

WinMain proc hInst:HINSTANCE, hPrevInstance:HINSTANCE, lpCmdLine:LPSTR, nCmdShow:DWORD

    invoke DialogBoxParam, hInst, IDD_MAINDLG, NULL, addr DlgProc, NULL
    invoke ExitProcess, rax

WinMain endp

DlgProc proc hDlg:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM

    LOCAL   hLib:QWORD
    LOCAL   buffer1[128]:BYTE
    LOCAL   buffer2[128]:BYTE
    LOCAL   rect:RECT
    
    .if uMsg==WM_INITDIALOG
        invoke  GetWindowRect, hDlg, addr rect
        invoke  SetWindowPos, \
                        hDlg, \
                        HWND_TOPMOST, \
                        rect.left, \
                        rect.top, \
                        rect.right, \
                        rect.bottom, \
                        SWP_SHOWWINDOW
    .elseif uMsg==WM_MOUSEHOOK
        invoke GetDlgItemText, hDlg, IDC_HANDLE, addr buffer2, 128
        invoke wsprintf, addr buffer1, addr template, wParam
        invoke lstrcmpi, addr buffer1, addr buffer2
        .if rax{}0
            invoke SetDlgItemText, hDlg, IDC_HANDLE, addr buffer1
        .endif
        
        invoke GetDlgItemText, hDlg, IDC_CLASSNAME, addr buffer2, 128
        invoke GetClassName, wParam, addr buffer1, 128
        invoke lstrcmpi, addr buffer1, addr buffer2
        .if rax{}0
            invoke SetDlgItemText, hDlg, IDC_CLASSNAME, addr buffer1
        .endif
        
        invoke GetDlgItemText, hDlg, IDC_WNDPROC, addr buffer2, 128
        invoke GetClassLongPtr, wParam, GCL_WNDPROC
        invoke wsprintf, addr buffer1, addr template, rax
        invoke lstrcmpi, addr buffer1, addr buffer2
        .if rax{}0
            invoke SetDlgItemText, hDlg, IDC_WNDPROC, addr buffer1
        .endif
    .elseif uMsg==WM_COMMAND
        .if lParam{}0
            mov rax, wParam
            mov rdx, rax
            shr rdx, 16
            .if dx==BN_CLICKED
                .if ax==IDC_EXIT
                    invoke SendMessage, hDlg, WM_CLOSE, 0, 0
                .else
                    .if HookFlag==FALSE
                        invoke InstallHook, hDlg
                        .if rax{}NULL
                            mov HookFlag, TRUE
                            invoke SetDlgItemText, hDlg, IDC_HOOK, addr UnhookText
                        .endif
                    .else
                        invoke UninstallHook
                        invoke SetDlgItemText, hDlg, IDC_HOOK, addr HookText
                        mov HookFlag, FALSE
                        invoke SetDlgItemText, hDlg, IDC_CLASSNAME, NULL
                        invoke SetDlgItemText, hDlg, IDC_HANDLE, NULL
                        invoke SetDlgItemText, hDlg, IDC_WNDPROC, NULL
                    .endif
                .endif
            .endif
        .endif
    .elseif uMsg==WM_CLOSE
        .if HookFlag==TRUE
            invoke UninstallHook
        .endif
        invoke EndDialog, hDlg, 0
    .else
        mov rax,FALSE
        ret
    .endif
    mov rax, TRUE
    ret

DlgProc endp

end
