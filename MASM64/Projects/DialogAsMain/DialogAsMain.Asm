    OPTION DOTNAME                          ; required for macro files
    option casemap:none                     ; case sensitive

    include DialogAsMain.inc

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

WinMain proc hInst:HINSTANCE, hPrevInst:HINSTANCE, lpCmdLine:LPSTR, nCmdShow:DWORD

    LOCAL   wcex:WNDCLASSEX
    LOCAL   msg:MSG
    LOCAL   hWnd:HWND

    invoke  LoadIcon,hInst,IDI_APPLICATION
    mov     hIcon, rax
    invoke  LoadCursor,hInst,IDC_ARROW
    mov     hCursor, rax

    mov     wcex.cbSize, sizeof WNDCLASSEX
    mov     wcex.style, CS_HREDRAW or CS_VREDRAW
    lea     rdi, WndProc
    mov     wcex.lpfnWndProc, rdi;offset WndProc
    mov     wcex.cbClsExtra, 0
    mov     wcex.cbWndExtra, DLGWINDOWEXTRA
    mov     wcex.hInstance, 0;hInst
    mov     rax, hIcon
    mov     wcex.hIcon, rax;hIcon
    mov     rbx, hCursor
    mov     wcex.hCursor, rbx;hCursor
    mov     wcex.hbrBackground, COLOR_WINDOW + 1
    mov     wcex.lpszMenuName, IDM_MENU
    lea     rdi, ClassName
    mov     wcex.lpszClassName, rdi;offset ClassName
    mov     wcex.hIconSm, rax;hIcon
    invoke  RegisterClassEx, addr wcex

    invoke  CreateDialogParam,hInstance,IDD_DIALOG,NULL,addr WndProc,NULL
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

WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    
    .if uMsg==WM_INITDIALOG

    .elseif uMsg==WM_COMMAND
        mov rax,wParam
        .if rax==IDM_FILE_EXIT
            invoke  SendMessage,hWnd,WM_CLOSE,0,0
        .elseif rax==IDM_HELP_ABOUT
            invoke  ShellAbout,hWnd,addr AppName,addr AboutMsg,NULL
        .endif
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

WndProc endp

end
