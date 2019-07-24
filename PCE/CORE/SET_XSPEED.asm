SET_XSPEED:
		; Load A with desired speed beforehand

		STA $00
		LDA !P2Blocked
		AND #$04 : BNE .Ground

	.Write	LDA $00 : STA !P2XSpeed
		RTS


	.Ground	LDA !IceLevel : BEQ .Write
		LDA $00
		CMP !P2XSpeed
		BEQ .Ret
		BMI .Dec
	.Inc	INC !P2XSpeed
		RTS

	.Dec	DEC !P2XSpeed
	.Ret	RTS



