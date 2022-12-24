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


; ------------------------------------------------
; Guardar coeficiente
; ------------------------------------------------

saveCoef macro coef
              call readNum
              call saveNumToBuffer
              mov  ah, tempNum
              mov  coef, ah
endm

; ------------------------------------------------
; Imprimir coeficiente
; ------------------------------------------------
printCoef macro coef
               mov  ah, coef
               mov  revertingNum, ah
               call writeNumToBuffer
               call printNumFromBuffer
endm

; ------------------------------------------------
; Guardar coeficiente derivada - word
; ------------------------------------------------
printCoefDiffWord macro coef
                       mov  ax, coef
                       mov  revertingNumDiff, ax
                       call writeNumToBufferDiff
                       call printNumFromBufferDiff
endm

.model small
.stack 100h
.data
    
     ;------------------------------------------------
     ; Menu string
     ;------------------------------------------------
     menuMsg          db 'Menu:', 10,13,
'1. Ingresar ecuacion', 10,13,
'2. Imprimir funcion', 10,13,
'3. Imprimir derivada', 10,13,
'4. Imprimir integral', 10,13,
'5. Salir', 10,13, '$'

     ;-----------------------------------------------------------------
     ; Texto de las opciones
     ;-----------------------------------------------------------------

     txt1             db 'Ingrese la ecuacion:', 10,13, '$'
     txt2             db 'Imprimir la funcion:', 10,13, '$'
     txt3             db 'Imprimir derivada:', 10,13, '$'
     txt4             db 'Imprimir Integral:', 10,13, '$'
     txt5             db 'Salir:', 10,13, '$'

     ; ------------------------------------------------
     ; texto de solicitud de coeficientes
     ; ------------------------------------------------
     txtCoefA         db 'Ingrese el coeficiente a: ax^5', 10,13, '$'
     txtCoefB         db 'Ingrese el coeficiente b: bx^4', 10,13, '$'
     txtCoefC         db 'Ingrese el coeficiente c: cx^3', 10,13, '$'
     txtCoefD         db 'Ingrese el coeficiente d: dx^2', 10,13, '$'
     txtCoefE         db 'Ingrese el coeficiente e: ex', 10,13, '$'
     txtCoefF         db 'Ingrese el coeficiente f: f', 10,13, '$'

     ; ------------------------------------------------
     ; Mostrar la funcion
     ; ------------------------------------------------
     txtFunc          db 'La funcion es: ', 10,13, '$'

     ; ------------------------------------------------
     ; Mostrar la derivada
     ; ------------------------------------------------
     txtDeriv         db 'La derivada es: ', 10,13, '$'

     ; ------------------------------------------------
     ; Mostrar la integral
     ; ------------------------------------------------
     txtInteg         db 'La integral es: ', 10,13, '$'

     ; ------------------------------------------------
     ; Mensaje de error
     ; ------------------------------------------------
     error            db 'Error', 10,13, '$'

     ; ------------------------------------------------
     ; Mensaje de error - ecuacion no ingresada
     ; ------------------------------------------------
     noEcuacionMsg    db 'Error: Ecuacion no ingresada', 10,13, '$'

     ; ------------------------------------------------
     ; Coeficientes
     ; ------------------------------------------------
     coefA            db ?
     coefB            db ?
     coefC            db ?
     coefD            db ?
     coefE            db ?
     coefF            db ?

     ; ------------------------------------------------
     ; Coeficientes derivada
     ; ------------------------------------------------
     coefADiff        dw ?
     coefBDiff        dw ?
     coefCDiff        dw ?
     coefDDiff        dw ?
     coefEDiff        dw ?

     ; ------------------------------------------------
     ; Coeficientes integral
     ; ------------------------------------------------
     coefAInteg       db ?
     coefBInteg       db ?
     coefCInteg       db ?
     coefDInteg       db ?
     coefEInteg       db ?
     coefFInteg       db ?

     ; ------------------------------------------------
     ; Variables temporales readNum
     ; ------------------------------------------------
     tempNum          db 0                                                ; Variable donde se guarda el número leído
     signo            db 0                                                ; 0 = positivo, 1 = negativo
     bufferNum1       db 0                                                ; Buffer para guardar el número leído
     bufferNum2       db 0                                                ; Buffer para guardar el número leído

     ; ------------------------------------------------
     ; Variables temporales writeNum
     ; ------------------------------------------------
     revertingNum     db 0                                                ; Variable donde se guarda el número invertido


     ; ------------------------------------------------
     ; Variables temporales writeNumDiff - 3 digitos
     ; ------------------------------------------------
     bufferNum1Diff   db 0                                                ; Buffer para guardar el número leído
     bufferNum2Diff   db 0                                                ; Buffer para guardar el número leído
     bufferNum3Diff   db 0                                                ; Buffer para guardar el número leído

     ; ------------------------------------------------
     ; Variable temporal revertNumDiff
     ; ------------------------------------------------
     revertingNumDiff dw 0                                                ; Guarda el número invertido en 16 bits

     ; ------------------------------------------------
     ; Flag que almacenara el estado de la ecuacion
     ; ------------------------------------------------
     flagEcuacion     db 0                                                ; 0 = no ingresada, 1 = ingresada
     

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
                               cmp               al, '-'                       ; Si es negativo
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

     ; ------------------------------------------------
     ; Guardar el número leído en tempNum
     ; ------------------------------------------------
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
     ; Escribe el numero en el buffer
     ; ------------------------------------------------
