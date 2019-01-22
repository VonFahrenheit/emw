; --Level INIT--

levelinit0:
		INC !SideExit
		JMP CLEAR_DYNAMIC_BG3

levelinit1:
		%GradientRGB(HDMA_BlueSky)
		INC !SideExit
		JSR levelinit2_GFX
		LDA #$09			;\ BG2 HScroll = Close2Half
		STA !BG2ModeH			;/
		LDA #$C0			;\
		STA !BG2BaseV			; | Base BG2 VScroll = 0xC0
		STZ !BG2BaseV+1			;/
		JMP level1

levelinit2:
		INC !SideExit
		LDA #$91 : STA !MsgPal		; > Portrait CGRAM location
		REP #$20			; > A 16 bit
		LDA #$3200			;\
		STA $4330			; |
		LDA #HDMA_BlueSky_Green		; | Set up green colour math on channel 3
		STA $4332			; |
		LDY #HDMA_BlueSky_Green>>16	; |
		STY $4334			;/
		LDA #$3200			;\
		STA $4340			; |
		LDA #HDMA_BlueSky_Blue		; | Set up blue colour math on channel 4
		STA $4342			; |
		STY $4344			;/
		LDA #$7C00			;\
		STA $400000+!MsgVRAM1		; | Portrait VRAM location
		LDA #$7C80			; |
		STA $400000+!MsgVRAM2		;/
		SEP #$20			; > A 8 bit
		LDA #$18			;\ Enable HDMA on channels 3 and 4
		TSB $6D9F			;/
		JSR CLEAR_DYNAMIC_BG3

; 31EC00

		.GFX
		PHB : LDA #!VRAMbank		;\ Bank wrapper
		PHA : PLB			;/
		JSL !GetVRAM			; > Get index
		LDA #$30			;\
		STA !VRAMtable+$04,x		; |
		REP #$20			; | > A 16 bit
		LDA #$0C00			; |
		STA !VRAMtable+$00,x		; | Queue Villager Rex GFX upload
		LDA #$8C08			; |
		STA !VRAMtable+$02,x		; |
		LDA #$7000			; |
		STA !VRAMtable+$05,x		;/
		SEP #$20			; > A 8 bit
		JSL !GetVRAM			; > Get next index
		LDA #$30			;\
		STA !VRAMtable+$04,x		; |
		REP #$20			; | > A 16 bit
		LDA #$0C00			; |
		STA !VRAMtable+$00,x		; | Queue Hammer Rex GFX upload
		LDA #$9808			; |
		STA !VRAMtable+$02,x		; |
		LDA #$7600			; |
		STA !VRAMtable+$05,x		;/
		PLB				; > Restore bank

		.Plant
		REP #$20
		LDA #$7C00 : JSR PLANT_GFX
		LDA #$54 : STA !GFX_status+$02	; > Plant base tile = 0x1C0
		RTS				; > Return

levelinit3:
		INC !SideExit
		LDA #$C1 : STA !MsgPal		; > Portrait CGRAM location
		LDA #$1F			;\ Put everything on mainscreen
		STA $6D9D			;/
		STZ $6D9E			; > Disable subscreen
		JSR CLEAR_DYNAMIC_BG3		; > Clear the top of BG3
		JSR REX_LEVEL			; > Rex level
		LDA #$31
		STA !VRAMbase+!VRAMtable+$12,x
		STA !VRAMbase+!VRAMtable+$19,x
		REP #$20
		LDA #$DC40
		STA !VRAMbase+!VRAMtable+$10,x
		LDA #$DE40
		STA !VRAMbase+!VRAMtable+$17,x
		LDA #$6A20
		STA !VRAMbase+!VRAMtable+$13,x
		LDA #$6B20
		STA !VRAMbase+!VRAMtable+$1A,x
		LDA #$0080
		STA !VRAMbase+!VRAMtable+$0E,x
		STA !VRAMbase+!VRAMtable+$15,x

		LDA #$0F02			;\ Use mode 2 to access 210Fl and 210Fh
		STA $4330			;/
		LDA #$7600			;\
		STA $400000+!MsgVRAM1		; | Portrait VRAM location
		LDA #$7680			; |
		STA $400000+!MsgVRAM2		;/
		SEP #$20			; > A 8 bit
		LDA #$00			;\ Bank of table
		STA $4334			;/
		LDA #$08			;\ Enable HDMA on channel 3 
		TSB $6D9F			;/
		JSL level3_HDMA : INC $14	;\ Set up double-buffered HDMA
		JSL level3_HDMA : DEC $14	;/
		JMP level3

levelinit4:
		INC !SideExit
		JSR REX_LEVEL
		JSR CLEAR_DYNAMIC_BG3
		RTS

levelinit5:

	; Upload sun, sample code

		JSL !GetVRAM
		LDA.b #!VRAMbank
		PHA : PLB
		REP #$20
		LDA #$3131
		STA !VRAMtable+$04,x
		STA !VRAMtable+$0B,x
		LDA #$DC00 : STA !VRAMtable+$02,x
		LDA #$DE00 : STA !VRAMtable+$09,x
		LDA #$0040
		STA !VRAMtable+$00,x
		STA !VRAMtable+$07,x
		LDA #$6880 : STA !VRAMtable+$05,x
		LDA #$6980 : STA !VRAMtable+$0C,x
		SEP #$20
		PHK : PLB

		INC !SideExit			; > Enable side exit
		LDA #$01			;\ BG2 HScroll = 40%
		STA !BG2ModeH			;/
		LDA #$04			;\ BG2 VScroll = 25%
		STA !BG2ModeV			;/
		LDA #$07 : STA !Level+5		; > Chunk size
		JSR .HDMA			; > Set up HDMA
		JSR CLEAR_DYNAMIC_BG3		; > Clear the top of BG3
		JSR REX_LEVEL			; > Rex level
		JMP level5


.HDMA		LDA #$1F			;\ Put everything on mainscreen
		STA $6D9D			;/
		STZ $6D9E			; > Disable subscreen
		REP #$20			; > A 16 bit
		LDA $1C				;\
		LSR #2				; |
		SEC : SBC $20			; | BG2 base Y position
		EOR #$FFFF			; |
		INC A				; |
		STA !BG2BaseV			;/
		LDA #$0F03			;\ Use mode 3 to access both 210F and 2110
		STA $4360			;/
		SEP #$20			; > A 8 bit
		LDA #$00			;\ Bank of table (location is set during processing)
		STA $4364			;/
		LDA #$40			;\ Enable HDMA on channel 6 
		TSB $6D9F			;/
		JSL level5_HDMA			;\
		INC $14				; | Initialize both tables (double-buffered)
		JSL level5_HDMA			; |
		DEC $14				;/
		RTS


levelinit6:
		LDA #$06 : STA !GFX_status+$09	; pal 8 replacement: palette A

		INC !SideExit
		LDA #$0E			;\ Scanline count
		XBA				;/
	-	LDA #$01			;\
		STA $0400,x			; |
		LDA #$31			; |
		STA $0401,x			; | Red scroll buffer
		INX #2				; |
		CPX #$20			; |
		BNE -				;/
	-	XBA				;\
		STA $0400,x			; |
		XBA				; |
		INC A				; |
		STA $0401,x			; |
		INX #2				; |
		CPX #$38			; | Red table
		BNE -				; |
		INC A : STA $0401,x		; |
		INC A : STA $0403,x		; |
		LDA #$1F			; |
		STA $0400,x			; |
		STA $0402,x			; |
		TDC : STA $0404,x		;/
		TAX				; > X = 0x00
		LDA #$15			;\ Scanline count
		XBA				;/
	-	LDA #$01			;\
		STA $0600,x			; |
		LDA #$40			; |
		STA $0601,x			; | Green scroll buffer
		INX #2				; |
		CPX #$20			; |
		BNE -				;/
	-	XBA				;\
		STA $0600,x			; |
		XBA				; |
		INC A				; |
		STA $0601,x			; | Green table
		INX #2				; |
		CPX #$34			; |
		BNE -				; |
		TDC : STA $0600,x		;/
		TAX				; > X = 0x00
		LDY #$88			; > Base color
	-	LDA #$1A			;\
		STA $0800,x			; |
		TYA : DEY			; |
		STA $0801,x			; | Blue table
		INX #2				; |
		CPX #$12			; |
		BNE -				; |
		TDC : STA $0800,x		;/

		LDA #$48			;\
		STA $0A00			; |
		STA $0A03			; |
		LDA #$01			; |
		STA $0A06			; | Set up BG2 Hscroll table
		TDC : STA $0A09			; |
		REP #$20			; |
		STA $0A01			; |
		STA $0A04			; |
		SEP #$20			;/

		REP #$20			; > A 16 bit
		LDA #$3200			;\
		STA $4330			; |
		LDA #$0400			; |
		STA $4332			; | Set up red colour math on channel 3
		LDY #$00			; |
		STY $4334			;/
		LDA #$3200			;\
		STA $4340			; |
		LDA #$0600			; | Set up green colour math on channel 4
		STA $4342			; |
		STY $4344			;/
		LDA #$3200			;\
		STA $4350			; |
		LDA #$0800			; | Set up blue colour math on channel 5
		STA $4352			; |
		STY $4354			;/
		LDA #$0F02			;\
		STA $4360			; |
		LDA #$0A00			; | Set up BG2 Hscroll on channel 6
		STA $4362			; |
		STY $4364			;/
		SEP #$20			; > A 8 bit
		LDA #$78			;\ Enable HDMA on channels 3 through 6
		TSB $6D9F			;/


		JSR LoadNoviceShaman
		JSR LoadHappySlime
		TXA					;\
		CLC : ADC #$07				; |
		TAX					; |
		PHB : LDA #!VRAMbank			; |
		PHA : PLB				; |
		LDA #$31				; |
		STA !VRAMtable+$04,x			; |
		STA !VRAMtable+$0B,x			; |
		REP #$20				; | Upload sun SBG
		LDA #$DC00 : STA !VRAMtable+$02,x	; |
		LDA #$DE00 : STA !VRAMtable+$09,x	; |
		LDA #$6EE0 : STA !VRAMtable+$05,x	; |
		LDA #$6FE0 : STA !VRAMtable+$0C,x	; |
		LDA #$0040				; |
		STA !VRAMtable+$00,x			; |
		STA !VRAMtable+$07,x			; |
		SEP #$20				; |
		PLB					;/

		JMP level6


; bank, source, dest, size

LoadNoviceShaman:
		JSL !GetVRAM				; > Get index
		PHB : LDA #!VRAMbank			;\ Bank wrapper
		PHA : PLB				;/
		LDA #$30 : STA !VRAMtable+$04,x		; > Source bank
		PHP					;\ Push processor and change to 16-bit
		REP #$20				;/
		LDA #$C408 : STA !VRAMtable+$02,x	;\
		LDA #$7600 : STA !VRAMtable+$05,x	; | Upload data
		LDA #$1000 : STA !VRAMtable+$00,x	;/
		PLP					; > Restore processor
		PLB					; > Restore bank
		RTS


LoadHappySlime:
		JSL !GetVRAM				; > Get index
		PHB : LDA #!VRAMbank			;\ Bank wrapper
		PHA : PLB				;/
		LDA #$30 : STA !VRAMtable+$04,x		; > Source bank
		PHP					;\ Push processor and change to 16-bit
		REP #$20				;/
		LDA #$DA08 : STA !VRAMtable+$02,x	;\
		LDA #$7000 : STA !VRAMtable+$05,x	; | Upload data
		LDA #$0C00 : STA !VRAMtable+$00,x	;/
		PLP					; > Restore processor
		PLB					; > Restore bank
		RTS




levelinit7:
		LDA #$06
		TRB $6D9D
		TRB $6D9E

		LDA #$11
		TSB $6D9D
		TRB $6D9E

		LDA #$0C : STA !TextPal			; Text palette = 0x03

		JSR CLEAR_DYNAMIC_BG3

		LDA #$02 : STA !BG2ModeH
		LDA #$04 : STA !BG2ModeV
		%GradientRGB(HDMA_BlueSky)
		JSL !GetVRAM
		PHB
		LDA.b #!VRAMbank
		PHA : PLB
		REP #$20
		LDA.w #$0C00 : STA.w !VRAMtable+$00,x	;\
		LDA.w #$9808 : STA.w !VRAMtable+$02,x	; | Upload hammer rex to start of SP3
		LDA.w #$0030 : STA.w !VRAMtable+$04,x	; |
		LDA.w #$7000 : STA.w !VRAMtable+$05,x	;/
		LDA.w #$0080 : STA.w !VRAMtable+$07,x	;\
		LDA.w #$8988 : STA.w !VRAMtable+$09,x	; |
		LDA.w #$0030 : STA.w !VRAMtable+$0B,x	; |
		LDA.w #$7600 : STA.w !VRAMtable+$0C,x	; | Upload hammer
		LDA.w #$0080 : STA.w !VRAMtable+$0E,x	; |
		LDA.w #$8B88 : STA.w !VRAMtable+$10,x	; |
		LDA.w #$0030 : STA.w !VRAMtable+$12,x	; |
		LDA.w #$7700 : STA.w !VRAMtable+$13,x	;/
		LDA.w #$0C00 : STA.w !VRAMtable+$15,x	;\
		LDA.w #$A408 : STA.w !VRAMtable+$17,x	; | Upload Koopa renegade to bottom of SP4
		LDA.w #$0030 : STA.w !VRAMtable+$19,x	; |
		LDA.w #$7A00 : STA.w !VRAMtable+$1A,x	;/
		SEP #$20
		PLB
		LDA #$0A : STA !GFX_status+$05		; Hammer offset (0x14)
		STZ !GFX_status+$04			; Hammer rex offset
		LDA #$80 : STA !GFX_status+$01		; Koopa offset ($100)
		LDA #$BA : STA !Level+4			; > negative 0x3F
		LDA #$07 : STA !Level+5			; > Size of chunks
		JSR levelinit5_HDMA
		JMP level7

levelinit8:
		INC !SideExit

		REP #$20
		LDA #$0404 : STA !BG2ModeH		; BG2 scroll: variable2;variable2
		LDA #$01D0 : STA !BG2BaseV		; base BG2 position
		JSL read3($048434)
		SEP #$20

		.GFX
		JSR REX_LEVEL
		PHB
		LDA #!VRAMbank : PHA : PLB
		REP #$20
		LDA #$DA08
		STA !VRAMtable+$02,x
		LDA #$3030
		STA !VRAMtable+$04,x
		LDA #$7000
		STA !VRAMtable+$05,x
		LDA #$0C00
		STA !VRAMtable+$00,x
		LDA #$0000
		STA !VRAMtable+$07,x
		PLB
		SEP #$20

	REP #$20
	LDA.w #.Dynamo : STA $0C
	CLC : JSL !UpdateGFX
	SEP #$20
	LDA #$C3 : STA !GFX_status+$0B

		RTS

		.Dynamo
		;31EC00
		dw ..End-..Start
		..Start
		dw $0040
		dl $31F500
		dw $6860
		dw $0040
		dl $31F700
		dw $6960
		..End




levelinit9:
	RTS
levelinitA:
		LDA #$11				;\
		TSB $6D9D				; | BG1 and sprites are on both main and subscreen
		TSB $6D9E				;/

		LDA #$80 : STA !Level+3

		LDA #$00 : STA !VineDestroyPage
		JSL !GetVRAM
		PHB
		LDA #!VRAMbank
		PHA : PLB
		REP #$20
		LDA #$3131
		STA !VRAMtable+$04,x
		STA !VRAMtable+$0B,x
		LDA #$DC00+$0C0
		STA !VRAMtable+$02,x
		LDA #$DC00+$2C0
		STA !VRAMtable+$09,x
		LDA #$00C0
		STA !VRAMtable+$00,x
		STA !VRAMtable+$07,x
		LDA #$7800 : STA !VRAMtable+$05,x
		LDA #$7900 : STA !VRAMtable+$0C,x
		LDA #$7000 : JSR PLANT_GFX
		SEP #$20
		PLB
		JSL levelA_HDMA
		STZ $00
		STZ $01
		LDA #$F4 : STA !GFX_status+$02		; > Plant base tile = 0x100


		.GFX
		JSL !GetVRAM
		PHB
		LDA #!VRAMbank
		PHA : PLB
		REP #$20
		LDA #$3131				;\
		STA !VRAMtable+$04,x			; | Source bank
		STA !VRAMtable+$0B,x			;/
		LDA #$DC00+$400				;\
		CLC : ADC $00				; |
		STA !VRAMtable+$02,x			; | Source GFX
		CLC : ADC #$0200			; |
		STA !VRAMtable+$09,x			;/
		LDA #$0100				;\
		STA !VRAMtable+$00,x			; | Upload size
		STA !VRAMtable+$07,x			;/
		LDA #$7860 : STA !VRAMtable+$05,x	;\ VRAM destination
		LDA #$7960 : STA !VRAMtable+$0C,x	;/
		SEP #$20
		PLB
		RTS

levelinitB:
		INC !SideExit

		JSR CLEAR_DYNAMIC_BG3
		JSR VineDestroy_INIT
		JSR REX_LEVEL

		LDA #$0E
		STA !VineDestroyPage			; > page of vines
		STA !GFX_status+$09			; > pal 8 replacement: palette F

		LDA #$07				;\
		STA !BG2ModeH				; | 75% BG2 scroll rate
		STA !BG2ModeV				;/
		STZ !BG2BaseV				;\ Base BG2 Vscroll = 0x00 (0x90 - 0x90)
		STZ !BG2BaseV+1				;/
		LDA #$C0 : STA !Level+2			;\ Base BG3 Vscroll = +0xC0
		STZ !Level+3				;/

		LDA #$D0 : STA !GFX_status+$05		; > Hammer tile = +0x1A0 = 0x0EC and 0x0EE
		LDA #$5D : STA !GFX_status+$0A		; > Lotus fire tile = +0x0DD = 0x160 and 0x170

		PHB
		LDA.b #!VRAMbank
		PHA : PLB
		REP #$20
		LDA #$0C00 : STA.w !VRAMtable+$00,x	;\
		LDA.w #$B008 : STA.w !VRAMtable+$02,x	; | Overwrite the normal rex since I only want the hammer one
		LDA.w #$0030 : STA.w !VRAMtable+$04,x	; |
		LDA #$7000 : STA.w !VRAMtable+$05,x	;/
		LDA.w #$0080 : STA.w !VRAMtable+$15,x	;\
		LDA.w #$8988 : STA.w !VRAMtable+$17,x	; |
		LDA.w #$0030 : STA.w !VRAMtable+$19,x	; |
		LDA.w #$6EC0 : STA.w !VRAMtable+$1A,x	; | Upload hammer to tiles 0xEC and 0xEE on page 1
		LDA.w #$0080 : STA.w !VRAMtable+$0E,x	; |
		LDA.w #$8B88 : STA.w !VRAMtable+$10,x	; |
		LDA.w #$0030 : STA.w !VRAMtable+$12,x	; |
		LDA.w #$6FC0 : STA.w !VRAMtable+$13,x	;/
		PLB

		LDA #$6AC0 : JSR PLANT_GFX		; > Upload piranha plant GFX
		REP #$20


		JSL levelB_HDMA
		SEP #$20
		JMP levelB

levelinitC:
	RTS
levelinitD:
		LDA #$1F			;\ Put everything on mainscreen
		STA $6D9D			;/
		STZ $6D9E			; > Disable subscreen
		JSR CLEAR_DYNAMIC_BG3		; > Clear the top of BG3

		REP #$20			; > A 16 bit
		LDA #$0F03			;\ Use mode 3 to access both bytes of 210F and 2110
		STA $4330			;/
		SEP #$20			; > A 8 bit
		LDA #$40			;\ Bank of table
		STA $4334			;/
		LDA #$08			;\ Enable HDMA on channel 3 
		TSB $6D9F			;/
	;	JSL levelD_HDMA : INC $14	;\ Set up double-buffered HDMA
	;	JSL levelD_HDMA : DEC $14	;/
		JMP levelD


levelinitE:

		LDA #$04 : STA !GFX_status+$09	; pal 8 replacement: Palette A
		LDA #$0C : STA !TextPal		; Text palette = 0x03

		LDA #$01 : STA !BG2ModeH
		LDA #$06 : STA !BG2ModeV
		REP #$20
		STZ !BG2BaseV
		JSL read3($048434)
		SEP #$20


		LDA #$2C : STA !SPC3		; Battle music

		LDY $97
		STY !P2YPosHi-$80
		STY !P2YPosHi

		CPY #$01 : BNE .NoTop
		LDA #$2E
		INY : STY $5F
		BRA .Music
		.NoTop

		CPY #$02 : BNE .NotTreasury
		STZ !EnableVScroll
		BRA .Shaman
		.NotTreasury

		CPY #$19 : BCS .NoRestrict
		LDA #$19 : STA $5F
		LDA #$45
	.Music	STA !SPC3		; Normal music
		.NoRestrict


		CPY #$15 : BCS .NoShaman	; this check needs to be last since the JSR shreds Y
	.Shaman	JSR LoadNoviceShaman
		.NoShaman


		LDA #$20 : STA $64
		JSL !GetVRAM
		LDA #$20
		JMP LoadGoombaSlave


levelinitF:
	RTS
