levelinit1:
		%GradientRGB(HDMA_BlueSky)
		INC !SideExit
		LDA #$09			;\ BG2 HScroll = Close2Half
		STA !BG2ModeH			;/
		LDA #$C0			;\
		STA !BG2BaseV			; | Base BG2 VScroll = 0xC0
		STZ !BG2BaseV+1			;/

		LDA #$50 : STA !GFX_Dynamic	; set dynamic area

		JMP level1

levelinit2:
		INC !SideExit
		REP #$20			; > A 16 bit
		LDA.w #$3200			;\
		STA $4330			; |
		LDA.w #HDMA_BlueSky_Green	; | Set up green colour math on channel 3
		STA !HDMA3source		; |
		LDY.b #HDMA_BlueSky_Green>>16	; |
		STY $4334			;/
		LDA.w #$3200			;\
		STA $4340			; |
		LDA.w #HDMA_BlueSky_Blue	; | Set up blue colour math on channel 4
		STA !HDMA4source		; |
		STY $4344			;/
		LDA.w #$7C00			;\
		STA $400000+!MsgVRAM1		; | Portrait VRAM location
		LDA.w #$7C80			; |
		STA $400000+!MsgVRAM2		;/
		SEP #$20			; > A 8 bit
		LDA #$18			;\ Enable HDMA on channels 3 and 4
		TSB $6D9F			;/
		JSR CLEAR_DYNAMIC_BG3
		RTS				; > Return

levelinit3:
		INC !SideExit
		LDA #$C1 : STA !MsgPal		; > Portrait CGRAM location
		LDA #$1F			;\ Put everything on mainscreen
		STA $6D9D			;/
		STZ $6D9E			; > Disable subscreen
		JSR CLEAR_DYNAMIC_BG3		; > Clear the top of BG3
		JSL !GetVRAM
		LDA #$31
		STA !VRAMbase+!VRAMtable+$04,x
		STA !VRAMbase+!VRAMtable+$0B,x
		REP #$20
		LDA #$DC40
		STA !VRAMbase+!VRAMtable+$02,x
		LDA #$DE40
		STA !VRAMbase+!VRAMtable+$09,x
		LDA #$6A20
		STA !VRAMbase+!VRAMtable+$05,x
		LDA #$6B20
		STA !VRAMbase+!VRAMtable+$0C,x
		LDA #$0080
	;	STA !VRAMbase+!VRAMtable+$00,x
	;	STA !VRAMbase+!VRAMtable+$07,x

		.HDMA
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
		LDA #$02 : STA $3E		; mode 2
		LDA #$03 : STA !Map16Remap+$0C	; remap page 0x0C to expanded GFX

		REP #$20
		LDA $1A
		AND #$01FF
		ORA #$2000
		LDX #$3E
	-	STA $40A000,x
		DEX #2 : BPL -
		LDA $1C
		AND #$01FF
		ORA #$2000
		LDX #$3E
	-	STA $40A040,x
		DEX #2 : BPL -
		SEP #$20


		LDA $1B
		CMP #$1C : BCS .Bonus

	.MainStage
		LDA #$1D : STA $5E
		LDA #$00 : STA !SmoothCamera
		RTS

	.Bonus
		BEQ ..1
		CMP #$1F : BNE ..2

	..3	REP #$20
		LDA #$1F00
		STA !CameraBoxL
		STA !CameraBoxR
		STZ !CameraBoxU
		LDA #$00E0
		BRA ..R


	..2	REP #$20
		LDA #$1D00 : STA !CameraBoxL
		LDA #$1E00 : STA !CameraBoxR
		STZ !CameraBoxU
		LDA #$0000
		BRA ..R

	..1	REP #$20
		LDA #$1D00 : STA !CameraBoxL
		LDA #$1E00 : STA !CameraBoxR
		LDA #$00E0
		STA !CameraBoxU

	..R	STA !CameraBoxD
		SEP #$30
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


; $0400-$06FF: reserved
; $0700 - red HDMA table
; $0800 - green HDMA table
; $0900 - blue HDMA table
; $0A00 - BG2 Hscroll HDMA table
; $0A80 - reserved

