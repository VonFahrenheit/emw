;============;
;UPDATE SPEED;
;============;
UPDATE_SPEED:
		LDA !P2Pipe				;\ skip this routine during pipe animation
		BEQ $01 : RTL				;/
		REP #$20				;\
		LDA !P2XFraction : STA $0C		; | backup sub pixels + lo byte coords
		LDA !P2YFraction : STA $0E		;/
		LDX !P2Platform : BEQ .NoPlatform	;\
		DEX					; |
		LDA !SpriteDeltaX,x			; |
		AND #$00FF				; |
		CMP #$0080				; |
		BCC $03 : ORA #$FF00			; |
		CLC : ADC !P2XPos			; |
		STA !P2XPos				; | apply platform delta
		LDA !SpriteDeltaY,x			; |
		AND #$00FF				; |
		CMP #$0080				; |
		BCC $03 : ORA #$FF00			; |
		CLC : ADC !P2YPos			; |
		STA !P2YPos				; |
		.NoPlatform				;/
		SEP #$20				; A 8-bit

		LDA !P2Stasis : BEQ .Main		;\
		DEC !P2Stasis				; | don't apply speed + vector during stasis
		RTL					;/

		.Main
		LDA !P2XSpeed				;\
		CLC : ADC !P2VectorX			; | composite X speed
		STA $00					;/
		LDA !P2YSpeed				;\
		CLC : ADC !P2VectorY			; | composite Y speed
		STA $01					;/
		LDA !P2VectorTimeX : BNE +		;\
		STZ !P2VectorX				; |
		STZ !P2VectorAccX			; | process X vector
		BRA ++					; |
	+	DEC !P2VectorTimeX			; |
		++					;/
		LDA !P2VectorTimeY : BNE +		;\
		STZ !P2VectorY				; |
		STZ !P2VectorAccY			; | process Y vector
		BRA ++					; |
	+	DEC !P2VectorTimeY			; |
		++					;/

		LDA !P2Slope : BEQ .NoSlope
		LDX !P2SlopeSpeed : BNE .Unlimit	; 00 = round, anything else = unlimit
	.Round	LDA $00					;\
		BPL $03 : EOR #$FF : INC A		; |
		LSR #3					; | round to nearest multiple of 8
		BCC $01 : INC A				; |
		TAX					;/
		LDA.l .SlopeIndex,x			;\
		CLC : ADC !P2Slope			; | get index to slope speed table
		CLC : ADC #$04				; |
		TAX					;/
		LDA $00					;\
		CMP.l .SlopeMin,x : BCC .Unlimit	; | update applied X speed while moving up slope
		CMP.l .SlopeMax,x : BCS .Unlimit	; |
		LDA.l .SlopeSet,x : STA $00		;/
		.Unlimit

		BIT $01 : BMI .NoSlope			; can't be moving up
		LDA !P2Slope : BEQ .NoSlope		; don't process this if there is no slope
	+	EOR $00 : BMI .NoSlope			; see if player is going up or down slope
	.DownSlope					;\
		REP #$20				; |
		LDA !P2Slope				; |
		AND #$00FF				; |
		CMP #$0080				; | adjust Ypos when moving down slope
		BCC $04 : EOR #$00FF : INC A		; |
		CLC : ADC !P2YPosLo			; |
		STA !P2YPosLo				; |
		SEP #$20				;/
		.NoSlope





		LDA $01
		BEQ .ReturnY
		BMI .TopCheck
		.BottomCheck
		LDA !P2Blocked
		AND #$04
		ORA !P2Platform
		BEQ .UpdateY
		BRA .ReturnY
		.TopCheck
		LDA !P2Blocked
		AND #$08 : BNE .ReturnY
		.UpdateY
		LDY #$00
		REP #$20
		LDA $01
		AND #$00FF
		ASL #4
		CMP #$0800
		BCC $04 : ORA #$F000 : DEY
		CLC : ADC !P2YFraction
		STA !P2YFraction
		SEP #$20
		TYA
		ADC !P2YPosHi
		STA !P2YPosHi
		.ReturnY


		LDA !P2YSpeed
		CLC : ADC !P2Gravity
		CLC : ADC !P2GravityMod
		STA !P2YSpeed
		STZ !P2GravityMod
		TAX
		BMI .NegY
		LDA !P2Blocked
		AND #$04 : BEQ .Midair
		.Ground
		CPX #$10 : BCC .NegY
		LDA #$10
		BRA +
		.Midair
		CPX !P2FallSpeed
		BCC .NegY
		LDA !P2FallSpeed
	+	STA !P2YSpeed
		.NegY


