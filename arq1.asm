; ------------------------------------------------
; Imprimir
; esta macro se encarga de imprimir una cadena de caracteres en la pantalla. Para ello, primero carga la dirección de 
; inicio de la sección de datos en el registro AX y luego la carga en el registro DS, lo que permite acceder a la 
; memoria de la cadena. Luego, carga el carácter de impresión de cadena en el registro AH y la dirección de inicio de 
; la cadena en el registro DX, y finalmente llama a la interrupción 21h para imprimir la cadena.
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
; esta macro se encarga de imprimir un número en formato ASCII en la pantalla. Para ello, primero carga la dirección de 
; inicio de la sección de datos en el registro AX y luego la carga en el registro DS, lo que permite acceder a la 
; memoria de la cadena. Luego, carga el carácter de impresión de carácter en el registro AH y el número en formato 
; ASCII en el registro DL, y finalmente llama a la interrupción 21h para imprimir el carácter.
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
; esta macro se encarga de imprimir un carácter ASCII en la pantalla. Para ello, primero carga la dirección de inicio 
; de la sección de datos en el registro AX y luego la carga en el registro DS, lo que permite acceder a la memoria de 
; la cadena. Luego, carga el carácter de impresión de carácter en el registro AH y el carácter ASCII en el registro DL, 
; y finalmente llama a la interrupción 21h para imprimir el carácter.
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
; esta macro se encarga de convertir un carácter ASCII en formato de número. Para ello, carga el carácter ASCII en el 
; registro DL y luego resta el valor ASCII del carácter '0' para obtener el valor numérico equivalente.
; ------------------------------------------------
convertAsciiToNum macro ascii
                       mov dl, ascii
                       sub dl, '0'
endm


; ------------------------------------------------
; Guardar coeficiente
; esta macro se encarga de leer un número del teclado y guardarlo en un buffer temporal. Luego, carga el número leído 
; en el registro AH y lo guarda en la variable "tempNum".
; ------------------------------------------------
saveCoef macro coef
              call readNum
              call saveNumToBuffer
              mov  ah, tempNum
              mov  coef, ah
endm

; ------------------------------------------------
; Imprimir coeficiente
; Esta macro se encarga de imprimir un número guardado en la variable "coef". Primero, carga el número en el registro 
; AH y lo guarda en la variable "revertingNum". Luego, llama a la función "writeNumToBuffer" para escribir el número en 
; un buffer temporal. Finalmente, llama a la función "printNumFromBuffer" para imprimir el número desde el buffer ; 
; temporal.
; ------------------------------------------------
printCoef macro coef
               mov  ah, coef
               mov  revertingNum, ah
               call writeNumToBuffer
               call printNumFromBuffer
endm

; ------------------------------------------------
; Guardar coeficiente derivada - word
; esta macro es similar a la anterior, pero se utiliza para imprimir un número guardado en una variable de 16 bits 
; (tipo "word") llamada "coefDiff". Primero, carga el número en el registro AX y lo guarda en la variable 
; "revertingNumDiff". Luego, llama a la función "writeNumToBufferDiff" para escribir el número en un buffer temporal. 
; Finalmente, llama a la función "printNumFromBufferDiff" para imprimir el número desde el buffer temporal.
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
'5. Salir', 10,13,
'6. Limpiar pantalla', 10,13,
'7. Graficar funcion',10,13,
'8. Metodo de Newton',10,13,
'9. Metodo de Steffenson',10,13,
'$'

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
     

     ; ------------------------------------------------
     ; Potencia variables temporales
     ; ------------------------------------------------
     base             dw 0                                                ; Variable donde se guarda la base
     exponente        dw 0                                                ; Variable donde se guarda el exponente
     resultado        dw 0                                                ; Variable donde se guarda el resultado

     ; ------------------------------------------------
     ; Variables temporales para calculo de Y Pos
     ; ------------------------------------------------
     x                dw 0                                                ; Variable donde se guarda el valor de X
     y                dw 0                                                ; Variable donde se guarda el valor de Y

