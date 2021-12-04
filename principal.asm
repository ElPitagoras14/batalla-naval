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

singleton proc                   ;Proceso del programa que controla el juego y repeticion
    repetir:                     ;Funcion que da lugar al juego y pregunta si desea repetir
        call principal           ;Llamo al proceso que es el juego
        mov ah, 09h              ;Valor para interrupcion
        lea dx, msg_repetir      ;Cargo el msg_repetir
        int 21h                  ;Interrupcion para mostrar por pantalla
        
        mov ah, 01h              ;Valor para captura de dato
        int 21h                  ;Interrupcion para capturar dato (Se guarda en AL)
        cmp al, "Y"              ;Comparo si el dato ingresado es "Y"
        je limpieza              ;Si AL == "Y" entonces salta a limpieza
        jmp terminar_programa    ;Sino salta a terminar el programa
        
    limpieza:                    ;Funcion que limpia el tablero y resetea valores
        call limpiar_tablero     ;Llama a proceso limpiar_tablero
        jmp repetir              ;Salta a repetir
    
    terminar_programa:           ;Funcion de salida
        ret                      ;Da el control al sistema
singleton endp                   ;Fin de proceso del programa

principal proc                   ;Proceso principal que se encarga de la logica del juego
    call cargar_datos            ;Llamo a proceso para precargar el juego (Seteo barcos de forma aleatoria)
    xor ax, ax                   ;Limpio registro
    xor bx, bx                   ;Limpio registro
    xor cx, cx                   ;Limpio registro
    xor dx, dx                   ;Limpio registro
    call imprimir                ;Llamo a proceso para imprimir tablero
    
    get_pos:                     ;Funcion para capturar la posicion como input
        mov ah, 09h              ;Valor para interrupcion
        lea dx, msg_ing          ;Cargo el msg_ing
        int 21h                  ;Interrupcion para mostrar por pantalla
        
        mov ah, 01h              ;Valor para captura de dato (Se captura la columna)
        int 21h                  ;Interrupcion para pedir dato
        mov bh, al               ;Se guarda el dato en BH
        
        mov ah, 01h              ;Valor para captura de dato (Se captura la fila)
        int 21h                  ;Interrupcion para mostrar por pantalla
        mov bl, al               ;Se guarda el dato en BL
        jmp rango                ;Salta a rango
    
    rango:                       ;Funcion que comprueba si la fila y columna estan en rango
        cmp bh, "F"              ;Compara con "F"
        jnle error_pos           ;Si su valor no es menor o igual salta a error_pos
        cmp bh, "A"              ;Compara con "A"
        jnge error_pos           ;Si su valor no es mayor o igual salta a error_pos
        cmp bl, "6"              ;Compara con "6"
        jnle error_pos           ;Si su valor no es menor o igual salta a error_pos
        cmp bl, "1"              ;Compara con "1"
        jnge error_pos           ;Si su valor no es mayor o igual salta a error_pos
        jmp cmp_disponible       ;Salta a cmp_disponible
        
    cmp_disponible:                  ;Funcion que comprueba si la posicion esta disponible
        call get_pos_tab             ;Llama a proceso que devuelve por di el offset adicional correspondiende a la fila y columna
        mov bx, offset cmp_tab       ;Obtenemos el offset de cmp_tab
        xor ax, ax                   ;Limpiamos AX
        mov al, byte ptr [bx + di]   ;Se guarda el valor de la fila y columna de cmp_tab en al
        
        cmp ax, "0"                  ;Compara con "0"
        je error_disp                ;Si su valor es igual salta a error_disp
        cmp ax, "1"                  ;Compara con "1"
        je error_disp                ;Si su valor es igual salta a error_disp
        
        mov bl, vida                 ;Obtenemos el valor de la vida(intentos realizados)
        add bl, 1                    ;Sumamos 1
        mov vida, bl                 ;Guardamos en el espacio de memoria de vida
        
        cmp ax, "."                  ;Compara con "."
        je no_barco                  ;Si es igual salta a no_barco
        jmp si_barco                 ;Salta a si_barco
    
    error_disp:                      ;Funcion que envia un mensaje de error cuando la posicion no esta disponible
        mov ah, 09h                  ;Valor para interrupcion
        lea dx, msg_err_disp         ;Cargamos msg_err_disp en DX
        int 21h                      ;Interrupcion para mostrar por pantalla
        jmp get_pos                  ;Salta a get_pos
        
    error_pos:                       ;Funcion que envia un mensaje de error cuando la posicion esta fuera de rango
        mov ah, 09h                  ;Valor para interrupcion
        lea dx, msg_err_pos          ;Cargamos msg_err_pos en DX
        int 21h                      ;Interrupcion para mostrar por pantalla
        jmp get_pos                  ;Salta a get_pos
    
    no_barco:                        ;Funcion que cambia el char en el tablero por 0 (Sin impacto)
        mov ah, 09h                  ;Valor para interrupcion
        lea dx, no_impacto           ;Cargamos no_impacto en DX
        int 21h                      ;Interrupcion para mostrar por pantalla
        mov bx, offset tablero       ;Guardamos en BX el offset de tablero
        mov byte ptr [bx + di], "0"  ;Cambiamos el valor de la posicion (Fila,Columna) a "0"
        mov bx, offset cmp_tab       ;Guardamos en BX el offset de cmp_tab
        mov byte ptr [bx + di], "0"  ;Cambiamos el valor de la posicion (Fila,Columna) a "0"
        mov cl, vida                 ;Obtenemos el valor de vida (Intentos)
        cmp cl, 20                   ;Comparamos con 20 (Valor que indica fin de intentos)
        jge perdedor                  ;Si es igual salta a perdedor
        call imprimir                ;Llama a imprimir para mostrar el tablero
        jmp get_pos                  ;Salta a get_pos
        
    si_barco:                        ;Funcion que cambia el char en el tablero por 1 (Impacto realizado)
        mov ah, 09h                  ;Valor para interrupcion
        lea dx, si_impacto           ;Cargamos si_impacto en DX
        int 21h                      ;Interrupcion para mostrar por pantalla
        mov bx, offset tablero       ;Guardamos en BX el offset de tablero
        mov byte ptr [bx + di], "1"  ;Cambiamos el valor de la posicion (Fila,Columna) a "1"
        mov bx, offset cmp_tab       ;Guardamos en BX el offset de cmp_tab
        mov byte ptr [bx + di], "1"  ;Cambiamos el valor de la posicion (Fila,Columna) a "1"
        jmp comprobar_estado:        ;Salta a comprobar_estado
        
    comprobar_estado:                ;Funcion para verificar victoria o derrota cuando se acerto a un barco
        xor cx, cx                   ;Limpiamos CX
        mov cl, barco_total          ;Obtenemos el valor de barco_total(Num casilla que ocupan los barcos)
        sub cl, 1                    ;Restamos 1
        mov barco_total, cl          ;Guardamos nuevamente
        cmp cl, 0                    ;Comparamos el valor con 0 (Indica que no quedan mas barcos por impactar)
        je ganador                   ;Si el valor es igual salta a ganador
        mov cl, vida                 ;Obtenemos el valor de vida(Intentos)
        cmp cl, 20                   ;Comparamos con 20 (Valor que indica fin de intentos) 
        je perdedor                  ;Si es igual salta a perdedor
        call imprimir                ;Llama a imprimir para mostrar el tablero
        jmp get_pos                  ;Salta a get_pos
    
    ganador:                         ;Funcion que muestra mensaje al ganar
        call imprimir
        mov ah, 09h                  ;Valor para interrupcion
        lea dx, msg_ganador          ;Cargamos msg_ganador en DX
        int 21h                      ;Interrupcion par amostrar por pantalla
        jmp salir_principal          ;Salta a salir_principal
        
    perdedor:                        ;Funcion que muestra mensaje al ganar
        mov ah, 09h                  ;Valor para interrupcion
        lea dx, cmp_tab              ;Cargamos cmp_tab en DX
        int 21h                      ;Interrupcion par amostrar por pantalla
        mov ah, 09h                  ;Valor para interrupcion
        lea dx, msg_perdedor         ;Cargamos msg_perdedor en DX
        int 21h                      ;Interrupcion par amostrar por pantalla
        jmp salir_principal          ;Salta a salir_principal
        
    salir_principal:                 ;Funcion para salir de la logica del juego
        ret                          ;Devuelve el control al procedimiento que lo llamo(Singleton)
    
