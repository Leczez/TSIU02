/*
 * Lax_demo3.asm
 *
 *  Created: 2020-01-06 13:19:23
 *   Author: lincl896
 */ 


 ;LAX 4 I häftet

.org $0000
	rjmp SETUP
.org INT0addr
	rjmp INTERRUPT0

SETUP:

.equ THIGH = $60
.equ TLOW = $61
.equ TEMP = $62
	ldi r16,HIGH(RAMEND)
	out SPH,r16
	ldi r16,LOW(RAMEND)
	out SPL,r16

	rcall HW_INIT

	sei

MAIN:
	rjmp MAIN



HW_INIT:
	
	ldi r16,(1<<ISC00)|(1<<ISC01)
	out MCUCR,r16

	ldi r16,(1<<INT0)
	out GICR,r16
	
	ldi r16,$FF
	out DDRA,r16

	clr r16
	out DDRB,r16

	ret

INTERRUPT0:

	in r16,PINB
	cpi r16,$0F
	brne PRINT

	brts T_IS_SET
	set
	rjmp PRINT
	
T_IS_SET:
	clt

PRINT:

	brts T_SET
T_CLEAR:
	;vänster segment
	cpi r16,$0F
	breq DO_PRINT
	sts TLOW,r16
	rjmp DO_PRINT

T_SET:
	;höger segment
	cpi r16,$0F
	breq DO_PRINT
	swap r16
	sts THIGH,r16


DO_PRINT:
	lds r16,TLOW
	lds r17,THIGH
	or r16,r17
	mov r20,r16
	out PORTA,r20
	reti



SWAP_DISPLAY:
	

	ret