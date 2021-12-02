.model small
.stack 260h
.data
    msg db "Ingrese Y para continuar, otra tecla para salir", 0ah, 0dh, 24h
    msg_error db "No se pudo ubicar la nave, simbolo incorrecto", 0ah, 0dh, 24h
    msg_ing db "Ingrese columna y fila (Ej. A1): ", 24h
    bandera db 0
    pos_ini dw 37
    
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
.code
.start

xor ax, ax
xor bx, bx
xor cx, cx
xor dx, dx

jmp imprimir

main:

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
    jnle error_ing
    cmp bh, 41h
    jnge error_ing
    cmp bl, 36h
    jnle error_ing
    cmp bl, 31h
    jnge error_ing
    ;imprimir dato correcto
    jmp setear
    
error_ing:
    ;imprimir dato incorrecto
    jmp get_pos

setear:
    mov di, pos_ini
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
    mov bx, offset tablero
    mov byte ptr [bx + di], 58h
    jmp imprimir
    

imprimir:
    mov ah, 09h         
    lea dx, imp_tablero
    int 21h
    jmp main