.code
     ; ------------------------------------------------
     ; Leer un número de dos digitos, posible negativo
     ; esta función se encarga de leer un número de dos dígitos del teclado y almacenarlo en un buffer temporal.
     ; Primero, inicializa las variables "signo", "bufferNum1" y "bufferNum2" a cero. Luego, llama a la interrupción
     ; 21h con el carácter de lectura de carácter en el registro AH para leer el primer dígito del número. Si el
     ; carácter leído es un signo negativo ('-'), salta a la etiqueta "readNumNeg", en caso contrario, verifica que el
     ; carácter leído esté dentro del rango de dígitos ('0' a '9'). Si no es así, salta a la etiqueta "readNumErr" para
     ; imprimir un mensaje de error y salir de la función. Si el carácter es válido, salta a la etiqueta "readNumProc"
     ; para leer el segundo dígito del número. Luego, convierte el carácter leído a formato numérico y lo almacena en
     ; "bufferNum1". Finalmente, imprime el número leído y vuelve a leer el segundo dígito del número. Si el segundo
     ; dígito es válido, convierte el carácter leído a formato numérico y lo almacena en "bufferNum2", y finalmente
     ; salta a la etiqueta "readNumEnd" para finalizar la función.
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
     ; esta función se encarga de almacenar el número leído en la variable "tempNum". Primero, inicializa "tempNum" a
     ; cero. Luego, multiplica "bufferNum1" por 10 y suma "bufferNum2" para obtener el número final. Si el número es
     ; negativo (indicado por la variable "signo"), se invierte el signo del número antes de almacenarlo en "tempNum".
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
     ; Esta función se encarga de escribir un número en un buffer temporal. Primero, inicializa las variables
     ; "bufferNum1", "bufferNum2" y "signo" a cero. Luego, verifica si el número es negativo y, en caso afirmativo,
     ; salta a la etiqueta "writeNumToBufferNeg" para invertir el signo del número y establecer la variable "signo" a
     ; 1. A continuación, divide el número por 10 y almacena el resto en "bufferNum1". Luego, divide el número entero
     ; por 10 y almacena el resto en "bufferNum2". Finalmente, la función retorna.
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
     ; esta función se encarga de imprimir un número desde un buffer temporal. Primero, verifica si el número es
     ; negativo y, en caso afirmativo, imprime el signo negativo. Luego, imprime el primer dígito del número y el
     ; segundo dígito del número. Finalmente, imprime un salto de línea para avanzar al siguiente renglón.
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
     ; esta función es similar a "writeNumToBuffer", pero se utiliza para escribir un número de 16 bits (tipo "word")
     ; en un buffer temporal.
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
     ; esta función es similar a "printNumFromBuffer", pero se utiliza para imprimir un número de 16 bits (tipo "word")
     ; desde un buffer temporal.
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
     ; esta función se encarga de calcular los coeficientes de las derivadas de un polinomio. Primero, inicializa las
     ; variables "coefADiff", "coefBDiff", "coefCDiff", "coefDDiff" y "coefEDiff" a cero. Luego, para cada uno de los
     ; coeficientes "coefA", "coefB", "coefC", "coefD" y "coefE" del polinomio, verifica si el coeficiente es negativo
     ; y, en caso afirmativo, invierte el signo del coeficiente. A continuación, multiplica el coeficiente por el
     ; exponente correspondiente y almacena el resultado en la variable de coeficiente de la derivada correspondiente.
     ; Finalmente, la función retorna.
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
     ; esta función se encarga de calcular los coeficientes de las integrales de un polinomio. Primero, inicializa las
     ; variables "coefAInteg", "coefBInteg", "coefCInteg", "coefDInteg", "coefEInteg" y "coefFInteg" a cero. Luego,
     ; para cada uno de los coeficientes "coefA", "coefB", "coefC", "coefD", "coefE" y "coefF" del polinomio, divide el
     ; coeficiente por el exponente correspondiente y almacena el resultado en la variable de coeficiente de la
     ; integral correspondiente. Finalmente, la función retorna.
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
     ; drawPixel
     ; ------------------------------------------------
drawPixel proc
     ; AL = color
                               mov               ah,0ch
     ;  mov               al,12
                               int               10h
                               ret
drawPixel endp
     ; ------------------------------------------------
     ; Dibjuar Eje X
     ; ------------------------------------------------
drawXAxis proc
                               mov               dx, 127                       ; Set Coordenada Y
                               mov               cx, 0                         ; Set Coordenada X

     drawXAxisLoop:            
                               inc               cx
                               call              drawPixel
                               cmp               cx, 255
                               jne               drawXAxisLoop
                               ret

drawXAxis endp

     ; ------------------------------------------------
     ; Dibjuar Eje Y
     ; ------------------------------------------------
drawYAxis proc
                               mov               dx, 0                         ; Set Coordenada Y
                               mov               cx, 127                       ; Set Coordenada X

     drawYAxisLoop:            
                               inc               dx
                               call              drawPixel
                               cmp               dx, 255
                               jne               drawYAxisLoop
                               ret

drawYAxis endp

     ; ------------------------------------------------
     ; Calcular potencia de un numero entero de 16 bits
     ; ------------------------------------------------
powIntWord proc
                               mov               resultado, 1

     powIntWordLoop:           
                               mov               ax, exponente
                               cmp               ax, 0
                               jle               powIntWordEnd

                               mov               ax, base
                               mul               resultado
                               mov               resultado, ax

                               dec               exponente
                               jmp               powIntWordLoop
     powIntWordEnd:            
                               ret
powIntWord endp


     ; ------------------------------------------------
     ; Calcular valor de la funcion
     ; ------------------------------------------------
