header
sa1rom

print "-- SP_LEVEL --"

; --Defines--

incsrc "Defines.asm"
	!CompileText = 0
	incsrc "MSG/TextData.asm"		; get defines from TextData


; --Macros--

	macro GradientRGB(table)
		REP #$20			; > A 16 bit
		LDA #$3200			;\
		STA $4330			; |
		LDA #<table>_Red		; |
		STA !HDMA3source		; | Set up red colour math on channel 3
		LDY.b #<table>_Red>>16		; |
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
		TSB !HDMA			;/
	endmacro

	macro GradientGB(table)
		REP #$20			; > A 16 bit
		LDA #$3200			;\
		STA $4330			; |
		LDA #<table>_Green		; |
		STA !HDMA3source		; | Set up red colour math on channel 3
		LDY.b #<table>_Red>>16		; |
		STY $4334			;/
		LDA #$3200			;\
		STA $4340			; |
		LDA #<table>_Blue		; | Set up green colour math on channel 4
		STA !HDMA4source		; |
		STY $4344			;/
		SEP #$20			; > A 8 bit
		LDA #$18			;\ Enable HDMA on channels 3 and 4
		TSB !HDMA			;/
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

	org $058566
		JML LOAD_SCREEN_MODE		; org: LDA $00 : AND #$80
		BRA 6 : NOP #6			; skip obsolete code
		RETURN_SCREEN_MODE:
	warnpc $058572


	org $05D845
		JML HANDLE_FORCED_NUMBER	; org: BNE $5B ($05D8A2) : REP #$30
		RETURN_FORCED:


	org $05D8B7
	;	REP #$30			; > All registers 16 bit
	;	LDA $0E				;\ Set current level
		JSL LOAD_VRAM_MAP		; > actually hijack this to set up VRAM map mode
		STA !Level			;/
		ASL A				;\
		CLC : ADC $0E			; | All entries are 24-bit, so multiply by 3
		TAY				;/
		LDA $E000,y : STA $65		;\
		LDA $E001,y : STA $66		; | 16 bit mode saves a bit of space here
		LDA $E600,y : STA $68		; |
		LDA $E601,y : STA $69		;/
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


	.Unlock
	; $188050
incsrc "level_data/Level_Unlock.asm"


	.VRAM_map
	; $188250
	incsrc "level_data/VRAM_map.asm"

incsrc "LevelGFXIndex.asm"

;=======================;
;LEVEL GAME MODE REWRITE;
;=======================;
print "Level game mode code inserted at $", pc, "."
	pushpc
	org $00A1DA
		JML GAMEMODE14
	pullpc

incsrc "GameMode14.asm"



	LOAD_VRAM_MAP:
		REP #$30
		PHX
		LDX $0E
		LDA.l LEVEL_VRAM_map,x
		AND #$00FF
		STA !VRAMmap
		CMP #$0001 : BEQ .Map01
		CMP #$0002 : BNE .Map00

; 2107: BG1 tilemap control
; 2108: BG2 tilemap control
; 2109: BG3 tilemap control
; 210A: BG4 tilemap control (currently unused)
; 210B: BG1/BG2 GFX control (always 0)
; 210C: BG3/BG4 GFX control

	.Map02
		LDA #$4000 : STA !BG1Address		;\  VRAM map 02:
		LDA #$4800 : STA !BG2Address		; | - 0x0000: 32KB of 4bpp GFX for layer 1/2
		SEP #$30				; | - 0x4000: layer 1 tilemap (64x32)
		LDA #$41 : STA !2107			; | - 0x4800: layer 2 tilemap (64x32)
		LDA #$49 : STA !2108			; | - 0x5000: used by status bar
		LDA #$59 : STA !2109			; | - 0x5800: displacement map (64x32)
		LDA #$05 : STA !210C			;/
		BRA .MapDone

	.Map01
		LDA #$4000 : STA !BG1Address		;\  VRAM map 01:
		LDA #$4800 : STA !BG2Address		; | - 0x0000: 32KB of 4bpp GFX for layer 1/2
		SEP #$30				; | - 0x4000: layer 1 tilemap (64x32)
		LDA #$41 : STA !2107			; | - 0x4800: layer 2 tilemap (64x32)
		LDA #$49 : STA !2108			; | - 0x5000: 4KB of 2bpp GFX for layer 3
		LDA #$59 : STA !2109			; | - 0x5800: layer 3 tilemap (64x32 or 32x64)
		LDA #$05 : STA !210C			;/
		BRA .MapDone

	.Map00
		LDA #$3000 : STA !BG1Address		;\  VRAM map 00:
		LDA #$3800 : STA !BG2Address		; | - 0x0000: 24KB of 2bpp GFX for layer 1/2
		SEP #$30				; | - 0x3000: layer 1 tilemap (64x32)
		LDA #$31 : STA !2107			; | - 0x3800: layer 2 tilemap (64x32)
		LDA #$39 : STA !2108			; | - 0x4000: 8KB of 2bpp GFX for layer 3
		LDA #$53 : STA !2109			; | - 0x5000: layer 3 tilemap (64x64)
		LDA #$04 : STA !210C			;/
		.MapDone

		REP #$30
		PLX
		LDA $0E
		RTL



	LOAD_SCREEN_MODE:
		PHP
		REP #$10
		LDX !Level
		LDA.l LEVEL_VRAM_map,x : BEQ .Mode1
		CMP #$01 : BEQ .Mode1
		CMP #$02 : BNE .Mode1

		.Mode2
		LDA #$02 : STA !2105
		BRA .Return

		.Mode1
		LDA #$01
		BIT $00
		BPL $02 : ORA #$08
		STA !2105

	.Return	PLP
		JML RETURN_SCREEN_MODE




	HANDLE_FORCED_NUMBER:
		BNE .Force
		.Return
		REP #$30
		JML RETURN_FORCED
		.Force
		JML $05D8A9				; load this number raw





