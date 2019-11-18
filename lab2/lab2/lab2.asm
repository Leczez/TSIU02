
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

	ldi r16,$01
	out DDRB,r16

	ldi r20,$00 ; räknare
	ldi r21,$00 ; räknare 2
	clr r17 ; BEEP BINARY
	clr r23 ; BEEP OUTPUT
	adiw Z,$00 ;pekare


MAIN:
	call GET_CHAR
	call SEND_CHAR
	inc r20
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

SEND_CHAR:
	call BEEP_CHAR
	call GET_CHAR	
	jmp SEND_CHAR


BEEP_CHAR:
	call LOOKUP
	;call SEND
	;call NOBEEP
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
	ldi ZH,HIGH(BIT*2) ; kanske gånger 2
	ldi ZL,LOW(BIT*2)

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
	mov r23, r17
	call GET_BIT
	call SEND_BITS
	ret

GET_BIT:
	rol r23
	ret

SEND_BITS:
	call BIT
	ret

BIT:
	call BEEP
	call NOBEEP
	call GET_BIT
	;lägg till skip instruktion här!!!!
	jmp BIT
	ret

MESSAGE:
	;.org 100
	.db "SOS",$00
ASCII:
	;.org 100
	.db $41,$42,$43,$44,$45,$46,$47,$48,$49,$4A,$4B,$4C,$4D,$4E,$4F,$50,$51,$52,$53,$54,$55,$56,$57,$58,$59,$5A,$00

BIT:
	;.org 100
	.db $60,$88,$A8,$90,$40,$28,$D0,$08,$20,$78,$B0,$48,$E0,$A0,$F0,$68,$D8,$50,$10,$C0,$30,$18,$70,$98,$B8,$C8,$00