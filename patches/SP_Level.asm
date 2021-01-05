header
sa1rom

print "-- SP_LEVEL --"

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
		LDA !CurrentMario : BNE +	;\
		LDA #$7F : STA !MarioMaskBits	; | hide mario if he's not in play
		+				;/
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
		CLC : ADC !Level		; | load pointer based on level number
		TAX				; | x3
		LDA .Table,x : STA $0000	; |
		LDA .Table+1,x : STA $0001	;/
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

		LDY.b #!File_Mario_Supplement	; |
		JSL !GetFileAddress		; |
		LDA !FileAddress : STA $4312	; |
		LDA !FileAddress+1 : STA $4313	; |

;	LDA #$FC00 : STA $4312		; |
;	LDX #$31 : STX $4314		; |

		LDA #$0140 : STA $4315		; |
		LDX #$02 : STX $420B		; |
		PLA				; |
		CLC : ADC #$0100		; |
		STA $2116			; |

		LDA !FileAddress		; |
		CLC : ADC #$0200		; |
		STA $4312			; |

;	LDA #$FE00 : STA $4312		; |

		LDA #$0140 : STA $4315		; |
		LDX #$02 : STX $420B		;/
		STZ $2182			;\
		LDA #$7D00+$C00 : STA $2181	; > this is RAM address for GFX33
		LDA #$8000 : STA $4310		; |

		LDY.b #!File_Mario_Expand	; |
		JSL !GetFileAddress		; |
		LDA !FileAddress : STA $4312	; |
		LDA !FileAddress+1 : STA $4313	; |

