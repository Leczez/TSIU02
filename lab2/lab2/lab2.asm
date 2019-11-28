
/*
 * lab2.asm
 *
 *  Created: 2019-11-12 16:05:29
 *   Author: lincl896
 */ 

 .equ N = 60
 .equ BEEPTIME = 40
 .equ SPEED = 10


SETUP:
	;st�ller in IO Pinnar och laddar program minnet
	
	ldi r25,HIGH(RAMEND); set stack
	out SPH,r25; for rcalls
	ldi r25,LOW(RAMEND);
	out SPL,r25

	ldi ZH,HIGH(MESSAGE*2)
	ldi ZL,LOW(MESSAGE*2)

	ldi r16,$ff
	out DDRB,r16

	ldi r20,$00 ; r�knare
	ldi r21,$00 ; r�knare 2
	clr r17 ; BEEP BINARY
	clr r23 ; BEEP OUTPUT
	adiw Z,$00 ;pekare


MAIN:
	ldi ZH,HIGH(MESSAGE*2)
	ldi ZL,LOW(MESSAGE*2)
NEXT:
	rcall GET_CHAR
	cpi r16,$00
	breq MAIN;RESET_Z
	rcall SEND_CHAR

	clr r20
	clr r21
	rjmp NEXT

/*RESET_Z:
	ldi ZH,HIGH(MESSAGE*2)
	ldi ZL,LOW(MESSAGE*2)
	rjmp MAIN*/

; H�mtar en character fr�n program minnet
GET_CHAR:
	lpm r16,Z+
	;adiw Z,1
	/*cpi r16,$00
	breq RESET_Z*/
	ret



SEND_CHAR:
	rcall BEEP_CHAR
	clr r20
	clr r21
	rcall NOSOUND
	rcall GET_CHAR	
	rjmp SEND_CHAR
	ret

BEEP_CHAR:
	rcall LOOKUP
	rcall SEND
	ldi r26,2*N
	rcall DELAY ;NOBEEP *2
	ldi r26,2*N
	rcall DELAY ;NOBEEP *2
	ldi r26,2*N
	rcall DELAY ;NOBEEP *2
	ret

LOOKUP:
	push ZH
	push ZL
	ldi ZH,HIGH(ASCII*2) ; kanske g�nger 2
	ldi ZL,LOW(ASCII*2)
FIND_ASCII:
	lpm r18,Z
	cp r16,r18
	breq LOOKUP_BIT
	adiw Z,1
	inc r20
	rjmp FIND_ASCII

LOOKUP_BIT:
	ldi ZH,HIGH(HEX*2) ; kanske g�nger 2
	ldi ZL,LOW(HEX*2)

FIND_BIT:
	cp r20,r21
	lpm r22,Z
	breq RETURN
	adiw Z,1
	inc r21
	rjmp FIND_BIT

RETURN:
	lpm r17,Z
	pop ZL
	pop ZH
	ret

SEND:
	mov r25, r17
	;rcall GET_BIT
	rcall SEND_BITS
	ret

GET_BIT:
	lsl r17
	ret

SEND_BITS:
	rcall BIT
	ret

BIT:
	rcall BEEP
	rcall NOSOUND
	;rcall GET_BIT
	cpi r17,$80
	brne BIT
	ret

BEEP:
	cpi r25,$01
	breq BLANKSPACE
	lsl r17
	brcs LONG_BEEP
	/*brcc SHORT_BEEP*/
SHORT_BEEP:
	ldi r27,BEEPTIME
	rcall SOUND
	ldi r26,N
	rjmp	BEEPAT
LONG_BEEP:
	ldi r27,3*BEEPTIME
	rcall SOUND
	ldi r26,N
	rjmp	BEEPAT
BLANKSPACE:
	ldi r26,2*N
	rcall DELAY ;NOBEEP *2
	ldi r26,2*N
	rcall DELAY ;NOBEEP *2
	ldi r26,N
	rcall DELAY ;NOBEEP
	ldi r17,$80
	ldi r26,N
	/*rjmp BEEPAT*/
/*SHORT_BEEP:
	ldi r27,BEEPTIME
	rcall SOUND
	ldi r26,N
	rjmp	BEEPAT*/
/*LONG_BEEP:
	ldi r27,3*BEEPTIME
	rcall SOUND
	ldi r26,N*/
BEEPAT:
	rcall DELAY
	ret





DELAY:
	;ldi r23,$0A
DELAY1:
	ldi r24,$1F
DELAY2:
	dec r24
	brne DELAY2
	dec r26
	brne DELAY1
	ret

SOUND:
;	ldi r28,$1F
	sbi PORTB,0
	ldi r26,SPEED
	rcall DELAY
	cbi PORTB,0
	ldi r26,SPEED
	rcall DELAY
;SOUND1:
;	dec r28
;	brne SOUND1
	dec r27
	brne SOUND
	ret

NOSOUND:
	ldi r26,2*N
	rcall DELAY ;NOBEEP *2
	ldi r26,2*N
	rcall DELAY ;NOBEEP *2
	ldi r26,2*N
	rcall DELAY ;NOBEEP *2
	ldi r26,2*N
	rcall DELAY ;NOBEEP *2
	ldi r26,2*N
	rcall DELAY ;NOBEEP *2
	ldi r26,2*N
	rcall DELAY ;NOBEEP *2
	ldi r26,2*N
	rcall DELAY ;NOBEEP *2
	ldi r26,2*N
	rcall DELAY ;NOBEEP *2
	ret


MESSAGE:
	;.org 100
	.db "SOS SAAB",$00
ASCII:
	;.org 100
	.db $20,$41,$42,$43,$44,$45,$46,$47,$48,$49,$4A,$4B,$4C,$4D,$4E,$4F,$50,$51,$52,$53,$54,$55,$56,$57,$58,$59,$5A,$00

HEX:
	;.org 100
	.db $01,$60,$88,$A8,$90,$40,$28,$D0,$08,$20,$78,$B0,$48,$E0,$A0,$F0,$68,$D8,$50,$10,$C0,$30,$18,$70,$98,$B8,$C8,$00