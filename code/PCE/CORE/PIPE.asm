;=========;
;PIPE CODE;
;=========;


	PIPE:
		LDX !P2Pipe : BEQ .NoPipe
		LDA $14
	;	AND #$0F : BNE +
		LDY #$04 : STY !SPC1		; pipe SFX
	+	LSR A : BCC +
		DEX
		STX !P2Pipe
	+	TXA
		AND #$3F : BNE .NoExit
		STZ !P2Pipe
		.NoPipe
		CLC
		RTL

		.NoExit
		CMP #$20 : BEQ .Load
		BIT !P2Pipe			; get highest two bits
		REP #$20			; A 16 bit
		BMI .VertPipe

		.HorzPipe
		LDA $13
		AND #$0001
		BEQ .Return16
		BVC .LeftPipe

		.RightPipe
		LDX #$01 : STX !P2Direction
		INC !P2XPosLo
		BRA .Return16

		.LeftPipe
		LDX #$00 : STX !P2Direction
		DEC !P2XPosLo
		BRA .Return16

		.VertPipe
		LDA !P2XPosLo
		AND #$000F
		CMP #$0008 : BEQ +
		BCC ..inc
	..dec	DEC !P2XPosLo : BRA +
	..inc	INC !P2XPosLo
	+	BVC .UpPipe

		.DownPipe
		INC !P2YPosLo
		BRA .Return16

		.UpPipe
		DEC !P2YPosLo
		BRA .Return16

		.Load
		LDA !P2Pipe
		AND #$20^$FF
		ORA #$01
		STA !P2Pipe
		INC $741A
		REP #$20
		LDA !P2XPosLo : STA $94		;\ Player 1 coords
		LDA !P2YPosLo : STA $96		;/
		LDX #$06 : STX $71		; > $71 = 06
		STZ $88				; > Wipe $88-$89
		LDX #$0F : STX !GameMode
		LDX #$01 : STX $741D

		.Return16
		SEP #$20
		SEC
		RTL

