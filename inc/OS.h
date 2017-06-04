
#ifndef _OS_H_
#define _OS_H_

#include"include.h"
#include"type.h"

// Macros
#define  TASK_NUM_MAX    3
#define  TASK_TIME_SLICE     50 //50ms for every task to run every time



// Types
typedef struct
{
//   FUNCPOINT TaskAddr;  //可以不需要，直接存在 stack
    uint32 *  StackP;
    uint8   Status;
} TCB_t;

// extern var
extern TCB_t * NextTCB ;
extern TCB_t * CurTCB ;
// extern function
extern void TCB_init(void);
extern  uint32 * TaskStack_init(FUNCPOINT EntryAddr, uint32 * StackAddr, void * arg);

extern void CreatTask(FUNCPOINT EntryAddr, uint32 * StackAddr);

extern void IdleTask_init(FUNCPOINT EntryAddr, uint32 * StackAddr);

extern void delayMs(volatile uint32  ms);




#endif /* _OS_H_ */

