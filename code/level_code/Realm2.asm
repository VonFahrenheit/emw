

levelinit7:
		LDA #$06
		TRB !MainScreen
		TRB !SubScreen

		LDA #$11
		TSB !MainScreen
		TRB !SubScreen

		LDA #$0C : STA !TextPal			; Text palette = 0x03

		JSL CLEAR_DYNAMIC_BG3

		LDA #$02 : STA !BG2ModeH
		LDA #$04 : STA !BG2ModeV
		%GradientRGB(HDMA_BlueSky)
		LDA #$B9 : STA !Level+4			; > base offset
		LDA #$07 : STA !Level+5			; > size of chunks
		JSL levelinit5_HDMA
		JML level7


levelinit8:
		INC !SideExit

		REP #$20
		LDA #$0404 : STA !BG2ModeH		; BG2 scroll: variable2;variable2
		LDA #$01D0 : STA !BG2BaseV		; base BG2 position
		SEP #$20
		RTL




levelinit9:
	RTL
levelinitA:
		LDA #$01 : STA !3DWater

		LDA #$11				;\
		TSB !MainScreen				; | BG1 and sprites are on both main and sub
		TSB !SubScreen				;/

		LDA #$80 : STA !Level+3
		JML levelA_HDMA


levelinitB:
		INC !SideExit

		LDA #$07				;\
		STA !BG2ModeH				; | 75% BG2 scroll rate
		STA !BG2ModeV				;/

		REP #$20
		LDA !BG2BaseV
		CLC : ADC #$0040
		STA !BG2BaseV
		SEP #$20

		JSL levelB_HDMA
		SEP #$20
		JML levelB

levelinitD:
		INC !SideExit

		LDA #$1F				;\ Put everything on mainscreen
		STA !MainScreen				;/
		STZ !SubScreen				; > Disable subscreen




		REP #$20				; > A 16 bit
		LDA #$0F03				;\ Use mode 3 to access both bytes of 210F and 2110
		STA $4350				;/
		SEP #$20				; > A 8 bit
		LDA #$40				;\ Bank of table
		STA $4354				;/
		LDA #$20				;\ Enable HDMA on channel 5 
		TSB $6D9F				;/
		JSL levelD_HDMA : INC $14		;\ Set up double-buffered HDMA
		JSL levelD_HDMA : DEC $14		;/
		JML levelD


levelinitE:
		LDA #$0C : STA !TextPal			; Text palette = 0x03
		LDA #$01 : STA !BG2ModeH
		LDA #$06 : STA !BG2ModeV
		REP #$20
		STZ !BG2BaseV
		JSL read3($048434)
		SEP #$20

		LDA #$2C : STA !SPC3			; Battle music

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
		BRA .NoRestrict
		.NotTreasury

		CPY #$19 : BCS .NoRestrict
		LDA #$19 : STA $5F
		LDA #$45
	.Music	STA !SPC3				; Normal music
		.NoRestrict

		RTL

levelinit14:
		JML level14


levelinit28:
		LDA $1B
		BEQ .BigCave

		.MoleCave
		LDA #$01 : STA !Level+4
		STZ !EnableHScroll
		LDA !StoryFlags+$02
		AND #$07
		CMP #$03 : BCC +

		LDA #$42 : STA !SPC3
		JML level28_Block

	+	LDA #$2C : STA !SPC3
		RTL

		.BigCave
		LDA #$09 : STA $5E
		LDA #$42 : STA !SPC3
		RTL

levelinit29:
		LDA #$15 : STA !MainScreen		; everything except BG2 on main
		LDA #$02 : STA !SubScreen		; BG2 on sub
		%GradientRGB(HDMA_Sunset)		; gradient
		RTL

levelinit30:
		JML levelinitA

levelinit31:
		LDA #$0E : STA !Translevel
		LDA #$01 : STA $73CE			; set midway flag
		LDX !Translevel				;\
		LDA !LevelTable1,x			; | set checkpoint flag
		ORA #$40				; |
		STA !LevelTable1,x			;/
		LDA !Level : STA !LevelTable2,x		;\
		LDA !Level+1 : BEQ +			; |
		LDA !LevelTable1,x			; | store level number to table
		ORA #$20				; |
		STA !LevelTable1,x			;/
		+

		JSL CLEAR_DYNAMIC_BG3

		LDA #$11				;\
		TSB !MainScreen				; | BG1 and sprites are on both main and subscreen
		TSB !SubScreen				;/
		RTL

