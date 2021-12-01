.8086
.model small
.stack 100h
.data
    ; Porta-aviones PPPPP
    ; Nave de batalla BBBB
    ; Crucero de batalla CCC
    ; Submarino SSS
    ; Destructor DD
    msj db "Ingrese Y para continuar, otra tecla para salir", 0dh, 0ah, 24h
    msjError db "No se pudo ubicar la nave, simbolo incorrecto", 0dh, 0ah, 24h
    bandera db 0
    
    seed        dw 0
    weylseq     dw 0
    prevRandInt dw 0
    
    impTablero db "El tablero:", 0dh, 0ah, 0dh, 0ah
    
    tablero   db "x-------------------------------------------x ", 0dh, 0ah
            db "|   | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | ", 0dh, 0ah
            db "| A | . | . | . | . | . | . | . | . | . | . | ", 0dh, 0ah
            db "| B | . | . | . | . | . | . | . | . | . | . | ", 0dh, 0ah
            db "| C | . | . | . | . | . | . | . | . | . | . | ", 0dh, 0ah
            db "| D | . | . | . | . | . | . | . | . | . | . | ", 0dh, 0ah
            db "| E | . | . | . | . | . | . | . | . | . | . | ", 0dh, 0ah
            db "| F | . | . | . | . | . | . | . | . | . | . | ", 0dh, 0ah
            db "| G | . | . | . | . | . | . | . | . | . | . | ", 0dh, 0ah
            db "| H | . | . | . | . | . | . | . | . | . | . | ", 0dh, 0ah
            db "| I | . | . | . | . | . | . | . | . | . | . | ", 0dh, 0ah
            db "| J | . | . | . | . | . | . | . | . | . | . | ", 0dh, 0ah
            db "x-------------------------------------------x ", 0dh, 0ah, 24h
    chars db 48  ;Cantidad de caracteres por fila
    rows db 12  ;Cantidad de filas
    colW db 4   ;Cantidad de caracteres por columna del tablero

.code
    ; Importo funciones de la libreria
    extrn comprobar_lugar:proc
    extrn obtenerIndice:proc
    extrn seedInicial:proc

main proc
    mov ax, @data
    mov ds, ax
    
    call seedInicial
    ;Inicializo las tres variables con el seed porque si no hay patrones
    mov seed, ax
    mov weylseq, ax
    mov prevRandInt, ax

    inicio:
        call Clearscreen
    
        xor ax, ax
        xor bx, bx
        xor cx, cx
        xor dx, dx
        xor si, si
        xor di, di
        
        mov bx, offset tablero
    
    
    ubicarP:
        mov bandera[0], 0
        call generarFyC
        call ElijeHoV
        mov si, ax
        mov al, "P" ;Quiero un porta-aviones
        call ubicarBarco
        cmp bandera[0], 1
        je ubicarP
        call chequearError
    
    ubicarB:
        mov bandera[0], 0
        call generarFyC
        call ElijeHoV
        mov si, ax
        mov al, "B" ;Quiero una nave de batalla
        call ubicarBarco
        cmp bandera[0], 1
        je ubicarB
        call chequearError
    
    ubicarD:
        mov bandera[0], 0
        call generarFyC
        call ElijeHoV
        mov si, ax
        mov al, "D" ;Quiero un destructor
        call ubicarBarco
        cmp bandera[0], 1
        je ubicarD
        call chequearError
    
    ubicarS:
        mov bandera[0], 0
        call generarFyC 
        call ElijeHoV
        mov si, ax
        mov al, "S" ;Quiero un submarino
        call ubicarBarco
        cmp bandera[0], 1
        je ubicarS
        call chequearError
    
    ubicarC:
        mov bandera[0], 0
        call generarFyC
        call ElijeHoV
        mov si, ax
        mov al, "C" ;Quiero un crucero
        call ubicarBarco
        cmp bandera[0], 1
        je ubicarC
        call chequearError
      
    imprimir:
        ; Imprimir tablero
        mov ah, 9
        mov dx, offset impTablero
        int 21h
    
        mov ah, 9
        mov dx, offset msj
        int 21h
    
        mov ah, 1
        int 21h
    
        cmp al, "y"
        jne fin
    
        jmp inicio
    
    fin:
        mov ax, 4c00h
        int 21h
main endp

