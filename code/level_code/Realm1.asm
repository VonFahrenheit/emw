levelinit1:
		%GradientRGB(HDMA_BlueSky)
		INC !SideExit
		LDA #$09			;\ BG2 HScroll = Close2Half
		STA !BG2ModeH			;/
		LDA #$C0			;\
		STA !BG2BaseV			; | Base BG2 VScroll = 0xC0
		STZ !BG2BaseV+1			;/

		JML level1

levelinit2:
		DEC !MarioYPosHi
		DEC !P2YPosHi-$80
		DEC !P2YPosHi


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
		JSL CLEAR_DYNAMIC_BG3
		RTL				; > Return



levelinit3:
		LDA #$03*4 : STA !TextPal

		LDA #$02 : STA !BG2ModeH
		LDA #$04 : STA !BG2ModeV
		%GradientRGB(HDMA_BlueSky)
		LDA #$BA : STA !Level+4			; > negative 0x3F
		LDA #$07 : STA !Level+5			; > Size of chunks
		JML levelinit5_HDMA



; legacy version
		LDA #$03 : STA !Translevel
		INC !SideExit
		LDA #$C1 : STA !MsgPal		; > Portrait CGRAM location
		LDA #$1F			;\ Put everything on mainscreen
		STA !MainScreen			;/
		STZ !SubScreen			; > Disable subscreen
		JSL CLEAR_DYNAMIC_BG3		; > Clear the top of BG3
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
		JML level3


levelinit4:
		INC !SideExit
		LDA #$03 : STA !Map16Remap+$0C	; remap page 0x0C to expanded GFX

		REP #$20
		LDA $1A
		AND #$01FF
		ORA #$2000
		LDX #$3E
	-	STA !DecompBuffer+$1000,x
		DEX #2 : BPL -
		LDA $1C
		AND #$01FF
		ORA #$2000
		LDX #$3E
	-	STA !DecompBuffer+$1040,x
		DEX #2 : BPL -
		SEP #$20


		LDA $1B
		CMP #$1C : BCS .Bonus

	.MainStage
		LDA #$1D : STA $5E
		RTL

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
		RTL


levelinit5:
		LDA #$06 : STA !PalsetStart

		LDA #$1F : STA !MainScreen
		STZ !SubScreen


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
		JSL .HDMA			; > Set up HDMA
		JSL CLEAR_DYNAMIC_BG3		; > Clear the top of BG3
		JML level5


.HDMA		REP #$20			; > A 16 bit
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
		RTL


; $0400-$06FF: reserved
; $0700 - red HDMA table
; $0800 - green HDMA table
; $0900 - blue HDMA table
; $0A00 - BG2 Hscroll HDMA table
; $0A80 - reserved

levelinit6:
		LDA #$06 : STA !PalsetStart
		INC !SideExit

	;	STZ $97
	;	STZ !P2YPosHi-$80
	;	STZ !P2YPosHi
	;	LDA $96
	;	SEC : SBC #$90
	;	STA $96
	;	LDA !P2YPosLo-$80
	;	SEC : SBC #$90
	;	STA !P2YPosLo-$80
	;	LDA !P2YPosLo
	;	SEC : SBC #$90
	;	STA !P2YPosLo

		LDA #$FF : STA !PalsetF					; lock palsetF for the sun BG
		LDA #$02 : STA !GlobalLight1				;\
		LDA #$03 : STA !GlobalLight2				; |
		LDA #$40 : STA !LightIndexStart				; | initial shader settings
		LDA #$01 : STA !LightIndexStart+1			; |
		LDA #$E0 : STA !LightIndexEnd				; |
		LDA #$01 : STA !LightIndexEnd+1				;/

		STZ $0AFE
		STZ $0AFF

		PHB
		LDA.b #!PaletteHSL>>16
		PHA : PLB
		REP #$30					;\
		LDY.w #!File_level06_night			; |
		JSL !GetFileAddress				; |
		LDA !FileAddress : STA $00			; |
		LDA !FileAddress+1 : STA $01			; | cache the HSL-formatted night time palette
		LDY #$017E					; |
	-	LDA [$00],y : STA.w !PaletteHSL+$300,y		; |
		DEY #2 : BPL -					; |
		SEP #$30					;/
		PLB


		LDX #$00
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
		STA $0A00 : STA $0A10		; |
		STA $0A03 : STA $0A13		; |
		LDA #$01			; |
		STA $0A06 : STA $0A16		; | Set up BG2 Hscroll table
		TDC : STA $0A09 : STA $0A19	; |
		REP #$20			; |
		STA $0A01 : STA $0A11		; |
		STA $0A04 : STA $0A14		; |
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


		LDA #$3100 : STA $4370
		LDA.w #.ColorMathHDMA : STA !HDMA7source
		LDY.b #.ColorMathHDMA>>16 : STY $4374


		SEP #$20				; > A 8 bit
		LDA #$F8 : TSB !HDMA			; > enable HDMA on channels 3 through 7


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

		JML level6


		.ColorMathHDMA
		db $4A,$22				;\ color math on backdrop + BG2
		db $4A,$22				;/
		db $01,$20				; color math on backdrop only
		db $00					; end table


levelinitC:

		LDA $97 : BEQ +
		LDA #$C4
		STA !P2VectorY-$80
		STA !P2VectorY
		LDA #$3C
		STA !P2VectorTimeY-$80
		STA !P2VectorTimeY
		LDA #$01
		STA !P2VectorAccY-$80
		STA !P2VectorAccY
		+

		INC !SideExit
		JSL levelinit35_Setup
		JSL levelC
	;	JSL InitCameraBox
		LDA #$0D : STA !Level+6
		STZ !Level+3
		REP #$20
		LDA $6701 : STA !3DWater_Color
		SEP #$20
		INC $14 : JSL HDMA3DWater		;\ set up double-buffered HDMA
		DEC $14 : JSL HDMA3DWater		;/
		RTL




levelinit26:
		%GradientRGB(HDMA_BlueSky)
		LDA #$06			;\
		STA !BG2ModeH			; | BG2 scroll = Close, Close
		STA !BG2ModeV			;/
		LDA #$A0 : STA !BG2BaseV	;\ Base BG2 Vscroll: 0x1A0
		LDA #$01 : STA !BG2BaseV+1	;/
		JML level26

levelinit27:
		RTL


levelinit2A:
		JSL !GetVRAM				;\
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
		RTL

