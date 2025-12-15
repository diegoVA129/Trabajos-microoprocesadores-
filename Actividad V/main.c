#include "stm32f10x.h"
#include "usart.h"
#include "random.h"
#include <stdio.h>

uint16_t numeros[2000];   // 2000 números en SRAM

void delay_ms(uint16_t t);

int main(void)
{
    USART1_Init();        // Inicializar USART1 para el HM-10
    delay_ms(500);

    USART1_SendString("\nSTM32F103C8 + HM-10 listo.\n");
    USART1_SendString("Generando 2000 numeros...\n");

    // Generar los 2000 valores
    generar_2000_numeros(numeros);

    USART1_SendString("Enviando datos...\n");

    // Enviar los 2000 números vía BLE
    for(int i=0; i<2000; i++)
    {
      char buffer[16];
      sprintf(buffer, "%u\n", numeros[i]);
      USART1_SendString(buffer);
      delay_ms(3);    // HM-10 necesita tiempo entre mensajes
    }

    USART1_SendString("Listo.\n");

    while(1)
    {

    }
}

void delay_ms(uint16_t t){
    volatile unsigned long l=0;
    for(uint16_t i = 0; i < t; i++)
    for(l = 0; l < 6000; l++);
}
