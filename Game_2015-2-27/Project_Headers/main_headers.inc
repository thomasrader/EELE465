;**************************************
; Header containing various macros
;
;**************************************





; Macro for calculating the log base 2 of the top four bits
logbase2: MACRO

		; Begin converting data to usuable row/col
		CLRX
		LDA \1 
		ORA #$0F		; Acumulator should now only have a single zero
		COMA			; Should be a Single one now
		
\@LOOP:	
		INCX 	; x is currently storing our loop index
		LSRA
		CMP #$10 	; the single one has passed into the lower four bits
		BHS \@LOOP
		
		CMP #$08 ; check if only one 1 was around
		BEQ \@LOOPFINE ; One one key hit detected, excellent
		BNE \@LOOPFAIL; uhoh garbage value!
\@LOOPFAIL:
		LDX #$06 ; 0x05 is what keyscan checks for bad value, but we decrement X later
\@LOOPFINE:
		DECX
		STX \1
 		
      ENDM