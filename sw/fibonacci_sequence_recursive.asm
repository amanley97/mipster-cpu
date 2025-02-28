
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

fib_seq:	addi	$sp, $sp, -16 		# make room on stack
		sw 	$ra, 12($sp) 		# push $ra
		sw 	$a1,  8($sp) 		# push $a1
		sw 	$a0,  4($sp) 		# push $a0 (N)
		sw 	$t0,  0($sp) 		# push $t0

		add	$t0, $a0, $0		# copy N to $t0
		add	$a0, $0, $0		# i = 0
start_fib:	jal	fib
		sw	$v0, 0($a1)		# store fib(i) to memory
		addi	$a0, $a0, 1		# i = i + 1
		addi	$a1, $a1, 4		# next location address
		slt	$at, $t0, $a0
		beq	$at, $0, start_fib	# calculate Fib(i+1) when i < N

done:		lw 	$t0,  0($sp) 		# pop $t0
 		lw 	$a0,  4($sp) 		# pop $a0
		lw 	$a1,  8($sp) 		# pop $a1
		lw 	$ra, 12($sp) 		# pop $ra
		addi 	$sp, $sp, 16 		# restore sp
		jr 	$ra
##############################################################################

##############################################################################
# This routine recursively generates the nth Fibonacci number fib(n) and 
# returns it into register $v0
fib:		addi 	$sp, $sp, -20		# make room on stack
		sw 	$ra, 16($sp) 		# push $ra
		sw 	$at, 12($sp) 		# push $at
		sw 	$s0,  8($sp)		# push $s0
		sw 	$a0,  4($sp)		# push $a0 (N)
		sw 	$t0,  0($sp)		# push $t0
		
		slt	$at,  $0, $a0
		bne	$at,  $0, test2		# if n>0, test if n=1
		add 	$v0, $0, $0 		# else fib(0) = 0
		j 	rtn 			#

test2: 		addi 	$t0, $0, 1 		# test if n=1
		bne 	$t0, $a0, gen 		# if n>1, gen
		add 	$v0, $0, $t0 		# else fib(1) = 1
		j 	rtn

gen: 		addi 	$a0, $a0, -1 		# n-1
		jal 	fib 			# call fib(n-1)
		add 	$s0, $v0, $0 		# copy fib(n-1)
		addi 	$a0, $a0, -1 		# n-2
		jal 	fib 			# call fib(n-2)
		add 	$v0, $v0, $s0 		# fib(n-1)+fib(n-2)

rtn: 		lw 	$t0,  0($sp)		# pop $t0
		lw 	$a0,  4($sp)		# pop $a0
		lw 	$s0,  8($sp) 		# pop $s0
		lw 	$at, 12($sp) 		# pop $at
		lw 	$ra, 16($sp) 		# pop $ra
		addi 	$sp, $sp, 20		# restore sp
		jr 	$ra
##############################################################################

exit:		
