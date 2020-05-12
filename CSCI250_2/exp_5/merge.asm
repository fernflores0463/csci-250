#
# FILE:         $File$
# AUTHOR:       Phil White, RIT 2016
#               
# CONTRIBUTORS:
#		Fernando Flores-Hernandez
#
# DESCRIPTION:
#	This file contains the merge function of mergesort
#

#-------------------------------

#
# Numeric Constants
#

PRINT_STRING = 4
PRINT_INT = 1


#***** BEGIN STUDENT CODE BLOCK 2 ***************************


#
# Make sure to add any .globl that you need here
#
.globl merge

#
# Name:         merge
# Description:  takes two individually sorted areas of an array and
#		merges them into a single sorted area
#
#		The two areas are defined between (inclusive)
#		area1:	low   - mid
#		area2:	mid+1 - high
#
#		Note that the area will be contiguous in the array
#
# Arguments:    a0:     a parameter block containing 3 values
#			- the address of the array to sort
#			- the address of the scrap array needed by merge
#			- the address of the compare function to use
#			  when ordering data
#               a1:     the index of the first element of the area
#               a2:     the index of the last element of the area
#               a3:     the index of the middle element of the area
# Returns:      none
# Destroys:     t0,t1
#
merge:

        sub     $t0, $a2, $a1           # Handles the trivial case of 0
        beq     $t0, $zero, ret

        addi    $sp, $sp, -28           # Store necessary stuff to stack
        sw      $ra, 0($sp)
        sw      $s0, 4($sp)
        sw      $s1, 8($sp)
        sw      $s2, 12($sp)
        sw      $s3, 16($sp)

        lw      $s0, 0($a0)      # s0 = addr of the array
        lw      $s1, 4($a0)      # s1 = addr of the scrap array
        lw      $s2, 8($a0)      # s2 = addr of the compare fn

        addi    $t0, 4           # Multiplier for array

        move    $s3, $a3         # move index of middle element to s3
        mul     $s3, $s3, $t0    # s3 = 4 * s3
        add     $s3, $s3, $s0

        move    $s4, $a2         # move index of last element to s4
        mul     $s4, $s4, $t0
        add     $s4, $s4, $s0

        move    $s5, $a1        # move index of first element
        mul     $s5, $s5, $t0
        add     $s5, $s5, $s0

        addi    $s6, $a3, 1
        add     $s6, $s6, $s6
        add     $s6, $s6, $s6
        add     $s6, $s6, $s0

        sw      $s1, 20($sp)            # Store the addr of scrap array
        sw      $s5, 24($sp)            # Store FIRST AREA START for later

my_loop:
        #addi    $t0, $zero, 0    # setting to zero for branch statements
        # TODO change register above
        sub     $t0, $s3, $s5    # diff between the area and ending of first
        sub     $t1, $s4, $s6    # diff between the area and ending of second
        add     $s7, $t0, $t1
        addi    $s7, $s7, 4     

        blt     $s7, $zero, restore

        lw      $a0, 0($s5)
        lw      $a1, 0($s6)

        blt     $t0, $zero, second_area
        blt     $t1, $zero, first_area

        jalr    $s2               # go to the cmpr fn if first and second are not empty
        beq     $v0, $zero, second_area # Act based on the result

first_area:
        sw      $a0, 0($s1)             # The value of a0 goes first
        addi    $s5, $s5, 4             # Shift FIRST AREA START (pointer)
        j       compare_done
        
second_area:
        sw      $a1, 0($s1)             # The value of a1 goes first
        addi    $s6, $s6, 4             # Shift SECOND AREA START (pointer)
        
compare_done:
        addi    $s1, $s1, 4             # Increment scrap array addr (pointer)
        j       my_loop

restore:
        lw      $s1, 20($sp)            # Restore the original scrap array addr
        lw      $s5, 24($sp)            # Restore original FIRST AREA START

copy_loop:
        sub     $t0, $s4, $s5           # Loop until FIRST AREA START >
        bltz    $t0, done_merge          #            SECOND AREA END
        lw      $t0, 0($s1)             # Load scrap array element
        sw      $t0, 0($s5)             # Store into result array
        
        addi    $s5, $s5, 4             # Increment FIRST AREA START (pointer)
        addi    $s1, $s1, 4             # Increment scrap array addr (pointer)
        j       copy_loop

done_merge:
        lw      $ra, 0($sp)
        lw      $s0, 4($sp)
        lw      $s1, 8($sp)
        lw      $s2, 12($sp)
        lw      $s3, 16($sp)
        addi    $sp, $sp, 28
ret:
        jr      $ra

# ********** END STUDENT CODE BLOCK 2 **********

#
# End of Merge routine.
#
