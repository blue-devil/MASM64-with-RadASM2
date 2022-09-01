Win64 App
DialogApp-Modal-x64
DialogApp -Modal- x64
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
0=DialogApp-Modal-x64.rap
1=DialogApp-Modal-x64.rc
2=DialogApp-Modal-x64.asm
3=DialogApp-Modal-x64.obj
4=DialogApp-Modal-x64.res
5=DialogApp-Modal-x64.exe
6=DialogApp-Modal-x64.def
7=DialogApp-Modal-x64.dll
8=DialogApp-Modal-x64.txt
9=DialogApp-Modal-x64.lib
10=DialogApp-Modal-x64.mak
11=DialogApp-Modal-x64.hla
12=DialogApp-Modal-x64.com
13=DialogApp-Modal-x64.ocx
14=DialogApp-Modal-x64.idl
15=DialogApp-Modal-x64.tlb
16=DialogApp-Modal-x64.sys
17=DialogApp-Modal-x64.dp32
18=DialogApp-Modal-x64.pdb
19=DialogApp-Modal-x64.dp64
20=DialogApp-Modal-x64.md
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
DialogApp-Modal-x64.Asm
    OPTION DOTNAME                          ; required for macro files
    option casemap:none                     ; case sensitive

    include DialogApp-Modal-x64.inc
    
.code

WinMainCRTStartup proc 
    
    invoke  GetModuleHandleEx,0,0,hInstance
    .if(rax {} 0)
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
        ; code that runs before dialog shows up
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
[*ENDTXT*]
[*BEGINTXT*]
DialogApp-Modal-x64.Inc
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
    
    STACKFRAME                              ; create a default stack frame
; _________________________________________________________________________
; libraries
    includelib \masm64\lib64\user32.lib
    includelib \masm64\lib64\kernel32.lib
    includelib \masm64\lib64\comctl32.lib

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


; _________________________________________________________________________
; uninitialized variables

.data?
    CommandLine         LPSTR ?
    hInstance           HINSTANCE ?
    icc                 INITCOMMONCONTROLSEX <>
[*ENDTXT*]
[*BEGINTXT*]
DialogApp-Modal-x64.Rc
#include "Res/DialogApp-Modal-x64Dlg.rc"
[*ENDTXT*]
[*BEGINBIN*]
DialogApp-Modal-x64.dlg
6600000001000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000
00000000000000004D532053616E732053657269660000000000000000000000
000000000000000008000000F5FFFFFF00000000E90300000000000000000000
0000000000000000321B0ABB000090018805080000000000A50A42001A0C0B00
000000000000CF10000000000A0000000A0000002C010000C80000004944445F
444C470000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000E8030000494444
5F444C4731000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000
0000000000
[*ENDBIN*]
[*ENDPRO*]
[*BEGINTXT*]
Res\DialogApp-Modal-x64Dlg.rc
#define IDD_DLG1 1000
IDD_DLG1 DIALOGEX 6,6,189,99
CAPTION "IDD_DLG"
FONT 8,"MS Sans Serif",400,0
STYLE 0x10CF0000
EXSTYLE 0x00000000
BEGIN
END
[*ENDTXT*]
