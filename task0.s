/* Task 0 a
Read the code of procedure getCellAddress and answer:

What is the difference between the base address of the tile (5, 6) and the base
address of grid? Show your calculation steps and show your answer in bytes.
*/
getCellAddress:
    add $t0, $a0, $zero #rowIndex
    add $t1, $a1, $zero #colIndex
    la $t2, grid
    sll $t3, $t0, 3
    add $t3, $t3, $t1
    sll $t3, $t3, 5
    add $t4, $t3, $t2
    add $v0, $t4, $zero
    jr $ra

/* Task 0 b
Read the code of procedure checkHorizontalMatch and answer:

For a particular game loop, suppose the game grid holds the status exactly the
same as the game grid displayed in Fig. 3 left at the start of this game loop.
During the execution of checkHorizontalMatch, when the hscore attribute of
the tile at (5, 6) is updated, what is the value held in register $s0 (loop row
index) and register $s1 (loop column index)? Tile (5, 6) denotes the tile placed
at row 5 and column 6 (indices start from 0).

The value held in register $s0 is 8 - 6 = 2, and the value held in register $s1 is -8 + 5 = -3.
*/


checkHorizontalMatch:
    // make the stack pointer ready to get 9 
    addi $sp, $sp, -36
    sw $ra, 32($sp)
    sw $s0, 28($sp)
    sw $s1, 24($sp)
    sw $s2, 20($sp)
    sw $s3, 16($sp)
    sw $s4, 12($sp)
    sw $s5, 8($sp)
    sw $s6, 4($sp)
    sw $s7, 0($sp)

	
    li $s0, 0 # rowIndex

    rowLoopMatchHorizontal:
        li $t0, 8
        beq $s0, $t0, endCheckHorizontalMatch // if rowIndex is 8

        li $s1, 0 # colIndex

        colLoopMatchHorizontal:
            li $t0, 8
            beq $s1, $t0, endColLoopMatchHorizontal // if colIndex is 8

            add $a0, $s0, $zero
            add $a1, $s1, $zero
            jal getCellAddress
            add $s2, $v0, $zero # address of current tile

            lw $t0, 24($s2) # grid[i][j].hscore //load the member hscore in grid
            bne $t0, $zero, colLoopMatchHorizontalContinue // each time $t0--

            add $s3, $s1, $zero # leftborder of matched pattern
            add $s4, $s1, $zero # rightborder of matched pattern
            lw $s5, 16($s2) # grid[i][j].kind // load the member kind in grid

            expandLeftBorder:
                bltz $s3, expandRightBorder // if leftborder is larger or equal to 0, expandRightBorder
                add $a0, $s0, $zero 
                add $a1, $s3, $zero	
                jal getCellAddress // else call function getCellAddress
                add $t0, $v0, $zero # address of left border tile
                lw $t1, 16($t0) # grid[i][leftborder].kind
                bne $t1, $s5, expandRightBorder // if grid[i][leftborder].kind != grid[i][j].kind, expandRightBorder

                addi $s3, $s3, -1 // $s3-- 
                j expandLeftBorder // else expandLeftBorder

            expandRightBorder:
                add $t0, $s4, $zero // get rightborder $s4
                addi $t0, $t0, -8 // MY TODO: why -8? just keep -1 is not ok?
                bgez $t0, endExpandRightBorder // if rightborder is larger or equal to 0, expandLeftBorder
                add $a0, $s0, $zero
                add $a1, $s4, $zero
                jal getCellAddress // else call function getCellAddress
                add $t0, $v0, $zero # address of right border tile
                lw $t1, 16($t0) # grid[i][rightborder].kind
                bne $t1, $s5, endExpandRightBorder // if grid[i][rightborder].kind != grid[i][j].kind, endExpandRightBorder

                addi $s4, $s4, 1 // $s4++
                j expandRightBorder

            endExpandRightBorder:
                sub $s6, $s4, $s3 # patternLength
                addi $s6, $s6, -1 // patternLength-- #MY TODO: is -1 necessary?
                addi $t0, $s6, -3 // if patternLength < 3, colLoopMatchHorizontalContinue
                bltz $t0, colLoopMatchHorizontalContinue

            addi $s7, $s3, 1
            updateHScore:
                sub $t0, $s7, $s4
                bgez $t0, colLoopMatchHorizontalContinue // if $s7 >= $s4, colLoopMatchHorizontalContinue

                add $a0, $s0, $zero
                add $a1, $s7, $zero
                jal getCellAddress // else call function getCellAddress
                add $t1, $v0, $zero # address of tile to be updated
                sw $s6, 24($t1) # grid[i][s7].hscore = patternLength

                addi $s7, $s7, 1 // $s7++
                j updateHScore


        colLoopMatchHorizontalContinue:
            addi $s1, $s1, 1
            j colLoopMatchHorizontal 

        endColLoopMatchHorizontal:
            addi $s0, $s0, 1
            j rowLoopMatchHorizontal


endCheckHorizontalMatch:
    lw $s7, 0($sp)
    lw $s6, 4($sp)
    lw $s5, 8($sp)
    lw $s4, 12($sp)
    lw $s3, 16($sp)
    lw $s2, 20($sp)
    lw $s1, 24($sp)
    lw $s0, 28($sp)
    lw $ra, 32($sp)
    addi $sp, $sp, 36
    jr $ra