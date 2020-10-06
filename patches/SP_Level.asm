header
sa1rom

; --Defines--

incsrc "Defines.asm"


; --Macros--

	macro GradientRGB(table)
		REP #$20			; > A 16 bit
		LDA #$3200			;\
		STA $4330			; |
		LDA #<table>_Red		; |
		STA !HDMA3source		; | Set up red colour math on channel 3
		PHK				; |
		PLY				; |
		STY $4334			;/
		LDA #$3200			;\
		STA $4340			; |
		LDA #<table>_Green		; | Set up green colour math on channel 4
		STA !HDMA4source		; |
		STY $4344			;/
		LDA #$3200			;\
		STA $4350			; |
		LDA #<table>_Blue		; | Set up blue colour math on channel 5
		STA !HDMA5source		; |
		STY $4354			;/
		SEP #$20			; > A 8 bit
		LDA #$38			;\ Enable HDMA on channels 3, 4, and 5
		TSB $6D9F			;/
	endmacro

	macro GradientGB(table)
		REP #$20			; > A 16 bit
		LDA #$3200			;\
		STA $4330			; |
		LDA #<table>_Green		; |
		STA !HDMA3source		; | Set up red colour math on channel 3
		PHK				; |
		PLY				; |
		STY $4334			;/
		LDA #$3200			;\
		STA $4340			; |
		LDA #<table>_Blue		; | Set up green colour math on channel 4
		STA !HDMA4source		; |
		STY $4344			;/
		SEP #$20			; > A 8 bit
		LDA #$18			;\ Enable HDMA on channels 3 and 4
		TSB $6D9F			;/
	endmacro


	macro TalkBox(X, Y, W, H, M)		; Xcoord, Ycoord, width, heigth, message
		LDX !P1Dead
		BNE ?P2
		LDA $94
		CMP.w #<X>
		BCC ?P2
		CMP.w #<X>+<H>
		BCS ?P2
		LDA $96
		CMP.w #<Y>
		BCC ?P2
		CMP.w #<Y>+<H>
		BCS ?P2
		LDA $77
		AND #$0004
		BEQ ?P2
		LDA $16
		AND #$0008
		BEQ ?P2
		LDX.b #<M>
		STX !MsgTrigger
		BRA ?Return

		?P2:
		LDX !P2Status
		BNE ?Return
		LDA !P2XPosLo
		CMP.w #<X>
		BCC ?Return
		CMP.w #<X>+<H>
		BCS ?Return
		LDA !P2YPosLo
		CMP.w #<Y>
		BCC ?Return
		CMP.w #<Y>+<H>
		BCS ?Return
		LDA !P2Blocked
		AND #$0004
		BEQ ?Return
		LDA $6DA7
		AND #$0008
		BEQ ?Return
		LDX.b #<M>
		STX !MsgTrigger

		?Return:
	endmacro


; --Hijacks--

	org $00A242
		JML MAIN_Level			;\ Source: LDA $73D4 : BEQ $43
		NOP				;/

	org $00A295
		BRA +				;\
		NOP #2				; | Source: JSL $7F8000
		+				;/

	org $00A5EE
		JML INIT_Level			;\ Source: SEP #$30 : JSR $919B
		NOP				;/

	org $05D8B7
		REP #$30			; > All registers 16 bit
		LDA $0E				;\ Set current level
		STA !Level			;/
		ASL A				;\
		CLC : ADC $0E			; | All entries are 24-bit, so multiply by 3
		TAY				;/
		LDA $E000,y			;\
		STA $65				; |
		LDA $E001,y			; |
		STA $66				; | 16 bit mode saves a bit of space here
		LDA $E600,y			; |
		STA $68				; |
		LDA $E601,y			; |
		STA $69				;/
		BRA +				; > Skip a few leftover bytes

	org $05D8E0
		+				; Execute the rest of the code here


; --Code--

;freecode

org $188000		; Bank already claimed because of Fe26


	LEVEL:

	print "Mega Level data stored at $", pc, "."
	.MegaLevel
	db $00,$00,$5F,$00,$00,$00,$00,$00	;\ 00-0F
	db $00,$00,$00,$00,$00,$00,$00,$00	;/
	db $00,$00,$00,$00,$00,$00,$00,$00	;\ 10-1F
	db $00,$00,$00,$00,$00,$00,$00,$00	;/
	db $00,$00,$00,$00,$00			; > 20-24
	db $00,$00,$00,$00,$00,$00,$00,$00	;\ 101-10F
	db $00,$00,$00,$00,$00,$00,$00		;/
	db $00,$00,$00,$00,$00,$00,$00,$00	;\ 120-12F
	db $00,$00,$00,$00,$00,$00,$00,$00	;/
	db $00,$00,$00,$00,$00,$00,$00,$00	;\ 130-13B
	db $00,$00,$00,$00			;/


	print "Level unlock data stored at $", pc, "."
	; what translevel each sublevel will unlock
	.Unlock
	db $00,$00,$00,$00,$00,$00,$00,$08,$0B,$00,$0E,$0A,$00,$00,$00,$00	; 000-00F
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; 010-01F
	db $00,$00,$00,$00,$00,$00,$00,$00,$0B,$0B,$00,$00,$00,$00,$00,$00	; 020-02F
	db $0E,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; 030-03F
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; 040-04F
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; 050-05F
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; 060-06F
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; 070-07F
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; 080-08F
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; 090-09F
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; 0A0-0AF
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; 0B0-0BF
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; 0C0-0CF
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; 0D0-0DF
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; 0E0-0EF
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; 0F0-0FF
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; 100-10F
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; 110-11F
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; 120-12F
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; 130-13F
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; 140-14F
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; 150-15F
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; 160-16F
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; 170-17F
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; 180-18F
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; 190-19F
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; 1A0-1AF
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; 1B0-1BF
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; 1C0-1CF
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; 1D0-1DF
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; 1E0-1EF
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; 1F0-1FF

	.VRAM_map
incsrc "LevelGFXIndex.asm"

