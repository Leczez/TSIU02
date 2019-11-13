/*
 * lab1.asm
 *
 *  Created: 2019-11-12 16:05:29
 *   Author: lincl896
 */ 

INIT:
	ldi r25,$ff
	out DDRB,r25
	ldi r25,$00
	out DDRA, r25
	ldi r21,$04; räknare
	clr r20 ; nummer
	clr r22 ; delay eller inte 1/0

IDLE:
	sbis PINA,0
	jmp IDLE
	jmp GET_DATA


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
	inc r22;

GET_DATA:
	sbrs r22,0
	call DELAY
	dec r22
	in r19,PINA0
	add r20,r19
	dec r21
	breq PRINT
	jmp GET_DATA

PRINT:
	out PORTB,r20
	jmp IDLE