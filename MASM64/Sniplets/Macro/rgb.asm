    ;
    ; RGB - This macro gets color value as integer put that info in eax
    ;
    ; Notes: Sample usage RGB(255,0,0)
    ;
    RGB macro red,green,blue
        xor rax,rax
        mov al,blue
        shl eax,16
        mov al,green
        shl ax,8
        mov al,red
    endm