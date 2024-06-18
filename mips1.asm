.data
string: .asciiz "Tesoros y Chacales\n"

.text 
main: addi $sp, $sp, -4
sw $a0, 0($sp)
la $a0, string
jal print_string
lw $a0, 0($sp)
addi $sp, $sp, 4
jal rng
move $a0, $v0      # Muevo el resultado de rng a a0 para ser impreso
li $v0, 1          # syscall code para imprimir un entero
syscall
li $v0, 10         # syscall code para acabar el programa
syscall

print_string: addi $sp, $sp, -4 # imprime un string presente en a0
sw $ra, 0($sp)     # llamar a syscall vuelve anidadas a las funciones
li $v0, 4          # syscall code para imprimir un string
syscall      
lw $ra, 0($sp)
addi $sp, $sp, 4
jr $ra

rng: addi $sp, $sp, -8 # genera un numero aleatorio entre [1-12]
sw $ra, 4($sp)
sw $a0, 0($sp)
li $v0, 42         # syscall code para generar un entero aleatorio
li $a1, 12         # limite superior exclusivo del entero a generarse 
syscall            # genera el entero y lo guarda en a0
addi $v0, $a0, 1   # lo mueve a v0 y se le agrega 1 para abarcar el rango [1-12]
lw $a0, 0($sp)
lw $ra, 4($sp)
addi $sp, $sp, 8
jr $ra


#generate_cells: addi $sp, $sp, -48
