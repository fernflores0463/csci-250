#
# FILE:         $File$
# AUTHOR:       Phil White, RIT 2016
#               
# CONTRIBUTORS:
#		Fernando Flores
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
        # set a register to 4 to multiply
        addi    $t0, $zero, 4
        addi    $t6, $zero, 0
        # multiply indexes will be used for stuff
        mult    $a1, $t0     # first/ left (l)
        mflo    $t1
        mult    $a2, $t0     # last/ right (r)
        mflo    $t2
        mult    $a3, $t0     # middle (m)
        mflo    $t3
        # iterate through the array
        sub     $t4, $t2, $t3 # n2 = t4 = r - m
        addi    $t5, $t3, -4  # n1 = t5 = m - 1 + l (might fail) (only m-1 is done on this line)
        add     $t5, $t5, $t1 # n1 = t5 = m - 1 + l (might fail)
        # add to temp lists using n1 and n2 as bounds
        addi    $t0, $zero, 1

        lw      $t1, 8($a0)     # address to the compare function
        lw      $t7, 4($a0)     # pointer to begin of scrap array
        lw      $t8, 0($a0)     # pointer to begin of array


        #loop "while i is less than n1"
        add     $t2, $t7, $t1   # add to point to the correct "begin" element
        add     $t3, $t7, $t2   # add to point to the correct "end" element
        jalr     $t1
        # use v0, the returned value for the comparison
        beq    $v0, $t0, put_in_scrap

        
        
        
        jal		loop1				# jump to target and save position to $ra

put_in_scrap:
        

#this loop if for n1
loop1:
        beq     $t5, $t6, done
        sw		$t8, 0($t7)	   # store a value into t7
        addi    $t7, 4         # next element in scrap array
        addi    $t6, 4         # increment counter by 4

done:


        


# ********** END STUDENT CODE BLOCK 2 **********

#
# End of Merge routine.
#
