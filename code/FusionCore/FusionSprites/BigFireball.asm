
	BigFireball:
		LDX !SpriteIndex

	.Physics
		JSR ApplySpeed
		..gravity
		LDA !Ex_YSpeed,x : BMI ..acc
		CMP #$40 : BCS ..done
		..acc
		INC !Ex_YSpeed,x
		INC !Ex_YSpeed,x
		INC !Ex_YSpeed,x
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
		LDA #$000C
		STA $EC
		STA $EE
		SEP #$20
		JSL PlayerContact : BCC ..done
		JSL HurtPlayers
		..done

	.Graphics
		JSR DrawExSprite
		dw !GFX_ReznorFireball_offset
		db $00,$33

		.Return
		RTS






