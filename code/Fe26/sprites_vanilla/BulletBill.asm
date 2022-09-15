

	INIT:
		PHB : PHK : PLB
		LDY !SpriteDir,x
		LDA DATA_XSpeed,y : STA !SpriteXSpeed,x
		PLB
		RTS


	MAIN:
		PHB : PHK : PLB

	.Physics
		JSL APPLY_SPEED_X
		JSL APPLY_SPEED_Y

	.Interaction
		JSL GetSpriteClippingE8
		JSL P2Standard
		LDA !BigRAM+$7E : BEQ .Graphics
		LDA #$02 : STA $3230,x

	.Graphics
		REP #$20
		LDA.w #ANIM : STA $04
		SEP #$20
		JSL LOAD_PSUEDO_DYNAMIC

		PLB
		RTS

	DATA:
	.XSpeed
		db $20,$E0


	ANIM:
		.Tilemap
		dw $0004
		db $30,$00,$00,$00


