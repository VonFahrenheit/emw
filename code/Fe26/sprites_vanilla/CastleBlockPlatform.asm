
	!BlockDirection		= $BE



	INIT:
		LDA #$01 : STA !SpriteDir,x
	MAIN:

	.Physics
		LDA $32D0,x : BNE ..process
		LDA !BlockDirection,x
		EOR #$01 : STA !BlockDirection,x
		LDA #$70 : STA $32D0,x
		..process
		CMP #$50 : BCC ..move
		LDA #$00 : BRA ..setspeed
		..move
		LDY !BlockDirection,x
		LDA DATA_XSpeed,y
		..setspeed
		STA !SpriteXSpeed,x
		JSL APPLY_SPEED_X
		..done

	.Interaction
		JSL GetSpriteClippingE8
		LDA #$04 : JSL OutputPlatformBox

	.Graphics
		REP #$20
		LDA.w #.Tilemap : STA $04
		SEP #$20
		JSL LOAD_PSUEDO_DYNAMIC

		RTS


	.Tilemap
	dw $0010
	db $22,$00,$00,$00
	db $22,$10,$00,$02
	db $22,$00,$10,$04
	db $22,$10,$10,$06



	DATA:
	.XSpeed
		db $10,$F0


