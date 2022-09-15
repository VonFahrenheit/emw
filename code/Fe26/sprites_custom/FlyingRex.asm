

	!Temp = 0
	%def_anim(FlyingRex_Fly, 2)
	%def_anim(FlyingRex_Swoop, 2)


	!DisableSwoopTimer	= $3280
	!SwoopoInitialYLo	= $3290
	!SwoopoInitialYHi	= $32A0
	!FlyingRexTimer		= $32D0



	; values
	!SwoopTimeEasy		= $A8
	!SwoopOffsetEasy	= $4F

	!SwoopTimeNormal	= $72
	!SwoopOffsetNormal	= $2F

	!SwoopTimeInsane	= $5F
	!SwoopOffsetInsane	= $21





FlyingRex:

	namespace FlyingRex


	INIT:
		RTL


	MAIN:
		PHB : PHK : PLB


	PHYSICS:

		%decreg(!DisableSwoopTimer)

		.Speed
		LDA !ExtraBits,x
		AND #$04 : BEQ ..move
		JSL SUB_HORZ_POS
		TYA : STA !SpriteDir,x
		JMP ..done
		..move
		LDA !FlyingRexTimer,x
		ORA !DisableSwoopTimer,x
		BNE ..notseen

		REP #$20
		LDA.w #DATA_SightBox : JSL LOAD_HITBOX
		JSL PlayerContact : BCC ..notseen
		LDY !Difficulty
		LDA DATA_FlyTimer,y : STA !FlyingRexTimer,x
		LDA #$02 : STA !SpriteAnimIndex,x
		STZ !SpriteAnimTimer,x
		LDA #$26 : STA !SPC4				; swooper SFX
		..notseen
		LDY !Difficulty
		LDA !FlyingRexTimer,x : BEQ ..forward
		CMP DATA_RiseThreshold,y : BCS ..swoop
		..rise
		LDA #$20 : STA !DisableSwoopTimer,x
		LDY !Difficulty
		LDA DATA_SwoopSpeed,y
		EOR #$FF
		BRA ..acc
		..swoop
		LDY !Difficulty
		LDA DATA_SwoopSpeed,y
		BRA ..acc
		..forward
	;	LDA !SpriteYSpeed,x : BNE +
	;	LDA !SwoopoInitialYLo,x : STA !SpriteYLo,x
	;	LDA !SwoopoInitialYHi,x : STA !SpriteYHi,x
	;	+
		LDA !SpriteAnimIndex,x
		CMP #$02 : BCC +
		STZ !SpriteAnimIndex,x
		STZ !SpriteAnimTimer,x
	+	LDA #$00
	..acc	JSL AccelerateY
		LDY !SpriteDir,x
		LDA DATA_XSpeed,y : STA !SpriteXSpeed,x
		..applyspeed
		JSL APPLY_SPEED_X
		JSL APPLY_SPEED_Y
		..done
		LDA !SpriteExtraCollision,x
		AND #$40
		BEQ $02 : LDA #$01
		STA !SpriteWater,x
		STZ !SpriteExtraCollision,x



	INTERACTION:
		JSL GetSpriteClippingE8
		JSL InteractAttacks : BCS .Hurt
		JSL P2Standard : BEQ .Done

		.Hurt
		LDA #$01 : STA !SpriteHP,x
		LDA #$02 : STA !SpriteNum,x
		LDA #!Rex_Hurt : STA !SpriteAnimIndex,x
		STZ !SpriteAnimTimer,x
		STZ !ExtraProp1,x
		STZ !ExtraProp2,x
		INX						; process this sprite again
		PLB
		RTL

		.Done


	GRAPHICS:

		.WaterCheck
		LDA !3DWater : BEQ ..done
		LDA !SpriteYHi,x : XBA
		LDA !SpriteYLo,x
		REP #$20
		CMP !Level+2
		SEP #$20
		BCC ..done
		LDA $14
		LSR A : BCS ..done
		DEC !SpriteAnimTimer,x
		..done

		REP #$20
		LDA.w #ANIM : JSL UPDATE_ANIM
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

		.FlyTimer
		db !SwoopTimeEasy,!SwoopTimeNormal,!SwoopTimeInsane

		.RiseThreshold
		db !SwoopTimeEasy-!SwoopOffsetEasy
		db !SwoopTimeNormal-!SwoopOffsetNormal
		db !SwoopTimeInsane-!SwoopOffsetInsane

		.SightBox
		dw $FFE0,$0000 : db $20,$80



	namespace off












