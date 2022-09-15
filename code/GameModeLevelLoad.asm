



	incsrc "LevelGFXIndex.asm"



	GAMEMODE_11:
		STZ $4200					; no interrupts
		STZ $15
		STZ $16
		STZ $17
		STZ $18

		STZ !PSwitchTimer
		STZ !SilverPTimer
		STZ !StarTimer


		; keep these for now
		LDX #$23
	-	STZ $70,x
		DEX : BNE -
		LDX #$37
	-	STZ $73D9,x
		DEX : BNE -
		STZ $749A
		STZ $7498
		STZ $7495
		STZ $7419

		JSL LOAD_LEVEL
		LDA [$65]					;\
		AND #$1F					; | slightly scuffed since this will be repeated
		INC A						; | but camera needs this value
		STA !LevelWidth					;/


		.PlayerCoords
		REP #$20
		LDA !MarioXPosLo
		STA !P2XPosLo-$80
		STA !P2XPosLo
		LDA !MarioYPosLo
		CLC : ADC #$0010
		LDX !P2Pipe-$80
		BNE $03 : STA !P2YPosLo-$80
		LDX !P2Pipe : BNE ..done
		STA !P2YPosLo
		LDA !MultiPlayer
		AND #$00FF : BEQ ..done
		LDA $741A
		AND #$00FF : BNE ..done
		LDA !P2XPosLo
		SEC : SBC #$0008
		STA !P2XPosLo
		CLC : ADC #$0010
		STA !P2XPosLo-$80
		..done
		SEP #$30

		; the rest is initialized during gamemode 12


