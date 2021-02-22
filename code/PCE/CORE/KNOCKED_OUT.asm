;===========;
;KNOCKED OUT;
;===========;
KNOCKED_OUT:

		STZ !P2XSpeed
		STZ !P2VectorX
		STZ !P2VectorY
		LDA #$03 : STA !P2Gravity
		LDA #$46 : STA !P2FallSpeed
		JSR CORE_UPDATE_SPEED
		REP #$20
		LDA !P2YPosLo
		SEC : SBC $1C
		CMP #$0180
		SEP #$20

		RTS








