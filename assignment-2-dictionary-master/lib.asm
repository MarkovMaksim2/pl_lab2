%define EXIT 60
%define STDIN 0
%define STDOUT 1
%define STDERR 2
%define SYS_READ 0
%define SYS_WRITE 1
%define EOL 0

global exit
global string_length
global print_string
global print_error
global print_char
global print_newline
global print_uint
global print_int
global string_equals
global read_char
global read_word
global parse_uint
global parse_int
global string_copy

section .text

; Принимает код возврата и завершает текущий процесс
exit:
    mov rax, EXIT
    syscall
    ret 

; Принимает указатель на нуль-терминированную строку, возвращает её длину
string_length:
    xor rax, rax
  .counter:
    cmp byte [rdi + rax], EOL ; checking on END_OF_LINE symbol
    jz .end
    inc rax
    jmp .counter
  .end:
    ret

; Принимает указатель на нуль-терминированную строку, выводит её в stdout
print_string:
    push rdi                  ; reading string length
    call string_length
    mov rdx, rax
    pop rsi
    mov rax, SYS_WRITE        ; printing string
    mov rdi, STDOUT
    syscall
    ret

; Printing string in error stream
print_error:
    push rdi
    call string_length
    mov rdx, rax
    pop rsi
    mov rax, SYS_WRITE
    mov rdi, STDERR
    syscall
    ret

; Принимает код символа и выводит его в stdout
print_char:
    push rdi
    mov rsi, rsp
    mov rax, SYS_WRITE
    mov rdx, 1
    mov rdi, STDOUT
    syscall
    pop rdi
    ret

; Переводит строку (выводит символ с кодом 0xA)
print_newline:
    mov rdi, 0xA              ; putting in rdi LF
    jmp print_char

; Выводит беззнаковое 8-байтовое число в десятичном формате 
; Совет: выделите место в стеке и храните там результаты деления
; Не забудьте перевести цифры в их ASCII коды.
print_uint:
    mov rax, rdi
    xor rsi, rsi
    dec rsp                   ; putting EOL symbol in stack
    mov byte[rsp], 0
    inc rsi
    mov rcx, 10               ; setting number dimnesion(10)
  .counter:
    xor rdx, rdx              ; diving number
    div rcx
    add rdx, '0'              ; adding '0' code to divivsion result for getting numeric code 
    dec rsp
    mov byte[rsp], dl         ; putting symbol in stack
    inc rsi
    test rax, rax             ; cycle till rax will not be 0
    jnz .counter
  .end:
    mov rdi, rsp              ; putting first symbol adress in rdi
    push rsi                  ; printing string
    call print_string
    pop rsi
    add rsp, rsi              ; setting rsp back
    ret

; Выводит знаковое 8-байтовое число в десятичном формате 
print_int:
    test rdi, rdi             ; checking number sign
    jnl .uint
    push rdi
    mov rdi, '-'              ; printing '-'
    call print_char
    pop rdi
    neg rdi                   ; setting abs on number
  .uint:
    jmp print_uint            ; printing number 

; Принимает два указателя на нуль-терминированные строки, возвращает 1 если они равны, 0 иначе
string_equals:
    xor rax, rax
    xor rcx, rcx
  .counter:
    mov al, byte[rsi + rcx]   ; moving symbol from rsi word for comparing
    cmp al, byte[rdi + rcx]   ; comparing words symbols
    jnz .not
    inc rcx
    test rax, rax             ; checking END_OF_LINE symbol
    jnz .counter
    mov rax, 1
    ret
  .not:
    xor rax, rax
    ret

; Читает один символ из stdin и возвращает его. Возвращает 0 если достигнут конец потока
read_char:
    mov rax, SYS_READ
    mov rdi, STDIN
    push 0
    mov rsi, rsp
    mov rdx, 1
    syscall
    cmp rax, -1
    jne .ok
    xor rax, rax
    pop rdi
  .ok:
    pop rax
    ret 

