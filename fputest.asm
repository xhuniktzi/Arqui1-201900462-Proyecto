

printAscii macro ascii
    ;    mov ax, @data    ; ax = offset de la cadena
    ;    mov ds, ax       ; ds = segmento de la cadena
               mov ah, 02h      ; imprimir caracter
               mov dl, ascii    ; dx = offset de la cadena
               int 21h          ; imprimir cadena
endm

.model small
.stack 100h
.data
    txt       db "Hola ke ace"
    num       dq 0.00001
    const_10  dw 10

    integer   dw 0

    config    dw 0C3Fh

    coefAWord dw 1
    coefBWord dw 1
    coefCWord dw 1
    coefDWord dw 2
    coefEWord dw -10
    coefFWord dw -20

    calc      dq 0
    x         dq 0

    wordTemp  dw 0
.code


printFloat proc
                   fld        num
                   frndint

                   fistp      integer
                   mov        ax, integer
                   call       printInt
                   printAscii '.'

                   fld        num
                   fisub      integer
                   fstp       num
    
                   mov        cx, 4

    printFloatLoop:

                   fld        num
                   fimul      const_10
                   fst        num
                   frndint
                   fistp      integer
                   mov        ax, integer
                   push       cx
                   call       printInt
                   pop        cx

                   fld        num
                   fisub      integer
                   fstp       num

                   loop       printFloatLoop
    
                   ret

printFloat endp

printInt proc
                   mov        cx, 0
    printIntLoop:  
                   cmp        ax, 0
                   je         printIntExit
                   xor        dx, dx
                   mov        bx, 10
                   div        bx
                   add        dx, 48
                   push       dx
                   inc        cx

                   jmp        printIntLoop
    printIntExit:  

                   pop        dx
                   printAscii dl
                   loop       printIntExit
                   ret
printInt endp

calcValue proc
                   
                   fldz
                   fstp       calc
    ; x^5
                   fld        x
                   fmul       x
                   fmul       x
                   fmul       x
                   fmul       x

                   fimul      coefAWord
                   fadd       calc
                   fstp       calc
    ; x^4
                   fld        x
                   fmul       x
                   fmul       x
                   fmul       x
                   
                   fimul      coefBWord
                   fadd       calc
                   fstp       calc
    ; x^3
                   fld        x
                   fmul       x
                   fmul       x
                       
                   fimul      coefCWord
                   fadd       calc
                   fstp       calc
    ; x^2
                   fld        x
                   fmul       x
                  
                   fimul      coefDWord
                   fadd       calc
                   fstp       calc
    ; x^1
                   fld        x
                   
                   fimul      coefEWord
                   fadd       calc
                   fstp       calc
    ; x^0
                   fld        calc
                   fiadd      coefFWord
                   fstp       calc

                   ret
calcValue endp

main proc
                   mov        ax, @data
                   mov        ds, ax
                   finit
                   fldcw      config

                   fld        num
                   fstp       x
    
                   call       calcValue

                   fld        calc
                   fstp       num

                   call       printFloat

                   mov        al, 0h
                   mov        ah, 4ch
                   int        21h

main endp

end main
