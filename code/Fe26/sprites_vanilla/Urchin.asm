
	!UrchinMode		= $BE
	!UrchinBlinkTimer	= $3280
	!UrchinBlinkState	= $3290

	; 32D0 timer until turning around (used for short boys only)


; mode:
; 00 = short horizontal
; 01 = short vertical
; 02 = long horizontal
; 03 = long vertical
; 04 = follow walls


	INIT:
		LDA !SpriteNum,x
		CMP #$3A : BEQ .Short
		CMP #$3B : BEQ .Long

		.WallFollower
		LDA #$04 : STA !UrchinMode,x
		RTS

		.Short
		LDA #$E0 : STA $32D0,x
		LDA #$00 : BRA .SetDirection

		.Long
		LDA #$02

		.SetDirection
		STA !UrchinMode,x
		LDA !SpriteXLo,x
		AND #$10 : BNE .Return
		INC !UrchinMode,x

		.Return
		STZ !SpriteDir,x				; always face right at the start
		STZ !SpriteFloat,x				; free swim
		RTS


	MAIN:

		.Blink
		%decreg(!UrchinBlinkTimer) : BNE ..done
		LDA !UrchinBlinkState,x
		EOR #$01 : STA !UrchinBlinkState,x
		BNE ..startblink
		..openeyes
		LDA !RNGtable,x
		AND #$1F
		ORA #$60 : BRA ..setblinktimer
		..startblink
		LDA #$08
		..setblinktimer
		STA !UrchinBlinkTimer,x
		..done


	.Physics
		LDA !UrchinMode,x
		CMP #$04 : BCS ..followwalls
		CMP #$02 : BCS ..long

		..short
		LDA !SpriteBlocked,x
		AND #$03 : BNE ..turn
		LDA $32D0,x : BNE ..straightspeed
		..turn
		LDA #$E0 : STA $32D0,x
		LDA !SpriteDir,x
		EOR #$01 : STA !SpriteDir,x
		LDA #$20 : STA !SpriteStasis,x
		BRA ..straightspeed


		..long
		LDA !SpriteBlocked,x
		AND #$03 : BNE ..turn
		..straightspeed
		LDY !SpriteDir,x
		LDA !UrchinMode,x
		LSR A : BCS ..vert
		..horz
		LDA DATA_Speed,y : STA !SpriteXSpeed,x
		STZ !SpriteYSpeed,x
		BRA ..move
		..vert
		STZ !SpriteXSpeed,x
		LDA DATA_Speed,y : STA !SpriteYSpeed,x
		BRA ..move

		..followwalls

		..move
		JSL APPLY_SPEED
		..done




	.Interaction
		JSL GetSpriteClippingE8
		JSL SpriteAttack_NoKnockback


	.Graphics
		LDA !UrchinBlinkState,x
		REP #$20
		BNE ..blink
		LDA.w #ANIM_EyeTM : BRA ..draweye
		..blink
		LDA.w #ANIM_BlinkTM
		..draweye
		STA $04
		SEP #$20
		JSL LOAD_PSUEDO_DYNAMIC

		REP #$20
		LDA.w #ANIM : JSL UPDATE_ANIM
		JSL LOAD_PSUEDO_DYNAMIC

		RTS


	DATA:
	.Speed
		db $08,$F8



	ANIM:
	dw .Tilemap0	: db $10,$01	; 00
	dw .Tilemap1	: db $10,$02	; 01
	dw .Tilemap0	: db $10,$03	; 02
	dw .Tilemap2	: db $10,$00	; 03

	.Tilemap0
	dw $0010
	db $22,$F8,$F0,$00
	db $62,$08,$F0,$00
	db $A2,$F8,$00,$00
	db $E2,$08,$00,$00

	.Tilemap1
	dw $0010
	db $22,$F8,$F0,$02
	db $62,$08,$F0,$02
	db $A2,$F8,$00,$02
	db $E2,$08,$00,$02

	.Tilemap2
	dw $0010
	db $22,$F8,$F0,$04
	db $62,$08,$F0,$04
	db $A2,$F8,$00,$04
	db $E2,$08,$00,$04

	; drawn separately on top
	.EyeTM
	dw $0008
	db $20,$00,$F8,$06
	db $20,$08,$F8,$07

	.BlinkTM
	dw $0008
	db $20,$00,$F8,$16
	db $20,$08,$F8,$17

