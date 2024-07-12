
	INIT:
		LDA #$80 : STA $32D0,x

	MAIN:
		REP #$20
		LDA.w #ANIM : JSL AUTO_ANIM : BNE .Physics		;\
		LDA !SpriteAnimIndex,x : BNE .Physics			; |
		JSL SUB_HORZ_POS					; |
		TYA : STA !SpriteDir,x					; | when anim 0 is autod, sprite will pick a random wait duration and face player
		LDA !RNG						; | (happens after attack and after rising from rubble)
		AND #$3F						; |
		ORA #$80						; |
		STA $32D0,x						;/
		LDA !SpriteTweaker3,x					;\ remove spiky surface trait
		AND.b #$40^$FF : STA !SpriteTweaker3,x			;/


	.Physics
		LDA !SpriteAnimIndex,x
		CMP #$09 : BEQ ..rubble ; BCS ..rubble
		CMP #$03 : BCS ..still

		..walking
		LDA $32D0,x : BEQ ..startspike
		LDY !SpriteDir,x
		LDA DATA_XSpeed,y : STA !SpriteXSpeed,x
		BRA ..move

		..rubble
		LDA $32D0,x : BEQ ..standup
		CMP #$20 : BCS ..still
		JSL ShakeX
		BRA ..still

		..standup
		LDA #$0A : BRA ..setanim

		..startspike
		LDA !SpriteTweaker3,x					;\ add spiky surface trait
		ORA #$40 : STA !SpriteTweaker3,x			;/

		LDA #$03
		..setanim
		STA !SpriteAnimIndex,x
		STZ !SpriteAnimTimer,x

		..still
		JSL AccelerateX_Friction2

		..move
		JSL APPLY_SPEED


	.Interaction
		LDA !SpriteAnimIndex,x					;\ no interaction during rubble anim
		CMP #$09 : BCS ..nocontact				;/
		JSL GetSpriteClippingE8
		JSL P2Attack : BCS ..stun
		JSL ThrownItemContact : BCS ..stun
		JSL FireballContact_Destroy : BCS ..stun
		JSL P2Standard : BEQ ..nocontact
		..stun
		LDA #$09 : STA !SpriteAnimIndex,x
		STZ !SpriteAnimTimer,x
		LDA #$C0 : STA $32D0,x					; stun timer
		LDA #$07 : STA !SPC1					; SFX

		..nocontact


	.Graphics
		REP #$20
		LDA.w #ANIM : JSL UNPACK_ANIM
		LDA !SpriteAnimIndex,x
		CMP #$08 : BCC ..draw
		..rubble
		LDA !GFX_SkeletonRubble_tile : STA !SpriteTile,x
		LDA !GFX_SkeletonRubble_prop : STA !SpriteProp,x
		..draw
		JSL LOAD_PSUEDO_DYNAMIC
		LDA !GFX_BonyBeetle_tile : STA !SpriteTile,x
		LDA !GFX_BonyBeetle_prop : STA !SpriteProp,x
		RTS

	DATA:
		.XSpeed
		db $08,$F8


	ANIM:
		dw .Walk0	: db $08,$02	; 00	special init frame, several functions key off of this being autod into

		dw .Walk0	: db $08,$02	; 01
		dw .Walk1	: db $08,$01	; 02

		dw .Walk0	: db $10,$04	; 03
		dw .HalfSpike	: db $04,$05	; 04
		dw .FullSpike	: db $20,$06	; 05
		dw .HalfSpike	: db $08,$07	; 06
		dw .Walk0	: db $10,$00	; 07

		dw .Rubble0	: db $04,$09	; 08
		dw .Rubble1	: db $00,$09	; 09
		dw .Rubble0	: db $08,$00	; 0A

		.Walk0
		dw $0004
		db $22,$00,$00,$00

		.Walk1
		dw $0004
		db $22,$00,$00,$02

		.HalfSpike
		dw $0004
		db $22,$00,$00,$04

		.FullSpike
		dw $0004
		db $22,$00,$00,$06

		.Rubble0
		dw $0008
		db $22,$FC,$00,$00
		db $22,$04,$00,$01

		.Rubble1
		dw $0008
		db $22,$FC,$00,$03
		db $22,$04,$00,$04


