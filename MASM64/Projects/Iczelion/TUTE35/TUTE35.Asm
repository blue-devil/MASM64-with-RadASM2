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
; | @date     : 10/10/2022                                                |
; | @license  : n/a                                                       |
; |_______________________________________________________________________|
; |                                                                       |
; |            Iczelion's Win32 Assembly Tutorials with MASM64            |
; |          Tutorial 35 - RichEdit Control :  Syntax Hilighting          |
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
; structure definitions
    
    ; The CHOOSECOLOR structure definition was slightly wrong when
    ; I wrote this code. So I need to fix it:
    CHOOSECOLORZ STRUC
      lStructSize       DWORD ?, ?
      hwndOwner         QWORD ?
      hInstance         QWORD ?
      rgbResult         DWORD ?, ?
      lpCustColors      QWORD ?     ; Must be QWORD in 64bit windows
      Flags             DWORD ?, ?
      lCustData         QWORD ?
      lpfnHook          QWORD ?
      lpTemplateName    QWORD ?
    CHOOSECOLORZ ENDS
    
    IFNDEF FINDTEXTEX
        FINDTEXTEX STRUCT QWORD
            chrg            CHARRANGE <>
            lpstrText       dq ?
            chrgText        CHARRANGE <>
        FINDTEXTEX ENDS
    ENDIF
    
    IFNDEF SETTEXTEX
        SETTEXTEX STRUCT
          flags             DWORD ?
          codepage          DWORD ?
        SETTEXTEX ENDS
    ENDIF
    
    IFNDEF MSGFILTER
        MSGFILTER STRUCT
            nmhdr           NMHDR <>
            msg             UINT ?
            wParam          WPARAM ?
            lParam          LPARAM ?
        MSGFILTER ENDS
    ENDIF
    
    IFNDEF WORDINFO
        WORDINFO struct
            WordLen         QWORD ? ; the length of the word: used as a quick comparison
            pszWord         QWORD ? ; pointer to the word
            pColor          QWORD ? ; point to the dword that contains the color used to hilite the word
            NextLink        QWORD ? ; point to the next WORDINFO structure
        WORDINFO ends
    ENDIF

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
    
    IDR_MAINACCEL                   equ 105
    IDD_FINDDLG                     equ 102
    IDD_GOTODLG                     equ 103
    IDD_REPLACEDLG                  equ 104
    IDC_FINDEDIT                    equ 1000
    IDC_MATCHCASE                   equ 1001
    IDC_REPLACEEDIT                 equ 1001
    IDC_WHOLEWORD                   equ 1002
    IDC_DOWN                        equ 1003
    IDC_UP                          equ 1004
    IDC_LINENO                      equ 1005
    IDM_FIND                        equ 40014
    IDM_FINDNEXT                    equ 40015
    IDM_REPLACE                     equ 40016
    IDM_GOTOLINE                    equ 40017
    IDM_FINDPREV                    equ 40018
    
    RichEditID                      equ 300

; _________________________________________________________________________
; initialized variables

.data
    ClassName                       db "x64IczEditClass", 0
    AppName                         db "x64 IczEdit version 3.0", 0
    RichEditDLL                     db "riched20.dll",0
    RichEditClass                   db "RichEdit20A",0
    NoRichEdit                      db "Cannot find riched20.dll",0
    ASMFilterString                 db "ASM Source code (*.asm)",0,"*.asm",0
                                    db "All Files (*.*)",0,"*.*",0,0
    OpenFileFail                    db "Cannot open the file",0
    WannaSave                       db "The data in the control is modified. Want to save it?",0
    FileOpened                      dq FALSE
    BackgroundColor                 dd 0FFFFFFh ; default to white
    TextColor                       dd 0        ; default to black
    WordFileName                    db "\wordfile.txt", 0
    ASMSection                      db "ASSEMBLY", 0
    C1Key                           db "C1", 0
    C2Key                           db "C2", 0
    C3Key                           db "C3", 0
    C4Key                           db "C4", 0
    C5Key                           db "C5", 0
    C6Key                           db "C6", 0
    C7Key                           db "C7", 0
    C8Key                           db "C8", 0
    C9Key                           db "C9", 0
    C10Key                          db "C10", 0
    ZeroString                      db 0
    CommentColor                    dd 808000h
    ASMColorArray dd 0FF0000h,0805F50h,0FFh,666F00h,44F0h,5F8754h,4 dup(0FF0000h)

