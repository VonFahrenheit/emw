header
sa1rom

; --Defines--

incsrc "Defines.asm"

	!MoleWizard		= $30E608


; --Macros--

	macro GradientRGB(table)
		REP #$20			; > A 16 bit
		LDA #$3200			;\
		STA $4330			; |
		LDA #<table>_Red		; |
		STA $4332			; | Set up red colour math on channel 3
		PHK				; |
		PLY				; |
		STY $4334			;/
		LDA #$3200			;\
		STA $4340			; |
		LDA #<table>_Green		; | Set up green colour math on channel 4
		STA $4342			; |
		STY $4344			;/
		LDA #$3200			;\
		STA $4350			; |
		LDA #<table>_Blue		; | Set up blue colour math on channel 5
		STA $4352			; |
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
		STA $4332			; | Set up red colour math on channel 3
		PHK				; |
		PLY				; |
		STY $4334			;/
		LDA #$3200			;\
		STA $4340			; |
		LDA #<table>_Blue		; | Set up green colour math on channel 4
		STA $4342			; |
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
		JML LEVEL_MAIN			;\ Source: LDA $73D4 : BEQ $43
		NOP				;/

	org $00A295
		BRA +				;\
		NOP #2				; | Source: JSL $7F8000
		+				;/

	org $00A5EE
		JML LEVEL_INIT			;\ Source: SEP #$30 : JSR $919B
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

	.INIT

		PHB : PHK : PLB			; > Bank wrapper
		PHP
		SEP #$20
		STZ !MarioPalOverride		; reset Mario pal override
		LDA #$00
		STA !PauseThif			; unpause Thif
		STA !LevelInitFlag		; set level INIT
		LDA #$FF			;\
		STA !CameraBoxU+1		; | disable camera box
		STA !CameraForbiddance		;/
		JSL $138020			; > Load Yoshi Coins (A must be 0x00)
		LDA.b #..SA1 : STA $3180	;\
		LDA.b #..SA1>>8 : STA $3181	; | Have SA-1 clear VR2 RAM
		LDA.b #..SA1>>16 : STA $3182	; |
		JSR $1E80			;/
		PLP
		LDY !Translevel			;\
		LDA.w .MegaLevel,y		; | Set mega level
		STA !MegaLevelID		;/
		LDA !Level			;\
		ASL A				; |
		TAX				; | Load pointer based on level number
		LDA ..Table,x			; |
		STA $0000			;/
		STZ !Level+2			;\ Clear extra bytes
		STZ !Level+4			;/
		STZ !GFX_status+$00			;\
		STZ !GFX_status+$02			; |
		STZ !GFX_status+$04			; |
		STZ !GFX_status+$06			; | Clear GFX status
		STZ !GFX_status+$08			; |
		STZ !GFX_status+$0A			; |
		STZ !GFX_status+$0C			; |
		STZ !GFX_status+$0E			; |
		STZ !GFX_status+$10			; |
		STZ !GFX_status+$12			; |
		LDA #$0080 : STA !GFX_status+$14	;/
		STZ !SmoothCamera		; Clear smooth camera
		LDA #$0000			; > Set up clear
		STA !HDMAptr+0			;\ Clear HDMA pointer
		STA !HDMAptr+1			;/
		SEP #$10			; > Index 8 bit
		LDY #$0C : STY !GFX_status+$09	; > Default palette 8 replacement (pal E)
		LDY #$60 : STY !GFX_status+$0D	; > Default dynamic tile placement is $0C0
		LDY $2100			; > Backup 2100
		LDX #$80 : STX $2100		;\
		LDA #$3B82 : STA $4300		; |
		LDA #$00A0 : STA $4302		; |
		LDX #$00 : STX $4304		; | f-blank-wrapped CGRAM read for dynamic BG3
		LDA #$0016 : STA $4305		; |
		LDX #$01 : STX $2121		; |
		LDX #$01 : STX $420B		;/
		LDA #$2200 : STA $4300		;\
		LDA !Characters			; |
		AND #$000F			; |
		ASL #5				; |
		CLC : ADC.w #..P2Palette	; |
		STA $4302			; | f-blanked-wrapped CGRAM upload for P2 palette
		LDX.b #..P2Palette>>16		; |
		STX $4304			; |
		LDA #$0020 : STA $4305		; |
		LDX #$90 : STX $2121		; |
		LDX #$01 : STX $420B		;/
		LDA #$2200 : STA $4300		;\
		LDA !Characters			; |
		AND #$00F0			; |
		ASL A				; |
		CLC : ADC.w #..P2Palette	; |
		STA $4302			; | f-blanked-wrapped CGRAM upload for P1 palette
		LDX.b #..P2Palette>>16		; |
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
		+

		JSR GFXIndex

		STY $2100			; > Restore 2100
		LDA #$7EB0			;\ Default border tiles are $1EB-$1EF, $1FB-$1FF
		STA $400000+!MsgVRAM3		;/
		LDA #$7C00			;\
		STA $400000+!MsgVRAM1		; | Default portrait tiles
		LDA #$7C80			; |
		STA $400000+!MsgVRAM2		;/
		SEP #$20			; > A 8 bit
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
		LDA ..PlayerHP,x : STA !P2HP	; > Reset player HP if it's the first sublevel
		LDA !Characters			; |
		LSR #4 : TAX			; |
		LDA ..PlayerHP,x : STA !P2HP-$80; |
		+				;/

		LDA #$00 : STA !CurrentMario	; > No one plays Mario by default
		LDA !Characters			;\
		AND #$F0 : BNE +		; |
		LDA #$01 : STA !CurrentMario	; |
		BRA ..Mario			; |
	+	LDA !MultiPlayer		; |
		BEQ ..KillMario			; | Determine who plays Mario and if he's alive
		LDA !Characters			; |
		AND #$0F : BNE ..KillMario	; |
		LDA #$02 : STA !CurrentMario	; |
		BRA ..Mario			; |
		..KillMario			; |
		LDA #$01 : STA !P1Dead		; |
		..Mario				;/


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

		SEP #$30			;
		PLB				; > End of bank wrapper
		PEA $A5F3-1			;\ Set return address and execute subroutine
		JML $00919B			;/


		..SA1
		PHP
		PHB
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
org $048431
dl ..P2Palette
pullpc


