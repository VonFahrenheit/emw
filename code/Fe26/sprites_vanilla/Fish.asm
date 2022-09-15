

	!FishJumpCount		= $BE
	!FishPrevWater		= $3280


	INIT:
		STZ !SpriteFloat,x
		RTS

	MAIN:
		LDA !SpriteStatus,x
		CMP #$08 : BEQ .Physics
		JMP .Graphics

	.Physics
		LDA !SpriteNum,x
		CMP #$18 : BNE ..simplefish
		LDA !SpriteWater,x : BNE ..surfaceswim
		LDA !SpriteBlocked,x
		AND #$04 : BNE ..flop
		LDA !FishPrevWater,x : BEQ +
		..jump
		LDY !FishJumpCount,x
		LDA DATA_JumpSpeed,y : STA !SpriteYSpeed,x
		INY
		CPY #$03
		BCC $02 : LDY #$00
		STY !FishJumpCount,x
	+	JMP ..move
		..surfaceswim
		LDA !FishJumpCount,x : BNE ++
		LDA $14
		AND #$03 : BNE +
	++	LDA #$E8
		JSL AccelerateY_Unlimit1
	+	LDY !SpriteDir,x
		LDA DATA_SwimSpeed,y : STA !SpriteXSpeed,x
		BRA ..move


		..simplefish
		LDA !SpriteWater,x : BNE ..swim
		..flop
		LDA #$15 : STA !SpriteNum,x				; reset to horizontal fish upon flopping
		LDA !SpriteBlocked,x
		AND #$04 : BEQ ..move
		LDA !RNG
		AND #$3C
		ADC !SpriteTweaker5,x
		AND #$F8 : STA !SpriteYSpeed,x
		LDA !RNG
		AND #$03 : TAY
		LDA DATA_BounceXSpeed,y : STA !SpriteXSpeed,x
		LDA #$00
		BIT !RNG
		BPL $01 : INC A
		STA !SpriteDir,x
		BIT !RNG : BVC ..move
		LDA #$07 : STA !SpriteAnimTimer,x
		BRA ..move
		..swim
		LDA $32D0,x : BNE ..forward
		LDA !SpriteDir,x
		EOR #$01 : STA !SpriteDir,x
		LDA #$80 : STA $32D0,x
		..forward
		LDY !SpriteDir,x
		LDA !SpriteNum,x
		CMP #$15 : BEQ ..sideways
		..vertical
		LDA DATA_SwimSpeed,y : STA !SpriteYSpeed,x
		STZ !SpriteXSpeed,x
		BRA ..move
		..sideways
		LDA DATA_SwimSpeed,y : STA !SpriteXSpeed,x
		STZ !SpriteYSpeed,x
		..move
		LDA !SpriteWater,x : STA !FishPrevWater,x
		JSL APPLY_SPEED


	.Interaction
		JSL GetSpriteClippingE8
		JSL InteractAttacks : BCS ..die
		LDY !SpriteWater,x : BEQ ..kick
		..water
		JSL SpriteAttack_NoKnockback			; attack with no knockback
		BRA ..nocontact
		..kick
		LDA #$08 : JSL P2Kick
		..die
		LDA !SpriteWater,x : BEQ +
		LDA #$04 : STA !SpriteAnimIndex,x
	+	LDA #$02 : STA !SpriteStatus,x
		BRA .Graphics
		..nocontact


	.Animation
		LDA !SpriteNum,x
		CMP #$18 : BEQ ..done
		LDA !SpriteWater,x : BEQ ..land

		..swim
		LDA !SpriteAnimIndex,x
		CMP #$02 : BCC ..done
		LDA #$00 : BRA ..setanim

		..land
		LDA #$02
		CMP !SpriteAnimIndex,x
		BEQ ..done
		BCC ..done
		..setanim
		STA !SpriteAnimIndex,x
		STZ !SpriteAnimTimer,x

		..done


	.Graphics
		REP #$20
		LDA.w #ANIM : JSL UPDATE_ANIM
		JSL LOAD_PSUEDO_DYNAMIC
		RTS


	DATA:
	.SwimSpeed
		db $0C,$F4

	.BounceXSpeed
		db $F0,$F8,$08,$10

	.JumpSpeed
		db $E0,$E0,$C0


	ANIM:
	dw .Swim0	: db $10,$01	; 00
	dw .Swim1	: db $10,$00	; 01
	dw .Flop0	: db $08,$03	; 02
	dw .Flop1	: db $08,$02	; 03
	dw .Dead	: db $FF,$04	; 04

	.Swim0
	dw $0004
	db $22,$00,$00,$00

	.Swim1
	dw $0004
	db $22,$00,$00,$02

	.Flop0
	dw $0004
	db $22,$00,$00,$04

	.Flop1
	dw $0004
	db $22,$00,$00,$06

	.Dead
	dw $0004
	db $A2,$00,$00,$00


