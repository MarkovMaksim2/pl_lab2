%include "lib.inc"
%include "dict.inc"
%include "words.inc"

%define BUF_SIZE 256

global _start

section .bss
    buf: resb BUF_SIZE

section .rodata
    overflow_error: db "String is too long", 10, 0
    no_words: db "No words", 10, 0

section .text

_start:
    mov rdi, buf                    ; reading word from stdin
    mov rsi, BUF_SIZE
    call read_word
    test rax, rax                   ; checking buffer length 
    jz .overflow
    mov rsi, ptr                    ; finding word
    mov rdi, buf
    push rdx
    call find_word
    pop rdx
    test rax, rax                   ; checking find or not
    jz .no
    lea rdi, [rax + 8 + rdx + 1]
    call print_string
    call exit
  .overflow:
    mov rdi, overflow_error
    call print_error
    call exit
  .no:
    mov rdi, no_words
    call print_error
    call exit
