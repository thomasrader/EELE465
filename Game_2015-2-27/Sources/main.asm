;*******************************************************************
;* Authors: Seth Kreitinger and Tom Rader						   *
;*  Changes:													   *
;*	Initial Version		2015-2-16, 14:01p                          *
;* 	Added LCD stuff		2015-2-27, 13:11p						   *
;*******************************************************************

; Include derivative-specific definitions
            INCLUDE 'derivative.inc'
            INCLUDE 'main_headers.inc'
            XREF MCU_init, keyBoardScan, LCD_init, write_LCD, clear_LCD, check_line_end, setup_custom_character
            XREF Animation_init,Animation_update, Animate_left, Animate_right

; export symbols
            XDEF _Startup, main, heartbeat_counter, interruptFlags
            XDEF colValue, rowValue, rowCol 	; These are for the keyboard scan
            XDEF LCD_char, LCD_char_pos, ASCII_table
        	
            
            ; we export both '_Startup' and 'main' as symbols. Either can
            ; be referenced in the linker .prm file or from C/C++ later on
            
            
            
            XREF __SEG_END_SSTACK   ; symbol defined by the linker for the end of the stack


; variable/data section
MY_ZEROPAGE: SECTION  SHORT         ; Insert here your data definition
		heartbeat_counter: DS.B 1
		interruptFlags: DS.B 1 		; heartbeat; 0; Hit; Left; Right; keydebounce; keyhit; 1s timer;
		rowValue: 	DS.B 1			; Holds values we send to keypad HC273 (rows)
		colValue: 	DS.B 1			; Hold keypad values (columns)
		rowCol:	  	DS.B 1			; Table offset for keyboard value array
		LCD_char:  	DS.B 1			; Hold the char to be sent to LCD
		LCD_char_pos: DS.B 1		; Holds the character to be written's  position
		First_Row_Blocks: DS.B 8 	; Hold the position and state of every block in the first row in half nibbles(2bits)
		Second_Row_Blocks: D.S B 8  ; Hold the position and state of every block in the second row in half nibbles(2bits)
		Random_seed:	   DS.B 1		; Hold the counter value when a button is pressed as random block seed						
MyConst: SECTION
		keyboard_table: DC.B $01, $04, $07, $0E, $02, $05, $08, $00, $03, $06, $09, $0F, $0A, $0B, $0C, $0D, $FF ; $0E and $0F are # and *, respectively. The 0xFF is for keycheckin'
		ASCII_table: 	DC.B $00, $34, $37, $45, $32, $35, $38, $30, $33, $36, $39, $46, $41, $42, $43, $44, $FF ; $0E and $0F are # and *, respectively. The 0xFF is for keycheckin'
		Char_table:		DC.B $1B, $00, $0E, $11, $11, $15, $0E		; Frogman Jones straight on
						;DC.B $
		
; code section
MyCode:     SECTION

		
main:		
_Startup:
            LDHX   #__SEG_END_SSTACK ; initialize the stack pointer
            TXS
			; Call generated device initialization function, including turning the reset button on
			JSR    MCU_init
			
			; Configure Port A to output
			LDA #$FF
			ORA PTADD
			STA PTADD  
			
			; Configure Port B to output
			LDA #$FF
			ORA PTBDD
			STA PTBDD  
			
			; Ensure HC138 is not enabling any of the other chips
			BSET 3, PTBD
			
			; Enable STOP mode
			LDA SOPT1
			ORA #$20
			STA SOPT1
			
			; Choose STOP3
			LDA SPMSC1
			ORA #$C
			STA SPMSC1
			
		;Variable initialization - RAM will have a random value in it, and we want the reset value to be known 
		;
			; initialize heartbeat_counter
			LDA #$3E  ; We are decrementing out heartbeat counter in the ISR. 0x3E is 60 in decimal
			STA heartbeat_counter 
		
			MOV #$00, interruptFlags
			
			
			LDA #$EF  		; This is what rowValue gets set to after it resets
			STA rowValue
			
			; Set keyboard entry to A which is $0C
			LDA #$0C
			STA rowCol
			
			; Start up MTIM disabled
			BSET 4, MTIMSC
			
			LDA #$C8			; Column two Row 8 of LCD with write bit set
			STA LCD_char_pos
			
	;; DEVICE initializations
			; Inline LED's
			MOV #$F0, PTBD ; Make Lower LEDS off
			BSET 3, PTBD
			
			MOV #$F1, PTBD ; Make Upper LEDS off
			BSET 3, PTBD	
			
			JSR LCD_init
			JSR setup_custom_character
			JSR Animation_init		; Display the character

