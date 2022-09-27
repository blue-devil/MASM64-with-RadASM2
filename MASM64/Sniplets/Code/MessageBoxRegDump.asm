    fmtRegDump          db "rax",9,": %016IX", 0Dh, 0Ah
                        db "rbx",9,": %016IX", 0Dh, 0Ah
                        db "rcx",9,": %016IX", 0Dh, 0Ah
                        db "rdx",9,": %016IX", 0Dh, 0Ah
                        db "rsi",9,": %016IX", 0Dh, 0Ah
                        db "rdi",9,": %016IX", 0Dh, 0Ah
                        db "rbp",9,": %016IX", 0Dh, 0Ah
                        db "rsp",9,": %016IX", 0Dh, 0Ah
                        db "r8",9,": %016IX", 0Dh, 0Ah
                        db "r9",9,": %016IX", 0Dh, 0Ah
                        db "r10",9,": %016IX", 0Dh, 0Ah
                        db "r11",9,": %016IX", 0Dh, 0Ah
                        db "r12",9,": %016IX", 0Dh, 0Ah
                        db "r13",9,": %016IX", 0Dh, 0Ah
                        db "r14",9,": %016IX", 0Dh, 0Ah
                        db "r15",9,": %016IX", 0Dh, 0Ah
                        db "Intel x64 registers",0

    invoke wsprintf, addr buffer, addr fmtRegDump, \
                rax, rbx, rcx, rdx, rsi, rdi, rbp, rsp, \
                r8, r9, r10, r11, r12, r13, r14, r15
    invoke MessageBox, 0, addr deneme, addr AppName, MB_OK or MB_ICONINFORMATION