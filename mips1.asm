.data
string: .asciiz "Tesoros y Chacales"

.text
main: li $v0, 4
la $a0, string
syscall