; conundrum:
; - DecompressBackground needs DP from LOAD_LEVEL and coordinates from Camera_Init
; - GFX_Loader can only be run after gamemode 11 finisher
; - GFXIndex needs to run after GFX_Loader
; - DecompressBackground needs to run after GFXIndex

		PEI ($00)
		PEI ($02)
		PEI ($04)
		PEI ($06)
		PEI ($08)
		PEI ($0A)
		PEI ($0C)
		PEI ($0E)

		REP #$20
		LDA $1A
		STA $7462
		STA !CameraBackupX
		LDA $1C
		STA $7464
		STA !CameraBackupY
		LDA $1E : STA $7466
		LDA $20 : STA $7468
		SEP #$20
		JSL Camera_Init

		REP #$20
		PLA : STA $0E
		PLA : STA $0C
		PLA : STA $0A
		PLA : STA $08
		PLA : STA $06
		PLA : STA $04
		PLA : STA $02
		PLA : STA $00

		JSL DecompressBackground			; decompress background tilemaps

		INC !GameMode

		; go to end of gamemode 11, modified a lot by lunar magic
		PHK : PEA.w .Return-1
		PEA.w $A59B-1
		LDY #$01 : JML $00A6CC
		.Return

	; flow into gamemode 12


	GAMEMODE_12:
		PHB : PHK : PLB
		STZ $4200
		LDA #$80 : STA $2100
		STZ !2100						; brightness = 0
		STZ !HDMA						;\
		STZ $1F0C						; | kill HDMA
		STZ $420C						;/

		LDA #$FF : STA $2126					;\ destroy window 1
		STZ $2127						;/
		LDA #$02 : STA !2130					;\ default color math settings
		LDA #$20 : STA !2131					;/
		LDA #$22
		STA !2123
		STA !2124
		STA !2125


		JSL GFX_Loader_Main					; load GFX
		JSL $0EF570						; Lunar magic custom palette routine

		; - 9FB8 -
		LDA !HeaderTileset
		ASL A
		CLC : ADC !HeaderTileset
		STA $00
		; - A012 -
		INC $73D5

		; - A5F9 -
		LDA #$E7 : TRB $14
	-	JSL read3($00A5FD+1)					; LUNAR MAGIC ROUTINE: sets up exanimation data (this routine is also found at $00A2A5)
		REP #$20
		STZ $6D7C
		STZ $6D7E
		STZ $6D80
		SEP #$20
		JSL read3($00A390+1)					; LUNAR MAGIC ROUTINE: uploads exanimation data
		INC $14
		LDA $14
		AND #$07 : BNE -


		; - 922F -
		STZ !PaletteRGB+0					;\ color 0 default = 0000 (black)
		STZ !PaletteRGB+1					;/
		STZ $4314						; bank = 00
		LDA #$02						; A = DMA bit
		REP #$10						; index 16-bit
		STZ $2102						;\
		LDX #$0400 : STX $4310					; |
		LDX.w #!OAM : STX $4312					; | RAM !OAM -> PPU OAM
		LDX #$0220 : STX $4315					; |
		STA $420B						;/

		; - 9F29 -
		LDA #$01 : STA $6DB1

		REP #$30
		LDA !2132_RGB : STA !Color0


	; INIT_Level

		SEP #$30

		STZ !PlayerWaiting					; clear wait flags

		STZ !Cutscene						; kill cutscene
		STZ !CutsceneSmoothness					; kill effect
		STZ !CutsceneWait					; kill timer
		STZ !Cutscene6DA2					;\
		STZ !Cutscene6DA3					; |
		STZ !Cutscene6DA4					; |
		STZ !Cutscene6DA5					; | kill cutscene input
		STZ !Cutscene6DA6					; |
		STZ !Cutscene6DA7					; |
		STZ !Cutscene6DA8					; |
		STZ !Cutscene6DA9					;/


		LDA !SRAM_Difficulty : STA !Difficulty_full		;\ difficulty settings from SRAM buffer
		AND #$03 : STA !Difficulty				;/

		LDA #$07 : STA !PalsetStart				; default: all palset rows are dynamic
		STZ !SpriteEraseMode					; default: erase mode 0, normal off-screen check enabled

		LDA #$00
		STA !LockBox						; disable camera box lock
		STA !PauseThif						; unpause Thif
		STA !LevelInitFlag					; set level INIT
		STA !3DWater						; disable 3D water
		STA !DizzyEffect					; disable dizzy effect
		LDA #$FF : STA !CameraBoxU+1				; disable camera box

		LDA.b #.SA1 : STA $3180					;\
		LDA.b #.SA1>>8 : STA $3181				; | run SA-1 portion
		LDA.b #.SA1>>16 : STA $3182				; |
		JSR $1E80						;/

		REP #$30						; all regs 16-bit
		LDA !Level						;\
		ASL A : ADC !Level					; | load pointer based on level number
		TAX							; | x3
		LDA LevelInitPtr,x : STA $0000				; |
		LDA LevelInitPtr+1,x : STA $0001			;/

		.LoadLightPoints					;\
		STZ !LightPointIndex					; |
		LDX #$0000						; |
		LDY !Level						; |
		..loop							; |
		TYA							; |
		CMP LevelData_LightPoints+$C,x : BNE ..next		; |
		LDY !LightPointIndex					; |
		CPY #$006C : BCS ..fail					; |
		LDA LevelData_LightPoints+$0,x : STA !LightPointX,y	; |
		LDA LevelData_LightPoints+$2,x : STA !LightPointY,y	; |
		LDA LevelData_LightPoints+$4,x : STA !LightPointR,y	; | search for and load light points belonging to this level
		LDA LevelData_LightPoints+$6,x : STA !LightPointG,y	; |
		LDA LevelData_LightPoints+$8,x : STA !LightPointB,y	; |
		LDA LevelData_LightPoints+$A,x : STA !LightPointS,y	; |
		TYA							; |
		CLC : ADC #$000C					; |
		STA !LightPointIndex					; |
		..fail							; |
		LDY !Level						; |
		..next							; |
		TXA							; |
		CLC : ADC #$000E					; |
		TAX							; |
		CPX.w #LevelData_LightPoints_end-LevelData_LightPoints : BCC ..loop



		STZ !Level+2						;\ clear extra bytes
		STZ !Level+4						;/
		STZ !GlobalLight1					;\ reset auto light mixer
		STZ !GlobalLightMix					;/
		STZ !Color0						; clear color 0
		LDA #$0000						; > set up clear
		STA !HDMAptr+0						;\ clear HDMA pointer
		STA !HDMAptr+1						;/
		SEP #$10						; > index 8 bit

		LDX #$0E						;\
	-	LDA !PaletteRGB+2,x : STA $00A0,x			; | store this palette in SNES WRAM
		DEX #2 : BPL -						;/

		LDA #$0100						;\
		STA !LightR						; | default lighting
		STA !LightG						; |
		STA !LightB						;/
		LDA #$0002 : STA !LightIndexStart			;\ default: shade all colors except background
		STZ !LightIndexEnd					;/
		STZ !LightList+$0					;\
		STZ !LightList+$2					; |
		STZ !LightList+$4					; |
		STZ !LightList+$6					; | default setting is to include all colors in SNES shader
		LDA #$0101 : STA !LightList+$8				; | except for player palettes!
		STZ !LightList+$A					; |
		STZ !LightList+$C					; |
		STZ !LightList+$E					;/

		LDA #$8000 : STA $4300					;\
		LDA.w #!PaletteRGB : STA $4302				; |
		STZ $4304						; |
		LDA #$0200 : STA $4305					; |
		STZ $2182						; | initialize light buffers
		LDA.w #!LightData_SNES : STA $2181			; |
		LDX #$01 : STX $420B					; |
		LDA.w #!PaletteRGB : STA $4302				; |
		LDA #$0200 : STA $4305					; |
		STX $420B						;/
		LDX #$02 : STX !ProcessLight				; stop light from running first frame


	; to use alt player palettes, just add an offset here
		REP #$30
		LDA !Characters
		LSR #4
		AND #$000F
		INC A
		STA !Palset8
		LDY #$0000
		XBA
		LSR #3
		TAX
	-	LDA.l !PalsetData-$20,x : STA !PaletteRGB+($80*2),y
		INX #2
		INY #2
		CPY #$0020 : BCC -
		LDA !Characters
		AND #$000F
		INC A
		STA !Palset9
		LDY #$0000
		XBA
		LSR #3
		TAX
	-	LDA.l !PalsetData-$20,x : STA !PaletteRGB+($90*2),y
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

		.PlayerPipe
		STZ !P2Entrance				;\ reset pipe timers
		STZ !P2Entrance-$80			;/
		LDA !MarioAnim				;\
		STZ !MarioAnim				; | pipe check (+clear)
		BEQ ..done				; |
		CMP #$07 : BNE ..normalpipe		;/
		..slantpipe				;\
		LDA #$30				; |
		STA !P2SlantPipe			; | slant pipe
		STA !P2SlantPipe-$80			; |
		BRA ..done				;/
		..normalpipe				;\
		LDA $89					; |
		AND #$03				; |
		CLC : ROR #3				; | get PCE pipe timer
		ORA #$0F				; |
		STA !P2Pipe				; |
		STA !P2Pipe-$80				;/
		REP #$20				;\
		BPL ..y					; |
		..x					; |
		LDA $94					; | init PCE X coord (vertical pipe only)
		ORA #$0008				; |
		STA !P2XPosLo				; |
		STA !P2XPosLo-$80			;/
		..y					;\
		LDA $96					; |
		CLC : ADC #$000E			; | init PCE Y coord
		STA !P2YPosLo				; |
		STA !P2YPosLo-$80			;/
		..done
		SEP #$20

		.InitMainLevel
		LDA $741A : BNE ..sublevel		; how many doors have been entered
		LDA #$FF				;\
		STA !HeldItemP1_num			; |
		STA !HeldItemP1_level+1			; | reset held items when going into a new level
		STA !HeldItemP2_num			; |
		STA !HeldItemP2_level+1			;/
		LDX #$7F				;\
	-	STZ !TranslevelFlags,x			; | clear translevel flags on first sublevel only
		DEX : BPL -				;/

		STZ !P2TempHP-$80			;\ clear temp HP
		STZ !P2TempHP				;/
		REP #$20				;\
		LDA !Translevel				; |
		ASL A					; |
		TAX					; | init time limit (on first sublevel only)
		LDA.l LevelData_TimeLimits,x		; |
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
		BRA ..megadone
		..megalevel
		STZ !StatusX
		LDX #$1F
	-	LDA .StatusProp_megalevel,x : STA !StatusProp,x
		DEX : BPL -
		..megadone
		LDX #$0E
	-	LDA .StatusBarColors,x : STA !StatusBarColors,x
		DEX : BPL -
		JSL StatusBar				; status bar


		LDA #$0F
		STA !P2HP-$80
		STA !P2HP
		BRA ..done

		..sublevel				;/
		LDA !P2HP-$80
		CLC : ADC !P2TempHP-$80
		STA !P2ShowHP-$80
		LDA !P2HP
		CLC : ADC !P2TempHP
		STA !P2ShowHP
		..done


		LDX #$18					;\
		LDA #$00					; | make sure these regs are wiped
	-	STA.l !VineDestroy,x				; |
		DEX : BPL -					;/


		LDA.b #InitSpriteEngine : STA $3180		;\
		LDA.b #InitSpriteEngine>>8 : STA $3181		; | have sa-1 init sprite engine
		LDA.b #InitSpriteEngine>>16 : STA $3182		; | (sprites need to spawn before level init pointer code is run)
		JSR $1E80					;/

		LDA #$A1 : STA !MsgPal				; default portrait palettes are A-B
		LDA #$18 : STA !TextPal				; default text palette (colors 0x19 and 0x1B)
		LDA #$08 : STA !BorderPal			; default border palette = red
		PHB
		LDA $0002
		PHA : PLB
		PHK : PEA.w .Return-1				; set return address
		JML [$0000]					; execute level init pointer
		.Return
		PLB
		SEP #$30					; all regs 8-bit
		LDA.b #Camera_BG : STA $3180			;\
		LDA.b #Camera_BG>>8 : STA $3181			; | initialize BG2/BG3 positions
		LDA.b #Camera_BG>>16 : STA $3182		; |
		JSR $1E80					;/
		JSL Camera_ExecutePtr				; HDMA pointer


		REP #$30					;\
		LDA $20						; |
		SEC : SBC #$0008				; | initialize BG2 zip column position
		STA !BG2ZipColumnY				; |
		SEP #$30					;/
		JSL $05809E					; init BG2 tilemap


		LDA !MarioDirection : PHA			;\
		LDA !P2Direction-$80 : PHA			; | preserve player directions
		LDA !P2Direction : PHA				;/

		LDA $741A
		ORA !P2Pipe-$80
		ORA !P2Pipe
		BNE +
		LDA !P2Entrance-$80 : BPL ++
		LDA #$10 : STA !P2Stasis			; delay P2
		DEC !MarioYPosHi
		DEC !P2YPosHi-$80
		DEC !P2YPosHi
		BRA +
		++
		LDA #$3F : STA !P2Entrance-$80
		LDA #$4F : STA !P2Entrance
		+


		; init sprite engine used to go here