levelinit2B:
		LDY #$0F

	-	%Ex_Index_X()
		LDA $94
		AND #$F0
		CLC : ADC .XDisp,y
		STA !Ex_XLo,x
		LDA $95
		ADC #$00
		STA !Ex_XHi,x
		LDA $96
		AND #$F0
		CLC : ADC .YDisp,y
		STA !Ex_YLo,x
		LDA $97
		ADC #$00
		STA !Ex_YHi,x
		LDA.b #$01+!MinorOffset : STA !Ex_Num,x
		LDA .XSpeed,y : STA !Ex_XSpeed,x
		LDA .YSpeed,y : STA !Ex_YSpeed,x
		STZ !Ex_Data1,x
		STZ !Ex_Data2,x
		STZ !Ex_Data3,x
		DEY : BPL -

		LDA #$09 : STA !SPC4
		LDA #$1F
		STA !ShakeTimer
		STA !ShakeBG3

		JML levelinit5

		.XDisp
		db $00,$08,$00,$08
		db $00,$08,$00,$08
		db $00,$08,$00,$08
		db $00,$08,$00,$08
		.YDisp
		db $00,$00,$08,$08
		db $00,$00,$08,$08
		db $00,$00,$08,$08
		db $00,$00,$08,$08
		.XSpeed
		db $02,$03,$02,$03
		db $02,$03,$02,$03
		db $02,$03,$02,$03
		db $02,$03,$02,$03
		.YSpeed
		db $F9,$F9,$FB,$FB
		db $FA,$FA,$FD,$FD
		db $FB,$FB,$FE,$FE
		db $FC,$FC,$FF,$FF


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
		LDX #$0A : STX $4206
		JSL GET_DIVISION
		LDA $4216
		CMP #$0005
		LDA $4214
		ADC #$0000
		SEC : SBC $20
		EOR #$FFFF
		INC A
		STA !BG2BaseV
		LDA #$00A0 : STA !LightR
		LDA #$00A0 : STA !LightG
		LDA #$00A0 : STA !LightB
		SEP #$30
		RTL




levelinit2D:
		STZ !SideExit
		LDX !Translevel
		LDA !Level : STA !LevelTable2,x
		LDA !LevelTable1,x
		AND.b #$60^$FF
		ORA #$40
		STA !LevelTable1,x
		LDA !Level+1
		BEQ $02 : LDA #$40
		ORA !LevelTable1,x
		STA !LevelTable1,x


		REP #$20
		LDA #$6800 : STA $400000+!MsgVRAM1
		LDA #$6880 : STA $400000+!MsgVRAM2
		LDA #$75C0 : STA $400000+!MsgVRAM3
		SEP #$20
		JSL level2D_HDMA
		RTL

levelinit2E:
		RTL

levelinit2F:
		JML levelinit2


	!CollapseStart	= $0100


levelinit32:
		JSL levelinit6
		LDA #$02 : STA $41				; enable window 1 on layer 1

		STZ $4324
		STZ $4374
		REP #$20
		LDA #$0D03 : STA $4320
		LDA #$0B00 : STA !HDMA2source
		LDA #$2601 : STA $4370				;\ clipping window HDMA
		LDA #$0C00 : STA !HDMA7source			;/

		LDA #!CollapseStart : STA !Level+6		; set starting point for collapsing level
		STA $0400					; also set for falling columns
		STZ $0402

		LDA.w #.BigMaskDyn : STA $0C
		CLC : JSL !UpdateGFX
		SEP #$20

		STZ !Level+3
		LDA #$04 : STA !41_WeatherFreq

		STZ $0A80				; clear chunk status
		STZ $0A87				; reset chunk size, baby!
		REP #$20				; A 16-bit
		LDA.w #.ChunkTable : STA $0A81		; set chunk data pointer
		LDA.w level6_BGColoursEnd		;\ set color 0x02
		STA $00A2				;/
		SEP #$20				; A 8-bit
		LDA #$F4 : STA !HDMA			; Enable HDMA on channels 2 and 4 through 7
		STZ !SideExit
		INC $14 : JSL level32_HDMA
		DEC $14 : JSL level32_HDMA
		JML level32


macro AdeptDyn(TileCount, SourceTile, DestVRAM)
	dw <TileCount>*$20
	dl <SourceTile>*$20+$32B008
	dw <DestVRAM>*$10+$6000
endmacro

	.BigMaskDyn
		dw ..End-..Start
		..Start
		%AdeptDyn(4, $100, $1CC)	;\
		%AdeptDyn(4, $110, $1DC)	; | big mask
		%AdeptDyn(4, $120, $1EC)	; |
		%AdeptDyn(4, $130, $1FC)	;/
		..End


.ChunkTable	dw $02D0,$0110 : db $06		; X, Y, size



levelinit39:
		LDA #$20
		STA !MarioYSpeed
		STA !P2YSpeed-$80
		STA !P2YSpeed
		STZ !P2VectorY-$80
		STZ !P2VectorY
		JSL level39
		JML InitCameraBox



; --Level MAIN--


level1:

;	JSL DisplayHurtbox_Main

	JSL DisplayHitbox1_Main
	JSL DisplayHitbox2_Main


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
.Return		RTL












level2:
	;	LDA #$00 : STA !GlobalPalset1
	;	LDA #$01 : STA !GlobalPalset2
	;	LDA #$20 : STA !GlobalPalsetMix

	STZ !P2Entrance-$80
	STZ !P2Entrance

		.ReloadSprites
		LDX #$00
		..loop
		LDA !SpriteLoadStatus,x : BEQ ..next
		STX $00
		LDY #$0F
	-	LDA $3230,y : BEQ +
		LDA $33F0,y
		CMP $00 : BEQ ..next
	+	DEY : BPL -
		..clear
		LDA #$00 : STA !SpriteLoadStatus,x
		..next
		INX : BNE ..loop

		RTL




