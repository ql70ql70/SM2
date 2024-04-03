.data

div3data QWORD 00000000000000000h, 05555555555555555h, 0aaaaaaaaaaaaaaaah

.code

asm_k_to_k_wmbNAF_pre proc EXPORT FRAME
    .endprolog

    push rbx
    push rsi
    push rdi
    push rbp
    push r12
    push r13
    push r14
    push r15

    push rdx

    xor rdi,rdi

    mov r8,[rcx]
    mov r9,[rcx+8]
    mov r10,[rcx+16]
    mov r11,[rcx+24]

    mov rbp,rdx

    test_r11:

    test r11,r11

    jz right_shift_64
    
    check_2exp:

    ;这里检查k的奇偶性，奇数时跳转检查是否被3整除。
    tzcnt rcx,r11

    jz check_3exp

    shrd r11,r10,cl
    shrd r10,r9,cl
    shrd r9,r8,cl
    shr r8,cl

    shl rcx,1

    mov byte ptr[rbp],cl
    inc rbp

    check_3exp:

    xor rdx,rdx;高位清零
    mov rsi, 0AAAAAAAAAAAAAAABh
    mov rax,rsi
    mov rcx,r8
    mul rcx;rcx=input[0]
    shr rdx,1;rdx=input[0]/3
    mov r12,rdx;result[0]=rdx
    mov rax,rdx
    add rax,rax
    add rax,rdx
    sub rcx,rax
    mov rbx,rcx;rbx=-result[0]%3
    
    mov rcx,r9;rcx=input[1]
    mov rax,rsi
    mul rcx
    shr rdx,1;rdx=input[1]/3
    add rdx,qword ptr div3data[8*rbx];rdx=input[1]/3+div3data[mod]
    mov rax,rdx
    add rax,rax
    add rax,rdx
    sub rcx,rax
    mov rbx,rcx
    cmp rbx,3
    jb next1
    sub rbx,3
    add rdx,1
next1:
    mov r13,rdx;result[1]=rax

    mov rcx,r10;rcx=input[1]
    mov rax,rsi
    mul rcx
    shr rdx,1;rdx=input[1]/3
    add rdx,qword ptr div3data[8*rbx];rdx=input[1]/3+div3data[mod]
    mov rax,rdx
    add rax,rax
    add rax,rdx
    sub rcx,rax
    mov rbx,rcx
    cmp rbx,3
    jb next2
    sub rbx,3
    add rdx,1
next2:
    mov r14,rdx;result[1]=rax

    mov rcx,r11;rcx=input[1]
    mov rax,rsi
    mul rcx
    shr rdx,1;rdx=input[1]/3
    add rdx,qword ptr div3data[8*rbx];rdx=input[1]/3+div3data[mod]
    mov rax,rdx
    add rax,rax
    add rax,rdx
    sub rcx,rax
    mov rbx,rcx
    cmp rbx,3
    jb next3
    sub rbx,3
    add rdx,1
next3:
    ;mov r15,rdx;result[1]=rax

    test rbx,rbx

    jnz mod_32

    ;mov r11,r15
    mov r11,rdx
    mov r10,r14
    mov r9,r13
    mov r8,r12
    
    mov byte ptr[rbp],0
    inc rbp

    jmp check_3exp

    mod_32:

    mov rcx,r11
    and rcx,31

    shrd r11,r10,5
    shrd r10,r9,5
    shrd r9,r8,5
    shr r8,5

    mov byte ptr[rbp],cl
    inc rbp
    cmp cl,16
    jnc k_add_1

    test r11,r11
    jnz check_2exp
    test r10,r10
    jnz right_shift_64
    test r9,r9
    jnz right_shift_128
    test r8,r8
    jnz right_shift_192

    pop rdx

    mov rax,rbp
    sub rax,rdx
    dec rax
    
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    pop rdi
    pop rsi
    pop rbx

    ret
    right_shift_192:

    mov byte ptr[rbp],128
    inc rbp

    mov r11,r10
    mov r10,r9
    mov r9,r8
    xor r8,r8

    right_shift_128:

    mov byte ptr[rbp],128
    inc rbp

    mov r11,r10
    mov r10,r9
    mov r9,r8
    xor r8,r8

    right_shift_64:

    mov byte ptr[rbp],128
    inc rbp

    mov r11,r10
    mov r10,r9
    mov r9,r8
    xor r8,r8

    jmp test_r11

    k_add_1:
    add r11,1
    adcx r10,rdi
    adcx r9,rdi
    adcx r8,rdi
    jmp test_r11
asm_k_to_k_wmbNAF_pre endp

;大数输入为rax,rbx,rsi,rdi，输出模乘结果到r8,r9,r10,r11。使用了全部16个寄存器。
;大数直接先乘，再模。使用了mulx，adcx，利用mulx不改变CF位的特性，修改了最终减p的判定，针对sm2的参考质数做优化，平方
_sm2_naked_sqr proc EXPORT FRAME
    .endprolog

    mov rdx,rdi

    mulx r13,r14,rsi
    mulx r12,rcx,rbx
    add r13,rcx
    mulx r11,rbp,rax
    adcx r12,rbp

    mov rdx,rax
    mulx r10,rcx,rsi
    adcx r11,rcx
    mulx r9,rbp,rbx
    adcx r10,rbp
    adc r9,0

    xor r8,r8
    mov rdx,rbx
    mulx rbp,rcx,rsi
    add r12,rcx
    adcx r11,rbp
    adc r10,0
    adc r9,0

    shl r14,1
    rcl r13,1
    rcl r12,1
    rcl r11,1
    rcl r10,1
    rcl r9,1
    rcl r8,1

    mov rdx,rdi
    mulx rbp,r15,rdx
    add r14,rbp

    mov rdx,rsi
    mulx rbp,rcx,rdx
    adcx r13,rcx
    adcx r12,rbp

    mov rdx,rbx
    mulx rbp,rcx,rdx
    adcx r11,rcx
    adcx r10,rbp

    mov rdx,rax
    mulx rbp,rcx,rdx
    adcx r9,rcx
    adcx r8,rbp

    ;r8,r9,r10,r11,r12,r13,r14,r15
    ;
    xor rbp,rbp

    mov rdx,r15
    mov rcx,r15

    add r14,r15
    adc r13,0
    adc r12,0
    adcx r11,r15
    adc r10,0
    adc r9,0
    adc r8,0
    adc rbp,0
    shl rdx,32
    shr rcx,32
    sub r14,rdx
    sbb r13,rcx
    sbb r12,rdx
    sbb r11,rcx
    sbb r10,0
    sbb r9,0
    sbb r8,0
    sbb rbp,0


    mov rdx,r14
    mov rcx,r14

    add r13,r14
    adc r12,0
    adc r11,0
    adcx r10,r14
    adc r9,0
    adc r8,0
    adc rbp,0
    shl rdx,32
    shr rcx,32
    sub r13,rdx
    sbb r12,rcx
    sbb r11,rdx
    sbb r10,rcx
    sbb r9,0
    sbb r8,0
    sbb rbp,0

    
    mov rdx,r13
    mov rcx,r13

    add r12,r13
    adc r11,0
    adc r10,0
    adcx r9,r13
    adc r8,0
    adc rbp,0
    shl rdx,32
    shr rcx,32
    sub r12,rdx
    sbb r11,rcx
    sbb r10,rdx
    sbb r9,rcx
    sbb r8,0
    sbb rbp,0


    mov rdx,r12
    mov rcx,r12

    add r11,r12
    adc r10,0
    adc r9,0
    adcx r8,r12
    adc rbp,0
    shl rdx,32
    shr rcx,32
    sub r11,rdx
    sbb r10,rcx
    sbb r9,rdx
    sbb r8,rcx
    sbb rbp,0

    ;mov rdx,r12
    ;xor r12,r12

    ;add r11,r15
    ;adcx r10,r14
    mov r15,r11
    ;adcx r9,r13
    mov r14,r10
    ;adcx r8,r12

    sub r11,0FFFFFFFFFFFFFFFFh
    mov rdx,0FFFFFFFF00000000h
    sbb r10,rdx
    mov r13,r9
    sbb r9,0FFFFFFFFFFFFFFFFh
    mov rdx,0FFFFFFFEFFFFFFFFh
    mov r12,r8
    sbb r8,rdx
    sbb rbp,0

    cmovc r11,r15
    cmovc r10,r14
    cmovc r9,r13
    cmovc r8,r12

    ret
_sm2_naked_sqr endp

;star;大数a在[[rsp+16+8][rsp+16+16][rsp+16+24][rsp+16+32]]，大数b输入为rax,rbx,rsi,rdi，输出模乘结果到r8,r9,r10,r11。使用了除rcx之外的15个寄存器。
_sm2_naked_mul_stack proc EXPORT FRAME
    .endprolog

    ;mov rax,[rdx]
    ;mov rbx,[rdx+8]
    ;mov rsi,[rdx+16]
    ;mov rdi,[rdx+24]

    xor rcx,rcx
    xor r10,r10 ;t5必然是0
    ;vpextrq rdx,xmm1,1 ;把a0放到rdx
    mov rdx,[rsp+16+32]

    mulx r15,r9,rdi ;a0乘以b0，低位给t0，高位给c

    mulx rbp,r8,rsi ;a0乘以b1，低位给t1，高位给rbp
    adcx r8,r15 ;低位加c更新t1

    mulx r14,r12,rbx ;a0乘以b2，低位给t2，高位给r14
    adox r8,r9
    adcx r12,rbp ;低位加c更新t2

    mulx r11,r13,rax ;a0乘以b3，低位给t3，高位给t4
    adox r12,rcx
    adcx r13,r14 ;低位加c更新t3
    adcx r11,rcx ;高位带进位加0来更新t4
    adox r13,rcx
    adox r11,r9
    adox r10,rcx

    ;

    mov rdx,r9 ;把t0放到rdx

    shr r9,32
    shl rdx,32

    sub r8,rdx
    sbb r12,r9
    sbb r13,rdx
    sbb r11,r9
    sbb r10,rcx

    ;数组t进行一组轮换
    
    ;vmovq rdx,xmm1 ;把a1放到rdx
    mov rdx,[rsp+16+24]
    xor r9,r9 ;t5清零

    mulx r15,rbp,rdi ;a1乘以b0，低位给rbp，高位给r15
    add r8,rbp ;低位加t0更新t0

    mulx r14,rbp,rsi ;a1乘以b1，低位给rbp，高位给r14
    adcx rbp,r15 ;低位加c
    adcx r14,rcx ;高位带进位加0
    adcx rbp,r12 ;低位加t1
    mov r12,rbp ;低位给t1

    mulx r15,rbp,rbx ;a1乘以b2，低位给rbp，高位给r15
    adcx rbp,r14 ;低位加c
    adcx r15,rcx ;高位带进位加0
    adcx rbp,r13 ;低位加t2
    mov r13,rbp ;低位给t2

    mulx r14,rbp,rax ;a1乘以b3，低位给rbp，高位给r14
    adcx rbp,r15 ;低位加c
    adcx r14,rcx ;高位带进位加0
    adcx rbp,r11 ;低位加t3
    mov r11,rbp ;低位给t3

    ;xor r9,r9 ;t5清零
    adcx r10,r14 ;高位加t4更新t4
    adcx r9,rcx ;t5带进位加0
    
    ;

    mov rdx,r8 ;把t0放到rdx

    add r12,r8
    adcx r13,rcx
    adcx r11,rcx
    adcx r10,r8
    adcx r9,rcx

    shr r8,32
    shl rdx,32

    sub r12,rdx
    sbb r13,r8
    sbb r11,rdx
    sbb r10,r8
    sbb r9,rcx

    ;数组t进行一组轮换
    
    ;vpextrq rdx,xmm0,1 ;把a2放到rdx
    mov rdx,[rsp+16+16]
    xor r8,r8 ;t5清零

    mulx r15,rbp,rdi ;a2乘以b0，低位给rbp，高位给c
    add r12,rbp ;低位加t0更新t0

    mulx r14,rbp,rsi ;a2乘以b1，低位给rbp，高位给r14
    adcx rbp,r15 ;低位加c
    adcx r14,rcx ;高位带进位加0
    add rbp,r13 ;低位加t1
    mov r13,rbp ;低位给t1

    mulx r15,rbp,rbx ;a2乘以b2，低位给rbp，高位给r14
    adcx rbp,r14 ;低位加c
    adcx r15,rcx ;高位带进位加0
    add rbp,r11 ;低位加t2
    mov r11,rbp ;低位给t2

    mulx r14,rbp,rax ;a2乘以b3，低位给rbp，高位给r14
    adcx rbp,r15 ;低位加c
    adcx r14,rcx ;高位带进位加0
    add rbp,r10 ;低位加t3
    mov r10,rbp ;低位给t3

    ;xor r8,r8 ;t5清零
    adcx r9,r14 ;高位加t4更新t4
    adcx r8,rcx ;t5带进位加0

    ;
    
    mov rdx,r12 ;把t0放到rdx

    add r13,r12
    adcx r11,rcx
    adcx r10,rcx
    adcx r9,r12
    adcx r8,rcx

    shr r12,32
    shl rdx,32

    sub r13,rdx
    sbb r11,r12
    sbb r10,rdx
    sbb r9,r12
    sbb r8,rcx

    ;数组t进行一组轮换
    
    ;vmovq rdx,xmm0 ;把a3放到rdx
    mov rdx,[rsp+16+8]
    xor r12,r12 ;t5清零

    mulx r15,rbp,rdi ;a3乘以b0，低位给rbp，高位给c
    add r13,rbp ;低位加t0更新t0

    mulx r14,rbp,rsi ;a3乘以b1，低位给rbp，高位给r14
    adcx rbp,r15 ;低位加c
    adcx r14,rcx ;高位带进位加0
    add rbp,r11 ;低位加t1
    mov r11,rbp ;低位给t1

    mulx r15,rbp,rbx ;a3乘以b2，低位给rbp，高位给r14
    adcx rbp,r14 ;低位加c
    adcx r15,rcx ;高位带进位加0
    add rbp,r10 ;低位加t2
    mov r10,rbp ;低位给t2

    mulx r14,rbp,rax ;a3乘以b3，低位给rbp，高位给r14
    adcx rbp,r15 ;低位加c
    adcx r14,rcx ;高位带进位加0
    add rbp,r9 ;低位加t3
    mov r9,rbp ;低位给t3

    ;xor r12,r12 ;t5清零
    adcx r8,r14 ;高位加t4更新t4
    adcx r12,rcx ;t5带进位加0
    
    ;

    mov rdx,r13 ;把t0放到rdx

    add r11,r13
    adcx r10,rcx
    adcx r9,rcx
    adcx r8,r13
    adcx r12,rcx

    shr r13,32
    shl rdx,32

    sub r11,rdx
    sbb r10,r13
    mov r15,r11
    sbb r9,rdx
    sbb r8,r13
    mov r14,r10
    sbb r12,rcx

    ;数组t进行一组轮换

    ;test r12,1

    ;mov rax,r12

    ;jnz sub_p

    ;ret

    sub_p:
    
    sub r11,0FFFFFFFFFFFFFFFFh
    mov rdx,0FFFFFFFF00000000h
    sbb r10,rdx
    mov r13,r9
    sbb r9,0FFFFFFFFFFFFFFFFh
    mov rdx,0FFFFFFFEFFFFFFFFh
    mov rbp,r8
    sbb r8,rdx
    sbb r12,0

    cmovc r11,r15
    cmovc r10,r14
    cmovc r9,r13
    cmovc r8,rbp

    ret
_sm2_naked_mul_stack endp

;star;大数a在[[rcx][rcx+8][rcx+16][rcx+24]]，大数b输入为rax,rbx,rsi,rdi，输出模乘结果到r8,r9,r10,r11。使用了全部15个寄存器。
_sm2_naked_mul_stack_rcx proc EXPORT FRAME
    .endprolog

    ;mov rax,[rdx]
    ;mov rbx,[rdx+8]
    ;mov rsi,[rdx+16]
    ;mov rdi,[rdx+24]

    ;xor rcx,rcx
    xor r10,r10 ;t5必然是0
    ;vpextrq rdx,xmm1,1 ;把a0放到rdx
    mov rdx,[rcx+24]

    mulx r15,r9,rdi ;a0乘以b0，低位给t0，高位给c

    mulx rbp,r8,rsi ;a0乘以b1，低位给t1，高位给rbp
    adcx r8,r15 ;低位加c更新t1

    mulx r14,r12,rbx ;a0乘以b2，低位给t2，高位给r14
    adox r8,r9
    adcx r12,rbp ;低位加c更新t2

    mulx r11,r13,rax ;a0乘以b3，低位给t3，高位给t4
    adox r12,r10
    adcx r13,r14 ;低位加c更新t3
    adcx r11,r10 ;高位带进位加0来更新t4
    adox r13,r10
    adox r11,r9
    adox r10,r10

    ;

    mov rdx,r9 ;把t0放到rdx

    shr r9,32
    shl rdx,32

    sub r8,rdx
    sbb r12,r9
    sbb r13,rdx
    sbb r11,r9
    sbb r10,0

    ;数组t进行一组轮换
    
    ;vmovq rdx,xmm1 ;把a1放到rdx
    mov rdx,[rcx+16]
    xor r9,r9 ;t5清零

    mulx r15,rbp,rdi ;a1乘以b0，低位给rbp，高位给r15
    add r8,rbp ;低位加t0更新t0

    mulx r14,rbp,rsi ;a1乘以b1，低位给rbp，高位给r14
    adcx rbp,r15 ;低位加c
    adcx r14,r9 ;高位带进位加0
    adcx rbp,r12 ;低位加t1
    mov r12,rbp ;低位给t1

    mulx r15,rbp,rbx ;a1乘以b2，低位给rbp，高位给r15
    adcx rbp,r14 ;低位加c
    adcx r15,r9 ;高位带进位加0
    adcx rbp,r13 ;低位加t2
    mov r13,rbp ;低位给t2

    mulx r14,rbp,rax ;a1乘以b3，低位给rbp，高位给r14
    adcx rbp,r15 ;低位加c
    adcx r14,r9 ;高位带进位加0
    adcx rbp,r11 ;低位加t3
    mov r11,rbp ;低位给t3

    ;xor r9,r9 ;t5清零
    adcx r10,r14 ;高位加t4更新t4
    adcx r9,r9 ;t5带进位加0
    
    ;

    mov rdx,r8 ;把t0放到rdx

    add r12,r8
    adc r13,0
    adc r11,0
    adcx r10,r8
    adc r9,0

    shr r8,32
    shl rdx,32

    sub r12,rdx
    sbb r13,r8
    sbb r11,rdx
    sbb r10,r8
    sbb r9,0

    ;数组t进行一组轮换
    
    ;vpextrq rdx,xmm0,1 ;把a2放到rdx
    mov rdx,[rcx+8]
    xor r8,r8 ;t5清零

    mulx r15,rbp,rdi ;a2乘以b0，低位给rbp，高位给c
    add r12,rbp ;低位加t0更新t0

    mulx r14,rbp,rsi ;a2乘以b1，低位给rbp，高位给r14
    adcx rbp,r15 ;低位加c
    adcx r14,r8 ;高位带进位加0
    add rbp,r13 ;低位加t1
    mov r13,rbp ;低位给t1

    mulx r15,rbp,rbx ;a2乘以b2，低位给rbp，高位给r14
    adcx rbp,r14 ;低位加c
    adcx r15,r8 ;高位带进位加0
    add rbp,r11 ;低位加t2
    mov r11,rbp ;低位给t2

    mulx r14,rbp,rax ;a2乘以b3，低位给rbp，高位给r14
    adcx rbp,r15 ;低位加c
    adcx r14,r8 ;高位带进位加0
    add rbp,r10 ;低位加t3
    mov r10,rbp ;低位给t3

    ;xor r8,r8 ;t5清零
    adcx r9,r14 ;高位加t4更新t4
    adcx r8,r8 ;t5带进位加0

    ;
    
    mov rdx,r12 ;把t0放到rdx

    add r13,r12
    adc r11,0
    adc r10,0
    adcx r9,r12
    adc r8,0

    shr r12,32
    shl rdx,32

    sub r13,rdx
    sbb r11,r12
    sbb r10,rdx
    sbb r9,r12
    sbb r8,0

    ;数组t进行一组轮换
    
    ;vmovq rdx,xmm0 ;把a3放到rdx
    mov rdx,[rcx]
    xor r12,r12 ;t5清零

    mulx r15,rbp,rdi ;a3乘以b0，低位给rbp，高位给c
    add r13,rbp ;低位加t0更新t0

    mulx r14,rbp,rsi ;a3乘以b1，低位给rbp，高位给r14
    adcx rbp,r15 ;低位加c
    adcx r14,r12 ;高位带进位加0
    add rbp,r11 ;低位加t1
    mov r11,rbp ;低位给t1

    mulx r15,rbp,rbx ;a3乘以b2，低位给rbp，高位给r14
    adcx rbp,r14 ;低位加c
    adcx r15,r12 ;高位带进位加0
    add rbp,r10 ;低位加t2
    mov r10,rbp ;低位给t2

    mulx r14,rbp,rax ;a3乘以b3，低位给rbp，高位给r14
    adcx rbp,r15 ;低位加c
    adcx r14,r12 ;高位带进位加0
    add rbp,r9 ;低位加t3
    mov r9,rbp ;低位给t3

    ;xor r12,r12 ;t5清零
    adcx r8,r14 ;高位加t4更新t4
    adcx r12,r12 ;t5带进位加0
    
    ;

    mov rdx,r13 ;把t0放到rdx

    add r11,r13
    adc r10,0
    adc r9,0
    adcx r8,r13
    adc r12,0

    shr r13,32
    shl rdx,32

    sub r11,rdx
    sbb r10,r13
    mov r15,r11
    sbb r9,rdx
    sbb r8,r13
    mov r14,r10
    sbb r12,0

    ;数组t进行一组轮换

    ;test r12,1

    ;mov rax,r12

    ;jnz sub_p

    ;ret

    ;sub_p:
    
    sub r11,0FFFFFFFFFFFFFFFFh
    mov rdx,0FFFFFFFF00000000h
    sbb r10,rdx
    mov r13,r9
    sbb r9,0FFFFFFFFFFFFFFFFh
    mov rdx,0FFFFFFFEFFFFFFFFh
    mov rbp,r8
    sbb r8,rdx
    sbb r12,0

    cmovc r11,r15
    cmovc r10,r14
    cmovc r9,r13
    cmovc r8,rbp

    ret
_sm2_naked_mul_stack_rcx endp

