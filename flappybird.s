#####################################################################
#
# CSC258H5S Winter 2020 Assembly Programming Project
# University of Toronto Mississauga
#
# Group members:
# - Student 1: Kavin Adithiya Vinayagapuram Shivakumar, 1005595492
# - Student 2: Spyridon Balageorge, 1004901751
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8					     
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestone is reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 5
#
# Which approved additional features have been implemented?
# (See the assignment handout for the list of additional features)
# 1. Realistic physics
# 2. Changing sky colour
# 3. Dynamic messages after each pipe
# 4.
#
# Any additional information that the TA needs to know:
# - (write here, if any)
#
#####################################################################
.data

	pipeColour: .word 0x7F3F3F
	displayAdStart: .word 0x10008000
	messageColour: 0xfc1936
	
	birdbody: .word 0x46057a 
    	birdbeak: .word 0xff9900 
    	birdeyes: .word 0xffffff
    	
    	skyColours: .word 0x3b4551, 0x3b4551, 0x444b7a, 0x8a93cc, 0xc49fb7, 0xf2a080, 0xffd9a0, 0xffe8aa, 0xffe8aa, 0xffd9a0, 0xf2a080, 0xc49fb7, 0x8a93cc, 0x444b7a
    	skyColourNum: .word 0
    	backColours: .word 0xc0c0c0, 0xc0c0c0, 0xc0c0c0, 0xc0c0c0, 0xc0c0c0, 0xc0c0c0, 0xc0c0c0, 0xc0c0c0, 0xc0c0c0, 0xc0c0c0, 0xc0c0c0, 0xc0c0c0, 0xc0c0c0, 0xc0c0c0
    	sunMoon: .word 0xc0c0c0, 0xc0c0c0, 0xc0c0c0, 0xc0c0c0, 0xc0c0c0, 0xc0c0c0, 0xc0c0c0, 0xc0c0c0, 0xc0c0c0, 0xc0c0c0, 0xc0c0c0, 0xc0c0c0, 0xc0c0c0, 0xc0c0c0
    	
    	pipePos: .word 31
    	pipeWidth: .word 1
    	pipeHeight: .word 15
    	
    	birdRow: .word 5
    	birdCol: .word 6
    	gravity: .word 0
    	
    	wordNum: .word 0
    	
    	fKey: .word 102
    	
    	endColour: .word 0xfc1936

    	
.text
	
	li $v0, 32 #sleep call
    	li $a0, 2000 #sleep for 17 milliseconds
    	syscall
	
	# ===== GAME LOOP =====
gameLoop:
	
	li $v0, 32 #sleep call
    	li $a0, 50 #sleep for 17 milliseconds
    	syscall
	
	jal drawSky
	jal drawBackground
	
	jal showWords
	
	jal updatePipe
	
	lw $a0, birdRow
	lw $a1, birdCol
	jal drawBird
	
	j gameLoop
	
	# =====  SKY BUILDING =====
	# No arguments
