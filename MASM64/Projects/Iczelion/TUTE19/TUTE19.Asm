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
; | @date     : 22/08/2022                                                |
; | @license  : n/a                                                       |
; |_______________________________________________________________________|
; |                                                                       |
; |            Iczelion's Win32 Assembly Tutorials with MASM64            |
; |                    Tutorial 19 - Treeview Control                     |
; \_______________________________________________________________________/


    OPTION DOTNAME                          ; required for macro files
    option casemap:none                     ; case sensitive

    include TUTE19.inc

.code

WinMainCRTStartup proc
    
    invoke  GetModuleHandle, NULL
    mov     hInstance, rax
    
    invoke  GetCommandLine
    mov     CommandLine, rax
    
    invoke  InitCommonControls
    
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
    
    invoke  CreateWindowEx, WS_EX_CLIENTEDGE, \
                    addr ClassName, \
                    addr AppName, \
                    WS_OVERLAPPED or WS_CAPTION or WS_SYSMENU or WS_MINIMIZEBOX or WS_MAXIMIZEBOX or WS_VISIBLE, \
                    CW_USEDEFAULT, \
                    CW_USEDEFAULT, \
                    200, \
                    400, \
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
    
    LOCAL   tvinsert:TV_INSERTSTRUCT
    LOCAL   hBitmap:QWORD
    LOCAL   tvhit:TV_HITTESTINFO
    LOCAL   posX:INT32
    LOCAL   posY:INT32
    
    .if uMsg==WM_CREATE
        invoke  CreateWindowEx, \
                        NULL, \
                        addr TreeViewClass, \
                        NULL, \
                        WS_CHILD or WS_VISIBLE or TVS_HASLINES or TVS_HASBUTTONS or TVS_LINESATROOT, \
                        0, 0, 200, 400, hWnd, NULL, \
                        hInstance, \
                        NULL
        mov hTreeView, rax
        
        invoke ImageList_Create, 16, 16, ILC_COLOR16, 2, 10
        mov hImageList, rax
        
        invoke LoadBitmap, hInstance, IDB_TREE
        mov hBitmap, rax
        
        invoke ImageList_Add, hImageList, hBitmap, NULL
        invoke DeleteObject, hBitmap
        
        invoke SendMessage, hTreeView, TVM_INSERTITEM, 0, addr tvinsert
        mov tvinsert.hParent, NULL
        mov tvinsert.hInsertAfter, TVI_ROOT
        mov tvinsert.item.imask, TVIF_TEXT or TVIF_IMAGE or TVIF_SELECTEDIMAGE
        mov rdi, offset Parent
        mov tvinsert.item.pszText, rdi
        mov tvinsert.item.iImage, 0
        mov tvinsert.item.iSelectedImage, 1
        invoke SendMessage, hTreeView, TVM_INSERTITEM, 0, addr tvinsert
        mov hParent, rax
        mov tvinsert.hParent, rax
        mov rax, TVI_LAST
        mov tvinsert.hInsertAfter, rax
        mov rdi, offset Child1
        mov tvinsert.item.pszText, rdi
        
        invoke SendMessage, hTreeView, TVM_INSERTITEM, 0, addr tvinsert
        mov rdi, offset Child2
        mov tvinsert.item.pszText, rdi
        
        invoke SendMessage, hTreeView, TVM_INSERTITEM, 0, addr tvinsert
    .elseif uMsg==WM_MOUSEMOVE
        .if DragMode==TRUE
            mov rax, lParam
            and eax, 0FFFFh
            mov rcx, lParam
            shr rax, 16
            mov tvhit.pt.x, eax
            mov tvhit.pt.y, ecx
            invoke ImageList_DragMove, eax, ecx
            invoke ImageList_DragShowNolock, FALSE
            
            invoke SendMessage, hTreeView, TVM_HITTEST, NULL, addr tvhit
            .if rax{}NULL
                invoke SendMessage, hTreeView, TVM_SELECTITEM, TVGN_DROPHILITE, rax
            .endif
            invoke ImageList_DragShowNolock, TRUE
        .endif
    .elseif uMsg==WM_LBUTTONUP
        .if DragMode==TRUE
            invoke ImageList_DragLeave, hTreeView
            invoke ImageList_EndDrag
            invoke ImageList_Destroy, hDragImageList
            
            ; Get the currently hilited item
            invoke SendMessage, hTreeView, TVM_GETNEXTITEM, TVGN_DROPHILITE, 0
            invoke SendMessage, hTreeView, TVM_SELECTITEM, TVGN_CARET, rax
            invoke SendMessage, hTreeView, TVM_SELECTITEM, TVGN_DROPHILITE, 0
            mov DragMode, FALSE
        .endif
    .elseif uMsg==WM_NOTIFY
        mov rdi, lParam
        
        .if (NMTREEVIEW ptr [rdi]).hdr._code==TVN_BEGINDRAG
            mov rax, (NMTREEVIEW ptr [rdi]).itemNew.hItem
            invoke SendMessage, hTreeView, TVM_CREATEDRAGIMAGE, 0, rax
            mov hDragImageList, rax
            invoke ImageList_BeginDrag, hDragImageList, 0, 0, 0
            mov eax, (NMTREEVIEW ptr [rdi]).ptDrag.x
            mov posX, eax
            mov eax, (NMTREEVIEW ptr [rdi]).ptDrag.y
            mov posY, eax
            invoke ImageList_DragEnter, hTreeView, posX, posY
            invoke SetCapture, hWnd
            mov DragMode, TRUE
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
