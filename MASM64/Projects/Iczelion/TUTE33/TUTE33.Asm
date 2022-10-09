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
; | @date     : 08/10/2022                                                |
; | @license  : n/a                                                       |
; |_______________________________________________________________________|
; |                                                                       |
; |            Iczelion's Win32 Assembly Tutorials with MASM64            |
; |                Tutorial 33 - RichEdit Control: Basics                 |
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
    include \masm64\include64\comdlg32.inc

; _________________________________________________________________________
; libraries

    includelib \masm64\lib64\kernel32.lib
    includelib \masm64\lib64\user32.lib
    includelib \masm64\lib64\gdi32.lib
    includelib \masm64\lib64\comdlg32.lib

; _________________________________________________________________________
; function prototypes

    WndProc             PROTO   :HWND,:UINT,:WPARAM,:LPARAM

; _________________________________________________________________________
; constant variables

.const
    IDR_MAINMENU                    equ 101
    IDM_OPEN                        equ 40001
    IDM_SAVE                        equ 40002
    IDM_CLOSE                       equ 40003
    IDM_SAVEAS                      equ 40004
    IDM_EXIT                        equ 40005
    IDM_COPY                        equ 40006
    IDM_CUT                         equ 40007
    IDM_PASTE                       equ 40008
    IDM_DELETE                      equ 40009
    IDM_SELECTALL                   equ 40010
    IDM_OPTION                      equ 40011
    IDM_UNDO                        equ 40012
    IDM_REDO                        equ 40013
    IDD_OPTIONDLG                   equ 101
    IDC_BACKCOLORBOX                equ 1000
    IDC_TEXTCOLORBOX                equ 1001
    
    RichEditID                      equ 300

; _________________________________________________________________________
; initialized variables

.data
    ClassName                       db "x64IczEditClass", 0    ; the name of our window class
    AppName                         db "x64 IczEdit version 1.0", 0    ; the name of our window
    RichEditDLL                     db "riched20.dll",0
    RichEditClass                   db "RichEdit20A",0
    NoRichEdit                      db "Cannot find riched20.dll",0
    ASMFilterString                 db "ASM Source code (*.asm)",0,"*.asm",0
                                    db "All Files (*.*)",0,"*.*",0,0
    OpenFileFail                    db "Cannot open the file",0
    WannaSave                       db "The data in the control is modified. Want to save it?",0
    FileOpened                      dq FALSE
    BackgroundColor                 dd 0FFFFFFh		; default to white
    TextColor                       dd 0		; default to black

; _________________________________________________________________________
; uninitialized variables

.data?
    CommandLine         LPSTR ?
    hInstance           HINSTANCE ?
    hIcon               HICON ?
    hCursor             HCURSOR ?
    hRichEdit           HANDLE ?
    hwndRichEdit        HANDLE ?
    AlternateFileName   db 256 dup(?)
    FileName            db 256 dup(?)
    CustomColors        dd 16 dup(?)

.code

WinMainCRTStartup proc
    
    invoke  GetModuleHandle, NULL
    mov     hInstance, rax
    
    invoke  GetCommandLine
    mov     CommandLine, rax
    
    invoke  LoadLibrary, addr RichEditDLL
    .if rax{}0
        mov hRichEdit, rax
        invoke WinMain, hInstance, NULL, CommandLine, SW_SHOWDEFAULT
    .else
        invoke MessageBox, NULL, addr NoRichEdit, addr AppName, MB_OK or MB_ICONERROR
    .endif

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
    mov     wcex.lpszMenuName, IDR_MAINMENU
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

StreamInProc proc hFile:HANDLE, pBuffer:LPVOID, nNumBytes:DWORD, lpBytesRead:LPDWORD
    
    invoke ReadFile, hFile, pBuffer, nNumBytes, lpBytesRead, 0
    xor rax, 1
    
    ret

StreamInProc endp

StreamOutProc proc hFile:HANDLE, pBuffer:LPVOID, nNumBytes:DWORD, lpBytesWritten:LPDWORD

    invoke WriteFile, hFile, pBuffer, nNumBytes, lpBytesWritten, 0
    xor rax, 1
    
    ret
    
StreamOutProc endp

CheckModifyState proc hWnd:HANDLE
    
    invoke SendMessage, hwndRichEdit, EM_GETMODIFY, 0, 0
    .if rax{}0
        invoke MessageBox, hWnd, addr WannaSave, addr AppName, MB_YESNOCANCEL
        .if rax==IDYES
            invoke SendMessage, hWnd, WM_COMMAND, IDM_SAVE, 0
        .elseif rax==IDCANCEL
            mov rax, FALSE
            ret
        .endif
    .endif
    
    mov rax, TRUE
    ret

