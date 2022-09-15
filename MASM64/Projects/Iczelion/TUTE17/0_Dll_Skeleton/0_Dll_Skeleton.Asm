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
; | @date     : 13/09/2022                                                |
; | @license  : n/a                                                       |
; |_______________________________________________________________________|
; |                                                                       |
; |           Iczelion's Win32 Assembly Tutorials with MASM64             |
; |                 Tutorial 17 - Dynamic Link Libraries                  |
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

    include \masm64\include64\kernel32.inc
    include \masm64\include64\user32.inc

; _________________________________________________________________________
; libraries

    includelib \masm64\lib64\kernel32.lib
    includelib \masm64\lib64\user32.lib

; _________________________________________________________________________
; funtion prototypes

    TestHello           PROTO

; _________________________________________________________________________
; constant variables

.const

; _________________________________________________________________________
; initialized variables

.data
    AppName             db "x64 DLL Skeleton",0
    HelloMsg            db "Hello, you're calling a function in this 64bit DLL",0
    LoadMsg             db "The x64 DLL is loaded",0
    UnloadMsg           db "The x64 DLL is unloaded",0
    ThreadCreated       db "A thread is created in this process",0
    ThreadDestroyed     db "A thread is destroyed in this process",0

; _________________________________________________________________________
; uninitialized variables

.data?
    

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

TestHello proc
    
    invoke MessageBox, NULL, addr HelloMsg, addr AppName, MB_OK
    
    ret

TestHello endp

end