levelinit10:

		REP #$20
		LDA #$1388 : STA !P1Coins
		LDA !MultiPlayer
		AND #$00FF : BEQ .1P
		LSR !P1Coins
		LDA !P1Coins : STA !P2Coins
		.1P

		LDA.w #.ThifGFX : STA $0C
		CLC : JSL !UpdateGFX
		SEP #$20
		LDA #$80 : STA !GFX_status+$08
		STZ !Level+4
		RTS

	.ThifGFX
	dw ..End-..Start
	..Start
	dw $0400 : dl $30BC08 : dw $7000
	dw $00C0 : dl $31F400 : dw $6AA0
	dw $00C0 : dl $31F600 : dw $6BA0
	..End


levelinit11:
	RTS
levelinit12:
	RTS
levelinit13:
	RTS
levelinit14:
	RTS
levelinit15:
	RTS
levelinit16:
	RTS
levelinit17:
	RTS
levelinit18:
	RTS
levelinit19:
	RTS
levelinit1A:
	RTS
levelinit1B:
	RTS
levelinit1C:
	RTS
levelinit1D:
	RTS
levelinit1E:
	RTS
levelinit1F:
	RTS
levelinit20:
	RTS
levelinit21:
	RTS
levelinit22:
	RTS
levelinit23:
	RTS
levelinit24:
	RTS
levelinit25:
	RTS
levelinit26:
		%GradientRGB(HDMA_BlueSky)
		JSR REX_LEVEL
		LDA #$06			;\
		STA !BG2ModeH			; | BG2 scroll = Close, Close
		STA !BG2ModeV			;/
		LDA #$A0 : STA !BG2BaseV	;\ Base BG2 Vscroll: 0x1A0
		LDA #$01 : STA !BG2BaseV+1	;/
		JMP level26

levelinit27:
		LDY $95
		BNE +
		LDA #$03 : STA $5E
		+
		CPY #$04
		BNE +
		LDA #$07 : STA $5E
		+
		CPY #$0B
		BNE +
		LDA #$0D : STA $5E
		+

		JSR REX_LEVEL

		TXA
		SEC : SBC #$07
		TAX

		LDA #$60

; To load goomba slave into tile XX:
;
; JSL !GetVRAM
; LDA #$XX (start tile of goomba slave on second page)
; JSR LoadGoombaSlave


	LoadGoombaSlave:
		STA !GFX_status+$07			; GFX status for goomba slave
		TAY
		PHB
		LDA.b #!VRAMbank : PHA : PLB
		REP #$20
		LDA #$D408
		STA !VRAMtable+$02,x
		LDA #$D808
		STA !VRAMtable+$09,x
		LDA #$3030
		STA !VRAMtable+$04,x
		STA !VRAMtable+$0B,x
		TYA
		ASL #4
		ORA #$7000				; $7600
		STA !VRAMtable+$05,x
		CLC : ADC #$03C0			; $79C0
		STA !VRAMtable+$0C,x
		LDA #$0600
		STA !VRAMtable+$00,x
		LDA #$0080
		STA !VRAMtable+$07,x
		SEP #$20
		PLB
		RTS

levelinit28:
		LDA #$0E : STA !GFX_status+$09	; pal 8 replacement: Palette F

		LDA $1B
		BEQ .BigCave

		.MoleCave
		LDA #$01 : STA !Level+4
		STZ !EnableHScroll
		LDA !StoryFlags+$02
		AND #$07
		CMP #$03 : BCC +

		LDA #$42 : STA !SPC3
		JMP level28_Block

	+	LDA #$2C : STA !SPC3
		RTS

		.BigCave
		LDA #$09 : STA $5E
		LDA #$42 : STA !SPC3
		JMP MOLE_GFX

levelinit29:
		LDA #$15			;\ Put everything except BG2 on main screen
		STA $6D9D			;/
		LDA #$02 : STA $6D9E		; > BG2 on subscreen
		%GradientRGB(HDMA_Sunset)	; > Enable sunset gradient
		JSR levelinit2_Plant
		JMP levelinit8_GFX


levelinit2A:	JSL !GetVRAM				;\
		REP #$20				; |
		LDA.w #$0C00				; |
		STA.l !VRAMbase+!VRAMtable+$00,x	; |
		LDA.w #$B400				; |
		STA.l !VRAMbase+!VRAMtable+$02,x	; | Load cannon
		LDA.w #$3131				; |
		STA.l !VRAMbase+!VRAMtable+$04,x	; |
		LDA #$2A00				; |
		STA.l !VRAMbase+!VRAMtable+$05,x	; |
		SEP #$20				;/
		JMP REX_LEVEL

levelinit2B:	LDA #$3F : STA !Level+2
		JMP levelinit5

levelinit2C:
		STZ $6DF5 : STZ $6DF6
		STZ !SideExit
		LDA #$0A
		STA !BG2ModeH
		STA !BG2ModeV
		REP #$20
		LDA #$7600			;\
		STA $400000+!MsgVRAM1		; | Portrait VRAM location
		LDA #$7680			; |
		STA $400000+!MsgVRAM2		;/
		LDX #$C1 : STX !MsgPal		; > Portrait CGRAM location
		LDA $1C
		ASL #2
		STA $4204
		LDX #$0A
		STX $4206
		JSR GET_DIVISION
		LDA $4216
		CMP #$0005
		LDA $4214
		ADC #$0000
		SEC : SBC $20
		EOR #$FFFF
		INC A
		STA !BG2BaseV
		LDA #$0000
		STA $4330
		LDA.w #.Table
		STA $4332
		SEP #$20
		LDA.b #.Table>>16
		STA $4334
		LDA #$08
		TSB $6D9F
		JMP REX_LEVEL


		.Table
		db $90
		db $08,$08,$08,$08,$08,$08,$08,$08
		db $08,$08,$08,$08,$08,$08,$08,$08
		db $60,$08
		db $70,$08
		db $00


levelinit2D:	STZ !SideExit
		JSL level2D_HDMA
		RTS

levelinit2E:
		JSR REX_LEVEL
		PHB
		LDA #!VRAMbank : PHA : PLB
		REP #$20
		LDA #$DA08
		STA !VRAMtable+$02,x
		LDA #$3030
		STA !VRAMtable+$04,x
		LDA #$7000
		STA !VRAMtable+$05,x
		LDA #$0C00
		STA !VRAMtable+$00,x
		SEP #$20
		PLB
		RTS

levelinit2F:
		JMP levelinit2

levelinit30:
		INC !SideExit
		JSR levelinitA
		STZ !Level+3
		RTS

levelinit31:
		LDA #$01				;\ Set midway flag
		STA $73CE				;/
		LDX $73BF				;\
		LDA $7EA2,x				; | Set flag in OW table
		ORA #$40				; |
		STA $7EA2,x				;/
		LDA !Level : STA !MidwayLo,x		;\ Store to midway table
		LDA !Level+1 : STA !MidwayHi,x		;/

		JSR CLEAR_DYNAMIC_BG3

		LDA #$02 : STA !AnimToggle
		LDA #$11				;\
		TSB $6D9D				; | BG1 and sprites are on both main and subscreen
		TSB $6D9E				;/
		RTS



levelinit32:
	RTS
levelinit33:
	RTS
levelinit34:
	RTS
levelinit35:
	RTS
levelinit36:
	RTS
levelinit37:
	RTS
levelinit38:
	RTS
levelinit39:
	RTS
levelinit3A:
	RTS
levelinit3B:
	RTS
levelinit3C:
	RTS
levelinit3D:
	RTS
levelinit3E:
	RTS
levelinit3F:
	RTS
levelinit40:
	RTS
levelinit41:
	RTS
levelinit42:
	RTS
levelinit43:
	RTS
levelinit44:
	RTS
levelinit45:
	RTS
levelinit46:
	RTS
levelinit47:
	RTS
levelinit48:
	RTS
levelinit49:
	RTS
levelinit4A:
	RTS
levelinit4B:
	RTS
levelinit4C:
	RTS
levelinit4D:
	RTS
levelinit4E:
	RTS
levelinit4F:
	RTS
levelinit50:
	RTS
levelinit51:
	RTS
levelinit52:
	RTS
levelinit53:
	RTS
levelinit54:
	RTS
levelinit55:
	RTS
levelinit56:
	RTS
levelinit57:
	RTS
levelinit58:
	RTS
levelinit59:
	RTS
levelinit5A:
	RTS
levelinit5B:
	RTS
levelinit5C:
	RTS
levelinit5D:
	RTS
levelinit5E:
	RTS
levelinit5F:
	RTS
levelinit60:
	RTS
levelinit61:
	RTS
levelinit62:
	RTS
levelinit63:
	RTS
levelinit64:
	RTS
levelinit65:
	RTS
levelinit66:
	RTS
levelinit67:
	RTS
levelinit68:
	RTS
levelinit69:
	RTS
levelinit6A:
	RTS
levelinit6B:
	RTS
levelinit6C:
	RTS
levelinit6D:
	RTS
levelinit6E:
	RTS
levelinit6F:
	RTS
levelinit70:
	RTS
levelinit71:
	RTS
levelinit72:
	RTS
levelinit73:
	RTS
levelinit74:
	RTS
levelinit75:
	RTS
levelinit76:
	RTS
levelinit77:
	RTS
levelinit78:
	RTS
levelinit79:
	RTS
levelinit7A:
	RTS
levelinit7B:
	RTS
levelinit7C:
	RTS
levelinit7D:
	RTS
levelinit7E:
	RTS
levelinit7F:
	RTS
levelinit80:
	RTS
levelinit81:
	RTS
levelinit82:
	RTS
levelinit83:
	RTS
levelinit84:
	RTS
levelinit85:
	RTS
levelinit86:
	RTS
levelinit87:
	RTS
levelinit88:
	RTS
levelinit89:
	RTS
levelinit8A:
	RTS
levelinit8B:
	RTS
levelinit8C:
	RTS
levelinit8D:
	RTS
levelinit8E:
	RTS
levelinit8F:
	RTS
levelinit90:
	RTS
levelinit91:
	RTS
levelinit92:
	RTS
levelinit93:
	RTS
levelinit94:
	RTS
levelinit95:
	RTS
levelinit96:
	RTS
levelinit97:
	RTS
levelinit98:
	RTS
levelinit99:
	RTS
levelinit9A:
	RTS
levelinit9B:
	RTS
levelinit9C:
	RTS
levelinit9D:
	RTS
levelinit9E:
	RTS
levelinit9F:
	RTS
levelinitA0:
	RTS
levelinitA1:
	RTS
levelinitA2:
	RTS
levelinitA3:
	RTS
levelinitA4:
	RTS
levelinitA5:
	RTS
levelinitA6:
	RTS
levelinitA7:
	RTS
levelinitA8:
	RTS
levelinitA9:
	RTS
levelinitAA:
	RTS
levelinitAB:
	RTS
levelinitAC:
	RTS
levelinitAD:
	RTS
levelinitAE:
	RTS
levelinitAF:
	RTS
levelinitB0:
	RTS
levelinitB1:
	RTS
levelinitB2:
	RTS
levelinitB3:
	RTS
levelinitB4:
	RTS
levelinitB5:
	RTS
levelinitB6:
	RTS
levelinitB7:
	RTS
levelinitB8:
	RTS
levelinitB9:
	RTS
levelinitBA:
	RTS
levelinitBB:
	RTS
levelinitBC:
	RTS
levelinitBD:
	RTS
levelinitBE:
	RTS
levelinitBF:
	RTS
levelinitC0:
	RTS
levelinitC1:
	RTS
levelinitC2:
	RTS
levelinitC3:
	RTS
levelinitC4:
	RTS
levelinitC5:
		LDA #$01			;\ Prevent camera from scrolling
		STA $5E				;/
		RTS				; > Return
levelinitC6:
	RTS
levelinitC7:
	pushpc
	org $0096C6
		LDA #$2A			; title screen music
	org $009C77
		NOP #6				; remove title screen movements
	org $0093A4
		LDA #$F0			; remove "Nintendo Presents"
	org $0093C0
		LDA #$2A			; first sound
		STA !SPC3

	pullpc
		RTS

levelinitC8:
	RTS
levelinitC9:
	RTS
levelinitCA:
	RTS
levelinitCB:
	RTS
levelinitCC:
	RTS
levelinitCD:
	RTS
levelinitCE:
	RTS
levelinitCF:
	RTS
levelinitD0:
	RTS
levelinitD1:
	RTS
levelinitD2:
	RTS
levelinitD3:
	RTS
levelinitD4:
	RTS
levelinitD5:
	RTS
levelinitD6:
	RTS
levelinitD7:
	RTS
levelinitD8:
	RTS
levelinitD9:
	RTS
levelinitDA:
	RTS
levelinitDB:
	RTS
levelinitDC:
	RTS
levelinitDD:
	RTS
levelinitDE:
	RTS
levelinitDF:
	RTS
levelinitE0:
	RTS
levelinitE1:
	RTS
levelinitE2:
	RTS
levelinitE3:
	RTS
levelinitE4:
	RTS
levelinitE5:
	RTS
levelinitE6:
	RTS
levelinitE7:
	RTS
levelinitE8:
	RTS
levelinitE9:
	RTS
levelinitEA:
	RTS
levelinitEB:
	RTS
levelinitEC:
	RTS
levelinitED:
	RTS
levelinitEE:
	RTS
levelinitEF:
	RTS
levelinitF0:
	RTS
levelinitF1:
	RTS
levelinitF2:
	RTS
levelinitF3:
	RTS
levelinitF4:
	RTS
levelinitF5:
	RTS
levelinitF6:
	RTS
levelinitF7:
	RTS
levelinitF8:
	RTS
levelinitF9:
	RTS
levelinitFA:
	RTS
levelinitFB:
	RTS
levelinitFC:
	RTS
levelinitFD:
	RTS
levelinitFE:
	RTS
levelinitFF:
	RTS
levelinit100:
	RTS
levelinit101:
	RTS
levelinit102:
	RTS
levelinit103:
	RTS
levelinit104:
	RTS
levelinit105:
	RTS
levelinit106:
	RTS
levelinit107:
	RTS
levelinit108:
	RTS
levelinit109:
	RTS
levelinit10A:
	RTS
levelinit10B:
	RTS
levelinit10C:
	RTS
levelinit10D:
	RTS
levelinit10E:
	RTS
levelinit10F:
	RTS
levelinit110:
	RTS
levelinit111:
	RTS
levelinit112:
	RTS
levelinit113:
	RTS
levelinit114:
	RTS
levelinit115:
	RTS
levelinit116:
	RTS
levelinit117:
	RTS
levelinit118:
	RTS
levelinit119:
	RTS
levelinit11A:
	RTS
levelinit11B:
	RTS
levelinit11C:
	RTS
levelinit11D:
	RTS
levelinit11E:
	RTS
levelinit11F:
	RTS
levelinit120:
	RTS
levelinit121:
	RTS
levelinit122:
	RTS
levelinit123:
	RTS
levelinit124:
	RTS
levelinit125:
	RTS
levelinit126:
	RTS
levelinit127:
	RTS
levelinit128:
	RTS
levelinit129:
	RTS
levelinit12A:
	RTS
levelinit12B:
	RTS
levelinit12C:
	RTS
levelinit12D:
	RTS
levelinit12E:
	RTS
levelinit12F:
	RTS
levelinit130:
	RTS
levelinit131:
	RTS
levelinit132:
	RTS
levelinit133:
	RTS
levelinit134:
	RTS
levelinit135:
	RTS
levelinit136:
	RTS
levelinit137:
	RTS
levelinit138:
	RTS
levelinit139:
	RTS
levelinit13A:
	RTS
levelinit13B:
	RTS
levelinit13C:
	RTS
levelinit13D:
	RTS
levelinit13E:
	RTS
levelinit13F:
	RTS
levelinit140:
	RTS
levelinit141:
	RTS
levelinit142:
	RTS
levelinit143:
	RTS
levelinit144:
	RTS
levelinit145:
	RTS
levelinit146:
	RTS
levelinit147:
	RTS
levelinit148:
	RTS
levelinit149:
	RTS
levelinit14A:
	RTS
levelinit14B:
	RTS
levelinit14C:
	RTS
levelinit14D:
	RTS
levelinit14E:
	RTS
levelinit14F:
	RTS
levelinit150:
	RTS
levelinit151:
	RTS
levelinit152:
	RTS
levelinit153:
	RTS
levelinit154:
	RTS
levelinit155:
	RTS
levelinit156:
	RTS
levelinit157:
	RTS
levelinit158:
	RTS
levelinit159:
	RTS
levelinit15A:
	RTS
levelinit15B:
	RTS
levelinit15C:
	RTS
levelinit15D:
	RTS
levelinit15E:
	RTS
levelinit15F:
	RTS
levelinit160:
	RTS
levelinit161:
	RTS
levelinit162:
	RTS
levelinit163:
	RTS
levelinit164:
	RTS
levelinit165:
	RTS
levelinit166:
	RTS
levelinit167:
	RTS
levelinit168:
	RTS
levelinit169:
	RTS
levelinit16A:
	RTS
levelinit16B:
	RTS
levelinit16C:
	RTS
levelinit16D:
	RTS
levelinit16E:
	RTS
levelinit16F:
	RTS
levelinit170:
	RTS
levelinit171:
	RTS
levelinit172:
	RTS
levelinit173:
	RTS
levelinit174:
	RTS
levelinit175:
	RTS
levelinit176:
	RTS
levelinit177:
	RTS
levelinit178:
	RTS
levelinit179:
	RTS
levelinit17A:
	RTS
levelinit17B:
	RTS
levelinit17C:
	RTS
levelinit17D:
	RTS
levelinit17E:
	RTS
levelinit17F:
	RTS
levelinit180:
	RTS
levelinit181:
	RTS
levelinit182:
	RTS
levelinit183:
	RTS
levelinit184:
	RTS
levelinit185:
	RTS
levelinit186:
	RTS
levelinit187:
	RTS
levelinit188:
	RTS
levelinit189:
	RTS
levelinit18A:
	RTS
levelinit18B:
	RTS
levelinit18C:
	RTS
levelinit18D:
	RTS
levelinit18E:
	RTS
levelinit18F:
	RTS
levelinit190:
	RTS
levelinit191:
	RTS
levelinit192:
	RTS
levelinit193:
	RTS
levelinit194:
	RTS
levelinit195:
	RTS
levelinit196:
	RTS
levelinit197:
	RTS
levelinit198:
	RTS
levelinit199:
	RTS
levelinit19A:
	RTS
levelinit19B:
	RTS
levelinit19C:
	RTS
levelinit19D:
	RTS
levelinit19E:
	RTS
levelinit19F:
	RTS
levelinit1A0:
	RTS
levelinit1A1:
	RTS
levelinit1A2:
	RTS
levelinit1A3:
	RTS
levelinit1A4:
	RTS
levelinit1A5:
	RTS
levelinit1A6:
	RTS
levelinit1A7:
	RTS
levelinit1A8:
	RTS
levelinit1A9:
	RTS
levelinit1AA:
	RTS
levelinit1AB:
	RTS
levelinit1AC:
	RTS
levelinit1AD:
	RTS
levelinit1AE:
	RTS
levelinit1AF:
	RTS
levelinit1B0:
	RTS
levelinit1B1:
	RTS
levelinit1B2:
	RTS
levelinit1B3:
	RTS
levelinit1B4:
	RTS
levelinit1B5:
	RTS
levelinit1B6:
	RTS
levelinit1B7:
	RTS
levelinit1B8:
	RTS
levelinit1B9:
	RTS
levelinit1BA:
	RTS
levelinit1BB:
	RTS
levelinit1BC:
	RTS
levelinit1BD:
	RTS
levelinit1BE:
	RTS
levelinit1BF:
	RTS
levelinit1C0:
	RTS
levelinit1C1:
	RTS
levelinit1C2:
	RTS
levelinit1C3:
	RTS
levelinit1C4:
	RTS
levelinit1C5:
	RTS
levelinit1C6:
	RTS
levelinit1C7:
	RTS
levelinit1C8:
	RTS
levelinit1C9:
	RTS
levelinit1CA:
	RTS
levelinit1CB:
	RTS
levelinit1CC:
	RTS
levelinit1CD:
	RTS
levelinit1CE:
	RTS
levelinit1CF:
	RTS
levelinit1D0:
	RTS
levelinit1D1:
	RTS
levelinit1D2:
	RTS
levelinit1D3:
	RTS
levelinit1D4:
	RTS
levelinit1D5:
	RTS
levelinit1D6:
	RTS
levelinit1D7:
	RTS
levelinit1D8:
	RTS
levelinit1D9:
	RTS
levelinit1DA:
	RTS
levelinit1DB:
	RTS
levelinit1DC:
	RTS
levelinit1DD:
	RTS
levelinit1DE:
	RTS
levelinit1DF:
	RTS
levelinit1E0:
	RTS
levelinit1E1:
	RTS
levelinit1E2:
	RTS
levelinit1E3:
	RTS
levelinit1E4:
	RTS
levelinit1E5:
	RTS
levelinit1E6:
	RTS
levelinit1E7:
	RTS
levelinit1E8:
	RTS
levelinit1E9:
	RTS
levelinit1EA:
	RTS