principal endp                       ;Fin proceso principal

imprimir proc                        ;Proceso que muestra el tablero por pantalla
    mov ah, 09h                      ;Valor para interrupcion
    lea dx, tablero                  ;Cargamos tablero en DX
    int 21h                          ;Interrupcion par amostrar por pantalla
    ret                              ;Devuelve el control al proceso que lo llamo
imprimir endp                        ;Fin proceso imprimir

get_pos_tab proc                     ;Proceso que devuelve por DI el offset adicional para la posicion pasada por BX
    push ax                          ;Guardamos AX en stack
    mov di, pos_ini                  ;Obtenemos el valor de pos_ini(Espacios en el tablero con "basura") en DI
    xor ax, ax                       ;Limpiamos ax
    push bx                          ;Guardamos BX(Posicion) en stack
    mov al, bh                       ;Asignamos BH(Columna) a AL
    sub al, 41h                      ;Restamos 41h
    mov bl, 4                        ;Asignamos 4 a BL
    mul bl                           ;Multiplicamos AX con BL
    mov ah, 0                        ;Limpiamos AH
    add di, ax                       ;Sumamos AX a DI (Esto posiciona el offset en la columna correspondiente)
    pop bx                           ;Obtenemos BX del stack
    mov al, bl                       ;Asignamos BL(Fila) a AL
    sub al, 30h                      ;Restamos 30h
    mov bl, 31                       ;Asignamos 31 a BL
    mul bl                           ;Multiplicamos AX con BL
    add di, ax                       ;Sumamos AX a DI (Esto posiciona el offset en la fila correspondiente)
    pop ax                           ;Obtenemos AX del stack
    ret                              ;Devolvemos el control al proceso que lo llamo
