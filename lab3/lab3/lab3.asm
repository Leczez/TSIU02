/*
 * lab3.asm
 *
 *  Created: 2019-12-06 10:40:34
 *   Author: lincl896
 */ .org $0000
	jmp SETUP

	.org $0002
 	jmp INTERRUPT0

	.org $0004
	jmp INTERRUPT1

	.equ CNT = $60

SETUP:

	ldi r16,HIGH(RAMEND)
	out SPH,r16
	ldi r16,LOW(RAMEND)
	out SPL,r16

	ldi r16,$FF
	out DDRB,r16
	ldi r16,$FF
	out DDRA,r16

	ldi r16,(1<<ISC01)|(1<<ISC00)|(1<<ISC11)|(1<<ISC10)
	out MCUCR, r16
	
	ldi r16,(1<<INT0)|(1<<INT1)
	out GICR,r16

	ldi r17, $FF
	sts CNT, r17
MAIN:
	sei
	sleep
	rjmp MAIN


/* MUX:

	ret ; kanske reti
*/

INTERRUPT1:
	cli
	rcall SAVE_STATUS_REGISTER
	lds r17,CNT
	out PORTB,r17
	rcall RESTORE_STATUS_REGISTER
	reti


INTERRUPT0:
	cli
	rcall SAVE_STATUS_REGISTER
	lds r17,CNT
	out PORTB,r17
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