; ID = 0xFF	-> not native to this level

		.SpawnHeldItems
		LDA !HeldItemP1_num
		CMP #$FF : BEQ ..p1done
		LDX #$0F
	-	LDA !SpriteStatus,x : BEQ ..thisp1
		DEX : BPL -
		JMP ..p2done
		..thisp1
		LDA #$40 : TSB !P2ExtraInput1-$80
		LDA !HeldItemP1_num : STA !SpriteNum,x
		LDA !HeldItemP1_extra : STA !ExtraBits,x
		JSL !ResetSprite
		LDA #$0B : STA !SpriteStatus,x
		LDA !HeldItemP1_prop1 : STA !ExtraProp1,x
		LDA !HeldItemP1_prop2 : STA !ExtraProp2,x
		LDA !HeldItemP1_ID : STA !SpriteID,x
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
	-	LDA !SpriteStatus,x : BEQ ..thisp2
		DEX : BPL -
		BRA ..p2done
		..thisp2
		LDA #$40 : TSB !P2ExtraInput1
		LDA !HeldItemP2_num : STA !SpriteNum,x
		LDA !HeldItemP2_extra : STA !ExtraBits,x
		JSL !ResetSprite
		LDA #$0B : STA !SpriteStatus,x
		LDA !HeldItemP2_prop1 : STA !ExtraProp1,x
		LDA !HeldItemP2_prop2 : STA !ExtraProp2,x
		LDA !HeldItemP1_ID : STA !SpriteID,x
		LDA !P2XPosLo : STA !SpriteXLo,x
		LDA !P2XPosHi : STA !SpriteXHi,x
		LDA !P2YPosLo : STA !SpriteYLo,x
		LDA !P2YPosHi : STA !SpriteYHi,x
		INX : STX !P2Carry
		..p2done
		LDA #$FF : STA !HeldItemP2_num



		LDA.b #PCE : STA $3180				;\
		LDA.b #PCE>>8 : STA $3181			; | run PCE
		LDA.b #PCE>>16 : STA $3182			; |
		JSR $1E80					;/
		PLA : STA !P2Direction				;\
		PLA : STA !P2Direction-$80			; | restore player directions
		PLA : STA !MarioDirection			;/

		LDA.b #GAMEMODE_14_CallLight : STA $3180	;\
		LDA.b #GAMEMODE_14_CallLight>>8 : STA $3181	; | run this in case global light was set
		LDA.b #GAMEMODE_14_CallLight>>16 : STA $3182	; |
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
		SEP #$20					; | have sa-1 preshade palette and dump it in !PaletteBuffer
		LDA.b #.PreShade>>16 : STA $3182		; |
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
		LDA #$2202 : STA $4300				; |
		LDA.w #!PaletteRGB : STA $4302			; | if light is all 100%, just upload !PaletteRGB -> CGRAM
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

		; call to 919B


		INC !GameMode
		LDA #$81					;\
	-	BIT $4212 : BMI - : BVS -			; | wait for no blanks, then enable NMI + auto joypad
		STA $4200					;/
		JSL KillOAM
		PLB
		RTL






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
		PHB						;/

		REP #$30
		LDX #$01BE					;\
		LDA #$00FF					; | reset windowing table
	-	STA $64A0,x					; |
		DEX #2 : BPL -					;/
		SEP #$30					;
		LDX #$03					;\
	-	STZ $15,x					; |
		STZ $6DA2,x					; | clear input regs
		STZ $6DA6,x					; |
		DEX : BPL -					;/

		REP #$20					; A 16-bit
		LDX !Translevel					;\ set mega level ID
		LDA.l LevelData_MegaLevelID,x : STA !MegaLevelID	;/

		SEP #$30					; all regs 8-bit
		LDA.b #LevelData_YoshiCoins>>16 : PHA : PLB	; bank = yoshi coin data bank
		STZ !PlayerBonusHP				; reset bonus HP

		REP #$20					; A 16-bit
		LDA !Translevel					;\ unless level = 0, despawn collected yoshi coins
		AND #$00FF : BEQ ..yoshicoindone		;/
		TAX						;\
		STA $0E						; |
		ASL #2 : ADC $0E				; | *25
		STA $0E						; |
		ASL #2 : ADC $0E				; |
		TAY						;/
		LDA !LevelTable1,x : STA $00			;\
		JSR .DestroyCoin				; |
		JSR .DestroyCoin				; | despawn collected yoshi coins
		JSR .DestroyCoin				; |
		JSR .DestroyCoin				; |
		JSR .DestroyCoin				;/
		LDA !MegaLevelID				;\ check for mega level
		AND #$00FF : BEQ ..yoshicoindone		;/
		TAX						;\
		STA $0E						; |
		ASL #2 : ADC $0E				; | *25
		STA $0E						; |
		ASL #2 : ADC $0E				; |
		TAY						;/
		LDA !LevelTable1,x : STA $00			;\
		JSR .DestroyCoin				; |
		JSR .DestroyCoin				; | despawn collected yoshi coins
		JSR .DestroyCoin				; |
		JSR .DestroyCoin				; |
		JSR .DestroyCoin				;/
		..yoshicoindone


		%ReloadOAMData()				; reload (wraps reg size)
		REP #$20					; A 16-bit
		STZ !DynamicTile				; clear dynamic data
		LDA !2132_RGB : STA !PaletteRGB+0		; > copy this (so it gets written as HSL)

		LDX #$00					;\
		LDY #$00					; | get HSL format palette
		JSL RGBtoHSL					;/

		SEP #$30					; all regs 8-bit
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