get_pos_tab endp                     ;Fin proceso get_pos_tab

limpiar_tablero proc                 ;Proceso que limpia el tablero y setea los valores iniciales
    xor ax, ax                       ;Limpio registro
    xor bx, bx                       ;Limpio registro
    xor cx, cx                       ;Limpio registro
    xor dx, dx                       ;Limpio registro
    mov vida, 0                      ;Setea vida(Intentos) a 0
    mov barco_total, 5+3+4           ;Setea barco_total al 12 (Num de casillas que ocupan los barcos)
    mov ax, 1                        ;Inicia en la fila 1 (Necesario de esta manera debido al valor de pos_ini)
    mov di, pos_ini                  ;Obtenemos pos_ini en DI
    push ax                          ;Guardamos AX(Fila actual) en el stack
    mov dl, 31                       ;Asignamos 31 a DL
    mul dl                           ;Multiplicamos AX con DL
    add di, ax                       ;Sumamos AX a DI (Esto posiciona el offset en la fila correspondiente)
    mov ax, 0                        ;Asignamos 0 a AX
    
    limpiar:                         ;Funcion que recorre todas las columnas de una fila y asigna "."
        mov dh, al                   ;Asignamos AL a DH(Para guardar la columna actual)
        mov dl, 4                    ;Asignamos 4 a DL
        mul dl                       ;Multiplicamos AX con DL
        push di                      ;Guardamos DI en el stack (Para salvar el offset de la fila sin sumar columna)
        add di, ax                   ;Sumamos AX a DI (Esto posiciona el offset en la columna correspondiente)
        mov bx, offset tablero       ;Guardamos en BX el offset de tablero
        mov byte ptr [bx + di], "."  ;Cambiamos el valor de la posicion (Fila,Columna) a "."
        mov bx, offset cmp_tab       ;Guardamos en BX el offset de cmp_tab
        mov byte ptr [bx + di], "."  ;Cambiamos el valor de la posicion (Fila,Columna) a "."
        pop di                       ;Obtenemos DI del stack (Cargamos el offset de la fila sin sumar columna para nuevamente el calculo)
        xor ax, ax                   ;Limpiamos AX
        mov al, dh                   ;Asignamos DH(Columna actual) a AL
        add al, 1                    ;Sumamos 1 a AL(Siguiente columna)
        cmp ax, 6                    ;Comparamos AX con 6 (Columna final)
        je aumentar_fila             ;Si el valor es igual salta a aumentar_fila
        jmp limpiar                  ;Salta a limpiar
    
    aumentar_fila:                   ;Funcion que aumenta el offset de DI con el de la fila actual
        mov di, pos_ini              ;Asigno pos_ini a DI
        pop ax                       ;Obtengo AX(Fila actual) del stack
        add ax, 1                    ;Sumo 1 a AX(Fila siguiente)
        cmp ax, 7                    ;Comparo con 7 (Si la siguiente fila es 7)
        je salir_limpiar             ;Si el valor es igual salta a salir_limpiar
        push ax                      ;Guardo AX(Fila siguiente, ahora actual)  en el stack
        mov dl, 31                   ;Asigno 31 a DL
        mul dl                       ;Multiplico AX con DL
        add di, ax                   ;Sumamos AX a DI (Esto posiciona el offset en la fila correspondiente)
        xor ax, ax                   ;Limpiamos AX
        jmp limpiar                  ;Salta a limpiar
        
    salir_limpiar:                   ;Funcion para salir de limpiar
        ret                          ;Devuelve el control al proceso que lo llamo
        
