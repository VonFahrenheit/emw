;============;
;UPDATE SPEED;
;============;
UPDATE_SPEED:

		REP #$20				;\
		LDA !P2XPosLo : STA !P2XPosBackup	; | Backup player coords
		LDA !P2YPosLo : STA !P2YPosBackup	; |
		SEP #$20				;/

		LDA !P2Stasis : BEQ +
		DEC !P2Stasis
		RTS
		+


		LDA !P2GravityTimer : BNE +
		STZ !P2GravityMod
		BRA ++
	+	DEC !P2GravityTimer
		++


		LDA !P2YSpeed
		BEQ .ReturnY
		CLC : ADC !P2VectorY
		BMI .TopCheck

		.BottomCheck
		LDA !P2Blocked
		AND #$04
		ORA !P2Platform
		BEQ .UpdateY
		BRA .ReturnY

		.TopCheck
		LDA !P2Blocked
		AND #$08
		BNE .ReturnY


;
; Gravity factor:
;	If 0, do nothing.
;	If positive, multiply by hi nybble + 1
;	If negative, invert and then divide by hi nybble + 1
;	Lo nybble are used as memory bits for division
;



		.UpdateY
		LDA !P2YSpeed
		ASL #4
		CLC : ADC !P2YFraction
		STA !P2YFraction
		REP #$20
		PHP
		LDA !P2YSpeed
		LSR #4
		AND #$000F
		CMP #$0008
		BCC $03 : ORA #$FFF0
		PLP
		ADC !P2YPosLo
		STA !P2YPosLo
		SEP #$20

		.ReturnY
		LDY #$00
		LDA !P2YSpeed
		CLC : ADC !P2Gravity
		CLC : ADC !P2GravityMod
		STA !P2YSpeed
		TAX
		BMI .NegY
		LDA !P2Blocked
		AND #$04
		BEQ .Midair

		.Ground
		CPX #$10
		BCC .NegY
		LDA #$10 : STA !P2YSpeed
		BRA .NegY

		.Midair
		CPX !P2FallSpeed
		BCC .NegY
		LDA !P2FallSpeed : STA !P2YSpeed

		.NegY
		LDA !P2XSpeed
		BEQ .ReturnX
		CLC : ADC !P2VectorX
		BMI .LeftCheck

		.RightCheck
		LDA !P2Blocked
		LSR A
		BCS .ReturnX
		BRA .UpdateX

		.LeftCheck
		LDA !P2Blocked
		AND #$02
		BNE .ReturnX

		.UpdateX

	REP #$20
	LDA !P2XPosLo
	STA $00
	SEP #$20

		LDA !P2XSpeed
		ASL #4
		CLC : ADC !P2XFraction
		STA !P2XFraction
		REP #$20
		PHP
		LDA !P2XSpeed
		LSR #4
		AND #$000F
		CMP #$0008
		BCC $03 : ORA #$FFF0
		PLP
		ADC !P2XPosLo
		STA !P2XPosLo
		SEP #$20

		LDA !P2Slope
		BEQ .ReturnX
		EOR !P2XSpeed
		BMI .ReturnX
		REP #$20
	LDA $00
	SEC : SBC !P2XPosLo
	BPL $04 : EOR #$FFFF : INC A
	CLC : ADC !P2YPosLo
	STA !P2YPosLo
		SEP #$20
		.ReturnX

		.VectorX
		LDA !P2VectorX				;\
		ASL #4					; |
		CLC : ADC !P2VectorMemX			; |
		STA !P2VectorMemX			; |
		REP #$20				; |
		PHP					; |
		LDA !P2VectorX				; |
		LSR #4					; | Apply X vector
		AND #$000F				; |
		CMP #$0008				; |
		BCC $03 : ORA #$FFF0			; |
		PLP					; |
		ADC !P2XPosLo				; |
		STA !P2XPosLo				; |
		SEP #$20				;/
		LDA !P2VectorAccX			;\
		CLC : ADC !P2VectorX			; | Update X vector
		STA !P2VectorX				;/
		LDA !P2VectorTimeX			;\
		BNE +					; |
		STZ !P2VectorX				; |
		STZ !P2VectorAccX			; | Update X vector timer
		STZ !P2VectorMemX			; |
		BRA .ReturnVectorX			; |
	+	DEC !P2VectorTimeX			; |
		.ReturnVectorX				;/

		.VectorY
		LDA !P2VectorY				;\
		ASL #4					; |
		CLC : ADC !P2VectorMemY			; |
		STA !P2VectorMemY			; |
		PHP					; |
		REP #$20				; |
		LDA !P2VectorY				; |
		LSR #4					; | Apply Y vector
		AND #$000F				; |
		CMP #$0008				; |
		BCC $03 : ORA #$FFF0			; |
		PLP					; |
		ADC !P2YPosLo				; |
		STA !P2YPosLo				; |
		SEP #$20				;/
		LDA !P2VectorAccY			;\
		CLC : ADC !P2VectorY			; | Update Y vector
		STA !P2VectorY				;/
		LDA !P2VectorTimeY			;\
		BNE +					; |
		STZ !P2VectorY				; |
		STZ !P2VectorAccY			; | Update Y vector timer
		STZ !P2VectorMemY			; |
		BRA .ReturnVectorY			; |
	+	DEC !P2VectorTimeY			; |
		.ReturnVectorY				;/

		RTS








