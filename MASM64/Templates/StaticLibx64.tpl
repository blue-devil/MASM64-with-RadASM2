LIB64 Project
ArithLib
Static Lib x64 Template
[*BEGINPRO*]
[*BEGINDEF*]
[MakeDef]
Menu=0,1,1,1,0,0,0,0,1,0,0,0,0,0,0,0
1=4,O,$B\RC.EXE /v,1
2=3,O,$B\ML64.exe /c /nologo /W2 /I"$I",2
3=9,O,$B\LIB.EXE *.obj /out:"$9"
4=0,0,,5
5=rsrc.obj,O,$B\CVTRES.EXE,rsrc.res
6=*.obj,O,$B\ML64.exe /c /nologo /W2 /I"$I",*.asm
7=0,0,"$E\x64dbg.exe",5
[MakeFiles]
0=ArithLib.rap
1=ArithLib.rc
2=ArithLib.asm
3=ArithLib.obj
4=ArithLib.res
5=ArithLib.exe
6=ArithLib.def
7=ArithLib.dll
8=ArithLib.txt
9=ArithLib.lib
10=ArithLib.mak
11=ArithLib.hla
12=ArithLib.com
13=ArithLib.ocx
14=ArithLib.idl
15=ArithLib.tlb
16=ArithLib.sys
17=ArithLib.dp32
18=ArithLib.pdb
19=ArithLib.dp64
20=ArithLib.md
[Resource]
[StringTable]
[Accel]
[VerInf]
[Group]
Group=Assembly,Modules,Misc
1=1
1001=2
1002=2
2=3
[*ENDDEF*]
[*BEGINTXT*]
ArithLib.Inc
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

;  _______________________________________________________________________ 
; |                                                                       |
; | Arithmetic function prototypes                                        |
; \_______________________________________________________________________/

    _add             PROTO   :QWORD,:QWORD
    _sub             PROTO   :QWORD,:QWORD
    
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
echo " #    | |_____|   .|    |  .|    Date   : 13/10/2022                   #"
echo " #    |_____.:|   :|    |  :|    WEB    : github.com/blue-devil        #"
echo " #     _____|:|   :|__  |  :|                                          #"
echo " #    |    .::|   .:::| |  :|  --/   Freedom, doesn't come from   \--  #"
echo " #    |_______|_______| |___|  --\_     second-hand thoughts.    _/--  #"
echo " #                                                                     #"
echo " #######################################################################"

set appname=ArithLib

REM Substitute working folder
subst Y: "%cd%"
Y:

REM Delete compiled files if exists
if exist %appname%.lib del %appname%.lib
if exist %appname%.res del %appname%.res
if exist %appname%.obj del %appname%.obj

REM Compile resource file
REM \masm64\bin64\rc.exe /v %appname%.rc
REM If an object file needed from compiled resource uncomment the line below
REM \masm64\bin64\Cvtres.exe /machine:x64 OURAPPNAME.res

REM Assemble
C:\masm64\bin64\ml64.exe /c Mod\_add.asm
C:\masm64\bin64\ml64.exe /c Mod\_sub.asm

REM Compile object files into lib
C:\masm64\bin64\LIB.EXE *.obj /out:%appname%.lib

dir %appname%.lib

REM Delete virtual drive
C:
subst Y: /D


pause
[*ENDTXT*]
[*BEGINTXT*]
Mod\_add.asm
    OPTION DOTNAME
    OPTION CASEMAP:NONE
    
    OPTION PROLOGUE:NONE
    OPTION EPILOGUE:NONE
    
.code

_add proc a:QWORD,b:QWORD
    
    mov a, rcx
    mov b, rdx
    mov rax, a
    mov rbx, b

    add rax, rbx
    
    ret

_add endp

end
[*ENDTXT*]
[*BEGINTXT*]
Mod\_sub.asm
    OPTION DOTNAME
    OPTION CASEMAP:NONE
    
    OPTION PROLOGUE:NONE
    OPTION EPILOGUE:NONE
    
.code

_sub proc a:QWORD,b:QWORD
    
    mov a, rcx
    mov b, rdx
    mov rax, a
    mov rbx, b

    sub rax, rbx
    
    ret

_sub endp

end
[*ENDTXT*]
[*ENDPRO*]
