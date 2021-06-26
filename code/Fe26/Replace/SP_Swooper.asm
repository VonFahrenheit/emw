


	pushpc
	org $0388E4
	SwooperSleep:
		JML SwooperCeiling
	.Check	JSL SUB_HORZ_POS
		REP #$20
		CLC : ADC #$0050
		CMP #$00A0
		SEP #$20
		BCS .Return
		JML SwooperAttack
	.Return	RTS
	warnpc $038905
	pullpc
	SwooperCeiling:
		REP #$30
		LDA #$0000
		LDY #$FFF8
		JSL !GetMap16Sprite
		CMP #$0025
		SEP #$30
		BEQ .Attack
		JML SwooperSleep_Check

	.Attack	JSL SUB_HORZ_POS

	SwooperAttack:
		INC $BE,x
		TYA : STA $3320,x
		LDA #$26 : STA !SPC4
		LDA #$20 : STA $9E,x
		JML SwooperSleep_Return