drawSky:
	lw $t0,displayAdStart
	lw $t2, skyColourNum
	srl $t3, $t2, 3
	beq $t3, 15, resetSkyNum
	addi $t2, $t2, 1
	j makeSky
	
	resetSkyNum:
	li $t3, 0
	li $t2, 0
	
	makeSky:
	sw $t2, skyColourNum
	sll $t3, $t3, 2
	la $t2, skyColours 
	add $t2, $t2, $t3 #choose the right sky colour
	
	lw $t1, 0($t2)
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
	
	#Deals with f key
	lw $t1, 0xffff0000 #key event
	lw $t2, 0xffff0004 #key pressed
	lw $t3, fKey
	beqz $t1, notPressed #no key pressed
	bne $t2, $t3, notPressed #f key not pressed
	
	
	
	Pressed: #if f key is pressed moves the bird up 1 and sets gravity to 0
	lw $t0, birdRow
	li $t1, 0
	subi $t0, $t0, 4
	sw $t1, gravity
	sw $t0, birdRow
	j afterKey
	
	notPressed: #if f key is not pressed increments gravity by 2 and moves the bird down gravity rows
	lw $t0, birdRow
	lw $t1, gravity
	addi $t1, $t1, 1
	srl $t2, $t1, 1
	add $t0, $t0, $t2
	sw $t1, gravity
	sw $t0, birdRow
	
	
	afterKey:
	#ends game if bird leaves screen
	li $t0, 33
	bge $a0, $t0, endGame
	bltz $a0, endGame
	
	lw $t0,displayAdStart
	sll $a0, $a0, 7
	sll $a1, $a1, 2
	
	add $a0, $a0, $a1
	add $a0, $a0, $t0 
	
	lw $t1, birdbody
    	lw $t2, birdbeak
    	lw $t3, birdeyes
	lw $t4, pipeColour
	
	lw $t5, 4($a0)
	beq $t4, $t5, endGame
	lw $t5, 8($a0)
	beq $t4, $t5, endGame
	
	lw $t5, 132($a0)
	beq $t4, $t5, endGame
	lw $t5, 136($a0)
	beq $t4, $t5, endGame
	lw $t5, 140($a0)
	beq $t4, $t5, endGame
	
	lw $t5, 256($a0)
	beq $t4, $t5, endGame
	lw $t5, 260($a0)
	beq $t4, $t5, endGame
	lw $t5, 264($a0)
	beq $t4, $t5, endGame
	
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
	# $a2: the gap size (not larger than 30) 
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
	lw $a0, pipePos
	lw $a1, pipeHeight
	li $a2, 9 
	lw $a3, pipeWidth
	
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	jal drawPipe
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	
	lw $t0, pipePos
	lw $t1, pipeWidth
	
	beq $t0, 0, changepipewidth
	j changepipewidth2
	
	changepipewidth: #If pipe POS = 0
	beq $t1, 1, startnewpipe 
	addi $t1, $t1, -1
	sw $t1, pipeWidth
	j return
	
	startnewpipe: # If pipe WIDTH = 1 AND POS = 0
	li $t0, 31
	sw $t0, pipePos
	
	li $v0, 42
	li $a1, 21 
	syscall
	
	addi $a0, $a0, 1
	sw $a0, pipeHeight
	
	j return
	
	changepipewidth2: 
	beq $t1, 4, upend
	#WIDTH != 4
	addi $t0, $t0, -1 
	addi $t1, $t1, 1
	sw $t0, pipePos
	sw $t1, pipeWidth
	j return
	
	upend: #If WIDTH = 4
	addi $t0, $t0, -1
	sw $t0, pipePos
	j return
	
	# ===== DRAW PIXEL =====
	# $a0: row
	# $a1: col
	# $a2: colour
	drawPixel:
	lw $t0, displayAdStart
	sll $t1, $a0, 7
	sll $t2, $a1, 2
	move $t3, $a2
	
	add $t0, $t0, $t1
	add $t0, $t0, $t2
	sw $t3 0($t0)
	
	j return

	# ===== BACKGROUND BUILDING =====
drawBackground:
	
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	j return

showWords:
	
	lw, $t1, pipePos
	beq $t1, 2, doWords1
	beq $t1, 1, doWords2
	beq $t1, 0, doWords2
	j return
	
	doWords1:
	li $v0, 42
	li $a1, 3 
	syscall
	move $t0, $a0
	sw $t0, wordNum
	
	doWords2:
	lw $t0, wordNum
	beq $t0, 0, drawWow
	beq $t0, 1, drawCool
	beq $t0, 2, drawNice
		
drawWow:
	addi $sp, $sp, -4
    	sw $ra, 0($sp)
	
	#W
	li $a0, 5 #row
	li $a1, 5 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	
	li $a0, 6 #row
	li $a1, 6 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	
	li $a0, 7 #row
	li $a1, 7 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	
	li $a0, 6 #row
	li $a1, 8 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	
	li $a0, 5 #row
	li $a1, 9 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	li $a0, 6 #row
	li $a1, 10 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	
	li $a0, 7 #row
	li $a1, 11 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	li $a0, 6 #row
	li $a1, 12 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	
	li $a0, 5 #row
	li $a1, 13 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	#O
	#upper O
	li $a0, 5 #row
	li $a1, 15 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	
	li $a0, 5 #row
	li $a1, 16 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	
	li $a0, 5 #row
	li $a1, 17 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	
	li $a0, 5 #row
	li $a1, 18 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	
	
	#Bottom O
	li $a0, 8 #row
	li $a1, 15 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	
	li $a0, 8 #row
	li $a1, 16 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	
	li $a0, 8 #row
	li $a1, 17 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	
	li $a0, 8 #row
	li $a1, 18 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	
	#Left O
	li $a0, 6 #row
	li $a1, 15 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	li $a0, 7 #row
	li $a1, 15 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	
	
	#Right 0
	li $a0, 6 #row
	li $a1, 18 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	li $a0, 7 #row
	li $a1, 18 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	
	#W
	li $a0, 5 #row
	li $a1, 20 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	
	li $a0, 6 #row
	li $a1, 21 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	
	li $a0, 7 #row
	li $a1, 22 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	
	li $a0, 6 #row
	li $a1, 23 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	
	li $a0, 5 #row
	li $a1, 24 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	li $a0, 6 #row
	li $a1, 25 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	
	li $a0, 7 #row
	li $a1, 26 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	
	li $a0, 6 #row
	li $a1, 27 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	
	li $a0, 5 #row
	li $a1, 28 #col
	lw $a2, messageColour #colour
	jal drawPixel

	lw $ra, 0($sp)
    	addi $sp, $sp, 4
	j return
	
	
