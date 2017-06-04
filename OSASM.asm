;  OS asm handle 
    IMPORT    CurTCB 
    IMPORT    NextTCB 
    
    EXPORT    OS_ENTER_CRITICAL
    EXPORT    OS_EXIT_CRITICAL
    EXPORT    OSStart
    EXPORT    PendSV_Handler
    EXPORT    OSCtxSw
    
NVIC_INT_CTRL    EQU            0xE000ED04    ; Address of NVIC Interruptions Control Register
NVIC_PENDSVSET   EQU            0x10000000    ; Enable PendSV
NVIC_SYSPRI14    EQU         0xE000ED22  ; System priority register (priority 14).
NVIC_PENDSV_PRI  EQU         0xFF        ; PendSV priority value (lowest).
    
    PRESERVE8 ; align 8

    RSEG CODE:CODE:NOROOT(2)
    THUMB 

;/******************OS_ENTER_CRITICAL************/
OS_ENTER_CRITICAL
    CPSID    I    ; Enable interruptions(Change Processor States: Interrupts Disable)
    BX    LR    ; Return

;/******************OS_EXIT_CRITICAL************/
OS_EXIT_CRITICAL
    CPSIE    I    ; Disable interruptions
    BX    LR     ; Return

;/******************OSStart************/
OSStart
    ; disable interruptions
    CPSID    I                            ; OS_ENTER_CRITICAL();
    ; initialize PendSV
    ; Set the PendSV exception priority
    LDR     R0, =NVIC_SYSPRI14            ; R0 = NVIC_SYSPRI14;
    LDR     R1, =NVIC_PENDSV_PRI          ; R1 = NVIC_PENDSV_PRI;
    STRB    R1, [R0]                      ; *R0 = R1;
    
    ; initialize PSP as 0
    ; MOV    R4, #0
    LDR R4,  =0x0                            ; R4 = 0;
    MSR    PSP, R4                           ; PSP = R4;
    
    ; trigger PendSV  
    LDR    R4, =NVIC_INT_CTRL              ; R4 = NVIC_INT_CTRL;
    LDR    R5, =NVIC_PENDSVSET             ; R5 = NVIC_PENDSVSET;
    STR    R5, [R4]                        ; *R4 = R5;
    
    ; enable interruptions��Ȼ��ᴥ��PendSV
    CPSIE    I                            ; OS_EXIT_CRITICAL();

; should never get here
; a endless loop
OSStartHang                                    
    B    OSStartHang

;/******************PendSV_Handler************/
PendSV_Handler
    CPSID    I                            ; OS_ENTER_CRITICAL();
    ; judge if PSP is 0 which means the task is first invoked
    MRS     R0, PSP                            ; R0 = PSP;
    CBZ     R0, PendSV_Handler_NoSave          ; if(R0 == 0) goto PendSV_Handler_NoSave;
    
    ;     R12, R3, R2, R1
    SUB     R0, R0, #0x20            ; R0 = R0 - 0x20;

    ; R4-R11�����ڵ�ǰTCB ָ���ջ��, 8������  0x20
    ; store R4 
    STR     R4 , [R0]                ; *R0 = R4;
    ADD     R0, R0, #0x4             ; R0 = R0 + 0x4;
    ; store R5 
    STR     R5 , [R0]                ; *R0 = R5;
    ADD     R0, R0, #0x4             ; R0 = R0 + 0x4;
    ; store R6 
    STR     R6 , [R0]                ; *R0 = R6;
    ADD     R0, R0, #0x4             ; R0 = R0 + 0x4;
    ; store R7 
    STR     R7 , [R0]                ; *R0 = R7;
    ADD     R0, R0, #0x4             ; R0 = R0 + 0x4;
    ; store R8 
    STR     R8 , [R0]                ; *R0 = R8;
    ADD     R0, R0, #0x4             ; R0 = R0 + 0x4;
    ; store R9
    STR     R9, [R0]                ; *R0 = R4;
    ADD     R0, R0, #0x4            ; R0 = R0 + 0x4;
    ; store R10 
    STR     R10, [R0]               ; *R0 = R10;
    ADD     R0, R0, #0x4            ; R0 = R0 + 0x4;
    ; store R11 
    STR     R11, [R0]               ; *R0 = R11;
    ADD     R0, R0, #0x4            ; R0 = R0 + 0x4;

    SUB     R0, R0, #0x20           ; R0 = R0 - 0x20;
    
    ; easy method
    ;SUB     R0, R0, #0x20
    ;STM     R0, {R4-R11}
    
    LDR     R1, =CurTCB                       ; R1 = OSTCBCur;
    LDR     R1, [R1]                 ; R1 = *R1;(R1 = OSTCBCur->OSTCBStkPtr)
    STR     R0, [R1]                 ; *R1 = R0;(*(OSTCBCur->OSTCBStkPrt) = R0)
