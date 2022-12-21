; ------------------------------------------------
; Imprimir
; ------------------------------------------------
printMsg macro str
              mov ax, @data          ; ax = offset de la cadena
              mov ds, ax             ; ds = segmento de la cadena
              mov ah, 09h            ; imprimir cadena
              mov dx, offset str     ; dx = offset de la cadena
              int 21h                ; imprimir cadena
              
endm

; ------------------------------------------------
; Imprimir un numero
; ------------------------------------------------
printAsciiFromNum macro num
                       mov ax, @data     ; ax = offset de la cadena
                       mov ds, ax        ; ds = segmento de la cadena
                       mov ah, 02h       ; imprimir caracter
                       mov dl, num       ; dx = offset de la cadena
                       add dl, '0'
                       int 21h           ; imprimir cadena
                       
endm

; ------------------------------------------------
; Imprimir un caracter ascii
; ------------------------------------------------
printAscii macro ascii
                mov ax, @data     ; ax = offset de la cadena
                mov ds, ax        ; ds = segmento de la cadena
                mov ah, 02h       ; imprimir caracter
                mov dl, ascii     ; dx = offset de la cadena
                int 21h           ; imprimir cadena
endm


; ------------------------------------------------
; Convertir un caracter ascii a numero
; ------------------------------------------------
convertAsciiToNum macro ascii
                       mov dl, ascii
                       sub dl, '0'
endm



.model small
.stack 100h
.data
    
     ;------------------------------------------------
     ; Menu string
     ;------------------------------------------------
     menuMsg    db 'Menu:', 10,13,
'1. Ingresar ecuacion', 10,13,
'2. Imprimir funcion', 10,13,
'3. Imprimir derivada', 10,13,
'4. Imprimir integral', 10,13,
'5. Salir', 10,13, '$'

     ;-----------------------------------------------------------------
     ; Texto de las opciones
     ;-----------------------------------------------------------------

     txt1       db 'Ingrese la ecuacion:', 10,13, '$'
     txt2       db 'Imprimir la funcion:', 10,13, '$'
     txt3       db 'Imprimir derivada:', 10,13, '$'
     txt4       db 'Imprimir Integral:', 10,13, '$'
     txt5       db 'Salir:', 10,13, '$'

     ; ------------------------------------------------
     ; texto de solicitud de coeficientes
     ; ------------------------------------------------
     txtCoefA   db 'Ingrese el coeficiente a: ax^5', 10,13, '$'
     txtCoefB   db 'Ingrese el coeficiente b: bx^4', 10,13, '$'
     txtCoefC   db 'Ingrese el coeficiente c: cx^3', 10,13, '$'
     txtCoefD   db 'Ingrese el coeficiente d: dx^2', 10,13, '$'
     txtCoefE   db 'Ingrese el coeficiente e: ex', 10,13, '$'
     txtCoefF   db 'Ingrese el coeficiente f: f', 10,13, '$'

     ; ------------------------------------------------
     ; Mostrar la funcion
     ; ------------------------------------------------
     txtFunc    db 'La funcion es: ', 10,13, '$'

     ; ------------------------------------------------
     ; Mostrar la derivada
     ; ------------------------------------------------
     txtDeriv   db 'La derivada es: ', 10,13, '$'

     ; ------------------------------------------------
     ; Mostrar la integral
     ; ------------------------------------------------
     txtInteg   db 'La integral es: ', 10,13, '$'

     ; ------------------------------------------------
     ; Mensaje de error
     ; ------------------------------------------------
     error      db 'Error', 10,13, '$'

     ; ------------------------------------------------
     ; Coeficientes
     ; ------------------------------------------------
     coefA      db ?
     coefB      db ?
     coefC      db ?
     coefD      db ?
     coefE      db ?
     coefF      db ?

     ; ------------------------------------------------
     ; Variables temporales readNum
     ; ------------------------------------------------
     tempNum    db 0                                                ; Variable donde se guarda el número leído
     signo      db 0                                                ; 0 = positivo, 1 = negativo
     bufferNum1 db 0                                                ; Buffer para guardar el número leído
     bufferNum2 db 0                                                ; Buffer para guardar el número leído
     

.code
     ; ------------------------------------------------
     ; Leer un número de dos digitos, posible negativo
     ; ------------------------------------------------