;star;大数a在[[rcx][rcx+8][rcx+16][rcx+24]]，大数b输入为rax,rbx,rsi,rdi，输出模乘结果到rax,rbx,rsi,rdi。使用了全部15个寄存器。
_sm2_naked_mul_stack_rcx_self proc EXPORT FRAME
    .endprolog

    ;mov rax,[rdx]
    ;mov rbx,[rdx+8]
    ;mov rsi,[rdx+16]
    ;mov rdi,[rdx+24]

    ;xor rcx,rcx
    xor r10,r10 ;t5必然是0
    ;vpextrq rdx,xmm1,1 ;把a0放到rdx
    mov rdx,[rcx+24]

    mulx r15,r9,rdi ;a0乘以b0，低位给t0，高位给c

    mulx rbp,r8,rsi ;a0乘以b1，低位给t1，高位给rbp
    adcx r8,r15 ;低位加c更新t1

    mulx r14,r12,rbx ;a0乘以b2，低位给t2，高位给r14
    adox r8,r9
    adcx r12,rbp ;低位加c更新t2

    mulx r11,r13,rax ;a0乘以b3，低位给t3，高位给t4
    adox r12,r10
    adcx r13,r14 ;低位加c更新t3
    adcx r11,r10 ;高位带进位加0来更新t4
    adox r13,r10
    adox r11,r9
    adox r10,r10

    ;

    mov rdx,r9 ;把t0放到rdx

    shr r9,32
    shl rdx,32

    sub r8,rdx
    sbb r12,r9
    sbb r13,rdx
    sbb r11,r9
    sbb r10,0

    ;数组t进行一组轮换
    
    ;vmovq rdx,xmm1 ;把a1放到rdx
    mov rdx,[rcx+16]
    xor r9,r9 ;t5清零

    mulx r15,rbp,rdi ;a1乘以b0，低位给rbp，高位给r15
    add r8,rbp ;低位加t0更新t0

    mulx r14,rbp,rsi ;a1乘以b1，低位给rbp，高位给r14
    adcx rbp,r15 ;低位加c
    adcx r14,r9 ;高位带进位加0
    adcx rbp,r12 ;低位加t1
    mov r12,rbp ;低位给t1

    mulx r15,rbp,rbx ;a1乘以b2，低位给rbp，高位给r15
    adcx rbp,r14 ;低位加c
    adcx r15,r9 ;高位带进位加0
    adcx rbp,r13 ;低位加t2
    mov r13,rbp ;低位给t2

    mulx r14,rbp,rax ;a1乘以b3，低位给rbp，高位给r14
    adcx rbp,r15 ;低位加c
    adcx r14,r9 ;高位带进位加0
    adcx rbp,r11 ;低位加t3
    mov r11,rbp ;低位给t3

    ;xor r9,r9 ;t5清零
    adcx r10,r14 ;高位加t4更新t4
    adcx r9,r9 ;t5带进位加0
    
    ;

    mov rdx,r8 ;把t0放到rdx

    add r12,r8
    adc r13,0
    adc r11,0
    adcx r10,r8
    adc r9,0

    shr r8,32
    shl rdx,32

    sub r12,rdx
    sbb r13,r8
    sbb r11,rdx
    sbb r10,r8
    sbb r9,0

    ;数组t进行一组轮换
    
    ;vpextrq rdx,xmm0,1 ;把a2放到rdx
    mov rdx,[rcx+8]
    xor r8,r8 ;t5清零

    mulx r15,rbp,rdi ;a2乘以b0，低位给rbp，高位给c
    add r12,rbp ;低位加t0更新t0

    mulx r14,rbp,rsi ;a2乘以b1，低位给rbp，高位给r14
    adcx rbp,r15 ;低位加c
    adcx r14,r8 ;高位带进位加0
    add rbp,r13 ;低位加t1
    mov r13,rbp ;低位给t1

    mulx r15,rbp,rbx ;a2乘以b2，低位给rbp，高位给r14
    adcx rbp,r14 ;低位加c
    adcx r15,r8 ;高位带进位加0
    add rbp,r11 ;低位加t2
    mov r11,rbp ;低位给t2

    mulx r14,rbp,rax ;a2乘以b3，低位给rbp，高位给r14
    adcx rbp,r15 ;低位加c
    adcx r14,r8 ;高位带进位加0
    add rbp,r10 ;低位加t3
    mov r10,rbp ;低位给t3

    ;xor r8,r8 ;t5清零
    adcx r9,r14 ;高位加t4更新t4
    adcx r8,r8 ;t5带进位加0

    ;
    
    mov rdx,r12 ;把t0放到rdx

    add r13,r12
    adc r11,0
    adc r10,0
    adcx r9,r12
    adc r8,0

    shr r12,32
    shl rdx,32

    sub r13,rdx
    sbb r11,r12
    sbb r10,rdx
    sbb r9,r12
    sbb r8,0

    ;数组t进行一组轮换
    
    ;vmovq rdx,xmm0 ;把a3放到rdx
    mov rdx,[rcx]
    xor r12,r12 ;t5清零

    mulx r15,rbp,rdi ;a3乘以b0，低位给rbp，高位给c
    add r13,rbp ;低位加t0更新t0

    mulx r14,rbp,rsi ;a3乘以b1，低位给rbp，高位给r14
    adcx rbp,r15 ;低位加c
    adcx r14,r12 ;高位带进位加0
    add rbp,r11 ;低位加t1
    mov r11,rbp ;低位给t1

    mulx r15,rbp,rbx ;a3乘以b2，低位给rbp，高位给r14
    adcx rbp,r14 ;低位加c
    adcx r15,r12 ;高位带进位加0
    add rbp,r10 ;低位加t2
    mov r10,rbp ;低位给t2

    mulx r14,rbp,rax ;a3乘以b3，低位给rbp，高位给r14
    adcx rbp,r15 ;低位加c
    adcx r14,r12 ;高位带进位加0
    add rbp,r9 ;低位加t3
    mov r9,rbp ;低位给t3

    ;xor r12,r12 ;t5清零
    adcx r8,r14 ;高位加t4更新t4
    adcx r12,r12 ;t5带进位加0
    
    ;

    mov rdx,r13 ;把t0放到rdx

    add r11,r13
    adc r10,0
    adc r9,0
    adcx r8,r13
    adc r12,0

    shr r13,32
    shl rdx,32

    sub r11,rdx
    sbb r10,r13
    mov rdi,r11
    sbb r9,rdx
    sbb r8,r13
    mov rsi,r10
    sbb r12,0

    
    sub r11,0FFFFFFFFFFFFFFFFh
    mov rdx,0FFFFFFFF00000000h
    sbb r10,rdx
    mov rbx,r9
    sbb r9,0FFFFFFFFFFFFFFFFh
    mov rdx,0FFFFFFFEFFFFFFFFh
    mov rax,r8
    sbb r8,rdx
    sbb r12,0

    cmovnc rdi,r11
    cmovnc rsi,r10
    cmovnc rbx,r9
    cmovnc rax,r8

    ret
_sm2_naked_mul_stack_rcx_self endp

;star;使用_sm2_naked_mul_stack
_sm2_point_double_stack_naked proc EXPORT FRAME
    .endprolog

    ;z,  | x, y

    ;delta = z^2
    call _sm2_naked_sqr
    ;z, z^2| x, y
    
    ;||[rax,rbx,rsi,rdi][r8,r9,r10,r11](rbp,r12,r13,r14,r15)rcx,rdx|rsp+8||
    ;||一[[rsp+8+8][rsp+8+16][rsp+8+24][rsp+8+32]]||二[[rsp+8+40][rsp+8+48][rsp+8+56][rsp+8+64]]||三[[rsp+8+72][rsp+8+80][rsp+8+88][rsp+8+96]]||四[[rsp+8+104][rsp+8+112][rsp+8+120][rsp+8+128]]||五[[rsp+8+136][rsp+8+144][rsp+8+152][rsp+8+160]]

    
    mov [rsp+8+72],r8
    mov [rsp+8+80],r9
    mov [rsp+8+88],r10
    mov [rsp+8+96],r11
    ;z, z^2| x, y, delta
    
    mov r8,rax
    mov r9,rbx
    mov r10,rsi
    mov r11,rdi

    ;加载y
    mov rax,[rsp+8+40]
    mov rbx,[rsp+8+48]
    mov rsi,[rsp+8+56]
    mov rdi,[rsp+8+64]
    ;y, z| x, y, delta

    xor rbp,rbp
    add r11,rdi
    adcx r10,rsi
    mov r15,r11
    adcx r9,rbx
    adcx r8,rax
    mov r14,r10
    adc rbp,0

    sub r11,0FFFFFFFFFFFFFFFFh
    mov rdx,0FFFFFFFF00000000h
    mov r13,r9
    sbb r10,rdx
    sbb r9,0FFFFFFFFFFFFFFFFh
    mov r12,r8
    mov rdx,0FFFFFFFEFFFFFFFFh
    sbb r8,rdx
    sbb rbp,0

    cmovc r11,r15
    cmovc r10,r14
    mov [rsp+8+64],r11
    cmovc r9,r13
    mov [rsp+8+56],r10
    mov [rsp+8+48],r9
    cmovc r8,r12
    mov [rsp+8+40],r8
    ;y, z+y  | x, z+y, delta

    ;||[rax,rbx,rsi,rdi][r8,r9,r10,r11](rbp,r12,r13,r14,r15)rcx,rdx|rsp+8||
    ;||一[[rsp+8+8][rsp+8+16][rsp+8+24][rsp+8+32]]||二[[rsp+8+40][rsp+8+48][rsp+8+56][rsp+8+64]]||三[[rsp+8+72][rsp+8+80][rsp+8+88][rsp+8+96]]||四[[rsp+8+104][rsp+8+112][rsp+8+120][rsp+8+128]]||五[[rsp+8+136][rsp+8+144][rsp+8+152][rsp+8+160]]
    
    ;gamma = y^2
    call _sm2_naked_sqr
    ;y, gamma| x, z+y, delta
    
    mov [rsp+8+104],r8
    mov [rsp+8+112],r9
    mov [rsp+8+120],r10
    mov [rsp+8+128],r11
    ;y, gamma| x, z+y, delta, gamma

    mov rax,r8
    mov rbx,r9
    mov rsi,r10
    mov rdi,r11
    ;gamma, gamma| x, z+y, delta, gamma

    ;beta = x*gamma
    call _sm2_naked_mul_stack
    ;gamma, beta| x, z+y, delta, gamma
    
    xor rbp,rbp
    shl r11,1
    rcl r10,1
    mov r15,r11
    rcl r9,1
    rcl r8,1
    mov r14,r10
    rcl rbp,1

    sub r11,0FFFFFFFFFFFFFFFFh
    mov rdx,0FFFFFFFF00000000h
    mov r13,r9
    sbb r10,rdx
    sbb r9,0FFFFFFFFFFFFFFFFh
    mov r12,r8
    mov rdx,0FFFFFFFEFFFFFFFFh
    sbb r8,rdx
    sbb rbp,0
    
    cmovc r11,r15
    cmovc r10,r14
    cmovc r9,r13
    cmovc r8,r12


    xor rbp,rbp
    shl r11,1
    rcl r10,1
    mov r15,r11
    rcl r9,1
    rcl r8,1
    mov r14,r10
    rcl rbp,1

    sub r11,0FFFFFFFFFFFFFFFFh
    mov rdx,0FFFFFFFF00000000h
    mov r13,r9
    sbb r10,rdx
    sbb r9,0FFFFFFFFFFFFFFFFh
    mov r12,r8
    mov rdx,0FFFFFFFEFFFFFFFFh
    sbb r8,rdx
    sbb rbp,0
    
    cmovc r11,r15
    cmovc r10,r14
    mov [rsp+8+160],r11
    cmovc r9,r13
    mov [rsp+8+152],r10
    mov [rsp+8+144],r9
    cmovc r8,r12
    mov [rsp+8+136],r8
    ;gamma, 4*beta| x, z+y, delta, gamma, 4*beta

    ;||[rax,rbx,rsi,rdi][r8,r9,r10,r11](rbp,r12,r13,r14,r15)rcx,rdx|rsp+8||
    ;||一[[rsp+8+8][rsp+8+16][rsp+8+24][rsp+8+32]]||二[[rsp+8+40][rsp+8+48][rsp+8+56][rsp+8+64]]||三[[rsp+8+72][rsp+8+80][rsp+8+88][rsp+8+96]]||四[[rsp+8+104][rsp+8+112][rsp+8+120][rsp+8+128]]||五[[rsp+8+136][rsp+8+144][rsp+8+152][rsp+8+160]]

    ;加载z+y
    mov rax,[rsp+8+40]
    mov rbx,[rsp+8+48]
    mov rsi,[rsp+8+56]
    mov rdi,[rsp+8+64]


    ;(y+z)^2
    call _sm2_naked_sqr
    ;y+z, (y+z)^2| x, z+y, delta, gamma, 4*beta
    

    ;加载gamma
    mov rax,[rsp+8+104]
    mov rbx,[rsp+8+112]
    mov rsi,[rsp+8+120]
    mov rdi,[rsp+8+128]
    ;gamma, (y+z)^2| x, z+y, delta, gamma, 4*beta

    ;||[rax,rbx,rsi,rdi][r8,r9,r10,r11](rbp,r12,r13,r14,r15)rcx,rdx|rsp+8||
    ;||一[[rsp+8+8][rsp+8+16][rsp+8+24][rsp+8+32]]||二[[rsp+8+40][rsp+8+48][rsp+8+56][rsp+8+64]]||三[[rsp+8+72][rsp+8+80][rsp+8+88][rsp+8+96]]||四[[rsp+8+104][rsp+8+112][rsp+8+120][rsp+8+128]]||五[[rsp+8+136][rsp+8+144][rsp+8+152][rsp+8+160]]

    xor rbp,rbp
    sub r11,rdi
    sbb r10,rsi
    mov r15,r11
    sbb r9,rbx
    sbb r8,rax
    mov r14,r10
    sbb rbp,0

    add r11,0FFFFFFFFFFFFFFFFh
    mov r13,r9
    mov rdx,0FFFFFFFF00000000h
    adcx r10,rdx
    adc r9,0FFFFFFFFFFFFFFFFh
    mov r12,r8
    mov rdx,0FFFFFFFEFFFFFFFFh
    adcx r8,rdx

    test rbp,rbp

    cmovz r11,r15
    cmovz r10,r14
    cmovz r9,r13
    cmovz r8,r12


    ;加载delta
    mov rax,[rsp+8+72]
    mov rbx,[rsp+8+80]
    mov rsi,[rsp+8+88]
    mov rdi,[rsp+8+96]
    ;delta, (y+z)^2-gamma| x, z+y, delta, gamma, 4*beta
    
    ;||[rax,rbx,rsi,rdi][r8,r9,r10,r11](rbp,r12,r13,r14,r15)rcx,rdx|rsp+8||
    ;||一[[rsp+8+8][rsp+8+16][rsp+8+24][rsp+8+32]]||二[[rsp+8+40][rsp+8+48][rsp+8+56][rsp+8+64]]||三[[rsp+8+72][rsp+8+80][rsp+8+88][rsp+8+96]]||四[[rsp+8+104][rsp+8+112][rsp+8+120][rsp+8+128]]||五[[rsp+8+136][rsp+8+144][rsp+8+152][rsp+8+160]]

    xor rbp,rbp
    sub r11,rdi
    sbb r10,rsi
    mov r15,r11
    sbb r9,rbx
    sbb r8,rax
    mov r14,r10
    sbb rbp,0

    add r11,0FFFFFFFFFFFFFFFFh
    mov r13,r9
    mov rdx,0FFFFFFFF00000000h
    adcx r10,rdx
    adc r9,0FFFFFFFFFFFFFFFFh
    mov r12,r8
    mov rdx,0FFFFFFFEFFFFFFFFh
    adcx r8,rdx

    test rbp,rbp

    cmovz r11,r15
    cmovz r10,r14
    mov [rsp+8+96],r11
    cmovz r9,r13
    mov [rsp+8+88],r10
    mov [rsp+8+80],r9
    cmovz r8,r12
    mov [rsp+8+72],r8
    ;delta, z0| x, z+y, z0, gamma, 4*beta

    ;加载x
    mov r11,[rsp+8+32]
    mov r10,[rsp+8+24]
    mov r9,[rsp+8+16]
    mov r8,[rsp+8+8]
    ;delta, x| x, z+y, z0, gamma, 4*beta
    
    ;||[rax,rbx,rsi,rdi][r8,r9,r10,r11](rbp,r12,r13,r14,r15)rcx,rdx|rsp+8||
    ;||一[[rsp+8+8][rsp+8+16][rsp+8+24][rsp+8+32]]||二[[rsp+8+40][rsp+8+48][rsp+8+56][rsp+8+64]]||三[[rsp+8+72][rsp+8+80][rsp+8+88][rsp+8+96]]||四[[rsp+8+104][rsp+8+112][rsp+8+120][rsp+8+128]]||五[[rsp+8+136][rsp+8+144][rsp+8+152][rsp+8+160]]
    
    xor rbp,rbp
    add r11,rdi
    adcx r10,rsi
    mov r15,r11
    adcx r9,rbx
    adcx r8,rax
    mov r14,r10
    adc rbp,0

    sub r11,0FFFFFFFFFFFFFFFFh
    mov rdx,0FFFFFFFF00000000h
    mov r13,r9
    sbb r10,rdx
    sbb r9,0FFFFFFFFFFFFFFFFh
    mov r12,r8
    mov rdx,0FFFFFFFEFFFFFFFFh
    sbb r8,rdx
    sbb rbp,0

    cmovnc r15,r11
    cmovnc r14,r10
    cmovnc r13,r9
    cmovnc r12,r8
    
    mov r11,[rsp+8+32]
    mov r10,[rsp+8+24]
    mov r9,[rsp+8+16]
    mov r8,[rsp+8+8]

    mov [rsp+8+32],r15
    mov [rsp+8+24],r14
    mov [rsp+8+16],r13
    mov [rsp+8+8],r12
    ;delta, x| x+delta, z+y, z0, gamma, 4*beta
    
    ;||[rax,rbx,rsi,rdi][r8,r9,r10,r11](rbp,r12,r13,r14,r15)rcx,rdx|rsp+8||
    ;||一[[rsp+8+8][rsp+8+16][rsp+8+24][rsp+8+32]]||二[[rsp+8+40][rsp+8+48][rsp+8+56][rsp+8+64]]||三[[rsp+8+72][rsp+8+80][rsp+8+88][rsp+8+96]]||四[[rsp+8+104][rsp+8+112][rsp+8+120][rsp+8+128]]||五[[rsp+8+136][rsp+8+144][rsp+8+152][rsp+8+160]]

    xor rbp,rbp
    sub r11,rdi
    sbb r10,rsi
    mov rdi,r11
    sbb r9,rbx
    sbb r8,rax
    mov rsi,r10
    sbb rbp,0

    add r11,0FFFFFFFFFFFFFFFFh
    mov rbx,r9
    mov rdx,0FFFFFFFF00000000h
    adcx r10,rdx
    adc r9,0FFFFFFFFFFFFFFFFh
    mov rax,r8
    mov rdx,0FFFFFFFEFFFFFFFFh
    adcx r8,rdx

    test rbp,rbp

    cmovnz rdi,r11
    cmovnz rsi,r10
    cmovnz rbx,r9
    cmovnz rax,r8
    ;x-delta | x+delta, z+y, z0, gamma, 4*beta

    call _sm2_naked_mul_stack
    ;x-delta, (x-delta)(x+delta) | x+delta, z+y, z0, gamma, 4*beta
    
    ;||[rax,rbx,rsi,rdi][r8,r9,r10,r11](rbp,r12,r13,r14,r15)rcx,rdx|rsp+8||
    ;||一[[rsp+8+8][rsp+8+16][rsp+8+24][rsp+8+32]]||二[[rsp+8+40][rsp+8+48][rsp+8+56][rsp+8+64]]||三[[rsp+8+72][rsp+8+80][rsp+8+88][rsp+8+96]]||四[[rsp+8+104][rsp+8+112][rsp+8+120][rsp+8+128]]||五[[rsp+8+136][rsp+8+144][rsp+8+152][rsp+8+160]]

    xor rbp,rbp
    mov rdi,r11
    mov rsi,r10
    shl r11,1
    mov rbx,r9
    rcl r10,1
    mov r15,r11
    mov rax,r8
    rcl r9,1
    rcl r8,1
    mov r14,r10
    rcl rbp,1

    sub r11,0FFFFFFFFFFFFFFFFh
    mov rdx,0FFFFFFFF00000000h
    mov r13,r9
    sbb r10,rdx
    sbb r9,0FFFFFFFFFFFFFFFFh
    mov r12,r8
    mov rdx,0FFFFFFFEFFFFFFFFh
    sbb r8,rdx
    sbb rbp,0
    
    cmovc r11,r15
    cmovc r10,r14
    cmovc r9,r13
    cmovc r8,r12
    ;(x-delta)(x+delta), 2(x-delta)(x+delta) | x+delta, z+y, z0, gamma, 4*beta
    
    ;||[rax,rbx,rsi,rdi][r8,r9,r10,r11](rbp,r12,r13,r14,r15)rcx,rdx|rsp+8||
    ;||一[[rsp+8+8][rsp+8+16][rsp+8+24][rsp+8+32]]||二[[rsp+8+40][rsp+8+48][rsp+8+56][rsp+8+64]]||三[[rsp+8+72][rsp+8+80][rsp+8+88][rsp+8+96]]||四[[rsp+8+104][rsp+8+112][rsp+8+120][rsp+8+128]]||五[[rsp+8+136][rsp+8+144][rsp+8+152][rsp+8+160]]


    xor rbp,rbp
    add r11,rdi
    adcx r10,rsi
    mov rdi,r11
    adcx r9,rbx
    adcx r8,rax
    mov rsi,r10
    adc rbp,0

    sub r11,0FFFFFFFFFFFFFFFFh
    mov rdx,0FFFFFFFF00000000h
    mov rbx,r9
    sbb r10,rdx
    sbb r9,0FFFFFFFFFFFFFFFFh
    mov rax,r8
    mov rdx,0FFFFFFFEFFFFFFFFh
    sbb r8,rdx
    sbb rbp,0

    cmovnc rdi,r11
    cmovnc rsi,r10
    mov [rsp+8+32],rdi
    mov [rsp+8+24],rsi
    cmovnc rbx,r9
    mov [rsp+8+16],rbx
    cmovnc rax,r8
    mov [rsp+8+8],rax
    ;alpha | alpha, z+y, z0, gamma, 4*beta

    call _sm2_naked_sqr
    ;alpha, alpha2 | alpha, z+y, z0, gamma, 4*beta
    
    mov rax,[rsp+8+136]
    mov rbx,[rsp+8+144]
    mov rsi,[rsp+8+152]
    mov rdi,[rsp+8+160]
    ;4*beta, alpha2 | alpha, z+y, z0, gamma, 4*beta

    xor rbp,rbp
    shl rdi,1
    rcl rsi,1
    mov r15,rdi
    rcl rbx,1
    rcl rax,1
    mov r14,rsi
    rcl rbp,1

    sub rdi,0FFFFFFFFFFFFFFFFh
    mov rdx,0FFFFFFFF00000000h
    mov r13,rbx
    sbb rsi,rdx
    sbb rbx,0FFFFFFFFFFFFFFFFh
    mov r12,rax
    mov rdx,0FFFFFFFEFFFFFFFFh
    sbb rax,rdx
    sbb rbp,0
    
    cmovc rdi,r15
    cmovc rsi,r14
    cmovc rbx,r13
    cmovc rax,r12
    ;8*beta, alpha2 | alpha, z+y, z0, gamma, 4*beta

    xor rbp,rbp
    sub r11,rdi
    sbb r10,rsi
    mov rdi,r11
    sbb r9,rbx
    sbb r8,rax
    mov rsi,r10
    sbb rbp,0

    add r11,0FFFFFFFFFFFFFFFFh
    mov rbx,r9
    mov rdx,0FFFFFFFF00000000h
    adcx r10,rdx
    adc r9,0FFFFFFFFFFFFFFFFh
    mov rax,r8
    mov rdx,0FFFFFFFEFFFFFFFFh
    adcx r8,rdx

    test rbp,rbp

    cmovnz rdi,r11
    cmovnz rsi,r10
    cmovnz rbx,r9
    cmovnz rax,r8
    ;x0 | alpha, z+y, z0, gamma, 4*beta
    
    ;||[rax,rbx,rsi,rdi][r8,r9,r10,r11](rbp,r12,r13,r14,r15)rcx,rdx|rsp+8||
    ;||一[[rsp+8+8][rsp+8+16][rsp+8+24][rsp+8+32]]||二[[rsp+8+40][rsp+8+48][rsp+8+56][rsp+8+64]]||三[[rsp+8+72][rsp+8+80][rsp+8+88][rsp+8+96]]||四[[rsp+8+104][rsp+8+112][rsp+8+120][rsp+8+128]]||五[[rsp+8+136][rsp+8+144][rsp+8+152][rsp+8+160]]

    mov [rsp+8+64],rdi
    mov [rsp+8+56],rsi
    mov [rsp+8+48],rbx
    mov [rsp+8+40],rax

    mov r11,[rsp+8+160]
    mov r10,[rsp+8+152]
    mov r9,[rsp+8+144]
    mov r8,[rsp+8+136]
    ;x0, 4*beta | alpha, x0, z0, gamma, 4*beta
    
    xor rbp,rbp
    sub r11,rdi
    sbb r10,rsi
    mov rdi,r11
    sbb r9,rbx
    sbb r8,rax
    mov rsi,r10
    sbb rbp,0

    add r11,0FFFFFFFFFFFFFFFFh
    mov rbx,r9
    mov rdx,0FFFFFFFF00000000h
    adcx r10,rdx
    adc r9,0FFFFFFFFFFFFFFFFh
    mov rax,r8
    mov rdx,0FFFFFFFEFFFFFFFFh
    adcx r8,rdx

    test rbp,rbp

    cmovnz rdi,r11
    cmovnz rsi,r10
    cmovnz rbx,r9
    cmovnz rax,r8
    ;4*beta-x0 | alpha, x0, z0, gamma, 4*beta

    call _sm2_naked_mul_stack
    ; , y0+8g2 | alpha, x0, z0, gamma, 4*beta
    
    mov rdi,[rsp+8+64]
    mov rsi,[rsp+8+56]
    mov rbx,[rsp+8+48]
    mov rax,[rsp+8+40]
    mov [rsp+8+32],rdi
    mov [rsp+8+24],rsi
    mov [rsp+8+16],rbx
    mov [rsp+8+8],rax
    mov [rsp+8+64],r11
    mov [rsp+8+56],r10
    mov [rsp+8+48],r9
    mov [rsp+8+40],r8

    ; | x0, y0+8g2, z0, gamma, 4*beta
    
    mov r11,[rsp+8+128]
    mov r10,[rsp+8+120]
    mov r9,[rsp+8+112]
    mov r8,[rsp+8+104]

    ; , gamma | x0, y0+8g2, z0, gamma, 4*beta

    xor rbp,rbp
    shl r11,1
    rcl r10,1
    mov rdi,r11
    rcl r9,1
    rcl r8,1
    mov rsi,r10
    rcl rbp,1

    sub r11,0FFFFFFFFFFFFFFFFh
    mov rdx,0FFFFFFFF00000000h
    mov rbx,r9
    sbb r10,rdx
    sbb r9,0FFFFFFFFFFFFFFFFh
    mov rax,r8
    mov rdx,0FFFFFFFEFFFFFFFFh
    sbb r8,rdx
    sbb rbp,0
    
    cmovnc rdi,r11
    cmovnc rsi,r10
    cmovnc rbx,r9
    cmovnc rax,r8

    call _sm2_naked_sqr
    
    xor rbp,rbp
    shl r11,1
    rcl r10,1
    mov rdi,r11
    rcl r9,1
    rcl r8,1
    mov rsi,r10
    rcl rbp,1

    sub r11,0FFFFFFFFFFFFFFFFh
    mov rdx,0FFFFFFFF00000000h
    mov rbx,r9
    sbb r10,rdx
    sbb r9,0FFFFFFFFFFFFFFFFh
    mov rax,r8
    mov rdx,0FFFFFFFEFFFFFFFFh
    sbb r8,rdx
    sbb rbp,0
    
    cmovnc rdi,r11
    cmovnc rsi,r10
    cmovnc rbx,r9
    cmovnc rax,r8
    
    mov r11,[rsp+8+64]
    mov r10,[rsp+8+56]
    mov r9,[rsp+8+48]
    mov r8,[rsp+8+40]

    ;8gamma2, y0+8g2 | x0, y0+8g2, z0, gamma, 4*beta

    xor rbp,rbp
    sub r11,rdi
    sbb r10,rsi
    mov rdi,r11
    sbb r9,rbx
    sbb r8,rax
    mov rsi,r10
    sbb rbp,0

    add r11,0FFFFFFFFFFFFFFFFh
    mov rbx,r9
    mov rdx,0FFFFFFFF00000000h
    adcx r10,rdx
    adc r9,0FFFFFFFFFFFFFFFFh
    mov rax,r8
    mov rdx,0FFFFFFFEFFFFFFFFh
    adcx r8,rdx

    test rbp,rbp

    cmovnz rdi,r11
    cmovnz rsi,r10
    cmovnz rbx,r9
    cmovnz rax,r8

    ;y0 | x0, y0+8g2, z0, gamma, 4*beta
    
    mov [rsp+8+64],rdi
    mov [rsp+8+56],rsi
    mov [rsp+8+48],rbx
    mov [rsp+8+40],rax
    
    ; | x0, y0, z0, gamma, 4*beta

    ret
