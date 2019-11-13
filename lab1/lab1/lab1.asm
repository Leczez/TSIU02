/*
 * lab1.asm
 *
 *  Created: 2019-11-12 16:05:29
 *   Author: lincl896
 */ 

INIT:
	ldi r25,$ff
	out DDRB,r15
	ldi r25,$00
	out DDRA, r15


IDLE:
	breq GET_DATA
	jmp IDLE


DELAY:
	sbi PORTB,7
	ldi r16,10
DelayYttreLoop:
	ldi r17,$1F
DelayInreLoop:
	dec r17
	brne DelayInreLoop
	dec r16;
	brne DelayYttreLoop
	cbi PORTB,7
	ret

GET_DATA:
	clr r19
	in r19,PINA0
	Call DELAY
	brne GET_DATA
	out PORTB,r19
	ret