# File:		add_ascii_numbers.asm
# Author:	K. Reek
# Contributors:	P. White, W. Carithers
#		Fernando Flores-Hernandez
#
# Updates:
#		3/2004	M. Reek, named constants
#		10/2007 W. Carithers, alignment
#		09/2009 W. Carithers, separate assembly
#
# Description:	Add two ASCII numbers and store the result in ASCII.
#
# Arguments:	a0: address of parameter block.  The block consists of
#		four words that contain (in this order):
#
#			address of first input string
#			address of second input string
#			address where result should be stored
#			length of the strings and result buffer
#
#		(There is actually other data after this in the
#		parameter block, but it is not relevant to this routine.)
#
# Returns:	The result of the addition, in the buffer specified by
#		the parameter block.
#

	.globl	add_ascii_numbers

add_ascii_numbers:
A_FRAMESIZE = 40

#
# Save registers ra and s0 - s7 on the stack.
#
	addi 	$sp, $sp, -A_FRAMESIZE
	sw 	$ra, -4+A_FRAMESIZE($sp)
	sw 	$s7, 28($sp)
	sw 	$s6, 24($sp)
	sw 	$s5, 20($sp)
	sw 	$s4, 16($sp)
	sw 	$s3, 12($sp)
	sw 	$s2, 8($sp)
	sw 	$s1, 4($sp)
	sw 	$s0, 0($sp)
	
# ##### BEGIN STUDENT CODE BLOCK 1 #####

        lw      $s0, 0($a0)        # first input string
        lw      $s1, 4($a0)        # second input string
        lw      $s2, 8($a0)        # where the result will be stored
        lw      $s3, 12($a0)       # length of the strings

        add     $s5, $zero, $zero
        li      $s7, 57            # 9 in ascii

add_ascii:
        beq     $zero, $s3, done    # end iteration once we've exhausted len of string
        addi    $s3, $s3, -1       # s3 = (len of string) - 1

        add     $t0, $s0, $s3      # t0 = 1st input addr + last index of string
        add	$t1, $s1, $s3      # t1 = 2nd input addr + last index of string

        lb      $t2, 0($t0)        # get char at t0
        lb      $t3, 0($t1)        # get char at t1

        add     $t4, $t2, $t3
        add     $t4, $t4, $s5
        addi    $t4, $t4, -48      # 0 in ascii

        slt     $t5, $s7, $t4      # if res < 48 ()
        beq     $t5, $zero, skip_carry
        addi    $t4, $t4, -10      # subtract res
        li      $s5, 1             # carry
        j       sum_val_and_stor
skip_carry:
        li    $s5, 0               # don't carry
sum_val_and_stor:
        add     $t7, $s2, $s3
        sb      $t4, 0($t7)
        j       add_ascii
done:
# ###### END STUDENT CODE BLOCK 1 ######

#
# Restore registers ra and s0 - s7 from the stack.
#
	lw 	$ra, -4+A_FRAMESIZE($sp)
	lw 	$s7, 28($sp)
	lw 	$s6, 24($sp)
	lw 	$s5, 20($sp)
	lw 	$s4, 16($sp)
	lw 	$s3, 12($sp)
	lw 	$s2, 8($sp)
	lw 	$s1, 4($sp)
	lw 	$s0, 0($sp)
	addi 	$sp, $sp, A_FRAMESIZE

	jr	$ra			# Return to the caller.