_sm2_point_double_stack_naked endp


_sm2_mul_to_mm proc EXPORT FRAME
    .endprolog

    push rbx
    push rsi
    push rdi
    push rbp
    push r12
    push r13
    push r14
    push r15

    push rdx
    

    mov rax,[rcx]
    mov rbx,[rcx+8]
    mov rsi,[rcx+16]
    mov rdi,[rcx+24]


    ;vpextrq rdx,xmm1,1 ;把a0放到rdx
    ;mov rdx,[rcx+24]
    mov rdx,00000000200000003h

    mulx r15,r9,rdi ;a0乘以b0，低位给t0，高位给c

    mulx rbp,r8,rsi ;a0乘以b1，低位给t1，高位给rbp
    add r8,r15 ;低位加c更新t1

    mulx r14,r12,rbx ;a0乘以b2，低位给t2，高位给r14
    adcx r12,rbp ;低位加c更新t2

    mulx r11,r13,rax ;a0乘以b3，低位给t3，高位给t4
    adcx r13,r14 ;低位加c更新t3
    adc r11,0 ;高位带进位加0来更新t4

    ;

    mov rdx,r9 ;把t0放到rdx
    xor r10,r10 ;t5必然是0

    add r8,r9
    adc r12,0
    adc r13,0
    adcx r11,r9
    adc r10,0

    shr r9,32
    shl rdx,32

    sub r8,rdx
    sbb r12,r9
    sbb r13,rdx
    sbb r11,r9
    sbb r10,0

    ;数组t进行一组轮换
    
    ;vmovq rdx,xmm1 ;把a1放到rdx
    ;mov rdx,[rcx+16]
    mov rdx,000000002ffffffffh
    xor r9,r9 ;t5清零

    mulx r15,rbp,rdi ;a1乘以b0，低位给rbp，高位给r15
    add r8,rbp ;低位加t0更新t0

    mulx r14,rbp,rsi ;a1乘以b1，低位给rbp，高位给r14
    adcx rbp,r15 ;低位加c
    adc r14,0 ;高位带进位加0
    adcx rbp,r12 ;低位加t1
    mov r12,rbp ;低位给t1

    mulx r15,rbp,rbx ;a1乘以b2，低位给rbp，高位给r15
    adcx rbp,r14 ;低位加c
    adc r15,0 ;高位带进位加0
    adcx rbp,r13 ;低位加t2
    mov r13,rbp ;低位给t2

    mulx r14,rbp,rax ;a1乘以b3，低位给rbp，高位给r14
    adcx rbp,r15 ;低位加c
    adc r14,0 ;高位带进位加0
    adcx rbp,r11 ;低位加t3
    mov r11,rbp ;低位给t3

    ;xor r9,r9 ;t5清零
    adcx r10,r14 ;高位加t4更新t4
    adc r9,0 ;t5带进位加0
    
    ;

    mov rdx,r8 ;把t0放到rdx

    add r12,r8
    adc r13,0
    adc r11,0
    adcx r10,r8
    adc r9,0

    shr r8,32
    shl rdx,32

    sub r12,rdx
    sbb r13,r8
    sbb r11,rdx
    sbb r10,r8
    sbb r9,0

    ;数组t进行一组轮换
    
    ;vpextrq rdx,xmm0,1 ;把a2放到rdx
    ;mov rdx,[rcx+8]
    mov rdx,00000000100000001h
    xor r8,r8 ;t5清零

    mulx r15,rbp,rdi ;a2乘以b0，低位给rbp，高位给c
    add r12,rbp ;低位加t0更新t0

    mulx r14,rbp,rsi ;a2乘以b1，低位给rbp，高位给r14
    adcx rbp,r15 ;低位加c
    adc r14,0 ;高位带进位加0
    add rbp,r13 ;低位加t1
    mov r13,rbp ;低位给t1

    mulx r15,rbp,rbx ;a2乘以b2，低位给rbp，高位给r14
    adcx rbp,r14 ;低位加c
    adc r15,0 ;高位带进位加0
    add rbp,r11 ;低位加t2
    mov r11,rbp ;低位给t2

    mulx r14,rbp,rax ;a2乘以b3，低位给rbp，高位给r14
    adcx rbp,r15 ;低位加c
    adc r14,0 ;高位带进位加0
    add rbp,r10 ;低位加t3
    mov r10,rbp ;低位给t3

    ;xor r8,r8 ;t5清零
    adcx r9,r14 ;高位加t4更新t4
    adc r8,0 ;t5带进位加0

    ;
    
    mov rdx,r12 ;把t0放到rdx

    add r13,r12
    adc r11,0
    adc r10,0
    adcx r9,r12
    adc r8,0

    shr r12,32
    shl rdx,32

    sub r13,rdx
    sbb r11,r12
    sbb r10,rdx
    sbb r9,r12
    sbb r8,0

    ;数组t进行一组轮换
    
    ;vmovq rdx,xmm0 ;把a3放到rdx
    ;mov rdx,[rcx]
    mov rdx,00000000400000002h
    xor r12,r12 ;t5清零

    mulx r15,rbp,rdi ;a3乘以b0，低位给rbp，高位给c
    add r13,rbp ;低位加t0更新t0

    mulx r14,rbp,rsi ;a3乘以b1，低位给rbp，高位给r14
    adcx rbp,r15 ;低位加c
    adc r14,0 ;高位带进位加0
    add rbp,r11 ;低位加t1
    mov r11,rbp ;低位给t1

    mulx r15,rbp,rbx ;a3乘以b2，低位给rbp，高位给r14
    adcx rbp,r14 ;低位加c
    adc r15,0 ;高位带进位加0
    add rbp,r10 ;低位加t2
    mov r10,rbp ;低位给t2

    mulx r14,rbp,rax ;a3乘以b3，低位给rbp，高位给r14
    adcx rbp,r15 ;低位加c
    adc r14,0 ;高位带进位加0
    add rbp,r9 ;低位加t3
    mov r9,rbp ;低位给t3

    ;xor r12,r12 ;t5清零
    adcx r8,r14 ;高位加t4更新t4
    adc r12,0 ;t5带进位加0
    
    ;

    mov rdx,r13 ;把t0放到rdx

    add r11,r13
    adc r10,0
    adc r9,0
    adcx r8,r13
    adc r12,0

    shr r13,32
    shl rdx,32

    sub r11,rdx
    sbb r10,r13
    mov r15,r11
    sbb r9,rdx
    sbb r8,r13
    mov r14,r10
    sbb r12,0

    ;数组t进行一组轮换

    ;test r12,1

    ;mov rax,r12

    ;jnz sub_p

    ;ret

    sub_p:
    
    sub r11,0FFFFFFFFFFFFFFFFh
    mov rdx,0FFFFFFFF00000000h
    sbb r10,rdx
    mov r13,r9
    sbb r9,0FFFFFFFFFFFFFFFFh
    mov rdx,0FFFFFFFEFFFFFFFFh
    mov rbp,r8
    sbb r8,rdx
    sbb r12,0

    cmovc r11,r15
    cmovc r10,r14
    cmovc r9,r13
    cmovc r8,rbp
    
    pop rdx

    mov [rdx],r8
    mov [rdx+8],r9
    mov [rdx+16],r10
    mov [rdx+24],r11


    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    pop rdi
    pop rsi
    pop rbx

    ret
_sm2_mul_to_mm endp

_sm2_mul_mm_to proc EXPORT FRAME
    .endprolog

    push rbx
    push rsi
    push rdi
    push rbp
    push r12
    push r13
    push r14
    push r15

    push rdx
    

    mov rax,[rcx]
    mov rbx,[rcx+8]
    mov rsi,[rcx+16]
    mov rdi,[rcx+24]


    ;vpextrq rdx,xmm1,1 ;把a0放到rdx
    ;mov rdx,[rcx+24]
    mov rdx,1

    mulx r15,r9,rdi ;a0乘以b0，低位给t0，高位给c

    mulx rbp,r8,rsi ;a0乘以b1，低位给t1，高位给rbp
    add r8,r15 ;低位加c更新t1

    mulx r14,r12,rbx ;a0乘以b2，低位给t2，高位给r14
    adcx r12,rbp ;低位加c更新t2

    mulx r11,r13,rax ;a0乘以b3，低位给t3，高位给t4
    adcx r13,r14 ;低位加c更新t3
    adc r11,0 ;高位带进位加0来更新t4

    ;

    mov rdx,r9 ;把t0放到rdx
    xor r10,r10 ;t5必然是0

    add r8,r9
    adc r12,0
    adc r13,0
    adcx r11,r9
    adc r10,0

    shr r9,32
    shl rdx,32

    sub r8,rdx
    sbb r12,r9
    sbb r13,rdx
    sbb r11,r9
    sbb r10,0

    ;数组t进行一组轮换
    
    ;vmovq rdx,xmm1 ;把a1放到rdx
    ;mov rdx,[rcx+16]
    mov rdx,0
    xor r9,r9 ;t5清零

    mulx r15,rbp,rdi ;a1乘以b0，低位给rbp，高位给r15
    add r8,rbp ;低位加t0更新t0

    mulx r14,rbp,rsi ;a1乘以b1，低位给rbp，高位给r14
    adcx rbp,r15 ;低位加c
    adc r14,0 ;高位带进位加0
    adcx rbp,r12 ;低位加t1
    mov r12,rbp ;低位给t1

    mulx r15,rbp,rbx ;a1乘以b2，低位给rbp，高位给r15
    adcx rbp,r14 ;低位加c
    adc r15,0 ;高位带进位加0
    adcx rbp,r13 ;低位加t2
    mov r13,rbp ;低位给t2

    mulx r14,rbp,rax ;a1乘以b3，低位给rbp，高位给r14
    adcx rbp,r15 ;低位加c
    adc r14,0 ;高位带进位加0
    adcx rbp,r11 ;低位加t3
    mov r11,rbp ;低位给t3

    ;xor r9,r9 ;t5清零
    adcx r10,r14 ;高位加t4更新t4
    adc r9,0 ;t5带进位加0
    
    ;

    mov rdx,r8 ;把t0放到rdx

    add r12,r8
    adc r13,0
    adc r11,0
    adcx r10,r8
    adc r9,0

    shr r8,32
    shl rdx,32

    sub r12,rdx
    sbb r13,r8
    sbb r11,rdx
    sbb r10,r8
    sbb r9,0

    ;数组t进行一组轮换
    
    ;vpextrq rdx,xmm0,1 ;把a2放到rdx
    ;mov rdx,[rcx+8]
    mov rdx,0
    xor r8,r8 ;t5清零

    mulx r15,rbp,rdi ;a2乘以b0，低位给rbp，高位给c
    add r12,rbp ;低位加t0更新t0

    mulx r14,rbp,rsi ;a2乘以b1，低位给rbp，高位给r14
    adcx rbp,r15 ;低位加c
    adc r14,0 ;高位带进位加0
    add rbp,r13 ;低位加t1
    mov r13,rbp ;低位给t1

    mulx r15,rbp,rbx ;a2乘以b2，低位给rbp，高位给r14
    adcx rbp,r14 ;低位加c
    adc r15,0 ;高位带进位加0
    add rbp,r11 ;低位加t2
    mov r11,rbp ;低位给t2

    mulx r14,rbp,rax ;a2乘以b3，低位给rbp，高位给r14
    adcx rbp,r15 ;低位加c
    adc r14,0 ;高位带进位加0
    add rbp,r10 ;低位加t3
    mov r10,rbp ;低位给t3

    ;xor r8,r8 ;t5清零
    adcx r9,r14 ;高位加t4更新t4
    adc r8,0 ;t5带进位加0

    ;
    
    mov rdx,r12 ;把t0放到rdx

    add r13,r12
    adc r11,0
    adc r10,0
    adcx r9,r12
    adc r8,0

    shr r12,32
    shl rdx,32

    sub r13,rdx
    sbb r11,r12
    sbb r10,rdx
    sbb r9,r12
    sbb r8,0

    ;数组t进行一组轮换
    
    ;vmovq rdx,xmm0 ;把a3放到rdx
    ;mov rdx,[rcx]
    mov rdx,0
    xor r12,r12 ;t5清零

    mulx r15,rbp,rdi ;a3乘以b0，低位给rbp，高位给c
    add r13,rbp ;低位加t0更新t0

    mulx r14,rbp,rsi ;a3乘以b1，低位给rbp，高位给r14
    adcx rbp,r15 ;低位加c
    adc r14,0 ;高位带进位加0
    add rbp,r11 ;低位加t1
    mov r11,rbp ;低位给t1

    mulx r15,rbp,rbx ;a3乘以b2，低位给rbp，高位给r14
    adcx rbp,r14 ;低位加c
    adc r15,0 ;高位带进位加0
    add rbp,r10 ;低位加t2
    mov r10,rbp ;低位给t2

    mulx r14,rbp,rax ;a3乘以b3，低位给rbp，高位给r14
    adcx rbp,r15 ;低位加c
    adc r14,0 ;高位带进位加0
    add rbp,r9 ;低位加t3
    mov r9,rbp ;低位给t3

    ;xor r12,r12 ;t5清零
    adcx r8,r14 ;高位加t4更新t4
    adc r12,0 ;t5带进位加0
    
    ;

    mov rdx,r13 ;把t0放到rdx

    add r11,r13
    adc r10,0
    adc r9,0
    adcx r8,r13
    adc r12,0

    shr r13,32
    shl rdx,32

    sub r11,rdx
    sbb r10,r13
    mov r15,r11
    sbb r9,rdx
    sbb r8,r13
    mov r14,r10
    sbb r12,0

    ;数组t进行一组轮换

    ;test r12,1

    ;mov rax,r12

    ;jnz sub_p

    ;ret

    sub_p:
    
    sub r11,0FFFFFFFFFFFFFFFFh
    mov rdx,0FFFFFFFF00000000h
    sbb r10,rdx
    mov r13,r9
    sbb r9,0FFFFFFFFFFFFFFFFh
    mov rdx,0FFFFFFFEFFFFFFFFh
    mov rbp,r8
    sbb r8,rdx
    sbb r12,0

    cmovc r11,r15
    cmovc r10,r14
    cmovc r9,r13
    cmovc r8,rbp
    
    pop rdx

    mov [rdx],r8
    mov [rdx+8],r9
    mov [rdx+16],r10
    mov [rdx+24],r11


    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    pop rdi
    pop rsi
    pop rbx

    ret
_sm2_mul_mm_to endp


_uint256_p_sub proc EXPORT FRAME
    .endprolog

    mov r11,0FFFFFFFFFFFFFFFFh
    mov r10,0FFFFFFFF00000000h
    mov rax,0FFFFFFFFFFFFFFFFh
    mov r8,0FFFFFFFEFFFFFFFFh
    sub r11,[rcx+24]
    sbb r10,[rcx+16]
    sbb rax,[rcx+8]
    sbb r8,[rcx]

    jc add_p

    mov [rdx+24],r11
    mov [rdx+16],r10
    mov [rdx+8],rax
    mov [rdx],r8
    
    ret

    add_p:
    add r11,0FFFFFFFFFFFFFFFFh
    mov r9,0FFFFFFFF00000000h
    adc r10,r9
    adc rax,0FFFFFFFFFFFFFFFFh
    mov r9,0FFFFFFFEFFFFFFFFh
    adc r8,r9

    jnc add_p

    mov [rdx+24],r11
    mov [rdx+16],r10
    mov [rdx+8],rax
    mov [rdx],r8
    
    ret
_uint256_p_sub endp


