.data
	skyColour: .word 0x8c113a
	birdColour: .word 0x8c1111
	pipeColour: .word 0x3b120d
	displayAdStart: .word 0x10008000
	
	birdbody: .word 0x46057a 
    	birdbeak: .word 0xff9900 
    	birdeyes: .word 0xffffff
    	
.text
	
	gameLoop:
	
	li $v0, 32 #sleep call
    	li $a0, 17 #sleep for 17 milliseconds
    	syscall
	
	jal drawSky
	
	li $a0, 0
	addi $a0, $a0, 2048
	addi $a0, $a0, 40
	jal drawBird
	
	#li $a0, 24
	#li $a1, 
	
	j gameLoop
	
	# =====  SKY BUILDING =====
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
	# $a0: location of the bird (top left)
	drawBird:
	lw $t0,displayAdStart
	add $a0, $a0, $t0 
	
	lw $t1, birdbody
    	lw $t2, birdbeak
    	lw $t3, birdeyes

    	sw $t1 0($a0) 
        sw $t3 4($a0)

        sw $t1 128($a0) 
        sw $t1 132($a0)
        sw $t2 136($a0)

        sw $t1 252($a0) 
        sw $t1 256($a0)
        sw $t1 260($a0)
	
	j return
	
	# ===== PIPE BUILDING =====
	# $a0: location (col) 0 to 31
	# $a1: end of the top pipe (row) 0 to 31
	# $a2: the gap size 
	drawPipe:
	lw $t0,displayAdStart
	sll $t1, $a0, 2
	add $t0, $t0, $t1 # adress of where to start drawing
	
	dplooptop:
	
	
	
	
	
	# ===== RETURN =====
	return:
	jr $ra	
	
							
Exit:
	li $v0, 10 # terminate the program gracefully
	syscall