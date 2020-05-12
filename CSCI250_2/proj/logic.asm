TREE   = 116
BURN   = 66
PERIOD = 46
EAST   = 69
WEST   = 87
NORTH  = 78
SOUTH  = 83
INDICATOR = 105

        .globl burning_case
        .globl tree_case
        .globl main
        .globl  game_board
        .globl  game_board_cpy
        .globl  create_board_header
        .globl  input_buffer
        .globl  gen_header
        .globl  indicator_case
        .globl  size

#
# Name:         burning_case
#
# Description:  Analyzes the case where the current char is 'B'.
#               modifies gameboard_cpy with results of analysis
# Arguments:    $a0 - addr. of curr. position on board being analyzed
#               $a1 - addr. of curr. position on board with solution
#               $a2 - Wind direction (IRRELEVANT MAYBE)
#               $a3 - offset (IRRELEVANT MAYBE)
# Returns:      
# Destroys:     
#
burning_case:
        addi	$sp,$sp,-24	# allocate space for the return address
	sw	$ra,20($sp)	# store the ra on the stack
	sw	$s0,16($sp)	# store the ra on the stack
	sw	$s1,12($sp)	# store the ra on the stack
        sw      $s2,8($sp) 
        sw      $s3,4($sp) 
        sw      $s4,0($sp) 

burning_case_body:
        move    $s0, $a0        # addr of analyzed
        move    $s1, $a1        # addr of solution
        move    $v0, $a0
        move    $v1, $a1

        li      $t0, PERIOD
        sb      $t0, 0($s1)

        move    $t5, $a0        # addr of analyzed
        move    $t6, $a1        # addr of solution

        li      $s2, TREE       # Searching for trees to burn down
        li      $s3, BURN       # Replacing with burning trees :(

        move    $a0, $s0
        move    $a1, $s1
        move    $a2, $s2
        move    $a3, $s3
        jal     go_south

        move    $a0, $t5
        move    $a1, $t6
        jal     go_north

        move    $a0, $t5
        move    $a1, $t6
        jal     go_west

        move    $a0, $t5
        move    $a1, $t6
        jal     go_east

        #################
        li      $a2, TREE       # Searching for trees to burn down
        li      $a3, INDICATOR       # Replacing with indicator
        move    $a0, $t5
        move    $a1, $t5
        jal     go_east

        move    $a0, $t5
        move    $a1, $t5
        jal     go_south

burning_case_end:
        lw      $s4,0($sp)
        lw      $s3,4($sp)
        lw      $s2,8($sp) 
        lw	$s1,12($sp)
	lw	$s0,16($sp)
	lw	$ra,20($sp)	# restore the ra
	addi	$sp,$sp,24	# deallocate stack space
        
        jr $ra


        # look in all directions for 't'
        #       if 't' found:
        #               mark equivalent pos. in sol board with 'B'
        # finally mark equiv. curr. pos. in sol. board as '.'


#
# Name:         tree_case
#
# Description:  Analyzes the case where the current char is 'B'.
#               modifies gameboard_cpy with results of analysis
# Arguments:    $a0 - addr. of curr. position on board being analyzed 
#               $a1 - addr. of curr. position on board with solution
#               $a2 - WIND_DIRECTION
#
# Returns:      
# Destroys:     
#
indicator_case:
tree_case:
        addi	$sp,$sp,-20	# allocate space for the return address
	sw	$ra,16($sp)	# store the ra on the stack
	sw	$s0,12($sp)	# store the ra on the stack
	sw	$s1,8($sp)	# store the ra on the stack
        sw      $s2,4($sp) 
        sw      $s3,0($sp) 

        move    $s0, $a0
        move    $s1, $a1
        move    $s2, $a2

        lb      $t0, 0($s0)
        li      $t1, INDICATOR

        beq     $t0, $t1, replace_inidicator
        li      $t0, TREE
        sb      $t0, 0($s1)
        j       skip_replace
