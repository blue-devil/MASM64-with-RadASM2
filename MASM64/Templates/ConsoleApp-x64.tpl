Console64 App
ConsoleTest
Win64 Console Project
[*BEGINPRO*]
[*BEGINDEF*]
[MakeDef]
Menu=0,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0
1=4,O,$B\RC.EXE /v,1
2=3,O,$B\ML64.EXE /c /nologo /W2 /I"$I",2
3=5,O,$B\LINK.EXE /SUBSYSTEM:CONSOLE /RELEASE /MACHINE:X64 /LIBPATH:"$L" /OUT:"$5",3
4=0,0,,5
5=rsrc.obj,O,$B\CVTRES.EXE,rsrc.res
6=*.obj,O,$B\ML64.EXE /c /nologo /W2 /I"$I",*.asm
7=0,0,"$E\x64dbg.exe",5
[MakeFiles]
0=ConsoleTest.rap
1=ConsoleTest.rc
2=ConsoleTest.asm
3=ConsoleTest.obj
4=ConsoleTest.res
5=ConsoleTest.exe
6=ConsoleTest.def
7=ConsoleTest.dll
8=ConsoleTest.txt
9=ConsoleTest.lib
10=ConsoleTest.mak
11=ConsoleTest.hla
12=ConsoleTest.com
13=ConsoleTest.ocx
14=ConsoleTest.idl
15=ConsoleTest.tlb
16=ConsoleTest.sys
17=ConsoleTest.dp32
18=ConsoleTest.pdb
19=ConsoleTest.dp64
20=ConsoleTest.md
[Resource]
[StringTable]
[Accel]
[VerInf]
[Group]
Group=Assembly
1=1
2=1
[*ENDDEF*]
[*BEGINTXT*]
ConsoleTest.Asm
;  _______________________________________________________________________
; |  ______ __          ,.'   __.'.__  .   ______               ___       |
; | |      |  |         /b`  '-.   .-'  d\|      ;             |   |      |
; | |   __ |  |        .5h     /.'.\    =5|   _   \            |   |      |
; | |.  1 \|  |        (0=h    '   '    =C)   1\   \        .--:.  |      |
; | |   1_/|  |        ?3==,          .==7|   | \   \       |__|   |      |
; | |.     | .-- -.-----{=`==oo____oo==`=}|   |  |.----.-- -.--:.  |      |
; | |.  __ | |  V |  ^__|'"o58888888888,; |.  |  ||  ^_|  V |  |.  |      |
; | |:  1 \|_|____|_____| `?88P^\,?88^\P  |.  | / |____|\___|__|:  |___   |
; | |:  1_/   /            C8?\__d88\_/'  |:  1/   / .         |:  1   |  |
; | |::.. .  /             `8o8888/\88P   |::.. . /            |::.. . |  |
; | `-------'               '7oo88oo8P    `------'             `-------'  |
; |                     Cooo##~\/\/\/~====>        github.com/blue-devil  |
; |                                                 gitlab.com/bluedevil  |
; | Freedom doesn't come from second-hand thoughts.      www.sctzine.com  |
; |_______________________________________________________________________|
; | @author   : Blue DeviL <bluedevil@sctzine.com>                        |
; | @tester   : ErrorInside <errorinside@sctzine.com>                     |
; | @IDE      : RadASM v2.2.2.4                                           |
; | @template : Blue DeviL                                                |
; | @date     : 13/10/2022                                                |
; | @license  : GPLv3                                                     |
; |_______________________________________________________________________|
; |                                                                       |
; |                MASM64 Programming Console Code Sniplet                |
; |                 Console Code Sniplet with BUILD Batch                 |
; \_______________________________________________________________________/


    OPTION DOTNAME                          ; required for macro files
    option casemap:none                     ; case sensitive

    include ConsoleTest.Inc

.code

mainCRTStartup proc
    
    invoke  GetModuleHandle, NULL
    mov     hInstance, rax
    
    invoke  GetCommandLineW
    mov     CommandLine,rax
    
    invoke  CommandLineToArgvW, CommandLine, addr NumArgs
    
    invoke  main, NumArgs, CommandLine
    invoke  ExitProcess,eax
    
    ret

mainCRTStartup endp

main proc argc:DWORD,argv:LPSTR
    
    conout "Freedom doesn't come from second-hand thoughts.",lf,lf
    invoke printf, addr fmt, addr msg
    
    lea rdi, argv[0]
    mov rax, [rdi]
    invoke  vc_printf,"Argv: %ls%sArgc: %d%s%s",rax,lf,argc,lf,lf
    
    invoke StdOut, addr msg
    conout nl
    
    invoke printf, addr fmt, addr msg
    
    conout hex$(rax),nl
    
    waitkey

    .exit
    ret

main endp

end
[*ENDTXT*]
[*BEGINTXT*]
ConsoleTest.Inc
; _________________________________________________________________________
; MASM64 macros
;include \masm64\include64\masm64rt.inc
    include \masm64\include64\win64.inc     ; main include file
    include \masm64\macros64\vasily.inc     ; main macro file
    include \masm64\macros64\macros64.inc   ; auxillary macro file

    STACKFRAME                              ; create a default stack frame

; _________________________________________________________________________
; include files

    include \masm64\m64lib\m64lib.inc       ; include file for m64lib library
    include \masm64\include64\kernel32.inc
    include \masm64\include64\user32.inc
    include \masm64\include64\shell32.inc
    include \masm64\include64\msvcrt.inc

; _________________________________________________________________________
; libraries

    includelib \masm64\m64lib\m64lib.lib    ; m64lib library
    includelib \masm64\lib64\kernel32.lib
    includelib \masm64\lib64\user32.lib
    includelib \masm64\lib64\shell32.lib
    includelib \masm64\lib64\msvcrt.lib

; _________________________________________________________________________
; funtion prototypes

    externdef           printf  : near
    externdef           _kbhit  : near
    externdef           exit    : near
    main                PROTO   :DWORD,:LPSTR

; _________________________________________________________________________
; constant variables

.const
    

; _________________________________________________________________________
; initialized variables

.data
    msg         db "Freedom doesn't come from second-hand thoughts.", 0
    fmt         db "%s", 13, 10, 0

; _________________________________________________________________________
; uninitialized variables

.data?
    CommandLine LPSTR ?
    hInstance   HINSTANCE ?
    NumArgs     DWORD ?
[*ENDTXT*]
[*ENDPRO*]
