

pushpc
org $01C6A1
	JML Rainbow		; Source: CMP #$76 : BNE $0D ($01C6B2)
org $01C616
	db $04,$08,$04,$08	; fix star palettes
org $01C6C9
	BRA $01 : NOP		; ORA $33C0,x
pullpc




	Rainbow:
		CMP #$78 : BEQ .GoldShroom
		CMP #$7F : BEQ .GoldShroom
		CMP #$76 : BEQ .Star

		.NoFlash
		JML $01C6B2

		.Star
		LDA $14
		AND #$02
		ORA #$04
		ORA $64
		STA !OAM+$103,y
		BRA .Flash

		.GoldShroom
		LDA $14
		AND #$02
		BEQ $02 : LDA #$06
		CLC : ADC #$04
		ORA $64
		STA !OAM+$103,y

		.Flash
		PEI ($00)
		PHY
		JSL MakeGlitter
		PLY
		PLA
		STA $00
		STA !OAM+$100,y
		PLA
		STA $01
		STA !OAM+$101,y
		STZ $33C0,x
		JML $01C6D1