print "Level code handler inserted at $", pc, "."
	INIT_Level:

		PHB : PHK : PLB			; > Bank wrapper
		PHP
		SEP #$30
		STZ !MarioPalOverride		; reset Mario pal override
		LDA #$00
		STA !PauseThif			; unpause Thif
		STA !LevelInitFlag		; set level INIT
		STA !3DWater			; disable 3D water
		STA !DizzyEffect		; disable dizzy effect
		LDA #$FF			;\
		STA !CameraBoxU+1		; | disable camera box
		STA !CameraForbiddance		;/
		LDX #$00			;\
	-	STA !Map16Remap,x		; | default map16 remap = 0xFF (disabled)
		INX : BNE -			;/
		LDA #$00 : JSL $138020		; > Load Yoshi Coins (A must be 0x00)
		LDA.b #.SA1 : STA $3180		;\
		LDA.b #.SA1>>8 : STA $3181	; | Have SA-1 clear VR2 RAM
		LDA.b #.SA1>>16 : STA $3182	; |
		JSR $1E80			;/
		PLP
		LDY !Translevel			;\
		LDA.w LEVEL_MegaLevel,y		; | Set mega level
		STA !MegaLevelID		;/
		LDA !Level			;\
		ASL A				; |
		TAX				; | Load pointer based on level number
		LDA .Table,x			; |
		STA $0000			;/
		STZ !Level+2			;\ Clear extra bytes
		STZ !Level+4			;/
		STZ !GlobalPalset1		;\ reset global palset option
		STZ !GlobalPalset2		;/
		STZ !SmoothCamera		; Clear smooth camera
		LDA #$0000			; > Set up clear
		STA !HDMAptr+0			;\ Clear HDMA pointer
		STA !HDMAptr+1			;/
		SEP #$10			; > Index 8 bit
		LDX #$80 : STX $2100		; start f-blank

		LDX #$14			;\
	-	LDA $6703+2,x : STA $00A0,x	; | store this palette in SNES WRAM
		DEX #2 : BPL -			;/

		LDA #$2200 : STA $4300		;\
		LDA !Characters			; |
		AND #$000F			; |
		ASL #5				; |
		CLC : ADC.w #!PalsetData+5	; |
		STA $4302			; | f-blanked-wrapped CGRAM upload for P2 palette
		LDX.b #!PalsetData>>16		; |
		STX $4304			; |
		LDA #$0020 : STA $4305		; |
		LDX #$90 : STX $2121		; |
		LDX #$01 : STX $420B		;/
		LDA #$2200 : STA $4300		;\
		LDA !Characters			; |
		AND #$00F0			; |
		ASL A				; |
		CLC : ADC.w #!PalsetData+5	; |
		STA $4302			; | f-blanked-wrapped CGRAM upload for P1 palette
		LDX.b #!PalsetData>>16		; |
		STX $4304			; |
		LDA #$0020 : STA $4305		; |
		LDX #$80 : STX $2121		; |
		LDX #$01 : STX $420B		;/
		LDX #$80 : STX $2118		; > Setup for Mario GFX upload
		LDA !MultiPlayer		;\ Ignore P2 during single player
		AND #$00FF : BEQ +		;/
		LDA !Characters			;\
		AND #$000F			; |
		BNE +				; |
		LDA #$6260			; |
		BRA ++				; |
	+	LDA !Characters			; |
		AND #$00F0			; |
		BNE +				; |
		LDA #$6060			; | Upload non-dynamic Mario tiles if Mario is in play
	++	STA $2116 : PHA			; |
		LDA #$1801 : STA $4310		; |
		LDA #$FC00 : STA $4312		; |
		LDX #$31 : STX $4314		; |
		LDA #$0140 : STA $4315		; |
		LDX #$02 : STX $420B		; |
		PLA				; |
		CLC : ADC #$0100		; |
		STA $2116			; |
		LDA #$FE00 : STA $4312		; |
		LDA #$0140 : STA $4315		; |
		LDX #$02 : STX $420B		;/
		STZ $2182			;\
		LDA #$7D00+$C00 : STA $2181	; |
		LDA #$8000 : STA $4310		; |
		LDA #$C400 : STA $4312		; | upload expansion tiles to GFX33
		LDX #$31 : STX $4314		; |
		LDA #$0400 : STA $4315		; |
		LDX #$02 : STX $420B		;/
		+

	; to use alt player palettes, just add an offset here
		REP #$30
		LDA !Characters
		LSR #4
		AND #$000F
		STA !Palset8
		LDY #$0000
		XBA
		LSR #3
		TAX
	-	LDA.l !PalsetData+5,x : STA $6803,y
		INX #2
		INY #2
		CPY #$0020 : BCC -
		LDA !Characters
		AND #$000F
		STA !Palset9
		LDY #$0000
		XBA
		LSR #3
		TAX
	-	LDA.l !PalsetData+5,x : STA $6823,y
		INX #2
		INY #2
		CPY #$0020 : BCC -

		JSR GFXIndex

		LDA #$7EB0			;\ Default border tiles are $1EB-$1EF, $1FB-$1FF
		STA $400000+!MsgVRAM3		;/
		LDA #$7C00			;\
		STA $400000+!MsgVRAM1		; | Default portrait tiles
		LDA #$7C80			; |
		STA $400000+!MsgVRAM2		;/



; VRAM map code

		LDX !Level
		LDA.l LEVEL_VRAM_map,x
		AND #$00FF
		CMP #$0001 : BNE .Map00

