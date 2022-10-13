Empty BUILDwML64.bat
BatchProj
Win64 Console Project with BUILD Batch
[*BEGINPRO*]
[*BEGINDEF*]
[MakeDef]
Menu=0,0,0,1,1,1,1,0,0,0,0,0,0,0,0,0
1=0
2=0
3=5,O,BUILDwML64.bat
4=0,0,,5
5=0
6=0
7=0,0,"$E\x64dbg.exe",5
[MakeFiles]
0=BatchProj.rap
1=BatchProj.rc
2=BatchProj.asm
3=BatchProj.obj
4=BatchProj.res
5=BatchProj.exe
6=BatchProj.def
7=BatchProj.dll
8=BatchProj.txt
9=BatchProj.lib
10=BatchProj.mak
11=BatchProj.hla
12=BatchProj.com
13=BatchProj.ocx
14=BatchProj.idl
15=BatchProj.tlb
16=BatchProj.sys
17=BatchProj.dp32
18=BatchProj.pdb
19=BatchProj.dp64
20=BatchProj.md
[Resource]
[StringTable]
[Accel]
[VerInf]
[Group]
Group=Misc,Assembly
1=2
2=2
3=1
[*ENDDEF*]
[*BEGINTXT*]
BatchProj.Asm
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

    include BatchProj.Inc

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
BatchProj.Inc
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
[*BEGINTXT*]
BUILDwML64.bat
@echo off

REM Clean command prompt screen
cls

echo " #######################################################################"
echo " #                                                                     #"
echo " #   -=[                ASSEMBLE and LINK SCRIPT                ]=-    #"
echo " #     _______ _______ _______                                         #"
echo " #    |    ...|    ...|    ...|  Author : Blue DeviL                   #"
echo " #    |  _____|    .__|_   .._|  E-mail : bluedevil.SCT@gmail.com      #"
echo " #    | |_____|   .|    |  .|    Date   : 10/10/2022                   #"
echo " #    |_____.:|   :|    |  :|    WEB    : github.com/blue-devil        #"
echo " #     _____|:|   :|__  |  :|                                          #"
echo " #    |    .::|   .:::| |  :|  --/   Freedom, doesn't come from   \--  #"
echo " #    |_______|_______| |___|  --\_     second-hand thoughts.    _/--  #"
echo " #                                                                     #"
echo " #######################################################################"


set appname=BatchProj

REM Delete compiled files if exists
if exist %appname%.exe del %appname%.exe
if exist %appname%.res del %appname%.res
if exist %appname%.obj del %appname%.obj

REM Compile resource file
REM \masm64\bin64\rc.exe /v %appname%.rc
REM If an object file needed from compiled resource uncomment the line below
REM \masm64\bin64\Cvtres.exe /machine:x64 %appname%.res

REM Assemble
\masm64\bin64\ml64.exe /c %appname%.asm
REM Link
\masm64\bin64\link.exe /SUBSYSTEM:CONSOLE /LARGEADDRESSAWARE %appname%.obj

dir %appname%.exe

pause
[*ENDTXT*]
[*ENDPRO*]
