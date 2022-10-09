WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM

    LOCAL   nWidth:INT32
    LOCAL   nHeight:INT32
    
    .if uMsg==WM_COMMAND
        ;
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