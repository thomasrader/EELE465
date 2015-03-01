;** ###################################################################
;**	Module for LED patterns operations like scanning
;** Authors: Seth Kreitinger and Tom Rader
;** Changes:
;** Initial Version		2015-2-16, 14:04p
;**    
;**    
;** ###################################################################

	    INCLUDE 'main_headers.inc'
	    INCLUDE MC9S08QG8.inc          ; I/O map for MC9S08QG8MPB
        XREF patternSelect, patternIndex, keyboard_table, LED_patternA, rowCol
		XDEF ledPattern, ledPatternUpdate


LEDCode:     SECTION
ledPatternUpdate:
			CLRH
			LDX rowCol 		; grab which keyboard row and column
			LDA keyboard_table, X
			
			; And so the branches begin
			CMP #$0A
			BEQ patternUpdateA
			
			CMP #$0B
			BEQ patternUpdateB
			
			CMP #$0C
			BEQ patternUpdateC
			
			CMP #$0D
			BEQ patternUpdateD
			BRA patternUpdateEnd
			
patternUpdateA:
			; pattern A is patternSelect = 0
			LDA #$00
			STA patternSelect
			BRA patternUpdateEnd
			
patternUpdateB:
			; pattern B is patternSelect = 2
			LDA #2
			STA patternSelect
			BRA patternUpdateEnd
			
patternUpdateC:
			; pattern C is patternSelect = 11
			LDA #11
			STA patternSelect
			BRA patternUpdateEnd
			
patternUpdateD:
			; pattern C is patternSelect = 18
			LDA #18
			STA patternSelect
			BRA patternUpdateEnd
			
patternUpdateEnd:
			RTS

ledPattern:
		
 		; Set the Databus to output
		LDA #$F0
		ORA PTBDD
		STA PTBDD
		
		; Select the correct IC
		; This means CBA = "001"
		LDA #$01 		; the PTBD register has A (B0) on the end
		ORA PTBD
		AND #$F9		; We want PTB_0 and PTB_1 cleared
		STA PTBD
		
		; Write the LED pattern to the databus
		; Clear top four bits
		LDA #$0F
		AND PTBD
		STA PTBD
		
		; Set top four bits as we like
		CLRH
		LDA patternIndex
		ADD patternSelect
		TAX 			; This transfers A->X
		LDA LED_patternA, X
		AND #$F0
		ORA PTBD
		STA PTBD
		
		; Clock low then high
		BCLR 3, PTBD
		BSET 3, PTBD
		
		; Select the correct IC
		; This means CBA = "000"
		LDA #$F8 		; the PTBD register has A (B0) on the end
		AND PTBD
		STA PTBD
		
		; Write the LED pattern to the databus
		; Clear top four bits
		LDA #$0F
		AND PTBD
		STA PTBD
		
		; Set top four bits as we like
		CLRH
		LDA patternIndex
		ADD patternSelect
		TAX 			; This transfers A->X
		LDA LED_patternA, X
		
		; We need to LSL four times
		LSLA
		LSLA
		LSLA
		LSLA
				
		ORA PTBD
		STA PTBD
		
		; Clock low
		BCLR 3, PTBD
		
		; Nop wait
		NOP
		
		; Clock High
		BSET 3, PTBD

		; Increment patternIndex
		CLRH
		LDX #patternIndex
		INC ,X
		BSR checkPatternIndex

		RTS 
		
checkPatternIndex:
		CLRH
		LDX patternSelect
		LDA LED_patternA, X

		INCA	; Add one because pattern starts at 1, not 0
		CMP patternIndex
		BEQ resetPatternIndex
		RTS
		
resetPatternIndex:
		LDA #$01
		STA patternIndex
		RTS



; END - ledPattern
