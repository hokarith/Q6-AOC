@ Just a code to use the buttons 'Left' and 'Right'
@ and the 0.0 to 3.3
@ Are there better solutions for this use in specific, just use as example

@ Those are bind to use the Software Interuptions Quickier
.equ Seg8, 0x200                                    @ Display on the 8 Segments the value in r0
.equ Print, 0x204                                   @ Display on the LCD the value in r2
.equ BlackB, 0x202                                  @ Put in r0 the button pressed (left/right)
.equ BlueB, 0x203                                   @ Put in r0 the button pressed (0-15)
.equ Clear, 0x206									@ Clear display
.equ RedLED, 0x201									@ Turn on Red LED

@ Those are binds for each one on 8 segment display
.equ SEG_A,0x80
.equ SEG_B,0x40
.equ SEG_C,0x20
.equ SEG_P,0x10
.equ SEG_D,0x08
.equ SEG_E,0x04
.equ SEG_F,0x02
.equ SEG_G,0x01

.data
.align 4       @ Memory location divisible by 4
        line0:      .skip   160      @ allocates 40 positions

.text

@ Binds for the characters used on the program
str_hyphen: .asciz "-"
str_space:  .asciz " "
str_hash:  .asciz "#"
str_star:  .asciz "*"
str_o:  .asciz "O"

.align

@ Clear the LCD Display
swi Clear

mov r0, #0                                          @ Starting the variable with 0
mov r1, #0                                          @ Starting the variable with 0
ldr r11, =line0
ldr r12, =str_hash

clear_line0:
    str r12, [r11, r0]
    add r0, r0, #4
    cmp r0, #159
    blt clear_line0

	mov r0, #0
    b PrintLine

PrintLine:
    cmp r0, #39
    bge Start

	mov r1, #0

    add r0, r0, #1
	ldr r2, [r12, r0]
    swi Print

	b PrintLine

mov r0, #0                                          @ Starting the variable with 0
mov r1, #0                                          @ Starting the variable with 0
mov r2, #0                                          @ Starting the variable with 0
mov r5, #0										    @ Starting the variable with 0
mov r7, #0										    @ Starting the variable with 0
mov r8, #0										    @ Starting the variable with 0
mov r9, #0											@ Starting the variable with 0

PrintCursor:

	mov r0, r8
	mov r1, r9
 	ldr r2, =str_hyphen
	swi Print
	b Start

ClearCursor:


PrintSpace:

	mov r0, r8
	mov r1, r9
	mov r3, #0
	mul r3, r0, r1
	ldr r4, =line0
 	ldr r2, =str_space
	str r2, [r4,r3]
	swi Print
	b Start

PrintHash:

	mov r0, r8
	mov r1, r9
	mov r3, #0
	mul r3, r0, r1
	ldr r4, =line0
 	ldr r2, =str_hash
	str r2, [r4,r3]
	swi Print
	b Start

PrintStar:

	mov r0, r8
	mov r1, r9
	mov r3, #0
	mul r3, r0, r1
	ldr r4, =line0
 	ldr r2, =str_star
 	str r2, [r4,r3]
	swi Print
	b Start

PrintHyphen:

	mov r0, r8
	mov r1, r9
	mov r3, #0
	mul r3, r0, r1
	ldr r4, =line0
 	ldr r2, =str_hyphen
	str r2, [r4,r3]
	swi Print
	b Start

PrintO:

	mov r0, r8
	mov r1, r9
	mov r3, #0
	mul r3, r0, r1
	ldr r4, =line0
 	ldr r2, =str_o
	str r2, [r4,r3]
	swi Print
	b Start

OverflowLeft:
	mov r0, r8
	mov r1, r9
 	ldr r2, =str_space
	swi Print

	mov r8, #40
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
	bne Start

OverflowRight:
	mov r0, r8
	mov r1, r9
 	ldr r2, =str_space
	swi Print

	mov r8, #0
PrintRight:
	cmp r8, #39
	beq OverflowRight
	beq Display

	mov r0, r8
	mov r1, r9
	mul r3, r0, r1
	ldr r4, =line0
	ldrb r2, [r4, r3]
	swi Print

	add r8, r8, #1
	b PrintCursor
	bne Start

OverflowUp:
	mov r0, r8
	mov r1, r9
 	ldr r2, =str_space
	swi Print

	mov r9, #15
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

OverflowDown:
	mov r0, r8
	mov r1, r9
 	ldr r2, =str_space
	swi Print

	mov r9, #0
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

Churewons:
	ldr r6, =str_space
	cmp r5, r6
    beq PrintHash
	bne PrintSpace

LED:
	ldr r7, =str_space
	cmp r2, r7
	beq RightLED
	bne LeftLED

LeftLED:
	mov r0, #0x01
	swi RedLED
    b Start

RightLED:
	mov r0, #0x02
	swi RedLED
    b Start

@ This will create a loop where it compares if any Blue Button was pressed or not
Start:
    swi BlueB                                       @ Puts in r0 the value of the button pressed
    cmp r0, #0
    bne Display

	swi BlackB                                      @ Puts in r0 the value of the button pressed
    cmp r0, #0x01
	beq LeftB
    cmp r0, #0x02
	beq RightB

	b LED
    b Display

    beq Start                                       @ Here's where the loop starts again


@ This is where it compares with each specific buttton

Display:
                                                    @ As the macro runs, it will pull the position. '0' in this case

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

Up:
mov r3, #1
b PrintUp

Space:
mov r3, #3
b PrintSpace

Left:
mov r3, #4
b PrintLeft

Right:
mov r3, #6
b PrintRight

Hash:
mov r3, #7
b PrintHash

Down:
mov r3, #9
b PrintDown

Star:
mov r3, #11
b PrintStar

O:
mov r3, #14
b PrintO

Hyphen:
mov r3, #15
b PrintHyphen

RightB:
b Churewons

LeftB:
swi Clear
b PrintCursor

@ Each function is printing a number (in hexa) on the 8 Segment Display
Key:
    ldr r0, [r1, r3, lsl#2]                         @ Puts on r0 the digits and the position you choose
    swi Seg8                                        @ Print on the Display
    b Start                                         @ Return to the code loop

.end