comprobar_lugar proc
    ;Por Bx espera el offset del 
    ;creo esta funciÛn para no modificar los registros en ponerBarco
    ;Cuido el entorno
    push ax
    push bx   ; El offset del tablero no me interesa modificarlo asi que por las dudas lo guardo, para no romper nada
    push cx
    push dx
    ;push si
    push di
    pushf
    ;xor ax, ax
    ;xor bx, bx
    ;xor cx, cx
    ;xor dx, dx
    ;xor si, si
    ;xor di, di
    
    comprobar:
        mov ah, byte ptr [bx + di] ;muevo lo que haya en el tablero a AH
        cmp ah, '.' ;compruebo si hay . (vacÌo)
        jne ocupado ;si es diferente . entonces hay un barco o un lÌmite
        ;sino, sigo comparando
        add di, dx ; Le sumo los caracteres por columna
        loop comprobar
        jmp fin_comprobar_lugar ;cuando termine el loop, que termine la funciÛn
    
    ocupado:
        mov byte ptr [si], 1 ;activo la bandera que indica que hay algo ocupado
        push dx
        push ax
        
        mov ah, 9
        mov dx, offset msj_ocupado
        int 21h
        
        pop ax
        pop dx
    
    fin_comprobar_lugar:
        popf
        pop di
        ;pop si
        pop dx
        pop cx
        pop bx
        pop ax
        ret
comprobar_lugar endp

; Recibo las coordenadas por DX (ej: DX = "B6")
; Recibo el ancho de las columnas por CL
; Recibo el largo de las filas por CH
;Devuelvo el Ìndice correspondiente por DI
obtenerIndice proc
    ;Cuido el entorno
    push ax
    push bx
    push cx
    push dx
    pushf
    xor ax, ax
    xor bx, bx
    xor di, di
    
    ;Poner un circulo en la posicion A4: x + y.cols -> 4 + 1.10 = 14 -> serÌa la posicion/indice del arreglo si consideramos solo 10 columnas
    ;Calculo la columna
    mov al, cl
    add di, ax ; Me corro una columna a la derecha por que la primera es la de las letras
    mov bl, 2 ; Pongo un 2 en BL
    div bl ; Divido AL por 2
    xor ah, ah
    add di, ax ; Agrego AL a DI para posicionarme en el centro de la columna del 0
    ; mov di, 6 ; Lo anterior es lo mismo que esto si el ancho de columna es 4
    mov al, dl ; Pongo la coordenada de la columna (el numero) en AL
    sub al, 30h ; Paso el caracter a numero
    
    mul cl ; multiplico AL por CL
    add di, ax ; Me posiciono en el Ìndice correspondiente
    
    xor ax, ax
    ;Sumo las filas a la columna
    mov al, 2 ; Me posiciono en la fila A
    
    add al, dh ; Pongo el caracter de la fila en AL
    sub al, 41h ; Paso la letra ascii a numero (asumiendo que es una letra mayuscula)
    
    mul ch ; multiplico AL por Ch (por el largo de las filas)
    add di, ax ; Sumo a DI (la posicion en X) lo que tengo en AL (la posicion en y por la cant de columnas)
    
    popf
    ; pop di ; Devuelvo el indice correspondiente por DI
    ; pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
obtenerIndice endp

seedInicial proc
    ; Genera una semilla a partir de la fecha y hora del sistema, la devuelve por AX
    push bx
    push cx
    push dx
    pushf
    
    xor ax, ax
    xor cx, cx
    xor dx, dx
    
    mov ah, 2ah   ;Obtengo la fecha
    int 21h   ;CX = YY, DH = M, DL = D, AL = w (dia de la semana, ej: 00h = Domingo) 
    
    xor ah, ah  ;Limpio AH
    
    add bx, cx
    add bx, dx
    add bx, ax
    
    mov ah, 2ch   ;Obtengo la hora, CH = Hr, CL = Min, DH = Sec, DL = 1/100sec
    int 21h
    
    add bx, cx
    add bx, dx
    or bx, 8101h  ;Necesito que el seed sea distinto de cero e impar en el bit menos significativo de cada byte
    mov ax, bx
    
    popf
    pop dx
    pop cx
    pop bx
    ret
seedInicial endp

Clearscreen proc
    push ax
    push es
    push cx
    push di
    mov ax,3
    int 10h
    mov ax,0b800h
    mov es,ax
    mov cx,1000
    mov ax,7
    mov di,ax
    cld
    rep stosw
    pop di
    pop cx
    pop es
    pop ax
    ret 
Clearscreen endp


