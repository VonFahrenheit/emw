

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

		STZ !SideExit
		LDA $741A : BNE +
		LDA #$80
		STA !P2Entrance-$80
		STA !P2Entrance
		+


	.Graphics
		LDA #$01 : STA !GlobalLight1
		DEC !GlobalLightMixPrev
		LDA !TranslevelFlags+$00 : STA !GlobalLightMix
		LDA #$E1 : STA !MsgPal


		INC !SideExit
		REP #$20					; > A 16 bit
		LDA.w #!SpriteNum				;\
		STA $4330					; |
		LDA.w #HDMA_BlueSky_Green			; | set up green colour math on channel 3
		STA !HDMA3source				; |
		LDY.b #HDMA_BlueSky_Green>>16			; |
		STY $4334					;/
		LDA.w #!SpriteNum				;\
		STA $4340					; |
		LDA.w #HDMA_BlueSky_Blue			; | set up blue colour math on channel 4
		STA !HDMA4source				; |
		STY $4344					;/
		LDA.w #$7C00					;\
		STA $400000+!MsgVRAM1				; | portrait VRAM location
		LDA.w #$7C80					; |
		STA $400000+!MsgVRAM2				;/
		SEP #$20					; > A 8 bit
		LDA #$18					;\ enable HDMA on channels 3 and 4
		TSB !HDMA					;/
		RTL						; > return



levelinit3:
		LDA #$06 : STA !PalsetStart				; exclude palette F
		LDA #$E1 : STA !MsgPal					; portrait: palettes E and F
		LDA #$03*4 : STA !TextPal				;

		REP #$30						;\
		LDA.w #.Dynamo : STA $0C				; | upload castle (sprite BG)
		LDY.w #!File_Sprite_BG_1 : JSL UpdateGFX_NoOffset	; |
		SEP #$30						;/

		LDA #$02 : STA !BG2ModeH
		LDA #$04 : STA !BG2ModeV
		%GradientRGB(HDMA_BlueSky)
		LDA #$B9 : STA !Level+4					; > base offset
		LDA #$07 : STA !Level+5					; > size of chunks
		JML levelinit5_HDMA


		.Dynamo
		dw ..end-..start
		..start
		dw $0040
		dl $20*2
		dw $7EE0
		..end



levelinit4:
		LDA #$04
		TRB !MainScreen
		TRB !SubScreen
		INC !SideExit

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


		LDA $95
		CMP #$1C : BCS .Bonus

	.MainStage
		REP #$20
		STZ !CameraBoxU
		STZ !CameraBoxL
		LDA #$1C00 : STA !CameraBoxR
		LDA #$00E0 : STA !CameraBoxD
		SEP #$20
		LDA #$04 : STA !SpriteEraseMode		; disable camera box sprite erase
		JML level4

	.Bonus
		CMP #$1E : BEQ ..2
		CMP #$1F : BEQ ..3

	..1	REP #$20
		LDA #$0000 : BRA +

	..2	REP #$20
		LDA #$00E0
	+	STA !CameraBoxU
		LDA #$1D00 : STA !CameraBoxL
		LDA #$1E00 : STA !CameraBoxR
		LDA !CameraBoxU

	..R	STA !CameraBoxD
		SEP #$30
		JML level4

	..3	REP #$20
		LDA #$1F00
		STA !CameraBoxL
		STA !CameraBoxR
		STZ !CameraBoxU
		LDA #$00E0 : BRA ..R


levelinit5:
		LDA #$02 : STA !GlobalLight1
		DEC !GlobalLightMixPrev
		LDA.b #$51*2 : STA !LightIndexStart
		LDA.b #$EF*2 : STA !LightIndexEnd
		LDA.b #$EF*2>>8 : STA !LightIndexEnd+1

		LDA #$06 : STA !PalsetStart
		LDA #$D1 : STA !MsgPal


		LDA #$1F : STA !MainScreen
		STZ !SubScreen


	; Upload sun, sample code

		JSL GetVRAM
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
		LDA #$7E90 : STA !VRAMtable+$05,x
		LDA #$7F90 : STA !VRAMtable+$0C,x
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

		REP #$20
		LDA.w #.BigMaskDyn : STA $0C
		LDY.b #!File_Wizrex : JSL UpdateGFX_NoOffset
		SEP #$20


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

		LDA #$FF : STA !PalsetF					;\ lock palsetF for the sun BG
		LDA #$06 : STA !PalsetStart				;/
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
		JSL GetFileAddress				; |
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
		LDA #!SpriteNum			;\
		STA $4330			; |
		LDA #$0700			; |
		STA !HDMA3source		; | Set up red colour math on channel 3
		LDY #$00			; |
		STY $4334			;/
		LDA #!SpriteNum			;\
		STA $4340			; |
		LDA #$0800			; | Set up green colour math on channel 4
		STA !HDMA4source		; |
		STY $4344			;/
		LDA #!SpriteNum			;\
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


		JSL GetVRAM				;\
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

		JML level6_Main

		.ColorMathHDMA
		db $4A,$22				;\ color math on backdrop + BG2
		db $4A,$22				;/
		db $01,$20				; color math on backdrop only
		db $00					; end table


	.BigMaskDyn
		dw ..end-..start
		..start
		%generic_dynamo(4, $104, $1CA)
		%generic_dynamo(4, $114, $1DA)
		%generic_dynamo(4, $124, $1EA)
		%generic_dynamo(4, $134, $1FA)
		..end


levelinitC:
		LDA #$03 : STA !BG2ModeH
		STZ !BG2ModeV


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
		LDA #$0D : STA !Level+6
		STZ !Level+3
		REP #$20
		LDA $6701 : STA !3DWater_Color

		SEP #$20
		INC $14 : JSL HDMA3DWater		;\ set up double-buffered HDMA
		DEC $14 : JSL HDMA3DWater		;/
		RTL




levelinit26:
	;	%GradientRGB(HDMA_BlueSky)

		LDA #$02 : STA !GlobalLight2

		LDA #$06			;\
		STA !BG2ModeH			; | BG2 scroll = Close, Close
		STA !BG2ModeV			;/
		LDA #$A0 : STA !BG2BaseV	;\ Base BG2 Vscroll: 0x1A0
		LDA #$01 : STA !BG2BaseV+1	;/
		JML level26

levelinit27:
		LDA #$10 : STA !Level+3			; timer

		LDA #$E1 : STA !MsgPal

		LDA #$81 : STA !SpriteEraseMode		; erase sprites outside camera box, but ignore standard off-screen check

		STZ !BG2BaseV
		STZ !BG2BaseV+1

		.DarkLight
		LDA $97 : BNE ..done
		LDA $95
		CMP #$06 : BCC ..done
		REP #$20
		LDA #$0700 : STA !LightPointX
		LDA #$0420 : STA !LightPointY
		LDA #$0080
		STA !LightPointR
		STA !LightPointG
		STA !LightPointB
		LDA #$0200 : STA !LightPointS
		LDA #$000C : STA !LightPointIndex
		SEP #$20
		..done

		JML level27


levelinit2A:
		JSL GetVRAM				;\
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

		LDA #$0F : STA $0E
		STZ $0F
		PHB

	-	JSL GetParticleIndex : TXY
		LDX $0E
		LDA.l .XDisp,x
		AND #$00FF
		CLC : ADC $94
		STA !Particle_X,y
		LDA.l .YDisp,x
		AND #$00FF
		CLC : ADC $96
		STA !Particle_Y,y
		LDA.l .XSpeed,x
		AND #$00FF
		ASL #4
		CMP #$0800
		BCC $03 : ORA #$F000
		STA !Particle_XSpeed,y
		LDA.l .YSpeed,x
		AND #$00FF
		ASL #4
		CMP #$0800
		BCC $03 : ORA #$F000
		STA !Particle_YSpeed,y
		LDA #$0000 : STA !Particle_XAcc,y
		DEC $0E : BPL -

		PLB
		SEP #$30
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
		db $20,$30,$20,$30
		db $20,$30,$20,$30
		db $20,$30,$20,$30
		db $20,$30,$20,$30
		.YSpeed
		db $90,$90,$B0,$B0
		db $A0,$A0,$D0,$D0
		db $B0,$B0,$E0,$E0
		db $C0,$C0,$F0,$F0


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
		LDX #$B1 : STX !MsgPal		; > Portrait CGRAM location
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
		REP #$20
		LDA #$FFE0
		STA !P2YPosLo-$80
		STA !P2YPosLo
		STA $96
		SEP #$20
		RTL


levelinit2F:
		JSL levelinit2_Graphics				;\
		LDA $741A : BNE .Return				; |
		LDA #$20					; | if entering through midway entrance, time of day is already mid day
		STA !TranslevelFlags+$00			; |
		STA !GlobalLightMix				;/
		.Return
		RTL



	!CollapseStart	= $11A0
	!CollapseEnd	= $1C80


levelinit32:
		JSL levelinit6
		LDA #$02 : STA $41				; enable window 1 on layer 1

		LDA $95
		CMP #$0E : BCS +
		LDA #$0F : STA !LevelWidth
		+


		LDA #$07 : STA !PalsetStart			; restore this

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

		SEP #$20
		STZ !Level+3
		LDA #$04 : STA !41_WeatherFreq

		STZ $0A80					; clear chunk status
		STZ $0A87					; reset chunk size, baby!
		REP #$20					; A 16-bit
		LDA.w #.ChunkTable : STA $0A81			; set chunk data pointer
		LDA.w level6_BGColoursEnd : STA $00A2		; set color 0x02
		SEP #$20					; A 8-bit
		LDA #$F4 : STA !HDMA				; enable HDMA on channels 2 and 4 through 7
		STZ !SideExit
		INC $14 : JSL level32_HDMA
		DEC $14 : JSL level32_HDMA
		JML level32


.ChunkTable	dw $02D0,$0110 : db $06		; X, Y, size


levelinit33:
		LDA $95 : BNE +
		LDA #$80
		STA !P2YSpeed-$80
		STA !P2YSpeed
		STA !MarioYSpeed
		+
		JMP level33


levelinit38:
		LDA $97
		CMP #$0B : BNE +
		LDA #$80
		STA !P2YSpeed-$80
		STA !P2YSpeed
		STA !MarioYSpeed
		LDA #$E0
		STA !P2XSpeed-$80
		STA !P2XSpeed
		STA !MarioXSpeed
		+


		LDA #$E1 : STA !MsgPal

		STZ !BG2BaseV
		STZ !BG2BaseV+1
		RTL




levelinit39:
		LDA $95 : BEQ .Cave
		.Chasm
		LDA #$08 : TSB !HDMA
		.Cave
		LDA #$20
		STA !MarioYSpeed
		STA !P2YSpeed-$80
		STA !P2YSpeed
		STZ !P2VectorY-$80
		STZ !P2VectorY
		JML level39



; --Level MAIN--


level1:
		STZ !SideExit
		LDA $1B : BNE .NoSide
		INC A : STA !SideExit
.NoSide		CMP #$0D : BCC .Return
		LDA $1A
		CMP #$A0 : BCC .Return
		LDA #$01 : STA !EnableVScroll
.Return		RTL