; _________________________________________________________________________
; uninitialized variables

.data?
    CommandLine         LPSTR ?
    hInstance           HINSTANCE ?
    hIcon               HICON ?
    hCursor             HCURSOR ?
    hRichEdit           HANDLE ?
    hwndRichEdit        HANDLE ?
    hSearch             HANDLE ?
    hAccell             HANDLE ?
    hMainHeap           HANDLE ?
    OldWndProc          QWORD ?
    RichEditVersion     DWORD ?
    AlternateFileName   db 256 dup(?)
    FileName            db 256 dup(?)
    CustomColors        dd 16 dup(?)
    FindBuffer          db 256 dup(?)
    ReplaceBuffer       db 256 dup(?)
    uFlags              dd ?
    findtext            FINDTEXTEX <>
    ASMSyntaxArray      dd 256 dup(?)

.code

WinMainCRTStartup proc
    
    invoke  GetModuleHandle, NULL
    mov     hInstance, rax
    
    invoke  GetCommandLine
    mov     CommandLine, rax
    
    mov     byte ptr [FindBuffer], 0
    mov     byte ptr [ReplaceBuffer], 0
    
    invoke  LoadLibrary, addr RichEditDLL
    .if rax{}0
        mov hRichEdit, rax
        invoke GetProcessHeap
        mov hMainHeap, rax
        
        ;===========================================================
        ; Load the words to be hilighted
        ;===========================================================
        ;call FillHiliteInfo
        
        invoke WinMain, hInstance, NULL, CommandLine, SW_SHOWDEFAULT
        invoke FreeLibrary, hRichEdit
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
    
    invoke  LoadAccelerators, hInstance, IDR_MAINACCEL
    mov     hAccell, rax
    
    .while TRUE
        invoke  GetMessage, addr msg, NULL, 0, 0
        .if (rax == 0)
            .break
        .endif
        invoke  IsDialogMessage, hSearch, addr msg
        .if rax==FALSE
            invoke TranslateAccelerator, hWnd, hAccell, addr msg
            .if rax==0
                invoke  TranslateMessage, addr msg
                invoke  DispatchMessage, addr msg
            .endif
        .endif
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

    LOCAL   clr:CHOOSECOLORZ
    LOCAL   tmp:QWORD
    
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
                mov clr.lpCustColors, rdi
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
                mov clr.lpCustColors, rdi
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
                mov tmp, rax
                invoke SetColor
                mov rax, tmp
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

SearchProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    
    .if uMsg==WM_INITDIALOG
        mov rax, hWnd
        mov hSearch, rax
        
        ;===================================================
        ; Select the default search down option
        ;===================================================
        invoke CheckRadioButton, hWnd, IDC_DOWN, IDC_UP, IDC_DOWN
        invoke SendDlgItemMessage, hWnd, IDC_FINDEDIT, WM_SETTEXT, 0, addr FindBuffer
        
    .elseif uMsg==WM_COMMAND
        mov rax, wParam
        shr rax, 16
        .if ax==BN_CLICKED
            mov rax, wParam
            .if ax==IDOK
                mov uFlags, 0
                invoke SendMessage, hwndRichEdit, EM_EXGETSEL, 0, addr findtext.chrg
                invoke GetDlgItemText, hWnd, IDC_FINDEDIT, addr FindBuffer, sizeof FindBuffer
                .if rax{}0
                    invoke IsDlgButtonChecked, hWnd, IDC_DOWN
                    .if rax==BST_CHECKED
                        or uFlags, FR_DOWN
                        mov eax, findtext.chrg.cpMin
                        .if eax{}findtext.chrg.cpMax
                            mov eax, findtext.chrg.cpMax
                            mov findtext.chrg.cpMin, eax
                        .endif
                        mov findtext.chrg.cpMax, -1
                    .else
                        mov findtext.chrg.cpMax, 0
                    .endif
                    
                    invoke IsDlgButtonChecked, hWnd, IDC_MATCHCASE
                    .if rax==BST_CHECKED
                        or uFlags, FR_MATCHCASE
                    .endif
                    
                    invoke IsDlgButtonChecked,hWnd,IDC_WHOLEWORD
                    .if rax==BST_CHECKED
                        or uFlags, FR_WHOLEWORD
                    .endif
                    lea rdi, FindBuffer
                    mov findtext.lpstrText, rdi
                    invoke SendMessage, hwndRichEdit, EM_FINDTEXTEX, uFlags, addr findtext
                    .if rax{}-1
                        invoke SendMessage, hwndRichEdit, EM_EXSETSEL, 0, addr findtext.chrgText
                    .endif
                    
                .endif
                
            .elseif ax==IDCANCEL
                invoke SendMessage, hWnd, WM_CLOSE, 0, 0
                
            .else
                mov eax, FALSE
                ret
                
            .endif
        .endif
        
    .elseif uMsg==WM_CLOSE
        mov hSearch, 0
        invoke EndDialog, hWnd, 0
        
    .else
        mov eax, FALSE
        ret
        
    .endif
    
    mov eax, TRUE
    ret