; data format per Yoshi Coin:
; [XX] [xy] [YY] [-s] [sS]
;
; X and Y are expected to be 3-digit hexadecimal numbers (but they can be entered as decimal too)
; they point to the tile coordinates of the coin
; if sublevel number is $FFFF, the Yoshi Coin does not exist
	.DestroyCoin
		LSR $00 : BCC ..return				; if yoshi coin is not collected, return
		LDA LevelData_YoshiCoins+3,y : BMI ..return		; if yoshi coin doesn't exist, return
		AND #$01FF					;\ if yoshi coin is in another level, return
		CMP !Level : BNE ..return			;/
		LDA LevelData_YoshiCoins-1,y			;\ X hi
		AND #$FF00 : STA $9A				;/
		LDA LevelData_YoshiCoins+1,y			;\
		AND #$000F					; | X lo
		ASL #4 : TSB $9A				;/
		LDA LevelData_YoshiCoins+1,y			;\ Y full
		AND #$FFF0 : STA $98				;/
		PEI ($00)					; preserve yoshi coins collected flags
		PHY						;\
		LDA #$0025 : JSL ChangeMap16			; |
		LDA $98						; |
		CLC : ADC #$0010				; | erase yoshi coin (preserving Y)
		STA $98						; |
		LDA #$0025 : JSL ChangeMap16			; |
		PLY						;/
		PLA : STA $00					; restore yoshi coins collected flags
		..return					;\
		TYA						; | update index
		CLC : ADC #$0005				; |
		TAY						;/
		RTS						; return