level2:


	if !Debug = 1					;\
	LDA $6DA6					; |
	AND #$20 : BEQ +				; |
	LDA #$0F : STA !SPC4				; | select to enter doors cheat
	LDA #$06 : STA $71				; |
	STZ $88						; |
	STZ $89						; |
	+						; |
	endif						;/

		JSL WARP_BOX
		db $04
		dw $0000,$02A0 : db $FF,$30
		dw $0C2E

		JSL WARP_BOX
		db $04
		dw $1020,$02A0 : db $40,$30
		dw $042E



		; .Talk
		; LDA #$01
		; BIT !Level+2 : BNE ..done
		; LDX #$0F
	; -	LDA !SpriteStatus,x : BEQ +
		; LDA !NewSpriteNum,x
		; CMP #$02 : BNE +
		; LDA !SpriteXLo,x
		; SEC : SBC #$40
		; STA $04
		; LDA !SpriteXHi,x
		; SBC #$00
		; STA $0A
		; LDA !SpriteYLo,x
		; SEC : SBC #$40
		; STA $05
		; LDA !SpriteYHi,x
		; SBC #$00
		; STA $0B
		; LDA #$90
		; STA $06
		; STA $07
		; SEC : JSL PlayerContact
		; BCS ..talk

	; +	DEX : BPL -
		; BRA  ..done

		; ..talk
		; LDA #$01 : TSB !Level+2
		; REP #$20
		; LDA.w #!MSG_RexVillage_Rex1 : STA !MsgTrigger
		; SEP #$20
		; ..done



		REP #$20
		LDA #$13E8 : JSL EXIT_Right

		.ReloadSprites
		JSL ReloadSprites


		.MorningLight
		LDA !TranslevelFlags+$00
		CMP #$20 : BEQ +
		LDA $14 : BNE +
		INC !TranslevelFlags+$00
		+
		LDA !TranslevelFlags+$00 : STA !GlobalLightMix


		RTL




; TODO:
;	give this parallax a proper offset table input
;	tie .HDMA codes to backgrounds


level3:
		REP #$20				;\
		LDA #$1FE8				; | regular exit
		LDY #$01				; |
		JSL END_Right				;/
		LDA !MsgTrigger				;\
		ORA !MsgTrigger+1 : BNE +		; |
		LDA #$1F : STA !MainScreen		; | everything on main
		STZ !SubScreen				; | nothing on sub
		+					;/

		LDA.b #.HDMA : STA !HDMAptr		;\
		LDA.b #.HDMA>>8 : STA !HDMAptr+1	; | set up pointer
		LDA.b #.HDMA>>16 : STA !HDMAptr+2	;/

		RTL					; > return


		.HDMA
		PHB : PHK : PLB
		JSL level5_HDMA
		REP #$20
		LDA !MsgTrigger : BNE ..fail
		INC !Level+2
		LDA $1C
		LSR #2
		CLC : ADC #$0078
		STA $24
		LDA !Level+2
		LSR A
		CLC : ADC $1A
		LSR #3
		STA $22

		..spritebg				;\
		LDA #$2000				; |
		SEC : SBC $1A				; |
		LSR #5					; |
		SEC : SBC #$0008			; |
		AND #$01FF				; |
		EOR #$0100				; | draw castle (sprite BG)
		STA $00					; |
		STA $0C					; |
		LDA.w #.Tilemap : STA $02		; |
		SEP #$30				; |
		LDA #$14 : STA $01			; |
		LDA #$20 : STA $0E			; |
		JSL DrawSpriteBG			; |
		..fail					;/

		PLB
		RTL



		.Tilemap
		db $00,$00,$EE,$0F
		db $08,$00,$EE,$4F
		db $00,$08,$EF,$0F
		db $08,$08,$EF,$0F
		db $00,$10,$EF,$0F
		db $08,$10,$EF,$0F
		db $00,$18,$EF,$0F
		db $08,$18,$EF,$0F


level4:
		LDA.b #.SA1 : STA $3180			;\
		LDA.b #.SA1>>8 : STA $3181		; |
		LDA.b #.SA1>>16 : STA $3182		; | speedup
		LDA #$80 : STA $2200			; |
		JSR !MPU_light				;/
		RTL					; return


	.SA1
		PHB : PHK : PLB
		PHP
		SEP #$30

		LDA #$02 : STA !GlobalLight2		; fade into sunset
		LDA $1B					;\
		CMP #$1D : BCS +			; | advance light as player proceeds in level
		CMP !GlobalLightMix : BCC +		; > can't go back
		STA !GlobalLightMix			; |
		+					;/

		LDA #$20 : STA $64
		LDA !P2Status : BNE +
		LDA !P2Pipe : BNE ++
	+	LDA !P2Status-$80 : BNE +
		LDA !P2Pipe-$80 : BEQ +
	++	STZ $64
		LDA #$40 : STA !SPC4			; dizzy OFF!! SFX
		+

		LDA !P2Status-$80 : BNE .P2
		LDA !P2XPosHi-$80
		CMP #$0E : BNE .P2
		LDA !P2XSpeed-$80 : BPL .P2
		CMP #$E8 : BCC .Secret
	.P2	LDA !P2Status : BNE .Wall
		LDA !P2XPosHi
		CMP #$0E : BNE .Wall
		LDA !P2XSpeed : BPL .Wall
		CMP #$E8 : BCS .Wall
	.Secret	LDA $1C
		CMP #$B0 : BCC .Wall
		LDA #$8B
		LDY #$02 : BRA .Update
	.Wall	LDA #$A5
		LDY #$05
	.Update	STA $40C800+($1C0*$0E)+$15E
		STA $40C800+($1C0*$0E)+$16E
		TYA
		STA $41C800+($1C0*$0E)+$15E
		STA $41C800+($1C0*$0E)+$16E

		LDY #$0F
		LDX #$02
	-	LDA !SpriteStatus,y
		CMP #$08 : BNE +
		LDA !ExtraBits,y
		AND #$0C
		CMP #$04 : BNE +
		LDA !SpriteNum,y
		CMP #$04 : BCC +
		CMP #$08 : BCS +
		LDA #!DizzyStar_Num : STA !Ex_Num,x	;\
		TYA : STA !Ex_Data1,x			; | allocate slots for dizzy stars on dancing koopas
		LDA #$F0 : STA !Ex_Data3,x		; |
		LDA !Ex_Data2,x				; |
		CMP #$AA : BCS ++			; |
		ADC #$55				; |
		STA !Ex_Data2,x				; |
		BRA ++
	+	LDA !Ex_Num,x
		CMP #!DizzyStar_Num : BNE ++
		STZ !Ex_Num,x
	++	INX
		DEY : BPL -


		LDA $1B
		CMP #$08 : BCC .NoSpawn			; screens 0-7: no fuzzies
		CMP #$1A : BCS .NoSpawn			; screens 1A+: no fuzzies
		LDY #$00				; use index 00 on screens 08-0F
		CMP #$10 : BCC .CheckSpawn		;\ use index 01 on screens 10-14
		INY					;/
		CMP #$15 : BCC .CheckSpawn		;\ use index 02 on screens 15-19
		INY					;/

		.CheckSpawn
		LDA .SpawnRate,y
		AND $14 : BNE .NoSpawn
		LDX #$0E				; DON'T use all slots
	-	LDA !SpriteStatus,x : BEQ .TriggerSpawn
		DEX : BPL -
		BRA .NoSpawn

		.TriggerSpawn
		JSR .Spawn
		.NoSpawn


		REP #$20
		LDA.w #.Mode2 : STA !HDMAptr+0
		LDA.w #.Mode2>>8 : STA !HDMAptr+1
		LDA $94
		CMP #$1D00 : BCS .Bonus
		LDA #$1CE8 : JSL END_Right		; exit

	.Bonus
		PLP
		PLB
		RTL


	.SpawnRate
	db $9F,$3F,$0F					; based on which part of the level the camera is on

	.SpawnX
	dw $FFE0
	dw $0120

		.Spawn
		LDA !RNG
		AND #$F0
		CLC : ADC $1C
		CLC : ADC $7888
		STA !SpriteYLo,x
		LDA $1D
		ADC $7889
		STA !SpriteYHi,x
		CPY #$02 : BEQ +
		LDY #$00
		LDA !BG1_X_Delta
		BEQ ..random
		BMI $02 : LDY #$02
		BRA +
		..random
		LDA !RNG
		AND #$02
		TAY
	+	REP #$20
		LDA $1A
		CLC : ADC .SpawnX,y
		SEP #$20
		STA !SpriteXLo,x
		XBA : STA !SpriteXHi,x
		LDA #$01 : STA !SpriteStatus,x
		LDA #$2D : STA !SpriteNum,x
		LDA #$08 : STA !ExtraBits,x
		JSL !ResetSprite
		..fail
		RTS



