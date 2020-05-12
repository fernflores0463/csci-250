
PRINT_STRING = 4		# arg for syscall to tell it to write
SPACE_CHAR   = 32
NEWLINE      = 10
PIPE         = 124
PLUS_SIGN    = 43
HYPHEN       = 45
P1_CHAR      = 88
P2_CHAR      = 79
PERIOD       = 46
TREE   = 116
BURN   = 66
INDICATOR = 105
EAST   = 69
WEST   = 87
NORTH  = 78
SOUTH  = 83

.data
welcome_msg:
        .ascii   "+-------------+"
        .ascii   "\n| FOREST FIRE |"
        .asciiz  "\n+-------------+\n\n"

gen_header:
        .asciiz  "==== #0 ====\n"

gen_half_1:
        .asciiz  "==== #"
gen_half_2:
        .asciiz  " ====\n"

grid_error:
        .asciiz  "ERROR: invalid grid size\n"
gen_error:
        .asciiz  "ERROR: invalid number of generations\n"
wind_error:
        .asciiz  "ERROR: invalid wind direction\n"
char_error:
        .asciiz  "ERROR: invalid character in grid\n"

input_buffer:
        .space  100
        
game_board:
        .space  100
        .space  100
        .space  100

game_board_cpy:
        .space  100
        .space  100
        .space  100

size:   .word   1

        .text
        .align	2
        .globl	main
        .globl  game_board
        .globl  game_board_cpy
        .globl  create_board_header
        .globl  input_buffer
        .globl  gen_header
        .globl  burning_case
        .globl  tree_case
        .globl  indicator_case
        .globl  size
        .globl  char_error

#
# Name:         main
#
# Description:  EXECUTION BEGINS HERE
# Arguments:    none
# Returns:      none
# Destroys:     
#

main:
        # print welcome message and the initial board           
        
        la      $a0, welcome_msg
        jal     print_string

        # read Grid Length
        li      $v0, 5
        syscall
        move    $s0, $v0             # s0 = GRID_SIZE
        la      $t0, size
        sw      $s0, 0($t0)

        la      $a0, grid_error
        li      $t0, 4
        slt     $t1, $s0, $t0
        bne     $t1, $zero, print_error
        li      $t0, 30
        sgt     $t1, $s0, $t0
        bne     $t1, $zero, print_error

        # read num of Generations
        li      $v0, 5
        syscall
        move    $s1, $v0             #  s1 = GENERATIONS

        la      $a0, gen_error
        li      $t0, 0
        slt     $t1, $s1, $t0
        bne     $t1, $zero, print_error
        li      $t0, 20
        sgt     $t1, $s1, $t0
        bne     $t1, $zero, print_error

        # read Wind Direction
        la      $a0, input_buffer    # a0 = &game_board
        li      $a1, 3               # read 1 chars
        li      $v0, 8
        syscall
        la      $a0, input_buffer
        lb      $s2, 0($a0)          # s2 = WIND_DIRECTION

        la      $a0, wind_error
        li      $t0, NORTH
        beq     $t0, $s2, skip_error
        li      $t0, SOUTH
        beq     $t0, $s2, skip_error
        li      $t0, EAST
        beq     $t0, $s2, skip_error
        li      $t0, WEST
        beq     $t0, $s2, skip_error
        j       print_error
skip_error:
        # read the actual grid (need a loop to actually read it)
        la      $a0, input_buffer      # a0 = &game_board
        move    $a1, $s0               # read amount chars
        jal     create_board_header

        ########   DONE PROCESSING INPUT ##################

         # Print the header for the first generation

        la     $a0, gen_header
        jal    print_string


        # print welcome message and the initial board           

        la      $a0, game_board
        jal     print_string

        ###########   DONE WITH GEN 0 ###################

        move    $a0, $s1    # a0 = GENERATIONS
        move    $a1, $s0    # a1 = GRID_SIZE
        move    $a2, $s2    # a2 = WIND_DIRECTION
        jal     start_sim

        j exit_prog

#
# Name:         start_sim
#
# Description:  EXECUTION BEGINS HERE
# Arguments:    $a0 - num of generations
#               $a1 - Length of the grid
#               $a2 - Wind direction
# Returns:      
# Destroys:     
#
start_sim:
        addi	$sp,$sp,-16	# allocate space for the return address
        sw	$ra,12($sp)	# store the ra on the stack
        sw	$s0,8($sp)	# store the ra on the stack
        sw	$s1,4($sp)	# store the ra on the stack
        sw      $s2,0($sp) 
        #########################
        move    $s0, $a0
        move    $s2, $a1
        li      $s1, 1
        li      $s5, 1
        
sim_loop:
        li      $t0, 2
        div     $s0, $t0
        mfhi    $t0            # gets s1 % s2 to figure out what board to analyze
        bne     $t0, $zero, skip
        la      $s3, game_board_cpy # set to GEN - 1
        la      $s4, game_board
        j       set
skip:
        la      $s3, game_board     # set to GEN - 1 
        la      $s4, game_board_cpy
set:
        move    $a0, $s3      # setting parameter so that the game board can be analyzed
        move    $a3, $s4
        # call set to begin here
        jal     set_to_begin
        la      $a0, gen_half_1
        jal     print_string
        li      $v0, 1
        move    $a0, $s5
        syscall
        la      $a0, gen_half_2
        jal     print_string
        move    $a0, $s4
        jal     print_string
        move    $a0, $s3
        move    $a1, $s2
        jal     clear_board
        addi    $s0, $s0, -1
        addi    $s5, $s5, 1
        bne     $s0, $zero, sim_loop
