
ShopObject:
	namespace ShopObject



	INIT:
		LDA #$09 : STA $3230,x			; go into state 09
		LDA #$0F : STA $3500,x			; leniency timer
		RTL

	MAIN:
		PHB : PHK : PLB

		LDA $3280,x : BNE +
		LDA $3500,x : BEQ .Kill
		DEC $3500,x
		JSL !GetSpriteClipping04
		LDX #$0F
	-	CPX !SpriteIndex : BEQ ++
		LDA $3230,x
		CMP #$08 : BCC ++
		CMP #$0B : BCS ++
		JSL !GetSpriteClipping00
		JSL !CheckContact : BCC ++

		TXA
		LDX !SpriteIndex
		INC A
		STA $3280,x
		BRA +

	++	DEX : BPL -
		LDX !SpriteIndex
		PLB
		RTL
		+

		DEC A
		TAY
		LDA $3230,y
		CMP #$08 : BCS +
		.Kill
		STZ $3230,x
		PLB
		RTL
		+

		STZ $0F
		STZ !BigRAM+0
		STZ !BigRAM+1

		LDA !ExtraProp1,x : BEQ .Draw
		CMP #$FF : BNE ..calc

		LDA #$FA : STA $0F
		LDY #$09 : JSR .AppendTile
		LDY #$09 : JSR .AppendTile
		LDY #$09 : JSR .AppendTile
		LDY #$09 : JSR .AppendTile
		LDY #$09 : JSR .AppendTile
		BRA .Draw

		..calc

		LDY #$00
	-	CMP #$64 : BCC +
		SBC #$64
		INY : BRA -
	+	STZ $00
	-	CMP #$0A : BCC +
		SBC #$0A
		INC $00 : BRA -
	+	STA $01
		CPY #$00 : BEQ ..skip100
		JSR .AppendTile
		LDY $00 : BRA ..10
		..skip100
		LDY $00 : BEQ ..skip10
		..10
		JSR .AppendTile
		..skip10
		LDY $01 : JSR .AppendTile

		.Draw
		REP #$20
		LDA.w #!BigRAM : STA $04
		SEP #$20
		JSL SETUP_CARRIED
		STA $00

		LDA !ExtraProp1,x : BEQ +

		LDA $3320,x : PHA
		LDA #$01 : STA $3320,x
		LDA $00
		JSL DRAW_CARRIED
		PLA : STA $3320,x

		+


		LDY $3280,x
		DEY
		LDA #$02
		STA !SpriteStasis,y
		STA !SpriteDisP1,y
		STA !SpriteDisP2,y

		LDA $3320,x : STA $3320,y
		LDA !ExtraBits,y
		AND.b #!CustomBit : BEQ +
		LDA #$00 : STA !SpriteAnimTimerY
		+
		JSL SPRITE_A_SPRITE_B_COORDS


		LDA $3230,x
		CMP #$0B : BEQ +
		LDA #$09 : STA $3230,x
		+
		.Return
		PLB
		RTL





	.AppendTile
		PHX
		LDA !BigRAM : TAX
		CLC : ADC #$04
		STA !BigRAM
		LDA .TileTable,y : STA !BigRAM+5,x
		LDA #$30 : STA !BigRAM+2,x
		LDA $0F : STA !BigRAM+3,x
		CPY #$01 : BEQ +
		CLC : ADC #$06
		BRA ++
	+	CLC : ADC #$04
	++	STA $0F
		LDA #$F0 : STA !BigRAM+4,x
		PLX
		RTS


	.TileTable
		db $00,$01,$02,$03,$04
		db $10,$11,$12,$13,$14


	namespace off

