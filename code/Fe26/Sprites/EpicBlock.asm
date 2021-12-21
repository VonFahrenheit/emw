
EpicBlock:
	namespace EpicBlock




	MAIN:
		PHB : PHK : PLB
		LDA.b #!palset_generic_grey : JSL LoadPalset
		LDX $0F
		LDA !Palset_status,x
		LDX !SpriteIndex
		ASL A
		STA $33C0,x


	PHYSICS:
		JSL !SpriteApplySpeed
		LDA $3330,x
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

		LDA !SpriteXLo,x
		SEC : SBC #$08
		STA $04
		LDA !SpriteXHi,x
		SBC #$00
		STA $0A
		LDA !SpriteYLo,x
		SEC : SBC #$10
		STA $05
		LDA !SpriteYHi,x
		SBC #$00
		STA $0B
		LDA #$20
		STA $06
		LDA #$40
		STA $07
		LDA #$07 : JSL OutputPlatformBox

		.Push
		SEC : JSL !PlayerClipping
		BCC ..0

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