; !Level+2: timer, activates effect
; !Level+4: internal timer

		.Mode2
		PHB : PHK : PLB
		PHP
		SEP #$30
		LDA $14
		LSR A : BCC +
		LDA $6DB0
		CMP #$10 : BCC +
		SEC : SBC #$10
		STA $6DB0
		+
		LDA !StarTimer : BEQ ..process
		STZ !Level+2
		STZ !Level+3
		LDA #$08 : STA !HDMA
		LDA $14
		AND #$01
		BEQ $02 : LDA #$40
		STA !HDMA3source
		LDA.b #..callparallax : STA $3180
		LDA.b #..callparallax>>8 : STA $3181
		LDA.b #..callparallax>>16 : STA $3182
		JSR $1E80

		LDA #$01 : STA !2105
		LDA !DizzyEffect : BEQ +
		LDA #$00 : STA !DizzyEffect
		LDA #$40 : STA !SPC4			; dizzy OFF!! SFX
		+
		PLP
		PLB
		RTL

		..process
		LDA #$02 : STA !2105
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
		CLC : ADC.w #!DecompBuffer+$10F0 : STA !HDMA2source	;/

		LDA #$0F02 : STA $4330					;\
		LDA $14							; |
		AND #$0001						; | layer 2 horizontal HDMA
		BEQ $03 : LDA #$0040					; |
		CLC : ADC.w #!DecompBuffer+$1100 : STA !HDMA3source	;/

		LDA #$1002 : STA $4340					;\
		LDA $14							; |
		AND #$0001						; | layer 2 stretch HDMA
		BEQ $03 : LDA #$0400					; |
		CLC : ADC.w #!DecompBuffer+$1200 : STA !HDMA4source	;/ > add because of bit overlap

		LDA #$3101 : STA $4350					;\ color math HDMA
		LDA #$0A00 : STA !HDMA5source				;/

		SEP #$20
		LDA #$40
		STA $4324
		STA $4334
		STA $4344
		STZ $4354

		LDA #$3C : TSB !HDMA

		LDA #$13 : STA !MainScreen
		STZ !2130						; don't add subscreen, just add $2132

		LDA !Level+2						;\
		ORA !Level+3						; |
		BNE ..dizzycolor					; | without dizzy, disable this HDMA channel
		STZ $0A00						; |
		REP #$20						; |
		LDA !PaletteRGB+0 : STA !2132_RGB			; > backdrop setup
		STZ !Color0						; |
		SEP #$20						; |
		BRA ..colordone						;/

		..dizzycolor
		REP #$20						;\
		STZ !2132_RGB						; | backdrop setup
		LDA !PaletteRGB : STA !Color0				; |
		SEP #$20						;/
		LDA #$01 : STA $0A00					; full screen
		LDA #$3F : STA $0A01					; dizzy effect: color on everything (otherwise just backdrop)
		LDA !Level+2						;\
		LSR #3							; | color value
		TAY							; |
		LDA ..ColorTable,y : STA $0A02				;/
		STZ $0A03						; end HDMA table
		..colordone

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

		LDA.w !DecompBuffer+$10FA : STA.l $2251
	-	LDA.l !TrigTable,x
		LSR #5
		STA.l $2253
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
		LSR #2
		STA.l !CutsceneSmoothness			; hide top of screen (cutoff)
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

		; Z stretch code
		REP #$10					;\
		LDA $14						; |
		AND #$0001					; | double buffer index
		BEQ $03 : LDA #$0400				; |
		TAX						;/
		LDA !Level+6					;\
		CLC : ADC $20					; |
	-	CMP.w #..ZTable_End-..ZTable : BCC +		; | modulo
		SBC.w #..ZTable_End-..ZTable : BRA -		; |
	+	TAY						;/
		LDA !DecompBuffer+$10FA : STA $2251		; multiplicand
	-	INY						; +1
		CPY.w #..ZTable_End-..ZTable			;\ overflow from +1 -> 0
		BCC $03 : LDY #$0000				;/



	; X &$3FF / 3 = position on-screen
	; find first scanline that shows the Y coordinate 0xF0 (in BG tilemap)
	; 0xF0 - scroll value = cutoff
	; cutoff + scroll value > 0xF0


		LDA #$0001 : STA !DecompBuffer+$1200,x		; scanline count
		LDA ..ZTable,y					;\
		AND #$00FF : STA $2253				; |
		INX #3						; |
		INY						; | calculate y position
		LDA $2306					; |
		LSR #5						; |
		CLC : ADC $20					;/
		STA !DecompBuffer+$1201-3,x			; store (-3 because we already +3 the index)
		TXA						;\
		AND #$03FF					; | loop for $D8 entries
		CMP #$00D8*3 : BCC -				;/
		LDA #$0000 : STA !DecompBuffer+$1200,x		; end table


		; H wave code
		JSR ..parallax


		; LDA !Level+4
		; LSR #2
		; AND #$001F
		; TAY
		; LDA $14
		; AND #$0001
		; BEQ $03 : LDA #$0040
		; TAX

	; ; STZ $02						; scanline tally = 0
	; ; STZ $04						; half flag = 0

		; LDA !DecompBuffer+$10FA : STA $2251
	; -	TYA
		; INC A
		; AND #$001F
		; TAY
		; LDA #$0010 : STA !DecompBuffer+$1100,x
	; ; BIT $04 : BMI +
	; ; CLC : ADC $02
	; ; STA $02
	; ; CMP $00 : BCC +
	; ; SBC $00
	; ; ADC #$000F
	; ; STA !DecompBuffer+$1100-3,x
	; ; DEC $04
	; ; +
		; LDA ..HTable,y
		; AND #$00FF : STA $2253
		; INX #3
		; LDA $2306
		; LSR #5
		; CLC : ADC $1E
	; ; BIT $04
	; ; BMI $01 : LSR A
		; STA !DecompBuffer+$1101-3,x
		; TXA
		; AND #$003F
		; CMP #$0030 : BCC -
		; LDA #$0000 : STA !DecompBuffer+$1100,x



		SEP #$10

		JSL GetVRAM
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


		..callparallax
		PHB : PHK : PLB
		PHP
		REP #$30
		STZ $2250
		JSR ..parallax
		PLP
		PLB
		RTL

		..parallax
		LDA $14
		AND #$0001
		BEQ $03 : LDA #$0040
		TAX
		LDA $1A : STA $2251

		LDA !Level+2 : BEQ +
		LDA #$0140 : STA $2253
		LDA #$0001 : STA !DecompBuffer+$1100,x
		LDA #$0000 : STA !DecompBuffer+$1103,x
		LDA $2307 : STA !DecompBuffer+$1101,x
		RTS
		+

		LDA #$00F0
		SEC : SBC $20
		LSR A
		STA !DecompBuffer+$1100,x
		BCC $01 : INC A
		STA !DecompBuffer+$1103,x
		LDA #$0020 : STA !DecompBuffer+$1106,x
		LDA #$0040 : STA !DecompBuffer+$1109,x
		LDA #$0012 : STA !DecompBuffer+$110C,x
		LDA #$0001 : STA !DecompBuffer+$110F,x
		LDA #$0000 : STA !DecompBuffer+$1112,x
		LDA #$00C0 : STA $2253
		NOP : BRA $00
		LDA $2307 : STA !DecompBuffer+$110F+1,x
		LDA #$00A8 : STA $2253
		NOP : BRA $00
		LDA $2307 : STA !DecompBuffer+$110C+1,x
		LDA #$0080 : STA $2253
		NOP : BRA $00
		LDA $2307 : STA !DecompBuffer+$1109+1,x
		LDA #$0070 : STA $2253
		NOP : BRA $00
		LDA $2307 : STA !DecompBuffer+$1106+1,x
		LDA #$0060 : STA $2253
		NOP : BRA $00
		LDA $2307
		STA !DecompBuffer+$1100+1,x
		STA !DecompBuffer+$1103+1,x
		RTS



	..HTable
	db $00,$01,$02,$03,$05,$07,$09,$0C
	db $0F,$12,$14,$16,$17,$18,$19,$1A
	db $1A,$19,$18,$17,$16,$14,$12,$0F
	db $0C,$09,$07,$05,$03,$02,$01,$00


; ripped from yoshi's island
; -$1B appended to make processing faster
	..ZTable
	db $28-$1B,$29-$1B,$29-$1B,$2A-$1B,$2A-$1B,$2B-$1B,$2B-$1B,$2C-$1B
	db $2C-$1B,$2C-$1B,$2D-$1B,$2D-$1B,$2E-$1B,$2E-$1B,$2E-$1B,$2F-$1B
	db $2F-$1B,$2F-$1B,$2F-$1B,$30-$1B,$30-$1B,$30-$1B,$30-$1B,$30-$1B
	db $30-$1B,$30-$1B,$31-$1B,$31-$1B,$31-$1B,$30-$1B,$30-$1B,$30-$1B
	db $30-$1B,$30-$1B,$30-$1B,$30-$1B,$2F-$1B,$2F-$1B,$2F-$1B,$2F-$1B
	db $2E-$1B,$2E-$1B,$2E-$1B,$2D-$1B,$2D-$1B,$2C-$1B,$2C-$1B,$2C-$1B
	db $2B-$1B,$2B-$1B,$2A-$1B,$2A-$1B,$29-$1B,$29-$1B,$28-$1B,$28-$1B
	db $27-$1B,$27-$1B,$26-$1B,$26-$1B,$25-$1B,$24-$1B,$24-$1B,$23-$1B
	db $23-$1B,$22-$1B,$22-$1B,$21-$1B,$21-$1B,$20-$1B,$20-$1B,$1F-$1B
	db $1F-$1B,$1F-$1B,$1E-$1B,$1E-$1B,$1D-$1B,$1D-$1B,$1D-$1B,$1C-$1B
	db $1C-$1B,$1C-$1B,$1C-$1B,$1B-$1B,$1B-$1B,$1B-$1B,$1B-$1B,$1B-$1B
	db $1B-$1B,$1B-$1B,$1B-$1B,$1B-$1B,$1B-$1B,$1B-$1B,$1B-$1B,$1B-$1B
	db $1B-$1B,$1B-$1B,$1B-$1B,$1B-$1B,$1C-$1B,$1C-$1B,$1C-$1B,$1C-$1B
	db $1D-$1B,$1D-$1B,$1D-$1B,$1E-$1B,$1E-$1B,$1F-$1B,$1F-$1B,$1F-$1B
	db $20-$1B,$20-$1B,$21-$1B,$21-$1B,$22-$1B,$22-$1B,$23-$1B,$23-$1B
	db $24-$1B,$24-$1B,$25-$1B,$26-$1B,$26-$1B,$27-$1B,$27-$1B,$28-$1B
	...End



level5:
		LDA #$02 : JSL SearchSprite_Custom
		BMI +
		LDA !ExtraBits,x
		AND #$04 : BEQ +
		LDA !ExtraProp1,x
		CMP #$02 : BNE +
		STZ !SpriteDir,x
		REP #$20
		LDA.w #.Table1 : JSL TalkOnce
		SEP #$20
		+


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
		db $60,$30,$E9,$0F
		db $68,$30,$E9,$4F
		db $60,$40,$E9,$8F
		db $68,$40,$E9,$CF


		;   ID       Xpos  Ypos       W   H        MSG
.Table1		db $00 : dw $0070,$00E0 : db $70,$FF : dw !MSG_CastleRex_Villager


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



		LDX #$07
		LDY ..index,x
		LDA $20 : STA ($02),y
		LDA $1E : BRA +
	-	LDY ..multiplier,x : STY $4202
		LDY $1E : STY $4203
		NOP #4
		LDA $4216 : STA $0E
		LDY $1F : STY $4203
		NOP #4
		LDA $4216
		AND #$00FF : XBA
		CLC : ADC $0E
		STA $4204
		LDY ..divisor,x : STY $4206
		LDY ..index,x
		LDA $20 : STA ($02),y
		NOP #8
		LDA $4214
	+	STA ($00),y
		DEX : BPL -


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
		LDA #$0008 : TSB $24

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


	..index
	db $00,$05,$0A,$0F,$14,$19,$1E,$23

; ideal values:
; 0.4385
; 0.4933
; 0.5549
; 0.6243
; 0.7023
; 0.7901
; 0.8888
;
; must be expressed as a fraction with both numbers <= 20
	..multiplier
	db 8		; 0.4385
	db 1		; 0.4933
	db 11		; 0.5549
	db 12		; 0.6243
	db 7		; 0.7023
	db 15		; 0.7901
	db 8		; 0.8888

	..divisor
	db 19
	db 2
	db 20
	db 19
	db 10
	db 19
	db 9





; see level init for info on RAM use

level6:
		REP #$20
		LDA #$10E8 : JSL EXIT_FADE_Right


		.CarriedMask
		LDA !TranslevelFlags : BNE ..done
		LDA $1A
		ORA $1B : BEQ ..done
		LDA !P2YPosHi-$80 : BEQ ..done
		INC !TranslevelFlags
		REP #$20
		LDA #$FFE0 : STA $00
		LDA #$00D0 : STA $02
		SEP #$20
		LDA #$06 : JSL SpawnSprite_Custom
		INC !ExtraProp1,x
		LDA #$C0 : STA !SpriteTweaker1,x
		STZ !SpriteTweaker3,x
		..done


		.Main
		LDA.b #.HDMA : STA !HDMAptr+0
		LDA.b #.HDMA>>8 : STA !HDMAptr+1
		LDA.b #.HDMA>>16 : STA !HDMAptr+2

		RTL



		.HDMA
		PHB : PHK : PLB
		PHP
		SEP #$30
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
		LDA #$17 : STA !MainScreen		;\ main/sub screen settings
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
	++	JSL MixHSL			; |
		BRA .NoHSL			; |
		.UploadColor			; |
		REP #$30			; |
		TXA				; |
		ORA #$0200			; |
		TAX				; |
		LDY #$000E			; |
		JSL HSLtoRGB			; |
		SEP #$30			; |
		.NoHSL				;/


	PHB
	LDX.b #HDMA_Evening>>16
	PHX : PLB
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
	PLB

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

		+
	PHB
	PHX
	LDX.b #HDMA_Evening>>16
	PHX : PLB
	PLX
		SEP #$20
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
	PLB

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
		dw $0439

		JSL WARP_BOX
		db $04 : dw $1910,$01F0 : db $50,$10
		dw $0C39

		REP #$20
		LDA #$1BE8 : JSL END_Right


		.SpawnDense
		LDA $1B					;\
		CMP #$16 : BCC ..done			; | spawn on screens 0x13-0x18
		CMP #$18+1 : BCS ..done			;/
		LDA $14					;\ spawn every 128 frames (roughly every 2 seconds)
		AND #$7F : BNE ..done			;/
		LDA #$34 : JSL CountSprites_Custom	;\ max 10 dense active
		CMP #$0A : BCS ..done			;/
		REP #$20				;\
		LDA $1C					; |
		SEC : SBC #$0020			; |
		STA $02					; |
		LDA !BG1_X_Delta			; |
		AND #$0080				; |
		EOR #$0080				; |
		STA $00					; | spawn above camera, random X offset
		LDA !RNG				; | (favors side that camera is moving towards)
		AND #$0070				; |
		ORA $00					; |
		ADC $1A					; |
		STA $00					; |
		SEP #$20				; |
		LDA #$34 : JSL SpawnSprite_Custom	; |
		BMI ..done				; |
		LDA !RNG				; |
		AND #$01				; |
		INC A : STA !ExtraProp1,x		; |
		..done					;/


	; squish dense on ground, but only underwater
		LDX #$0F
	-	LDA !SpriteNum,x
		CMP #$34 : BNE +
		LDA !SpriteWater,x : BEQ +
		LDA !SpriteHP,x
		CMP #$02 : BCS +
		LDA !SpriteBlocked,x
		AND #$04 : BEQ +
		LDA #$0B : STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		LDA #$02 : STA !SpriteHP,x
	+	DEX : BPL -


		LDA.b #HDMA3DWater : STA !HDMAptr+0
		LDA.b #HDMA3DWater>>8 : STA !HDMAptr+1
		LDA.b #HDMA3DWater>>16 : STA !HDMAptr+2

		LDA #$DC : STA !Level+2
		LDA #$30 : TRB !HDMA			; disable channels 4 + 5

		JSL level35_Graphics			; returns 16-bit A
		SEP #$30
		RTL




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
		LDA.w #.Gradient : JML level35_HDMA_3DWater

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
		dw $0007
		..start
		dw $5986
		dw $59A6
		dw $59A7
		dw $59C7
		dw $59E8
		dw $5A08
		dw $5A29
		dw $5A49
		dw $5A6A
		dw $5A8A
		dw $5A8B
		dw $5AAB
		..end