level3:
		REP #$20
		LDA #$15E8				;\
		LDY #$01				; | Regular exit (screen 0x15)
		JSL END_Right				;/
		LDA !MsgTrigger				;\
		ORA !MsgTrigger+1 : BNE +		; |
		LDA #$1F : STA !MainScreen		; | everything on main screen
		STZ !SubScreen				; | nothing on subscreen
		+					;/

	;	LDA.b #.HDMA : STA !HDMAptr		;\
	;	LDA.b #.HDMA>>8 : STA !HDMAptr+1	; | Set up pointer
	;	LDA.b #.HDMA>>16 : STA !HDMAptr+2	;/

		LDA.b #level5_HDMA : STA !HDMAptr		;\
		LDA.b #level5_HDMA>>8 : STA !HDMAptr+1		; | Set up pointer
		LDA.b #level5_HDMA>>16 : STA !HDMAptr+2		;/

		RTL					; > Return

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
		SBC #$13 : BCC ..NoScroll
		STZ !EnableHScroll
		STZ !SideExit
		LDA $1B
		CMP #$14 : BCS ..NoScroll
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
		LDA #$0090 : STA $24			; | Y = 0x090
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
		STA $00
		LDA !OAMindex_p0 : TAX
		CLC : ADC #$0008
		STA !OAMindex_p0
		SEP #$20				; > A 8 bit
		LDA $00
		EOR #$FF				;\
		STA !OAM_p0+$000,x			; | Xpos of castle
		STA !OAM_p0+$004,x			;/
		LDA #$30 : STA !OAM_p0+$001,x		;\ Ypos of castle
		LDA #$40 : STA !OAM_p0+$005,x		;/
		LDA #$A2 : STA !OAM_p0+$002,x		;\ tile numbers of castle
		LDA #$A4 : STA !OAM_p0+$006,x		;/
		LDA #$0E				;\
		STA !OAM_p0+$003,x			; | YXPPCCCT of castle
		STA !OAM_p0+$007,x			;/
		XBA : BEQ +				;\
		LDA #$01				; | hi byte of castle
	+	ORA #$02				; |
		STA $00
		REP #$20
		TXA
		LSR #2
		TAX
		SEP #$20
		LDA $00
		STA !OAMhi_p0+$00,x			; |
		STA !OAMhi_p0+$01,x			;/
	..R	SEP #$30
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
		LDA #$40 : STA !SPC4			; dizzy OFF!! SFX
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
	-	LDA $3230,x : BEQ .TriggerSpawn
		DEX : BPL -
		BRA .NoSpawn

		.TriggerSpawn
		STX $00
		LDA.b #.Spawn : STA $3180
		LDA.b #.Spawn>>8 : STA $3181
		LDA.b #.Spawn>>16 : STA $3182
		JSR $1E80
		.NoSpawn


		REP #$20
		LDA.w #.HDMA : STA !HDMAptr+0
		LDA.w #.HDMA>>8 : STA !HDMAptr+1
		LDA $1A
		CMP #$1C40 : BCS .Bonus
		LDA #$1CF8				;\
		LDY #$01				; | Regular exit
		JML END_Right				;/

	.Bonus
		SEP #$30
		RTL


	.SpawnRate
	db $9F,$3F					; based on which quarter of the level the camera is on

	.SpawnX
	dw $0120
	dw $FFE0

		.Spawn
		PHB : PHK : PLB
		PHP
		SEP #$30
		LDX $00
		LDA !RNG
		AND #$F0
		CLC : ADC $1C
		CLC : ADC $7888
		STA $3210,x
		LDA $1D
		ADC $7889
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
		PLP
		PLB
		RTL


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
		LDA #$40 : STA !SPC4			; dizzy OFF!! SFX
		+


		LDA #$01 : STA !DecompBuffer+$10F0 : STA !DecompBuffer+$10F4
		LDA #$00 : STA !DecompBuffer+$10F3 : STA !DecompBuffer+$10F7


		REP #$20
		LDA #$0E02 : STA $4320					;\
		LDA $14							; |
		AND #$0001						; | layer 1 HDMA
		BEQ $03 : LDA #$0004					; |
		ORA.w #!DecompBuffer+$10F0 : STA !HDMA2source		;/

		LDA #$0F02 : STA $4330					;\
		LDA $14							; |
		AND #$0001						; | layer 2 horizontal HDMA
		BEQ $03 : LDA #$0040					; |
		ORA.w #!DecompBuffer+$1100 : STA !HDMA3source		;/

		LDA #$1002 : STA $4340					;\
		LDA $14							; |
		AND #$0001						; | layer 2 stretch HDMA
		BEQ $03 : LDA #$0400					; |
		ORA.w #!DecompBuffer+$1200 : STA !HDMA4source		;/

		LDA #$3101 : STA $4350					;\ color math HDMA
		LDA #$0A00 : STA !HDMA5source				;/

		SEP #$20
		LDA #$40
		STA $4324
		STA $4334
		STA $4344
		STZ $4354

		LDA #$3C : TSB !HDMA

		LDA #$1F : STA !MainScreen
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
		LDA !DecompBuffer+$1040,x
		SEC : SBC $1C
		SEC : SBC $7888
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



; !DecompBuffer+$1000 - X table
; !DecompBuffer+$1040 - Y table
; !DecompBuffer+$10F0 - layer 1 HDMA table
; !DecompBuffer+$10FA - intensity factor
; !DecompBuffer+$10FC - added during flip
; !DecompBuffer+$10FE - EOR'd during flip

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

		PHB : LDX.b #!DecompBuffer>>16
		PHX : PLB


		LDA.l !Level+2 : BEQ +
		DEC A
		STA.l !Level+2
		AND #$001F
	+	TAY

		REP #$10
		LDY #$003E
		STZ.w !DecompBuffer+$10FE
		STZ.w !DecompBuffer+$10FC
		LDA $1A
		LSR A
		EOR #$FFFF
		CLC : ADC.l !Level+2
		ASL #3
		AND #$03FF
		CMP #$0200 : BCC +
		DEC.w !DecompBuffer+$10FE
		INC.w !DecompBuffer+$10FC
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
	++	STA.w !DecompBuffer+$10FA

	-	LDA.l !TrigTable,x
		LSR #5
		STA.l $2251
		LDA.w !DecompBuffer+$10FA : STA.l $2253
		BRA $00 : NOP
		LDA.l $2306
		LSR #4
		EOR.w !DecompBuffer+$10FE
		CLC : ADC $1C
		CLC : ADC.l $7888
		CLC : ADC.w !DecompBuffer+$10FC
		AND #$01FF
		ORA #$2000
		STA.w !DecompBuffer+$1040,y
		LDA $1A
		ORA #$2000
		STA.w !DecompBuffer+$1000,y
		TXA
		CLC : ADC #$0020
		AND #$01FF
		TAX
		CMP #$0020 : BCS +
		LDA.w !DecompBuffer+$10FE
		EOR #$FFFF
		STA.w !DecompBuffer+$10FE
		LDA.w !DecompBuffer+$10FC
		EOR #$0001
		STA.w !DecompBuffer+$10FC
	+	DEY #2 : BPL -

		LDA.l !TrigTable,x
		LSR #5
		STA.l $2251
		LDA.w !DecompBuffer+$10FA : STA.l $2253
		LDA $14
		AND #$0001
		BEQ $03 : LDA #$0004
		TAX
		LDA.l $2306
		LSR #4
		EOR.w !DecompBuffer+$10FE
		CLC : ADC $1C
		CLC : ADC.l $7888
		CLC : ADC.w !DecompBuffer+$10FC
		AND #$01FF
		STA.w !DecompBuffer+$10F1,x			; layer 1 HDMA value

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
		LDA #$0010 : STA !DecompBuffer+$1100,x
		LDA ..HTable,y
		AND #$00FF
		STA $2251
		LDA !DecompBuffer+$10FA : STA $2253
		BRA $00 : NOP
		LDA $2306
		LSR #5
		CLC : ADC $1E
		STA !DecompBuffer+$1101,x
		INX #3
		TXA
		AND #$003F
		CMP #$0030 : BCC -
		LDA #$0000 : STA !DecompBuffer+$1100,x


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
		LDA #$0001 : STA !DecompBuffer+$1200,x
		LDA ..ZTable,y
		AND #$00FF
		SEC : SBC #$001B
		STA $2251
		LDA !DecompBuffer+$10FA : STA $2253
		BRA $00 : NOP
		LDA $2306
		LSR #5
		CLC : ADC $20
		STA !DecompBuffer+$1201,x
		INX #3
		INY
		TXA
		AND #$03FF
		CMP #$0300 : BCC -
		LDA #$0000 : STA !DecompBuffer+$1200,x

		SEP #$10

		JSL !GetVRAM
		LDA #$0080 : STA !VRAMbase+!VRAMtable+$00,x
		LDA.w #!DecompBuffer+$1000 : STA !VRAMbase+!VRAMtable+$02,x
		LDA.w #!DecompBuffer>>16 : STA !VRAMbase+!VRAMtable+$04,x
		LDA.l !2109						;\
		AND #$00FC						; | layer 3 address
		XBA							; |
		STA !VRAMbase+!VRAMtable+$05,x				;/
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
		LDA #$02 : STA !GlobalLight1

		REP #$20
		LDA #$07E8
		JSL EXIT_Right


		.NoExit
		PHB : PHK : PLB
		REP #$30
		LDA !OAMindex_p0 : TAX
		CLC : ADC #$0010
		STA !OAMindex_p0
		LDY #$0000
	-	LDA .SunTilemap,y : STA !OAM_p0,x
		INY #2
		INX #2
		CPY #$0010 : BCC -
		TXA
		SEC : SBC #$0010
		LSR #2
		TAX
		LDA #$0202
		STA !OAMhi_p0+$00,x
		STA !OAMhi_p0+$02,x
		SEP #$30
		PLB

		LDA.b #.HDMA : STA !HDMAptr		;\
		LDA.b #.HDMA>>8 : STA !HDMAptr+1	; | Set up pointer
		LDA.b #.HDMA>>16 : STA !HDMAptr+2	;/
		RTL					; > Return

		.SunTilemap
		db $60,$30,$88,$0E
		db $68,$30,$88,$4E
		db $60,$40,$88,$8E
		db $68,$40,$88,$CE


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
		JSL GET_DIVISION			; | Next chunk is set to 40%
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

		LDA !Level
		CMP #$0003 : BEQ +

	;	LDA !BG3BaseSettings			;\ > Include LM initial offset
	;	AND #$00F8				; |
	;	ASL A					; |
	;	STA $02					; |
		LDA $1A					; |
		ASL #3					; |
		CLC : ADC $1A				; |
		LSR #3					; |
		STA $22					; | BG3 scroll = 112.5%
	;	LDA $1C					; | (this only applies if BG3 scroll is turned off in LM)
	;	SEC : SBC #$00C0			; | (used for ramparts in castle rex)
	;	STA $00					; |
	;	ASL #3					; |
	;	CLC : ADC $00				; |
	;	LSR #3					; |
	;	CLC : ADC #$00C4			; |
	;	CLC : ADC $02				; |
	;	STA $24					;/
	+	PLP
		RTL



