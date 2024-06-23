.data
board: .space 12           # Tablero de 12 casillas
chacales: .word 0          # Número de chacales encontrados
tesoros: .word 0           # Número de tesoros encontrados
dinero: .word 0            # Dinero acumulado
descubiertas: .space 12    # Casillas descubiertas
mensaje_bienvenida: .asciiz "Bienvenido al Juego de Chacales!\n"
mensaje_perder: .asciiz "¡Has perdido el juego!\n"
mensaje_ganar: .asciiz "¡Has ganado el juego!\n"
mensaje_continuar: .asciiz "¿Deseas continuar jugando? (1: Si, 0: No)\n"
mensaje_dinero: .asciiz "Dinero acumulado: $"
mensaje_chacales: .asciiz "Chacales encontrados: "
mensaje_tesoros: .asciiz "Tesoros encontrados: "
mensaje_tablero: .asciiz "Estado del tablero: \n"
msg_O: .asciiz "O "
msg_X: .asciiz "X "
msg_dollar: .asciiz "$ "
newline: .asciiz "\n"

.text
.globl main

main:
    # Inicializar el juego
    li $v0, 4
    la $a0, mensaje_bienvenida
    syscall

    jal inicializar_tablero
    
    # Bucle principal del juego
jugar:
    jal mostrar_tablero
    jal generar_numero_aleatorio
    jal descubrir_casilla

    # Verificar condiciones de fin del juego
    jal verificar_condiciones

    # Preguntar al jugador si quiere continuar
    jal preguntar_continuar
    beq $v0, 0, fin_juego

    j jugar

fin_juego:
    jal mostrar_resultados
    li $v0, 10
    syscall




# Inicializa el tablero con chacales y tesoros distribuidos aleatoriamente
inicializar_tablero:
    li $t0, 0  # Índice del tablero
    li $t1, 4  # Número de chacales
    li $t2, 8  # Número de tesoros

# Inicializar tablero con 0 (vacío)
inicializar_loop:
    li $t3, 0
    sb $t3, board($t0)
    addi $t0, $t0, 1
    bne $t0, 12, inicializar_loop

# Colocar chacales en el tablero
colocar_chacales:
    li $v0, 42         # syscall code para generar un entero aleatorio
    li $a1, 12         # limite superior exclusivo del entero a generarse 
    syscall

    move $t4, $a0 #the random number 0-11


    # Verificar si la casilla ya está ocupada
    lb $t5, board($t4)
    bnez $t5, colocar_chacales

    # Colocar chacal
    li $t5, 1
    sb $t5, board($t4)
    subi $t1, $t1, 1
    bnez $t1, colocar_chacales

    # Colocar tesoros en el tablero
colocar_tesoros:
    li $v0, 42         # syscall code para generar un entero aleatorio
    li $a1, 12         # limite superior exclusivo del entero a generarse 
    syscall

    move $t4, $a0 #the random number 0-11

    # Verificar si la casilla ya está ocupada
    lb $t5, board($t4)
    bnez $t5, colocar_tesoros

    # Colocar tesoro
    li $t5, 2
    sb $t5, board($t4)
    subi $t2, $t2, 1
    bnez $t2, colocar_tesoros

    jr $ra





# Muestra el estado actual del tablero
mostrar_tablero:
    li $v0, 4
    la $a0, mensaje_tablero
    syscall

    li $t0, 0
mostrar_tablero_loop:
    lb $t1, board($t0)
    beqz $t1, casilla_vacia
    beq $t1, 1, casilla_chacal
    beq $t1, 2, casilla_tesoro

casilla_vacia:
    li $v0, 4
    la $a0, msg_O
    syscall
    j siguiente_casilla

casilla_chacal:
    li $v0, 4
    la $a0, msg_X
    syscall
    j siguiente_casilla

casilla_tesoro:
    li $v0, 4
    la $a0, msg_dollar
    syscall

siguiente_casilla:
    addi $t0, $t0, 1
    bne $t0, 12, mostrar_tablero_loop
    jr $ra




# Genera un número aleatorio entre 1 y 12
generar_numero_aleatorio:
    addi $sp, $sp, -8
    sw $ra, 8($sp)
    sw $a0, 4($sp)
    sw $a1, 0($sp)
    
    li $v0, 42         # syscall code para generar un entero aleatorio
    li $a1, 12         # limite superior exclusivo del entero a generarse 
    syscall            # genera el entero y lo guarda en a0
    
    addi $v0, $a0, 0
    
    lw $ra, 8($sp)
    lw $a0, 4($sp)
    lw $a1, 0($sp)
    addi $sp, $sp, 8
    
    jr $ra



# Descubre la casilla seleccionada
descubrir_casilla:
    move $t0, $v0  # $t0 = número de casilla
    subi $t0, $t0, 1  # Convertir de 1-12 a 0-11
    lb $t1, board($t0)
    beqz $t1, casilla_vacia_descubrir
    beq $t1, 1, casilla_chacal_descubrir
    beq $t1, 2, casilla_tesoro_descubrir
    j casilla_ya_descubierta

casilla_vacia_descubrir:
    li $t1, 0
    sb $t1, board($t0)
    j fin_descubrir

casilla_chacal_descubrir:
    li $t1, 1
    sb $t1, board($t0)
    lw $t2, chacales
    addi $t2, $t2, 1
    sw $t2, chacales
    j fin_descubrir

casilla_tesoro_descubrir:
    li $t1, 2
    sb $t1, board($t0)
    lw $t2, tesoros
    addi $t2, $t2, 1
    sw $t2, tesoros
    lw $t3, dinero
    addi $t3, $t3, 100
    sw $t3, dinero
    j fin_descubrir

casilla_ya_descubierta:
    # Implementar lógica para casilla ya descubierta (pérdida del juego si se repite 3 veces)
    j fin_descubrir

fin_descubrir:
    jr $ra

# Verifica las condiciones para terminar el juego
verificar_condiciones:
    lw $t1, chacales
    lw $t2, tesoros
    beq $t1, 4, perder_juego
    beq $t2, 4, ganar_juego
    jr $ra

perder_juego:
    li $v0, 4
    la $a0, mensaje_perder
    syscall
    li $v0, 10
    syscall

ganar_juego:
    li $v0, 4
    la $a0, mensaje_ganar
    syscall
    li $v0, 10
    syscall

# Pregunta al jugador si quiere continuar jugando
preguntar_continuar:
    li $v0, 4
    la $a0, mensaje_continuar
    syscall
    li $v0, 5
    syscall
    move $v0, $v0  # Guardar respuesta del jugador
    jr $ra

# Muestra los resultados finales del juego
mostrar_resultados:
    li $v0, 4
    la $a0, mensaje_dinero
    syscall

    lw $a0, dinero
    li $v0, 1
    syscall

    li $v0, 4
    la $a0, newline
    syscall

    li $v0, 4
    la $a0, mensaje_chacales
    syscall

    lw $a0, chacales
    li $v0, 1
    syscall

    li $v0, 4
    la $a0, newline
    syscall

    li $v0, 4
    la $a0, mensaje_tesoros
    syscall

    lw $a0, tesoros
    li $v0, 1
    syscall

    li $v0, 4
    la $a0, newline
    syscall

    jr $ra