levelinit34:
		JML level34



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
		TRB !MainScreen
		TSB !SubScreen


		LDA.b #level5_HDMA : STA !HDMAptr		;\
		LDA.b #level5_HDMA>>8 : STA !HDMAptr+1		; | Set up pointer
		LDA.b #level5_HDMA>>16 : STA !HDMAptr+2		;/

		LDA !StoryFlags+$02
		AND #$07 : BNE $04 : JML .CheckCoin
		CMP #$01 : BEQ .QuestStarted
		CMP #$02 : BEQ .QuestAbandoned
		CMP #$04 : BCC .QuestComplete
		JML .MountainEnd

		.QuestComplete
		LDA !Level+3 : BNE +
		JSL .NearMountainKing
		BCC $03
	+	JML .MountainEnd
		LDA #$01 : STA !Level+3
	;	LDA #$06 : STA !MsgTrigger
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
		JSL .NearMountainKing
		BCS .MountainEnd
	;	LDA #$05 : STA !MsgTrigger
		LDA #$01 : STA !Level+3
		LDA !StoryFlags+$02
		AND.b #$07^$FF
		ORA #$01
		STA !StoryFlags+$02
		BRA .MountainEnd

		.QuestStarted
		JSL .NearMountainKing
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
		LDA !LevelTable1,x
		AND #$02 : BEQ .MountainEnd
	;	LDA #$01 : STA !MsgTrigger
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
		LDA #$0004 : JSL END_Left		;/
		LDA $1B
		CMP #$1E : BCC .NoExit
		REP #$20
		LDA #$01A0 : JSL EXIT_Down
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
		LDA !Level+2 : BEQ .Return
		REP #$20
		LDY #$0E
		LDX.b #$7F*2
	-	LDA .Pal1,y : STA !ShaderInput+($71*2),x
		DEX #2
		DEY #2 : BPL -
		SEP #$20
		STZ !Level+2
		RTL


		.CastleColor
		LDA !Level+2 : BNE .Return
		REP #$20
		LDY #$0E
		LDX.b #$7F*2
	-	LDA .Pal2,y : STA !ShaderInput+($71*2),x
		DEX #2
		DEY #2 : BPL -
		SEP #$20
		LDA #$01 : STA !Level+2

		.Return
		RTL


	; Carry clear = close
	; Carry set = not close
		.NearMountainKing
		REP #$20
		LDA $1A
		SEC : SBC #$0DE0
		BPL $03 : EOR #$FFFF
		CMP #$0050
		SEP #$20
		RTL

		.Pal1
		dw $7FDD,$0000,$08E1,$0DA2,$1663,$4653,$56F8	; green version

		.Pal2
		dw $7FDD,$0000,$0C62,$2108,$31AD,$4653,$56F8	; grey version


level8:
	RTL

level9:
	RTL
levelA:
		STZ !SideExit
		LDA $1B : BNE +
		INC !SideExit
		+

		LDA.b #.HDMA : STA !HDMAptr+0
		LDA.b #.HDMA>>8 : STA !HDMAptr+1
		LDA.b #.HDMA>>16 : STA !HDMAptr+2
		RTL



