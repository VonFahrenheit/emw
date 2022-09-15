
	VolcanoLotusFire:
		LDX !SpriteIndex

	.Physics
		JSR ApplySpeed
		..gravity
		LDA $14
		AND #$03 : BNE ..done
		LDA !Ex_YSpeed,x : BMI ..acc
		CMP #$18 : BCS ..done
		..acc
		INC !Ex_YSpeed,x
		..done

	.Drift
		BIT !Ex_YSpeed,x : BMI ..done
		TXA
		ASL #3 : ADC $14
		LDY #$08
		AND #$08
		BNE $02 : LDY #$F8
		TYA : STA !Ex_XSpeed,x
		..done

	.Interaction
		LDA !Ex_XLo,x : STA $E8
		LDA !Ex_XHi,x : STA $E9
		LDA !Ex_YLo,x : STA $EA
		LDA !Ex_YHi,x : STA $EB
		REP #$20
		INC $E8
		INC $E8
		INC $EA
		INC $EA
		LDA #$0004
		STA $EC
		STA $EE
		SEP #$20
		JSL PlayerContact : BCC ..done
		JSL HurtPlayers
		..done

	.Graphics
		LDA $14
		LSR A
		EOR !SpriteIndex
		LSR #2
		BCS ..frame2
		..frame1
		JSR DrawExSprite
		dw !GFX_LotusPollen_offset
		db $00,$30
		RTS
		..frame2
		JSR DrawExSprite
		dw !GFX_LotusPollen_offset
		db $10,$30
		RTS






