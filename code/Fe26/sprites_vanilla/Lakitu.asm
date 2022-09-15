
	INIT:

		TXY
		STY $00
		PLX
		CPX $00 : BCC .Return		; if lakitu has the lower index it's fine

		REP #$30			; if lakitu has higher index, completely swap sprites
		TXA
		CLC : ADC #$03F0
		TAX
		TYA
		CLC : ADC #$03F0
	-	TAY
		SEP #$20
		LDA $3200,x : XBA
		LDA $3200,y : XBA
		STA $3200,y
		XBA : STA $3200,x
		REP #$20
		TXA
		SEC : SBC #$0010
		TAX
		TYA
		SEC : SBC #$0010
		BPL -
		SEP #$30
		STY !SpriteIndex
		LDX !SpriteIndex

	.Return
		STZ $78E0			; overwritten code

	MAIN:
		RTS