level26:
		LDA $14
		AND #$7F : BNE +
		LDA !TranslevelFlags+$00
		CMP #$20 : BEQ +
		INC !TranslevelFlags+$00
		+
		LDA !TranslevelFlags+$00 : STA !GlobalLightMix
		LDA !LightBuffer
		LSR A
		REP #$20
		BCS +
		LDA !LightData_SNES+($10*2)+$200 : BRA ++
		+
		LDA !LightData_SNES+($10*2)
	++	STA !2132_RGB
		SEP #$20



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
		LDA !Level+3 : BEQ +
		DEC !Level+3
		+



	if !Debug = 1					;\
	LDA $6DA6					; |
	AND #$20 : BEQ +				; |
	LDA #$0F : STA !SPC4				; | select to enter doors cheat
	LDA #$06 : STA $71				; |
	STZ $88						; |
	STZ $89						; |
	+						; |
	endif						;/


		LDA !Room
		ASL A : TAX
		JSR (.RoomCode,x)
		REP #$20
		LDA.w #.RoomPointers : JML LoadCameraBox



		.RoomCode
		dw .AristocratHouse		; 00
		dw .Shop			; 01
		dw .SwoopoHouse			; 02
		dw .EmptyPtr			; 03
		dw .DarkRoom			; 04
		dw .BigHouse			; 05
		dw .BigHouse			; 06
		dw .Negotiator			; 07
		dw .EmptyPtr			; 08
		dw .EmptyPtr			; 09
		dw .DimensionalCatacombs	; 0A


	.EmptyPtr
		RTS


	.AristocratHouse
		LDA #$02 : JSL SearchSprite_Custom : BMI ..done
		LDA $3400,x : BNE ..done
		LDA !SpriteHP,x : BNE ..done
		LDA #$02 : STA !SpriteStasis,x
		LDA #$5A : STA !SpriteXLo,x
		LDA !P2XPosHi
		LDA $95 : BEQ ..done
		LDA !TranslevelFlags+$01
		BIT #$01 : BNE ..nomsg1
		..msg1
		ORA #$01 : STA !TranslevelFlags+$01
		REP #$20
		LDA.w #!MSG_RexVillage_Aristocrat1 : STA !MsgTrigger
		SEP #$20
		..nomsg1
		LDA #$78 : JSL CountSprites_Vanilla : BNE ..nomsg2
		LDA !TranslevelFlags+$01
		BIT #$02 : BNE ..nomsg2
		..msg2
		ORA #$02 : STA !TranslevelFlags+$01
		REP #$20
		LDA.w #!MSG_RexVillage_Aristocrat2 : STA !MsgTrigger
		SEP #$20
		LDA #$02 : JSL SearchSprite_Custom
		BMI ..nomsg2
		..enrage
		LDA #$03 : STA $3400,x
		STZ !SpriteTweaker6,x
		LDA #$05 : STA !ExtraProp1,x
		..nomsg2
		..done
		RTS


	.Shop
		LDA !Level+3
		CMP #$01 : BNE ..nomsg
		STZ !Level+2
		LDA !StoryFlags+2
		AND #$01
		REP #$20
		BEQ ..buy
		..sins
		LDA.w #!MSG_RexVillage_ShopRegret : STA !MsgTrigger
		SEP #$20
		BRA ..nomsg
		..buy
		LDA.w #!MSG_RexVillage_Shop1 : STA !MsgTrigger
		SEP #$20
		..nomsg

		STZ $00
		LDX #$0F					;\
	-	LDA !SpriteStatus,x				; |
		CMP #$0B : BNE +				; |
		LDA !SpriteNum,x				; | look for purchaseable items in shop area
		CMP #$32 : BNE +				; |
		LDA !SpriteXHi,x				; |
		CMP #$03 : BCS +				; |
		LDA !SpriteXLo,x : BMI +			;/

		LDY #$00					;\
		TXA						; |
		INC A						; | index to player coin count
		CMP !P2Carry-$80				; |
		BEQ $02 : LDY #$02				;/

		REP #$20
		LDA !ExtraProp1,x
		AND #$00FF
		CMP !P1Coins,y
		BEQ ++
		BCC ++
		SEP #$20
		INC $00
		BRA +
	++	SEC : SBC !P1Coins,y
		EOR #$FFFF : INC A
		STA !P1Coins,y
		LDA.w #!MSG_RexVillage_Shop2 : STA !MsgTrigger
		SEP #$20
		LDA #$29 : STA !SPC4
		STZ !SpriteStatus,x
		PHX
		LDA #$02 : JSL SearchSprite_Custom
		BMI ++
		LDA #$C0 : STA !SpriteYSpeed,x
		STZ !SpriteBlocked,x
	++	PLX
	+	DEX : BPL -
		LDA $00
		CMP !Level+2 : BEQ ..nobuy
		STA !Level+2
		BCC ..nobuy
		REP #$20
		LDA !MsgTrigger : BNE +
		LDA.w #!MSG_RexVillage_Shop3 : STA !MsgTrigger
	+	SEP #$20
		LDA !SPC4 : BNE ..nobuy
		LDA #$2A : STA !SPC4
		..nobuy

		LDA !StoryFlags+2
		AND #$01 : BEQ ..nokill
		LDA #$02 : JSL KillSprite_Custom
		..nokill
		LDA #$02 : JSL SearchSprite_Custom
		BMI ..kill
		LDA !SpriteHP,x : BNE ..assault
		STZ !SpriteXSpeed,x
		STZ !SpriteXSub,x
		LDA #$65 : STA !SpriteXLo,x
		LDA !SpriteBlocked,x
		AND #$04 : BEQ +
		STZ !SpriteAnimTimer
		+
		BRA ..noclear
		..assault
		LDA !Level+4 : BNE ..noclear
		INC !Level+4
		REP #$20
		LDA.w #!MSG_RexVillage_ShopHurt : STA !MsgTrigger
		SEP #$20
		BRA ..noclear
		..kill
		LDA !StoryFlags+2			;\
		ORA #$01				; | shopkeeper is kill
		STA !StoryFlags+2			;/
		LDA #$32 : JSL KillSprite_Custom
		..noclear

		LDA #$21 : JSL KillSprite_Vanilla
		..noshop
		RTS


	.BigHouse
		REP #$20
		LDA.w #..HDMA : STA !HDMAptr+0
		LDA.w #..HDMA>>8 : STA !HDMAptr+1
		..done
		SEP #$20
		RTS


		..HDMA
		REP #$20
		SEP #$10
		LDA #$0000 : STA $4320
		LDA $14
		AND #$0001
		BEQ $03 : LDA #$0010
		TAX
		ORA #$0200
		STA !HDMA2source
		STZ $4324
		LDA #$0004 : TSB !HDMA

		STZ $00
		LDY !P2Status-$80 : BNE +
		LDA !P2YPosLo-$80 : STA $00
		+
		LDY !P2Status : BNE +
		LDA !P2YPosLo
		CMP $00 : BCC +
		STA $00
		+

		LDA $00
		CMP #$0690-1
		SEP #$20
		BCC +
		LDA !Level+2
		CMP #$08 : BEQ ++
		INC !Level+2
		BRA ++
	+	LDA !Level+2 : BEQ ++
		DEC !Level+2
		++
		REP #$20

		LDA $1C
		CLC : ADC #$00E0
		CMP #$0690-1 : BCC ..nohide

		..hide
		LDA #$0690-1
		SEC : SBC $1C
		SEP #$20
		CMP #$80 : BCC ..1chunk

		..2chunks
		LSR A : STA $0200,x
		BCC $01 : INC A
		STA $0202,x
		LDA !2100
		STA $0201,x
		STA $0203,x
		LDA #$01 : STA $0204,x
		LDA !Level+2 : STA $0205,x
		STZ $0206,x
		RTL

		..1chunk
		STA $0200,x
		LDA !2100 : STA $0201,x
		LDA #$01 : STA $0202,x
		LDA !Level+2 : STA $0203,x
		STZ $0204,x
		RTL

		..nohide
		SEP #$20
		LDA #$01 : STA $0200,x
		LDA !2100 : STA $0201,x
		STZ $0202,x
		RTL


	.Negotiator
		LDA #$02 : JSL SearchSprite_Custom
		BMI ..return
		LDA !SpriteHP,x : BNE ..return
		STA !SpriteStasis,x
		LDA #$7A : STA !SpriteXLo,x
		LDA $95
		CMP #$05 : BCC ..return
		LDA !TranslevelFlags+$02
		BIT #$01 : BEQ ..talk1
		BIT #$02 : BNE ..return

		..talk2
		LDA #$74 : JSL CountSprites_Vanilla : BNE ..return
		LDA #$02 : TSB !TranslevelFlags+$02
		REP #$20
		LDA.w #!MSG_RexVillage_Negotiator2 : STA !MsgTrigger
		SEP #$20
		RTS

		..talk1
		LDA #$01 : TSB !TranslevelFlags+$02
		REP #$20
		LDA.w #!MSG_RexVillage_Negotiator1 : STA !MsgTrigger
		SEP #$20

		..return
		RTS



	.DarkRoom
		REP #$20
		LDA #$0100
		STA !LightR
		STA !LightG
		STA !LightB
		..darkness
		LDA #$0080
		STA !LightR
		STA !LightG
		STA !LightB
		LDA.w #..HDMA : STA !HDMAptr+0
		LDA.w #..HDMA>>8 : STA !HDMAptr+1
		..done
		SEP #$20
		RTS

		..HDMA
		REP #$20
		LDA #$0040 : STA $4320
		LDA.w #..table : STA !HDMA2source
		SEP #$30
		LDA.b #..table>>16
		STA $4324
		STA $4327
		LDA #$04 : TSB !HDMA
		LDX #$0F
		LDA !2100
		AND #$0F
	-	STA $0200,x
		DEC A
		BPL $02 : LDA #$00
		DEX : BPL -
		RTL

		..table
		db $02 : dw $0200
		db $02 : dw $0201
		db $02 : dw $0202
		db $02 : dw $0203
		db $02 : dw $0204
		db $02 : dw $0205
		db $02 : dw $0206
		db $02 : dw $0207
		db $02 : dw $0208
		db $02 : dw $0209
		db $02 : dw $020A
		db $02 : dw $020B
		db $02 : dw $020C
		db $02 : dw $020D
		db $02 : dw $020E
		db $4D : dw $020F
		db $4D : dw $020F
		db $02 : dw $020E
		db $02 : dw $020D
		db $02 : dw $020C
		db $02 : dw $020B
		db $02 : dw $020A
		db $02 : dw $0209
		db $02 : dw $0208
		db $02 : dw $0207
		db $02 : dw $0206
		db $02 : dw $0205
		db $02 : dw $0204
		db $02 : dw $0203
		db $02 : dw $0202
		db $02 : dw $0201
		db $02 : dw $0200
		db $00



	.SwoopoHouse
		LDA $14
		AND #$3F : BNE ..done
		LDX #$0F
		..loop
		LDA !SpriteStatus,x : BEQ ..thisone
		DEX : BPL ..loop
		BRA ..done
		..thisone
		LDA #$2C : STA !SpriteNum,x
		LDA #$08 : STA !ExtraBits,x
		LDA #$01 : STA !SpriteStatus,x
		STZ !SpriteXLo,x
		LDA #$06 : STA !SpriteXHi,x
		LDA $14
		AND #$40 : STA !SpriteYLo,x
		LDA #$01 : STA !SpriteYHi,x
		JSL !ResetSprite
		..done
		SEP #$20
		RTS


	.DimensionalCatacombs
		JSL ReloadSprites
		LDA !TranslevelFlags+$03
		BIT #$01 : BNE ..nomsg
		LDA #$01 : TSB !TranslevelFlags+$03
		REP #$20
		LDA.w #!MSG_RexVillage_Catacombs : STA !MsgTrigger
		SEP #$20
		..nomsg

		JSR .DarkRoom

		LDA !BG1_X_Delta
		BEQ ..noloop
		REP #$20
		BMI ..lowerloop

		..upperloop
		LDA $1A
		CMP #$0120 : BCC ..noloop
		CMP #$0130 : BCS ..noloop
		LDA #$FFF0 : STA $00
		LDA !P2YPosLo-$80			;\
		CMP #$0630 : BCC ..noloop		; | player must be in this range
		CMP #$0690 : BCC ..loop			;/
		LDA !P2YPosLo
		CMP #$0630 : BCC ..noloop
		CMP #$0690 : BCC ..loop
		BRA ..noloop

		..lowerloop
		LDA $1A
		CMP #$0110 : BCC ..noloop
		CMP #$0120 : BCS ..noloop
		LDA #$0010 : STA $00
		LDA !P2YPosLo-$80			;\
		CMP #$0690 : BCC ..noloop		; | player must be in this range
		LDA !P2YPosLo
		CMP #$0690 : BCC ..noloop

		..loop
		LDA $1A : JSR .SpaceTimeLoop
		..noloop
		SEP #$20


		RTS