; Принимает: адрес начала буфера, размер буфера
; Читает в буфер слово из stdin, пропуская пробельные символы в начале, .
; Пробельные символы это пробел 0x20, табуляция 0x9 и перевод строки 0xA.
; Останавливается и возвращает 0 если слово слишком большое для буфера
; При успехе возвращает адрес буфера в rax, длину слова в rdx.
; При неудаче возвращает 0 в rax
; Эта функция должна дописывать к слову нуль-терминатор
read_word:
    push r12                  ; saving values
    push r13
    push r14
    mov r12, rdi              ; setting buffer adress
    mov r13, rsi              ; setting buffer length
    xor r14, r14              ; setting counter
  .counter:
    call read_char            ; reading symbol
    test rax, rax             ; checking on input end
    jz .end
    cmp rax, 0x20             ; checking on space symbol
    jz .is_space
    cmp rax, 0x9
    jz .is_space
    cmp rax, 0xA
    jz .is_space
    mov [r12 + r14], al       ; moving symbol in buffer
    inc r14                   ; increasing counter
    cmp r14, r13              ; comparing counter and buffer length
    jnl .overflow
    jmp .counter
  .is_space:
    test r14, r14             ; is space in string start
    jz .counter
  .end:              
    mov byte[r12 + r14], EOL  ; setting END_OF_LINE symbol in buffer 
    mov rdx, r14              ; moving word length
    mov rax, r12              ; moving buffer adress
    pop r14                   ; getting back values
    pop r13
    pop r12
    ret
  .overflow:
    xor rax, rax
    pop r14                   ; getting back values
    pop r13
    pop r12
    ret

; Принимает указатель на строку, пытается
; прочитать из её начала беззнаковое число.
; Возвращает в rax: число, rdx : его длину в символах
; rdx = 0 если число прочитать не удалось
parse_uint:
    xor rdx, rdx
    xor rcx, rcx
  .A:
    mov rax, [rdi + rdx]      ; reading symbol
    and rax, 0xFF             ; checking that symbol is in '0' - '9' range
    test rax, rax
    jz .C
    cmp rax, 10
    jz .C
    cmp rax, '0'
    jz .B                     ; zero-case
    jb .C
    cmp rax, '9'
    ja .C
    imul rcx, 10
    sub rax, '0'              ; getting number instead symbol code
    add rcx, rax              ; adding number to value
    inc rdx
    jmp .A
  .B:
    inc rdx
    cmp rdx, 1
    jz .C
    imul rcx, 10
    jmp .A
  .C:
    mov rax, rcx              ; end of parsing 
    ret

; Принимает указатель на строку, пытается
; прочитать из её начала знаковое число.
; Если есть знак, пробелы между ним и числом не разрешены.
; Возвращает в rax: число, rdx : его длину в символах (включая знак, если он был) 
; rdx = 0 если число прочитать не удалось
parse_int:
    cmp byte[rdi], '-'        ; checking number sign
    jne parse_uint
    cmp byte[rdi], '+'
    je .signpl
    push rdi
    inc rdi                   ; parsing negative number
    call parse_uint
    pop rdi
    neg rax
    inc rdx
    ret
  .signpl:
    inc rdi
    call parse_uint
    neg rdi
    ret 

; Принимает указатель на строку, указатель на буфер и длину буфера
; Копирует строку в буфер
; Возвращает длину строки если она умещается в буфер, иначе 0
string_copy:
    xor rax, rax
  .counter:
    cmp rax, rdx              ; checking string and buffer length
    jnb .fail
    mov cl, [rdi + rax]       ; moving symbol to copy in temporary register
    mov byte[rsi + rax], cl   ; copying symbol
    cmp cl, 0
    jz .end
    inc rax
    jmp .counter
  .fail:
    xor rax, rax
    ret
  .end:
    inc rax
    ret
