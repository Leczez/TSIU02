/*
 * Lax_demo2.asm
 *
 *  Created: 2020-01-06 11:13:19
 *   Author: lincl896
 */
.org $0000
	rjmp SETUP
.org INT0addr
	rjmp INTERRUPT0
.org INT1addr
	rjmp INTERRUPT1


SETUP:

	ldi r16,HIGH(RAMEND)
	out SPH,r16
	ldi r16,LOW(RAMEND)
	out SPL,r16

	ldi r16,(1<<ISC01)|(1<<ISC00)|(1<<ISC11)|(1<<ISC10)
	out MCUCR,r16

	ldi r16,(1<<INT0)|(1<<INT1)
	out GICR,r16

	ldi r16,$0F
	out DDRA,r16

	ldi r16,$0F
	out DDRB,r16

	sei

MAIN:
	rjmp MAIN








INTERRUPT0:
	inc r20
	reti


INTERRUPT1:
	;mov r17,r20
	out PORTB,r20

	reti