;====================;
; LEVEL LOADER EDITS ;
;====================;
; DOCUMENTATION:
; $05D796 - routine start, nothing useful here (checks relating to yoshi wings and bonus game)
; $05D7AB - SPLIT depending on $741A (door counter), goes to $05D83E if 0 or $05D7B3 otherwise
; $05D7B3 - load sublevel (level -> level transition)
; $05D83E - load main level (overworld -> level transition)
; $05D8B1 - lunar magic inserts JSL $05DCD0 here, a routine that is completely useless for me
; $05D8B7 - REJOIN, from here on the 16-bit level number stored in $0E will be loaded

; LUNAR MAGIC DOCUMENTATION:
;	$05D9D7 is where the game checks for the midway flag
;	Lunar Magic inserts the following code at $05DCE0:
;		CMP #$25
;		BCC $03 : SBC #$24 : INY
;		STA $77BB
;		STA $0E
;		TYA
;		RTL
;	As soon as it returns, A is stored to $0F, making $0E hold the 16-bit level number to be loaded.

	pushpc
	org $05D796
	LOAD_LEVEL:
		PHB : PHK : PLB			;\ unchanged
		SEP #$30			;/
		LDA $741A : BNE .LevelToLevel	;\ go straight to this, skipping yoshi and bonus game checks
		JMP .OverworldToLevel		;/

	org $05D7B3
	.LevelToLevel
		; this code is edited by lunar magic

	org $05D83E
	.OverworldToLevel
		LDA $6109
		ORA $7F11 : BNE ..override

		..normal
		LDA !Translevel
		CMP #$25
		BCC $02 : SBC #$24
		STA $0E
		STA $77BB
		STZ $0F : ROL $0F
		JMP .Load

		..override
		LDA $6109
		STA $0E
		STA $77BB
		LDA $7F11 : STA $0F
		JMP .Load


	org $05D8B7
	.Load
		REP #$30			; all regs 16-bit
		LDA $0E : STA !Level		; write level
		TAX				; X = level
		ASL A : ADC $0E			; Y = level x3
		TAY				;\
		LDA $E000,y : STA $65		; |
		LDA $E001,y : STA $66		; | get BG1 and BG2 pointers
		LDA $E600,y : STA $68		; |
		LDA $E601,y : STA $69		;/
		JML .LoadVRAMMap
	warnpc $05D8E0
	org $05D8E0				; execute the rest of the code here
		.ReturnVRAMMap

	org $058566
		BIT $00 : BPL +			;\
		LDA #$08 : TSB !2105		; | layer 3 priority bit (only applies in mode 1)
		BRA +				;/
	warnpc $058572
	org $058572
		+

	org $05808F				; patch out broken sprite init code
		PLP				;\ org: SEP #$30
		RTL				;/

	; level load code, controls which level is loaded (can be changed if a checkpoint is loaded from the overworld)
	org $05D9D7
		JSL .CheckCheckpoint		;\ org: LDA !LevelTable1,x : AND #$40
		NOP				;/
	org $05DCE7
		JML .LoadCheckpoint		;\ org: STA $77BB : STA $0E (inserted by Lunar Magic)
		NOP				;/

	pullpc

	; 2107: BG1 tilemap control
	; 2108: BG2 tilemap control
	; 2109: BG3 tilemap control
	; 210A: BG4 tilemap control (currently unused)
	; 210B: BG1/BG2 GFX control (always 0)
	; 210C: BG3/BG4 GFX control
	.LoadVRAMMap
		PHP
		REP #$30
		LDA.l LevelData_VRAM_map,x
		AND #$00FF
		STA !VRAMmap
		CMP #$0001 : BEQ ..map01
		CMP #$0002 : BNE ..map00

	..map02
		LDA #$4000 : STA !BG1Address		;\  VRAM map 02:
		LDA #$4800 : STA !BG2Address		; | - 0x0000: 32KB of 4bpp GFX for layer 1/2
		SEP #$30				; | - 0x4000: layer 1 tilemap (64x32)
		LDA #$41 : STA !2107			; | - 0x4800: layer 2 tilemap (64x32)
		LDA #$49 : STA !2108			; | - 0x5000: used by status bar
		LDA #$59 : STA !2109			; | - 0x5800: displacement map (64x32)
		LDA #$05 : STA !210C			;/
		LDA #$02 : BRA ..setmode		; mode = 2

	..map01
		LDA #$4000 : STA !BG1Address		;\  VRAM map 01:
		LDA #$4800 : STA !BG2Address		; | - 0x0000: 32KB of 4bpp GFX for layer 1/2
		SEP #$30				; | - 0x4000: layer 1 tilemap (64x32)
		LDA #$41 : STA !2107			; | - 0x4800: layer 2 tilemap (64x32)
		LDA #$49 : STA !2108			; | - 0x5000: 4KB of 2bpp GFX for layer 3
		LDA #$59 : STA !2109			; | - 0x5800: layer 3 tilemap (64x32 or 32x64)
		LDA #$05 : STA !210C			;/
		BRA ..setmode1

	..map00
		LDA #$3000 : STA !BG1Address		;\  VRAM map 00:
		LDA #$3800 : STA !BG2Address		; | - 0x0000: 24KB of 2bpp GFX for layer 1/2
		SEP #$30				; | - 0x3000: layer 1 tilemap (64x32)
		LDA #$31 : STA !2107			; | - 0x3800: layer 2 tilemap (64x32)
		LDA #$39 : STA !2108			; | - 0x4000: 8KB of 2bpp GFX for layer 3
		LDA #$53 : STA !2109			; | - 0x5000: layer 3 tilemap (64x64)
		LDA #$04 : STA !210C			;/
		..setmode1				;\ mode = 1 (layer 3 prio might be set later)
		LDA #$01				;/
		..setmode				;\ write mode
		STA !2105				;/

		..done
		PLP
		JML .ReturnVRAMMap


	.LoadCheckpoint
		STA $77BB
		STA $0E
		TYA : STA $0F
		PHX
		PHP
		SEP #$10
		LDA !LoadCheckpoint : BEQ ..return
		LDX !Translevel
		BIT !LevelTable1,x : BVC ..return	; check checkpoint flag
		LDA !LevelTable2,x : STA $0E		;\
		LDA !LevelTable1,x			; |
		AND #$20				; | get level number
		BEQ $02 : LDA #$01			; |
		TAY					;/
		..return
		PLP
		PLX
		RTL

	.CheckCheckpoint
		LDA !LoadCheckpoint : BEQ ..return
		LDA !LevelTable1,x
		AND #$40
		..return
		RTL