; see level init for info on RAM use

level6:
		REP #$20
		LDA #$0FE8 : JSL EXIT_FADE_Right

		LDA.b #.HDMA : STA !HDMAptr+0
		LDA.b #.HDMA>>8 : STA !HDMAptr+1
		LDA.b #.HDMA>>16 : STA !HDMAptr+2
		RTL


		.HDMA
		PHB
		PHP
		SEP #$30
		LDA.b #MAIN_Level>>16
		PHA : PLB
		LDA $14
		AND #$01
		ASL #4
		TAX
		LDA $1F					;\
		LSR A					; |
		STA $0A08,x				; | Update BG2 Hscroll
		LDA $1E					; |
		ROR A					; |
		STA $0A07,x				;/
		STX !HDMA6source			; update table pointer
		LDA #$17 : STA !MainScreen		;\ Main/sub screen settings
		STZ !SubScreen				;/
		LDA !Level+3				;\
		CMP #$04				; |
		BEQ .Return				; |
		LDA $9D					; | Don't do anything past animation frame 0x3FF
		ORA !Pause				; |
		BEQ .Process				; |
		JMP .CGRAM				; |
.Return		PLP					; |
		PLB					; |
		RTL					;/

.Process	REP #$20				;\
		LDA $1A					; |
		LSR #3					; |
		DEC A					; |
		BMI .Regular				; |
		CMP !Level+2 : BCC .Regular		; |
		STA !Level+2				; |
		SEP #$20				; |
		BRA .StretchGreen			; |
.Regular	SEP #$20				; |
		LDA $14					; |
		AND #$1F : BNE .HandleHDMA		; |
.StretchGreen	LDX #$00				; |
	-	LDA $0800,x				; |
		CMP #$26 : BEQ +			; | Increment timer and stretch green
		INC A					; |
		STA $0800,x				; |
		BRA ++					; |
	+	INX #2					; |
		CPX #$14 : BNE -			; |
	++	REP #$20				; |
		INC !Level+2				;/

.HandleHDMA	REP #$20
		LDA !Level+2
		CMP #$0100
		BCC $03 : LDA #$0100
		LSR #3
		SEP #$20
		STA !GlobalLightMix


		REP #$20			;\
		LDA !Level+2			; |
		SEC : SBC #$0108		; |
		BPL $03 : LDA #$0000		; |
		LSR #4				; |
		CMP #$001F			; |
		BCC $03 : LDA #$001F		; |
		STA $00				; | fade in star palette
		ASL #5				; |
		ORA $00				; |
		ASL #5				; |
		ORA $00				; |
		LDX #$14			; |
	-	STA $00A0,x			; |
		DEX #2 : BPL -			; |
		SEP #$20			;/



		LDA $14				;\
		LSR A				; |
		AND #$07 : BEQ .NoHSL		; |
		ASL #4				; |
		ORA #$02			; |
		TAX				; |
		LDY #$0E			; |
		LDA $14				; |
		LSR A : BCS .UploadColor	; |
		.MixColor			; |
		LDA !Level+3 : BEQ +		; |
		LDA #$00 : BRA ++		; | alternate between converting and uploading
	+	LDA !Level+2			; |
		BNE $01 : INC A			; |
		EOR #$FF : INC A		; |
	++	JSL !MixHSL			; |
		BRA .NoHSL			; |
		.UploadColor			; |
		REP #$30			; |
		TXA				; |
		ORA #$0200			; |
		TAX				; |
		LDY #$000E			; |
		JSL !HSLtoRGB			; |
		SEP #$30			; |
		.NoHSL				;/


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
		BCC +					; | Update color 0x02
		LDA.w #.BGColoursEnd-.BGColours		; |
	+	TAX					; |
		LDA.l .BGColours,x : STA $00A2		; |
		SEP #$20				;/

		LDA !Level+3				;\
		BNE .OffScreen				; |
		LDA !Level+2				; | Don't draw sun if it's off-screen
		CMP #$A0				; |
		BCC .DrawSun				;/
.OffScreen	PLP
		PLB					; |
		RTL