; !Level+2: timer
; !Level+3: state (0 = wait, 1 = indicate, 2 = active)
; !Level+4: Xpos lo byte
; !Level+5: Xpos hi byte
; !VineDestroyTimer+$00: init flag for big bolt
; !VineDestroyTimer+$01: Ypos lo of big bolt
; !VineDestroyTimer+$02: Ypos hi of big bolt
; !VineDestroyTimer+$03: height of big bolt




		.HDMA
		PHB : PHK : PLB
		PHP

		SEP #$30
		LDA $14				;\
		AND #$01			; | X = HDMA table index
		BEQ $02 : LDA #$20		; |
		TAX				;/
		REP #$20			; > A 16-bit
		LDA $1A : STA $22		;\
		LDA $1C				; |
		BMI ..wrap			; |
		CMP #$0030 : BCS ..nowrap	; |
		..wrap				; |
		AND #$000F			; |
		ORA #$0030			; |
		..nowrap			; |
		STA $24				;/

		LDA #$0176 : STA !Level+2	; water height

		LDA #$0166			;\
		SEC : SBC $24			; |
		CMP #$00D8 : BCC ..fulleffect	; |
		..onlyrain			; | if only rain fits on screen
		LDA #$0001 : STA $0400,x	; |
		STZ $0405,x			; |
		BRA ..scrollrain		;/
		..fulleffect			;\
		LSR A				; |
		STA $0400,x			; | scanline counts (rain part)
		BCC $01 : INC A			; |
		STA $0405,x			;/
		LDA #$0008 : STA $040A,x	; scanline count (lo prio water part)
		LDA #$0001 : STA $040F,x	; scanline count (hi prio water part)
		STZ $0414,x			; end table

		LDA $1C				;\
		STA $040D,x			; | water Y = BG1 Y
		STA $0412,x			;/
		LDA $14				;\
		AND #$00FF			; | scroll lo prio water
		CLC : ADC $1A			; |
		STA $040B,x			;/
		LSR #2				;\
		CLC : ADC $040B,x		; | hi prio water = lo prio water x 125%
		STA $0410,x			;/


		..scrollrain
		LDA $14				;\
		ASL A				; | rain scroll value
		AND #$000F : STA $00		;/
		CLC : ADC $22			;\
		STA $0401,x			; | scroll rain right
		STA $0406,x			;/
		LDA $24				;\
		SEC : SBC $00			; |
		SEC : SBC #$0020		; | scroll rain down
		STA $0403,x			; |
		STA $0408,x			;/



		..updatemirrors
		LDA #$1103 : STA $4330		;\
		STZ $4334			; | mode 3 to write twice to 2111 and 2112
		TXA				; |
		ORA #$0400			; |
		STA !HDMA3source		;/
		SEP #$20			; > A 8-bit

		LDA #$08 : TSB !HDMA		; > HDMA on channel 3


		PLP
		PLB
		RTL


levelB:
		REP #$20
		LDA.w #.HDMA : STA !HDMAptr+0		; > set lo-mid bytes of HDMA pointer
		LDA #$1FE8				;\ do this now so I don't have to SEP #20
		JSL END_Right				;/
		LDA.b #.HDMA>>16 : STA !HDMAptr+2	; > set hi byte of HDMA pointer
		RTL

		.HDMA
		PHP
		SEP #$20
		LDA !GameMode
		CMP #$14 : BEQ +
		LDA $1B : BEQ +
		LDA #$8F : STA $1E
		LDA #$0A : STA $1F
	+	REP #$20
		LDA $1E : STA $4204			;\ BG2 X has to loop every 9 tiles
		LDX #$90 : STX $4206			;/

		LDA $14					;\
		AND #$0007 : BNE +			; |
		INC !Level+2				; | BG3 X
	+	LDA $1A					; |
		CLC : ADC !Level+2			; |
		STA $22					;/
		NOP #3					; finish division

		LDA $4216 : STA $1E			; write BG2 X to make sure it loops every 9 tiles

		PLP					; |
		RTL					;/



