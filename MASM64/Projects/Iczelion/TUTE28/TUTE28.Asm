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
; |           Iczelion's Win32 Assembly Tutorials with MASM64             |
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
; funtion prototypes

    

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
    fmtRegDump          db "rax",9,": %016IX", 0Dh, 0Ah
                        db "rbx",9,": %016IX", 0Dh, 0Ah
                        db "rcx",9,": %016IX", 0Dh, 0Ah
                        db "rdx",9,": %016IX", 0Dh, 0Ah
                        db "r8",9,": %016IX", 0Dh, 0Ah
                        db "r9",9,": %016IX", 0Dh, 0Ah
                        db "r10",9,": %016IX", 0Dh, 0Ah
                        db "r11",9,": %016IX", 0Dh, 0Ah
                        db "r12",9,": %016IX", 0Dh, 0Ah
                        db "r13",9,": %016IX", 0Dh, 0Ah
                        db "r14",9,": %016IX", 0Dh, 0Ah
                        db "r15",9,": %016IX", 0Dh, 0Ah,0
.data?
    buffer              db 512 dup(?)
    ofn                 OPENFILENAME <>
    startinfo           STARTUPINFO <>
    pi                  PROCESS_INFORMATION <>
    DBEvent             DEBUG_EVENT <>

.code

WinMainCRTStartup proc

    mov ofn.lStructSize, sizeof ofn
    lea rdi, FilterString
    mov ofn.lpstrFilter, rdi
    lea rdi, buffer
    mov ofn.lpstrFile, rdi
    mov ofn.nMaxFile, 512
    mov ofn.Flags, OFN_FILEMUSTEXIST or OFN_PATHMUSTEXIST or OFN_LONGNAMES or OFN_EXPLORER or OFN_HIDEREADONLY
    comment *
    mov eax, DBEvent.dwDebugEventCode
    lea rdx, DBEvent.dwDebugEventCode
    lea r8, DBEvent.dwProcessId
    lea r9, DBEvent.dwThreadId
    mov r8, offset [DBEvent + 0]
    mov r9, offset [DBEvent + 4]
    mov r10, offset [DBEvent + 8]
    mov r11, offset [DBEvent + 12]
    mov r12, qword ptr [DBEvent + 16]
    invoke wsprintf, addr buffer, addr fmtRegDump, rax, rbx, rcx, rdx, r8, r9, r10, r11
    invoke MessageBox, 0, addr buffer, addr AppName, MB_OK or MB_ICONINFORMATION
    *
    invoke GetOpenFileName, addr ofn
    
    .if rax==TRUE
        invoke GetStartupInfo, addr startinfo
        invoke CreateProcess, addr buffer, NULL, NULL, NULL, FALSE, DEBUG_PROCESS or DEBUG_ONLY_THIS_PROCESS, NULL, NULL, addr startinfo, addr pi
    
        ;lea rax, DBEvent
        .while TRUE
            invoke WaitForDebugEvent, addr DBEvent,  INFINITE
            
            .if DBEvent.dwDebugEventCode==EXIT_PROCESS_DEBUG_EVENT
                invoke MessageBox, 0, addr ExitProc, addr AppName, MB_OK or MB_ICONINFORMATION
                .break
            
            .elseif DBEvent.dwDebugEventCode==CREATE_PROCESS_DEBUG_EVENT
                mov r15, qword ptr [DBEvent + 16 + 48]      ; DBEvent.u.CreateProcessInfo.lpStartAddress
                mov r14, qword ptr [DBEvent + 16 + 24]      ; DBEvent.u.CreateProcessInfo.lpBaseOfImage
                mov r13, qword ptr [DBEvent + 16 + 16]      ; DBEvent.CreateProcessInfo.hThread
                mov r12, qword ptr [DBEvent + 16 + 8]       ; DBEvent.u.CreateProcessInfo.hProcess
                mov r11, qword ptr [DBEvent + 16]           ; DBEvent.CreateProcessInfo.hFile
                invoke wsprintf, addr buffer, addr ProcessInfo, r11, r12, r13, r14, r15
                ;invoke wsprintf, addr buffer, addr ProcessInfo, DBEvent.CreateProcessInfo.hFile,\
                ;       DBEvent.u.CreateProcessInfo.hProcess, DBEvent.CreateProcessInfo.hThread,\
                ;       DBEvent.u.CreateProcessInfo.lpBaseOfImage,DBEvent.u.CreateProcessInfo.lpStartAddress
                invoke MessageBox,0, addr buffer, addr AppName, MB_OK or MB_ICONINFORMATION
            
            .elseif DBEvent.dwDebugEventCode==EXCEPTION_DEBUG_EVENT
                mov r15, qword ptr [DBEvent + 16]           ; DBEvent.u.Exception.pExceptionRecord.ExceptionCode
                ;.if DBEvent.Exception.pExceptionRecord.ExceptionCode==EXCEPTION_BREAKPOINT
                .if r15==EXCEPTION_BREAKPOINT
                    invoke ContinueDebugEvent, DBEvent.dwProcessId,DBEvent.dwThreadId,DBG_CONTINUE
                    .continue
                .endif
                
            .elseif DBEvent.dwDebugEventCode==CREATE_THREAD_DEBUG_EVENT
                invoke MessageBox,0, addr NewThread, addr AppName,MB_OK or MB_ICONINFORMATION
            
            .elseif DBEvent.dwDebugEventCode==EXIT_THREAD_DEBUG_EVENT
                invoke MessageBox,0, addr EndThread, addr AppName,MB_OK or MB_ICONINFORMATION
            
            .endif
            invoke ContinueDebugEvent, DBEvent.dwProcessId, DBEvent.dwThreadId, DBG_EXCEPTION_NOT_HANDLED
        .endw
    .endif
    
    invoke CloseHandle, pi.hProcess
    invoke CloseHandle, pi.hThread
    
    invoke  ExitProcess, 0

WinMainCRTStartup endp

end