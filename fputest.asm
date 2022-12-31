

printAscii macro ascii
               mov ax, @data    ; ax = offset de la cadena
               mov ds, ax       ; ds = segmento de la cadena
               mov ah, 02h      ; imprimir caracter
               mov dl, ascii    ; dx = offset de la cadena
               int 21h          ; imprimir cadena
endm

.model small
.stack 100h
.data
    txt      db "Hola ke ace"
    num      dq 3.14159
    const_10 dw 10

    integer  dw 0

    count    dw 0

    config   dw 0C3Fh

             
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

                   mov        count, 3

    printFloatLoop:

                   fld        num
                   fimul      const_10
                   fst        num
                   frndint
                   fistp      integer
                   mov        ax, integer
                   call       printInt

                   fld        num
                   fisub      integer
                   fstp       num
                   
                   dec        count
                   cmp        count, 0
                   ja         printFloatLoop

    
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

main proc
                   mov        ax, @data
                   mov        ds, ax
                   finit
                   fldcw      config
                   
                   call       printFloat

                   mov        al, 0h
                   mov        ah, 4ch
                   int        21h

main endp

end main
