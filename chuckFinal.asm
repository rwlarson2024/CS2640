########################################################################
# Program: chuck (Chuck-A-Luck)				Programmer: RYAN LARSON
# Due Date: 11/25/2022					Course: CS2640
########################################################################
# Overall Program Functional Description:
#	The program plays the Chuck-A-Luck game.  The player starts with
#	a purse of $500.  For each round, the player selects a wager, then
#	picks a number from 1 to 6.  The program then rolls three dice.
#	If none of the dice match the chosen number, the player loses the
#	wager.  For each dice that matches the chosen number, the player
#	earns the wager (so, for example, if two dice show the chosen number,
#	the player earns twice the wager).  The program ends when the
#	player enters a wager of 0.
#
########################################################################
# Register usage in Main:
#	- $v0
#	- $a0
#	- $t0, $t3 - $t9
########################################################################
# Pseudocode Description:
#	1. Print a welcome message
#	2. Get a value from the user, use it to seed the random number generator
#	3. Seed the player's holdings with 500.
#	4. Loop:
#		a. Print their holdings, receive the wager.  If 0, break the loop.
#		b. Get the chosen number for this round.
#		c. Looping 3 times:
#			1. Get a random dice roll
#			2. If it matches the chosen number, increment the success counter
#		d. Print a message based on the success counter, and adjust their
#			holdings based on this same counter.
#		e. If the holdings get to 0, print a 'bye' message.
#	5. Clean up, print a 'bye' message, and leave.
#
########################################################################
.data
	welcome:	.asciiz "\nWelcome to Chuck-A-Luck! Place your bets and Test Your Luck!"
	matchingmsg:	.asciiz "\nYour betting number: "
	rolling:	.asciiz "\nRolling ............  "
	winning:	.asciiz "\nJackpot! You win for each match! \n"
	losing:		.asciiz "\nYou Lose Your Wager:P Better Luck Next Time\n"
	noMore:		.asciiz "\nGood Bye! See you next time!"
			.align 2
	wager: 		.word 0
	betNumber:	.word 0
	count:		.word 0
	loopCounter:	.word 3


.globl main
.text
main:						#using the registers $v0, $a0, $t3 - $t9
		li 	$v0, 4
		la 	$a0, welcome
		syscall
		li	$t3, 500		#The $t3 register will be a living value that will hold the value of the balance
		move 	$a0, $t3		#This preps the getwager function with the current balance of the user
loop:						#The looping function to keep the game running until the user runs out of money or ends it
		blez 	$t3, exit		#when the user has no more money to use in the function, jump to the exit function
		jal 	getwager		#takes betting wager from the user and uses it as the base multiplier for the user's winnings. 
		sw 	$v0, wager		#the value can be from 1 to the max value of the balance that the user has. 
		beqz 	$v0, exit		#If the user enters the value 0 for wager then the program will jump to the exit function
		jal 	getguess		#asks the user to input a value for their betting guess value.
		sw 	$v0, betNumber		#returns the value from the function and stores it into memory
		li 	$v0, 4			#The Value for the betting number is given back to the user to make sure that the value is correct
		la 	$a0, matchingmsg		
		syscall
		
		lw	$a0, betNumber	 		
		li	$v0, 1	
		syscall
						#This makes sure to update all the values from memory into different registers for the following functions
		lw 	$t5, betNumber		#Register to hold the betting value from user
		lw 	$t7, loopCounter	#Register to hold the counter for how many loop iterations there has been
		lw	$t6, wager		#Register to hold the wager value from the usre
		lw	$t9, count		#Register to hold the amount of times that the user successfully matches a value from the rolls
diceRoll:	
		beqz	$t7, out		#checks if the loop has completed its 3 itterations
		jal 	rand			#Gets the value for the random rolled dice and prints them with a msg and the value of the roll
		move 	$t4, $v0
		li 	$v0, 4						
		la 	$a0, rolling 				
		syscall
		move	$a0, $t4	 	#moves the value of $t4 into $a0 to print the value on the command line
		li	$v0, 1	
		syscall
		addi	$t7, $t7, -1		#this section decreases the loop counter and once the loopcounter hits 0 it will jump out of the dice roll loop
		beq	$t5, $t4, incre		#This checks the value of the user guess and the dice roll and increases the multiplier of the wager
		j	diceRoll
incre:						#This is the increasing function that computes the amount the user will get in a multiplier
		addi 	$t9, $t9, 1
		j	diceRoll		#returns back to top of the roll function to start the next iteration of the dice roll

out:		beqz	$t9, noWin		#breaks out of the dice rolls to return if the user has won any amount of money or has lost any.
		mult	$t9, $t6		#this will compute how much the user should recieve if there was any winnings. 
		mflo	$t6						
		add	$t3, $t3, $t6		#adds the winnings back to the constantly updating value of $t3 aka Balance
		li 	$v0, 4
		la 	$a0, winning
		syscall
		move 	$a0, $t3		#preps $a0 for the function getWager
		j loop

noWin: 		sub	$t3, $t3, $t6		#if the user does not recieve any matches with the dice roll then the wager is removed from the running balance
		li 	$v0, 4
		la 	$a0, losing
		syscall
		move 	$a0, $t3		#preps $a0 for the function getWager
		j loop
exit: 		li 	$v0, 4			#the exit function that loads an exit message and closes the programly gracefully
		la 	$a0, noMore
		syscall
		li 	$v0, 10
		syscall
