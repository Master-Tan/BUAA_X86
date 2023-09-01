STACK1          SEGMENT PARA STACK 
STACK_AREA      DW      100 DUP(?)
STACK_BOTTOM    EQU     $-STACK_AREA
STACK1          ENDS

DATA1           SEGMENT PARA
                DB      5 DUP(?)    ; space before
STRING1         DB      'Tanlide', '$'
LEN             EQU     $-STRING1   ; length of string
                DB      5 DUP(?)    ; 空白
STRING2         DB      20 DUP(?)   ; 在 string1后面
DATA1           ENDS

CODE1           SEGMENT PARA
                ASSUME  SS:STACK1, ES:DATA1, DS:DATA1, CS:CODE1

MEMMOVE         PROC            ; prepare: DS:[SI] at String1, ES:[DI] at String2
                MOV     CX, LEN
                CLD
                REP     MOVSB   ; move string by byte
                RET
MEMMOVE         ENDP

; print str1, call memmove, print str1 and str2
TRY             PROC                    ; head address of str2 and str1 is already pushed to stack
                MOV     BP, SP          ; [BP+2H]: str2, [BP+4H]: str1
                                        ; print str1
                MOV     DX, [BP+4H]
                MOV     AH, 9
                INT     21H
                                        ; print '\n'
                MOV     DL, 0AH
                MOV     AH, 2
                INT     21H
                                        ; call memmove: load SI and DI
                MOV     SI, [BP+4H]
                MOV     DI, [BP+2H]
                CALL    MEMMOVE
                                        ; print str1
                MOV     DX, [BP+4H]
                MOV     AH, 9
                INT     21H
                                        ; print ' '
                MOV     DL, 20H
                MOV     AH, 2
                INT     21H
                                        ; print str2
                MOV     DX, [BP+2H]
                MOV     AH, 9
                INT     21H
                                        ; print '\n'
                MOV     DL, 0AH
                MOV     AH, 2
                INT     21H
                                        ; end, pop str2 and str1
                RET     4H
TRY             ENDP

START:
MAIN            PROC    FAR
                MOV     AX, STACK1          ; 必须的准备操作
                MOV     SS, AX
                MOV     SP, STACK_BOTTOM
                MOV     AX, DATA1
                MOV     DS, AX
                MOV     ES, AX
                                            ; try 1: string2 does not intersect with string1
                LEA     AX, STRING1
                PUSH    AX
                LEA     AX, STRING2
                PUSH    AX
                CALL    TRY
                                            ; try 2: string2 before string1 with intersection
                LEA     AX, STRING1
                PUSH    AX
                LEA     AX, STRING1-5H
                PUSH    AX
                CALL    TRY
                                            ; try 3: string2 after string1 with intersection
                LEA     AX, STRING1
                PUSH    AX
                LEA     AX, STRING1+5H
                PUSH    AX
                CALL    TRY
                           
EXIT:           
                MOV     AX, 4C00H
                INT     21H

MAIN            ENDP
CODE1           ENDS
                END     START