jacobian_point_double_z1_equ_1 proc EXPORT FRAME
    .endprolog
    push rbx
    push rsi
    push rdi
    push rbp
    push r12
    push r13
    push r14
    push r15

    sub rsp,288
    mov [rsp],rcx
    mov [rsp+8],rdx

    mov rdi,[rcx+56]
    mov rsi,[rcx+48]
    mov rbx,[rcx+40]
    mov rax,[rcx+32]
    ; y1, || 

    call _sm2_naked_sqr
    ; y1, yy|| 

    xor rbp,rbp
    shl rdi,1
    rcl rsi,1
    mov r15,rdi
    rcl rbx,1
    rcl rax,1
    mov r14,rsi
    rcl rbp,1

    sub rdi,0FFFFFFFFFFFFFFFFh
    mov rdx,0FFFFFFFF00000000h
    mov r13,rbx
    sbb rsi,rdx
    sbb rbx,0FFFFFFFFFFFFFFFFh
    mov r12,rax
    mov rdx,0FFFFFFFEFFFFFFFFh
    sbb rax,rdx
    sbb rbp,0
    
    cmovc rdi,r15
    cmovc rsi,r14
    cmovc rbx,r13
    cmovc rax,r12

    ; 2*y1, yy|| 

    mov rcx,[rsp+8]
    mov [rcx+88],rdi
    mov [rcx+80],rsi
    mov [rcx+72],rbx
    mov [rcx+64],rax

    mov rdi,r11
    mov rsi,r10
    mov rbx,r9
    mov rax,r8
    
    call _sm2_naked_sqr
    ; yy, yyyy|| 
    
    mov [rsp+40],r11
    mov [rsp+32],r10
    mov [rsp+24],r9
    mov [rsp+16],r8
    ; yy, yyyy|| yyyy

    xor rbp,rbp
    shl r11,1
    rcl r10,1
    mov r15,r11
    rcl r9,1
    rcl r8,1
    mov r14,r10
    rcl rbp,1

    sub r11,0FFFFFFFFFFFFFFFFh
    mov rdx,0FFFFFFFF00000000h
    mov r13,r9
    sbb r10,rdx
    sbb r9,0FFFFFFFFFFFFFFFFh
    mov r12,r8
    mov rdx,0FFFFFFFEFFFFFFFFh
    sbb r8,rdx
    sbb rbp,0
    
    cmovc r11,r15
    cmovc r10,r14
    cmovc r9,r13
    cmovc r8,r12

    xor rbp,rbp
    shl r11,1
    rcl r10,1
    mov r15,r11
    rcl r9,1
    rcl r8,1
    mov r14,r10
    rcl rbp,1

    sub r11,0FFFFFFFFFFFFFFFFh
    mov rdx,0FFFFFFFF00000000h
    mov r13,r9
    sbb r10,rdx
    sbb r9,0FFFFFFFFFFFFFFFFh
    mov r12,r8
    mov rdx,0FFFFFFFEFFFFFFFFh
    sbb r8,rdx
    sbb rbp,0
    
    cmovc r11,r15
    cmovc r10,r14
    cmovc r9,r13
    cmovc r8,r12
    
    xor rbp,rbp
    shl r11,1
    rcl r10,1
    mov r15,r11
    rcl r9,1
    rcl r8,1
    mov r14,r10
    rcl rbp,1

    sub r11,0FFFFFFFFFFFFFFFFh
    mov rdx,0FFFFFFFF00000000h
    mov r13,r9
    sbb r10,rdx
    sbb r9,0FFFFFFFFFFFFFFFFh
    mov r12,r8
    mov rdx,0FFFFFFFEFFFFFFFFh
    sbb r8,rdx
    sbb rbp,0
    
    cmovc r11,r15
    cmovc r10,r14
    cmovc r9,r13
    cmovc r8,r12
    ; yy, 8*yyyy|| yyyy
    
    mov rcx,[rsp]

    mov [rcx+56],r11
    mov [rcx+48],r10
    mov [rcx+40],r9
    mov [rcx+32],r8
    ; yy, 8*yyyy|| yyyy, 8*yyyy


    xor rbp,rbp
    add rdi,[rcx+24]
    adcx rsi,[rcx+16]
    mov r11,rdi
    adcx rbx,[rcx+8]
    adcx rax,[rcx]
    mov r10,rsi
    adc rbp,0

    sub r11,0FFFFFFFFFFFFFFFFh
    mov rdx,0FFFFFFFF00000000h
    mov r9,rbx
    sbb r10,rdx
    sbb r9,0FFFFFFFFFFFFFFFFh
    mov r8,rax
    mov rdx,0FFFFFFFEFFFFFFFFh
    sbb r8,rdx
    sbb rbp,0

    cmovnc rdi,r11
    cmovnc rsi,r10
    cmovnc rbx,r9
    cmovnc rax,r8
    ; x1+yy,|| yyyy, 8*yyyy

    call _sm2_naked_sqr

    xor rbp,rbp
    sub r11,[rsp+40]
    sbb r10,[rsp+32]
    mov rdi,r11
    sbb r9,[rsp+24]
    sbb r8,[rsp+16]
    mov rsi,r10
    sbb rbp,0

    add r11,0FFFFFFFFFFFFFFFFh
    mov rbx,r9
    mov rdx,0FFFFFFFF00000000h
    adcx r10,rdx
    adc r9,0FFFFFFFFFFFFFFFFh
    mov rax,r8
    mov rdx,0FFFFFFFEFFFFFFFFh
    adcx r8,rdx

    test rbp,rbp

    cmovnz rdi,r11
    cmovnz rsi,r10
    cmovnz rbx,r9
    cmovnz rax,r8
    ; (x1+yy)^2-yyyy,|| yyyy, 8*yyyy
    
    mov [rsp+40],rdi
    mov [rsp+32],rsi
    mov [rsp+24],rbx
    mov [rsp+16],rax
    ; (x1+yy)^2-yyyy,|| (x1+yy)^2-yyyy, 8*yyyy

    mov rcx,[rsp]
    mov rdi,[rcx+24]
    mov rsi,[rcx+16]
    mov rbx,[rcx+8]
    mov rax,[rcx]
    ; x1,|| (x1+yy)^2-yyyy, 8*yyyy
    
    call _sm2_naked_sqr
    ; x1, xx || (x1+yy)^2-yyyy, 8*yyyy
    
    mov [rsp+104],r11
    mov [rsp+96],r10
    mov [rsp+88],r9
    mov [rsp+80],r8
    ; x1, xx || (x1+yy)^2-yyyy, 8*yyyy, xx

    xor rbp,rbp  
    sub r11,00000000000000001h
    mov rdx,000000000FFFFFFFFh
    sbb r10,rdx
    mov r15,r11
    sbb r9,00000000000000000h
    mov rdx,00000000100000000h
    sbb r8,rdx
    mov r14,r10
    sbb rbp,0

    add r11,0FFFFFFFFFFFFFFFFh
    mov r13,r9
    mov rdx,0FFFFFFFF00000000h
    adcx r10,rdx
    adc r9,0FFFFFFFFFFFFFFFFh
    mov r12,r8
    mov rdx,0FFFFFFFEFFFFFFFFh
    adcx r8,rdx

    test rbp,rbp

    cmovz r11,r15
    cmovz r10,r14
    cmovz r9,r13
    cmovz r8,r12

    xor rbp,rbp
    mov rdi,r11
    mov rsi,r10
    shl r11,1
    mov rbx,r9
    rcl r10,1
    mov r15,r11
    mov rax,r8
    rcl r9,1
    rcl r8,1
    mov r14,r10
    rcl rbp,1

    sub r11,0FFFFFFFFFFFFFFFFh
    mov rdx,0FFFFFFFF00000000h
    mov r13,r9
    sbb r10,rdx
    sbb r9,0FFFFFFFFFFFFFFFFh
    mov r12,r8
    mov rdx,0FFFFFFFEFFFFFFFFh
    sbb r8,rdx
    sbb rbp,0
    
    cmovc r11,r15
    cmovc r10,r14
    cmovc r9,r13
    cmovc r8,r12

    xor rbp,rbp
    add r11,rdi
    adcx r10,rsi
    mov rdi,r11
    adcx r9,rbx
    adcx r8,rax
    mov rsi,r10
    adc rbp,0

    sub r11,0FFFFFFFFFFFFFFFFh
    mov rdx,0FFFFFFFF00000000h
    mov rbx,r9
    sbb r10,rdx
    sbb r9,0FFFFFFFFFFFFFFFFh
    mov rax,r8
    mov rdx,0FFFFFFFEFFFFFFFFh
    sbb r8,rdx
    sbb rbp,0

    cmovnc rdi,r11
    cmovnc rsi,r10
    cmovnc rbx,r9
    cmovnc rax,r8
    
    mov [rsp+136],rdi
    mov [rsp+128],rsi
    mov [rsp+120],rbx
    mov [rsp+112],rax
    ; m, || (x1+yy)^2-yyyy, 8*yyyy, xx, m

    call _sm2_naked_sqr
    ; m, m^2 || (x1+yy)^2-yyyy, 8*yyyy, xx, m

    ; m, m^2 || (x1+yy)^2-yyyy, 8*yyyy, xx, m

    mov rdi,[rsp+40]
    mov rsi,[rsp+32]
    mov rbx,[rsp+24]
    mov rax,[rsp+16]
    ; (x1+yy)^2-yyyy, m^2 || (x1+yy)^2-yyyy, 8*yyyy, xx, m

    xor rbp,rbp
    sub rdi,[rsp+104]
    sbb rsi,[rsp+96]
    mov r15,rdi
    sbb rbx,[rsp+88]
    sbb rax,[rsp+80]
    mov r14,rsi
    sbb rbp,0

    add rdi,0FFFFFFFFFFFFFFFFh
    mov r13,rbx
    mov rdx,0FFFFFFFF00000000h
    adcx rsi,rdx
    adc rbx,0FFFFFFFFFFFFFFFFh
    mov r12,rax
    mov rdx,0FFFFFFFEFFFFFFFFh
    adcx rax,rdx

    test rbp,rbp

    cmovz rdi,r15
    cmovz rsi,r14
    cmovz rbx,r13
    cmovz rax,r12
    ; s/2, m^2 || (x1+yy)^2-yyyy, 8*yyyy, xx, m

    xor rbp,rbp
    shl rdi,1
    rcl rsi,1
    mov r15,rdi
    rcl rbx,1
    rcl rax,1
    mov r14,rsi
    rcl rbp,1

    sub rdi,0FFFFFFFFFFFFFFFFh
    mov rdx,0FFFFFFFF00000000h
    mov r13,rbx
    sbb rsi,rdx
    sbb rbx,0FFFFFFFFFFFFFFFFh
    mov r12,rax
    mov rdx,0FFFFFFFEFFFFFFFFh
    sbb rax,rdx
    sbb rbp,0
    
    cmovc rdi,r15
    cmovc rsi,r14
    cmovc rbx,r13
    cmovc rax,r12
    ; s, m^2 || (x1+yy)^2-yyyy, 8*yyyy, xx, m

    xor rbp,rbp
    sub r11,rdi
    sbb r10,rsi
    mov r15,r11
    sbb r9,rbx
    sbb r8,rax
    mov r14,r10
    sbb rbp,0

    add r11,0FFFFFFFFFFFFFFFFh
    mov r13,r9
    mov rdx,0FFFFFFFF00000000h
    adcx r10,rdx
    adc r9,0FFFFFFFFFFFFFFFFh
    mov r12,r8
    mov rdx,0FFFFFFFEFFFFFFFFh
    adcx r8,rdx

    test rbp,rbp

    cmovz r11,r15
    cmovz r10,r14
    cmovz r9,r13
    cmovz r8,r12

    mov rcx,[rsp]
    mov [rcx+24],rdi
    mov [rcx+16],rsi
    mov [rcx+8],rbx
    mov [rcx],rax

    ; s, m^2-s || (x1+yy)^2-yyyy, 8*yyyy, xx, m

    xor rbp,rbp
    sub r11,rdi
    sbb r10,rsi
    mov r15,r11
    sbb r9,rbx
    sbb r8,rax
    mov r14,r10
    sbb rbp,0

    add r11,0FFFFFFFFFFFFFFFFh
    mov r13,r9
    mov rdx,0FFFFFFFF00000000h
    adcx r10,rdx
    adc r9,0FFFFFFFFFFFFFFFFh
    mov r12,r8
    mov rdx,0FFFFFFFEFFFFFFFFh
    adcx r8,rdx

    test rbp,rbp

    cmovz r11,r15
    cmovz r10,r14
    cmovz r9,r13
    cmovz r8,r12
    ; s, t || (x1+yy)^2-yyyy, 8*yyyy, xx, m

    mov rcx,[rsp+8]
    mov [rcx+24],r11
    mov [rcx+16],r10
    mov [rcx+8],r9
    mov [rcx],r8

    xor rbp,rbp
    sub rdi,r11
    sbb rsi,r10
    mov r15,rdi
    sbb rbx,r9
    sbb rax,r8
    mov r14,rsi
    sbb rbp,0

    add rdi,0FFFFFFFFFFFFFFFFh
    mov r13,rbx
    mov rdx,0FFFFFFFF00000000h
    adcx rsi,rdx
    adc rbx,0FFFFFFFFFFFFFFFFh
    mov r12,rax
    mov rdx,0FFFFFFFEFFFFFFFFh
    adcx rax,rdx

    test rbp,rbp

    cmovz rdi,r15
    cmovz rsi,r14
    cmovz rbx,r13
    cmovz rax,r12
    ; s-t, t || (x1+yy)^2-yyyy, 8*yyyy, xx, m

    lea rcx,[rsp+112]

    call _sm2_naked_mul_stack_rcx
    ; ,m*(s-t) || (x1+yy)^2-yyyy, 8*yyyy, xx, m
    
    mov rcx,[rsp]

    xor rbp,rbp
    sub r11,[rcx+56]
    sbb r10,[rcx+48]
    mov rdi,r11
    sbb r9,[rcx+40]
    sbb r8,[rcx+32]
    mov rsi,r10
    sbb rbp,0

    add r11,0FFFFFFFFFFFFFFFFh
    mov rbx,r9
    mov rdx,0FFFFFFFF00000000h
    adcx r10,rdx
    adc r9,0FFFFFFFFFFFFFFFFh
    mov rax,r8
    mov rdx,0FFFFFFFEFFFFFFFFh
    adcx r8,rdx

    test rbp,rbp

    cmovnz rdi,r11
    cmovnz rsi,r10
    cmovnz rbx,r9
    cmovnz rax,r8
    
    mov rcx,[rsp+8]

    mov [rcx+56],rdi
    mov [rcx+48],rsi
    mov [rcx+40],rbx
    mov [rcx+32],rax

    ;||[rax,rbx,rsi,rdi][r8,r9,r10,r11](rbp,r12,r13,r14,r15)rcx,rdx|rsp+8||||rcx=[rsp]||rdx=[rsp+8]||
    ;||一[[rsp+16][rsp+24][rsp+32][rsp+40]]||二[[rsp+48][rsp+56][rsp+64][rsp+72]]||三[[rsp+80][rsp+88][rsp+96][rsp+104]]||四[[rsp+112][rsp+120][rsp+128][rsp+136]]
    ;||五[[rsp+144][rsp+152][rsp+160][rsp+168]]||六[[rsp+176][rsp+184][rsp+192][rsp+200]]||七[[rsp+208][rsp+216][rsp+224][rsp+232]]||八[[rsp+240][rsp+248][rsp+256][rsp+264]]||


    add rsp,288

    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    pop rdi
    pop rsi
    pop rbx
    ret
jacobian_point_double_z1_equ_1 endp

jacobian_point_add_z1_equ_z2_lambda proc EXPORT FRAME
    .endprolog
    push rbx
    push rsi
    push rdi
    push rbp
    push r12
    push r13
    push r14
    push r15

    sub rsp,288
    mov [rsp],r8
    mov [rsp+8],r9
    mov [rsp+272],rcx
    mov [rsp+280],rdx
    
    mov rdi,[rdx+24]
    mov rsi,[rdx+16]
    mov rbx,[rdx+8]
    mov rax,[rdx]

    xor rbp,rbp
    sub rdi,[rcx+24]
    sbb rsi,[rcx+16]
    mov r15,rdi
    sbb rbx,[rcx+8]
    sbb rax,[rcx]
    mov r14,rsi
    sbb rbp,0

    add rdi,0FFFFFFFFFFFFFFFFh
    mov r13,rbx
    mov rdx,0FFFFFFFF00000000h
    adcx rsi,rdx
    adc rbx,0FFFFFFFFFFFFFFFFh
    mov r12,rax
    mov rdx,0FFFFFFFEFFFFFFFFh
    adcx rax,rdx

    test rbp,rbp

    cmovz rdi,r15
    cmovz rsi,r14
    cmovz rbx,r13
    cmovz rax,r12

    lea rcx,[rcx+64]
    call _sm2_naked_mul_stack_rcx

    mov [rcx+24],r11
    mov [rcx+16],r10
    mov [rcx+8],r9
    mov [rcx],r8

    call _sm2_naked_sqr
    ;x2-x1, A ||

    mov rdi,r11
    mov rsi,r10
    mov rbx,r9
    mov rax,r8
    mov rcx,[rsp+272]

    call _sm2_naked_mul_stack_rcx
    ;A, B ||

    mov [rcx+24],r11
    mov [rcx+16],r10
    mov [rcx+8],r9
    mov [rcx],r8
    ;A, B ||

    mov rcx,[rsp+280]
    
    call _sm2_naked_mul_stack_rcx
    ;A, C ||
    
    mov [rsp+72],r11
    mov [rsp+64],r10
    mov [rsp+56],r9
    mov [rsp+48],r8
    ;A, C || , C

    mov rcx,[rsp+8]

    mov [rcx+24],rdi
    mov [rcx+16],rsi
    mov [rcx+8],rbx
    mov [rcx],rax
    
    mov rcx,[rsp+272]

    xor rbp,rbp
    sub r11,[rcx+24]
    sbb r10,[rcx+16]
    mov rdi,r11
    sbb r9,[rcx+8]
    sbb r8,[rcx]
    mov rsi,r10
    sbb rbp,0

    add r11,0FFFFFFFFFFFFFFFFh
    mov rbx,r9
    mov rdx,0FFFFFFFF00000000h
    adcx r10,rdx
    adc r9,0FFFFFFFFFFFFFFFFh
    mov rax,r8
    mov rdx,0FFFFFFFEFFFFFFFFh
    adcx r8,rdx

    test rbp,rbp

    cmovnz rdi,r11
    cmovnz rsi,r10
    cmovnz rbx,r9
    cmovnz rax,r8
    ;C-B, || , C

    mov rcx,[rsp+8]
    
    mov [rcx+56],rdi
    mov [rcx+48],rsi
    mov [rcx+40],rbx
    mov [rcx+32],rax

    mov rcx,[rsp+272]
    lea rcx,[rcx+32]

    call _sm2_naked_mul_stack_rcx
    ;C-B, y1*(C-B) ||, C

    mov rdi,[rcx+24]
    mov rsi,[rcx+16]
    mov rbx,[rcx+8]
    mov rax,[rcx]
    
    mov [rcx+24],r11
    mov [rcx+16],r10
    mov [rcx+8],r9
    mov [rcx],r8
    ;y1, ||, C

    mov rcx,[rsp+280]

    xor rbp,rbp
    sub rdi,[rcx+56]
    sbb rsi,[rcx+48]
    mov r15,rdi
    sbb rbx,[rcx+40]
    sbb rax,[rcx+32]
    mov r14,rsi
    sbb rbp,0

    add rdi,0FFFFFFFFFFFFFFFFh
    mov r13,rbx
    mov rdx,0FFFFFFFF00000000h
    adcx rsi,rdx
    adc rbx,0FFFFFFFFFFFFFFFFh
    mov r12,rax
    mov rdx,0FFFFFFFEFFFFFFFFh
    adcx rax,rdx

    test rbp,rbp

    cmovz rdi,r15
    cmovz rsi,r14
    cmovz rbx,r13
    cmovz rax,r12
    ;y1-y2, ||, C

    call _sm2_naked_sqr
    ;y1-y2, D ||, C

    xor rbp,rbp
    sub r11,[rsp+72]
    sbb r10,[rsp+64]
    mov r15,r11
    sbb r9,[rsp+56]
    sbb r8,[rsp+48]
    mov r14,r10
    sbb rbp,0

    add r11,0FFFFFFFFFFFFFFFFh
    mov r13,r9
    mov rdx,0FFFFFFFF00000000h
    adcx r10,rdx
    adc r9,0FFFFFFFFFFFFFFFFh
    mov r12,r8
    mov rdx,0FFFFFFFEFFFFFFFFh
    adcx r8,rdx

    test rbp,rbp

    cmovz r11,r15
    cmovz r10,r14
    cmovz r9,r13
    cmovz r8,r12
    ;y1-y2, D-C ||, C

    mov rcx,[rsp+272]

    xor rbp,rbp
    sub r11,[rcx+24]
    sbb r10,[rcx+16]
    mov r15,r11
    sbb r9,[rcx+8]
    sbb r8,[rcx]
    mov r14,r10
    sbb rbp,0

    add r11,0FFFFFFFFFFFFFFFFh
    mov r13,r9
    mov rdx,0FFFFFFFF00000000h
    adcx r10,rdx
    adc r9,0FFFFFFFFFFFFFFFFh
    mov r12,r8
    mov rdx,0FFFFFFFEFFFFFFFFh
    adcx r8,rdx

    test rbp,rbp

    cmovz r11,r15
    cmovz r10,r14
    cmovz r9,r13
    cmovz r8,r12
    ;y1-y2, D-C-B ||, C

    mov rbp,[rsp]
    mov [rbp+24],r11
    mov [rbp+16],r10
    mov [rbp+8],r9
    mov [rbp],r8
    
    xor rbp,rbp
    sub r11,[rcx+24]
    sbb r10,[rcx+16]
    mov r15,r11
    sbb r9,[rcx+8]
    sbb r8,[rcx]
    mov r14,r10
    sbb rbp,0

    add r11,0FFFFFFFFFFFFFFFFh
    mov r13,r9
    mov rdx,0FFFFFFFF00000000h
    adcx r10,rdx
    adc r9,0FFFFFFFFFFFFFFFFh
    mov r12,r8
    mov rdx,0FFFFFFFEFFFFFFFFh
    adcx r8,rdx

    test rbp,rbp

    cmovz r11,r15
    cmovz r10,r14
    cmovz r9,r13
    cmovz r8,r12
    ;y1-y2, D-C-B-B=x3-B ||, C

    mov [rsp+40],r11
    mov [rsp+32],r10
    mov [rsp+24],r9
    mov [rsp+16],r8

    lea rcx,[rsp+16]
    call _sm2_naked_mul_stack_rcx
    ;y1-y2, (y1-y2)*(x3-B) || x3-B, C

    mov rcx,[rsp+272]

    xor rbp,rbp
    sub r11,[rcx+56]
    sbb r10,[rcx+48]
    mov r15,r11
    sbb r9,[rcx+40]
    sbb r8,[rcx+32]
    mov r14,r10
    sbb rbp,0

    add r11,0FFFFFFFFFFFFFFFFh
    mov r13,r9
    mov rdx,0FFFFFFFF00000000h
    adcx r10,rdx
    adc r9,0FFFFFFFFFFFFFFFFh
    mov r12,r8
    mov rdx,0FFFFFFFEFFFFFFFFh
    adcx r8,rdx

    test rbp,rbp

    cmovz r11,r15
    cmovz r10,r14
    cmovz r9,r13
    cmovz r8,r12

    mov rcx,[rsp]

    mov [rcx+56],r11
    mov [rcx+48],r10
    mov [rcx+40],r9
    mov [rcx+32],r8



    ;||[rax,rbx,rsi,rdi][r8,r9,r10,r11](rbp,r12,r13,r14,r15)rcx,rdx|rsp+8||||r8=[rsp]||r9=[rsp+8]||rcx=[rsp+272]||rdx=[rsp+280]
    ;||一[[rsp+16][rsp+24][rsp+32][rsp+40]]||二[[rsp+48][rsp+56][rsp+64][rsp+72]]||三[[rsp+80][rsp+88][rsp+96][rsp+104]]||四[[rsp+112][rsp+120][rsp+128][rsp+136]]
    ;||五[[rsp+144][rsp+152][rsp+160][rsp+168]]||六[[rsp+176][rsp+184][rsp+192][rsp+200]]||七[[rsp+208][rsp+216][rsp+224][rsp+232]]||八[[rsp+240][rsp+248][rsp+256][rsp+264]]||[rsp+272][rsp+280]


    add rsp,288

    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    pop rdi
    pop rsi
    pop rbx
    ret
jacobian_point_add_z1_equ_z2_lambda endp

