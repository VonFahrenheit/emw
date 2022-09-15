

	MAIN:
		LDA !SpriteStatus,x
		CMP #$08 : BNE .Graphics

	.Physics
		JSL SUB_HORZ_POS
		TYA : STA !SpriteDir,x

		JSL APPLY_SPEED
		LDA !SpriteBlocked,x
		AND #$04 : BEQ ..done
		LDA $32D0,x : BNE ..done
		LDA #$60 : STA $32D0,x
		INC $BE,x
		LDA $BE,x
		AND #$03 : TAY
		LDA DATA_JumpHeight,y : STA !SpriteYSpeed,x
		..done

	.Interaction
		JSL GetSpriteClippingE8
		JSL InteractAttacks : BCS ..die
		JSL P2Standard : BEQ ..nocontact
		..fall
		STZ !SpriteYSpeed,x
		..die
		LDA #$02 : STA !SpriteStatus,x
		..nocontact

	.Graphics
		LDA !SpriteStatus,x
		CMP #$08 : BEQ ..checkanim
		REP #$20
		LDA.w #ANIM_Dead : STA $04
		SEP #$20
		JSL LOAD_PSUEDO_DYNAMIC
		RTS
		..checkanim
		BIT !SpriteYSpeed,x : BMI ..jump
		..idle
		JSL DRAW_SIMPLE_0
		RTS
		..jump
		JSL DRAW_SIMPLE_2

	INIT:
		RTS


	DATA:
	.JumpHeight
		db $D0,$C0,$B0,$D0


	ANIM:
		.Idle
		dw $0004
		db $22,$00,$00,$00

		.Jump
		dw $0004
		db $22,$00,$00,$02

		.Dead
		dw $0004
		db $A2,$00,$00,$02


