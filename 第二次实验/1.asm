STACK1          SEGMENT PARA STACK
STACK_AREA      DW      100H DUP(?)
STACK_BOTTOM    EQU     $-STACK_AREA
STACK1          ENDS

DATA1           SEGMENT PARA           ; 定义数据段 DATA1
TABLE_LEN       DW      16              ; 定义一个16位的表长度变量 TABLE_LEN
TABLE           DW      200, 300, 400, 10, 20, 1, 2037H, 3864H ; 定义一个包含8个16位元素的表 TABLE
                DW      41H, 40, 42H, 50, 60, 0FFFFH, 2, 3
RESULT          DB      5 DUP(?), 20H, '$'  ; 定义一个长度为5的字节数组 RESULT，用于存储排序后的结果和字符串结束符号 '$'
NEW_LINE        DB      0DH, 0AH, '$'       ; 定义一个回车换行字符和字符串结束符号 '$'
X2              DB      1
DATA1           ENDS                    ; 结束数据段定义

CODE1           SEGMENT PARA
                ASSUME  CS:CODE1, DS:DATA1, SS:STACK1 ; 声明代码段、数据段和堆栈段的寄存器值

PRINT_WORD_DEC  PROC    FAR                     ; 要打印的数字位于 AX 中（十进制输出）
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
                DEC     DI              ; 将 DI 寄存器的值减一，指向 RESULT 数组的下一个位置
                LOOP    LP_DECIMAL          ; 循环 5 次，将 AX 寄存器的值转换成 ASCII 码，并存储在 RESULT 数组中

                MOV     DX, OFFSET RESULT ; 将 RESULT 数组的首地址存储在 DX 寄存器中
                CALL    FAR PTR PRINT_STRING

                POP     DI
                POP     DX
                POP     CX              ; 将堆栈中保存的 CX 寄存器的值弹出，恢复原值
                POP     BX
                POP     AX
                RET
PRINT_WORD_DEC  ENDP 

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

PRINT_TABLE     PROC    FAR             ; 定义过程 PRINT_TABLE

                ; PART1: 将未排序的表显示出来
                MOV     CX, TABLE_LEN   ; 将表长度 TABLE_LEN 存储在 CX 寄存器中
                MOV     SI, OFFSET TABLE ; 将表 TABLE 的偏移地址存储在 SI 寄存器中
LP1:            
                MOV     AX, [SI]        ; 将表 TABLE 中的一个元素保存在 AX 寄存器中
                CALL    PRINT_WORD_DEC
                INC     SI              ; 将 SI 寄存器的值加二，指向下一个表元素
                INC     SI              ; 因为表元素占用 2 个字节，所以需要将 SI 寄存器的值再加二
                LOOP    LP1             ; 循环 TABLE_LEN 次，将表 TABLE 中的所有元素转换成 ASCII 码，并输出

                MOV     DX, OFFSET NEW_LINE ; 将 NEW_LINE 字符串的地址存储在 DX 寄存器中
                CALL    PRINT_STRING

                RET
PRINT_TABLE     ENDP

BUBBLE_SORT     PROC    
                                                ; 冒泡排序
                MOV     CX, TABLE_LEN
                DEC     CX
LP2:            MOV     BX, 1
                MOV     SI, OFFSET TABLE
                PUSH    CX

LP2_1:          MOV     AX, [SI]
                CMP     AX, [SI + 2]
                JBE     CONTINUE
                XCHG    AX, [SI + 2]
                MOV     [SI], AX
                MOV     BX, 0
CONTINUE:       ADD     SI, 2
                LOOP    LP2_1

                POP     CX
                DEC     CX
                CMP     BX, 1
                JZ      BUBBLE_SORT_EXIT
                JMP     SHORT LP2

BUBBLE_SORT_EXIT:
                RET

BUBBLE_SORT     ENDP

START:  
MAIN            PROC    FAR
                MOV     AX, STACK1              ; 必须的准备操作
                MOV     SS, AX
                MOV     SP, STACK_BOTTOM
                MOV     AX, DATA1
                MOV     DS, AX

                ; CALL    PRINT_TABLE

                ; CALL    BUBBLE_SORT
                
                ; CALL    PRINT_TABLE
                MOV     [X2], 1

EXIT:           
                MOV     AX, 4C00H
                INT     21H

MAIN            ENDP
CODE1           ENDS
                END    START
