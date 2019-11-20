
/*
 * lab2.asm
 *
 *  Created: 2019-11-12 16:05:29
 *   Author: lincl896
 */ 

SETUP:
	;ställer in IO Pinnar och laddar program minnet
	
	ldi r25,HIGH(RAMEND); set stack
	out SPH,r25; for calls
	ldi r25,LOW(RAMEND);
	out SPL,r25

	ldi ZH,HIGH(MESSAGE*2)
	ldi ZL,LOW(MESSAGE*2)

	ldi r16,$ff
	out DDRB,r16

	ldi r20,$00 ; räknare
	ldi r21,$00 ; räknare 2
	clr r17 ; BEEP BINARY
	clr r23 ; BEEP OUTPUT
	adiw Z,$00 ;pekare


MAIN:
	call GET_CHAR
	call SEND_CHAR
	clr r20
	clr r21
	jmp MAIN

; Hämtar en character från program minnet
GET_CHAR:
	lpm r16,Z
	adiw Z,1
	cpi r16,$00
	breq RESET_Z
	ret

RESET_Z:
	ldi ZH,HIGH(MESSAGE*2)
	ldi ZL,LOW(MESSAGE*2)
	jmp MAIN

SEND_CHAR:
	call BEEP_CHAR
	clr r20
	clr r21
	call GET_CHAR	
	jmp SEND_CHAR


BEEP_CHAR:
	call LOOKUP
	call SEND
	ldi r26,80
	call NOBEEP
	ret

LOOKUP:
	push ZH
	push ZL
	ldi ZH,HIGH(ASCII*2) ; kanske gånger 2
	ldi ZL,LOW(ASCII*2)
FIND_ASCII:
	lpm r18,Z
	cp r16,r18
	breq LOOKUP_BIT
	adiw Z,1
	inc r20
	jmp FIND_ASCII

LOOKUP_BIT:
	ldi ZH,HIGH(HEX*2) ; kanske gånger 2
	ldi ZL,LOW(HEX*2)

FIND_BIT:
	cp r20,r21
	lpm r22,Z
	breq RETURN
	adiw Z,1
	inc r21
	jmp FIND_BIT

RETURN:
	lpm r17,Z
	pop ZL
	pop ZH
	ret

SEND:
	mov r25, r17
	call GET_BIT
	call SEND_BITS
	ret

GET_BIT:
	lsl r17
	ret

SEND_BITS:
	call BIT
	ret

BIT:
	call BEEP
	ldi r26,10
	call NOBEEP
	call GET_BIT
	cpi r17,$00
	breq RETURN_BIT
	jmp BIT
RETURN_BIT:
	ret

BEEP:
	cpi r25,$01
	;ldi r27,25
	breq BLANKSPACE 
	brcs LONG_BEEP
;	brcc SHORT_BEEP
SHORT_BEEP:
	ldi r27,10
	call SOUND
	ldi r26,10
	jmp	BEEPAT
LONG_BEEP:
	ldi r27,30
	call SOUND
	ldi r26,30
BEEPAT:
	;call DELAY
	cbi PORTB,0
	ret


BLANKSPACE:
	ldi r26,255
	jmp BEEPAT

NOBEEP:
	call DELAY
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
	ldi r28,$1F
	sbi PORTB,0
	ldi r26,10
	call DELAY
	cbi PORTB,0
SOUND1:
	dec r28
	brne SOUND1
	dec r27
	brne SOUND
	
	ret

MESSAGE:
	;.org 100
	.db "SOS",$00
ASCII:
	;.org 100
	.db $20,$41,$42,$43,$44,$45,$46,$47,$48,$49,$4A,$4B,$4C,$4D,$4E,$4F,$50,$51,$52,$53,$54,$55,$56,$57,$58,$59,$5A,$00

HEX:
	;.org 100
	.db $01,$60,$88,$A8,$90,$40,$28,$D0,$08,$20,$78,$B0,$48,$E0,$A0,$F0,$68,$D8,$50,$10,$C0,$30,$18,$70,$98,$B8,$C8,$00