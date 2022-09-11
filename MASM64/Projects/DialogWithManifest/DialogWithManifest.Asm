    OPTION DOTNAME                          ; required for macro files
    option casemap:none                     ; case sensitive

    include DialogWithManifest.inc
    
.code

WinMainCRTStartup proc 
    
    invoke GetModuleHandle,0
    mov hInstance, rax
    .if(rax == 0)
        invoke  ExitProcess,NULL
    .endif
    
    invoke  GetCommandLine
    mov     CommandLine,rax
    
    invoke  InitCommonControls
    mov     icc.dwSize, sizeof INITCOMMONCONTROLSEX
    mov     icc.dwICC, ICC_COOL_CLASSES or ICC_STANDARD_CLASSES or ICC_WIN95_CLASSES
    invoke  InitCommonControlsEx, addr icc
    
    invoke  WinMain,hInstance, NULL, CommandLine, SW_SHOWDEFAULT
    invoke  ExitProcess,eax
    
    ret

WinMainCRTStartup endp

WinMain proc hInst:HINSTANCE, hPrevInstance:HINSTANCE, lpCmdLine:LPSTR, nCmdShow:DWORD

    invoke DialogBoxParam,hInst, IDD_DIALOG, 0, addr DlgProc, NULL
    invoke ExitProcess,NULL

WinMain endp

DlgProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM

    .if uMsg==WM_INITDIALOG
        invoke LoadIcon,hInstance, 5001
        invoke SendMessage,hWnd,WM_SETICON,ICON_SMALL,rax
        ret TRUE
    .elseif uMsg==WM_COMMAND
        ; code of controls, buttons, checkboxes...
    .elseif uMsg==WM_CLOSE
        invoke EndDialog,hWnd,0
        ret
    .else
        mov     eax,FALSE
        ret
    .endif
    mov     eax,TRUE
    ret

DlgProc endp

end