limpiar_tablero endp                 ;Fin proceso limpiar_tablero
        
cargar_datos proc                    ;Proceso para cargar datos (Setear barcos aleatoriamente)
    xor ax, ax                       ;Limpio registro
    xor bx, bx                       ;Limpio registro
    xor cx, cx                       ;Limpio registro
    xor dx, dx                       ;Limpio registro
    
    load_data:                       ;Funcion para dar inicio a la carga de datos
        mov ah, 09h                  ;Valor para interrupcion
        lea dx, msg                  ;Cargamos msg en DX
        int 21h                      ;Interrupcion para mostrar por pantalla
        mov ah, 01h                  ;Valor para captura de dato
        int 21h                      ;Interrupcion para obtener dato
    
    barcos:
        mov ah, 7                    ;Asignamos 7(Tamanio tablero + 1) a AH
        mov al, porta_avion          ;Asignamos porta_avion(Tamanio) a AL
        call set_barco               ;Llama a set_barco                          
        
        ;Mismo proceso para crucero y submarino
        mov ah, 7
        mov al, crucero
        call set_barco
        mov ah, 7
        mov al, submarino
        call set_barco
        ret                          ;Devuelve el control al proceso que lo llamo
            
cargar_datos endp                    ;Fin proceso cargar_datos

                                     ;Recibe AH tamanio tablero + 1 y AL tamanio barco
