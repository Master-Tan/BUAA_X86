STACK1          SEGMENT PARA STACK
STACK_AREA      DW      100H DUP(?)
STACK_BOTTOM    EQU     $-STACK_AREA
STACK1          ENDS


DATA1           SEGMENT PARA           ; 定义数据段 DATA1
STRING_MAX     EQU     20H
STRING_BUF     DB      STRING_MAX-1
STRING_LEN     DB      ?
STRING         DB      STRING_MAX DUP(?)
RESULT          DB      5 DUP(?), 20H, '$'  ; 定义一个长度为5的字节数组 RESULT，用于存储排序后的结果和字符串结束符号 '$'
NEW_LINE        DB      0DH, 0AH, '$'       ; 定义一个回车换行字符和字符串结束符号 '$'
DATA1           ENDS                    ; 结束数据段定义


CODE1           SEGMENT PARA
                ASSUME  CS:CODE1, DS:DATA1, ES:DATA1, SS:STACK1 ; 声明代码段、数据段和堆栈段的寄存器值

PRINT_WORD_DEC  PROC    FAR                     ; 要打印的字位于 AX 中（十进制输出）
                PUSH    AX
                PUSH    BX
                PUSH    CX              ; 将 CX 寄存器的值压入堆栈中，以备后续使用
                PUSH    DX
                PUSH    DI

                MOV     CX, 5           ; 将计数器 CX 初始化为 5
                MOV     DI, OFFSET RESULT + 4 ; 将 RESULT 数组的第五个元素的地址（也就是倒数第二个元素的地址）保存在 DI 寄存器中
                MOV     BX, 10          ; 将常数 10 存储在 BX 寄存器中，用于进行十进制转换
LP_DECIMAL:          
                XOR     DX, DX          ; 将 DX 寄存器的值清零
                DIV     BX              ; 将 DX:AX 除以 BX 寄存器的值，商存储在 AX 中，余数存储在 DX 中
                OR      DL, 30H         ; 将余数 DL 的值加上 30H，转换成 ASCII 码
                MOV     [DI], DL        ; 将转换后的 ASCII 码存储在 RESULT 数组中的相应位置
                CMP     AX, 0
                JZ      LP_ZERO
                DEC     DI              ; 将 DI 寄存器的值减一，指向 RESULT 数组的下一个位置
                LOOP    LP_DECIMAL          ; 循环 5 次，将 AX 寄存器的值转换成 ASCII 码，并存储在 RESULT 数组中

LP_ZERO:
                MOV     DX, DI          ; 将 RESULT 数组的首地址存储在 DX 寄存器中
                CALL    FAR PTR PRINT_STRING

                POP     DI
                POP     DX
                POP     CX              ; 将堆栈中保存的 CX 寄存器的值弹出，恢复原值
                POP     BX
                POP     AX
                RET
PRINT_WORD_DEC  ENDP

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

GET_CHAR        PROC    FAR                     ; BUF偏移在DX中
                MOV     AH, 1H
                INT     21H

                RET
GET_CHAR        ENDP

FIND            PROC    FAR
                PUSH    BP

                MOV     BP, SP
                MOV     DI, [BP+08H]
                MOV     CX, [BP+06H]
                MOV     SI, 0       
                CLD
FIND_LP:                            
                MOV     AL, DL
                SCASB         
                DEC     CX
                                    
                JNZ     FIND_END    
                ADD     SI, 1       
FIND_END:
                CMP     CX, 0H
                JNZ     FIND_LP
                                    
                MOV     AX, SI      
                POP     BP
                RET     04H         
FIND            ENDP

START:  
MAIN            PROC    FAR
                MOV     AX, STACK1              ; 必须的准备操作
                MOV     SS, AX
                MOV     SP, STACK_BOTTOM
                MOV     AX, DATA1
                MOV     DS, AX
                MOV     ES, AX
                            
                MOV     DX, OFFSET STRING_BUF
                CALL    GET_STRING
                MOV     BH, 0
                MOV     BL, STRING_LEN
                MOV     BYTE PTR STRING[BX], '$'
                CALL    PRINT_NEWLINE

                CALL    GET_CHAR
                MOV     DL, AL
                CALL    PRINT_NEWLINE

                LEA     AX, STRING
                PUSH    AX
                MOV     AH, 0
                MOV     AL, STRING_LEN
                PUSH    AX

                CALL    FIND
                CALL    PRINT_WORD_DEC 
                CALL    PRINT_NEWLINE

EXIT:           
                MOV     AX, 4C00H
                INT     21H

MAIN            ENDP
CODE1           ENDS
                END    START