print "Level code handler inserted at $", pc, "."
	INIT_Level:

		PHB : PHK : PLB					; > bank wrapper start
		PHP
		SEP #$30

		STZ !Cutscene					; kill cutscene
		STZ !CutsceneSmoothness				; kill effect
		STZ !CutsceneWait				; kill timer
		STZ !Cutscene6DA2				;\
		STZ !Cutscene6DA3				; |
		STZ !Cutscene6DA4				; |
		STZ !Cutscene6DA5				; | kill cutscene input
		STZ !Cutscene6DA6				; |
		STZ !Cutscene6DA7				; |
		STZ !Cutscene6DA8				; |
		STZ !Cutscene6DA9				;/


		LDA !SRAM_Difficulty : STA !Difficulty_full	;\ difficulty settings from SRAM buffer
		AND #$03 : STA !Difficulty			;/


		LDA #$07 : STA !PalsetStart			; default: all palset rows are dynamic

		LDA !CurrentMario : BNE +			;\
		LDA #$7F : STA !MarioMaskBits			; | hide mario if he's not in play
		+						;/
		LDA #$00
		STA !PauseThif					; unpause Thif
		STA !LevelInitFlag				; set level INIT
		STA !3DWater					; disable 3D water
		STA !DizzyEffect				; disable dizzy effect
		LDA #$FF					;\
		STA !CameraBoxU+1				; | disable camera box
		STA !CameraForbiddance				;/
		LDX #$00					;\
	-	STA !Map16Remap,x				; | default map16 remap = 0xFF (disabled)
		INX : BNE -					;/
		LDA #$03 : STA !Map16Remap+3			; > exception for page 3, which defaults to GFX page 3
		LDA #$00 : JSL !ProcessYoshiCoins		; > load Yoshi Coins (A must be 0x00)
		LDA.b #.SA1 : STA $3180				;\
		LDA.b #.SA1>>8 : STA $3181			; | have SA-1 clear VR2 RAM
		LDA.b #.SA1>>16 : STA $3182			; |
		JSR $1E80					;/
		PLP
		LDY !Translevel					;\
		LDA.w LEVEL_MegaLevel,y				; | set mega level
		STA !MegaLevelID				;/
		LDA !Level					;\
		ASL A						; |
		CLC : ADC !Level				; | load pointer based on level number
		TAX						; | x3
		LDA .Table,x : STA $0000			; |
		LDA .Table+1,x : STA $0001			;/

		.LoadLightPoints					;\
		STZ !LightPointIndex					; |
		LDX #$0000						; |
		LDY !Level						; |
		..loop							; |
		TYA							; |
		CMP LightPoints+$C,x : BNE ..next			; |
		LDY !LightPointIndex					; |
		CPY #$006C : BCS ..fail					; |
		LDA LightPoints+$0,x : STA !LightPointX,y		; |
		LDA LightPoints+$2,x : STA !LightPointY,y		; |
		LDA LightPoints+$4,x : STA !LightPointR,y		; | search for and load light points belonging to this level
		LDA LightPoints+$6,x : STA !LightPointG,y		; |
		LDA LightPoints+$8,x : STA !LightPointB,y		; |
		LDA LightPoints+$A,x : STA !LightPointS,y		; |
		TYA							; |
		CLC : ADC #$000C					; |
		STA !LightPointIndex					; |
		..fail							; |
		LDY !Level						; |
		..next							; |
		TXA							; |
		CLC : ADC #$000E					; |
		TAX							; |
		CPX.w #LightPoints_End-LightPoints : BCC ..loop		;/



		STZ !Level+2				;\ Clear extra bytes
		STZ !Level+4				;/
		STZ !GlobalLight1			;\ reset auto light mixer
		STZ !GlobalLightMix			;/
		STZ !Color0				; clear color 0
		LDA #$0000				; > Set up clear
		STA !HDMAptr+0				;\ Clear HDMA pointer
		STA !HDMAptr+1				;/
		SEP #$10				; > Index 8 bit
		LDX #$80 : STX $2100			; start f-blank

		LDX #$0E				;\
	-	LDA $6703+2,x : STA $00A0,x		; | store this palette in SNES WRAM
		DEX #2 : BPL -				;/

		LDA #$0100				;\
		STA !LightR				; | default lighting
		STA !LightG				; |
		STA !LightB				;/
		LDA #$0002 : STA !LightIndexStart	;\ default: shade all colors except background
		STZ !LightIndexEnd			;/
		STZ !LightList+$0			;\
		STZ !LightList+$2			; |
		STZ !LightList+$4			; |
		STZ !LightList+$6			; | default setting is to include all colors in SNES shader
		LDA #$0101 : STA !LightList+$8		; | except for player palettes!
		STZ !LightList+$A			; |
		STZ !LightList+$C			; |
		STZ !LightList+$E			;/

		LDA #$8000 : STA $4300			;\
		LDA.w #!PaletteRGB : STA $4302		; |
		STZ $4304				; |
		LDA #$0200 : STA $4305			; |
		STZ $2182				; | initialize light buffers
		LDA.w #!LightData_SNES : STA $2181	; |
		LDX #$01 : STX $420B			; |
		LDA.w #!PaletteRGB : STA $4302		; |
		LDA #$0200 : STA $4305			; |
		STX $420B				;/
		LDX #$02 : STX !ProcessLight		; stop light from running first frame

		LDA #$2200 : STA $4300			;\
		LDA !Characters				; |
		AND #$000F				; |
		ASL #5					; |
		CLC : ADC.w #!PalsetData		; |
		STA $4302				; | f-blanked-wrapped CGRAM upload for P2 palette
		LDX.b #!PalsetData>>16			; |
		STX $4304				; |
		LDA #$0020 : STA $4305			; |
		LDX #$90 : STX $2121			; |
		LDX #$01 : STX $420B			;/
		LDA #$2200 : STA $4300			;\
		LDA !Characters				; |
		AND #$00F0				; |
		ASL A					; |
		CLC : ADC.w #!PalsetData		; |
		STA $4302				; | f-blanked-wrapped CGRAM upload for P1 palette
		LDX.b #!PalsetData>>16			; |
		STX $4304				; |
		LDA #$0020 : STA $4305			; |
		LDX #$80 : STX $2121			; |
		LDX #$01 : STX $420B			;/
		LDX #$80 : STX $2115			; > Setup for Mario GFX upload
		LDA !MultiPlayer			;\ Ignore P2 during single player
		AND #$00FF : BEQ +			;/
		LDA !Characters				;\
		AND #$000F : BNE +			; |
		LDA #$6280				; |
		BRA ++					; |
	+	LDA !Characters				; |
		AND #$00F0 : BNE +			; |
		LDA #$6080				; | Upload non-dynamic Mario tiles if Mario is in play
	++	STA $2116 : PHA				; |
		LDA #$1801 : STA $4310			; |

		LDY.b #!File_Mario			; |
		JSL !GetFileAddress			; |

		LDY #$80 : STY $2115
		LDA !FileAddress+1 : STA $4313		; |
		LDA !FileAddress			; |
		CLC : ADC.w #$7000-$400+$100		; |
		STA $4312				; |
		LDA #$0100 : STA $4315			; |
		LDX #$02 : STX $420B			; |
		PLA					; |
		CLC : ADC #$0100			; |
		STA $2116				; |
		LDA !FileAddress			; |
		CLC : ADC.w #$7000-$400+$300		; |
		STA $4312				; |
		LDA #$0100 : STA $4315			; |
		LDX #$02 : STX $420B			;/
	;	STZ $2182				;\
	;	LDA #$7D00+$C00 : STA $2181		; > this is RAM address for GFX33
	;	LDA #$8000 : STA $4310			; |
	;	LDY.b #!File_Mario_Expand		; |
	;	JSL !GetFileAddress			; |
	;	LDA !FileAddress : STA $4312		; |
	;	LDA !FileAddress+1 : STA $4313		; |
	;	LDA #$0400 : STA $4315			; |
	;	LDX #$02 : STX $420B			;/
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
	-	LDA.l !PalsetData,x : STA $6803,y
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
	-	LDA.l !PalsetData,x : STA $6823,y
		INX #2
		INY #2
		CPY #$0020 : BCC -

		JSR GFXIndex

		LDA #$7EB0				;\ default border tiles are $1EB-$1EF, $1FB-$1FF
		STA $400000+!MsgVRAM3			;/
		LDA #$7C00				;\
		STA $400000+!MsgVRAM1			; | default portrait tiles are $1C0-$1DF
		LDA #$7C80				; |
		STA $400000+!MsgVRAM2			;/

		STZ !MsgTrigger
		STZ !MsgTrigger+1


		SEP #$30				; all regs 16-bit
		LDA #$70 : STA !AnimToggle		; default !AnimToggle setting: everything allowed, max 4KB



		LDA !P2Status-$80			;\
		CMP #$02 : BCS .P1Done			; |
		LDA !P2Pipe-$80 : PHA			; |
		LDA !P2SlantPipe-$80 : PHA		; |
		LDX.b #!P2Physics-(!P2Basics)-6		; > keep first 5 bytes of basics
	-	STZ !P2Basics-$80+$05,x			; |
		DEX : BPL -				; | reset p1
		LDX.b #!P2Base+$80-(!P2Physics)-7-1	; > keep first 6 bytes of physics, keep last byte of custom (temp HP)
	-	STZ !P2Physics-$80+$06,x		; |
		DEX : BPL -				; |
		PLA : STA !P2SlantPipe-$80		; |
		PLA : STA !P2Pipe-$80			; |
		.P1Done					;/

		LDA !P2Status-$80			;\
		CMP #$02 : BCS .P2Done			; |
		LDA !P2Pipe : PHA			; |
		LDA !P2SlantPipe : PHA			; |
		LDX.b #!P2Physics-(!P2Basics)-6		; > keep first 5 bytes of basics
	-	STZ !P2Basics+$05,x			; |
		DEX : BPL -				; | reset p1
		LDX.b #!P2Base+$80-(!P2Physics)-7-1	; > keep first 6 bytes of physics, keep last byte of custom (temp HP)
	-	STZ !P2Physics+$06,x			; |
		DEX : BPL -				; |
		PLA : STA !P2SlantPipe			; |
		PLA : STA !P2Pipe			; |
		.P2Done					;/

		LDA.b #1 : STA !TimerFrames		; set timer to update right away
		LDA !MarioDirection			;\
		STA !P2Direction-$80			; | character facing
		STA !P2Direction			;/

		STZ !P2Init-$80				;\ reset PCE init flags
		STZ !P2Init				;/

		LDA $741A : BNE +			; how many doors have been entered
		LDX #$7F				;\
	-	STZ !TranslevelFlags,x			; | clear translevel flags on first sublevel only
		DEX : BPL -				;/

		STZ !P2TempHP-$80			;\ clear temp HP
		STZ !P2TempHP				;/
		REP #$20				;\
		LDA !Translevel				; |
		ASL A					; |
		TAX					; | init time limit (on first sublevel only)
		LDA.l LevelTimerTable,x			; |
		INC A					; |
		STA !TimerSeconds			;/
		STZ !TimeElapsed+0			;\
		STZ !TimeElapsed+1			; | reset time elapsed (on first sublevel only)
		SEP #$20				;/


		LDA !MegaLevelID : BNE ..megalevel
		..normallevel
		LDA #$FC : STA !StatusX
		LDX #$1F
	-	LDA .StatusProp_normallevel,x : STA !StatusProp,x
		DEX : BPL -
		BRA ..done
		..megalevel
		STZ !StatusX
		LDX #$1F
	-	LDA .StatusProp_megalevel,x : STA !StatusProp,x
		DEX : BPL -
		..done
		LDX #$0E
	-	LDA .StatusBarColors,x : STA !StatusBarColors,x
		DEX : BPL -
		JSL $008E1A				; status bar


		LDA #$0F
		STA !P2HP-$80
		STA !P2HP

		+					;/

		LDA #$00 : STA !CurrentMario		; > No one plays Mario by default
		LDA !Characters				;\
		AND #$F0 : BNE +			; |
		LDA #$01 : STA !CurrentMario		; |
		BRA .Mario				; |
	+	LDA !MultiPlayer			; |
		BEQ .KillMario				; | Determine who plays Mario and if he's alive
		LDA !Characters				; |
		AND #$0F : BNE .KillMario		; |
		LDA #$02 : STA !CurrentMario		; |
		BRA .Mario				; |
		.KillMario				; |
		LDA #$01 : STA !P1Dead			; |
		.Mario					;/


		LDX #$18					;\
		LDA #$00					; | make sure these regs are wiped
	-	STA.l !VineDestroy,x				; |
		DEX : BPL -					;/



		LDA !P1Dead					;\
		BEQ +						; | keep mario dead between sub-levels
		LDA #$09 : STA $71				; |
		+						;/
		LDA #$A1 : STA !MsgPal				; default portrait palettes are A-B
		LDA #$18 : STA !TextPal				; default text palette (colors 0x19 and 0x1B)
		LDA #$08 : STA !BorderPal			; default border palette = red
		PHB
		LDA $0002
		PHA : PLB
		PHK : PEA.w .Return-1				; set return address
		JML [$0000]					; execute pointer
		.Return
		PLB
		SEP #$30
		JSL GAMEMODE14_Camera				; set scroll values for BG2
		REP #$20
		LDA $20
		SEC : SBC #$0008
		STA !BG2ZipColumnY				; store first value

		JSL $05809E					; move this to here, after the camera has been initialized


		SEP #$30					; all regs 8-bit
		LDA !MarioDirection : PHA			;\
		LDA !P2Direction-$80 : PHA			; | preserve player directions
		LDA !P2Direction : PHA				;/

		LDA $741A
		ORA !P2Pipe-$80
		ORA !P2Pipe
		BNE +
		LDA #$3F : STA !P2Entrance-$80
		LDA #$4F : STA !P2Entrance
		+