;只能用于求a^(-1) ( mod p )
_uint256_inv_pre_pro proc EXPORT FRAME
    .endprolog

    push rbx
    push rsi
    push rdi
    push rbp
    push r12
    push r13
    push r14
    push r15

    push r8

    ;rax里面是k，这里初始化k为0
    xor rax,rax

    ;rcx里面是a的指针，这里初始化了v
    mov rdi,[rcx]
    mov r9,[rcx+8]
    mov r10,[rcx+16]
    mov r11,[rcx+24]

    ;rdx里面是p的指针，这里初始化了u
    mov r12,[rdx]
    mov r13,[rdx+8]
    mov r14,[rdx+16]
    mov r15,[rdx+24]

    ;初始化s和r。s初始化直接存入栈；由于第一个循环必然从test_v开始，所以r先在空区初始化
    mov [rsp-40],rax
    mov [rsp-48],rax
    mov [rsp-56],rax

    xor rsi,rsi
    inc rsi
    mov [rsp-64],rsi

    xor rsi,rsi
    xor r8,r8
    xor rbx,rbx
    xor rbp,rbp

    ;

    test_v:

    ;这里检查v的奇偶性，奇数时跳转
    tzcnt rcx,r11
    jz store_r_and_cmp_u_v

    v_is_even:
    add rax,rcx
    shrd r11,r10,cl
    shrd r10,r9,cl
    shrd r9,rdi,cl
    shr rdi,cl
    ;r乘以2
    shld rbp,rbx,cl
    
    ;如果进位，那么r需要加上p在2e256元域上的负元
    jc r_sub_p

    shld rbx,r8,cl
    shld r8,rsi,cl
    shl rsi,cl

    test_v_again:
    tzcnt rcx,r11
    jnz v_is_even

    store_r_and_cmp_u_v:
    ;把r存回去
    mov [rsp-8],rbp
    mov [rsp-16],rbx
    mov [rsp-24],r8
    mov [rsp-32],rsi
    ;jmp cmp_u_v

    ;

    cmp_u_v:
    inc rax

    ;把v搬运到空区
    mov rbp,rdi
    mov rbx,r9
    mov r8,r10
    mov rsi,r11
    ;在空区计算v-u
    sub rsi,r15
    sbb r8,r14
    sbb rbx,r13
    sbb rbp,r12

    ;如果借位，说明u>v，跳转到u更大情况的处理区
    jc u_is_greater

    ;v = (v - u) >> 1
    mov rdi,rbp
    mov r9,rbx
    mov r10,r8
    mov r11,rsi
    shr rdi,1
    rcr r9,1
    rcr r10,1
    rcr r11,1
    
    ;把s加载进来
    mov rsi,[rsp-64]
    mov r8,[rsp-56]
    mov rbx,[rsp-48]
    mov rbp,[rsp-40]
    
    ;s = s + r
    add rsi,[rsp-32]
    adc r8,[rsp-24]
    adc rbx,[rsp-16]
    adc rbp,[rsp-8]

    ;如果进位，那么s需要加上p在2e256元域上的负元
    jc s_sub_p_cmp_v

    store_s_cmp_v:
    ;把s存回去
    mov [rsp-40],rbp
    mov [rsp-48],rbx
    mov [rsp-56],r8
    mov [rsp-64],rsi

    ;把r加载进来
    mov rsi,[rsp-32]
    mov r8,[rsp-24]
    mov rbx,[rsp-16]
    mov rbp,[rsp-8]

    ;r乘以2
    shl rsi,1
    rcl r8,1
    rcl rbx,1
    rcl rbp,1

    ;如果进位，那么r需要加上p在2e256元域上的负元
    jc r_sub_p_cmp_v

    ;把r存回去
    store_r_cmp_v:

    test r11,r11
    jnz test_v
    test r10,r10
    jnz test_v
    test r9,r9
    jnz test_v
    test rdi,rdi
    jnz test_v
    jmp ret_out

    ;

    u_is_greater:

    sub r15,r11
    sbb r14,r10
    sbb r13,r9
    sbb r12,rdi

    shr r12,1
    rcr r13,1
    rcr r14,1
    rcr r15,1

    ;把r加载进来
    mov rsi,[rsp-32]
    mov r8,[rsp-24]
    mov rbx,[rsp-16]
    mov rbp,[rsp-8]

    ;r = r + s
    add rsi,[rsp-64]
    adc r8,[rsp-56]
    adc rbx,[rsp-48]
    adc rbp,[rsp-40]

    ;如果进位，那么r需要加上p在2e256元域上的负元
    jc r_sub_p_cmp_u

    store_r_cmp_u:
    ;把r存回去
    mov [rsp-8],rbp
    mov [rsp-16],rbx
    mov [rsp-24],r8
    mov [rsp-32],rsi

    ;把s加载进来
    mov rsi,[rsp-64]
    mov r8,[rsp-56]
    mov rbx,[rsp-48]
    mov rbp,[rsp-40]

    ;s乘以2
    shl rsi,1
    rcl r8,1
    rcl rbx,1
    rcl rbp,1

    ;shl qword ptr [rsp-64],1
    ;rcl qword ptr [rsp-56],1
    ;rcl qword ptr [rsp-48],1
    ;rcl qword ptr [rsp-40],1

    ;如果进位，那么s需要加上p在2e256元域上的负元
    jc s_sub_p_cmp_u

    ;把s存回去
    store_s_cmp_u:

    test_u:

    ;检查u的奇偶性，奇数时跳转
    tzcnt rcx,r15
    jz store_s_and_cmp_u_v

    u_is_even:
    add rax,rcx
    shrd r15,r14,cl
    shrd r14,r13,cl
    shrd r13,r12,cl
    shr r12,cl
    ;s乘以2
    shld rbp,rbx,cl
    
    ;如果进位，那么s需要加上p在2e256元域上的负元
    jc s_sub_p

    shld rbx,r8,cl
    shld r8,rsi,cl
    shl rsi,cl

    test_u_again:
    tzcnt rcx,r15
    jnz u_is_even

    store_s_and_cmp_u_v:
    ;把s存回去
    mov [rsp-40],rbp
    mov [rsp-48],rbx
    mov [rsp-56],r8
    mov [rsp-64],rsi
    jmp cmp_u_v

    s_sub_p:
    shld rbx,r8,cl
    shld r8,rsi,cl
    shl rsi,cl
    sub rsi,[rdx+24]
    sbb r8,[rdx+16]
    sbb rbx,[rdx+8]
    sbb rbp,[rdx]
    ;把s存回去
    mov [rsp-40],rbp
    mov [rsp-48],rbx
    mov [rsp-56],r8
    mov [rsp-64],rsi
    jmp cmp_u_v

    ;

    s_sub_p_cmp_u:
    sub rsi,[rdx+24]
    sbb r8,[rdx+16]
    sbb rbx,[rdx+8]
    sbb rbp,[rdx]
    jmp store_s_cmp_u

    r_sub_p_cmp_u:
    sub rsi,[rdx+24]
    sbb r8,[rdx+16]
    sbb rbx,[rdx+8]
    sbb rbp,[rdx]
    jmp store_r_cmp_u

    ;

    r_sub_p:
    shld rbx,r8,cl
    shld r8,rsi,cl
    shl rsi,cl
    sub rsi,[rdx+24]
    sbb r8,[rdx+16]
    sbb rbx,[rdx+8]
    sbb rbp,[rdx]

    mov [rsp-8],rbp
    mov [rsp-16],rbx
    mov [rsp-24],r8
    mov [rsp-32],rsi
    jmp cmp_u_v

    s_sub_p_cmp_v:
    sub rsi,[rdx+24]
    sbb r8,[rdx+16]
    sbb rbx,[rdx+8]
    sbb rbp,[rdx]
    jmp store_s_cmp_v

    r_sub_p_cmp_v:
    sub rsi,[rdx+24]
    sbb r8,[rdx+16]
    sbb rbx,[rdx+8]
    sbb rbp,[rdx]
    jmp store_r_cmp_v
    
    ;

    ret_out:

    ;加载p
    mov r12,[rdx]
    mov r13,[rdx+8]
    mov r14,[rdx+16]
    mov r15,[rdx+24]

    sub r15,rsi
    sbb r14,r8
    sbb r13,rbx
    sbb r12,rbp

    jnc result

    add r15,[rdx+24]
    adc r14,[rdx+16]
    adc r13,[rdx+8]
    adc r12,[rdx]

    result:

    pop r8

    mov [r8+24],r15
    mov [r8+16],r14
    mov [r8+8],r13
    mov [r8],r12

    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    pop rdi
    pop rsi
    pop rbx

    ret
_uint256_inv_pre_pro endp

_sm2_mul_ori proc EXPORT FRAME
    .endprolog

    push rbx
    push rsi
    push rdi
    push rbp
    push r12
    push r13
    push r14
    push r15

    push rdx
    push r8
    
    ;vmovdqa xmm0,xmmword ptr [rcx]
    ;vmovdqa xmm1,xmmword ptr [rcx+16]

    mov rax,[rdx]
    mov rbx,[rdx+8]
    mov rsi,[rdx+16]
    mov rdi,[rdx+24]


    ;vpextrq rdx,xmm1,1 ;把a0放到rdx
    mov rdx,[rcx+24]

    mulx r15,r9,rdi ;a0乘以b0，低位给t0，高位给c

    mulx rbp,r8,rsi ;a0乘以b1，低位给t1，高位给rbp
    add r8,r15 ;低位加c更新t1

    mulx r14,r12,rbx ;a0乘以b2，低位给t2，高位给r14
    adcx r12,rbp ;低位加c更新t2

    mulx r11,r13,rax ;a0乘以b3，低位给t3，高位给t4
    adcx r13,r14 ;低位加c更新t3
    adc r11,0 ;高位带进位加0来更新t4

    ;

    mov rdx,r9 ;把t0放到rdx
    xor r10,r10 ;t5必然是0

    add r8,r9
    adc r12,0
    adc r13,0
    adcx r11,r9
    adc r10,0

    shr r9,32
    shl rdx,32

    sub r8,rdx
    sbb r12,r9
    sbb r13,rdx
    sbb r11,r9
    sbb r10,0

    ;数组t进行一组轮换
    
    ;vmovq rdx,xmm1 ;把a1放到rdx
    mov rdx,[rcx+16]
    xor r9,r9 ;t5清零

    mulx r15,rbp,rdi ;a1乘以b0，低位给rbp，高位给r15
    add r8,rbp ;低位加t0更新t0

    mulx r14,rbp,rsi ;a1乘以b1，低位给rbp，高位给r14
    adcx rbp,r15 ;低位加c
    adc r14,0 ;高位带进位加0
    adcx rbp,r12 ;低位加t1
    mov r12,rbp ;低位给t1

    mulx r15,rbp,rbx ;a1乘以b2，低位给rbp，高位给r15
    adcx rbp,r14 ;低位加c
    adc r15,0 ;高位带进位加0
    adcx rbp,r13 ;低位加t2
    mov r13,rbp ;低位给t2

    mulx r14,rbp,rax ;a1乘以b3，低位给rbp，高位给r14
    adcx rbp,r15 ;低位加c
    adc r14,0 ;高位带进位加0
    adcx rbp,r11 ;低位加t3
    mov r11,rbp ;低位给t3

    ;xor r9,r9 ;t5清零
    adcx r10,r14 ;高位加t4更新t4
    adc r9,0 ;t5带进位加0
    
    ;

    mov rdx,r8 ;把t0放到rdx

    add r12,r8
    adc r13,0
    adc r11,0
    adcx r10,r8
    adc r9,0

    shr r8,32
    shl rdx,32

    sub r12,rdx
    sbb r13,r8
    sbb r11,rdx
    sbb r10,r8
    sbb r9,0

    ;数组t进行一组轮换
    
    ;vpextrq rdx,xmm0,1 ;把a2放到rdx
    mov rdx,[rcx+8]
    xor r8,r8 ;t5清零

    mulx r15,rbp,rdi ;a2乘以b0，低位给rbp，高位给c
    add r12,rbp ;低位加t0更新t0

    mulx r14,rbp,rsi ;a2乘以b1，低位给rbp，高位给r14
    adcx rbp,r15 ;低位加c
    adc r14,0 ;高位带进位加0
    add rbp,r13 ;低位加t1
    mov r13,rbp ;低位给t1

    mulx r15,rbp,rbx ;a2乘以b2，低位给rbp，高位给r14
    adcx rbp,r14 ;低位加c
    adc r15,0 ;高位带进位加0
    add rbp,r11 ;低位加t2
    mov r11,rbp ;低位给t2

    mulx r14,rbp,rax ;a2乘以b3，低位给rbp，高位给r14
    adcx rbp,r15 ;低位加c
    adc r14,0 ;高位带进位加0
    add rbp,r10 ;低位加t3
    mov r10,rbp ;低位给t3

    ;xor r8,r8 ;t5清零
    adcx r9,r14 ;高位加t4更新t4
    adc r8,0 ;t5带进位加0

    ;
    
    mov rdx,r12 ;把t0放到rdx

    add r13,r12
    adc r11,0
    adc r10,0
    adcx r9,r12
    adc r8,0

    shr r12,32
    shl rdx,32

    sub r13,rdx
    sbb r11,r12
    sbb r10,rdx
    sbb r9,r12
    sbb r8,0

    ;数组t进行一组轮换
    
    ;vmovq rdx,xmm0 ;把a3放到rdx
    mov rdx,[rcx]
    xor r12,r12 ;t5清零

    mulx r15,rbp,rdi ;a3乘以b0，低位给rbp，高位给c
    add r13,rbp ;低位加t0更新t0

    mulx r14,rbp,rsi ;a3乘以b1，低位给rbp，高位给r14
    adcx rbp,r15 ;低位加c
    adc r14,0 ;高位带进位加0
    add rbp,r11 ;低位加t1
    mov r11,rbp ;低位给t1

    mulx r15,rbp,rbx ;a3乘以b2，低位给rbp，高位给r14
    adcx rbp,r14 ;低位加c
    adc r15,0 ;高位带进位加0
    add rbp,r10 ;低位加t2
    mov r10,rbp ;低位给t2

    mulx r14,rbp,rax ;a3乘以b3，低位给rbp，高位给r14
    adcx rbp,r15 ;低位加c
    adc r14,0 ;高位带进位加0
    add rbp,r9 ;低位加t3
    mov r9,rbp ;低位给t3

    ;xor r12,r12 ;t5清零
    adcx r8,r14 ;高位加t4更新t4
    adc r12,0 ;t5带进位加0
    
    ;

    mov rdx,r13 ;把t0放到rdx

    add r11,r13
    adc r10,0
    adc r9,0
    adcx r8,r13
    adc r12,0

    shr r13,32
    shl rdx,32

    sub r11,rdx
    sbb r10,r13
    mov r15,r11
    sbb r9,rdx
    sbb r8,r13
    mov r14,r10
    sbb r12,0

    ;数组t进行一组轮换

    ;test r12,1

    ;mov rax,r12

    ;jnz sub_p

    ;ret

    sub_p:
    
    sub r11,0FFFFFFFFFFFFFFFFh
    mov rdx,0FFFFFFFF00000000h
    sbb r10,rdx
    mov r13,r9
    sbb r9,0FFFFFFFFFFFFFFFFh
    mov rdx,0FFFFFFFEFFFFFFFFh
    mov rbp,r8
    sbb r8,rdx
    sbb r12,0

    cmovc r11,r15
    cmovc r10,r14
    cmovc r9,r13
    cmovc r8,rbp
    
    pop rdx

    mov [rdx],r8
    mov [rdx+8],r9
    mov [rdx+16],r10
    mov [rdx+24],r11

    pop rdx

    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    pop rdi
    pop rsi
    pop rbx

    ret
_sm2_mul_ori endp

p_j2a_pre proc EXPORT FRAME
    .endprolog
    push rbx
    push rsi
    push rdi
    push rbp
    push r12
    push r13
    push r14
    push r15
    
    sub rsp,128

    mov [rsp],rcx
    lea rcx,[rcx+32]
    mov [rsp+8],rcx
    mov [rsp+16],rdx
    mov [rsp+24],r8
    
    ;|| , ||p2+4
    ;||[rax,rbx,rsi,rdi]|[r8,r9,r10,r11]||rcx
    ;||  p2 |  p2+4 |  p_pre | lambda |
    ;||[rsp]|[rsp+8]|[rsp+16]|[rsp+24]|

    mov rdi,[rcx+56]
    mov rsi,[rcx+48]
    mov rbx,[rcx+40]
    mov rax,[rcx+32]

    call _sm2_naked_sqr
    
    ;|| p2+8, p2 ||p2+4
    ;||[rax,rbx,rsi,rdi]|[r8,r9,r10,r11]||rcx
    ;||  p2 |  p2+4 |  p_pre | lambda |
    ;||[rsp]|[rsp+8]|[rsp+16]|[rsp+24]|

    mov rcx,[rsp]
    mov [rcx+24],r11
    mov [rcx+16],r10
    mov [rcx+8],r9
    mov [rcx],r8

    lea rcx,[rcx+64]
    
    mov rdi,r11
    mov rsi,r10
    mov rbx,r9
    mov rax,r8

    call _sm2_naked_mul_stack_rcx
    
    ;|| p2, p2+4 ||p2+8
    ;||[rax,rbx,rsi,rdi]|[r8,r9,r10,r11]||rcx
    ;||  p2 |  p2+4 |  p_pre | lambda |
    ;||[rsp]|[rsp+8]|[rsp+16]|[rsp+24]|
    
    mov [rcx-8],r11
    mov [rcx-16],r10
    mov [rcx-24],r9
    mov [rcx-32],r8

    mov rcx,[rsp+16]
    lea rcx,[rcx+448]

    call _sm2_naked_mul_stack_rcx
    
    ;|| p2, p_pre+56 ||p_pre+56
    ;||[rax,rbx,rsi,rdi]|[r8,r9,r10,r11]||rcx
    ;||  p2 |  p2+4 |  p_pre | lambda |
    ;||[rsp]|[rsp+8]|[rsp+16]|[rsp+24]|
    
    mov [rcx+24],r11
    mov [rcx+16],r10
    mov [rcx+8],r9
    mov [rcx],r8
    
    mov [rcx+88],r11
    mov [rcx+80],r10
    mov [rcx+72],r9
    mov [rcx+64],r8

    mov rcx,[rsp+8]
    
    mov rdi,[rcx+24]
    mov rsi,[rcx+16]
    mov rbx,[rcx+8]
    mov rax,[rcx]

    mov rcx,[rsp+16]
    lea rcx,[rcx+480]
    
    call _sm2_naked_mul_stack_rcx
    
    ;|| p2+4, p_pre+60 ||p_pre+60
    ;||[rax,rbx,rsi,rdi]|[r8,r9,r10,r11]||rcx
    ;||  p2 |  p2+4 |  p_pre | lambda |
    ;||[rsp]|[rsp+8]|[rsp+16]|[rsp+24]|
    
    mov [rcx+24],r11
    mov [rcx+16],r10
    mov [rcx+8],r9
    mov [rcx],r8

    xor rbp,rbp
    mov r15,0FFFFFFFFFFFFFFFFh
    mov r14,0FFFFFFFF00000000h
    sub r15,r11
    mov r13,0FFFFFFFFFFFFFFFFh
    sbb r14,r10
    mov r12,0FFFFFFFEFFFFFFFFh
    mov r11,r15
    sbb r13,r9
    mov r10,r14
    sbb r12,r8
    mov r9,r13
    sbb rbp,0
    
    add r15,0FFFFFFFFFFFFFFFFh
    mov rdx,0FFFFFFFF00000000h
    adcx r14,rdx
    mov r8,r12
    adc r13,0FFFFFFFFFFFFFFFFh
    mov rdx,0FFFFFFFEFFFFFFFFh
    adcx r12,rdx

    test rbp,rbp

    cmovnz r11,r15
    cmovnz r10,r14
    cmovnz r9,r13
    cmovnz r8,r12
    
    mov [rcx+88],r11
    mov [rcx+80],r10
    mov [rcx+72],r9
    mov [rcx+64],r8
    
    ;|| p2+4, p_pre+68 ||p_pre+60
    ;||[rax,rbx,rsi,rdi]|[r8,r9,r10,r11]||rcx
    ;||  p2 |  p2+4 |  p_pre | lambda |
    ;||[rsp]|[rsp+8]|[rsp+16]|[rsp+24]|

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    mov rcx,[rsp+24]
    lea rcx,[rcx+352]
    call _sm2_naked_mul_stack_rcx_self
    
    ;|| p2+4, || lambda+44

    mov rcx,[rsp+16]
    lea rcx,[rcx+416]
    call _sm2_naked_mul_stack_rcx
    
    ;|| p2+4, p_pre+52 || p_pre+52
    
    mov [rcx+24],r11
    mov [rcx+16],r10
    mov [rcx+8],r9
    mov [rcx],r8

    xor rbp,rbp
    mov r15,0FFFFFFFFFFFFFFFFh
    mov r14,0FFFFFFFF00000000h
    sub r15,r11
    mov r13,0FFFFFFFFFFFFFFFFh
    sbb r14,r10
    mov r12,0FFFFFFFEFFFFFFFFh
    mov r11,r15
    sbb r13,r9
    mov r10,r14
    sbb r12,r8
    mov r9,r13
    sbb rbp,0
    
    add r15,0FFFFFFFFFFFFFFFFh
    mov rdx,0FFFFFFFF00000000h
    adcx r14,rdx
    mov r8,r12
    adc r13,0FFFFFFFFFFFFFFFFh
    mov rdx,0FFFFFFFEFFFFFFFFh
    adcx r12,rdx

    test rbp,rbp

    cmovnz r11,r15
    cmovnz r10,r14
    cmovnz r9,r13
    cmovnz r8,r12
    
    mov [rcx+216],r11
    mov [rcx+208],r10
    mov [rcx+200],r9
    mov [rcx+192],r8
    
    ;|| p2+4, p_pre+76 || p_pre+52

    mov rcx,[rsp+24]
    lea rcx,[rcx+288]
    call _sm2_naked_mul_stack_rcx_self
    
    ;|| p2+4, || lambda+36

    mov rcx,[rsp+16]
    lea rcx,[rcx+352]
    call _sm2_naked_mul_stack_rcx
    
    ;|| p2+4, p_pre+44 || p_pre+44
    
    mov [rcx+24],r11
    mov [rcx+16],r10
    mov [rcx+8],r9
    mov [rcx],r8

    xor rbp,rbp
    mov r15,0FFFFFFFFFFFFFFFFh
    mov r14,0FFFFFFFF00000000h
    sub r15,r11
    mov r13,0FFFFFFFFFFFFFFFFh
    sbb r14,r10
    mov r12,0FFFFFFFEFFFFFFFFh
    mov r11,r15
    sbb r13,r9
    mov r10,r14
    sbb r12,r8
    mov r9,r13
    sbb rbp,0
    
    add r15,0FFFFFFFFFFFFFFFFh
    mov rdx,0FFFFFFFF00000000h
    adcx r14,rdx
    mov r8,r12
    adc r13,0FFFFFFFFFFFFFFFFh
    mov rdx,0FFFFFFFEFFFFFFFFh
    adcx r12,rdx

    test rbp,rbp

    cmovnz r11,r15
    cmovnz r10,r14
    cmovnz r9,r13
    cmovnz r8,r12
    
    mov [rcx+344],r11
    mov [rcx+336],r10
    mov [rcx+328],r9
    mov [rcx+320],r8
    
    ;|| p2+4, p_pre+84 || p_pre+44
    
    mov rcx,[rsp+24]
    lea rcx,[rcx+224]
    call _sm2_naked_mul_stack_rcx_self
    
    ;|| p2+4, || lambda+28

    mov rcx,[rsp+16]
    lea rcx,[rcx+288]
    call _sm2_naked_mul_stack_rcx
    
    ;|| p2+4, p_pre+36 || p_pre+36
    
    mov [rcx+24],r11
    mov [rcx+16],r10
    mov [rcx+8],r9
    mov [rcx],r8

    xor rbp,rbp
    mov r15,0FFFFFFFFFFFFFFFFh
    mov r14,0FFFFFFFF00000000h
    sub r15,r11
    mov r13,0FFFFFFFFFFFFFFFFh
    sbb r14,r10
    mov r12,0FFFFFFFEFFFFFFFFh
    mov r11,r15
    sbb r13,r9
    mov r10,r14
    sbb r12,r8
    mov r9,r13
    sbb rbp,0
    
    add r15,0FFFFFFFFFFFFFFFFh
    mov rdx,0FFFFFFFF00000000h
    adcx r14,rdx
    mov r8,r12
    adc r13,0FFFFFFFFFFFFFFFFh
    mov rdx,0FFFFFFFEFFFFFFFFh
    adcx r12,rdx

    test rbp,rbp

    cmovnz r11,r15
    cmovnz r10,r14
    cmovnz r9,r13
    cmovnz r8,r12
    
    mov [rcx+472],r11
    mov [rcx+464],r10
    mov [rcx+456],r9
    mov [rcx+448],r8
    
    ;|| p2+4, p_pre+92 || p_pre+36
    
    mov rcx,[rsp+24]
    lea rcx,[rcx+160]
    call _sm2_naked_mul_stack_rcx_self
    
    ;|| p2+4, || lambda+20

    mov rcx,[rsp+16]
    lea rcx,[rcx+224]
    call _sm2_naked_mul_stack_rcx
    
    ;|| p2+4, p_pre+28 || p_pre+28
    
    mov [rcx+24],r11
    mov [rcx+16],r10
    mov [rcx+8],r9
    mov [rcx],r8

    xor rbp,rbp
    mov r15,0FFFFFFFFFFFFFFFFh
    mov r14,0FFFFFFFF00000000h
    sub r15,r11
    mov r13,0FFFFFFFFFFFFFFFFh
    sbb r14,r10
    mov r12,0FFFFFFFEFFFFFFFFh
    mov r11,r15
    sbb r13,r9
    mov r10,r14
    sbb r12,r8
    mov r9,r13
    sbb rbp,0
    
    add r15,0FFFFFFFFFFFFFFFFh
    mov rdx,0FFFFFFFF00000000h
    adcx r14,rdx
    mov r8,r12
    adc r13,0FFFFFFFFFFFFFFFFh
    mov rdx,0FFFFFFFEFFFFFFFFh
    adcx r12,rdx

    test rbp,rbp

    cmovnz r11,r15
    cmovnz r10,r14
    cmovnz r9,r13
    cmovnz r8,r12
    
    mov [rcx+600],r11
    mov [rcx+592],r10
    mov [rcx+584],r9
    mov [rcx+576],r8
    
    ;|| p2+4, p_pre+100 || p_pre+28
    
    mov rcx,[rsp+24]
    lea rcx,[rcx+96]
    call _sm2_naked_mul_stack_rcx_self
    
    ;|| p2+4, || lambda+12

    mov rcx,[rsp+16]
    lea rcx,[rcx+160]
    call _sm2_naked_mul_stack_rcx
    
    ;|| p2+4, p_pre+20 || p_pre+20
    
    mov [rcx+24],r11
    mov [rcx+16],r10
    mov [rcx+8],r9
    mov [rcx],r8

    xor rbp,rbp
    mov r15,0FFFFFFFFFFFFFFFFh
    mov r14,0FFFFFFFF00000000h
    sub r15,r11
    mov r13,0FFFFFFFFFFFFFFFFh
    sbb r14,r10
    mov r12,0FFFFFFFEFFFFFFFFh
    mov r11,r15
    sbb r13,r9
    mov r10,r14
    sbb r12,r8
    mov r9,r13
    sbb rbp,0
    
    add r15,0FFFFFFFFFFFFFFFFh
    mov rdx,0FFFFFFFF00000000h
    adcx r14,rdx
    mov r8,r12
    adc r13,0FFFFFFFFFFFFFFFFh
    mov rdx,0FFFFFFFEFFFFFFFFh
    adcx r12,rdx

    test rbp,rbp

    cmovnz r11,r15
    cmovnz r10,r14
    cmovnz r9,r13
    cmovnz r8,r12
    
    mov [rcx+728],r11
    mov [rcx+720],r10
    mov [rcx+712],r9
    mov [rcx+704],r8
    
    ;|| p2+4, p_pre+108 || p_pre+20
    
    mov rcx,[rsp+24]
    lea rcx,[rcx+32]
    call _sm2_naked_mul_stack_rcx_self
    
    ;|| p2+4, || lambda+4

    mov rcx,[rsp+16]
    lea rcx,[rcx+96]
    call _sm2_naked_mul_stack_rcx
    
    ;|| p2+4, p_pre+12 || p_pre+12
    
    mov [rcx+24],r11
    mov [rcx+16],r10
    mov [rcx+8],r9
    mov [rcx],r8

    xor rbp,rbp
    mov r15,0FFFFFFFFFFFFFFFFh
    mov r14,0FFFFFFFF00000000h
    sub r15,r11
    mov r13,0FFFFFFFFFFFFFFFFh
    sbb r14,r10
    mov r12,0FFFFFFFEFFFFFFFFh
    mov r11,r15
    sbb r13,r9
    mov r10,r14
    sbb r12,r8
    mov r9,r13
    sbb rbp,0
    
    add r15,0FFFFFFFFFFFFFFFFh
    mov rdx,0FFFFFFFF00000000h
    adcx r14,rdx
    mov r8,r12
    adc r13,0FFFFFFFFFFFFFFFFh
    mov rdx,0FFFFFFFEFFFFFFFFh
    adcx r12,rdx

    test rbp,rbp

    cmovnz r11,r15
    cmovnz r10,r14
    cmovnz r9,r13
    cmovnz r8,r12
    
    mov [rcx+856],r11
    mov [rcx+848],r10
    mov [rcx+840],r9
    mov [rcx+832],r8
    
    ;|| p2+4, p_pre+116 || p_pre+12

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    mov rcx,[rsp]
    mov rdi,[rcx+24]
    mov rsi,[rcx+16]
    mov rbx,[rcx+8]
    mov rax,[rcx]
    
    ;|| p2, || p2
    
    mov rcx,[rsp+24]
    lea rcx,[rcx+320]
    call _sm2_naked_mul_stack_rcx_self
    
    ;|| p2, || lambda+40
    
    mov rcx,[rsp+16]
    lea rcx,[rcx+384]
    call _sm2_naked_mul_stack_rcx
    
    ;|| p2, p_pre+48 || p_pre+48

    mov [rcx+24],r11
    mov [rcx+16],r10
    mov [rcx+8],r9
    mov [rcx],r8
    mov [rcx+216],r11
    mov [rcx+208],r10
    mov [rcx+200],r9
    mov [rcx+192],r8
    
    mov rcx,[rsp+24]
    lea rcx,[rcx+256]
    call _sm2_naked_mul_stack_rcx_self
    
    ;|| p2, || lambda+32

    mov rcx,[rsp+16]
    lea rcx,[rcx+320]
    call _sm2_naked_mul_stack_rcx
    
    ;|| p2, p_pre+40 || p_pre+40

    mov [rcx+24],r11
    mov [rcx+16],r10
    mov [rcx+8],r9
    mov [rcx],r8
    mov [rcx+344],r11
    mov [rcx+336],r10
    mov [rcx+328],r9
    mov [rcx+320],r8

    mov rcx,[rsp+24]
    lea rcx,[rcx+192]
    call _sm2_naked_mul_stack_rcx_self
    
    ;|| p2, || lambda+24

    mov rcx,[rsp+16]
    lea rcx,[rcx+256]
    call _sm2_naked_mul_stack_rcx
    
    ;|| p2, p_pre+32 || p_pre+32

    mov [rcx+24],r11
    mov [rcx+16],r10
    mov [rcx+8],r9
    mov [rcx],r8
    mov [rcx+472],r11
    mov [rcx+464],r10
    mov [rcx+456],r9
    mov [rcx+448],r8

    mov rcx,[rsp+24]
    lea rcx,[rcx+128]
    call _sm2_naked_mul_stack_rcx_self
    
    ;|| p2, || lambda+16

    mov rcx,[rsp+16]
    lea rcx,[rcx+192]
    call _sm2_naked_mul_stack_rcx
    
    ;|| p2, p_pre+24 || p_pre+24

    mov [rcx+24],r11
    mov [rcx+16],r10
    mov [rcx+8],r9
    mov [rcx],r8
    mov [rcx+600],r11
    mov [rcx+592],r10
    mov [rcx+584],r9
    mov [rcx+576],r8
    
    mov rcx,[rsp+24]
    lea rcx,[rcx+64]
    call _sm2_naked_mul_stack_rcx_self
    
    ;|| p2, || lambda+8

    mov rcx,[rsp+16]
    lea rcx,[rcx+128]
    call _sm2_naked_mul_stack_rcx
    
    ;|| p2, p_pre+16 || p_pre+16

    mov [rcx+24],r11
    mov [rcx+16],r10
    mov [rcx+8],r9
    mov [rcx],r8
    mov [rcx+728],r11
    mov [rcx+720],r10
    mov [rcx+712],r9
    mov [rcx+704],r8

    mov rcx,[rsp+24]
    call _sm2_naked_mul_stack_rcx_self
    
    ;|| p2, || lambda

    mov rcx,[rsp+16]
    lea rcx,[rcx+64]
    call _sm2_naked_mul_stack_rcx
    
    ;|| p2, p_pre+8 || p_pre+8

    mov [rcx+24],r11
    mov [rcx+16],r10
    mov [rcx+8],r9
    mov [rcx],r8
    mov [rcx+856],r11
    mov [rcx+848],r10
    mov [rcx+840],r9
    mov [rcx+832],r8


    ;||[rax,rbx,rsi,rdi]|[r8,r9,r10,r11]||rcx
    ;||  p2 |  p2+4 |  p_pre | lambda |
    ;||[rsp]|[rsp+8]|[rsp+16]|[rsp+24]|

    add rsp,128

    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    pop rdi
    pop rsi
    pop rbx
    ret
