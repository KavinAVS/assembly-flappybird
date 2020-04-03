.data
	skyColour: .word 0x8c113a
	birdColour: .word 0x8c1111
	pipeColour: .word 0x3b120d
	displayAdStart: .word 0x10008000
	
	birdbody: .word 0x46057a 
    	birdbeak: .word 0xff9900 
    	birdeyes: .word 0xffffff
    	
    	pipePos: .word 31
    	
.text
	# ===== GAME LOOP =====
	gameLoop:
	
	li $v0, 32 #sleep call
    	li $a0, 17 #sleep for 17 milliseconds
    	syscall
	
	jal drawSky
	
	li $a0, 20
	li $a1, 15
	li $a2, 10
	li $a3, 5
	jal drawPipe
	
	li $a0, 16
	li $a1, 32
	jal drawBird
	
	j gameLoop
	
	# =====  SKY BUILDING =====
	# No arguments
	drawSky:
	lw $t0,displayAdStart
	lw $t1,skyColour
	li $t2, 0
	li $t3, 1024
	
	dsloop:
	beq $t2, $t3, return
	sw $t1, 0($t0) #set color
	addi $t0, $t0, 4 #move to next pixel
	addi $t2, $t2, 1 # add 1 to counter
	j dsloop
	
	# ===== BIRD BUILDING =====
	# $a0: row (top left)
	# $a1: col (top left)
	
	drawBird:
	lw $t0,displayAdStart
	
	sll $a0, $a0, 7
	sll $a1, $a1, 2
	
	add $a0, $a0, $a1
	add $a0, $a0, $t0 
	
	lw $t1, birdbody
    	lw $t2, birdbeak
    	lw $t3, birdeyes

    	sw $t1 4($a0) 
        sw $t3 8($a0)

        sw $t1 132($a0) 
        sw $t1 136($a0)
        sw $t2 140($a0)

        sw $t1 256($a0) 
        sw $t1 260($a0)
        sw $t1 264($a0)
	
	j return
	
	# ===== PIPE BUILDING =====
	# $a0: location (col) 0 to 31
	# $a1: end of the top pipe (row) 0 to 31
	# $a2: the gap size 
	# $a3: pipe width 1 to 4
	drawPipe:
	lw $t0,displayAdStart
	lw $t3,pipeColour
	
	sll $t1, $a0, 2 #multiply by 4
	add $t0, $t0, $t1 # address of where to start drawing
	
	sll $t2, $a1, 7 #multiply by 128
	add $t2, $t0, $t2 #left bottom of top pipe
	
	dplooptop:
	move $t5, $t0
	li $t4, 0
	
	dplooptop2:
	sw $t3, 0($t5) #set color
	addi $t5, $t5, 4
	addi $t4, $t4, 1
	bne $a3, $t4, dplooptop2
	
	addi $t0, $t0, 128 
	bne $t2, $t0, dplooptop
	
	sll $t4, $a2, 7 # gap
	add $t4, $t2, $t4 # set where to start at: end of top + gap
	
	lw $t0, displayAdStart
	li $t5, 32
	sll $t5, $t5, 7 # 31* 128
	add $t5, $t0, $t5 #start of last line 
	add $t5, $t1, $t5 #bottom left of bottom pipe
	
	dploopbottom:
	move $t6, $t4
	li $t7, 0
	
	dploopbottom2:
	sw $t3, 0($t6) #set color
	addi $t6, $t6, 4
	addi $t7, $t7, 1
	bne $a3, $t7, dploopbottom2
	
	addi $t4, $t4, 128 
	bne $t4, $t5, dploopbottom
	
	j return
	
	# ===== UPDATE PIPE =====
	updatePipe:
	lw $t0, pipePos
	
	width1check:
	bne $t0, 31, width2check
	
	j makepipe
	width2check:
	bne $t0, 30, width3check
	
	j makepipe
	width3check:
	bne $t0, 29, makepipe
	
	j makepipe
	makepipe:
	
	# ===== RETURN =====
	return:
	jr $ra	
	
							
Exit:
	li $v0, 10 # terminate the program gracefully
	syscall
