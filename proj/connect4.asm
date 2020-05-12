
PRINT_STRING = 4		# arg for syscall to tell it to write
SPACE_CHAR   = 32
NEWLINE      = 10
P1_CHAR      = 88
P2_CHAR      = 79

.data
welcome_msg:
        .ascii   "\n   ************************"
        .ascii   "\n   **    Connect Four    **"
        .asciiz  "\n   ************************\n"


user_input:
        .word 4

p1_prompt:
        .asciiz  "\nPlayer 1: select a row to place your coin (0-6 or -1 to quit):"

p2_prompt:
        .asciiz  "\nPlayer 2: select a row to place your coin (0-6 or -1 to quit):"

game_board:
        .ascii  "\n   0   1   2   3   4   5   6   "
        .ascii  "\n+----+---+---+---+---+---+----+"
        .ascii  "\n|+---+---+---+---+---+---+---+|"
        .ascii  "\n||   |   |   |   |   |   |   ||"
        .ascii  "\n|+---+---+---+---+---+---+---+|"
        .ascii  "\n||   |   |   |   |   |   |   ||"
        .ascii  "\n|+---+---+---+---+---+---+---+|"
        .ascii  "\n||   |   |   |   |   |   |   ||"
        .ascii  "\n|+---+---+---+---+---+---+---+|"
        .ascii  "\n||   |   |   |   |   |   |   ||"
        .ascii  "\n|+---+---+---+---+---+---+---+|"
        .ascii  "\n||   |   |   |   |   |   |   ||"
        .ascii  "\n|+---+---+---+---+---+---+---+|"
        .ascii  "\n||   |   |   |   |   |   |   ||"
        .ascii  "\n|+---+---+---+---+---+---+---+|"
        .ascii  "\n+----+---+---+---+---+---+----+"
        .asciiz "\n   0   1   2   3   4   5   6   \n"

illegal_col:
        .asciiz "Illegal column number."

col_full:
        .asciiz "Illegal move, no more room in that column.\n"

tie_message:
        .asciiz "The game ends in a tie."

p1_win:
        .asciiz "\nPlayer 1 wins!\n"

p2_win:
        .asciiz "\nPlayer 2 wins!\n"

p1_quit:
        .asciiz "Player 1 quit."

p2_quit:
        .asciiz "Player 2 quit."

        .text
        .align	2
	.globl	main


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
        
        la      $a0, game_board
        jal     print_string

        addi	$s0, $zero, 0			# $s0 = zero1 + 0
        addi	$s1, $zero, 0			# $s0 = zero1 + 0
        



play:
        jal     check_full
        jal     ask_p1_input
        la      $a0, game_board
        jal     print_string
        jal     ask_p2_input
        la      $a0, game_board
        jal     print_string
        j       play


game_done:
        j       exit_prog			# jump to print_string


#
# Name:         ask_p1_input
#
# Description:  EXECUTION BEGINS HERE
# Arguments:    none
# Returns:      none
# Destroys:     
#
ask_p1_input:
        # saving return register on stack
        addi    $sp, $sp, -4
        sw      $s0, 0($sp)
        addi    $sp, $sp,-4
        sw      $ra, 0($sp)

        la      $a0, p1_prompt
        jal     print_string

        li      $v0, 5         #load op code for getting a string from the user into register $v0
        syscall                 #reads register $v0 for op code, sees 8 and asks user to input an int

        move 	$a0, $v0		# $a0 = $v0

        addi    $t0, $zero, -1
        
        beq     $a0, $t0, exit_p1

        #slt     $v0, $a0, $zero         # $v0 = a0 < $zero
        #bne     $v0, $zero, exit_prog   # if $v0 == $zero then exit prog
        addi    $v0, $zero, 6
        slt     $t1 ,$v0, $a0
        bne     $t1, $zero, illegal_cl
        slt     $t1, $a0, $t0
        beq     $t1, $zero, skip_print_2
illegal_cl:
        la      $t5, illegal_col
        move    $a0, $t5
        li 	$v0, PRINT_STRING
        syscall
        # restoring return register from stack
        lw      $ra,0($sp)
        addi    $sp,$sp,4
        lw      $s0,0($sp)
        addi    $sp,$sp,4
        j       ask_p1_input		
