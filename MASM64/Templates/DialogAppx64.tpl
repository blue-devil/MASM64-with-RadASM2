Win64 App
DialogAppx64
Dialog App x64
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
0=DialogAppx64.rap
1=DialogAppx64.rc
2=DialogAppx64.asm
3=DialogAppx64.obj
4=DialogAppx64.res
5=DialogAppx64.exe
6=DialogAppx64.def
7=DialogAppx64.dll
8=DialogAppx64.txt
9=DialogAppx64.lib
10=DialogAppx64.mak
11=DialogAppx64.hla
12=DialogAppx64.com
13=DialogAppx64.ocx
14=DialogAppx64.idl
15=DialogAppx64.tlb
16=DialogAppx64.sys
17=DialogAppx64.dp32
18=DialogAppx64.pdb
19=DialogAppx64.dp64
20=DialogAppx64.md
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
[*ENDDEF*]
[*BEGINTXT*]
DialogAppx64.Asm
    OPTION DOTNAME                          ; required for macro files
    option casemap:none                     ; case sensitive

    include DialogAppx64.inc

.code

WinMainCRTStartup proc hInstance:HINSTANCE, hPrevInstance:HINSTANCE, lpCmdLine:LPSTR, nCmdShow:DWORD

    invoke InitCommonControls
    invoke DialogBoxParam,hInstance, IDD_DIALOG, 0, addr DlgProc, NULL

    invoke ExitProcess,NULL

WinMainCRTStartup endp

STACKFRAME                                  ; create a default stack frame
DlgProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    
    .if uMsg==WM_INITDIALOG
        
    .elseif uMsg==WM_COMMAND
        
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
DialogAppx64.Inc
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
    ;STACKFRAME                              ; create a default stack frame
; _________________________________________________________________________
; libraries
    includelib \masm64\lib64\user32.lib
    includelib \masm64\lib64\kernel32.lib
    includelib \masm64\lib64\comctl32.lib

; _________________________________________________________________________
; funtion prototypes

    DlgProc         PROTO   :HWND,:UINT,:WPARAM,:LPARAM
    
; _________________________________________________________________________
; constant variables
.const
    ; Main Dialog
    IDD_DIALOG      EQU 1000

; _________________________________________________________________________
; initialized variables
.data


; _________________________________________________________________________
; uninitialized variables
.data?
[*ENDTXT*]
[*BEGINTXT*]
DialogAppx64.Rc
#include "Res/DialogAppx64Dlg.rc"
[*ENDTXT*]
[*BEGINBIN*]
Res\DialogAppx64.dlg
6600000001000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000
00000000000000004D532053616E732053657269660000000000000000000000
000000000000000008000000F5FFFFFF00000000E90300000000000000000000
0000000000000000D41A0AEC00009001F80B040000000000A50A42000E0C0600
000000000000CF10000000000A0000000A0000002C010000C80000000044445F
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
Res\DialogAppx64Dlg.rc
#define IDD_DIALOG 1000
IDD_DIALOG DIALOGEX 6,6,189,99
FONT 8,"MS Sans Serif",400,0
STYLE 0x10CF0000
EXSTYLE 0x00000000
BEGIN
END
[*ENDTXT*]
