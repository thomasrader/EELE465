;*******************************************************************
;* LCD Source File												   *
;* Authors: Seth Kreitinger and Tom Rader						   *
;*  Changes:													   *
;*	Initial Version		2015-2-19, 14:01                           *
;*	Custom Characters	2015-2-26, 13:15                           *
;*******************************************************************

            INCLUDE 'derivative.inc'

			XDEF LCD_init,write_LCD,clear_LCD, check_line_end, setup_custom_character
			XREF LCD_char, LCD_char_pos
; LCD Intialization 
; LCD address is CBA="100"
; It looks like the module update on the falling edge of a clock
; each instruction takes at least 250ns per cycle, so we should be okay timing-wise
; We might need some NO-OP's depending
LCD_init:
		
		JSR delay_15ms
		
		; set RS R/W DB7 DB6 DB5 DB4
		;	  0   0   0   0   1   1
		MOV #$00,PTAD 		; Set RS and R/W
		MOV #$34,PTBD		; Set up databus and enable line
		BSET 3, PTBD			; And enable off
		
		
		
		; wait at least 5ms
		JSR delay_15ms
		
		; set RS R/W DB7 DB6 DB5 DB4
		;	  0   0   0   0   1   1
		BCLR 3, PTBD
		BSET 3, PTBD
		
		; wait at least 100us
		JSR delay_50us
		
		; set RS R/W DB7 DB6 DB5 DB4
		;	  0   0   0   0   1   1
		BCLR 3, PTBD
		BSET 3, PTBD
		JSR delay_50us
		; set RS R/W DB7 DB6 DB5 DB4
		;	  0   0   0   0   1   0
		JSR delay_50us
		BCLR 4, PTBD 		; Data is now 0010
		BCLR 3, PTBD
		JSR delay_50us
		BSET 3, PTBD
		
		; This sets number of lines and character font (N,F)
		; set RS R/W DB7 DB6 DB5 DB4	
		;	  0   0   0   0   1   0
		;	  0   0   1   X   X   X
		 
		JSR delay_15ms
		MOV #$24, PTBD 			; Send the first line
		BSET 3, PTBD			; And enable off
		JSR delay_15ms
		MOV #$84, PTBD			; Send the second line
		BSET 3, PTBD			; And enable off
		JSR delay_15ms
		 
		; This turns the display off
		; set RS R/W DB7 DB6 DB5 DB4	
		;	  0   0   0   0   0   0
		;	  0   0   1   0   0   0
		JSR delay_15ms
		MOV #$04, PTBD			; Send the first line
		BSET 3, PTBD			; And enable off
		MOV #$84, PTBD			; Send the second line
		BSET 3, PTBD			; And enable off
		
		; Check the Busy Flag to Ensure internal operation has ceased
		; set RS R/W DB7 DB6 DB5 DB4
		;	  0   1   BF   0   0   0
		 

		; This clears the display
		; set RS R/W DB7 DB6 DB5 DB4
		;	  0   0   0   0   0   0
		;	  0   0   0   0   0   1
		JSR delay_50us
		MOV #$04, PTBD			; Send the first line
		BSET 3, PTBD			; And enable off
		MOV #$14, PTBD			; Send the second line
		BSET 3, PTBD			; And enable off
		
		
		; Check the Busy Flag to Ensure internal operation has ceased
		; set RS R/W DB7 DB6 DB5 DB4
		;	  0   1   BF   0   0   0
		 
		
		; This sets the entry mode
		; set RS R/W DB7 DB6 DB5 DB4
		;	  0   0   0   0   0   0
		;	  0   0   0   1   1   0
		JSR delay_50us
		MOV #$04, PTBD			; Send the first line
		BSET 3, PTBD			; And enable off
		MOV #$64, PTBD			; Send the second line
		BSET 3, PTBD			; And enable off
		
		
		; Check the Busy Flag to Ensure internal operation has ceased
		; set RS R/W DB7 DB6 DB5 DB4
		;	  0   1   BF   0   0   0
		 
				
		;Turn display on and set Cursor Blink Options
		; set RS R/W DB7 DB6 DB5 DB4
		;	  0   0   0   0   0   0
		;	  0   0   1   1   0   0
		JSR delay_50us
		MOV #$04, PTBD			; Send the first line
		BSET 3, PTBD			; And enable off
		MOV #$C4, PTBD			; Send the second line
		BSET 3, PTBD			; And enable off
		
		JSR delay_15ms			; Just to be safe
		
		RTS
;;;;;;;;;;;;;;;;;;;
; delay_15ms
; 15ms delay loop
delay_15ms:
		CLRH
		CLRX 	; there isn't a CLRHX command
		
