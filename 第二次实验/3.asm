STACK1          SEGMENT PARA STACK
STACK_AREA      DW      100H DUP(?)
STACK_BOTTOM    EQU     $-STACK_AREA
STACK1          ENDS


DATA1           SEGMENT PARA           ; 定义数据段 DATA1
XX              DD      20373864
YY              DD      20373719
; XX              DD      8
; YY              DD      8
ZZ              DW      4 DUP(?)
; TABLE_LEN       DW      16              ; 定义一个16位的表长度变量 TABLE_LEN
; TABLE           DW      200, 300, 400, 10, 20, 1, 2037H, 3864H ; 定义一个包含8个16位元素的表 TABLE
;                 DW      41H, 40, 42H, 50, 60, 0FFFFH, 2, 3
RESULT          DB      5 DUP(?), 20H, '$'  ; 定义一个长度为5的字节数组 RESULT，用于存储排序后的结果和字符串结束符号 '$'
RESULT_64       DB      20 DUP('0'), '$'  ; 定义一个长度为20的字节数组 RESULT_64，用于输出64位结果
NEW_LINE        DB      0DH, 0AH, '$'       ; 定义一个回车换行字符和字符串结束符号 '$'
HEXCHAR         DB      '0123456789ABCDEF'   ; 用于打印16进制字符
DATA1           ENDS                    ; 结束数据段定义


CODE1           SEGMENT PARA
                ASSUME  CS:CODE1, DS:DATA1, SS:STACK1 ; 声明代码段、数据段和堆栈段的寄存器值

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

PRINT_BYTE_ASC  PROC    FAR                     ; 要显示的字符位于 DL 中，输出其对应的 ASCII 字符
                PUSH    AX
                MOV     AH, 2
                INT     21H
                POP     AX

                RET
PRINT_BYTE_ASC  ENDP

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

GETINT          PROC    FAR
                PUSH    BX
                PUSH    CX

                XOR     BX, BX

GETINT_LOOP_1:
                MOV     AH, 1     ; 设置AH寄存器为1，表示读取键盘输入
                INT     21H       ; 调用21H中断，等待键盘输入
                CMP     AL, 0DH
                JE      GETINT_LOOP_1_OUT
                SUB     AL, 30H
                MOV     AH, 0
                MOV     CX, AX
                MOV     AX, 10
                MUL     BX
                MOV     BX, AX
                ADD     BX, CX
                JMP     GETINT_LOOP_1

GETINT_LOOP_1_OUT:
                MOV     AX, BX

                POP     CX
                POP     BX
                RET
GETINT          ENDP

PRINT_BYTE      PROC            ; 要显示的字符位于 DL 中，输出16进制到屏幕
                PUSH    CX
                PUSH    DX
                PUSH    SI

                PUSH    DX
                MOV     CL, 4
                SHR     DL, CL                        ; DL >> 4
                XOR     DH, DH
                MOV     SI, DX
                MOV     DL, HEXCHAR[SI]
                CALL    PRINT_BYTE_ASC

                POP     DX
                AND     DL, 0FH
                XOR     DH, DH
                MOV     SI, DX
                MOV     DL, HEXCHAR[SI]
                CALL    PRINT_BYTE_ASC

                POP     SI
                POP     DX
                POP     CX
                RET     
PRINT_BYTE      ENDP

MULT32_32       PROC                            ; XX（32位） * YY（32位） -> ZZ（64位）
                PUSH    AX
                PUSH    BX
                PUSH    DX

                                                ; XXL * YYL -> ZZ1:ZZ0
                MOV     AX, WORD PTR [XX+00H]
                MOV     BX, WORD PTR [YY+00H]
                MUL     BX                    
                MOV     [ZZ+00H], AX    ; 无进位
                MOV     [ZZ+02H], DX    ; 无进位
                                                ; XXL * YYH -> ZZ2:ZZ1
                                                ;            +     ZZ1:ZZ0
                MOV     AX, WORD PTR [XX+00H]
                MOV     BX, WORD PTR [YY+02H]
                MUL     BX
                ADD     [ZZ+02H], AX    ; 可能有进位
                ADC     [ZZ+04H], DX    ; 可能有进位
                ADC     [ZZ+06H], 0     ; 无进位
                                                ; XXH * YYL -> ZZ2:ZZ1
                                                ;      +   ZZ3:ZZ2:ZZ1:ZZ0
                MOV     AX, WORD PTR [XX+02H]
                MOV     BX, WORD PTR [YY+00H]
                MUL     BX
                ADD     [ZZ+02H], AX    ; 可能有进位
                ADC     [ZZ+04H], DX    ; 可能有进位
                ADC     [ZZ+06H], 0     ; 无进位
                                                ; XXH * YYH -> ZZ3:ZZ2
                                                ;           +  ZZ3:ZZ2:ZZ1:ZZ0
                MOV     AX, WORD PTR [XX+02H]
                MOV     BX, WORD PTR [YY+02H]
                MUL     BX
                ADD     [ZZ+04H], AX    ; 可能有进位
                ADC     [ZZ+06H], DX    ; 无进位
                
                POP     DX
                POP     BX
                POP     AX
                RET