.DrawSun	LDA !Level+3
		LSR A
		LDA !Level+2
		ROR A
		STA $00

		REP #$30
		LDA !OAMindex_p0 : TAX
		CLC : ADC #$0010
		STA !OAMindex_p0
		SEP #$20
		LDA #$60					;\
		SEC : SBC $00					; |
		STA !OAM_p0+$000,x				; |
		STA !OAM_p0+$008,x				; | Xpos of sun
		LDA #$68					; |
		SEC : SBC $00					; |
		STA !OAM_p0+$004,x				; |
		STA !OAM_p0+$00C,x				;/
		LDA #$60					;\
		CLC : ADC $00					; |
		STA !OAM_p0+$001,x				; |
		STA !OAM_p0+$005,x				; | Ypos of sun
		LDA #$70					; |
		CLC : ADC $00					; |
		STA !OAM_p0+$009,x				; |
		STA !OAM_p0+$00D,x				;/
		LDA #$EE					;\
		STA !OAM_p0+$002,x				; |
		STA !OAM_p0+$006,x				; | tile numbers of sun
		STA !OAM_p0+$00A,x				; |
		STA !OAM_p0+$00E,x				;/
		LDA #$0F : STA !OAM_p0+$003,x			;\
		LDA #$4F : STA !OAM_p0+$007,x			; | YXPPCCCT of sun
		LDA #$8F : STA !OAM_p0+$00B,x			; |
		LDA #$CF : STA !OAM_p0+$00F,x			;/
		REP #$20					;\
		TXA						; |
		LSR #2						; |
		TAX						; | tile size of sun
		LDA #$0202					; |
		STA !OAMhi_p0+$00,x				; |
		STA !OAMhi_p0+$02,x				;/
		PLP
		PLB					; |
		RTL

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

		JSL WARP_BOX
		db $04 : dw $12D0,$01F0 : db $50,$10

		JSL WARP_BOX
		db $04 : dw $1910,$01F0 : db $50,$10


		LDA $1B					;\
		CMP #$15 : BCC .NoHammers		; | only spawn hammers on screens 15-17
		CMP #$18 : BCS .NoHammers		;/
		LDA $14
		AND #$FC : BEQ .NoHammers
		AND #$1C : BNE .NoHammers
		LDX.b #!Ex_Amount-1
	-	LDA !Ex_Num,x : BEQ +
		DEX : BPL -
		BRA .NoHammers
	+	LDA $14
		AND #$03
		TAY
		LDA .FallingHammerData,y : STA !Ex_XLo,x
		LDA .FallingHammerData+4,y : STA !Ex_XHi,x
		LDA $1C
		SEC : SBC #$10
		STA !Ex_YLo,x
		LDA $1D
		SBC #$00
		STA !Ex_YHi,x
		LDA #$04+!ExtendedOffset : STA !Ex_Num,x
		LDA #$40 : STA !Ex_YSpeed,x
		.NoHammers


		LDA.b #HDMA3DWater : STA !HDMAptr+0
		LDA.b #HDMA3DWater>>8 : STA !HDMAptr+1
		LDA.b #HDMA3DWater>>16 : STA !HDMAptr+2

		LDA #$DC : STA !Level+2

		JSL level35_Graphics			; returns 16-bit A

		SEP #$30
		RTL

	.FallingHammerData
		db $D0,$90,$D0,$D0	; X lo byte
		db $15,$17,$16,$17	; X hi byte


	;	REP #$20
	;	LDA.w #.RoomPointers
	;	JML LoadCameraBox


		.RoomPointers
		dw .ScreenMatrix
		dw .BoxTable
		dw .DoorList
		dw .DoorTable




;	Key ->	   X  Y  W  H  S  FX FY
;		   |  |  |  |  |  |  |
;		   V  V  V  V  V  V  V
;
.BoxTable
.Box0	%CameraBox(0, 0, 27, 1, $FF, 0, 0)

.ScreenMatrix	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

.DoorList	db $FF			; no doors
.DoorTable



	HDMA3DWater:
		PHP
		SEP #$20
		LDA.b #.SA1 : STA $3180
		LDA.b #.SA1>>8 : STA $3181
		LDA.b #.SA1>>16 : STA $3182
		JSR $1E80
		PLP
		PHP
		PHB : PHK : PLB			; start of bank wrapper has to go here so .Gradient can be read
		REP #$20
		LDA.w #.Gradient
		JML level35_HDMA_3DWater

	.SA1
		PHB
		PHP
		SEP #$20
		LDA.b #Water3D_Calc>>16
		PHA : PLB
		REP #$30
		JSL Water3D_Calc
		PLP
		PLB
		RTL

.Gradient
		dw ..end-..start
		dw $000C
		..start
		dw $4CA0
		dw $48A0
		dw $4080
		dw $3C80
		dw $3880
		dw $3060
		dw $2C60
		dw $2860
		dw $2040
		dw $1C40
		dw $1840
		dw $1020
		dw $0C20
		dw $0400
		..end


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

		LDA #$01E8				;\
		LDY #$01				; | Regular exit
		JML END_Right				;/


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
		RTL



level2A:
		REP #$20
		LDA #$0000 : JSL EXIT_Up
		RTL


level2B:

	; WARNING: EXTREMELY SCUFFED
		.SlantFix
		LDA !P2SlantPipe-$80 : BNE ..tempslant
		..normal
		LDA #$1F : STA !MainScreen
		STZ !SubScreen
		BRA ..done
		..tempslant
		LDA #$1D : STA !MainScreen
		LDA #$02 : STA !SubScreen
		..done

		STZ !SideExit
		LDA $1B
		BEQ .NoExit
		INC !SideExit
		.NoExit

		REP #$20
		LDA #$06E8
		PHK : PEA level5_NoExit-1
		JML EXIT_FADE_Right


level2C:
		LDX #$0F			;\
	-	LDA $3230,x			; | look for a killed sprite (states 2-7)
		CMP #$02 : BCC +		; |
		CMP #$08 : BCS +		;/
		LDY $3240,x			;\ must be on Y screen 00-03
		CPY #$04 : BCS +		;/
		LDA .Table,y : TSB $6DF5	; if there is a rex, it can talk
	+	DEX : BPL -			; Loop

		REP #$20
		LDA.w #.Table1 : JSL TalkOnce
		LDA.w #.Table2 : JSL TalkOnce
		LDA.w #.Table3 : JSL TalkOnce


		LDA $1A
		CMP #$00E0 : BNE +
		LDA $1C : BNE +
		LDA $6DF5
		AND #$0008 : BNE +
		LDA.w #!MSG_CaptainWarrior_Warning : STA !MsgTrigger
		LDA #$0008 : TSB $6DF5
		+

		LDA !P2XPosLo-$80
		CMP #$0148 : BCC .NoEntry1
		CMP #$0168 : BCS .NoEntry1
		SEP #$20
		LDA $6DA6
		AND #$08 : BEQ .NoEntry1
		LDA !P2Blocked-$80
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
		LDA #$06 : STA $71
		STZ $88
		STZ $89
		LDA #$80 : STA !SPC3
		RTL
		.NoEntry2

		REP #$20
		LDA !P2YPosLo
		CMP #$00A1 : BCS +
		LDA #$00E0 : STA $00
		LDA #$0000 : JSL SCROLL_UPRIGHT
		SEP #$20
		RTL
	+	STZ !Level+2
		SEP #$20
		LDA #$01
		STA !EnableVScroll
		RTL


		.Table
		db $00,$04,$02,$01

		;   ID       Xpos  Ypos       W   H        MSG
.Table1		db $00 : dw $0150,$0360 : db $70,$30 : dw !MSG_CastleRex_Rex_Warning_1
.Table2		db $02 : dw $0020,$0280 : db $50,$40 : dw !MSG_CastleRex_Rex_Warning_2
.Table3		db $04 : dw $0090,$0120 : db $20,$30 : dw !MSG_CastleRex_Rex_Warning_3



level2D:	LDA.b #.HDMA : STA !HDMAptr+0
		LDA.b #.HDMA>>8 : STA !HDMAptr+1
		LDA.b #.HDMA>>16 : STA !HDMAptr+2
		RTL

		.HDMA
		PHP
		REP #$20
		STZ $22
		STZ $24
		LDA $14
		AND #$0007
		BNE $03 : DEC !Level+2
		LDA !Level+2 : STA $1E
		PLP
		RTL