skip_print_2:

        addi    $a1, $zero, 0   # setting arg to be p2 (1)

        addi    $v0, $zero, 0           # $v0 = 1 if col is full
        jal     place_piece

        beq     $v0, $zero, rest_and_ret_p1
        j       ask_p1_input

rest_and_ret_p1:

        #jal		check_right_diagonal				# jump to target and save position to $ra
        

        # restoring return register from stack
        lw      $ra,0($sp)
        addi    $sp,$sp,4
        lw      $s0,0($sp)
        addi    $sp,$sp,4

        jr      $ra

#####################################################

#
# Name:         ask_p2_input
#
# Description:  EXECUTION BEGINS HERE
# Arguments:    none
# Returns:      none
# Destroys:     
#
ask_p2_input:
        # saving return register on stack
        addi    $sp, $sp, -4
        sw      $s0, 0($sp)
        addi    $sp, $sp,-4
        sw      $ra, 0($sp)

        la      $a0, p2_prompt
        jal     print_string

        li      $v0, 5         #load op code for getting a string from the user into register $v0
        syscall                 #reads register $v0 for op code, sees 8 and asks user to input an int

        move 	$a0, $v0		# $a0 = $v0

        addi    $t0, $zero, -1
        
        beq     $a0, $t0, exit_p2

        #slt     $v0, $a0, $zero         # $v0 = a0 < $zero
        #bne     $v0, $zero, exit_prog   # if $v0 == $zero then exit prog
        addi    $v0, $zero, 6
        slt     $t1 ,$v0, $a0
        slt     $t1, $a0, $t0
        beq     $t1, $zero, skip_print
        la      $t5, illegal_col
        move    $a0, $t5
        li 	$v0, PRINT_STRING
        syscall
        # restoring return register from stack
        lw      $ra,0($sp)
        addi    $sp,$sp,4
        lw      $s0,0($sp)
        addi    $sp,$sp,4
        j       ask_p2_input		
skip_print:
        addi    $a1, $zero, 1   # setting arg to be p2 (1)

        addi    $v0, $zero, 0           # $v0 = 1 if col is full
        jal     place_piece

        beq     $v0, $zero, rest_and_ret_p2
        j       ask_p2_input

rest_and_ret_p2:
        # restoring return register from stack
        lw      $ra,0($sp)
        addi    $sp,$sp,4
        lw      $s0,0($sp)
        addi    $sp,$sp,4

        jr      $ra

###############################################

#
# Name:         place_piece
#
# Description:  EXECUTION BEGINS HERE
# Arguments:    $a0: rowNum $a1: playerNum
# Returns:      none
# Destroys:     
#
place_piece:
        # saving return register on stack
        addi    $sp, $sp, -4
        sw      $s0, 0($sp)
        addi    $sp, $sp,-4
        sw      $ra, 0($sp)
        #################################

        # $a0: rowNum $a1:playerNum
        addi	$t0, $zero, 4			# $t0 = $zero + 0
        # get initial index of the row
        mult	$t0, $a0			# $t0 * $t1 = Hi and Lo registers
        mflo	$t2					# copy Lo to $t2

        addi	$t2, $t2, 420			# $t2 = $t2 + 96
        
        # set the pointer to the row on the game board
        la      $t1, game_board		# copy game board add to $t1
        add     $t1, $t2
        

        #la      $t3, user_input		# MAYBE DELETE?
        #sw      $t2, 0($t3)		# MAYBE DELETE?
        
        
        # if player 1, set $t2 to 79('O') if p2 then set to 88('X')
set_player_char:
        addi    $t4, $zero, 384         #counter to see if col is full

        addi	$t2, $zero, P2_CHAR			# $t0 = $t1 + 0
        move    $a0, $a1
        beq     $a1, $zero, set_p1_char	# if $a0 == $zero then target
        
place_piece_cont:
        lb      $t3, 0($t1)		# 
        addi	$t0, $zero, SPACE_CHAR			# $t0 = $zero + SPACE_CHAR

        bne     $t3, $t0, increment
        sb      $t2, 0($t1)		# 
        move 	$a1, $t1		# $a1 = $t1
        move 	$a2, $t2		# $a2 = $t2
        #check horizontal
        jal     check_if_win            

