#include "usart.h"

void USART1_Init(void)
{
    // Habilitar reloj para USART1 y GPIOA
    RCC->APB2ENR |= RCC_APB2ENR_USART1EN | RCC_APB2ENR_IOPAEN | RCC_APB2ENR_AFIOEN;

    // PA9 = TX -> Alternate function push-pull
    GPIOA->CRH &= ~(0xF << 4);
    GPIOA->CRH |=  (0x0B << 4); // 1011: AF PP 50MHz

    // PA10 = RX -> entrada flotante
    GPIOA->CRH &= ~(0xF << 8);
    GPIOA->CRH |=  (0x04 << 8); // 0100: input floating

    // Configurar USART1: 9600 baudios
    USART1->BRR = 7500;

    USART1->CR1 |= USART_CR1_TE | USART_CR1_RE; // TX y RX
    USART1->CR1 |= USART_CR1_UE;                // USART enable
}

void USART1_SendByte(uint8_t c)
{
    while(!(USART1->SR & USART_SR_TXE));
    USART1->DR = c;
}

void USART1_SendString(char *s)
{
    while(*s)
    {
        USART1_SendByte(*s++);
    }
}