; 2107: BG1 tilemap control
; 2108: BG2 tilemap control
; 2109: BG3 tilemap control
; 210C: BG3 GFX control

	.Map01
		LDA #$4000 : STA !BG1Address	;\  VRAM map 01:
		LDA #$4800 : STA !BG2Address	; | - 0x0000: 32KB of 4bpp GFX for layer 1/2
		SEP #$30			; | - 0x4000: layer 1 tilemap (64x32)
		LDA #$41 : STA !2107		; | - 0x4800: layer 2 tilemap (64x32)
		LDA #$49 : STA !2108		; | - 0x5000: 4KB of 2bpp GFX for layer 3
		LDA #$59 : STA !2109		; | - 0x5800: layer 3 tilemap (64x32)
		LDA #$05 : STA !210C		;/
		BRA .MapDone

	.Map00
		LDA #$3000 : STA !BG1Address	;\  VRAM map 00:
		LDA #$3800 : STA !BG2Address	; | - 0x0000: 24KB of 2bpp GFX for layer 1/2
		SEP #$30			; | - 0x3000: layer 1 tilemap (64x32)
		LDA #$31 : STA !2107		; | - 0x3800: layer 2 tilemap (64x32)
		LDA #$39 : STA !2108		; | - 0x4000: 8KB of 2bpp GFX for layer 3
		LDA #$53 : STA !2109		; | - 0x5000: layer 3 tilemap (64x64)
		LDA #$04 : STA !210C		;/
		.MapDone

		LDA #$70 : STA !AnimToggle	; default !AnimToggle setting: everything allowed, max 4KB

		LDA !P2Status			;\
		CMP #$02 : BCS +		; |
		STZ !P2Status			; | Reset player 2
		LDX #$77			; |
	-	CPX #$28 : BEQ ++		; |
		CPX #$30 : BEQ ++		; |
		STZ !P2Base+$08,x		; |
	++	DEX : BPL -			; |
		STZ !P2XSpeed			; |
		INC !P2Direction		; |
		+				;/
		LDA !P2Status-$80		;\
		CMP #$02 : BCS +		; |
		STZ !P2Status-$80		; | Reset player 1
		LDX #$77			; |
	-	CPX #$28 : BEQ ++		; |
		CPX #$30 : BEQ ++		; |
		STZ !P2Base+$08-$80,x		; |
	++	DEX : BPL -			; |
		STZ !P2XSpeed-$80		; |
		INC !P2Direction-$80		; |
		+				;/
		LDA $741A			;\ How many doors have been entered
		BNE +				;/
		LDA !Characters			;\
		AND #$0F : TAX			; |
		LDA .PlayerHP,x : STA !P2HP	; > Reset player HP if it's the first sublevel
		LDA !Characters			; |
		LSR #4 : TAX			; |
		LDA .PlayerHP,x : STA !P2HP-$80	; |
		+				;/

		LDA #$00 : STA !CurrentMario	; > No one plays Mario by default
		LDA !Characters			;\
		AND #$F0 : BNE +		; |
		LDA #$01 : STA !CurrentMario	; |
		BRA .Mario			; |
	+	LDA !MultiPlayer		; |
		BEQ .KillMario			; | Determine who plays Mario and if he's alive
		LDA !Characters			; |
		AND #$0F : BNE .KillMario	; |
		LDA #$02 : STA !CurrentMario	; |
		BRA .Mario			; |
		.KillMario			; |
		LDA #$01 : STA !P1Dead		; |
		.Mario				;/


		LDX #$18			;\
		LDA #$00			; | Make sure these regs are wiped
	-	STA.l !VineDestroy,x		; |
		DEX : BPL -			;/

		LDA #$18 : STA !TextPal		; Default text palette (colors 0x19 and 0x1B)


		LDA !P1Dead			;\
		BEQ +				; | Keep P1 dead between sub-levels
		LDA #$09 : STA $71		; |
		+				;/
		LDA #$A1 : STA !MsgPal		; > Default portrait palettes are A-B
		LDX #$00			;\ Execute pointer
		JSR ($0000,x)			;/

		REP #$20
		SEP #$10
		JSL read3($048434)		; set scroll values for BG2

		SEP #$30			;
		PLB				; > End of bank wrapper
		PEA $A5F3-1			;\ Set return address and execute subroutine
		JML $00919B			;/


		.SA1
		PHP
		PHB : PHK : PLB
		REP #$20			;\
		LDA $96				; |
		SEC : SBC #$0010		; |
		STA $01				; |
		STA $08				; |
		LDA $94				; |
		SEC : SBC #$0020		; |
		STA $07				; |
		SEP #$30			; |
		STA $00				; | despawn sprites that are withing 32px of players upon level entry
		LDA #$50			; |
		STA $02				; |
		STA $03				; |
		LDX #$0F			; |
	-	LDA $3230,x : BEQ +		; |
		JSL !GetSpriteClipping04	; |
		JSL !CheckContact		; |
		BCC +				; |
		STZ $3230,x			; |
	+	DEX : BPL -			;/

		LDX #$00			;\
		LDY #$00			; | get HSL format palette
		JSL !RGBtoHSL			;/
		LDA #$41 : PHA
		LDA #$40
		PHA : PLB
		STZ.w $4406			; clear !MsgVertOffset
		STZ.w !NPC_ID+0			;\
		STZ.w !NPC_ID+1			; | reset NPC ID table
		STZ.w !NPC_ID+2			;/
		STZ !VRAMtable+$3FF		;\ set up wipes
		LDA #$00 : STA.l !3D_Base+$7FF	;/
		REP #$30			; all regs 16 bit
		LDA.w #$03FE			;\
		LDX.w #!VRAMtable+$3FF		; | wipe VRAM table
		LDY.w #!VRAMtable+$3FE		; |
		MVP $40,$40			;/
		PLB				; change to bank 0x41
		LDA.w #$07FE			;\
		LDX.w #!3D_Base+$7FF		; | wipe 3D cluster joints
		LDY.w #!3D_Base+$7FE		; |
		MVP !3D_Base>>16,!3D_Base>>16	;/
		PLB
		PLP
		RTL

pushpc
org $048452
dl LoadPalset	; code pointer, should be read manually
pullpc

.PlayerHP	db $00,$02,$03,$02,$00,$00		; < Max HP (Mario, Luigi, Kadaal, Leeway, Alter, Peach)