ret_to_input:
        ### restoring return register from stack ####
        lw      $ra,0($sp)
        addi    $sp,$sp,4
        lw      $s0,0($sp)
        addi    $sp,$sp,4
        #############################################
        jr      $ra

increment:
        addi    $v0, $zero, 0           # $v0 = 1 if col is full
        addi    $t1, $t1, -32			# $t1 = $t1 -32
        addi    $t4, $t4, -32
        slt     $t3, $t4, $zero
        beq     $t3, $zero, go_back

        la	$a0, col_full		#
        jal     print_string
        addi    $v0, $zero, 1           # $v0 = 1 if col is full
        j       ret_to_input
go_back:
        j       place_piece_cont
    

#
# Name:         check_if_win
#
# Description:  EXECUTION BEGINS HERE
# Arguments:    $a0: playerNum
# Returns:      none
# Destroys:     
#
check_if_win:
         # saving return register on stack
        addi    $sp, $sp, -4
        sw      $s0, 0($sp)
        addi    $sp, $sp,-4
        sw      $ra, 0($sp)
        addi    $sp, $sp,-4
        sw      $v0, 0($sp)
        #################################
        jal     check_left_diagonal
        jal     check_right_diagonal
        jal     check_horizontal
        jal     check_vertical

        ### restoring return register from stack ####
        lw      $v0,0($sp)
        addi    $sp,$sp,4
        lw      $ra,0($sp)
        addi    $sp,$sp,4
        lw      $s0,0($sp)
        addi    $sp,$sp,4
        #############################################
        jr      $ra

        # run after a player's turn
        # $a0: playerNum $a1: index_

#
# Name:         check_full
#
# Description:  EXECUTION BEGINS HERE
# Arguments:    $a0: playerNum
# Returns:      none
# Destroys:     
#
check_full:
        la      $t0, game_board
        addi    $t0, 100
        addi    $t2, $zero, SPACE_CHAR
        lb      $t1, 0($t0)
        bne     $t1, $t2, increment_2
        addi    $t2, $zero, NEWLINE
        beq     $t1, $t2, print_full
        jr      $ra

increment_2:
        addi    $t0, $t0, 4
        j       check_full

print_full:
        la   $a0, tie_message
        j    print_string
        j    exit_prog

#
# Name:         check_left_diagonal
#
# Description:  EXECUTION BEGINS HERE
# Arguments:    $a0: playerNum,  $a1: start address , $a2: playerpiece
# Returns:      none
# Destroys:     
#
check_left_diagonal:
#$a0: playerNum, $a1: startAddress, $a2: PLAYER_PIECE
        #returns: whether the player won or not
        move 	$t0, $a1		# $t0 = $a1
        move 	$t4, $a1		# $t4 = $a1
        addi    $t2, $zero, 3
        addi    $t3, $zero, 0

check_left_d_pos:
        addi	$t0, $t0, 60			# $t0 = $t0 + 68
        lb	$t1, 0($t0)		# 
        bne	$t1, $a2, check_left_d_neg	# if $t1 != $t1 then end
        addi    $t3, $t3, 1
        beq     $t3, $t2, print_win
        j       check_left_d_pos

check_left_d_neg:
        addi	$t4, $t4, -60			# $t0 = $t0 + 68
        lb	$t1, 0($t4)		# 
        bne	$t1, $a2, end	# if $t1 != $t1 then end
        addi    $t3, $t3, 1
        beq     $t3, $t2, print_win
        j       check_left_d_neg

#
# Name:         check_right_diagonal
#
# Description:  EXECUTION BEGINS HERE
# Arguments:    a0: playerNum, $a1: startAddress, $a2: PLAYER_PIECE
# Returns:      v0: whether the player won or not
# Destroys:     
#
check_right_diagonal:

        move 	$t0, $a1		# $t0 = $a1
        move 	$t4, $a1		# $t4 = $a1
        addi    $t2, $zero, 3
        addi    $t3, $zero, 0

check_right_d_pos:
        addi	$t0, $t0, 68			# $t0 = $t0 + 68
        lb	$t1, 0($t0)		# 
        bne	$t1, $a2, check_right_d_neg	# if $t1 != $t1 then end
        addi    $t3, $t3, 1
        beq     $t3, $t2, print_win
        j       check_right_d_pos

