    OPTION DOTNAME                          ; required for macro files
    option casemap:none                     ; case sensitive

    include DialogApp-Modeless-x64.inc

.code

WinMainCRTStartup proc

    invoke  GetModuleHandle, NULL
    mov hInstance, rax

    invoke  GetCommandLine
    mov     CommandLine, rax

    invoke  WinMain, hInstance, NULL, CommandLine, SW_SHOWDEFAULT
    invoke  ExitProcess,eax

    ret

WinMainCRTStartup endp

WinMain proc hInst:HINSTANCE, hPrevInst:HINSTANCE, lpCmdLine:LPSTR, nCmdShow:DWORD

    LOCAL   wcex:WNDCLASSEX
    LOCAL   msg:MSG
    LOCAL   hWnd:HWND

    invoke  LoadIcon, NULL, IDI_APPLICATION
    mov     hIcon, rax
    invoke  LoadCursor, NUL,IDC_ARROW
    mov     hCursor, rax

    mov     wcex.cbSize, sizeof WNDCLASSEX
    mov     wcex.style, CS_HREDRAW or CS_VREDRAW
    lea     rdi, DlgProc
    mov     wcex.lpfnWndProc, rdi;offset WndProc
    mov     wcex.cbClsExtra, NULL
    mov     wcex.cbWndExtra, DLGWINDOWEXTRA
    mov     rdi, hInst
    mov     wcex.hInstance, rdi;hInst
    mov     rax, hIcon
    mov     wcex.hIcon, rax;hIcon
    mov     rbx, hCursor
    mov     wcex.hCursor, rbx;hCursor
    mov     wcex.hbrBackground, COLOR_WINDOW + 1
    mov     wcex.lpszMenuName, NULL
    lea     rdi, ClassName
    mov     wcex.lpszClassName, rdi;offset ClassName
    mov     wcex.hIconSm, rax;hIcon
    invoke  RegisterClassEx, addr wcex

    invoke  CreateDialogParam,hInst,IDD_DIALOG,NULL,addr DlgProc,NULL
    mov     hWnd,rax
    
    invoke  ShowWindow,hWnd,SW_SHOWNORMAL
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

DlgProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    
    .if uMsg==WM_INITDIALOG

    .elseif uMsg==WM_COMMAND
        
    .elseif uMsg==WM_CLOSE
        invoke  DestroyWindow,hWnd
    .elseif uMsg==WM_DESTROY
        invoke  PostQuitMessage,NULL
    .else
        invoke  DefWindowProc,hWnd,uMsg,wParam,lParam
        ret
    .endif
    xor     eax,eax
    ret

DlgProc endp

end