levelinit6:

		STZ $97
		STZ !P2YPosHi-$80
		STZ !P2YPosHi
		LDA $96
		SEC : SBC #$90
		STA $96
		LDA !P2YPosLo-$80
		SEC : SBC #$90
		STA !P2YPosLo-$80
		LDA !P2YPosLo
		SEC : SBC #$90
		STA !P2YPosLo

		LDA #$FF : STA !PalsetF					; lock palsetF for the sun BG

	LDA #$02 : STA !GlobalPalset1
	LDA #$03 : STA !GlobalPalset2

		STZ $0AFE
		STZ $0AFF

		REP #$30					;\
		LDX #$017E					; |
	-	LDA.l $3E8008,x : STA !PaletteHSL+$300,x	; | cache the HSL-formatted night time palette
		DEX #2 : BPL -					; |
		SEP #$30					;/



		LDX #$00
		INC !SideExit
		LDA #$0E			;\ Scanline count
		XBA				;/
	-	LDA #$01			;\
		STA $0700,x			; |
		LDA #$31			; |
		STA $0701,x			; | Red scroll buffer
		INX #2				; |
		CPX #$20			; |
		BNE -				;/
	-	XBA				;\
		STA $0700,x			; |
		XBA				; |
		INC A				; |
		STA $0701,x			; |
		INX #2				; |
		CPX #$38			; | Red table
		BNE -				; |
		INC A : STA $0701,x		; |
		INC A : STA $0703,x		; |
		LDA #$1F			; |
		STA $0700,x			; |
		STA $0702,x			; |
		TDC : STA $0704,x		;/
		TAX				; > X = 0x00
		LDA #$15			;\ Scanline count
		XBA				;/
	-	LDA #$01			;\
		STA $0800,x			; |
		LDA #$40			; |
		STA $0801,x			; | Green scroll buffer
		INX #2				; |
		CPX #$20			; |
		BNE -				;/
	-	XBA				;\
		STA $0800,x			; |
		XBA				; |
		INC A				; |
		STA $0801,x			; | Green table
		INX #2				; |
		CPX #$34			; |
		BNE -				; |
		TDC : STA $0800,x		;/
		TAX				; > X = 0x00
		LDY #$88			; > Base color
	-	LDA #$1A			;\
		STA $0900,x			; |
		TYA : DEY			; |
		STA $0901,x			; | Blue table
		INX #2				; |
		CPX #$12			; |
		BNE -				; |
		TDC : STA $0900,x		;/

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
		LDA #$0700			; |
		STA !HDMA3source		; | Set up red colour math on channel 3
		LDY #$00			; |
		STY $4334			;/
		LDA #$3200			;\
		STA $4340			; |
		LDA #$0800			; | Set up green colour math on channel 4
		STA !HDMA4source		; |
		STY $4344			;/
		LDA #$3200			;\
		STA $4350			; |
		LDA #$0900			; | Set up blue colour math on channel 5
		STA !HDMA5source		; |
		STY $4354			;/
		LDA #$0F02			;\
		STA $4360			; |
		LDA #$0A00			; | Set up BG2 Hscroll on channel 6
		STA !HDMA6source		; |
		STY $4364			;/
		SEP #$20			; > A 8 bit
		LDA #$78			;\ Enable HDMA on channels 3 through 6
		TSB $6D9F			;/

		JSL !GetVRAM				;\
		PHB : LDA #!VRAMbank			; |
		PHA : PLB				; |
		LDA #$31				; |
		STA !VRAMtable+$04,x			; |
		STA !VRAMtable+$0B,x			; |
		REP #$20				; | Upload sun SBG
		LDA #$DC00 : STA !VRAMtable+$02,x	; |
		LDA #$DE00 : STA !VRAMtable+$09,x	; |
		LDA #$7EE0 : STA !VRAMtable+$05,x	; |
		LDA #$7FE0 : STA !VRAMtable+$0C,x	; |
		LDA #$0040				; |
		STA !VRAMtable+$00,x			; |
		STA !VRAMtable+$07,x			; |
		SEP #$20				; |
		PLB					;/

		JMP level6



levelinitC:
		INC !SideExit
		JSR levelinit35
		LDA #$00 : STA !SmoothCamera
		LDA #$FF : STA !CameraBoxU+1
		LDA #$16 : STA !Level+6
		RTS




levelinit26:
		%GradientRGB(HDMA_BlueSky)
		LDA #$06			;\
		STA !BG2ModeH			; | BG2 scroll = Close, Close
		STA !BG2ModeV			;/
		LDA #$A0 : STA !BG2BaseV	;\ Base BG2 Vscroll: 0x1A0
		LDA #$01 : STA !BG2BaseV+1	;/
		JMP level26

levelinit27:
		RTS


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
		RTS

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
		STA !HDMA3source
		SEP #$20
		LDA.b #.Table>>16
		STA $4334
		LDA #$08
		TSB $6D9F
		RTS


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
		RTS

levelinit2F:
		JMP levelinit2


levelinit32:

		STZ !Level+3
		LDA #$02 : STA.l !WeatherType
		LDA #$04 : STA.l !WeatherFreq

		STZ $0A84
		REP #$20				;\
		LDA.w level6_BGColoursEnd		; | set color 0x02
		STA $00A2				; |
		SEP #$20				;/
		LDA #$78				;\ Enable HDMA on channels 3 through 6
		TSB $6D9F				;/
		STZ !SideExit
		JMP level32


levelinit1FD:
	RTS


