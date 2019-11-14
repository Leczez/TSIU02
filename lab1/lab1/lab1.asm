/*
 * lab1.asm
 *
 *  Created: 2019-11-12 16:05:29
 *   Author: lincl896
 */ 

SETUP:
	;ställer in IO Pinnar och rensar register
	ldi r25,HIGH(RAMEND); set stack
	out SPH,r25; for calls
	ldi r25,LOW(RAMEND);
	out SPL,r25

	ldi r25,$8f
	out DDRB,r25
	ldi r25,$00
	out DDRA, r25
	clr r20 ; nummer
	ldi r23,$08

MAIN:
	call INIT
	call IDLE
	call PRINT
	jmp MAIN

INIT:
	;ställer in register
	ldi r21,$04; räknare
	ldi r16,10
	clr r22
	ret

IDLE:
	sbis PINA,0
	jmp IDLE
	call DELAY
	sbic PINA,0
	call GET_DATA
	ret


DELAY:
	sbi PORTB,7
	//ldi r16,10
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
	ldi r16,20
	call DELAY
	in r19,PINA
	call SORT_DATA
	dec r21
	brne GET_DATA
	ret

SORT_DATA:
	andi r19,$01
	lsr r22
	sbrc r19,0
	add r22,r23
	ret


PRINT:
	ldi r16,20
	call DELAY
	mov r20,r22
	out PORTB,r20
	ret