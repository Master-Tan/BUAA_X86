STACK           SEGMENT PARA STACK   ; 定义栈段
STACK_AREA      DW  100h DUP(?)      ; 定义栈空间
STACK_TOP       EQU $-STACK_AREA     ; 定义栈顶指针
STACK           ENDS

CODE            SEGMENT             ; 定义代码段
ASSUME          CS:CODE, SS:STACK   ; 设置代码段和栈段的默认段寄存器

GETINT          PROC                ; 定义获取整数的过程
                PUSH     BX        ; 保存寄存器BX的值
                PUSH    CX        ; 保存寄存器CX的值
                MOV     CX, 0     ; CX寄存器清零
GETINT_LOOP_1:
                MOV     AH, 1     ; 设置AH寄存器为1，表示读取键盘输入
                INT     21H       ; 调用21H中断，等待键盘输入
                MOV     AH, 0     ; 设置AH寄存器为0，获取AL寄存器的值
                CMP     AL, '0'   ; 比较AL寄存器的值和字符'0'
                JB      GETINT_LOOP_1 ; 如果小于'0'，继续循环
                CMP     AL, '9'   ; 比较AL寄存器的值和字符'9'
                JA      GETINT_LOOP_1 ; 如果大于'9'，继续循环
GETINT_LOOP_2:
                SUB     AL, 30H   ; 将AL寄存器的值转换为数字
                XCHG    AX, CX    ; 交换AX和CX寄存器的值
                MOV     BX, 10   ; 将BX寄存器设置为10
                MUL     BX       ; 将AX和BX的值相乘，结果存放在AX中
                ADD     AX, CX   ; 将CX的值加到AX中
                XCHG    AX, CX   ; 交换AX和CX寄存器的值
                MOV     AH, 1    ; 设置AH寄存器为1，表示读取键盘输入
                INT 21H          ; 调用21H中断，等待键盘输入
                MOV AH, 0        ; 设置AH寄存器为0，获取AL寄存器的值
                CMP AL, '0'      ; 比较AL寄存器的值和字符'0'
                JB GETINT_RET    ; 如果小于'0'，返回结果
                CMP AL, '9'      ; 比较AL寄存器的值和字符'9'
                JA GETINT_RET    ; 如果大于'9'，返回结果
                JMP GETINT_LOOP_2 ; 继续循环
GETINT_RET:
                MOV AX, CX       ; 将CX的值移动到AX寄存器中
                POP CX           ; 恢复寄存器CX的值
                POP BX           ; 恢复寄存器BX的值
                RET              ; 返回结果
GETINT          ENDP

PUTINT          PROC                ; 定义子程序 PUTINT
                PUSH AX            ; 保存 AX 的值到堆栈中
                PUSH BX            ; 保存 BX 的值到堆栈中
                PUSH CX            ; 保存 CX 的值到堆栈中
                PUSH DX            ; 保存 DX 的值到堆栈中
                CMP AX, 0          ; 判断 AX 是否为 0
                JZ PUTINT_ZERO     ; 如果是，则跳转到 PUTINT_ZERO 标号处
                MOV CX, 0          ; 将 CX 的值设置为 0
PUTINT_LOOP1:
                MOV DX, 0          ; 将 DX 的值设置为 0
                MOV BX, 10         ; 将 BX 的值设置为 10
                DIV BX             ; 将 AX 的值除以 BX，余数存储在 DX 中
                PUSH DX            ; 将 DX 的值保存到堆栈中
                INC CX             ; 将 CX 的值加 1
                CMP AX, 0          ; 判断 AX 是否为 0
                JNZ PUTINT_LOOP1   ; 如果不是 0，则继续循环
PUTINT_LOOP2:
                POP DX             ; 从堆栈中弹出 DX 的值
                ADD DL, 30H        ; 将 DX 转换为字符
                MOV AH, 2          ; 将 AH 的值设置为 2
                INT 21H            ; 输出字符
                LOOP PUTINT_LOOP2  ; 循环 CX 次
                JMP PUTINT_RET     ; 跳转到 PUTINT_RET 标号处
PUTINT_ZERO: 
                MOV DL, '0'         ; 将 DL 的值设置为字符 '0'
                MOV AH, 2           ; 将 AH 的值设置为 2
                INT 21H             ; 输出字符 '0'
                JMP PUTINT_RET      ; 跳转到 PUTINT_RET 标号处
PUTINT_RET: 
                POP DX              ; 从堆栈中恢复 DX 的值
                POP CX              ; 从堆栈中恢复 CX 的值
                POP BX              ; 从堆栈中恢复 BX 的值
                POP AX              ; 从堆栈中恢复 AX 的值
                RET                 ; 返回到调用者处
PUTINT ENDP

MAIN PROC                           ; 程序的主函数
                MOV AX, STACK       ; 将堆栈段的地址存储到 AX 中
                MOV SS, AX          ; 将 AX 的值存储到 SS 中
                MOV SP, STACK_TOP   ; 将堆栈顶部的地址存储到 SP 中
                CALL GETINT         ; 调用 GETINT 子程序，从键盘读取第一个整数
                MOV BX, AX          ; 将第一个整数存储到 BX 中
                CALL GETINT         ; 调用 GETINT 子程序，从键盘读取第二个整数
                MUL BX              ; 将第一个整数和第二个整数相乘
                CALL PUTINT         ; 调用 PUTINT 子程序，将结果打印到屏幕上
                MOV AH, 4CH         ; 将 AH 的值设置为 4CH，表示退出程序
                INT 21H             ; 调用 DOS 中断，退出程序
MAIN ENDP

CODE ENDS                           ; 代码段声明结束
END MAIN                            ; 程序结束