; input:
;	A = $1A
;	$00 = loop amount
	.SpaceTimeLoop
		CLC : ADC $00
		STA $1A
		LDA $7462
		CLC : ADC $00
		STA $7462
		LDA !CameraBackupX
		CLC : ADC $00
		STA !CameraBackupX
		LDA !P2XPosLo-$80
		CLC : ADC $00
		STA !P2XPosLo-$80
		LDA !P2XPosLo
		CLC : ADC $00
		STA !P2XPosLo
		LDA !MarioXPosLo
		CLC : ADC $00
		STA !MarioXPosLo
		SEP #$20
		LDX #$0F
	-	LDA !SpriteStatus,x
		CMP #$08 : BNE +
		LDA !SpriteXHi,x : XBA
		LDA !SpriteXLo,x
		REP #$20
		CLC : ADC #$0030
		CMP $1A : BCC ..spriteout
		SEC : SBC #$0140
		BMI ..spriteneg				; if sprite is too close to left border of level to make this calc, just assume it should move
		CMP $1A : BCS ..spriteout
		..spriteneg
		CLC : ADC #$0110
		CLC : ADC $00
		SEP #$20
		STA !SpriteXLo,x
		XBA : STA !SpriteXHi,x
		..spriteout
		SEP #$20
	+	DEX : BPL -
		RTS



		.RoomPointers
		dw .ScreenMatrix
		dw .BoxTable

;	Key ->	   X  Y  W  H
;		   |  |  |  |
;		   V  V  V  V
;
.BoxTable
.Box0	%CameraBox(0, 0, 1, 1)
.Box1	%CameraBox(2, 0, 1, 0)
.Box2	%CameraBox(4, 0, 1, 1)
.Box3	%CameraBox(0, 2, 1, 1)
.Box4	%CameraBox(2, 2, 0, 0)
.Box5	%CameraBox(4, 4, 1, 3)
.Box6	%CameraBox(4, 5, 3, 2)
.Box7	%CameraBox(4, 2, 1, 0)
.Box8	%CameraBox(0, 4, 3, 1)
.Box9	%CameraBox(6, 0, 1, 4)
.BoxA	%CameraBox(0, 6, 3, 1)

.ScreenMatrix	db $00,$00,$01,$01,$02,$02,$09,$09
		db $00,$00,$FF,$FF,$02,$02,$09,$09
		db $03,$03,$04,$FF,$07,$07,$09,$09
		db $03,$03,$FF,$FF,$FF,$FF,$09,$09
		db $08,$08,$08,$08,$05,$05,$09,$09
		db $08,$08,$08,$08,$05,$05,$06,$06
		db $0A,$0A,$0A,$0A,$05,$05,$06,$06
		db $0A,$0A,$0A,$0A,$06,$06,$06,$06



level2A:
		.FirstBit
		LDA !StoryFlags+1
		AND #$01 : BNE ..done

		REP #$20
		LDA.w #190*16 : STA $E8
		LDA #$0030 : STA $EA
		LDA #$0050
		STA $EC
		STA $EE
		SEP #$20

		JSL PlayerContact : BCC ..done
		LSR A : BCC ..p2
		LDY !P2InAir-$80 : BEQ ..msg
		..p2
		LSR A : BCC ..done
		LDY !P2InAir : BNE ..done
		..msg
		REP #$20
		LDA.w #!MSG_FirstBit : STA !MsgTrigger
		SEP #$20
		LDA !StoryFlags+1
		ORA #$01 : STA !StoryFlags+1
		..done



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

		PHK : PEA level5_NoExit-1
		REP #$20
		LDA #$0AE8 : JML EXIT_FADE_Right


level2C:
		LDA #$E1 : STA !MsgPal

		LDX #$0F						;\
	-	LDA !SpriteStatus,x						; | look for a killed sprite (states 2-7)
		CMP #$02 : BCC +					; |
		CMP #$08 : BCS +					;/
		LDY !SpriteYHi,x					;\ must be on Y screen 00-03
		CPY #$04 : BCS +					;/
		LDA .Table,y : TSB !TranslevelFlags+$20			; if there is a rex, it can talk
	+	DEX : BPL -						; loop

		REP #$20
		LDA.w #.Table1 : JSL TalkOnce
		LDA.w #.Table2 : JSL TalkOnce
		LDA.w #.Table3 : JSL TalkOnce


		LDY !Translevel						;\ captain warrior doesn't spawn if level is beaten
		LDA !LevelTable1-1,y : BMI +				;/
		LDA $1A
		CMP #$00E0 : BNE +
		LDA $1C : BNE +
		LDA !TranslevelFlags+$20
		AND #$0008 : BNE +
		LDA.w #!MSG_CaptainWarrior_Warning : STA !MsgTrigger
		LDA #$0008 : TSB !TranslevelFlags+$20
		+

		REP #$30
		LDY.w #.DoorBox : JSL DoorBox


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


.DoorBox	dw $0140,$0030 : db $40,$90


		.Table
		db $00,$04,$02,$01

		;   ID       Xpos  Ypos       W   H        MSG
.Table1		db $00 : dw $0150,$0360 : db $70,$30 : dw !MSG_CastleRex_Rex_Warning_1
.Table2		db $02 : dw $0020,$0280 : db $50,$40 : dw !MSG_CastleRex_Rex_Warning_2
.Table3		db $04 : dw $0090,$0120 : db $20,$30 : dw !MSG_CastleRex_Rex_Warning_3



level2D:
		LDA #$10 : JSL CountSprites_Custom	;\ count custom sprite 0x10 (boss + scepter)
		CMP #$01 : BNE .KeepFighting		;/ if there is 1 (scepter) boss is dead

		LDA !Level+4 : BEQ .End			;\
		CMP #$C0 : BNE .DecTimer		; |
		LDA #$36 : STA !SPC3			; > victory fanfare
		.DecTimer				; |
		LDA $14					; |
		AND #$03 : BNE .Stall			; | once boss has died, wait for timer then beat the level
		DEC !Level+4 : BRA .Stall		; |
		.End					; |
		JSL END_End				;/
		.KeepFighting				;\
		LDA #$E0 : STA !Level+4			; | if boss is alive, keep timer up
		.Stall					;/
		LDA.b #.HDMA : STA !HDMAptr+0
		LDA.b #.HDMA>>8 : STA !HDMAptr+1
		LDA.b #.HDMA>>16 : STA !HDMAptr+2
		RTL

		.HDMA
		REP #$20
		STZ $22
		STZ $24
		LDA $14
		AND #$0007
		BNE $03 : DEC !Level+2
		LDA !Level+2 : STA $1E
		RTL

level2E:

		JSL ReloadSprites

		JSL WARP_BOX
		db $08
		dw $0300,$FFE0 : db $FF,$1F
		dw $062B
		JSL WARP_BOX
		db $08
		dw $0580,$FFE0 : db $80,$1F
		%SecondaryExitValue($384)


		REP #$20
		LDA.w #.RoomPointers : JML LoadCameraBox



		.RoomPointers
		dw .ScreenMatrix
		dw .BoxTable

;	Key ->	   X  Y  W  H
;		   |  |  |  |
;		   V  V  V  V
;
.BoxTable
.Box0	%CameraBox(3, 0, 0, 0)
.Box1	%CameraBox(1, 0, 1, 1)
.Box2	%CameraBox(0, 1, 0, 1)
.Box3	%CameraBox(3, 1, 1, 1)
.Box4	%CameraBox(1, 2, 1, 1)
.Box5	%CameraBox(3, 3, 1, 0)
.Box6	%CameraBox(5, 0, 0, 1)
.Box7	%CameraBox(5, 2, 0, 1)
.Box8	%CameraBox(6, 0, 2, 2)
.Box9	%CameraBox(6, 3, 0, 1)
.BoxA	%CameraBox(5, 5, 1, 1)
.BoxB	%CameraBox(2, 6, 2, 0)
.BoxC	%CameraBox(2, 4, 0, 1)
.BoxD	%CameraBox(4, 5, 0, 0)
.BoxE	%CameraBox(0, 0, 0, 0)

.ScreenMatrix	db $0E,$01,$01,$00,$FF,$06,$08,$08,$08
		db $02,$01,$01,$03,$03,$06,$08,$08,$08
		db $02,$04,$04,$03,$03,$07,$08,$08,$08
		db $FF,$04,$04,$05,$05,$07,$09,$FF,$FF
		db $FF,$FF,$0C,$FF,$FF,$FF,$09,$FF,$FF
		db $FF,$FF,$0C,$FF,$0D,$0A,$0A,$FF,$FF
		db $FF,$FF,$0B,$0B,$0B,$0A,$0A,$FF,$FF




;
; level+2
;	--------
; level+3
; level+4
;

	!StatueX	= 191
	!StatueY	= 48


