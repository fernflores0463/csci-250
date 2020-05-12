#
# FILE:         $File$
# AUTHOR:       Phil White, RIT 2016
# CONTRIBUTORS:
#		W. Carithers
#		<<<YOUR NAME HERE>>>
#
# DESCRIPTION:
#	This program is an implementation of merge sort in MIPS
#	assembly 
#
# ARGUMENTS:
#	None
#
# INPUT:
# 	The numbers to be sorted.  The user will enter a 9999 to
#	represent the end of the data
#
# OUTPUT:
#	A "before" line with the numbers in the order they were
#	entered, and an "after" line with the same numbers sorted.
#
#
# REVISION HISTORY:
#	Jan  2017	- P. White, added more/better merge tests 
#	Aug  2016	- P. White, Initial version of merge sort exp.
#

#-------------------------------

#
# Numeric Constants
#

MAX_NUMBERS = 20
STOP_INPUT = 9999
PRINT_STRING = 4
READ_INT = 5
PRINT_INT = 1

#
# DATA AREAS
#
	.data
	.align	2		# word data must be on word boundaries

parm_block:	
	.word	array		# the address of the array to sort
	.word	scratch		# temp storage needed by merge
	.word	compare		# the comparison function to use

parm_block2:	
	.word	arr_copy	# the address of the array to sort
	.word	scratch		# temp storage needed by merge
	.word	compare2	# the comparison function to use


parm_merge:
	.word	arr_merge1
	.word	scratch
	.word	compare

array:	
	.word	-1,-2,-5,-6,-9,-0,-7,-8,-3,-4
	.word	-11,-12,-15,-16,-19,-10,-17,-18,-13,-14
scratch:
	.word	 1, 2, 5, 6, 9, 0, 7, 8, 3, 4
	.word	11,12,15,16,19,10,17,18,13,14

arr_copy:	
	.word	-1,-2,-5,-6,-9,-0,-7,-8,-3,-4
	.word	-11,-12,-15,-16,-19,-10,-17,-18,-13,-14


arr_merge1:
	.word	2, 4, 6, 1, 3, 5

arr_merge2:
	.word	24, 25, 26, 21, 22, 23

arr_merge3:
	.word	41, 42, 43, 44, 45, 46

arr_merge3r1:
	.word	85, 86, 87, 88, 32, 34, 31, 33

arr_merge3l1:
	.word	15, 18, 16, 17, 81, 82, 83, 84

arr_merge3m1:
	.word	91, 92, 93, 94, 111, 116, 110, 113 
	.word	95, 94,	95, 99, 96, 98, 97, 92


	.align	0		# string data doesn't have to be aligned
space:	
	.asciiz	" "
pound:	
	.asciiz	"#"
dollar:	
	.asciiz	"$"
newline:
	.asciiz	"\n"
before:	
	.asciiz	"Before: "
after:	
	.asciiz	"After : "
prompt:	
	.asciiz	"Begin Entering Numbers, enter 9999 to quit:\n"

in_order_text:
	.asciiz "In Order\n"

rev_order_text:
	.asciiz "Reverse Order\n"


merge_header_text:
	.asciiz "Merge Tests\n"

merge_done_text:
	.asciiz "Merge Tests Done\n"

merge_test_mid:
	.asciiz "Merge called only on middle:\n"

merge_test_left:
	.asciiz "Merge called only on the left half:\n"

merge_test_right:
	.asciiz "Merge called only on the right half:\n"

#-------------------------------

#
# CODE AREAS
#
	.text			# this is program code
	.align	2		# instructions must be on word boundaries

	.globl	main		# main is a global label
	.globl	sort		# the extewrnal sort routine
	.globl	merge		# the extewrnal merge routine

#
# EXECUTION BEGINS HERE
#
main:
	addi	$sp,$sp,-12	# allocate space for the return address
	sw	$ra,8($sp)	# store the ra on the stack
	sw	$s7,4($sp)	# store the ra on the stack
	sw	$s6,0($sp)	# store the ra on the stack


	jal	merge_test