;=====================;
; OBJECT LOADER EDITS ;
;=====================;
OBJECT_LOADER:
	pushpc

	; object loader code, controls if the checkpoint spawns or not
	org $0DA691
		JSL .SpawnCheckpoint			; org: LDA.l !LevelTable1,x
	org $0DA699
		BRA $03 : NOP #3			; org: LDA $73CE : BNE $12


	; modify some blocks to use item mem
	org $0DA5C5
		CPX #$1B : BEQ .VariableBlock
		JSL LOAD_ITEM_MEM_CheckItem : BNE .CheckMem
		BRA .WriteMap16
	warnpc $0DA5D9

	org $0DA5D9 : .VariableBlock

	org $0DA5F0 : .CheckMem

	org $0DA5F4					; ?-block, brick, other similar blocks code
		JSL LOAD_ITEM_MEM			;\ org: LDX $73BE (!HeaderItemMem) : LDA #$F8 : CLC
		BRA +					;/
	org $0DA635 : +

	org $0DA648 : .WriteMap16

	org $0DA8E0					; normal coins code
		JSL LOAD_ITEM_MEM			;\ org: LDX $73BE (!HeaderItemMem) : LDA #$F8 : CLC
		BRA +					;/
	org $0DA920 : +

	org $0DB2E0					; yoshi coins code: always spawn yoshi coins
		STZ $0F					;\ org: LDX $73BE (!HeaderItemMem) : LDA #$F8 : CLC
		LDA #$00 : BRA +			;/
	org $0DB320 : +


	pullpc




