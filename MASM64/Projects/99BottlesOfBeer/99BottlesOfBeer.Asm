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
; |                          MASM64 Programming                           |
; |                          99 Bottles of Beer                           |
; \_______________________________________________________________________/


    OPTION DOTNAME                          ; required for macro files
    option casemap:none                     ; case sensitive

    include 99BottlesOfBeer.Inc

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
    
    waitkey

    .exit
    ret

main endp

end