.Table
dw levelinit0	
dw levelinit1	
dw levelinit2	
dw levelinit3	
dw levelinit4
dw levelinit5
dw levelinit6
dw levelinit7
dw levelinit8
dw levelinit9
dw levelinitA
dw levelinitB
dw levelinitC
dw levelinitD
dw levelinitE
dw levelinitF
dw levelinit10
dw levelinit11
dw levelinit12
dw levelinit13
dw levelinit14
dw levelinit15
dw levelinit16
dw levelinit17
dw levelinit18
dw levelinit19
dw levelinit1A
dw levelinit1B
dw levelinit1C
dw levelinit1D
dw levelinit1E
dw levelinit1F
dw levelinit20
dw levelinit21
dw levelinit22
dw levelinit23
dw levelinit24
dw levelinit25
dw levelinit26
dw levelinit27
dw levelinit28
dw levelinit29
dw levelinit2A
dw levelinit2B
dw levelinit2C
dw levelinit2D
dw levelinit2E
dw levelinit2F
dw levelinit30
dw levelinit31
dw levelinit32
dw levelinit33
dw levelinit34
dw levelinit35
dw levelinit36
dw levelinit37
dw levelinit38
dw levelinit39
dw levelinit3A
dw levelinit3B
dw levelinit3C
dw levelinit3D
dw levelinit3E
dw levelinit3F
dw levelinit40
dw levelinit41
dw levelinit42
dw levelinit43
dw levelinit44
dw levelinit45
dw levelinit46
dw levelinit47
dw levelinit48
dw levelinit49
dw levelinit4A
dw levelinit4B
dw levelinit4C
dw levelinit4D
dw levelinit4E
dw levelinit4F
dw levelinit50
dw levelinit51
dw levelinit52
dw levelinit53
dw levelinit54
dw levelinit55
dw levelinit56
dw levelinit57
dw levelinit58
dw levelinit59
dw levelinit5A
dw levelinit5B
dw levelinit5C
dw levelinit5D
dw levelinit5E
dw levelinit5F
dw levelinit60
dw levelinit61
dw levelinit62
dw levelinit63
dw levelinit64
dw levelinit65
dw levelinit66
dw levelinit67
dw levelinit68
dw levelinit69
dw levelinit6A
dw levelinit6B
dw levelinit6C
dw levelinit6D
dw levelinit6E
dw levelinit6F
dw levelinit70
dw levelinit71
dw levelinit72
dw levelinit73
dw levelinit74
dw levelinit75
dw levelinit76
dw levelinit77
dw levelinit78
dw levelinit79
dw levelinit7A
dw levelinit7B
dw levelinit7C
dw levelinit7D
dw levelinit7E
dw levelinit7F
dw levelinit80
dw levelinit81
dw levelinit82
dw levelinit83
dw levelinit84
dw levelinit85
dw levelinit86
dw levelinit87
dw levelinit88
dw levelinit89
dw levelinit8A
dw levelinit8B
dw levelinit8C
dw levelinit8D
dw levelinit8E
dw levelinit8F
dw levelinit90
dw levelinit91
dw levelinit92
dw levelinit93
dw levelinit94
dw levelinit95
dw levelinit96
dw levelinit97
dw levelinit98
dw levelinit99
dw levelinit9A
dw levelinit9B
dw levelinit9C
dw levelinit9D
dw levelinit9E
dw levelinit9F
dw levelinitA0
dw levelinitA1
dw levelinitA2
dw levelinitA3
dw levelinitA4
dw levelinitA5
dw levelinitA6
dw levelinitA7
dw levelinitA8
dw levelinitA9
dw levelinitAA
dw levelinitAB
dw levelinitAC
dw levelinitAD
dw levelinitAE
dw levelinitAF
dw levelinitB0
dw levelinitB1
dw levelinitB2
dw levelinitB3
dw levelinitB4
dw levelinitB5
dw levelinitB6
dw levelinitB7
dw levelinitB8
dw levelinitB9
dw levelinitBA
dw levelinitBB
dw levelinitBC
dw levelinitBD
dw levelinitBE
dw levelinitBF
dw levelinitC0
dw levelinitC1
dw levelinitC2
dw levelinitC3
dw levelinitC4
dw levelinitC5
dw levelinitC6
dw levelinitC7
dw levelinitC8
dw levelinitC9
dw levelinitCA
dw levelinitCB
dw levelinitCC
dw levelinitCD
dw levelinitCE
dw levelinitCF
dw levelinitD0
dw levelinitD1
dw levelinitD2
dw levelinitD3
dw levelinitD4
dw levelinitD5
dw levelinitD6
dw levelinitD7
dw levelinitD8
dw levelinitD9
dw levelinitDA
dw levelinitDB
dw levelinitDC
dw levelinitDD
dw levelinitDE
dw levelinitDF
dw levelinitE0
dw levelinitE1
dw levelinitE2
dw levelinitE3
dw levelinitE4
dw levelinitE5
dw levelinitE6
dw levelinitE7
dw levelinitE8
dw levelinitE9
dw levelinitEA
dw levelinitEB
dw levelinitEC
dw levelinitED
dw levelinitEE
dw levelinitEF
dw levelinitF0
dw levelinitF1
dw levelinitF2
dw levelinitF3
dw levelinitF4
dw levelinitF5
dw levelinitF6
dw levelinitF7
dw levelinitF8
dw levelinitF9
dw levelinitFA
dw levelinitFB
dw levelinitFC
dw levelinitFD
dw levelinitFE
dw levelinitFF
dw levelinit100
dw levelinit101
dw levelinit102
dw levelinit103
dw levelinit104
dw levelinit105
dw levelinit106
dw levelinit107
dw levelinit108
dw levelinit109
dw levelinit10A
dw levelinit10B
dw levelinit10C
dw levelinit10D
dw levelinit10E
dw levelinit10F
dw levelinit110
dw levelinit111
dw levelinit112
dw levelinit113
dw levelinit114
dw levelinit115
dw levelinit116
dw levelinit117
dw levelinit118
dw levelinit119
dw levelinit11A
dw levelinit11B
dw levelinit11C
dw levelinit11D
dw levelinit11E
dw levelinit11F
dw levelinit120
dw levelinit121
dw levelinit122
dw levelinit123
dw levelinit124
dw levelinit125
dw levelinit126
dw levelinit127
dw levelinit128
dw levelinit129
dw levelinit12A
dw levelinit12B
dw levelinit12C
dw levelinit12D
dw levelinit12E
dw levelinit12F
dw levelinit130
dw levelinit131
dw levelinit132
dw levelinit133
dw levelinit134
dw levelinit135
dw levelinit136
dw levelinit137
dw levelinit138
dw levelinit139
dw levelinit13A
dw levelinit13B
dw levelinit13C
dw levelinit13D
dw levelinit13E
dw levelinit13F
dw levelinit140
dw levelinit141
dw levelinit142
dw levelinit143
dw levelinit144
dw levelinit145
dw levelinit146
dw levelinit147
dw levelinit148
dw levelinit149
dw levelinit14A
dw levelinit14B
dw levelinit14C
dw levelinit14D
dw levelinit14E
dw levelinit14F
dw levelinit150
dw levelinit151
dw levelinit152
dw levelinit153
dw levelinit154
dw levelinit155
dw levelinit156
dw levelinit157
dw levelinit158
dw levelinit159
dw levelinit15A
dw levelinit15B
dw levelinit15C
dw levelinit15D
dw levelinit15E
dw levelinit15F
dw levelinit160
dw levelinit161
dw levelinit162
dw levelinit163
dw levelinit164
dw levelinit165
dw levelinit166
dw levelinit167
dw levelinit168
dw levelinit169
dw levelinit16A
dw levelinit16B
dw levelinit16C
dw levelinit16D
dw levelinit16E
dw levelinit16F
dw levelinit170
dw levelinit171
dw levelinit172
dw levelinit173
dw levelinit174
dw levelinit175
dw levelinit176
dw levelinit177
dw levelinit178
dw levelinit179
dw levelinit17A
dw levelinit17B
dw levelinit17C
dw levelinit17D
dw levelinit17E
dw levelinit17F
dw levelinit180
dw levelinit181
dw levelinit182
dw levelinit183
dw levelinit184
dw levelinit185
dw levelinit186
dw levelinit187
dw levelinit188
dw levelinit189
dw levelinit18A
dw levelinit18B
dw levelinit18C
dw levelinit18D
dw levelinit18E
dw levelinit18F
dw levelinit190
dw levelinit191
dw levelinit192
dw levelinit193
dw levelinit194
dw levelinit195
dw levelinit196
dw levelinit197
dw levelinit198
dw levelinit199
dw levelinit19A
dw levelinit19B
dw levelinit19C
dw levelinit19D
dw levelinit19E
dw levelinit19F
dw levelinit1A0
dw levelinit1A1
dw levelinit1A2
dw levelinit1A3
dw levelinit1A4
dw levelinit1A5
dw levelinit1A6
dw levelinit1A7
dw levelinit1A8
dw levelinit1A9
dw levelinit1AA
dw levelinit1AB
dw levelinit1AC
dw levelinit1AD
dw levelinit1AE
dw levelinit1AF
dw levelinit1B0
dw levelinit1B1
dw levelinit1B2
dw levelinit1B3
dw levelinit1B4
dw levelinit1B5
dw levelinit1B6
dw levelinit1B7
dw levelinit1B8
dw levelinit1B9
dw levelinit1BA
dw levelinit1BB
dw levelinit1BC
dw levelinit1BD
dw levelinit1BE
dw levelinit1BF
dw levelinit1C0
dw levelinit1C1
dw levelinit1C2
dw levelinit1C3
dw levelinit1C4
dw levelinit1C5
dw levelinit1C6
dw levelinit1C7
dw levelinit1C8
dw levelinit1C9
dw levelinit1CA
dw levelinit1CB
dw levelinit1CC
dw levelinit1CD
dw levelinit1CE
dw levelinit1CF
dw levelinit1D0
dw levelinit1D1
dw levelinit1D2
dw levelinit1D3
dw levelinit1D4
dw levelinit1D5
dw levelinit1D6
dw levelinit1D7
dw levelinit1D8
dw levelinit1D9
dw levelinit1DA
dw levelinit1DB
dw levelinit1DC
dw levelinit1DD
dw levelinit1DE
dw levelinit1DF
dw levelinit1E0
dw levelinit1E1
dw levelinit1E2
dw levelinit1E3
dw levelinit1E4
dw levelinit1E5
dw levelinit1E6
dw levelinit1E7
dw levelinit1E8
dw levelinit1E9
dw levelinit1EA
dw levelinit1EB
dw levelinit1EC
dw levelinit1ED
dw levelinit1EE
dw levelinit1EF
dw levelinit1F0
dw levelinit1F1
dw levelinit1F2
dw levelinit1F3
dw levelinit1F4
dw levelinit1F5
dw levelinit1F6
dw levelinit1F7
dw levelinit1F8
dw levelinit1F9
dw levelinit1FA
dw levelinit1FB
dw levelinit1FC
dw levelinit1FD
dw levelinit1FE
dw levelinit1FF

	MAIN_Level:
		LDA $73D4				;\
		PHA					; | Don't clear OAM while game is paused
		BNE +					;/
		LDA !MsgTrigger : BEQ ++		; > Always clear if there's no message box
		LDA $7B88 : BNE +			; > Don't clear while window is closing
		LDA.l !MsgMode				;\
		BNE +					; | Don't clear OAM during !MsgMode non-zero
	++	JSL $138010				;/
	+	LDA #$01 : STA !LevelInitFlag		; set level MAIN
		JSL $138020				; > Handle Yoshi Coins (A=1)
		PHB : PHK : PLB				; > Bank wrapper
		LDA !RNG				; Load RNG from last frame
		ADC $13					; Add true frame counter
		ADC $15					;\
		ADC $16					; | Add player 1 controller input
		ADC $17					; |
		ADC $18					;/
		ADC $6DA3				;\
		ADC $6DA5				; | Add player 2 controller input
		ADC $6DA7				; |
		ADC $6DA9				;/
		ADC $7B					;\ Add player 1 speed
		ADC $7D					;/
		ADC $94					;\ Add player 1 position
		ADC $96					;/
		ADC !P2XSpeed				;\ Add player 2 speed
		ADC !P2YSpeed				;/
		ADC !P2XPosLo				;\ Add player 2 position
		ADC !P2YPosLo				;/
		STA !RNG				; Store RNG back (it should be at least kind of random now)



		SEP #$30
		LDA.b #HandleGraphics : STA $3180
		LDA.b #HandleGraphics>>8 : STA $3181
		LDA.b #HandleGraphics>>16 : STA $3182
		JSR $1E80


		REP #$30			; > All registers 16 bit
		LDA !Level			;\
		ASL A				; |
		TAX				; | Load pointer based on level number
		LDA .Table,x			; |
		STA $0000			;/
		SEP #$30			; > All registers 8 bit
		LDX #$00			;\ Execute pointer
		JSR ($0000,x)			;/
		PLB				; > End of bank wrapper
		PLA				;\
		BEQ +				; | Pull pause flag and execute overwritten branch
		JML $00A25B			; |
	+	JML $00A28A			;/