SearchProc endp

ReplaceProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    
    LOCAL   settext:SETTEXTEX
    
    .if uMsg==WM_INITDIALOG
        mov rax, hWnd
        mov hSearch, rax
        invoke SetDlgItemText, hWnd, IDC_FINDEDIT, addr FindBuffer
        invoke SetDlgItemText, hWnd, IDC_REPLACEEDIT, addr ReplaceBuffer
        
    .elseif uMsg==WM_COMMAND
        mov rax, wParam
        shr rax, 16
        .if ax==BN_CLICKED
            mov rax, wParam
            .if ax==IDCANCEL
                invoke SendMessage, hWnd, WM_CLOSE, 0, 0
                
            .elseif ax==IDOK
                invoke GetDlgItemText, hWnd, IDC_FINDEDIT, addr FindBuffer, sizeof FindBuffer
                invoke GetDlgItemText, hWnd, IDC_REPLACEEDIT, addr ReplaceBuffer, sizeof ReplaceBuffer
                mov findtext.chrg.cpMin, 0
                mov findtext.chrg.cpMax, -1
                lea rdi, FindBuffer
                mov findtext.lpstrText, rdi
                mov settext.flags, ST_SELECTION
                mov settext.codepage, CP_ACP
                .while TRUE
                    invoke SendMessage, hwndRichEdit, EM_FINDTEXTEX, FR_DOWN, addr findtext
                    .if rax==-1
                        .break
                    .else
                        invoke SendMessage, hwndRichEdit, EM_EXSETSEL, 0, addr findtext.chrgText
                        invoke SendMessage, hwndRichEdit, EM_SETTEXTEX, addr settext, addr ReplaceBuffer
                    .endif
                .endw
                
            .endif
        .endif
        
    .elseif uMsg==WM_CLOSE
        mov hSearch, 0
        invoke EndDialog, hWnd, 0
    .else
        mov eax, FALSE
        ret
        
    .endif
    
    mov eax, TRUE
    ret

ReplaceProc endp

GoToProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    
    LOCAL   LineNo:QWORD
    LOCAL   chrg:CHARRANGE
    
    .if uMsg==WM_INITDIALOG
        mov rax, hWnd
        mov hSearch, rax
    .elseif uMsg==WM_COMMAND
        mov rax, wParam
        shr rax, 16
        .if ax==BN_CLICKED
            mov rax, wParam
            .if ax==IDCANCEL
                invoke SendMessage, hWnd, WM_CLOSE, 0, 0
                
            .elseif ax==IDOK
                invoke GetDlgItemInt, hWnd, IDC_LINENO, NULL, FALSE
                mov LineNo, rax
                invoke SendMessage, hwndRichEdit, EM_GETLINECOUNT, 0, 0
                .if rax}LineNo
                    invoke SendMessage, hwndRichEdit, EM_LINEINDEX, LineNo, 0
                    invoke SendMessage, hwndRichEdit, EM_SETSEL, rax, rax
                    invoke SetFocus, hwndRichEdit
                .endif
                
            .endif
        .endif
        
    .elseif uMsg==WM_CLOSE
        mov hSearch, 0
        invoke EndDialog, hWnd, 0
        
    .else
        mov eax, FALSE
        ret
        
    .endif
    
    mov eax, TRUE
    ret

