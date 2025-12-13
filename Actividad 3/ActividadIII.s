        THUMB
        AREA    |.text|, CODE, READONLY
        EXPORT  __main

;========================================================
;   ACTIVIDAD III – MICROPROCESADORES
;   STM32F103C8 - ARM Cortex-M3
;========================================================

; --- Direcciones base ---
RCC_APB2ENR     EQU     0x40021018
GPIOA_CRL       EQU     0x40010800
GPIOA_IDR       EQU     0x40010808
GPIOC_CRH       EQU     0x40011004
GPIOC_ODR       EQU     0x4001100C

; LED en PC13 (salida)
; Entradas: PA0 y PA1

; Memoria donde se guardan 100 números
BASE_ADDR       EQU     0x20000100
N_NUM           EQU     100

__main
;========================================================
; HABILITAR RELOJES
;========================================================
        LDR     R0, =RCC_APB2ENR
        LDR     R1, [R0]
        ORR     R1, R1, #(1<<2)     ; Habilitar GPIOA
        ORR     R1, R1, #(1<<4)     ; Habilitar GPIOC
        STR     R1, [R0]

;========================================================
; CONFIGURACIÓN GPIOA: PA0 y PA1 como ENTRADAS
;========================================================
        LDR     R0, =GPIOA_CRL
        LDR     R1, [R0]
        BIC     R1, R1, #(0xF)          ; PA0 input
        BIC     R1, R1, #(0xF<<4)       ; PA1 input
        STR     R1, [R0]

;========================================================
; CONFIGURACIÓN GPIOC: PC13 como SALIDA (LED)
;========================================================
        LDR     R0, =GPIOC_CRH
        LDR     R1, [R0]
        BIC     R1, R1, #(0xF<<20)      ; limpiar PC13
        ORR     R1, R1, #(0x1<<20)      ; salida push-pull 10 MHz
        STR     R1, [R0]

; LED apagado
        LDR     R0, =GPIOC_ODR
        LDR     R1, [R0]
        ORR     R1, R1, #(1<<13)
        STR     R1, [R0]

; --- Inicializar banderas ---
        LDR     R0, =flag_random
        MOVS    R1, #0
        STR     R1, [R0]

        LDR     R0, =flag_sort
        MOVS    R1, #0
        STR     R1, [R0]

;========================================================
;              BUCLE PRINCIPAL
;========================================================
main_loop
        BL      read_inputs

        CMP     R0, #0      ; 00 ? inicio
        BEQ     state_inicio

        CMP     R0, #1      ; 01 ? generar aleatorios
        BEQ     state_random

        CMP     R0, #2      ; 10 ? ordenar
        BEQ     state_sort

        B       main_loop

;========================================================
; ESTADO 00 : INICIO
; LED apagado – borrar banderas
;========================================================
state_inicio
        ; LED OFF
        LDR     R0, =GPIOC_ODR
        LDR     R1, [R0]
        ORR     R1, R1, #(1<<13)
        STR     R1, [R0]

        B       main_loop

;========================================================
; ESTADO 01 : GENERAR 100 PSEUDO-ALEATORIOS
;========================================================
state_random
        ; LED ON
        LDR     R0, =GPIOC_ODR
        LDR     R1, [R0]
        BIC     R1, R1, #(1<<13)
        STR     R1, [R0]

        ; generar si no se han generado antes
        LDR     R0, =flag_random
        LDR     R1, [R0]
        CMP     R1, #1
        BEQ     main_loop   ; ya hechos

        BL      generate_randoms

        ; poner bandera
        MOVS    R1, #1
        STR     R1, [R0]

        B       main_loop


;========================================================
; ESTADO 10 : ORDENAR DATOS
;========================================================
state_sort
        ; LED ON
        LDR     R0, =GPIOC_ODR
        LDR     R1, [R0]
        BIC     R1, R1, #(1<<13)
        STR     R1, [R0]

        ; verificar si ya hay aleatorios
        LDR     R0, =flag_random
        LDR     R1, [R0]
        CMP     R1, #0
        BEQ     main_loop   ; no hay datos ? regreso

        ; si no se ha ordenado antes
        LDR     R0, =flag_sort
        LDR     R1, [R0]
        CMP     R1, #1
        BEQ     main_loop

        BL      bubble_sort

        MOVS    R1, #1
        STR     R1, [R0]

        B       main_loop

;========================================================
; LEE 2 BITS DE ENTRADA (PA1:PA0)
;========================================================
read_inputs
        LDR     R0, =GPIOA_IDR
        LDR     R1, [R0]
        ANDS    R1, R1, #0x03
        MOV     R0, R1
        BX      LR

;========================================================
; GENERAR 100 ALEATORIOS (LFSR simple)
;========================================================
generate_randoms
        MOVS    R4, #0xAB        ; semilla
        LDR     R5, =BASE_ADDR

gen_loop
        ; LFSR (pseudo-random)
        LSRS    R6, R4, #1
        EORS    R4, R6, #(1<<6)

        STR     R4, [R5]
        ADDS    R5, R5, #4

        SUBS    R7, R7, #1
        CMP     R7, #0
        BEQ     gen_done

        B       gen_loop

gen_done
        BX      LR

;========================================================
; ORDENAMIENTO BURBUJA
;========================================================
bubble_sort
        LDR     R0, =BASE_ADDR
        MOVS    R1, #N_NUM

outer
        MOV     R2, R0           ; ptr inicio

inner
        LDR     R3, [R2]
        LDR     R4, [R2, #4]
        CMP     R3, R4
        BLE     no_swap

        ; swap
        STR     R4, [R2]
        STR     R3, [R2, #4]

no_swap
        ADDS    R2, R2, #4
        SUBS    R5, R1, #1
        CMP     R2, R0
        ADD     R6, R0, R5, LSL #2
        CMP     R2, R6
        BLT     inner

        SUBS    R1, R1, #1
        CMP     R1, #1
        BGT     outer

        BX      LR

;========================================================
; VARIABLES
;========================================================
        AREA |.data|, DATA, READWRITE

flag_random     DCD 0
flag_sort       DCD 0

        END