; ID = 0xFF	-> not native to this level



		.SpawnHeldItems
		LDA !HeldItemP1_num
		CMP #$FF : BEQ ..p1done
		LDX #$0F
	-	LDA $3230,x : BEQ ..thisp1
		DEX : BPL -
		JMP ..p2done
		..thisp1
		LDA #$40 : TSB !P2ExtraInput1-$80
		LDA !HeldItemP1_num : STA $3200,x
		LDA !HeldItemP1_customnum : STA !NewSpriteNum,x
		LDA !HeldItemP1_extra : STA !ExtraBits,x
		JSL !ResetSprite
		LDA #$0B : STA $3230,x
		LDA !HeldItemP1_prop1 : STA !ExtraProp1,x
		LDA !HeldItemP1_prop2 : STA !ExtraProp2,x
		LDA !HeldItemP1_ID : STA $33F0,x
		LDA !P2XPosLo-$80 : STA !SpriteXLo,x
		LDA !P2XPosHi-$80 : STA !SpriteXHi,x
		LDA !P2YPosLo-$80 : STA !SpriteYLo,x
		LDA !P2YPosHi-$80 : STA !SpriteYHi,x
		INX : STX !P2Carry-$80
		..p1done
		LDA #$FF : STA !HeldItemP1_num

		LDA !HeldItemP2_num
		CMP #$FF : BEQ ..p2done
		LDX #$0F
	-	LDA $3230,x : BEQ ..thisp2
		DEX : BPL -
		BRA ..p2done
		..thisp2
		LDA #$40 : TSB !P2ExtraInput1
		LDA !HeldItemP2_num : STA $3200,x
		LDA !HeldItemP2_customnum : STA !NewSpriteNum,x
		LDA !HeldItemP2_extra : STA !ExtraBits,x
		JSL !ResetSprite
		LDA #$0B : STA $3230,x
		LDA !HeldItemP2_prop1 : STA !ExtraProp1,x
		LDA !HeldItemP2_prop2 : STA !ExtraProp2,x
		LDA !HeldItemP1_ID : STA $33F0,x
		LDA !P2XPosLo : STA !SpriteXLo,x
		LDA !P2XPosHi : STA !SpriteXHi,x
		LDA !P2YPosLo : STA !SpriteYLo,x
		LDA !P2YPosHi : STA !SpriteYHi,x
		INX : STX !P2Carry
		..p2done
		LDA #$FF : STA !HeldItemP2_num



		LDA.b #$08 : STA $3180				;\
		LDA.b #$80 : STA $3181				; | run PCE
		LDA.b #$15 : STA $3182				; |
		JSR $1E80					;/
		LDA #$01 : STA !ProcessingSprites		;\
		LDA.b #$00 : STA $3180				; |
		LDA.b #$80 : STA $3181				; | run Fe26
		LDA.b #$16 : STA $3182				; |
		JSR $1E80					; |
		LDA #$00 : STA !ProcessingSprites		;/
		PLA : STA !P2Direction				;\
		PLA : STA !P2Direction-$80			; | restore player directions
		PLA : STA !MarioDirection			;/

		JSL !BuildOAM					; put tiles on-screen

		LDA.b #HandleGraphics_CallLight : STA $3180	;\
		LDA.b #HandleGraphics_CallLight>>8 : STA $3181	; | run this in case global light was set
		LDA.b #HandleGraphics_CallLight>>16 : STA $3182	; |
		JSR $1E80					;/

		REP #$20					;\
		LDA !OAMindex_p0_prev : STA !OAMindex_p0	; |
		LDA !OAMindex_p1_prev : STA !OAMindex_p1	; | keep the just-drawn stuff from being cleared
		LDA !OAMindex_p2_prev : STA !OAMindex_p2	; |
		LDA !OAMindex_p3_prev : STA !OAMindex_p3	;/
		LDA #$0100					;\
		CMP !LightR : BNE ..shade			; | check for light alterations
		CMP !LightG : BNE ..shade			; |
		CMP !LightB : BEQ ..initpal			;/
		..shade						;\
		LDA.w #.PreShade : STA $3180			; |
		LDA.w #.PreShade>>8 : STA $3181			; | have sa-1 preshade palette and dump it in !PaletteBuffer
		SEP #$20					; |
		JSR $1E80					;/
		LDA !LightIndexStart+1				;\
		LSR A						; |
		LDA !LightIndexStart				; |
		ROR A						; |
		STA $2121					; |
		LDA.b #!PaletteBuffer>>16 : STA $4304		; |
		REP #$30					; |
		LDX !LightIndexStart				; |
		CPX #$000E+2 : BCS ..noBG3			; |
		..BG3						; |
		LDA !PaletteBuffer,x : STA $00A0-2,x		; |
		CPX #$0002 : BCC ..noBG3			; |
		DEX #2 : BRA ..BG3				; | !PaletteBuffer -> CGRAM
		..noBG3						; |
		LDA #$2202 : STA $4300				; |
		LDA !LightIndexStart				; |
		CLC : ADC.w #!PaletteBuffer			; |
		STA $4302					; |
		LDA !LightIndexEnd				; |
		BNE $03 : LDA #$0200				; |
		SEC : SBC !LightIndexStart			; |
		STA $4305					; |
		SEP #$30					; |
		LDA #$01 : STA $420B				; |
		BRA ..noshade					;/
		..initpal					;\
		SEP #$20					; |
		STZ $2121					; |
		REP #$30					; |
		LDA #$2202 : STA $4300				; | if light is all 100%, just upload !PaletteRGB -> CGRAM
		LDA.w #!PaletteRGB : STA $4302			; |
		LDA.w #!PaletteRGB>>8 : STA $4303		; |
		LDA #$0200 : STA $4305				; |
		SEP #$30					; |
		LDA #$01 : STA $420B				; |
		..noshade					;/
		LDA.b #.InitShader : STA $3180			;\
		LDA.b #.InitShader>>8 : STA $3181		; | initialize !ShaderInput with a copy of !PaletteRGB
		LDA.b #.InitShader>>16 : STA $3182		; |
		JSR $1E80					;/
		STZ !ProcessLight				; light shader is good to go


		PLB						; > end of bank wrapper
		PEA $A5F3-1					;\ set return address and execute subroutine
		JML $00919B					;/

	.InitShader						;\
		PHB : PHK : PLB					; |
		PHP						; |
		REP #$30					; |
		LDX.w #!PaletteRGB				; |
		LDY.w #!ShaderInput				; | copy RGB palette to shader input
		LDA.w #$01FF					; |
		MVN !ShaderInput>>16,$00			; |
		PLP						; |
		PLB						; |
		RTL						;/



	.PreShade
		PHB : PHK : PLB
		PHP
		STZ $2250
		REP #$30

		LDX !LightIndexStart

		..loop
		LDA !PaletteRGB,x : STA $04
		AND #$001F : STA $2251
		LDA !LightR : STA $2253
		NOP : BRA $00
		LDA $2307
		CMP #$001F
		BCC $03 : LDA #$001F
		STA $00
		LDA $04
		AND #$001F*$20 : STA $2251
		LDA !LightG : STA $2253
		NOP : BRA $00
		LDA $2307
		CMP #$001F*$20
		BCC $03 : LDA #$001F*$20
		AND #$001F*$20
		STA $02
		LDA $04
		AND #$001F*$20*$20 : STA $2251
		LDA !LightB : STA $2253
		NOP : BRA $00
		LDA $2307
		CMP #$001F*$20*$20
		BCC $03 : LDA #$001F*$20*$20
		AND #$001F*$20*$20
		ORA $00
		ORA $02
		STA !PaletteBuffer,x

		..next
		INX #2
		CPX #$0200 : BCS ..end
		CPX !LightIndexEnd : BNE ..checkdisable
		..end
		PLP
		PLB
		RTL

		..checkdisable
		TXA
		BIT #$001F : BNE ..loop
		TXY
		LSR #5
		TAX
		LDA !ShaderRowDisable,x
		AND #$00FF : BEQ ..ok
		TYX
		LDA !PaletteRGB+$00,x : STA !PaletteBuffer+$00,x
		LDA !PaletteRGB+$02,x : STA !PaletteBuffer+$02,x
		LDA !PaletteRGB+$04,x : STA !PaletteBuffer+$04,x
		LDA !PaletteRGB+$06,x : STA !PaletteBuffer+$06,x
		LDA !PaletteRGB+$08,x : STA !PaletteBuffer+$08,x
		LDA !PaletteRGB+$0A,x : STA !PaletteBuffer+$0A,x
		LDA !PaletteRGB+$0C,x : STA !PaletteBuffer+$0C,x
		LDA !PaletteRGB+$0E,x : STA !PaletteBuffer+$0E,x
		LDA !PaletteRGB+$10,x : STA !PaletteBuffer+$10,x
		LDA !PaletteRGB+$12,x : STA !PaletteBuffer+$12,x
		LDA !PaletteRGB+$14,x : STA !PaletteBuffer+$14,x
		LDA !PaletteRGB+$16,x : STA !PaletteBuffer+$16,x
		LDA !PaletteRGB+$18,x : STA !PaletteBuffer+$18,x
		LDA !PaletteRGB+$1A,x : STA !PaletteBuffer+$1A,x
		LDA !PaletteRGB+$1C,x : STA !PaletteBuffer+$1C,x
		LDA !PaletteRGB+$1E,x : STA !PaletteBuffer+$1E,x
		TXA
		CLC : ADC #$0020
		TAX
		JMP ..loop

		..ok
		TYX
		JMP ..loop




	.StatusProp
		..megalevel
		db $20,$20,$20,$20,$20				; P1 coins
		db $20,$20,$20,$20,$20,$20			; P1 hearts
		db $20,$20,$20,$20,$20				;\ Yoshi coins
		db $20,$20,$20,$20,$20				;/
		db $64,$64,$64,$64,$64,$64			; P2 hearts
		db $24,$24,$24,$24,$24				; P2 coins
		..normallevel
		db $20,$20,$20,$20,$20				; P1 coins
		db $20,$20,$20,$20,$20,$20			; P1 hearts
		db $20,$20,$20,$20,$20				;\ Yoshi coins
		db $20,$20,$20,$20,$20				;/
		db $64,$64,$64,$64,$64				; P2 hearts
		db $24,$24,$24,$24,$24,$24			; P2 coins

	.StatusBarColors
		incbin "../PaletteData/StatusBar.mw3":2-10



		.SA1
		PHP						;\ wrapper start
		PHB : PHK : PLB					;/
		SEP #$30

		STZ !PlayerBonusHP				;\
	;	LDA !Difficulty_full				; |
	;	AND #$03 : BNE ..nobonushp			; | +1 max HP on easy
	;	LDA #$04 : STA !PlayerBonusHP			; |
		..nobonushp					;/

		%ReloadOAMData()				; reload
		REP #$20					; A 16-bit
		STZ !DynamicTile				; clear dynamic data
		LDA $6701 : STA $6703				; > copy this (so it gets written as HSL)
		LDA $96						;\
		SEC : SBC #$0010				; |
		STA $01						; |
		STA $08						; |
		LDA $94						; |
		SEC : SBC #$0020				; |
		STA $07						; |
		SEP #$30					; |
		STA $00						; | despawn sprites that are withing 32px of players upon level entry
		LDA #$50					; |
		STA $02						; |
		STA $03						; |
		LDX #$0F					; |
	-	LDA $3230,x : BEQ +				; |
		LDA !NewSpriteNum,x				; |
		CMP #$11 : BEQ +				; > exception for sign
		LDA $3200,x					; |
		CMP #$0E : BEQ +				; > exception for keyhole
		JSL !GetSpriteClipping04			; |
		JSL !CheckContact				; |
		BCC +						; |
		STZ $3230,x					; |
	+	DEX : BPL -					;/

		LDX #$00					;\
		LDY #$00					; | get HSL format palette
		JSL !RGBtoHSL					;/
		LDA #$41 : PHA					; push bank 0x41
		LDA #$40					;\ switch to bank 0x40
		PHA : PLB					;/
		STZ.w $4406					; clear !MsgVertOffset
		REP #$30					; all regs 16-bit
		LDX #$01FE					;\
		LDA #$8001					; | reset NPC talk tables (all level message 1)
	-	STA.w !NPC_Talk,x				; | (also set cap to the same thing)
		STA.w !NPC_TalkCap,x				; |
		DEX #2 : BPL -					;/
		STZ !VRAMtable+$3FF				; set up wipe (!VRAMtable)
		LDA.w #$03FE					;\
		LDX.w #!VRAMtable+$3FF				; | wipe VR3 tables
		LDY.w #!VRAMtable+$3FE				; |
		MVP $40,$40					;/
		PLB						; switch to bank 0x41
		STZ.w !3D_Base+$7FE				; set up wipe for cluster joint data
		STZ.w !Particle_Base				; set up wipe for particle data
		STZ.w !BG_object_Base				; set up wipe for BG object data
		LDA.w #$07FE					;\
		LDX.w #!3D_Base+$7FF				; | wipe 3D cluster joints
		LDY.w #!3D_Base+$7FE				; |
		MVP !3D_Base>>16,!3D_Base>>16			;/
		LDA.w #(!Particle_Size*!Particle_Count)-2	;\
		LDX.w #!Particle_Base				; | wipe particle data
		LDY.w #!Particle_Base+1				; |
		MVN $41,$41					;/
		LDA.w #(!BG_object_Size*!BG_object_Count)-2	;\
		LDX.w #!BG_object_Base				; | wipe BG object data
		LDY.w #!BG_object_Base+1			; |
		MVN $41,$41					;/

		PLB						;\ wrapper end
		PLP						;/
		RTL						; return





