STACK SEGMENT PARA STACK           ; 堆栈段定义
    STACK_AREA DW  100h DUP(?)     ; 堆栈空间大小为100h字节
    STACK_TOP  EQU $-STACK_AREA    ; 栈顶指针

STACK ENDS                         ; 堆栈段结束

DATA SEGMENT PARA                     ; 数据段定义
    X        DD 20373719              ; 32位无符号整数乘数1
    Y        DD 20373864              ; 32位无符号整数乘数2
    P        DD 2 DUP(00H)            ; 4个字，8个字节，存放乘积
    ; hexadecimal characters
    HEXDIGIT DB '0123456789ABCDEF'    ; 用于打印16进制字符

DATA ENDS                             ; 数据段结束

CODE SEGMENT PAGE                                       ; 代码段定义
                   ASSUME CS:CODE, DS:DATA, SS:STACK    ; 段寄存器赋值

    ; Display a byte in hexadecimal
PUTB PROC                                               ; 以16进制打印AL寄存器的值
    ; 保护现场
                   PUSH   CX
                   PUSH   DX
                   PUSH   SI
    ; 打印高位数码
                   PUSH   AX
                   MOV    DH, 0
                   MOV    DL, AL
                   MOV    CL, 4
                   SHR    DL, CL                        ; AL >> 4
                   MOV    SI, DX
                   MOV    DL, [SI+HEXDIGIT]             ; 相对地址寻址
                   MOV    AH, 2
                   INT    21H                           ; putchar
    ; 打印低位数码
                   POP    AX
                   MOV    DL, AL
                   AND    DL, 0FH                       ; 取出低位数码
                   MOV    SI, DX
                   MOV    DL, [SI+HEXDIGIT]
                   MOV    AH, 2
                   INT    21H
    ; 恢复现场并返回
                   POP    SI
                   POP    DX
                   POP    CX
                   RET
PUTB ENDP

    ; 以十六进制显示64位整数
PUTHEX64 PROC                                           ; 以16进制打印64位整数
    ; 保护现场
                   PUSH   AX
                   PUSH   BX
                   PUSH   DX
    ; 从高位到低位打印8个字节
                   MOV    AL, [BX+7]
                   CALL   PUTB
                   MOV    AL, [BX+6]
                   CALL   PUTB
                   MOV    AL, [BX+5]
                   CALL   PUTB
                   MOV    AL, [BX+4]
                   CALL   PUTB
                   MOV    AL, [BX+3]
                   CALL   PUTB
                   MOV    AL, [BX+2]
                   CALL   PUTB
                   MOV    AL, [BX+1]
                   CALL   PUTB
                   MOV    AL, [BX]
                   CALL   PUTB
    ; 恢复现场并返回
                   POP    DX
                   POP    BX
                   POP    AX
                   RET
PUTHEX64 ENDP

    ; 在十进制中显示64位整数。
PUTINT64 PROC                                           ; 打印 mem64@[BX]
    ; 保护寄存器
                   PUSH   AX
                   PUSH   BX
                   PUSH   CX
                   PUSH   DX
                   PUSH   BP                            ; 将临时结果存储到栈中
    ; 如果 [BX] == 0 : 打印 0
                   MOV    AX, [BX]
                   OR     AX, [BX+02H]
                   OR     AX, [BX+04H]
                   OR     AX, [BX+06H]
                   CMP    AX, 0
                   JNZ    PUTINT64_MAIN
    ; 打印零
    PUTINT64_ZERO: 
                   MOV    AH, 2
                   MOV    DL, 30H
                   INT    21H
                   JMP    PUTINT64_RET
    PUTINT64_MAIN: 
    ; 将 mem64@[BX] 复制到栈中
                   SUB    SP, 16                        ; 两个64位
                   MOV    BP, SP
                   MOV    AX, [BX+00H]
                   MOV    [BP+08H], AX
                   MOV    AX, [BX+02H]
                   MOV    [BP+0AH], AX
                   MOV    AX, [BX+04H]
                   MOV    [BP+0CH], AX
                   MOV    AX, [BX+06H]
                   MOV    [BP+0EH], AX
    ; [BP] / 10, [BP] % 10 : 每个字，4次
    PUTINT64_LOOP1:
                   MOV    CX, 0AH                       ; 除数: 10
                   MOV    DX, 0                         ; 高位（部分余数）
                   MOV    AX, [BP+0EH]
                   DIV    CX                            ; DX, AX = AX % 10, AX / 10
                   MOV    [BP+06H], AX                  ; 部分商
                   MOV    AX, [BP+0CH]
                   DIV    CX
                   MOV    [BP+04H], AX
                   MOV    AX, [BP+0AH]
                   DIV    CX
                   MOV    [BP+02H], AX
                   MOV    AX, [BP+08H]
                   DIV    CX
                   MOV    [BP+00H], AX                  ; DX是余数
                   PUSH   DX                            ; 跟随BP
    ; 将BP[0:3]复制到BP[4:7]
                   MOV    AX, [BP+00H]
                   MOV    [BP+08H], AX
                   MOV    AX, [BP+02H]
                   MOV    [BP+0AH], AX
                   MOV    AX, [BP+04H]
                   MOV    [BP+0CH], AX
                   MOV    AX, [BP+06H]
                   MOV    [BP+0EH], AX
    ; 如果 [BX] != 0 LOOP
                   MOV    AX, [BP+08H]
                   OR     AX, [BP+0AH]
                   OR     AX, [BP+0CH]
                   OR     AX, [BP+0EH]
                   CMP    AX, 0
                   JNZ    PUTINT64_LOOP1
    ; 循环1结束
    ; 打印每个数字
    PUTINT64_LOOP2:
                   POP    DX
                   ADD    DL, 30H                       ; + '0'
                   MOV    AH, 2
                   INT    21H
                   CMP    SP, BP                        ; 弹出直到栈下BP为空
                   JNZ    PUTINT64_LOOP2
    ; 循环2结束
    ; 完成输出。
                   ADD    SP, 16                        ; 两个64位
    ; 恢复寄存器并返回
    PUTINT64_RET:  
                   POP    BP
                   POP    DX
                   POP    CX
                   POP    BX
                   POP    AX
                   RET
