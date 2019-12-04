
/*
 * lab2.asm
 *
 *  Created: 2019-11-12 16:05:29
 *   Author: lincl896
 */ 

 .equ NHIGH = 0
 .equ NLOW = 70
 .equ BEEPTIME = 40
 .equ SPEED = 10


SETUP:
	;ställer in IO Pinnar och laddar program minnet
	
	ldi r25,HIGH(RAMEND); set stack
	out SPH,r25; for rcalls
	ldi r25,LOW(RAMEND);
	out SPL,r25

	ldi ZH,HIGH(MESSAGE*2)
	ldi ZL,LOW(MESSAGE*2)

	ldi r16,$ff
	out DDRB,r16
	clr r25; För DELAYEN
	clr r24; För DELAYEN
	clr r3
	adiw Z,$00 ;pekare


MAIN:
	ldi ZH,HIGH(MESSAGE*2)
	ldi ZL,LOW(MESSAGE*2)
NEXT:
	lpm r16,Z+
	mov r20,r16	
	cpi r16,$00
	breq MAIN;RESET_Z
	rcall SEND_CHAR
	rjmp NEXT

SEND_CHAR:
	cpi r16,$20
	breq BLANKSPACE
	rcall LOOKUP
	rcall BEEP_CHAR
	rcall NOSOUND
DONE:
	ret

BLANKSPACE:
	ldi r24,NLOW*2
	ldi r25,NHIGH
	rcall DELAY ;NOBEEP *2
	;rcall DELAY ;NOBEEP *2
	;ldi r26,N
	;rcall DELAY ;NOBEEP
	;ldi r26,N
	rjmp DONE

LOOKUP:
	push ZH
	push ZL
	ldi ZH,HIGH(HEX*2)
	ldi ZL,LOW(HEX*2)
	subi r16,$41
	add ZL,r16
	adc ZH,r3
	lpm r17,Z
	pop ZL
	pop ZH
	ret

BEEP_CHAR:
	rcall SEND
	ldi r24,NLOW*2
	ldi r25,NHIGH
	rcall DELAY ;NOBEEP *2
	ret

SEND:
	mov r29,r17
	rcall SEND_BITS
	ret

SEND_BITS:
	rcall BIT
	ret

BIT:
	lsl r17
	breq BITDONE
	rcall BEEP
	rcall NOSOUND
	rjmp BIT
BITDONE:
	ret

BEEP:
	brcs LONG_BEEP
SHORT_BEEP:
	ldi r27,BEEPTIME
	rjmp DOBEEP
LONG_BEEP:
	ldi r27,3*BEEPTIME
DOBEEP:
	rcall SOUND
	ldi r24,NLOW*2
	ldi r25,NHIGH
	rcall DELAY
	ret

DELAY:
	sbiw r24,1
	brne DELAY
	ret

/*DELAY:
	ldi r24,$1F
DELAY1:
	dec r24
	brne DELAY1
	dec r26
	brne DELAY
	ldi r26,2*N
	ret
*/
SOUND:
	sbi PORTB,0
	ldi r24,SPEED
	rcall DELAY
	cbi PORTB,0
	ldi r24,SPEED
	rcall DELAY
	dec r27
	brne SOUND
	ret

NOSOUND:
	ldi r24,NLOW*2
	ldi r25,NHIGH*3
	rcall DELAY ;NOBEEP *2
	ret


MESSAGE:
	;.org 100
	.db "SOS SAAB",$00
HEX:
	;.org $200
	.db $60,$88,$A8,$90,$40,$28,$D0,$08,$20,$78,$B0,$48,$E0,$A0,$F0,$68,$D8,$50,$10,$C0,$30,$18,$70,$98,$B8,$C8,$00