; Recibe en BX el offset del tablero
; en DI la coordenada en X + la coordenada en Y multiplicada por la cantidad de columnas (la posicion correspondiente)
; en DX la cantidad de caracteres por fila (para ubicar verticalmente) o tama√±o de las columnas (para ubicar horizontalmente)
; en AL el caracter para representar el barco
; y en CX el tama√±o del barco a colocar
ponerBarco proc
    ;Cuido el entorno
    push ax
    push bx   ; El offset del tablero no me interesa modificarlo asi que por las dudas lo guardo, para no romper nada
    push cx
    push dx
    push si
    push di
    pushf
    xor ax, ax
    xor bx, bx
    xor cx, cx
    xor dx, dx
    xor si, si
    xor di, di
    
    mov si, offset bandera
    call comprobar_lugar
    cmp bandera[0], 1
    je fin_ponerBarco
    
    barco:
        mov byte ptr [bx + di], al ; Pongo un simbolo  en la posicion DI del tablero
        add di, dx ; Le sumo los caracteres que hay por fila para pasar a la fila de abajo
        loop barco
    
    fin_ponerBarco:
        ; mov bandera[0], 0 ;reinicio la bandera
        popf
        pop di
        pop si
        pop dx
        pop cx
        pop bx
        pop ax
        ret
ponerBarco endp


; Recibo el simbolo del barco por AL
; El offset del tablero por BX
; Las coordenadas por DX
;y si es horizontal u vertical por SI
;Devuelve por CX 0 si se le pas¢ un simbolo de barco erroneo
ubicarBarco proc
    ;Cuido el entorno
    push ax
    push bx
    push dx
    push di
    pushf
    xor cx, cx
    
    mov cl, colW
    mov ch, chars
    call obtenerIndice ;Me devuelve las coordenadas transformadas en un °ndice por DI
    
    mov dx, 0 ; Limpio dx
    cmp si, 0
    je horizontal
    add dl, ch    ; paso el largo de cada fila a DL para que se ubique de forma vertical
    jmp simbolo
    
    horizontal:
        add dl, cl    ;paso el ancho de cada columna para que sea horizontal
    
    simbolo:
        mov cx, 0
        ; Porta-aviones PPPPP
        ; Nave de batalla BBBB
        ; Crucero de batalla CCC
        ; Submarino SSS
        ; Destructor DD
        cmp al, "P"
        je portaAviones
        cmp al, "B"
        je naveBatlla
        cmp al, "C"
        je crucero
        cmp al, "S"
        je submarino
        cmp al, "D"
        je destructor
        ;no era ninguno, es un barco erroneo
        jmp salir
    
    portaAviones:
        add cx, 1   ;Tama§o 5
    naveBatlla:
        add cx, 1   ;Tama§o 4
    crucero:
    submarino:
        add cx, 1   ;Ambos de tama§o 3
    destructor:
        add cx, 2   ;Tama§o 2
    
    call ponerBarco ; Tambien le paso el indice por DI
    
    salir:
        popf
        pop di
        pop dx
        pop bx
        pop ax
        ret
ubicarBarco endp

chequearError proc
    push ax
    push dx
    pushf
    cmp cx, 0
    jne finChequeo
    mov ah, 9
    mov dx, offset msjError
    int 21h
    finChequeo:
        popf
        pop dx
        pop ax
        ret
chequearError endp

generarFyC proc
    ;Recibe por AX un seed o 0 para usar el existente
    ; por SI el offset de la secuencia de weyl
    ;y por DI el offset del numero random anterior
    ;devuelvo en DX la posicion random
    ;cuido el entorno
    push bx
    pushf

    mov ax, seed
    mov si, weylseq
    mov di, prevRandInt
    int 81h   ;Genero un numero random
    ;Recibo por AX el numero random
    mov weylseq, si
    mov prevRandInt, ax

    xor ah, ah  ;Limpio AH para la division de 8bits
    mov bl, 0Ah
    div bl

    add ah, 30h    ;Convierto a numero ascii el resto
    mov dh, ah

    xor ah, ah  ;Limpio AH para la division de 8bits
    mov bl, 0Ah
    div bl

    add ah, 30h    ;Convierto a ascii el resto
    mov dl, ah

    ;devuelvo el entorno
    popf
    pop bx
    ret
generarFyC endp
  
;Elige de forma aleatoria si el barco ser  vertical u horizontal
ElijeHoV proc
    ;Recibe por AX un seed o 0 para usar el existente
    ; por SI el offset de la secuencia de weyl
    ;y por DI el offset del numero random anterior
    ;devuelvo en DX la posicion random
    ;cuido el entorno
    push si
    push dx
    push bx
    pushf

    mov ax, seed
    mov si, weylseq
    mov di, prevRandInt
    int 81h   ;Genero un numero random
    ;Recibo por AX el numero random
    mov weylseq, si
    mov prevRandInt, ax

    xor ah, ah  ;Limpio AH para la division de 8bits
    mov bl, 2
    div bl

    mov al, ah
    xor ah, ah

    ;devuelvo el entorno
    popf
    pop bx
    pop dx
    pop si
    ret
ElijeHoV endp

end main