levelD:

		STZ !BG2ModeV
		LDA #$C0 : STA !BG2BaseV
		LDA.b #.HDMA : STA !HDMAptr+0
		LDA.b #.HDMA>>8 : STA !HDMAptr+1
		LDA.b #.HDMA>>16 : STA !HDMAptr+2
		RTL

		.HDMA
		PHP
		SEP #$20
		LDA.b #..SA1 : STA $3180
		LDA.b #..SA1>>8 : STA $3181
		LDA.b #..SA1>>16 : STA $3182
		JSR $1E80

		STZ !HDMA5source
		LDA $14
		AND #$01
		ASL #2
		ORA #$A0
		STA !HDMA5source+1

		PLP
		RTL



	; ceiling section is $140 bytes
	; this is skipped on tall levels (32 tiles and above)



		..SA1
		PHP
		PHB : PHK : PLB
		SEP #$20
		STZ $2250				; set multiplication

		REP #$30				; all regs 16 bit

		LDA $14					;\
		AND #$0001				; | HDMA table base index
		BEQ $03 : LDA #$0400			; |
		STA $0A					;/


		LDY !LevelHeight			;\
		CPY #$0200 : BCC +			; |
		BRA ++					; | X = table index (skip ceiling on tall levels)
	+	ADC #$0140				; |
	++	TAX					;/


		LDA #$007F				;\
		CPY #$0200 : BCS +			;  > ignore ceiling part on tall levels
		SEC : SBC #$0040			; |
	+	STA $06					;  > accumulating total scanline count
		LSR A					; |
		STA $40A000,x				; | scanline count for non-parallax part
		BCC $01 : INC A				; |
		STA $40A005,x				; |
		CLC : ADC $40A000,x			; |
		STA $00					;/
		LDA $20					;\
		STA $40A003,x				; | set up Y coords for non-parallax part
		SEC : SBC #$0020			; | (expand this section 2 tiles)
		STA $40A008,x				;/

		PEI ($20)				; preserve BG2 Y


		CPY #$0200 : BCS $03 : JMP ..small



	; BG3 code goes here, but only on tall levels


		JSL Water3D_Calc



		LDA $1C
		CMP #$0560 : BCC ..stretch
		SBC #$0560
		JMP ..compress

		..stretch
		STZ $0C
		LDA $1C
	-	CMP #$0006 : BCC +
		SBC #$0006
		INC $0C
		BRA -


	+	LDA $0C
		LSR A
		STA $0E
		LDA #$0082				;\
		SEC : SBC $0E				; |
		STA $06					; |
		LSR A					; | extension chunk scanline count
		STA $40A00A,x				; |
		BCC $01 : INC A				; |
		STA $40A00F,x				;/
		LDA $1E					;\
		STA $40A00B,x				; |
		STA $40A010,x				; |
		LDA #$001E				; |
		CLC : ADC $0E				; | extension chunk
		CMP #$0048				; |
		BCS $03 : LDA #$0048			; |
		STA $40A00D,x				; |
		STA $40A012,x				;/
		STA $02					; BG2 height during stretch

		LDA #$00E5				;\
		SEC : SBC $0C				; | for stretching purposes
		STA $0C					;/
		TXA					;\
		CLC : ADC #$000A			; | X = HDMA table index
		TAX					;/
		LDY #$005F				; Y = index for scroll/stretch tables
		LDA $06					;\
		CLC : ADC #$0080			; | total scanline count
		STA $06					;/


	-	LDA #$0001 : STA $40A00A,x		; scanline
		INC $06					; increment total scanline count
		STY $08					;\
		TYA					; |
		ASL A					; |
		TAY					; |
		LDA $1E					; |
		SEC : SBC #$0200			; | x coords
		STA $2251				; |
		LDA ..ScrollTable_pos,y : STA $2253	; |
		NOP : BRA $00				; |
		LDA $2307 : STA $40A00B,x		; |
		LDY $08					;/
		CPY #$0050 : BCS ++			;\
		LDA ..StretchTable,y			; |
		AND #$00FF				; |
		CMP $0C					; |
		BEQ +					; |
		BCS ++					; | stretch
	+	DEC $02					; |
		LDA $40A00A,x : STA $40A00F,x		; |
		LDA $40A00B,x : STA $40A010,x		; |
		LDA $02 : STA $40A00D,x			; |
		INX #5					;/
	++	LDA $02 : STA $40A00D,x			; y coords
		INX #5					;\
		LDA $06					; | loop
		CMP #$00E0 : BCS +			; |
		DEY : BPL -				;/

	+	LDA #$0000 : STA $40A00A,x
		PLA : STA $20
		PLB
		PLP
		RTL



		..small
		LDA $1C					;\ small level
		CMP #$00C0				; \ cap at 0x0C0 and compress
		BCC $03 : LDA #$00C0			; /

		..compress
		LDY #$0010 : STY $0C			;\
		STZ $0E					; |
	-	CMP #$0003 : BCC +			; |
		SBC #$0003				; |
		INC $0E					; | starting factor index
		BRA -					; |
	+	LDA #$0040				; |
		SEC : SBC $0E				; |
		LSR #2					; |
		STA $0C					; |
		LDA #$0020				; |
		SEC : SBC $0C				; |
		TAY					;/

		LDA $20 : STA $02			;\
		SEC : SBC $0C				; | BG2 Y for ceiling
		STA $20					;/
		LDA $0C					;\
		LSR A					; |
		LDA $02					; | BG2 Y for ground
		SEC : SBC $0C				; |
		SEC : SBC #$0020			; |
		STA $02					;/


		LDX $0A					; X = base table index
		LDA !LevelHeight			;\
		CMP #$0200 : BCC ..Ceiling		; | skip ceiling on tall levels
		JML ..Floor				; |
		..Ceiling				;/


	-	LDA #$0001 : STA $40A000,x		;\
		INC $06					; > increment total scanline count
		LDA $1E : STA $2251			; |
		STY $08					; |
		TYA					; |
		ASL A					; |
		TAY					; | ceiling X positions
		LDA ..ScrollTable_pos,y			; |
		STA $2253				; |
		NOP : BRA $00				; |
		LDA $2307				; |
		LSR A					; |
		STA $40A001,x				;/
		LDA $0C					;\
		LSR A : BEQ ++				; |
		TAY					; |
	--	LDA ..CeilingTable,y			; |
		AND #$00FF				; | compress ceiling
		ORA #$0020				; |
		CMP $08 : BEQ +				; |
		DEY : BPL --				; |
		BRA ++					; |
	+	INC $20					; |
		INC $08					; |
	++	LDY $08					;/
		LDA $20					;\
		CLC : ADC #$0010			; | ceiling Y positions
		STA $40A003,x				;/
		INY					;\
		INX #5					; | ceiling loop
		CPX #$0140 : BEQ +			; |
		CPX #$0540 : BNE -			;/

		..Floor
	+	LDA $0C
		CLC : ADC #$005F
		TAY

	-	LDA #$0001 : STA $40A00A,x		; floor scanline count
		INC $06					; increment total scanline count
		STY $08					;\
		TYA					; |
		ASL A					; |
		TAY					; |
		LDA $1E					; |
		SEC : SBC #$0200			; | floor X positions
		STA $2251				; |
		LDA ..ScrollTable_pos,y : STA $2253	; |
		NOP : BRA $00				; |
		LDA $2307 : STA $40A00B,x		; |
		LDY $08					;/

		LDA ..StretchTable,y			;\
		AND #$00FF				; |
		CMP $0E					; |
		BEQ +					; | compress floor
		BCS ++					; |
	+	INC $02					; |
		DEY					;/
	++	LDA $02 : STA $40A00D,x			; > floor y positions

		INX #5					;\ loop
		DEY : BPL -				;/

		LDA $06
		CMP #$00E0 : BCS +

		LDY #$003E				;\
	-	LDA #$0001 : STA $40A00A,x		; |
		INC $06					; > increment total scanline count
		LDA $1E					; |
		SEC : SBC #$0200			; |
		STA $2251				; |
		LDA ..ScrollTable,y : STA $2253		; | extend floor to connect to BG1
		NOP : BRA $00				; |
		LDA $2307 : STA $40A00B,x		; |
		LDA $02 : STA $40A00D,x			; |
		INX #5					; |
		LDA $06					; |
		CMP #$00E0 : BCS +			; |
		DEY #2 : BPL -				;/

	+	LDA #$0000 : STA $40A00A,x		; end table

		PLA : STA $20				; restore BG2 Y

		PLB
		PLP
		RTL




