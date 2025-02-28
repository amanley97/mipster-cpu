
caller:		addi 	$a0, $zero, 15		# initialize argument register $a0 with n = 15
		#addi	$a1, $zero, 0x1001000C	# intialize argument register $a1 with the starting address
		lui	$a1, 0x1001		# intialize argument register $a1 with upper part of the starting address
		ori	$a1, 0x000C		# intialize argument register $a1 with lower part of the starting address
		jal	fib_seq			# call fib_seq
next:		j	next

##############################################################################
# This routine generates Fibonacci sequence fib(0), fib(1), fib(2), ... fib(n)
# and stores it into the data segment starting at memory address 0x1001000C
# which is pointed at by register $a1

fib_seq:	addi	$sp, $sp, -24 		# make room on stack
		sw 	$ra, 20($sp) 		# push $ra
		sw 	$a1, 16($sp) 		# push $a1
		sw 	$a0, 12($sp) 		# push $a0 (N)
		sw 	$t0,  8($sp) 		# push $t0
		sw 	$t1,  4($sp) 		# push $t1
		sw 	$t2,  0($sp) 		# push $t2
		
		addi	$t2, $zero, 0		# intialize register with fib(0)
		sw	$t2, 0($a1)		# store fib(0) to memory
		addi	$a1, $a1, 4		# next location address
		beq	$a0, $zero, done	# are we done?
		addi	$t1, $zero, 1		# intialize register with fib(1)
		sw	$t1, 0($a1)		# store fib(1) to memory
		addi	$a1, $a1, 4		# next location address
		addi 	$a0, $a0, -1 		# n = n-1
		beq	$a0, $zero, done	# are we done?
		
loop:		add	$t0, $t1, $t2		# fib(i) = fib(i-1)+fib(i-2)
		add	$t2, $t1, $zero		# fib(i-2) = fib(i-1)
		add	$t1, $t0, $zero		# fib(i-1) = fib(i)
		sw	$t0, 0($a1)		# store fib(i) to memory
		addi	$a1, $a1, 4		# next location address
		addi 	$a0, $a0, -1 		# n = n-1
		bne	$a0, $zero, loop	# loop if not done (i.e. n != 0) 
		
done:		lw 	$t2,  0($sp) 		# pop $t2
		lw 	$t1,  4($sp) 		# pop $t1
		lw 	$t0,  8($sp) 		# pop $t0
 		lw 	$a0, 12($sp) 		# pop $a0
		lw 	$a1, 16($sp) 		# pop $a1
		lw 	$ra, 20($sp) 		# pop $ra
		addi 	$sp, $sp, 24 		# restore sp
		jr 	$ra
##############################################################################

exit:		