.Table
dw level0	
dw level1	
dw level2	
dw level3	
dw level4
dw level5
dw level6
dw level7
dw level8
dw level9
dw levelA
dw levelB
dw levelC
dw levelD
dw levelE
dw levelF
dw level10
dw level11
dw level12
dw level13
dw level14
dw level15
dw level16
dw level17
dw level18
dw level19
dw level1A
dw level1B
dw level1C
dw level1D
dw level1E
dw level1F
dw level20
dw level21
dw level22
dw level23
dw level24
dw level25
dw level26
dw level27
dw level28
dw level29
dw level2A
dw level2B
dw level2C
dw level2D
dw level2E
dw level2F
dw level30
dw level31
dw level32
dw level33
dw level34
dw level35
dw level36
dw level37
dw level38
dw level39
dw level3A
dw level3B
dw level3C
dw level3D
dw level3E
dw level3F
dw level40
dw level41
dw level42
dw level43
dw level44
dw level45
dw level46
dw level47
dw level48
dw level49
dw level4A
dw level4B
dw level4C
dw level4D
dw level4E
dw level4F
dw level50
dw level51
dw level52
dw level53
dw level54
dw level55
dw level56
dw level57
dw level58
dw level59
dw level5A
dw level5B
dw level5C
dw level5D
dw level5E
dw level5F
dw level60
dw level61
dw level62
dw level63
dw level64
dw level65
dw level66
dw level67
dw level68
dw level69
dw level6A
dw level6B
dw level6C
dw level6D
dw level6E
dw level6F
dw level70
dw level71
dw level72
dw level73
dw level74
dw level75
dw level76
dw level77
dw level78
dw level79
dw level7A
dw level7B
dw level7C
dw level7D
dw level7E
dw level7F
dw level80
dw level81
dw level82
dw level83
dw level84
dw level85
dw level86
dw level87
dw level88
dw level89
dw level8A
dw level8B
dw level8C
dw level8D
dw level8E
dw level8F
dw level90
dw level91
dw level92
dw level93
dw level94
dw level95
dw level96
dw level97
dw level98
dw level99
dw level9A
dw level9B
dw level9C
dw level9D
dw level9E
dw level9F
dw levelA0
dw levelA1
dw levelA2
dw levelA3
dw levelA4
dw levelA5
dw levelA6
dw levelA7
dw levelA8
dw levelA9
dw levelAA
dw levelAB
dw levelAC
dw levelAD
dw levelAE
dw levelAF
dw levelB0
dw levelB1
dw levelB2
dw levelB3
dw levelB4
dw levelB5
dw levelB6
dw levelB7
dw levelB8
dw levelB9
dw levelBA
dw levelBB
dw levelBC
dw levelBD
dw levelBE
dw levelBF
dw levelC0
dw levelC1
dw levelC2
dw levelC3
dw levelC4
dw levelC5
dw levelC6
dw levelC7
dw levelC8
dw levelC9
dw levelCA
dw levelCB
dw levelCC
dw levelCD
dw levelCE
dw levelCF
dw levelD0
dw levelD1
dw levelD2
dw levelD3
dw levelD4
dw levelD5
dw levelD6
dw levelD7
dw levelD8
dw levelD9
dw levelDA
dw levelDB
dw levelDC
dw levelDD
dw levelDE
dw levelDF
dw levelE0
dw levelE1
dw levelE2
dw levelE3
dw levelE4
dw levelE5
dw levelE6
dw levelE7
dw levelE8
dw levelE9
dw levelEA
dw levelEB
dw levelEC
dw levelED
dw levelEE
dw levelEF
dw levelF0
dw levelF1
dw levelF2
dw levelF3
dw levelF4
dw levelF5
dw levelF6
dw levelF7
dw levelF8
dw levelF9
dw levelFA
dw levelFB
dw levelFC
dw levelFD
dw levelFE
dw levelFF
dw level100
dw level101
dw level102
dw level103
dw level104
dw level105
dw level106
dw level107
dw level108
dw level109
dw level10A
dw level10B
dw level10C
dw level10D
dw level10E
dw level10F
dw level110
dw level111
dw level112
dw level113
dw level114
dw level115
dw level116
dw level117
dw level118
dw level119
dw level11A
dw level11B
dw level11C
dw level11D
dw level11E
dw level11F
dw level120
dw level121
dw level122
dw level123
dw level124
dw level125
dw level126
dw level127
dw level128
dw level129
dw level12A
dw level12B
dw level12C
dw level12D
dw level12E
dw level12F
dw level130
dw level131
dw level132
dw level133
dw level134
dw level135
dw level136
dw level137
dw level138
dw level139
dw level13A
dw level13B
dw level13C
dw level13D
dw level13E
dw level13F
dw level140
dw level141
dw level142
dw level143
dw level144
dw level145
dw level146
dw level147
dw level148
dw level149
dw level14A
dw level14B
dw level14C
dw level14D
dw level14E
dw level14F
dw level150
dw level151
dw level152
dw level153
dw level154
dw level155
dw level156
dw level157
dw level158
dw level159
dw level15A
dw level15B
dw level15C
dw level15D
dw level15E
dw level15F
dw level160
dw level161
dw level162
dw level163
dw level164
dw level165
dw level166
dw level167
dw level168
dw level169
dw level16A
dw level16B
dw level16C
dw level16D
dw level16E
dw level16F
dw level170
dw level171
dw level172
dw level173
dw level174
dw level175
dw level176
dw level177
dw level178
dw level179
dw level17A
dw level17B
dw level17C
dw level17D
dw level17E
dw level17F
dw level180
dw level181
dw level182
dw level183
dw level184
dw level185
dw level186
dw level187
dw level188
dw level189
dw level18A
dw level18B
dw level18C
dw level18D
dw level18E
dw level18F
dw level190
dw level191
dw level192
dw level193
dw level194
dw level195
dw level196
dw level197
dw level198
dw level199
dw level19A
dw level19B
dw level19C
dw level19D
dw level19E
dw level19F
dw level1A0
dw level1A1
dw level1A2
dw level1A3
dw level1A4
dw level1A5
dw level1A6
dw level1A7
dw level1A8
dw level1A9
dw level1AA
dw level1AB
dw level1AC
dw level1AD
dw level1AE
dw level1AF
dw level1B0
dw level1B1
dw level1B2
dw level1B3
dw level1B4
dw level1B5
dw level1B6
dw level1B7
dw level1B8
dw level1B9
dw level1BA
dw level1BB
dw level1BC
dw level1BD
dw level1BE
dw level1BF
dw level1C0
dw level1C1
dw level1C2
dw level1C3
dw level1C4
dw level1C5
dw level1C6
dw level1C7
dw level1C8
dw level1C9
dw level1CA
dw level1CB
dw level1CC
dw level1CD
dw level1CE
dw level1CF
dw level1D0
dw level1D1
dw level1D2
dw level1D3
dw level1D4
dw level1D5
dw level1D6
dw level1D7
dw level1D8
dw level1D9
dw level1DA
dw level1DB
dw level1DC
dw level1DD
dw level1DE
dw level1DF
dw level1E0
dw level1E1
dw level1E2
dw level1E3
dw level1E4
dw level1E5
dw level1E6
dw level1E7
dw level1E8
dw level1E9
dw level1EA
dw level1EB
dw level1EC
dw level1ED
dw level1EE
dw level1EF
dw level1F0
dw level1F1
dw level1F2
dw level1F3
dw level1F4
dw level1F5
dw level1F6
dw level1F7
dw level1F8
dw level1F9
dw level1FA
dw level1FB
dw level1FC
dw level1FD
dw level1FE
dw level1FF





