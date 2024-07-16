%include "lib.inc"

global find_word

section .text

find_word:
   push r12              ; saving values for temporary usage
   push r13
   mov r12, rdi
   mov r13, rsi
  .loop:
    test r13, r13        ; checking pointer
    jz .end
    mov rdi, r12
    lea rsi, [r13 + 8]   ; putting words in rsi
    call string_equals
    test rax, rax
    jnz .ok
    mov r13, [r13]       ; going to next data
    jmp .loop
  .ok:
    mov rax, r13
    pop r13
    pop r12
    ret
  .end:
    xor rax, rax
    pop r13
    pop r12 
    ret
