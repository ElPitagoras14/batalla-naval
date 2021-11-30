.8086
.model small
.stack 100h
.data
    msj db "Ingrese Y para continuar, otra tecla para salir", 0dh, 0ah, 24h 
    msjError db "No se pudo ubicar la nave, simbolo incorrecto", 0dh, 0ah, 24h
    bandera db 0
    
    seed dw 0
    weylseq dw 0
    prev_rand_int dw 0
    
    imp_tablero db "El tablero:", 0dh, 0ah, 0dh, 0ah
    
    tablero db "x-------------------------------------------x ", 0dh, 0ah
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
extrn comprobar_lugar:proc
extrn obtener_indice:proc
extrn seed_inicial:proc
    
main proc
    mov ax, @data
    mov ds, ax
    
    call seed_incial
    
    mov seed, ax
    mov weylseq, ax
    mov prev_ran_int ax
    
inicio:
    call clear_screen
    
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
    call eligeHoV
    mov si, ax
    mov al, "P"
    call ubicar_barco
    cmp bandera[0], 1
    je ubicarP
    call chequear_error
    
ubicarB:
    mov bandera[0], 0
    call generarFyC
    call eligeHoV
    mov si, ax
    mov al, "B"
    call ubicar_barco
    cmp bandera[0], 1
    je ubicarB
    call chequear_error
    
ubicarC:
    mov bandera[0], 0
    call generarFyC
    call eligeHoV
    mov si, ax
    mov al, "C" ;Quiero un crucero
    call ubicar_barco
    cmp bandera[0], 1
    je ubicarC
    call chequearError    