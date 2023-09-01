STACK1          SEGMENT PARA STACK
STACK_AREA      DW      100H DUP(?)
STACK_BOTTOM    EQU     $-STACK_AREA
STACK1          ENDS

DATA1           SEGMENT PARA
PRO             DW      GET_STR, STR_FIND, STR_CMP, STR_CPY, PRINT_STR

STR             DB      'TANLIDE', '$'
STR_LEN         EQU     $-STR
IN_MAX          EQU     20H
IN_BUF          DB      IN_MAX-1
IN_LEN          DB      ?
IN_STR          DB      IN_MAX DUP(?)

RESULT          DB      5 DUP(?), 20H, '$'  ; 定义一个长度为5的字节数组 RESULT，用于存储排序后的结果和字符串结束符号 '$'
NEW_LINE        DB      0DH, 0AH, '$'       ; 定义一个回车换行字符和字符串结束符号 '$'
DATA1           ENDS

CODE1           SEGMENT PARA
                ASSUME  CS:CODE1, DS:DATA1
                ASSUME  ES:DATA1, SS:STACK1

PRINT_STRING    PROC    FAR                     ; 要显示的以 '$' 结尾的字符串首地址位于 堆栈 中
                PUSH    BP
                MOV     BP, SP

                PUSH    AX
                PUSH    DX

                MOV     DX, [BP+06H]
                MOV     AH, 9
                INT     21H

                POP     DX
                POP     AX
                POP     BP
                RET     02H
PRINT_STRING    ENDP

PRINT_NEWLINE   PROC    FAR
                PUSH    DX

                MOV     DX, OFFSET NEW_LINE ; 将 NEW_LINE 字符串的地址存储在 DX 寄存器中
                PUSH    DX
                CALL    PRINT_STRING

                POP     DX
                RET
PRINT_NEWLINE   ENDP

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
                PUSH    DX
                CALL    FAR PTR PRINT_STRING

                POP     DI
                POP     DX
                POP     CX              ; 将堆栈中保存的 CX 寄存器的值弹出，恢复原值
                POP     BX
                POP     AX
                RET
PRINT_WORD_DEC  ENDP

GET_CHAR        PROC    FAR                     ; BUF偏移在DX中
                MOV     AH, 1H
                INT     21H

                RET
GET_CHAR        ENDP

GET_STR         PROC                         ; BUF偏移在DX中
                PUSH    AX

                MOV     DX, OFFSET IN_BUF
                MOV     AH, 0AH
                INT     21H

                MOV     DX, OFFSET IN_BUF
                MOV     DI, DX
                INC     DI
                ADD     DX, 2
                ADD     DL, BYTE PTR [DI]
                MOV     DI, DX
                MOV     BYTE PTR [DI], '$'

                POP     AX
                RET
GET_STR         ENDP

STR_FIND        PROC
                CALL    GET_CHAR
                CALL    PRINT_NEWLINE
                PUSH    ES
                PUSH    DS
                POP     ES
                LEA     DI, IN_STR
                MOV     CH, 0
                MOV     CL, IN_LEN
                MOV     SI, 0       
                CLD

STR_FIND_LOOP:                            
                DEC     CX
                SCASB         
                                    
                JNZ     STR_NOT_FIND    
                INC     SI      
STR_NOT_FIND:
                CMP     CX, 0H
                JNZ     STR_FIND_LOOP

                MOV     AX, SI
                CALL    PRINT_WORD_DEC

                RET
STR_FIND        ENDP

STR_CMP         PROC
                PUSH    ES
                PUSH    DS
                POP     ES

                MOV     SI, OFFSET STR
                MOV     DI, OFFSET IN_STR

                MOV     CH, 0
                MOV     CL, STR_LEN
                CMP     CL, IN_LEN
                JA      STR_CMP_1
                MOV     CL, STR_LEN
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
                MOV     AH, 2
                INT     21H
                POP     ES
                RET
STR_CMP         ENDP

STR_CPY         PROC
                PUSH    SI
                PUSH    DI

                PUSH    ES
                PUSH    DS
                POP     ES
                LEA     SI, STR             
                LEA     DI, IN_STR
                MOV     CX, STR_LEN
                CLD
                REP     MOVSB
                POP     ES
                
                POP     DI
                POP     SI
                RET
STR_CPY         ENDP

PRINT_STR       PROC
                PUSH    AX
                PUSH    DX

                LEA     DX, IN_STR
                MOV     AH, 9
                INT     21H

                POP     DX
                POP     AX
                RET
PRINT_STR       ENDP

START:
MAIN            PROC
                MOV     AX, STACK1
                MOV     SS, AX
                MOV     SP, STACK_BOTTOM
                MOV     AX, DATA1
                MOV     DS, AX
                MOV     ES, AX

MAIN_LOOP:
                CALL    GET_CHAR
                MOV     AH, 0
                CMP     AL, 30H
                JB      MAIN_LOOP_1
                JE      EXIT
                CMP     AL, 35H
                JA      MAIN_LOOP_1

                LEA     BX, PRO
                SUB     AL, 31H
                ADD     BX, AX
                ADD     BX, AX
                CALL    PRINT_NEWLINE
                CALL    [BX]
                JMP     MAIN_LOOP_1
MAIN_LOOP_1:
                CALL    PRINT_NEWLINE
                JMP     MAIN_LOOP

EXIT:           
                CALL    PRINT_NEWLINE
                
                MOV     AX, 4C00H
                INT     21H
MAIN            ENDP
CODE1           ENDS
                END     START