writeNumToBuffer proc
                               mov               bufferNum1, 0
                               mov               bufferNum2, 0
                               mov               signo, 0
     ; check if number is negative
                               cmp               revertingNum, 0
                               jl                writeNumToBufferNeg
                               cmp               revertingNum, 0
                               jge               writeNumToBufferPos
     writeNumToBufferNeg:      
                               neg               revertingNum
                               mov               signo, 1
                        
     writeNumToBufferPos:      
                               mov               ax, 0
                               mov               al, revertingNum
                               mov               bl, 10
                               div               bl


                               mov               bufferNum1, al
                               mov               bufferNum2, ah
                               ret

writeNumToBuffer endp

     ; ------------------------------------------------
     ; Imprime el numero almacenado en el buffer
     ; ------------------------------------------------
printNumFromBuffer proc


                               cmp               signo, 1
                               je                printNumFromBufferNeg
                               printAscii        '+'
                               printAsciiFromNum bufferNum1
                               printAsciiFromNum bufferNum2
                               ret
     printNumFromBufferNeg:    
                               printAscii        '-'
                               printAsciiFromNum bufferNum1
                               printAsciiFromNum bufferNum2
                               ret

printNumFromBuffer endp

     ; ------------------------------------------------
     ; Escribe el numero del buffer para derivadas
     ; ------------------------------------------------
writeNumToBufferDiff proc
                               mov               bufferNum1Diff,0
                               mov               bufferNum2Diff,0
                               mov               bufferNum3Diff,0
                               mov               signo,0

     ; check if number is negative
                               cmp               revertingNumDiff, 0
                               jl                writeNumToBufferDiffNeg
                               cmp               revertingNumDiff, 0
                               jge               writeNumToBufferDiffPos
     writeNumToBufferDiffNeg:  
                               neg               revertingNumDiff
                               mov               signo, 1
     writeNumToBufferDiffPos:  
                               mov               dx, 0
                               mov               ax,0
                               mov               ax, revertingNumDiff
                               mov               bx, 100
                               div               bx
                               mov               bufferNum1Diff, al
                               mov               ax, dx
                               mov               dx, 0
                               mov               bx, 10
                               div               bx
                               mov               bufferNum2Diff, al
                               mov               bufferNum3Diff, dl

                               ret
writeNumToBufferDiff endp


     ; -----------------------------------------------------------
     ; Escribe el numero almacenado en el buffer para derivadas
     ; -----------------------------------------------------------
printNumFromBufferDiff proc
                               cmp               signo, 1
                               je                printNumFromBufferDiffNeg
                               printAscii        '+'
                               printAsciiFromNum bufferNum1Diff
                               printAsciiFromNum bufferNum2Diff
                               printAsciiFromNum bufferNum3Diff
                               ret
     printNumFromBufferDiffNeg:
                               printAscii        '-'
                               printAsciiFromNum bufferNum1Diff
                               printAsciiFromNum bufferNum2Diff
                               printAsciiFromNum bufferNum3Diff
                               ret
