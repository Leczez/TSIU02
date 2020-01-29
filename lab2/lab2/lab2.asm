
/*
 * lab2.asm
 *
 *  Created: 2019-11-12 16:05:29
 *   Author: lincl896
 */ 

 .equ BEEPTIME = 70
 .equ NHIGH = BEEPTIME
 .equ NLOW = $00
 .equ SPEED = 100


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
	clr r3
	;adiw Z,$00 ;pekare


MAIN:
	ldi ZH,HIGH(MESSAGE*2)
	ldi ZL,LOW(MESSAGE*2)
NEXT:
	lpm r16,Z+
	;mov r20,r16	
	cpi r16,$00
	breq MAIN;RESET_Z
	; ascii
	rcall SEND_CHAR
	rjmp NEXT

SEND_CHAR:
	cpi r16,$20
	breq BLANKSPACE
	; a-z
	rcall LOOKUP
	rcall BEEP_CHAR
	rcall NOSOUND
	rjmp DONE
BLANKSPACE:
	ldi r27,BEEPTIME*2
	rcall NOSOUND
	ldi r27,BEEPTIME*2
	rcall NOSOUND
DONE:
	ret

LOOKUP:
	push ZH
	push ZL
	ldi ZH,HIGH(HEX*2)
	ldi ZL,LOW(HEX*2)
	subi r16,$41
	add ZL,r16
	adc ZH,r3
	lpm r16,Z
	pop ZL
	pop ZH
	ret

BEEP_CHAR:
	rcall SEND
	ldi r27,BEEPTIME*2
	rcall NOSOUND
	ret

SEND:
	;mov r29,r17
	rcall BIT
	ret

BIT:
	lsl r16
	breq BITDONE
	rcall BEEP
	ldi r27,BEEPTIME
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
	ret

DELAY:
	sbiw r24,1
	brne DELAY
	ret
SOUND:
	sbi PORTB,0
	rcall CLEAR
	brne SOUND
	ret

NOSOUND:
	cbi PORTB,0
	rcall CLEAR
	brne NOSOUND
	ret
	
CLEAR:
	ldi r24,SPEED
	rcall DELAY
	cbi PORTB,0
	ldi r24,SPEED
	rcall DELAY
	dec r27
	ret


MESSAGE:
	;.org 100
	.db "SOS SAAB ",$00
HEX:
	;.org $200
	.db $60,$88,$A8,$90,$40,$28,$D0,$08,$20,$78,$B0,$48,$E0,$A0,$F0,$68,$D8,$50,$10,$C0,$30,$18,$70,$98,$B8,$C8,$00