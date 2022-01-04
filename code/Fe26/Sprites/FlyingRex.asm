

	!Temp = 0
	%def_anim(FlyingRex_Fly, 2)
	%def_anim(FlyingRex_Swoop, 2)


	!FlyingRexTargetPlayer	= $3280
	!FlyingRexTargetYLo	= $3290
	!FlyingRexTargetYHi	= $32A0
	!FlyingRexState		= $32B0

	!FlyingRexTimer		= $32D0


FlyingRex:

	namespace FlyingRex


	INIT:
		PHB : PHK : PLB
		JSL SUB_HORZ_POS
		TYA : STA $3320,x
		STZ !FlyingRexTargetPlayer,x			; just in case
		LDA !Difficulty
		AND #$03 : TAY
		LDA $3210,x
		CLC : ADC DATA_SwoopDisp,y
		STA !FlyingRexTargetYLo,x			; save adjusted Ypos
		LDA $3240,x
		ADC #$00
		STA !FlyingRexTargetYHi,x
		LDA #!palset_generic_lightblue : JSL LoadPalset
		LDX $0F
		LDA !Palset_status,x
		LDX !SpriteIndex
		ASL A
		STA $33C0,x
		PLB
		RTL



	MAIN:
		PHB : PHK : PLB
		JSL SPRITE_OFF_SCREEN
		LDA $9D : BEQ .Process
		JMP GRAPHICS

		.Process
		LDA $BE,x : BNE .Transform
		LDA $3230,x
		CMP #$08 : BEQ PHYSICS
		CMP #$02 : BNE .Return
		LDA #$02 : STA $BE,x

		.Transform
		LDA #$34 : STA !NewSpriteNum,x
		LDA #$01
		STA !RexChase,x
		STA !RexDensity,x
		LDA #!Rex_Hurt : STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		STZ !ExtraProp1,x
		LDA !ExtraProp2,x
		AND #$C0
		STA !ExtraProp2,x
		INX						; process this sprite again

		.Return
		PLB
		RTL




	PHYSICS:

		.Speed
		LDA !ExtraBits,x
		AND #$04 : BEQ ..move
		JSL SUB_HORZ_POS
		TYA : STA $3320,x
		JMP ..done
		..move
		LDA !FlyingRexTimer,x : BNE ..notseen
		LDA !FlyingRexState,x : BNE ..notseen
		LDY $3320,x
		LDA $3220,x
		CLC : ADC DATA_SightX,y
		STA $04
		LDA $3250,x
		ADC DATA_SightX+2,y
		STA $0A
		LDA $3210,x : STA $05
		LDA $3240,x : STA $0B
		LDA #$20 : STA $06
		LDA #$80 : STA $07
		SEC : JSL !PlayerClipping : BCC ..notseen
		CMP #$02 : BCC +
		LDA #$80 : STA !FlyingRexTargetPlayer,x		; target player 2
	+	LDA #$01 : STA !FlyingRexState,x
		LDA #$3F : STA !FlyingRexTimer,x
		LDA #$02 : STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		LDA #$26 : STA !SPC4				; swooper SFX
		..notseen
		LDA !FlyingRexState,x : BEQ ..forward
		CMP #$01 : BEQ ..swoop
		..rise
		LDA $3210,x
		CMP !FlyingRexTargetYLo,x
		LDA $3240,x
		SBC !FlyingRexTargetYHi,x
		BCS +
		STZ !FlyingRexState,x
		STZ !SpriteAnimIndex
		STZ !SpriteAnimTimer
		LDA #$30 : STA !FlyingRexTimer,x
	+	LDA !Difficulty
		AND #$03 : TAY
		LDA DATA_SwoopSpeed,y
		EOR #$FF
		BRA ..acc
		..swoop
		LDY !FlyingRexTargetPlayer,x : BNE +
		JSL SUB_VERT_POS_P1 : BRA ++
	+	JSL SUB_VERT_POS_P2
	++	CPY #$00 : BEQ +
		LDA #$02 : STA !FlyingRexState,x
		BRA ..rise
	+	LDA !Difficulty
		AND #$03 : TAY
		LDA DATA_SwoopSpeed,y
		BRA ..acc
		..forward
		LDA #$00
	..acc	JSL AccelerateY
		LDY $3320,x
		LDA DATA_XSpeed,y : STA !SpriteXSpeed,x
		..applyspeed
		JSL !SpriteApplySpeed-$10
		JSL !SpriteApplySpeed-$08
		..done
		LDA !SpriteExtraCollision,x
		AND #$40
		BEQ $02 : LDA #$01
		STA !SpriteWater,x
		STZ !SpriteExtraCollision,x



	INTERACTION:
		JSL !GetSpriteClipping04

		.Attack
		JSL P2Attack : BCC ..nocontact
		LDA #$01 : STA $BE,x
		LDA #$08 : JSL DontInteract
		LDA !P2Hitbox1XSpeed-$80,y : STA !SpriteXSpeed,x
		LDA !P2Hitbox1YSpeed-$80,y : STA !SpriteYSpeed,x
		..nocontact

		.Body
		JSL P2Standard
		BCC ..nocontact
		BEQ ..nocontact
		LDA #$01 : STA $BE,x
		..nocontact

		.Fireball
		JSL FireballContact_Destroy : BCC ..nocontact
		LDA #$01 : STA $BE,x
		LDA $00 : STA !SpriteXSpeed,x
		LDA #$E8 : STA !SpriteYSpeed,x
		..nocontact


	GRAPHICS:

		.HandleUpdate
		STZ $00
		LDA !3DWater : BEQ +
		LDA !SpriteYHi,x : XBA
		LDA !SpriteYLo,x
		REP #$20
		CMP !Level+2
		SEP #$20
		BCC +
		LDA $14
		LSR A : BCS ++
	+	INC $00
		++

		LDA !SpriteAnimIndex
		ASL #2
		TAY
		LDA !SpriteAnimTimer
		CLC : ADC $00
		CMP.w ANIM+2,y : BNE .SameAnim
		.NewAnim
		LDA.w ANIM+3,y : STA !SpriteAnimIndex
		ASL #2
		TAY
		LDA #$00
		.SameAnim
		STA !SpriteAnimTimer

		.Draw
		LDA !SpriteAnimIndex
		ASL #2
		TAY
		REP #$20
		LDA.w ANIM+0,y : STA $04
		SEP #$20
		JSL LOAD_PSUEDO_DYNAMIC
		PLB
		RTL



	ANIM:
	; fly
		dw .FlyTM00 : db $02,!FlyingRex_Fly+1
		dw .FlyTM01 : db $02,!FlyingRex_Fly+0
	; swoop
		dw .SwoopTM00 : db $02,!FlyingRex_Swoop+1
		dw .SwoopTM01 : db $02,!FlyingRex_Swoop+0


	.FlyTM00
		dw $0010
		db $22,$F8,$F0,$00
		db $22,$08,$F0,$02
		db $22,$F8,$00,$20
		db $22,$08,$00,$22
	.FlyTM01
		dw $0010
		db $22,$F8,$F0,$04
		db $22,$08,$F0,$06
		db $22,$F8,$00,$24
		db $22,$08,$00,$26

	.SwoopTM00
		dw $0010
		db $22,$F8,$F0,$08
		db $22,$08,$F0,$0A
		db $22,$F8,$00,$28
		db $22,$08,$00,$2A
	.SwoopTM01
		dw $0010
		db $22,$F8,$F0,$0C
		db $22,$08,$F0,$0E
		db $22,$F8,$00,$2C
		db $22,$08,$00,$2E




	DATA:
		.XSpeed
		db $10,$F0

		.SwoopSpeed
		db $18,$28,$38,$48

		.SwoopDisp
		db $08,$18,$2F,$4F

		.SightX
		db $00,$E0
		db $00,$FF



	namespace off












