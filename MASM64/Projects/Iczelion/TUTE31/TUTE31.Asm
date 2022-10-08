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
; | @date     : 28/09/2022                                                |
; | @license  : n/a                                                       |
; |_______________________________________________________________________|
; |                                                                       |
; |            Iczelion's Win32 Assembly Tutorials with MASM64            |
; |                    Tutorial 31 - Listview Control                     |
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

    RGB macro red,green,blue
        xor rax,rax
        mov al,blue
        shl eax,16
        mov al,green
        shl ax,8
        mov al,red
    endm

    NMLISTVIEW STRUCT
        hdr             NMHDR <>
        iItem           DWORD ?
                        DWORD ?
        iSubItem        DWORD ?
        uNewState       DWORD ?
        uOldState       DWORD ?
        uChanged        DWORD ?
        ptAction        POINT <>
                        DWORD ?
        lParam          LPARAM ?
    NMLISTVIEW ENDS
; _________________________________________________________________________
; function prototypes

    WndProc                 PROTO   :HWND,:UINT,:WPARAM,:LPARAM

; _________________________________________________________________________
; constant variables

.const
    IDM_MAINMENU            equ 10000
    IDM_ICON                equ LVS_ICON
    IDM_SMALLICON           equ LVS_SMALLICON
    IDM_LIST                equ LVS_LIST
    IDM_REPORT              equ LVS_REPORT
    
    ; Constants from CommCtrl.h
    LVM_SETBKCOLOR          equ LVM_FIRST + 1
    LVM_GETNEXTITEM         equ LVM_FIRST + 12
    LVM_SETTEXTCOLOR        equ LVM_FIRST + 36
    LVM_SETTEXTBKCOLOR      equ LVM_FIRST + 38
    LVM_GETITEMTEXTA        equ LVM_FIRST + 45
    LVM_SORTITEMS           equ LVM_FIRST + 48
    LVM_GETITEMTEXTW        equ LVM_FIRST + 115
    LVNI_FOCUSED            equ 1

; _________________________________________________________________________
; initialized variables

.data
    ClassName               db "ListViewWin64Class", 0              ; the name of our window class
    AppName                 db "x64 Testing a ListView Control", 0  ; the name of our window
    ListViewClassName       db "SysListView32", 0
    Heading1                db "Filename", 0
    Heading2                db "Size", 0
    FileNamePattern         db "*.*", 0
    template                db "%lu", 0
    FileNameSortOrder       dd 3
    SizeSortOrder           dd 1

; _________________________________________________________________________
; uninitialized variables

.data?
    CommandLine LPSTR ?
    hInstance   HINSTANCE ?
    hIcon       HICON ?
    hCursor     HCURSOR ?
    hList       HANDLE ?
    hMenu       HMENU ?

.code

WinMainCRTStartup proc
    
    invoke  InitCommonControls
    
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
    mov     wcex.lpszMenuName, IDM_MAINMENU
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

InsertColumn proc
    
    LOCAL   lvc:LVCOLUMNA
    
    mov lvc._mask, LVCF_TEXT or LVCF_WIDTH
    lea rdi, Heading1
    mov lvc.pszText, rdi
    mov lvc._cx, 150
    invoke SendMessage, hList, LVM_INSERTCOLUMN, 0, addr lvc
    
    or lvc._mask, LVCF_FMT
    mov lvc.fmt, LVCFMT_RIGHT
    lea rdi, Heading2
    mov lvc.pszText, rdi
    mov lvc._cx, 100
    invoke SendMessage, hList, LVM_INSERTCOLUMN, 1, addr lvc
    
    ret

InsertColumn endp

ShowFileInfo proc row:DWORD, lpFind:QWORD
    
    LOCAL   lvi:LVITEM
    LOCAL   buffer[20]:BYTE
    
    mov rdi, lpFind
    mov lvi._mask, LVIF_TEXT or LVIF_PARAM
    mov eax, row
    mov lvi.iItem, eax
    mov lvi.iSubItem, 0
    lea rax, (WIN32_FIND_DATA ptr [rdi]).cFileName
    mov lvi.pszText, rax
    mov eax, row
    mov lvi.lParam, rax
    invoke SendMessage, hList, LVM_INSERTITEM, 0, addr lvi
    
    mov lvi._mask, LVIF_TEXT
    inc lvi.iSubItem
    
    mov ebx, (WIN32_FIND_DATA ptr [rdi]).nFileSizeLow
    invoke wsprintf,addr buffer, addr template,ebx
    lea rax, buffer
    mov lvi.pszText, rax
    invoke SendMessage, hList, LVM_SETITEM, 0, addr lvi
    xor rdi, rdi
    
    ret

