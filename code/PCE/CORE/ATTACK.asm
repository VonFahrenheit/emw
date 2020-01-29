ATTACK:

	.Setup
		REP #$20			;\
		LDA #$32E0 : STA $0E		; |
		LDA !CurrentPlayer		; | $0E = interaction pointer
		AND #$00FF : BEQ +		; |
		LDA #$35F0 : STA $0E		; |
	+	SEP #$20			;/
		RTS


	.Main
		TXY
		LDA #$10 : STA ($0E),y		; prevent interaction
		LDA CORE_BITS,x			;\
		CPX #$08			; |
		BCS +				; | mark sprite as hit
		TSB !P2IndexMem1		; |
		BRA ++				; |
	+	TSB !P2IndexMem2		;/
	++	PHX
		LDX #$03

	.Loop	LDA $77C0,x : BEQ .Spawn
		DEX : BPL .Loop
		PLX
		RTS

		.Spawn
		LDA #$02 : STA $77C0,x
		LDA $0F : PHA
		LDA $02
		LSR A
		CLC : ADC $00
		STA $0F
		LDA $06
		LSR A
		CLC : ADC $04
		CLC : ADC $0F
		ROR A
		STA $77C8,x

		LDA $03
		LSR A
		CLC : ADC $01
		STA $0F
		LDA $07
		LSR A
		CLC : ADC $05
		CLC : ADC $0F
		ROR A
		SEC : SBC #$08
		STA $77C4,x

		LDA #$08 : STA $77CC,x
		PLA : STA $0F
		PLX
		RTS