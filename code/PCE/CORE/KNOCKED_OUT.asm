;===========;
;KNOCKED OUT;
;===========;
KNOCKED_OUT:

		LDA !Difficulty
		AND #$03 : BNE .NoRiposte
		LDA !P2HurtTimer : BEQ .NoRiposte
		STZ !P2HurtTimer
		JSL CORE_RIPOSTE
		.NoRiposte



		STZ !P2XSpeed
		STZ !P2VectorX
		STZ !P2VectorY
		STZ !P2Blocked
		STZ !P2ExtraBlock
		STZ !P2Platform
		STZ !P2FlashPal
		LDA #$03 : STA !P2Gravity
		LDA #$46 : STA !P2FallSpeed
		JSL CORE_UPDATE_SPEED
		REP #$20
		LDA !P2YPosLo
		SEC : SBC $1C
		CMP #$0100
		SEP #$20

		RTL








