/*
 * lab4.asm
 *
 *  Created: 2019-12-12 15:26:50
 *   Author: lincl896
 */ 


 ; --- lab4spel.asm

	.equ	VMEM_SIZE     = 5		; #rows on display
	.equ	AD_CHAN_X   = $04		; ADC0=PA0, PORTA bit 0 X-led
	.equ	AD_CHAN_Y   = $03		; ADC1=PA1, PORTA bit 1 Y-led
	.equ	GAME_SPEED  = 255	; inter-run delay (millisecs)
	.equ	GAME_SPEED2 = 30
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
;CNT:	.byte	1 ;Counter for the MUX

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

	clr r24
	clr r25 ; DELAY
	clr r3
	;sts CNT,r3

	call	HW_INIT	
	call	WARM
RUN:
	call	JOYSTICK
	call	ERASE_VMEM
	call	UPDATE

;*** 	Vänta en stund så inte spelet går för fort 	**
	ldi r24, GAME_SPEED
	ldi r25, GAME_SPEED2
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
	;cli
	sbiw r24,1
	brne DELAY
	;sei
	ret


	; ---------------------------------------
	; --- Multiplex display
MUX:	

;*** 	skriv rutin som handhar multiplexningen och ***
;*** 	utskriften till diodmatrisen. Öka SEED.		***
	push r16; Y
	push r17; X
	push r18
	push YL
	push YH
	in r18,SREG

	lds r16,LINE
	cpi r16,5
	brne PRINT
RESET_LINE:
	clr r16
PRINT:
	add YL,r16
	adc YH,r3

	clr r17
	out PORTB,r17
	out PORTA,r16
	ld r17,Y
	out PORTB,r17
	inc r16
	sts LINE,r16
/*
	lds r16,SEED
	inc r16
	sts SEED,r16
*/
	out SREG,r18
	pop YH
	pop YL
	pop r18
	pop r17
	pop r16
	reti



SET_Y_POINTER:
	ldi YL,LOW(VMEM)
	ldi YH,HIGH(VMEM)
	ret

INPUT:
	;ADC	
	out ADMUX,r16
	;ADC setup
	ldi r16,(1<<ADEN)|(1<<ADSC)
	out ADCSRA,r16
	in r16,ADCH
	ret


INPUTX:
	push r16
	push r17
	in r17,SREG

	ldi r16,AD_CHAN_X
	rcall INPUT
	cpi r16,0
	brne CHECK_3 
	DECSRAM POSX
	rjmp X_DONE
CHECK_3:
	cpi r16,3
	brne X_DONE
	INCSRAM POSX
X_DONE:
	out SREG,r17
	pop r17
	pop r16
	ret



INPUTY:
	push r16
	push r17
	in r17,SREG

	ldi r16,AD_CHAN_Y
	rcall INPUT
	cpi r16,0
	brne CHECK_Y_3
	DECSRAM POSY
	rjmp Y_DONE
CHECK_Y_3:
	cpi r16,3
	brne Y_DONE
	INCSRAM POSY
Y_DONE:
	out SREG,r17
	pop r17
	pop r16
	ret
	; ---------------------------------------
	; --- JOYSTICK Sense stick and update POSX, POSY
	; --- Uses r16
JOYSTICK:	

;*** 	skriv kod som ökar eller minskar POSX beroende 	***
;*** 	på insignalen från A/D-omvandlaren i X-led...	***


	rcall INPUTX

;*** 	...och samma för Y-led 				***
	rcall INPUTY

/*
	ldi r16,2
	sts POSY,r16
	sts POSX,r16
*/	


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
	cli
	clr	ZH 
	ldi	ZL,LOW(POSX)
	rcall 	SETPOS
	clr	ZH
	ldi	ZL,LOW(TPOSX)
	call	SETPOS
	sei
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

	;sei			; display on
	ret

	; ---------------------------------------
	; --- WARM start. Set up a new game
WARM:
	cli
	rcall SET_Y_POINTER
	call	ERASE_VMEM
;*** 	Sätt startposition (POSX,POSY)=(0,2)		***
	
	sts LINE,r3

	rcall RESET_POS

/*
	push	r0		
	push	r0		
	call	RANDOM		; RANDOM returns x,y on stack

	pop r0
	pop r0
*/
;*** 	Sätt startposition (TPOSX,POSY)				***


	sei
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
	;sts POSX,r16
	st Y+,r16
	ldi r16,(1<<0)
	;sts POSY,r16
	st Y,r16

	pop YL
	pop YH
	ret



	; ---------------------------------------
	; --- Erase Videomemory bytes
	; --- Clears VMEM..VMEM+4
	
ERASE_VMEM:

;*** 	Radera videominnet						***
	cli
	push YL
	push YH
	
	rcall SET_Y_POINTER
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
	sei

	ret

	; ---------------------------------------
	; --- BEEP(r16) r16 half cycles of BEEP-PITCH
BEEP:	

;*** skriv kod för ett ljud som ska markera träff 	***

	ret