; --Level MAIN--


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





	DisplayHitbox:


	.OutsideJump
		JMP .Outside

	.Main
		PHP
		SEP #$20
		STZ $6D9F				; disable HDMA at first
		STZ $41
		STZ $42
		STZ $43
		REP #$20
		LDA !P2Hitbox+4-$80 : BEQ .OutsideJump
		AND #$00FF
		CLC : ADC !P2Hitbox+0-$80
		STA $00					; $00 = x + w
		LDA !P2Hitbox+5-$80
		AND #$00FF
		CLC : ADC !P2Hitbox+2-$80
		STA $02					; $02 = y + h

		LDA $1A
		CLC : ADC #$0100
		STA $04					; $04 = screen right
		LDA $1C
		CLC : ADC #$00D8
		STA $06					; $06 = screen bottom


		LDA !P2Hitbox+2-$80 : BMI .OverTop
		CMP $1C : BCC .OverTop

	.UnderTop
		CMP $06 : BCS .OutsideJump

	; case 5: outside

		LDA !P2Hitbox+2-$80
		SEC : SBC $1C
		TAY
		LDA $02
		CMP $06 : BCC .YInside
		LDA $06
		SEC : SBC !P2Hitbox+2-$80
		BRA .Height

	; case 4: visible $1C+0xD8-y


	.YInside
		LDA !P2Hitbox+5-$80
		AND #$00FF
		BRA .Height

	; case 3: completely inside


	.OverTop
		LDA $02
		SEC : SBC $1C
		BCC .OutsideJump
		LDY #$00				; start at scanline 0

	; case 1: outside
	; case 2: visible y+h-$1C


	.Height
		STY $0F					; $0F = starting scanline
		TAY					; y = number of scanlines visible


		LDA !P2Hitbox+0-$80 : BMI .LeftLeft
		CMP $1A : BCC .LeftLeft

	.RightLeft
		CMP $04 : BCS .OutsideJump

	; case E: outside

		LDA !P2Hitbox+0-$80
		SEC : SBC $1A
		TAX
		LDA $00
		CMP $04 : BCC .XInside
		LDA $04
		SEC : SBC !P2Hitbox+0-$80
		BRA .Width

	; case D: visible $1A+0x100-x


	.XInside
		LDA !P2Hitbox+4-$80
		AND #$00FF
		BRA .Width

	; case C: completely inside


	.LeftLeft
		LDA $00
		SEC : SBC $1A
		BCC .Outside
		LDX #$00				; x coord 0

	; case A: outside
	; case B: visible x+w-$1A


	.Width
		STX $0D
		SEP #$20
		CLC : ADC $0D
		BCC $02 : LDA #$FF			; cap at 0xFF
		STA $0E

	; $0D:	left border
	; $0E:	right border
	; $0F:	starting y coord
	; y:	number of scanlines visible


		LDA #$04 : STA $6D9F			; enable HDMA on channel 2
		LDA #$22
		STA $41
		STA $42
		STA $43


		LDX #$00				; table index: 0
		LDA $0F : BEQ .InstantStart
		CMP #$40 : BCC +

		LSR A
		STA $0400
		BCC $01 : INC A
		STA $0403
		INX
		LDA #$FF : STA $0400,x
		STZ $0401,x
		INX #3
		BRA ++

	+	STA $0400
		INX
		LDA #$FF
	++	STA $0400,x				;\
		STZ $0401,x				; | set up skip lines
		INX #2					;/

	.InstantStart
		TYA : STA $0400,x			;\
		LDA $0D : STA $0401,x			; | write box
		LDA $0E : STA $0402,x			;/
		LDA #$01 : STA $0403,x			;\
		LDA #$FF : STA $0404,x			; | set up a final skip line
		STZ $0405,x				;/
		STZ $0406,x				; end table

		REP #$20
		LDA #$2601 : STA $4320
		STZ $4323
		LDA #$0400 : STA !HDMA2source


	.Outside

		PLP
		RTS










level2:
	;	LDA #$00 : STA !GlobalPalset1
	;	LDA #$01 : STA !GlobalPalset2
	;	LDA #$20 : STA !GlobalPalsetMix

		RTS

level3:
		REP #$20
	;	LDA #$15E8				;\
	LDA #$1FE8
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
		CMP #$82 : BNE ..Scroll
		LDA !BossData+2
		CMP #$02 : BNE ..Scroll
		LDA #$01
		STA !EnableHScroll			; > Enable scrolling
		STA !SmoothCamera			; enable smooth camera to prevent a glitch later
		REP #$20
	;	LDA #$1400
	LDA #$1E00
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
	;	SBC #$13
	SBC #$1D
		BCC ..NoScroll
		STZ !EnableHScroll
		STZ !SideExit
		LDA $1B
	;	CMP #$14
	CMP #$1E
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

		STZ !HDMA3source
		LDA $14
		AND #$01
		XBA
		LDA #$00
		REP #$10
		TAX

		.MakeTable
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
	;	STA !OAM+$1F9				; | Ypos of castle
		LDA #$40				; |
	;	STA !OAM+$1FD				;/
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
	..R	SEP #$20
		LDA $14					;\
		AND #$01				; | use the table we just made
		ORA #$04				; |
		STA !HDMA3source+1			;/
		PLP
		RTL


