

	INIT:
		LDA !ExtraBits,x
		AND #$04 : BNE .Roll
		LDA !SpriteNum,x
		CMP #$14 : BNE .Return
		.Roll
		LDA #$02 : STA !SpriteAnimIndex,x
		.Return
		RTS


	MAIN:
		LDA !SpriteStatus,x
		CMP #$08 : BNE .Graphics

	.Physics
		LDY !SpriteDir,x
		LDA !ExtraBits,x
		AND #$04 : BEQ ..notrolling
		..roll
		LDA !SpriteBlocked,x
		AND #$04 : BEQ ..freefall
		LDA DATA_XSpeed+2,y
		JSL AccelerateX_Unlimit2
		JSL AccelerateX_Unlimit2
		..freefall
		JSL ITEM_PHYSICS
		BRA ..done
		..notrolling
		LDA !SpriteNum,x
		CMP #$14 : BNE ..walk
		LDA !SpriteBlocked,x
		AND #$04 : BEQ ..freefall
		LDA !SpriteYSpeed,x : BNE ..freefall
		STZ !SpriteAnimIndex,x
		STZ !SpriteAnimTimer,x
		LDA #$13 : STA !SpriteNum,x
		..walk
		LDA DATA_XSpeed,y : STA !SpriteXSpeed,x
		JSL APPLY_SPEED
		..done

	.Interaction
		JSL GetSpriteClippingE8
		JSL InteractAttacks : BCC ..checkbody
		LDA #$02 : STA !SpriteStatus,x
		LDA #$04 : STA !SpriteAnimIndex,x
		BRA .Graphics
		..checkbody
		JSL P2Standard
		..nocontact

	.Graphics
		REP #$20
		LDA.w #ANIM : JSL UPDATE_ANIM
		JSL LOAD_PSUEDO_DYNAMIC
		RTS


	DATA:
	.XSpeed
		db $08,$F8
		db $20,$E0


	ANIM:
	dw .Walk0	: db $08,$01	; 00
	dw .Walk1	: db $08,$00	; 01
	dw .Roll0	: db $04,$03	; 02
	dw .Roll1	: db $04,$02	; 03
	dw .Dead	: db $FF,$04	; 04

		.Walk0
		dw $0004
		db $22,$00,$00,$00

		.Walk1
		dw $0004
		db $22,$00,$00,$02

		.Roll0
		dw $0004
		db $22,$00,$00,$04

		.Roll1
		dw $0004
		db $22,$00,$00,$06

		.Dead
		dw $0004
		db $A2,$00,$00,$00