########################################################################
# Function Name: int getwager(holdings)
########################################################################
# Functional Description:
#	This routine is passed the player's current holdings, and will return
#	the player's wager, or the value 0 if the player wants to quit the
#	program.  It displays the holdings, then prompts for the wager.
#	It then checks to see if the wager is in the proper range.  If so,
#	it returns the wager.  Otherwise, it prints an error message, then
#	tries again.
#
########################################################################
# Register Usage in the Function:
#	$v0, #a0 -- for subroutine linkage and general calculations
#	$t8 -- a temporary register used to store the holdings
#
########################################################################
# Algorithmic Description in Pseudocode:
#	1. Display the current holdings to the player
#	1. Print the prompt, asking for the wager
#	2. Read in the number
#	3. If the number is between 0 and holdings, return with that number
#	4. Otherwise print an error message and loop back to try again.
#
########################################################################
	.data
holdmsg:	.asciiz "\nYou currently have $"
wagermsg:	.asciiz "\nHow much would you like to wager? "
big:	.asciiz "\nThat bet is too big."
negtv:	.asciiz "\nYou can't bet a negative amount."
	.text
getwager:
	move 	$t8, $a0		# Save their holdings in $t8
again:
	li		$v0, 4			# Call the Print String I/O Service to print
	la		$a0, holdmsg	#   message about their holdings
	syscall
	move	$a0, $t8		# Call the Print Integer I/O Service to 
	li		$v0, 1			#   print the value
	syscall
	li		$v0, 4			# Call the Print String I/O Service to 
	la		$a0, wagermsg	#  	ask for the wager
	syscall
	li		$v0, 5			# Call the Read Integer I/O Service to
	syscall					#   fetch the wager
	bgt		$v0, $t8, toobig	# If wager > holdings, go to error line
	bltz	$v0, toosmall	# If wager < 0, go to error line
	jr		$ra				# Return with the wager in $v0
toobig:
	li		$v0, 4			# Call the Print String I/O Service to print
	la		$a0, big		#   that the wager was too big
	syscall
	j		again			# Jump back to try again
toosmall:
	li		$v0, 4			# Call the Print String I/O Service to print
	la		$a0, negtv		#   that the wager was too small
	syscall
	j		again			# Jump back to try again

########################################################################
# Function Name: int getguess()
########################################################################
# Functional Description:
#	This routine asks the player to enter the chosen number, which
#	should be between 1 and 6.  If the value is out-of-range, the
#	routine will print a message and ask again, repeating until we
#	get a valid number.
#
########################################################################
# Register Usage in the Function:
#	$v0, #a0 -- for subroutine linkage and general calculations
#	$t0 -- a temporary register used in the calculations
#
########################################################################
# Algorithmic Description in Pseudocode:
#	1. Print the prompt, asking for the chosen number
#	2. Read in the number
#	3. If the number is between 1 and 6, return with that number
#	4. Otherwise print an error message and loop back to try again.
#
########################################################################
	.data
dice:	.asciiz "\nWhat number do you want to bet on? "
limit:	.asciiz "\nThe number has to be between 1 and 6."
	.text
getguess:
	li		$v0, 4			# Call the Print String I/O Service to print
	la		$a0, dice		#   request for their chosen number
	syscall
	li		$v0, 5			# Call the Read Integer I/O Service to get
	syscall					#   the number from the player
	blez	$v0, bad		# If the number is negative, it is bad
	li		$a0, 6			# If the number is greater than 6, it is bad
	bgt		$v0, $a0, bad
	jr		$ra				# Return with the valid number in $v0
bad:
	li		$v0, 4			# Call the Print String I/O Service to print
	la		$a0, limit		#   that the number is out-of-bounds
	syscall
	j		getguess		# Loop back to try again

########################################################################
# Function Name: int rand()
########################################################################
# Functional Description:
#	This routine generates a pseudorandom number using the xorsum
#	algorithm.  It depends on a non-zero value being in the 'seed'
#	location, which can be set by a prior call to seedrand.  This
#	version of the routine always returns a value between 1 and 6.
#
########################################################################
# Register Usage in the Function:
#	$t0 -- a temporary register used in the calculations
#	$v0 -- the register used to hold the return value
#
########################################################################
# Algorithmic Description in Pseudocode:
#	1. Fetch the current seed value into $v0
#	2. Perform these calculations:
#		$v0 ^= $v0 << 13
#		$v0 ^= $v0 >> 17
#		$v0 ^= $v0 << 5
#	3. Save the resulting value back into the seed.
#	4. Mask the number, then get the modulus (remainder) dividing by 6.
#	5. Add 1, so the value ranges from 1 to 6
#
########################################################################
		.data
		.align 2
seed:	.word 31415			# An initial value, in case seedrand wasn't called
		.text
rand:
	lw		$v0, seed		# Fetch the seed value
	sll		$t0, $v0, 13	# Compute $v0 ^= $v0 << 13
	xor		$v0, $v0, $t0
	srl		$t0, $v0, 17	# Compute $v0 ^= $v0 >> 17
	xor		$v0, $v0, $t0
	sll		$t0, $v0, 5		# Compute $v0 ^= $v0 << 5
	xor		$v0, $v0, $t0
	sw		$v0, seed		# Save result as next seed
	andi	$v0, $v0, 0xFFFF	# Mask the number (so we know its positive)
	li		$t0, 6			# Get result mod 6, plus 1.  We get a 6 into
	div		$v0, $t0		# $t0, then do a divide.  The reminder will be
	mfhi	$v0				# in the special register, HI.  Move to $v0.
	add		$v0, $v0, 1		# Increment the value, so it goes from 1 to 6.
	jr		$ra				# Return the number in $v0
	
########################################################################
# Function Name: seedrand(int)
########################################################################
# Functional Description:
#	This routine sets the seed for the random number generator.  The
#	seed is the number passed into the routine.
#
########################################################################
# Register Usage in the Function:
#	$a0 -- the seed value being passed to the routine
#
########################################################################
seedrand:
	sw $a0, seed
	jr $ra