;	LDA #$C400 : STA $4312		; | upload expansion tiles to GFX33
;	LDX #$31 : STX $4314		; |
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
		PHB
		LDA $0002
		PHA : PLB
		PHK : PEA.w .Return-1		; set return address
		JML [$0000]			; execute pointer
		.Return
		PLB

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
		LDA $6701 : STA $6703		; copy this (so it gets written as HSL)
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
dl levelinit0	
dl levelinit1	
dl levelinit2	
dl levelinit3	
dl levelinit4
dl levelinit5
dl levelinit6
dl levelinit7
dl levelinit8
dl levelinit9
dl levelinitA
dl levelinitB
dl levelinitC
dl levelinitD
dl levelinitE
dl levelinitF
dl levelinit10
dl levelinit11
dl levelinit12
dl levelinit13
dl levelinit14
dl levelinit15
dl levelinit16
dl levelinit17
dl levelinit18
dl levelinit19
dl levelinit1A
dl levelinit1B
dl levelinit1C
dl levelinit1D
dl levelinit1E
dl levelinit1F
dl levelinit20
dl levelinit21
dl levelinit22
dl levelinit23
dl levelinit24
dl levelinit25
dl levelinit26
dl levelinit27
dl levelinit28
dl levelinit29
dl levelinit2A
dl levelinit2B
dl levelinit2C
dl levelinit2D
dl levelinit2E
dl levelinit2F
dl levelinit30
dl levelinit31
dl levelinit32
dl levelinit33
dl levelinit34
dl levelinit35
dl levelinit36
dl levelinit37
dl levelinit38
dl levelinit39
dl levelinit3A
dl levelinit3B
dl levelinit3C
dl levelinit3D
dl levelinit3E
dl levelinit3F
dl levelinit40
dl levelinit41
dl levelinit42
dl levelinit43
dl levelinit44
dl levelinit45
dl levelinit46
dl levelinit47
dl levelinit48
dl levelinit49
dl levelinit4A
dl levelinit4B
dl levelinit4C
dl levelinit4D
dl levelinit4E
dl levelinit4F
dl levelinit50
dl levelinit51
dl levelinit52
dl levelinit53
dl levelinit54
dl levelinit55
dl levelinit56
dl levelinit57
dl levelinit58
dl levelinit59
dl levelinit5A
dl levelinit5B
dl levelinit5C
dl levelinit5D
dl levelinit5E
dl levelinit5F
dl levelinit60
dl levelinit61
dl levelinit62
dl levelinit63
dl levelinit64
dl levelinit65
dl levelinit66
dl levelinit67
dl levelinit68
dl levelinit69
dl levelinit6A
dl levelinit6B
dl levelinit6C
dl levelinit6D
dl levelinit6E
dl levelinit6F
dl levelinit70
dl levelinit71
dl levelinit72
dl levelinit73
dl levelinit74
dl levelinit75
dl levelinit76
dl levelinit77
dl levelinit78
dl levelinit79
dl levelinit7A
dl levelinit7B
dl levelinit7C
dl levelinit7D
dl levelinit7E
dl levelinit7F
dl levelinit80
dl levelinit81
dl levelinit82
dl levelinit83
dl levelinit84
dl levelinit85
dl levelinit86
dl levelinit87
dl levelinit88
dl levelinit89
dl levelinit8A
dl levelinit8B
dl levelinit8C
dl levelinit8D
dl levelinit8E
dl levelinit8F
dl levelinit90
dl levelinit91
dl levelinit92
dl levelinit93
dl levelinit94
dl levelinit95
dl levelinit96
dl levelinit97
dl levelinit98
dl levelinit99
dl levelinit9A
dl levelinit9B
dl levelinit9C
dl levelinit9D
dl levelinit9E
dl levelinit9F
dl levelinitA0
dl levelinitA1
dl levelinitA2
dl levelinitA3
dl levelinitA4
dl levelinitA5
dl levelinitA6
dl levelinitA7
dl levelinitA8
dl levelinitA9
dl levelinitAA
dl levelinitAB
dl levelinitAC
dl levelinitAD
dl levelinitAE
dl levelinitAF
dl levelinitB0
dl levelinitB1
dl levelinitB2
dl levelinitB3
dl levelinitB4
dl levelinitB5
dl levelinitB6
dl levelinitB7
dl levelinitB8
dl levelinitB9
dl levelinitBA
dl levelinitBB
dl levelinitBC
dl levelinitBD
dl levelinitBE
dl levelinitBF
dl levelinitC0
dl levelinitC1
dl levelinitC2
dl levelinitC3
dl levelinitC4
dl levelinitC5
dl levelinitC6
dl levelinitC7
dl levelinitC8
dl levelinitC9
dl levelinitCA
dl levelinitCB
dl levelinitCC
dl levelinitCD
dl levelinitCE
dl levelinitCF
dl levelinitD0
dl levelinitD1
dl levelinitD2
dl levelinitD3
dl levelinitD4
dl levelinitD5
dl levelinitD6
dl levelinitD7
dl levelinitD8
dl levelinitD9
dl levelinitDA
dl levelinitDB
dl levelinitDC
dl levelinitDD
dl levelinitDE
dl levelinitDF
dl levelinitE0
dl levelinitE1
dl levelinitE2
dl levelinitE3
dl levelinitE4
dl levelinitE5
dl levelinitE6
dl levelinitE7
dl levelinitE8
dl levelinitE9
dl levelinitEA
dl levelinitEB
dl levelinitEC
dl levelinitED
dl levelinitEE
dl levelinitEF
dl levelinitF0
dl levelinitF1
dl levelinitF2
dl levelinitF3
dl levelinitF4
dl levelinitF5
dl levelinitF6
dl levelinitF7
dl levelinitF8
dl levelinitF9
dl levelinitFA
dl levelinitFB
dl levelinitFC
dl levelinitFD
dl levelinitFE
dl levelinitFF
dl levelinit100
dl levelinit101
dl levelinit102
dl levelinit103
dl levelinit104
dl levelinit105
dl levelinit106
dl levelinit107
dl levelinit108
dl levelinit109
dl levelinit10A
dl levelinit10B
dl levelinit10C
dl levelinit10D
dl levelinit10E
dl levelinit10F
dl levelinit110
dl levelinit111
dl levelinit112
dl levelinit113
dl levelinit114
dl levelinit115
dl levelinit116
dl levelinit117
dl levelinit118
dl levelinit119
dl levelinit11A
dl levelinit11B
dl levelinit11C
dl levelinit11D
dl levelinit11E
dl levelinit11F
dl levelinit120
dl levelinit121
dl levelinit122
dl levelinit123
dl levelinit124
dl levelinit125
dl levelinit126
dl levelinit127
dl levelinit128
dl levelinit129
dl levelinit12A
dl levelinit12B
dl levelinit12C
dl levelinit12D
dl levelinit12E
dl levelinit12F
dl levelinit130
dl levelinit131
dl levelinit132
dl levelinit133
dl levelinit134
dl levelinit135
dl levelinit136
dl levelinit137
dl levelinit138
dl levelinit139
dl levelinit13A
dl levelinit13B
dl levelinit13C
dl levelinit13D
dl levelinit13E
dl levelinit13F
dl levelinit140
dl levelinit141
dl levelinit142
dl levelinit143
dl levelinit144
dl levelinit145
dl levelinit146
dl levelinit147
dl levelinit148
dl levelinit149
dl levelinit14A
dl levelinit14B
dl levelinit14C
dl levelinit14D
dl levelinit14E
dl levelinit14F
dl levelinit150
dl levelinit151
dl levelinit152
dl levelinit153
dl levelinit154
dl levelinit155
dl levelinit156
dl levelinit157
dl levelinit158
dl levelinit159
dl levelinit15A
dl levelinit15B
dl levelinit15C
dl levelinit15D
dl levelinit15E
dl levelinit15F
dl levelinit160
dl levelinit161
dl levelinit162
dl levelinit163
dl levelinit164
dl levelinit165
dl levelinit166
dl levelinit167
dl levelinit168
dl levelinit169
dl levelinit16A
dl levelinit16B
dl levelinit16C
dl levelinit16D
dl levelinit16E
dl levelinit16F
dl levelinit170
dl levelinit171
dl levelinit172
dl levelinit173
dl levelinit174
dl levelinit175
dl levelinit176
dl levelinit177
dl levelinit178
dl levelinit179
dl levelinit17A
dl levelinit17B
dl levelinit17C
dl levelinit17D
dl levelinit17E
dl levelinit17F
dl levelinit180
dl levelinit181
dl levelinit182
dl levelinit183
dl levelinit184
dl levelinit185
dl levelinit186
dl levelinit187
dl levelinit188
dl levelinit189
dl levelinit18A
dl levelinit18B
dl levelinit18C
dl levelinit18D
dl levelinit18E
dl levelinit18F
dl levelinit190
dl levelinit191
dl levelinit192
dl levelinit193
dl levelinit194
dl levelinit195
dl levelinit196
dl levelinit197
dl levelinit198
dl levelinit199
dl levelinit19A
dl levelinit19B
dl levelinit19C
dl levelinit19D
dl levelinit19E
dl levelinit19F
dl levelinit1A0
dl levelinit1A1
dl levelinit1A2
dl levelinit1A3
dl levelinit1A4
dl levelinit1A5
dl levelinit1A6
dl levelinit1A7
dl levelinit1A8
dl levelinit1A9
dl levelinit1AA
dl levelinit1AB
dl levelinit1AC
dl levelinit1AD
dl levelinit1AE
dl levelinit1AF
dl levelinit1B0
dl levelinit1B1
dl levelinit1B2
dl levelinit1B3
dl levelinit1B4
dl levelinit1B5
dl levelinit1B6
dl levelinit1B7
dl levelinit1B8
dl levelinit1B9
dl levelinit1BA
dl levelinit1BB
dl levelinit1BC
dl levelinit1BD
dl levelinit1BE
dl levelinit1BF
dl levelinit1C0
dl levelinit1C1
dl levelinit1C2
dl levelinit1C3
dl levelinit1C4
dl levelinit1C5
dl levelinit1C6
dl levelinit1C7
dl levelinit1C8
dl levelinit1C9
dl levelinit1CA
dl levelinit1CB
dl levelinit1CC
dl levelinit1CD
dl levelinit1CE
dl levelinit1CF
dl levelinit1D0
dl levelinit1D1
dl levelinit1D2
dl levelinit1D3
dl levelinit1D4
dl levelinit1D5
dl levelinit1D6
dl levelinit1D7
dl levelinit1D8
dl levelinit1D9
dl levelinit1DA
dl levelinit1DB
dl levelinit1DC
dl levelinit1DD
dl levelinit1DE
dl levelinit1DF
dl levelinit1E0
dl levelinit1E1
dl levelinit1E2
dl levelinit1E3
dl levelinit1E4
dl levelinit1E5
dl levelinit1E6
dl levelinit1E7
dl levelinit1E8
dl levelinit1E9
dl levelinit1EA
dl levelinit1EB
dl levelinit1EC
dl levelinit1ED
dl levelinit1EE
dl levelinit1EF
dl levelinit1F0
dl levelinit1F1
dl levelinit1F2
dl levelinit1F3
dl levelinit1F4
dl levelinit1F5
dl levelinit1F6
dl levelinit1F7
dl levelinit1F8
dl levelinit1F9
dl levelinit1FA
dl levelinit1FB
dl levelinit1FC
dl levelinit1FD
dl levelinit1FE
dl levelinit1FF