no_merge_test:
	la	$a0,array	# set up to read in an array of ints
	li	$a1,MAX_NUMBERS	# and put them at label array
	jal	readarray
	move	$s7,$v0		# save the number of numbers read in

	la	$a0,array
	la	$a1,arr_copy
	move	$a2,$s7
	jal	copyarray


	li	$v0,4
	la	$a0,rev_order_text
	syscall

	la	$a0,parm_block2	# set up for call to sort
	move	$a1,$s7		# the number of elements
	jal	run_test	# run the test

	li	$v0,4
	la	$a0,newline
	syscall			# print a newline


	li	$v0,4
	la	$a0,in_order_text
	syscall

	la	$a0,parm_block	# set up for call to sort
	move	$a1,$s7		# the number of elements
	jal	run_test	# run the test

	li	$v0,4
	la	$a0,newline
	syscall			# print a newline

main_done:
	lw	$s6,0($sp)
	lw	$s7,4($sp)
	lw	$ra,8($sp)	# restore the ra
	addi	$sp,$sp,12	# deallocate stack space
	jr	$ra		# return from main and exit spim

#-------------------------------

#
# Name:		run_test
# Description:	run a test of the merge sort algorithm
# Arguments:    a0:     a parameter block containing 3 values
#                       - the address of the array to sort
#                       - the address of the scrap array needed by merge
#                       - the address of the compare function to use
#                         when ordering data
#               a1:     the number of elements
# Returns:      none
# Destroys:     none
#

run_test:
        addi    $sp,$sp,-20
        sw      $ra,16($sp)
        sw      $s3,12($sp)
        sw      $s2, 8($sp)
        sw      $s1, 4($sp)
        sw      $s0, 0($sp)

	move 	$s0,$a0		# s0 is the &param block
	move 	$s1,$a1		# the number of elements
	lw	$s3,0($s0)	# get the address of the array
	
	li	$v0,PRINT_STRING
	la	$a0,before
	syscall			# print the before message

	move	$a0,$s3	
	move	$a1,$s1
	jal	parray

	move	$a0,$s0		# set up for call to sort
	li	$a1,0		# lo the index of the first element
	addi	$a2,$s1,-1	# hi is index of last element
	jal	sort		# go sort em

	li	$v0,PRINT_STRING
	la	$a0,after
	syscall			# print the after message

	move	$a0,$s3		# print the array again (now sorted)
	move	$a1,$s1
	jal	parray


        lw      $ra,16($sp)
        lw      $s3,12($sp)
        lw      $s2, 8($sp)
        lw      $s1, 4($sp)
        lw      $s0, 0($sp)
        addi    $sp,$sp,20     # sort
        jr      $ra

#-------------------------------

#
# Name:		parray
# Description:	printarray prints an array of integers
# Arguments:    a0: 	the address of the array
#   		a1: 	the number of elements in the array
# Returns:      none
# Destroys:     t0,t1
#

parray:
	li	$t0,0		# i=0;
	move	$t1,$a0		# t1 is pointer to array
pa_loop:
	beq	$t0,$a1,pa_done	# done if i==n

	lw	$a0,0($t1)	# get a[i]
	li	$v0,PRINT_INT
	syscall			# print one int

	li	$v0,PRINT_STRING
	la	$a0,space
	syscall			# print a space

	addi	$t1,$t1,4	# update pointer
	addi	$t0,$t0,1	# and count
	j	pa_loop
pa_done:
	li	$v0,4
	la	$a0,newline
	syscall			# print a newline

	jr	$ra

#-------------------------------

# Name:		readarray
# Description:	reads in an array of integers
# Arguments:	a0:	the address of the array
# 		a1:	the max number of elements in the array
# Returns:      none
# Destroys:     t0,t1,t2
#

readarray:
	li	$t0,0		# i=0;
	li	$t2,STOP_INPUT	# if equal to $t2, then stop
	move	$t1,$a0		# t1 is pointer to array

	li	$v0,PRINT_STRING
	la	$a0,prompt
	syscall			# print one int

ra_loop:
	beq	$t0,$a1,ra_done	# done if i==n

	li	$v0,READ_INT
	syscall
	beq	$v0,$t2,ra_done	# done if i==n
	sw	$v0,0($t1)

	addi	$t1,$t1,4	# update pointer
	addi	$t0,$t0,1	# and count
	j	ra_loop
ra_done:
	li	$v0,PRINT_STRING
	la	$a0,newline
	syscall			# print a message

	move	$v0,$t0
	jr	$ra

#-------------------------------

#
# Name:		copyarray
# Description:	copyarray copies an array of integers
# Arguments:    a0: 	the address of the source array
#   		a1: 	the address of the destination array
#   		a2: 	the number of elements in the array
# Returns:      none
# Destroys:     t0,t1
#

copyarray:
	li	$t0,0		# i=0;