level4:

		LDA #$20 : STA $64
		LDA $71
		CMP #$05 : BEQ ++
		CMP #$06 : BNE +
	++	STZ $64
		LDA #$40 : STA !SPC4			; dizzy OFF!!
		+

		LDA !P2Status-$80 : BNE .P2
		LDA !P2XPosHi-$80
		CMP #$0E : BNE .P2
		LDA !P2XSpeed-$80 : BPL .P2
		CMP #$D8 : BCC .Secret
	.P2	LDA !P2Status : BNE .Wall
		LDA !P2XPosHi
		CMP #$0E : BNE .Wall
		LDA !P2XSpeed : BPL .Wall
		CMP #$D8 : BCS .Wall
	.Secret	LDA $1C
		CMP #$B0 : BCC .Wall
		LDA #$8B
		LDY #$02
		BRA .Update
	.Wall	LDA #$A5
		LDY #$05
	.Update	STA $40C800+($1C0*$0E)+$15E
		STA $40C800+($1C0*$0E)+$16E
		TYA
		STA $41C800+($1C0*$0E)+$15E
		STA $41C800+($1C0*$0E)+$16E

		LDY #$0F
		LDX #$02
	-	LDA $3230,y
		CMP #$08 : BNE +
		LDA $3590,y
		AND #$08 : BEQ +
		LDA $35C0,y
		CMP #$13 : BEQ ++
		CMP #$14 : BNE +
	++	LDA #$01+!CustomOffset : STA !Ex_Num,x	;\
		TYA : STA !Ex_Data1,x			; | allocate slots for dizzy stars on dancing koopas
		LDA #$F0 : STA !Ex_Data3,x		; |
		LDA !Ex_Data2,x				; |
		CMP #$AA : BCS ++			; |
		ADC #$55				; |
		STA !Ex_Data2,x				; |
		BRA ++
	+	LDA !Ex_Num,x
		CMP #$01+!CustomOffset : BNE ++
		STZ !Ex_Num,x
	++	INX
		DEY : BPL -


		LDA $1B
		CMP #$08 : BCC .NoSpawn			; screens 0-7: no fuzzies
		CMP #$17 : BCS .NoSpawn			; screens 17+: no fuzzies
		LDX #$00				;\
		CMP #$10 : BCC .CheckSpawn		; | use index on screens 8-16
		INX					;/

		.CheckSpawn
		LDA .SpawnRate,x
		AND $14 : BNE .NoSpawn
		LDX #$0F
	-	LDA $3230,x : BEQ .Spawn
		DEX : BPL -
		BRA .NoSpawn

		.Spawn
		LDA !RNG
		AND #$F0
		CLC : ADC $1C
		STA $3210,x
		LDA $1D
		ADC #$00
		STA $3240,x
		LDA !RNG
		AND #$02
		TAY
		REP #$20
		LDA $1A
		CLC : ADC .SpawnX,y
		SEP #$20
		STA $3220,x
		XBA : STA $3250,x
		LDA #$01 : STA $3230,x
		LDA #$36 : STA $3200,x
		LDA #$2D : STA $35C0,x
		LDA #$08 : STA $3590,x
		JSL !ResetSprite
		JSL !ResetSpriteExtra
		.NoSpawn


		REP #$20
		LDA.w #.HDMA : STA !HDMAptr+0
		LDA.w #.HDMA>>8 : STA !HDMAptr+1
		LDA $1A
		CMP #$1C40 : BCS .Bonus
		LDA #$1CF8				;\
		LDY #$01				; | Regular exit
		JMP END_Right				;/

	.Bonus
		SEP #$30
		RTS


	.SpawnRate
	db $9F,$3F					; based on which quarter of the level the camera is on

	.SpawnX
	dw $0120
	dw $FFE0


		.HDMA
		PHB : PHK : PLB
		PHP
		REP #$20
		LDA !P2XPosLo-$80
		CMP #$1D00 : BCC +
		LDA #$1D00
		CMP $1A : BCC +
		STA $1A

	+	JSL .Mode2
		PLP
		PLB
		RTL