CheckModifyState endp

SetColor proc
    
    LOCAL   cfm:CHARFORMAT
    
    invoke SendMessage, hwndRichEdit, EM_SETBKGNDCOLOR, 0, BackgroundColor
    invoke RtlZeroMemory, addr cfm, sizeof cfm
    mov cfm.cbSize, sizeof cfm
    mov cfm.dwMask, CFM_COLOR
    mov eax, TextColor
    mov cfm.crTextColor, eax
    invoke SendMessage, hwndRichEdit, EM_SETCHARFORMAT, SCF_ALL, addr cfm
    
    ret

SetColor endp

OptionProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM

    LOCAL   clr:CHOOSECOLOR
    
    .if uMsg==WM_INITDIALOG
        ;
    .elseif uMsg==WM_COMMAND
        mov rax, wParam
        shr rax, 16
        .if ax==BN_CLICKED
            mov rax, wParam
            .if ax==IDCANCEL
                invoke SendMessage, hWnd, WM_CLOSE, 0, 0
                
            .elseif ax==IDC_BACKCOLORBOX
                invoke RtlZeroMemory, addr clr, sizeof clr
                mov clr.lStructSize, sizeof clr
                mov rax, hWnd
                mov clr.hwndOwner, rax
                mov rax, hInstance
                mov clr.hInstance, rax
                mov eax, BackgroundColor
                mov clr.rgbResult, eax
                lea rdi, CustomColors
                mov clr.lpCustColors, edi
                mov clr.Flags, CC_ANYCOLOR or CC_RGBINIT
                invoke ChooseColor, addr clr
                .if rax{}0
                    mov eax, clr.rgbResult
                    mov BackgroundColor, eax
                    invoke GetDlgItem, hWnd, IDC_BACKCOLORBOX
                    invoke InvalidateRect, rax, 0, TRUE
                .endif
                
            .elseif ax==IDC_TEXTCOLORBOX
                invoke RtlZeroMemory, addr clr, sizeof clr
                mov clr.lStructSize, sizeof clr
                mov rax, hWnd
                mov clr.hwndOwner, rax
                mov rax, hInstance
                mov clr.hInstance, rax
                mov eax, TextColor
                mov clr.rgbResult, eax
                lea rdi, CustomColors
                mov clr.lpCustColors, edi
                mov clr.Flags, CC_ANYCOLOR or CC_RGBINIT
                invoke ChooseColor, addr clr
                .if rax{}0
                    mov eax, clr.rgbResult
                    mov TextColor, eax
                    invoke GetDlgItem, hWnd, IDC_TEXTCOLORBOX
                    invoke InvalidateRect, rax, 0, TRUE
                .endif
                
            .elseif ax==IDOK
                invoke SendMessage, hwndRichEdit, EM_GETMODIFY, 0, 0
                push rax
                invoke SetColor
                pop rax
                invoke SendMessage, hwndRichEdit, EM_SETMODIFY, rax, 0
                invoke EndDialog, hWnd, 0
                
            .endif
        .endif
    .elseif uMsg==WM_CTLCOLORSTATIC
        invoke GetDlgItem, hWnd, IDC_BACKCOLORBOX
        .if rax==lParam
            invoke CreateSolidBrush, BackgroundColor
            ret
        .else
            invoke GetDlgItem, hWnd, IDC_TEXTCOLORBOX
            .if rax==lParam
                invoke CreateSolidBrush, TextColor
                ret
            .endif
        .endif
        
        mov eax, FALSE
        ret
        
    .elseif uMsg==WM_CLOSE
        invoke EndDialog, hWnd, 0
        
    .else
        mov eax, FALSE
        ret
        
    .endif

    mov eax, TRUE
    ret
    
OptionProc endp


WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM

    LOCAL   chrg:CHARRANGE
    LOCAL   ofn:OPENFILENAME
    LOCAL   buffer[256]:BYTE
    LOCAL   editstream:EDITSTREAM
    LOCAL   hFile:HANDLE
    LOCAL   nWidth:INT32
    LOCAL   nHeight:INT32
    
    .if uMsg==WM_CREATE
        invoke CreateWindowEx, WS_EX_CLIENTEDGE, \
                addr RichEditClass, \
                NULL, \
                WS_CHILD or WS_VISIBLE or ES_MULTILINE or WS_VSCROLL or WS_HSCROLL or ES_NOHIDESEL, \
                CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, \
                hWnd, \
                RichEditID, \
                hInstance, \
                0
        mov hwndRichEdit, rax
        
        ;=============================================================
        ; Set the text limit. The default is 64K
        ;=============================================================
        invoke SendMessage, hwndRichEdit, EM_LIMITTEXT, -1, 0
        
        ;=============================================================
        ; Set the default text/background color
        ;=============================================================
        invoke SetColor
        invoke SendMessage, hwndRichEdit, EM_SETMODIFY, FALSE, 0
        invoke SendMessage, hwndRichEdit, EM_EMPTYUNDOBUFFER, 0, 0
        
    .elseif uMsg==WM_INITMENUPOPUP
        mov rax, lParam
        .if ax==0
            .if FileOpened==TRUE
                invoke EnableMenuItem, wParam, IDM_OPEN, MF_GRAYED
                invoke EnableMenuItem, wParam, IDM_CLOSE, MF_ENABLED
                invoke EnableMenuItem, wParam, IDM_SAVE, MF_ENABLED
                invoke EnableMenuItem, wParam, IDM_SAVEAS, MF_ENABLED
            .else
                invoke EnableMenuItem, wParam, IDM_OPEN, MF_ENABLED
                invoke EnableMenuItem, wParam, IDM_CLOSE, MF_GRAYED
                invoke EnableMenuItem, wParam, IDM_SAVE, MF_GRAYED
                invoke EnableMenuItem, wParam, IDM_SAVEAS, MF_GRAYED
            .endif
            
        .elseif ax==1
            ;=============================================================================
            ; Check whether there is some text in the clipboard. If so, we enable the paste menuitem
            ;=============================================================================
            invoke SendMessage, hwndRichEdit, EM_CANPASTE, CF_TEXT, 0
            .if rax==0      ; no text in the clipboard
                invoke EnableMenuItem, wParam, IDM_PASTE, MF_GRAYED
            .else
                invoke EnableMenuItem, wParam, IDM_PASTE, MF_ENABLED
            .endif
            ;==========================================================
            ; check whether the undo queue is empty
            ;==========================================================
            invoke SendMessage, hwndRichEdit, EM_CANUNDO, 0, 0
            .if rax==0
                invoke EnableMenuItem, wParam, IDM_UNDO, MF_GRAYED
            .else
                invoke EnableMenuItem, wParam, IDM_UNDO, MF_ENABLED
            .endif
            ;=========================================================
            ; check whether the redo queue is empty
            ;=========================================================
            invoke SendMessage, hwndRichEdit, EM_CANREDO, 0, 0
            .if eax==0
                invoke EnableMenuItem, wParam, IDM_REDO, MF_GRAYED
            .else
                invoke EnableMenuItem, wParam, IDM_REDO, MF_ENABLED
            .endif
            ;=========================================================
            ; check whether there is a current selection in the richedit control.
            ; If there is, we enable the cut/copy/delete menuitem
            ;=========================================================
            invoke SendMessage, hwndRichEdit, EM_EXGETSEL, 0, addr chrg
            mov eax, chrg.cpMin
            .if eax==chrg.cpMax     ; no current selection
                invoke EnableMenuItem, wParam, IDM_COPY, MF_GRAYED
                invoke EnableMenuItem, wParam, IDM_CUT, MF_GRAYED
                invoke EnableMenuItem, wParam, IDM_DELETE, MF_GRAYED
            .else
                invoke EnableMenuItem, wParam, IDM_COPY, MF_ENABLED
                invoke EnableMenuItem, wParam, IDM_CUT, MF_ENABLED
                invoke EnableMenuItem, wParam, IDM_DELETE, MF_ENABLED
            .endif
        .endif
    
    .elseif uMsg==WM_COMMAND
        .if lParam==0
            mov rax, wParam
            .if ax==IDM_OPEN
                invoke RtlZeroMemory, addr ofn, sizeof ofn
                mov ofn.lStructSize, sizeof ofn
                mov rax, hWnd
                mov ofn.hwndOwner, rax
                mov rax, hInstance
                mov ofn.hInstance, rax
                lea rdi, ASMFilterString
                mov ofn.lpstrFilter, rdi
                lea rdi, FileName
                mov ofn.lpstrFile, rdi
                mov byte ptr [FileName], 0
                mov ofn.nMaxFile, sizeof FileName
                mov ofn.Flags, OFN_FILEMUSTEXIST or OFN_HIDEREADONLY or OFN_PATHMUSTEXIST
                invoke GetOpenFileName, addr ofn
                .if rax{}0
                    invoke CreateFile, addr FileName, \
                            GENERIC_READ, \
                            FILE_SHARE_READ, \
                            NULL, \
                            OPEN_EXISTING, \
                            FILE_ATTRIBUTE_NORMAL, \
                            0
                    .if rax{}INVALID_HANDLE_VALUE
                        mov hFile, rax
                        ;================================================================
                        ; stream the text into the richedit control
                        ;================================================================ 
                        mov editstream.dwCookie, rax
                        lea rdi, StreamInProc
                        mov editstream.pfnCallback, rdi
                        invoke SendMessage, hwndRichEdit, EM_STREAMIN, SF_TEXT, addr editstream
                        
                        ;==========================================================
                        ; Initialize the modify state to false
                        ;==========================================================
                        invoke SendMessage, hwndRichEdit, EM_SETMODIFY, FALSE, 0
                        invoke CloseHandle, hFile
                        mov FileOpened, TRUE
                    .else
                        invoke MessageBox, hWnd, addr OpenFileFail, addr AppName, MB_OK or MB_ICONERROR
                    .endif
                    
                .endif
                
            .elseif ax==IDM_CLOSE
                invoke CheckModifyState, hWnd
                .if rax==TRUE
                    invoke SetWindowText, hwndRichEdit, NULL
                    mov FileOpened, FALSE
                .endif
                
            .elseif ax==IDM_SAVE
                invoke CreateFile, addr FileName, \
                        GENERIC_WRITE, \
                        FILE_SHARE_READ, \
                        NULL, CREATE_ALWAYS, \
                        FILE_ATTRIBUTE_NORMAL, \
                        0
                .if rax{}INVALID_HANDLE_VALUE
                    
                    mov hFile, rax
                    ;================================================================
                    ; stream the text to the file
                    ;================================================================
                    mov editstream.dwCookie, rax
                    lea rdi, StreamOutProc
                    mov editstream.pfnCallback, rdi
                    invoke SendMessage, hwndRichEdit, EM_STREAMOUT, SF_TEXT, addr editstream
                    
                    ;==========================================================
                    ; Initialize the modify state to false
                    ;==========================================================
                    invoke SendMessage, hwndRichEdit, EM_SETMODIFY, FALSE, 0
                    invoke CloseHandle, hFile
                    
                .else
                    invoke MessageBox, hWnd, addr OpenFileFail, addr AppName, MB_OK or MB_ICONERROR
                .endif
                
            .elseif ax==IDM_COPY
                invoke SendMessage, hwndRichEdit, WM_COPY, 0, 0
                
            .elseif ax==IDM_CUT
                invoke SendMessage, hwndRichEdit, WM_CUT, 0, 0
                
            .elseif ax==IDM_PASTE
                invoke SendMessage, hwndRichEdit, WM_PASTE, 0, 0
                
            .elseif ax==IDM_DELETE
                invoke SendMessage, hwndRichEdit, EM_REPLACESEL, TRUE, 0
                
            .elseif ax==IDM_SELECTALL
                mov chrg.cpMin, 0
                mov chrg.cpMax, -1
                invoke SendMessage, hwndRichEdit, EM_EXSETSEL, 0, addr chrg
                
            .elseif ax==IDM_UNDO
                invoke SendMessage, hwndRichEdit, EM_UNDO, 0, 0
                
            .elseif ax==IDM_REDO
                invoke SendMessage, hwndRichEdit, EM_REDO, 0, 0
                
            .elseif ax==IDM_OPTION
                invoke DialogBoxParam, hInstance, IDD_OPTIONDLG, hWnd, addr OptionProc, 0
                
            .elseif ax==IDM_SAVEAS
                ;
            .elseif ax==IDM_EXIT
                invoke SendMessage, hWnd, WM_CLOSE, 0, 0
                
            .endif
        .endif
        
    .elseif uMsg==WM_CLOSE
        invoke CheckModifyState, hWnd
        .if rax==TRUE
            invoke DestroyWindow, hWnd
        .endif
        
    .elseif uMsg==WM_SIZE
        mov rax, lParam
        mov rdx, rax
        and rax, 0FFFFh
        mov nWidth, eax
        shr rdx, 16
        and rdx, 0FFFFh
        mov nHeight, edx
        invoke MoveWindow, hwndRichEdit, 0, 0, nWidth, nHeight, TRUE
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
