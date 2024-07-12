;=======================;
; VR3 INTERFACE MODULES ;
;=======================;

; intput: void
; output:
;	X = index to !VRAMtable
;	C = 0 (BCC) if slot was found, C = 1 (BCS) if no slot was found
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


; intput: void
; output:
;	Y = index to !CGRAMtable
;	C = 0 (BCC) if slot was found, C = 1 (BCS) if no slot was found
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


; input: void
; output:
;	X = index to !CCDMAtable
;	C = 0 (BCC) if slot was found, C = 1 (BCS) if no slot was found
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


; input: void
; output:
;	X = index to !CCDMAtable
;	C = 0 (BCC) if slot was found, C = 1 (BCS) if no slot was found
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


