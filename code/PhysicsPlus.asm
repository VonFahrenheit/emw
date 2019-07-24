header
sa1rom


	!SprYSpeed =		$AA
	!SprXSpeed =		$B6
	!SprYPosLo =		$D8
	!SprXPosLo =		$E4
	!SprYPosHi =		$14D4
	!SprXPosHi =		$14E0
	!SprYFraction =		$14EC
	!SprXFraction =		$14F8

	!SprObjDisable =	$15DC
	!SprWater =		$164A

	
	!SprStasis =		$0000		; Speed is zero while this timer is active.
	!SprTimeFactor =	$0000		; See below for format.
	!SprTimeMem =		$0000		; Fraction bits for time factor
	!SprTimeDeriv =		$0000		; How much to move time factor towards 1 every frame.

	!SprYSpeedAlt =		$0000
	!SprXSpeedAlt =		$0000
	!SprYFractionAlt =	$0000
	!SprXFractionAlt =	$0000
	!SprYAccAlt =		$0000
	!SprXAccAlt =		$0000



	!PixelCount =		$1491


	org $01802A
		autoclean JML PhysicsPlus	; PHB : PHK : PLB : JSR $9032





; Factor formula:
; V * (F + 1)/$80 = Actual V
; Unless F = 0x00, in which case speed is not applied.





	freecode
	PhysicsPlus:

		LDA !SprTimeFactor,x
		BMI .NegativeFactor
		CMP #$7F
		BEQ .PerfectFactor

		.PositiveFactor
		CLC : ADC !SprTimeDeriv,x
		BPL $02 : LDA #$7F
		BRA .StoreFactor

		.NegativeFactor
		SEC : SBC !SprTimeDeriv,x
		BMI $02 : LDA #$7F

		.StoreFactor
		STA !SprTimeFactor,x

		.PerfectFactor
		LDA !SprStasis,x		;\ No speed during stasis
		BNE .Stasis			;/

		LDA !SprTimeFactor,x		;\ No speed if time factor is zero
		BEQ .Stasis			;/
		INC A				;\
		BEQ .FullSpeed			; |
		ASL A				; | Run physics an extra time if there is overflow
		CLC : ADC !SprTimeMem,x		; |
		STA !SprTimeMem,x		; |
		BCC .NotTwice			;/

		.FullSpeed
		JSL .MAIN

		.NotTwice
		LDA !SprTimeFactor,x		;\
		INC A				; |
		BEQ .MAIN			; | Run physics normally if time factor is 1 or greater
		BMI .MAIN			; |
		RTL				;/


		.MAIN
		LDA !SprYSpeed,x
		BEQ $03 : JSR UpdateY
		LDA !SprYSpeedAlt,x
		BEQ $03 : JSR UpdateAltY


		LDY #$00
		LDA !SprWater,x
		BEQ .NoWater

		.Water				;\
		INY				; |
		LDA !SprYSpeed,x		; |
		BPL .NoWater			; | Limit Yspeed under water
		CMP #$E8 : BCS .NoWater		; |
		LDA #$E8 : STA !SprYSpeed,x	; |
		.NoWater			;/

		LDA !SprYSpeed,x		;\
		CLC : ADC .Gravity,y		; | Apply gravity
		STA !SprYSpeed,x		;/
		BMI .Up

		.Down				;\
		CMP .MaxFallSpeed,y : BCC .Up	; |
		LDA .MaxFallSpeed,y		; | Limit fall speed
		STA !SprYSpeed,x		; |
		.Up				;/

		LDA !SprXSpeed,x : PHA
		LDY !SprWater,x
		BEQ +
		ASL A
		ROR !SprXSpeed,x
		LDA !SprXSpeed,x : PHA
		STA $00
		ASL A
		ROR $00
		PLA
		CLC : ADC $00
		STA !SprXSpeed,x

	+	LDA !SprXSpeed,x
		BEQ $03 : JSR UpdateX
		LDA !SprXSpeedAlt,x
		BEQ $03 : JSR UpdateAltX
		PLA : STA !SprXSpeed,x

		.Stasis
		LDA !SprObjDisable,x
		BNE .Return
		JSR Objects

		.Return
		RTL


		.MaxFallSpeed
		db $40,$10			; Air, water

		.Gravity
		db $03,$01			; Air, water


	UpdateY:
		ASL #4
		CLC : ADC !SprYFraction,x
		STA !SprYFraction,x
		PHP : PHP
		LDY #$00
		LDA !SprYSpeed,x
		LSR #4
		CMP #$08 : BCC .Pos

		.Neg
		ORA #$F0
		DEY
		.Pos

		PLP
		PHA
		ADC !SprYPosLo,x
		STA !SprYPosLo,x
		TYA
		ADC !SprYPosHi,x
		STA !SprYPosHi,x
		PLA
		PLP
		ADC #$00
		STA !PixelCount
		RTS


	UpdateX:
		ASL #4
		CLC : ADC !SprXFraction,x
		STA !SprXFraction,x
		PHP : PHP
		LDY #$00
		LDA !SprXSpeed,x
		LSR #4
		CMP #$08 : BCC .Pos

		.Neg
		ORA #$F0
		DEY
		.Pos

		PLP
		PHA
		ADC !SprXPosLo,x
		STA !SprXPosLo,x
		TYA
		ADC !SprXPosHi,x
		STA !SprXPosHi,x
		PLA
		PLP
		ADC #$00
		STA !PixelCount
		RTS


	UpdateAltY:
		ASL #4
		CLC : ADC !SprYFractionAlt,x
		STA !SprYFractionAlt,x
		PHP : PHP
		LDY #$00
		LDA !SprYSpeedAlt,x
		LSR #4
		CMP #$08 : BCC .Pos

		.Neg
		ORA #$F0
		DEY
		.Pos

		PLP
		PHA
		ADC !SprYPosLo,x
		STA !SprYPosLo,x
		TYA
		ADC !SprYPosHi,x
		STA !SprYPosHi,x
		PLA
		PLP
		ADC #$00
		STA !PixelCount

		LDA !SprYSpeedAlt,x
		BPL .AccNeg

		.AccPos
		CLC : ADC !SprYAccAlt,x
		BPL .AccReset
		STA !SprYSpeedAlt,x
		RTS

		.AccNeg
		SEC : SBC !SprYAccAlt,x
		BEQ .AccReset
		BMI .AccReset
		STA !SprYSpeedAlt,x
		RTS

		.AccReset
		STZ !SprYSpeedAlt,x
		STZ !SprYFractionAlt,x
		LDA #$01 : STA !SprYAccAlt,x
		RTS


	UpdateAltX:
		ASL #4
		CLC : ADC !SprXFractionAlt,x
		STA !SprXFractionAlt,x
		PHP : PHP
		LDY #$00
		LDA !SprXSpeedAlt,x
		LSR #4
		CMP #$08 : BCC .Pos

		.Neg
		ORA #$F0
		DEY
		.Pos

		PLP
		PHA
		ADC !SprXPosLo,x
		STA !SprXPosLo,x
		TYA
		ADC !SprXPosHi,x
		STA !SprXPosHi,x
		PLA
		PLP
		ADC #$00
		STA !PixelCount

		LDA !SprXSpeedAlt,x
		BPL .AccNeg

		.AccPos
		CLC : ADC !SprXAccAlt,x
		BPL .AccReset
		STA !SprXSpeedAlt,x
		RTS

		.AccNeg
		SEC : SBC !SprXAccAlt,x
		BEQ .AccReset
		BMI .AccReset
		STA !SprXSpeedAlt,x
		RTS

		.AccReset
		STZ !SprXSpeedAlt,x
		STZ !SprXFractionAlt,x
		LDA #$01 : STA !SprXAccAlt,x
		RTS