set_barco proc                       ;Proceso para setear un barco en el tablero de forma aleatoria
    get_rand_pos:                    ;Funcion para obtener la posicion(Fila,Columna) aleatoria
        push ax                      ;Guardamos AX en stack
        mov cl, ah                   ;Asignamos AH(tamanio tablero + 1) a CL
        sub cl, al                   ;Restamos AL(tamanio barco) a CL
        call rand_barco_pos          ;Llama a rand_barco_pos que devuelve en DL un numero del 1 al (tamanio_tablero + 1 - tamanio_barco)
        push dx                      ;Guardamos DX(Num aleatorio) en el stack
        call rand_1al6               ;Llama a rand_1al6 que devuelve en DL un numero del 1 al 6
        mov bh, dl                   ;Asignamos DL(Num del 1 al 6) a BH
        add bh, 40h                  ;Sumamos 40h a BH(Se torna en la columna)
        pop dx                       ;Obtenemos DX(Num del 1 al <tamanio_tablero + 1 - tamanio_barco>) del stack
        mov bl, dl                   ;Asignamos DL a BL
        add bl, 30h                  ;Sumamos 30h a BL(Se torna en la fila)
        pop ax                       ;Obtenemos AX del stack
        call get_pos_tab             ;Llama get_pos_tab que devuelve el offset adicional de la posicion en DI
        push ax                      ;Guardamos AX en el stack
        
                                     
                                     ;Ejemplo visual - Busqueda en la columna hacia arriba
                                     
                                     ;Iteracion 1          Iteracion 2         Iteracion 3
                                     ;| . |   DI  | . |    | . |   DI  | . |   | . |   DI  | . |
                                     ;| . |   .   | . |    | . |   .   | . |   | . |   .   | . |
                                     ;| . |   .   | . |    | . |   .   | . |   | . | DI+AX | . |
                                     ;| . |   .   | . |    | . | DI+AX | . |   | . |   .   | . |
                                     ;| . | DI+AX | . |    | . |   .   | . |   | . |   .   | . |
                                     
    cmp_rand_disp:                   ;Funcion que comprueba si la posicion aleatoria obtenida esta disponible para el tamanio del barco
        mov ah, 0                    ;Asigna AH a 0
        sub al, 1                    ;Restamos 1 a AL(Tamanio del barco)
        mov dh, al                   ;Asignamos AL a DH(Guarda la casilla actual del barco a verificar)
        mov dl, 31                   ;Asignamos 31 a DL
        mul dl                       ;Multiplicamos AX a DL
        push di                      ;Guardamos el offset de DI en el stack
        add di, ax                   ;Sumamos AX a DI (Ahora el offset esta para la fila y columna obtenida pero N-1 filas abajo)
                                     ;Donde N es el tamanio del barco
        mov bx, offset cmp_tab       ;Guardamos el offset de cmp_tab en BX
        mov cl, byte ptr[bx + di]    ;Guardamos el char de esa posicion del cmp_tab en CL
        xor ax, ax                   ;Limpiamos AX
        mov al, dh                   ;Asignamos DH(Casilla actual del barco) a AL
        pop di                       ;Obtenemos DI(Offset unicamente con el de la posicion aleatoria)
        cmp cl, "."                  ;Comparamos el char de la posicion con "."
        jne rep_proc                 ;Si el valor no es igual salta a rep_proc
        cmp ax, 0                    ;Comparamos AX con 0 (Significa que ya revisamos todas las casillas que ocuparia el barco)
        je pre_setear                ;Si el valor es igual salta a pre_setear
        jmp cmp_rand_disp            ;Salta a cmp_rand_disp
        
    pre_setear:                      ;Funcion que realiza las condiciones antes de setear el barco
        pop ax                       ;Obtenemos AX(AH=7 y AL=Tamanio_barco) del stack
                                     
                                     ;Misma logica que cmp_rand_disp solo que en vez de comprobar ahora asigna
    setear:                          ;Funcion para setear en el cmp_tab el barco
        mov ah, 0                    ;
        sub al, 1                    ;
        mov dh, al                   ;
        mov dl, 31                   ;
        mul dl                       ;
        push di                      ;
        add di, ax                   ;
        mov byte ptr[bx + di], "H"   ;
        pop di                       ;
        xor ax, ax                   ;
        mov al, dh                   ;
        cmp ax, 0                    ;Comparamos AX con 0 (Significa que ya seteamos todas las casillas que ocupa el barco)
        je salir_set_barco           ;Si el valor es igual salta a salir_set_barco
        jmp setear                   ;Salta a setear
        
    rep_proc:                        ;Funcion para las condiciones previas a repetir el proceso de obtener otra posicion random
        pop ax                       ;Obtenemos AX(AH=7 y AL=Tamanio_barco) del stack
        jmp get_rand_pos             ;Salta a get_rand_pos
        
    salir_set_barco:                 ;Funcion para salir de set_barco
        ret                          ;Devuelve el control al proceso que lo llamo
        
set_barco endp                       ;Fin del proceso set_barco

rand_1al6 proc                       ;Proceso que retorna en DL un numero del 1 al 6
    mov ah, 0h                       ;Interrupcion para obtener el tiempo del sistema
    int 1AH                          ;Pulso del reloj guardado en DX
    mov ax, dx                       ;Mueve el valor de DX a AX
    xor dx, dx                       ;Setea el valor de DX a 1
    mov cx, 6                        ;CX= 6 divisor que genera un numero entre 0 y 5 como residuo
    div cx                           ;Divide AX por CX, BX=6 y DX=1 
    add dl, 1                        ;Sumamos 1 para que el rango sea del 1 al 6
    ret                              ;Devuelve el control al proceso que lo llamo
rand_1al6 endp                       ;Fin proceso rand_1al6
    
                                     ;Recibe por cx el tamanio del barco    
rand_barco_pos proc                  ;Proceso que devuelve un numero del 1 al CX(tamanio_tablero + 1 - tamanio_barco)
    push cx                          ;Guardamos CX
    mov ah, 00h                      ;interrupcion para obtener el tiempo del sistema
    int 1AH                          ;Pulso del reloj guardado en DX
    mov ax, dx                       ;Mueve el valor de DX a AX
    xor dx, dx                       ;Setea el valor de DX a 1                       
    pop cx                           ;Obtenemos CX que es el divisor y genera un numero entre 0 y CX-1 como residuo
    div cx                           ;Divide AX por CX
    add dl, 1                        ;Sumamos 1 para que el rango sea del 1 al CX                                     
    ret                              ;Devuelve el control al proceso que lo llamo
rand_barco_pos endp                  ;Fin proceso rand_barco_pos