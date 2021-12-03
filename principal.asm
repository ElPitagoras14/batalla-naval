.model small
.stack 260h
.data
    msg db 0ah, 0dh, "Ingrese ENTER para continuar y asignar aleatoriamente los barcos", 0ah, 0dh, 24h
    msg_err_pos db " - No se pudo ubicar la nave, fuera de rango", 0ah, 0dh, 24h
    msg_ing db "Ingrese columna y fila (Ej. A1): ", 24h
    msg_err_disp db " - Posicion no disponible", 0ah, 0dh, 24h
    
    msg_ganador db "Felicitaciones has ganado", 0ah, 0dh, 24h
    msg_perdedor db "Lamentablemente no has hallado todos los barcos ):", 0ah, 0dh, 24h
    msg_repetir db "Desea jugar nuevamente (Y/N): ", 24h
    
    si_impacto db " - Impacto realizado", 0ah, 0dh, 24h
    no_impacto db " - Sin impacto", 0ah, 0dh, 24h
    
    pos_ini dw 37
    vida db 0
    
    porta_avion db 5
    crucero db 4
    submarino db 3
    
    barco_total db 5+4+3
    
    imp_tablero db 0ah, 0dh, "El tablero:", 0ah, 0ah, 0dh
    
    tablero db "x---------------------------x", 0ah, 0dh
            db "|   | A | B | C | D | E | F |", 0ah, 0dh
            db "| 1 | . | . | . | . | . | . |", 0ah, 0dh
            db "| 2 | . | . | . | . | . | . |", 0ah, 0dh
            db "| 3 | . | . | . | . | . | . |", 0ah, 0dh
            db "| 4 | . | . | . | . | . | . |", 0ah, 0dh
            db "| 5 | . | . | . | . | . | . |", 0ah, 0dh
            db "| 6 | . | . | . | . | . | . |", 0ah, 0dh
            db "x---------------------------x", 0ah, 0dh, 0ah, 0dh, 24h  
            
    cmp_tab db "x---------------------------x", 0ah, 0dh
            db "|   | A | B | C | D | E | F |", 0ah, 0dh
            db "| 1 | . | . | . | . | . | . |", 0ah, 0dh
            db "| 2 | . | . | . | . | . | . |", 0ah, 0dh
            db "| 3 | . | . | . | . | . | . |", 0ah, 0dh
            db "| 4 | . | . | . | . | . | . |", 0ah, 0dh
            db "| 5 | . | . | . | . | . | . |", 0ah, 0dh
            db "| 6 | . | . | . | . | . | . |", 0ah, 0dh
            db "x---------------------------x", 0ah, 0dh, 0ah, 0dh, 24h
    
.code
.start

singleton proc
    repetir:
        call principal
        mov ah, 09h         
        lea dx, msg_repetir
        int 21h
        
        mov ah, 01h         ;funcion para captura de dato LETRA
        int 21h
        cmp al, "Y"
        je limpieza
        jmp terminar_programa
        
    limpieza:
        call limpiar_tablero
        jmp repetir
    
    terminar_programa:
        ret
singleton endp

principal proc
    call cargar_datos
    xor ax, ax
    xor bx, bx
    xor cx, cx
    xor dx, dx
    call imprimir
    
    get_pos:
        mov ah, 09h         
        lea dx, msg_ing
        int 21h
        
        mov ah, 01h         ;funcion para captura de dato LETRA
        int 21h
        mov bh, al
        
        mov ah, 01h         ;funcion para captura de dato NUM
        int 21h
        mov bl, al   
        jmp rango
    
    rango: 
        cmp bh, 46h
        jnle error_pos
        cmp bh, 41h
        jnge error_pos
        cmp bl, 36h
        jnle error_pos
        cmp bl, 31h
        jnge error_pos
        jmp cmp_disponible
        
    cmp_disponible:
        call get_pos_tab
        mov bx, offset cmp_tab
        xor ax, ax
        mov al, byte ptr [bx + di]
        
        cmp ax, "0"
        je error_disp
        cmp ax, "1"
        je error_disp
        
        mov bl, vida
        add bl, 1
        mov vida, bl
        
        cmp ax, "."
        je no_barco
        jmp si_barco
    
    error_disp:
        mov ah, 09h         
        lea dx, msg_err_disp
        int 21h
        jmp get_pos    
        
    error_pos:
        mov ah, 09h         
        lea dx, msg_err_pos
        int 21h  
        jmp get_pos
    
    no_barco:
        mov ah, 09h         
        lea dx, no_impacto
        int 21h  
        mov bx, offset tablero
        mov byte ptr [bx + di], "0"
        mov bx, offset cmp_tab
        mov byte ptr [bx + di], "0"
        mov cl, vida
        cmp cl, 20
        je perdedor
        call imprimir
        jmp get_pos
        
    si_barco:
        mov ah, 09h         
        lea dx, si_impacto
        int 21h  
        mov bx, offset tablero
        mov byte ptr [bx + di], "1"
        mov bx, offset cmp_tab
        mov byte ptr [bx + di], "1"
        jmp comprobar_estado:
        
    comprobar_estado:
        xor cx, cx
        mov cl, barco_total
        sub cl, 1
        mov barco_total, cl
        cmp cl, 0
        je ganador
        mov cl, vida
        cmp cl, 20
        je perdedor
        call imprimir
        jmp get_pos
    
    ganador:
        call imprimir
        mov ah, 09h         
        lea dx, msg_ganador
        int 21h
        jmp salir_principal
        
    perdedor:        
        call imprimir
        mov ah, 09h         
        lea dx, msg_perdedor
        int 21h
        jmp salir_principal
        
    salir_principal:        
        ret
    
