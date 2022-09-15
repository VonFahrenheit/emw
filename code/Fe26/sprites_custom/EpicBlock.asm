
EpicBlock:
	namespace EpicBlock




	MAIN:
		PHB : PHK : PLB


	PHYSICS:
		JSL APPLY_SPEED
		LDA !SpriteBlocked,x
		AND #$04 : BEQ +
		LDA #$10 : STA !SpriteYSpeed,x

		LDA $14
		AND #$03 : BNE +
		LDA !SpriteXSpeed,x : BEQ +
		LDA #$04 : STA $00
		LDA #$0C : STA $01
		STZ $02
		STZ $03
		STZ $04
		STZ $05
		LDA #$30 : STA $07
		LDA #!prt_smoke8x8 : JSL SpawnParticle
		+


		REP #$20
		LDA.w #HITBOX : JSL LOAD_HITBOX
		LDA #$07 : JSL OutputPlatformBox

		.Push
		JSL PlayerContact : BCC ..0

		LDA !P2BlockedLayer-$80
		AND #$04 : BEQ ..0

		LDA $6DA2
		AND #$03 : BEQ ..0
		CMP #$03 : BEQ ..0
		CMP #$02 : BEQ ..minus
	..pos	LDA #$10 : BRA +
	..minus	LDA #$F0 : BRA +
	..0	LDA #$00
	+	JSL AccelerateX

		..nocontact


	HITBOX:
		dw $FFF8,$FFF0 : db $20,$20



	GRAPHICS:
		REP #$20
		LDA.w #ANIM_TM : STA $04
		SEP #$20
		JSL DRAW_CARRIED

		.Done

		PLB
	INIT:
		RTL


	ANIM:
	.TM
		dw $0010
		db $02,$F8,$F0,$00
		db $02,$08,$F0,$02
		db $02,$F8,$00,$04
		db $02,$08,$00,$06



	namespace off

