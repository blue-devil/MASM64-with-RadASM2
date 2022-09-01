Win64 App
DialogAsMain
Dialog As Main Window x64
[*BEGINPRO*]
[*BEGINDEF*]
[MakeDef]
Menu=1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0
1=4,O,$B\RC.EXE /v,1
2=3,O,$B\ML64.exe /c -Zp8 /D_WIN64 /Cp /nologo /W2 /I"$I",2
3=5,O,$B\LINK.EXE /SUBSYSTEM:WINDOWS /RELEASE /VERSION:4.0  /MACHINE:X64 /LIBPATH:"$L" /OUT:"$5",3,4
4=0,0,,5
5=rsrc.obj,O,$B\CVTRES.EXE,rsrc.res
6=*.obj,O,$B\ML64.exe /c -Zp8 /Zi /D_WIN64 /Cp /nologo /W2 /I"$I",*.asm
7=0,0,"$E\x64\x64dbg",5
11=4,O,$B\RC.EXE /v,1
12=3,O,$B\ML64.exe /c -Zp8 /Zi /D_WIN64 /Cp /nologo /W2 /Zi /Zd /nologo /I"$I",2
13=5,O,$B\LINK.EXE /SUBSYSTEM:WINDOWS /DEBUG /DEBUGTYPE:CV /PDB:$.pdb /VERSION:4.0 /MACHINE:X64 /LIBPATH:"$L" /OUT:"$5",3,4
14=0,0,,5
15=rsrc.obj,O,$B\CVTRES.EXE,rsrc.res
16=*.obj,O,$B\ML64.exe /c -Zp8 /Zi /D_WIN64 /Cp /nologo /W2  /I"$I",*.asm
17=0,0,"$E\x64\x64dbg",$.exe
[MakeFiles]
0=DialogAsMain.rap
1=DialogAsMain.rc
2=DialogAsMain.asm
3=DialogAsMain.obj
4=DialogAsMain.res
5=DialogAsMain.exe
6=DialogAsMain.def
7=DialogAsMain.dll
8=DialogAsMain.txt
9=DialogAsMain.lib
10=DialogAsMain.mak
11=DialogAsMain.hla
12=DialogAsMain.com
13=DialogAsMain.ocx
14=DialogAsMain.idl
15=DialogAsMain.tlb
16=DialogAsMain.sys
17=DialogAsMain.dp32
18=DialogAsMain.pdb
19=DialogAsMain.dp64
20=DialogAsMain.md
[Resource]
[StringTable]
[Accel]
[VerInf]
[Group]
Group=Assembly,Resources,Misc
1=1
2=1
3=2
4=2
5=2
[*ENDDEF*]
[*BEGINTXT*]
DialogAsMain.Asm
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
	xor		eax,eax
	ret

WndProc endp

end 
[*ENDTXT*]
[*BEGINTXT*]
DialogAsMain.Inc
; _____________________________________________________________________________
; MASM64 macros

    include \masm64\macros64\vasily.inc     ; main macro file
    include \masm64\macros64\macros64.inc   ; auxillary macro file

; _____________________________________________________________________________
; include files

    include \masm64\include64\win64.inc     ; main include file
    include \masm64\include64\kernel32.inc
    include \masm64\include64\user32.inc
    include \masm64\include64\comctl32.inc
    include \masm64\include64\shell32.inc
    include \masm64\include64\gdi32.inc
    STACKFRAME                              ; create a default stack frame
; _____________________________________________________________________________
; libraries

    includelib \masm64\lib64\user32.lib
    includelib \masm64\lib64\kernel32.lib
    includelib \masm64\lib64\comctl32.lib
    includelib \masm64\lib64\shell32.lib
    includelib \masm64\lib64\gdi32.lib

; _____________________________________________________________________________
; funtion prototypes

    WndProc			    PROTO	:HWND,:UINT,:WPARAM,:LPARAM
    
; _____________________________________________________________________________
; constant variables

.const
    ; Main Dialog
    IDD_DIALOG		    EQU 1000

    IDM_MENU            EQU 10000
    IDM_FILE_EXIT		equ 10001
    IDM_HELP_ABOUT		equ 10101

; _____________________________________________________________________________
; initialized variables

.data
    ClassName			db 'DLGCLASS',0
    AppName				db 'Dialog as main',0
    AboutMsg			db 'MASM64 RadASM Dialog as main',13,10,'BlueDeviL//SCT 2022',0

; _____________________________________________________________________________
; uninitialized variables

.data?
    CommandLine         LPSTR ?
    hInstance			HINSTANCE ?
    hCursor             HCURSOR ?
    hIcon               HICON ?
    
[*ENDTXT*]
[*BEGINTXT*]
DialogAsMain.Rc
#include "Res/DialogAsMainMnu.rc"
#include "Res/DialogAsMainDlg.rc"
[*ENDTXT*]
[*BEGINBIN*]
Res\DialogAsMain.dlg
6600000001000000444C47434C41535300000000000000000000000000000000
00000000000000005265735C4469616C6F6741734D61696E2E6D6E7500000000
00000000000000004D532053616E732053657269660000000000000000000000
000000000000000008000000F5FFFFFF00000000E90300000000000000000000
0000000000000000381B0AEE00009001880B070000000000A50A42008A0B0700
000000000008CF10000000000A0000000A0000002C010000C80000004469616C
6F67204173204D61696E00000000000000000000000000000000000000000000
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
[*BEGINBIN*]
Res\DialogAsMain.mnu
49444D5F4D454E55000000000000000000000000000000000000000000000000
10270000112764000100000000444D5F00000000000000000000000000000000
000000000000000000000000000000002646696C650000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000
0100000049444D5F46494C455F45584954000000000000000000000000000000
0000000011270000452678697400000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000
0000000000000000010000000000000000000000000000000100000000444D5F
0000000000000000000000000000000000000000000000000000000000000000
2648656C70000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000100000049444D5F48454C505F41424F
5554000000000000000000000000000000000000752700002641626F75740000
0000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000100000000000000
0000000000000000
[*ENDBIN*]
[*ENDPRO*]
[*BEGINTXT*]
Res\DialogAsMainDlg.rc
#define IDD_DIALOG 1000
IDD_DIALOG DIALOGEX 6,6,189,99
CAPTION "Dialog As Main"
FONT 8,"MS Sans Serif",400,0
CLASS "DLGCLASS"
STYLE 0x10CF0800
EXSTYLE 0x00000000
BEGIN
END
[*ENDTXT*]
[*BEGINTXT*]
Res\DialogAsMainMnu.Rc
#define IDM_MENU 10000
#define IDM_FILE_EXIT 10001
#define IDM_HELP_ABOUT 10101
IDM_MENU MENUEX
BEGIN
  POPUP "&File"
  BEGIN
    MENUITEM "E&xit",IDM_FILE_EXIT
  END
  POPUP "&Help"
  BEGIN
    MENUITEM "&About",IDM_HELP_ABOUT
  END
END
[*ENDTXT*]