GoToProc endp

PrepareEditMenu proc hSubMenu:HANDLE
    
    LOCAL   chrg:CHARRANGE
    
    ;=============================================================================
    ; Check whether there is some text in the clipboard. If so, we enable the paste menuitem
    ;=============================================================================
    invoke SendMessage, hwndRichEdit, EM_CANPASTE, CF_TEXT, 0
    .if rax==0      ; no text in the clipboard
        invoke EnableMenuItem, hSubMenu, IDM_PASTE, MF_GRAYED
    .else
        invoke EnableMenuItem, hSubMenu, IDM_PASTE, MF_ENABLED
    .endif
    
    ;==========================================================
    ; check whether the undo queue is empty
    ;==========================================================
    invoke SendMessage, hwndRichEdit, EM_CANUNDO, 0, 0
    .if rax==0
        invoke EnableMenuItem, hSubMenu, IDM_UNDO, MF_GRAYED
    .else
        invoke EnableMenuItem, hSubMenu, IDM_UNDO, MF_ENABLED
    .endif
    
    ;=========================================================
    ; check whether the redo queue is empty
    ;=========================================================
    invoke SendMessage, hwndRichEdit, EM_CANREDO, 0, 0
    .if rax==0
        invoke EnableMenuItem, hSubMenu, IDM_REDO, MF_GRAYED
    .else
        invoke EnableMenuItem, hSubMenu, IDM_REDO, MF_ENABLED
    .endif
    
    ;=========================================================
    ; check whether there is a current selection in the richedit control.
    ; If there is, we enable the cut/copy/delete menuitem
    ;=========================================================
    invoke SendMessage, hwndRichEdit, EM_EXGETSEL, 0, addr chrg
    mov eax,chrg.cpMin
    .if eax==chrg.cpMax     ; no current selection
        invoke EnableMenuItem, hSubMenu, IDM_COPY, MF_GRAYED
        invoke EnableMenuItem, hSubMenu, IDM_CUT, MF_GRAYED
        invoke EnableMenuItem, hSubMenu, IDM_DELETE, MF_GRAYED
    .else
        invoke EnableMenuItem, hSubMenu, IDM_COPY, MF_ENABLED
        invoke EnableMenuItem, hSubMenu, IDM_CUT, MF_ENABLED
        invoke EnableMenuItem, hSubMenu, IDM_DELETE, MF_ENABLED
    .endif
    
    ret

PrepareEditMenu endp

ParseBuffer proc uses rdi rsi hHeap:HANDLE, pBuffer:QWORD, nSize:QWORD, ArrayOffset:QWORD, pArray:QWORD
    
    LOCAL   buffer[128]:BYTE
    LOCAL   InProgress:QWORD
    
    mov InProgress, FALSE
    lea rsi, buffer
    mov rdi, pBuffer
    invoke CharLower, rdi
    
    mov rcx, nSize
    
SearchLoop:
    or rcx, rcx
    jz Finished
    cmp byte ptr[rdi], " "      ; space
    je EndOfWord
    cmp byte ptr[rdi], 9        ; tab
    je EndOfWord
    mov InProgress, TRUE
    mov al, byte ptr[rdi]
    mov byte ptr[rsi], al
    inc rsi
    
SkipIt:
    inc rdi
    dec rcx
    jmp SearchLoop

EndOfWord:
    cmp InProgress, TRUE
    je WordFound
    jmp SkipIt

