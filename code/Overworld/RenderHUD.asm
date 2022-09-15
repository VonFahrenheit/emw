

; input:
;	$00 = coordinates to read from (X/2 + 128*Y)
;	$02 = coordinates to write to (X + 256*Y)
;	$0C = width of block (16-bit)
;	$0E = height of block (16-bit)
;
;


; scratch RAM:
;	$00 = coordinates to read from (X/2 + 128*Y)
;	$02 = coordinates to write to (X/2 + 128*Y)
;	$04 = used to keep track of first offset pixel on each row in X+1 mode
;	$06
;	$08 = scratch pixel data (holds 4 pixels at a time)
;	$0A = current row
;	$0C = end X coordinate of read block (16-bit) note that width is half the number of pixels since each byte holds 2 pixels
;	$0E = end Y coordinate of read block, ends entire operation (16-bit)


	RenderHUD:
		PHB
		PHP
		SEP #$20
		LDA #$41
		PHA : PLB
		REP #$30

		LDA $00
		AND #$007F
		CLC : ADC $0C
		STA $0C

		LDA $0E
		XBA
		LSR A
		STA $0E
		LDA $00
		AND #$FF80
		CLC : ADC $0E
		STA $0E




		LSR $02
		LDY $00
		LDX $02
		STZ $0A				; how many rows have been rendered so far
		BCS .Render4X
		JMP .Render4


		.Render4X
		STZ $04
		..loop
		LDA $3000,y
		ASL #4
		BIT #$F000 : PHP
		BIT #$0F00 : PHP
		BIT #$00F0 : PHP
		STA $08
		LDA $04 : BNE ++
		PHP
		BRA +

	++	LDA $3000-1,y
		AND #$00F0 : PHP
		BEQ +
		LSR #4
		TSB $08
	+	LDA $2000,x
		PLP : BEQ $03 : AND #$FFF0
		PLP : BEQ $03 : AND #$FF0F
		PLP : BEQ $03 : AND #$F0FF
		PLP : BEQ $03 : AND #$0FFF
		ORA $08
		STA.l !DecompBuffer,x
		DEC $04

		INX #2
		INY #2
		TYA
		AND #$007F
		CMP $0C : BCC ..loop

		LDA $0A
		ADC #$007F			; skip CLC after CMP optimization
		STA $0A
		LDA $02
		CLC : ADC $0A
		TAX
		LDA $00
		CLC : ADC $0A
		TAY
		CPY $0E : BCC $03 : JMP UpdateHUD
		STZ $04
		JMP ..loop



		.Render4
		..loop
		LDA $3000,y : STA $08
		BIT #$000F : PHP
		BIT #$00F0 : PHP
		BIT #$0F00 : PHP
		BIT #$F000 : PHP
		LDA $2000,x
		PLP : BEQ $03 : AND #$0FFF
		PLP : BEQ $03 : AND #$F0FF
		PLP : BEQ $03 : AND #$FF0F
		PLP : BEQ $03 : AND #$FFF0
		ORA $08
		STA.l !DecompBuffer,x

		INX #2
		INY #2
		TYA
		AND #$007F
		CMP $0C : BCC ..loop

		LDA $0A
		ADC #$007F			; skip CLC after CMP optimization
		STA $0A
		LDA $02
		CLC : ADC $0A
		TAX
		LDA $00
		CLC : ADC $0A
		TAY
		CPY $0E : BCC ..loop


	UpdateHUD:
		.Main
		PHK : PLB
		LDX #$0000
		LDA $02
		ASL A
		XBA
		AND #$00FF
		LSR #3
		TAX
		LDA $0A
		..loop
		INC !MapUpdateHUD,x
		CMP #$0080*8 : BCC ..done
		SBC #$0080*8
		INX
		BRA ..loop
		..done



		PLP
		PLB
		RTS


	RenderP2Name:
		.Main
		PHB
		PHP
		SEP #$20
		LDA #$41
		PHA : PLB
		REP #$30

		LDA $00
		AND #$007F
		CLC : ADC $0C
		STA $0C

		LDA $0E
		XBA
		LSR A
		STA $0E
		LDA $00
		AND #$FF80
		CLC : ADC $0E
		STA $0E
		LSR $02
		LDY $00
		LDX $02
		STZ $0A				; how many rows have been rendered so far

		..loop
		LDA $3000,y : STA $08
		AND #$F000
		CMP #$8000 : BNE +
		TRB $08
		LDA #$9000 : TSB $08
		+
		LDA $08
		AND #$0F00
		CMP #$0800 : BNE +
		TRB $08
		LDA #$0900 : TSB $08
		+
		LDA $08
		AND #$00F0
		CMP #$0080 : BNE +
		TRB $08
		LDA #$0090 : TSB $08
		+
		LDA $08
		AND #$000F
		CMP #$0008 : BNE +
		TRB $08
		LDA #$0009 : TSB $08
		+
		LDA $08
		BIT #$000F : PHP
		BIT #$00F0 : PHP
		BIT #$0F00 : PHP
		BIT #$F000 : PHP
		LDA $2000,x
		PLP : BEQ $03 : AND #$0FFF
		PLP : BEQ $03 : AND #$F0FF
		PLP : BEQ $03 : AND #$FF0F
		PLP : BEQ $03 : AND #$FFF0
		ORA $08
		STA.l !DecompBuffer,x

		INX #2
		INY #2
		TYA
		AND #$007F
		CMP $0C : BCS $03 : JMP ..loop

		LDA $0A
		ADC #$007F			; skip CLC after CMP optimization
		STA $0A
		LDA $02
		CLC : ADC $0A
		TAX
		LDA $00
		CLC : ADC $0A
		TAY
		CPY $0E : BCS $03 : JMP ..loop

		JMP UpdateHUD



	ResetHUD:
		PHB
		PHP
		SEP #$20
		LDA #$41
		PHA : PLB
		REP #$30

		LSR $02
		LDA $02
		AND #$007F
		CLC : ADC $0C
		STA $0C

		LDA $0E
		XBA
		LSR A
		STA $0E
		LDA $02
		AND #$FF80
		CLC : ADC $0E
		STA $0E

		LDX $02
		STZ $0A				; how many rows have been cleared


		.Clear4
		..loop
		LDA $2000,x : STA.l !DecompBuffer,x
		INX #2
		TXA
		AND #$007F : BNE +
		LDA $0C
		CMP #$0080 : BCS ..break
		BRA ..loop

	+	CMP $0C : BCC ..loop

		..break
		LDA $0A
		ADC #$007F			; skip CLC after CMP optimization
		STA $0A
		LDA $02
		CLC : ADC $0A
		TAX
		CPX $0E : BCC ..loop

		JMP UpdateHUD