; !Level+2: timer, activates effect
; !Level+4: internal timer

		.Mode2
		PHB : PHK : PLB
		PHP
		SEP #$30
		LDA #$01 : STA !DizzyEffect
		LDA.b #..SA1 : STA $3180
		LDA.b #..SA1>>8 : STA $3181
		LDA.b #..SA1>>16 : STA $3182
		JSR $1E80

		LDA !Level+3 : BNE +
		LDA !Level+2
		CMP #$01 : BNE +
		LDA #$40 : STA !SPC4			; turn off dizzy
		+


		LDA #$01 : STA $40A0F0 : STA $40A0F4
		LDA #$00 : STA $40A0F3 : STA $40A0F7


		REP #$20
		LDA #$0E02 : STA $4320			;\
		LDA $14					; |
		AND #$0001				; | layer 1 HDMA
		BEQ $03 : LDA #$0004			; |
		ORA #$A0F0 : STA !HDMA2source		;/

		LDA #$0F02 : STA $4330			;\
		LDA $14					; |
		AND #$0001				; | layer 2 horizontal HDMA
		BEQ $03 : LDA #$0040			; |
		ORA #$A100 : STA !HDMA3source		;/

		LDA #$1002 : STA $4340			;\
		LDA $14					; |
		AND #$0001				; | layer 2 stretch HDMA
		BEQ $03 : LDA #$0400			; |
		ORA #$A200 : STA !HDMA4source		;/

		LDA #$3101 : STA $4350			;\ color math HDMA
		LDA #$0A00 : STA !HDMA5source		;/

		SEP #$20
		LDA #$40
		STA $4324
		STA $4334
		STA $4344
		STZ $4354

		LDA #$3C : TSB !HDMA


		LDA #$1F : STA $6D9D
		LDA #$02 : TRB $44

		LDA #$02 : TRB $44
		LDA #$01 : STA $0A00
		LDA #$3F : STA $0A01
		LDA !Level+2
		LSR #3
		TAY
		LDA ..ColorTable,y : STA $0A02
		STZ $0A03

		LDY #$00
	-	LDA !P2Blocked-$80,y
		AND #$04 : BEQ +
		REP #$20
		LDA !P2XPosLo-$80,y
		CLC : ADC #$0008
		SEC : SBC $1A
		LSR #3
		ASL A
		TAX
		LDA $40A040,x
		SEC : SBC $1C
		SEP #$20
		STA !P2VectorX-$80,y
		LDA #$00 : STA !P2VectorAccX-$80,y
		LDA #$10 : STA !P2VectorTimeX-$80,y
	+	CPY #$80 : BEQ +
		LDY #$80 : BRA -
		+

		LDA $14
		LSR A : BCC +
		LDA $6DB0
		CMP #$10 : BCC +
		SEC : SBC #$10
		STA $6DB0
		+

		PLP
		PLB
		RTL

	..ColorTable
	db $E0,$82,$83,$84,$85,$86,$87,$88
	db $87,$86,$85,$84,$83,$82,$81,$20
	db $21,$22,$23,$24,$25,$26,$27,$28
	db $27,$26,$25,$24,$23,$22,$21,$E0



