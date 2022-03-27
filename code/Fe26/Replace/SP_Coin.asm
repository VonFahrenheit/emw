

pushpc
org $01C3BB			;\
	CMP #$21 : BEQ +	; | make coin sprite not have any X speed
org $01C3D0			; | org: CMP #$76 : BNE $00 (useless branch)
	+			;/

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