..P2Palette	dw $0000,$7FFF,$0000,$0D71		; < Mario
		dw $1E98,$3B7F,$635F,$581D
		dw $000A,$381F,$44C4,$4E08
		dw $6770,$30B6,$35DF,$03FF

		dw $0000,$0000,$0000,$0000		; < Luigi
		dw $0000,$0000,$0000,$0000
		dw $0000,$0000,$0000,$0000
		dw $0000,$0000,$0000,$0000

		dw $0000,$7FFF,$0000,$610D		; < Kadaal
		dw $7172,$7E5A,$00B8,$025F
		dw $017C,$1F1F,$2620,$32E0
		dw $0000,$0000,$0000,$0000

			       ;0C63
		dw $0000,$7FFF,$0000,$0A5A		; < Leeway
		dw $0AFD,$1FBF,$125E,$190A
		dw $1D51,$21B6,$4E72,$6738
		dw $5D20,$7D80,$0000,$0000

..PlayerHP	db $00,$00,$03,$02,$00,$00		; < Max HP (Mario, Luigi, Kadaal, Leeway, Alter, Peach)


..Table
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

	.MAIN
		LDA $73D4			;\
		PHA				; | Don't clear OAM while game is paused
		BNE +				;/
		LDA !MsgTrigger : BEQ ++	; > Always clear if there's no message box
		LDA $7B88 : BNE +		; > Don't clear while window is closing
		LDA.l !MsgMode			;\
		BNE +				; | Don't clear OAM during !MsgMode non-zero
	++	JSL $138010			;/
	+	LDA #$01
		STA !LevelInitFlag		; set level MAIN
		JSL $138020			; > Handle Yoshi Coins (A=1)
		PHB : PHK : PLB			; > Bank wrapper
		LDA !RNG			; Load RNG from last frame
		ADC $13				; Add true frame counter
		ADC $15				;\
		ADC $16				; | Add player 1 controller input
		ADC $17				; |
		ADC $18				;/
		ADC $6DA3			;\
		ADC $6DA5			; | Add player 2 controller input
		ADC $6DA7			; |
		ADC $6DA9			;/
		ADC $7B				;\ Add player 1 speed
		ADC $7D				;/
		ADC $94				;\ Add player 1 position
		ADC $96				;/
		ADC !P2XSpeed			;\ Add player 2 speed
		ADC !P2YSpeed			;/
		ADC !P2XPosLo			;\ Add player 2 position
		ADC !P2YPosLo			;/
		STA !RNG			; Store RNG back (it should be at least kind of random now)

		REP #$30			; > All registers 16 bit
		LDA !Level			;\
		ASL A				; |
		TAX				; | Load pointer based on level number
		LDA ..Table,x			; |
		STA $0000			;/
		SEP #$30			; > All registers 8 bit
		LDX #$00			;\ Execute pointer
		JSR ($0000,x)			;/
		PLB				; > End of bank wrapper
		PLA				;\
		BEQ +				; | Pull pause flag and execute overwritten branch
		JML $00A25B			; |
	+	JML $00A28A			;/
..Table
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

incsrc "LevelCode.asm"

incsrc "LevelGFXIndex.asm"

print " "
print "Level code ends at $", pc, "."