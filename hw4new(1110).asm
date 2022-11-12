##################################################################################################
# Program : Combination Calculator			Programmer : Ryan Larson		 
# Date : 11/12/2022					Course : CS2640				 
##################################################################################################
# Program Functional Description:
# The main routine is a simple combination calculator, where the main function asks a user to 
# input values for N and R. The main routine will then recursivly call the fact subroutine to 
# compute the values of N!, R!, and (N-R)! and store them in .data. Lastly the main function will
# call the comb subroutine to compute the combination of the inputed values.
##################################################################################################
# Registers usage in Main:
# $a0 -- used for subroutine linkage 
# $t0 -- used to save input values
# $v0 -- used to return values from the subroutines
##################################################################################################
# Psedocode Description :
# 1. print a prompt
# 2. get input from user for both n and r 
# 3. compare multiple cases (n==r, n<r, n>13)
# 4. call subroutines to get values of factorial
# 5. display the factorial values to the user
# 6. call subroutine to get value of the combination
# 7. display the combination 
# 8. end program
##################################################################################################
.data
	inputN: 	.asciiz "\nEnter the n value(n > = r): "
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
	s:		.word 0 
	p:		.word 1
	returnN:	.word 0
	returnR:	.word 0
	returnS:	.word 0 
	Combination:	.word 0
.text
.globl main
main:
	#take the input from  user and store it into n. if n is greater than 13 display error and jump to storeN
storeN:	li $v0, 4
	la $a0, inputN
	syscall
	li $v0, 5
	syscall
	sw $v0, n
	lw $t0, n
	bge $t0, 13, errorLargeN
	#take the input from user and store it into r
storeR:	li $v0, 4
	la $a0, inputR
	syscall
	li $v0, 5
	syscall
	sw $v0, r
	lw $t1, r
	#validates the value to make sure it can be processed correctly
	bge $t1, 13, errorLargeR
	#compare n and r. if equal jumps to subroutine that returns combination = 1
	beq $t1,$t0, combequal
	#compare n and r. if n is greater than r continue to loading stack, else display error and jump to storeR. 
	bgt $t1, $t0, error
	#subtract the values of n - r to get the denominator of the Comb formula.
	sub $t3, $t0, $t1
	sw $t3, s 
	
	#call factorial for n
	lw $a0, n
	jal fact
	sw $v0, returnN
	#display the result
	li $v0,4
	la $a0, msgOne
	syscall
	li $v0, 1
	lw $a0, returnN
	syscall
	
	#Call Factorial for r
	lw $a0, r
	jal fact
	sw $v0, returnR
	#display result
	li $v0,4
	la $a0, msgTwo
	syscall
	li $v0, 1
	lw $a0, returnR
	syscall 
	
	#Call Factorial for s
	lw $a0, s
	jal fact
	sw $v0, returnS
	#display result
	li $v0,4
	la $a0, msgThree
	syscall
	li $v0, 1
	lw $a0, returnS
	syscall
	#call subroutine for combination and display the result
	jal Comb
	li $v0,4
	la $a0, combEqual
	syscall
	li $v0, 1
	lw $a0, Combination
	syscall
	#end of program
	li $v0, 10
	syscall
#----------------------------------------------------------------
#factorial function
.globl fact
fact: 
	#Create space on the stack to compute that values for the factorial
	addiu $sp, $sp, -8
	sw    $ra, ($sp)
	sw    $s0, 4($sp)
	# Base case to stop recursion (arguments = 0)
	li $v0, 1
	beq $a0, 0, factDone
	#find factorial of n - 1
	move $s0,$a0
	addi $a0,$a0,-1
	jal fact
	#recursion is unwinding
	mul $v0, $s0, $v0
				
factDone:
	lw $ra, ($sp)	
	lw $s0, 4($sp)
	addu $sp, $sp, 8
	jr $ra	
Comb:	
	lw $t0, returnN
	lw $t1, returnR
	lw $t2, returnS
	mul $t1, $t1, $t2
	div $t0, $t0, $t1
	sw $t0, Combination
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
