;** ###################################################################
;**	Module for Keyboard operations like scanning
;** Authors: Seth Kreitinger and Tom Rader
;** Changes:
;** Initial Version		2015-2-16, 014:02p
;**    
;**    
;** ###################################################################

	    INCLUDE 'main_headers.inc'
	    INCLUDE MC9S08QG8.inc          ; I/O map for MC9S08QG8MP


KeyBoardCode:     SECTION
		XREF colValue, rowValue, rowCol, interruptFlags
		XDEF keyBoardScan
		
; keyBoardScan
keyBoardScan:
		
		; check key if a key has been hit within 1s
		LDA interruptFlags
		BIT #$02
		BNE keyHitStill ; BIT would return a 0 if a key hasn't been hit yet
		BEQ keyOkay
keyHitStill:
		JMP keyBoardEnd
keyOkay:

		; Set up the right Data direction registers
		MOV #$FF, PTBDD
		
		; Address the keypad HC273: CBA = "010"	
		; With the HC138 Gbar2 still high, this is 0x0A	
		; We don't care about the old data bus stuff
		; Load PTBD with new value to check for next row
		LDA rowValue
		AND #$F0
		ADD #$0A  ; This is keeping Gbar2 high and addressing CBA
		STA PTBD
		
		; update the HC273 with a low pulse
		BCLR 3, PTBD ; low
		BSET 3, PTBD ; back high

		; Now we are to the scan section
		; First we set the PTBDD 4,5,6,7 to inputs
		MOV #$0F, PTBDD

		; Address the keypad HC245: CBA = "011"
		MOV #$0B, PTBD ; This is HC245 addressed with Gbar2 still high

		; Grab data from the keypad HC245
		BCLR 3, PTBD  ; go low
		MOV PTBD, colValue ; colValue is under 0xFF, so this is fine
		BSET 3, PTBD  ; go back to high
		
		MOV #$FF, PTBDD ; Set data directions back to all outputs
		
		LDA colValue  ; reload in the column value
		
		; Check if any column is low
		CMP #$F0
		BHS keyBoardNextRow
		
		; A key was hit, fire up the MTIM for the 1s debounce
		;BSET 5, MTIMSC ; reset timer
		;BCLR 4, MTIMSC ; start 'er up
		
		; We know a column is low, let's find it!
		; Begin converting data to usuable row/col
		
		; MAAAAACROOOOOOO POOOOWEEEERRRRR!
		logbase2 colValue
		logbase2 rowValue  
		
		; Check if colValue is an unexpected value - this would indicate two keys hit
		LDA colValue
		CMP #$05 ; anything larger than this is bad
		BHS keyBoardEnd
		
		; Now combine row and columns
		; Recall X already has the rowValue in it
		LDA #$04 	; Each row counts as four bytes
		MUL			; This command multiplies A and X
		ADD colValue	; Now we have the column offset also
		STA rowCol		; Now we have the row/column information that can be used with lookup table
		
		; Put row value back to scan mode
		MOV #$F7, rowValue
		
		; A key was hit!
		BSET 1,interruptFlags ; this is fine, interruptFlags is under 0xFF
		BRA keyBoardEnd ; we found a key! return to main
		
keyBoardNextRow:			
		; Update the value we want keypad HC273 to have
		LSL rowValue  ; This gets truncated, but this variable is under 0xFF so it should be okay
			
		; Check that rowValue is okay
		LDA rowValue
		CMP #$E0 		; If rowValue is $E0, that means we've shifted past where we want to be
		BNE checkRowValueEnd
		
		MOV #$EF, rowValue
		BRA keyBoardEnd ; We've scanned all the rows, go back to main

		checkRowValueEnd:
		JMP keyBoardScan ; we aren't done scanning

keyBoardEnd:		
		RTS



;; END keyBoardScan
