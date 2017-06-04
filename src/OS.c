// OS function handle
//  variables
#include"OS.h"

TCB_t  TCB[TASK_NUM_MAX];
TCB_t * NextTCB = NULL;
TCB_t * CurTCB = NULL;
TCB_t  IdleTCB ;

uint32 TimeMS = 0;
uint32 TaskTimeSlice = TASK_TIME_SLICE;
uint8 OSTaskNext = 0;
// local function


void TCB_init(void)
{
    for(int i = 0; i < TASK_NUM_MAX; i++)
    {

        TCB[i].StackP= NULL;
        TCB[i].Status= 0;
    }


}

uint32 * TaskStack_init(FUNCPOINT EntryAddr,uint32 * StackAddr, void * arg)
{

// stack data init
// R0 ~R12,xPSR PC

//xPSR  why the value ? 一个程序正常运行时，状态寄存器PSR该有的值；
    *StackAddr = (uint32)	0x01000000L	;
    *(--StackAddr) =  (uint32) EntryAddr;

// random value
    *(--StackAddr) =  (uint32) 0xFFFFFFFEL; // R14 (LR)
    *(--StackAddr) =  (uint32) 0x12L;  //R12
    *(--StackAddr) =  (uint32) 0x3L;  //R3
    *(--StackAddr) =  (uint32) 0x2L;  //R2
    *(--StackAddr) =  (uint32) 0x1L;  //R1

//任务函数参数的所在地址，因为我们一直赋值为“0”，所以暂且没有太多意义。因为任务函数没有参数。
    *(--StackAddr) =  (uint32) arg;  //R0

    *(--StackAddr) =  (uint32) 0x11L;  //R11
    *(--StackAddr) =  (uint32) 0x10L;  //R10
    *(--StackAddr) =  (uint32) 0x9L;  //R9
    *(--StackAddr) =  (uint32) 0x8L;  //R8
    *(--StackAddr) =  (uint32) 0x7L;  //R7
    *(--StackAddr) =  (uint32) 0x6L;  //R6
    *(--StackAddr) =  (uint32) 0x5L;  //R5
    *(--StackAddr) =  (uint32) 0x4L;  //R4

// return StackTop;
    return StackAddr;
}

void CreatTask(FUNCPOINT EntryAddr,uint32 * StackAddr)
{
// first ,search unsued  TCB
    int i = 0;
    for(; i < TASK_NUM_MAX; i++)
    {
        if(TCB[i].StackP== NULL)
        {
            break;
        }

    }
    if(TASK_NUM_MAX == i)
        return;

//TCB[i].TaskAddr = &EntryAddr;
    TCB[i].StackP= TaskStack_init(EntryAddr,StackAddr,0);


}



void IdleTask_init(FUNCPOINT EntryAddr,uint32 * StackAddr)
{

    IdleTCB .StackP = TaskStack_init(EntryAddr,StackAddr,0);
    IdleTCB .Status = 0;

    NextTCB = &IdleTCB ;
    CurTCB = &IdleTCB ;

}

uint32 GetTime(void)
{
    return TimeMS;
}

void delayMs(volatile uint32  ms)
{
    uint32 tmp;
    tmp = GetTime() + ms;
    while(1)
    {
        if(tmp < GetTime()) break;
    }
}

void SysTick_Handler(void)
{
// task switch
    __disable_interrupt();

    if((--TaskTimeSlice) <= 0)
    {
        TaskTimeSlice = TASK_TIME_SLICE;

        if(OSTaskNext >= TASK_NUM_MAX    )
        {
            OSTaskNext = 0;
        }
        if(TCB[OSTaskNext].StackP == NULL)
        {
                    return;
        }
        CurTCB = NextTCB ;
        NextTCB = &TCB[OSTaskNext];

        OSCtxSw();
        OSTaskNext++;
    }

    TimeMS++;
    __enable_interrupt();
}