calculateYPosFunction proc
                               mov               bx, 0

                               mov               exponente, 5
                               mov               ax, x
                               mov               base, ax
                               call              powIntWord
                               mov               ax, 0
                               mov               al, coefA

                               cmp               coefA, 0
                               jge               calculateYPosFunctionPosA
                               not               ah

     calculateYPosFunctionPosA:

                               imul              resultado
                               add               bx, ax
     ;  add               bx, cx

                               mov               exponente, 4
                               mov               ax, x
                               mov               base, ax
                               call              powIntWord
                               mov               ax, 0
                               mov               al, coefB

                               cmp               coefB, 0
                               jge               calculateYPosFunctionPosB
                               not               ah

     calculateYPosFunctionPosB:

                               imul              resultado
                               add               bx, ax
     ;  add               bx, cx

                               mov               exponente, 3
                               mov               ax, x
                               mov               base, ax
                               call              powIntWord
                               mov               ax, 0
                               mov               al, coefC

                               cmp               coefC, 0
                               jge               calculateYPosFunctionPosC
                               not               ah

     calculateYPosFunctionPosC:

                               imul              resultado
                               add               bx, ax
     ;  add               bx, cx

                               mov               exponente, 2
                               mov               ax, x
                               mov               base, ax
                               call              powIntWord
                               mov               ax, 0
                               mov               al, coefD

                               cmp               coefD, 0
                               jge               calculateYPosFunctionPosD
                               not               ah

     calculateYPosFunctionPosD:

                               imul              resultado
                               add               bx, ax
     ;  add               bx, cx

                               mov               exponente, 1
                               mov               ax, x
                               mov               base, ax
                               call              powIntWord
                               mov               ax, 0
                               mov               al, coefE

                               cmp               coefE, 0
                               jge               calculateYPosFunctionPosE
                               not               ah

     calculateYPosFunctionPosE:

                               imul              resultado
                               add               bx, ax
     ;  add               bx, cx

                               mov               exponente, 0
                               mov               ax, x
                               mov               base, ax
                               call              powIntWord
                               mov               ax, 0
                               mov               al, coefF

                               cmp               coefF, 0
                               jge               calculateYPosFunctionPosF
                               not               ah

     calculateYPosFunctionPosF:

                               imul              resultado
                               add               bx, ax
     ;  add               bx, cx

                               mov               y, bx
                               ret
calculateYPosFunction endp

     ; ------------------------------------------------
     ; Dibujar plano cartesiano
     ; ------------------------------------------------
displayCartesiano proc

                               mov               ax,@data
                               mov               ds,ax
     
     ; ---------------------------- Iniciar modo video ----------------------------
                               mov               ah, 00h
                               mov               al, 12h
                               int               10h

                               call              drawXAxis
                               call              drawYAxis

     ; ---------------------------- Esperar tecla ----------------------------
                               mov               ah, 00h                       ; Leer caracter
                               int               16h
                               
     ; ---------------------------- Finalizar modo video ----------------------------
                               mov               ax, @data
                               mov               ds, ax
                               mov               ah, 0h
                               mov               al, 07h
                               int               10h
                               ret
displayCartesiano endp


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

                               cmp               al, '6'
                               je                opt6

                               cmp               al,'7'
                               je                opt7

                               jmp               menu

     ;------------------------------------------------
     ; Salida
     ;------------------------------------------------
     exit:                     
     ; Llamr a la rutina de salida
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

     ; Marcar que la ecuacion fue ingresada
                               mov               flagEcuacion, 1

                               jmp               menu

     ;------------------------------------------------
     ; Opcion 2 - Imprimir la funcion
     ;------------------------------------------------
     opt2:                     
                               printMsg          txt2

     ; Verificar si la ecuacion fue ingresada
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

     opt6:                     
     ; Mover cursor a (0,0) y limpiar pantalla
                               mov               ah, 02h                       ; Función 02h: Mover cursor
                               mov               bh, 00h                       ; Número de la pantalla (0: pantalla principal)
                               mov               dh, 00h                       ; Coordenada Y del cursor (fila)
                               mov               dl, 00h                       ; Coordenada X del cursor (columna)
                               int               10h                           ; Llamada al sistema de video

     ; Limpiar pantalla a partir de la posición actual del cursor
                               mov               ah, 06h                       ; Función 06h: Scroll de pantalla hacia arriba
                               mov               al, 00h                       ; Número de líneas a borrar (0: todas las líneas)
                               mov               bh, 07h                       ; Atributo de color (blanco sobre fondo negro)
                               mov               ch, 00h                       ; Coordenada Y de inicio (fila)
                               mov               cl, 00h                       ; Coordenada X de inicio (columna)
                               mov               dh, 24h                       ; Coordenada Y de fin (fila)
                               mov               dl, 79h                       ; Coordenada X de fin (columna)
                               int               10h                           ; Llamada al sistema de video
                               jmp               menu

     opt7:                                                                     ; Cambia a modo de video gráfico


     ;  call              displayCartesiano
                               call              readNum
                               call              saveNumToBuffer
                              
                               mov               ax, 0
                               mov               al, tempNum
                               mov               x, ax
                               
                               call              calculateYPosFunction

                               mov               ax, y
                               mov               revertingNumDiff, ax
                               call              writeNumToBufferDiff
                               call              printNumFromBufferDiff

                               jmp               menu
     

main endp
end main