

pushpc
org $01C6A1
	JML Rainbow		; Source: CMP #$76 : BNE $0D ($01C6B2)
org $01C616
	db $04,$08,$04,$08	; fix star palettes
org $01C6C9
	BRA $01 : NOP		; ORA $33C0,x
pullpc




	Rainbow:
		CMP #$7F : BEQ .Flash
		CMP #$76 : BEQ .Flash
		CMP #$78 : BNE .NoFlash

		.Flash
		PHY
		PEI ($00)
		JSL MakeGlitter
		PLA : STA $00
		PLA : STA $01
		PLY
		JML $01C6A5

		.NoFlash
		JML $01C6B2




