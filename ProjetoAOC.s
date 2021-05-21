@ Trabalho de AOC 
@ - Christian A. Carneiro e Raian Moretti

@ Those are binds to make the swi more meaningful
.equ Seg8, 0x200                                    @ Display on the 8 Segments the value in r0
.equ Print, 0x204                                   @ Display on the LCD the value in r2
.equ BlackB, 0x202                                  @ Put in r0 the button pressed (left/right)
.equ BlueB, 0x203                                   @ Put in r0 the button pressed (0-15)
.equ Clear, 0x206									@ Clear display
.equ RedLED, 0x201									@ Turn on Red LED

@ Those are binds for each segment of the 8-segment display 
.equ SEG_A,0x80
.equ SEG_B,0x40
.equ SEG_C,0x20
.equ SEG_P,0x10
.equ SEG_D,0x08
.equ SEG_E,0x04
.equ SEG_F,0x02
.equ SEG_G,0x01

.text
@ Binds for the characters used in the program
str_hyphen: .asciz "-"
str_space:  .asciz " "
str_hash:  .asciz "#"
str_star:  .asciz "*"
str_o:  .asciz "O"
	
@ Sequence of binds in an array that will light up the 8-segment display
Digits:                                             @ Those are the value for r0:
                                                    @ that will also be light-up on the display
    .word SEG_A|SEG_B|SEG_C|SEG_D|SEG_E|SEG_G       @ 0
    .word SEG_B|SEG_C                               @ 1
    .word SEG_A|SEG_B|SEG_F|SEG_E|SEG_D             @ 2
    .word SEG_A|SEG_B|SEG_F|SEG_C|SEG_D             @ 3
    .word SEG_G|SEG_F|SEG_B|SEG_C                   @ 4
    .word SEG_A|SEG_G|SEG_F|SEG_C|SEG_D             @ 5
    .word SEG_A|SEG_G|SEG_F|SEG_E|SEG_D|SEG_C       @ 6
    .word SEG_A|SEG_B|SEG_C                         @ 7
    .word SEG_A|SEG_B|SEG_C|SEG_D|SEG_E|SEG_F|SEG_G @ 8
    .word SEG_A|SEG_B|SEG_F|SEG_G|SEG_C             @ 9
    .word SEG_A|SEG_G|SEG_B|SEG_F|SEG_E|SEG_C       @ A [10]
    .word 0                                         @ 'empty'


.align

@ Clears the LCD screen
swi Clear

@ "Defining" the registers that are going to be used
mov r0, #0                                          @ Starting the variable with 0
mov r1, #0                                          @ Starting the variable with 0
mov r2, #0                                          @ Starting the variable with 0
mov r5, #0										    @ Starting the variable with 0
mov r6, #0										    @ Starting the variable with 0
mov r7, #0										    @ Starting the variable with 0
mov r8, #0										    @ Starting the variable with 0
mov r9, #0											@ Starting the variable with 0
mov r10, #0											@ Starting the variable with 0
mov r11, #0											@ Starting the variable with 0
mov r12, #0											@ Starting the variable with 0
ldr r13, =str_space									@ Starting the variable with 0

@ Prints the '-' cursor on the LCD Screen in the position 'x' = r8 and 'y' = r9
PrintCursor:

	mov r0, r8
	mov r1, r9
 	ldr r2, =str_hyphen
	swi Print
    ldr r2, =LINHA0 
	b Start  

ClearCursor:

