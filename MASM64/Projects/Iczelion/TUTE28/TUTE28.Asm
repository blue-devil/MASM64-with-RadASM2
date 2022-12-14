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
; | @date     : 22/08/2022                                                |
; | @license  : n/a                                                       |
; |_______________________________________________________________________|
; |                                                                       |
; |            Iczelion's Win32 Assembly Tutorials with MASM64            |
; |                 Tutorial 28 - Win64 Debug API Part 1                  |
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

    

; _________________________________________________________________________
; constant variables

.const

; _________________________________________________________________________
; initialized variables

.data
    AppName             db "Win64 Debug Example no.1", 0
    FilterString        db "Executable Files", 0,"*.exe", 0
                        db "All Files", 0,"*.*", 0, 0
    ExitProc            db "The debuggee exits", 0
    NewThread           db "A new thread is created", 0
    EndThread           db "A thread is destroyed", 0
    ProcessInfo         db "File Handle: %016IX ", 0Dh, 0Ah
                        db "Process Handle: %016IX", 0Dh, 0Ah
                        db "Thread Handle: %016IX", 0Dh, 0Ah
                        db "Image Base: %016IX", 0Dh, 0Ah
                        db "Start Address: %016IX", 0

    ofn                 OPENFILENAME <sizeof ofn,,,offset FilterString,,,,offset buffer,\
                        sizeof buffer,,,,,OFN_FILEMUSTEXIST or OFN_PATHMUSTEXIST or \
                        OFN_LONGNAMES or OFN_EXPLORER or OFN_HIDEREADONLY>

.data?
    buffer              db 512 dup(?)
    startinfo           STARTUPINFO <>
    pi                  PROCESS_INFORMATION <>
    DBEvent             DEBUG_EVENT <>


.code

WinMainCRTStartup proc

    invoke GetOpenFileName, addr ofn
    
    .if rax==TRUE
        invoke GetStartupInfo, addr startinfo
        invoke CreateProcess, addr buffer, \
                    NULL, NULL, NULL, FALSE, \
                    DEBUG_PROCESS or DEBUG_ONLY_THIS_PROCESS, \
                    NULL, NULL, addr startinfo, addr pi

        .while TRUE
            invoke WaitForDebugEvent, addr DBEvent, INFINITE
            
            .if DBEvent.dwDebugEventCode==EXIT_PROCESS_DEBUG_EVENT
                invoke MessageBox, NULL, addr ExitProc, addr AppName, MB_OK or MB_ICONINFORMATION
                .break
            
            .elseif DBEvent.dwDebugEventCode==CREATE_PROCESS_DEBUG_EVENT
                invoke wsprintf, addr buffer, addr ProcessInfo, \
                        DBEvent.CreateProcessInfo.hFile,\           ; image file handle
                        DBEvent.CreateProcessInfo.hProcess, \       ; process handle
                        DBEvent.CreateProcessInfo.hThread,\         ; thread handle
                        DBEvent.CreateProcessInfo.lpBaseOfImage, \  ; imagebase
                        DBEvent.CreateProcessInfo.lpStartAddress    ; entrypoint
                invoke MessageBox, NULL, addr buffer, addr AppName, MB_OK or MB_ICONINFORMATION
            
            .elseif DBEvent.dwDebugEventCode==EXCEPTION_DEBUG_EVENT
                .if DBEvent.Exception.ExceptionRecord.ExceptionCode==EXCEPTION_BREAKPOINT
                    invoke ContinueDebugEvent, DBEvent.dwProcessId, DBEvent.dwThreadId, DBG_CONTINUE
                    .continue
                .endif
                
            .elseif DBEvent.dwDebugEventCode==CREATE_THREAD_DEBUG_EVENT
                invoke MessageBox, NULL, addr NewThread, addr AppName,MB_OK or MB_ICONINFORMATION
            
            .elseif DBEvent.dwDebugEventCode==EXIT_THREAD_DEBUG_EVENT
                invoke MessageBox, NULL, addr EndThread, addr AppName,MB_OK or MB_ICONINFORMATION
            
            .endif
            invoke ContinueDebugEvent, DBEvent.dwProcessId, DBEvent.dwThreadId, DBG_EXCEPTION_NOT_HANDLED
        .endw
    .endif
    
    invoke CloseHandle, pi.hProcess
    invoke CloseHandle, pi.hThread
    
    invoke  ExitProcess, 0

WinMainCRTStartup endp

end
