COYOTE_TIME:

		LDA !P2Blocked
		AND #$04
		ORA !P2Platform
		ORA !P2SpritePlatform
		BNE .Ground

		.Air
		LDA !P2CoyoteTime
		BEQ .Jump
		BPL .Timer
	.Jump	LDA $6DA7
		AND #$80 : BEQ .Timer
		ORA #$03 : STA !P2CoyoteTime
		RTS

		.Ground
		LDA !P2CoyoteTime : BMI .Buffer
		LDA #$03 : STA !P2CoyoteTime
		RTS

	.Buffer	AND #$80 : TSB !P2Buffer
	.Clear	STZ !P2CoyoteTime
		RTS

		.Timer
		LDA !P2CoyoteTime
		DEC A
		CMP #$7F : BEQ .Clear
		CMP #$FF : BEQ .Clear
		STA !P2CoyoteTime
		RTS