pushpc
org $048452
dl LoadPalset	; code pointer, should be read manually
dl BoxTable	; data pointer for camera boxes
pullpc


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
		LDA #$01 : STA !LevelInitFlag		; set level MAIN

		JSL !ProcessYoshiCoins			; > handle Yoshi Coins (A=1)

		PHB : PHK : PLB				; > bank wrapper
		REP #$30				; > all registers 16 bit
		LDA !Level				;\
		ASL A					; |
		CLC : ADC !Level			; | load pointer based on level number
		TAX					; | x3
		LDA .Table,x : STA $0000		; |
		LDA .Table+1,x : STA $0001		;/
		SEP #$30				; > all registers 8 bit
		LDA $0002
		PHA : PLB				; set bank
		PHK : PEA.w .Return-1			; set return address
		JML [$0000]				; execute pointer
		.Return
		PLB					; > end of bank wrapper
		RTS


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





; alt palset light values:


LightValues:	;    R     G     B
.Default	dw $0100,$0100,$0100	; 00
.Dawn		dw $00F8,$00EE,$00D4	; 01
.Sunset		dw $0120,$00E0,$00C0	; 02
.Night		dw $0080,$00C0,$00E0	; 03
.Lava		dw $0180,$0080,$0080	; 04
.Water		dw $00C0,$00E0,$00F0	; 05