levelinit1EB:
	RTS
levelinit1EC:
	RTS
levelinit1ED:
	RTS
levelinit1EE:
	RTS
levelinit1EF:
	RTS
levelinit1F0:
	RTS
levelinit1F1:
	RTS
levelinit1F2:
	RTS
levelinit1F3:
	RTS
levelinit1F4:
	RTS
levelinit1F5:
	RTS
levelinit1F6:
	RTS
levelinit1F7:
	RTS
levelinit1F8:
	RTS
levelinit1F9:
	RTS
levelinit1FA:
	RTS
levelinit1FB:
	RTS
levelinit1FC:
	RTS
levelinit1FD:
		LDA $95 : BEQ .NoScroll
		CMP #$02 : BEQ .HorzScroll

		.AllScroll
		LDA #$01 : STA !EnableVScroll

		.HorzScroll
		LDA #$01 : STA !EnableHScroll

		.NoScroll
		JMP REX_LEVEL



levelinit1FE:
	RTS
levelinit1FF:
	RTS

; --Level MAIN--

level0:

		LDX #$0B
	-	LDA .Tilemap,x
		STA !OAM+$1F4,x
		DEX : BPL -
		LDA !YoshiCoinCount
	-	CMP #$0A : BCC +
		SBC #$0A
		INC !OAM+$1FA
		BRA -
	+	CLC : ADC !OAM+$1FE
		STA !OAM+$1FE
		LDA !OAM+$1FA
		CMP #$A2 : BNE +
		LDA #$F0 : STA !OAM+$1F9
		+
		STZ !OAMhi+$7D
		STZ !OAMhi+$7E
		STZ !OAMhi+$7F

		REP #$20
		LDA #$01F0 : JSR END_Right
		SEP #$20

		LDA !MsgTrigger
		CMP #$02 : BNE .NoQueue

		LDY #$00
	-	LDA !YoshiCoinCount
		CMP .CostTable,y : BCC +

		LDA .RewardTable,y
		AND !KadaalUpgrades : BNE +
		STY !Level+2
		LDA .RewardTable,y : STA !Level+3
		LDA #$10 : STA !Level+4
		BRA .Return

	+	INY
		CPY #$07 : BNE -

		RTS


		.NoQueue
		LDA !Level+4 : BEQ .Return
		DEC !Level+4 : BNE .Return
		LDA !Level+2
		INC #3 : STA !MsgTrigger
		LDA !Level+3
		ORA !KadaalUpgrades
		STA !KadaalUpgrades

		.Return
		RTS


.CostTable	db $03,$07,$0A,$0E,$11,$15,$19
.RewardTable	db $01,$02,$08,$40,$10,$20,$04

.Tilemap	db $08,$08,$F1,$3F
		db $20,$08,$A2,$3F
		db $28,$08,$A2,$3F

level1:
		REP #$20
		LDA $1C
		LSR #3
		STA $24
		LDA $745E
		AND #$00F8
		ASL A
		CLC : ADC $24
		STA $24
		SEP #$20

		STZ !SideExit
		LDA $1B
		BNE .NoSide
		INC A
		STA !SideExit
.NoSide		CMP #$0D
		BCC .Return
		LDA $1A
		CMP #$A0
		BCC .Return
		LDA #$01			;\ Enable Vscroll
		STA !EnableVScroll		;/
.Return		RTS


level2:
		LDA !P2Blocked-$80
		AND #$04 : BEQ +
		LDA !P2YPosHi-$80 : BEQ +
		REP #$20
		LDA !P2XPosLo-$80 : BMI +
		CMP #$0440 : BCC +
		CMP #$0450 : BCS +
		SEP #$20
		LDA $6DA6
		AND #$08 : BEQ +
		LDA #$01 : STA !MsgTrigger
	+	REP #$20
		LDA !P2Blocked
		AND #$0004 : BEQ +
		LDA !P2YPosHi
		AND #$FF00 : BEQ +
		LDA !P2XPosLo : BMI +
		CMP #$0440 : BCC +
		CMP #$0450 : BCS +
		SEP #$20
		LDA $6DA7
		AND #$08 : BEQ +
		LDA #$01 : STA !MsgTrigger
	+	SEP #$20

		STZ !SideExit
		LDA $1B
		BNE .NoExit
		INC !SideExit
		.NoExit
		REP #$20
		LDA #$10F8
		JMP EXIT_Right

level3:
		REP #$20
		LDA #$15F8				;\
		LDY #$01				; | Regular exit (screen 0x15)
		JSR END_Right				;/
		LDA #$1F				;\ Put everything on mainscreen
		STA $6D9D				;/
		STZ $6D9E				; > Disable subscreen

		LDA.b #.HDMA : STA !HDMAptr		;\
		LDA.b #.HDMA>>8 : STA !HDMAptr+1	; | Set up pointer
		LDA.b #.HDMA>>16 : STA !HDMAptr+2	;/
		RTS					; > Return

		.HDMA
		PHP
		SEP #$30
		LDA $9D					;\
		ORA !Pause				; | Y = pause flag
		TAY					;/
		LDA !BossData+0
		CMP #$82
		BNE ..Scroll
		LDA !BossData+2
		CMP #$02
		BNE ..Scroll
		LDA #$01 : STA !EnableHScroll		; > Enable scrolling
		REP #$20
		LDA #$1400
		CMP $1A
		BEQ +
		BCC +
		STA $1A
		LSR A
		STA $1E
	+	SEP #$20
		STZ !SideExit
		LDA $1B
		BRA ..NoScroll

		..Scroll
		TYX : BNE ..NoScroll
		LDA $1A
		CMP #$80
		LDA $1B
		SBC #$13
		BCC ..NoScroll
		STZ !EnableHScroll
		STZ !SideExit
		LDA $1B
		CMP #$14
		BCS ..NoScroll
		REP #$20
		INC $1A
		LDA $1A					;\
		CLC : ADC #$0008			; |
		CMP $94					; | Push Mario if he's at the screen border
		BCC +					; |
		STA $94					; |
	+	SEP #$20				;/
		..NoScroll

		STZ $4332
		LDA $14
		AND #$01
		XBA
		LDA #$00
		REP #$10
		TAX
		CPX #$0100
		BNE .Table2				; > Use the table not being written

		.Table1
		LDA #$04
		BRA .MakeTable

		.Table2
		LDA #$05

		.MakeTable
		STA $4333				; > Hi byte of table
		LDA #$70				;\ layer 1 (includes hills)
		STA $0400,x				;/
		LDA #$0A				;\ layer 2
		STA $0403,x				;/
		LDA #$0B				;\ layer 3
		STA $0406,x				;/
		LDA #$0E				;\ layer 4
		STA $0409,x				;/
		LDA #$12				;\
		STA $040C,x				; | layers 5 and 6
		STA $040F,x				;/
		LDA #$00				;\ End table
		STA $0412,x				;/
		REP #$20				; > A 16 bit
		LDA $1E					;\ layer 4 (100%)
		STA $040A,x				;/
		INY : DEY				;\
		BNE ++					; |
		LSR #2					; |
		CLC : ADC !Level+2			; |
		STA $22					; | BG3 (25%)
		LDA #$00C0				; |
		STA $24					; |
		LDA $14					; |
		AND #$0007				; |
		BNE +					; |
		INC !Level+2				; |
	+	LDA $1E					;/
	++	PHA					;\
		LSR #3					; |
		STA $00					; | layer 3 (87,5%)
		PLA					; |
		SEC : SBC $00				; |
		STA $0407,x				;/
		PHA					;\
		LSR #3					; |
		STA $00					; | layer 2 (76,5%)
		PLA					; |
		SEC : SBC $00				; |
		STA $0404,x				;/
		PHA					;\
		LSR #3					; |
		STA $00					; | layer 1 (67%)
		PLA					; |
		SEC : SBC $00				; |
		STA $0401,x				;/
		LDA $1E					;\
		ASL #3					; |
		STA $4204				; |
		LDA #$0007				; | layer 5 (113,3%)
		STA $4206				; |
	-	DEC A : BPL -				; |
		LDA $4214				; |
		STA $040D,x				;/
		ASL #3					;\
		STA $4204				; |
		LDA #$0007				; |
		STA $4206				; | layer 6 (130,6%)
	-	DEC A : BPL -				; |
		LDA $4214				; |
		STA $0410,x				;/

		.Castle
		LDA $1E
		LSR #3
		SEP #$30				; > Regs 8 bit
		EOR #$FF				;\
		STA !OAM+$1F8				; | Xpos of castle
		STA !OAM+$1FC				;/
		LDA #$30				;\
		STA !OAM+$1F9				; | Ypos of castle
		LDA #$40				; |
		STA !OAM+$1FD				;/
		LDA #$A2				;\
		STA !OAM+$1FA				; | Tile numbers of castle
		LDA #$A4				; |
		STA !OAM+$1FE				;/
		LDA #$0E				;\
		STA !OAM+$1FB				; | YXPPCCCT of castle
		STA !OAM+$1FF				;/
		XBA					;\
		BEQ +					; |
		LDA #$01				; | Hi table of castle
	+	ORA #$02				; |
		STA !OAMhi+$7E				; |
		STA !OAMhi+$7F				;/
		PLP
		RTL

level4:
		REP #$20
		LDA #$14F8				;\
		LDY #$01				; | Regular exit
		JMP END_Right				;/

level5:
		LDA #$1F				;\ Put everything on mainscreen
		STA $6D9D				;/
		STZ $6D9E				; > Disable subscreen

		REP #$20
		LDA #$07F8
		JSR EXIT_Right

		.NoExit
		LDA #$60				;\
		STA !OAM+$1F0				; |
		STA !OAM+$1F8				; | Xpos of sun
		LDA #$68				; |
		STA !OAM+$1F4				; |
		STA !OAM+$1FC				;/
		LDA #$30				;\
		STA !OAM+$1F1				; |
		STA !OAM+$1F5				; | Ypos of sun
		LDA #$40				; |
		STA !OAM+$1F9				; |
		STA !OAM+$1FD				;/
		LDA #$88				;\
		STA !OAM+$1F2				; |
		STA !OAM+$1F6				; | Tile numbers of sun
		STA !OAM+$1FA				; |
		STA !OAM+$1FE				;/
		LDA #$0E				;\
		STA !OAM+$1F3				; |
		LDA #$4E				; |
		STA !OAM+$1F7				; | Properties of sun
		LDA #$8E				; |
		STA !OAM+$1FB				; |
		LDA #$CE				; |
		STA !OAM+$1FF				;/
		LDA #$02				;\
		STA !OAMhi+$7C				; |
		STA !OAMhi+$7D				; | Tile size of sun
		STA !OAMhi+$7E				; |
		STA !OAMhi+$7F				;/
		LDA.b #.HDMA : STA !HDMAptr		;\
		LDA.b #.HDMA>>8 : STA !HDMAptr+1	; | Set up pointer
		LDA.b #.HDMA>>16 : STA !HDMAptr+2	;/
		RTS					; > Return

		.HDMA
		PHP
		REP #$30
		LDX #$0000				;\
		LDA $14					; | Determine which table to use
		LSR A					; |
		BCC $03 : LDX #$0100			; |
		TXA					; |
		CLC : ADC #$0400			; | > Immediately switch to display this one
		STA $4362				;/

		LDA !Level+4
		AND #$00FF
		CMP #$0080
		BCC $03 : ORA #$FF00
		CLC : ADC #$00A6
		CLC : ADC #$00C0
		SEC : SBC $20
		LSR A
		SEP #$20
		STA $0400,x
		ADC #$00
		STA $0405,x
		LDA !Level+5
		STA $040A,x
		STA $040F,x
		STA $0414,x
		STA $0419,x
		STA $041E,x
		STA $0423,x
		STA $0428,x
		LDA #$21 : STA $042D,x
		LDA #$01 : STA $0432,x
		STZ $0437,x				; > End table
		PHB : PHK : PLB
		REP #$20
		TXA
		CLC : ADC #$0410
		STA $00					; > $00 = HDMA table pointer
		INC #2
		STA $02					; > $02 = HDMA table +2 pointer
		LDA $1E					;\
		LSR #2					; |
		SEC : SBC $1E				; |
		EOR #$FFFF : INC A			; | Upper section (covered by !Level+4) is set to 37.5%
		LSR A					; |
		STA $0401,x				; |
		STA $0406,x				;/
		LDA $1E					;\
		ASL #2					; |
		STA $4204				; |
		SEP #$20				; |
		LDA #$0A : STA $4206			; |
		REP #$20				; |
		JSR GET_DIVISION			; | Next chunk is set to 40%
		LDA $4216				; |
		CMP #$0005				; |
		LDA $4214				; |
		ADC #$0000				; |
		STA $040B,x				;/
		LDA $20					;\
		STA $0403,x				; | Set Y coords for upper 3 chunks
		STA $0408,x				; |
		STA $040D,x				;/
		SEP #$10				; > Index 8 bit
		LDX #$09				; > X = divisor (9)
		LDY #$23				; > Y = loop counter and index
		LDA $20 : STA ($02),y			; > Store Y coord for lowest chunk
		LDA $1E					; > A = BG2x
		BRA +					; > Lowest chunk moves at 100%
	-	ASL #3					;\
		STA $4204				; | Multiply by 8 and divide by 9 for each step
		STX $4206				; |
		LDA $20 : STA ($02),y			; > Store Y coord right away to finish division
		NOP #4					;/
		LDA $4216				;\
		CMP #$0004				; | Round up/down
		LDA $4214				; |
		ADC #$0000				;/
	+	STA ($00),y				; > Store X coord to HDMA table
		DEY #5					;\ Loop
		BPL -					;/
		PLB					; > Restore bank

		LDA !BG3BaseSettings			;\ > Include LM initial offset
		AND #$00FC				; |
		ASL A					; |
		STA $02					; |
		LDA $1A					; |
		ASL #3					; |
		CLC : ADC $1A				; |
		LSR #3					; |
		STA $22					; | BG3 scroll = 112.5%
		LDA $1C					; | (this only applies if BG3 scroll is turned off in LM)
		SEC : SBC #$00C0			; |
		STA $00					; |
		ASL #3					; |
		CLC : ADC $00				; |
		LSR #3					; |
		CLC : ADC #$00C4			; |
		CLC : ADC $02				; |
		STA $24					;/
		PLP
		RTL



level6:
		LDA $1F					;\
		LSR A					; |
		STA $0A08				; | Update BG2 Hscroll
		LDA $1E					; |
		ROR A					; |
		STA $0A07				;/
		LDA #$17				;\
		STA $6D9D				; | Main/sub screen settings
		STZ $6D9E				;/
		LDA !Level+3				;\
		CMP #$04				; |
		BEQ .Return				; |
		LDA $9D					; | Don't do anything past animation frame 0x3FF
		ORA !Pause				; |
		BEQ .Process				; |
		JMP .CGRAM				; |
.Return		RTS					;/

.Process	REP #$20				;\
		LDA $1A					; |
		LSR #3					; |
		DEC A					; |
		BMI .Regular				; |
		CMP !Level+2				; |
		BCC .Regular				; |
		STA !Level+2				; |
		SEP #$20				; |
		BRA .StretchGreen			; |
.Regular	SEP #$20				; |
		LDA $14					; |
		AND #$1F				; |
		BNE .HandleHDMA				; |
.StretchGreen	LDX #$00				; |
	-	LDA $0600,x				; |
		CMP #$26				; | Increment timer and stretch green
		BEQ +					; |
		INC A					; |
		STA $0600,x				; |
		BRA ++					; |
	+	INX #2					; |
		CPX #$14				; |
		BNE -					; |
	++	LDA !Level+2				; |
		INC A					; |
		STA !Level+2				; |
		BNE .HandleHDMA				; |
		INC !Level+3				;/

.HandleHDMA	LDX #$00
		REP #$20
		LDA !Level+2
		AND #$03FF
	-	CMP #$000F
		BCC +
		INX #2
		SEC : SBC #$000E
		BRA -
	+	SEP #$20
		STA $7FA100
		LDA #$0E : XBA
		LDA #$00
		STA $7FA102,x
		LDA #$30
	-	STA $7FA101,x
		CPX #$00
		BEQ +
		XBA : STA $7FA100,x
		XBA : CMP #$20
		BEQ $01 : DEC A
		DEX #2
		BPL -
	+	STZ $00
		STZ $01
		LDX #$00
	-	LDA $7FA100,x
		BEQ +
		INC $01
		INC $01
		INX #2
		BRA -
	+	LDA $01
		BEQ +
		LDX #$00
	-	LDA $7FA100,x
		STA $0400,x
		CLC : ADC $00
		STA $00
		LDA $7FA101,x
		STA $0401,x
		INX #2
		BCS ++
		CPX $01
		BNE -
	+	LDY #$00
	-	LDA.w HDMA_Evening,y
		STA $0400,x
		CLC : ADC $00
		STA $00
		LDA.w HDMA_Evening+1,y
		STA $0401,x
		INX #2
		BCS ++
		INY #2
		CPY #$1E
		BNE -
	++	TDC : STA $0400,x

		LDX #$00
		REP #$20
		LDA !Level+2
		LSR A
		CMP #$00C8
		BCC +
		SEP #$20
		JMP .CGRAM
		+
	-	CMP #$001B
		BCC +
		INX #2
		SEC : SBC #$001A
		BRA -
	+	SEP #$20
		STA $7FA200
		LDA #$1A : XBA
		LDA #$00
		STA $7FA202,x
		LDA #$87
	-	STA $7FA201,x
		CPX #$00
		BEQ +
		XBA : STA $7FA200,x
		XBA : CMP #$80
		BEQ $01 : DEC A
		DEX #2
		BPL -
	+	STZ $00
		STZ $01
		LDX #$00
	-	LDA $7FA200,x
		BEQ +
		INC $01
		INC $01
		INX #2
		BRA -
	+	LDA $01
		BEQ +
		LDX #$00
	-	LDA $7FA200,x
		STA $0800,x
		CLC : ADC $00
		STA $00
		LDA $7FA201,x
		STA $0801,x
		INX #2
		BCS ++
		CPX $01
		BNE -
	+	LDY #$00
	-	LDA.w HDMA_Evening_Blue,y
		STA $0800,x
		CLC : ADC $00
		STA $00
		LDA.w HDMA_Evening_Blue+1,y
		STA $0801,x
		INX #2
		BCS ++
		INY #2
		CPY #$1E
		BNE -
	++	TDC : STA $0800,x

.CGRAM		REP #$20				;\
		LDA !Level+2				; |
		LSR #2					; |
		ASL A					; |
		CMP.w #.BGColoursEnd-.BGColours		; |
		BCC +					; | Update colour 0x02
		LDA.w #.BGColoursEnd-.BGColours		; |
	+	TAX					; |
		LDA.w .BGColours,x			; |
		STA $00A2				; |
		SEP #$20				;/

		LDA !Level+3				;\
		BNE .OffScreen				; |
		LDA !Level+2				; | Don't draw sun if it's off-screen
		CMP #$A0				; |
		BCC .DrawSun				;/
.OffScreen	RTS

.DrawSun	LDA !Level+3
		LSR A
		LDA !Level+2
		ROR A
		STA $00
		LDA #$60				;\
		SEC : SBC $00				; |
		STA !OAM+$1F0				; |
		STA !OAM+$1F8				; | Xpos of sun
		LDA #$68				; |
		SEC : SBC $00				; |
		STA !OAM+$1F4				; |
		STA !OAM+$1FC				;/
		LDA #$60				;\
		CLC : ADC $00				; |
		STA !OAM+$1F1				; |
		STA !OAM+$1F5				; | Ypos of sun
		LDA #$70				; |
		CLC : ADC $00				; |
		STA !OAM+$1F9				; |
		STA !OAM+$1FD				;/
		LDA #$EE				;\
		STA !OAM+$1F2				; |
		STA !OAM+$1F6				; | Tile numbers of sun
		STA !OAM+$1FA				; |
		STA !OAM+$1FE				;/
		LDA #$0E				;\
		STA !OAM+$1F3				; |
		LDA #$4E				; |
		STA !OAM+$1F7				; | Properties of sun
		LDA #$8E				; |
		STA !OAM+$1FB				; |
		LDA #$CE				; |
		STA !OAM+$1FF				;/
		LDA #$02				;\
		STA !OAMhi+$7C				; |
		STA !OAMhi+$7D				; | Tile size of sun
		STA !OAMhi+$7E				; |
		STA !OAMhi+$7F				;/
		RTS

.BGColours	dw $006F,$006F
		dw $006E,$006E
		dw $006D,$006D
		dw $006D,$006D
		dw $006C,$006C
		dw $004C,$004C
		dw $004B,$004B
		dw $004A,$004A
		dw $0049,$0049
		dw $0048,$0048
		dw $0028
		dw $0027
		dw $0026
		dw $0025
		dw $0024,$0024
		dw $0004,$0004
		dw $0003,$0003,$0003,$0003,$0003,$0003,$0003
		dw $0403,$0403,$0403,$0403,$0403,$0403,$0403
		dw $0802,$0802,$0802,$0802,$0802,$0802,$0802
.BGColoursEnd	dw $0C21


