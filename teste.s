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
        line1:      .skip   160

.text

str_hyphen: .asciz "-"
str_space:  .asciz " "
str_hash:  .asciz "#"
str_star:  .asciz "*"
str_o:  .asciz "O"

.align

swi Clear

mov r0, #0                                          @ Starting the variable with 0
ldr r1, =line0
ldr r2, =str_hash
ldr r4, =str_space

clear_line0:
    str r2, [r1, r0]
    add r0, r0, #4
    cmp r0, #19
    blt clear_line0
    
	cmp r0, #19


    mov r0, #0
    mov r1, #0
    b PrintLine

HashToSpace:
    ldr r3, =str_hash
    
    mov r0, #0
    ldr r1, =line0

    ldr r1, [r2, r0]
    cmp r2, r3
    beq SuppHTS
    
PrintLine:
    @Avançar r0++ e manter r1 
    cmp r0, #19
    beq Start

    add r0, r0, #1
    swi Print

    b PrintLine

SuppHTS:

	ldr r2, =str_space
	str r2, [r1, r0]
    add r0, r0, #4
    cmp r0, #19
    blt SuppHTS

	;cmp r0, #19
	;bge Start
    
    mov r0, #0
    mov r1, #0
    b PrintLine


Start:
	mov r0, #0
	b SuppHTS