;================;
;GRAPHICS HANDLER;
;================;
HandleGraphics:
		PHB : PHK : PLB
		PHP
		SEP #$30

		JSR .RotateSimple
		JSR .RainbowShifter

		LDA !GlobalPalsetMix
		CMP !GlobalPalsetMix+1 : BEQ +
		LDX #$07
	-	LDA !Palset8,x
		AND #$7F
		STA !Palset8,x
		DEX : BPL -
		+


		LDX #$07						;\
	-	STZ $00,x						; | clear $00-$07
		DEX : BPL -						;/

		LDY #$0F						;\
	-	LDA $33C0,y						; |
		LSR A							; |
		AND #$07						; | mark palettes as used if an existing sprite uses them
		TAX							; |
		LDA $3230,y						; |
		BEQ $02 : STA $00,x					; |
		DEY : BPL -						;/

		LDY.b #!Ex_Amount-1					;\
	-	LDA !Ex_Palset,y					; |
		CMP #$FF : BEQ +					; |
		LSR A							; | mark palettes as used if a FusionCore sprite uses them
		AND #$07						; |
		TAX							; |
		LDA #$01 : STA $00,x					; |
	+	DEY : BPL -						;/

		LDX #$07						;\
	-	LDA !Palset8,x						; |
		AND #$7F						; |
		CMP PalsetDefaults,x : BEQ +				; |
		LDA $00,x : BNE +					; |
		PHX							; | if palset is non-default AND unused, unload it
		LDA !Palset8,x						; |
		AND #$7F						; |
		TAX							; |
		LDA #$00 : STA !GFX_status+$180,x			; |
		PLX							; |
		LDA #$80 : STA !Palset8,x				; |
	+	DEX							; |
		CPX #$02 : BCS -					;/

		REP #$10
		LDY #$0007						; loop through all sprite palsets
	.loop	LDA !Palset8,y : BMI .next				; if already loaded, go to next			
		STA $00 : STZ $01					; $00 = palset to load
		TAX							;\
		ORA #$80						; | mark palset as loaded
		STA !Palset8,y						; |
		TYA : STA !GFX_status+$180,x				;/

		JSR UpdatePalset

	.next	DEY : BPL .loop						; loop

		LDA !GlobalPalsetMix : STA !GlobalPalsetMix+1


		PLP
		PLB
		RTL


	; handler for simple rotation graphics
	.RotateSimple
		STZ $2250
		LDY #$00
	..Loop	PHY
		LDA .RotationData,y : TAX
		LDA !GFX_status,x : BNE ..Process
		JMP ..Next

		..Process
		AND #$0F				;\
		STA $00					; |
		LDA !GFX_status,x			; |
		AND #$70				; |
		ASL A					; |
		TSB $00					; | $00 = tile number (000-1FF)
		LDA !GFX_status,x			; |
		ASL A					; |
		ROL A					; |
		AND #$01				; |
		STA $01					;/
		LDA .RotationData+1,y : TAX		;\
		LDA !GFX_status+$100,x : STA $02	; | $02 = SD status
		STZ $03					;/
		LDA .RotationData+2,y : STA $04		;\ $04 = size
		STZ $05					;/
		LDA .RotationData+3,y : STA $07		; $06 = animation rate (n/v flag triggers)
		LDA .RotationData+4,y : STA $08		;\ $08 = rotation direction
		STZ $09					;/

		JSL !GetVRAM
		PHB : LDA.b #!VRAMbank
		PHA : PLB
		REP #$20
		LDA $00
		ASL #4
		ORA #$6000
		STA.w !VRAMtable+$05,x
		CLC : ADC #$0100
		STA.w !VRAMtable+$0C,x
		LDA $02
		AND #$003F
		ASL #2
		XBA
		STA $0E
		LDA $14
		BIT $06
		BPL $01 : LSR A
		BVC $01 : LSR A
		AND #$000F
		EOR $08
		STA.l $2251
		LDA $04 : STA.l $2253
		NOP
		LDA $0E
		CLC : ADC.l $2306
		STA.w !VRAMtable+$02,x
		ADC #$0040
		STA.w !VRAMtable+$09,x
		LDA $04
		CMP #$0040 : BCS ..big
	..8x8	STA.w !VRAMtable+$00,x
		BRA +
	..big	LSR A
		STA.w !VRAMtable+$00,x
		STA.w !VRAMtable+$07,x
	+	SEP #$20
		LDY #$7E
		LDA $02
		AND #$C0 : BEQ +
		LDY #$7F
		CMP #$40 : BEQ +
		LDY #$40
		CMP #$80 : BEQ +
		LDY #$41
	+	TYA
		STA.w !VRAMtable+$04,x
		STA.w !VRAMtable+$0B,x
		PLB

	..Next	PLY
		INY #5
		CPY.b #.RotationData_End-.RotationData : BCS $03 : JMP ..Loop
		RTS

	; format:
	; - GFX status index
	; - SD index
	; - width ($20 for 8x8 or $80 for 16x16)
	; - animation speed (00 = every frame, 40/80 = every other frame, C0 = every 4 frames)
	; - direction (00 = clockwise, 0F = counterclockwise)

	.RotationData
		db !GFX_Hammer-!GFX_status,$00,$80,$00,$0F
		db !GFX_Bone-!GFX_status,$02,$80,$40,$0F
		db !GFX_SmallFireball-!GFX_status,$03,$20,$00,$00
		db !GFX_ReznorFireball-!GFX_status,$04,$80,$00,$00
		db !GFX_Goomba-!GFX_status,$05,$80,$00,$0F
		..End


	; handler for player rainbow effect
	.RainbowShifter
		PHP
		SEP #$20
		REP #$10

		LDA $7490 : BNE .Shift
		LDA !Palset8
		AND #$7F
		STA !Palset8
		LDA !Palset9
		AND #$7F
		STA !Palset9
		PLP
		RTS

	.Shift
		LDX #$0080
		LDY #$0020
		JSL !RGBtoHSL
		LDX #$009F*3
	--	LDA $7490
		ASL #2
		CLC : ADC !PaletteHSL,x
	-	CMP #$F0 : BCC +
		SBC #$F0 : BRA -
	+	STA !PaletteHSL,x
		LDA #$30 : STA !PaletteHSL+1,x
		LDA #$20 : STA !PaletteHSL+2,x
		DEX #3
		CPX #$0080*3 : BCS --
		LDX #$0080
		LDY #$0020
		JSL !HSLtoRGB
		LDX #$0080
		LDY #$0020
		LDA $7490
		CMP #$10
		BCC $02 : LDA #$10
		SEC : SBC #$20
		EOR #$FF : INC A
		JSL !MixRGB

		PLP
		RTS



