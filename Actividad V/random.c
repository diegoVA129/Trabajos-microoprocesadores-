#include "random.h"

static uint32_t seed = 1234567;   // Semilla fija

static uint16_t lcg_rand(void)
{
    seed = (1664525 * seed + 1013904223);  
    return (seed >> 16); // Regresa 16 bits
}

void generar_2000_numeros(uint16_t *buffer)
{
    for(int i=0; i<2000; i++)
    {
        buffer[i] = lcg_rand();
    }
}
