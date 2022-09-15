;=======================;
; VR3 INTERFACE MODULES ;
;=======================;

	; switching bank is only faster if we search 16+ entries on average, but most searches are just 1-3
	GetVRAM:
		PHP
		SEP #$10
		REP #$20
		LDX #$00
		.Loop
		LDA.l !VRAMbase+!VRAMtable,x : BEQ .SlotFound
		TXA
		CLC : ADC #$0007
		TAX
		CMP #$0100 : BCC .Loop
		LDX #$00
		PLP
		SEC
		RTL
		.SlotFound
		PLP
		CLC
		RTL


	GetCGRAM:
		PHB
		PHP
		SEP #$30
		LDA #!VRAMbank
		PHA : PLB
		REP #$20
		LDY #$00
		.Loop
		LDA !CGRAMtable,y
		BEQ .SlotFound
		TYA
		CLC : ADC #$0006
		TAY
		CMP #$0100 : BCC .Loop
		PLP
		PLB
		SEC
		RTL
		.SlotFound
		PLP
		PLB
		CLC
		RTL


	GetBigCCDMA:
		PHB
		PHP
		SEP #$30
		LDA.b #!VRAMbank
		PHA : PLB
		REP #$20
		LDX #$00
		.Loop
		CPX #$80 : BCS .Fail
		LDA !CCDMAtable+$00,x : BEQ .ThisSlot
		TXA
		CLC : ADC #$0008
		TAX
		BRA .Loop
		.ThisSlot
		PLP
		PLB
		CLC				; carry clear = at least 1 free slot
		RTL
		.Fail
		PLP
		PLB
		SEC				; carry set = no free slots
		RTL


	GetSmallCCDMA:
		PHB
		PHP
		SEP #$30
		LDA.b #!VRAMbank
		PHA : PLB
		REP #$20
		LDX #$80
		.Loop
		CPX #$00 : BEQ .Fail
		LDA !CCDMAtable+$00,x : BEQ .ThisSlot
		TXA
		CLC : ADC #$0008
		TAX
		BRA .Loop
		.ThisSlot
		PLP
		PLB
		CLC				; carry clear = at least 1 free slot
		RTL
		.Fail
		PLP
		PLB
		SEC				; carry set = no free slots
		RTL



; input: Y = file index (can be 8-bit or 16-bit)
; output: !FileAddress set to the address of the file
	GetFileAddress:
		PHB
		PHP
		REP #$10
		SEP #$20
		LDA.b #$30 : PHA : PLB				; bank
		REP #$20
		LDA.w $840A,y					;\ bank is stored as a 16-bit number to make some processes faster
		AND #$00FF : STA !FileAddress+2			;/
		LDA.w $8408,y : STA !FileAddress+0
		PLP
		PLB
		RTL


