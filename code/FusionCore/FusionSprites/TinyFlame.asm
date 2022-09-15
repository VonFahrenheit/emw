
	TinyFlame:
		LDX !SpriteIndex

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
		TXA
		CLC : ADC $14
		AND #$08 : BEQ ..frame2
		..frame1
		JSR DrawExSprite
		dw !GFX_HoppingFlame_offset
		db $04,$30
		RTS
		..frame2
		JSR DrawExSprite
		dw !GFX_HoppingFlame_offset
		db $14,$30
		RTS