;==============;
;PALETTE LOADER;
;==============;
;	input:
;	A:		sprite palset to load
LoadPalset:
		PHB : PHK : PLB
		PHX					; push X
		STA $0F					; store palset to load in $0F
		TAX					;\ if palset is already loaded, return
		LDA !GFX_status+$180,x : BNE .Return	;/
		LDX #$07				;\
	-	LDA !Palset8,x				; |
		AND #$7F				; | if palset is about to be loaded this frame, return
		CMP $0F : BEQ .Return			; | (probably not necessary, just in case there's an error somewhere)
		DEX : BPL -				;/
		PLX					; pull X
		LDY #$07				;\
	.Loop	LDA !Palset8,y				; |
		CMP #$80 : BEQ .Load			; | look for a free row in A-F
	.Next	DEY					; |
		CPY #$02 : BCS .Loop			;/
		PLB
		RTL					; if none are found, return

	.Load	LDA $0F : STA $00			;\
		STZ $01					; | set palset to load here
		ORA #$80				; |
		STA !Palset8,y				;/
		PHX					;\
		AND #$7F				; |
		TAX					; | mark palset as loaded
		TYA : STA !GFX_status+$180,x		; |
		LDA $0F : PHA				; |
		JSR UpdatePalset			; > update
		PLA : STA $0F				; |
	.Return	PLX					;/
		PLB
		RTL					; return


UpdatePalset:
		REP #$30
		STY $08							;\
		JSL !GetCGRAM						; | get CGRAM table index
		TYX							;/
		LDA !GlobalPalset1					;\
		AND #$00FF						; | globel palset variation
		STA $02							;/

		LDA !GlobalPalsetMix
		AND #$00FF : BEQ .NoMix

	.Mix
		JSR GetAddress : STA $0A
		LDA !GlobalPalset2
		AND #$00FF
		STA $02
		JSR GetAddress : STA $02
		LDA $0A : STA $00
		PHX
		LDA $08
		ORA #$0008
		ASL #4
		INC A
		ASL A
		TAX
		PHX
		LDY #$0000
		JSR FadePalset
		PLA
		CLC : ADC #$6703
		PLX
		LDY $08
		BRA .addr

	.NoMix
		JSR GetAddress
	.addr	STA !VRAMbase+!CGRAMtable+$02,x					; store source address
		LDA #$001E : STA !VRAMbase+!CGRAMtable+$00,x			; upload size
		SEP #$30							; A 8-bit
		LDA.b #!PalsetData>>16 : STA !VRAMbase+!CGRAMtable+$04,x	; source bank
		TYA								;\
		ORA #$08							; |
		ASL #4								; | dest CGRAM
		INC A								; |
		STA !VRAMbase+!CGRAMtable+$05,x					;/
		RTS


GetAddress:
; input:
; $00 = palset id
; $02 = suffix id (treated as 0 if invalid)
		PHX
		LDX #$0000						;
		LDA $02 : BEQ .type0					; if variation is 0, skip search
	-	LDA.l read3(!PalsetData),x				;\
		AND #$00FF						; |
		CMP $00 : BNE +						; | search for alt palset that matches both global palset option and palset id
		LDA.l read3(!PalsetData)+1,x				; |
		AND #$00FF						; |
		CMP $02 : BNE +						;/
		TXA							;\
		CLC : ADC.l !PalsetData					; |
		INC #2							; | if there's a match, use this upload address
		LDY $08							; |
		PLX							; |
		RTS							;/
	+	TXA							;\
		CLC : ADC #$0020					; | keep searching if a match was not found
		TAX							; |
		CMP.l !PalsetData+3 : BCC -				;/
	.type0	LDY $08							;\
		LDA $00							; |
		XBA							; | address for variation 0 palset
		LSR #3							; |
		CLC : ADC.w #!PalsetData+7				; |
		PLX							; |
		RTS							;/




FadePalset:

; $00 = pointer 1
; $02 = pointer 2
; $04 = mix value 1
; $06 = mix value 2
; $08 = holds palette row index
; $0A = cache for address
; $0C = color assembly
; $0E = color plane assembly

		SEP #$20
		PHB : LDA.b #!PalsetData>>16
		PHA : PLB
		STZ $2250
		REP #$20


		LDA !GlobalPalsetMix
		AND #$00FF
		STA $06
		SEC : SBC #$0020
		EOR #$FFFF : INC A
		STA $04

	.Loop	LDA ($00),y						;\
		AND #$001F						; |
		STA $2251						; |
		LDA $04 : STA $2253					; | first half of R
		NOP : BRA $00						; |
		LDA $2306						; |
		STA $0E							;/
		LDA ($02),y						;\
		AND #$001F						; |
		STA $2251						; |
		LDA $06 : STA $2253					; | second half of R
		NOP							; |
		LDA $0E							; |
		CLC : ADC $2306						; |
		LSR #5							; | > get final R
		STA $0C							;/

		LDA ($00),y						;\
		LSR #5							; |
		AND #$001F						; |
		STA $2251						; |
		LDA $04 : STA $2253					; | first half of G
		NOP : BRA $00						; |
		LDA $2306						; |
		STA $0E							;/
		LDA ($02),y						;\
		LSR #5							; |
		AND #$001F						; |
		STA $2251						; |
		LDA $06 : STA $2253					; | second half of G
		NOP							; |
		LDA $0E							; |
		CLC : ADC $2306						; |
		AND #$03E0						; | > get final G
		TSB $0C							;/

		LDA ($00),y						;\
		XBA : LSR #2						; |
		AND #$001F						; |
		STA $2251						; |
		LDA $04 : STA $2253					; | first half of B
		NOP : BRA $00						; |
		LDA $2306						; |
		STA $0E							;/
		LDA ($02),y						;\
		XBA : LSR #2						; |
		AND #$001F						; |
		STA $2251						; |
		LDA $06 : STA $2253					; | second half of B
		NOP							; |
		LDA $0E							; |
		CLC : ADC $2306						; |
		ASL #5							; |
		AND #$7C00						;/ > get final B

		ORA $0C							;\ store final RGB
		STA $6703,x						;/

		INX #2
		INY #2
		CPY #$001E : BCS .Done
		JMP .Loop

	.Done
		PLB
		RTS



print "Unsorted code inserted at $", pc, "."
incsrc "levelcode/Unsorted.asm"

print "Realm 1 code inserted at $", pc, "."
incsrc "levelcode/Realm1.asm"

print "Realm 2 code inserted at $", pc, "."
incsrc "levelcode/Realm2.asm"

print "Realm 3 code inserted at $", pc, "."
incsrc "levelcode/Realm3.asm"

print "Realm 4 code inserted at $", pc, "."
incsrc "levelcode/Realm4.asm"

print "Realm 5 code inserted at $", pc, "."
incsrc "levelcode/Realm5.asm"

print "Realm 6 code inserted at $", pc, "."
incsrc "levelcode/Realm6.asm"

print "Realm 7 code inserted at $", pc, "."
incsrc "levelcode/Realm7.asm"

print "Realm 8 code inserted at $", pc, "."
incsrc "levelcode/Realm8.asm"

print " "
print "Level code ends at $", pc, "."