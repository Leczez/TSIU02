/*
 * lab3.asm
 *
 *  Created: 2019-12-06 10:40:34
 *   Author: lincl896
 */ 


 SETUP:

	ldi r16,HIGH(RAMEND)
	out SPH,r16
	ldi r16,LOW(RAMEND)
	out SPL,r16

	ldi r16,$FF
	out DDRB,r16
	ldi r16,$07
	out DDRA,r16



	sei

MAIN:
	sleep
	rjmp MAIN


 MUX:

	ret ; kanske reti


INTERRUPT1:
	rcall SAVE_STATUS_REGISTER

	rcall RESTORE_STATUS_REGISTER
	reti


INTERRUPT0:
	rcall SAVE_STATUS_REGISTER

	rcall RESTORE_STATUS_REGISTER
	reti

SAVE_STATUS_REGISTER:
	push r16
	in r16,SREG
	ret

RESTORE_STATUS_REGISTER:
	out SREG,r16
	pop r16
	ret