;================;
;GRAPHICS HANDLER;
;================;
HandleGraphics:
		PHB : PHK : PLB
		PHP
		SEP #$30

		JSR .RotateSimple
		JSR .UpdatePortal
		JSR .RainbowShifter					; also spawns sparkles
		JSR .UpdateLight
		JSR .UpdatePalset

		PLP
		PLB
		RTL


		.CallLight
		PHB : PHK : PLB
		PHP
		SEP #$30
		JSR .UpdateLight
		PLP
		PLB
		RTL



	; handler for simple rotation graphics
	.RotateSimple
		STZ $2250
		LDY #$00
		..loop
		PHY
		REP #$30
		LDX .RotationData,y
		LDA !GFX_status,x
		SEP #$30
		BNE ..process
		JMP ..next
		..process				;\
		STA $00					; | $00 = tile num (000-1FF)
		XBA : STA $01				;/
		LDA .RotationData+2,y : TAX		;\
		LDA !SD_status,x : STA $02		; | $02 = SD status
		STZ $03					;/
		LDA .RotationData+3,y : STA $04		;\ $04 = size
		STZ $05					;/
		LDA .RotationData+4,y : STA $07		; $06 = animation rate (n/v flag triggers)
		LDA .RotationData+5,y : STA $08		;\ $08 = rotation direction
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
		..8x8
		STA.w !VRAMtable+$00,x : BRA ..shared
		..big
		LSR A
		STA.w !VRAMtable+$00,x
		STA.w !VRAMtable+$07,x
		..shared
		SEP #$20
		LDY #$7E
		LDA $02
		AND #$C0 : BEQ ..writebank
		LDY #$7F
		CMP #$40 : BEQ ..writebank
		LDY #$40
		CMP #$80 : BEQ ..writebank
		LDY #$41
		..writebank
		TYA
		STA.w !VRAMtable+$04,x
		STA.w !VRAMtable+$0B,x
		PLB

		..next
		PLA
		CLC : ADC #$06
		CMP.b #.RotationData_end-.RotationData : BCS ..return
		TAY
		JMP ..loop
		..return
		RTS

	; format:
	; - GFX status index
	; - SD index
	; - width ($20 for 8x8 or $80 for 16x16)
	; - animation speed (00 = every frame, 40/80 = every other frame, C0 = every 4 frames)
	; - direction (00 = clockwise, 0F = counterclockwise)

	.RotationData
		dw !GFX_Hammer_offset		: db $00,$80,$00,$0F
		dw !GFX_Bone_offset		: db $02,$80,$40,$0F
		dw !GFX_SmallFireball_offset	: db $03,$20,$00,$00
		dw !GFX_ReznorFireball_offset	: db $04,$80,$00,$0F
		dw !GFX_Goomba_offset		: db $05,$80,$00,$0F
		dw !GFX_LuigiFireball_offset	: db $06,$20,$00,$00
		dw !GFX_Baseball_offset		: db $07,$20,$40,$0F
		..end



	; handler for portal sprite
	.UpdatePortal
		PHP
		REP #$30
		LDA $14
		AND #$0003 : BNE ..return
		LDA !GFX_Portal : BEQ ..return
		LDY.w #!File_Portal : JSL !GetFileAddress
		JSL !GetVRAM
		LDA !FileAddress+1
		STA !VRAMbase+!VRAMtable+$03,x
		STA !VRAMbase+!VRAMtable+$0A,x
		LDA $14
		LSR #2
		AND #$0003
		XBA : LSR A			; *128
		ADC !FileAddress
		STA !VRAMbase+!VRAMtable+$02,x
		ADC #$0200
		STA !VRAMbase+!VRAMtable+$09,x
		LDA #$0080
		STA !VRAMbase+!VRAMtable+$00,x
		STA !VRAMbase+!VRAMtable+$07,x
		LDA !GFX_Portal
		ASL #4
		ORA #$6000
		STA !VRAMbase+!VRAMtable+$05,x
		ADC #$0100
		STA !VRAMbase+!VRAMtable+$0C,x
		..return
		PLP
		RTS



	; handler for player rainbow effect
	.RainbowShifter
		PHP
		SEP #$30
		LDA !StarTimer : BNE .Shift
	..P1	LDA !P2LockPalset-$80 : BNE ..P2
		LDA !Palset8
		AND #$7F
		STA !Palset8
	..P2	LDA !P2LockPalset : BNE ..ret
		LDA !Palset9
		AND #$7F
		STA !Palset9
	..ret	PLP
		RTS

	.Shift
		XBA
		LDA $14
		AND #$03
		BNE $03 : DEC !StarTimer
		LDA #$00
		XBA
		LSR #5
		TAX
		LDA $13
		AND.l $028AA9,x : BNE ..nosparkle
		LDA !P2Status-$80 : BNE ..nop1
		LDY #$00
		JSR .SpawnSparkles
		..nop1
		LDA !MultiPlayer : BEQ ..nosparkle
		LDA !P2Status : BNE ..nosparkle
		LDY #$80
		JSR .SpawnSparkles
		..nosparkle
		REP #$10
		LDX #$0081
		LDY #$001F
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
		CPX #$0081*3 : BCS --
		LDX #$0081
		LDY #$001F
		JSL !HSLtoRGB
		LDX #$0081
		LDY #$001F
		LDA $7490
		CMP #$10
		BCC $02 : LDA #$10
		SEC : SBC #$20
		EOR #$FF : INC A
		JSL !MixRGB

		PLP
		RTS


		.SpawnSparkles
		LDA #$1F : STA $0C			;\ AND value for Y coord
		STZ $0D					;/
		LDA #$EE : STA $0E			;\ Y offset = -18
		LDA #$FF : STA $0F			;/

		LDA !P2HurtboxH-$80,y
		CMP #$11 : BCS +
		LDA #$0F : STA $0C
		LDA #$FE : STA $0E
		+

		LDA #$0F : STA $04			;\ AND value for X coord
		STZ $05					;/
		STZ $06					;\ X offset
		STZ $07					;/

		LDA !P2HurtboxW-$80,y
		CMP #$11 : BCC +
		LDA #$1F : STA $04
		LDA !P2Dashing-$80,y : BEQ +++
		LDA !P2Direction-$80,y : BNE +
		BRA ++
	+++	LDA !P2Direction-$80,y : BEQ +
	++	LDA #$F0 : STA $06
		DEC $07
		+



		LDA $14
		AND #$1F
		TAX
		REP #$20
		LDA !RNGtable,x
		AND $04
		DEC #2
		CLC : ADC $06
		STA $00
		TXA
		EOR #$0010
		TAX
		LDA !RNGtable+1,x
		AND $0C
		CLC : ADC $0E
		STA $02
		SEP #$20
		%Ex_Index_X()
		LDA #$05+!MinorOffset : STA !Ex_Num,x	; sparkle
		LDA #$17 : STA !Ex_Data1,x		; timer
		LDA !P2XPosLo-$80,y			;\
		CLC : ADC $00				; |
		STA !Ex_XLo,x				; | Xpos
		LDA !P2XPosHi-$80,y			; |
		ADC $01					; |
		STA !Ex_XHi,x				;/
		LDA !P2YPosLo-$80,y			;\
		CLC : ADC $02				; |
		STA !Ex_YLo,x				; | Ypos
		LDA !P2YPosHi-$80,y			; |
		ADC $03					; |
		STA !Ex_YHi,x				;/
		RTS


	.UpdateLight
		LDA !GlobalLightMix					;\
		CMP !GlobalLightMixPrev : BNE ..update			; | see if there was a change this frame
		RTS							;/
		..update
		STZ $2250						; prepare multiplication
		REP #$20						;\
		LDA !GlobalLight1					; |
		AND #$00FF						; |
		ASL A							; |
		STA $00							; |
		ASL A							; | RGB values of light 1
		ADC $00							; |
		TAX							; |
		LDA.w LightValues+0,x : STA $04				; |
		LDA.w LightValues+2,x : STA $06				; |
		LDA.w LightValues+4,x : STA $08				;/
		LDA !GlobalLight2					;\
		AND #$00FF						; |
		ASL A							; |
		STA $00							; |
		ASL A							; | RGB values of light 2
		ADC $00							; |
		TAX							; |
		LDA.w LightValues+0,x : STA $0A				; |
		LDA.w LightValues+2,x : STA $0C				; |
		LDA.w LightValues+4,x : STA $0E				;/
		LDA !GlobalLightMix					;\
		AND #$00FF						; |
		CMP #$0021						; | (min 0x00, max 0x20)
		BCC $03 : LDA #$0020					; | strength of lights 1 and 2
		STA $02							; |
		LDA #$0020						; |
		SEC : SBC $02						; |
		STA $00							;/
		STA $2251						;\
		LDA $04 : STA $2253					; |
		NOP : BRA $00						; |
		LDA $2306 : STA $04					; |
		LDA $06 : STA $2253					; |
		NOP : BRA $00						; | update light 1
		LDA $2306 : STA $06					; |
		LDA $08 : STA $2253					; |
		LDA #$0020						; |
		SEC : SBC $00						; |
		STA $02							; |
		LDA $2306 : STA $08					;/
		LDA $02 : STA $2251					;\
		LDA $0A : STA $2253					; |
		NOP							; |
		LDA $04							; |
		CLC : ADC $2306						; |
		LSR #5							; |
		STA !LightR						; |
		LDA $0C : STA $2253					; |
		NOP							; |
		LDA $06							; | update light 2, merge with light 1, then update light RGB values
		CLC : ADC $2306						; |
		LSR #5							; |
		STA !LightG						; |
		LDA $0E : STA $2253					; |
		NOP							; |
		LDA $08							; |
		CLC : ADC $2306						; |
		LSR #5							; |
		STA !LightB						; |
		SEP #$20						;/
		..done
		LDA !GlobalLightMix : STA !GlobalLightMixPrev		; update for next frame
		RTS


	.UpdatePalset
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

		LDA !MsgPal						;\
		AND #$7F						; |
		LSR #4							; |
		STA $0E							; |
		INC A							; |
		STA $0F							; |
		LDA !MsgTrigger						; | mark palsets used by portrait
		ORA !MsgTrigger+1					; |
		BEQ .nomsg						; |
		LDA !WindowDir : BEQ .msg				; |
		.nomsg							; |
		LDA #$FF						; |
		STA $0E							; |
		STA $0F							; |
		.msg							;/

		LDX !PalsetStart					;\
	-	CPX $0E : BEQ +						; |
		CPX $0F : BEQ +						; |
		LDA !Palset8,x						; |
		AND #$7F						; |
		CMP PalsetDefaults,x : BEQ +				; |
		LDA $00,x : BNE +					; |
		PHX							; |
		LDA #$00 : XBA						; > clear B
		LDA !Palset8,x						; | if palset is non-default AND unused, unload it
		AND #$7F						; | (unless it is used by msg portraits)
		TAX							; |
		LDA #$00 : STA !Palset_status,x				; |
		PLX							; |
		LDA #$80 : STA !Palset8,x				; |
	+	DEX							; |
		CPX #$02 : BCS -					;/

		LDY !PalsetStart					; loop through all sprite palsets
		REP #$10
	.loop	LDA !Palset8,y : BMI .next				; if already loaded, go to next			
		STA $00 : STZ $01					; $00 = palset to load
		XBA : LDA #$00						;\ clear B
		XBA							;/
		TAX							;\
		ORA #$80						; | mark palset as loaded
		STA !Palset8,y						; |
		TYA : STA !Palset_status,x				;/

		TYX							;\ disable this for 1 operation
		LDA #$01 : STA !ShaderRowDisable+8,x			;/

		JSR UpdatePalset					; get color data

	.next	DEY : BPL .loop						; loop
		RTS