print "Level MAIN inserted at $", pc

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
		CLC : ADC !Level		; | load pointer based on level number
		TAX				; | x3
		LDA .Table,x : STA $0000	; |
		LDA .Table+1,x : STA $0001	;/
		SEP #$30			; > All registers 8 bit
		LDA $0002
		PHA : PLB			; set bank
		PHK : PEA.w .Return-1		; set return address
		JML [$0000]			; execute pointer
		.Return
		PLB				; > End of bank wrapper
		PLA				;\
		BEQ +				; | Pull pause flag and execute overwritten branch
		JML $00A25B			; |
	+	JML $00A28A			;/



.Table
dl level0	
dl level1	
dl level2	
dl level3	
dl level4
dl level5
dl level6
dl level7
dl level8
dl level9
dl levelA
dl levelB
dl levelC
dl levelD
dl levelE
dl levelF
dl level10
dl level11
dl level12
dl level13
dl level14
dl level15
dl level16
dl level17
dl level18
dl level19
dl level1A
dl level1B
dl level1C
dl level1D
dl level1E
dl level1F
dl level20
dl level21
dl level22
dl level23
dl level24
dl level25
dl level26
dl level27
dl level28
dl level29
dl level2A
dl level2B
dl level2C
dl level2D
dl level2E
dl level2F
dl level30
dl level31
dl level32
dl level33
dl level34
dl level35
dl level36
dl level37
dl level38
dl level39
dl level3A
dl level3B
dl level3C
dl level3D
dl level3E
dl level3F
dl level40
dl level41
dl level42
dl level43
dl level44
dl level45
dl level46
dl level47
dl level48
dl level49
dl level4A
dl level4B
dl level4C
dl level4D
dl level4E
dl level4F
dl level50
dl level51
dl level52
dl level53
dl level54
dl level55
dl level56
dl level57
dl level58
dl level59
dl level5A
dl level5B
dl level5C
dl level5D
dl level5E
dl level5F
dl level60
dl level61
dl level62
dl level63
dl level64
dl level65
dl level66
dl level67
dl level68
dl level69
dl level6A
dl level6B
dl level6C
dl level6D
dl level6E
dl level6F
dl level70
dl level71
dl level72
dl level73
dl level74
dl level75
dl level76
dl level77
dl level78
dl level79
dl level7A
dl level7B
dl level7C
dl level7D
dl level7E
dl level7F
dl level80
dl level81
dl level82
dl level83
dl level84
dl level85
dl level86
dl level87
dl level88
dl level89
dl level8A
dl level8B
dl level8C
dl level8D
dl level8E
dl level8F
dl level90
dl level91
dl level92
dl level93
dl level94
dl level95
dl level96
dl level97
dl level98
dl level99
dl level9A
dl level9B
dl level9C
dl level9D
dl level9E
dl level9F
dl levelA0
dl levelA1
dl levelA2
dl levelA3
dl levelA4
dl levelA5
dl levelA6
dl levelA7
dl levelA8
dl levelA9
dl levelAA
dl levelAB
dl levelAC
dl levelAD
dl levelAE
dl levelAF
dl levelB0
dl levelB1
dl levelB2
dl levelB3
dl levelB4
dl levelB5
dl levelB6
dl levelB7
dl levelB8
dl levelB9
dl levelBA
dl levelBB
dl levelBC
dl levelBD
dl levelBE
dl levelBF
dl levelC0
dl levelC1
dl levelC2
dl levelC3
dl levelC4
dl levelC5
dl levelC6
dl levelC7
dl levelC8
dl levelC9
dl levelCA
dl levelCB
dl levelCC
dl levelCD
dl levelCE
dl levelCF
dl levelD0
dl levelD1
dl levelD2
dl levelD3
dl levelD4
dl levelD5
dl levelD6
dl levelD7
dl levelD8
dl levelD9
dl levelDA
dl levelDB
dl levelDC
dl levelDD
dl levelDE
dl levelDF
dl levelE0
dl levelE1
dl levelE2
dl levelE3
dl levelE4
dl levelE5
dl levelE6
dl levelE7
dl levelE8
dl levelE9
dl levelEA
dl levelEB
dl levelEC
dl levelED
dl levelEE
dl levelEF
dl levelF0
dl levelF1
dl levelF2
dl levelF3
dl levelF4
dl levelF5
dl levelF6
dl levelF7
dl levelF8
dl levelF9
dl levelFA
dl levelFB
dl levelFC
dl levelFD
dl levelFE
dl levelFF
dl level100
dl level101
dl level102
dl level103
dl level104
dl level105
dl level106
dl level107
dl level108
dl level109
dl level10A
dl level10B
dl level10C
dl level10D
dl level10E
dl level10F
dl level110
dl level111
dl level112
dl level113
dl level114
dl level115
dl level116
dl level117
dl level118
dl level119
dl level11A
dl level11B
dl level11C
dl level11D
dl level11E
dl level11F
dl level120
dl level121
dl level122
dl level123
dl level124
dl level125
dl level126
dl level127
dl level128
dl level129
dl level12A
dl level12B
dl level12C
dl level12D
dl level12E
dl level12F
dl level130
dl level131
dl level132
dl level133
dl level134
dl level135
dl level136
dl level137
dl level138
dl level139
dl level13A
dl level13B
dl level13C
dl level13D
dl level13E
dl level13F
dl level140
dl level141
dl level142
dl level143
dl level144
dl level145
dl level146
dl level147
dl level148
dl level149
dl level14A
dl level14B
dl level14C
dl level14D
dl level14E
dl level14F
dl level150
dl level151
dl level152
dl level153
dl level154
dl level155
dl level156
dl level157
dl level158
dl level159
dl level15A
dl level15B
dl level15C
dl level15D
dl level15E
dl level15F
dl level160
dl level161
dl level162
dl level163
dl level164
dl level165
dl level166
dl level167
dl level168
dl level169
dl level16A
dl level16B
dl level16C
dl level16D
dl level16E
dl level16F
dl level170
dl level171
dl level172
dl level173
dl level174
dl level175
dl level176
dl level177
dl level178
dl level179
dl level17A
dl level17B
dl level17C
dl level17D
dl level17E
dl level17F
dl level180
dl level181
dl level182
dl level183
dl level184
dl level185
dl level186
dl level187
dl level188
dl level189
dl level18A
dl level18B
dl level18C
dl level18D
dl level18E
dl level18F
dl level190
dl level191
dl level192
dl level193
dl level194
dl level195
dl level196
dl level197
dl level198
dl level199
dl level19A
dl level19B
dl level19C
dl level19D
dl level19E
dl level19F
dl level1A0
dl level1A1
dl level1A2
dl level1A3
dl level1A4
dl level1A5
dl level1A6
dl level1A7
dl level1A8
dl level1A9
dl level1AA
dl level1AB
dl level1AC
dl level1AD
dl level1AE
dl level1AF
dl level1B0
dl level1B1
dl level1B2
dl level1B3
dl level1B4
dl level1B5
dl level1B6
dl level1B7
dl level1B8
dl level1B9
dl level1BA
dl level1BB
dl level1BC
dl level1BD
dl level1BE
dl level1BF
dl level1C0
dl level1C1
dl level1C2
dl level1C3
dl level1C4
dl level1C5
dl level1C6
dl level1C7
dl level1C8
dl level1C9
dl level1CA
dl level1CB
dl level1CC
dl level1CD
dl level1CE
dl level1CF
dl level1D0
dl level1D1
dl level1D2
dl level1D3
dl level1D4
dl level1D5
dl level1D6
dl level1D7
dl level1D8
dl level1D9
dl level1DA
dl level1DB
dl level1DC
dl level1DD
dl level1DE
dl level1DF
dl level1E0
dl level1E1
dl level1E2
dl level1E3
dl level1E4
dl level1E5
dl level1E6
dl level1E7
dl level1E8
dl level1E9
dl level1EA
dl level1EB
dl level1EC
dl level1ED
dl level1EE
dl level1EF
dl level1F0
dl level1F1
dl level1F2
dl level1F3
dl level1F4
dl level1F5
dl level1F6
dl level1F7
dl level1F8
dl level1F9
dl level1FA
dl level1FB
dl level1FC
dl level1FD
dl level1FE
dl level1FF





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
		db !GFX_LuigiFireball-!GFX_status,$06,$20,$00,$00
		db !GFX_Baseball-!GFX_status,$07,$20,$40,$0F
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
		STA $00								; also copy palette to RAM mirror
		LDA.w #!PalsetData>>16 : STA $02
		PHX
		PHY
		TYA
		ORA #$0008
		ASL #4
		INC A
		ASL A
		TAX
		STA $04
		LDY #$0000
	-	LDA [$00],y : STA $6703,x
		INX #2
		INY #2
		CPY #$001E : BCC -
		PLY
		PLX
		LDA $04
		CLC : ADC.w #$6703

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

print "Bank $18 level code ends at $", pc, "."

org $198000
db $53,$54,$41,$52
dw $FFF7
dw $0008

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

print "Level code ends at $", pc, "."
print " "