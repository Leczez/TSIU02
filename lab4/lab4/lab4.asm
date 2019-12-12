/*
 * lab4.asm
 *
 *  Created: 2019-12-12 15:26:50
 *   Author: lincl896
 */ 


 ; --- lab4spel.asm

	.equ	VMEM_SIZE     = 5		; #rows on display
	.equ	AD_CHAN_X   = $03		; ADC0=PA0, PORTA bit 0 X-led
	.equ	AD_CHAN_Y   = $04		; ADC1=PA1, PORTA bit 1 Y-led
	.equ	GAME_SPEED  = 70	; inter-run delay (millisecs)
	.equ	PRESCALE    = 7		; AD-prescaler value
	.equ	BEEP_PITCH  = 20	; Victory beep pitch
	.equ	BEEP_LENGTH = 100	; Victory beep length
	
	; ---------------------------------------
	; --- Memory layout in SRAM
	.dseg
	.org	SRAM_START
POSX:	.byte	1	; Own position
POSY:	.byte 	1
TPOSX:	.byte	1	; Target position
TPOSY:	.byte	1
LINE:	.byte	1	; Current line	
VMEM:	.byte	VMEM_SIZE ; Video MEMory
SEED:	.byte	1	; Seed for Random

	; ---------------------------------------
	; --- Macros for inc/dec-rementing
	; --- a byte in SRAM
	.macro INCSRAM	; inc byte in SRAM
		lds	r16,@0
		inc	r16
		sts	@0,r16
	.endmacro

	.macro DECSRAM	; dec byte in SRAM
		lds	r16,@0
		dec	r16
		sts	@0,r16
	.endmacro

	; ---------------------------------------
	; --- Code
	.cseg
	.org 	$0
	jmp	START
	.org	INT0addr
	jmp	MUX
		


START:
	ldi r16,HIGH(RAMEND)
	out SPH,r16
	ldi r16,LOW(RAMEND)
	out SPL,r16	

	
	call	HW_INIT	
	call	WARM
RUN:
	call	JOYSTICK
	call	ERASE_VMEM
	call	UPDATE

;*** 	Vänta en stund så inte spelet går för fort 	***
	rcall DELAY
;*** 	Avgör om träff				 	***

/*	brne	NO_HIT	
	ldi	r16,BEEP_LENGTH
	call	BEEP
	call	WARM
*/
NO_HIT:
	jmp	RUN


DELAY:
	ldi r16,GAME_SPEED
DELAY1:
	dec r16
	brne DELAY1
	ret


	; ---------------------------------------
	; --- Multiplex display
MUX:	

;*** 	skriv rutin som handhar multiplexningen och ***
;*** 	utskriften till diodmatrisen. Öka SEED.		***
	push r16
	
	lds r16,line
	cpi r16,5
	breq RESET_Y
	cp r16, r17
	out PORTA,r16
	inc r16
	rjmp DONE
RESET_Y:
	clr r16
	rcall SET_Y_POINTER
DONE:
	sts line,r16
	ld r16,Y+
	out PORTB,r16

	pop r16
	reti

SET_Y_POINTER:
	ldi YL,LOW(VMEM)
	ldi YH,HIGH(VMEM)
	ret

INPUTX:
	;ADC
	
	ldi r16,AD_CHAN_X
	out ADMUX,r16
		
	;ADC setup
	ldi r16,(1<<ADEN)|(1<<ADSC)
	out ADCSRA,r16

	in r16,ADCH
	ret

INPUTY:
	;ADC

	ldi r16,AD_CHAN_Y
	out ADMUX,r16
	
	;ADC setup
	ldi r16,(1<<ADEN)|(1<<ADSC)
	out ADCSRA,r16

	in r16,ADCH
	ret
	; ---------------------------------------
	; --- JOYSTICK Sense stick and update POSX, POSY
	; --- Uses r16
JOYSTICK:	

;*** 	skriv kod som ökar eller minskar POSX beroende 	***
;*** 	på insignalen från A/D-omvandlaren i X-led...	***
	rcall INPUTX
	sbrs r16,0
	DECSRAM POSX
	sbrc r16,0
	INCSRAM POSX
	rcall INPUTY
	sbrs r16,0
	DECSRAM POSY
	sbrc r16,0
	INCSRAM POSY


;*** 	...och samma för Y-led 				***

JOY_LIM:
	call	LIMITS		; don't fall off world!
	ret

	; ---------------------------------------
	; --- LIMITS Limit POSX,POSY coordinates	
	; --- Uses r16,r17
