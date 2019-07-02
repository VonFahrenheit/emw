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

		LDX !SpriteIndex


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

		.OneTile
		REP #$20
		LDA #$0004 : STA !BigRAM+0
		LDA #$0020 : STA !BigRAM+2
		LDA #$8200 : STA !BigRAM+4
		LDA #!BigRAM : STA $04
		SEP #$20
		LDA !GFX_status+$09 : TSB !BigRAM+2	; use pal8 replacement
		JSL LOAD_TILEMAP_Long

		PLB
		RTL





	namespace off





