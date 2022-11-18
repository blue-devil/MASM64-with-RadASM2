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
; | @date     : 18/11/2022                                                |
; | @license  : GPLv3                                                     |
; |_______________________________________________________________________|
; |                                                                       |
; |                   Assembly Programming with MASM64                    |
; |                          99 Bottles of Beer                           |
; |                                                                       |
; | The source below have lots of MASM64 macros. I have left like this on |
; | purpose for the sake of MASM64 style.                                 |
; |                                                                       |
; | You need ML64.exe from a Visual Studio release and MASM64 SDK from    |
; | MASM32 forums.(https://masm32.com/board/index.php?topic=10052.0)      |
; |                                                                       |
; | Optional: I am using RadASM for assembly IDE, I have created MASM64   |
; | language files for RadASM. Check my github!                           |
; |                                                                       |
; | I hope you like it, cheers from Turkiye!                              |
; |                                                                       |
; | Assemble:                                                             |
; | --------                                                              |
; | \MASM64\bin64\ML64.EXE /c /nologo /W2 /I"\MASM64\include64"           |
; |                 "99BottlesOfBeer.asm"                                 |
; | Link:                                                                 |
; | ----                                                                  |
; | \MASM64\bin64\LINK.EXE /SUBSYSTEM:CONSOLE /RELEASE /ENTRY:main        |
; |                 /MACHINE:X64 /LIBPATH:"\MASM64\lib\x64"               |
; |                 /OUT:"99BottlesOfBeer.exe""99BottlesOfBeer.obj"       |
; \_______________________________________________________________________/


    OPTION DOTNAME                          ; required for macro files
    option casemap:none                     ; case sensitive

; _________________________________________________________________________
; MASM64 macros

    include \masm64\include64\win64.inc     ; main include file
    include \masm64\macros64\vasily.inc     ; main macro file
    include \masm64\macros64\macros64.inc   ; auxillary macro file

    STACKFRAME                              ; create a default stack frame

; _________________________________________________________________________
; include files

    include \masm64\m64lib\m64lib.inc       ; include file for m64lib library
    include \masm64\include64\msvcrt.inc

; _________________________________________________________________________
; libraries

    includelib \masm64\m64lib\m64lib.lib    ; m64lib library
    includelib \masm64\lib64\msvcrt.lib

; _________________________________________________________________________
; funtion prototypes

    externdef           printf  : near
    externdef           sprintf  : near

; _________________________________________________________________________
; initialized variables

.data
    sverse1 db "%s bottle%s of beer on the wall, %s bottle%s of beer.", 13, 10, 0
    sverse2 db "Take one down and pass it around, %s bottle%s of beer on the wall.", 13, 10, 13, 10, 0
    sverse3 db "Go to the store and buy some more, 99 bottles of beer on the wall.", 13, 10,  0
    nBeer   dq 99
    empty   db 0

; _________________________________________________________________________
; uninitialized variables

.data?
    sBeer1      db 3 dup(?)
    sBeer2      db 3 dup(?)

.code

main proc argc:DWORD,argv:LPSTR

    .while(nBeer {} -1)
        invoke sprintf, addr sBeer1,"%d", nBeer
        mov r15, nBeer
        dec r15
        invoke sprintf, addr sBeer2,"%d", r15
        .if nBeer == 2
            invoke printf, addr sverse1, addr sBeer1, "s", addr sBeer1, "s"
            invoke printf, addr sverse2, addr sBeer2, addr empty
            
        .elseif nBeer == 1
            invoke printf, addr sverse1, addr sBeer1, addr empty, addr sBeer1, addr empty
            invoke printf, addr sverse2, "no more", "s"
            
        .elseif nBeer == 0
            invoke printf, addr sverse1, "No more", "s", "no more", "s"
            invoke printf, addr sverse3
            
        .else
            invoke printf, addr sverse1, addr sBeer1, "s", addr sBeer1, "s"
            invoke printf, addr sverse2, addr sBeer2, "s"
        .endif

        
        sub nBeer,1
    .endw

    ret

main endp

end
