.data
	inputN: 	.asciiz "Enter the n value(n > = r): "
	inputR:		.asciiz "Enter the r value(n > = r): "
	errorlargeN:	.asciiz "The n value is too large, try again :D\n"
	errorlargeR:	.asciiz "The r value is too large, try again :D\n"
	msgOne: 	.asciiz "\nThe Factorial of N is: "
	msgTwo: 	.asciiz "\nThe Factorial of R is: "
	msgThree: 	.asciiz "\nThe Factorial of N-R is: "
	combEqual:	.asciiz "\nThe Combination : " 
	.align 2
	n: 		.word 0
	r:		.word 0
	p:		.word 1
.text
main:
	#N
storeN:	li $v0, 4
	la $a0, inputN
	syscall
	li $v0, 5
	syscall
	sw $v0, n
	lw $t0, n
	bge $t0, 13, errorLargeN
	#R
storeR:	li $v0, 4
	la $a0, inputR
	syscall
	li $v0, 5
	syscall
	sw $v0, r
	lw $t1, r
	#compare.
	bge $t1, 13, errorLargeR
	beq $t1,$t0, combequal
	bgt $t1, $t0, error
	
	move $a0, $t0 #setting $a0 to n
	move $a1, $t1 #setting $a1 to r
	li $v0, 0
	#call funvtion
	jal comb
	#move the result from the recursive call to $t1 to print.
	move $t1, $v0
	move $t2, $s0
	add $t1, $t1, $t2
	#print the result onto the commmand line.
	li $v0,1
	add $a0, $0, $t1
	syscall
	li $v0, 10
	syscall

comb:   addiu $sp, $sp, -20 #make stack
	sw $ra, 0($sp)
	sw $a0, 4($sp)
	sw $a1, 8($sp)
	#msybe
	sw $v0, 12($sp)
	sw $s0, 16($sp)
	
	
	
	
	#check n==r and r>=0
	beq $a0, $a1, return  # n equal r return $v0 + 1
	beqz $a1, return    #r equal zero $v0 + 1
	#add $v1, $v0, $s0
	#jr $ra
	
recure: lw $a0, 4($sp)
	addi $a0,$a0, -1
	lw $a1, 8($sp)
	jal comb
	#sw $v0, 12($sp)
	#lw $a0, 4($sp)
	#move $s0, $v0
	#addi $a0,$a0, -1
	#lw $a1, 8($sp)
	#addi $a1, $a1, -1
	#jal comb 
	#sw $s0, 16($sp)
	lw $ra, 0($sp)
	jr $ra 
return: 
	lw $ra, 0($sp)
	lw $a0, 4($sp)
	lw $a1, 8($sp)
	lw $s0, 16($sp)
	addi $sp, $sp, 16
	addi $v0, $v0, 1
	jr $ra
	
	
	
	
	
	
	
	
	
	
	
	
	
	
combequal:
	lw $t2, p	
	li $v0,4
	la $a0, combEqual
	syscall
	li $v0, 1
	lw $a0, p
	syscall
	li $v0, 10
	syscall
error:
	li $v0, 4
	la $a0, errorlargeR
	syscall
	j storeR
errorLargeN:
	li $v0, 4
	la $a0, errorlargeN
	syscall
	j storeN
errorLargeR:
	li $v0, 4
	la $a0, errorlargeR
	syscall
	j storeR
end:
	jr $ra