level2F:
		LDX #$0F
	-	LDA !SpriteNum,x
		CMP #$02 : BNE +
		LDA !ExtraProp1,x
		CMP #$04 : BNE +
		LDA !SpriteXHi,x
		CMP #$02 : BNE +
		LDA !SpriteXLo,x
		CMP #$D8 : BCC +
		STZ !SpriteStatus,x
	+	DEX : BPL -


		LDA !Level+3 : BEQ +
		DEC !Level+3
		+


		LDA $1D : BNE +
		REP #$20
		LDA #$09E8 : JSL END_Right		; secret exit to fuzzy's ridge
		LDA #$02 : TRB !SubScreen		; disable BG2
		BRA ++
		+
		LDA #$02 : TSB !SubScreen		; enable BG2
		++


		REP #$20
		LDA !Level : PHA
		LDA #$0002 : STA !Level
		LDA #$0DE8 : JSL END_Right		; normal exit to rex reef beach
		PLA : STA !Level
		PLA : STA !Level+1



		REP #$20
		LDA #$0008 : JSL EXIT_Left



		JSL level2_ReloadSprites


		.HandleRooms
		LDA !Room : STA !Level+4
		REP #$20
		LDA.w #.RoomPointers : JSL LoadCameraBox
		STZ !LockBox
		LDA !Room
		CMP !Level+4
		STA !Level+4 : BEQ ..same
		..newroom
		LDA #$3F : STA !Level+3
		..same
		LDA !Room : BEQ .NoBox
		CMP #$01 : BEQ .Brawl
		.Return
		RTL

		.NoBox
		LDA #$FF : STA !CameraBoxU+1			; box 0 = no camera box
		RTL


	.Brawl
		LDA !TranslevelFlags+$10 : BMI .Return
		LDA #$01 : STA !LockBox
		LDA #$83 : STA !SpriteEraseMode			; erase sprites outside of camera box (threshold = 0x60), disable normal check
		REP #$20
		LDA #$0C00 : STA !CameraBoxR
		SEP #$20

		LDX !TranslevelFlags+$10
		CPX.b #..lastwaveindex-..waveindex+3 : BCC ..nextwave
		..end
		LDA #$04 : JSL CountSprites_Custom : BNE .Return
		LDA #$FF : STA !TranslevelFlags+$10
		INC !CameraBoxR+1				; reload camera box
		REP #$30
		LDA #$0025 : JSR ..togglegates
		SEP #$30
		LDA #$80 : STA !SPC3				; fade music
		RTL

		..nextwave
		CPX.b #..lastwaveindex-..waveindex+1 : BCC ..normalwave
		..aggrowave
		LDA !Level+3 : BEQ ..aggroinit
		CMP #$80 : BEQ ..aggroshake
		RTL

		..aggroinit
		CPX.b #..lastwaveindex-..waveindex+2 : BEQ ..aggrospawn
		LDA #$FF : STA !Level+3
		INC !TranslevelFlags+$10
		RTL

		..aggroshake
		ADC #$20
		STA !ShakeBG1
		RTL

		..aggrospawn
		JMP ..breakstatue


		..normalwave
		LDA !Level+3 : BNE .Return			;\
		LDX #$0F					; |
		LDY #$00					; |
	-	LDA !SpriteStatus,x : BEQ +			; |
		LDA !SpriteNum,x				; |
		CMP #$02 : BEQ ++				; | count brawlers
		CMP #$03 : BEQ ++				; |
		CMP #$04 : BEQ ++				; |
		CMP #$2C : BNE +				; |
	++	LDA !SpriteXHi,x				; |
		CMP #$0A : BCC +				; \ don't count if too far off-screen
		CMP #$0E : BCS +				; /
		INY						; |
	+	DEX : BPL -					; |
		CPY #$02 : BCS ..return				;/

		LDA #$48 : STA !SPC3				; switch music when spawning first wave

		LDX !TranslevelFlags+$10
		INC !TranslevelFlags+$10
		CPX.b #..lastwaveindex-..waveindex : BCS ..return
		LDA ..waveindex+1,x : STA $0F
		LDA ..waveindex,x : TAX

		..nextspawn
		REP #$20
		LDA ..wavedata+0,x
		AND #$00FF
		ASL #4
		ADC #$0A00
		STA $00
		LDA ..wavedata+1,x
		AND #$00FF
		ASL #4
		ADC #$0200
		STA $02
		SEP #$20
		PHX
		LDA $0F : PHA
		LDA ..wavedata+2,x : JSL SpawnSprite_Custom
		PLA : STA $0F
		CPX #$FF : BEQ +
		LDA !SpriteNum,x
		CMP #$02 : BNE +
		LDA #$05 : STA !ExtraProp1,x
		LDA #$08 : STA !ExtraProp2,x
	+	PLX
		INX #3
		CPX $0F : BCC ..nextspawn
		..return
		RTL


		..breakstatue
		INC !TranslevelFlags+$10
		REP #$30
		LDX.w #..statueblocky-..statueblockx-2
	-	LDA ..statueblockx,x : STA $9A
		LDA ..statueblocky,x : STA $98
		PHX
		LDA #$0025 : JSL ChangeMap16
		STZ $00
		LDA #$FF80 : STA $02
		LDA.w #!prt_smoke16x16 : JSL SpawnParticleBlock
		PLX
		DEX #2 : BPL -
		LDA #$0130 : JSR ..togglegates
		REP #$30
		LDA.w #!StatueX*16+16 : STA $00
		LDA.w #!StatueY*16+48 : STA $02
		SEP #$30
		LDA #$04 : JSL SpawnSprite_Custom
		CPX #$FF : BEQ ..return
		LDA #$09 : STA !SpriteAnimIndex
		LDA #$E0 : STA !SpriteAnimTimer
		LDA #$40 : STA $32D0,x
		INC $3400,x
		LDA #$25 : STA !SPC1					; roar SFX
		RTL

		..statueblockx
		dw !StatueX*16,!StatueX*16+16,!StatueX*16+32
		dw !StatueX*16,!StatueX*16+16,!StatueX*16+32
		dw !StatueX*16,!StatueX*16+16,!StatueX*16+32
		dw !StatueX*16,!StatueX*16+16,!StatueX*16+32
		..statueblocky
		dw !StatueY*16,!StatueY*16,!StatueY*16
		dw !StatueY*16+16,!StatueY*16+16,!StatueY*16+16
		dw !StatueY*16+32,!StatueY*16+32,!StatueY*16+32
		dw !StatueY*16+48,!StatueY*16+48,!StatueY*16+48


	; input: A = map16 tile
		..togglegates
		REP #$10
		LDX #$0000
		SEP #$20
	-	STA $40C800+($A*$400)+$2AD,x
		STA $40C800+($D*$400)+$2A2,x
		XBA
		STA $41C800+($A*$400)+$2AD,x
		STA $41C800+($D*$400)+$2A2,x
		XBA
		INX #16
		CPX #$00B0 : BCC -
		RTS



	..waveindex
	db ..wave0-..wavedata
	db ..wave1-..wavedata
	db ..wave2-..wavedata
	db ..wave3-..wavedata
	..lastwaveindex
	db ..waveend-..wavedata

; coords relative to 0A00,0200
	..wavedata
	..wave0
	db $30,$14	: db $02
	db $31,$14	: db $02
	db $32,$14	: db $02
	..wave1
	db $0C,$14	: db $02
	db $0D,$14	: db $02
	db $0E,$14	: db $02
	db $0F,$14	: db $02
	..wave2
	db $0C,$14	: db $02
	db $0D,$14	: db $03
	db $0E,$14	: db $03
	db $0F,$14	: db $03
	..wave3
	db $0C,$0C	: db $2C
	db $0E,$0D	: db $2C
	db $30,$0D	: db $2C
	db $32,$0C	: db $2C
	..waveend




		.RoomPointers
		dw .ScreenMatrix
		dw .BoxTable

;	Key ->	   X  Y  W  H
;		   |  |  |  |
;		   V  V  V  V
;
.BoxTable
.Box0	%CameraBox(0, 0, 11, 4)
.Box1	%CameraBox(11, 3, 2, 0)
.Box2	%CameraBox(0, 0, 9, 0)

.ScreenMatrix	db $00,$00,$00,$00,$00,$00,$00,$00,$02,$02,$00,$01,$01,$01
		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$01
		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$01
		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$01
		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$01


level32:
		REP #$20
		LDA.w #.HDMA : STA.l !HDMAptr+0
		LDA.w #.HDMA>>8 : STA.l !HDMAptr+1
		LDA #$0080 : STA !LightR
		LDA #$0100 : STA !LightG
		LDA #$00E0 : STA !LightB
		SEP #$20


		.Weather
		LDA $1B
		CMP #$1C : BCS ..done
		LDA #$06 : JSL SearchSprite_Custom
		BMI ..spellparticles
		LDA !ExtraProp1,x
		CMP #$01 : BNE ..spellparticles

		..ritualcasters
		LDA #$7F : TRB !Level+4
		LDX #$0F
		..loop
		LDA !SpriteStatus,x
		CMP #$08 : BNE ..next
		LDA !ExtraBits,x
		AND #$08 : BEQ ..next
		LDA !SpriteNum,x
		CMP #$05 : BNE ..next
		LDA !SpriteXHi,x
		CMP #$0D : BNE ..next
		LDA !SpriteHP,x : BNE ..next
		LDA !SpriteXLo,x
		ASL A
		ROL A
		AND #$01
		STA !SpriteDir,x
		INC A : TSB !Level+4
		LDA #$0F : STA $32D0,x
		..next
		DEX : BPL ..loop

		LDA #$03 : BRA ..spawnweather
		..spellparticles
		LDA #$02
		..spawnweather
		JSL Weather
		..done



		LDA $1B
		CMP #$0E : BNE .NoExit
		REP #$20
		LDA #$00A0 : JSL EXIT_Up
		.NoExit

		REP #$20
		LDA #$1FE8 : JSL END_Right



		.DestroyChunk
		LDA #$01					;\
		AND $0A80 : BNE ..done				; |
		LDA #$06 : JSL SearchSprite_Custom		; |
		BMI ..done					; |
		LDA $BE,x					; | load chunks when adept shaman dies
		AND #$03					; |
		CMP #$02 : BNE ..done				; |
		LDA #$01 : JSL LoadChunk			; |
		..done						;/

		LDA $0A87 : BEQ .Return
		LDA $14
		AND #$1F : BNE $04 : JML DestroyChunk

		.Return
		RTL



		.HDMA
		PHB : PHK : PLB
		SEP #$30

		LDA $14
		AND #$01
		BEQ $02 : LDA #$10
		TAX
		LDA $1F						;\
		LSR A : STA $0A08,x				; | update BG2 Hscroll
		LDA $1E						; |
		ROR A : STA $0A07,x				;/
		STX !HDMA6source				; update source for BG2

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

		PHB
		JSL GetParticleIndex
		LDA.l !RNG
		AND #$00FF
		ADC $1A
		STA !Particle_X,x
		LDA #$00B8 : STA !Particle_Y,x
		STZ !Particle_XSpeed,x
		STZ !Particle_YSpeed,x
		STZ !Particle_XAcc,x
		STZ !Particle_YAcc,x
		PLB
		..fail
		; keep all regs 16-bit here
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
		LDA !RNG
		AND #$F0
		CMP $00 : BCS ..fail
		STA $00
		STZ $01
		PHB
		JSL GetParticleIndex
		LDA.l !RNG
		AND #$001F
		SEC : SBC #$0010
		CLC : ADC.l !Level+6
		STA !Particle_X,x
		LDA.l !LevelHeight
		SEC : SBC $00
		STA !Particle_Y,x
		STZ !Particle_XSpeed,x
		STZ !Particle_YSpeed,x
		STZ !Particle_XAcc,x
		STZ !Particle_YAcc,x
		PLB
		..fail
		REP #$30
		BRA .CheckTimer

		.NotCollapsingYet
		LDA $1A
		CMP #!CollapseStart : BCS .CheckTimer
	-	JMP .HandleColumns_done
		.CheckTimer

		SEP #$30
		LDA #$06 : JSL SearchSprite_Custom
		REP #$30
		LDA $3570,x
		AND #$00FF : BNE -

		LDA #$001F : STA $00
		LDA !Level+6
		CMP.w #!CollapseEnd : BCS ..nospawn
		CMP $1A : BCS +
		LDA #$0007 : STA $00
		+

		LDA $14
		AND $00 : BEQ ..spawnnew
		..nospawn
		JMP .NoCollapse
		..spawnnew

		LDX $0402					;\
		STZ $0404,x					; |
		STZ $0406,x					; | spawn new collapsing column
		INX #4						; |
		STX $0402					;/
		LDA !ShakeTimer
		ORA #$0010 : STA !ShakeTimer

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
		AND #$00FF : STA $0406,x
		BRA ..loop
		..done

		SEP #$30
		LDA $14
		AND #$01
		BEQ $02 : LDA #$10
		TAX
		STX !HDMA2source				; update source for BG1
		LDA #$01 : STA $0B00,x
		STZ $0B05,x

		LDA $14
		AND #$01
		LSR A
		ROR A
		AND #$80 : TAX
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
		CMP.w #!CollapseEnd : BCS ..generatewindow

		CMP !Level+6 : BNE $03 : JMP ..done	; exception: collapse has not started yet

		..generatewindow
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


		JSL GetVRAM
		LDA #$0080 : STA !VRAMbase+!VRAMtable+$00,x
		LDA.w #!DecompBuffer+$1000 : STA !VRAMbase+!VRAMtable+$02,x
		LDA.w #!DecompBuffer>>16 : STA !VRAMbase+!VRAMtable+$04,x
		LDA !2109
		AND #$00FC
		XBA
		STA !VRAMbase+!VRAMtable+$05,x
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

		STZ $00
		STZ $02
		STZ $04
		STZ $06
		LDA.w #!prt_smoke16x16 : JSL SpawnParticleBlock
		PLA : STA $9A
		PLA : STA $98

		.Return
		PLP
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




