;
; interacts with both players and sprites
; extra byte 1:
;	0: interacts with both players and sprites
;	1: disable sprite interaction
;	2: disable player interaction
;	3: disable all interaction
;	this only works with extra bit off



Block:

	namespace Block

	INIT:
		PHB : PHK : PLB			; > Start of bank wrapper
		LDA #$01 : STA $3320,x		; Proper facing
		DEC $3210,x			;\
		LDA $3210,x			; | Move one pixel up
		CMP #$FF			; |
		BNE $03 : DEC $3240,x		;/
		PLB				; > End of bank wrapper
		RTL				; > End INIT routine


	MAIN:
		PHB : PHK : PLB

		JSL !GetSpriteClipping04
		LDA !ExtraProp1,x
		AND #$01 : BNE .SkipSprites
		LDX #$0F
	-	LDA $3230,x
		CMP #$08 : BCC +
		CMP #$0B : BCS +
		JSL !GetSpriteClipping00
		JSL !CheckContact
		BCC +

		LDY !SpriteIndex
		LDA $3210,y
		CMP $3210,x
		LDA $3240,y
		SBC $3240,x
		BCS .Down

	.Up	BIT !SpriteYSpeed,x : BPL .Side
		LDA $3330,x
		ORA #$08
		STA $3330,x
		STZ !SpriteYSpeed,x
	.Down	BIT !SpriteYSpeed,x : BMI .Side
		LDA $3330,x
		ORA #$04
		STA $3330,x
		STZ !SpriteYSpeed,x

	.Side	LDA $3220,y
		CMP $3220,x
		LDA $3250,y
		SBC $3250,x
		BCS .Right

	.Left	BIT !SpriteYSpeed,x : BPL +
		LDA $3330,x
		ORA #$02
		STA $3330,x
		STZ !SpriteYSpeed,x
	.Right	BIT !SpriteYSpeed,x : BMI +
		LDA $3330,x
		ORA #$01
		STA $3330,x
		STZ !SpriteYSpeed,x
	+	DEX : BPL -

	.SkipSprites
		LDX !SpriteIndex
		LDA !ExtraProp1,x
		AND #$02 : BEQ .PlayerInteraction
		LDA #$FF
		STA $32E0,x
		STA $35F0,x
		BRA .OneTile_draw

	.PlayerInteraction
		LDA !ExtraBits,x
		AND #$04 : BEQ .OneTile
		LDA $04
		SEC : SBC #$10
		STA $04
		LDA $0A
		SBC #$00
		STA $0A
		LDA $06
		CLC : ADC #$10
		STA $06
		LDA #$0F : JSL OutputPlatformBox
		..draw
		REP #$20
		LDA.w #.TM2 : BRA +

		.OneTile
		LDA #$0F : JSL OutputPlatformBox
		..draw
		REP #$20
		LDA.w #.TM1
	+	STA $04
		SEP #$20
		JSL LOAD_PSUEDO_DYNAMIC

		PLB
		RTL


	.TM1
	dw $0004
	db $32,$00,$00,$00

	.TM2
	dw $0008
	db $32,$F0,$00,$00
	db $32,$00,$00,$00

	namespace off