@ Prints the ' ' in r2 on the position 'x' = r8 and 'y' = r9, current position of the cursor
PrintSpace:

	mov r0, r8
	mov r1, r9
 	ldr r2, =str_space
	ldr r5, =LINHA0
	str r2, [r5, #0x0]
	swi Print
	b checkPercent 

@ Prints the '#' in r2 on the position 'x' = r8 and 'y' = r9, current position of the cursor
PrintHash:

	mov r0, r8
	mov r1, r9
 	ldr r2, =str_hash
	swi Print
	b checkPercent

@ Prints the '*' in r2 on the position 'x' = r8 and 'y' = r9, current position of the cursor
PrintStar:

	mov r0, r8
	mov r1, r9
 	ldr r2, =str_star
	swi Print
	b checkPercent 

@ Prints the '-' on the position 'x' = r8 and 'y' = r9, current position of the cursor
PrintHyphen:

	mov r0, r8
	mov r1, r9
 	ldr r2, =str_hyphen
	swi Print
	b checkPercent 

@ Prints the 'O' on the position 'x' = r8 and 'y' = r9, current position of the cursor
PrintO:

	mov r0, r8
	mov r1, r9
 	ldr r2, =str_o
	swi Print
	b checkPercent 

@ Prints the cursor on the right side of the screen, on the same row 
OverflowLeft:
	mov r0, r8
	mov r1, r9
 	ldr r2, =str_space
	swi Print
    
	mov r8, #40

@ Checks if the cursor is going to move to an "illegal" position on the left side of the LCD screen
@ If it is, it calls OverflowLeft otherwise it prints the cursor on the designated place 
@ ('x' = r8 and 'y' = r9)
PrintLeft:
	cmp r8, #0
	beq OverflowLeft
	beq Display
    
	mov r0, r8
	mov r1, r9
 	ldr r2, =str_space
	swi Print

	sub r8, r8, #1
	b PrintCursor
	bne checkPercent

@ Prints the cursor on the left side of the screen, on the same row 
OverflowRight:
	mov r0, r8
	mov r1, r9
 	ldr r2, =str_space
	swi Print

	mov r8, #0

@ Checks if the cursor is going to move to an "illegal" position on the Right side of the LCD screen
@ If it is, it calls OverflowRight otherwise it prints the cursor on the designated place 
@ ('x' = r8 and 'y' = r9)
PrintRight:
	cmp r8, #39
	beq OverflowRight
	beq Display

	mov r0, r8
	mov r1, r9
 	ldr r2, =str_space
	swi Print

	add r8, r8, #1
	b PrintCursor
	bne Start

@ Prints the cursor on the bottom side of the screen on the same column 
OverflowUp:
	mov r0, r8
	mov r1, r9
 	ldr r2, =str_space
	swi Print

	mov r9, #15

@ Checks if the cursor is going to move to an "illegal" position on the Upper side of the LCD screen
@ If it is, it calls OverflowUp otherwise it prints the cursor on the designated place 
@ ('x' = r8 and 'y' = r9)
PrintUp:
	cmp r9, #0
	beq OverflowUp
	beq Display

	mov r0, r8
	mov r1, r9
 	ldr r2, =str_space
	swi Print

	sub r9, r9, #1
	b PrintCursor
	bne Start

@ Prints the cursor on the Upper side of the screen on the same column 
OverflowDown:
	mov r0, r8
	mov r1, r9
 	ldr r2, =str_space
	swi Print
	
	mov r9, #0

@ Checks if the cursor is going to move to an "illegal" position on the bottom side of the LCD screen
@ If it is, it calls OverflowDown otherwise it prints the cursor on the designated place 
@ ('x' = r8 and 'y' = r9)
PrintDown:
	cmp r9, #14
	beq OverflowDown
	beq Display

	mov r0, r8
	mov r1, r9
 	ldr r2, =str_space
	swi Print

	add r9, r9, #1
	b PrintCursor
	bne Start
@ Compares if the content in the cursor's position is a " "
@ If it calls PrintHash otherwise PrintSpace is called
Inverter:
	ldr r5, =LINHA0
	
	ldr r6, =str_space
	cmp r5, r6
    beq PrintHash
	bne PrintSpace

@ Check if the content on the current position of the cursor is " "
@ If it is, it calls RightLED, otherwise LeftLED is called
LED:
	ldr r7, =str_space
	cmp r2, r7
	beq RightLED
	bne LeftLED

@ Lights up the left LED
LeftLED:
	mov r0, #0x01
	swi RedLED
    b Start


@ Lights up the right LED
RightLED:
	mov r0, #0x02
	swi RedLED
    b Start

@ This will create a loop where it compares if any Blue Button has been pressed or not
Start:
    swi BlueB                                       @ Puts in r0 the value of the button pressed
    cmp r0, #0
    bne Display
    
	swi BlackB                                      @ Puts in r0 the value of the button pressed
    cmp r0, #0x01                                   @ Checks if the Left Black Button has been pressed, if it was then LeftB is called 
	beq LeftB
    cmp r0, #0x02                                   @ Checks if the Right Black Button has been pressed, if it was then RightB is called
	beq RightB                                      

	b LED
    b Display

@ This is where it compares with each specific blue buttton
Display:

@ The values that r0 is being compared to are the specific values of the buttons that the question requested 
    cmp r0, #0x02
    beq Up

    cmp r0, #0x08
    beq Space

    cmp r0, #0x10
    beq Left

    cmp r0, #0x40
    beq Right

    cmp r0, #0x80
    beq Hash

    cmp r0, #0x200
    beq Down

    cmp r0, #0x800
    beq Star

    cmp r0, #0x4000
    beq O

    cmp r0, #0x8000
    beq Hyphen

	b Start

@ Initially the idea was for r3 to help with storing the characters ' ', '*', '-', '#', 'O'
Up:
@mov r3, #1
b PrintUp

Space:
@mov r3, #3
b PrintSpace

Left:
@mov r3, #4
b PrintLeft

Right:
@mov r3, #6
b PrintRight

Hash:
@mov r3, #7
b PrintHash

Down:
@mov r3, #9
b PrintDown

Star:
@mov r3, #11
b PrintStar

O:
@mov r3, #14
b PrintO

Hyphen:
@mov r3, #15
b PrintHyphen

@ (Black Right Button) calls inverter
RightB:
b Inverter

@ (Left Black Button) clears the screen and then calls PrintCursor
LeftB:
swi Clear
b PrintCursor

@ Checks the amount of times that the characters, beside " ", have been pressed and if it is 
@  <= 10%(1) -> <= 20%(2) -> <= 30%(3) -> ... -> <= 90% -> == 100%(A) of the amount of positions on the LCD screen (40 * 15 = 600)
@ r10, r11, r12 work as counters for a percentage of the screen if it's 59 or less 
@ it remains on "0", if it's between 59 and 119 it's "1" and so on
checkPercent:
	cmp r2, r13 @ Check if it's a space
	beq Start

	add r10, r10, #1

	cmp r10, #59
	ble Perc0

	cmp r10, #119
	ble Perc1

	cmp r10, #179
	ble Perc2

	cmp r10, #239
	ble Perc3

    add r11, r11, #1

	cmp r11, #59
	ble Perc4

	cmp r11, #119
	ble Perc5

    cmp r11, #179
	ble Perc6

	cmp r11, #239
	ble Perc7

    add r12, r12, #1

	cmp r12, #59
	ble Perc8
	
	cmp r12, #119
	ble Perc9

	cmp r12, #179
	beq PercA

	b Start

@ In this case r6 will be the position of the number or "A" on Digits of the 8-segment Display
Perc0:
	mov r6, #0
	b Key
Perc1:
	mov r6, #1
	b Key
Perc2:
	mov r6, #2
	b Key
Perc3:
	mov r6, #3
	b Key
Perc4:
	mov r6, #4
	b Key
Perc5:
	mov r6, #5
	b Key
Perc6:
	mov r6, #6
	b Key
Perc7:
	mov r6, #7
	b Key
Perc8:
	mov r6, #8
	b Key
Perc9:
	mov r6, #9
	b Key
PercA:
	mov r6, #10
	b Key

@ Each function is printing a number on the 8 Segment Display
Key:
    ldr r1, =Digits                                 @ Load the macros on r1
    ldr r0, [r1, r6, lsl#2]                         @ Puts on r0 the digits and the position stored in r6
    swi Seg8                                        @ Print on the 8-segment Display
    b Start                                         @ Return to the Start loop

@ The initial idea was for this array to store the positions of the LCD screen (x, y)
.data
	LINHA0:   .word
	LINHA1:   .word
	LINHA2:   .word
	LINHA3:   .word
	LINHA4:   .word
	LINHA5:   .word
	LINHA6:   .word
	LINHA7:   .word
	LINHA8:   .word
	LINHA9:   .word
	LINHA10:  .word
	LINHA11:  .word
	LINHA12:  .word
	LINHA13:  .word
	LINHA14:  .word
	LINHA15:  .word
.end