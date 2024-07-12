;=========;
;PIPE CODE;
;=========;


	PIPE:
		LDA !P2Pipe
		BEQ .NoPipe
		DEC A
		STA !P2Pipe

	LDY #$04 : STY !SPC1		; pipe SFX

		AND #$3F
		BNE .NoExit
		STZ !P2Pipe
		BRA .NoPipe

		.NoExit
		CMP #$20
		BEQ .Load
		BIT !P2Pipe			; Get highest two bits
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
		BVC .UpPipe

		.DownPipe
		INC !P2YPosLo
		BRA .Return16

		.UpPipe
		DEC !P2YPosLo
		BRA .Return16

		.Load
<<<<<<< Updated upstream
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
		RTS
=======
		LDA !P2Pipe					;\
		AND #$20^$FF					; | make sure pipe timer stays trigger happy
		ORA #$01 : STA !P2Pipe				;/
		LDA !MultiPlayer : BEQ .Transition		;\
		LDA !CurrentPlayer				; |
		INC A						; | wait for both players on multiplayer
		ORA !PlayerWaiting				; |
		STA !PlayerWaiting				; |
		CMP #$03 : BNE .Return16			;/

		.Transition
		INC !DoorCounter : BNE +			; +1 door count
		DEC !DoorCounter : +				; stay at 255 instead of wrapping around to 0
		REP #$20
		LDA !P2XPosLo : STA !MarioXPosLo
		LDA !P2YPosLo : STA !MarioYPosLo
		JSL TranslateOldExitNumber			; placeholder code until level loader is updated

		LDX #$0F : STX !GameMode
		BRA .Return16
>>>>>>> Stashed changes

		.NoPipe
		CLC
		RTS