delay2:		
		AIX #$1
		CPHX #$EA60
		BNE delay2
		RTS
; delay_15ms END
;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;
; delay_50us
; 50µs delay loop
delay_50us:
		CLRH
		CLRX 	; there isn't a CLRHX command
		
delay2_2:		
		AIX #$1
		CPHX #$C8
		BNE delay2
		RTS
; delay_15ms END
;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;
; check_busy_flag
; loops until busy flag gets set
check_busy_flag:

		; Check the Busy Flag to Ensure internal operation has ceased
		; set RS R/W DB7 DB6 DB5 DB4
		;	  0   1   BF   0   0   0
		BSET 0, PTAD 	; Set read flag
		MOV #$0F, PTBDD		; Set databus direction to inputs
check_busy_while:
		MOV #$04, PTBD		; Address and enable LCD ???
		LDA PTBD
		BSET 3, PTBD		; Turn off enable
		
		BCLR 3, PTBD		; Turn on enable
		LDX PTBD
		BSET 3, PTBD		; Turn off enable
		CMP #$80
		BHS check_busy_while	; check for busy flag clear
		
		BCLR 0, PTAD 	; Clear write flag
		MOV #$FF, PTBDD	; Make PTBD all outputs
		; Down here means BF was clear
		RTS
; check_busy_flag END
;;;;;;;;;;;;;;;;;;;		

;;;;;;;;;;;;;;;;;;;
;Write L To Display
write_LCD:
		STA LCD_char
		STX LCD_char_pos
		
		MOV #$FF, PTBDD 		; Make sure PTB is set to output		
		; Set DD ram address
		; Set the DD RAM address back
		; set RS R/W DB7 DB6 DB5 DB4
		;	  0   0   1   0   0   0
		;	  0   0   0   0   0   0
		TXA						; Load accumulator with LCD_char_pos
		AND #$F0
		ADD #$04				; LCD address
		STA PTBD
		BSET 3, PTBD			; And enable off
		
		LDA LCD_char_pos
		NSA						; Swap the nibbles
		AND #$F0
		ADD #$04				; LCD address
		STA PTBD
		BSET 3, PTBD			; And enable off
		
		 
		JSR delay_50us
		
		BSET 1,PTAD				; Set RS flag

		;; Now right the character
		; first nibble
		LDA LCD_char
		AND #$F0
		ADD #$4
		STA PTBD
		BSET 3, PTBD
		
		; second nibble
		LDA LCD_char
		NSA
		AND #$F0
		ADD #$4
		STA PTBD
		BSET 3, PTBD
		BCLR 1,PTAD			; Clear RS flag
		JSR delay_50us
		RTS
;;;;;;;;;;;;;;;;;;;
		
;;;;;;;;;;;;;;;;;;;
;Clear the LCD
clear_LCD:
		 
		MOV #$04, PTBD			; Send the first line
		BSET 3, PTBD			; And enable off
		MOV #$14, PTBD			; Send the second line
		BSET 3, PTBD			; And enable off
		JSR delay_50us
		RTS
;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;
;Check if LCD char line is full
check_line_end:
		BSET 0, PTAD 	; Set read flag
		MOV #$04, PTBD		; Address and enable LCD
		MOV #$0F, PTBDD
		LDA PTBD
		BSET 3, PTBD		; Turn off enable
		BCLR 3, PTBD		; Turn on enable
		;LDX PTBD
		BSET 3, PTBD		; Turn off enable
		CMP #$14
		BLO check_line_end_end

check_line_end_end:
		MOV #$FF, PTBDD
		BCLR 0, PTAD 	; clear read flag
		RTS