ca_loop:
	beq	$t0,$a2,ca_done	# done if i==n

	lw	$t1,0($a0)	# read from a[i]
	sw	$t1,0($a1)	# write to  b[i]

	addi	$a0,$a0,4	# update src pointer
	addi	$a1,$a1,4	# update dst pointer
	addi	$t0,$t0,1	# and count
	j	ca_loop
ca_done:

	jr	$ra

#-------------------------------

# Name:		run_merge
# Description:	This function tests the merge function independent
#		of the sort function.  It is used for testing
# params:       a0: the array of data to merge
#		a1: the first index
#		a2: the last index
#		a3: the size of array
# returns:      none
# Destroys:	t0, 
run_merge:
	addi	$sp, $sp, -20
	sw	$ra,16($sp)
	sw	$s3,12($sp)
	sw	$s2, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)

	move	$s0, $a0		# s0 is addr array
	move	$s1, $a1		# s1 is first index
	add	$t0, $a1, $a2
	div	$s2, $t0, 2		# s2 is mid
	move	$s3, $a3		# s3 is size of array

        li      $v0,PRINT_STRING
        la      $a0,before
        syscall

	move	$a0, $s0
	move	$a1, $s3
	jal 	parray

	la	$a0, parm_merge
	sw	$s0, 0($a0)
	move	$a1, $s1		# s1 is first index
	move	$a3, $s2		# set up mid
	jal	merge

        li      $v0,PRINT_STRING
        la      $a0,after
        syscall

	move	$a0, $s0
	move	$a1, $s3
	jal 	parray

	lw	$ra,16($sp)
	lw	$s3,12($sp)
	lw	$s2, 8($sp)
	lw	$s1, 4($sp)
	lw	$s0, 0($sp)
	addi	$sp, $sp, 20
	jr	$ra

#-------------------------------

# Name:		merge_test
# Description:	This function tests the merge function independent
#		of the sort function.  It is used for testing
# params:       none
# returns:      none
# Destroys:	t0, 
merge_test:
	addi	$sp, $sp, -4
	sw	$ra, 0($sp)

        li      $v0,PRINT_STRING
        la      $a0,merge_header_text
        syscall

	la	$a0, arr_merge1
	li	$a1, 0
	li	$a2, 5
	li	$a3, 6
	jal	run_merge
        li      $v0,PRINT_STRING
        la      $a0,newline
        syscall

	la	$a0, arr_merge2
	li	$a1, 0
	li	$a2, 5
	li	$a3, 6
	jal	run_merge
        li      $v0,PRINT_STRING
        la      $a0,newline
        syscall

	la	$a0, arr_merge3
	li	$a1, 0
	li	$a2, 5
	li	$a3, 6
	jal	run_merge
        li      $v0,PRINT_STRING
        la      $a0,newline
        syscall

        li      $v0,PRINT_STRING
        la      $a0,merge_test_right
        syscall

        la      $a0, arr_merge3r1
        li      $a1, 4
        li      $a2, 7
        li      $a3, 8
        jal     run_merge
        li      $v0,PRINT_STRING
        la      $a0,newline
        syscall

        li      $v0,PRINT_STRING
        la      $a0,merge_test_left
        syscall

        la      $a0, arr_merge3l1
        li      $a1, 0
        li      $a2, 3
        li      $a3, 8
        jal     run_merge
        li      $v0,PRINT_STRING
        la      $a0,newline
        syscall

        li      $v0,PRINT_STRING
        la      $a0,merge_test_mid
        syscall

        la      $a0, arr_merge3m1
        li      $a1, 4
        li      $a2, 7
        li      $a3, 16
        jal     run_merge
        li      $v0,PRINT_STRING
        la      $a0,newline
        syscall


        li      $v0,PRINT_STRING
        la      $a0,merge_done_text
        syscall

	lw	$ra, 0($sp)
	addi	$sp, $sp, 4
	jr	$ra

#-------------------------------

# compare function to compare 2 values
# params:	a0	the 1st value
# 		a1	the 2nd value
# returns:	v0	1 	if 1st val < 2nd val
#			0 	othewise
compare:

	slt	$v0,$a0,$a1
	
        jr      $ra

#-------------------------------

# compare2 function to compare 2 values in reverse order
# params:	a0	the 1st value
# 		a1	the 2nd value
# returns:	v0	1 	if 2nd val < 1st val
#			0 	othewise
compare2:

	slt	$v0,$a1,$a0
	
        jr      $ra


#
# End of Mergesort program.
#
