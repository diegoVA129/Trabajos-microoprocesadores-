        THUMB
        AREA    |.text|, CODE, READONLY
        EXPORT  __main

__main
        ; Cargar n
        LDR     R0, =n          ; R0 -> dirección de 'n'
        LDR     R1, [R0]        ; R1 = n

        ; Limitar/validar: si n > 47 lo truncamos a 47 (evita overflow o petición fuera de rango)
        CMP     R1, #47
        BLE     compute_continue
        MOVS    R1, #47

compute_continue
        ; Cargar dirección base donde almacenar (0x20001000)
        LDR     R2, =base_addr_ptr
        LDR     R2, [R2]        ; R2 = 0x20001000

        ; Caso n == 0  -> almacenar solo F0 = 0
        CMP     R1, #0
        BEQ     store_F0_only

        ; Inicializar F0 = 0, F1 = 1
        MOVS    R3, #0          ; R3 = a = F(i-2)
        MOVS    R4, #1          ; R4 = b = F(i-1)

        ; Almacenar F0
        STR     R3, [R2], #4    ; *addr = F0 ; addr += 4

        ; Almacenar F1 (porque n >= 1)
        STR     R4, [R2], #4    ; *addr = F1 ; addr += 4

        ; Si n == 1 ya terminamos
        CMP     R1, #1
        BEQ     finished_loop

        ; Bucle i = 2 .. n
        MOVS    R5, #2          ; R5 = contador i
fib_loop
        ADDS    R6, R3, R4      ; R6 = next = a + b
        STR     R6, [R2], #4    ; almacenar next en memoria, addr += 4

        ; actualizar a,b
        MOV     R3, R4
        MOV     R4, R6

        ; incrementar i y comparar
        ADDS    R5, R5, #1
        CMP     R5, R1
        BLE     fib_loop

        B       finished_loop

store_F0_only
        ; Almacenar solo F0 = 0 en la dirección base (n == 0)
        LDR     R2, =base_addr_ptr
        LDR     R2, [R2]
        MOVS    R3, #0
        STR     R3, [R2]

finished_loop
        ; Fin: loop infinito para dejar el MCU en estado detenido (para simular)
end_loop
        B       end_loop

        ; -----------------------
        ; Datos (sección de datos)
        ; -----------------------
        AREA    |.data|, DATA, READWRITE

n               DCD     9               ; <-- <-- Valor de n (ejemplo: 9). Cambialo aquí (0..47).
base_addr_ptr   DCD     0x20001000      ; dirección base en SRAM donde se depositan los resultados

        ; -----------------------
        END
