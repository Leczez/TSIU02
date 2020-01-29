/*
 * lab3.asm
 *
 *  Created: 2019-12-06 10:40:34
 *   Author: lincl896
 */ 
.org $0000
	rjmp SETUP
<<<<<<< HEAD
.org $0010
	rjmp INTERRUPT1
.org $0012
	rjmp INTERRUPT0


=======
.org INT0addr
	rjmp INTERRUPT0
.org INT1addr
	rjmp INTERRUPT1
>>>>>>> master
.equ LSEC = $100
.equ HSEC = $101
.equ LMIN = $102
.equ HMIN = $103

<<<<<<< HEAD
.equ SECOND = 15624

=======
>>>>>>> master
SETUP:

	ldi r16,HIGH(RAMEND)
	out SPH,r16
	ldi r16,LOW(RAMEND)
	out SPL,r16

	ldi r16,$FF
	out DDRB,r16
	ldi r16,$FF
	out DDRA,r16

<<<<<<< HEAD
	ldi r16,(1<<WGM13)|(1<<WGM12)|(1<<CS10)|(1<<CS11)
	out TCCR1B,r16
	ldi r16,(1<<WGM11)|(0<<WGM10)
	out TCCR1A,r16

	ldi r16,LOW(SECOND)
	ldi r17,HIGH(SECOND)

	out ICR1H,r17
	out ICR1L,r16

	ldi r16,(1<<TOIE1)|(1<<TOIE0)
	out TIMSK,r16

	ldi r16,(1<<WGM01)|(1<<WGM00)|(0<<CS01)|(1<<CS00)
	out TCCR0,r16

/*
=======
>>>>>>> master
	ldi r16,(1<<ISC01)|(1<<ISC00)|(1<<ISC11)|(1<<ISC10)
	out MCUCR, r16
	
	ldi r16,(1<<INT0)|(1<<INT1)
	out GICR,r16
<<<<<<< HEAD
*/
=======
>>>>>>> master

	clr r3
	clr r17
	clr r19

	sts LSEC,r17
	sts HSEC,r17
	sts LMIN,r17
	sts HMIN,r17
<<<<<<< HEAD
	 
=======

>>>>>>> master
	rcall LOAD_Y

	sei

MAIN:
	rjmp MAIN


LOAD_Y:	
	ldi YL,LOW(LSEC)
	ldi YH,HIGH(LSEC)
	ret

CHECK_10:
	ld r17,Y
	ldi r18,10
	rcall INC_TIME
	ret
CHECK_6:
	ld r17,Y
	ldi r18,6
	rcall INC_TIME
	ret

INC_TIME:
	cp r17,r18
	breq DO
	st Y+,r17
	rjmp DID
DO:
	ldi r17,$00
	st Y+,r17
	ld r17,Y
	inc r17
	st Y,r17
DID:
	ret

INTERRUPT1:
	;cli
	push r16
	push r20
	in r20,SREG
	push YL
	push YH
	rcall LOAD_Y
	
	ld r17,Y
	inc r17
	st Y,r17
		
	rcall CHECK_10
	rcall CHECK_6
	rcall CHECK_10

	ld r17,Y
	cpi r17,6
	breq RESET
	rjmp DONE
RESET:
	ldi r17,0
	sts LSEC,r17
	sts HSEC,r17
	sts LMIN,r17
	sts HMIN,r17
DONE:
	pop YH
	pop YL
	out SREG,r20
	pop r20
	pop r16
	reti



INTERRUPT0:
	push r16
	push r20
	in r20,SREG

	ld r17,Y+
	rcall OUTPUT
	inc r19
	cpi r19,4
	breq RESET_Y
	jmp EXIT
RESET_Y:
	rcall LOAD_Y
	clr r19
EXIT:
	out SREG,r20
	pop r20
	pop r16
	reti

LOOKUP:
	ldi ZL,LOW(TIME*2)
	ldi ZH,HIGH(TIME*2)

	add ZL,r17
	adc ZH,r3

	lpm r16,Z
	ret
	
OUTPUT:
	rcall LOOKUP
	out PORTA,r19
	out PORTB,r16
	ret



TIME:
	.db $3F,$06,$5B,$4F,$66,$6D,$7D,$07,$7F,$6F