WordFound:
    mov byte ptr[rsi], 0
    push rcx
    ;========================================================
    ; store the word in a WORDINFO structure
    ;========================================================
    invoke HeapAlloc, hHeap, HEAP_ZERO_MEMORY, sizeof WORDINFO
    push rsi
    mov rsi, rax
    invoke lstrlen, addr buffer
    mov (WORDINFO ptr[rsi]).WordLen, rax
    mov rbx, ArrayOffset
    mov (WORDINFO ptr[rsi]).pColor, rbx
    inc rax
    invoke HeapAlloc, hHeap, HEAP_ZERO_MEMORY, rax
    mov (WORDINFO ptr[rsi]).pszWord, rax
    mov rdx, rax
    invoke lstrcpy, rdx, addr buffer
    mov rax, pArray
    movzx edx, byte ptr buffer
    shl rdx, 2                          ; multiply by 4
    add rax, rdx
    .if qword ptr[rax]==0
        mov qword ptr[rax], rsi
    .else
        mov rbx, qword ptr[rax]
        mov (WORDINFO ptr[rsi]).NextLink, rbx
        mov qword ptr[rax], rsi
    .endif
    
    pop rsi
    pop rcx
    lea rsi, buffer
    mov InProgress, FALSE
    jmp SkipIt

Finished:
    .if InProgress==TRUE
        ;========================================================
        ; store the word in a WORDINFO structure
        ;========================================================
        invoke HeapAlloc, hHeap, HEAP_ZERO_MEMORY, sizeof WORDINFO
        push rsi
        mov rsi, rax
        invoke lstrlen, addr buffer
        mov (WORDINFO ptr[rsi]).WordLen, rax
        mov rbx, ArrayOffset
        mov (WORDINFO ptr[rsi]).pColor, rbx
        inc rax
        invoke HeapAlloc, hHeap, HEAP_ZERO_MEMORY, rax
        mov (WORDINFO ptr[rsi]).pszWord, rax
        mov rdx, rax
        invoke lstrcpy, rdx, addr buffer
        mov rax, pArray
        movzx edx, byte ptr buffer
        shl rdx, 2                          ; multiply by 4
        add rax, rdx
        .if qword ptr[rax]==0
            mov qword ptr[rax], rsi
        .else
            mov rbx, qword ptr[rax]
            mov (WORDINFO ptr[rsi]).NextLink, rbx
            mov qword ptr[rax], rsi
        .endif
        
        pop rsi
        
    .endif
    
    ret

ParseBuffer endp

FillHiliteInfo proc uses rdi
    
    LOCAL   buffer[1024]:BYTE
    LOCAL   pTemp:QWORD
    LOCAL   BlockSize:QWORD
    
    ;===================================================================
    ; Zero out the array
    ;===================================================================
    invoke RtlZeroMemory, addr ASMSyntaxArray, sizeof ASMSyntaxArray
    
    ;===================================================================
    ; obtaining the path of this program instance
    ;===================================================================
    invoke GetModuleFileName, hInstance, addr buffer, sizeof buffer
    invoke lstrlen, addr buffer
    mov rcx, rax
    
    dec rcx
    lea rdi, buffer
    add rdi, rcx
    std                         ; sets direction flag
    mov al, "\"
    repne scasb                 ; Find AL, starting at [RDI].
    cld                         ; clear direction flag
    inc rdi
    mov byte ptr[rdi], 0
    invoke lstrcat, addr buffer, addr WordFileName
    
    ;==================================================================
    ; Check whether the file exists
    ;==================================================================
    invoke GetFileAttributes, addr buffer
    .if rax{}-1
        ;===================================================================
        ; allocate a block of memory from the heap for the strings
        ;===================================================================
        mov BlockSize,1024*10
        invoke HeapAlloc, hMainHeap, 0, BlockSize
        mov pTemp, rax

@@:     
        invoke GetPrivateProfileString, \
                    addr ASMSection, \
                    addr C1Key, \
                    addr ZeroString, \
                    pTemp, \
                    BlockSize, \
                    addr buffer
        .if rax{}0
            inc rax
            .if rax==BlockSize  ; the buffer is too small
                add BlockSize, 1024*10
                invoke HeapReAlloc, hMainHeap, 0, pTemp, BlockSize
                mov pTemp, rax
                jmp @B
            .endif
            
            mov rdx, offset ASMColorArray
            invoke ParseBuffer, hMainHeap, pTemp, rax, rdx, addr ASMSyntaxArray
        .endif
