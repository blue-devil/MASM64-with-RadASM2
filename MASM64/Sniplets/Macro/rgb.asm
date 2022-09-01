    RGB macro red,green,blue
        xor rax,rax
        mov al,blue
        shl eax,16
        mov al,green
        shl ax,8
        mov al,red
    endm