readNum proc
                        mov               signo, 0
                 
                        mov               bufferNum1, 0
                        mov               bufferNum2, 0

                        mov               ah, 07h
                        int               21h
                        cmp               al, '-'                ; Si es negativo
                        je                readNumNeg

                        cmp               al, '0'
                        jb                readNumErr
                        cmp               al, '9'
                        ja                readNumErr
                        jmp               readNumFirst

     readNumProc:       
                        mov               ah, 07h
                        int               21h
     
                        cmp               al, '0'
                        jb                readNumErr
                        cmp               al, '9'
                        ja                readNumErr
     readNumFirst:      
                        convertAsciiToNum al
                        mov               bufferNum1, dl
                        printAsciiFromNum bufferNum1

                        mov               ah, 07h
                        int               21h
                 
                        cmp               al, '0'
                        jb                readNumErr
                        cmp               al, '9'
                        ja                readNumErr
                        convertAsciiToNum al
                        mov               bufferNum2, dl
                        printAsciiFromNum bufferNum2
                  
                        jmp               readNumEnd
     readNumNeg:        
                        printAscii        '-'
                        mov               signo, 1
                        jmp               readNumProc
     readNumErr:        
                        printMsg          error
                 
     readNumEnd:        
                        printAscii        13
                        printAscii        10
                        ret

readNum endp

saveNumToBuffer proc
                        mov               tempNum, 0
                        mov               al, 10
                        mul               bufferNum1
                        add               al, bufferNum2
                        mov               tempNum, al
                        cmp               signo, 1
                        je                saveNumToBufferNeg
                        ret
     saveNumToBufferNeg:
                        neg               tempNum
                        ret

saveNumToBuffer endp



     ; ------------------------------------------------
     ; Main
     ; ------------------------------------------------
main proc
                        mov               ax, @data
                        mov               ds, ax
     ;----------------
     ; Menu
     ;----------------
     menu:              
                        printMsg          menuMsg

                        mov               ah, 00h                ; Leer caracter
                        int               16h

                        cmp               al, 27                 ; ESC
                        je                opt5

                        cmp               al, '1'
                        je                opt1

                        cmp               al, '2'
                        je                opt2
    
                        cmp               al, '3'
                        je                opt3

                        cmp               al, '4'
                        je                opt4

                        cmp               al, '5'
                        je                opt5

                        jmp               menu

     ;------------------------------------------------
     ; Salida
     ;------------------------------------------------
     exit:              
                        mov               ah, 4ch
                        int               21h

     ;------------------------------------------------
     ; Opcion 1 - Ingresar ecuacion
     ;------------------------------------------------
     opt1:              
                        printMsg          txt1

                        printMsg          txtCoefA
                        call              readNum
                        call              saveNumToBuffer
                        mov               ah, tempNum
                        mov               coefA, ah


                        printMsg          txtCoefB
                        call              readNum
                        call              saveNumToBuffer
                        mov               ah, tempNum
                        mov               coefB, ah

                        printMsg          txtCoefC
                        call              readNum
                        call              saveNumToBuffer
                        mov               ah, tempNum
                        mov               coefC, ah

                        printMsg          txtCoefD
                        call              readNum
                        call              saveNumToBuffer
                        mov               ah, tempNum
                        mov               coefD, ah

                        printMsg          txtCoefE
                        call              readNum
                        call              saveNumToBuffer
                        mov               ah, tempNum
                        mov               coefE, ah

                        printMsg          txtCoefF
                        call              readNum
                        call              saveNumToBuffer
                        mov               ah, tempNum
                        mov               coefF, ah

                        jmp               menu

     ;------------------------------------------------
     ; Opcion 2 - Imprimir la funcion
     ;------------------------------------------------
     opt2:              
                        printMsg          txt2
                        jmp               menu

     ;------------------------------------------------
     ; Opcion 3 - Imprimir derivada
     ;------------------------------------------------
     opt3:              
                        printMsg          txt3
                        jmp               menu

     ;------------------------------------------------
     ; Opcion 4 - Imprimir integral
     ;------------------------------------------------
     opt4:              
                        printMsg          txt4
                        jmp               menu

     ;------------------------------------------------
     ; Opcion 5 - Salir
     ;------------------------------------------------
     opt5:              
                        printMsg          txt5
                        jmp               exit

main endp
end main