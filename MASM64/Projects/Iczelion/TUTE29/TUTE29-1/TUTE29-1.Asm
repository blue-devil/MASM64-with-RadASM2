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
; | @date     : 10/08/2022                                                |
; | @license  : n/a                                                       |
; |_______________________________________________________________________|
; |                                                                       |
; |            Iczelion's Win32 Assembly Tutorials with MASM64            |
; |                 Tutorial 29 - Win64 Debug API Part 2                  |
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
    include \masm64\include64\comdlg32.inc

; _________________________________________________________________________
; libraries

    includelib \masm64\lib64\kernel32.lib
    includelib \masm64\lib64\user32.lib
    includelib \masm64\lib64\comdlg32.lib

; _________________________________________________________________________
; function prototypes

    WndProc             PROTO   :HWND,:UINT,:WPARAM,:LPARAM

; _________________________________________________________________________
; constant variables

.const

; _________________________________________________________________________
; initialized variables

.data
    ClassName           db "SimpleWin64Class", 0
    AppName             db "Win64 Debug Example no.2", 0
    SearchFail          db "Cannot find the target process", 0
    TargetPatched       db "Target patched!", 0
    ErrFmt              db "[-] Error suspending thread %016IX",0
    ErrCode             dd 0
    buffer              dw 9090h

; _________________________________________________________________________
; uninitialized variables

.data?
    CommandLine         LPSTR ?
    hInstance           HINSTANCE ?
    ProcessId           QWORD ?
    ThreadId            QWORD ?
    DBEvent             DEBUG_EVENT <>
    align 16            ; CONTEXT structure must be aligned
    context             CONTEXT <>

.code

WinMainCRTStartup proc
    
    LOCAL   errBuff[512]:BYTE
    
    invoke RtlZeroMemory, addr context, sizeof context

    invoke FindWindow, addr ClassName, NULL
    .if rax{}NULL
        invoke GetWindowThreadProcessId, rax, addr ProcessId
        mov ThreadId, rax
        
        invoke DebugActiveProcess, ProcessId
        .while TRUE
            invoke WaitForDebugEvent, addr DBEvent, INFINITE
            .if DBEvent.dwDebugEventCode==EXIT_PROCESS_DEBUG_EVENT
                .break
            .endif
                
            .if DBEvent.dwDebugEventCode==CREATE_PROCESS_DEBUG_EVENT
                mov context.ContextFlags, CONTEXT_CONTROL
                invoke GetThreadContext, DBEvent.CreateProcessInfo.hThread, addr context
                .if rax==0
                    mov rax, rv(GetLastError)
                    invoke wsprintf, addr errBuff, addr ErrFmt, rax
                    invoke MessageBox, NULL, addr errBuff, addr AppName, MB_OK
                    
                    mov eax, FALSE
                    ret 
                .endif
                
                invoke WriteProcessMemory, \
                            DBEvent.CreateProcessInfo.hProcess, \
                            context.Rip, addr buffer, 2, NULL
                invoke MessageBox, NULL, addr TargetPatched, addr AppName, MB_OK or MB_ICONINFORMATION
                
            .elseif DBEvent.dwDebugEventCode==EXCEPTION_DEBUG_EVENT
                .if DBEvent.Exception.ExceptionRecord.ExceptionCode==EXCEPTION_BREAKPOINT
                    invoke ContinueDebugEvent, DBEvent.dwProcessId, DBEvent.dwThreadId, DBG_CONTINUE
                    .continue
                .endif
                
            .endif
            invoke ContinueDebugEvent, DBEvent.dwProcessId, DBEvent.dwThreadId, DBG_EXCEPTION_NOT_HANDLED
        .endw
    .else
        invoke MessageBox, NULL, addr SearchFail, addr AppName, MB_OK or MB_ICONERROR
    .endif
    
    invoke  ExitProcess, 0

WinMainCRTStartup endp

end