check_right_d_neg:
        addi	$t4, $t4, -68			# $t0 = $t0 + 68
        lb	$t1, 0($t4)		# 
        bne	$t1, $a2, end	# if $t1 != $t1 then end
        addi    $t3, $t3, 1
        beq     $t3, $t2, print_win
        j       check_right_d_neg


#
# Name:         check_vertical
#
# Description:  EXECUTION BEGINS HERE
# Arguments:    none
# Returns:      none
# Destroys:     
#
check_vertical:
#$a0: playerNum, $a1: startAddress, $a2: PLAYER_PIECE
        #returns: whether the player won or not
        move 	$t0, $a1		# $t0 = $a1
        move 	$t4, $a1		# $t4 = $a1
        addi    $t2, $zero, 3
        addi    $t3, $zero, 0

check_down_vert:
        addi	$t0, $t0, 64			# $t0 = $t0 + 68
        lb	$t1, 0($t0)		# 
        bne	$t1, $a2, check_up_vert	# if $t1 != $t1 then end
        addi    $t3, $t3, 1
        beq     $t3, $t2, print_win
        j       check_down_vert

check_up_vert:
        addi	$t4, $t4, -64			# $t0 = $t0 + 68
        lb	$t1, 0($t4)		# 
        bne	$t1, $a2, end	# if $t1 != $t1 then end
        addi    $t3, $t3, 1
        beq     $t3, $t2, print_win
        j       check_up_vert

#
# Name:         check_horizontal
#
# Description:  EXECUTION BEGINS HERE
# Arguments:    none
# Returns:      none
# Destroys:     
#
check_horizontal:
#$a0: playerNum, $a1: startAddress, $a2: PLAYER_PIECE
        #returns: whether the player won or not
        move 	$t0, $a1		# $t0 = $a1
        move 	$t4, $a1		# $t4 = $a1
        addi    $t2, $zero, 3
        addi    $t3, $zero, 0

check_hor_pos:
        addi	$t0, $t0, 4			# $t0 = $t0 + 68
        lb	$t1, 0($t0)		# 
        bne	$t1, $a2, check_hor_neg	# if $t1 != $t1 then end
        addi    $t3, $t3, 1
        beq     $t3, $t2, print_win
        j       check_hor_pos

check_hor_neg:
        addi	$t4, $t4, -4			# $t0 = $t0 + 68
        lb	$t1, 0($t4)		# 
        bne	$t1, $a2, end	# if $t1 != $t1 then end
        addi    $t3, $t3, 1
        beq     $t3, $t2, print_win
        j       check_hor_neg

#
# Name:         print_win
#
# Description:  EXECUTION BEGINS HERE
# Arguments:    $a0: playerNum
# Returns:      none
# Destroys:     
#
print_win:
        beq     $a0, $zero, p1_win_msg
        la      $a0, game_board
        jal     print_string
        la      $a0, p2_win
        jal     print_string
        j       exit_prog
p1_win_msg:
        la      $a0, game_board
        jal     print_string
        la      $a0, p1_win
        jal     print_string
        j       exit_prog

#
# Name:         end
#
# Description:  EXECUTION BEGINS HERE
# Arguments:    none
# Returns:      none
# Destroys:     
#
end:
        jr $ra


#
# Name:         set_p1_char
#
# Description:  EXECUTION BEGINS HERE
# Arguments:    none
# Returns:      none
# Destroys:     
#
set_p1_char:
        addi    $t2, $zero, P1_CHAR			# $t0 = $t1 + 0
        j       place_piece_cont

print_exc:
        la      $t5, illegal_col
        move    $a0, $t5


#
# Name:         print_string
#
# Description:  EXECUTION BEGINS HERE
# Arguments:    none
# Returns:      none
# Destroys:     
#
print_string:
        li 	$v0, PRINT_STRING
        syscall			#print a0
        jr      $ra

exit_p1:
        la      $a0, p1_quit
        jal       print_string
        j       exit_prog

exit_p2:
        la      $a0, p2_quit
        jal       print_string
        j       exit_prog
#
# Name:         exit_prog
#
# Description:  exits the program gracefully
# Arguments:    none
# Returns:      none
# Destroys:     
#
exit_prog:
        li      $v0, 10 		# $v0  10= 
        syscall