ShowFileInfo endp

FillFileInfo proc
    
    LOCAL   findData:WIN32_FIND_DATA
    LOCAL   hFind:HANDLE
    
    invoke FindFirstFile, addr FileNamePattern, addr findData
    
    .if rax{}INVALID_HANDLE_VALUE
        mov hFind, rax
        xor rdi, rdi
        
        .while rax{}0
            test findData.dwFileAttributes, FILE_ATTRIBUTE_DIRECTORY
            .if ZERO?
                invoke ShowFileInfo, rdi, addr findData
                inc rdi
            .endif
            
            invoke FindNextFile, hFind, addr findData
            
        .endw
        invoke FindClose, hFind
    .endif
    
    ret

FillFileInfo endp

String2Qword proc szStr:QWORD

    LOCAL   res:QWORD
    
    mov res, 0
    mov rdi, szStr
    invoke lstrlen, szStr
    
    .while rax{}0
        xor rdx, rdx
        mov dl, byte ptr[rdi]
        sub dl, "0"
        mov rsi, rax
        dec rsi
        push rax
        mov rax, rdx
        push rbx
        mov rbx, 10
        .while rsi } 0
            mul rbx
            dec rsi
        .endw
        pop rbx
        add res, rax
        pop rax
        inc rdi
        dec rax
    .endw
    
    mov rax, res
    
    ret
    
String2Qword endp

CompareFunc proc lParam1:LPARAM, lParam2:LPARAM, SortType:QWORD

    LOCAL   buffer1[256]:BYTE
    LOCAL   buffer2[256]:BYTE
    LOCAL   lvi:LVITEM
    LOCAL   old_rdi:QWORD
    LOCAL   old_rsi:QWORD
    LOCAL   old_rbx:QWORD
    
    mov old_rdi, rdi
    mov old_rsi, rsi
    
    mov lvi._mask, LVIF_TEXT
    lea rax, buffer1
    mov lvi.pszText, rax
    mov lvi.cchTextMax, 256
    
    .if SortType==1
        mov lvi.iSubItem, 1
        invoke SendMessage, hList, LVM_GETITEMTEXTA, lParam1, addr lvi
        invoke String2Qword, addr buffer1
        mov old_rbx, rbx
        mov rbx, rax
        invoke SendMessage, hList, LVM_GETITEMTEXTA, lParam2, addr lvi
        invoke String2Qword, addr buffer1
        sub rbx, rax
        mov rax, rbx
        mov rbx, old_rbx
        
    .elseif SortType==2
        mov lvi.iSubItem,1
		invoke SendMessage, hList, LVM_GETITEMTEXTA, lParam1, addr lvi
		invoke String2Qword, addr buffer1
		mov old_rbx, rbx
		mov rbx, rax
		invoke SendMessage, hList, LVM_GETITEMTEXTA, lParam2, addr lvi
        invoke String2Qword, addr buffer1
        sub rax, rbx
        mov rbx, old_rbx
        
    .elseif SortType==3
        mov lvi.iSubItem, 0
		invoke SendMessage, hList, LVM_GETITEMTEXTA, lParam1, addr lvi
		invoke lstrcpy, addr buffer2, addr buffer1
		invoke SendMessage, hList, LVM_GETITEMTEXTA, lParam2, addr lvi
		invoke lstrcmpi, addr buffer2, addr buffer1
    .else
        mov lvi.iSubItem, 0
		invoke SendMessage, hList, LVM_GETITEMTEXTA, lParam1, addr lvi
		invoke lstrcpy, addr buffer2, addr buffer1
		invoke SendMessage, hList, LVM_GETITEMTEXTA, lParam2, addr lvi
		invoke lstrcmpi, addr buffer1, addr buffer2
    .endif
    
    mov rsi, old_rsi
    mov rdi, old_rdi
    
    ret
    
CompareFunc endp

