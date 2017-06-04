/*
May OS
Author: Hellc    (  hello  china  )

2017-5-1 start try to write the OS .
IAR 7.8
STM32 F205VE
LED left->  PA4,  LED right->  PA5
main.c
*/

#include"include.h"


//  variables
uint32 LED_LeftStack[TASK_STACK_LEN] = {0};
uint32 LED_RightStack[TASK_STACK_LEN] = {0};
uint32 LED_CloseStack[TASK_STACK_LEN] = {0};
uint32 IDLE_Stack[TASK_STACK_LEN] = {0};

FUNCPOINT FuncPoint;


// local function
void IdleTask(void);
void LED_Left(void);
void LED_Right(void);
void LED_Close(void);
void LED_init(void);
void SysTickInit(void );

int main(void)
{
// hardware init and sys init
    __disable_interrupt();
    SystemInit();
    NVIC_PriorityGroupConfig(NVIC_PriorityGroup_2);
    __enable_interrupt();

    SysTickInit(); // configure the SysTick as 1ms
    LED_init();

// task and OS
    TCB_init();
    CreatTask(LED_Left, &LED_LeftStack[TASK_STACK_LEN - 1]);
    CreatTask(LED_Right, &LED_RightStack[TASK_STACK_LEN - 1]);
    CreatTask(LED_Close, &LED_CloseStack[TASK_STACK_LEN - 1]);
//idle task
    IdleTask_init(IdleTask, &IDLE_Stack[TASK_STACK_LEN - 1]);

    OSStart();

    while(1);

}

void IdleTask(void)
{
    while(1)
    {
        delayMs(1000);
    }
}

void LED_Left(void)
{
    while(1)
    {
        GPIO_WriteBit(GPIOA,GPIO_Pin_4 ,Bit_SET);
        delayMs(1000);
        GPIO_WriteBit(GPIOA,GPIO_Pin_4 ,Bit_RESET);
        delayMs(1000);
    }
}
void LED_Right(void)
{
    while(1)
    {
        GPIO_WriteBit(GPIOA, GPIO_Pin_5 ,Bit_SET);
        delayMs(3000);
        GPIO_WriteBit(GPIOA, GPIO_Pin_5 ,Bit_RESET);
        delayMs(3000);
    }
}
void LED_Close(void)
{
    while(1)
    {
        //GPIO_WriteBit(GPIOA,GPIO_Pin_4 ,Bit_RESET);
        delayMs(1000);
    }
}


void LED_init(void)
{
    // stm32 驱动
// gpio

    GPIO_InitTypeDef GPIO_InitStructure;
    /*EnableGPIOAclocksPA4,PA5,gr100老板子的flash管脚*/
    RCC_AHB1PeriphClockCmd(RCC_AHB1Periph_GPIOA,ENABLE);

    GPIO_InitStructure.GPIO_Pin = GPIO_Pin_4|GPIO_Pin_5|GPIO_Pin_6|GPIO_Pin_7;
    GPIO_InitStructure.GPIO_Mode = GPIO_Mode_OUT;
    GPIO_InitStructure.GPIO_OType = GPIO_OType_PP;
    GPIO_InitStructure.GPIO_Speed = GPIO_Speed_2MHz;
    GPIO_InitStructure.GPIO_PuPd = GPIO_PuPd_DOWN;
    GPIO_Init(GPIOA,&GPIO_InitStructure);

    GPIO_WriteBit(GPIOA, GPIO_Pin_4|GPIO_Pin_5|GPIO_Pin_6|GPIO_Pin_7, Bit_RESET);
}

void SysTickInit(void )
{
    SysTick_Config( SYSTEM_CLOCK / (1000));
// stm32 驱动

}