; $40A000 - X table
; $40A040 - Y table
; $40A0F0 - layer 1 HDMA table
; $40A0FA - intensity factor
; $40A0FC - added during flip
; $40A0FE - EOR'd during flip

		..SA1
		PHB : PHK : PLB
		PHP
		REP #$20
		SEP #$10
		LDX #$00 : STX $2250

		INC !Level+4
		LDA !Level+6
		INC A
		CMP.w #..ZTable_End-..ZTable
		BCC $03 : LDA #$0000
		STA !Level+6

		PHB : LDX #$40
		PHX : PLB


		LDA.l !Level+2 : BEQ +
		DEC A
		STA.l !Level+2
		AND #$001F
	+	TAY

		REP #$10
		LDY #$003E
		STZ $A0FE
		STZ $A0FC
		LDA $1A
		LSR A
		EOR #$FFFF
		CLC : ADC.l !Level+2
		ASL #3
		AND #$03FF
		CMP #$0200 : BCC +
		DEC $A0FE
		INC $A0FC
	+	AND #$01FF
		TAX

		LDA.l !Level+2
		CMP #$03E0 : BCC +
		SEC : SBC #$0400
		EOR #$FFFF : INC A
		BRA ++
	+	CMP #$0100
		BCC $03 : LDA #$0100
		LSR #3
	++	STA $A0FA

	-	LDA.l !TrigTable,x
		LSR #5
		STA.l $2251
		LDA $A0FA : STA.l $2253
		BRA $00 : NOP
		LDA.l $2306
		LSR #4
		EOR $A0FE
		CLC : ADC $1C
		CLC : ADC $A0FC
		AND #$01FF
		ORA #$2000
		STA $A040,y
		LDA $1A
		ORA #$2000
		STA $A000,y
		TXA
		CLC : ADC #$0020
		AND #$01FF
		TAX
		CMP #$0020 : BCS +
		LDA $A0FE
		EOR #$FFFF
		STA $A0FE
		LDA $A0FC
		EOR #$0001
		STA $A0FC
	+	DEY #2 : BPL -

		LDA.l !TrigTable,x
		LSR #5
		STA.l $2251
		LDA $A0FA : STA.l $2253
		LDA $14
		AND #$0001
		BEQ $03 : LDA #$0004
		TAX
		LDA.l $2306
		LSR #4
		EOR $A0FE
		CLC : ADC $1C
		CLC : ADC $A0FC
		AND #$01FF
		STA $A0F1,x			; layer 1 HDMA value

		STZ $22
		STZ $24

		PLB
		SEP #$10


		; H wave code
		LDA !Level+4
		LSR #2
		AND #$001F
		TAY
		LDA $14
		AND #$0001
		BEQ $03 : LDA #$0040
		TAX

	-	TYA
		INC A
		AND #$001F
		TAY
		LDA #$0010 : STA $40A100,x
		LDA ..HTable,y
		AND #$00FF
		STA $2251
		LDA $40A0FA : STA $2253
		BRA $00 : NOP
		LDA $2306
		LSR #5
		CLC : ADC $1E
		STA $40A101,x
		INX #3
		TXA
		AND #$003F
		CMP #$0030 : BCC -
		LDA #$0000 : STA $40A100,x


		; Z stretch code
		REP #$10
		LDA $14
		AND #$0001
		BEQ $03 : LDA #$0400
		TAX
		LDA !Level+6
		CLC : ADC $20
	-	CMP.w #..ZTable_End-..ZTable : BCC +
		SBC.w #..ZTable_End-..ZTable : BRA -
	+	TAY

	-	INY
		CPY.w #..ZTable_End-..ZTable
		BCC $03 : LDY #$0000
		LDA #$0001 : STA $40A200,x
		LDA ..ZTable,y
		AND #$00FF
		SEC : SBC #$001B
		STA $2251
		LDA $40A0FA : STA $2253
		BRA $00 : NOP
		LDA $2306
		LSR #5
		CLC : ADC $20
		STA $40A201,x
		INX #3
		INY
		TXA
		AND #$03FF
		CMP #$0300 : BCC -
		LDA #$0000 : STA $40A200,x

		SEP #$10




		JSL !GetVRAM
		LDA #$0080 : STA !VRAMbase+!VRAMtable+$00,x
		LDA #$A000 : STA !VRAMbase+!VRAMtable+$02,x
		LDA #$0040 : STA !VRAMbase+!VRAMtable+$04,x
		LDA #$5800 : STA !VRAMbase+!VRAMtable+$05,x
		PLP
		PLB
		RTL


	..HTable
		db $00,$01,$02,$03,$05,$07,$09,$0C
		db $0F,$12,$14,$16,$17,$18,$19,$1A
		db $1A,$19,$18,$17,$16,$14,$12,$0F
		db $0C,$09,$07,$05,$03,$02,$01,$00


; ripped from yoshi's island
	..ZTable
	db $28,$29,$29,$2A,$2A,$2B,$2B,$2C
	db $2C,$2C,$2D,$2D,$2E,$2E,$2E,$2F
	db $2F,$2F,$2F,$30,$30,$30,$30,$30
	db $30,$30,$31,$31,$31,$30,$30,$30
	db $30,$30,$30,$30,$2F,$2F,$2F,$2F
	db $2E,$2E,$2E,$2D,$2D,$2C,$2C,$2C
	db $2B,$2B,$2A,$2A,$29,$29,$28,$28
	db $27,$27,$26,$26,$25,$24,$24,$23
	db $23,$22,$22,$21,$21,$20,$20,$1F
	db $1F,$1F,$1E,$1E,$1D,$1D,$1D,$1C
	db $1C,$1C,$1C,$1B,$1B,$1B,$1B,$1B
	db $1B,$1B,$1B,$1B,$1B,$1B,$1B,$1B
	db $1B,$1B,$1B,$1B,$1C,$1C,$1C,$1C
	db $1D,$1D,$1D,$1E,$1E,$1F,$1F,$1F
	db $20,$20,$21,$21,$22,$22,$23,$23
	db $24,$24,$25,$26,$26,$27,$27,$28
	...End



level5:
		LDA #$02 : STA !GlobalPalset1

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
		STA !HDMA6source			;/

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



; see level init for info on RAM use

level6:
		REP #$20
		LDA #$1FE8 : JSR EXIT_FADE_Right
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
	-	LDA $0800,x				; |
		CMP #$26				; | Increment timer and stretch green
		BEQ +					; |
		INC A					; |
		STA $0800,x				; |
		BRA ++					; |
	+	INX #2					; |
		CPX #$14				; |
		BNE -					; |
	++	REP #$20				; |
		INC !Level+2				;/