principal endp

imprimir proc
    mov ah, 09h         
    lea dx, imp_tablero
    int 21h
    ret
imprimir endp

get_pos_tab proc
    push ax
    mov di, pos_ini
    xor ax, ax
    push bx
    mov al, bh
    sub al, 41h
    mov bl, 4
    mul bl
    mov ah, 0
    add di, ax
    pop bx
    mov al, bl
    sub al, 30h
    mov bx, 31
    mul bx
    add di, ax
    pop ax
    ret
get_pos_tab endp

limpiar_tablero proc
    xor ax, ax
    xor bx, bx
    xor cx, cx
    xor dx, dx
    mov vida, 0
    mov barco_total, 5+3+4
    mov ax, 1 ;fila
    mov di, pos_ini
    push ax
    mov dl, 31
    mul dl
    add di, ax
    mov ax, 0 ;recorre columna
    
    limpiar:
        mov dh, al
        mov dl, 4
        mul dl
        push di
        add di, ax
        mov bx, offset tablero
        mov byte ptr[bx + di], "."
        mov bx, offset cmp_tab
        mov byte ptr[bx + di], "."
        pop di
        xor ax, ax
        mov al, dh
        add al, 1
        cmp ax, 6
        je aumentar_fila
        jmp limpiar
    
    aumentar_fila:
        mov di, pos_ini
        pop ax
        add ax, 1
        cmp ax, 7
        je salir_limpiar
        push ax
        mov dl, 31
        mul dl
        add di, ax
        mov ax, 0
        jmp limpiar
        
    salir_limpiar:
        ret
        
limpiar_tablero endp
        
cargar_datos proc
    xor ax, ax
    xor bx, bx
    xor cx, cx
    xor dx, dx
    load_data:
        mov ah, 09h         
        lea dx, msg
        int 21h
        mov ah, 01h         ;funcion para captura de dato LETRA
        int 21h
        
    
    barcos:
        mov ah, 7 ;tablero+1
        mov al, porta_avion; tamanio
        call set_barco
        mov ah, 7
        mov al, crucero
        call set_barco
        mov ah, 7
        mov al, submarino
        call set_barco
        ret
            
cargar_datos endp

set_barco proc
    get_rand_pos:
        push ax
        mov cl, ah
        sub cl, al
        call rand_barco_pos
        push dx
        mov cl, ah
        sub cl, al
        call rand_1al6
        mov bh, dl
        add bh, 40h
        pop dx
        mov bl, dl
        add bl, 30h
        pop ax
        call get_pos_tab
        push ax
        
    cmp_rand_disp:
        mov ah, 0
        sub al, 1
        mov dh, al
        mov dl, 31
        mul dl  
        push di
        add di, ax
        mov bx, offset cmp_tab
        mov cl, byte ptr[bx + di]
        xor ax, ax
        mov al, dh
        pop di
        cmp cl, "."
        jne rep_proc
        cmp ax, 0
        je pre_setear
        jmp cmp_rand_disp
        
    pre_setear:
        pop ax
        
    setear:
        mov ah, 0
        sub al, 1
        mov dh, al
        mov dl, 31
        mul dl
        push di
        add di, ax
        mov byte ptr[bx + di], "Z"
        pop di
        xor ax, ax
        mov al, dh
        cmp ax, 0
        je salir_set_barco
        jmp setear
        
    rep_proc:
        pop ax
        jmp get_rand_pos
        
    salir_set_barco:
        ret
        
set_barco endp

rand_1al6 proc
    mov ah, 0h ;interrupcion para obtener el tiempo del sistema
    int 1AH     ;pulso del reloj guardado en dx
    
    mov ax, dx  ;mueve el valor de dx a ax
    xor dx, dx   ;setea el valor de dx a 1
    mov cx, 6   ;cx= 6 divisor que genera un numero entre 1 y 6
    div cx      ;divide ax por cx, bx=6 y dx=1 
   
    ret
rand_1al6 endp 
    
;Recibe por cx el tamanio del barco    

rand_barco_pos proc
    push cx
    mov ah, 00h ;interrupcion para obtener el tiempo del sistema
    int 1AH 
    mov ax, dx
    xor dx, dx
    pop cx
    div cx
    
    ret  
rand_barco_pos endp
                                          