mainLoop:
			
			BSR checkFlags
			JSR keyBoardScan
			JSR Animation_update
            ; feed_watchdog -- By default COP is disabled with device init. When enabling, also reset the watchdog. */
            BRA    mainLoop
            
 ; checkFlags subroutine - Checks if an interrupt flag has triggered
            
checkFlags:
	LDA interruptFlags

	; Check for key hit flag
	BIT #$02
	BEQ checkFlagsTimer
	BCLR 1, interruptFlags 	; Reset key hit flag, okay because variable address is under 0xFF
	;;BCLR 2, interruptFlags 	; Reset key timer flag
	
	;  rowCol gets pushed to stack so we can retain an old value
	LDA rowCol
	PSHA 
	
	; Scan the keypad again
	; If a key isn't hit, rowCol won't be updated by keyBoardScan, so it would always
	; trigger if you just tapped the button. We overwrite the value of rowCol so we know if a key was hit again
	LDA #$10   
	STA rowCol 
	JSR keyBoardScan ; scan keypad again
	
	PULA 	; resurrect old rowCol
	CMP rowCol ; compare with the new rowCol
	BEQ checkFlagsTimer ; key is still down
	
	; Key up, time to deal with it
	STA rowCol 	; store the old key hit, because the new one is probably garbage
	BCLR 1, interruptFlags ; key up event, so we can begin looking for a new key hit
	
	; grab the key that was hit
	CLRH
	LDX rowCol
	LDA keyboard_table, X
	BSR updateLEDs

	CLRH
	LDX rowCol
	LDA keyboard_table, X	; LCD_Char
	
	CBEQA #$0A, A_hit
	CBEQA #$02, Two_hit
	CBEQA #$0E, Star_hit
	BRA other_hit
A_hit:
		; Go left
		BSET 3, interruptFlags
		;JSR Animate_left
		BRA checkFlagsTimer
Two_hit:
		; Go right
		BSET 4, interruptFlags
		;JSR Animate_right
		BRA checkFlagsTimer
Star_hit:
		; Hit
		BSET 5, interruptFlags
		BRA checkFlagsTimer
other_hit:
		CLRH
		LDX rowCol
		LDA ASCII_table, X	; LCD_Char
		LDX LCD_char_pos		; character position
		JSR write_LCD
		
	;JSR check_line_end


	;BSET 4, MTIMSC ; Stop the timer so we don't have a useless interrupt fire in 1s
	;BSET 5, MTIMSC ; reset timer


	
checkFlagsTimer:
	; Check 1s timer flag
	LDA interruptFlags
	BIT #$01
	BEQ checkEnd

	BSR heartBeat ; toggle heartbeat LED
	; Reset interrupt flag
	BCLR 0, interruptFlags ; this is okay because variable is below 0xFF
	
checkEnd:
	RTS
; END checkFlags	
	
heartBeat:

		; Set up PTB Data direction to all outs
		MOV #$FF, PTBDD
		
		; Select the lower LED HC273
		; This means CBA = "001"
		; Recall that B(0) is A
		MOV #$F9, PTBD
		
		; Toggle heartbeat flag
		LDA interruptFlags
		EOR #$80 ; toggle bit 4 - heartbeat flag
		STA interruptFlags ; store it up
		AND #$80 ; Keep only bit 7
		
		; Bring in PTBD
		; Accumulator is mostly zeros so EORing will leave almost
		; all of it alone
		EOR PTBD 
		STA PTBD 
	
		
		; Update HC273: Clock low, then back high
		BCLR 3, PTBD
		BSET 3, PTBD
		
		RTS 
		
updateLEDs:
		MOV #$FF, PTBDD ; make sure data bus is set to outputs
		
		;??? This section could be greatly optimized, but let's do that after it gets working
		; Select the correct IC
		; This means CBA = "000"
		MOV #$08, PTBD ; address and key Gbar2 high still
		
		; Set up PTBD data bus portion (bits 7-4)
		NSA 	; Nibble swap because we want our information in bits 7-4
		COMA 	; LEDs are active low
		AND #$F0 ; mask off lower four bits
		ADD PTBD ; include PTBD
		STA PTBD 
		
		
		; Clock low then high
		BCLR 3, PTBD
		BSET 3, PTBD
		
		RTS
; END heartBeat
	

		
