;============;
;UPDATE SPEED;
;============;
UPDATE_SPEED:

<<<<<<< Updated upstream
		REP #$20				;\
		LDA !P2XPosLo : STA !P2XPosBackup	; | Backup player coords
		LDA !P2YPosLo : STA !P2YPosBackup	; |
		SEP #$20				;/
=======
		.Checks
		LDA !P2Pipe : BNE ..return		; skip this routine during pipe animation
		REP #$20				;\
		LDA !P2XFraction : STA $0C		; | backup sub pixels + lo byte coords
		LDA !P2YFraction : STA $0E		;/
		LDX !P2Platform : BEQ ..platformdone	;\
		..platform				; |
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
		..platformdone				;/
		SEP #$20				; A 8-bit
		LDA !P2Stasis : BEQ .Main		;\
		DEC !P2Stasis				; | don't apply speed + vector during stasis
		..return				; |
		RTL					;/


		.Main
		LDA !P2XSpeed				;\
		CLC : ADC !P2VectorX			; | composite X speed
		STA $00					;/
		LDA !P2YSpeed				;\
		CLC : ADC !P2VectorY			; | composite Y speed
		STA $01					;/

		.VectorX
		LDA !P2VectorTimeX : BNE ..dec		;\
		STZ !P2VectorX				; |
		STZ !P2VectorAccX			; |
		BRA ..done				; | process X vector
		..dec					; |
		DEC !P2VectorTimeX			; |
		..done					;/

		.VectorY
		LDA !P2VectorTimeY : BNE ..dec		;\
		STZ !P2VectorY				; |
		STZ !P2VectorAccY			; |
		BRA ..done				; | process Y vector
		..dec					; |
		DEC !P2VectorTimeY			; |
		..done					;/


		.Slopes
		LDA !P2Slope : BEQ ..done
		LDX !P2SlopeSpeed : BNE ..unlimit	; 00 = adjust, anything else = unlimit
		..adjust				;\
		LDA $00					; |
		BPL $03 : EOR #$FF : INC A		; | round to nearest multiple of 8
		LSR #3					; |
		BCC $01 : INC A				; |
		TAX					;/
		DEX : BMI ..unlimit			; if speed < 8, treat as 0 and bypass slope adjust
		LDA.l .SlopeIndex,x			;\
		CLC					; |
		ADC #$04				; | get index to slope speed table
		ADC !P2Slope				; | (ordered to prevent overflow)
		TAX					;/
		LDA $00					;\
		CMP.l .SlopeMin,x : BCC ..unlimit	; | update applied X speed while moving up slope
		CMP.l .SlopeMax,x : BCS ..unlimit	; |
		LDA.l .SlopeSet,x : STA $00		;/
		..unlimit
		BIT $01 : BMI ..done			; can't be moving up
		LDA !P2Slope				;\ see if player is going up or down slope
		EOR $00 : BMI ..done			;/
		..downslope				;\
		REP #$20				; |
		LDA !P2Slope				; |
		AND #$00FF				; |
		CMP #$0080				; | adjust Ypos when moving down slope
		BCC $04 : EOR #$00FF : INC A		; |
		CLC : ADC !P2YPosLo			; |
		STA !P2YPosLo				; |
		SEP #$20				;/
		..done
>>>>>>> Stashed changes

		LDA !P2Stasis : BEQ +
		DEC !P2Stasis
		RTS
		+


		LDA !P2GravityTimer : BNE +
		STZ !P2GravityMod
		BRA ++
	+	DEC !P2GravityTimer
		++


<<<<<<< Updated upstream
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
=======
	.UpdateY
		LDA $01
		BEQ ..done
		BMI ..top
		..bottom
		LDA !P2Blocked
		AND #$04
		ORA !P2Platform
		BEQ ..move
		BRA ..done
		..top
		LDA !P2Blocked
		AND #$08 : BNE ..done
		..move
		LDY #$00
		REP #$20
		LDA $01
		AND #$00FF
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream

		.ReturnY
		LDY #$00
=======
		TYA
		ADC !P2YPosHi
		STA !P2YPosHi
		..done

	.Gravity
>>>>>>> Stashed changes
		LDA !P2YSpeed
		CLC : ADC !P2Gravity
		CLC : ADC !P2GravityMod
		STA !P2YSpeed
<<<<<<< Updated upstream
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
=======
		STZ !P2GravityMod
		BMI ..done
		LDX !P2InAir : BNE ..air
		..ground
		CMP #$10 : BCC ..done
		LDA #$10 : BRA ..set
		..air
		CMP !P2FallSpeed : BCC ..done
		LDA !P2FallSpeed
		..set
		STA !P2YSpeed
		..done


; !P2XPosLo used to be stored to $00 before being updated
; doesn't seem like that was used by anything, so i removed it

	.UpdateX
		LDA $00
		BEQ ..done
		BMI ..left
		..right
		LDA !P2Blocked
		LSR A : BCS ..done
		BRA ..move
		..left
		LDA !P2Blocked
		AND #$02 : BNE ..done
		..move
		LDY #$00
		REP #$20
		LDA $00
		AND #$00FF
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
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
=======
		TYA
		ADC !P2XPosHi
		STA !P2XPosHi
		..done



	.Return
		LDA !P2Y				;\
		SEC : SBC $0F				; | set Y delta (px)
		STA !P2YDelta				;/

		REP #$20				;\
		LDA !P2XFraction			; |
		SEC : SBC $0C				; |
		STA $785F				; | how much player moved (sub pixels)
		LDA !P2YFraction			; |
		SEC : SBC $0E				; |
		STA $78D7				; |
>>>>>>> Stashed changes
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



<<<<<<< Updated upstream