;==============;
;PALETTE LOADER;
;==============;
;	input:
;	A:		sprite palset to load
LoadPalset:
		PHB : PHK : PLB
		PHX							; push X
		STA $0F							; store palset to load in $0F
		TAX							;\ if palset is already loaded, return
		LDA !Palset_status,x : BNE .Return			;/
		.PortraitColors						;\
		LDA #$FF						; |
		STA $00							; |
		STA $01							; |
		LDA $400000+!MsgPortrait : BEQ ..done			; |
		LDA !MsgPal						; | don't let portrait colors be overwritten
		LSR #4							; |
		AND #$07						; |
		STA $00							; |
		INC A : STA $01						; |
		..done							;/

		LDX !PalsetStart					;\
	-	CPX $00 : BEQ +
		CPX $01 : BEQ +
		LDA !Palset8,x						; |
		CMP #$80 : BEQ +					; |
		AND #$7F						; | if palset is about to be loaded this frame, return
		CMP $0F : BEQ .Return					; | (probably not necessary, just in case there's an error somewhere)
	+	DEX : BPL -						;/
		PLX							; pull X
		LDY !PalsetStart					;\
	.Loop	LDA !Palset8,y						; |
		CMP #$80 : BEQ .Load					; | look for a free row in A-F
	.Next	DEY							; |
		CPY #$02 : BCS .Loop					;/
		PLB
		RTL							; if none are found, return

	.Load	LDA $0F : STA $00					;\
		STZ $01							; | set palset to load here
		ORA #$80						; |
		STA !Palset8,y						;/
		PHX							;\
		XBA : LDA #$00						;\ clear B
		XBA							;/
		AND #$7F						; |
		TAX							; | mark palset as loaded
		TYA : STA !Palset_status,x				; |
		LDA $0F : PHA						; |
		TYX							;\ disable this for 1 operation
		LDA #$01 : STA !ShaderRowDisable+8,x			;/
		JSR UpdatePalset					; > update
		PLA : STA $0F						; |
	.Return	PLX							;/
		PLB
		RTL							; return


UpdatePalset:
		REP #$30
		STY $08								;\
		JSL !GetCGRAM							; | get CGRAM table index
		TYX								;/

		LDY $08								;\
		LDA $00								; |
		XBA								; | address for palset
		LSR #3								; |
		CLC : ADC.w #!PalsetData+2					;/
		STA $00								; also copy palette to RAM mirror
		LDA.w #!PalsetData>>16 : STA $02				;\
		PHX								; |
		PHY								; |
		TYA								; |
		ORA #$0008							; | set up pointer or whatever
		ASL #4								; | (ORA #$0008 is for targeting palettes 8-F)
		INC A								; |
		ASL A								; |
		TAX								; |
		STA $04								;/
		LDA #$0080 : TSB !ProcessLight					; SA-1 currently writing to !PaletteRGB
		LDY #$0000							; index
		LDA #$0100							;\
		CMP !LightR : BNE .PreShade					; | see if preshading is required
		CMP !LightG : BNE .PreShade					; |
		CMP !LightB : BNE .PreShade					;/

	.Raw
	-	LDA [$00],y
		STA !PaletteRGB,x						;\
		STA !ShaderInput,x						; |
		INX #2								; | update palette in RAM
		INY #2								; |
		CPY #$001E : BCC -						;/ > loop
		LDA #$0080 : TRB !ProcessLight					; SA-1 no longer writing to !PaletteRGB
		PLY								;\
		PLX								; | source address
		LDA $04								; |
		CLC : ADC.w #!PaletteRGB					;/
		STA !VRAMbase+!CGRAMtable+$02,x					; store source address
		LDA #$001E : STA !VRAMbase+!CGRAMtable+$00,x			; upload size
		SEP #$30							; A 8-bit
		LDA.b #!PaletteRGB>>16 : STA !VRAMbase+!CGRAMtable+$04,x	; source bank
		TYA								;\
		ORA #$08							; |
		ASL #4								; | dest CGRAM
		INC A								; |
		STA !VRAMbase+!CGRAMtable+$05,x					;/
		RTS								; return

	.PreShade
		PEI ($04)							; preserve
		STZ $2250							; multiplication
		LDA !LightR : STA $04						;\
		LDA !LightG : STA $06						; | DP speedup
		LDA !LightB : STA $08						;/
	-	LDA [$00],y : STA $0E						; > get source color
		STA !ShaderInput,x						; > shader input
		AND #$001F							;\
		STA $2251							; |
		LDA $04 : STA $2253						; |
		NOP : BRA $00							; | shade R
		LDA $2307							; |
		CMP #$0020							; |
		BCC $03 : LDA #$001F						; |
		STA $0A								;/
		LDA $0E								;\
		LSR #5								; |
		STA $0E								; |
		AND #$001F							; |
		STA $2251							; |
		LDA $06 : STA $2253						; | shade G
		NOP : BRA $00							; |
		LDA $2307							; |
		CMP #$0020							; |
		BCC $03 : LDA #$001F						; |
		STA $0C								;/
		LDA $0E								;\
		LSR #5								; |
		AND #$001F							; |
		STA $2251							; |
		LDA $08 : STA $2253						; | shade B
		NOP : BRA $00							; |
		LDA $2307							; |
		CMP #$0020							; |
		BCC $03 : LDA #$001F						;/
		ASL #5								;\
		ORA $0C								; |
		ASL #5								; |
		ORA $0A								; | assemble color and write to palette
		STA !PaletteRGB,x						; |
		STA !PaletteBuffer,x						; |
		INX #2								; |
		INY #2								; |
		CPY #$001E : BCS $03 : JMP -					;/ > loop

		LDA #$0080 : TRB !ProcessLight					; SA-1 no longer writing to !PaletteRGB
		PLA								;\ > pull from $04
		PLY								; | source address
		PLX								; |
		CLC : ADC.w #!PaletteBuffer					;/
		STA !VRAMbase+!CGRAMtable+$02,x					; store source address
		LDA #$001E : STA !VRAMbase+!CGRAMtable+$00,x			; upload size
		SEP #$30							; A 8-bit
		LDA.b #!PaletteBuffer>>16 : STA !VRAMbase+!CGRAMtable+$04,x	; source bank
		TYA								;\
		ORA #$08							; |
		ASL #4								; | dest CGRAM
		INC A								; |
		STA !VRAMbase+!CGRAMtable+$05,x					;/
		RTS								; return



macro CameraBox(X, Y, W, H, S, FX, FY)
	dw <X>*$100
	dw <Y>*$E0
	dw (<X>+<W>)*$100
	dw (<Y>+<H>)*$E0
	dw <S>|(<FX><<6)|(<FY><<11)
endmacro

macro Door(x, y)
	db <x>|(<y><<4)
endmacro


incsrc "level_data/TimeLimits.asm"
incsrc "level_data/LevelLightPoints.asm"
incsrc "level_data/CameraBox.asm"


print "Realm 5 code inserted at $", pc, "."
incsrc "level_code/Realm5.asm"

print "Realm 6 code inserted at $", pc, "."
incsrc "level_code/Realm6.asm"

print "Realm 7 code inserted at $", pc, "."
incsrc "level_code/Realm7.asm"

print "Realm 8 code inserted at $", pc, "."
incsrc "level_code/Realm8.asm"


print "Bank $18 level code ends at $", pc, "."

org $198000
db $53,$54,$41,$52
dw $FFF7
dw $0008

print "Unsorted code inserted at $", pc, "."
incsrc "level_code/Unsorted.asm"


print "Bank $19 code ends at $", pc, "."


org $1C8000
db $53,$54,$41,$52
dw $FFF7
dw $0008

print "Realm 1 code inserted at $", pc, "."
incsrc "level_code/Realm1.asm"

print "Realm 2 code inserted at $", pc, "."
incsrc "level_code/Realm2.asm"

print "Realm 3 code inserted at $", pc, "."
incsrc "level_code/Realm3.asm"

print "Realm 4 code inserted at $", pc, "."
incsrc "level_code/Realm4.asm"

print "Bank $1C code ends at $", pc, "."
print " "


