Dll64 Project
DLLTest
DLL Scaffold Template
[*BEGINPRO*]
[*BEGINDEF*]
[MakeDef]
Menu=0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0
1=4,O,$B\RC.EXE /v,1
2=3,O,$B\ML64.exe /c /nologo /W2 /I"$I",2
3=7,O,$B\LINK.EXE /SUBSYSTEM:WINDOWS /RELEASE /DLL /DEF:$6 /ENTRY:DllMain /MACHINE:X64 /LIBPATH:"$L" /OUT:"$7",3
4=0,0,,5
5=rsrc.obj,O,$B\CVTRES.EXE,rsrc.res
6=*.obj,O,$B\ML64.exe /c /nologo /W2 /I"$I",*.asm
7=0,0,"$E\x64dbg.exe",5
11=4,O,$B\RC.EXE /v,1
12=3,O,$B\ML64.exe /c /Cp /nologo /W2 /Zi /Zd /nologo /I"$I",2
13=7,O,$B\LINK.EXE /SUBSYSTEM:WINDOWS /DEBUG /DEBUGTYPE:CV /PDB:"$18" /DLL /DEF:$6 /MACHINE:X64 /LIBPATH:"$L" /OUT:"$7",3
14=0,0,,5
15=rsrc.obj,O,$B\CVTRES.EXE,rsrc.res
16=*.obj,O,$B\ML64.exe /c /Zi /Zd /Cp /nologo /W2 /I"$I",*.asm
17=0,0,"$E\x64dbg.exe",$.exe
[MakeFiles]
0=DLLTest.rap
1=DLLTest.rc
2=DLLTest.asm
3=DLLTest.obj
4=DLLTest.res
5=DLLTest.exe
6=DLLTest.def
7=DLLTest.dll
8=DLLTest.txt
9=DLLTest.lib
10=DLLTest.mak
11=DLLTest.hla
12=DLLTest.com
13=DLLTest.ocx
14=DLLTest.idl
15=DLLTest.tlb
16=DLLTest.sys
17=DLLTest.dp32
18=DLLTest.pdb
19=DLLTest.dp64
20=DLLTest.md
[Resource]
[StringTable]
[Accel]
[VerInf]
[Group]
Group=Assembly,Misc
1=1
2=1
3=2
[*ENDDEF*]
[*BEGINTXT*]
DLLTest.Asm
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
; | @date     : 13/10/2022                                                |
; | @license  : GPLv3                                                     |
; |_______________________________________________________________________|
; |                                                                       |
; |                  MASM64 Programming DLL Code Sniplet                  |
; |                         DLL Test Code Sniplet                         |
; \_______________________________________________________________________/


    OPTION DOTNAME                          ; required for macro files
    option casemap:none                     ; case sensitive

    include DLLTest.inc

.code

DllMain proc hinstDLL:HINSTANCE, fdwReason:DWORD, lpReserved :DWORD

    .if fdwReason==DLL_PROCESS_ATTACH
        invoke MessageBox, NULL, addr LoadMsg, addr AppName, MB_OK
        
    .elseif fdwReason==DLL_PROCESS_DETACH
        invoke MessageBox, NULL, addr UnloadMsg, addr AppName, MB_OK
        
    .elseif fdwReason==DLL_THREAD_ATTACH
        invoke MessageBox, NULL, addr ThreadCreated, addr AppName, MB_OK
        
    .else; DLL_THREAD_DETACH
        invoke MessageBox, NULL, addr ThreadDestroyed, addr AppName, MB_OK
    .endif

    ret
DllMain endp

HelloWorld proc
    
    invoke MessageBox, NULL, addr HelloMsg, addr AppName, MB_OK
    
    ret

HelloWorld endp

end
[*ENDTXT*]
[*BEGINTXT*]
DLLTest.Inc
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

; _________________________________________________________________________
; libraries

    includelib \masm64\lib64\kernel32.lib
    includelib \masm64\lib64\user32.lib

; _________________________________________________________________________
; function prototypes

    HelloWorld          PROTO

; _________________________________________________________________________
; constant variables

.const

; _________________________________________________________________________
; initialized variables

.data
    AppName             db "[SCT] DLL Test x64", 0
    HelloMsg            db "Hello, world, I am a 64 bit DLL", 0
    LoadMsg             db "[+] x64 DLL is loaded", 0
    UnloadMsg           db "[+] x64 DLL is unloaded", 0
    ThreadCreated       db "[+] Thread created", 0
    ThreadDestroyed     db "[+] Thread destroyed", 0

; _________________________________________________________________________
; uninitialized variables

.data?
    
[*ENDTXT*]
[*BEGINTXT*]
DLLTest.Def
LIBRARY DLLTest
EXPORTS HelloWorld
[*ENDTXT*]
[*ENDPRO*]
