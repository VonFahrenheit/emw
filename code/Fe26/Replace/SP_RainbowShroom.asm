

pushpc
org $01C600
	JML Coins100		; Source: CLC : ADC $3340,x

org $01C6A1
	JML Rainbow		; Source: CMP #$76 : BNE $0D ($01C6B2)

org $01C616
	db $04,$08,$04,$08	; fix star palettes
org $01C6C9
	BRA $01 : NOP		; ORA $33C0,x
pullpc





	Coins100:
		STZ $3230,x		; despawn winged version too
		LDA !CurrentMario	;\ Nope out if no one is playing Mario
		BEQ .Nope		;/
		DEC A			;\
		TAX			; |
		LDA !P1CoinIncrease,x	; | Give 100 coins
		CLC : ADC #$64		; |
		STA !P1CoinIncrease,x	;/

		LDA #$01		;\
		CMP $19			; |
		BCC $02 : STA $19	; | Full heal
		CMP $6DC2		; |
		BCC $03 : STA $6DC2	;/


	.Nope	JML $01C608		; > Return



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




