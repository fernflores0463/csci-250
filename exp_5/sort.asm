#
# FILE:         $File$
# AUTHOR:       Phil White, RIT 2016
# CONTRIBUTORS:
#		W. Carithers
#		Fernando Flores Hernandez
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
# REVISION HISTORY:
#	Aug  08		- P. White, original version
#

#-------------------------------

#
# Numeric Constants
#

PRINT_STRING = 4
PRINT_INT = 1

#-------------------------------

#

# ********** BEGIN STUDENT CODE BLOCK 1 **********

#
# Make sure to add any .globl that you need here
#
.globl sort
.globl merge

# Name:         sort
# Description:  sorts an array of integers using the merge sort
#		algorithm
# 		Arguments Note: a1 and a2 specify the range inclusively
#
# Arguments:    a0:     a parameter block containing 3 values
#                       - the address of the array to sort
#                       - the address of the scrap array needed by merge
#                       - the address of the compare function to use
#                         when ordering data
#               a1:     the index of the first element in the range to sort
#               a2:     the index of the last element in the range to sort
# Returns:      none
#
sort:
        # setting stack countback ##
        addi    $sp, -16	  # We're saving 4 words to the stack (4*4bits=16)
        sw      $ra, 0($sp)	  # Save the ra so we can call back
        sw      $s0, 4($sp)	  # Save s0, the middle
        sw      $s1, 8($sp)
        sw      $s2, 12($sp)
        #save first and second params
        addi    $t0, $zero, 0
        move    $s1, $a1      # s1 = a1 (scoped)
        move    $s2, $a2      # s2 = a2 (scoped)
        # END
        addi    $s0, $zero, 2     # s0 will be used to find middle

        # start your code below this line

        # trivial cases handled here
        # case where first is more than last and if only one element
        slt     $t0, $a1, $a2     # t0 = a1 < a2
        beq     $a1, $a2, sort_done    # if a1 == a2, done
        beq     $t0, $zero, sort_done  # if first not less than last index done
        # trivial case handling done
        addi    $t1, $a2, 1       # adding 1 to last index
        add     $t1, $a1, $a2     # adding the indexes together
        div     $t1, $s0          # t1 will be used for middle
        move    $s0, $t1          # s0 = t1 the median (scoped)

        # sort left
        # a0 does not need to move, will stay the same for all intents
        move 	$a2, $s0		  # $a2 = $t1
        jal     sort
        lw      $ra, 0($sp)	# Load back the ra to call back
        lw	    $s0, 4($sp)	# Load s0-s2 back from the stack
        lw	    $s1, 8($sp)
        lw	    $s2, 12($sp)

        # sort right
        move 	$a2, $t1		  #a2 must be middle plus 1
        move 	$a3, $t1		  # $t0 = $t1
        jal     sort
        lw      $ra, 0($sp)	# Load back the ra to call back
        lw	    $s0, 4($sp)	# Load s0-s2 back from the stack
        lw	    $s1, 8($sp)
        lw	    $s2, 12($sp)

        # merge
        jal     merge

sort_done:
        jr       $ra


# ********** END STUDENT CODE BLOCK 1 **********

#
# End of Merge sort routine.
#
