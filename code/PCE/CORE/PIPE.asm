;=========;
;PIPE CODE;
;=========;


	PIPE:
		LDA !PlayerWaiting
		CMP #$03 : BNE $03 : JMP .Transition
		LDX !P2Pipe : BEQ .NoPipe
		LDA #$04 : STA !SPC1		; pipe SFX
		LDA $14
		LSR A : BCC +
		DEX : STX !P2Pipe
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
		LDA $14
		AND #$0001
		BEQ .Return16
		BVC .LeftPipe

		.RightPipe
		LDX #$01 : STX !P2Direction
		INC !P2XPosLo
		.Return16
		SEP #$21			; also set C
		RTL

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
		INC $741A					; +1 door count
		BNE $03 : DEC $741A				; stay at 255 instead of wrapping around to 0
		REP #$20
		LDA !P2XPosLo : STA !MarioXPosLo		;\ mario coords
		LDA !P2YPosLo : STA !MarioYPosLo		;/
		LDX #$0D : STX !MarioAnim			; > $71 = 06
	;	STZ $88						; > wipe $88-$89
		LDX #$0F : STX !GameMode
		LDX #$01 : STX $741D				; disable "MARIO START !" message
		BRA .Return16