; generated using value 0.03125

..ScrollTable
dw $0153,$0150,$014E,$014B,$0149,$0146,$0143,$0141		;\
dw $013E,$013C,$0139,$0136,$0134,$0131,$012E,$012C		; | negative section
dw $0129,$0127,$0124,$0121,$011F,$011C,$011A,$0117		; |
dw $0114,$0112,$010F,$010D,$010A,$0107,$0105,$0102		;/

...pos
dw $0100,$00FD,$00FA,$00F8,$00F5,$00F2,$00F0,$00ED
dw $00EB,$00E8,$00E5,$00E3,$00E0,$00DE,$00DB,$00D8
dw $00D6,$00D3,$00D1,$00CE,$00CB,$00C9,$00C6,$00C3
dw $00C1,$00BE,$00BC,$00B9,$00B6,$00B4,$00B1,$00AF
dw $00AC,$00A9,$00A7,$00A4,$00A2,$009F,$009C,$009A
dw $0097,$0094,$0092,$008F,$008D,$008A,$0087,$0085
dw $0082,$0080,$007D,$007A,$0078,$0075,$0073,$0070
dw $006D,$006B,$0068,$0065,$0063,$0060,$005E,$005B
dw $0058,$0056,$0053,$0051,$004E,$004B,$0049,$0046
dw $0044,$0041,$003E,$003C,$0039,$0046,$0034,$0031
dw $002F,$002C,$0029,$0027,$0024,$0022,$001F,$001C
dw $001A,$0017,$0015,$0012,$000F,$000D,$000A,$0008




