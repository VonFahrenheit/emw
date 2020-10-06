

	; BG3 code goes here

		LDA !IceLevel
		AND #$00FF
		BNE $03 : INC !Level+4			; water does not animate when frozen
		LDA $1C
		SEC : SBC !Level+2
		CLC : ADC #$0030			; account for displaced tilemap
		CMP #$0100 : BCC +
		CMP #$FF00 : BCS +
		LDA #$0100
	+	STA $24
		LDA $1A
		CLC : ADC !Level+4
		STA $22



		PHX					;\
		LDA $14					; |
		AND #$0001				; | X = index to double buffer
		ASL #2					; |
		XBA					; |
		TAX					;/


		LDA !Level+2				;\
		SEC : SBC $1C				; | the magic number (wl-c)
		SEC : SBC #$0070			; |
		CMP #$FFFD				; |
		BCC $03 : LDA #$FFFE			; > minimum negative distance is -2
		STA $00					;/

		LDY #$0016				;\
	-	LDA $00 : STA $2251			; |
		LDA ..BG3Table,y : STA $2253		; |
		NOP : BRA $00				; |
		LDA $2307				; | dump height on screen values in !BigRAM
		CLC : ADC #$0070			; | and horizontal scroll values in !BigRAM+$18
		STA !BigRAM,y				; |
		LDA $22 : STA $2251			; |
		LDA ..BG3Table,y : STA $2253		; |
		NOP : BRA $00				; |
		LDA $2307 : STA !BigRAM+$18,y		; |
		DEY #2 : BPL -				;/

		LDA $1C					;\
		CLC : ADC #$0070			; | determine view
		CMP !Level+2 : BCS $03 : JMP ..BG3low	;/

		..BG3high				; viewed from below
		LDY #$0016
		STZ $06
	-	LDA !BigRAM,y : BEQ ++ : BPL +
	++	LDA $06
		CLC : ADC #$0008
		STA $06
		DEY #2 : BPL -
		LDA #$0001 : STA $40A380,x
		LDA #$0060 : STA $40A383,x
		LDA #$0000 : STA $40A385,x
		JMP ..endbg3

	+
	-	STA $40A380,x
		CPY #$0016 : BNE +
		LDA #$0060 : STA $40A383,x		; ignore X scroll here since you can't see it
		BRA ++
	
	+	LDA !BigRAM+$18,y : STA $40A381,x
		LDA !BigRAM,y
		EOR #$FFFF : INC A
		CLC : ADC $06
		STA $40A383,x

	++	INX #5
		LDA $06
		CLC : ADC #$0008
		STA $06
	--	LDA !BigRAM-2,y				;\
		SEC : SBC !BigRAM,y			; |
		BNE +					; | don't allow scanline counts of zero
		DEY #2 : BPL --				; |
		BRA ++					;/

	+	DEY #2 : BPL -				; note that this doesn't loop for y = 0
							; meaning that the next chunk is the below-water section
	++	LDA #$0001 : STA $40A380,x
		LDA #$0060 : STA $40A383,x
		LDA #$0000 : STA $40A385,x
		JMP ..endbg3


		..BG3low				; viewed from above
		LDY #$0000
		LDA !BigRAM,y
		CMP #$007F : BCC +
		LSR A
		STA $40A380,x
		BCC $01 : INC A
		PHA
		LDA #$0060 : STA $40A383,x
		LDA #$0000 : STA $40A381,x
		INX #5
		PLA
	+	STA $40A380,x
		LDA #$0060 : STA $40A383,x
		LDA #$0000 : STA $40A381,x
		INX #5
		STZ $00


	-	CPY #$0016 : BNE +
		LDA #$0001 : BRA ++
	+	LDA !BigRAM+2,y
		SEC : SBC !BigRAM,y
		BPL $04 : EOR #$FFFF : INC A
		CMP #$0000
		BNE $01 : INC A
		CMP #$007F
		BCC $03 : LDA #$007F
	++	STA $40A380,x
		LDA !BigRAM,y
		EOR #$FFFF : INC A
		CLC : ADC $00
		STA $40A383,x
		LDA !BigRAM+$18,y : STA $40A381,x
		LDA $00
		CLC : ADC #$0008
		STA $00
		INX #5
		INY #2
		CPY #$0018 : BNE -
		LDA #$0000 : STA $40A380,x

		..endbg3
		PLX


	; no return here since this is part of a larger routine







..BG3Table
dw $0015,$0033,$0050,$006D,$008B,$00A8,$00C5,$00E3,$0100,$011D,$013B,$0158