drawNice:
	addi $sp, $sp, -4
    	sw $ra, 0($sp)
	
	#N
	
	#left
	li $a0, 5 #row
	li $a1, 5 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	li $a0, 6 #row
	li $a1, 5 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	li $a0, 7 #row
	li $a1, 5 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	li $a0, 8 #row
	li $a1, 5 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	
	#right
	li $a0, 5 #row
	li $a1, 9 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	li $a0, 6 #row
	li $a1, 9 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	li $a0, 7 #row
	li $a1, 9 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	li $a0, 8 #row
	li $a1, 9 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	
	
	li $a0, 5 #row
	li $a1, 6 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	li $a0, 6 #row
	li $a1, 7 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	li $a0, 7 #row
	li $a1, 8 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	#I
	
	li $a0, 5 #row
	li $a1, 11 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	li $a0, 6 #row
	li $a1, 11 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	li $a0, 7 #row
	li $a1, 11 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	li $a0, 8 #row
	li $a1, 11 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	
	#C
	li $a0, 5 #row
	li $a1, 13 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	li $a0, 6 #row
	li $a1, 13 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	li $a0, 7 #row
	li $a1, 13 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	li $a0, 8 #row
	li $a1, 13 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	li $a0, 5 #row
	li $a1, 14 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	li $a0, 5 #row
	li $a1, 15 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	li $a0, 8 #row
	li $a1, 14 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	li $a0, 8 #row
	li $a1, 15 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	#E
	
	li $a0, 5 #row
	li $a1, 17 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	li $a0, 5 #row
	li $a1, 18 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	
	li $a0, 5 #row
	li $a1, 19 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	li $a0, 6 #row
	li $a1, 17 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	li $a0, 7 #row
	li $a1, 17 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	li $a0, 7 #row
	li $a1, 18 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	li $a0, 7 #row
	li $a1, 19 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	
	li $a0, 7 #row
	li $a1, 19 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	li $a0, 8 #row
	li $a1, 17 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	li $a0, 9 #row
	li $a1, 17 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	li $a0, 9 #row
	li $a1, 18 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	li $a0, 9 #row
	li $a1, 19 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	lw $ra, 0($sp)
   	addi $sp, $sp, 4
	j return
	
	