..StretchTable
db $00,$06,$0C,$12,$18,$1E,$24,$2A,$30,$36,$3C,$42,$48,$4E,$54,$5A
db $01,$07,$0D,$13,$19,$1F,$25,$2B,$31,$37,$3D,$43,$49,$4F,$55,$5B
db $02,$08,$0E,$14,$1A,$20,$26,$2C,$32,$38,$3E,$44,$4A,$50,$56,$5C
db $03,$09,$0F,$15,$1B,$21,$27,$2D,$33,$39,$3F,$45,$4B,$51,$57,$5D
db $04,$0A,$10,$16,$1C,$22,$28,$2E,$34,$3A,$40,$46,$4C,$52,$58,$5E
db $05,$0B,$11,$17,$1D,$23,$29,$2F,$35,$3B,$41,$47,$4D,$53,$59,$5F

..CeilingTable
db $00,$10,$20,$30,$04,$14,$24,$34,$08,$18,$28,$38,$0C,$1C,$2C,$3C


	Water3D:
	.Calc
		LDA !IceLevel
		AND #$00FF : BNE +
		LDA $14
		AND #$0003 : BNE +
		INC !Level+4				; water does not animate when frozen
	+	LDA $1C
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

		STZ $2250				; set multiplication
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
		LDA #$0001 : STA $414000,x
		LDA #$0060 : STA $414003,x
		LDA #$0000 : STA $414005,x
		JMP ..endbg3

	+
	-	CMP #$007F
		BCC $03 : LDA #$007F
		STA $414000,x
		CPY #$0016 : BNE +
		LDA #$0060 : STA $414003,x		; ignore X here
		BRA ++
	
	+	LDA !BigRAM+$18,y : STA $414001,x
		LDA !BigRAM,y
		EOR #$FFFF : INC A
		CLC : ADC $06
		STA $414003,x

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
	++	LDA #$0001 : STA $414000,x
		LDA #$0020 : STA $414003,x
		LDA #$0000 : STA $414005,x
		JMP ..endbg3


		..BG3low				; viewed from above
		LDY #$0000
		LDA !BigRAM,y
		CMP #$007F : BCC +
		LSR A
		STA $414000,x
		BCC $01 : INC A
		PHA
		LDA #$0060 : STA $414003,x
		LDA #$0000 : STA $414001,x
		INX #5
		PLA
	+	STA $414000,x
		LDA #$0060 : STA $414003,x
		LDA #$0000 : STA $414001,x
		INX #5
		STZ $00


	-	CPY #$0016 : BNE +
		LDA #$0001 : BRA ++
	+	LDA !BigRAM+2,y
		SEC : SBC !BigRAM,y
		BPL $04 : EOR #$FFFF : INC A
		CMP #$0000 : BEQ +
	;	BNE $01 : INC A
		CMP #$007F
		BCC $03 : LDA #$007F
	++	STA $414000,x
		LDA !BigRAM,y
		EOR #$FFFF : INC A
		CLC : ADC $00
		STA $414003,x
		LDA !BigRAM+$18,y : STA $414001,x
		INX #5
	+	INY #2
		LDA $00
		CLC : ADC #$0008
		STA $00
		CPY #$0018 : BNE -
		LDA #$0000 : STA $414000,x

		..endbg3
		PLX
		RTL


..BG3Table
dw $0015,$0033,$0050,$006D,$008B,$00A8,$00C5,$00E3,$0100,$011D,$013B,$0158






levelE:
		JSL WARP_BOX
		db $0F : dw $0170,$1440 : db $50,$20

		JSL WARP_BOX
		db $0F : dw $01F6,$0B90 : db $0A,$20

		JSL WARP_BOX
		db $0F : dw $0000,$0290 : db $0A,$20



		LDA !Level+4 : BNE .Gate

		REP #$20
		LDA $96
		CMP #$00C0 : BCS +
		LDA #$0100 : STA $00
		LDA #$0000
		JSL SCROLL_UPRIGHT
		BRA ++
		+
		STZ !Level+2
		LDX #$01 : STX !EnableVScroll
		++

		LDA.w #.Table1 : JSL TalkOnce

		LDA #$01A0 : STA $E8
		LDA #$0050 : STA $EA
		LDA #$0008 : STA $EC
		LDA #$0010 : STA $EE
		SEP #$20
		JSL PlayerContact : BCS .Gate

		.NoWarp
		JML DANCE


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
		LDA #$0200 : STA !HDMA2source
		LDA #$2601 : STA $4320
		SEP #$20
		LDA #$04 : TSB $6D9F
		LDA #$22
		STA $41
		STA $42
		RTL

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
		TRB !MainScreen
		TRB !SubScreen
		RTL


		;  ID  MSG      Xpos  Ypos       W   H
