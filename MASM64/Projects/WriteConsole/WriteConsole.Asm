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
; | @date     : 05/12/2022                                                |
; | @license  : GPLv3                                                     |
; |_______________________________________________________________________|
; |                                                                       |
; |                MASM64 Programming Console Code Sniplet                |
; |                     WinAPI Examples: WriteConsole                     |
; \_______________________________________________________________________/


    OPTION DOTNAME                          ; required for macro files
    option casemap:none                     ; case sensitive

    include WriteConsole.Inc

.code

mainCRTStartup proc
    
    invoke  GetModuleHandle, NULL
    mov     hInstance, rax
    
    invoke  main
    invoke  ExitProcess,eax
    
    ret

mainCRTStartup endp

main proc
    
    invoke GetStdHandle,STD_OUTPUT_HANDLE
    mov hConsoleOutput, rax
    
    .if rax == INVALID_HANDLE_VALUE
        invoke GetLastError
        mov errCode, eax
    .else
        invoke WriteConsole,hConsoleOutput, addr hw, len_hw, NULL, NULL
    .endif
    
    waitkey

    .exit
    ret

main endp

end