;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;
; Write a custom character
setup_custom_character:

		MOV #$FF, PTBDD 		; Make sure PTBDD is all set to output

		 
		JSR delay_50us
		BCLR 1, PTAD
		
		; Set CG RAM
		; set RS R/W DB7 DB6 DB5 DB4
		;	  0   0   0   1   0   0
		;	  0   0   0   0   0   0
		MOV #$44, PTBD			; Send the first line
		BSET 3, PTBD			; And enable off
		JSR delay_50us
		MOV #$04, PTBD			; Send the second line
		BSET 3, PTBD			; And enable off
		
		JSR delay_50us
		
		BSET 1, PTAD			; Set RS flag
		 
		 JSR delay_50us
		; Write lines of data
		; set RS R/W DB7 DB6 DB5 DB4
		;	  1   0   0   0   0   1
		;	  1   0   1   0   1   1

		MOV #$14, PTBD			; Send the first line
		BSET 3, PTBD			; And enable off
		JSR delay_50us
		MOV #$B4, PTBD			; Send the second line
		BSET 3, PTBD			; And enable off
		
		JSR delay_50us
		; Write lines of data
		; set RS R/W DB7 DB6 DB5 DB4
		;	  1   0   0   0   0   1
		;	  1   0   1   0   1   1

		MOV #$14, PTBD			; Send the first line
		BSET 3, PTBD			; And enable off
		JSR delay_50us
		MOV #$B4, PTBD			; Send the second line
		BSET 3, PTBD			; And enable off
		 
		JSR delay_50us
		; Write lines of data
		; set RS R/W DB7 DB6 DB5 DB4
		;	  1   0   0   0   0   0
		;	  1   0   0   0   0   0
		MOV #$04, PTBD			; Send the first line
		BSET 3, PTBD			; And enable off
		JSR delay_50us
		MOV #04, PTBD			; Send the second line
		BSET 3, PTBD			; And enable off
		
		
		 
		JSR delay_50us
		; Write lines of data
		; set RS R/W DB7 DB6 DB5 DB4
		;	  1   0   0   0   0   0
		;	  1   0   1   1   1   0
		MOV #$04, PTBD			; Send the first line
		BSET 3, PTBD			; And enable off
		JSR delay_50us
		MOV #$E4, PTBD			; Send the second line
		BSET 3, PTBD			; And enable off
		
		 
		JSR delay_50us
		; Write lines of data
		; set RS R/W DB7 DB6 DB5 DB4
		;	  1   0   0   0   0   1
		;	  1   0   0   0   0   1
		MOV #$14, PTBD			; Send the first line
		BSET 3, PTBD			; And enable off
		JSR delay_50us
		MOV #$14, PTBD			; Send the second line
		BSET 3, PTBD			; And enable off
		
		
		 
		JSR delay_50us
		; Write lines of data
		; set RS R/W DB7 DB6 DB5 DB4
		;	  1   0   0   0   0   1
		;	  1   0   0   1   0   1
		MOV #$14, PTBD			; Send the first line
		BSET 3, PTBD			; And enable off
		JSR delay_50us
		MOV #$54, PTBD			; Send the second line
		BSET 3, PTBD			; And enable off
		
		 
		JSR delay_50us
		; Write lines of data
		; set RS R/W DB7 DB6 DB5 DB4
		;	  1   0   0   0   0   0
		;	  1   0   1   1   1   0
		MOV #$04, PTBD			; Send the first line
		BSET 3, PTBD			; And enable off
		JSR delay_50us
		MOV #$E4, PTBD			; Send the second line
		BSET 3, PTBD			; And enable off
		
		
		 
		JSR delay_50us
		; Write lines of data
		; set RS R/W DB7 DB6 DB5 DB4
		;	  1   0   0   0   0   0
		;	  1   0   0   0   0   0
		MOV #$04, PTBD			; Send the first line
		BSET 3, PTBD			; And enable off
		MOV #$04, PTBD			; Send the second line
		BSET 3, PTBD			; And enable off
		JSR delay_50us
		BCLR 1, PTAD			; clear RS flag;

		 
		JSR delay_50us
		; Set DD ram address
		; Set the DD RAM address back
		; set RS R/W DB7 DB6 DB5 DB4
		;	  0   0   1   0   0   0
		;	  0   0   0   0   0   0
		MOV #$84, PTBD			; Send the first line
		BSET 3, PTBD			; And enable off
		JSR delay_50us
		MOV #$04, PTBD			; Send the second line
		BSET 3, PTBD			; And enable off
		
		
		JSR delay_15ms			; Just to be safe
		
		RTS
		
; END setup custom character
;;;;;;;;;;;;;;;;;;;
		

;;;;;;;;;;;;;;;;;;;
; Write a custom character
LCD_write_custom_character:


		; Set DD ram address
		; Set the DD RAM address back
		; set RS R/W DB7 DB6 DB5 DB4
		;	  0   0   1   0   0   0
		;	  0   0   0   0   0   0
		;MOV #$84, PTBD			; Send the first line
		;BSET 3, PTBD			; And enable off
		;MOV #$04, PTBD			; Send the second line
		;BSET 3, PTBD			; And enable off


		BSET 1, PTAD		; Set RS flag
		; display the new character
		; set RS R/W DB7 DB6 DB5 DB4
		;	  1   0   0   0   0   0
		;	  1   0   0   0   0   0
		
		MOV #$04, PTBD			; Send the first line
		BSET 3, PTBD			; And enable off
		MOV #$04, PTBD			; Send the second line
		BSET 3, PTBD			; And enable off
; END write a custom character
;;;;;;;;;;;;;;;;;;;;
		
		
		
		