end_sim:
        #########################
        lw      $s2,0($sp) 
        lw	$s1,4($sp)
        lw	$s0,8($sp)
        lw	$ra,12($sp)	# restore the ra
        addi	$sp,$sp,16	# deallocate stack space
        jr $ra

#
# Name:         set_to_begin
#
# Description:  EXECUTION BEGINS HERE
# Arguments:    $a0 - addr. of gameboard that will be analyzed
#               $a1 - Length of the grid
#               $a2 - Wind direction
#               $a3 - addr. of gameboard with result
# Returns:      $v0 - the solution to the puzzle for this generation
# Destroys:     
#
set_to_begin:
        addi	$sp,$sp,-28	# allocate space for the return address
        sw	$ra,24($sp)	# store the ra on the stack
        sw	$s0,20($sp)	# store the ra on the stack
        sw	$s1,16($sp)	# store the ra on the stack
        sw      $s2,12($sp) 
        sw      $s3,8($sp)
        sw      $s4,4($sp)
        sw      $s5,0($sp)

        move    $s0, $a0       # addr of gameboards
        move    $s1, $a1       # counter for rows
        move    $s4, $a1       
        move    $s3, $a3       # addr of gameboard sol.
        addi    $t0, $s1, 4    # t0 = spaces needed to get to the beginnning of board

        add     $s0, $s0, $t0  # s0 = pointer at the beginning of board
        add     $s3, $s3, $t0  # s0 = pointer at the beginning of board
        
reset_col_counter:
        move    $s2, $s4
read_cols:
        lb      $t3, 0($s0)    # load current character

        move    $a0, $s0
        move   $a1, $s3
        #li      $v0, 11
        #syscall
        li      $t1, TREE
        li      $t2, BURN
        li      $s5, INDICATOR
        beq     $t3, $t1, tree_fun
        beq     $t3, $t2, burn_fun
        beq     $t3, $s5, inidic_fun
        li      $t1, PERIOD
        la      $a0, char_error
        bne     $t1, $t3, print_error
done_check:
        # check the char here & do logic
        addi    $s0, $s0, 1    # move pointer forward 1 in string
        addi    $s3, $s3, 1    # move pointer forward 1 in sol. gameboard

        addi    $t0, $t0, 1    # update offset
        addi    $s2, $s2, -1   # update col counter

        bne     $s2, $zero, read_cols   # go through each element in this row
read_rows:
        addi    $s0, $s0, 3    # move pointer forward 4 in string to get to next row
        addi    $s3, $s3, 3    # move pointer forward 4 in string to get to next row

        addi    $t0, $t0, 3    # update offset
        addi    $s1, $s1, -1   # update row counter

        bne     $s1, $zero, reset_col_counter   # go through each element in this row

        lw      $s5,0($sp)
        lw      $s4,4($sp)
        lw      $s3,8($sp)
        lw      $s2,12($sp) 
        lw	$s1,16($sp)
        lw	$s0,20($sp)
        lw	$ra,24($sp)	# restore the ra
        addi	$sp,$sp,28	# deallocate stack space
        
        jr      $ra

tree_fun:
        #li      $v0, 11
        #syscall
        jal     tree_case
        j       done_check
burn_fun:
        jal     burning_case
        j       done_check
inidic_fun:
        jal     indicator_case
        j       done_check

#
# Name:         clear_board
#
# Description:  EXECUTION BEGINS HERE
# Arguments:    $a0 - addr. of gameboard that will be cleared
#               $a1 - Length of the grid
# Returns:
# Destroys:     
#
clear_board:
        addi	$sp,$sp,-20	# allocate space for the return address
        sw	$ra,16($sp)	# store the ra on the stack
        sw	$s0,12($sp)	# store the ra on the stack
        sw	$s1,8($sp)	# store the ra on the stack
        sw      $s2,4($sp) 
        sw      $s3,0($sp) 

        move    $s0, $a0
        move    $s1, $a1       # counter for rows
        addi    $t0, $a1, 4    # t0 = spaces needed to get to the beginnning of board
        add     $s0, $s0, $t0  # s0 = pointer at the beginning of board
        li      $t1, PERIOD
        
reset_clear_counter:
        move    $s2, $a1
        addi    $s2, $s2, -1
clear_cols:
        sb      $t1, 0($s0)    # load current character
        addi    $s0, $s0, 1    # move pointer forward 1 in string
        addi    $s2, $s2, -1   # update col counter

        bne     $s2, $zero, clear_cols   # go through each element in this row
        sb      $t1, 0($s0)    # load current character
clear_rows:
        addi    $s0, $s0, 4    # move pointer forward 4 in string to get to next row

        addi    $s1, $s1, -1   # update row counter

        bne     $s1, $zero, reset_clear_counter   # go through each element in this row

        lw      $s3,0($sp)
        lw      $s2,4($sp) 
        lw	$s1,8($sp)
        lw	$s0,12($sp)
        lw	$ra,16($sp)	# restore the ra
        addi	$sp,$sp,20	# deallocate stack space
        
        jr $ra


print_error:
        jal print_string
        j   exit_prog

#
# Name:         print_string
#
# Description:  EXECUTION BEGINS HERE
# Arguments:    $a0 - address of the string that will be printed
# Returns:      none
# Destroys:     
#
print_string:
        li 	$v0, PRINT_STRING
        syscall		#print a0
        jr      $ra

exit_prog:
        li      $v0, 10     # $v0  10= 
        syscall