; object loader codes

	.SpawnCheckpoint
		LDA.l !LevelTable1,x
		AND #$40 : BEQ ..return
		LDA.l !LoadCheckpoint : BEQ ..return
		PEI ($00)
		LDA.l !LevelTable2,x : STA $00
		LDA.l !LevelTable1,x
		AND #$20
		BEQ $02 : LDA #$01
		STA $01
		REP #$20
		LDA.l !Level
		CMP $00 : BEQ ..despawn
		..spawn
		PLA : STA $00
		SEP #$20
		LDA #$00
		..return
		RTL
		..despawn
		PLA : STA $00
		SEP #$20
		LDA #$40
		RTL		


; input:
;	Y = X offset
;	$57 = combined X+Y position, lo byte (yyyyxxxx)
;	$6B = map16 page pointer
; output:
;	A = memory bit (0 if not marked)
;	Z = 0 if not marked, 1 if marked
;	$08 = index to item memory table (16-bit), only if valid index
;	$0E = index (lowest 7 bits)
;	$0F = result of bit check (8-bit)

; NOTE: the !LevelWidth variable is NOT how many screens there can be in this mode, just how many are used
;	this is NOT a problem, future!Eric
;	it just means less of the table is used, but everything will still be mapped properly

; calculations:
; xlo	= $57 & $0F
; ylo	= $57 & $F0
; xhi	= $6B - $C800 / level height
; yhi	= rest / $100

	LOAD_ITEM_MEM:
		REP #$20
		LDA #$0001 : STA $2250			; prep division
		LDA $6B
		SEC : SBC #$C800
		STA $2251
		LDA !LevelHeight : STA $2253
		SEP #$20
		BRA $00					;

		LDA $2306 : STA $9B			; x hi
		LDA $2309 : STA $99			; y hi

		LDA !HeaderItemMem			;\ check memory setting
		CMP #$03 : BCC .Search			;/
		LDA #$00 : STA $0F			;\ return null if invalid
		RTL					;/

		.Search
		PHX					; push X
		STA $08					; $08 = index (will be converted to 00 or 80)
		LSR A					;\ $09 = -------I
		STA $09					;/
		STZ $2250				;\
		REP #$20				; |
		LDA $99					; | y screen * level width
		AND #$00FF : STA $2251			; |
		LDA !LevelWidth				; |
		AND #$00FF : STA $2253			;/
		SEP #$20				;\
		LDA $9B					; | + x screen
		CLC : ADC $2306				;/
		ASL A					; * 2
		ASL A					;\
		LSR $08					; | get highest bit from index
		ROR A					; |
		STA $08					;/
		TYA					;\
		AND #$08				; | +1 on right half (iSSSSSSx)
		BEQ $02 : INC $08			;/
		LDA $08					;\ output 7 lowest bits of index
		AND #$7F : STA $0E			;/
		TYA					;\
		AND #$07 : TAX				; | get bit (reverse order because of course it is)
		LDA.l .Bits,x				;/
		REP #$10				;\
		LDX $08					; | read item memory bit
		AND !ItemMem0,x				; |
		SEP #$10				;/
		STA $0F					; store to output

		PLX					; pull X
		CMP #$00				; z
		RTL					; return

		.Bits
		db $80,$40,$20,$10,$08,$04,$02,$01

	.CheckItem
		LDA.l .ExtendedItemMem,x
		RTL

		.ExtendedItemMem
		db $00		; 10 - small door
		db $01		; 11 - invisible 1-up block
		db $00		; 12 - invisible note block
		db $00		; 13 - UNKNOWN
		db $00		; 14 - UNKNOWN
		db $00		; 15 - small invisible POW door
		db $01		; 16 - invisible POW ?-block
		db $01		; 17 - green star block
		db $00		; 18 - moon
		db $00		; 19 - invisible 1-up point #1
		db $00		; 1A - invisible 1-up point #2
		db $00		; 1B - invisible 1-up point #3
		db $00		; 1C - invisible 1-up point #4
		db $00		; 1D - red berry
		db $00		; 1E - pink berry
		db $00		; 1F - green berry
		db $00		; 20 - UNUSED (constantly turning turn block)
		db $01		; 21 - UNKNOWN
		db $00		; 22 - UNKNOWN
		db $00		; 23 - note block with variable item inside
		db $00		; 24 - ON/OFF block
		db $01		; 25 - directional coin ?-block
		db $00		; 26 - note block
		db $00		; 27 - note block
		db $01		; 28 - brick with flower
		db $01		; 29 - brick with feather
		db $01		; 2A - brick with star
		db $01		; 2B - brick with variable item
		db $01		; 2C - brick with multiple coins
		db $00		; 2D - brick with 1 coin
		db $01		; 2E - brick with nothing inside
		db $01		; 2F - brick with POW inside
		db $01		; 30 - ?-block with flower
		db $01		; 31 - ?-block with feather
		db $01		; 32 - ?-block with star
		db $01		; 33 - ?-block with star 2
		db $01		; 34 - ?-block with multiple coins
		db $01		; 35 - ?-block with variable item (key/wing/balloon/shell)
		db $01		; 36 - ?-block with yoshi/1-up
		db $01		; 37 - ?-block with green shell
		db $01		; 38 - ?-block with green shell
		db $00		; 39 - jank brick
		db $00		; 3A - UNKNOWN
		db $00		; 3B - UNKNOWN
		db $00		; 3C - UNKNOWN
		db $00		; 3D - UNKNOWN
		db $00		; 3E - UNKNOWN
		db $00		; 3F - UNKNOWN
		db $01		; 40 - translucent block
		; other extended objects do not run this code