; !P2XPosLo used to be stored to $00 before being updated
; doesn't seem like that was used by anything, so i removed it

		LDA $00
		BEQ .ReturnX
		BMI .LeftCheck
		.RightCheck
		LDA !P2Blocked
		LSR A : BCS .ReturnX
		BRA .UpdateX
		.LeftCheck
		LDA !P2Blocked
		AND #$02 : BNE .ReturnX
		.UpdateX
		LDY #$00
		REP #$20
		LDA $00
		AND #$00FF
		ASL #4
		CMP #$0800
		BCC $04 : ORA #$F000 : DEY
		CLC : ADC !P2XFraction
		STA !P2XFraction
		SEP #$20
		TYA
		ADC !P2XPosHi
		STA !P2XPosHi
		.ReturnX

		.ReturnNormal
		REP #$20				;\
		LDA !P2XFraction			; |
		SEC : SBC $0C				; |
		STA $785F				; | how much player moved (sub pixels)
		LDA !P2YFraction			; |
		SEC : SBC $0E				; |
		STA $78D7				; |
		SEP #$20				;/
		LDA !P2Slope : STA $7693		; slope that speed was used with
		RTL







; order:
; - supersteep left, steep left, normal left, gradual left
; - flat ground
; - gradual right, normal right, steep right, supersteep right
;
; slope speed:
; 0 - unlimit, no index
; 1 - 8		index 0
; 2 - 16	index 9
; 3 - 24	index 18
; 4 - 32	index 27
; 5 - 40	index 36
; 6 - 48	index 45
; 7 - 56	index 54
; 8 - 64	index 63

		.SlopeIndex
		db $00,$09,$12,$1B,$24,$2D,$36,$3F

		.SlopeMin
		db $04,$06,$07,$08,$00,$80,$80,$80,$80		; speed = 08
		db $07,$0B,$0E,$10,$00,$80,$80,$80,$80		; speed = 16
		db $0B,$11,$15,$17,$00,$80,$80,$80,$80		; speed = 24
		db $0E,$17,$1D,$1F,$00,$80,$80,$80,$80		; speed = 32
		db $12,$1C,$23,$27,$00,$80,$80,$80,$80		; speed = 40
		db $15,$22,$2B,$2F,$00,$80,$80,$80,$80		; speed = 48
		db $19,$28,$32,$36,$00,$80,$80,$80,$80		; speed = 56
		db $1D,$2D,$39,$3E,$00,$80,$80,$80,$80		; speed = 64

		.SlopeMax
		db $80,$80,$80,$80,$00,$F8,$F9,$FA,$FC		; speed = 08
		db $80,$80,$80,$80,$00,$F0,$F2,$F5,$F9		; speed = 16
		db $80,$80,$80,$80,$00,$E9,$EB,$EF,$F5		; speed = 24
		db $80,$80,$80,$80,$00,$E1,$E3,$E9,$F2		; speed = 32
		db $80,$80,$80,$80,$00,$D9,$DD,$E4,$EE		; speed = 40
		db $80,$80,$80,$80,$00,$D1,$D5,$DE,$EB		; speed = 48
		db $80,$80,$80,$80,$00,$CA,$CE,$D8,$E7		; speed = 56
		db $80,$80,$80,$80,$00,$C2,$C7,$D3,$E3		; speed = 64

		.SlopeSet
		db $04,$06,$07,$08,$00,$F8,$F9,$FA,$FC		; speed = 08
		db $07,$0B,$0E,$10,$00,$F0,$F2,$F5,$F9		; speed = 16
		db $0B,$11,$15,$17,$00,$E9,$EB,$EF,$F5		; speed = 24
		db $0E,$17,$1D,$1F,$00,$E1,$E3,$E9,$F2		; speed = 32
		db $12,$1C,$23,$27,$00,$D9,$DD,$E4,$EE		; speed = 40
		db $15,$22,$2B,$2F,$00,$D1,$D5,$DE,$EB		; speed = 48
		db $19,$28,$32,$36,$00,$CA,$CE,$D8,$E7		; speed = 56
		db $1D,$2D,$39,$3E,$00,$C2,$C7,$D3,$E3		; speed = 64


		.SlopeAcc
		dw $0280,$0080,$0000,$0000,$0000,$0000,$0000,$0080,$0280	; speed = 16 or same direction as slope
		dw $0280,$00C0,$0000,$0000,$0000,$0000,$0000,$00C0,$0280	; speed = 32
		dw $0280,$0100,$0000,$0000,$0000,$0000,$0000,$0100,$0280	; speed = 48
		dw $0280,$0180,$0000,$0000,$0000,$0000,$0000,$0180,$0280	; speed = 64

		.SlopeSpeed
		dw $2000,$1000,$0000,$0000,$0000,$0000,$0000,$1000,$2000	;