.Table1		db $00,$02 : dw $0010,$10D0 : db $B0,$50



level14:

		REP #$20
		LDA.w #.RoomPointers
		JSL LoadCameraBox
		RTL

		.RoomPointers
		dw .ScreenMatrix
		dw .BoxTable
		dw .DoorList
		dw .DoorTable




;	Key ->	   X  Y  W  H
;		   |  |  |  |
;		   V  V  V  V
;
.BoxTable
.Box0	%CameraBox(0, 5, 3, 2)
.Box1	%CameraBox(3, 4, 0, 0)
.Box2	%CameraBox(1, 4, 1, 0)
.Box3	%CameraBox(2, 2, 2, 1)
.Box4	%CameraBox(4, 4, 0, 2)
.Box5	%CameraBox(5, 2, 2, 4)
.Box6	%CameraBox(0, 2, 1, 1)
.Box7	%CameraBox(1, 0, 1, 1)
.Box8	%CameraBox(0, 0, 0, 1)
.Box9	%CameraBox(5, 0, 1, 1)
.BoxA	%CameraBox(3, 0, 1, 1)
.BoxB	%CameraBox(7, 0, 0, 0)
.BoxC	%CameraBox(7, 1, 0, 3)
.BoxD	%CameraBox(4, 7, 3, 0)
.BoxE	%CameraBox(0, 5, 2, 1)
.BoxF	%CameraBox(0, 4, 0, 0)


.ScreenMatrix	db $08,$07,$07,$0A,$0A,$09,$09,$0B
		db $08,$07,$07,$0A,$0A,$09,$09,$0C
		db $06,$06,$03,$03,$03,$05,$05,$0C
		db $06,$06,$03,$03,$03,$05,$05,$0C
		db $0F,$02,$02,$01,$04,$05,$05,$0C
		db $0E,$0E,$0E,$00,$04,$05,$05,$05
		db $0E,$0E,$0E,$00,$04,$05,$05,$05
		db $00,$00,$00,$00,$0D,$0D,$0D,$0D




.DoorList	db $FF			; area 0
		db $04,$05,$FF		; area 1
		db $03,$04,$FF		; area 2
		db $FF			; area 3
		db $05,$06,$FF		; area 4
		db $06,$FF		; area 5
		db $FF			; area 6
		db $02,$FF		; area 7
		db $02,$FF		; area 8
		db $00,$01,$FF		; area 9
		db $00,$FF		; area A
		db $01,$FF		; area B
		db $FF			; area C
		db $FF			; area D
		db $FF			; area E
		db $03,$FF		; area F


