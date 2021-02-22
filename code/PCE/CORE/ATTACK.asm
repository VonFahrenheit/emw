ATTACK:

	.Setup
		REP #$20			;\
		LDA #$32E0 : STA $0E		; |
		LDA !CurrentPlayer		; | $0E = interaction pointer
		AND #$00FF : BEQ +		; |
		LDA #$35F0 : STA $0E		; |
	+	SEP #$20			;/
		RTS


	.Main
		TXY
		LDA #$10 : STA ($0E),y		; prevent interaction
		LDA CORE_BITS,x			;\
		CPX #$08			; |
		BCS +				; | mark sprite as hit
		TSB !P2IndexMem1		; |
		BRA ++				; |
	+	TSB !P2IndexMem2		;/
	++	RTS