@@:     
        invoke GetPrivateProfileString, \
                    addr ASMSection, \
                    addr C2Key, \
                    addr ZeroString, \
                    pTemp, \
                    BlockSize, \
                    addr buffer
        .if rax{}0
            inc rax
            .if rax==BlockSize  ; the buffer is too small
                add BlockSize, 1024*10
                invoke HeapReAlloc, hMainHeap, 0, pTemp, BlockSize
                mov pTemp, rax
                jmp @B
            .endif
            
            mov rdx, offset ASMColorArray
            invoke ParseBuffer, hMainHeap, pTemp, rax, rdx, addr ASMSyntaxArray
        .endif
@@:     
        invoke GetPrivateProfileString, \
                    addr ASMSection, \
                    addr C3Key, \
                    addr ZeroString, \
                    pTemp, \
                    BlockSize, \
                    addr buffer
        .if rax{}0
            inc rax
            .if rax==BlockSize  ; the buffer is too small
                add BlockSize, 1024*10
                invoke HeapReAlloc, hMainHeap, 0, pTemp, BlockSize
                mov pTemp, rax
                jmp @B
            .endif
            
            mov rdx, offset ASMColorArray
            invoke ParseBuffer, hMainHeap, pTemp, rax, rdx, addr ASMSyntaxArray
        .endif
@@:     
        invoke GetPrivateProfileString, \
                    addr ASMSection, \
                    addr C4Key, \
                    addr ZeroString, \
                    pTemp, \
                    BlockSize, \
                    addr buffer
        .if rax{}0
            inc rax
            .if rax==BlockSize  ; the buffer is too small
                add BlockSize, 1024*10
                invoke HeapReAlloc, hMainHeap, 0, pTemp, BlockSize
                mov pTemp, rax
                jmp @B
            .endif
            
            mov rdx, offset ASMColorArray
            invoke ParseBuffer, hMainHeap, pTemp, rax, rdx, addr ASMSyntaxArray
        .endif
@@:     
        invoke GetPrivateProfileString, \
                    addr ASMSection, \
                    addr C5Key, \
                    addr ZeroString, \
                    pTemp, \
                    BlockSize, \
                    addr buffer
        .if rax{}0
            inc rax
            .if rax==BlockSize  ; the buffer is too small
                add BlockSize, 1024*10
                invoke HeapReAlloc, hMainHeap, 0, pTemp, BlockSize
                mov pTemp, rax
                jmp @B
            .endif
            
            mov rdx, offset ASMColorArray
            invoke ParseBuffer, hMainHeap, pTemp, rax, rdx, addr ASMSyntaxArray
        .endif
@@:     
        invoke GetPrivateProfileString, \
                    addr ASMSection, \
                    addr C6Key, \
                    addr ZeroString, \
                    pTemp, \
                    BlockSize, \
                    addr buffer
        .if rax{}0
            inc rax
            .if rax==BlockSize  ; the buffer is too small
                add BlockSize, 1024*10
                invoke HeapReAlloc, hMainHeap, 0, pTemp, BlockSize
                mov pTemp, rax
                jmp @B
            .endif
            
            mov rdx, offset ASMColorArray
            invoke ParseBuffer, hMainHeap, pTemp, rax, rdx, addr ASMSyntaxArray
        .endif
@@:     
        invoke GetPrivateProfileString, \
                    addr ASMSection, \
                    addr C7Key, \
                    addr ZeroString, \
                    pTemp, \
                    BlockSize, \
                    addr buffer
        .if rax{}0
            inc rax
            .if rax==BlockSize  ; the buffer is too small
                add BlockSize, 1024*10
                invoke HeapReAlloc, hMainHeap, 0, pTemp, BlockSize
                mov pTemp, rax
                jmp @B
            .endif
            
            mov rdx, offset ASMColorArray
            invoke ParseBuffer, hMainHeap, pTemp, rax, rdx, addr ASMSyntaxArray
        .endif