p_j2a_pre endp


_sm2_point_double_stack1 proc EXPORT FRAME
    .endprolog

    push rbx
    push rsi
    push rdi
    push rbp
    push r12
    push r13
    push r14
    push r15
    
    push rcx

    sub rsp,176
    
    mov rax,[rcx]
    mov rbx,[rcx+8]
    mov rsi,[rcx+16]
    mov rdi,[rcx+24]
    mov [rsp+8],rax
    mov [rsp+16],rbx
    mov [rsp+24],rsi
    mov [rsp+32],rdi

    mov rax,[rcx+32]
    mov rbx,[rcx+40]
    mov rsi,[rcx+48]
    mov rdi,[rcx+56]
    mov [rsp+40],rax
    mov [rsp+48],rbx
    mov [rsp+56],rsi
    mov [rsp+64],rdi

    ;加载z
    mov rax,[rcx+64]
    mov rbx,[rcx+72]
    mov rsi,[rcx+80]
    mov rdi,[rcx+88]
    ;z | x, y

    call _sm2_point_double_stack_naked
    ;jmp release

    ; | x1, y1, z1

    mov rbp,rsp
    add rsp,176
    pop rdx
    
    mov rax,[rbp+8]
    mov rbx,[rbp+16]
    mov rsi,[rbp+24]
    mov rdi,[rbp+32]
    mov [rdx],rax
    mov [rdx+8],rbx
    mov [rdx+16],rsi
    mov [rdx+24],rdi
    
    mov rax,[rbp+40]
    mov rbx,[rbp+48]
    mov rsi,[rbp+56]
    mov rdi,[rbp+64]
    mov [rdx+32],rax
    mov [rdx+40],rbx
    mov [rdx+48],rsi
    mov [rdx+56],rdi
    
    mov rax,[rbp+72]
    mov rbx,[rbp+80]
    mov rsi,[rbp+88]
    mov rdi,[rbp+96]
    mov [rdx+64],rax
    mov [rdx+72],rbx
    mov [rdx+80],rsi
    mov [rdx+88],rdi


    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    pop rdi
    pop rsi
    pop rbx

    ret
_sm2_point_double_stack1 endp

_sm2_point_double_stack2 proc EXPORT FRAME
    .endprolog

    push rbx
    push rsi
    push rdi
    push rbp
    push r12
    push r13
    push r14
    push r15
    
    push rcx

    sub rsp,176
    
    mov rax,[rcx]
    mov rbx,[rcx+8]
    mov rsi,[rcx+16]
    mov rdi,[rcx+24]
    mov [rsp+8],rax
    mov [rsp+16],rbx
    mov [rsp+24],rsi
    mov [rsp+32],rdi

    mov rax,[rcx+32]
    mov rbx,[rcx+40]
    mov rsi,[rcx+48]
    mov rdi,[rcx+56]
    mov [rsp+40],rax
    mov [rsp+48],rbx
    mov [rsp+56],rsi
    mov [rsp+64],rdi

    ;加载z
    mov rax,[rcx+64]
    mov rbx,[rcx+72]
    mov rsi,[rcx+80]
    mov rdi,[rcx+88]
    ;z | x, y

    call _sm2_point_double_stack_naked
    ;jmp release

    ; | x1, y1, z1

    
    mov rax,[rsp+72]
    mov rbx,[rsp+80]
    mov rsi,[rsp+88]
    mov rdi,[rsp+96]

    call _sm2_point_double_stack_naked


    mov rbp,rsp
    add rsp,176
    pop rdx
    
    mov rax,[rbp+8]
    mov rbx,[rbp+16]
    mov rsi,[rbp+24]
    mov rdi,[rbp+32]
    mov [rdx],rax
    mov [rdx+8],rbx
    mov [rdx+16],rsi
    mov [rdx+24],rdi
    
    mov rax,[rbp+40]
    mov rbx,[rbp+48]
    mov rsi,[rbp+56]
    mov rdi,[rbp+64]
    mov [rdx+32],rax
    mov [rdx+40],rbx
    mov [rdx+48],rsi
    mov [rdx+56],rdi
    
    mov rax,[rbp+72]
    mov rbx,[rbp+80]
    mov rsi,[rbp+88]
    mov rdi,[rbp+96]
    mov [rdx+64],rax
    mov [rdx+72],rbx
    mov [rdx+80],rsi
    mov [rdx+88],rdi


    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    pop rdi
    pop rsi
    pop rbx

    ret
_sm2_point_double_stack2 endp

_sm2_point_double_stack3 proc EXPORT FRAME
    .endprolog

    push rbx
    push rsi
    push rdi
    push rbp
    push r12
    push r13
    push r14
    push r15
    
    push rcx

    sub rsp,176
    
    mov rax,[rcx]
    mov rbx,[rcx+8]
    mov rsi,[rcx+16]
    mov rdi,[rcx+24]
    mov [rsp+8],rax
    mov [rsp+16],rbx
    mov [rsp+24],rsi
    mov [rsp+32],rdi

    mov rax,[rcx+32]
    mov rbx,[rcx+40]
    mov rsi,[rcx+48]
    mov rdi,[rcx+56]
    mov [rsp+40],rax
    mov [rsp+48],rbx
    mov [rsp+56],rsi
    mov [rsp+64],rdi

    ;加载z
    mov rax,[rcx+64]
    mov rbx,[rcx+72]
    mov rsi,[rcx+80]
    mov rdi,[rcx+88]
    ;z | x, y

    call _sm2_point_double_stack_naked
    ;jmp release

    ; | x1, y1, z1

    mov rax,[rsp+72]
    mov rbx,[rsp+80]
    mov rsi,[rsp+88]
    mov rdi,[rsp+96]

    call _sm2_point_double_stack_naked

    mov rax,[rsp+72]
    mov rbx,[rsp+80]
    mov rsi,[rsp+88]
    mov rdi,[rsp+96]

    call _sm2_point_double_stack_naked


    mov rbp,rsp
    add rsp,176
    pop rdx
    
    mov rax,[rbp+8]
    mov rbx,[rbp+16]
    mov rsi,[rbp+24]
    mov rdi,[rbp+32]
    mov [rdx],rax
    mov [rdx+8],rbx
    mov [rdx+16],rsi
    mov [rdx+24],rdi
    
    mov rax,[rbp+40]
    mov rbx,[rbp+48]
    mov rsi,[rbp+56]
    mov rdi,[rbp+64]
    mov [rdx+32],rax
    mov [rdx+40],rbx
    mov [rdx+48],rsi
    mov [rdx+56],rdi
    
    mov rax,[rbp+72]
    mov rbx,[rbp+80]
    mov rsi,[rbp+88]
    mov rdi,[rbp+96]
    mov [rdx+64],rax
    mov [rdx+72],rbx
    mov [rdx+80],rsi
    mov [rdx+88],rdi


    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    pop rdi
    pop rsi
    pop rbx

    ret
_sm2_point_double_stack3 endp

_sm2_point_double_stack4 proc EXPORT FRAME
    .endprolog

    push rbx
    push rsi
    push rdi
    push rbp
    push r12
    push r13
    push r14
    push r15
    
    push rcx

    sub rsp,176
    
    mov rax,[rcx]
    mov rbx,[rcx+8]
    mov rsi,[rcx+16]
    mov rdi,[rcx+24]
    mov [rsp+8],rax
    mov [rsp+16],rbx
    mov [rsp+24],rsi
    mov [rsp+32],rdi

    mov rax,[rcx+32]
    mov rbx,[rcx+40]
    mov rsi,[rcx+48]
    mov rdi,[rcx+56]
    mov [rsp+40],rax
    mov [rsp+48],rbx
    mov [rsp+56],rsi
    mov [rsp+64],rdi

    ;加载z
    mov rax,[rcx+64]
    mov rbx,[rcx+72]
    mov rsi,[rcx+80]
    mov rdi,[rcx+88]
    ;z | x, y

    call _sm2_point_double_stack_naked
    ;jmp release

    ; | x1, y1, z1

    mov rax,[rsp+72]
    mov rbx,[rsp+80]
    mov rsi,[rsp+88]
    mov rdi,[rsp+96]

    call _sm2_point_double_stack_naked

    mov rax,[rsp+72]
    mov rbx,[rsp+80]
    mov rsi,[rsp+88]
    mov rdi,[rsp+96]

    call _sm2_point_double_stack_naked

    mov rax,[rsp+72]
    mov rbx,[rsp+80]
    mov rsi,[rsp+88]
    mov rdi,[rsp+96]

    call _sm2_point_double_stack_naked

    mov rbp,rsp
    add rsp,176
    pop rdx
    
    mov rax,[rbp+8]
    mov rbx,[rbp+16]
    mov rsi,[rbp+24]
    mov rdi,[rbp+32]
    mov [rdx],rax
    mov [rdx+8],rbx
    mov [rdx+16],rsi
    mov [rdx+24],rdi
    
    mov rax,[rbp+40]
    mov rbx,[rbp+48]
    mov rsi,[rbp+56]
    mov rdi,[rbp+64]
    mov [rdx+32],rax
    mov [rdx+40],rbx
    mov [rdx+48],rsi
    mov [rdx+56],rdi
    
    mov rax,[rbp+72]
    mov rbx,[rbp+80]
    mov rsi,[rbp+88]
    mov rdi,[rbp+96]
    mov [rdx+64],rax
    mov [rdx+72],rbx
    mov [rdx+80],rsi
    mov [rdx+88],rdi


    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    pop rdi
    pop rsi
    pop rbx

    ret
_sm2_point_double_stack4 endp


