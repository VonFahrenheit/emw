
	MAIN:
		LDA !SpriteStatus,x
		CMP #$08 : BNE .Graphics

	.Physics
		LDA $14
		AND #$03 : BNE ..move
		LDA $BE,x
		AND #$01 : TAY
		LDA DATA_YSpeed,y : JSL AccelerateY_Unlimit1
		CMP !SpriteYSpeed,x : BNE ..move
		INC $BE,x
		..move
		LDY !SpriteDir,x
		LDA DATA_XSpeed,y : STA !SpriteXSpeed,x
		JSL APPLY_SPEED_X
		JSL APPLY_SPEED_Y

	.Interaction
		JSL GetSpriteClippingE8
		JSL InteractAttacks : BCC ..noattacks
		LDA #$02 : STA !SpriteStatus,x
		STA !SpriteAnimIndex,x				; heh, keep the 02
		BRA ..nocontact
		..noattacks
		JSL SpriteAttack_NoKnockback			; attack with no knockback
		..nocontact

	.Graphics
		REP #$20
		LDA.w #ANIM : JSL UPDATE_ANIM
		JSL LOAD_PSUEDO_DYNAMIC

	INIT:
		RTS

	DATA:
	.XSpeed
		db $08,$F8

	.YSpeed
		db $04,$FC


	ANIM:
	dw .Swim0	: db $08,$01	; 00
	dw .Swim1	: db $08,$00	; 01
	dw .Dead	: db $FF,$02	; 02

	.Swim0
	dw $0004
	db $22,$00,$00,$00

	.Swim1
	dw $0004
	db $22,$00,$00,$02

	.Dead
	dw $0004
	db $82,$00,$00,$00



