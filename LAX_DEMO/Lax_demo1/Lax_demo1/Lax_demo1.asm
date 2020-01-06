/*
 * Lax_demo1.asm
 *
 *  Created: 2020-01-06 11:04:20
 *   Author: lincl896
 */ 

.org $0000
	rjmp SETUP
.org INT0addr
	rjmp INTERRUPT0



SETUP:

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
	mov r17,r16
	;swap r16
	cpi r16,10
	brmi LESS_THAN_10
	subi r17,10
	ldi r16,$10
	add r16,r17	
LESS_THAN_10:
	swap r16
	out PORTA,r16
	reti