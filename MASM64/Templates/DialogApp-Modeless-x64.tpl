Win64 App
DialogApp-Modeless-x64
DialogApp -Modeless- x64
[*BEGINPRO*]
[*BEGINDEF*]
[MakeDef]
Menu=1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0
1=4,O,$B\RC.EXE /v,1
2=3,O,$B\ML64.exe /c -Zp8 /D_WIN64 /Cp /nologo /W2 /I"$I",2
3=5,O,$B\LINK.EXE /SUBSYSTEM:WINDOWS /RELEASE /VERSION:4.0 /MACHINE:X64 /LIBPATH:"$L" /OUT:"$5",3,4
4=0,0,,5
5=rsrc.obj,O,$B\CVTRES.EXE,rsrc.res
6=*.obj,O,$B\ML64.exe /c -Zp8 /Zi /D_WIN64 /Cp /nologo /W2 /I"$I",*.asm
7=0,0,"$E\x64\x64dbg",5
[MakeFiles]
0=DialogApp-Modeless-x64.rap
1=DialogApp-Modeless-x64.rc
2=DialogApp-Modeless-x64.asm
3=DialogApp-Modeless-x64.obj
4=DialogApp-Modeless-x64.res
5=DialogApp-Modeless-x64.exe
6=DialogApp-Modeless-x64.def
7=DialogApp-Modeless-x64.dll
8=DialogApp-Modeless-x64.txt
9=DialogApp-Modeless-x64.lib
10=DialogApp-Modeless-x64.mak
11=DialogApp-Modeless-x64.hla
12=DialogApp-Modeless-x64.com
13=DialogApp-Modeless-x64.ocx
14=DialogApp-Modeless-x64.idl
15=DialogApp-Modeless-x64.tlb
16=DialogApp-Modeless-x64.sys
17=DialogApp-Modeless-x64.dp32
18=DialogApp-Modeless-x64.pdb
19=DialogApp-Modeless-x64.dp64
20=DialogApp-Modeless-x64.md
[Resource]
[StringTable]
[Accel]
[VerInf]
[Group]
Group=Assembly,Resources
1=1
2=1
3=2
4=2
[*ENDDEF*]
[*BEGINTXT*]
DialogApp-Modeless-x64.Asm
    OPTION DOTNAME                          ; required for macro files
    option casemap:none                     ; case sensitive

    include DialogApp-Modeless-x64.inc

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
    lea     rdi, DlgProc
    mov     wcex.lpfnWndProc, rdi;offset WndProc
    mov     wcex.cbClsExtra, 0
    mov     wcex.cbWndExtra, DLGWINDOWEXTRA
    mov     rdi, hInst
    mov     wcex.hInstance, rdi;hInst
    mov     rax, hIcon
    mov     wcex.hIcon, rax;hIcon
    mov     rbx, hCursor
    mov     wcex.hCursor, rbx;hCursor
    mov     wcex.hbrBackground, COLOR_WINDOW + 1
    mov     wcex.lpszMenuName, 0
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
[*ENDTXT*]
[*BEGINTXT*]
DialogApp-Modeless-x64.Inc
; _________________________________________________________________________
; MASM64 macros

    include \masm64\macros64\vasily.inc     ; main macro file
    include \masm64\macros64\macros64.inc   ; auxillary macro file

; _________________________________________________________________________
; include files

    include \masm64\include64\win64.inc     ; main include file
    include \masm64\include64\kernel32.inc
    include \masm64\include64\user32.inc
    include \masm64\include64\comctl32.inc
    include \masm64\include64\shell32.inc
    include \masm64\include64\gdi32.inc
    STACKFRAME                              ; create a default stack frame
; _________________________________________________________________________
; libraries

    includelib \masm64\lib64\user32.lib
    includelib \masm64\lib64\kernel32.lib
    includelib \masm64\lib64\comctl32.lib
    includelib \masm64\lib64\shell32.lib
    includelib \masm64\lib64\gdý32.lib

; _________________________________________________________________________
; funtion prototypes

    DlgProc             PROTO   :HWND,:UINT,:WPARAM,:LPARAM
    
; _________________________________________________________________________
; constant variables

.const
    ; Main Dialog
    IDD_DIALOG          EQU 1000

; _________________________________________________________________________
; initialized variables

.data
    ClassName           db 'DLGCLASS',0
    AppName             db 'Modeless Dialog App x64',0

; _________________________________________________________________________
; uninitialized variables

.data?
    CommandLine         LPSTR ?
    hInstance           HINSTANCE ?
    hCursor             HCURSOR ?
    hIcon               HICON ?
    
[*ENDTXT*]
[*BEGINTXT*]
DialogApp-Modeless-x64.Rc
#include "Res/DialogApp-Modeless-x64Dlg.rc"
[*ENDTXT*]
[*BEGINBIN*]
DialogApp-Modeless-x64.dlg
6600000001000000444C47434C41535300000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000
00000000000000004D532053616E732053657269660000000000000000000000
000000000000000008000000F5FFFFFF00000000E90300000000000000000000
0000000000000000BC220A4300009001CA0D110000000000A50A42007C100800
000000000000CF10000000000A0000000A0000002C010000C80000004944445F
444C470000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000E8030000494444
5F4449414C4F4700000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000
0000000000
[*ENDBIN*]
[*ENDPRO*]
[*BEGINTXT*]
Res\DialogApp-Modeless-x64Dlg.rc
#define IDD_DIALOG 1000
IDD_DIALOG DIALOGEX 6,6,189,99
CAPTION "IDD_DLG"
FONT 8,"MS Sans Serif",400,0
CLASS "DLGCLASS"
STYLE 0x10CF0000
EXSTYLE 0x00000000
BEGIN
END
[*ENDTXT*]