level2E:
	RTL
level2F:
	RTL

level32:
		LDA.b #.HDMA : STA.l !HDMAptr+0
		LDA.b #.HDMA>>8 : STA.l !HDMAptr+1
		LDA.b #.HDMA>>16 : STA.l !HDMAptr+2


		REP #$20
		LDA #$0080 : STA !LightR
		LDA #$0100 : STA !LightG
		LDA #$00E0 : STA !LightB
		SEP #$20



		LDA #$7F : TRB !Level+4
		LDX #$0F
	-	LDA $3230,x
		CMP #$08 : BNE +
		LDA $3590,x
		AND #$08 : BEQ +
		LDA $35C0,x
		CMP #$05 : BNE +
		LDA $3250,x
		CMP #$0D : BNE +
		LDA $BE,x : BNE +
		LDA $3220,x
		ASL A
		ROL A
		AND #$01
		STA $3320,x
		INC A : TSB !Level+4
		LDA #$0F : STA $32D0,x
	+	DEX : BPL -

		REP #$20
		LDA !Level+3
		ASL A
		AND #$00FF
		STA $02
		LDA #$0D70
		SEC : SBC $1A
		CMP #$0100 : BCC .GoodX
		CMP #$FFE0 : BCS $03 : JMP .Nope
	.GoodX	STA $00
		CLC : ADC #$0010
		STA $0E
		LDA $14
		AND #$00FF
		LSR #4
		SEC : SBC #$0008
		BPL $03 : EOR #$FFFF
		CLC : ADC #$0108
		SEC : SBC $1C
		SEC : SBC $02
		CMP #$00D8 : BCC .GoodY
		CMP #$FFE0 : BCS $03 : JMP .Nope
	.GoodY	LDY !OAMindex
		SEP #$20
		STA !OAM+$01,y
		STA !OAM+$05,y
		CLC : ADC #$10
		STA !OAM+$09,y
		STA !OAM+$0D,y
		LDA $00
		STA !OAM+$00,y
		STA !OAM+$08,y
		LDA $0E
		STA !OAM+$04,y
		STA !OAM+$0C,y
		LDA #$CC : STA !OAM+$02,y
		LDA #$CE : STA !OAM+$06,y
		LDA #$EC : STA !OAM+$0A,y
		LDA #$EE : STA !OAM+$0E,y
		LDA #$39
		STA !OAM+$03,y
		STA !OAM+$07,y
		STA !OAM+$0B,y
		STA !OAM+$0F,y

		LDA !Level+4
		AND #$03 : BNE +
		INC !Level+3
		LDA !Level+4 : BMI +
		ORA #$80
		STA !Level+4
		REP #$20
		LDA #$0D60 : STA $0A83
		LDA #$0130 : STA $0A85
		JSL PuffTile
		LDA #$0D70 : STA $0A83
		JSL PuffTile
		LDA #$0D80 : STA $0A83
		JSL PuffTile
		LDA #$0D90 : STA $0A83
		JSL PuffTile
		SEP #$20
		LDA #$10 : STA !SPC1			; magikoopa sound

	+	TYA
		CLC : ADC #$10
		STA !OAMindex
		SEC : SBC #$10
		LSR #2
		TAY
		LDA $01
		AND #$01
		ORA #$02
		STA !OAMhi+0,y
		STA !OAMhi+2,y
		LDA $0F
		AND #$01
		ORA #$02
		STA !OAMhi+1,y
		STA !OAMhi+3,y
		LDA #$03 : JSL Weather
		BRA .WeatherDone

	.Nope	SEP #$20
		LDA #$02 : JSL Weather
		.WeatherDone


		LDA $1B
		CMP #$0E : BNE .NoExit
		REP #$20
		LDA #$00A0 : JSL EXIT_Up
		.NoExit


		LDA #$01				;\
		AND $0A80 : BNE ++			; |
		LDX #$0F				; |
	-	LDA $3230,x : BEQ +			; |
		LDA $35C0,x				; |
		CMP #$06 : BNE +			; |
		LDA $3280,x				; | load chunks when adept shamans die
		AND #$03				; |
		CMP #$02 : BNE +			; |
		LDA #$01 : JSL LoadChunk		; |
		BRA ++					; |
	+	DEX : BPL -				; |
		++					;/

		LDA $0A87 : BEQ .Return
		LDA $14
		AND #$1F : BNE $04 : JML DestroyChunk

	.Return	RTL



		.HDMA
		PHB : PHK : PLB
		PHP
		REP #$30


		LDA $0402 : BNE $03 : JMP .NotCollapsingYet
		LDA $14
		AND #$0003 : BEQ .Smoke
		LDA $14
		INC A
		AND #$0003 : BEQ .Debris
		JMP .CheckTimer

		.Debris
		LDA !RNG
		AND #$00F0
		ORA #$0008
		CLC : ADC $1A
		PHA
		AND #$FF00
		XBA
		TAX
		PLA
		AND #$00FF
		LSR #4
		CLC : ADC #$00C0
	-	DEX : BMI +
		CLC : ADC !LevelHeight
		BRA -
	+	TAX
		LDA $40C800,x
		AND #$00FF
		CMP #$0025 : BEQ ..fail

		SEP #$30
		LDX.b #!Ex_Amount-1
	..loop	LDA !Ex_Num,x : BEQ ..spawn
		DEX : BPL ..loop
		BRA ..fail
		..spawn
		LDA #$01+!MinorOffset : STA !Ex_Num,x
		LDA !RNG
		CLC : ADC $1A
		STA !Ex_XLo,x
		LDA $1B
		ADC #$00
		STA !Ex_XHi,x
		LDA #$B8 : STA !Ex_YLo,x
		STZ !Ex_YHi,x
	..fail	REP #$30
		JMP .CheckTimer


		.Smoke
		LDA !Level+6
		CLC : ADC #$0008
		AND #$FF00
		XBA
		TAX
		LDA !Level+6
		CLC : ADC #$0008
		AND #$00FF
		LSR #4
		CLC : ADC !LevelHeight		;\ start at the bottom
		SEC : SBC #$0010		;/
	-	DEX : BMI +
		CLC : ADC !LevelHeight
		BRA -
	+	TAX
		LDY #$0000
	-	LDA $40C800,x
		AND #$00FF
		CMP #$0025 : BEQ +
		INY
		CPY #$000E : BEQ +
		TXA
		SEC : SBC #$0010
		TAX
		BRA -

	+	TYA
		ASL #4
		INC A
		STA $00

		SEP #$30
		LDX.b #!Ex_Amount-1
	..loop	LDA !Ex_Num,x : BEQ ..spawn
		DEX : BPL ..loop
		BRA ..fail
		..spawn
		LDA #$01+!ExtendedOffset : STA !Ex_Num,x
		LDA !RNG
		AND #$F0
		CMP $00 : BCS ..fail
		STA $00
		LDA !LevelHeight
		SEC : SBC $00
		STA !Ex_YLo,x
		LDA !LevelHeight+1
		SBC #$00
		STA !Ex_YHi,x
		LDA #$0B : STA !Ex_Data2,x
		REP #$20
		LDA !RNG
		AND #$001F
		SEC : SBC #$0010
		CLC : ADC !Level+6
		SEP #$20
		STA !Ex_XLo,x
		XBA : STA !Ex_XHi,x
		STZ !Ex_XSpeed,x
		STZ !Ex_YSpeed,x
	..fail	REP #$30
		BRA .CheckTimer


		.NotCollapsingYet
		LDA $1A
		CMP #!CollapseStart : BCS $03 : JMP .HandleColumns_done
		.CheckTimer

		LDA #$001F : STA $00
		LDA !Level+6
		CMP $1A : BCS +
		LDA #$0007 : STA $00
		+

		LDA $14
		AND $00 : BEQ $03 : JMP .NoCollapse

		LDX $0402					;\
		STZ $0404,x					; |
		STZ $0406,x					; | spawn new collapsing column
		INX #4						; |
		STX $0402					;/
		LDA !ShakeTimer
		ORA #$0010
		STA !ShakeTimer

		; update map16 to remove interaction
		; TO DO: non-interaction page without blanking the column upon reload
		LDA !Level+6
		CLC : ADC #$0008
		AND #$FF00
		XBA
		TAX
		LDA !Level+6
		CLC : ADC #$0008
		AND #$00FF
		LSR #4
	-	DEX : BMI +
		CLC : ADC !LevelHeight
		BRA -
	+	TAX
		LDA !LevelHeight
		LSR #4
		TAY
	-	SEP #$20
		LDA #$25 : STA $40C800,x
		LDA #$00 : STA $41C800,x
		REP #$20
		DEY : BEQ +
		TXA
		CLC : ADC #$0010
		TAX
		BRA -

	+	LDA !Level+6					;\
		CLC : ADC #$0010				; | X of next column to fall
		STA !Level+6					;/
		.NoCollapse


		.HandleColumns
		LDX $0402
	..loop	DEX #4 : BMI ..done
		LDA $0404,x
		INC A
		CMP #$002A : BCC ..down
		PHX
		LDX #$0000
	-	CPX $0402 : BCS ..reorderdone
		LDA $0408,x : STA $0404,x
		LDA $040A,x : STA $0406,x
		INX #4
		BRA -
		..reorderdone
		LDA $0400					;\
		CLC : ADC #$0010				; | update X of currently collapsing area
		STA $0400					;/
		LDA $0402
		SEC : SBC #$0004
		BPL $03 : LDA #$0000
		STA $0402
		PLX
		BRA ..loop
	..down	STA $0404,x
		TAY
		LDA .ChunkY,y
		AND #$00FF
		STA $0406,x
		BRA ..loop
		..done

		SEP #$30
		LDA $14
		AND #$01
		ASL #4
		TAX
		LDA $1F						;\
		LSR A						; |
		STA $0A08,x					; | Update BG2 Hscroll
		LDA $1E						; |
		ROR A						; |
		STA $0A07,x					;/
		STX !HDMA6source				; update source for BG2
		STX !HDMA2source				; update source for BG1

		LDA #$01 : STA $0B00,x
		STZ $0B05,x

		LDA $14
		AND #$01
		LSR A
		ROR A
		AND #$80
		TAX
		STX !HDMA7source				; update source for clipping window
		LDA #$01 : STA $0C00,x				;\
		LDA #$FF : STA $0C01,x				; | pre-emptively disable clipping window
		STZ $0C02,x					; |
		STZ $0C03,x					;/

		REP #$20					;\
		LDX !HDMA6source				; | layer 1 positions in hdma table
		LDA $1A : STA $0B01,x				; |

		; LDA $14
		; AND #$0003
		; CMP #$0003
		; BNE $03 : LDA #$0001
		; DEC A
		; STA $0E
		LDA $1C
		CLC : ADC $7888
		STA $0B03,x

	;	LDA $1C : STA $0B03,x				;/
		STZ $22						;\
		STZ $24						; |
		LDA $1A						; |
		AND #$01FF					; |
		ORA #$2000					; |
		STA $00						; |
		LDA $1C						; | set up mode 2 table
		CLC : ADC $7888
	;CLC : ADC $0E
		AND #$01FF					; |
		ORA #$2000					; |
		STA $02						; |
		LDX #$3E					; |
	-	LDA $00 : STA !DecompBuffer+$1000,x		; |
		LDA $02 : STA !DecompBuffer+$1040,x		; |
		DEX #2 : BPL -					;/


		.HandleDisplacement
		LDA $0400					; left edge of collapsing area
		SEC : SBC $1A
		STA $0E
		LDY #$00
	..loop	CPY $0402 : BCC ..process
		JMP ..done

		..process
		LDA $0E : BEQ ..bg1plusfirst
		CMP #$00F8 : BCC ..full
		CMP #$0100 : BCC ..onecolumn
		CMP #$FFF1 : BCC ..next
		CMP #$FFF9 : BCC ..bg1

		..bg1plusfirst
		LDX !HDMA6source
		LDA $0B03,x
		SEC : SBC $0406,y
		STA $0B03,x
		LDX #$00 : BRA +

		..bg1
		LDX !HDMA6source
		LDA $0B03,x
		SEC : SBC $0406,y
		STA $0B03,x
		BRA ..next

		..onecolumn
		LSR #3
		ASL A
		TAX
		LDA $0E
		AND #$0007
		BNE $02 : DEX #2
	+	LDA !DecompBuffer+$1040,x
		AND #$01FF
		SEC : SBC $0406,y
		AND #$01FF
		ORA #$2000
		STA !DecompBuffer+$1040,x
		BRA ..next

		..full
		LSR #3
		ASL A
		TAX
		LDA $0E
		AND #$0007
		BNE $02 : DEX #2
		LDA !DecompBuffer+$1040,x
		AND #$01FF
		SEC : SBC $0406,y
		AND #$01FF
		ORA #$2000
		STA !DecompBuffer+$1040,x
		STA !DecompBuffer+$1042,x

		..next
		LDA $0E
		CLC : ADC #$0010
		STA $0E
		INY #4
		JMP ..loop
		..done