jacobian_point_tripling proc EXPORT FRAME
    .endprolog
    push rbx
    push rsi
    push rdi
    push rbp
    push r12
    push r13
    push r14
    push r15

    sub rsp,288
    ;mov [rsp+8],r8
    mov [rsp+272],rcx
    mov [rsp+280],rdx
    
    mov r11,[rcx+56]
    mov r10,[rcx+48]
    mov r9,[rcx+40]
    mov r8,[rcx+32]

    xor rbp,rbp
    shl r11,1
    rcl r10,1
    mov rdi,r11
    rcl r9,1
    rcl r8,1
    mov rsi,r10
    rcl rbp,1

    sub r11,0FFFFFFFFFFFFFFFFh
    mov rdx,0FFFFFFFF00000000h
    mov rbx,r9
    sbb r10,rdx
    sbb r9,0FFFFFFFFFFFFFFFFh
    mov rax,r8
    mov rdx,0FFFFFFFEFFFFFFFFh
    sbb r8,rdx
    sbb rbp,0
    
    cmovnc rdi,r11
    cmovnc rsi,r10
    cmovnc rbx,r9
    cmovnc rax,r8

    call _sm2_naked_sqr

    mov [rsp+40],rdi
    mov [rsp+32],rsi
    mov [rsp+24],rbx
    mov [rsp+16],rax
    ;2*y1, 4*yy || 2*y1

    mov rdi,r11
    mov rsi,r10
    mov rbx,r9
    mov rax,r8
    
    call _sm2_naked_sqr
    ;4*yy, t || 2*y1
    
    mov [rsp+72],rdi
    mov [rsp+64],rsi
    mov [rsp+56],rbx
    mov [rsp+48],rax

    mov [rsp+104],r11
    mov [rsp+96],r10
    mov [rsp+88],r9
    mov [rsp+80],r8

    ;4*yy, t || 2*y1, 4*yy, t

    mov rcx,[rsp+272]

    call _sm2_naked_mul_stack_rcx
    
    
    xor rbp,rbp
    mov rdi,r11
    mov rsi,r10
    shl r11,1
    mov rbx,r9
    rcl r10,1
    mov r15,r11
    mov rax,r8
    rcl r9,1
    rcl r8,1
    mov r14,r10
    rcl rbp,1

    sub r11,0FFFFFFFFFFFFFFFFh
    mov rdx,0FFFFFFFF00000000h
    mov r13,r9
    sbb r10,rdx
    sbb r9,0FFFFFFFFFFFFFFFFh
    mov r12,r8
    mov rdx,0FFFFFFFEFFFFFFFFh
    sbb r8,rdx
    sbb rbp,0
    
    cmovc r11,r15
    cmovc r10,r14
    cmovc r9,r13
    cmovc r8,r12

    xor rbp,rbp
    add r11,rdi
    adcx r10,rsi
    mov rdi,r11
    adcx r9,rbx
    adcx r8,rax
    mov rsi,r10
    adc rbp,0

    sub r11,0FFFFFFFFFFFFFFFFh
    mov rdx,0FFFFFFFF00000000h
    mov rbx,r9
    sbb r10,rdx
    sbb r9,0FFFFFFFFFFFFFFFFh
    mov rax,r8
    mov rdx,0FFFFFFFEFFFFFFFFh
    sbb r8,rdx
    sbb rbp,0

    cmovnc rdi,r11
    cmovnc rsi,r10
    mov [rsp+136],rdi
    mov [rsp+128],rsi
    cmovnc rbx,r9
    mov [rsp+120],rbx
    cmovnc rax,r8
    mov [rsp+112],rax
    
    mov rcx,[rsp+272]

    mov rdi,[rcx+88]
    mov rsi,[rcx+80]
    mov rbx,[rcx+72]
    mov rax,[rcx+64]

    call _sm2_naked_sqr
    ;z, zz || 2*y1, 4*yy, t, 12*x1*yy
    
    mov rcx,[rsp+272]
    mov rdi,[rcx+24]
    mov rsi,[rcx+16]
    mov rbx,[rcx+8]
    mov rax,[rcx]

    xor rbp,rbp
    sub rdi,r11
    sbb rsi,r10
    mov r15,rdi
    sbb rbx,r9
    sbb rax,r8
    mov r14,rsi
    sbb rbp,0

    add rdi,0FFFFFFFFFFFFFFFFh
    mov r13,rbx
    mov rdx,0FFFFFFFF00000000h
    adcx rsi,rdx
    adc rbx,0FFFFFFFFFFFFFFFFh
    mov r12,rax
    mov rdx,0FFFFFFFEFFFFFFFFh
    adcx rax,rdx

    test rbp,rbp

    cmovz rdi,r15
    cmovz rsi,r14
    cmovz rbx,r13
    cmovz rax,r12
    
    mov [rsp+168],rdi
    mov [rsp+160],rsi
    mov [rsp+152],rbx
    mov [rsp+144],rax
    ;x-zz, zz || 2*y1, 4*yy, t, 12*x1*yy, x-zz
    
    mov [rsp+200],r11
    mov [rsp+192],r10
    mov [rsp+184],r9
    mov [rsp+176],r8
    ;x-zz, zz || 2*y1, 4*yy, t, 12*x1*yy, x-zz, zz

    xor rbp,rbp
    add r11,[rcx+24]
    adcx r10,[rcx+16]
    mov rdi,r11
    adcx r9,[rcx+8]
    adcx r8,[rcx]
    mov rsi,r10
    adc rbp,0

    sub r11,0FFFFFFFFFFFFFFFFh
    mov rdx,0FFFFFFFF00000000h
    mov rbx,r9
    sbb r10,rdx
    sbb r9,0FFFFFFFFFFFFFFFFh
    mov rax,r8
    mov rdx,0FFFFFFFEFFFFFFFFh
    sbb r8,rdx
    sbb rbp,0

    cmovnc rdi,r11
    cmovnc rsi,r10
    cmovnc rbx,r9
    cmovnc rax,r8
    ;x+zz || 2*y1, 4*yy, t, x-zz, zz

    lea rcx,[rsp+144]
    call _sm2_naked_mul_stack_rcx
    ;x+zz, (x-zz)*(x+zz) || 2*y1, 4*yy, t, 12*x1*yy, x-zz, zz

    xor rbp,rbp
    mov rdi,r11
    mov rsi,r10
    shl r11,1
    mov rbx,r9
    rcl r10,1
    mov r15,r11
    mov rax,r8
    rcl r9,1
    rcl r8,1
    mov r14,r10
    rcl rbp,1

    sub r11,0FFFFFFFFFFFFFFFFh
    mov rdx,0FFFFFFFF00000000h
    mov r13,r9
    sbb r10,rdx
    sbb r9,0FFFFFFFFFFFFFFFFh
    mov r12,r8
    mov rdx,0FFFFFFFEFFFFFFFFh
    sbb r8,rdx
    sbb rbp,0
    
    cmovc r11,r15
    cmovc r10,r14
    cmovc r9,r13
    cmovc r8,r12

    xor rbp,rbp
    add r11,rdi
    adcx r10,rsi
    mov rdi,r11
    adcx r9,rbx
    adcx r8,rax
    mov rsi,r10
    adc rbp,0

    sub r11,0FFFFFFFFFFFFFFFFh
    mov rdx,0FFFFFFFF00000000h
    mov rbx,r9
    sbb r10,rdx
    sbb r9,0FFFFFFFFFFFFFFFFh
    mov rax,r8
    mov rdx,0FFFFFFFEFFFFFFFFh
    sbb r8,rdx
    sbb rbp,0

    cmovnc rdi,r11
    cmovnc rsi,r10
    mov [rsp+168],rdi
    mov [rsp+160],rsi
    cmovnc rbx,r9
    mov [rsp+152],rbx
    cmovnc rax,r8
    mov [rsp+144],rax
    ;m || 2*y1, 4*yy, t, 12*x1*yy, m, zz
    
    call _sm2_naked_sqr
    ;m, mm || 2*y1, 4*yy, t, 12*x1*yy, m, zz

    mov [rsp+232],r11
    mov [rsp+224],r10
    mov [rsp+216],r9
    mov [rsp+208],r8
    ;m, mm || 2*y1, 4*yy, t, 12*x1*yy, m, zz, mm
    
    mov rdi,[rsp+136]
    mov rsi,[rsp+128]
    mov rbx,[rsp+120]
    mov rax,[rsp+112]
    ;12*x1*yy, mm || 2*y1, 4*yy, t, 12*x1*yy, m, zz, mm

    xor rbp,rbp
    sub rdi,r11
    sbb rsi,r10
    mov r15,rdi
    sbb rbx,r9
    sbb rax,r8
    mov r14,rsi
    sbb rbp,0

    add rdi,0FFFFFFFFFFFFFFFFh
    mov r13,rbx
    mov rdx,0FFFFFFFF00000000h
    adcx rsi,rdx
    adc rbx,0FFFFFFFFFFFFFFFFh
    mov r12,rax
    mov rdx,0FFFFFFFEFFFFFFFFh
    adcx rax,rdx

    test rbp,rbp

    cmovz rdi,r15
    cmovz rsi,r14
    cmovz rbx,r13
    cmovz rax,r12
    
    call _sm2_naked_sqr
    ;e, ee || 2*y1, 4*yy, t, 12*x1*yy, m, zz, mm
    
    mov [rsp+264],r11
    mov [rsp+256],r10
    mov [rsp+248],r9
    mov [rsp+240],r8
    ;e, ee || 2*y1, 4*yy, t, 12*x1*yy, m, zz, mm, ee
    
    mov [rsp+136],rdi
    mov [rsp+128],rsi
    mov [rsp+120],rbx
    mov [rsp+112],rax
    ;e, ee || 2*y1, 4*yy, t, e, m, zz, mm, ee

    xor rbp,rbp
    add rdi,[rsp+168]
    adcx rsi,[rsp+160]
    mov r11,rdi
    adcx rbx,[rsp+152]
    adcx rax,[rsp+144]
    mov r10,rsi
    adc rbp,0

    sub r11,0FFFFFFFFFFFFFFFFh
    mov rdx,0FFFFFFFF00000000h
    mov r9,rbx
    sbb r10,rdx
    sbb r9,0FFFFFFFFFFFFFFFFh
    mov r8,rax
    mov rdx,0FFFFFFFEFFFFFFFFh
    sbb r8,rdx
    sbb rbp,0

    cmovnc rdi,r11
    cmovnc rsi,r10
    cmovnc rbx,r9
    cmovnc rax,r8

    call _sm2_naked_sqr
    ;m+e, (m+e)^2 || 2*y1, 4*yy, t, e, m, zz, mm, ee

    xor rbp,rbp
    sub r11,[rsp+232]
    sbb r10,[rsp+224]
    mov r15,r11
    sbb r9,[rsp+216]
    sbb r8,[rsp+208]
    mov r14,r10
    sbb rbp,0

    add r11,0FFFFFFFFFFFFFFFFh
    mov r13,r9
    mov rdx,0FFFFFFFF00000000h
    adcx r10,rdx
    adc r9,0FFFFFFFFFFFFFFFFh
    mov r12,r8
    mov rdx,0FFFFFFFEFFFFFFFFh
    adcx r8,rdx

    test rbp,rbp

    cmovz r11,r15
    cmovz r10,r14
    cmovz r9,r13
    cmovz r8,r12

    xor rbp,rbp
    sub r11,[rsp+264]
    sbb r10,[rsp+256]
    mov r15,r11
    sbb r9,[rsp+248]
    sbb r8,[rsp+240]
    mov r14,r10
    sbb rbp,0

    add r11,0FFFFFFFFFFFFFFFFh
    mov r13,r9
    mov rdx,0FFFFFFFF00000000h
    adcx r10,rdx
    adc r9,0FFFFFFFFFFFFFFFFh
    mov r12,r8
    mov rdx,0FFFFFFFEFFFFFFFFh
    adcx r8,rdx

    test rbp,rbp

    cmovz r11,r15
    cmovz r10,r14
    cmovz r9,r13
    cmovz r8,r12

    xor rbp,rbp
    sub r11,[rsp+104]
    sbb r10,[rsp+96]
    mov rdi,r11
    sbb r9,[rsp+88]
    sbb r8,[rsp+80]
    mov rsi,r10
    sbb rbp,0

    add r11,0FFFFFFFFFFFFFFFFh
    mov rbx,r9
    mov rdx,0FFFFFFFF00000000h
    adcx r10,rdx
    adc r9,0FFFFFFFFFFFFFFFFh
    mov rax,r8
    mov rdx,0FFFFFFFEFFFFFFFFh
    adcx r8,rdx

    test rbp,rbp

    cmovnz rdi,r11
    cmovnz rsi,r10
    cmovnz rbx,r9
    cmovnz rax,r8
    ;u, || 2*y1, 4*yy, t, e, m, zz, mm, ee

    lea rcx,[rsp+48]
    call _sm2_naked_mul_stack_rcx
    ;u, 4*yy*u || 2*y1, 4*yy, t, e, m, zz, mm, ee

    mov [rsp+232],rdi
    mov [rsp+224],rsi
    mov [rsp+216],rbx
    mov [rsp+208],rax
    mov [rsp+72],r11
    mov [rsp+64],r10
    mov [rsp+56],r9
    mov [rsp+48],r8
    ;u, 4*yy*u || 2*y1, 4*yy*u, t, e, m, zz, u, ee
    
    mov rdi,[rsp+264]
    mov rsi,[rsp+256]
    mov rbx,[rsp+248]
    mov rax,[rsp+240]
    mov rcx,[rsp+272]

    call _sm2_naked_mul_stack_rcx
    ;ee, x1*ee || 2*y1, 4*yy*u, t, e, m, zz, u, ee
    
    xor rbp,rbp
    sub r11,[rsp+72]
    sbb r10,[rsp+64]
    mov r15,r11
    sbb r9,[rsp+56]
    sbb r8,[rsp+48]
    mov r14,r10
    sbb rbp,0

    add r11,0FFFFFFFFFFFFFFFFh
    mov r13,r9
    mov rdx,0FFFFFFFF00000000h
    adcx r10,rdx
    adc r9,0FFFFFFFFFFFFFFFFh
    mov r12,r8
    mov rdx,0FFFFFFFEFFFFFFFFh
    adcx r8,rdx

    test rbp,rbp

    cmovz r11,r15
    cmovz r10,r14
    cmovz r9,r13
    cmovz r8,r12

    xor rbp,rbp
    shl r11,1
    rcl r10,1
    mov r15,r11
    rcl r9,1
    rcl r8,1
    mov r14,r10
    rcl rbp,1

    sub r11,0FFFFFFFFFFFFFFFFh
    mov rdx,0FFFFFFFF00000000h
    mov r13,r9
    sbb r10,rdx
    sbb r9,0FFFFFFFFFFFFFFFFh
    mov r12,r8
    mov rdx,0FFFFFFFEFFFFFFFFh
    sbb r8,rdx
    sbb rbp,0
    
    cmovc r11,r15
    cmovc r10,r14
    cmovc r9,r13
    cmovc r8,r12

    xor rbp,rbp
    shl r11,1
    rcl r10,1
    mov r15,r11
    rcl r9,1
    rcl r8,1
    mov r14,r10
    rcl rbp,1

    sub r11,0FFFFFFFFFFFFFFFFh
    mov rdx,0FFFFFFFF00000000h
    mov r13,r9
    sbb r10,rdx
    sbb r9,0FFFFFFFFFFFFFFFFh
    mov r12,r8
    mov rdx,0FFFFFFFEFFFFFFFFh
    sbb r8,rdx
    sbb rbp,0
    
    cmovc r11,r15
    cmovc r10,r14
    cmovc r9,r13
    cmovc r8,r12
    ;ee, x3 || 2*y1, 4*yy*u, t, e, m, zz, u, ee

    mov rcx,[rsp+280]
    mov [rcx+24],r11
    mov [rcx+16],r10
    mov [rcx+8],r9
    mov [rcx],r8

    lea rcx,[rsp+112]
    call _sm2_naked_mul_stack_rcx
    
    mov [rsp+264],r11
    mov [rsp+256],r10
    mov [rsp+248],r9
    mov [rsp+240],r8
    ;ee, || 2*y1, 4*yy*u, t, e, m, zz, u, e*ee

    xor rbp,rbp
    add rdi,[rsp+200]
    adcx rsi,[rsp+192]
    mov r11,rdi
    adcx rbx,[rsp+184]
    adcx rax,[rsp+176]
    mov r10,rsi
    adc rbp,0

    sub r11,0FFFFFFFFFFFFFFFFh
    mov rdx,0FFFFFFFF00000000h
    mov r9,rbx
    sbb r10,rdx
    sbb r9,0FFFFFFFFFFFFFFFFh
    mov r8,rax
    mov rdx,0FFFFFFFEFFFFFFFFh
    sbb r8,rdx
    sbb rbp,0

    cmovnc rdi,r11
    cmovnc rsi,r10
    cmovnc rbx,r9
    cmovnc rax,r8
    
    mov [rsp+200],rdi
    mov [rsp+192],rsi
    mov [rsp+184],rbx
    mov [rsp+176],rax
    ; || 2*y1, 4*yy*u, t, e, m, ee+zz, u, e*ee

    mov rdi,[rsp+104]
    mov rsi,[rsp+96]
    mov rbx,[rsp+88]
    mov rax,[rsp+80]

    xor rbp,rbp
    sub rdi,[rsp+232]
    sbb rsi,[rsp+224]
    mov r15,rdi
    sbb rbx,[rsp+216]
    sbb rax,[rsp+208]
    mov r14,rsi
    sbb rbp,0

    add rdi,0FFFFFFFFFFFFFFFFh
    mov r13,rbx
    mov rdx,0FFFFFFFF00000000h
    adcx rsi,rdx
    adc rbx,0FFFFFFFFFFFFFFFFh
    mov r12,rax
    mov rdx,0FFFFFFFEFFFFFFFFh
    adcx rax,rdx

    test rbp,rbp

    cmovz rdi,r15
    cmovz rsi,r14
    cmovz rbx,r13
    cmovz rax,r12

    lea rcx,[rsp+208]
    call _sm2_naked_mul_stack_rcx
    ; ,u*(t-u) || 2*y1, 4*yy*u, t, e, m, ee+zz, u, e*ee

    xor rbp,rbp
    sub r11,[rsp+264]
    sbb r10,[rsp+256]
    mov rdi,r11
    sbb r9,[rsp+248]
    sbb r8,[rsp+240]
    mov rsi,r10
    sbb rbp,0

    add r11,0FFFFFFFFFFFFFFFFh
    mov rbx,r9
    mov rdx,0FFFFFFFF00000000h
    adcx r10,rdx
    adc r9,0FFFFFFFFFFFFFFFFh
    mov rax,r8
    mov rdx,0FFFFFFFEFFFFFFFFh
    adcx r8,rdx

    test rbp,rbp

    cmovnz rdi,r11
    cmovnz rsi,r10
    cmovnz rbx,r9
    cmovnz rax,r8
    ;u*(t-u)-e*ee, || 2*y1, 4*yy*u, t, e, m, ee+zz, u, e*ee

    lea rcx,[rsp+16]
    call _sm2_naked_mul_stack_rcx

    xor rbp,rbp
    shl r11,1
    rcl r10,1
    mov r15,r11
    rcl r9,1
    rcl r8,1
    mov r14,r10
    rcl rbp,1

    sub r11,0FFFFFFFFFFFFFFFFh
    mov rdx,0FFFFFFFF00000000h
    mov r13,r9
    sbb r10,rdx
    sbb r9,0FFFFFFFFFFFFFFFFh
    mov r12,r8
    mov rdx,0FFFFFFFEFFFFFFFFh
    sbb r8,rdx
    sbb rbp,0
    
    cmovc r11,r15
    cmovc r10,r14
    cmovc r9,r13
    cmovc r8,r12

    xor rbp,rbp
    shl r11,1
    rcl r10,1
    mov r15,r11
    rcl r9,1
    rcl r8,1
    mov r14,r10
    rcl rbp,1

    sub r11,0FFFFFFFFFFFFFFFFh
    mov rdx,0FFFFFFFF00000000h
    mov r13,r9
    sbb r10,rdx
    sbb r9,0FFFFFFFFFFFFFFFFh
    mov r12,r8
    mov rdx,0FFFFFFFEFFFFFFFFh
    sbb r8,rdx
    sbb rbp,0
    
    cmovc r11,r15
    cmovc r10,r14
    cmovc r9,r13
    cmovc r8,r12
    
    mov rcx,[rsp+280]
    mov [rcx+56],r11
    mov [rcx+48],r10
    mov [rcx+40],r9
    mov [rcx+32],r8

    mov rcx,[rsp+272]
    mov rdi,[rcx+88]
    mov rsi,[rcx+80]
    mov rbx,[rcx+72]
    mov rax,[rcx+64]

    xor rbp,rbp
    add rdi,[rsp+136]
    adcx rsi,[rsp+128]
    mov r11,rdi
    adcx rbx,[rsp+120]
    adcx rax,[rsp+112]
    mov r10,rsi
    adc rbp,0

    sub r11,0FFFFFFFFFFFFFFFFh
    mov rdx,0FFFFFFFF00000000h
    mov r9,rbx
    sbb r10,rdx
    sbb r9,0FFFFFFFFFFFFFFFFh
    mov r8,rax
    mov rdx,0FFFFFFFEFFFFFFFFh
    sbb r8,rdx
    sbb rbp,0

    cmovnc rdi,r11
    cmovnc rsi,r10
    cmovnc rbx,r9
    cmovnc rax,r8

    call _sm2_naked_sqr

    xor rbp,rbp
    sub r11,[rsp+200]
    sbb r10,[rsp+192]
    mov r15,r11
    sbb r9,[rsp+184]
    sbb r8,[rsp+176]
    mov r14,r10
    sbb rbp,0

    add r11,0FFFFFFFFFFFFFFFFh
    mov r13,r9
    mov rdx,0FFFFFFFF00000000h
    adcx r10,rdx
    adc r9,0FFFFFFFFFFFFFFFFh
    mov r12,r8
    mov rdx,0FFFFFFFEFFFFFFFFh
    adcx r8,rdx

    test rbp,rbp

    cmovz r11,r15
    cmovz r10,r14
    cmovz r9,r13
    cmovz r8,r12


    mov rcx,[rsp+280]

    mov [rcx+88],r11
    mov [rcx+80],r10
    mov [rcx+72],r9
    mov [rcx+64],r8

    ;||[rax,rbx,rsi,rdi][r8,r9,r10,r11](rbp,r12,r13,r14,r15)rcx,rdx|rsp+8||||r8=[rsp+8]||rcx=[rsp+272]||rdx=[rsp+280]
    ;||一[[rsp+8+8][rsp+8+16][rsp+8+24][rsp+8+32]]||二[[rsp+8+40][rsp+8+48][rsp+8+56][rsp+8+64]]||三[[rsp+8+72][rsp+8+80][rsp+8+88][rsp+8+96]]||四[[rsp+8+104][rsp+8+112][rsp+8+120][rsp+8+128]]
    ;||五[[rsp+8+136][rsp+8+144][rsp+8+152][rsp+8+160]]||六[[rsp+8+168][rsp+8+176][rsp+8+184][rsp+8+192]]||七[[rsp+8+200][rsp+8+208][rsp+8+216][rsp+8+224]]||八[[rsp+240][rsp+248][rsp+256][rsp+264]]||[rsp+272][rsp+280]

    

    add rsp,288

    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    pop rdi
    pop rsi
    pop rbx
    ret
jacobian_point_tripling endp