level33:
		STZ !SideExit

		REP #$20
		LDA #$0270 : JSL EXIT_Down


		; LDA !StoryFlags+$02
		; ORA #$80 : STA !StoryFlags+$02
		; LDA #$80 : TSB !LevelTable4+$03		; unlock dinolord's domain


		; REP #$20
		; LDA.w #350 : STA !SRAM_overworldX
		; LDA.w #740 : STA !SRAM_overworldY
		; LDA #$00A0 : JSL END_Up

		REP #$20
		LDA.w #.RoomPointers : JML LoadCameraBox


		.RoomPointers
		dw .ScreenMatrix
		dw .BoxTable

;	Key ->	   X  Y  W  H
;		   |  |  |  |
;		   V  V  V  V
.BoxTable
.Box0	%CameraBox(0, 0, 1, 0)
.Box1	%CameraBox(2, 0, 0, 0)
.Box2	%CameraBox(2, 1, 0, 1)
.Box3	%CameraBox(3, 0, 2, 2)
.Box4	%CameraBox(6, 0, 1, 2)
.Box5	%CameraBox(8, 0, 5, 2)

.ScreenMatrix	db $00,$00,$01,$03,$03,$03,$04,$04,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05
		db $00,$00,$02,$03,$03,$03,$04,$04,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05
		db $00,$00,$02,$03,$03,$03,$04,$04,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05




level38:


	.HandleRooms
		LDA !Level+3 : BEQ ..timerdone
		DEC !Level+3
		..timerdone

		LDA !Room
		ASL A
		TAX
		JSR (.RoomCode,x)
		LDA !Room
		CMP !Level+4
		STA !Level+4 : BEQ ..same
		..newroom
		LDA #$FF : STA !Level+3
		..same
		REP #$20
		LDA.w #.RoomPointers : JML LoadCameraBox

		.RoomCode
		dw .TopFloor		; 00
		dw .Floor6		; 01
		dw .Floor5		; 02
		dw .Floor4		; 03
		dw .Floor3		; 04
		dw .Floor2		; 05
		dw .GroundFloor		; 06

		dw .MayorsHouse		; 07
		dw .MayorsHouse		; 08

		dw .TrashHouse		; 09
		dw .Prison		; 0A
		dw .Library		; 0B




	.TopFloor
		LDA #$32 : JSL KillSprite_Custom
		RTS

	.Floor6
		LDA #$10 : JSR .BreakInBox
		dw $0100,$0200		; trigger X,Y
		db $FF,$18		; trigger W,H
		db $08,$02		; sprite data
		dw $0BCB		; tile
		dw $01A0,$0210		; coords
		JSR .SetBandit

		LDA #$20 : JSR .BreakInBox
		dw $0000,$01C0
		db $E0,$20
		db $08,$02
		dw $0BCB
		dw $0040,$01C0
		JSR .SetBandit

		LDA #$40 : JSR .BreakInBox
		dw $0140,$0150
		db $C0,$40
		db $08,$02
		dw $0BCB
		dw $01A0,$0160
		JSR .SetBandit

		LDA #$80 : JSR .BreakInBox
		dw $0100,$0120
		db $FF,$20
		db $08,$02
		dw $0BCB
		dw $01A0,$0120
		JSR .SetBandit

		JSR .SpawnAssassin
		RTS

	.Floor5
		JSR .SpawnAssassin
		RTS

	.Floor4
		JSR .SpawnAssassin
		RTS

	.Floor3
		LDA #$04 : JSR .BreakInBox
		dw $0100,$0480
		db $FF,$18
		db $08,$02
		dw $0BCB
		dw $01A0,$0480
		JSR .SetBandit

		..nobreakin
		JSR .SpawnAssassin
		RTS


	.Floor2
		LDA !Level+2
		AND #$02 : BNE ..spawn
		LDA $1B : BNE ..return
		LDA #$02 : TSB !Level+2
		REP #$20
		LDA.w #!MSG_RexVillage_SkyScraper3 : STA !MsgTrigger
		SEP #$20
		..spawn
		JSR .SpawnAssassin
		..return

		RTS

	.GroundFloor
		LDA #$02 : JSL SearchSprite_Custom
		BMI ..return
		LDA !SpriteHP,x : BEQ ..normal
		..hurt
		LDA !Level+2
		AND #$01 : BNE ..return
		LDA #$01 : TSB !Level+2
		REP #$20
		LDA.w #!MSG_RexVillage_SkyScraper2 : STA !MsgTrigger
		SEP #$20
		RTS
		..normal
		LDA #$08 : STA !SpriteOAMProp,x
		LDA #$2A : STA !SpriteXLo,x
		LDA !Level+3
		CMP #$01 : BNE ..return
		REP #$20
		LDA.w #!MSG_RexVillage_SkyScraper1 : STA !MsgTrigger
		SEP #$20
		..return
		RTS


	.HandleSprites
		LDA !Room
		CMP #$01
		REP #$20
		BNE ..screen
		..camerabox
		LDA !CameraBoxU
		SEC : SBC #$0018
		STA $00
		LDA !CameraBoxD
		CMP $1C
		BCS $02 : LDA $1C
		CLC : ADC #$00F8
		BRA ..set
		..screen
		LDA $1C
		SEC : SBC #$0018
		STA $00
		LDA $1C
		CLC : ADC #$00F8
		..set
		STA $02
		SEP #$20
		LDX #$0F
		..loop
		LDA !SpriteNum,x
		CMP #$02 : BEQ ..thisnum
		CMP #$30 : BNE ..next
		..thisnum
		LDA !SpriteYHi,x : XBA
		LDA !SpriteYLo,x
		REP #$20
		CMP $00 : BCC ..kill
		CMP $02 : BCC ..next
		..kill
		SEP #$20
		STZ !SpriteStatus,x
		..next
		SEP #$20
		DEX : BPL ..loop
		..return
		RTS


	.SpawnAssassin
		JSR .HandleSprites
		REP #$20
		LDA $1C
		CMP !CameraBoxU : BCC ..return16
		CMP !CameraBoxD
		SEP #$20
		BEQ ..process
		BCC ..process
		..return16
		SEP #$20
		RTS
		..process
		LDA $14
		AND #$1F : BNE ..return
		LDA #$02 : JSL CountSprites_Custom
	;	LDY !Room
	;	CMP ..count,y : BCS ..return
	CMP #$04 : BCS ..return
		LDX #$0F
		..loop
		LDA !SpriteStatus,x : BEQ ..thisone
		DEX : BPL ..loop
		RTS
		..thisone
		LDA #$08 : STA !SpriteStatus,x
		LDA #$02 : STA !SpriteNum,x
		LDA #$08 : STA !ExtraBits,x
		JSL !ResetSprite
		LDY !Room
		LDA ..xlo,y : STA !SpriteXLo,x
		LDA ..xhi,y : STA !SpriteXHi,x
		LDA ..ylo,y : STA !SpriteYLo,x
		LDA ..yhi,y : STA !SpriteYHi,x
		LDA #$05 : STA !ExtraProp1,x
		LDA #$05 : STA !ExtraProp2,x
		LDA #$03 : STA $3400,x
		LDA #$C0 : STA !SpriteYSpeed,x
		..return
		RTS

		..count
		db $00,$09,$07,$06,$05,$04,$00
		..xlo
		db $FF,$F8,$80,$70,$70,$80,$FF
		..xhi
		db $FF,$00,$01,$00,$00,$01,$FF
		..ylo
		db $FF,$A0,$80,$60,$40,$20,$FF
		..yhi
		db $FF,$02,$03,$04,$05,$06,$FF




		.SetBandit
		CPX #$10 : BCS ..return
		LDA #$03 : STA $3400,x
		LDA #$05 : STA !ExtraProp1,x
		LDA #$05 : STA !ExtraProp2,x
		..return
		RTS



	.BreakInBox
		BIT !Level+2 : BEQ ..ok					; check bit key
		LDX #$FF						; return X = invalid
		..return						;\
		REP #$20						; |
		LDA $01,s						; |
		CLC : ADC #$000E					; | +14 to return address, then return
		STA $01,s						; |
		SEP #$20						; |
		RTS							;/

		..ok							;\
		STA !BigRAM						; > preserve bit key
		REP #$20						; |
		LDA $01,s						; |
		INC A							; | $0E = pointer
		STA $0E							; | return address +6
		CLC : ADC #$0005					; |
		STA $01,s						;/




		LDA ($0E) : STA $E8					;\
		LDY #$02						; |
		LDA ($0E),y : STA $EA					; |
		LDY #$04						; |
		LDA ($0E),y : STA $EE-1					; |
		AND #$00FF : STA $EC					; | check trigger box, then let .BreakIn code take over
		SEP #$20						; |
		STZ $EF							; |
		JSL PlayerContact : BCC .BreakIn_fail			; |
		LDA !BigRAM						; > A = bit key
		BCS .BreakIn_spawn					; |
		BRA .BreakIn_return					;/




; input:
;	A = bit key
;	8 bytes after JSR = input for !ChangeMap16 (sprite extra bits, sprite num, map16 tile num, x coord, y coord)
; output:
;	X = sprite index (0xFF if spawn failed)

