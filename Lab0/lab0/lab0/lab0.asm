/*
 * lab0.asm
 *
 *  Created: 2019-11-07 15:01:50
 *   Author: lincl896
 */ 

.def key = r21; key pressed yes or no
.def number = r20; number 0-9

ldi r16,HIGH(RAMEND)
out SPH,r16
ldi r16,LOW(RAMEND)
out SPL,r16
call INIT
clr number


FOREVER:
	;call GET_KEY
LOOP:
	/*cpi key,0*/
	sbis PINA,1
	jmp loop;breq FOREVER
	out PORTB,number; print digit
	call DELAY
	inc number
	cpi number,10
	brne NOT_10
	clr number
NOT_10:
	;call GET_KEY
	jmp LOOP
/*GET_KEY:
	clr key
	sbic PINA,1
	dec key
	ret*/
INIT:
	clr r16
	out DDRA,r16
	ldi r16,$0F
	out DDRB,r16
	ret
DELAY:
	ldi r18,3
	D_3:
		ldi r17,0
	D_2:
		ldi r16,0
	D_1:
		dec r16
		brne D_1
		dec r17
		brne D_2
		dec r18
		brne D_3
		ret
	
