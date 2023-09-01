STACK1          SEGMENT PARA STACK
STACK_AREA      DW      100H DUP(?)
STACK_BOTTOM    EQU     $-STACK_AREA
STACK1          ENDS


DATA1           SEGMENT PARA           ; 定义数据段 DATA1
                DB      20 DUP(?)
STRING1         DB      'TANLIDE', '$'
STRING1_LEN     EQU     $-STRING1
                DB      20 DUP(?)
                
; TABLE_LEN       DW      16              ; 定义一个16位的表长度变量 TABLE_LEN
; TABLE           DW      200, 300, 400, 10, 20, 1, 2037H, 3864H ; 定义一个包含8个16位元素的表 TABLE
;                 DW      41H, 40, 42H, 50, 60, 0FFFFH, 2, 3
NEW_LINE        DB      0DH, 0AH, '$'       ; 定义一个回车换行字符和字符串结束符号 '$'
DATA1           ENDS                    ; 结束数据段定义


CODE1           SEGMENT PARA
                ASSUME  CS:CODE1, DS:DATA1
                ASSUME  ES:DATA1, SS:STACK1 ; 声明代码段、数据段和堆栈段的寄存器值

PRINT_STRING    PROC    FAR                     ; 要显示的以 '$' 结尾的字符串首地址位于 DX 中
                PUSH    AX
                MOV     AH, 9
                INT     21H
                POP     AX

                RET
PRINT_STRING    ENDP

PRINT_NEWLINE   PROC    FAR
                PUSH    DX

                MOV     DX, OFFSET NEW_LINE ; 将 NEW_LINE 字符串的地址存储在 DX 寄存器中
                CALL    PRINT_STRING

                POP     DX
                RET
PRINT_NEWLINE   ENDP

Memmove         PROC    FAR
                PUSH    SI
                PUSH    DI

                MOV     CX, STRING1_LEN
                CLD
                REP     MOVSB

                POP     DI
                POP     SI
                RET
Memmove         ENDP

DO_STH          PROC    FAR
                PUSH    SI
                PUSH    DI
                PUSH    DX

                LEA     SI, STRING1             ; STRING1地址
                LEA     DI, STRING1
                ADD     DI, DX
                MOV     DX, SI
                CALL    PRINT_STRING
                CALL    PRINT_NEWLINE
                CALL    Memmove
                MOV     DX, SI
                CALL    PRINT_STRING
                CALL    PRINT_NEWLINE
                MOV     DX, DI
                CALL    PRINT_STRING
                CALL    PRINT_NEWLINE
                CALL    PRINT_NEWLINE
                
                POP     DX
                POP     DI
                POP     SI
                RET
DO_STH          ENDP

START:  
MAIN            PROC    FAR
                MOV     AX, STACK1              ; 必须的准备操作
                MOV     SS, AX
                MOV     SP, STACK_BOTTOM
                MOV     AX, DATA1
                MOV     DS, AX
                MOV     ES, AX
                            
                MOV     DX, 10H
                CALL    DO_STH
                            
                MOV     DX, -5H
                CALL    DO_STH
                            
                MOV     DX, 5H
                CALL    DO_STH

EXIT:           
                MOV     AX, 4C00H
                INT     21H

MAIN            ENDP
CODE1           ENDS
                END    START