=======
; order:
; - supersteep left, steep left, normal left, gradual left
; - flat ground
; - gradual right, normal right, steep right, supersteep right
;
; speed index:
; FF- 0		no index
; 0 - 8		index 0
; 1 - 16	index 9
; 2 - 24	index 18
; 3 - 32	index 27
; 4 - 40	index 36
; 5 - 48	index 45
; 6 - 56	index 54
; 7 - 64	index 63
; 8 - 72	index 72
; 9 - 80	index 81
; A - 88	index 90
; B - 96	index 99
; C - 104	index 108
; D - 112	index 117
; E - 120	index 126
; F - 128	index 135

		.SlopeIndex
		db $00,$09,$12,$1B,$24,$2D,$36,$3F
		db $48,$51,$5A,$63,$6C,$75,$7E,$87


		.SlopeMin
		db $04,$06,$07,$08,$00,$80,$80,$80,$80		; speed = 08
		db $07,$0B,$0E,$10,$00,$80,$80,$80,$80		; speed = 10
		db $0B,$11,$15,$17,$00,$80,$80,$80,$80		; speed = 18
		db $0E,$17,$1D,$1F,$00,$80,$80,$80,$80		; speed = 20
		db $12,$1C,$23,$27,$00,$80,$80,$80,$80		; speed = 28
		db $15,$22,$2B,$2F,$00,$80,$80,$80,$80		; speed = 30
		db $19,$28,$32,$36,$00,$80,$80,$80,$80		; speed = 38
		db $1D,$2D,$39,$3E,$00,$80,$80,$80,$80		; speed = 40
		db $21,$33,$41,$46,$00,$80,$80,$80,$80		; speed = 48
		db $24,$39,$48,$4E,$00,$80,$80,$80,$80		; speed = 50
		db $28,$3E,$4F,$55,$00,$80,$80,$80,$80		; speed = 58
		db $2C,$44,$56,$5D,$00,$80,$80,$80,$80		; speed = 60
		db $2F,$4C,$5E,$65,$00,$80,$80,$80,$80		; speed = 68
		db $33,$51,$65,$6D,$00,$80,$80,$80,$80		; speed = 70
		db $36,$57,$6C,$74,$00,$80,$80,$80,$80		; speed = 78
		db $3A,$5D,$73,$7C,$00,$80,$80,$80,$80		; speed = 80


		.SlopeMax
		db $7F,$7F,$7F,$7F,$00,$F8,$F9,$FA,$FC		; speed = 08
		db $7F,$7F,$7F,$7F,$00,$F0,$F2,$F5,$F9		; speed = 10
		db $7F,$7F,$7F,$7F,$00,$E9,$EB,$EF,$F5		; speed = 18
		db $7F,$7F,$7F,$7F,$00,$E1,$E3,$E9,$F2		; speed = 20
		db $7F,$7F,$7F,$7F,$00,$D9,$DD,$E4,$EE		; speed = 28
		db $7F,$7F,$7F,$7F,$00,$D1,$D5,$DE,$EB		; speed = 30
		db $7F,$7F,$7F,$7F,$00,$CA,$CE,$D8,$E7		; speed = 38
		db $7F,$7F,$7F,$7F,$00,$C2,$C7,$D3,$E3		; speed = 40
		db $7F,$7F,$7F,$7F,$00,$BA,$BF,$CD,$DF		; speed = 48
		db $7F,$7F,$7F,$7F,$00,$B2,$B8,$C7,$DC		; speed = 50
		db $7F,$7F,$7F,$7F,$00,$AB,$B1,$C2,$D8		; speed = 58
		db $7F,$7F,$7F,$7F,$00,$A3,$AA,$BC,$D4		; speed = 60
		db $7F,$7F,$7F,$7F,$00,$9B,$A2,$B4,$D1		; speed = 68
		db $7F,$7F,$7F,$7F,$00,$93,$9B,$AF,$CD		; speed = 70
		db $7F,$7F,$7F,$7F,$00,$8C,$94,$A9,$CA		; speed = 78
		db $7F,$7F,$7F,$7F,$00,$84,$8D,$A3,$C6		; speed = 80


		.SlopeSet
		db $04,$06,$07,$08,$00,$F8,$F9,$FA,$FC		; speed = 08
		db $07,$0B,$0E,$10,$00,$F0,$F2,$F5,$F9		; speed = 10
		db $0B,$11,$15,$17,$00,$E9,$EB,$EF,$F5		; speed = 18
		db $0E,$17,$1D,$1F,$00,$E1,$E3,$E9,$F2		; speed = 20
		db $12,$1C,$23,$27,$00,$D9,$DD,$E4,$EE		; speed = 28
		db $15,$22,$2B,$2F,$00,$D1,$D5,$DE,$EB		; speed = 30
		db $19,$28,$32,$36,$00,$CA,$CE,$D8,$E7		; speed = 38
		db $1D,$2D,$39,$3E,$00,$C2,$C7,$D3,$E3		; speed = 40
		db $21,$33,$41,$46,$00,$BA,$BF,$CD,$DF		; speed = 48
		db $24,$39,$48,$4E,$00,$B2,$B8,$C7,$DC		; speed = 50
		db $28,$3E,$4F,$55,$00,$AB,$B1,$C2,$D8		; speed = 58
		db $2C,$44,$56,$5D,$00,$A3,$AA,$BC,$D4		; speed = 60
		db $2F,$4C,$5E,$65,$00,$9B,$A2,$B4,$D1		; speed = 68
		db $33,$51,$65,$6D,$00,$93,$9B,$AF,$CD		; speed = 70
		db $36,$57,$6C,$74,$00,$8C,$94,$A9,$CA		; speed = 78
		db $3A,$5D,$73,$7C,$00,$84,$8D,$A3,$C6		; speed = 80
>>>>>>> Stashed changes