.DoorTable
.Door0		%Door(5, 0)
.Door1		%Door(7, 0)
.Door2		%Door(1, 1)
.Door3		%Door(1, 4)
.Door4		%Door(3, 4)
.Door5		%Door(4, 4)
.Door6		%Door(5, 6)




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
		LDA #$00C0 : JSL LOCK_VSCROLL		;/


		.Scroll
		SEP #$20
		LDA $1B
		CMP #$07 : BEQ .EndLevel
		CMP #$08 : BNE .NoEnd

		.EndLevel
		LDY #$02
		REP #$20
		LDA #$0000 : JML END_Up

		.NoEnd
		RTL


		.MoleRoom
		LDA !StoryFlags+$02			;\
		AND #$07				; | moles can only be fought once
		CMP #$03 : BCS +			;/


	; Mole spawn
		LDX #$0F
	-	LDA $3230,x
		BEQ .ProcessMoles
	+	JML .NoMoreMoles

		.ProcessMoles
		DEX : BPL -
		LDA !Difficulty				;\
		INC #2					; | number of waves depends on difficulty
		STA $00					;/
		LDY !Level+5
		CPY $00 : BCS $04 : JML .Mole
		BNE .NoMessage
	;	LDA #$02 : STA !MsgTrigger
		JML .End

		.NoMessage
		CPY #$40 : BNE .NoPath

		LDA !StoryFlags+$02
		AND.b #$07^$FF
		ORA #$03
		STA !StoryFlags+$02

		.Block
		LDA #$09 : STA !SPC4			; > boom sfx
		PEI ($98)
		PEI ($9A)
		REP #$20
		LDA #$0940 : STA $9A
		LDA #$0160 : STA $98
		LDX #$02 : STX $9C
		JSL $00BEB0
		STZ $00
		STZ $02
		STZ $04
		STZ $06
		LDA.w #!prt_smoke16x16 : JSL SpawnParticleBlock
		LDA #$0950 : STA $9A
		LDA #$0160 : STA $98
		LDX #$02 : STX $9C
		JSL $00BEB0
		STZ $00
		STZ $02
		STZ $04
		STZ $06
		LDA.w #!prt_smoke16x16 : JSL SpawnParticleBlock
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
		LDA #$01A0 : JSL EXIT_Down
		SEP #$20

		.Return
		RTL

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
		LDA #$01F8 : JML END_Right		; exit

		.NoExit
		STZ !SideExit
		RTL


level30:
		JSL levelA
		REP #$20
		LDA #$0AE8 : JML END_Right		; Exit

level31:
		LDA !MsgTrigger
		ORA !MsgTrigger+1
		BNE .Continue
		LDA !Level+4 : BEQ .Continue
		DEC !Level+4 : BNE .Continue
		JML END_End

		.Continue
		JML DANCE


level34:



		REP #$20
		LDA.w #.RoomPointers
		JSL LoadCameraBox
		RTL

		.RoomPointers
		dw .ScreenMatrix
		dw .BoxTable
		dw .DoorList
		dw .DoorTable




;	Key ->	   X  Y  W  H
;		   |  |  |  |
;		   V  V  V  V
;
.BoxTable
.Box0	%CameraBox(0, 0, 0, 3)
.Box1	%CameraBox(1, 0, 0, 3)
.Box2	%CameraBox(2, 0, 5, 0)
.Box3	%CameraBox(2, 1, 1, 2)
.Box4	%CameraBox(4, 1, 3, 0)
.Box5	%CameraBox(3, 2, 4, 1)
.Box6	%CameraBox(0, 4, 1, 1)
.Box7	%CameraBox(2, 4, 0, 1)
.Box8	%CameraBox(3, 4, 0, 3)
.Box9	%CameraBox(4, 4, 3, 2)
.BoxA	%CameraBox(5, 5, 2, 2)
.BoxB	%CameraBox(0, 6, 1, 1)
.BoxC	%CameraBox(2, 6, 0, 0)
.BoxD	%CameraBox(2, 7, 0, 0)
.BoxE	%CameraBox(4, 7, 0, 0)


.ScreenMatrix	db $00,$01,$02,$02,$02,$02,$02,$02
		db $00,$01,$03,$03,$04,$04,$04,$04
		db $00,$01,$03,$05,$05,$05,$05,$05
		db $00,$01,$03,$05,$05,$05,$05,$05
		db $06,$06,$07,$08,$09,$09,$09,$09
		db $06,$06,$07,$08,$09,$0A,$0A,$0A
		db $0B,$0B,$0C,$08,$09,$0A,$0A,$0A
		db $0B,$0B,$0D,$08,$0E,$0A,$0A,$0A




.DoorList	db $01,$FF		; area 0
		db $00,$01,$FF		; area 1
		db $00,$FF		; area 2
		db $FF			; area 3
		db $FF			; area 4
		db $FF			; area 5
		db $02,$FF		; area 6
		db $02,$FF		; area 7
		db $02,$FF		; area 8
		db $03,$FF		; area 9
		db $03,$FF		; area A
		db $04,$05,$FF		; area B
		db $04,$FF		; area C
		db $05,$FF		; area D
		db $FF			; area E


.DoorTable
.Door0		%Door(2, 0)
.Door1		%Door(1, 3)
.Door2		%Door(2, 5)
.Door3		%Door(5, 5)
.Door4		%Door(2, 6)
.Door5		%Door(2, 7)