drawCool:
	addi $sp, $sp, -4
    	sw $ra, 0($sp)
	
	#C
	li $a0, 5 #row
	li $a1, 5 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	li $a0, 6 #row
	li $a1, 5 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	li $a0, 7 #row
	li $a1, 5 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	li $a0, 8 #row
	li $a1, 5 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	li $a0, 5 #row
	li $a1, 6 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	li $a0, 5 #row
	li $a1, 7 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	li $a0, 8 #row
	li $a1, 6 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	li $a0, 8 #row
	li $a1, 7 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	#O
	#upper O
	li $a0, 5 #row
	li $a1, 9 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	
	li $a0, 5 #row
	li $a1, 10 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	
	li $a0, 5 #row
	li $a1, 11 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	
	li $a0, 5 #row
	li $a1, 12 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	
	
	#Bottom O
	li $a0, 8 #row
	li $a1, 9 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	
	li $a0, 8 #row
	li $a1, 10 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	
	li $a0, 8 #row
	li $a1, 11 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	
	li $a0, 8 #row
	li $a1, 12 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	
	#Left O
	li $a0, 6 #row
	li $a1, 9 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	li $a0, 7 #row
	li $a1, 9 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	
	
	#Right 0
	li $a0, 6 #row
	li $a1, 12 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	li $a0, 7 #row
	li $a1, 12 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	
	#O - 2
	#upper O
	li $a0, 5 #row
	li $a1, 14 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	
	li $a0, 5 #row
	li $a1, 15 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	
	li $a0, 5 #row
	li $a1, 16 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	
	li $a0, 5 #row
	li $a1, 17 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	
	
	#Bottom O
	li $a0, 8 #row
	li $a1, 14 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	
	li $a0, 8 #row
	li $a1, 15 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	
	li $a0, 8 #row
	li $a1, 16 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	
	li $a0, 8 #row
	li $a1, 17 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	
	#Left O
	li $a0, 6 #row
	li $a1, 14 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	li $a0, 7 #row
	li $a1, 14 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	
	
	#Right 0
	li $a0, 6 #row
	li $a1, 17 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	li $a0, 7 #row
	li $a1, 17 #col
	lw $a2, messageColour #colour
	jal drawPixel


	#L
	li $a0, 5 #row
	li $a1, 19 #col
	lw $a2, messageColour #colour
	jal drawPixel

	li $a0, 6 #row
	li $a1, 19 #col
	lw $a2, messageColour #colour
	jal drawPixel

	li $a0, 7 #row
	li $a1, 19 #col
	lw $a2, messageColour #colour
	jal drawPixel

	li $a0, 8 #row
	li $a1, 19 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	li $a0, 8 #row
	li $a1, 20 #col
	lw $a2, messageColour #colour
	jal drawPixel
	
	li $a0, 8 #row
	li $a1, 21 #col
	lw $a2, messageColour #colour
	jal drawPixel

	lw $ra, 0($sp)
    	addi $sp, $sp, 4
	j return
	
	
endGame:
	lw $t0, displayAdStart
	lw $t1, endColour
	
	addi $t0, $t0, 640 #row 5
    
    	#U
    	sw $t1 8($t0) 
        sw $t1 20($t0)
        
        #S
        sw $t1 28($t0) 
        sw $t1 32($t0)
        sw $t1 36($t0) 
        sw $t1 40($t0)
        
        #U
	sw $t1 48($t0) 
        sw $t1 60($t0) 
	
	#C
        sw $t1 68($t0)
        sw $t1 72($t0)
        sw $t1 76($t0)
        sw $t1 80($t0)

	#K
        sw $t1 88($t0)
        sw $t1 96($t0)
   
        addi $t0, $t0, 128 #row 6
        
        #U
    	sw $t1 8($t0) 
        sw $t1 20($t0)
        
        #S
        sw $t1 28($t0) 
        
        
        #U
	sw $t1 48($t0) 
        sw $t1 60($t0) 
	
	#C
        sw $t1 68($t0)
        

	#K
        sw $t1 88($t0)
        sw $t1 92($t0)
        
        addi $t0, $t0, 128 #row 7
        
        #U
    	sw $t1 8($t0) 
        sw $t1 20($t0)
        
       #S
        sw $t1 28($t0) 
        sw $t1 32($t0)
        sw $t1 36($t0) 
        sw $t1 40($t0)
        
        
        #U
	sw $t1 48($t0) 
        sw $t1 60($t0) 
	
	#C
        sw $t1 68($t0)
        

	#K
        sw $t1 88($t0)

        
        addi $t0, $t0, 128 #row 8
        
        #U
    	sw $t1 8($t0) 
        sw $t1 20($t0)
        
       #S

        sw $t1 40($t0)
        
        
        #U
	sw $t1 48($t0) 
        sw $t1 60($t0) 
	
	#C
        sw $t1 68($t0)
        

	#K
        sw $t1 88($t0)
        sw $t1 92($t0)
       
       	addi $t0, $t0, 128 #row 9
        
        #U
    	sw $t1 8($t0) 
    	sw $t1 12($t0) 
    	sw $t1 16($t0) 
        sw $t1 20($t0)
        
        #S
        sw $t1 28($t0) 
        sw $t1 32($t0)
        sw $t1 36($t0) 
        sw $t1 40($t0)
        
        
        #U
	sw $t1 48($t0) 
	sw $t1 52($t0)
	sw $t1 56($t0)
        sw $t1 60($t0) 
	
	#C
        sw $t1 68($t0)
        sw $t1 72($t0)
        sw $t1 76($t0)
        sw $t1 80($t0)
        

	#K
        sw $t1 88($t0)
        sw $t1 96($t0)
   
      
        j Exit
        
	# ===== RETURN =====
return:
	jr $ra	
																							
Exit:
	li $v0, 10 # terminate the program gracefully
	syscall