jacobian_point_double_add proc EXPORT FRAME
    .endprolog
    push rbx
    push rsi
    push rdi
    push rbp
    push r12
    push r13
    push r14
    push r15

    sub rsp,288
    mov [rsp+8],r8
    mov [rsp+272],rcx
    mov [rsp+280],rdx
    
    mov rax,[rcx+64]
    mov rbx,[rcx+72]
    mov rsi,[rcx+80]
    mov rdi,[rcx+88]

    call _sm2_naked_sqr
    ;z1, z1z1 ||

    mov [rsp+80],r8
    mov [rsp+88],r9
    mov [rsp+96],r10
    mov [rsp+104],r11
    ;z1, z1z1 || , , z1z1
    ;||[rax,rbx,rsi,rdi][r8,r9,r10,r11](rbp,r12,r13,r14,r15)rcx,rdx|rsp+8||||r8=[rsp+8]||rcx=[rsp-8]||rdx=[rsp-16]
    ;||一[[rsp+8+8][rsp+8+16][rsp+8+24][rsp+8+32]]||二[[rsp+8+40][rsp+8+48][rsp+8+56][rsp+8+64]]||三[[rsp+8+72][rsp+8+80][rsp+8+88][rsp+8+96]]||四[[rsp+8+104][rsp+8+112][rsp+8+120][rsp+8+128]]
    ;||五[[rsp+8+136][rsp+8+144][rsp+8+152][rsp+8+160]]||六[[rsp+8+168][rsp+8+176][rsp+8+184][rsp+8+192]]||七[[rsp+8+200][rsp+8+208][rsp+8+216][rsp+8+224]]||[rsp+240][rsp+248]||八[[rsp+256][rsp+264][rsp+272][rsp+280]]

    lea rcx,[rsp+80]
    call _sm2_naked_mul_stack_rcx

    mov rax,r8
    mov rbx,r9
    mov rsi,r10
    mov rdi,r11

    mov rcx,[rsp+280]
    add rcx,32

    call _sm2_naked_mul_stack_rcx
    ;, s2 || , , z1z1

    mov rcx,[rsp+272]
    mov rax,[rcx+32]
    mov rbx,[rcx+40]
    mov rsi,[rcx+48]
    mov rdi,[rcx+56]

    xor rbp,rbp
    sub r11,rdi
    sbb r10,rsi
    mov r15,r11
    sbb r9,rbx
    sbb r8,rax
    mov r14,r10
    sbb rbp,0

    add r11,0FFFFFFFFFFFFFFFFh
    mov r13,r9
    mov rdx,0FFFFFFFF00000000h
    adcx r10,rdx
    adc r9,0FFFFFFFFFFFFFFFFh
    mov r12,r8
    mov rdx,0FFFFFFFEFFFFFFFFh
    adcx r8,rdx

    test rbp,rbp

    cmovz r11,r15
    cmovz r10,r14
    cmovz r9,r13
    cmovz r8,r12

    xor rbp,rbp
    shl r11,1
    rcl r10,1
    mov r15,r11
    rcl r9,1
    rcl r8,1
    mov r14,r10
    rcl rbp,1

    sub r11,0FFFFFFFFFFFFFFFFh
    mov rdx,0FFFFFFFF00000000h
    mov r13,r9
    sbb r10,rdx
    sbb r9,0FFFFFFFFFFFFFFFFh
    mov r12,r8
    mov rdx,0FFFFFFFEFFFFFFFFh
    sbb r8,rdx
    sbb rbp,0
    
    cmovc r11,r15
    cmovc r10,r14
    cmovc r9,r13
    cmovc r8,r12
    
    mov [rsp+72],r11
    mov [rsp+64],r10
    mov [rsp+56],r9
    mov [rsp+48],r8
    
    ;y1, r || , r, z1z1

    mov rcx,[rsp+280]
    mov rax,[rsp+80]
    mov rbx,[rsp+88]
    mov rsi,[rsp+96]
    mov rdi,[rsp+104]
    
    call _sm2_naked_mul_stack_rcx
    
    ;z1z1, u2 || , r, z1z1

    mov rcx,[rsp+272]

    xor rbp,rbp
    sub r11,[rcx+24]
    sbb r10,[rcx+16]
    mov rdi,r11
    sbb r9,[rcx+8]
    sbb r8,[rcx]
    mov rsi,r10
    sbb rbp,0

    add r11,0FFFFFFFFFFFFFFFFh
    mov rbx,r9
    mov rdx,0FFFFFFFF00000000h
    adcx r10,rdx
    adc r9,0FFFFFFFFFFFFFFFFh
    mov rax,r8
    mov rdx,0FFFFFFFEFFFFFFFFh
    adcx r8,rdx

    test rbp,rbp

    cmovnz rdi,r11
    cmovnz rsi,r10
    cmovnz rbx,r9
    cmovnz rax,r8

    call _sm2_naked_sqr
    
    mov [rsp+16],rax
    mov [rsp+24],rbx
    mov [rsp+32],rsi
    mov [rsp+40],rdi
    mov [rsp+136],r11
    mov [rsp+128],r10
    mov [rsp+120],r9
    mov [rsp+112],r8
    ;h, hh || h, r, z1z1, hh

    
    xor rbp,rbp
    shl r11,1
    rcl r10,1
    mov r15,r11
    rcl r9,1
    rcl r8,1
    mov r14,r10
    rcl rbp,1

    sub r11,0FFFFFFFFFFFFFFFFh
    mov rdx,0FFFFFFFF00000000h
    mov r13,r9
    sbb r10,rdx
    sbb r9,0FFFFFFFFFFFFFFFFh
    mov r12,r8
    mov rdx,0FFFFFFFEFFFFFFFFh
    sbb r8,rdx
    sbb rbp,0
    
    cmovc r11,r15
    cmovc r10,r14
    cmovc r9,r13
    cmovc r8,r12


    xor rbp,rbp
    shl r11,1
    rcl r10,1
    mov rdi,r11
    rcl r9,1
    rcl r8,1
    mov rsi,r10
    rcl rbp,1

    sub r11,0FFFFFFFFFFFFFFFFh
    mov rdx,0FFFFFFFF00000000h
    mov rbx,r9
    sbb r10,rdx
    sbb r9,0FFFFFFFFFFFFFFFFh
    mov rax,r8
    mov rdx,0FFFFFFFEFFFFFFFFh
    sbb r8,rdx
    sbb rbp,0
    
    cmovnc rdi,r11
    cmovnc rsi,r10
    cmovnc rbx,r9
    cmovnc rax,r8
    
    ;i || h, r, z1z1, hh

    lea rcx,[rsp+16]
    call _sm2_naked_mul_stack_rcx
    
    ;i, j_y1 || h, r, z1z1, hh
    
    mov [rsp+168],r11
    mov [rsp+160],r10
    mov [rsp+152],r9
    mov [rsp+144],r8
    
    ;i, j_y1 || h, r, z1z1, hh, j_y1

    mov rcx,[rsp+272]
    call _sm2_naked_mul_stack_rcx
    
    mov [rsp+200],r11
    mov [rsp+192],r10
    mov [rsp+184],r9
    mov [rsp+176],r8

    ;i, v_x1 || h, r, z1z1, hh, j_y1, v_x1
    ;||[rax,rbx,rsi,rdi][r8,r9,r10,r11](rbp,r12,r13,r14,r15)rcx,rdx|rsp+8||||r8=[rsp+8]||rcx=[rsp+240]||rdx=[rsp+248]
    ;||一[[rsp+8+8][rsp+8+16][rsp+8+24][rsp+8+32]]||二[[rsp+8+40][rsp+8+48][rsp+8+56][rsp+8+64]]||三[[rsp+8+72][rsp+8+80][rsp+8+88][rsp+8+96]]||四[[rsp+8+104][rsp+8+112][rsp+8+120][rsp+8+128]]
    ;||五[[rsp+8+136][rsp+8+144][rsp+8+152][rsp+8+160]]||六[[rsp+8+168][rsp+8+176][rsp+8+184][rsp+8+192]]||七[[rsp+8+200][rsp+8+208][rsp+8+216][rsp+8+224]]

    mov rax,[rsp+48]
    mov rbx,[rsp+56]
    mov rsi,[rsp+64]
    mov rdi,[rsp+72]
    call _sm2_naked_sqr
    ;r, r^2 || h, r, z1z1, hh, j_y1, v_x1

    xor rbp,rbp
    sub r11,[rsp+168]
    sbb r10,[rsp+160]
    mov r15,r11
    sbb r9,[rsp+152]
    sbb r8,[rsp+144]
    mov r14,r10
    sbb rbp,0

    add r11,0FFFFFFFFFFFFFFFFh
    mov r13,r9
    mov rdx,0FFFFFFFF00000000h
    adcx r10,rdx
    adc r9,0FFFFFFFFFFFFFFFFh
    mov r12,r8
    mov rdx,0FFFFFFFEFFFFFFFFh
    adcx r8,rdx

    test rbp,rbp

    cmovz r11,r15
    cmovz r10,r14
    cmovz r9,r13
    cmovz r8,r12
    ;r, r^2-j || h, r, z1z1, hh, j_y1, v_x1
    
    mov rax,[rsp+176]
    mov rbx,[rsp+184]
    mov rsi,[rsp+192]
    mov rdi,[rsp+200]
    ;v, r^2-j || h, r, z1z1, hh, j_y1, v_x1

    xor rbp,rbp
    sub r11,rdi
    sbb r10,rsi
    mov r15,r11
    sbb r9,rbx
    sbb r8,rax
    mov r14,r10
    sbb rbp,0

    add r11,0FFFFFFFFFFFFFFFFh
    mov r13,r9
    mov rdx,0FFFFFFFF00000000h
    adcx r10,rdx
    adc r9,0FFFFFFFFFFFFFFFFh
    mov r12,r8
    mov rdx,0FFFFFFFEFFFFFFFFh
    adcx r8,rdx

    test rbp,rbp

    cmovz r11,r15
    cmovz r10,r14
    cmovz r9,r13
    cmovz r8,r12

    xor rbp,rbp
    sub r11,rdi
    sbb r10,rsi
    mov r15,r11
    sbb r9,rbx
    sbb r8,rax
    mov r14,r10
    sbb rbp,0

    add r11,0FFFFFFFFFFFFFFFFh
    mov r13,r9
    mov rdx,0FFFFFFFF00000000h
    adcx r10,rdx
    adc r9,0FFFFFFFFFFFFFFFFh
    mov r12,r8
    mov rdx,0FFFFFFFEFFFFFFFFh
    adcx r8,rdx

    test rbp,rbp

    cmovz r11,r15
    cmovz r10,r14
    cmovz r9,r13
    cmovz r8,r12
    ;v, x || h, r, z1z1, hh, j_y1, v_x1
    
    mov [rsp+232],r11
    mov [rsp+224],r10
    mov [rsp+216],r9
    mov [rsp+208],r8
    ;v, x || h, r, z1z1, hh, j_y1, v_x1, x

    xor rbp,rbp
    sub rdi,r11
    sbb rsi,r10
    mov r15,rdi
    sbb rbx,r9
    sbb rax,r8
    mov r14,rsi
    sbb rbp,0

    add rdi,0FFFFFFFFFFFFFFFFh
    mov r13,rbx
    mov rdx,0FFFFFFFF00000000h
    adcx rsi,rdx
    adc rbx,0FFFFFFFFFFFFFFFFh
    mov r12,rax
    mov rdx,0FFFFFFFEFFFFFFFFh
    adcx rax,rdx

    test rbp,rbp

    cmovz rdi,r15
    cmovz rsi,r14
    cmovz rbx,r13
    cmovz rax,r12

    mov r11,0FFFFFFFFFFFFFFFFh
    mov r10,0FFFFFFFF00000000h
    mov r9,0FFFFFFFFFFFFFFFFh
    mov r8,0FFFFFFFEFFFFFFFFh

    xor rbp,rbp
    sub r11,rdi
    sbb r10,rsi
    mov r15,r11
    sbb r9,rbx
    sbb r8,rax
    mov r14,r10
    sbb rbp,0

    add r11,0FFFFFFFFFFFFFFFFh
    mov r13,r9
    mov rdx,0FFFFFFFF00000000h
    adcx r10,rdx
    adc r9,0FFFFFFFFFFFFFFFFh
    mov r12,r8
    mov rdx,0FFFFFFFEFFFFFFFFh
    adcx r8,rdx

    test rbp,rbp

    cmovz r11,r15
    cmovz r10,r14
    cmovz r9,r13
    cmovz r8,r12

    mov [rsp+264],r11
    mov [rsp+256],r10
    mov [rsp+248],r9
    mov [rsp+240],r8

    ;v-x, A || h, r, z1z1, hh, j_y1, v_x1, x, A
    lea rcx,[rsp+48]
    call _sm2_naked_mul_stack_rcx
    ;v-x, (v-x)r || h, r, z1z1, hh, j_y1, v_x1, x, A
    
    mov [rsp+72],r11
    mov [rsp+64],r10
    mov [rsp+56],r9
    mov [rsp+48],r8
    ;v-x, (v-x)r || h, (v-x)r, z1z1, hh, j_y1, v_x1, x, A

    mov rax,[rsp+144]
    mov rbx,[rsp+152]
    mov rsi,[rsp+160]
    mov rdi,[rsp+168]
    ;j, (v-x)r || h, (v-x)r, z1z1, hh, j_y1, v_x1, x, A

    mov rcx,[rsp+272]
    add rcx,32
    call _sm2_naked_mul_stack_rcx

    xor rbp,rbp
    shl r11,1
    rcl r10,1
    mov r15,r11
    rcl r9,1
    rcl r8,1
    mov r14,r10
    rcl rbp,1

    sub r11,0FFFFFFFFFFFFFFFFh
    mov rdx,0FFFFFFFF00000000h
    mov r13,r9
    sbb r10,rdx
    sbb r9,0FFFFFFFFFFFFFFFFh
    mov r12,r8
    mov rdx,0FFFFFFFEFFFFFFFFh
    sbb r8,rdx
    sbb rbp,0
    
    cmovc r11,r15
    cmovc r10,r14
    cmovc r9,r13
    cmovc r8,r12
    
    mov rax,[rsp+48]
    mov rbx,[rsp+56]
    mov rsi,[rsp+64]
    mov rdi,[rsp+72]

    xor rbp,rbp
    sub rdi,r11
    sbb rsi,r10
    mov r15,rdi
    sbb rbx,r9
    sbb rax,r8
    mov r14,rsi
    sbb rbp,0

    add rdi,0FFFFFFFFFFFFFFFFh
    mov r13,rbx
    mov rdx,0FFFFFFFF00000000h
    adcx rsi,rdx
    adc rbx,0FFFFFFFFFFFFFFFFh
    mov r12,rax
    mov rdx,0FFFFFFFEFFFFFFFFh
    adcx rax,rdx

    test rbp,rbp

    cmovz rdi,r15
    cmovz rsi,r14
    cmovz rbx,r13
    cmovz rax,r12

    xor rbp,rbp
    sub rdi,r11
    sbb rsi,r10
    mov r15,rdi
    sbb rbx,r9
    sbb rax,r8
    mov r14,rsi
    sbb rbp,0

    add rdi,0FFFFFFFFFFFFFFFFh
    mov r13,rbx
    mov rdx,0FFFFFFFF00000000h
    adcx rsi,rdx
    adc rbx,0FFFFFFFFFFFFFFFFh
    mov r12,rax
    mov rdx,0FFFFFFFEFFFFFFFFh
    adcx rax,rdx

    test rbp,rbp

    cmovz rdi,r15
    cmovz rsi,r14
    cmovz rbx,r13
    cmovz rax,r12
    
    ;D, y1 || h, (v-x)r, z1z1, hh, j_y1, v_x1, x, A

    mov [rsp+144],rax
    mov [rsp+152],rbx
    mov [rsp+160],rsi
    mov [rsp+168],rdi
    mov [rsp+72],r11
    mov [rsp+64],r10
    mov [rsp+56],r9
    mov [rsp+48],r8
    
    ; || h, y1, z1z1, hh, D, x1, x2, A
    
    mov r11,[rsp+40]
    mov r10,[rsp+32]
    mov r9,[rsp+24]
    mov r8,[rsp+16]

    xor rbp,rbp
    add r11,[rcx+56]
    adcx r10,[rcx+48]
    mov rdi,r11
    adcx r9,[rcx+40]
    adcx r8,[rcx+32]
    mov rsi,r10
    adc rbp,0

    sub r11,0FFFFFFFFFFFFFFFFh
    mov rdx,0FFFFFFFF00000000h
    mov rbx,r9
    sbb r10,rdx
    sbb r9,0FFFFFFFFFFFFFFFFh
    mov rax,r8
    mov rdx,0FFFFFFFEFFFFFFFFh
    sbb r8,rdx
    sbb rbp,0

    cmovnc rdi,r11
    cmovnc rsi,r10
    cmovnc rbx,r9
    cmovnc rax,r8

    call _sm2_naked_sqr
    ;z1+h, (z1+h)^2 || h, y1, z1z1, hh, D, x1, x2, A
    ;||[rax,rbx,rsi,rdi][r8,r9,r10,r11](rbp,r12,r13,r14,r15)rcx,rdx|rsp+8||||r8=[rsp+8]||rcx=[rsp+272]||rdx=[rsp+280]
    ;||一[[rsp+8+8][rsp+8+16][rsp+8+24][rsp+8+32]]||二[[rsp+8+40][rsp+8+48][rsp+8+56][rsp+8+64]]||三[[rsp+8+72][rsp+8+80][rsp+8+88][rsp+8+96]]||四[[rsp+8+104][rsp+8+112][rsp+8+120][rsp+8+128]]
    ;||五[[rsp+8+136][rsp+8+144][rsp+8+152][rsp+8+160]]||六[[rsp+8+168][rsp+8+176][rsp+8+184][rsp+8+192]]||七[[rsp+8+200][rsp+8+208][rsp+8+216][rsp+8+224]]||八[[rsp+8+232][rsp+8+240][rsp+8+248][rsp+8+256]]||[rsp+272][rsp+280]

    xor rbp,rbp
    sub r11,[rsp+104]
    sbb r10,[rsp+96]
    mov r15,r11
    sbb r9,[rsp+88]
    sbb r8,[rsp+80]
    mov r14,r10
    sbb rbp,0

    add r11,0FFFFFFFFFFFFFFFFh
    mov r13,r9
    mov rdx,0FFFFFFFF00000000h
    adcx r10,rdx
    adc r9,0FFFFFFFFFFFFFFFFh
    mov r12,r8
    mov rdx,0FFFFFFFEFFFFFFFFh
    adcx r8,rdx

    test rbp,rbp

    cmovz r11,r15
    cmovz r10,r14
    cmovz r9,r13
    cmovz r8,r12

    xor rbp,rbp
    sub r11,[rsp+136]
    sbb r10,[rsp+128]
    mov rdi,r11
    sbb r9,[rsp+120]
    sbb r8,[rsp+112]
    mov rsi,r10
    sbb rbp,0

    add r11,0FFFFFFFFFFFFFFFFh
    mov rbx,r9
    mov rdx,0FFFFFFFF00000000h
    adcx r10,rdx
    adc r9,0FFFFFFFFFFFFFFFFh
    mov rax,r8
    mov rdx,0FFFFFFFEFFFFFFFFh
    adcx r8,rdx

    test rbp,rbp

    cmovnz rdi,r11
    cmovnz rsi,r10
    cmovnz rbx,r9
    cmovnz rax,r8

    ;z1 || h, y1, z1z1, hh, D, x1, x2, a

    lea rcx,[rsp+240]
    call _sm2_naked_mul_stack_rcx
    
    mov rcx,[rsp+8]

    mov [rcx+88],r11
    mov [rcx+80],r10
    mov [rcx+72],r9
    mov [rcx+64],r8

    mov rax,[rsp+240]
    mov rbx,[rsp+248]
    mov rsi,[rsp+256]
    mov rdi,[rsp+264]

    call _sm2_naked_sqr

    mov rax,r8
    mov rbx,r9
    mov rsi,r10
    mov rdi,r11

    ;A || h, y1, z1z1, hh, d, x1, x2, a

    lea rcx,[rsp+176]
    call _sm2_naked_mul_stack_rcx
    
    mov [rsp+176],r8
    mov [rsp+184],r9
    mov [rsp+192],r10
    mov [rsp+200],r11
    
    ;A, B || h, y1, z1z1, hh, d, B, x2, a

    lea rcx,[rsp+208]
    call _sm2_naked_mul_stack_rcx
    
    mov [rsp+208],r8
    mov [rsp+216],r9
    mov [rsp+224],r10
    mov [rsp+232],r11
    
    ;A, C || h, y1, z1z1, hh, d, B, C, a
    xor rbp,rbp
    sub r11,[rsp+200]
    sbb r10,[rsp+192]
    mov rdi,r11
    sbb r9,[rsp+184]
    sbb r8,[rsp+176]
    mov rsi,r10
    sbb rbp,0

    add r11,0FFFFFFFFFFFFFFFFh
    mov rbx,r9
    mov rdx,0FFFFFFFF00000000h
    adcx r10,rdx
    adc r9,0FFFFFFFFFFFFFFFFh
    mov rax,r8
    mov rdx,0FFFFFFFEFFFFFFFFh
    adcx r8,rdx

    test rbp,rbp

    cmovnz rdi,r11
    cmovnz rsi,r10
    cmovnz rbx,r9
    cmovnz rax,r8
    
    lea rcx,[rsp+48]
    call _sm2_naked_mul_stack_rcx
    
    ;C-B, y1(C-B) || h, y1, z1z1, hh, d, B, C, a
    
    mov [rsp+48],r8
    mov [rsp+56],r9
    mov [rsp+64],r10
    mov [rsp+72],r11
    
    ;C-B, y1(C-B) || h, y1(C-B), z1z1, hh, d, B, C, a
    
    mov rax,[rsp+144]
    mov rbx,[rsp+152]
    mov rsi,[rsp+160]
    mov rdi,[rsp+168]

    call _sm2_naked_sqr
    
    ;d, D || h, y1(C-B), z1z1, hh, d, B, C, a

    xor rbp,rbp
    sub r11,[rsp+232]
    sbb r10,[rsp+224]
    mov r15,r11
    sbb r9,[rsp+216]
    sbb r8,[rsp+208]
    mov r14,r10
    sbb rbp,0

    add r11,0FFFFFFFFFFFFFFFFh
    mov r13,r9
    mov rdx,0FFFFFFFF00000000h
    adcx r10,rdx
    adc r9,0FFFFFFFFFFFFFFFFh
    mov r12,r8
    mov rdx,0FFFFFFFEFFFFFFFFh
    adcx r8,rdx

    test rbp,rbp

    cmovz r11,r15
    cmovz r10,r14
    cmovz r9,r13
    cmovz r8,r12

    mov rax,[rsp+176]
    mov rbx,[rsp+184]
    mov rsi,[rsp+192]
    mov rdi,[rsp+200]
    
    ;B, D-C || h, y1(C-B), z1z1, hh, d, B, C, a
    
    xor rbp,rbp
    sub r11,rdi
    sbb r10,rsi
    mov r15,r11
    sbb r9,rbx
    sbb r8,rax
    mov r14,r10
    sbb rbp,0

    add r11,0FFFFFFFFFFFFFFFFh
    mov r13,r9
    mov rdx,0FFFFFFFF00000000h
    adcx r10,rdx
    adc r9,0FFFFFFFFFFFFFFFFh
    mov r12,r8
    mov rdx,0FFFFFFFEFFFFFFFFh
    adcx r8,rdx

    test rbp,rbp

    cmovz r11,r15
    cmovz r10,r14
    cmovz r9,r13
    cmovz r8,r12
    
    ;B, D-B-C || h, y1(C-B), z1z1, hh, d, B, C, a
    
    mov rcx,[rsp+8]

    mov [rcx+24],r11
    mov [rcx+16],r10
    mov [rcx+8],r9
    mov [rcx],r8

    xor rbp,rbp
    sub rdi,r11
    sbb rsi,r10
    mov r15,rdi
    sbb rbx,r9
    sbb rax,r8
    mov r14,rsi
    sbb rbp,0

    add rdi,0FFFFFFFFFFFFFFFFh
    mov r13,rbx
    mov rdx,0FFFFFFFF00000000h
    adcx rsi,rdx
    adc rbx,0FFFFFFFFFFFFFFFFh
    mov r12,rax
    mov rdx,0FFFFFFFEFFFFFFFFh
    adcx rax,rdx

    test rbp,rbp

    cmovz rdi,r15
    cmovz rsi,r14
    cmovz rbx,r13
    cmovz rax,r12
    
    ;B-x3 || h, y1(C-B), z1z1, hh, d, B, C, a

    lea rcx,[rsp+144]
    call _sm2_naked_mul_stack_rcx
    ;B-x3, d(B-x3) || h, y1(C-B), z1z1, hh, d, B, C, a

    xor rbp,rbp
    sub r11,[rsp+72]
    sbb r10,[rsp+64]
    mov r15,r11
    sbb r9,[rsp+56]
    sbb r8,[rsp+48]
    mov r14,r10
    sbb rbp,0

    add r11,0FFFFFFFFFFFFFFFFh
    mov r13,r9
    mov rdx,0FFFFFFFF00000000h
    adcx r10,rdx
    adc r9,0FFFFFFFFFFFFFFFFh
    mov r12,r8
    mov rdx,0FFFFFFFEFFFFFFFFh
    adcx r8,rdx

    test rbp,rbp

    cmovz r11,r15
    cmovz r10,r14
    cmovz r9,r13
    cmovz r8,r12
    
    mov rcx,[rsp+8]

    mov [rcx+56],r11
    mov [rcx+48],r10
    mov [rcx+40],r9
    mov [rcx+32],r8

    add rsp,288

    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    pop rdi
    pop rsi
    pop rbx
    ret
jacobian_point_double_add endp

_sm2_sqr proc EXPORT FRAME
    .endprolog

    push rbx
    push rsi
    push rdi
    push rbp
    push r12
    push r13
    push r14
    push r15

    push rcx
    push rdx

    ;加载z
    mov rax,[rcx]
    mov rbx,[rcx+8]
    mov rsi,[rcx+16]
    mov rdi,[rcx+24]

    mov rdx,rdi

    mulx r13,r14,rsi
    mulx r12,rcx,rbx
    add r13,rcx
    mulx r11,rbp,rax
    adcx r12,rbp

    mov rdx,rax
    mulx r10,rcx,rsi
    adcx r11,rcx
    mulx r9,rbp,rbx
    adcx r10,rbp
    adc r9,0

    xor r8,r8
    mov rdx,rbx
    mulx rbp,rcx,rsi
    add r12,rcx
    adcx r11,rbp
    adc r10,0
    adc r9,0

    shl r14,1
    rcl r13,1
    rcl r12,1
    rcl r11,1
    rcl r10,1
    rcl r9,1
    rcl r8,1

    mov rdx,rdi
    mulx rbp,r15,rdx
    add r14,rbp

    mov rdx,rsi
    mulx rbp,rcx,rdx
    adcx r13,rcx
    adcx r12,rbp

    mov rdx,rbx
    mulx rbp,rcx,rdx
    adcx r11,rcx
    adcx r10,rbp

    mov rdx,rax
    mulx rbp,rcx,rdx
    adcx r9,rcx
    adcx r8,rbp

    ;r8,r9,r10,r11,r12,r13,r14,r15
    ;
    xor rbp,rbp

    mov rdx,r15
    mov rcx,r15

    add r14,r15
    adc r13,0
    adc r12,0
    adcx r11,r15
    adc r10,0
    adc r9,0
    adc r8,0
    adc rbp,0
    shl rdx,32
    shr rcx,32
    sub r14,rdx
    sbb r13,rcx
    sbb r12,rdx
    sbb r11,rcx
    sbb r10,0
    sbb r9,0
    sbb r8,0
    sbb rbp,0


    mov rdx,r14
    mov rcx,r14

    add r13,r14
    adc r12,0
    adc r11,0
    adcx r10,r14
    adc r9,0
    adc r8,0
    adc rbp,0
    shl rdx,32
    shr rcx,32
    sub r13,rdx
    sbb r12,rcx
    sbb r11,rdx
    sbb r10,rcx
    sbb r9,0
    sbb r8,0
    sbb rbp,0

    
    mov rdx,r13
    mov rcx,r13

    add r12,r13
    adc r11,0
    adc r10,0
    adcx r9,r13
    adc r8,0
    adc rbp,0
    shl rdx,32
    shr rcx,32
    sub r12,rdx
    sbb r11,rcx
    sbb r10,rdx
    sbb r9,rcx
    sbb r8,0
    sbb rbp,0


    mov rdx,r12
    mov rcx,r12

    add r11,r12
    adc r10,0
    adc r9,0
    adcx r8,r12
    adc rbp,0
    shl rdx,32
    shr rcx,32
    sub r11,rdx
    sbb r10,rcx
    sbb r9,rdx
    sbb r8,rcx
    sbb rbp,0

    ;mov rdx,r12
    ;xor r12,r12

    ;add r11,r15
    ;adcx r10,r14
    mov r15,r11
    ;adcx r9,r13
    mov r14,r10
    ;adcx r8,r12

    sub r11,0FFFFFFFFFFFFFFFFh
    mov rdx,0FFFFFFFF00000000h
    sbb r10,rdx
    mov r13,r9
    sbb r9,0FFFFFFFFFFFFFFFFh
    mov rdx,0FFFFFFFEFFFFFFFFh
    mov r12,r8
    sbb r8,rdx
    sbb rbp,0

    cmovc r11,r15
    cmovc r10,r14
    cmovc r9,r13
    cmovc r8,r12

    pop rdx

    mov [rdx],r8
    mov [rdx+8],r9
    mov [rdx+16],r10
    mov [rdx+24],r11

    pop rcx

    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    pop rdi
    pop rsi
    pop rbx

    ret

    ret
_sm2_sqr endp

end