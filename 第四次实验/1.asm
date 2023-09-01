STACK1          SEGMENT PARA STACK
STACK_AREA      DW      100H DUP(?)
STACK_BOTTOM    EQU     $-STACK_AREA
STACK1          ENDS

DATA1           SEGMENT PARA 
STR             DB      'dsn love ', '$'
                DB      20H DUP(?)
                
IN_MAX          EQU     20H
IN_BUF          DB      IN_MAX-1
IN_LEN          DB      ?
IN_STR          DB      IN_MAX DUP(?)

NEW_LINE        DB      0DH, 0AH, '$'       ; 定义一个回车换行字符和字符串结束符号 '$'
DATA1           ENDS

CODE1           SEGMENT PARA
                ASSUME  CS:CODE1, DS:DATA1
                ASSUME  ES:DATA1, SS:STACK1

PRINT_STR       PROC    FAR                     ; 要显示的以 '$' 结尾的字符串首地址位于 堆栈 中
                PUSH    BP
                MOV     BP, SP

                MOV     DX, [BP+06H]
                MOV     AH, 9
                INT     21H

                POP     BP
                RET     02H
PRINT_STR       ENDP

PRINT_NEWLINE   PROC    FAR
                PUSH    DX

                MOV     DX, OFFSET NEW_LINE ; 将 NEW_LINE 字符串的地址存储在 DX 寄存器中
                PUSH    DX
                CALL    PRINT_STR

                POP     DX
                RET
PRINT_NEWLINE   ENDP

GET_STR         PROC    FAR                     ; BUF偏移在栈中
                PUSH    BP

                MOV     BP, SP

                MOV     DX, [BP+06H]
                MOV     AH, 0AH
                INT     21H

                MOV     DX, [BP+06H]
                MOV     DI, DX
                INC     DI
                ADD     DX, 2
                ADD     DL, BYTE PTR [DI]
                MOV     DI, DX
                MOV     BYTE PTR [DI], '$'

                POP     BP
                RET     02H
GET_STR         ENDP

STR_CAT         PROC    FAR
                PUSH    BP
                MOV     BP, SP

                MOV     DI, [BP+08H]
                MOV     AL, '$'
                CLD
STR_CAT_LOOP_1:
                SCASB
                JNE     STR_CAT_LOOP_1

                PUSH    ES
                PUSH    DS
                POP     ES

                DEC     DI
                MOV     SI, [BP+06H]
                CLD

STR_CAT_LOOP_2:
                MOVSB
                CMP     [SI], AL
                JNE     STR_CAT_LOOP_2               

                POP     ES

                MOV     [DI], AL
                
                POP     BP
                RET     04H
STR_CAT         ENDP

START:
MAIN            PROC    FAR
                MOV     AX, STACK1
                MOV     SS, AX
                MOV     SP, STACK_BOTTOM
                MOV     AX, DATA1
                MOV     DS, AX
                MOV     ES, AX

                LEA     AX, IN_BUF
                PUSH    AX
                CALL    GET_STR

                CALL    PRINT_NEWLINE

                LEA     AX, STR
                PUSH    AX
                LEA     AX, IN_STR
                PUSH    AX
                CALL    STR_CAT

                LEA     AX, STR
                PUSH    AX
                CALL    PRINT_STR
                
                CALL    PRINT_NEWLINE


EXIT:           
                MOV     AX, 4C00H
                INT     21H
MAIN            ENDP
CODE1           ENDS
                END     START