@@:     
        invoke GetPrivateProfileString, \
                    addr ASMSection, \
                    addr C8Key, \
                    addr ZeroString, \
                    pTemp, \
                    BlockSize, \
                    addr buffer
        .if rax{}0
            inc rax
            .if rax==BlockSize  ; the buffer is too small
                add BlockSize, 1024*10
                invoke HeapReAlloc, hMainHeap, 0, pTemp, BlockSize
                mov pTemp, rax
                jmp @B
            .endif
            
            mov rdx, offset ASMColorArray
            invoke ParseBuffer, hMainHeap, pTemp, rax, rdx, addr ASMSyntaxArray
        .endif
@@:     
        invoke GetPrivateProfileString, \
                    addr ASMSection, \
                    addr C9Key, \
                    addr ZeroString, \
                    pTemp, \
                    BlockSize, \
                    addr buffer
        .if rax{}0
            inc rax
            .if rax==BlockSize  ; the buffer is too small
                add BlockSize, 1024*10
                invoke HeapReAlloc, hMainHeap, 0, pTemp, BlockSize
                mov pTemp, rax
                jmp @B
            .endif
            
            mov rdx, offset ASMColorArray
            invoke ParseBuffer, hMainHeap, pTemp, rax, rdx, addr ASMSyntaxArray
        .endif
@@:     
        invoke GetPrivateProfileString, \
                    addr ASMSection, \
                    addr C10Key, \
                    addr ZeroString, \
                    pTemp, \
                    BlockSize, \
                    addr buffer
        .if rax{}0
            inc rax
            .if rax==BlockSize  ; the buffer is too small
                add BlockSize, 1024*10
                invoke HeapReAlloc, hMainHeap, 0, pTemp, BlockSize
                mov pTemp, rax
                jmp @B
            .endif
            
            mov rdx, offset ASMColorArray
            invoke ParseBuffer, hMainHeap, pTemp, rax, rdx, addr ASMSyntaxArray
        .endif
        invoke HeapFree, hMainHeap, 0, pTemp

    .endif
    
    ret

FillHiliteInfo endp


WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM

    LOCAL   chrg:CHARRANGE
    LOCAL   ofn:OPENFILENAME
    LOCAL   buffer[256]:BYTE
    LOCAL   editstream:EDITSTREAM
    LOCAL   hFile:HANDLE
    LOCAL   nWidth:INT32
    LOCAL   nHeight:INT32
    LOCAL   hPopup:HANDLE
    LOCAL   pt:POINT
    
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
        ;============================================================
        ; set event mask
        ;============================================================
        invoke SendMessage, hwndRichEdit, EM_SETEVENTMASK, 0, ENM_MOUSEEVENTS
        invoke SendMessage, hwndRichEdit, EM_EMPTYUNDOBUFFER, 0, 0
        
    .elseif uMsg==WM_NOTIFY
        mov rdi, lParam
        
        mov eax, (NMHDR ptr[rdi])._code
        .if rax==EN_MSGFILTER
            mov eax, (MSGFILTER ptr[rdi]).msg
            .if rax==WM_RBUTTONDOWN
                invoke GetMenu, hWnd
                invoke GetSubMenu, rax, 1
                mov hPopup, rax
                invoke PrepareEditMenu, hPopup
                mov rdx, (MSGFILTER ptr[rdi]).lParam
                mov rcx, rdx
                and rdx, 0FFFFh
                shr ecx, 16
                mov pt.x, edx
                mov pt.y, ecx
                invoke ClientToScreen, hWnd, addr pt
                invoke TrackPopupMenu, hPopup, TPM_LEFTALIGN or TPM_BOTTOMALIGN, pt.x, pt.y, NULL, hWnd, NULL
            .endif
        .endif
        
    .elseif uMsg==WM_INITMENUPOPUP
        mov rax, lParam
        .if ax==0                       ; File Menu
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
            
        .elseif ax==1                   ; Edit Menu
            invoke PrepareEditMenu, wParam

        .elseif ax==2                   ; Search Menu bar
            .if FileOpened==TRUE
                invoke EnableMenuItem, wParam, IDM_FIND, MF_ENABLED
                invoke EnableMenuItem, wParam, IDM_FINDNEXT, MF_ENABLED
                invoke EnableMenuItem, wParam, IDM_FINDPREV, MF_ENABLED
                invoke EnableMenuItem, wParam, IDM_REPLACE, MF_ENABLED
                invoke EnableMenuItem, wParam, IDM_GOTOLINE, MF_ENABLED
            .else
                invoke EnableMenuItem, wParam, IDM_FIND, MF_GRAYED
                invoke EnableMenuItem, wParam, IDM_FINDNEXT, MF_GRAYED
                invoke EnableMenuItem, wParam, IDM_FINDPREV, MF_GRAYED
                invoke EnableMenuItem, wParam, IDM_REPLACE, MF_GRAYED
                invoke EnableMenuItem, wParam, IDM_GOTOLINE, MF_GRAYED
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
@@:
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
                invoke RtlZeroMemory, addr ofn, sizeof ofn
                mov ofn.lStructSize, sizeof ofn
                mov rax, hWnd
                mov ofn.hwndOwner, rax
                mov rax, hInstance
                mov ofn.hInstance, rax
                lea rdi, ASMFilterString
                mov ofn.lpstrFilter, rdi
                lea rdi, AlternateFileName
                mov ofn.lpstrFile, rdi
                mov byte ptr[AlternateFileName], 0
                mov ofn.nMaxFile, sizeof AlternateFileName
                mov ofn.Flags, OFN_FILEMUSTEXIST or OFN_HIDEREADONLY or OFN_PATHMUSTEXIST
                invoke GetSaveFileName, addr ofn
                .if rax{}0
                    invoke CreateFile, addr AlternateFileName, \
                            GENERIC_WRITE, \
                            FILE_SHARE_READ, \
                            NULL, \
                            CREATE_ALWAYS, \
                            FILE_ATTRIBUTE_NORMAL, \
                            NULL
                    .if rax{}INVALID_HANDLE_VALUE
                        jmp @B
                    .endif
                .endif
                
            .elseif ax==IDM_FIND
                .if hSearch==0
                    invoke CreateDialogParam, hInstance, IDD_FINDDLG, hWnd, addr SearchProc, 0
                .endif
                
            .elseif ax==IDM_REPLACE
                .if hSearch==0
                    invoke CreateDialogParam, hInstance, IDD_REPLACEDLG, hWnd, addr ReplaceProc, 0
                .endif
                
            .elseif ax==IDM_GOTOLINE
                .if hSearch==0
                    invoke CreateDialogParam, hInstance, IDD_GOTODLG, hWnd, addr GoToProc, 0
                .endif
                
            .elseif ax==IDM_FINDNEXT
                invoke lstrlen, addr FindBuffer
                .if rax{}0
                    invoke SendMessage, hwndRichEdit, EM_EXGETSEL, 0, addr findtext.chrg
                    mov eax,findtext.chrg.cpMin
                    .if eax{}findtext.chrg.cpMax
                        mov eax, findtext.chrg.cpMax
                        mov findtext.chrg.cpMin, eax
                    .endif
                    
                    mov findtext.chrg.cpMax, -1
                    lea rdi, FindBuffer
                    mov findtext.lpstrText, rdi
                    invoke SendMessage, hwndRichEdit, EM_FINDTEXTEX, FR_DOWN, addr findtext
                    .if rax{}-1
                        invoke SendMessage, hwndRichEdit, EM_EXSETSEL, 0,addr findtext.chrgText
                    .endif
                .endif
                
            .elseif ax==IDM_FINDPREV
                invoke lstrlen, addr FindBuffer
                .if rax{}0
                    invoke SendMessage, hwndRichEdit, EM_EXGETSEL, 0, addr findtext.chrg
                    mov findtext.chrg.cpMax, 0
                    lea rdi, FindBuffer
                    mov findtext.lpstrText, rdi
                    invoke SendMessage, hwndRichEdit, EM_FINDTEXTEX, 0, addr findtext
                    .if rax{}-1
                        invoke SendMessage, hwndRichEdit, EM_EXSETSEL, 0, addr findtext.chrgText
                    .endif
                .endif
                
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
