STACK1          SEGMENT PARA STACK
STACK_AREA      DW      100H DUP(?)
STACK_BOTTOM    EQU     $-STACK_AREA
STACK1          ENDS


DATA1           SEGMENT PARA           ; 定义数据段 DATA1
STRING1         DB      'TANLIDE', '$'
STRING1_LEN     EQU     $-STRING1
STRING2_MAX     EQU     20H
STRING2_BUF     DB      STRING2_MAX-1
STRING2_LEN     DB      ?
STRING2         DB      STRING2_MAX DUP(?)

NEW_LINE        DB      0DH, 0AH, '$'       ; 定义一个回车换行字符和字符串结束符号 '$'
DATA1           ENDS                    ; 结束数据段定义


CODE1           SEGMENT PARA
                ASSUME  CS:CODE1, DS:DATA1, SS:STACK1 ; 声明代码段、数据段和堆栈段的寄存器值

PRINT_BYTE      PROC    FAR                     ; 要显示的字符位于 DL 中
                PUSH    AX
                MOV     AH, 2
                INT     21H
                POP     AX

                RET
PRINT_BYTE      ENDP

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

GET_STRING      PROC    FAR                     ; BUF偏移在DX中
                PUSH    AX

                MOV     AH, 0AH
                INT     21H

                POP     AX
                RET
GET_STRING      ENDP

STR_CMP         PROC
                PUSH    ES
                PUSH    DS
                POP     ES

                MOV     CH, 0
                MOV     CL, STRING1_LEN
                CMP     CL, STRING2_LEN
                JA      STR_CMP_1
                MOV     CL, STRING2_LEN
STR_CMP_1:
                
                CLD
                REPZ    CMPSB

                JA      STR_ABOVE               ; 大于
                JB      STR_BELOW               ; 小于
                                                ; 相等
                MOV     DL, '='
                JMP     STR_CMP_2
STR_ABOVE:
                MOV     DL, '>'
                JMP     STR_CMP_2
STR_BELOW:
                MOV     DL, '<'

STR_CMP_2:
                CALL    PRINT_BYTE
                POP     ES
                RET
STR_CMP         ENDP

START:  
MAIN            PROC    FAR
                MOV     AX, STACK1              ; 必须的准备操作
                MOV     SS, AX
                MOV     SP, STACK_BOTTOM
                MOV     AX, DATA1
                MOV     DS, AX

                MOV     DX, OFFSET STRING2_BUF
                CALL    GET_STRING
                MOV     BH, 0
                MOV     BL, STRING2_LEN
                MOV     BYTE PTR STRING2[BX], '$'
                CALL    PRINT_NEWLINE
                
                MOV     DX, OFFSET STRING1
                CALL    PRINT_STRING

                MOV     SI, OFFSET STRING1
                MOV     DI, OFFSET STRING2
                CALL    STR_CMP
                
                MOV     DX, OFFSET STRING2
                CALL    PRINT_STRING
                
                CALL    PRINT_NEWLINE

EXIT:           
                MOV     AX, 4C00H
                INT     21H

MAIN            ENDP
CODE1           ENDS
                END    START
