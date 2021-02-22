; Set extra bit to let the sprite cling sideways to blocks acting like 0x130

	pushpc
	org $0183F8
		JSL SpikeTopInitFix		; Org: ASL #4
	pullpc
	SpikeTopInitFix:
		ASL #4
		PHA

		LDA !ExtraBits,x
		AND #$04 : BEQ .NormalBoy
		REP #$30
		LDA #$0010
		LDY #$0000
		JSL !GetMap16Sprite
		CMP #$0130
		BEQ .Right

		.Left
		LDA #$FFFA
		BRA .ClingMove

		.Right
		LDA #$0006

		.ClingMove
		STA $00
		SEP #$20
		LDA $3220,x
		CLC : ADC $00
		STA $3220,x
		LDA $3250,x
		ADC $01
		STA $3250,x

		.NormalBoy
		PLA
		RTL