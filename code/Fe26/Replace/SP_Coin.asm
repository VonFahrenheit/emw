

pushpc
org $01857C
	JML Coin_Init	; > Source : JSR $AD30 : TYA (SUB_HORZ_POS)
org $01C4CF
	JSL Coin	; > Source : JSL $05B34A
pullpc




	Coin:

		LDA !CurrentMario
		TAY
		DEY
		LDA !ExtraProp1,x
		SEC : ADC !P1CoinIncrease,y		; extra +1
		STA !P1CoinIncrease,y
		JML $05B34D

	.Init	LDA $3200,x
		CMP #$21 : BEQ ..setcoins
		CMP #$7E : BNE .Nope
		LDA #$04 : BRA +
		..setcoins
		LDA !ExtraBits,x
		AND #$04
		BEQ $02 : LDA #$63
	+	STA !ExtraProp1,x

	.Nope	JSL SUB_HORZ_POS
		TYA

		.Return
		JML $018580
