





SETUP:
	ldi r16,$ff
	out DDRB,r16

MAIN:
	SBI PORTB,0
	jmp MAIN