; example:
;	JSR .BreakIn
;	db $08,$02		; rex
;	dw $0B70		; tile
;	dw $0080,$0480		; coords

	.BreakIn
		BIT !Level+2 : BEQ ..spawn				; check bit key
		..fail							;\ return X = invalid
		LDX #$FF						;/
		..return						;\
		REP #$20						; |
		LDA $01,s						; |
		CLC : ADC #$0008					; | +8 to return address, then return
		STA $01,s						; |
		SEP #$20						; |
		RTS							;/

		..spawn							;\ set bit key
		TSB !Level+2						;/
		REP #$20						;\
		LDA $01,s						; |
		SEC : ADC #$0002					; > +1 +2 to get to map16 part of data
		STA $00							; |
		LDY #$02						; |
		LDA ($00),y : STA $9A					; > X
		LDY #$04						; |
		LDA ($00),y : STA $98					; > Y
		LDA ($00) : PHA						; > tile
		JSR ..break						; |
		LDA $9A							; | break + puff blocks
		CLC : ADC #$0010					; |
		STA $9A							; |
		LDA $01,s : JSR ..break					; |
		LDA $98							; |
		CLC : ADC #$0010					; |
		STA $98							; |
		LDA $01,s : JSR ..break					; |
		LDA $9A							; |
		SEC : SBC #$0010					; |
		STA $9A							; |
		PLA : JSR ..break					; |
		SEP #$20						;/

		LDX #$00						;\
		..loop							; |
		LDA !SpriteStatus,x : BEQ ..thisone				; | search for a sprite slot
		INX							; |
		CPX #$10 : BCC ..loop					; |
		BRA ..fail						;/
		..thisone						;\
		REP #$20						; |
		LDA $01,s						; |
		INC A							; |
		STA $00							; |
		SEP #$20						; |
		LDY #$01						; |
		LDA ($00) : STA !ExtraBits,x				; | get sprite data
		BIT #$08 : BNE ..custom					; |
		..vanilla						; |
		LDA ($00),y : STA !SpriteNum,x				; |
		BRA ..reset						; |
		..custom						; |
		LDA ($00),y : STA !SpriteNum,x				; |
		..reset							;/
		INC !SpriteStatus,x					;\
		JSL !ResetSprite					; |
		LDA $9A							; |
		ORA #$08 : STA !SpriteXLo,x				; | spawn sprite
		LDA $9B : STA !SpriteXHi,x				; | (NOTE: block coords are at +0,+10 after block update, so this is perfect)
		LDA $98 : STA !SpriteYLo,x				; |
		LDA $99 : STA !SpriteYHi,x				;/
		LDA #$3F : STA !ShakeTimer				; shake timer
		JMP ..return

		..break
		JSL ChangeMap16
		LDA #$FF80 : STA $00
		STZ $02
		LDA.w #!prt_smoke16x16 : JSL SpawnParticleBlock
		RTS




	.MayorsHouse
		LDA !TranslevelFlags+$04
		AND #$02 : BEQ ..normal
		LDA #$02 : JSL KillSprite_Custom
		..normal

		LDX #$0F
	-	LDA !ExtraBits,x
		AND #$08 : BNE ..custom
		..vanilla
		LDA !SpriteNum,x
		CMP #$1D : BNE +
		LDA #$02
		STA !SpriteStasis,x
		STA !SpriteDisP1,x
		STA !SpriteDisP2,x
		BRA +
		..custom
		LDA !SpriteNum,x
		CMP #$02 : BNE +
		..mayor
		LDA !SpriteStatus,x
		CMP #$04 : BEQ ..dead
		LDA !SpriteHP,x : BEQ ..alive
		CMP #$01 : BEQ +
		..dead
		LDA !TranslevelFlags+$04
		AND #$02 : BNE +
		LDA #$02 : TSB !TranslevelFlags+$04
		REP #$20
		LDA.w #!MSG_RexVillage_Mayor2 : STA !MsgTrigger
		SEP #$20
		BRA +

		..alive
		LDA #$02 : STA !SpriteStasis,x
		LDA #$04 : STA !SpriteOAMProp,x
		LDA #$1A : STA !SpriteXLo,x
		LDA !TranslevelFlags+$04
		AND #$01 : BNE +
		LDA #$01 : TSB !TranslevelFlags+$04
		REP #$20
		LDA.w #!MSG_RexVillage_Mayor1 : STA !MsgTrigger
		SEP #$20
	+	DEX : BPL -
		RTS


	.TrashHouse
		JSL WARP_BOX
		db $04
		dw $00E0,$0B70 : db $40,$10
		%SecondaryExitValue($2E0)
		RTS

	.Prison
		LDX #$0F
	-	LDA !SpriteNum,x
		CMP #$1D : BNE +
		LDA #$02
		STA !SpriteStasis,x
		STA !SpriteDisP1,x
		STA !SpriteDisP2,x
	+	DEX : BPL -

		LDA #$02 : JSL SearchSprite_Custom
		BMI ..return
		LDA !SpriteHP,x : BNE ..return
		STZ !SpriteDir,x

		LDA !TranslevelFlags+$05
		BIT #$01 : BNE ..return
		LDA $95 : BEQ ..return
		LDA #$01 : TSB !TranslevelFlags+$05
		REP #$20
		LDA.w #!MSG_RexVillage_BullyGuard : STA !MsgTrigger
		SEP #$20
		..return
		RTS


	.Library
		LDA #$02 : JSL SearchSprite_Custom
		BMI ..return
		LDA #$01 : JSR .TalkBox
		dw $0130,$0F00
		db $40,$20
		dw !MSG_RexVillage_Library
		..return
		RTS


	.TalkBox
		BIT !Level+2 : BEQ ..process
		..return
		REP #$20
		LDA $01,s
		CLC : ADC #$0008
		STA $01,s
		SEP #$20
		RTS

		..process
		STA !BigRAM
		REP #$20
		LDA $01,s
		INC A
		STA $0E

		LDA ($0E) : STA $E8
		LDY #$02
		LDA ($0E),y : STA $EA
		LDY #$04
		LDA ($0E),y : STA $EE-1
		AND #$00FF : STA $EC
		SEP #$20
		STZ $EF

		JSL PlayerContact : BCC ..return
		LDA !BigRAM : TSB !Level+2
		REP #$20
		LDA $01,s
		SEC : ADC #$0006
		STA $0E
		LDA ($0E) : STA !MsgTrigger
		BRA ..return



		.RoomPointers
		dw .ScreenMatrix
		dw .BoxTable

;	Key ->	   X  Y  W  H
;		   |  |  |  |
;		   V  V  V  V
;
.BoxTable
.Box0	%CameraBox(0, 0, 1, 0)
.Box1	%CameraBox(0, 1, 1, 1)
.Box2	%CameraBox(0, 3, 1, 0)
.Box3	%CameraBox(0, 4, 1, 0)
.Box4	%CameraBox(0, 5, 1, 0)
.Box5	%CameraBox(0, 6, 1, 0)
.Box6	%CameraBox(0, 7, 1, 0)
.Box7	%CameraBox(0, 9, 1, 2)
.Box8	%CameraBox(0, 8, 1, 0)
.Box9	%CameraBox(0, 12, 1, 0)
.BoxA	%CameraBox(0, 14, 1, 1)
.BoxB	%CameraBox(0, 16, 1, 1)

.ScreenMatrix	db $00,$00	; top floor
		db $01,$01	;\ floor 6
		db $01,$01	;/
		db $02,$02	; floor 5
		db $03,$03	; floor 4
		db $04,$04	; floor 3
		db $05,$05	; floor 2
		db $06,$06	; ground floor

		db $08,$08	; mayor's attic
		db $07,$07	;\ mayor's house
		db $07,$07	;/

		db $09,$09	;\
		db $09,$09	; | trash house
		db $09,$09	;/

		db $0A,$0A	;\ prison
		db $0A,$0A	;/

		db $0B,$0B	;\ some house
		db $0B,$0B	;/

		db $06,$06
		db $06,$06
		db $06,$06
		db $06,$06
		db $06,$06
		db $06,$06
		db $06,$06
		db $06,$06
		db $06,$06
		db $06,$06
		db $06,$06
		db $06,$06
		db $06,$06
		db $06,$06




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
		LDA.b #.HDMA : STA !HDMAptr+0
		LDA.b #.HDMA>>8 : STA !HDMAptr+1
		LDA.b #.HDMA>>16 : STA !HDMAptr+2



		LDA !Room : BNE .Chasm

		.Cavern
		JSL WARP_BOX
		db $08 : dw $0040,$0000 : db $50,$04
		dw $06C0
		JSL WARP_BOX
		db $08 : dw $0100,$0000 : db $50,$04
		dw $06C1
		JSL WATER_BOX
		dw $0000,$0000 : db $FF,$FF
		JSL WATER_BOX
		dw $0000,$0100 : db $FF,$FF
		JSL WATER_BOX
		dw $0100,$01A0 : db $60,$30
		JSL WATER_BOX
		dw $0100,$00C0 : db $80,$30
		JSL WATER_BOX
		dw $0100,$0000 : db $40,$FF
		BRA .GetCam

		.Chasm
		JSL WARP_BOX
		db $08 : dw $0380,$0000 : db $50,$04
		dw $06C2
		LDA #$01 : STA !WaterLevel
		REP #$20
		LDA $1C
		CMP #$0100 : BCC ..daylight
		SBC #$0100
		LSR #3
		CMP #$0080
		BCC $03 : LDA #$0080
		STA $00
		LDA #$0100
		SEC : SBC $00
		STA !LightR
		LDA #$0100
		LSR $00
		SBC $00
		BRA +

		..daylight
		LDA #$0100
		STA !LightR
		BRA +

	+	STA !LightG
		SEP #$20

		.GetCam
		REP #$20
		LDA.w #.RoomPointers
		JML LoadCameraBox


		.RoomPointers
		dw .ScreenMatrix
		dw .BoxTable

;	Key ->	   X  Y  W  H
;		   |  |  |  |
;		   V  V  V  V
;
.BoxTable
.Box0	%CameraBox(0, 0, 1, 2)
.Box1	%CameraBox(2, 0, 1, 7)

.ScreenMatrix	db $00,$00,$01,$01
		db $00,$00,$01,$01
		db $00,$00,$01,$01
		db $FF,$FF,$01,$01
		db $FF,$FF,$01,$01
		db $FF,$FF,$01,$01
		db $FF,$FF,$01,$01
		db $FF,$FF,$01,$01



	.HDMA
		PHB : PHK : PLB
	; BG1 wave code

		REP #$20
		STZ $0E
		LDA $14
		AND #$0001
		BEQ $03 : LDA #$0060
		TAX
		CLC : ADC #$0C21+6			; get pointer and index to current tables
		STA $00
		SEP #$20


		LDA $14					;\
		LSR #2					; |
		AND #$0F				; |
		INC A					; | update scanline count to scroll wave effect
		STA $0C20+6,x				; |
		CMP #$01 : BNE .NoUpdate		; |
		LDA $14					; |
		AND #$02 : BNE .NoUpdate		;/

		.Update					;\
		LDY #$30				; |
	-	LDA ($00),y				; |
		AND #$F0				; > maintain hi nybble
		STA $02					; |
		LDA ($00),y				; |
		SEC : SBC #$04				; | update pointers for wave effect
		AND #$0F				; |
		ORA $02					; |
		STA ($00),y				; |
		DEY #3 : BPL -				; |
		.NoUpdate				;/

		REP #$20				;\
		LDA $0E					; |
		BPL $03 : LDA #$0000			; |
		LDY !IceLevel : BNE +			; > no wave effect when frozen
		CMP #$00E0				; |
		BCC $03					; |
	+	LDA #$00E0				; | distance to hi prio water from top of screen
		SEP #$20				; |
		LSR A					; |
		STA $0C20,x				; |
		BCC $01 : INC A				; |
		STA $0C23,x				;/
		LDA $00					;\ > lo byte of pointer
		SEC : SBC #$07				; |
		TAY					; |
		LDA $0C20,x				; |
		BNE $03 : INY #3			; | see how many chunks we need
		LDA $0C23,x				; |
		BNE $03 : INY #3			;/
		STY !HDMA3source			; > update source



	; +0+0
	; -1+0
	; -1+1
	; +0+1


		REP #$20				;\
		LDA $14					; |
		AND #$0001				; |
		BEQ $03 : LDA #$0010			; |
		TAX					; |
		LDA $1A					; |
		STA $0D00,x				; |
		STA $0D0C,x				; |
		DEC A					; |
		BPL $03 : LDA #$0000			; > don't allow negative due to clipping errors
		STA $0D04,x				; |
		STA $0D08,x				; | recalculate BG1 positions
		LDA $1C					; |
		CLC : ADC $7888
		STA $0D02,x				; |
		STA $0D06,x				; |
		INC A					; |
		STA $0D0A,x				; |
		STA $0D0E,x				;/
		PLB
		RTL