MULT32_32       ENDP

PRINT64_HEX     PROC
                PUSH    DX
                PUSH    CX
                PUSH    SI

                MOV     CX, 8

PRINT64_HEX_LOOP_1:
                MOV     SI, CX
                MOV     DL, BYTE PTR [ZZ+SI-1]
                CALL    PRINT_BYTE
                LOOP    PRINT64_HEX_LOOP_1

                POP     SI
                POP     CX
                POP     DX
                RET
PRINT64_HEX     ENDP

PRINT64_DEC     PROC                    ; 要打印的字位于 ZZ[0]-ZZ[7] 中（十进制输出）
                PUSH    AX
                PUSH    BX
                PUSH    DX
                PUSH    DI
                PUSH    BP

                MOV     DI, OFFSET RESULT_64 + 19 ; 将 RESULT_64 数组的第19个元素的地址保存在 DI 寄存器中
                MOV     BX, 10          ; 将常数 10 存储在 BX 寄存器中，用于进行十进制转换
          
                SUB     SP, 16                        ; 两个64位
                MOV     BP, SP
                MOV     AX, [ZZ+00H]
                MOV     [BP+08H], AX
                MOV     AX, [ZZ+02H]
                MOV     [BP+0AH], AX
                MOV     AX, [ZZ+04H]
                MOV     [BP+0CH], AX
                MOV     AX, [ZZ+06H]
                MOV     [BP+0EH], AX
                                        ;BP[4:7] 逐字除 10
PRINT64_DEC_LOOP1:
                MOV     DX, 0            ; 初始 DX 置 0
                MOV     AX, [BP+0EH]
                DIV     BX               ; DX:AX = AX ... DX
                MOV     [BP+06H], AX
                MOV     AX, [BP+0CH]
                DIV     BX
                MOV     [BP+04H], AX
                MOV     AX, [BP+0AH]
                DIV     BX
                MOV     [BP+02H], AX
                MOV     AX, [BP+08H]
                DIV     BX
                MOV     [BP+00H], AX     
                OR      DL, 30H         ; 将余数 DL 的值加上 30H，转换成 ASCII 码
                MOV     [DI], DL        ; 将转换后的 ASCII 码存储在 RESULT 数组中的相应位置
                DEC     DI              ; 将 DI 寄存器的值减一，指向 RESULT 数组的下一个位置
                                        ; 把商作为被除数：BP[0:3] -> BP[4:7]
                MOV     AX, [BP+00H]
                MOV     [BP+08H], AX
                MOV     AX, [BP+02H]
                MOV     [BP+0AH], AX
                MOV     AX, [BP+04H]
                MOV     [BP+0CH], AX
                MOV     AX, [BP+06H]
                MOV     [BP+0EH], AX
                                        ; 若 [BX] != 0 则循环
                MOV    AX, [BP+08H]
                OR     AX, [BP+0AH]
                OR     AX, [BP+0CH]
                OR     AX, [BP+0EH]
                CMP    AX, 0
                JNZ    PRINT64_DEC_LOOP1

                ; INC     DI
                ; MOV     DX,   DI
                MOV     DX, OFFSET RESULT_64          ; 将 RESULT 数组的首地址存储在 DX 寄存器中
                CALL    FAR PTR PRINT_STRING

                ADD     SP, 16

                POP     DI
                POP     DX
                POP     BX
                POP     AX
                RET
PRINT64_DEC     ENDP

START:  
MAIN            PROC    FAR
                MOV     AX, STACK1              ; 必须的准备操作
                MOV     SS, AX
                MOV     SP, STACK_BOTTOM
                MOV     AX, DATA1
                MOV     DS, AX
                            
                CALL    MULT32_32

                CALL    PRINT64_HEX

                CALL    PRINT_NEWLINE
                
                CALL    PRINT64_DEC

                CALL    PRINT_NEWLINE

EXIT:           
                MOV     AX, 4C00H
                INT     21H

MAIN            ENDP
CODE1           ENDS
                END    START