PUTINT64 ENDP
    ; 测试输出函数
; TEST_OUTPUT PROC
;     ; 测试PUTB
;                    MOV    AL, 3AH
;                    CALL   PUTB
;     ; 输出换行符
;                    MOV    DL, 0AH
;                    MOV    AH, 2
;                    INT    21H
;     ; 测试PUTHEX64
;                    LEA    BX, X
;                    CALL   PUTHEX64
;     ; 输出换行符
;                    MOV    DL, 0AH
;                    MOV    AH, 2
;                    INT    21H
;     ; 测试PUTINT64
;                    CALL   PUTINT64
;     ; 输出换行符
;                    MOV    DL, 0AH
;                    MOV    AH, 2
;                    INT    21H
;     ; 所有测试通过
;                    RET
; TEST_OUTPUT ENDP

    ; 主程序
MAIN PROC
    ; 设置堆栈和数据
                   MOV    AX, STACK
                   MOV    SS, AX
                   MOV    SP, STACK_TOP
                   MOV    AX, DATA
                   MOV    DS, AX

    ; 测试输出函数
    ; CALL TEST_OUTPUT

    ; 乘两个32位数
    ; lo1 * lo2
                   MOV    AX, WORD PTR X+00H
                   MOV    BX, WORD PTR Y+00H
                   MUL    BX                            ; DX:AX <- AX*BX
                   MOV    WORD PTR P+00H, AX
                   MOV    WORD PTR P+02H, DX
    ; lo1 * hi2
                   MOV    AX, WORD PTR X+00H
                   MOV    BX, WORD PTR Y+02H
                   MUL    BX
                   ADD    WORD PTR P+02H, AX
                   ADC    WORD PTR P+04H, DX
                   ADC    WORD PTR P+06H, 0
    ; hi1 * lo2
                   MOV    AX, WORD PTR X+02H
                   MOV    BX, WORD PTR Y+00H
                   MUL    BX
                   ADD    WORD PTR P+02H, AX
                   ADC    WORD PTR P+04H, DX
                   ADC    WORD PTR P+06H, 0
    ; hi1 * hi2
                   MOV    AX, WORD PTR X+02H
                   MOV    BX, WORD PTR Y+02H
                   MUL    BX
                   ADD    WORD PTR P+04H, AX
                   ADC    WORD PTR P+06H, DX
    ; 输出积
                   LEA    BX, P
    ; 输出16进制
                   CALL   PUTHEX64
    ; 输出换行符
                   MOV    DL, 0AH
                   MOV    AH, 2
                   INT    21H
    ; 输出10进制
                   CALL   PUTINT64
    ; 输出换行符
                   MOV    DL, 0AH
                   MOV    AH, 2
                   INT    21H
    ; 返回DOS
                   MOV    AX, 4C00H
                   INT    21H
    ; 结束主程序
MAIN ENDP
CODE ENDS
END MAIN