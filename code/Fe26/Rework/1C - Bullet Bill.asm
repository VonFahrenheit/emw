

	INIT:
		PHB : PHK : PLB
		LDY $3320,x
		LDA DATA_XSpeed,y : STA !SpriteXSpeed,x
		PLB
		RTL


	MAIN:
		PHB : PHK : PLB

	.Physics
		JSL APPLY_SPEED_X
		JSL APPLY_SPEED_Y

	.Interaction
		JSL !GetSpriteClipping04
		JSL P2Standard
		LDA !BigRAM+$7E : BEQ .Graphics
		LDA #$02 : STA $3230,x

	.Graphics
		REP #$20
		LDA.w #ANIM : STA $04
		SEP #$20
		JSL LOAD_PSUEDO_DYNAMIC

		PLB
		RTL

	DATA:
	.XSpeed
		db $20,$E0


	ANIM:
		.Tilemap
		dw $0004
		db $30,$00,$00,$00


