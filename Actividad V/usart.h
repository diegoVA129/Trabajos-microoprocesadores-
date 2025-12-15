#ifndef USART_H
#define USART_H

#include "stm32f10x.h"
#include <stdint.h>

void USART1_Init(void);
void USART1_SendByte(uint8_t c);
void USART1_SendString(char *s);

#endif