; left edge is !CollapseStart
; right edge is !Level+6
; start with R = !Level+6, for scanlines = Ydisp of last column
; then R = !Level+6 - 16, for scanlines = Ydisp of second to last column - Ydisp of last column
; repeat for all columns
; then set R = $0400
;

; $00 - left edge of window area
; $02 - right edge of top row
; $04 - left edge of top row
; $0E - keeping track of current Xpos of window's right edge

		.HandleClipping
		LDX !HDMA7source
		LDY $0402
		LDA #$0000 : STA $0406,y		; clear this to make the math simpler later
		LDA #!CollapseStart
		SEC : SBC $1A
		BPL $03 : LDA #$0000
		CMP #$00FF
		BCC $03 : LDA #$00FF
		STA $00

		LDA $0400
		CMP !Level+6 : BNE $03 : JMP ..done	; exception: collapse has not started yet
		SEC : SBC $1A
		BPL $03 : LDA #$0000
		CMP #$00FF
		BCC $03 : LDA #$00FF
		STA $02

		LDA !Level+6
		DEC A
		SEC : SBC $1A
		STA $0E
		BPL $03 : LDA #$0000
		CMP #$00FF
		BCC $03 : LDA #$00FF
		STA $04
		LDA $0E : BEQ +				; if right edge is exactly 0, it is not off-screen
		CMP $00 : BEQ ..done			; no clipping if both are off-screen at the same side
	+	SEP #$20

		..loop
		DEY #4 : BMI ..finish
		LDA $0406,y
		SEC : SBC $040A,y
		SEC : SBC $7888
		BPL ..small

		..big
		LSR A
		STA $0C00,x
		BCC $01 : INC A
		STA $0C03,x
		LDA $00
		STA $0C01,x
		STA $0C04,x
		LDA $04
		STA $0C02,x
		STA $0C05,x
		INX #3
		BRA ..shared
		..small
		STA $0C00,x
		LDA $00 : STA $0C01,x
		LDA $04 : STA $0C02,x
		..shared
		INX #3
		REP #$20
		LDA $0E
		SEC : SBC #$0010
		STA $0E : BMI ..offscreen
		CMP #$00FF
		BCC $03 : LDA #$00FF
		STA $04
		SEP #$20
		BRA ..loop

		..offscreen
		SEP #$20

		..finish
		LDA $00 : STA $0C01,x
		LDA $02
		BEQ $01 : DEC A
		STA $0C02,x
		BNE +
		LDA #$FF : STA $0C01,x
	+	LDA #$01 : STA $0C00,x
		STZ $0C03,x
		REP #$20

		..done


		JSL !GetVRAM
		LDA #$0080 : STA !VRAMbase+!VRAMtable+$00,x
		LDA.w #!DecompBuffer+$1000 : STA !VRAMbase+!VRAMtable+$02,x
		LDA.w #!DecompBuffer>>16 : STA !VRAMbase+!VRAMtable+$04,x
		LDA !2109
		AND #$00FC
		XBA
		STA !VRAMbase+!VRAMtable+$05,x
		PLP
		PLB
		RTL


		.ChunkY
		db $01,$01,$02,$02,$03,$04,$05,$07,$09,$0B,$0E,$11,$14,$18,$1C,$20
		db $25,$2A,$2F,$35,$3B,$41,$48,$4F,$57,$5F,$67,$6F,$77,$7F,$87,$8F
		db $97,$9F,$A7,$AF,$B7,$BF,$C7,$CF,$D7,$DF


