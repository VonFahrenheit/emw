

	INIT:
		REP #$30
		LDA #$0000
		LDY #$FFF8
		JSL GetMap16_Sprite
		CMP #$0025
		SEP #$30
		BEQ MAIN_PhysicsAnimation_triggerattack

		.Return
		RTS

	MAIN:

	.PhysicsAnimation
		LDA $BE,x : BNE ..attack

		; state 0: waitin time
		REP #$20
		LDA.w #DATA_SwooperSight : JSL LOAD_HITBOX
		JSL PlayerContact : BCC ..done
		..triggerattack
		INC $BE,x
		LDA #$01 : STA !SpriteAnimIndex,x
		STZ !SpriteAnimTimer,x
		LDA #$20 : STA !SpriteYSpeed,x				; initial y speed
		LDA #$26 : STA !SPC4					; swooper sfx
		BRA ..move

		..attack
		CMP #$02 : BEQ ..movestraight

		; state 1: swoopin time
		LDA $14
		AND #$03 : BNE ..move
		LDY !SpriteDir,x
		LDA DATA_TargetXSpeed,y : JSL AccelerateX_Unlimit1
		LDA !SpriteYSpeed,x : BEQ ..move
		DEC !SpriteYSpeed,x : BNE ..move
		INC $BE,x						; go into fly straight mode

		..movestraight
		; state 2: move straight time
		LDA $14
		LSR A : BCS ..move
		LDA $3280,x
		AND #$01 : TAY
		LDA DATA_TargetYSpeed,y
		JSL AccelerateY_Unlimit1
		CMP !SpriteYSpeed,x : BNE ..move
		INC $3280,x

		..move
		JSL APPLY_SPEED_X
		JSL APPLY_SPEED_Y
		..done


	.Interaction
		JSL GetSpriteClippingE8
		JSL InteractAttacks : BCS ..die
		JSL P2Standard : BEQ ..nocontact
		..fall
		STZ !SpriteYSpeed,x
		..die
		LDA #$02 : STA !SpriteStatus,x
		LDA #$03 : STA !SpriteAnimIndex,x
		..nocontact



	.Graphics
		REP #$20
		LDA.w #ANIM : JSL UPDATE_ANIM
		JSL LOAD_PSUEDO_DYNAMIC
		RTS


	DATA:
	.SwooperSight
		dw $FFB0,$0000 : db $B0,$D0

	.TargetXSpeed
		db $10,$F0

	.TargetYSpeed
		db $04,$FC


	ANIM:
		dw .Idle	: db $FF,$00	; 00
		dw .Fly0	: db $04,$02	; 01
		dw .Fly1	: db $04,$01	; 02
		dw .Dead	: db $FF,$03	; 03

		.Idle
		dw $0004
		db $22,$00,$FF,$00

		.Fly0
		dw $0004
		db $22,$00,$00,$02

		.Fly1
		dw $0004
		db $22,$00,$00,$04

		.Dead
		dw $0004
		db $A2,$00,$00,$04

