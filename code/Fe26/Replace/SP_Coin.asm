

pushpc
org $01857C
	JML Coin_Init	; > Source : JSR $AD30 : TYA (SUB_HORZ_POS)
org $01C4CF
	JSL Coin	; > Source : JSL $05B34A
pullpc




	Coin:
		LDA !ExtraBits,x
		AND #$04 : BEQ .1
	.100	LDA !CurrentMario
		TAY
		DEY
		LDA !P1CoinIncrease,y
		CLC : ADC $35D0,x
		DEC A
		STA !P1CoinIncrease,y
	.1	JML $05B34A

	.Init	LDA $3200,x
		CMP #$21 : BNE .Nope
		LDA #$64 : STA $35D0,x		; special coin is worth 100 coins

	.Nope	JSL SUB_HORZ_POS
		TYA

		.Return
		JML $018580