printNumFromBufferDiff endp

     ; ------------------------------------------------
     ; Calcular coeficientes de las derivadas
     ; ------------------------------------------------
calculateDiffCoefs proc
                               mov               coefADiff, 0
                               mov               coefBDiff, 0
                               mov               coefCDiff, 0
                               mov               coefDDiff, 0
                               mov               coefEDiff, 0

                               mov               ax, 0
                               mov               dx, 0
                               mov               al, coefA
                               
                               cmp               coefA,0
                               jge               calculateDiffCoefAPos
                               not               ah
     calculateDiffCoefAPos:    
                               mov               bx, 5
                               imul              bx
                               mov               coefADiff, ax

                               mov               ax, 0
                               mov               dx, 0
                               mov               al, coefB

                               cmp               coefB,0
                               jge               calculateDiffCoefBPos
                               not               ah
     calculateDiffCoefBPos:    
                               mov               bx, 4
                               imul              bx
                               mov               coefBDiff, ax
     
                               mov               ax, 0
                               mov               dx, 0
                               mov               al, coefC

                               cmp               coefC,0
                               jge               calculateDiffCoefCPos
                               not               ah
     calculateDiffCoefCPos:    
                               mov               bx, 3
                               imul              bx
                               mov               coefCDiff, ax
     
                               mov               ax, 0
                               mov               dx, 0
                               mov               al, coefD
                               
                               cmp               coefD,0
                               jge               calculateDiffCoefDPos
                               not               ah
     calculateDiffCoefDPos:    
                               mov               bx, 2
                               imul              bx
                               mov               coefDDiff, ax
     
                               mov               ax, 0
                               mov               dx, 0
                               mov               al, coefE

                               cmp               coefE,0
                               jge               calculateDiffCoefEPos
                               not               ah
     calculateDiffCoefEPos:    
                               mov               bx, 1
                               imul              bx
                               mov               coefEDiff, ax
     
                               ret
calculateDiffCoefs endp

     ; ------------------------------------------------
     ; Calcular coeficientes de las integrales
     ; ------------------------------------------------

calculateIntegCoefs proc

                               mov               coefAInteg, 0
                               mov               coefBInteg, 0
                               mov               coefCInteg, 0
                               mov               coefDInteg, 0
                               mov               coefEInteg, 0
                               mov               coefFInteg, 0

                               mov               ax, 0
                               mov               dx,0
                               mov               al, coefA

                               cmp               coefA,0
                               jge               calculateIntegCoefAPos
                               not               ah
     calculateIntegCoefAPos:   
                               mov               bl, 6
                               idiv              bl
                               mov               coefAInteg, al

                               mov               ax, 0
                               mov               dx,0
                               mov               al, coefB

                               cmp               coefB,0
                               jge               calculateIntegCoefBPos
                               not               ah
     calculateIntegCoefBPos:   
                               mov               bl, 5
                               idiv              bl
                               mov               coefBInteg, al

                               mov               ax, 0
                               mov               dx,0
                               mov               al, coefC
                               
                               cmp               coefC,0
                               jge               calculateIntegCoefCPos
                               not               ah
     calculateIntegCoefCPos:   
                               mov               bl, 4
                               idiv              bl
                               mov               coefCInteg, al

                               mov               ax, 0
                               mov               dx,0
                               mov               al, coefD

                               cmp               coefD,0
                               jge               calculateIntegCoefDPos
                               not               ah
     calculateIntegCoefDPos:   
                               mov               bl, 3
                               idiv              bl
                               mov               coefDInteg, al

                               mov               ax, 0
                               mov               dx,0
                               mov               al, coefE

                               cmp               coefE,0
                               jge               calculateIntegCoefEPos
                               not               ah
     calculateIntegCoefEPos:   
                               mov               bl, 2
                               idiv              bl
                               mov               coefEInteg, al

                               mov               ax, 0
                               mov               dx,0
                               mov               al, coefF

                               cmp               coefF,0
                               jge               calculateIntegCoefFPos
                               not               ah
     calculateIntegCoefFPos:   
                               mov               bl, 1
                               idiv              bl
                               mov               coefFInteg, al

                               ret

