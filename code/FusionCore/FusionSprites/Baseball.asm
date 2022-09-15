
	Baseball:
		LDX !SpriteIndex

	.Physics
		JSR ApplySpeed

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
		JSR DrawExSprite
		dw !GFX_Baseball_offset
		db $00,$31

	.Return
		RTS