macro HUD_Element(name, sX, sY, tX, tY, W, H)
	.<name>
	dw <sX>/2|(<sY>*128)
	dw <tX>|(<tY>*256)
	db <W>/2
	db <H>
endmacro


macro LoadHUD(name)
	LDA HUD_Elements_<name>+0 : STA $00
	LDA HUD_Elements_<name>+2 : STA $02
	LDA HUD_Elements_<name>+4
	AND #$00FF
	STA $0C
	LDA HUD_Elements_<name>+5
	AND #$00FF
	STA $0E
endmacro

macro UpdateHUD(slot)
	LDA !MapUpdateHUD+<slot> : BEQ ?Next
	JSL GetBigCCDMA : BCS ?Next
	STZ !MapUpdateHUD+<slot>
	LDA #$15 : STA !VRAMbase+!CCDMAtable+$07,x
	LDA.b #!DecompBuffer>>16 : STA !VRAMbase+!CCDMAtable+$04,x
	REP #$20
	LDA.w #!DecompBuffer+(<slot>*$400) : STA !VRAMbase+!CCDMAtable+$02,x
	LDA.w #$3000+(<slot>*$200) : STA !VRAMbase+!CCDMAtable+$05,x
	LDA.w #$0400 : STA !VRAMbase+!CCDMAtable+$00,x
	SEP #$20
	?Next:
endmacro



; +0x44 to X for P2 compared to P1

	HUD_Elements:
;		       |        name	      | srcX  | srcY  | destX | destY | width | height
;----------------------|----------------------|-------|-------|-------|-------|-------|-------
;		       |		      |       |       |       |       |       |
		%HUD_Element(StartSolidP1,	0,	0,	$6C,	$15,	24,	8)
		%HUD_Element(StartPressedP1,	$18,	0,	$6C,	$15,	24,	8)
		%HUD_Element(StartSolidP2,	0,	0,	$B0,	$15,	24,	8)
		%HUD_Element(StartPressedP2,	$18,	0,	$B0,	$15,	24,	8)

		%HUD_Element(SwitchP1,		$60,	0,	$46,	$15,	32,	8)
		%HUD_Element(JoinP2,		$80,	0,	$8E,	$15,	24,	8)
		%HUD_Element(SwitchP2,		$60,	0,	$8A,	$15,	32,	8)

		%HUD_Element(NameP1,		$98,	0,	$60,	$0A,	32,	8)
		%HUD_Element(NameP2,		$98,	0,	$A4,	$0A,	32,	8)

		%HUD_Element(PortraitP1,	$00,	8,	$4A,	$03,	16,	16)
		%HUD_Element(PortraitP2,	$00,	8,	$8E,	$03,	16,	16)

		%HUD_Element(WarpPipe,		$60,	8,	$D5,	$06,	16,	16)
		%HUD_Element(ShipIcon,		$70,	8,	$D5,	$06,	16,	16)
		%HUD_Element(HomeText,		$80,	8,	$E7,	$07,	24,	8)
		%HUD_Element(ShipText,		$80,	16,	$E7,	$07,	24,	8)
		%HUD_Element(SelectSolid,	$30,	0,	$E6,	$0D,	24,	8)
		%HUD_Element(SelectPressed,	$48,	0,	$E6,	$0D,	24,	8)