calculateIntegCoefs endp

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

                               mov               ah, 00h                       ; Leer caracter
                               int               16h

                               cmp               al, 27                        ; ESC
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
     ; Ecuacion no ingresada
     ;------------------------------------------------
     noEcuacion:               
                               printMsg          noEcuacionMsg
                               jmp               menu

     ;------------------------------------------------
     ; Opcion 1 - Ingresar ecuacion
     ;------------------------------------------------
     opt1:                     
                               printMsg          txt1

                               printMsg          txtCoefA
                               saveCoef          coefA


                               printMsg          txtCoefB
                               saveCoef          coefB

                               printMsg          txtCoefC
                               saveCoef          coefC

                               printMsg          txtCoefD
                               saveCoef          coefD

                               printMsg          txtCoefE
                               saveCoef          coefE

                               printMsg          txtCoefF
                               saveCoef          coefF

                               mov               flagEcuacion, 1

                               jmp               menu

     ;------------------------------------------------
     ; Opcion 2 - Imprimir la funcion
     ;------------------------------------------------
     opt2:                     
                               printMsg          txt2

                               cmp               flagEcuacion, 0
                               je                noEcuacion

                               printCoef         coefA
                               printAscii        'x'
                               printAscii        '^'
                               printAscii        '5'

                               printCoef         coefB
                               printAscii        'x'
                               printAscii        '^'
                               printAscii        '4'


                               printCoef         coefC
                               printAscii        'x'
                               printAscii        '^'
                               printAscii        '3'


                               printCoef         coefD
                               printAscii        'x'
                               printAscii        '^'
                               printAscii        '2'

                               printCoef         coefE
                               printAscii        'x'
                           

                               printCoef         coefF
                               printAscii        13
                               printAscii        10

                               jmp               menu

     ;------------------------------------------------
     ; Opcion 3 - Imprimir derivada
     ;------------------------------------------------
     opt3:                     
                               printMsg          txt3
                           
                               cmp               flagEcuacion, 0
                               je                noEcuacion

                               call              calculateDiffCoefs

                               printCoefDiffWord coefADiff
                               printAscii        'x'
                               printAscii        '^'
                               printAscii        '4'

                               printCoefDiffWord coefBDiff
                               printAscii        'x'
                               printAscii        '^'
                               printAscii        '3'
                               
                               printCoefDiffWord coefCDiff
                               printAscii        'x'
                               printAscii        '^'
                               printAscii        '2'

                               printCoefDiffWord coefDDiff
                               printAscii        'x'
                              


                               printCoefDiffWord coefEDiff
                               printAscii        13
                               printAscii        10
                                   

                               jmp               menu

     ;------------------------------------------------
     ; Opcion 4 - Imprimir integral
     ;------------------------------------------------
     opt4:                     
                               printMsg          txt4

                               cmp               flagEcuacion, 0
                               je                noEcuacion
                           
                               call              calculateIntegCoefs
                           
                               printCoef         coefAInteg
                               printAscii        'x'
                               printAscii        '^'
                               printAscii        '6'

                               printCoef         coefBInteg
                               printAscii        'x'
                               printAscii        '^'
                               printAscii        '5'

                               printCoef         coefCInteg
                               printAscii        'x'
                               printAscii        '^'
                               printAscii        '4'

                               printCoef         coefDInteg
                               printAscii        'x'
                               printAscii        '^'
                               printAscii        '3'

                               printCoef         coefEInteg
                               printAscii        'x'
                               printAscii        '^'
                               printAscii        '2'

                               printCoef         coefFInteg
                               printAscii        'x'
                           
                               printAscii        '+'
                               printAscii        'C'
                               printAscii        13
                               printAscii        10

                               jmp               menu

     ;------------------------------------------------
     ; Opcion 5 - Salir
     ;------------------------------------------------
     opt5:                     
                               printMsg          txt5
                               jmp               exit

main endp
end main