level7:

	; !Level+3:
	; 00 - Enable mountain king message
	; 01 - Disable mountain king message

	; !Storyflags info:
	; 00 - Quest not started
	; 01 - Quest started
	; 02 - Quest started but abandoned
	; 03 - Quest complete
	; 04 - Quest rewarded

		LDA #$06
		TRB $6D9D
		TSB $6D9E


		LDA.b #level5_HDMA : STA !HDMAptr		;\
		LDA.b #level5_HDMA>>8 : STA !HDMAptr+1		; | Set up pointer
		LDA.b #level5_HDMA>>16 : STA !HDMAptr+2		;/

		LDA !StoryFlags+$02
		AND #$07 : BNE $03 : JMP .CheckCoin
		CMP #$01 : BEQ .QuestStarted
		CMP #$02 : BEQ .QuestAbandoned
		CMP #$04 : BCC .QuestComplete
		JMP .MountainEnd

		.QuestComplete
		LDA !Level+3 : BNE +
		JSR .NearMountainKing
		BCC $03
	+	JMP .MountainEnd
		LDA #$01 : STA !Level+3
		LDA #$06 : STA !MsgTrigger
		LDX #$00				; reward player with a lot of coins
		LDA !P2Status-$80 : BEQ +
		LDX #$02
	+	REP #$20
		LDA !P1Coins,x
		CLC : ADC #$02E9
		STA !P1Coins,x
		SEP #$20
		TXA
		LSR A
		TAX
		LDA #$FF : STA !P1CoinIncrease,x
		LDA !StoryFlags+$02			; mark quest as rewarded
		AND.b #$07^$FF
		ORA #$04
		STA !StoryFlags+$02
		BRA .MountainEnd

		.QuestAbandoned
		JSR .NearMountainKing
		BCS .MountainEnd
		LDA #$05 : STA !MsgTrigger
		LDA #$01 : STA !Level+3
		LDA !StoryFlags+$02
		AND.b #$07^$FF
		ORA #$01
		STA !StoryFlags+$02
		BRA .MountainEnd

		.QuestStarted
		JSR .NearMountainKing
		BCC +
		LDA $6DD9 : STA !SPC3 : STA $6F34
		STZ !Level+3
		LDA !StoryFlags+$02
		AND.b #$07^$FF
		ORA #$02
		STA !StoryFlags+$02
		BRA .QuestAbandoned
	+	LDA #$01 : STA !Level+3
		BRA .MountainEnd

		.CheckCoin
		LDX !Translevel
		LDA !YoshiCoinTable,x
		AND #$02 : BEQ .MountainEnd
		LDA #$01 : STA !MsgTrigger
		LDA !StoryFlags+$02
		AND.b #$07^$FF
		ORA #$01
		STA !StoryFlags+$02
		LDA !SPC3 : STA $6DD9
		LDA #$2E : STA !SPC3
		.MountainEnd

		LDA $1B
		CMP #$02 : BCC .SideExit
		CMP #$1E : BCS .SideExit+5
		STZ !SideExit
		BRA .NoExit

		.SideExit
		LDA #$01 : STA !SideExit
		REP #$20
		LDY #$01				;\ Regular exit left
		LDA #$0004 : JSR END_Left		;/
		LDA $1B
		CMP #$1E : BCC .NoExit
		REP #$20
		LDA #$01A0 : JSR EXIT_Down
		LDA $71
		CMP #$06 : BNE .NoExit
		LDA #$80 : STA !SPC3

		.NoExit


		LDA $1B
		CMP #$0C : BEQ +
		CMP #$0D : BNE ++

		LDA $1A
		CMP #$60 : BCS .CastleColor
		BRA .CaveColor

	+	LDA $1A
		CMP #$40 : BCC .CastleColor
		BRA .CaveColor

	++	CMP #$1B : BCS .CaveColor
		CMP #$1A : BNE .CastleColor
		LDA $1A
		CMP #$60 : BCC .CastleColor

		.CaveColor
		LDA !Level+2
		BEQ .Return
		JSL $138030
		BCS .Return
		PHB
		LDA #!VRAMbank
		PHA : PLB
		REP #$20
		LDA #$000E : STA !CGRAMtable+$00,y
		LDA.w #.Pal1 : STA !CGRAMtable+$02,y
		SEP #$20
		LDA.b #.Pal1>>16 : STA !CGRAMtable+$04,y
		LDA #$71 : STA !CGRAMtable+$05,y
		PLB
		STZ !Level+2
		RTS


		.CastleColor
		LDA !Level+2
		BNE .Return
		JSL $138030
		BCS .Return
		PHB
		LDA #!VRAMbank
		PHA : PLB
		REP #$20
		LDA #$000E : STA !CGRAMtable+$00,y
		LDA.w #.Pal2 : STA !CGRAMtable+$02,y
		SEP #$20
		LDA.b #.Pal2>>16 : STA !CGRAMtable+$04,y
		LDA #$71 : STA !CGRAMtable+$05,y
		PLB
		LDA #$01 : STA !Level+2

		.Return
		RTS


	; Carry clear = close
	; Carry set = not close
		.NearMountainKing
		REP #$20
		LDA $1A
		SEC : SBC #$0DE0
		BPL $03 : EOR #$FFFF
		CMP #$0050
		SEP #$20
		RTS

		.Pal1
		dw $7FDD,$0000,$08E1,$0DA2,$1663,$4653,$56F8	; green version

		dw $7FDD,$0C63,$2D6B,$39CE,$4231,$4E95,$5EF8	; grey version


		.Pal2
		dw $7FDD,$0000,$0C62,$2108,$31AD,$4653,$56F8


level8:
	RTS

level9:
	RTS
levelA:

		STZ !SideExit
		LDA $1B : BNE +
		INC !SideExit
		+

		LDA #$02 : STA $7403

		LDA.b #.HDMA : STA !HDMAptr+0
		LDA.b #.HDMA>>8 : STA !HDMAptr+1
		LDA.b #.HDMA>>16 : STA !HDMAptr+2
		RTS



; !Level+2: timer
; !Level+3: state (0 = wait, 1 = indicate, 2 = active)
; !Level+4: Xpos lo byte
; !Level+5: Xpos hi byte
; !VineDestroyTimer+$00: init flag for big bolt
; !VineDestroyTimer+$01: Ypos lo of big bolt
; !VineDestroyTimer+$02: Ypos hi of big bolt
; !VineDestroyTimer+$03: height of big bolt




		.HDMA
		PHP
		PHB : PHK : PLB
	LDX #$00
	LDA $13
	LSR A
	BCC $02 : LDX #$10

	REP #$20
	LDA #$00AF
	SEC : SBC $1C
	CLC : ADC #$00C0
	LSR A
		SEP #$30
	PHP
	CMP #$6C
	BCC $02 : LDA #$6C
	PLP


		REP #$20			; > A 16-bit

		LDA $1A : STA $22		;\
		LDA $1C				; | Set BG3 coordinates
		SEC : SBC #$006E		; |
		STA $24				;/
		LDA #$007F : STA $0400,x	;\
		STZ $0402,x			; | Make BG3 look like it's at the same height as BG1
		LDA $1C : STA $0401,x		;/


		LDA #$1202 : STA $4320,x	;\
		STZ $4323,x			; | Mode 2 to write twice to 2112
		TXA				; |
		ORA #$0400			; |
		STA $4322,x			;/

		SEP #$20			; > A 8-bit

		LDA #$0C : TRB $6D9F		; > Clear channels 2-3
		TXA				;\
		LSR A				; | Alternate between channels 2 and 3
		BNE $02 : LDA #$04		;/
		TSB $6D9F			; > Enable HDMA on channel 2


		..Lightning


; 2130: 0x02
; 2131: 0x24


		LDA !Level+3 : BPL ..Active		;\
		LDA $1B					; | Lightning starts at screen 0x02
		CMP #$02 : BCC ..Return			; |
		STZ !Level+3				;/

		..Active
		LDA !Level+2				;\ Decrement timer
		BEQ $03 : DEC !Level+2			;/
		LDA !Level+3 : BEQ ..Wait
		CMP #$01 : BEQ ..Strike
		CMP #$02 : BEQ ..Striking

		..Return
		PLB
		PLP
		RTL


		..Wait
		LDA #$00
		STA !VineDestroyTimer+$00
		STA !VineDestroyPage
		LDA !Level+2 : BNE ..Return
		INC !Level+3
		LDA #$40 : STA !Level+2
		LDA !P2XPosLo-$80 : STA !Level+4
		LDA !P2XPosHi-$80 : STA !Level+5

		..Strike
		LDA !Level+2 : BEQ ++
		CMP #$30 : BCS +
		CMP #$08 : BNE ..Return
		LDA #$18 : STA !SPC4
		PLB
		PLP
		RTL

	++	INC !Level+3
		LDA #$10 : STA !Level+2

		..Striking
		LDA !Level+2 : BNE +
		STZ !Level+3
		LDA #$80 : STA !Level+2
	+	LDA !Level+4 : STA $0C
		LDA !Level+5 : STA $0D
		LDA #$C0 : STA $0E
		STZ $0F

		LDY !Level+3
		LDA ..BoltTime,y
		SEC : SBC !Level+2
		BPL $02 : LDA #$00
		REP #$20
		AND #$00FF
		LSR #2
		XBA
		CMP #$0200
		BCC $03 : ADC #$01FF
		STA $00
		SEP #$20
		JSR levelinitA_GFX
		JSR LightningBolt
		PLB
		PLP
		RTL

	..BoltTime
	db $8E,$3E,$0E