; !Level+6	-	next column that will fall
; $0400		-	X of last column that disappeared
; $0402		-	how many falling columns there are
; $0404 +2X	-	timer for X falling column
; $0406 +2X	-	displacement of X falling column





;	$0A80:		chunk status (each bit represents a chunk, so bit 0 = chunk 1, bit 1 = chunk 2 etc.)
;	$0A81-$0A82:	16-bit pointer to chunk data (uses B as bank)
;	$0A83-$0A84:	X coord of section being destroyed
;	$0A85-$0A86:	Y coord of section being destroyed
;	$0A87:		how many rows are left to destroy

	DestroyChunk:
		REP #$20
		JSL PuffTile
		LDA $0A83 : PHA
		CLC : ADC #$0010
		STA $0A83
		JSL PuffTile
		PLA : STA $0A83
		LDA $0A85
		CLC : ADC #$0010
		STA $0A85
		SEP #$20
		DEC $0A87
		LDA #$09 : STA !SPC4			; > Boom sound
	.Return	RTL


	PuffTile:
		PHP
		PEI ($98)
		PEI ($9A)
		REP #$20
		LDA $0A83 : STA $9A
		LDA $0A85 : STA $98
		LDX #$02 : STX $9C
		JSL $00BEB0
		PLA : STA $9A
		PLA : STA $98

		SEP #$30
		LDX.b #!Ex_Amount-1
	-	LDA !Ex_Num,x : BEQ .Slot
		DEX : BPL -
		BMI .Return
	.Slot	LDA #$01+!SmokeOffset : STA !Ex_Num,x
		LDA $0A83 : STA !Ex_XLo,x
		LDA $0A84 : STA !Ex_XHi,x
		LDA $0A85 : STA !Ex_YLo,x
		LDA $0A86 : STA !Ex_YHi,x
		LDA #$17 : STA !Ex_Data1,x
	.Return	PLP
		RTL



; call LoadChunk_Force to force a chunk to load, even if it has been loaded before

	LoadChunk:
		STA $00
		AND $0A80 : BNE .Return
		LDA $00
	.Force
		TSB $0A80			; set chunk as loaded
		PHY				; push Y
		PHP				; push P
		SEP #$10			;\
		LDY #$FB			; |
	-	INY #5				; | get index
		LSR A				; |
		BCC -				;/
		REP #$20			;\
		LDA $0A81 : STA $00		; |
		LDA ($00),y : STA $0A83		; |
		INY #2				; | load chunk
		LDA ($00),y : STA $0A85		; |
		INY #2				; |
		SEP #$20			; |
		LDA ($00),y : STA $0A87		;/
		PLP				; pull P
		PLY				; pull Y
	.Return	RTL





;lines	x	w
;10	+30	40
;50	+30	90
;60	+90	30
;10	+50	80
;10	+30	A0
;60	+00	D0
;10	+70	60
;10	+80	50
;10	+80	40

level39:
		JSL WARP_BOX
		db $08 : dw $0100,$0000 : db $50,$04

		JSL WARP_BOX
		db $08 : dw $0780,$0000 : db $50,$04

		JSL WATER_BOX
		dw $0000,$0000 : db $FF,$FF

		JSL WATER_BOX
		dw $0000,$0100 : db $FF,$FF

		JSL WATER_BOX
		dw $0100,$0190 : db $60,$40

		JSL WATER_BOX
		dw $0100,$00B0 : db $80,$40

		JSL WATER_BOX
		dw $0100,$0000 : db $40,$FF

		REP #$20
		LDA.w #.RoomPointers
		JML LoadCameraBox


		.RoomPointers
		dw .ScreenMatrix
		dw .BoxTable
		dw .DoorList
		dw .DoorTable




;	Key ->	   X  Y  W  H  S  FX FY
;		   |  |  |  |  |  |  |
;		   V  V  V  V  V  V  V
;
.BoxTable
.Box0	%CameraBox(0, 0, 1, 2, $FF, 0, 0)
.Box1	%CameraBox(6, 0, 1, 7, $FF, 0, 0)

.ScreenMatrix	db $00,$00,$FF,$FF,$FF,$FF,$01,$01
		db $00,$00,$FF,$FF,$FF,$FF,$01,$01
		db $00,$00,$FF,$FF,$FF,$FF,$01,$01
		db $FF,$FF,$FF,$FF,$FF,$FF,$01,$01
		db $FF,$FF,$FF,$FF,$FF,$FF,$01,$01
		db $FF,$FF,$FF,$FF,$FF,$FF,$01,$01
		db $FF,$FF,$FF,$FF,$FF,$FF,$01,$01
		db $FF,$FF,$FF,$FF,$FF,$FF,$01,$01

.DoorList	db $FF			; no doors
.DoorTable






