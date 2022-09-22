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
; |           Iczelion's Win32 Assembly Tutorials with MASM64             |
; |                      Tutorial 26 - Splash Screen                      |
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
; funtion prototypes

    WndProc             PROTO   :HWND,:UINT,:WPARAM,:LPARAM
    ShowBitmap          PROTO

; _________________________________________________________________________
; constant variables

.const

; _________________________________________________________________________
; initialized variables

.data
    BitmapName          db "MySplashBMP", 0
    ClassName           db "SplashWndx64Class", 0
    TimerID             dq 0
    hBitmap             HBITMAP 0

; _________________________________________________________________________
; uninitialized variables

.data?
    hInstance   HINSTANCE ?
    hIcon       HICON ?
    hCursor     HCURSOR ?

.code

DllMain proc hinstDLL:HINSTANCE, fdwReason:DWORD, lpReserved :DWORD

    .if fdwReason==DLL_PROCESS_ATTACH
        push    hinstDLL
        pop     hInstance
        call    ShowBitmap
    .endif

    mov eax, TRUE
    ret

DllMain endp

ShowBitmap proc
    
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
    mov     rax, hInstance
    mov     wcex.hInstance, rax
    mov     rax, hIcon
    mov     wcex.hIcon, rax
    mov     rbx, hCursor
    mov     wcex.hCursor, rbx
    mov     wcex.hbrBackground, COLOR_WINDOW + 1
    mov     wcex.lpszMenuName, NULL
    lea     rdi, ClassName
    mov     wcex.lpszClassName, rdi
    mov     wcex.hIconSm, 0
    invoke  RegisterClassEx, addr wcex
    
    invoke  CreateWindowEx, \
                    NULL, \
                    addr ClassName, \
                    NULL, \
                    WS_POPUP, \
                    CW_USEDEFAULT, \
                    CW_USEDEFAULT, \
                    320, \
                    400, \
                    NULL, \
                    NULL, \
                    hInstance, \
                    NULL
    mov     hWnd, rax
    
    invoke  ShowWindow, hWnd, SW_SHOWNORMAL
    
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

ShowBitmap endp

WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    
    LOCAL   ps:PAINTSTRUCT
    LOCAL   hdc:HDC
    LOCAL   hMemDC:HDC
    LOCAL   hOldBmp:QWORD
    LOCAL   bitmap:BITMAP
    LOCAL   DlgHeight:DWORD
    LOCAL   DlgWidth:DWORD
    LOCAL   posX:INT32
    LOCAL   posY:INT32
    LOCAL   DlgRect:RECT
    LOCAL   DesktopRect:RECT
    
    .if uMsg==WM_CREATE
        invoke GetWindowRect, hWnd, addr DlgRect
        invoke GetDesktopWindow
        mov rcx, rax
        invoke GetWindowRect, rcx, addr DesktopRect
        
        ;______________________________________________
        ; Make our window at the center of the screen
        mov eax, DlgRect.bottom
        sub eax, DlgRect.top
        mov DlgHeight, eax
        
        mov eax, DlgRect.right
        sub eax, DlgRect.left
        mov DlgWidth, eax
        
        mov eax, DesktopRect.bottom
        sub eax, DlgHeight
        shr eax, 1
        
        mov posY, eax
        mov eax, DesktopRect.right
        sub eax, DlgWidth
        shr eax, 1
        
        mov posX, eax
        invoke MoveWindow, hWnd, posX, posY, DlgWidth, DlgHeight, FALSE
        ;______________________________________________
        
        invoke LoadBitmap, hInstance, addr BitmapName
        mov hBitmap, rax
        
        invoke SetTimer, hWnd, 1, 2000, NULL
        mov TimerID, rax
        
    .elseif uMsg==WM_TIMER
        invoke SendMessage, hWnd, WM_LBUTTONDOWN, NULL, NULL
        invoke KillTimer, hWnd, TimerID
        
    .elseif uMsg==WM_PAINT
        invoke BeginPaint, hWnd, addr ps
        mov hdc, rax
        
        invoke CreateCompatibleDC, hdc
        mov hMemDC, rax
        
        invoke SelectObject, rax, hBitmap
        mov hOldBmp, rax
        
        invoke GetObject, hBitmap, sizeof BITMAP, addr bitmap
        invoke StretchBlt, hdc, 0, 0, 320, 400, hMemDC, 0, 0, bitmap.bmWidth, bitmap.bmHeight, SRCCOPY
        invoke SelectObject, hMemDC, hOldBmp
        
        invoke DeleteDC, hMemDC
        invoke EndPaint, hWnd, addr ps
    .elseif uMsg==WM_LBUTTONDOWN
        invoke DestroyWindow, hWnd
    .elseif uMsg==WM_DESTROY
        .if hBitmap {} 0
            invoke DeleteObject, hBitmap
        .endif
        invoke  PostQuitMessage, NULL
    .else
        invoke  DefWindowProc, hWnd, uMsg, wParam, lParam
        ret
    .endif
    xor eax, eax
    
    ret

WndProc endp

end
