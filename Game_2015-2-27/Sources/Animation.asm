;*******************************************************************
;* LCD Animation Source File									   *
;* Authors: Seth Kreitinger and Tom Rader						   *
;*  Changes:													   *
;*	Initial Version		2015-2-26, 14:01                           *
;*******************************************************************

            INCLUDE 'derivative.inc'
            
            XDEF Animation_init, Animation_update, Animate_left, Animate_right
            XREF write_LCD, ASCII_table, interruptFlags, LCD_char_pos

;;;;;;;;;;;;;;;;;;;
; Animation Initializations
Animation_init:


		CLRH
		LDX #$00
		LDA ASCII_table, X	; LCD_Char
		LDX LCD_char_pos		; character position
		JSR write_LCD
		RTS

; END - Animation initialization
;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;
; Update display			
Animation_update:

		BRSET 3,interruptFlags, Animate_left
		BRSET 4,interruptFlags, Animate_right
		BRSet 5,interruptFlags, Animate_break
		
		RTS
	
Animate_right:
		CLRH
		LDA #$20			; ASCII Space
		LDX LCD_char_pos	; Get current Frogman Position
		PSHX
		JSR write_LCD		; Write Space to current frogman position
		PULX
		INCX
		STX LCD_char_pos
		
		LDA #$00			; Get Frogman Character
		JSR write_LCD		; Write into space to right of original position
		BCLR 4,interruptFlags
		RTS
Animate_left:
		CLRH
		LDA #$20			; ASCII Space
		LDX LCD_char_pos	; Get current Frogman Position
		PSHX
		JSR write_LCD		; Write Space to current frogman position
		PULX
		DECX
		STX LCD_char_pos
		
		LDA #$00			; Get Frogman Character
		JSR write_LCD		; Write into space to right of original position
		
		BCLR 3,interruptFlags
		RTS
Animate_break:

		RTS
; END - Update display
;;;;;;;;;;;;;;;;;;;