.HandleHDMA	REP #$20
		LDA !Level+2
		CMP #$0100
		BCC $03 : LDA #$0100
		LSR #3
		SEP #$20
		STA !GlobalPalsetMix


		LDA $14
		LSR A
		STA $00
		AND #$07 : BEQ .NoHSL
		ASL #4
		ORA #$02
		TAX
		LDY #$0E
		LDA $14
		LSR A : BCS .UploadColor

		.MixColor
		LDA !Level+3 : BEQ +
		LDA #$00 : BRA ++
	+	LDA !Level+2
		BNE $01 : INC A
		EOR #$FF : INC A
	++	JSL !MixHSL
		BRA .NoHSL

		.UploadColor
		REP #$30
		TXA
		ORA #$0200
		TAX
		LDY #$000E
		JSL !HSLtoRGB
		SEP #$30
		.NoHSL


		LDX #$00
		REP #$20

		LDA !Level+2
		AND #$03FF
	-	CMP #$000F
		BCC +
		INX #2
		SBC #$000E
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
		STA $0700,x
		CLC : ADC $00
		STA $00
		LDA $7FA101,x
		STA $0701,x
		INX #2
		BCS ++
		CPX $01
		BNE -
	+	LDY #$00
	-	LDA.w HDMA_Evening,y
		STA $0700,x
		CLC : ADC $00
		STA $00
		LDA.w HDMA_Evening+1,y
		STA $0701,x
		INX #2
		BCS ++
		INY #2
		CPY #$1E
		BNE -
	++	TDC : STA $0700,x

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
		STA $0900,x
		CLC : ADC $00
		STA $00
		LDA $7FA201,x
		STA $0901,x
		INX #2
		BCS ++
		CPX $01
		BNE -
	+	LDY #$00
	-	LDA.w HDMA_Evening_Blue,y
		STA $0900,x
		CLC : ADC $00
		STA $00
		LDA.w HDMA_Evening_Blue+1,y
		STA $0901,x
		INX #2
		BCS ++
		INY #2
		CPY #$1E
		BNE -
	++	TDC : STA $0900,x

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
		LDA #$0D				;\
		STA !OAM+$1F3				; |
		LDA #$4D				; |
		STA !OAM+$1F7				; | Properties of sun
		LDA #$8D				; |
		STA !OAM+$1FB				; |
		LDA #$CD				; |
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


levelC:
		JSR level35
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
	RTS

level32:
		LDA.b #.HDMA : STA.l !HDMAptr+0
		LDA.b #.HDMA>>8 : STA.l !HDMAptr+1
		LDA.b #.HDMA>>16 : STA.l !HDMAptr+2

		LDA #$7F : TRB !Level+4
		LDX #$0F
	-	LDA $3230,x
		CMP #$08 : BNE +
		LDA $3590,x
		AND #$08 : BEQ +
		LDA $35C0,x
		CMP #$05 : BNE +
		LDA $3250,x
		CMP #$0C : BNE +
		LDA $BE,x : BNE +
		LDA $3220,x
		ASL A
		ROL A
		AND #$01
		STA $3320,x
		INC A : TSB !Level+4
		LDA #$0F : STA $32D0,x
	+	DEX : BPL -


		LDA #$02 : STA !WeatherType
		LDA #$04 : STA !WeatherFreq
		REP #$20
		LDA !Level+3
		ASL A
		AND #$00FF
		STA $02
		LDA #$0C78
		SEC : SBC $1A
		CMP #$0100 : BCC .GoodX
		CMP #$FFF0 : BCS $03 : JMP .Nope
	.GoodX	STA $00
		LDA $14
		AND #$00FF
		LSR #4
		SEC : SBC #$0008
		BPL $03 : EOR #$FFFF
		CLC : ADC #$0110
		SEC : SBC $1C
		SEC : SBC $02
		CMP #$00D8 : BCC .GoodY
		CMP #$FFF0 : BCC .Nope
	.GoodY	LDY !OAMindex
		SEP #$20
		STA !OAM+1,y
		LDA $00 : STA !OAM+0,y
		LDA #$E0 : STA !OAM+2,y
		LDA #$28 : STA !OAM+3,y

		LDA !Level+4
		AND #$03 : BNE +
		INC !Level+3
		LDA !Level+4 : BMI +
		ORA #$80
		STA !Level+4
		REP #$20
		LDA #$0C60 : STA $0A80
		LDA #$0130 : STA $0A82
		JSR PuffTile
		LDA #$0C70 : STA $0A80
		JSR PuffTile
		LDA #$0C80 : STA $0A80
		JSR PuffTile
		LDA #$0C90 : STA $0A80
		JSR PuffTile
		SEP #$20
		LDA #$10 : STA !SPC1			; magikoopa sound

	+	TYA
		INY #4
		STY !OAMindex
		LSR #2
		TAY
		LDA $01
		AND #$01
		ORA #$02
		STA !OAMhi,y
		LDA #$03 : STA !WeatherType
		LDA #$04 : STA !WeatherFreq

	.Nope	SEP #$20

		JSR Weather


		LDA $1B
		CMP #$0D : BNE .NoExit
		REP #$20
		LDA #$00A0 : JSR EXIT_Up
		.NoExit


		LDX #$0F				;\
	-	LDA $3200,x				; |
		CMP #$0C : BCS +			; |
		LDA $3590,x				; |
		AND #$08 : BNE +			; | koopas go behind scenery
		LDA #$01 : STA $3410,x			; |
		LDA #$1F				; |
		STA $32E0,x				; |
		STA $35F0,x				; |
	+	DEX : BPL -				;/


		LDY $1B					;\
		LDA .ChunkScreen,y			; |
		AND !Level+2 : BNE ++			; |
		LDX #$0F				; |
	-	LDA $3230,x : BEQ +			; |
		LDA $35C0,x				; |
		CMP #$06 : BNE +			; |
		LDA $3280,x				; | load chunks when adept shamans die
		AND #$03				; |
		CMP #$02 : BNE +			; |
		LDA .ChunkScreen,y : TSB !Level+2	; |
		JSR LoadChunk				; |
		BRA ++					; |
	+	DEX : BPL -				; |
		++					;/

		LDA $0A84 : BEQ .Return
		LDA $14
		AND #$1F : BEQ DestroyChunk

	.Return	RTS


