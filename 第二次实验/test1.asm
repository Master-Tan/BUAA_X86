STACK       SEGMENT PARA STACK
STACK_AREA  DW      100h DUP(?)
STACK_TOP   EQU     $-STACK_AREA
STACK       ENDS

DATA        SEGMENT PARA
TABLE_LEN   DW      16
TABLE       DW      200, 300, 400, 10, 20, 0, 1, 8
            DW      41H, 40, 42H, 50, 3000H, 0FFFFH, 2037H, 3864H
            
; hexadecimal characters
HEXCHAR     DB  '0123456789ABCDEF'
X1          DB      'A', 00H
X2          DD      56781264H

DATA        ENDS

CODE        SEGMENT
ASSUME      CS:CODE,DS:DATA, SS:STACK

; print a byte value in hexadecimal
PUTB        PROC    ; print AL in hexadecimal
; protect registers
            PUSH CX
            PUSH DX
            PUSH SI
; print high digit
            PUSH AX
            MOV DH, 0
            MOV DL, AL
            MOV CL, 4
            SHR DL, CL  ; AL >> 4
            MOV SI, DX
            MOV DL, [SI+HEXCHAR]    ; relative addressing
            MOV AH, 2
            INT 21H     ; putchar
; print low digit
            POP AX
            MOV DL, AL
            AND DL, 0FH ; low digit
            MOV SI, DX
            MOV DL, [SI+HEXCHAR]
            MOV AH, 2
            INT 21H
; restore registers and return
            POP SI
            POP DX
            POP CX
            RET
PUTB        ENDP

; print 16-bit integer in hexadecimal
PUTHEX16    PROC    ; print DX
; protect registers
            PUSH AX
            PUSH DX
; print 4 bytes from high to low
            MOV AL, DH
            CALL PUTB
            MOV AL, DL
            CALL PUTB
; restore registers and return
            POP DX
            POP AX
            RET
PUTHEX16    ENDP

; bubble sort
BUBBLE_SORT PROC    ; sort `TABLE` in memory with `TABLE_LEN` before.
LP1:
            MOV     BX, 1   ; flag
            MOV     CX, TABLE_LEN
            DEC     CX  ; loop TABLE_LEN times
            LEA     SI, TABLE   ; i = 0
LP2:
            MOV     AX, [SI]    ; a[i], a[i + 1]
            CMP     AX, [SI+2]
            JBE     CONTINUE    ; if a[i] > a[i + 1] swap
            XCHG    AX, [SI+2]  ; swap
            MOV     [SI], AX
            MOV     BX, 0       ; swap happen in a pass
CONTINUE:
            ADD     SI, 2       ; i++
            LOOP    LP2
; end of LP2
            CMP     BX, 1       ; if (not swapped) break
            JZ      EXIT
            JMP     SHORT LP1   ; loop LP1
; end of LP1
EXIT:
            RET
BUBBLE_SORT ENDP

PRINT_TABLE PROC    ; print `TABLE` with `TABLE_LEN` before
            MOV     CX,0
            MOV     SI,0
PRINT_LOOP:
            MOV     DX, [SI+TABLE]
            CALL PUTHEX16
            ; cx += 1
            INC     CX
            ADD     SI, 2
            CMP     CX, TABLE_LEN
            JZ      PRINT_LOOP_END
            ; putchar ' '
            MOV     DL, 20H
            MOV     AH, 2
            INT     21H
            ; loop
            JMP     PRINT_LOOP
PRINT_LOOP_END:
            ; putchar '\n'
            MOV     DL, 0AH
            MOV     AH, 2
            INT     21H
            RET
PRINT_TABLE ENDP

; main program
MAIN        PROC
; setup stack and data
            MOV     AX,STACK
            MOV     SS,AX
            MOV     SP,STACK_TOP
            MOV     AX,DATA
            MOV     DS,AX               ;SET SS,SP,DS
; display the old table
;             CALL    PRINT_TABLE
; ; call bubblesort
;             CALL    BUBBLE_SORT
; ; print sorted table
;             CALL    PRINT_TABLE
            MOV     DX, WORD PTR X1 + 3
; return to dos
            MOV     AX,4C00H
            INT     21H
MAIN        ENDP
CODE        ENDS
            END         MAIN