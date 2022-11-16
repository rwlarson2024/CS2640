##################################################################################################
# Program : Combination Calculator			Programmer : Ryan Larson		 
# Date : 11/15/2022					Course : CS2640				 
##################################################################################################
# Program Functional Description:
# The main routine is a simple combination calculator, where the main function asks a user to 
# input values for N and R. The main routine will then recursivly call the comb subroutine and 
# compute the Comb(n-1,r) save the value into a stack, then call Comb(n-1, r-1). From these calls
# the recursive function will get to the smallest value of n before n < 0 and when n = r. At this
# point the recursion will unwind and add the values together to get the combination value
##################################################################################################
# Registers usage in Main:
# $a0 -- used to stage the value of n for Comb
# $a1 -- used to stage the value of r for Comb
# $t0 -- used to compare n with r
# $t1 -- used to compare r with n
# $v0 -- used to return values from the subroutines
# $0  -- used to compare and set values to zero
##################################################################################################
# Psedocode Description :
# 1. print a prompt
# 2. get input from user for both n and r 
# 3. compare multiple cases (n==r, n<r, n>13)
# 4. call subroutine comb to compute comb(n-1, r)
# 5. recursivly call the comb funtion until n == r or r >= 0
# 6. add plus one to $v0 for each time n==r and r>=0
# 7. display the combination 
# 8. end program
##################################################################################################
.data
	inputN: 	.asciiz "Enter the n value(n > = r): "
	inputR:		.asciiz "Enter the r value(n > = r): "
	errorlargeN:	.asciiz "The n value is too large, try again :D\n"
	errorlargeR:	.asciiz "The r value is too large, try again :D\n"
	combEqual:	.asciiz "\nThe Combination : " 
	.align 2
	n: 		.word 0
	r:		.word 0
	p:		.word 1
.text
main:
	#Taking the input from the user and storing it in the data segment n
storeN:	li $v0, 4
	la $a0, inputN
	syscall
	li $v0, 5
	syscall
	sw $v0, n
	lw $t0, n
	bge $t0, 13, errorLargeN
	#Taking the input from the user and storing it in the data segment r
storeR:	li $v0, 4
	la $a0, inputR
	syscall
	li $v0, 5
	syscall
	sw $v0, r
	lw $t1, r
	#compare the values to make sure that there are no values larger than 13 and if they are equal then print out
	bge $t1, 13, errorLargeR
	beq $t1,$t0, combequal
	bgt $t1, $t0, error
	#prepare the function with values that can be computed by the function without affecting the original value
	move $a0, $t0 #setting $a0 to n
	move $a1, $t1 #setting $a1 to r
	li $v0, 0
	#call Comb function
	jal comb
	#move the result from the recursive call to $t1 to print.
	move $t1, $v0
	addi $t1,$t1, 1
	div $t1, $t1, 2
	#print the result onto the commmand line.
	li $v0,1
	add $a0, $0, $t1
	syscall
	#end program gracefully
	li $v0, 10
	syscall

comb:   addiu $sp, $sp, -12 #make stack of size 12 to hold the data from the call of this recursion
	sw $ra, 0($sp) 	    #store value of return address in the first word section of the stack
	sw $a0, 4($sp)      #store the original value of n into stack
	sw $a1, 8($sp)	    #store the original value of r into stack
	#check n==r and r>=0
	beq $a0, $a1, return  # n equal r return $v0 + 1
	beqz $a1, return    #r equal zero $v0 + 1
	#recursive call that will compute the values of Comb (n-1, r) and Comb (n-1, r-1)
recure: lw $a0, 4($sp)
	#compute (n-1)
	addi $a0,$a0, -1
	lw $a1, 8($sp)
	jal comb
	#compute (n-1, r-1)
	lw $a0, 4($sp)
	addi $a0,$a0, -1
	lw $a1, 8($sp)
	addi $a1, $a1, -1
	jal comb
	#when the lowest n and r have been found, unwind the recursion
	j return
return: 
	#restore the values in the stack to their original call value and restore the stack
	lw $ra, 0($sp)
	lw $a0, 4($sp)
	lw $a1, 8($sp)
	addi $sp, $sp, 12
	#add 1 to $v0
	addi $v0, $v0, 1
	jr $ra
combequal:
	#when the imputed value of n and r are equal call this subroutine to return the value in p and end
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
	#when the value of r is greater than the value of n print error statement and loop back to get a new value of r
	li $v0, 4
	la $a0, errorlargeR
	syscall
	j storeR
errorLargeN:
	#if the value of n is greater than the value of 13 then the program will print an error statment and ask for another n value
	li $v0, 4
	la $a0, errorlargeN
	syscall
	j storeN
errorLargeR:
	#when the value of r is greater than the value of 13 print error statement and loop back to get a new value of r
	li $v0, 4
	la $a0, errorlargeR
	syscall
	j storeR
end:
	jr $ra
