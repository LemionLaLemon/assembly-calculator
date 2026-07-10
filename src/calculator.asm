global _start
extern itoa ; $EAX literal input, $RDI buffer pointer, $RAX string length literal output
extern atoi ; $RAX pointer input, $RAX 32 bit signed int literal output

section .data
    digit1message db 'Digit 1> '
    operatormessage db 'Operator> '
    digit2message db 'Digit 2> '
    resultmessage db 'Result> '
    nooperatormessage db 'No operator was found',10
    return db 10 ; 0x0A or \n

section .bss
    inputBuffer resb 64
    working resb 12

    term1 resb 4
    term2 resb 4
    operator resb 1

section .text
addition:
    mov eax, dword [term1] ; eax = term1
    mov ebx, dword [term2] ; ebx = term2
    add rax, rbx ; rax = rax + rbx
    call finish

subtraction:
    mov eax, dword [term1] ; eax = term1
    mov ebx, dword [term2] ; ebx = term2
    sub eax, ebx ; eax = eax - ebx
    call finish

multiplication:
    mov eax, dword [term1] ; eax = term1
    mov ebx, dword [term2] ; ebx = term2
    mul ebx ; rax = rax + rbx
    call finish

division:
    movsx rax, dword [term1] ; eax = term1 (move sign extended 32 bit -> 64 bit)
    cqo ; sign extend rax into rdx:rax (convert quadword to octaword)
    movsx rbx, dword [term2] ; ebx = term2
    idiv ebx ; eax = eax / ebx, edx = remainder
    call finish

finish:
    mov rdi, working ; itoa input
    call itoa 

    mov r12, rax ; r12 = itoa string length output

    mov eax, 1 ; stdwrite
    mov rdi, 1 ; stdout
    mov rsi, resultmessage ; Result>
    mov rdx, 8 ; 8 bytes
    syscall

    mov eax, 1 ; stdwrite
    mov rdi, 1 ; stdout
    mov rsi, working ; answer
    mov rdx, r12 ; r12 bytes
    syscall

    mov eax, 1 ; stdwrite
    mov rdi, 1 ; stdout
    mov rsi, return ; \n
    mov rdx, 1 ; 1 byte
    syscall

    jmp exit

_start:
    ; take in inputs
    mov eax, 1 ; syswrite
    mov rdi, 1 ; stdout
    mov rsi, digit1message ; Digit 1>
    mov rdx, 9 ; 9 bytes
    syscall

    mov eax, 0 ; sysread
    mov rdi, 0 ; stdin
    mov rsi, inputBuffer ; input
    mov rdx, 64 ; 64 bytes
    syscall

    mov rax, inputBuffer ; atoi input
    call atoi
    mov [term1], eax ; atoi output to term1

    mov eax, 1 ; syswrite
    mov rdi, 1 ; stdout
    mov rsi, operatormessage ; Operator>
    mov rdx, 10 ; 10 bytes
    syscall

    mov eax, 0 ; sysread
    mov rdi, 0 ; stdin
    mov rsi, inputBuffer ; operator
    mov rdx, 64 ; 64 bytes
    syscall

    mov al, byte [inputBuffer]
    mov [operator], al

    mov eax, 1 ; syswrite
    mov rdi, 1 ; stdout
    mov rsi, digit2message ; Digit 2>
    mov rdx, 9 ; 9 bytes
    syscall

    mov eax, 0 ; sysread
    mov rdi, 0 ; stdin
    mov rsi, inputBuffer ; Input: 
    mov rdx, 64 ; 64 bytes
    syscall

    mov rax, inputBuffer
    call atoi
    mov [term2], eax

    ; operator ifs
    movzx rax, byte [operator] 
    cmp rax, '+'
    je addition
    cmp rax, '-'
    je subtraction
    cmp rax, '*'
    je multiplication
    cmp rax, '/'
    je division

    mov eax, 1 ; syswrite
    mov rdi, 1 ; stdout
    mov rsi, nooperatormessage ; No operator was found
    mov rdx, 22
    syscall

    exit:
    mov eax, 60 ; sysexit
    xor rdi, rdi ; status 0
    syscall