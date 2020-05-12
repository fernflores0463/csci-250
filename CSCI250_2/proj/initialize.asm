SPACE_CHAR   = 32
NEWLINE      = 10
PIPE         = 124
PLUS_SIGN    = 43
HYPHEN       = 45  
PERIOD       = 46
TREE   = 116
BURN   = 66
INDICATOR = 105 

        .globl  create_board_header
        .globl	main
        .globl  game_board
        .globl  game_board_cpy
        .globl  create_board_header
        .globl  input_buffer
        .globl  print_error
        .globl  char_error
#
# Name:         create_board_header
#
# Description:  EXECUTION BEGINS HERE
# Arguments:    $a0 - address of the stdin
#               $a1 - length of the board
#               $a2 - MAYBE 
# Returns:      none
# Destroys:     
#
create_board_header:
        addi	$sp,$sp,-12	# allocate space for the return address
	sw	$ra,8($sp)	# store the ra on the stack
	sw	$s0,4($sp)	# store the ra on the stack
	sw	$s1,0($sp)	# store the ra on the stack
        # for i in range of board len + 2
        #       if i == 0 or i == len - 1
        #               set curr index to '+'
        #       else:
        #               set curr index t0 '-'
        la      $s0, game_board
        la      $s7, game_board_cpy
        move    $t3, $a0
        move    $s4, $a1
        move    $t0, $a1       # setting the $t0 to grid length
        li      $t2, PLUS_SIGN
        sb      $t2, 0($s0)
        sb      $t2, 0($s7)
header_loop:
        addi    $s0, $s0, 1
        addi    $s7, $s7, 1

        li      $t2, HYPHEN

        sb      $t2, 0($s0)
        sb      $t2, 0($s7)

        addi    $t0, $t0, -1
        bne     $t0, $zero, header_loop
        
after_header_loop:
        li      $t1, PLUS_SIGN     # setting to the byte value for '+'

        addi    $s0, $s0, 1
        addi    $s7, $s7, 1
        sb      $t1, 0($s0)        # setting the byte value in the string
        sb      $t1, 0($s7)

        li      $t1, NEWLINE       # setting the byte value for '\n'
        addi    $s0, $s0, 1        # MIGHT BE A SOURCE OF ERROR
        addi    $s7, $s7, 1
        sb      $t1, 0($s0)        # setting the byte value in the string
        sb      $t1, 0($s7)

        #move    $s1, $a1            #setting counter for row
        move    $t7, $s4
        
        
row_loop:
        move    $t0, $s4    # set t0 to the length of the grid
        move    $s3, $s4
        
        li      $t1, PIPE      # setting the byte value for '|'

        addi    $s0, $s0, 1
        addi    $s7, $s7, 1
        sb      $t1, 0($s0)  # setting the byte value in the string
        sb      $t1, 0($s7)

        ##
        la      $a0, input_buffer     # a0 = &input_buffer
        li      $a1, 50               # read 5 chars
        li      $v0, 8
        syscall
        ##

col_loop:
        addi    $s0, $s0, 1
        addi    $s7, $s7, 1

        lb      $t2, 0($a0)    # get char from the input

        #$$$$$$$$$$$$$$$$$$
        li     $t1, TREE
        beq    $t2, $t1, skip_check
        li     $t1, BURN
        beq    $t2, $t1, skip_check
        li     $t1, PERIOD
        beq    $t1, $t2, skip_check
        la     $a0, char_error
        j      print_error
        #$$$$$$$$$$$$$$$$$$
skip_check:
        sb      $t2, 0($s0)    # set index to byte
        sb      $t2, 0($s7) 

        addi    $a0, $a0, 1
        addi    $s3, $s3, -1
        bne     $s3, $zero, col_loop	# if len_of_board != $zer0 then create_board
        
        # Adding a pipe, \n, and pipe (prep
        addi    $s0, $s0, 1
        addi    $s7, $s7, 1
        li      $t1, PIPE      # setting the byte value for '|'
        sb      $t1, 0($s0)
        sb      $t1, 0($s7)

        addi    $s0, $s0, 1
        addi    $s7, $s7, 1
        li      $t1, NEWLINE       # setting the byte value for '\n'
        sb      $t1, 0($s0)        # setting the byte value in the string
        sb      $t1, 0($s7)
        
        addi    $t7, $t7, -1
        bne     $t7, $zero, row_loop

        # USE T0 FOR LEN OF GRID
        addi    $s0, $s0, 1
        addi    $s7, $s7, 1
        li      $t2, PLUS_SIGN
        sb      $t2, 0($s0)
        sb      $t2, 0($s7) 
footer_loop:
        addi    $s0, $s0, 1
        addi    $s7, $s7, 1
        li      $t2, HYPHEN
        sb      $t2, 0($s0)
        sb      $t2, 0($s7)
        
        addi    $t0, $t0, -1
        bne     $t0, $zero, footer_loop
        
after_footer_loop:
        li      $t1, PLUS_SIGN     # setting to the byte value for '+'
        addi    $s0, $s0, 1
        addi    $s7, $s7, 1
        sb      $t1, 0($s0)        # setting the byte value in the string
        sb      $t1, 0($s7)
        
        li      $t1, NEWLINE       # setting the byte value for '\n'
        addi    $s0, $s0, 1        # MIGHT BE A SOURCE OF ERROR
        addi    $s7, $s7, 1
        sb      $t1, 0($s0)        # setting the byte value in the string
        sb      $t1, 0($s7)

        addi    $s0, $s0, 1        # MIGHT BE A SOURCE OF ERROR
        addi    $s7, $s7, 1
        sb      $t1, 0($s0)        # setting the byte value in the string
        sb      $t1, 0($s7)

        lw	$s1,0($sp)
	lw	$s0,4($sp)
	lw	$ra,8($sp)	# restore the ra
	addi	$sp,$sp,12	# deallocate stack space

        jr      $ra