; �����Ǽ�������ĺ�����û��return, �����Ǳ��浱ǰ�ļĴ�����ջ�������ȡ��ջ���������д���Ĵ���
; switch to task1
PendSV_Handler_NoSave  
    LDR     R0, =CurTCB                      ; R0 = OSTCBCur;
    LDR     R1, =NextTCB                    ; R1 = OSTCBNext;
    LDR     R2, [R1]                ; R2 = OSTCBNext->OSTCBStkPtr;
    STR     R2, [R0]                ; *R0 = R2;(OSTCBCur->OSTCBStkPtr = OSTCBNext->OSTCBStkPtr)
    ; ��curTCB ����Ķ�ջֵȡ���������ص� R4~R11�Ĵ�����������pc

    LDR     R0, [R2]                 ; R0 = *R2;(R0 = OSTCBNext->OSTCBStkPtr)
    ; LDM     R0, {R4-R11}
    ; load R4 
    LDR     R4, [R0]                 ; R4 = *R0;(R4 = *(OSTCBNext->OSTCBStkPtr))
    ADD     R0, R0, #0x4             ; R0 = R0 + 0x4;(OSTCBNext->OSTCBStkPtr++)
    ; load R5 
    LDR     R5, [R0]                 ; R5 = *R0;(R5 = *(OSTCBNext->OSTCBStkPtr))
    ADD     R0, R0, #0x4             ; R0 = R0 + 0x4;(OSTCBNext->OSTCBStkPtr++)
    ; load R6
    LDR     R6, [R0]                 ; R6 = *R0;(R6 = *(OSTCBNext->OSTCBStkPtr))
    ADD     R0, R0, #0x4             ; R0 = R0 + 0x4;(OSTCBNext->OSTCBStkPtr++)
    ; load R7 
    LDR     R7 , [R0]                ; R7 = *R0;(R7 = *(OSTCBNext->OSTCBStkPtr))
    ADD     R0, R0, #0x4             ; R0 = R0 + 0x4;(OSTCBNext->OSTCBStkPtr++)
    ; load R8 
    LDR     R8 , [R0]                ; R8 = *R0;(R8 = *(OSTCBNext->OSTCBStkPtr))
    ADD     R0, R0, #0x4             ; R0 = R0 + 0x4;(OSTCBNext->OSTCBStkPtr++)
    ; load R9 
    LDR     R9 , [R0]                ; R9 = *R0;(R9 = *(OSTCBNext->OSTCBStkPtr))
    ADD     R0, R0, #0x4             ; R0 = R0 + 0x4;(OSTCBNext->OSTCBStkPtr++)
    ; load R10 
    LDR     R10 , [R0]               ; R10 = *R0;(R10 = *(OSTCBNext->OSTCBStkPtr))
    ADD     R0, R0, #0x4             ; R0 = R0 + 0x4;(OSTCBNext->OSTCBStkPtr++)
    ; load R11 
    LDR     R11 , [R0]               ; R11 = *R0;(R11 = *(OSTCBNext->OSTCBStkPtr))
    ADD     R0, R0, #0x4             ; R0 = R0 + 0x4;(OSTCBNext->OSTCBStkPtr++)
    
    MSR     PSP, R0                 ; PSP = R0;(PSP = OSTCBNext->OSTCBStkPtr)
; CPU���Զ���PSP����ͼ���8������R0~R3,R12,LR,������ڣ���������Ĺؼ�����xPSR���������趯��
    ; P42
    ; P139 (key word: EXC_RETURN)
    ; use PSP
    ORR     LR, LR, #0x04           ; LR = LR | 0x04;
    CPSIE     I                     ; OS_EXIT_CRITICAL();
    BX    LR                        ; return;

OSCtxSw ;OS context switch  ���� pendsv �ж�
    PUSH    {R4, R5}                
    LDR     R4, =NVIC_INT_CTRL       ; R4 = NVIC_INT_CTRL
    LDR     R5, =NVIC_PENDSVSET      ; R5 = NVIC_PENDSVSET
    STR     R5, [R4]                 ; *R4 = R5
    POP     {R4, R5}
    BX     LR                        ; return;
    
    // ALIGN  4
    end