LIMITS:
	lds	r16,POSX	; variable
	ldi	r17,7		; upper limit+1
	call	POS_LIM		; actual work
	sts	POSX,r16
	lds	r16,POSY	; variable
	ldi	r17,5		; upper limit+1
	call	POS_LIM		; actual work
	sts	POSY,r16
	ret

POS_LIM:
	ori	r16,0		; negative?
	brmi	POS_LESS	; POSX neg => add 1
	cp	r16,r17		; past edge
	brne	POS_OK
	subi	r16,2
POS_LESS:
	inc	r16	
POS_OK:
	ret

	; ---------------------------------------
	; --- UPDATE VMEM
	; --- with POSX/Y, TPOSX/Y
	; --- Uses r16, r17
UPDATE:	
	clr	ZH 
	ldi	ZL,LOW(POSX)
	rcall 	SETPOS
	clr	ZH
	ldi	ZL,LOW(TPOSX)
	call	SETPOS
	ret

	; --- SETPOS Set bit pattern of r16 into *Z
	; --- Uses r16, r17
	; --- 1st call Z points to POSX at entry and POSY at exit
	; --- 2nd call Z points to TPOSX at entry and TPOSY at exit
SETPOS:
	ld	r17,Z+  	; r17=POSX
	call	SETBIT		; r16=bitpattern for VMEM+POSY
	ld	r17,Z		; r17=POSY Z to POSY
	ldi	ZL,LOW(VMEM)
	add	ZL,r17		; *(VMEM+T/POSY) ZL=VMEM+0..4
	ld	r17,Z		; current line in VMEM
	or	r17,r16		; OR on place
	st	Z,r17		; put back into VMEM
	ret
	
	; --- SETBIT Set bit r17 on r16
	; --- Uses r16, r17
SETBIT:
	ldi	r16,$01		; bit to shift
SETBIT_LOOP:
	dec 	r17			
	brmi 	SETBIT_END	; til done
	lsl 	r16		; shift
	jmp 	SETBIT_LOOP
SETBIT_END:
	ret

	; ---------------------------------------
	; --- Hardware init
	; --- Uses r16
HW_INIT:

;*** 	Konfigurera hårdvara och MUX-avbrott enligt ***
;*** 	ditt elektriska schema. Konfigurera 		***
;*** 	flanktriggat avbrott på INT0 (PD2).			***
	
	
	ldi r16,(1<<ISC01)|(1<<ISC00)
	out MCUCR,r16

	ldi r16,(1<<INT0)
	out GICR,r16

	ldi r16,$FF
	out DDRB,r16
	ldi r16,$07
	out DDRA,r16

	rcall SET_Y_POINTER

	sei			; display on
	ret

	; ---------------------------------------
	; --- WARM start. Set up a new game
WARM:

;*** 	Sätt startposition (POSX,POSY)=(0,2)		***
	rcall RESET_POS

	;push	r0		
	;push	r0		
	call	RANDOM		; RANDOM returns x,y on stack

;*** 	Sätt startposition (TPOSX,POSY)				***

	call	ERASE_VMEM
	ret

	; ---------------------------------------
	; --- RANDOM generate TPOSX, TPOSY
	; --- in variables passed on stack.
	; --- Usage as:
	; ---	push r0 
	; ---	push r0 
	; ---	call RANDOM
	; ---	pop TPOSX 
	; ---	pop TPOSY
	; --- Uses r16
RANDOM:
	in	r16,SPH
	mov	ZH,r16
	in	r16,SPL
	mov	ZL,r16
	lds	r16,SEED
	
;*** 	Använd SEED för att beräkna TPOSX		***
;*** 	Använd SEED för att beräkna TPOSX		***

;	***		; store TPOSX	2..6
;	***		; store TPOSY   0..4
	ret



RESET_POS:
	push YH
	push YL
	rcall SET_Y_POINTER
	
	clr r16
	sts POSX,r16
	st Y+,r16
	ldi r16,(1<<0)
	sts POSY,r16
	st Y,r16

	pop YL
	pop YH
	ret

	; ---------------------------------------
	; --- Erase Videomemory bytes
	; --- Clears VMEM..VMEM+4
	
ERASE_VMEM:

;*** 	Radera videominnet						***
	push YL
	push YH
	
	call SET_Y_POINTER
	clr r16
	clr r17
CLEAR_VM:
	st Y+,r16
	cpi r17,5
	breq EXIT
	inc r17
	rjmp CLEAR_VM
EXIT:
	pop YH
	pop YL

	ret

	; ---------------------------------------
	; --- BEEP(r16) r16 half cycles of BEEP-PITCH
BEEP:	

;*** skriv kod för ett ljud som ska markera träff 	***

	ret