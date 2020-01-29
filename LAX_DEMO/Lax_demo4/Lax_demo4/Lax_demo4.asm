/*
 * Lax_demo4.asm
 *
 *  Created: 2020-01-06 14:56:42
 *   Author: lincl896
 */ 

.org $0000
	rjmp SETUP
.org INT0addr
	rjmp INTERRUPT0

SETUP:

.equ TEMP = $60
	
	ldi r16,HIGH(RAMEND)
	out SPH,r16
	ldi r16,LOW(RAMEND)
	out SPL,r16

	rcall HW_INIT

	sei

MAIN:

	rjmp MAIN


HW_INIT:
	
	ldi r16,(1<<ISC00)|(1<<ISC01)
	out MCUCR,r16

	ldi r16,(1<<INT0)
	out GICR,r16

	ldi r16,$FF
	out DDRA,r16

	clr r16
	out DDRB,r16

	ret

INTERRUPT0:

	in r16,PINB

	cpi r16,$00
	brne PRINT

	brts CLR_T
	set
	rjmp PRINT
CLR_T:
	clt

PRINT:
	cpi r16,$00
	breq DO_PRINT
	mov r18,r16
	swap r16
	brts INVERT
NORMAL:
	rjmp SET_R20
INVERT:
	;ori r18,$0F	
	;swap r18
	com r18
	andi r18,$0F
	
SET_R20:
	or r16,r18
	swap r16
	mov r20,r16
DO_PRINT:
	
	out PORTA,r20	

	reti