replace_inidicator:
        li      $t0, BURN
        sb      $t0, 0($s1)
skip_replace:
        #move   $a0, $s2
        #li     $v0, 11
        #syscall

        li      $t0, EAST
        li      $t1, WEST
        li      $t2, SOUTH
        li      $t3, NORTH

        li      $a2, PERIOD
        li      $a3, TREE
        beq     $s2, $t0, east
        beq     $s2, $t1, west
        beq     $s2, $t2, south
        beq     $s2, $t3, north
east:
        jal go_east
        j tree_case_end
west:
        #jal go_west
        j tree_case_end
south:
        jal go_south
        j tree_case_end
north:
        jal go_north
        j tree_case_end
tree_case_end:
        lw      $s3,0($sp)
        lw      $s2,4($sp) 
        lw	$s1,8($sp)
	lw	$s0,12($sp)
	lw	$ra,16($sp)	# restore the ra
	addi	$sp,$sp,20	# deallocate stack space
        
        jr $ra

#
# a0 - board being analyzed
# a1 - solution board
# a2 - character being searched for
# a3 - character replacement
go_south:
        #addi	$sp,$sp,-8	# allocate space for the return address
	#sw	$ra,4($sp)	# store the ra on the stack
	#sw	$s0,0($sp)	# store the ra on the stack
        la      $t0, size
        lw      $t0, 0($t0)
        addi    $t0, $t0, 3

        move    $s0, $a0
        move    $s1, $a1
        add     $s0, $s0, $t0
        add     $s1, $s1, $t0
        lb      $t0, 0($s0)

        bne     $t0, $a2, go_south_skip # skip putting on sol board if it's not what we're looking for
        sb      $a3, 0($s1)     # replace on solution board
go_south_skip:
	#lw	$s0,0($sp)
	#lw	$ra,4($sp)	# restore the ra
	#addi	$sp,$sp,-8
        jr      $ra


#
# a0 - board being analyzed
# a1 - solution board
# a2 - character being searched for
# a3 - character replacement
go_north:
        la      $t0, size
        lw      $t0, 0($t0)

        li      $t1, -1
        mul     $t0, $t0, $t1  
        addi    $t0, $t0, -3

        move    $s0, $a0
        move    $s1, $a1
        add    $s0, $s0, $t0
        add    $s1, $s1, $t0
        lb      $t0, 0($s0)

        bne     $t0, $a2, go_north_skip # skip putting on sol board if it's not what we're looking for
        sb      $a3, 0($s1)     # replace on solution board
go_north_skip:
        jr      $ra

#
# a0 - board being analyzed
# a1 - solution board
# a2 - character being searched for
# a3 - character replacement
go_east:
        move    $s0, $a0
        move    $s1, $a1
        addi    $s0, $s0, 1
        addi    $s1, $s1, 1
        lb      $t0, 0($s0)

        bne     $t0, $a2, go_east_skip # skip putting on sol board if it's not what we're looking for
        sb      $a3, 0($s1)     # replace on solution board
go_east_skip:

        jr      $ra

#
# a0 - board being analyzed
# a1 - solution board
# a2 - character being searched for
# a3 - character replacement
go_west:
        # addi	$sp,$sp,-8	# allocate space for the return address
	# sw	$ra,4($sp)	# store the ra on the stack
	# sw	$s0,0($sp)	# store the ra on the stack

        move    $s0, $a0
        move    $s1, $a1
        addi    $s0, $s0, -1
        addi    $s1, $s1, -1
        lb      $t0, 0($s0)

        bne     $t0, $a2, go_west_skip # skip putting on sol board if it's not what we're looking for
        sb      $a3, 0($s1)     # replace on solution board
go_west_skip:
	# lw	$s0,0($sp)
	# lw	$ra,4($sp)	# restore the ra
	# addi	$sp,$sp,-8
        jr      $ra