.ChunkScreen	db $01,$01,$01,$01			; screens 00-03
		db $02,$02,$02				; screens 04-06
		db $04,$04,$04,$04,$04,$04,$04		; screens 07-0D
		db $08,$08,$08,$08			; screens 0E-11




		.HDMA
		PHP
		REP #$20
		LDA !Level+2
		AND #$0088 : BEQ ..Check
		CMP #$0080 : BEQ ..Lock
		BRA ..R

	..Check	LDA $1A
		CMP #$1016 : BCC ..R
		LDA #$0080 : TSB !Level+2
		BRA ..R

	..Lock	LDA #$1018
		CMP $1A : BCC ..R
		STA $1A
		LSR A
		STA $1E

	..R	SEP #$20
		LDA $1F					;\
		LSR A					; |
		STA $0A08				; | Update BG2 Hscroll
		LDA $1E					; |
		ROR A					; |
		STA $0A07				;/
		PLP
		RTL




;	!Level+2: chunk status
;			each bit represents a chunk, so bit 0 - chunk 1 etc.


;	$0A80-$0A81:	X coord of section being destroyed
;	$0A82-$0A83:	Y coord of section being destroyed
;	$0A84:		how many rows are left to destroy

	DestroyChunk:
		REP #$20
		JSR PuffTile
		LDA $0A80 : PHA
		CLC : ADC #$0010
		STA $0A80
		JSR PuffTile
		PLA : STA $0A80
		LDA $0A82
		CLC : ADC #$0010
		STA $0A82
		SEP #$20
		DEC $0A84
		LDA #$09 : STA !SPC4			; > Boom sound
	.Return	RTS


	PuffTile:
		PHP
		PEI ($98)
		PEI ($9A)
		REP #$20
		LDA $0A80 : STA $9A
		LDA $0A82 : STA $98
		LDX #$02 : STX $9C
		JSL $00BEB0
		PLA : STA $9A
		PLA : STA $98

		LDA $0A80
		SEC : SBC $1A
		CMP #$0100 : BCC .GoodX
		CMP #$FFF0 : BCC .Return
	.GoodX	STA $00
		LDA $0A82
		SEC : SBC $1C
		CMP #$0100 : BCC .GoodY
		CMP #$FFF0 : BCC .Return
	.GoodY	STA $02
		SEP #$20
		LDX #!Ex_Amount-1
	-	LDA !Ex_Num,x : BEQ .Slot
		DEX : BPL -
		BMI .Return
	.Slot	LDA #$01+!SmokeOffset : STA !Ex_Num,x
		LDA $0A80 : STA !Ex_XLo,x
		LDA $0A82 : STA !Ex_YLo,x
		LDA #$17 : STA !Ex_Data1,x
	.Return	PLP
		RTS



	LoadChunk:
		PHP
		LDX #$FE
	-	INX #2
		LSR A
		BCC -
		REP #$20
		LDA .ChunkX,x : STA $0A80
		LDA .ChunkY,x : STA $0A82
		LDA .ChunkSize,x : STA $0A84
		PLP
		RTS

.ChunkX		dw $02D0,$06E0,$0D70,$0F50
.ChunkY		dw $0110,$0110,$0120,$00D0
.ChunkSize	dw $0006,$0006,$0002,$000B



level1FD:
	RTS