levelB:
		LDA #$07
		LDX $1B
		CPX #$0B : BCC .Nah			;\ vines are destroyed slower between these screens
		CPX #$0F : BCS .Nah			;/
		LDA #$0F
		.Nah
		STA !VineDestroyBaseTime

		LDA !Level+4 : BNE .Nope		; Only do this once
		LDA $1B
		CMP #$0A : BCC .Nope
		REP #$10				;\
		LDX.w #155*16				; |
		LDY.w #15*16				; | This is what you do to get the pointer
		JSL $138018				; |
		SEP #$30				;/
		LDY #$32				;\
	-	LDA #$0E : STA [$05],y			; |
		DEY : STA [$05],y			; |
		DEY : STA [$05],y			; | Hi bytes are usually the same so this is pretty fast
		TYA					; |
		SEC : SBC #$0E				; |
		TAY					; |
		BPL -					;/
		DEC $07					; > Change banks
		LDY #$32				;\
		LDX #$03*3				; |
	-	LDA .VineTable+2,x : STA [$05],y	; |
		DEY					; |
		LDA .VineTable+1,x : STA [$05],y	; |
		DEY					; | This size can probably be cut a lot with some kind of indirect addressing
		LDA .VineTable+0,x : STA [$05],y	; |
		DEX #3					; |
		TYA					; |
		SEC : SBC #$0E				; |
		TAY					; |
		BPL -					;/
		REP #$20				;\
		LDA.w #.Dynamo : STA $0C		; | Load dynamo
		CLC : JSL !UpdateGFX			; |
		SEP #$20				;/
		LDA #$01 : STA !Level+4			; Don't repeat this
		.Nope


		REP #$20				; > A 16 bit
		LDA $14					;\ Only move fog vertically once every 8 frames
		AND #$0007 : BNE .FogDone		;/
		LDA !Level+2				;\ Don't stop raising fog once it starts
		CMP #$00C0 : BNE .RaiseFog		;/
		LDA $1A					;\ Threshold for fog rising is screen 0x10
		CMP #$0B80 : BCC .FogDone		;/

		.RaiseFog
		LDA !Level+2				;\
		BEQ .FogDone				; | Raise fog until it's at BG1's position
		DEC !Level+2				;/

		.FogDone
		LDA.w #.HDMA : STA !HDMAptr+0		; > Set lo-mid bytes of HDMA pointer
		LDY #$01				;\
		LDA #$1FE8				; | Do this now so I don't have to SEP #20
		JSR END_Right				;/ (normal exit at 0x1DE8
		LDA.b #.HDMA>>16 : STA !HDMAptr+2	; > Set hi byte of HDMA pointer
		JMP VineDestroy_MAIN			; > Handle vines

		.HDMA
		PHP
		SEP #$20
		LDA !GameMode
		CMP #$14 : BEQ +
		LDA $1B : BEQ +
		LDA #$8F : STA $1E
		LDA #$0A : STA $1F
	+	PLP

		LDA !Level+2				;\
		CMP #$00C0 : BNE +			; | Invisible until a certain point
	-	LDA #$0000 : BRA ++			;/
	+	LDA $1C					;\
		SEC : SBC !Level+2			; | Set BG3 Vscroll
	++	STA $24					;/
		BMI -					; > Make sure it's not visible at the top
		LDA $1E : STA $4204			;\
		LDX #$90 : STX $4206			; |
		JSR GET_DIVISION			; | Divide BG2 Hscroll by 0x90 and set it to the remainder
		LDA $4216				; | to make sure it loops every 9 tiles
		STA $1E					; |
		RTL					;/



		.VineTable
		db $E0,$E1,$E2
		db $F0,$F1,$F2
		db $E0,$E1,$E2
		db $F0,$F1,$F2

		.Dynamo			; puts volcano lotus fire on tiles 0x160 and 0x170
		dw ..End-..Start
		..Start
		dw $0020
		dl $31ECC0
		dw $7600
		dw $0020
		dl $31EEC0
		dw $7700
		..End


levelC:
	RTS
levelD:

		STZ $7414
		LDA #$C0 : STA !BG2BaseV
		LDA.b #.HDMA : STA !HDMAptr+0
		LDA.b #.HDMA>>8 : STA !HDMAptr+1
		LDA.b #.HDMA>>16 : STA !HDMAptr+2
		RTS

		.HDMA
		PHP
		SEP #$20
		LDA #$00 : STA $4332
		LDA #$C1 : STA $4333
		LDA.b #..SA1 : STA $3180
		LDA.b #..SA1>>8 : STA $3181
		LDA.b #..SA1>>16 : STA $3182
		JSR $1E80
		PLP
		RTL


		..SA1
		PHP
		PHB : PHK : PLB
		SEP #$20
		STZ $2250				; Enable multiplication

		REP #$30
		LDA $20					;\ $02 is the fake Y position (for stretching)
		STA $02					;/
		LDA $1C					;\
		LSR #3					; | $04 is number of rows to compress
		STA $04					;/
		LDA.w #..ScrollTable : STA $06		; > Pointer
		LDA #$013F
		SEC : SBC $20
		LSR A
		STA $40C100
		BCC $01 : INC A
		STA $40C105
		CLC : ADC $40C100
		STA $00

		LDA $20					;\
		STA $40C103				; | Set up Y coords for non-parallax part
		STA $40C108				;/
		LDA $40C101
		LDA #$00D7
		SEC : SBC $00
		TAY					; > Y = row count
		STA $00
		ASL #2
		CLC : ADC $00
		TAX
		LDA #$0000 : STA $40C10E,x		; [actual end]-1 so I don't overstep (16-bit mode)
		STX $00
		LDA #$0001				;\
	-	STA $40C10A,x				; |
		DEX #5					; | Set up row counts
		BPL -					; |
		LDX $00					;/

	-	LDA ..StretchTable,y
		AND #$00FF
		CMP $04
		BEQ +
		BCS ++
	+	DEC $02
		DEC $06
	++	LDA $02
		STA $40C10D,x

		LDA $1E
		SEC : SBC #$0200
		STA $2251
		LDA ($06),y
		AND #$00FF
		STA $2253
		NOP : BRA $00
		LDA $2308
		XBA
		AND #$FF00
		STA $00
		LDA $2306
		XBA
		BPL $01 : INC A
		AND #$00FF
		ORA $00
		STA $40C10B,x


		DEY
		DEX #5
		BPL -

		PLB
		PLP
		RTL

function f(x) = 0.98^x

..ScrollTable
db f($00),f($01),f($02),f($03),f($04),f($05),f($06),f($07)
db f($08),f($09),f($0A),f($0B),f($0C),f($0D),f($0E),f($0F)
db f($10),f($11),f($12),f($13),f($14),f($15),f($16),f($17)
db f($18),f($19),f($1A),f($1B),f($1C),f($1D),f($1E),f($1F)
db f($20),f($21),f($22),f($23),f($24),f($25),f($26),f($27)
db f($28),f($29),f($2A),f($2B),f($2C),f($2D),f($2E),f($2F)
db f($30),f($31),f($32),f($33),f($34),f($35),f($36),f($37)
db f($38),f($39),f($3A),f($3B),f($3C),f($3D),f($3E),f($3F)
db f($40),f($41),f($42),f($43),f($44),f($45),f($46),f($47)
db f($48),f($49),f($4A),f($4B),f($4C),f($4D),f($4E),f($4F)
db f($50),f($51),f($52),f($53),f($54),f($55),f($56),f($57)
db f($58),f($59),f($5A),f($5B),f($5C),f($5D),f($5E),f($5F)
db f($60),f($61),f($62),f($63),f($64),f($65),f($66),f($67)
db f($68),f($69),f($6A),f($6B),f($6C),f($6D),f($6E),f($6F)
db f($70),f($71),f($72),f($73),f($74),f($75),f($76),f($77)
db f($78),f($79),f($7A),f($7B),f($7C),f($7D),f($7E),f($7F)

..StretchTable
db $00,$06,$0C,$12,$18,$1E,$24,$2A,$30,$36,$3C,$42,$48,$4E,$54,$5A
db $01,$07,$0D,$13,$19,$1F,$25,$2B,$31,$37,$3D,$43,$49,$4F,$55,$5B
db $02,$08,$0E,$14,$1A,$20,$26,$2C,$32,$38,$3E,$44,$4A,$50,$56,$5C
db $03,$09,$0F,$15,$1B,$21,$27,$2D,$33,$39,$3F,$45,$4B,$51,$57,$5D
db $04,$0A,$10,$16,$1C,$22,$28,$2E,$34,$3A,$40,$46,$4C,$52,$58,$5E
db $05,$0B,$11,$17,$1D,$23,$29,$2F,$35,$3B,$41,$47,$4D,$53,$59,$5F



levelE:
		LDX #$00 : JSR WARP_BOX
		LDX #$06 : JSR WARP_BOX
		LDX #$0C : JSR WARP_BOX

		LDA !Level+4 : BNE .Gate

		REP #$20
		LDA $96
		CMP #$00C0 : BCS +
		LDA #$0100 : STA $00
		LDA #$0000
		JSR SCROLL_UPRIGHT
		BRA ++
		+
		STZ !Level+2
		LDX #$01 : STX !EnableVScroll
		++

		LDA.w #.Table1 : JSR TalkOnce

		LDA #$01A0
		STA $04
		STA $09
		LDA #$0050
		STA $05
		XBA : STA $0B
		LDA #$1008 : STA $06
		SEP #$20
		SEC : JSL !PlayerClipping
		BCS .Gate

		.NoWarp
		JMP DANCE


		.Gate

	; Animation code here

		LDA !Level+5 : BNE .CloseGate
		LDA !Level+4
		CMP #$13 : BEQ .CloseGate
		INC !Level+4
		STZ $43				; Sprites unaffected by window

	-	LDA #$FF
		STA !P2Stasis-$80
		STA !P2Stasis
		LDA #$48
		STA $0200
		STA $0203
		LDA #$01 : STA $0206
		STZ $0209
		LDA #$A8
		SEC : SBC !Level+4
		STA $0201
		STA $0204
		LDA #$A8
		CLC : ADC !Level+4
		STA $0202
		STA $0205
		LDA #$FF : STA $0207
		STZ $0208
		STZ $4324
		REP #$20
		LDA #$0200 : STA $4322
		LDA #$2601 : STA $4320
		SEP #$20
		LDA #$04 : TSB $6D9F
		LDA #$22
		STA $41
		STA $42
		RTS

		.CloseGate
		LDA #$03 : STA $43		; Sprites only visible inside window
		LDA #$01 : STA !Level+5
		DEC !Level+4 : BNE -

		.Warp
		LDA #$01 : STA !Level+5
		LDA #$06 : STA $71
		STZ $88
		STZ $89
		LDA #$10
		TRB $6D9D
		TRB $6D9E
		RTS


		;  ID  MSG      Xpos  Ypos       W   H
.Table1		db $00,$02 : dw $0010,$10D0 : db $B0,$50


levelF:
	RTS
level10:

		LDA !BossData+0
		AND #$7F
		CMP #$06 : BCS ++

		LDA $1B
		CMP #$04 : BCS +
		CMP #$02 : BEQ +++
		CMP #$03 : BCC ++
		STZ !EnableVScroll
		BRA ++

	+++	LDA.b #.HDMA2 : STA !HDMAptr+0
		LDA.b #.HDMA2>>8 : STA !HDMAptr+1
		LDA.b #.HDMA2>>16 : STA !HDMAptr+2

	++	JMP .HandleGrind

	+	PEA.w .HandleGrind-1
		LDA !BossData+0
		ASL A
		TAX
		JMP (.GrindPtr,x)


		.GrindPtr
		dw .Init		; 00
		dw .GrindStart		; 01
		dw .Wait		; 02
		dw .SpawnBirdo		; 03
		dw .KillBirdo		; 04
		dw .RisingPlatform	; 05
		dw .EmptyPtr		; 06
		dw .EmptyPtr		; 07

		.EmptyPtr
		RTS


		.Init
		LDA #$80 : STA !SPC3
		STZ !EnableHScroll
		INC !BossData+0
		RTS

		.GrindStart
		LDA !Level+4
		CMP #$10 : BCS ..Next
		LDA $14
		AND #$0F : BNE ..R
		INC !Level+4
		LDA #$0F : STA !ShakeTimer
		LDA #$17 : STA !SPC4
	..R	RTS
	..Next	INC !BossData+0
		LDA #$37 : STA !SPC3
		RTS

		.Wait
		LDA !BossData+0 : BMI ..Main
	..Init	ORA #$80 : STA !BossData+0
		LDA #$FF : STA !BossData+1
	..Main	LDA !BossData+1 : BNE ..Go
		INC !BossData+0
	..Go	DEC !BossData+1
		RTS

		.SpawnBirdo
		JSR SpawnBirdo
		LDA #$20 : STA $3210,x
		LDA #$80 : STA $3220,x
		LDA #$01 : STA $3240,x
		LDA #$04 : STA $3250,x
		LDA #$01 : STA $3230,x
		LDA #$80 : STA $9E,x
		INC !BossData+0
		RTS

		.KillBirdo
		JSR FindBirdo
		CPY #$00 : BNE ..R
		INC !BossData+0
	..R	RTS


		.RisingPlatform
		LDA $14
		AND #$0F : BNE ..R
		LDA #$0F : STA !ShakeTimer
		LDA #$17 : STA !SPC4

		INC !BossData+1
		LDA !BossData+1
		CMP #$1A : BNE ..R
		INC !BossData+0

		LDA #$01 : STA !EnableHScroll
		LDA #$09 : STA !SPC4
		LDA #$60
		STA !P2VectorX-$80
		STA !P2VectorX
		STA !P2VectorTimeX-$80
		STA !P2VectorTimeX
		LDA #$FF
		STA !P2VectorAccX-$80
		STA !P2VectorAccX
		LDA #$C0
		STA !P2VectorY-$80
		STA !P2VectorY
		LDA #$40
		STA !P2VectorTimeY-$80
		STA !P2VectorTimeY
	..R	RTS


		.HandleGrind
		LDA !BossData+0
		AND #$7F : BEQ ..Grind
		CMP #$06 : BCC ..Plat

		STZ !Level+2
		LDA #$04 : STA !Level+3
		STZ !Level+4
		LDA $1B					;\ Only go fast until screen 0x05 is reached
		CMP #$05 : BCC ..Fast			;/
		CMP #$06 : BNE ..Slow
		STZ $6D9F
	..Slow	LDA #$01 : STA !Level+3
	..Fast	LDA.b #.HDMA : STA !HDMAptr+0
		LDA.b #.HDMA>>8 : STA !HDMAptr+1
		LDA.b #.HDMA>>16 : STA !HDMAptr+2
		STZ !EnableHScroll
		RTS

	..Grind	LDA #$01 : STA !Level+2
		STA !Level+3
		STZ !Level+4
		JMP ScreenGrind

	..Plat	LDA #$FC
		STA !P2VectorX-$80
		STA !P2VectorX
		LDA #$02
		STA !P2VectorTimeX-$80
		STA !P2VectorTimeX
		JSR SpeedPlatform



	; Spawn Thif code

		LDA !BossData+0
		CMP #$02 : BCC .Return
		LDA $14
		AND #$0F : BNE .Return
		LDY #$00
		LDX #$0F
	-	LDA $3230,x
		CMP #$02 : BEQ +
		CMP #$08 : BNE ++
	+	LDA $35C0,x
		CMP #$17 : BNE ++
		INY

	++	DEX : BPL -
		LDA !Difficulty
		AND #$03
		INC A
		STA $00
		CPY $00 : BCS .Return
		JSL !GetSpriteSlot
		BMI .Return
		TYX
		LDA #$17 : STA $35C0,x		; custom sprite number
		LDA #$36 : STA $3200,x
		LDA #$01 : STA $3230,x
		JSL $07F7D2			; | > Reset sprite tables
		JSL $0187A7			; | > Reset custom sprite tables
		LDA !RNG			;\ Random table entry
		AND #$04 : TAY			;/
		LDA #$08 : STA $3590,x		; extra bits
		LDA .Table+0,y : STA $3220,x
		LDA .Table+1,y : STA $3250,x
		LDA #$D0 : STA $3210,x
		LDA #$00 : STA $3240,x
		LDA #$A0 : STA $9E,x
		LDA .Table+2,y : STA $3320,x
		LDA .Table+3,y : STA $AE,x

		.Return
		RTS

		.Table
		dw $03F0 : db $00,$10
		dw $0510 : db $01,$F0



		.HDMA
		PHP
		JSL ScreenGrind_HDMA
		REP #$20

		LDA $1A
		CMP #$0500 : BCC +
		CMP #$05FF : BCC ++
	+	LDA #$004F
		STA $0205
		DEC A
		STA $020A
		LDA $1A
		STA $0206
		STA $020B
		STA $0210
		LDA $1C
		STA $0208
		STA $020D
		LDA #$FF40 : STA $0212
		PLP
		RTL

		.HDMA2
		PHP
		REP #$20
	++	LDA #$0002 : STA $41
		LDA #$2601 : STA $4320
		STZ $4323
		LDA #$0400 : STA $4322
		LDA #$0022 : STA $0400
		LDA #$0001 : STA $0403
		STZ $0406
		LDA #$FF00 : STA $0401
		XBA
		STA $0404
		LDA #$0004 : TSB $6D9F
		PLP
		RTL



	FindBirdo:
		LDY #$00
		LDX #$0F
	.Loop	LDA $3230,x : BEQ .Nope
		LDA $3590,x
		AND #$08 : BEQ .Nope
		LDA $35C0,x
		CMP #$19 : BNE .Nope
		INY				; +1 Birdo

	.Nope	DEX : BPL .Loop
		RTS


	SpawnBirdo:
		JSL !GetSpriteSlot
		TYX
		LDA #$36 : STA $3200,x		; > Sprite num
		LDA #$19 : STA $35C0,x		; custom sprite num
		JSL $07F7D2			; > Reset tables
		JSL $0187A7			; > Reset custom sprite tables
		LDA #$08 : STA $3590,x		; extra bits
		RTS


level11:
	RTS
level12:
	RTS
level13:
	RTS
level14:
	RTS
level15:
	RTS
level16:
	RTS
level17:
	RTS
level18:
	RTS
level19:
	RTS
level1A:
	RTS
level1B:
	RTS
level1C:
	RTS
level1D:
	RTS
level1E:
	RTS
level1F:
	RTS
level20:
	RTS
level21:
	RTS
level22:
	RTS
level23:
	RTS
level24:
	RTS
level25:
	RTS

level26:
		STZ !SideExit
		LDA $1B
		BEQ .NoSide
		LDA $1D
		CMP #$02
		BNE .NoSide
		DEC A
		STA !SideExit
.NoSide		REP #$20				;\
		LDA $1C					; |
		LSR #4					; | BG3 Vscroll = Variable3
		STA $24					;/

		LDA #$01F8				;\
		LDY #$01				; | Regular exit
		JMP END_Right				;/


.RightLimit	dw $01FF,$01FF				; 0 - 1
		dw $01FF,$01FF				; 2 - 3
		dw $01FF,$01FF				; 4 - 5
		dw $01FF,$01FF				; 6 - 7
		dw $01FF,$01FF				; 8 - 9
		dw $01FF,$01FF				; A - B
		dw $01FF,$017F				; C - D

.LeftLimit	dw $0000,$0000				; 0 - 1
		dw $0000,$0000				; 2 - 3
		dw $0000,$0000				; 4 - 5
		dw $0100,$0100				; 6 - 7
		dw $0000,$0000				; 8 - 9
		dw $0000,$0000				; A - B
		dw $0000,$0000				; C - D


level27:
		REP #$20
		LDA #$01A0
		JMP EXIT_Down

level28:
		LDA !Level+4
		BNE .MoleRoom
		LDA #$01 : STA !EnableVScroll		; > Start with Vscroll enabled
		REP #$20				; > A 16 bit
		LDA !P2YPosLo-$80			;\
		CMP #$00C0 : BCC .Scroll		; | Scroll if a player goes above the screen
		LDA !P2YPosLo				; |
		CMP #$00C0 : BCC .Scroll		;/
		LDA $1A					;\
		CMP #$0080 : BCC .Scroll		; | Otherwise ground camera until X = 0x0500
		CMP #$0500 : BCS .Scroll		; |
		LDA #$00C0 : JSR LOCK_VSCROLL		;/


		.Scroll
		SEP #$20
		LDA $1B
		CMP #$07 : BEQ .EndLevel
		CMP #$08 : BNE .NoEnd

		.EndLevel
		LDY #$02
		REP #$20
		LDA #$0000 : JMP END_Up

		.NoEnd
		RTS


		.MoleRoom
		LDA !StoryFlags+$02			;\
		AND #$07				; | moles can only be fought once
		CMP #$03 : BCS +			;/


	; Mole spawn
		LDX #$0F
	-	LDA $3230,x
		BEQ .ProcessMoles
	+	JMP .NoMoreMoles

		.ProcessMoles
		DEX : BPL -
		LDA !Difficulty				;\
		AND #$03				; | Amount of waves depends on difficulty
		INC #2					; |
		STA $00					;/
		LDY !Level+5
		CPY $00 : BCS $03 : JMP .Mole
		BNE .NoMessage
		LDA #$02 : STA !MsgTrigger
		JMP .End

		.NoMessage
		CPY #$40 : BNE .NoPath

		LDA !StoryFlags+$02
		AND.b #$07^$FF
		ORA #$03
		STA !StoryFlags+$02

		.Block
		LDA #$09 : STA !SPC4			; > Boom sound
		LDA $1D : BNE +				;\ Only spawn smoke sprite on vertical screen 01
		LDA $1C : BPL ++			;/
	+	LDA #$01				;\
		STA $77C0 : STA $77C1			; |
		LDA #$60				; |
		STA $77C4 : STA $77C5			; | Smoke puff the cement blocks
		LDA #$40 : STA $77C8			; |
		LDA #$50 : STA $77C9			; |
		LDA #$17				; |
		STA $77CC : STA $77CD			;/
	++	PEI ($98)
		PEI ($9A)
		REP #$20
		LDA #$0940 : STA $9A
		LDA #$0160 : STA $98
		LDX #$02 : STX $9C
		JSL $00BEB0
		LDA #$0950 : STA $9A
		LDA #$0160 : STA $98
		LDX #$02 : STX $9C
		JSL $00BEB0
		PLA : STA $9A
		PLA : STA $98
		SEP #$20
		BRA .End

		.NoPath
		CPY #$41 : BEQ .NoMoreMoles
		BRA .End

		.Mole
		LDX .MoleCount,y		; X = mole (loop) count
		LDA .MoleOffset,y		; Y = table offset
		TAY

	-	LDA #$4D : STA $3200,x		; > Sprite num
		JSL $07F7D2			; > Reset tables
		LDA .MoleCoords+0,y		;\
		STA $3220,x			; |
		LDA .MoleCoords+1,y		; |
		STA $3250,x			; |
		LDA .MoleCoords+2,y		; | Spawn mole
		STA $3210,x			; |
		LDA .MoleCoords+3,y		; |
		STA $3240,x			; |
		LDA #$01 : STA $3230,x		;/
		LDA #$0D : STA $33C0,x		; > Set YXPPCCCT
		TYA				;\
		CLC : ADC #$04			; | Loop
		TAY				; |
		DEX : BPL -			;/

		.End
		INC !Level+5

		.NoMoreMoles
		REP #$20
		LDA #$01A0 : JSR EXIT_Down
		SEP #$20

		.Return
		RTS

.MoleCount	db $02,$03,$03,$07

.MoleOffset	db $00,$0C,$04,$00

		; X coords, Y coords
.MoleCoords	dw $0910,$0120			; Each row represents one mole
		dw $0920,$0150
		dw $0970,$0150
		dw $09A0,$0150
		dw $09A0,$0110
		dw $09E0,$0120
		dw $09D0,$0150
		dw $0990,$00E0



level29:
		LDA $1B : BEQ .NoExit
		LDA $1D
		CMP #$0F : BCS .NoExit
		LDA #$01 : STA !SideExit
		REP #$20
		LDA #$01F8				;\
		LDY #$01				; | Regular exit
		JMP END_Right				;/

		.NoExit
		STZ !SideExit
		RTS


level2A:	REP #$20
		LDY #$00
		LDA $1A
		CMP #$0470-$80 : BCC .DisableV
		CMP #$09E0-$80 : BCC .EnableV
		CMP #$0D00-$80 : BCS +
		PEA .DisableV+2
		LDA #$0080 : JMP LOCK_VSCROLL

	+	CMP #$0E80-$80 : BCS .EnableV
		PEA .DisableV+2
		LDA #$0050 : JMP LOCK_VSCROLL
.EnableV	STZ !Level+2
		INY
.DisableV	STY !EnableVScroll

		LDY $95
		CPY #$10 : BNE .NoExit
		LDA $96
		BPL .NoExit
		CMP #$FFE0 : BCS .NoExit
		LDY #$05 : STY $71
		LDY #$00 : STY $88
		SEP #$20
		RTS
.NoExit		SEP #$20


; $1892+$00:	BA------21
;		B = P2 ready
;		A = P1 ready
;		2 = P2 entering cannon
;		1 = P1 entering cannon
;
; $1892+$01:	Timer
; $1892+$02:	0 = cannon ready, 1 = cannon has fired

		LDA $7892+$00			;\
		AND #$03			; |
		STA $00				; |
		LDA !P2Status-$80		; |
		BEQ $04 : LDA #$01 : TSB $00	; | (mark nonexistant players as processed)
		LDA !P2Status			; |
		BEQ $04 : LDA #$02 : TSB $00	; | Scroll camera when cannon is ready
		LDA $00				; |
		CMP #$03			; |
		BNE .NoCam			; |
		REP #$20			; |
		LDA #$1000			; |
		JSR LOCK_HSCROLL		; |
		SEP #$20			; |
		.NoCam				;/

		LDA $7892+$02			;\ See if cannon has fired already
		BEQ $03 : JMP .PrepShoot	;/


		LDY #$00			; Start index
	-	REP #$20			;\
		LDA !P2XPosLo-$80,y		; |
		CMP #$1020 : BCC .Next		; | Must be within bounds (x-axis)
		CMP #$1030 : BCS .Next		; |
		SEP #$20			;/
		LDA !P2Blocked-$80,y : STA $00
		PHY
		TYA
		CLC : ROL #2
		TAY
		INC A
		AND $7892+$00 : BNE .Nope	; Can't enter if already entering
		LDA $00				;\
		AND $6DA6,y			; | Must be on top of cannon and push down
		AND #$04 : BEQ .Nope		;/
		TYA				;\
		INC A				; | Mark player as entered
		TSB $7892+$00			;/

	.Nope	PLY
	.Next	SEP #$20
		LDA !MultiPlayer : BEQ .Done
		CPY #$80 : BEQ .Done
		LDY #$80 : BRA -

	.Done	LDX #$00
		LDA #$E0 : STA $0E		;\ $32E0 disables interaction for P1
		LDA #$32 : STA $0F		;/
		LDA $7892+$00
		AND #$03
		LSR A : BCC .P2
		PHA
		JSR .PlayerEntering
		PLA
	.P2	LSR A : BCC .Return
		LDX #$80
		LDA #$F0 : STA $0E		;\ $35F0 disables interaction for P1
		LDA #$35 : STA $0F		;/
.PlayerEntering	LDA !P2Character-$80,x : BNE +	;\
		PEA.w .PlayerD-1		; | Special code for Mario
		JMP .MarioEntering		;/
	+	LDA #$DF : STA !P2Pipe-$80,x
		LDY #$0F			;\
		LDA #$FF			; | Disable interaction for player
	-	STA ($0E),y			; |
		DEY : BPL -			;/
		LDA !P2XPosLo
		CMP #$26 : BEQ .PlayerD
		BCC .PlayerR
.PlayerL	DEC !P2YPosLo-$80,x
		DEC !P2XPosLo-$80,x
		BRA .Return
.PlayerR	DEC !P2YPosLo-$80,x
		INC !P2XPosLo-$80,x
		BRA .Return
.PlayerD	LDA !P2YPosLo-$80,x
		CMP #$70 : BNE .Return
		TXA				;\
		BNE $02 : LDA #$40		; | Mark player as ready
		TSB $7892+$00			;/
		DEC !P2YPosLo-$80,x
		BRA .PrepShoot
.Return		SEP #$20
		RTS

.PrepShoot	LDA $7892+$00
		STA $00
		LDA !P1Dead
		BEQ $04 : LDA #$40 : TSB $00
		LDA !P2Status
		BEQ $04 : LDA #$80 : TSB $00
		BIT $00
		BPL .Return
		BVC .Return

		INC $7892+$01
		LDA $7892+$01
		CMP #$01 : BEQ ++
		CMP #$10 : BNE +
	++	LDY #$01 : STY !SPC1
	+	CMP #$30 : BNE +
		LDY #$09 : STY !SPC4
		PHB
		REP #$30
		LDX #$4140				; > This be bank numbers for map16 tables
		PHX
		PLB
		LDX #$2525
		STX $E303
		STX $E305
		STX $E307
		STX $E309
		STX $E30B
		PLB
		STZ $E303
		STZ $E305
		STZ $E307
		STZ $E309
		STZ $E30B
		SEP #$30
		PLB
	+	CMP #$34 : BNE +
		LDA #$01 : STA $7892+$02
	+	JSL !GetVRAM
		LDA $7892+$02 : BEQ +


		LDA !P1Dead : BNE .NoMario		;\
		LDA #$07 : STA $71			; |
		LDA #$0C : STA $73E0			; |
.NoMario	LDA #$40 : STA $7B			; |
		STA !P2XSpeed-$80 : STA !P2XSpeed	; |
		LDA #$C0 : STA $7D			; | Eject players at high velocity
		STA !P2YSpeed-$80 : STA !P2YSpeed	; |
		STZ $88					; |
		STZ !P2Pipe-$80				; |
		STZ !P2Pipe				; |
		REP #$20				; |
		LDY #$08 : BRA ++			;/


	+	LDA $7892+$01
		LSR #4
		ASL #3
		REP #$20
		AND #$001E
		TAY
	++	LDA.w .Cannon+0,y : STA $00
		LDA.w .Cannon+2,y : STA $02
		LDA.w .Cannon+4,y : STA $04
		LDA.w .Cannon+6,y : STA $06
		PHB
		PEA $7F7F
		PLB : PLB
		LDA $00 : STA $A100
		INC A : STA $A102
		INC A : STA $A104
		INC A : STA $A106
		LDA $02 : STA $A108
		INC A : STA $A10A
		INC A : STA $A10C
		INC A : STA $A10E
		LDA $04 : STA $A110
		INC A : STA $A112
		INC A : STA $A114
		INC A : STA $A116
		LDA $06 : STA $A118
		INC A : STA $A11A
		INC A : STA $A11C
		INC A : STA $A11E
		LDY.b #!VRAMbank
		PHY : PLB
		LDA #$0008
		STA !VRAMtable+$00,x
		STA !VRAMtable+$07,x
		STA !VRAMtable+$0E,x
		STA !VRAMtable+$15,x
		LDA #$A100 : STA !VRAMtable+$02,x
		LDA #$A108 : STA !VRAMtable+$09,x
		LDA #$A110 : STA !VRAMtable+$10,x
		LDA #$A118 : STA !VRAMtable+$17,x
		LDA #$7FA1
		STA !VRAMtable+$03,x
		STA !VRAMtable+$0A,x
		STA !VRAMtable+$11,x
		STA !VRAMtable+$18,x
		LDA #$3184 : STA !VRAMtable+$05,x
		LDA #$31A4 : STA !VRAMtable+$0C,x
		LDA #$31C4 : STA !VRAMtable+$13,x
		LDA #$31E4 : STA !VRAMtable+$1A,x
		PLB
	+	SEP #$20
		RTS


.MarioEntering	LDA #$0F : STA $73E0
		LDA #$06 : STA $71
		STA $88
		LDA $94
		CMP #$26 : BEQ .MarioD
		BCC .MarioR
.MarioL		DEC $94
		RTS
.MarioR		INC $94
		RTS
.MarioD		LDA $96
		CLC : ADC #$10
		STA !P2YPosLo-$80,x
		CMP #$70 : BEQ +
		INC $96
	+	RTS


; YXPCCCTT tttttttt
; $2A
;

.Cannon
.CannonAim1	dw $2AE0
		dw $2AF0
		dw $2AE4
		dw $2AF4
.CannonAim2	dw $2AA4
		dw $2AB4
		dw $2AC4
		dw $2AD4
.CannonFire1	dw $2AA8
		dw $2AB8
		dw $2AC8
		dw $2AD8
.CannonFire2	dw $2AAC
		dw $2ABC
		dw $2ACC
		dw $2ADC


level2B:
		STZ !SideExit
		LDA $1B
		BEQ .NoExit
		INC !SideExit
		.NoExit

		LDA !Level+2
		BEQ +
		DEC !Level+2
		LDA #$40 : STA !P2XSpeed
		LDA #$C0 : STA !P2YSpeed
		+

		REP #$20
		LDA #$06F8
		PEA level5_NoExit-1
		JMP EXIT_FADE_Right


level2C:
		LDX #$0F
	-	LDA $3230,x			;\
		CMP #$02 : BCC +		; | Look for a killed sprite (states 2-7)
		CMP #$08 : BCS +		;/
		LDY $3240,x			;\ Must be on screen 00-03
		CPY #$04 : BCS +		;/
		LDA .Table,y			;\ If there's a rex, it can talk
		TSB $6DF5			;/
	+	DEX : BPL -			; Loop

		REP #$20
		LDA.w #.Table1 : JSR TalkOnce
		LDA.w #.Table2 : JSR TalkOnce
		LDA.w #.Table3 : JSR TalkOnce

		LDA $1A
		CMP #$00E0 : BNE +
		LDA $1C
		BNE +
		LDA $6DF5
		AND #$0008
		BNE +
		LDX #$08 : STX !MsgTrigger
		LDA #$0008
		TSB $6DF5
		+

		LDA $94
		CMP #$0148 : BCC .NoEntry1
		CMP #$0168 : BCS .NoEntry1
		SEP #$20
		LDA $16
		AND #$08 : BEQ .NoEntry1
		LDA $77
		AND #$04 : BNE .Entry

		.NoEntry1
		REP #$20
		LDA !P2XPosLo
		CMP #$0148 : BCC .NoEntry2
		CMP #$0168 : BCS .NoEntry2
		SEP #$20
		LDA $6DA7
		AND #$08 : BEQ .NoEntry2
		LDA !P2Blocked
		AND #$04 : BEQ .NoEntry2

		.Entry
		LDA #$05 : STA $71
		STZ $88
		LDA #$80 : STA !SPC3
		.NoEntry2

		REP #$20
		LDA $96
		CMP #$0091
		BCS +
		LDA #$00E0 : STA $00
		LDA #$0000
		JSR SCROLL_UPRIGHT
		SEP #$20
		RTS
	+	STZ !Level+2
		SEP #$20
		LDA #$01
		STA !EnableVScroll
		RTS


		.Table
		db $00,$04,$02,$01

		;  ID  MSG      Xpos  Ypos       W   H
.Table1		db $00,$03 : dw $0150,$0360 : db $70,$30
.Table2		db $02,$05 : dw $0020,$0280 : db $50,$40
.Table3		db $04,$06 : dw $0090,$0120 : db $20,$30



level2D:	LDA.b #.HDMA : STA !HDMAptr+0
		LDA.b #.HDMA>>8 : STA !HDMAptr+1
		LDA.b #.HDMA>>16 : STA !HDMAptr+2
		RTS

		.HDMA
		PHP
		REP #$20
		LDA $14
		AND #$0007
		BNE $03 : DEC !Level+2
		LDA !Level+2 : STA $1E
		PLP
		RTL

level2E:
	RTS
level2F:
		REP #$20
		LDA #$0FF8				;\
		LDY #$01				; | Regular exit
		JSR END_Right				;/

		REP #$20
		LDA #$0008
		JMP EXIT_Left


level30:
		JSR levelA
		REP #$20
		LDA #$0AE8 : JMP END_Right		; Exit

level31:
		LDA !MsgTrigger : BNE .Continue
		LDA !Level+4 : BEQ .Continue
		DEC !Level+4 : BNE .Continue
		JMP END_End

		.Continue
		JMP DANCE



level32:
	RTS
level33:
	RTS
level34:
	RTS
level35:
	RTS
level36:
	RTS
level37:
	RTS
level38:
	RTS
level39:
	RTS
level3A:
	RTS
level3B:
	RTS
level3C:
	RTS
level3D:
	RTS
level3E:
	RTS
level3F:
	RTS
level40:
	RTS
level41:
	RTS
level42:
	RTS
level43:
	RTS
level44:
	RTS
level45:
	RTS
level46:
	RTS
level47:
	RTS
level48:
	RTS
level49:
	RTS
level4A:
	RTS
level4B:
	RTS
level4C:
	RTS
level4D:
	RTS
level4E:
	RTS
level4F:
	RTS
level50:
	RTS
level51:
	RTS
level52:
	RTS
level53:
	RTS
level54:
	RTS
level55:
	RTS
level56:
	RTS
level57:
	RTS
level58:
	RTS
level59:
	RTS
level5A:
	RTS
level5B:
	RTS
level5C:
	RTS
level5D:
	RTS
level5E:
	RTS
level5F:
	RTS
level60:
	RTS
level61:
	RTS
level62:
	RTS
level63:
	RTS
level64:
	RTS
level65:
	RTS
level66:
	RTS
level67:
	RTS
level68:
	RTS
level69:
	RTS
level6A:
	RTS
level6B:
	RTS
level6C:
	RTS
level6D:
	RTS
level6E:
	RTS
level6F:
	RTS
level70:
	RTS
level71:
	RTS
level72:
	RTS
level73:
	RTS
level74:
	RTS
level75:
	RTS
level76:
	RTS
level77:
	RTS
level78:
	RTS
level79:
	RTS
level7A:
	RTS
level7B:
	RTS
level7C:
	RTS
level7D:
	RTS
level7E:
	RTS
level7F:
	RTS
level80:
	RTS
level81:
	RTS
level82:
	RTS
level83:
	RTS
level84:
	RTS
level85:
	RTS
level86:
	RTS
level87:
	RTS
level88:
	RTS
level89:
	RTS
level8A:
	RTS
level8B:
	RTS
level8C:
	RTS
level8D:
	RTS
level8E:
	RTS
level8F:
	RTS
level90:
	RTS
level91:
	RTS
level92:
	RTS
level93:
	RTS
level94:
	RTS
level95:
	RTS
level96:
	RTS
level97:
	RTS
level98:
	RTS
level99:
	RTS
level9A:
	RTS
level9B:
	RTS
level9C:
	RTS
level9D:
	RTS
level9E:
	RTS
level9F:
	RTS
levelA0:
	RTS
levelA1:
	RTS
levelA2:
	RTS
levelA3:
	RTS
levelA4:
	RTS
levelA5:
	RTS
levelA6:
	RTS
levelA7:
	RTS
levelA8:
	RTS
levelA9:
	RTS
levelAA:
	RTS
levelAB:
	RTS
levelAC:
	RTS
levelAD:
	RTS
levelAE:
	RTS
levelAF:
	RTS
levelB0:
	RTS
levelB1:
	RTS
levelB2:
	RTS
levelB3:
	RTS
levelB4:
	RTS
levelB5:
	RTS
levelB6:
	RTS
levelB7:
	RTS
levelB8:
	RTS
levelB9:
	RTS
levelBA:
	RTS
levelBB:
	RTS
levelBC:
	RTS
levelBD:
	RTS
levelBE:
	RTS
levelBF:
	RTS
levelC0:
	RTS
levelC1:
	RTS
levelC2:
	RTS
levelC3:
	RTS
levelC4:
	RTS
levelC5:
	RTS
levelC6:
	RTS
levelC7:
		LDA #$FF
		STA !P2Stasis-$80
		STA !P2Stasis
		RTS
levelC8:
	RTS
levelC9:
	RTS
levelCA:
	RTS
levelCB:
	RTS
levelCC:
	RTS
levelCD:
	RTS
levelCE:
	RTS
levelCF:
	RTS
levelD0:
	RTS
levelD1:
	RTS
levelD2:
	RTS
levelD3:
	RTS
levelD4:
	RTS
levelD5:
	RTS
levelD6:
	RTS
levelD7:
	RTS
levelD8:
	RTS
levelD9:
	RTS
levelDA:
	RTS
levelDB:
	RTS
levelDC:
	RTS
levelDD:
	RTS
levelDE:
	RTS
levelDF:
	RTS
levelE0:
	RTS
levelE1:
	RTS
levelE2:
	RTS
levelE3:
	RTS
levelE4:
	RTS
levelE5:
	RTS
levelE6:
	RTS
levelE7:
	RTS
levelE8:
	RTS
levelE9:
	RTS
levelEA:
	RTS
levelEB:
	RTS
levelEC:
	RTS
levelED:
	RTS
levelEE:
	RTS
levelEF:
	RTS
levelF0:
	RTS
levelF1:
	RTS
levelF2:
	RTS
levelF3:
	RTS
levelF4:
	RTS
levelF5:
	RTS
levelF6:
	RTS
levelF7:
	RTS
levelF8:
	RTS
levelF9:
	RTS
levelFA:
	RTS
levelFB:
	RTS
levelFC:
	RTS
levelFD:
	RTS
levelFE:
	RTS
levelFF:
	RTS
level100:
	RTS
level101:
	RTS
level102:
	RTS
level103:
	RTS
level104:
	RTS
level105:
	RTS
level106:
	RTS
level107:
	RTS
level108:
	RTS
level109:
	RTS
level10A:
	RTS
level10B:
	RTS
level10C:
	RTS
level10D:
	RTS
level10E:
	RTS
level10F:
	RTS
level110:
	RTS
level111:
	RTS
level112:
	RTS
level113:
	RTS
level114:
	RTS
level115:
	RTS
level116:
	RTS
level117:
	RTS
level118:
	RTS
level119:
	RTS
level11A:
	RTS
level11B:
	RTS
level11C:
	RTS
level11D:
	RTS
level11E:
	RTS
level11F:
	RTS
level120:
		LDA $6DA6
		AND #$20
		BEQ +
		JMP END_End
		+
		RTS
level121:
	RTS
level122:
	RTS
level123:
	RTS
level124:
	RTS
level125:
	RTS
level126:
	RTS
level127:
	RTS
level128:
	RTS
level129:
	RTS
level12A:
	RTS
level12B:
	RTS
level12C:
	RTS
level12D:
	RTS
level12E:
	RTS
level12F:
	RTS
level130:
	RTS
level131:
	RTS
level132:
	RTS
level133:
	RTS
level134:
	RTS
level135:
	RTS
level136:
	RTS
level137:
	RTS
level138:
	RTS
level139:
	RTS
level13A:
	RTS
level13B:
	RTS
level13C:
	RTS
level13D:
	RTS
level13E:
	RTS
level13F:
	RTS
level140:
	RTS
level141:
	RTS
level142:
	RTS
level143:
	RTS
level144:
	RTS
level145:
	RTS
level146:
	RTS
level147:
	RTS
level148:
	RTS
level149:
	RTS
level14A:
	RTS
level14B:
	RTS
level14C:
	RTS
level14D:
	RTS
level14E:
	RTS
level14F:
	RTS
level150:
	RTS
level151:
	RTS
level152:
	RTS
level153:
	RTS
level154:
	RTS
level155:
	RTS
level156:
	RTS
level157:
	RTS
level158:
	RTS
level159:
	RTS
level15A:
	RTS
level15B:
	RTS
level15C:
	RTS
level15D:
	RTS
level15E:
	RTS
level15F:
	RTS
level160:
	RTS
level161:
	RTS
level162:
	RTS
level163:
	RTS
level164:
	RTS
level165:
	RTS
level166:
	RTS
level167:
	RTS
level168:
	RTS
level169:
	RTS
level16A:
	RTS
level16B:
	RTS
level16C:
	RTS
level16D:
	RTS
level16E:
	RTS
level16F:
	RTS
level170:
	RTS
level171:
	RTS
level172:
	RTS
level173:
	RTS
level174:
	RTS
level175:
	RTS
level176:
	RTS
level177:
	RTS
level178:
	RTS
level179:
	RTS
level17A:
	RTS
level17B:
	RTS
level17C:
	RTS
level17D:
	RTS
level17E:
	RTS
level17F:
	RTS
level180:
	RTS
level181:
	RTS
level182:
	RTS
level183:
	RTS
level184:
	RTS
level185:
	RTS
level186:
	RTS
level187:
	RTS
level188:
	RTS
level189:
	RTS
level18A:
	RTS
level18B:
	RTS
level18C:
	RTS
level18D:
	RTS
level18E:
	RTS
level18F:
	RTS
level190:
	RTS
level191:
	RTS
level192:
	RTS
level193:
	RTS
level194:
	RTS
level195:
	RTS
level196:
	RTS
level197:
	RTS
level198:
	RTS
level199:
	RTS
level19A:
	RTS
level19B:
	RTS
level19C:
	RTS
level19D:
	RTS
level19E:
	RTS
level19F:
	RTS
level1A0:
	RTS
level1A1:
	RTS
level1A2:
	RTS
level1A3:
	RTS
level1A4:
	RTS
level1A5:
	RTS
level1A6:
	RTS
level1A7:
	RTS
level1A8:
	RTS
level1A9:
	RTS
level1AA:
	RTS
level1AB:
	RTS
level1AC:
	RTS
level1AD:
	RTS
level1AE:
	RTS
level1AF:
	RTS
level1B0:
	RTS
level1B1:
	RTS
level1B2:
	RTS
level1B3:
	RTS
level1B4:
	RTS
level1B5:
	RTS
level1B6:
	RTS
level1B7:
	RTS
level1B8:
	RTS
level1B9:
	RTS
level1BA:
	RTS
level1BB:
	RTS
level1BC:
	RTS
level1BD:
	RTS
level1BE:
	RTS
level1BF:
	RTS
level1C0:
	RTS
level1C1:
	RTS
level1C2:
	RTS
level1C3:
	RTS
level1C4:
	RTS
level1C5:
	RTS
level1C6:
	RTS
level1C7:
	RTS
level1C8:
	RTS
level1C9:
	RTS
level1CA:
	RTS
level1CB:
	RTS
level1CC:
	RTS
level1CD:
	RTS
level1CE:
	RTS
level1CF:
	RTS
level1D0:
	RTS
level1D1:
	RTS
level1D2:
	RTS
level1D3:
	RTS
level1D4:
	RTS
level1D5:
	RTS
level1D6:
	RTS
level1D7:
	RTS
level1D8:
	RTS
level1D9:
	RTS
level1DA:
	RTS
level1DB:
	RTS
level1DC:
	RTS
level1DD:
	RTS
level1DE:
	RTS
level1DF:
	RTS
level1E0:
	RTS
level1E1:
	RTS
level1E2:
	RTS
level1E3:
	RTS
level1E4:
	RTS
level1E5:
	RTS
level1E6:
	RTS
level1E7:
	RTS
level1E8:
	RTS
level1E9:
	RTS
level1EA:
	RTS
level1EB:
	RTS
level1EC:
	RTS
level1ED:
	RTS
level1EE:
	RTS
level1EF:
	RTS
level1F0:
	RTS
level1F1:
	RTS
level1F2:
	RTS
level1F3:
	RTS
level1F4:
	RTS
level1F5:
	RTS
level1F6:
	RTS
level1F7:
	RTS
level1F8:
	RTS
level1F9:
	RTS
level1FA:
	RTS
level1FB:
	RTS
level1FC:
	RTS
level1FD:
	RTS
level1FE:
	RTS
level1FF:
	RTS

; --Help routines--

GET_CGRAM:
		PHP : PHB
		SEP #$30
		LDA #!VRAMbank
		PHA : PLB
		LDX #$00
.Loop		LDA !CGRAMtable+$01,x
		BEQ .CheckLo
.NotFound	TXA
		CLC : ADC #$06
		BCS .Return
		TAX
		BRA .Loop
.Return		PLB : PLP
		SEC
		RTS
.CheckLo	LDA !CGRAMtable,x
		BNE .NotFound
		PLB : PLP
		RTS


CLEAR_DYNAMIC_BG3:
		PHP
		REP #$30
		LDA #$38FC
		LDX #$003E
	-	STA $0020,x
		DEX #2
		BPL -
		PLP
		RTS


LOCK_VSCROLL:	LDY #$00
		CMP $1C
		BEQ .Done
		LDA $1C
		BCC .Up
.Down		INC A
		INY
		BRA .Done
.Up		DEC A
		INY
.Done		STA !Level+2
		STY !EnableVScroll
		LDA.w #.Scroll : STA !HDMAptr+0
		LDA.w #.Scroll>>8 : STA !HDMAptr+1
		RTS

		.Scroll
		PHP
		REP #$20
		LDA !Level+2
		STA $1C
		LDA #$0000
		STA !HDMAptr+0
		STA !HDMAptr+1
		PLP
		RTL


LOCK_HSCROLL:	LDY #$00
		CMP $1A
		BEQ .Done
		LDA $1A
		BCC .Left
.Right		INC A
		INY
		BRA .Done
.Left		DEC A
		INY
.Done		STA !Level+2
		STY !EnableHScroll
		LDA.w #.Scroll : STA !HDMAptr+0
		LDA.w #.Scroll>>8 : STA !HDMAptr+1
		RTS

		.Scroll
		PHP
		REP #$20
		LDA !Level+2
		STA $1A
		LDA #$0000
		STA !HDMAptr+0
		STA !HDMAptr+1
		PLP
		RTL


SCROLL_UPRIGHT:	LDY #$00
		STY !EnableHScroll
		STY !EnableVScroll
		CMP $1C
		BEQ .DoneUp
		LDA $1C
		DEC A
		STA !Level+2
		LDA.w #.ScrollUp : STA !HDMAptr+0
		LDA.w #.ScrollUp>>8 : STA !HDMAptr+1
		RTS

.DoneUp		LDA $1A
		CMP $00
		BEQ .DoneRight
		INC A
		STA !Level+2
		LDA.w #.ScrollRight : STA !HDMAptr+0
		LDA.w #.ScrollRight>>8 : STA !HDMAptr+1
.DoneRight	RTS


		.ScrollUp
		PHP
		REP #$20
		LDA !Level+2
		STA $1C
		LDA #$0000
		STA !HDMAptr+0
		STA !HDMAptr+1
		PLP
		RTL

		.ScrollRight
		PHP
		REP #$20
		LDA !Level+2
		STA $1A

		SEC : SBC !MarioXPosLo
		CMP #$0004 : BCS +
		LDA $1A
		CLC : ADC #$0004
		STA !MarioXPosLo
		+

		LDA #$0000
		STA !HDMAptr+0
		STA !HDMAptr+1
		PLP
		RTL



CALC_MULTI:	LDA $00
		CLC : ADC $00
		DEX
		BNE CALC_MULTI
		STA $4204
		SEP #$10
		LDX #100
		STX $4206
		JSR GET_DIVISION
		LDA $4214
		RTS

GET_DIVISION:	NOP #2
		RTS


REX_LEVEL:	PHB : LDA #!VRAMbank		;\ Bank wrapper
		PHA : PLB			;/
		JSL !GetVRAM			; > Get index
		LDA #$30			;\
		STA !VRAMtable+$04,x		; | Source bank
		STA !VRAMtable+$0B,x		;/
		REP #$20			; > A 16 bit
		LDA #$0C00			;\
		STA !VRAMtable+$00,x		; | Upload size
		STA !VRAMtable+$07,x		;/
		LDA #$8008			;\
		STA !VRAMtable+$02,x		; | Source address
		LDA #$9808			; |
		STA !VRAMtable+$09,x		;/
		LDA #$7000			;\
		STA !VRAMtable+$05,x		; | Dest VRAM
		LDA #$7600			; |
		STA !VRAMtable+$0C,x		;/
		SEP #$20			; > A 8 bit
		PLB				; > Restore bank
		STZ !GFX_status+$03
		LDA #$60 : STA !GFX_status+$04
		STZ !GFX_status+$05
		RTS				; > Return


PLANT_GFX:	PHB
		PHA
		JSL !GetVRAM
		LDY #!VRAMbank
		PHY : PLB
		LDA #$3131			;\
		STA !VRAMtable+$04,x		; |
		STA !VRAMtable+$0B,x		; | Queue plant upload
		PLA				; |
		STA !VRAMtable+$05,x		; |
		CLC : ADC #$0100		; |
		STA !VRAMtable+$0C,x		; |
		LDA #$EC00			; |
		STA !VRAMtable+$02,x		; |
		LDA #$EE00			; |
		STA !VRAMtable+$09,x		; |
		LDA #$00C0			; |
		STA !VRAMtable+$00,x		; |
		LDA #$0080			; |
		STA !VRAMtable+$07,x		;/
		SEP #$20
		PLB
		RTS

MOLE_GFX:	JSL !GetVRAM
		REP #$20
		LDA.w #$06A0 : STA.l !VRAMbase+!VRAMtable+$00,x
		LDA.w #!MoleWizard : STA.l !VRAMbase+!VRAMtable+$02,x
		LDA.w #!MoleWizard>>8 : STA.l !VRAMbase+!VRAMtable+$03,x
		LDA #$7000 : STA.l !VRAMbase+!VRAMtable+$05,x
		SEP #$20
		RTS



VineDestroy:

		.INIT
		LDX #$17					;\
		LDA #$FF					; | Write 0xFF ("off") to all vine destroy regs
	-	STA !VineDestroy+1,x				; |
		DEX : BPL -					;/
		RTS						; > Return


		.MAIN
		LDA.b #..SA1 : STA $3180			;\
		LDA.b #..SA1>>8 : STA $3181			; | Make the SA-1 process this since it's really intense
		LDA.b #..SA1>>16 : STA $3182			; |
		JMP $1E80					;/

		..SA1
		PHB						;\
		LDA.b #!VineDestroy>>16				; | Switch to vine bank
		PHA : PLB					;/
		LDY #$03					; > Highest vine destroy index
	..Loop	LDA $14						;\
	-	CMP.w !VineDestroyTimer,y			; |
		BCC +						; |
		SBC.w !VineDestroyTimer,y			; | Use timer to determine if vine should be processed
		BCS -						; |
	+	STA $00						; |
		CPY $00 : BNE ..Next				;/
		LDA.w !VineDestroyXHi,y				;\ Check if register is active
		CMP #$FF : BNE ..ProcessVine			;/

		..Next
		DEY : BPL ..Loop				; > Next reg

		..Return
		PLB						; > Restore bank
		RTL						; > Return

		..ProcessVine
		PEI ($98)					;\ Push block values
		PEI ($9A)					;/
		XBA						;\
		LDA.w !VineDestroyYLo,y : STA $00		; |
		LDA.w !VineDestroyYHi,y : STA $01		; |
		LDA.w !VineDestroyXLo,y				; |
		PHY						; | Read map16 tile
		PHP						; |
		REP #$10					; |
		TAX						; |
		LDY $00						; |
		JSL $138018					;/
		PLP						;\ Restore stuff
		PLY						;/
		LDA [$05]					;\
		CMP.w !VineDestroyPage				; | Return if wrong page
		BEQ $03						; |
	-	JMP ..Invalid					;/
		DEC $07						;\
		LDA [$05]					; | Get actual number, not acts like setting
		BPL -						;/

		PHA						; > Preserve map16 number (lo byte)
		LDA.w !VineDestroyXLo,y : STA $9A		;\
		LDA.w !VineDestroyXHi,y : STA $9B		; | Set up tile destruction
		LDA.w !VineDestroyYLo,y : STA $98		; |
		LDA.w !VineDestroyYHi,y : STA $99		;/
		JSR .DestroyTile				; > Destroy tile
		TYX						;\
		LDA #$01 : STA $0077C0,x			; |
		LDA $9A : STA $0077C8,x				; | Spawn smoke puff
		LDA $9B : STA.l !SmokeXHi,x			; |
		LDA $98 : STA $0077C4,x				; |
		LDA $99 : STA.l !SmokeYHi,x			; |
		LDA #$01 : STA.l !SmokeHack,x			; |
		LDA #$13 : STA $0077CC,x			;/
		LDA #$01 : STA.l !SPC1
		PLA						; > Restore map16 number (lo byte)
		BRA +
	-	JMP ..Horz
	--	JMP ..Vert
	+	CMP.b #!VineDestroyHorzTile1 : BEQ -		;\
		CMP.b #!VineDestroyHorzTile2 : BEQ -		; |
		CMP.b #!VineDestroyHorzTile3 : BEQ -		; |
		CMP.b #!VineDestroyHorzTile4 : BEQ -		; |
		CMP.b #!VineDestroyHorzTile5 : BEQ -		; |
		CMP.b #!VineDestroyHorzTile6 : BEQ -		; |
		CMP.b #!VineDestroyHorzTile7 : BEQ -		; |
		CMP.b #!VineDestroyHorzTile8 : BEQ -		; |
		CMP.b #!VineDestroyHorzTile9 : BEQ -		; |
		CMP.b #!VineDestroyHorzTile10 : BEQ ..Horz	; |
		CMP.b #!VineDestroyHorzTile11 : BEQ ..Horz	; |
		CMP.b #!VineDestroyHorzTile12 : BEQ ..Horz	; |
		CMP.b #!VineDestroyVertTile1 : BEQ --		; | Check tile type
		CMP.b #!VineDestroyVertTile2 : BEQ --		; |
		CMP.b #!VineDestroyVertTile3 : BEQ ..Vert	; |
		CMP.b #!VineDestroyVertTile4 : BEQ ..Vert	; |
		CMP.b #!VineDestroyVertTile5 : BEQ ..Vert	; |
		CMP.b #!VineDestroyVertTile6 : BEQ ..Vert	; |
		CMP.b #!VineDestroyVertTile7 : BEQ ..Vert	; |
		CMP.b #!VineDestroyVertTile8 : BEQ ..Vert	; |
		CMP.b #!VineDestroyVertTile9 : BEQ ..Vert	; |
		CMP.b #!VineDestroyVertTile10 : BEQ ..Vert	; |
		CMP.b #!VineDestroyVertTile11 : BEQ ..Vert	; |
		CMP.b #!VineDestroyVertTile12 : BEQ ..Vert	; |
		CMP.b #!VineDestroyCornerUL1 : BEQ ..UL		; |
		CMP.b #!VineDestroyCornerUL2 : BEQ ..UL		; |
		CMP.b #!VineDestroyCornerUR1 : BEQ ..UR		; |
		CMP.b #!VineDestroyCornerUR2 : BEQ ..UR		; |
		CMP.b #!VineDestroyCornerDL1 : BEQ ..DL		; |
		CMP.b #!VineDestroyCornerDL2 : BEQ ..DL		; |
		CMP.b #!VineDestroyCornerDR1 : BEQ ..DR		; |
		CMP.b #!VineDestroyCornerDR2 : BEQ ..DR		;/

		..Invalid
		LDA #$FF					;\
		STA.w !VineDestroyXLo,y				; |
		STA.w !VineDestroyXHi,y				; | Clear regs if invalid tile
		STA.w !VineDestroyYLo,y				; |
		STA.w !VineDestroyYHi,y				; |
		STA.w !VineDestroyDirection,y			;/

		..Back
		REP #$20					;\
		PLA : STA $9A					; | Restore block values
		PLA : STA $98					; |
		SEP #$20					;/
		PLB						;\ Return since only one vine is processed in a frame
		RTL						;/

		..Horz
		JSR .HorzExtra					; > Destroy extra tiles
		LDA.w !VineDestroyDirection,y			;\
		TAX						; |
	..Horz2	LDA.l .MovementXLo,x				; |
		CLC : ADC.w !VineDestroyXLo,y			; | Move horizontally
		STA.w !VineDestroyXLo,y				; |
		LDA.l .MovementXHi,x				; |
		ADC.w !VineDestroyXHi,y				; |
		STA.w !VineDestroyXHi,y				;/
		BRA ..Back					; > Loop

		..Vert
		JSR .VertExtra					; > Destroy extra tiles
		LDA.w !VineDestroyDirection,y			;\
		TAX						; |
	..Vert2	LDA.l .MovementYLo,x				; |
		CLC : ADC.w !VineDestroyYLo,y			; | Move vertically
		STA.w !VineDestroyYLo,y				; |
		LDA.l .MovementYHi,x				; |
		ADC.w !VineDestroyYHi,y				; |
		STA.w !VineDestroyYHi,y				;/
		BRA ..Back					; > Loop

		..UL
		PHY						;\
		LDY #$03					; | Erase extra tiles
		PEA ..Corner-1					; |
		PEA .CornerExtra_UL-1				; |
		BRA .CornerExtra				;/

		..UR
		PHY						;\
		LDY #$03					; | Erase extra tiles
		PEA ..Corner-1					; |
		PEA .CornerExtra_UR-1				; |
		BRA .CornerExtra				;/

		..DL
		PHY						;\
		LDY #$03					; | Erase extra tiles
		PEA ..Corner-1					; |
		PEA .CornerExtra_DL-1				; |
		BRA .CornerExtra				;/

		..DR
		PHY						;\
		LDY #$03					; | Erase extra tiles
		PEA ..Corner-1					; |
		PEA .CornerExtra_DR-1				; |
		BRA .CornerExtra				;/

		..Corner
		PLY
		CLC : ADC.w !VineDestroyDirection,y		;\
		TAX						; |
		LDA.l .CornerUL,x				; |
		STA.w !VineDestroyDirection,y			; | Change direction then move
		TAX						; |
		AND #$02 : BEQ ..Horz2				; |
		BRA ..Vert2					;/


		.DestroyTile
		PHY						;\
		PHP						; |
		SEP #$20					; |
		LDA #$01 : STA $9C				; |
		PHB : PHK : PLB					; | Destroy tile at $9A;$98
		JSL $00BEB0					; | (complete with wrappers for most important regs)
		PLB						; |
		PLP						; |
		PLY						;/
		RTS						; > Return


	.VertExtra
		PHP
		REP #$20
		LDA $9A
		SEC : SBC #$0010
		STA $9A
		JSR .DestroyTile
		LDA $9A
		CLC : ADC #$0020
		STA $9A
		PLP
		BRA .DestroyTile

	.HorzExtra
		PHP
		REP #$20
		LDA $98
		SEC : SBC #$0010
		STA $98
		JSR .DestroyTile
		LDA $98
		CLC : ADC #$0020
		STA $98
		PLP
		BRA .DestroyTile


	.CornerExtra
		REP #$20
		RTS

	..DR	LDA $9A
		SEC : SBC #$0010
		STA $9A
		JSR .DestroyTile
		DEY : BEQ ..ReturnUL
	..DL	LDA $98
		SEC : SBC #$0010
		STA $98
		JSR .DestroyTile
		DEY : BEQ ..ReturnUR
	..UL	LDA $9A
		CLC : ADC #$0010
		STA $9A
		JSR .DestroyTile
		DEY : BEQ ..ReturnDR
	..UR	LDA $98
		CLC : ADC #$0010
		STA $98
		JSR .DestroyTile
		DEY : BNE ..DR

		..ReturnDL
		SEP #$20
		LDA #$08
		RTS

		..ReturnUL
		SEP #$20
		LDA #$00
		RTS

		..ReturnUR
		SEP #$20
		LDA #$04
		RTS

		..ReturnDR
		SEP #$20
		LDA #$0C
		RTS



; Indexed by direcion: right, left, down, up
; 0 = right
; 1 = left
; 2 = down
; 3 = up

.MovementXLo	db $10,$F0
.MovementYLo	db $00,$00
		db $10,$F0

.MovementXHi	db $00,$FF
.MovementYHi	db $00,$00
		db $00,$FF

.CornerUL	db $03,$01,$01,$03
.CornerUR	db $00,$03,$00,$03
.CornerDL	db $02,$01,$02,$01
.CornerDR	db $00,$02,$02,$00





; Write X coordinate to $0C and Y coordinate to $0E

LightningBolt:
		PHP
		REP #$20
		LDA !Level+3
		AND #$00FF
		CMP #$0001 : BNE .BigBolt

		.WarningBolt
		LDA #$0040 : STA $07
		LDA $0C
		STA $04
		STA $09
		LDA $1C
		SEC : SBC #$0010
		AND #$FFF0
		SEP #$20
		STA $05
		XBA : STA $0B
		JMP .DrawLightning

		.BigBolt
		LDA !VineDestroyTimer+$00	;\
		AND #$00FF : BEQ .Init		; |
		LDA !VineDestroyTimer+$01	; |
		STA $05				; |
		STA $0A				; |
		LDA !Level+4			; | Only calculate the shape of the bolt during the first frame
		SEP #$20			; |
		STA $04				; |
		XBA : STA $0A			; |
		LDA !VineDestroyTimer+$03	; |
		STA $07				; |
		JMP .Main			;/

		.Init
		LDA $1C				;\
		AND #$FFF0			; | Start 2 tiles above screen
		SEC : SBC #$0020		; |
		STA $0E				;/
		LDA $0C				;\
		CLC : ADC #$0008		; | Look at tile from middle
		STA $0C				;/
	-	REP #$10
		SEP #$20
		LDX $0C
		LDY $0E
		JSL $138018
		CMP #$0002 : BEQ .WaterImpact
		CMP #$0003 : BEQ .WaterImpact
		CMP #$0100 : BCC .NextTile
		CMP #$016A : BCC .TileImpact

		.NextTile
		LDA $1C				;\
		CLC : ADC #$00D0		; | Max height = 0xF0 px
		STA $00				;/
		LDA $0E				;\
		CLC : ADC #$0010		; |
		BMI +				; |
		CMP #$0170 : BCS .WaterImpact	; |
		CMP $00 : BCS .TileImpact	; | Enforce a max height even if it doesn't hit anything
	+	STA $0E				; |
		BRA -				;/

		.WaterImpact
		LDA #$0001
		STA !VineDestroyPage

		.TileImpact
		LDA $0C				;\
		SEC : SBC #$0008		; | Restore Xpos
		STA $0C				;/
		LDA $1C				;\
		SEC : SBC #$0020		; |
		AND #$FFF0			; | Lo byte of Y in $05, hi byte in $0B (always starts at screen top)
		STA $05				; |
		STA $0A				;/
		LDA $0E				;\
		SEC : SBC $05			; | Height in $07
		BEQ $02 : BPL $03		; |
		JMP .WarningBolt		; | > Go to .WarningBolt if zero or negative
		STA $07				;/
		LDA $0C				;\
		SEP #$20			; | Lo byte of X in $04, hi byte in $0A
		STA $04				; |
		XBA : STA $0A			;/
		LDA #$10 : STA $06		; > Width in $06

		LDX #$03			;\
	-	LDA $7699,x : BEQ +		; |
		LDA $76A1,x : STA $01		; |
		LDA $76A5,x : STA $00		; |
		LDA $76A9,x : STA $09		; |
		LDA $76AD,x : STA $08		; | See if lightning hits a bounce sprite
		LDA #$10			; |
		STA $02				; |
		STA $03				; |
		JSL !Contact16			; |
		BCC +				;/
		LDA $09 : STA $02		;\
		LDA $0B : XBA			; |
		LDA $05				; |
		REP #$20			; |
		SEC : SBC $01			; | Update lightning hitbox
		EOR #$FFFF : INC A		; |
		SEP #$20			; |
		STA $07				;/
	+	DEX : BPL -			; > Check all bounce sprites

		LDA !Translevel			;\ Ignore sprites on Tower of Storms
		CMP #$10 : BEQ ++		;/
		LDX #$0F			;\
	-	LDA $3230,x			; |
		CMP #$08 : BCC +		; |
		CMP #$0B : BCS +		; |
		JSL $03B6E5			; | See if lightning hits a sprite
		JSL !Contact16			; |
		BCS .SpriteImpact		; |
	+	DEX : BPL -			;/
	++	SEC : JSL !PlayerClipping	;\
		LDY #$00			; | See if lightning hits a player
		LSR A : BCS .P1Impact		; |
		LSR A : BCS .P2Impact		;/
		BRA .Electrocute		; > Either way, draw lightning

		.SpriteImpact
		LDA $3430,x : BNE +		;\ Clear water flag unless sprite is in water
		LDA #$00 : STA !VineDestroyPage	;/
	+	LDA $3210,x : STA $0E		;\
		LDA $3240,x			; | Update coordinates for sprite impact
		BRA .UpdateImpact		;/

		.P2Impact
		LDY #$80			; > index for player 2

		.P1Impact
		LDA !P2Water			;\
		AND #$40 : BNE +		; | Clear water flag unless player is in water
		LDA #$00 : STA !VineDestroyPage	;/
	+	LDA !P2YPosLo-$80,y : STA $0E	;\ Update coordinates for player impact
		LDA !P2YPosHi-$80,y		;/

		.UpdateImpact
		STA $0F				;\
		LDA $0B : XBA			; |
		LDA $05				; |
		REP #$20			; | Update height of lightning bolt so it'll end on impact
		SEC : SBC $0E			; |
		EOR #$FFFF : INC A		; |
		SEP #$20			; |
		CLC : ADC #$10			; |
		STA $07				;/
		CPX #$FF : BEQ .Electrocute	; > Try finding a higher target unless all sprites are checked
		DEX : BPL -			; > Loop

		.Electrocute
		LDA !VineDestroyTimer+$00	;\
		BNE .Main			; |
		LDA $05				; |
		STA !VineDestroyTimer+$01	; |
		LDA $0B				; | Backup Ypos and height
		STA !VineDestroyTimer+$02	; |
		LDA $07				; |
		STA !VineDestroyTimer+$03	; |
		LDA #$01			; |
		STA !VineDestroyTimer+$00	;/

		.Main
		LDA $07				;\
		CLC : ADC #$08			; | The hitbox needs to actually reach the ground...
		STA $07				;/

		JSR .BrickBreak			; > Break bricks

		LDX #$0F
	-	LDA $3230,x
		CMP #$08 : BCC +
		CMP #$0C : BCS +
		LDA $3460,x			;\
		AND #$30			; |
		CMP #$30 : BEQ +		; | Lightning counts as both fire and cape
		LDA $3470,x			; |
		AND #$02 : BNE +		;/
		LDA $3430,x			;\
		AND !VineDestroyPage		; | If water contact overlaps, then ZAP!
		BNE ++				;/
		JSL $03B6E5
		JSL !Contact16
		BCC +
	++	LDA #$04 : STA $3230,x
		LDA #$1F : STA $32D0,x
	+	DEX : BPL -

		LDA !VineDestroyPage		;\
		BEQ +				; |
		LDA !P2Water			; |
		AND #$40			; |
		ASL A				; |
		STA $00				; | Zap players in water
		LDA !P2Water-$80		; |
		AND #$40			; |
		ORA $00				; |
		CLC : ROL #3			; |
		JSL !HurtPlayers		;/

	+	SEC : JSL !PlayerClipping
		BCC .DrawLightning
		JSL !HurtPlayers

		.DrawLightning
		LDA !VineDestroyPage		;\ Horizontal electricity upon water contact
		BEQ $03 : JSR .WaterShock	;/
		LDA $05 : STA $02		;\
		LDA $0B : STA $03		; | Set up OAM calculations
		LDA $0A : XBA			;/
		LDA $04				;\
		REP #$20			; |
		SEC : SBC $1A			; |
		STA $00				; |
		CMP #$0100 : BCC .GoodX		; | If X coordinate is invalid, don't draw anything
		CMP #$FFF0 : BCS .GoodX		; |
		PLP				; |
		RTS				;/

	.GoodX	LDA $02
		SEC : SBC $1C
		SEC : SBC #$0010
		STA $02
		SEP #$20
		LDX !OAMindex
		LDY #$00
		LDA $07
		CLC : ADC #$08
		AND #$F0
		LSR #2
		CLC : ADC !OAMindex
		STA $08				; > End index
		STX $09				; > Start index

	-	LDA $00 : STA !OAM+$00,x
		REP #$20
		LDA $02
		CLC : ADC #$0010
		STA $02
		CMP #$00E8 : BCC .GoodY
		CMP #$FFF0 : BCS .GoodY
		LDA #$00F0
	.GoodY	STA !OAM+$01,x
		LDA .Tilemap,y
		AND #$00FF
		ORA #$3F00
		STA !OAM+$02,x
		SEP #$20

		PHX
		TXA
		LSR #2
		TAX
		LDA $01
		AND #$01
		ORA #$02 : STA !OAMhi,x
		PLX

		INX #4
		INY
		CPY #$0E : BEQ +
		CPX $08 : BNE -

	+	LDA $08					;\
		STA !OAMindex				;/
		LDA #$8A : STA !OAM-$06,x		;\ Set tip
		LDA #$8C : STA !OAM-$02,x		;/

		LDX $09
		REP #$20
		LDA !OAM+$00,x				;\ Totally done dude
		BMI .Return				;/

		LDX $08					;\
		LDY #$01				; |
	-	SEC : SBC #$1000			; |
		STA !OAM+$00,x				; |
		LDA .Tilemap,y				; |
		AND #$00FF				; |
		ORA #$3F00				; |
		STA !OAM+$02,x				; |
		SEP #$20				; |
		PHX					; | Fill out empty top area
		TXA					; |
		LSR #2					; |
		TAX					; |
		LDA $01					; |
		AND #$01				; |
		ORA #$02 : STA !OAMhi,x			; |
		PLX					; |
		REP #$20				; |
		INX #4					; |
		INY					; |
		LDA !OAM-$04,x				; |
		BPL -					; |
		STX !OAMindex				;/

	.Return	PLP
		RTS

.Tilemap	db $86,$88,$86,$88
		db $86,$88,$86,$88
		db $86,$88,$86,$88
		db $86,$88,$86,$88


.WaterShock	PHP
		REP #$30
		LDA #$3F80
		STA !OAM+$02
		STA !OAM+$06
		STA !OAM+$0A
		STA !OAM+$0E
		STA !OAM+$12
		STA !OAM+$16
		STA !OAM+$1A
		STA !OAM+$1E

		LDA $14
		AND #$000C
		ASL #3
		CLC : ADC $1A
		AND #$003F
		EOR #$003F
		STA $00

		LDA #$0168
		SEC : SBC $1C
		BMI .Nope
		CMP #$00E8 : BCS .Nope
		AND #$00FF
		XBA
		ORA $00
		LDX #$0018
	-	STA !OAM+$04,x
		CLC : ADC #$0010
		STA !OAM+$00,x
		CLC : ADC #$0030
		DEX #8
		BPL -

		LDA #$0202
		LDX #$0006
	-	STA !OAMhi,x
		DEX #2
		BPL -
		SEP #$20
		LDA #$20 : STA !OAMindex
		LDA $00
		CMP #$21 : BCC .Nope
		AND #$0F : BEQ .Nope
		ORA #$F0
		STA !OAM+$20
		LDA !OAM+$1D : STA !OAM+$21
		LDA !OAM+$1E : STA !OAM+$22
		LDA !OAM+$1F : STA !OAM+$23
		LDA #$03 : STA !OAMhi+$08
		LDA #$24 : STA !OAMindex
		.Nope

		PLP
		RTS


.BrickBreak	PEI ($04)
		PEI ($06)
		PEI ($0A)

		REP #$10
		LDA $04
		CLC : ADC #$08
		STA $04
		LDA $0A
		ADC #$00
		XBA
		LDA $04
		AND #$F0
		TAX
		STX $9A						; > Block X
		LDA $05
		CLC : ADC $07
		STA $05
		LDA $0B
		ADC #$00
		XBA
		LDA $05
		AND #$F0
		TAY
		STY $98						; > Block Y
		JSL $138018
		CMP #$011E : BNE +

		PHB						;\
		PHP						; |
		SEP #$20					; |
		LDA #$02					; |
		PHA : PLB					; |
		LDA #$01 : STA $9C				; | Shatter brick
		JSL $00BEB0					; |
		LDA #$00					; |
		JSL $028663					; |
		PLP						; |
		PLB						;/

	+	PLA : STA $0A
		PLA : STA $06
		PLA : STA $04
		SEP #$20
		RTS

; To call:
; REP #$20
; LDA.w #.TalkBox
; JSR TalkOnce
;
; Data format:
; 00: ID (bit in RAM table, min 0 max 15) times 2
; 01: Message number
; 02-03: Xcoord
; 04-05: Ycoord
; 06: Width
; 07: Height
TalkOnce:
		STA $00
		LDA ($00)
		TAY			; ID in Y
		XBA : TAX		; Message number in X
		LDA.w .Table,y		;\
		AND $6DF5		; | Only trigger message once
		BNE .Return		;/

		PHY			; ID on stack
		INC $00
		INC $00
		LDA ($00)
		STA $04			; Xlo in $04
		STA $09			; Xhi in $0A
		INC $00
		INC $00
		LDA ($00)
		STA $05			; Ylo in $05
		XBA : STA $0B		; Yhi in $0B
		INC $00
		INC $00
		LDA ($00)
		STA $06			; Dimensions in $06-$07
		INC $00
		INC $00
		SEP #$21		; 8-bit, set carry
		JSL !PlayerClipping	; Check player contact
		BCC .ReturnP
		STZ $00			;\
		LSR A : BCC +		; |
		PHA			; |
		LDA !P2Blocked-$80	; |
		AND #$04		; |
		TSB $00			; | Only trigger on a player that's on the ground
		PLA			; |
	+	LSR A : BCC +		; |
		LDA !P2Blocked		; |
		AND #$04		; |
		TSB $00			; |
	+	LDA $00 : BEQ .ReturnP	;/
		STX !MsgTrigger		; Trigger message
		PLY
		REP #$20
		LDA.w .Table,y		;\ Mark message as triggered
		TSB $6DF5		;/
		RTS

		.ReturnP
		REP #$20
		PLY

		.Return
		RTS
		

		.Table
		dw $0001,$0002,$0004,$0008
		dw $0010,$0020,$0040,$0080
		dw $0100,$0200,$0400,$0800
		dw $1000,$2000,$4000,$8000


; regs:
; $00		- 0 if inactive, 1 if active
; $01		- symbol of first input (set highest bit to mark as missed)
; $02		- timer for first input, determines height
; $03-$10	- identical to $01-$02 but for the rest of the symbols
; $11		- number of misses
; $12		- P1 pose
; $13		- P2 pose




; !Level+2 holds AND value for $14. If $14&!Level+2 == 0, then !Level+3 is added to $1A (16-bit)
ScreenGrind:
		STZ !EnableHScroll
		LDA !Level+2 : BEQ .Go			; If frequency = 0, always scroll
		AND $14 : BNE .Return			; Otherwise, only scroll when $14&!Level+2 == 0

	.Go	LDA.b #.HDMA : STA !HDMAptr+0
		LDA.b #.HDMA>>8 : STA !HDMAptr+1
		LDA.b #.HDMA>>16 : STA !HDMAptr+2
	.Return	RTS

		.HDMA
		PHP
		REP #$20
		LDA #$0000 : STA !HDMAptr+0
		LDA $1A
		CLC : ADC !Level+3
		STA $1A
		INC !EnableHScroll
		PLP
		RTL



; Speed platform eats up !Level+2, 3 and 4.
; 2+3 are used to hold the scroll value, 4 is the value to add to 2+3 every frame.
SpeedPlatform:
		LDA.b #.HDMA : STA !HDMAptr+0
		LDA.b #.HDMA>>8 : STA !HDMAptr+1
		LDA.b #.HDMA>>16 : STA !HDMAptr+2
		RTS

		.HDMA
		PHP
		REP #$20
		LDA !Level+4
		AND #$00FF
		CMP #$0080
		BCC $03 : ORA #$FF00
		CLC : ADC !Level+2
		STA !Level+2
		ASL A
		CLC : ADC $1A
		LSR A
		SEC : SBC #$0100
		STA $1E

		LDA !BossData+0
		AND #$007F
		CMP #$0006 : BCC ..Process
		PLP
		RTL


		..Process
		LDA $14					;\
		ASL #2					; |
		AND #$00FF				; | Hide top 2 tile layers
		STA $0201				; |
		LDA #$0020 : STA $0203			;/
		LDA $1A : STA $0206			;\
		LDA !ShakeTimer				; |
		AND #$00FF : BEQ +			; |
		AND #$0003				; |
		BNE $04 : DEC #2 : BRA +		; | Put main chunk in the right place
		CMP #$0002 : BEQ +			; |
		LDA #$0000				; |
	+	CLC : ADC $1C				; |
		STA $0208				;/
		LDA #$0D07 : STA $4320			;\
		LDA #$0200 : STA $4322			; |
		SEP #$20				; | Set up HDMA
		STZ $4324				; |
		LDA #$04 : TSB $6D9F			;/
		LDA #$22 : STA $0200			;\
		LDA #$01 : STA $0205			; | Scanlines
		STZ $020A				;/

		LDA !BossData+0				;\
		AND #$7F				; | Check for crash
		CMP #$05 : BCC ..Return			;/

		LDA #$B6				;\
		SEC : SBC !BossData+1			; |
		LSR A					; | Scanline counts for main chunk
		STA $0205				; |
		BCC $01 : INC A				; |
		STA $020A				;/
		LDA #$01 : STA $020F			;\ Rest of the scanlines
		STZ $0214				;/
		REP #$20				;\
		LDA $0206 : STA $020B			; | Split main chunk in 2 pieces
		LDA $0208 : STA $020D			;/
		LDA $0201 : STA $0210			; > Horizontal position of crash chunk
		LDA !BossData+1				;\
		AND #$00FF				; | Vertical position of crash chunk
		CLC : ADC #$FF27			; |
		STA $0212				;/

		..Return
		PLP
		RTL


	; Normal:
	; 0x22 scanlines of value 0x20 (hides top)
	; rest is just $1C (+ shake value)

	; Rising:
	; 0x22 scanlines of value 0x20 (hides top)
	; 0xB6 - (!BossData+1) scanlines of $1C (2 entries)
	; rest is (!BossData+1) + 0xFF50





DANCE:

		LDA !VineDestroy+$00 : BNE .Go			;\ See if it should run
		RTS						;/

	.Go	LDA !VineDestroy+$12 : STA !P2ExternalAnim-$80
		LDA !VineDestroy+$13 : STA !P2ExternalAnim
		LDA #$02
		STA !P2ExternalAnimTimer-$80
		STA !P2ExternalAnimTimer

		LDA #$02					;\
		STA !P2Stasis-$80				; | Players can't move normally during dance
		STA !P2Stasis					;/
		LDX #$0E					;\
	-	STZ $00,x					; | Clear $00, $02, $04, $06, $08, $0A, $0C, and $0E
		DEX #2						; |
		BPL -						;/
		PHB
		LDA #$40
		PHA : PLB
		LDX #$0E
	.Next	LDA.w !VineDestroy+$01,x
		BMI .NoInput
		BEQ .Skip
		LDA.w !VineDestroy+$02,x			;\ No input for first second to prevent mash fail
		CMP #$40 : BCC .NoInput				;/

		STZ $00						;\
		PHX						; |
	-	DEX #2 : BMI +					; |
		LDA.w !VineDestroy+$01,x			; |
		BEQ -						; | See if another symbol should be first
		BMI -						; |
		INC $00						; |
		BRA -						; |
	+	PLX						;/
		LDA $00 : BNE .NoInput				; > Only allow input on one symbol at a time
		LDA.w !VineDestroy+$02,x			;\
		CMP #$90 : BCC +				; |
	-	LDA.w !VineDestroy+$01,x			; | No input past 0xD0
		ORA #$80					; |
		STA.w !VineDestroy+$01,x			;/
		LDA #$2A : STA.l !SPC4				; Wrong! SFX
		INC.w !VineDestroy+$11				; Add one miss

		BRA .NoInput					; Branch
	+	CMP #$80 : BCC +				; > Good input between 0x80 and 0x90
		LDA.l $006DA6					;\
		ORA.l $006DA7					; |
		PHP						; | Look for correct input
		AND.w !VineDestroy+$01,x			; |
		BNE .CorrectInput				;/
		PLP						;\
		BEQ .NoInput					; | If the wrong button is pushed, mark a failure
		BRA -						;/

		.CorrectInput
		PLP						; Get this off the stack
		JSR .Pose					; Get the pose yo
		STZ.w !VineDestroy+$01,x			; Remove input
		LDA #$29 : STA.l !SPC4				; Correct! SFX
		BRA .NoInput					; Branch
	+	LDA.l $006DA6					;\
		ORA.l $006DA7					; | Look for early button presses
		BNE -						;/

		.NoInput
		LDA.w !VineDestroy+$01,x : STA $00,x		; Tile setting in scratch RAM
		LDA.w !VineDestroy+$02,x : STA $01,x		; Timer in scratch RAM
		INC A						; Increment
		CMP #$A8 : BCC .Write				;\
		STZ.w !VineDestroy+$01,x			; | Kill this input after px 0xA8
		BRA .Skip					;/

		.Write
		STA.w !VineDestroy+$02,x			; Update timer


		.Skip
		DEX #2 : BMI $03 : JMP .Next			; Loop
		PLB						; Restore bank

		.DrawSymbols
		LDX #$0E					;\ Indexes
		LDY !OAMindex					;/

	-	LDA $00,x : BEQ ..Next				; Look for symbol
		AND #$7F					;\
		CMP #$04 : BCC +				; |
		LDA #$02 : BRA $02				; | Tile number
	+	LDA #$00					; |
		STA !OAM+$002,y					;/
		LDA $01,x					;\
		CMP #$20					; | Y coordinate
		BCS $02 : LDA #$20				; |
		STA !OAM+$001,y					;/
		TXA						;\
		STA $0F						; |
		ASL #3						; | X coordinate
		CLC : ADC $0F					; | (includes "O" symbol)
		CLC : ADC #$38					; |
		STA !OAM+$000,y					; |
		STA !OAM+$004,y					;/
		PHX						;\
		LDA $00,x					; |
		AND #$7F					; |
		TAX						; |
		LDA.w ..PropTable-1,x				; | Prop
		PLX						; |
		BIT $00,x					; |
		BPL $02 : INC #2				; |
		STA !OAM+$003,y					;/
		LDA #$88 : STA !OAM+$005,y			;\
		LDA #$06 : STA !OAM+$006,y			; | "O" symbol
		LDA #$37 : STA !OAM+$007,y			;/
		PHY						;\
		TYA						; |
		LSR #2						; |
		TAY						; | Tile size
		LDA #$02					; |
		STA !OAMhi,y					; |
		STA !OAMhi+1,y					;/
		PLA						;\
		CLC : ADC #$08					; | Increment index
		TAY						;/
	..Next	DEX #2 : BPL -					; Loop
		STY !OAMindex					; Store new index
		RTS


	..PropTable
		db $7D,$3D,$FF,$BD
		db $FF,$FF,$FF,$3D

	.Pose
		PHX
		LDA.w !VineDestroy+$01,x
		TAX
		LDA.l !P2Character-$80
		BEQ .Mario
		CMP #$02 : BEQ .Kadaal
		CMP #$03 : BEQ .Leeway
		PLX
		RTS

		.Mario
	-	LDA.l .MarioPose-1,x
		CMP.w !VineDestroy+$12 : BNE +
		INX #5
		BRA -

		.Kadaal
	-	LDA.l .KadaalPose-1,x
		CMP.w !VineDestroy+$12 : BNE +
		INX #5
		BRA -

		.Leeway
	-	LDA.l .LeewayPose-1,x
		CMP.w !VineDestroy+$12 : BNE +
		INX #5
		BRA -

	+	STA.w !VineDestroy+$12
		PLX
		RTS



	.MarioPose
		db $0E,$23,$FF,$38		; R1, L1, XX, D1
		db $FF,$1D,$32,$26		; XX, R2, L2, U1
		db $39,$FF,$FF,$FF		; D2, XX, XX, XX
		db $1E				; U2

	.KadaalPose
		db $12,$28,$FF,$0C		; R1, L1, XX, D1
		db $FF,$13,$2A,$19		; XX, R2, L2, U1
		db $0D,$FF,$FF,$FF		; D2, XX, XX, XX
		db $13				; U2

	.LeewayPose
		db $0F,$3D,$FF,$24		; R1, L1, XX, D1
		db $FF,$10,$11,$42		; XX, R2, L2, U1
		db $26,$FF,$FF,$FF		; D2, XX, XX, XX
		db $43				; U2

; Mario poses:
; right:	0E
; left:		23
; down:		38
; up:		26




; LDX #$XX (index*6)
; JSR WARP_BOX
WARP_BOX:
		REP #$20
		LDA .Table+0,x : STA $04	; Xlo in $04
		STA $09				; Xhi in $0A
		LDA .Table+2,x : STA $05	; Ylo in $05
		XBA : STA $0B			; Yhi in $0B
		LDA .Table+4,x : STA $06	; Dimensions in $06-$07
		SEP #$20
		SEC : JSL !PlayerClipping
		BCS EXIT_Exit+2			; Warp if player is touching box
		RTS


		.Table
		dw $0170,$1440 : db $50,$20	; index 00
		dw $01F6,$0B90 : db $0A,$20	; index 06
		dw $0000,$0290 : db $0A,$20	; index 0C


EXIT:
		.Right
		LDX !P2Status-$80 : BNE +
		BIT !P2XPosLo-$80 : BMI +
		CMP !P2XPosLo-$80
		BEQ .Exit
		BCC .Exit
	+	LDX !P2Status : BNE .Return
		BIT !P2XPosLo : BMI .Return
		CMP !P2XPosLo
		BEQ .Exit
		BCC .Exit
		.Return
		SEP #$20
		RTS

		.Left
		LDX !P2Status-$80 : BNE +
		CMP !P2XPosLo-$80 : BCS .Exit
	+	LDX !P2Status : BNE .Return
		CMP !P2XPosLo : BCS .Exit
		SEP #$20
		RTS

		.Exit					; Placed here so the WARP_BOX routine can reach
		SEP #$20
		LDA #$06 : STA $71
		STZ $88
		STZ $89
		RTS

		.Down
		LDX !P2Status-$80 : BNE +
		BIT !P2YPosLo-$80 : BMI +
		CMP !P2YPosLo-$80
		BEQ .Exit
		BCC .Exit
	+	LDX !P2Status : BNE .Return
		BIT !P2YPosLo : BMI .Return
		CMP !P2YPosLo
		BEQ .Exit
		BCC .Exit
		SEP #$20
		RTS

		.Up
		LDX !P2Status-$80 : BNE +
		CMP !P2YPosLo-$80
		BCS .Exit
	+	LDX !P2Status : BNE .Return
		CMP !P2YPosLo
		BCS .Exit
		SEP #$20
		RTS


; Same as the normal one, except it fades the music upon exit
EXIT_FADE:
		.Right
		JSR EXIT_Right
		BRA .Exit

		.Left
		JSR EXIT_Left
		BRA .Exit

		.Down
		JSR EXIT_Down
		BRA .Exit

		.Up
		JSR EXIT_Up

		.Exit
		LDA $71
		CMP #$06 : BNE .Return
		LDA #$80 : STA !SPC3

		.Return
		RTS



END:
		.Right
		LDX !P2Status-$80 : BNE +
		CMP !P2XPosLo-$80
		BEQ .End
		BCC .End
	+	LDX !P2Status : BNE +
		CMP !P2XPosLo
		BEQ .End
		BCC .End
	+	SEP #$20
		RTS

		.Left
		LDX !P2Status-$80 : BNE +
		CMP !P2XPosLo-$80
		BCS .End
	+	LDX !P2Status : BNE +
		CMP !P2XPosLo
		BCS .End
	+	SEP #$20
		RTS

		.Down
		LDX !P2Status-$80 : BNE +
		CMP !P2YPosLo-$80
		BEQ .End
		BCC .End
	+	LDX !P2Status : BNE +
		CMP !P2YPosLo
		BEQ .End
		BCC .End
	+	SEP #$20
		RTS

		.Up
		LDX !P2Status-$80 : BNE +
		CMP !P2YPosLo-$80
		BCS .End
	+	LDX !P2Status : BNE +
		CMP !P2YPosLo
		BCS .End
	+	SEP #$20
		RTS

		.End
		SEP #$20
		LDA #$02
		STA $73CE
		LDA #$80				;\ Fade music
		STA !SPC3				;/
		STA $6DD5				; Set exit
		LDX !Translevel				;\
		LDA !LevelTable,x : BMI +		; |
		INC $7F2E				; > You've now beaten one more level (only once/level)
		ORA #$80				; | Set clear, remove midway
	+	AND.b #$40^$FF				; > Clear checkpoint
		STA !LevelTable,x			;/
		LDA #$00				;\
		STA !MidwayLo,x				; | clear extra checkpoint data
		STA !MidwayHi,x				; |
		STZ $73CE				;/
		LDA #$0B : STA !GameMode

		REP #$10				; unlock level
		LDX !Level
		LDA LEVEL_Unlock,x
		SEP #$10
		TAX
		LDA !LevelTable,x
		ORA #$01
		STA !LevelTable,x

		RTS


; --HDMA tables--

HDMA_Evening:

	.Red
	db $0E,$31
	db $0E,$32
	db $0E,$33
	db $0E,$34
	db $0E,$35
	db $0E,$36
	db $0E,$37
	db $0E,$38
	db $0E,$39
	db $0E,$3A
	db $0E,$3B
	db $0E,$3C
	db $0E,$3D
	db $1F,$3E
	db $1F,$3F
	db $00

	.Green
	db $15,$40
	db $15,$41
	db $15,$42
	db $15,$43
	db $15,$44
	db $15,$45
	db $15,$46
	db $15,$47
	db $15,$48
	db $15,$49
	db $15,$4A
	db $00

	.Blue
	db $1A,$88
	db $1A,$87
	db $1A,$86
	db $1A,$85
	db $1A,$84
	db $1A,$83
	db $1A,$82
	db $1A,$81
	db $1A,$80
	db $00

HDMA_Sunset:

	.Red
	db $70,$3F
	db $70,$3F
	db $00

	.Green
	db $13,$4B
	db $13,$4C
	db $13,$4D
	db $13,$4E
	db $13,$4F
	db $13,$50
	db $13,$51
	db $13,$52
	db $13,$53
	db $13,$54
	db $13,$55
	db $13,$56
	db $00

	.Blue
	db $00,$86
	db $20,$85
	db $20,$84
	db $20,$83
	db $20,$82
	db $20,$81
	db $20,$80
	db $00

HDMA_BlueSky:

	.Red
	db $0C,$29
	db $0C,$2A
	db $0C,$2B
	db $0C,$2C
	db $0C,$2D
	db $0C,$2E
	db $0C,$2F
	db $0C,$30
	db $0C,$31
	db $0C,$32
	db $00

	.Green
	db $0E,$54
	db $0E,$55
	db $0E,$56
	db $0E,$57
	db $0E,$58
	db $0E,$59
	db $0E,$5A
	db $0E,$5B
	db $0E,$5C
	db $00

	.Blue
	db $26,$99
	db $26,$9A
	db $26,$9B
	db $00


HDMA_Mist:

	db $30,$E0
	db $30,$E0
	db $08,$E1
	db $08,$E2
	db $08,$E3
	db $08,$E4
	db $08,$E5
	db $08,$E6
	db $08,$E7
	db $08,$E8
	db $08,$E9
	db $08,$EA
	db $08,$EB
	db $08,$EC
	db $08,$ED
	db $08,$EE
	db $08,$EF
	db $08,$F0
	db $00

HDMA_Nighttime:

	.Green
	db $26,$40
	db $26,$41
	db $26,$42
	db $26,$43
	db $26,$44
	db $26,$45
	db $00

	.Blue
	db $0C,$80
	db $0C,$81
	db $0C,$82
	db $0C,$83
	db $0C,$84
	db $0C,$85
	db $0C,$86
	db $0C,$87
	db $0C,$88
	db $0C,$89
	db $0C,$8A
	db $0C,$8B
	db $0C,$8C
	db $0C,$8D
	db $0C,$8E
	db $0C,$8F
	db $0C,$90
	db $0C,$91
	db $0C,$92
	db $0C,$93
	db 00