UpdatelParam proc
    
    LOCAL   lvi:LVITEM
    LOCAL   old_rdi:QWORD
    
    mov old_rdi, rdi
    invoke SendMessage, hList, LVM_GETITEMCOUNT, 0, 0
    mov edi, eax
    mov lvi._mask, LVIF_PARAM
    mov lvi.iSubItem, 0
    mov lvi.iItem, 0
    mov lvi.lParam, 0
    .while rdi } 0
        ;mov eax, lvi.iItem
        ;mov lvi.lParam, rax
        invoke SendMessage, hList, LVM_SETITEM, 0, addr lvi
        inc lvi.iItem
        inc lvi.lParam
        dec rdi
    .endw
    
    mov rdi, old_rdi
    
    ret

UpdatelParam endp

ShowCurrentFocus proc
    
    LOCAL   lvi:LVITEM
    LOCAL   buffer[256]:BYTE
    
    invoke SendMessage, hList, LVM_GETNEXTITEM, -1, LVNI_FOCUSED
    mov lvi.iItem, eax
    mov lvi.iSubItem, 0
    mov lvi._mask, LVIF_TEXT
    lea rax, buffer
    mov lvi.pszText, rax
    mov lvi.cchTextMax, 256
    
    invoke SendMessage, hList, LVM_GETITEM, 0, addr lvi
    invoke MessageBox, 0, addr buffer, addr AppName, MB_OK
    
    ret

ShowCurrentFocus endp

WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM

    LOCAL   nWidth:INT32
    LOCAL   nHeight:INT32
    
    .if uMsg==WM_CREATE
        invoke CreateWindowEx, \
                        NULL, \
                        addr ListViewClassName, \
                        NULL, \
                        LVS_REPORT or WS_VISIBLE or WS_CHILD, \
                        0, 0, 0, 0, \
                        hWnd, NULL, hInstance, NULL
        mov hList, rax
        
        invoke InsertColumn
        invoke FillFileInfo
        
        RGB 255,255,255
        invoke SendMessage, hList, LVM_SETTEXTCOLOR, 0, rax
        
        RGB 0, 0, 0
        invoke SendMessage, hList, LVM_SETBKCOLOR, 0, rax
        
        RGB 0, 0, 0
        invoke SendMessage, hList, LVM_SETTEXTBKCOLOR, 0, rax
        
        invoke GetMenu, hWnd
        mov hMenu,  rax
        invoke CheckMenuRadioItem, hMenu, IDM_ICON, IDM_LIST, IDM_REPORT, MF_CHECKED
        
    .elseif uMsg==WM_COMMAND
        .if lParam==0
            invoke GetWindowLongPtr, hList, GWL_STYLE
            and eax, not LVS_TYPEMASK
            movzx edi, word ptr wParam
            or eax, edi
            invoke SetWindowLongPtr, hList, GWL_STYLE, rax
            invoke CheckMenuRadioItem, hMenu, IDM_ICON, IDM_LIST, rdi, MF_CHECKED
        .endif
        
    .elseif uMsg==WM_NOTIFY
        mov rdi, lParam
        
        mov rax, (NMHDR ptr[rdi]).hwndFrom
        .if rax==hList
            .if (NMHDR ptr [rdi])._code==LVN_COLUMNCLICK
                .if (NMLISTVIEW ptr[rdi] - 4).iSubItem==1
                    .if SizeSortOrder==0 || SizeSortOrder==2
                        invoke SendMessage, hList, LVM_SORTITEMS, 1, addr CompareFunc
                        invoke UpdatelParam
                        mov SizeSortOrder, 1
                        
                    .else
                        invoke SendMessage, hList, LVM_SORTITEMS, 2, addr CompareFunc
                        invoke UpdatelParam
                        mov SizeSortOrder, 2
                        
                    .endif
                .else
                    .if FileNameSortOrder==0 || FileNameSortOrder==4
                        invoke SendMessage, hList, LVM_SORTITEMS, 3, addr CompareFunc
                        invoke UpdatelParam
                        mov FileNameSortOrder, 3
                        
                    .else
                        invoke SendMessage, hList, LVM_SORTITEMS, 4, addr CompareFunc
                        invoke UpdatelParam
                        mov FileNameSortOrder, 4
                        
                    .endif
                .endif
            .elseif (NMHDR ptr [rdi])._code==NM_DBLCLK
                invoke ShowCurrentFocus
            .endif
        .endif
        
    .elseif uMsg==WM_SIZE
        mov rax, lParam
        mov rdx, rax
        and rax, 0FFFFh
        mov nWidth, eax
        shr rdx, 16
        and rdx, 0FFFFh
        mov nHeight, edx
        invoke MoveWindow, hList, 0, 0, nWidth, nHeight, TRUE
        
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
