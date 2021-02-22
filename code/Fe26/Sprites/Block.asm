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

		JSL $03B69F
		LDA !ExtraProp1,x
		AND #$01 : BNE .SkipSprites
		LDX #$0F
	-	LDA $3230,x
		CMP #$08 : BCC +
		CMP #$0B : BCS +
		JSL $03B6E5
		JSL !CheckContact
		BCC +

		LDY !SpriteIndex
		LDA $3210,y
		CMP $3210,x
		LDA $3240,y
		SBC $3240,x
		BCS .Down

	.Up	BIT $9E,x : BPL .Side
		LDA $3330,x
		ORA #$08
		STA $3330,x
		STZ $9E,x
	.Down	BIT $9E,x : BMI .Side
		LDA $3330,x
		ORA #$04
		STA $3330,x
		STZ $9E,x

	.Side	LDA $3220,y
		CMP $3220,x
		LDA $3250,y
		SBC $3250,x
		BCS .Right

	.Left	BIT $AE,x : BPL +
		LDA $3330,x
		ORA #$02
		STA $3330,x
		STZ $AE,x
	.Right	BIT $AE,x : BMI +
		LDA $3330,x
		ORA #$01
		STA $3330,x
		STZ $AE,x
	+	DEX : BPL -

	.SkipSprites
		LDX !SpriteIndex
		LDA !ExtraProp1,x
		AND #$02 : BEQ .PlayerInteraction
		LDA #$FF
		STA $32E0,x
		STA $35F0,x
		BRA .OneTile

	.PlayerInteraction
		JSL $01B44F			; Run invisible block code
		LDA !ExtraBits,x
		AND #$04
		BEQ .OneTile
		LDA $3220,x
		CLC : ADC #$10
		STA $3220,x
		LDA $3250,x
		ADC #$00
		STA $3250,x
		JSL $01B44F
		LDA $3220,x
		SEC : SBC #$10
		STA $3220,x
		LDA $3250,x
		SBC #$00
		STA $3250,x
		REP #$20
		LDA.w #.TM2 : BRA +

		.OneTile
		REP #$20
		LDA.w #.TM1
	+	STA $04
		SEP #$20
		JSL LOAD_PSUEDO_DYNAMIC_Long

		PLB
		RTL


	.TM1
	dw $0004
	db $30,$00,$00,$00

	.TM2
	dw $0008
	db $30,$00,$00,$00
	db $30,$10,$00,$00

	namespace off





