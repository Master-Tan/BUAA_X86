STACK1 SEGMENT PARA STACK
    STACK_AREA   DW  100 DUP(?)
    STACK_BOTTOM EQU $-STACK_AREA
STACK1 ENDS

DATA1 SEGMENT PARA
    STR1     DB  '20373864', '.'
    STR2     DB  '666', '.'
    STR3     DB  'blalala', '.'
    STR4     DB  'i love dsn', '.'
    STR5     DB  'sixsixsix', '.'
    STR6     DB  'Win', '.'
    STR7     DB  'Rose', '.'
    STR_NUM  DW  7
    STR_LIST DW  STR1, STR2, STR3, STR4, STR5, STR6, STR7
             DW  ?
    MAX_LEN  EQU 21h
    BUF      DB  MAX_LEN-1
    LEN      DB  ?
    STR8     DB  MAX_LEN DUP(?)
DATA1 ENDS

CODE1 SEGMENT PARA
                  ASSUME SS:STACK1, ES:DATA1, DS:DATA1, CS:CODE1

STRCMP PROC
                  MOV    BP, SP
                  PUSH   SI
                  PUSH   DI
                  PUSH   ES
                  PUSH   DS
                  POP    ES
                  MOV    DI, [BP+02H]
                  MOV    SI, [BP+04H]
                  CLD
    STRCMP_LOOP:  
                  CMP    BYTE PTR [SI], '.'
                  JZ     STRCMP_BELOW
                  CMP    BYTE PTR [DI], '.'
                  JZ     STRCMP_ABOVE
                  CMPSB
                  JZ     STRCMP_LOOP
                  JMP    STRCMP_END
    STRCMP_ABOVE: 
                  MOV    AX, 1
                  CMP    AX, 0
                  JMP    STRCMP_END
    STRCMP_BELOW: 
                  MOV    AX, 0
                  CMP    AX, 1
    STRCMP_END:   
                  POP    ES
                  POP    DI
                  POP    SI
                  RET    04H
STRCMP ENDP

SORT PROC
    SORT_LP1:     
                  MOV    BX, 1
                  MOV    CX, STR_NUM
                  DEC    CX
                  MOV    SI, 0
    SORT_LP2:     
                  PUSH   STR_LIST[SI]
                  PUSH   STR_LIST[SI+02H]
                  CALL   STRCMP
                  JBE    SORT_CONTINUE
                  MOV    AX, STR_LIST[SI]
                  XCHG   AX, STR_LIST[SI+2]
                  MOV    STR_LIST[SI], AX
                  MOV    BX, 0
    SORT_CONTINUE:
                  ADD    SI, 2
                  LOOP   SORT_LP2
                  CMP    BX, 1
                  JNZ    SORT_LP1
                  RET
SORT ENDP

READ PROC
                  LEA    DX, BUF
                  MOV    AH, 0AH
                  INT    21H
                  MOV    AH, 2
                  MOV    DL, 0AH
                  INT    21H
                  MOV    BH, 0
                  MOV    BL, LEN
                  MOV    BYTE PTR STR8[BX], '.'
                  RET
READ ENDP

INSERT PROC
                  LEA    AX, STR8
                  MOV    BX, STR_NUM
                  ADD    BX, BX
                  MOV    STR_LIST[BX], AX
                  MOV    CX, STR_NUM
    INSERT_LP:    
                  MOV    SI, CX
                  SUB    SI, 1
                  ADD    SI, SI
                  PUSH   STR_LIST[SI]
                  PUSH   STR_LIST[SI+02H]
                  CALL   STRCMP
                  JB     INSERT_END
                  MOV    AX, STR_LIST[SI]
                  XCHG   AX, STR_LIST[SI+02H]
                  MOV    STR_LIST[SI], AX
                  LOOP   INSERT_LP
    INSERT_END:   
                  ADD    WORD PTR STR_NUM, 1
                  RET
INSERT ENDP

PUTS PROC
    PUTS_LP:      
                  CLD
                  LODSB
                  CMP    AL, '.'
                  JZ     PUTS_END
                  MOV    DL, AL
                  MOV    AH, 2
                  INT    21H
                  JMP    PUTS_LP
    PUTS_END:     
                  RET
PUTS ENDP

PUTLIST PROC
                  MOV    CX, STR_NUM
                  LEA    SI, STR_LIST
    PUTLIST_LP:   
                  PUSH   SI
                  MOV    SI, [SI]
                  CALL   PUTS
                  POP    SI
                  DEC    CX
                  CMP    CX, 0
                  JZ     PUTLIST_END
                  MOV    DL, 20H
                  MOV    AH, 2
                  INT    21H
                  ADD    SI, 2
                  JMP    PUTLIST_LP
    PUTLIST_END:  
                  MOV    DL, 0AH
                  MOV    AH, 2
                  INT    21H
                  MOV    DL, 0DH
                  MOV    AH, 2
                  INT    21H
                  RET
PUTLIST ENDP

    START:        
MAIN PROC FAR
                  MOV    AX, STACK1
                  MOV    SS, AX
                  MOV    SP, STACK_BOTTOM
                  MOV    AX, DATA1
                  MOV    DS, AX
                  MOV    ES, AX

                  CALL   PUTLIST
                  CALL   SORT
                  CALL   PUTLIST
                  CALL   READ
                  CALL   INSERT
                  CALL   PUTLIST

    EXIT:         
                  MOV    AX, 4C00H
                  INT    21H

MAIN ENDP
CODE1 ENDS
END START