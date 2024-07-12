
; all things considered...
;	the easiest way to do this should be to feed this routine a single word as input
;	the word determines which entrance to load
;	!LevelEntry format:
;	FM-SsssL llllllll
;	F	secondary entrance flag
;	M	midway entrance flag
;	S	secondary entrance num highest bit (only used if F is set)
;	s	secondary entrance num extra bits (only used if F is set)
;	L	level num hi bit
;	l	level num lo byte

; if F is clear, we are loading a main or midway entrance
; when loading a secondary entrance, S sss L llllllll are all used together as the index
;	(to enter secondary entrance, value = num|$8000)

; ROM entrance data is:
;	level num (if secondary entrance)
;	player position
;	player action
;	player facing
;	foreground / background position
;	water level flag
;	ice level flag




; structure is acceleration-based
; it's really a single thread, but as much as possible is moved to SA-1 side
;
; SNES 1
;	- turn off PPU interrupts
;	- kill OAM
;	- reset windowing regs (PPU side)
;
; SA1 1
;	CLEAR RAM
;	- clear various RAM addresses
;	READ HEADERS
;	- read and apply level headers
;	- set up level data pointers
;	- load raw RGB palette into RAM
;	- load VRAM map
;	- apply entrance settings and spawn players
;
; SNES 2
;	- get LM animation setting (kind of a header thing, but has to be read on SNES side)
;	- call object loader (mostly runs on SA-1 side but has to be called from SNES)
;	- call GFX loader (can run now that sprite pointer and map16 are both loaded)
;
; SA1 2
;	COLORS
;	- load light points
;	- apply initial shader settings
;	- load initial player palettes
;	TRANSLEVEL
;	- apply time limit setting
;	- apply mega level settings
;	- initialize yoshi coins
;
; SNES 3
;	- reset HDMA modules (SNES side)
;	- initialize camera (SNES side)
;
; SA1 3
;	- initialize camera (SA-1 side)
;	- initialize sprite engine
;
; SNES 4
;	- RUN LEVEL INIT CODE
;	- run HDMA pointer
;	- run HDMA modules
;
; SA1 4
;	- light auto-mixer
;	- run Camera_BG once
;	- calculate !BG2BaseV
;
; SNES 5
;	- execute HDMA pointer if there is one
;	- init BG2 zips
;	- init exanimation
;	- run initial shading operation (could be run in parallel with next SA1 thread to save 2-3 frames of load time)
;
; SA1 5
;	- apply player entrance animations
;	- initialize players (PCE)
;
; SNES 6
;	- initialize status bar
;	- upload palette to CGRAM
;	- generate and upload initial tilemaps




; TODO:
; TO DO:
; - replace object loader and reformat map16 (LAST priority)






;==================================================================
;
;	START OF SNES THREAD
;
;==================================================================


	LOAD_LEVEL:
	;===============;
	; SNES THREAD 1 ;
	;===============;
		SEP #$30					; all regs 8-bit
		STZ $4200					; no PPU interrupts
	-	BIT $4212 : BPL -				; wait for v-blank
		STZ $420C					;\
		STZ !HDMA					; | clear HDMA
		STZ !420C					;/
		LDA #$80 : STA $2100				; f-blank
		JSL KillOAM					; clear OAM
		STZ $210B					; BG1 chr address = 0x0000, BG2 chr address = 0x0000
		LDA #$22					;\
		STA $2123 : STA !2123				; | default windowing settings
		STA $2124 : STA !2124				; | (enable window 1, uninverted, on all layers)
		STA $2125 : STA !2125				;/
		LDA #$FF					;\
		STA $2126					; |
		STZ $2127					; | destroy windows (255-0)
		STA $2128					; |
		STZ $2129					;/
		STZ $212A					;\ window clipping settings (OR)
		STZ $212B					;/
		STZ $212C					;\
		STZ $212D					; | disable main/sub
		STZ $212E					; |
		STZ $212F					;/
		LDA #$02 : STA $2130 : STA !2130		; color addition select
		LDA #$20 : STA $2131 : STA !2131		; color math designation
		PHB						;\
		LDA #$05					; | set bank
		PHA : PLB					;/
		LDA.b #LevelInitRAM : STA $3180			;\
		LDA.b #LevelInitRAM>>8 : STA $3181		; | SA-1 thread 1: wipe RAM
		LDA.b #LevelInitRAM>>16 : STA $3182		; |
		JSR $1E80					;/
		LDA.b #ReadLevelHeaders : STA $3180		;\
		LDA.b #ReadLevelHeaders>>8 : STA $3181		; | SA-1 thread 1: handle headers
		LDA.b #ReadLevelHeaders>>16 : STA $3182		; | !BigRAM = static BG2 coord
		JSR $1E80					;/



	;===============;
	; SNES THREAD 2 ;
	;===============;
		REP #$10					; index 16-bit
		LDX !BigRAM : PHX				; push this value since it might be shredded
		LDX !Level : STX !LevelToBeat			;\> default level to beat
		LDA $03FE00,x : STA $7FC00A			; | get LM animation setting
		SEP #$10					;/
		STZ $7928					; this has to be cleared before call
		JSL $0583B5					; get LM to parse object data (must be called on SNES side)
		JSL GFX_Loader					; handles static GFX, pseudo-dynamic, and super-dynamic
		LDA.b #InitColors : STA $3180			;\
		LDA.b #InitColors>>8 : STA $3181		; | SA-1 thread 2: initialize light engine
		LDA.b #InitColors>>16 : STA $3182		; |
		JSR $1E80					;/
		LDA.b #InitTranslevel : STA $3180		;\
		LDA.b #InitTranslevel>>8 : STA $3181		; | SA-1 thread 2: load translevel settings
		LDA.b #InitTranslevel>>16 : STA $3182		; | (also despawns collected yoshi coins)
		JSR $1E80					;/



	;===============;
	; SNES THREAD 3 ;
	;===============;
	; these are the default HDMA locations
	; they can be overwritten by level .Init
	.InitHDMA
		LDX #$5F					;\
	-	STZ !HDMA2source,x				; | clear all HDMA modules variables
		DEX : BPL -					;/
		LDA #$04 : STA !HDMA2bit			;\
		LDA #$08 : STA !HDMA3bit			; |
		LDA #$10 : STA !HDMA4bit			; | set channel bits
		LDA #$20 : STA !HDMA5bit			; |
		LDA #$40 : STA !HDMA6bit			; |
		LDA #$80 : STA !HDMA7bit			;/
		REP #$20					; A 16-bit
		LDA.w #$200 : STA !HDMA2location		;\ channel 2: 0x200-0x3BF (448 bytes, generally reserved for message box)
		LDA.w #$E0 : STA !HDMA2size			;/
		LDA.w #$3C0 : STA !HDMA3location		;\ channel 3: 0x3C0-0x3FF (64 bytes)
		LDA.w #$20 : STA !HDMA3size			;/
		LDA.w #$400 : STA !HDMA4location		;\ channel 4: 0x400-0x4FF (256 bytes)
		LDA.w #$80 : STA !HDMA4size			;/
		LDA.w #$500 : STA !HDMA5location		;\ channel 5: 0x500-0x5FF (256 bytes)
		LDA.w #$80 : STA !HDMA5size			;/
		LDA.w #$600 : STA !HDMA6location		;\ channel 6: 0x600-0x7FF (512 bytes)
		LDA.w #$100 : STA !HDMA6size			;/
		LDA.w #$800 : STA !HDMA7location		;\ channel 7: 0x800-0xFFF (1024 bytes)
		LDA.w #$400 : STA !HDMA7size			;/

		LDA $1A						;\
		STA $7462					; |
		STA !CameraBackupX				; |
		LDA $1C						; |
		STA $7464					; | init camera
		STA !CameraBackupY				; |
		LDA $1E : STA $7466				; |
		LDA $20 : STA $7468				; |
		STZ !BG2BaseV					;/> initialize to 0 for BG2Controller
		LDA.w #Camera_Init : STA $3180			;\
		LDA.w #Camera_Init>>8 : STA $3181		; | SA-1 thread 3: camera init
		SEP #$30					; |
		JSR $1E80					;/
		JSL Camera					;> move camera once
		STZ !SpriteEraseMode				; default: erase mode 0, normal off-screen check enabled
		LDA.b #InitSpriteEngine : STA $3180		;\
		LDA.b #InitSpriteEngine>>8 : STA $3181		; | SA-1 thread 3: initialize sprite engine
		LDA.b #InitSpriteEngine>>16 : STA $3182		; | (old comment says that sprites need to spawn before level init pointer code is run)
		JSR $1E80					;/



	;===============;
	; SNES THREAD 4 ;
	;===============;
	; level .Init is able to:
	; - overwrite HDMA modules
	; - overwrite palette by writing to !PaletteRGB
	;	(writing to mirror at $00A0 has no effect)
	; - directly move the camera by writing to !CameraPrevX/!CameraPrevY + $1A/$1C
	; - call HDMA code by writing to !HDMAptr, which will run after the HDMA modules
	; - set lighting, which will run before the palette is uploaded

	.InitLevelCode
		REP #$30					; all regs 16-bit
		LDA !Level					;\
		ASL A : ADC !Level				; |
		TAX						; | check for main level pointer
		LDA.l LevelPtr,x : BEQ .InitCutsceneModule	; |
		STA $00						;/
		PHB						;\
		SEP #$20					; | wrap to level pointer bank
		LDA.l LevelPtr+2,x : PHA : PLB			;/
		STA $00+2					; bank byte of pointer

		.Modules
		REP #$20					;\
		LDY #$0004					; | check for HDMA modules
		LDA ($00),y : BEQ ..done			;/
		..load						;\
		TAY						; |
		LDX #$0000					; |
		CLC						; > no overflow should occur
		..loop						; |
		LDA $0000,y : STA !HDMA2module,x		; |
		LDA $0001,y : STA !HDMA2module+1,x		; | if there are any, load them
		INY #3						; |
		TXA						; |
		ADC #$0010					; |
		TAX						; |
		CPX #$0060 : BCC ..loop				; |
		..done						;/

		.ExecuteInit
		LDA ($00) : BEQ ..return			;\ check for init routine
		STA $00						;/
		PHK : PEA.w ..return-1				;\
		SEP #$30					; | if there is one, execute it
		JML [$3000]					; |
		..return					;/
		PLB						; restore bank


	.InitCutsceneModule
		SEP #$10
		REP #$20
		LDX #$00
		..loop						;\
		LDY !HDMA2module+2,x				; |
		CPY.b #CutsceneSmoothness>>16 : BNE ..next	; |
		LDA !HDMA2module,x				; |
		CMP.w #CutsceneSmoothness : BEQ ..done		; | if cutscene module is already loaded, end
		..next						; |
		TXA						; |
		CLC : ADC #$0010				; |
		TAX						; |
		CPX #$60 : BCC ..loop				;/
		LDX #$10					;\> start at 0x10, because cutscene is not allowed in slot 2
		..loop2						; |
		LDA !HDMA2module,x : BNE ..next2		; |
		LDA.w #CutsceneSmoothness : STA !HDMA2module,x	; |
		LDA.w #CutsceneSmoothness>>8 : STA !HDMA2module+1,x
		BRA ..done					; | if cutscene module is not loaded, slot it into a free module slot
		..next2						; |
		TXA						; |
		CLC : ADC #$0010				; |
		TAX						; |
		CPX #$60 : BCC ..loop2				;/
		..done


		SEP #$30					; all regs 8-bit
		LDA #$01 : STA !LevelMainFlag			; next is .Main

	.InitLightMixer
		LDA !GlobalLight1 : BNE ..run			;\ skip if no auto light mix has been selected
		LDA !GlobalLight2 : BEQ ..done			;/
		..run						;\
		LDA.b #GAMEMODE_14_CallLight : STA $3180	; |
		LDA.b #GAMEMODE_14_CallLight>>8 : STA $3181	; | SA-1 thread 4: auto-light mixer
		LDA.b #GAMEMODE_14_CallLight>>16 : STA $3182	; |
		JSR $1E80					; |
		..done						;/

	.InitBG2
		LDA.b #Camera_BG : STA $3180			;\
		LDA.b #Camera_BG>>8 : STA $3181			; | SA-1 thread 4: run BG camera
		LDA.b #Camera_BG>>16 : STA $3182		; |
		JSR $1E80					;/

		; BG2 position is now determined

		REP #$20					;\
		PLA : STA !BigRAM				; | this is needed if static coord is used
		SEP #$20					;/
		LDA.b #CalcBG2BaseV : STA $3180			;\
		LDA.b #CalcBG2BaseV>>8 : STA $3181		; | SA-1 thread 4: calculate BG2 base V
		LDA.b #CalcBG2BaseV>>16 : STA $3182		; |
		JSR $1E80					;/




	;===============;
	; SNES THREAD 5 ;
	;===============;
	.HDMAptr
		REP #$20					;\
		LDA.l !HDMAptr+0 : BEQ ..done			; |
		STA $00						; |
		LDA.l !HDMAptr+1 : STA $00+1			; | execute HDMA code
		PHB						; |
		LDY $00+2 : PHY : PLB				; > wrap bank
		PHK : PEA ..return-1				; |
		JML [$3000]					;/
		..return					;\
		PLB						; > restore bank
		REP #$20					; |
		LDA #$0000 : STA.l !HDMAptr			; | clear pointer
		SEP #$10					; > return index 8-bit
		..done						;/


	.ProcessModules
		PHB						; bank wrapper start
		SEP #$10					; index 8-bit
		REP #$20					; A 16-bit
		LDA $1A : STA $311A				;\
		LDA $1C : STA $311C				; |
		LDA $1E : STA $311E				; | mirror layer positions
		LDA $20 : STA $3120				; |
		LDA $22 : STA $3122				; |
		LDA $24 : STA $3124				;/
		LDX #$00					; loop from 0
		..loop						;\
		LDA !HDMA2module,x : BEQ ..next			; | get module address
		STA $00						; |
		LDY !HDMA2module+2,x : STY $00+2		;/
		PHY : PLB					; bank switch
		LDA !HDMA2bit,x					;\
		AND #$00FF : TSB !HDMA				; > channel bit
		LDA [$00] : STA $4320,x				; > channel settings
		LDY #$02					; |
		LDA [$00],y : BEQ ..next			; |
		STA $0000					; | execute code pointer
		LDY #$03					; | (note that 16-bit $0000 goes in SNES WRAM so there's no conflict here)
		LDA [$00],y : STA $0000+1			; |
		LDA #$00E0 : STA $3100+!HDMA_MaxY		; > reset max Y
		PHK : PEA.w ..return-1				; |
		JML [$0000]					;/
		..return					;\
		SEP #$30					; | always set init after running a module
		LDA #$01 : STA !HDMA2init,x			; |
		REP #$20					;/
		..next						;\
		TXA						; |
		CLC : ADC #$0010				; | loop
		TAX						; |
		CPX #$60 : BCC ..loop				;/
		PLB						; bank wrapper end


	.InitZips
		LDA $1E						;\
		CLC : ADC #$0080				; |
		STA !BG2ZipRowX					; |
		STA !BG2ZipColumnX				; | place all BG2 zips in the middle of the screen
		LDA $20						; |
		CLC : ADC #$0070				; |
		STA !BG2ZipRowY					; |
		STA !BG2ZipColumnY				;/


	.InitExAnim
		LDA !Level					;\
		INC A : STA $FE					; | LM needs $FE = level+1
		SEP #$20					;/
		JSL read3($0583AD+1)				; LUNAR MAGIC ROUTINE: initializes exanimation
; $C000	24-bit pointer to level exanim data
; $C003
; $C004
; $C005
; $C006	24-bit pointer related to layer 3
; $C009	related to layer 3
; $C00A	LM animation settings
; $C00B
; $C00C	16-bit, number of level exanim slots used?
; $C00E	16-bit, number of global exanim slots used?
; $C010	24-bit pointer from $03BCC0, purpose?
; $C013
; $C016	24-bit pointer to global exanim data
; $C019	starts at 0xFF
; $C01A
; $C01B
; $C01C


; $C020-$C02F	used during decompression code


; $C060-$C06F	conditional map16
; $C070-$C07F	exanim triggers (manual)
; $C080-$C09F	level exanim frame counters
; $C0A0-$C0BF	global exanim frame counters
; $C0C0-$C0F7	exanim dynamo data
; $C0F8-$C0FD	exanim triggers (one shot)
; $C0FE-$C0FF	exanim triggers (custom)



		LDA #$E7 : TRB $14				;\
	-	JSL read3($00A5FD+1)				; > LUNAR MAGIC ROUTINE: sets up exanimation data (this routine is also found at $00A2A5)
		REP #$20					; |
		STZ $6D7C					; |
		STZ $6D7E					; |
		STZ $6D80					; | initialize exanimation
		SEP #$20					; |
		JSL read3($00A390+1)				; > LUNAR MAGIC ROUTINE: uploads exanimation data
		INC $14						; |
		LDA $14						; |
		AND #$07 : BNE -				;/


	.InitialShading
		REP #$20					; A 16-bit
		LDX #$0E					;\
	-	LDA !PaletteRGB+2,x : STA $00A0,x		; | store this palette in SNES WRAM
		DEX #2 : BPL -					;/

		LDX.b #!LightData_SNES>>16&1 : STX $2183	; WRAM bank
		LDX #$01					; DMA bit
		LDA #$8000 : STA $4300				;\
		LDA.w #!PaletteRGB : STA $4302			; |
		STZ $4304					; |
		LDA #$0200 : STA $4305				; |
		LDA.w #!LightData_SNES : STA $2181		; | initialize SNES side light buffers
		STX $420B					; |
		LDA.w #!PaletteRGB : STA $4302			; |
		LDA #$0200 : STA $4305				; |
		STX $420B					;/
		PHB						;\
		REP #$30					; |
		LDX.w #!PaletteRGB				; |
		LDY.w #!ShaderInput				; | copy RGB palette to shader input
		LDA.w #$01FF					; |
		MVN !ShaderInput>>16,$00			; |
		PLB						;/

		SEP #$30					; all regs 8-bit
		STZ !LightBuffer				;\ start new shading op
		STZ !ProcessLight				;/

		LDA.b #InitPlayers : STA $3180			;\
		LDA.b #InitPlayers>>8 : STA $3181		; |
		LDA.b #InitPlayers>>16 : STA $3182		; | end of SNES thread 5 runs in parallel with SA-1 thread 5
		LDA #$80 : STA $2200				; |
		JSR.w MPU_Light					;/


	;===============;
	; SNES THREAD 6 ;
	;===============;
		PHK : PLB					; B = K

	.UploadPalette
		REP #$20					;\
		LDA #$2202 : STA $4300				; |
		LDA #$0200 : STA $4305				; |
		LDA.w #!LightData_SNES : STA $4302		; | shaded palette -> CGRAM
		SEP #$20					; |
		LDA.b #!LightData_SNES>>16 : STA $4304		; |
		STZ $2121					; |
		LDA #$01 : STA $420B				;/

	.StatusBar
		LDA !DoorCounter : BNE ..done			;\
		LDA !MegaLevelID : BNE ..megalevel		; |
		..normallevel					; |
		LDA #$FC : STA !StatusX				; |
		LDX #$1F					; |
	-	LDA .StatusProp_normal,x : STA !StatusProp,x	; |
		DEX : BPL -					; |
		BRA ..megadone					; |
		..megalevel					; | initialize status bar, but only on first sublevel
		STZ !StatusX					; |
		LDX #$1F					; |
	-	LDA .StatusProp_mega,x : STA !StatusProp,x	; |
		DEX : BPL -					; |
		..megadone					; |
		LDX #$0E					; |
	-	LDA .StatusBarColors,x : STA !StatusBarColors,x	; |
		DEX : BPL -					; |
		JSL StatusBar					; |
		..done						;/

	.InitialTilemaps
		JSL GetInitialTilemaps

	.Music
		LDA !GameMode
		CMP #$07 : BCC +
		LDA !MusicBackup : STA !SPC3
		+

	.Return
		PLB
		RTL

;==================================================================
;
;	END OF SNES THREAD
;
;==================================================================




	.StatusProp
		..mega
		db $20,$20,$20,$20,$20				; P1 coins
		db $20,$20,$20,$20,$20,$20			; P1 hearts
		db $20,$20,$20,$20,$20				;\ Yoshi coins
		db $20,$20,$20,$20,$20				;/
		db $64,$64,$64,$64,$64,$64			; P2 hearts
		db $24,$24,$24,$24,$24				; P2 coins
		..normal
		db $20,$20,$20,$20,$20				; P1 coins
		db $20,$20,$20,$20,$20,$20			; P1 hearts
		db $20,$20,$20,$20,$20				;\ Yoshi coins
		db $20,$20,$20,$20,$20				;/
		db $64,$64,$64,$64,$64				; P2 hearts
		db $24,$24,$24,$24,$24,$24			; P2 coins

	.StatusBarColors
		incbin "../PaletteData/StatusBar.mw3":2-10







;==================================================================
;
;	START OF SA-1 THREAD
;
;==================================================================



	;===============;
	; SA-1 THREAD 1 ;
	;===============;
	LevelInitRAM:
		PHB : PHK : PLB
		PHP

		; mem clear: windowing + input
		REP #$30
		LDX #$01BE					;\
		LDA #$00FF					; | reset windowing table
	-	STA $64A0,x					; |
		DEX #2 : BPL -					;/

		LDX #$0279					;\
	-	STZ $7693,x					; | clear $7693-$790D
		DEX #2 : BPL -					;/

		STZ $15						;\
		STZ $17						; |
		STZ $6DA2					; | clear input regs
		STZ $6DA4					; |
		STZ $6DA6					; |
		STZ $6DA8					;/

		; clear border exit regs
		STZ !UpExitLimitL
		STZ !UpExitLimitR
		STZ !LeftExitLimitU
		STZ !LeftExitLimitD
		STZ !RightExitLimitU
		STZ !RightExitLimitD
		STZ !DownExitLimitL
		STZ !DownExitLimitR
		STZ !UpExitOverride
		STZ !LeftExitOverride
		STZ !RightExitOverride
		STZ !DownExitOverride
		STZ !HardBoxBorders-1


		; mem: RAM code parameters
		STZ !RAMcode_flag				;\ make sure this can't carry over from previous mode
		STZ !RAMcode_offset				;/

		; mem: reload OAM data
		%ReloadOAMData()				; reload (wraps reg size)

		; mem: dynamic tile
		STZ !DynamicTile				; clear dynamic data

		; mem: MSG
		STZ !MsgTrigger					; clear message

		; mem: cutscene data
		SEP #$30					; all regs 8-bit
		STZ !PlayerWaiting				; clear wait flags
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

		; mem: default anim toggle settings
		LDA #$70 : STA !AnimToggle			; everything allowed, max 4KB

		; mem: difficulty settings
		LDA !SRAM_Difficulty : STA !Difficulty_full	;\ difficulty settings from SRAM buffer
		AND #$03 : STA !Difficulty			;/

		; mem: fusion sprites
		LDX.b #!Ex_Amount-1
	-	STZ !Ex_Num,x
		STZ !PProjectile_List,x
		DEX : BPL -
		STZ !PProjectile_Index

		; mem: misc flags (long addressing)
		LDA #$00
		STA !LockBox					; disable camera box lock
		STA !PauseThif					; unpause Thif
		STA !LevelMainFlag				; set level INIT
		STA !3DWater					; disable 3D water
		STA !DizzyEffect				; disable dizzy effect
		STA !HDMAptr+0					;\
		STA !HDMAptr+1					; | clear HDMA pointer
		STA !HDMAptr+2					;/
		STA !LevelMainFlag				; start by running INIT

		LDA #$FF : STA !CameraBoxU+1			; disable camera box


		; note that the following bank 0x40 and bank 0x41 modules have to run in this order

		; mem default: MSG
		LDA #$41 : PHA					; push bank 0x41
		LDA #$40					;\ switch to bank 0x40
		PHA : PLB					;/
		LDA #$A1 : STA !MsgPal				; default portrait palettes are A-B
		LDA #$18 : STA !TextPal				; default text palette (colors 0x19 and 0x1B)
		LDA #$08 : STA !BorderPal			; default border palette = red
		STZ.w !MsgVertOffset				; clear !MsgVertOffset
		REP #$30					; all regs 16-bit
		LDA #$7EB0 : STA $400000+!MsgVRAM3		; default border tiles are $1EB-$1EF, $1FB-$1FF
		LDA #$7C00 : STA $400000+!MsgVRAM1		;\ default portrait tiles are $1C0-$1DF
		LDA #$7C80 : STA $400000+!MsgVRAM2		;/
		LDX #$01FE					;\
		LDA #$8001					; | reset NPC talk tables (all level message 1)
	-	STA.w !NPC_Talk,x				; | (also set cap to the same thing)
		STA.w !NPC_TalkCap,x				; |
		DEX #2 : BPL -					;/

		; mem clear: VR3, 3D cluster, particles, BG objects
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

		PLP
		PLB
		RTL


; output: !BigRAM = static BG2 coord (if there is one)
	ReadLevelHeaders:
	.SetBank
		PHB
		PHP
		SEP #$20
		LDA #$05
		PHA : PLB

	.GetEntrance
		REP #$30					;\ read level entry word
		LDA !LevelEntry : BPL ..mainmid			;/
		JMP ..secondaryentrance				; secondary entrance clause
		..mainmid					;\
		AND #$01FF : STA $0E				; | check main/mid
		BIT !LevelEntry : BVS ..midwayentrance		;/

		..mainentrance					;\
		SEP #$20					; | main entrance screen number
		LDX $0E						; |
		LDA $F600,x					;/
		AND #$1F : STA $01				; $01 = X hi
		..basicentrance
		LDA $F200,x					;\
		AND #$07 : STA $00				; |
		LDA $DE00,x					; | $00 = X lo
		AND #$08 : ORA $00				; | (one more bit can be used on vertical levels)
		ASL #4 : STA $00				;/
		LDA $F000,x					;\ $02 = Y lo
		ASL #4 : STA $02				;/
		LDA $06FC00,x					;\ $03 = Y hi
		AND #$3F : STA $03				;/
		LDA $F200,x					;\
		LSR #3						; | $04 = player action
		AND #$07 : STA $04				;/
		LDA $06FE00,x					;\ $05 = player facing
		AND #$40 : STA $05				;/
		LDA $06FC00,x					;\
		AND #$40					; |
		LSR #2 : STA $06				; | $06 = camera offsets
		LDA $F400,x					; |
		AND #$0F : TSB $06				;/
		LDA $06FE00,x					;\ $07 = camera auto-coord
		AND #$80 : STA $07				;/
		LDA $DE00,x					;\ $08 = ice + water flags
		AND #$C0 : STA $08				;/
		JMP .HandleEntranceData


		..midwayentrance
		LDX $0E						; X = sublevel number

		LDA $D9E4 : STA $F0				;\
		SEP #$20					; | read3($05D9E4)
		LDA $D9E4+2 : STA $F0+2				;/

		LDY #$000C					;\
		LDA [$F0],y					; |
		STA $E0+2					; | bank bytes of midway entrance pointers
		STA $E3+2					; |
		STA $E6+2					; |
		STA $E9+2					;/

		REP #$21					; +CLC
		LDY #$000A					;\ read3(read3($05D9E4)+$0A)
		LDA [$F0],y					;/
		ADC $0E						; first midway entrance byte is at pointer + level
		STA $E0						; [$E0] = midway entrance byte 1
		ADC #$0200 : STA $E3				; [$E3] = midway entrance byte 2
		ADC #$0200 : STA $E6				; [$E6] = midway entrance byte 3
		ADC #$0200 : STA $E9				; [$E9] = midway entrance byte 4
		SEP #$20

		LDA [$E0]					;\
		AND #$10 : STA $01				; | $01 = X hi
		LDA $F400,x					; |
		LSR #4 : TSB $01				;/
		LDA [$E0]					;\ see if midway uses separate settings
		BIT #$20 : BNE ..separatemidway			;/
		JMP ..basicentrance
		..separatemidway
		LDA [$E3]					;\ $00 = X lo
		ASL #4 : STA $00				;/
		LDA [$E3]					;\ $02 = Y lo
		AND #$F0 : STA $02				;/
		LDA [$E9]					;\ $03 = Y hi
		AND #$3F : STA $03				;/
		LDA [$E0]					;\ $04 = player action
		AND #$07 : STA $04				;/
		LDA [$E6]					;\ $05 = player facing
		AND #$40 : STA $05				;/
		LDA [$E9]					;\
		AND #$40					; |
		LSR #2 : STA $06				; | $06 = camera offsets
		LDA [$E6]					; |
		AND #$0F : TSB $06				;/
		LDA [$E6]					;\ $07 = camera auto-coord
		AND #$80 : STA $07				;/
		LDA [$E0]					;\ $08 = ice + water flags
		AND #$C0 : STA $08				;/
		JMP .HandleEntranceData


; secondary entrance:
;	read3($0DE191) -> [$E0]
;		lo byte of level num
;
;	read3($0DE198) -> [$E3]
;		bb	bg Y position setting
;		ff	fg Y position setting
;		yyyy	entrance Y, lo 4 bits
;
;	read3($0DE19F) -> [$E6]
;		xxx	entrance X, lo 3 bits
;		MMMMM	entrance screen number
;
;	read3($05DC81) -> [$E9]
;		I	ice level flag
;		P	flag to use X/Y position method 2
;		XX	entrance X, hi 2 bits
;		N	hi bit of level num
;		AAA	player action
;
;	read3($05DC86) -> [$EC]
;		E	exit to overworld flag
;		F	hi bit of Fffbb if auto-coord is set
;		YYYYYY	entrance Y, hi 6 bits
;
;	read3($05DC8B) -> [$EF]
;		R	auto-coord flag (BG1 Y = entrance coord - 16*Fbbff)
;		L	entrance face left flag
;		W	entrance water level flag
		..secondaryentrance
		AND #$1FFF : TAY
		LDA $0DE191 : STA $E0				;\
		LDA $0DE198 : STA $E3				; |
		LDA $0DE19F : STA $E6				; |
		LDA $05DC81 : STA $E9				; |
		LDA $05DC86 : STA $EC				; |
		LDA $05DC8B : STA $EF				; |
		SEP #$20					; | get 24-bit pointers to secondary entrance data
		LDA $0DE191+2 : STA $E0+2			; |
		LDA $0DE198+2 : STA $E3+2			; |
		LDA $0DE19F+2 : STA $E6+2			; |
		LDA $05DC81+2 : STA $E9+2			; |
		LDA $05DC86+2 : STA $EC+2			; |
		LDA $05DC8B+2 : STA $EF+2			;/

		LDA [$E0],y : STA $0E				;\
		LDA [$E9],y					; |
		AND #$08					; | $0E = secondary entrance level num
		BEQ $02 : LDA #$01				; |
		STA $0F						;/
		LDA [$E6],y					;\
		AND #$E0 : STA $00				; > unshifted
		LDA [$E9],y					; |
		AND #$10					; | $00 = x lo
		CMP #$10					; |
		ROR $00						;/> roll highest bit into place (also rolls lower bits)
		LDA [$E6],y					;\ $01 = X hi
		AND #$1F : STA $01				;/
		LDA [$E3],y					;\ $02 = Y lo
		ASL #4 : STA $02				;/
		LDA [$EC],y					;\ $03 = Y hi
		AND #$3F : STA $03				;/
		LDA [$E9],y					;\ $04 = player action
		AND #$07 : STA $04				;/
		LDA [$EF],y					;\ $05 = player facing
		AND #$40 : STA $05				;/
		LDA [$EC],y					;\
		AND #$40					; |
		LSR #2 : STA $06				; |
		LDA [$E3],y					; |
		ROL #3						; | $06 = camera offsets
		AND #$03 : TSB $06				; |
		LDA [$E3],y					; |
		LSR #2						; |
		AND #$0C : TSB $06				;/
		LDA [$EF],y					;\ $07 = camera auto-coord
		AND #$80 : STA $07				;/
		LDA [$E9],y					;\
		AND #$80 : STA $08				; |
		LDA [$EF],y					; | $08 = ice + water flags
		AND #$20					; |
		ASL A : TSB $08					;/




; input format:
; $00 = X (16-bit coord: ---XXXXX xxxx----)
; $02 = Y (16-bit coord: --YYYYYY yyyy----)
; $04 = player action (-----AAA)
; $05 = player facing (0 = face right, 1+ = face left)
; $06 = camera offsets (---Fffbb, F is only used if auto-coord is set)
; $07 = camera auto-coord (marked by highest bit, rest is unused)
; $08 = ice + water level flags (IW------)
; $0E = level number



	.HandleEntranceData
		SEP #$30					; all regs 8-bit
		LDX.b #!P2Physics-(!P2Basics)-6			;\> keep first 5 bytes of basics
	-	STZ !P2Basics-$80+$05,x				; |
		DEX : BPL -					; | reset player 1
		LDX.b #!P2Base+$80-(!P2Physics)-2		; > keep last byte of custom (temp HP)
	-	STZ !P2Physics-$80,x				; |
		DEX : BPL -					; |
		..p1done					;/

		LDX.b #!P2Physics-(!P2Basics)-6			;\> keep first 5 bytes of basics
	-	STZ !P2Basics+$05,x				; |
		DEX : BPL -					; | reset player 2
		LDX.b #!P2Base+$80-(!P2Physics)-2		; > keep last byte of custom (temp HP)
	-	STZ !P2Physics,x				; |
		DEX : BPL -					; |
		..p2done					;/

		STZ !P2Init-$80					;\ reset PCE init flags
		STZ !P2Init					;/
		STZ !PlayerBonusHP				; reset bonus HP

		REP #$30					; all regs 16-bit
		LDY $0E						; reload level number

		LDA $02						;\
		CLC : ADC #$0010				; |
		STA $96						; | player Y
		STA !P2YPos-$80					; |
		STA !P2YPos					;/

		SEP #$20					; A 8-bit
		LDA $05						;\
		BEQ $02 : LDA #$01				; |
		EOR #$01					; | set player direction
		STA !P2Direction-$80				; | (for players, 0 = left and 1 = right)
		STA !P2Direction				;/

		STZ !IceLevel					;\
		STZ !WaterLevel					; |
		BIT $08 : BPL ..noice				; |
		INC !IceLevel					; | apply ice + water level flags
		..noice						; |
		BIT $08 : BVC ..nowater				; |
		INC !WaterLevel					; |
		..nowater					;/

		LDA $04 : BEQ ..noaction			;\
		CMP #$05 : BEQ ..iceaction			; |
		CMP #$07 : BNE ..nowaterpipe			; |
		..waterpipe					; | check player action
		INC !WaterLevel					; |
		LDA #$04					; |
		..nowaterpipe					; |
		CMP #$06 : BEQ ..slantpipe			;/
		DEC A						;\
		ROR #3						; |
		AND #$C0					; | player pipe reg
		ORA #$10					; |
		STA !P2Pipe-$80					; |
		STA !P2Pipe					;/
		BRA ..pipex					; go to set pipe x position
		..slantpipe					;\
		LDA #$40					; | player slant pipe timer
		STA !P2SlantPipe-$80				; |
		STA !P2SlantPipe				;/
		..pipex						;\
		REP #$30					; |
		LDA $00						; |
		CLC : ADC #$0008				; | player pipe X
		STA $94						; |
		STA !P2XPosLo-$80				; |
		STA !P2XPosLo					;/
		BRA ..actiondone				;/
		..iceaction					;\ special ice action
		INC !IceLevel					;/
		..noaction					;\
		REP #$30					; |
		LDA $00 : STA $94				; |
		SEC : SBC #$0008				; | player X
		STA !P2XPos					; |
		TAX						; > X = x coord
		ADC #$000F					; |
		STA !P2XPos-$80					;/
		LDY !P2Y					; > Y = y coord
		JSL GetMap16					;\
		CMP #$0025 : BEQ ..actiondone			; |
		SEC						; |
		LDA !P2X-$80					; | if player 2 (left side) would be placed inside a wall, move both players half a tile right
		SBC #$0008					; |
		STA !P2X-$80					; |
		SBC #$0008					; |
		STA !P2X					;/
		..actiondone


		LDA $94						;\
		SEC : SBC #$0077				; | BG1 initial X coord
		BPL $03 : LDA #$0000				; |
		STA $1A						;/



		LDA $06 : BPL ..staticcoord			; check for auto-coord
		..autocoord					;\
		AND #$001F					; |
		ASL #4						; |
		CMP #$0100 : BCC +				; | BG1 auto-coord
		ORA #$FE00					; |
	+	CLC : ADC $96					; |
		BPL $03 : LDA #$0000				; |
		STA $1C						;/
		BRA ..coorddone

		..staticcoord
		AND #$000C					;\
		LSR #2 : TAX					; | static BG1 Y coord
		LDA.w $05D708,x					; |
		AND #$00FF : STA $1C				;/
		LDA $06						;\
		AND #$0003 : TAX				; | static BG2 Y coord
		LDA.w $05D70C,x					; |
		AND #$00FF : STA $20				;/
		STA !BigRAM					; output on !BigRAM
		..coorddone



	.GetPointers
		REP #$30
		LDA $0E : STA !Level
		ASL A : ADC $0E
		TAX
		; X = level num * 3

		LDA $0EF600,x : BEQ ..nopalette		;\
		STA $00					; |
		LDA $0EF601,x : STA $01			; |
		LDA [$00] : STA !2132_RGB		; |
		INC $00					; | get raw RGB palette
		INC $00					; |
		LDY #$01FE				; |
	-	LDA [$00],y : STA !PaletteRGB,y		; |
		DEY #2 : BPL -				; |
		LDA !2132_RGB : STA !PaletteRGB+0	; > make sure this is also in the RGB palette
		..nopalette				;/


		; lunar magic uses level * 2 for sprite data pointer
		; bank byte is found at $0EF100, indexed by level * 1

		LDA $E000,x : STA $65			;\ layer 1 data pointer
		LDA $E001,x : STA $65+1			;/
		LDA $E600,x : STA $68			;\ layer 2 data pointer
		LDA $E601,x : STA $68+1			;/

		LDA $0E					;\
		INC A : STA $F0				; | $F0 = level+1
		DEC A					;/
		ASL A : TAX				;\
		LDA $EC00,x : STA $CE			; |
		LDX $0E					; | sprite data pointer
		SEP #$20				; |
		LDA $0EF100,x : STA $CE+2		;/

		LDA [$CE]				;\ new sprite system flag
		AND #$20 : STA !HorzLevelMode		;/
	;	LDA [$CE]				;\ sprite memory is obsolete
	;	AND #$1F : STA $7962			;/
		LDA [$CE]				;\ sprite bouyancy
		AND #$C0 : STA !BuoyancySettings	;/



	.PrimaryHeader

		..byte1
		LDA [$65]				;\
		AND #$1F				; |
		STZ !CameraBoxR				; | effective level width + right border
		STA !CameraBoxR+1			; |
		INC A : STA !LevelWidth			;/
		REP #$20				;\
		AND #$00FF				; |
		XBA					; | clamp camera X
		CMP $1A					; |
		BCS $02 : STA $1A			; |
		LDA #$0000				; > clear B
		SEP #$20				;/


		..byte2
		LDY #$0001				;\
		LDA [$65],y				; | level mode setting
		AND #$1F : STA $7925			;/
		TAX					; X = level mode setting
		LDA $84B7,x : STA $64			;\
		LDA $8437,x : STA !MainScreen		; |
		LDA $8457,x : STA !SubScreen		; | level mode settings
		LDA $8477,x : STA !2131			; |
		LDA $8497,x : STA $6D9B			; |
		LDA $8417,x : STA !RAM_ScreenMode	;/

		..byte3
		INY					;\
		LDA [$65],y				; |
		AND #$80				; | layer 3 priority
		BEQ $02 : LDA #$08			; |
		STA !2105				;/
		LDA [$65],y				;\ sprite tileset
		AND #$0F : STA $792B			;/

		..byte4
		INY					;\ useless (vanilla timer + vanilla FG/BG palette)
	;	LDA [$65],y				;/

		..byte5
		INY					;\
		LDA [$65],y				; | item memory setting
		ROL #3					; |
		AND #$03 : STA !HeaderItemMem		;/
		LDA [$65],y				;\ FG/BG tileset
		AND #$0F : STA !HeaderTileset		;/

		LDA #$01 : STA !EnableHScroll		; default: allow horizontal scrolling
		LDA [$65],y				;\ 0 = no vertical scroll
		AND #$30				;/
		CMP #$30 : BNE +			; 1 or 2 = allow horizontal and vertical scroll
		LDA #$00				;\ 3 = no horizontal or vertical scroll
		STA !EnableHScroll			;/
	+	STA !EnableVScroll			; write

		REP #$30				; all regs 16-bit
		LDA $65					;\
		CLC : ADC #$0005			; | pointer +5
		STA $65					;/




	.ExtraSettings
		LDX $0E					; X = level * 1
		LDA.l LevelData_VRAM_map,x
		AND #$00FF : STA !VRAMmap
		CMP #$0001 : BEQ ..map01
		CMP #$0002 : BNE ..map00

		..map02
		LDA #$0404 : TRB !MainScreen		; wipe BG3 from main and sub
		LDA #$4000 : STA !BG1Address		;\  VRAM map 02:
		LDA #$4800 : STA !BG2Address		; | - 0x0000: 32KB of 4bpp GFX for layer 1/2
		SEP #$20				; | - 0x4000: layer 1 tilemap (64x32)
		LDA #$41 : STA !2107			; | - 0x4800: layer 2 tilemap (64x32)
		LDA #$49 : STA !2108			; | - 0x5000: used by status bar
		LDA #$59 : STA !2109			; | - 0x5800: displacement map (64x32)
		LDA #$05 : STA !210C			;/
		LDA #$02 : BRA ..setmode		; mode = 2

		..map01
		LDA #$4000 : STA !BG1Address		;\  VRAM map 01:
		LDA #$4800 : STA !BG2Address		; | - 0x0000: 32KB of 4bpp GFX for layer 1/2
		SEP #$20				; | - 0x4000: layer 1 tilemap (64x32)
		LDA #$41 : STA !2107			; | - 0x4800: layer 2 tilemap (64x32)
		LDA #$49 : STA !2108			; | - 0x5000: 4KB of 2bpp GFX for layer 3
		LDA #$59 : STA !2109			; | - 0x5800: layer 3 tilemap (64x32 or 32x64)
		LDA #$05 : STA !210C			;/
		BRA ..setmode1

		..map00
		LDA #$3000 : STA !BG1Address		;\  VRAM map 00:
		LDA #$3800 : STA !BG2Address		; | - 0x0000: 24KB of 2bpp GFX for layer 1/2
		SEP #$20				; | - 0x3000: layer 1 tilemap (64x32)
		LDA #$31 : STA !2107			; | - 0x3800: layer 2 tilemap (64x32)
		LDA #$39 : STA !2108			; | - 0x4000: 8KB of 2bpp GFX for layer 3
		LDA #$53 : STA !2109			; | - 0x5000: layer 3 tilemap (64x64)
		LDA #$04 : STA !210C			;/
		..setmode1				;\ mode = 1 (layer 3 prio might be set later)
		LDA #$01				;/
		..setmode				;\ write mode
		TSB !2105				;/ (previously initialized to just 0x08 bit)
		STZ !Mode7Settings			; default: disable mode7

		; exits with 8-bit A and 16-bit index




	.SecondaryHeader
		; assume bank 05
		; byte 1 - $F000
		; byte 2 - $F200
		; byte 3 - $F400
		; byte 4 - $F600
		; byte 5 - $DE00
		; byte 6 - $06FC00
		; byte 7 - $06FE00
		; byte 8 - read3(read3($05D9A2)+$5C)

		; we already handled the entrance so we're only getting the non-entrance data from here
		LDY $0E					; Y = level * 1
		LDA #$00 : XBA				; B = 0x00

		..byte1
		LDA $F000,y				;\
		LSR #4 : TAX				; | BG2 scroll settings
		LDA $D720,x : STA !BG2ModeH		; |
		LDA $D710,x : STA !BG2ModeV		;/

		..byte2
		LDA $F200,y				;\
		ROL #3					; | layer 3 image setting
		AND #$03 : STA $7BE3			;/

		..byte5
		LDA $DE00,y				;\ sprite spawn range
		AND #$03 : STA $6BF4			;/ (smart flag doesn't matter since it's always on)

		..byte6
		TYX					; X = level * 1
		LDA $06FC00,x				;\ "set BG relative to FG" flag
		AND #$80 : STA !BG2Height		;/

		..byte7
		LDA $06FE00,x				;\ BG height
		AND #$1F : TSB !BG2Height		;/ OR BG offset if previous flag is set
		LDA $07					;\
		AND #$80				; | add auto-coord flag to !BG2Height
		LSR A : TSB !BG2Height			;/

		..byte8
		REP #$20				; A 16-bit
		LDA.w $D9A2 : STA $F0			;\ read pointer from LM JSL
		LDA.w $D9A2+1 : STA $F0+1		;/
		LDY #$005B+1				;\
		LDA [$F0],y : STA $00			; | pointer to secondary header byte 8 data stored at +0x5B (+1 since it's an LDA.l)
		INY					; |
		LDA [$F0],y : STA $00+1			;/
		LDY #$0069+1				;\
		LDA [$F0],y : STA $03			; | pointer to level height table stored at +0x69 (+1 since it's an LDA.l)
		INY					; |
		LDA [$F0],y : STA $03+1			;/


		LDA #$0001 : STA $2250			;\ division setup
		LDA #$3800 : STA $2251			;/

		LDY $0E					; Y = level num
		LDA [$00],y				;\ get secondary header byte 8
		AND #$00DF : TSB !HorzLevelMode		;/ 0x20 bit is ignored (taken from sprite header), rest is written to !HorzLevelMode
		AND #$001F				;\ get index to level height table
		ASL A : TAY				;/
		LDA [$03],y				;\
		STA $2253				; | get level height
		STA !LevelHeight			;/
		SEC : SBC #$0010			;\ effective level height for camera if bottom row viewing is disabled
		STA $7936				;/

		BIT !HorzLevelMode-1 : BVC +		;\
		CLC : ADC #$0010			; |
	+	SEC : SBC #$00E0			; | cap initial BG1 Y coord at !LevelHeight
		CMP $1C					; | (taking "show bottom row" into account)
		BCS $02 : STA $1C			;/

		STA !CameraBoxD
		STZ !CameraBoxL

		SEP #$20				; A 8-bit
		LDA $2306				;\
		CMP #$1F				; | calculate map16 width
		BCC $02 : LDA #$1F			; |
		STA !Map16Width				;/

		; also have to set !Map16Width here!
		; the value is highest mapped map16 column (can be different from effective level width)
		; i think it's equal to (0x3800 / !LevelHeight) -1, capped at 0x1F
		; these are the correct values, anyway:
		; mode	num
		; 00	1F
		; 01	1F
		; 02	1D
		; 03	1B
		; 04	19
		; 05	17
		; 06	16
		; 07	15
		; 08	14
		; 09	13
		; 0A	12
		; 0B	11
		; 0C	10
		; 0D	0F
		; 0E	0E
		; 0F	0D
		; 10	0C
		; 11	0B
		; 12	0A
		; 13	09
		; 14	08
		; 15	07
		; 16	06
		; 17	05
		; 18	04
		; 19	03
		; 1A	02
		; 1B	01
		; 1C	00
		; 1D	INVALID
		; 1E	INVALID
		; 1F	INVALID

		; X and Y are shredded here

		LDX #$005D				;\
	-	LDA #$40 : STA $6BF6+2,x		; | bank bytes of dynamic map16 pointers
		LDA #$41 : STA $6C56+2,x		; |
		DEX #3 : BPL -				;/

		REP #$20				;\
		LDA #$C800				; |
		LDX #$0000				; |
		CLC					; |
	-	STA $6BF6,x				; | lo+mid bytes of dynamic map16 pointers
		STA $6C56,x				; |
		ADC !LevelHeight			; |
		INX #3 : BCS +				; |
		CPX #$0060 : BCC -			; |
		+					;/

		BIT !HorzLevelMode-1 : BPL +		; check if layer 2 or 3 uses map16
		CPX #$0060 : BCS +			; check if there is room for layer 2 or 3 to use map16
		TXA					;\
		BIT #$0001 : BEQ ++			; |
		SEC : SBC #$0003			; |
	++	LSR A : TAX				; |
		LDA $6BF6,x				; |
		LDX #$0030				; | lo+mid bytes of dynamic map16 pointers for layer 2/3
	-	STA $6BF6,x				; |
		STA $6C56,x				; |
		ADC !LevelHeight			; |
		INX #3 : BCS +				; |
		CPX #$0060 : BCC -			; |
		+					;/

		SEP #$20				;\
		LDX #$005D				; |
		LDY #$001F				; |
	-	LDA $6BF6,x : STA $6CB6,y		; | lo bytes are also copied into separate tables
		LDA $6BF7,x : STA $6CD6,y		; |
		DEX #3					; |
		DEY : BPL -				;/

		; i have no idea what read3($05DA17+1) does... but it might be important
		REP #$30					;\
		LDA #$0025 : STA $40C800			; |
		LDA #$0000 : STA $41C800			; |
		LDX #$C800					; |
		LDY #$C801					; |
		LDA #$37FF					; | set all map16 tiles to 0x025 (air)
		MVN $40,$40					; |
		LDX #$C800					; |
		LDY #$C801					; |
		LDA #$37FF					; |
		MVN $41,$41					;/

		PLP						;\ wrapper end
		PLB						;/
		RTL						; return




	;===============;
	; SA-1 THREAD 2 ;
	;===============;
	InitColors:
		PHB : PHK : PLB
		PHP
		SEP #$30

		LDX #$00						;\
		LDY #$00						; | get HSL format palette
		JSL RGBtoHSL						;/

		LDA #$07 : STA !PalsetStart				; default: all palset rows are dynamic

	.LoadLightPoints
		PHB							;\
		LDA.b #LevelData>>16					; | bank wrapper start
		PHA : PLB						;/
		REP #$30						; all regs 16-bit
		STZ !LightPointIndex					;\
		LDX #$0000						; |
		LDY !Level						; |
		..loop							; |
		TYA							; |
		CMP.w LevelData_LightPoints+$C,x : BNE ..next		; |
		LDY !LightPointIndex					; |
		CPY #$006C : BCS ..fail					; |
		LDA.w LevelData_LightPoints+$0,x : STA !LightPointX,y	; |
		LDA.w LevelData_LightPoints+$2,x : STA !LightPointY,y	; |
		LDA.w LevelData_LightPoints+$4,x : STA !LightPointR,y	; | search for and load light points belonging to this level
		LDA.w LevelData_LightPoints+$6,x : STA !LightPointG,y	; |
		LDA.w LevelData_LightPoints+$8,x : STA !LightPointB,y	; |
		LDA.w LevelData_LightPoints+$A,x : STA !LightPointS,y	; |
		TYA							; |
		CLC : ADC #$000C					; |
		STA !LightPointIndex					; |
		..fail							; |
		LDY !Level						; |
		..next							; |
		TXA							; |
		CLC : ADC #$000E					; |
		TAX							; |
		CPX.w #LevelData_LightPoints_end-LevelData_LightPoints	; |
		BCC ..loop						;/
		PLB							; restore bank

	.InitialLightSettings
		STZ !GlobalLight1					;\ reset auto light mixer
		STZ !GlobalLightMix					;/
		STZ !Color0						; clear color 0
		SEP #$10						; > index 8 bit
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


	; to use alt player palettes, just add an offset here
	.PlayerPalsets
		REP #$30						;\
		LDA !Characters						; |
		LSR #4							; |
		AND #$000F						; |
		INC A							; |
		STA !Palset8						; > overwriting !Palset9 is fine since it's set just after
		LDY #$0000						; |
		XBA							; |
		LSR #3							; |
		TAX							; |
	-	LDA.l !PalsetData-$20,x : STA !PaletteRGB+($80*2),y	; |
		INX #2							; |
		INY #2							; | load initial player palsets
		CPY #$0020 : BCC -					; |
		LDA !Characters						; |
		AND #$000F						; |
		INC A							; |
		SEP #$20						; > make sure we don't overwrite !PalsetA
		STA !Palset9						; |
		REP #$20						; |
		LDY #$0000						; |
		XBA							; |
		LSR #3							; |
		TAX							; |
	-	LDA.l !PalsetData-$20,x : STA !PaletteRGB+($90*2),y	; |
		INX #2							; |
		INY #2							; |
		CPY #$0020 : BCC -					;/

		PLP							;\ wrapper end
		PLB							;/
		RTL							; return



	InitTranslevel:
		PHB : PHK : PLB
		PHP
		SEP #$30						; all regs 8-bit
		LDX !Translevel						;\ set mega level ID
		LDA.l LevelData_MegaLevelID,x : STA !MegaLevelID	;/


		STZ !Level+2						;\
		STZ !Level+3						; | clear extra bytes
		STZ !Level+4						; |
		STZ !Level+5						;/
		LDA !DoorCounter : BEQ .InitMainLevel			; how many doors have been entered

	.InitSubLevel
		LDA !P2HP-$80
		CLC : ADC !P2TempHP-$80
		STA !P2ShowHP-$80
		LDA !P2HP
		CLC : ADC !P2TempHP
		STA !P2ShowHP
		BRA .InitYoshiCoins

	.InitMainLevel
		LDA #$FF						;\
		STA !HeldItemP1_num					; |
		STA !HeldItemP1_level+1					; | reset held items when going into a new level
		STA !HeldItemP2_num					; |
		STA !HeldItemP2_level+1					;/
		LDX #$7F						;\
	-	STZ !TranslevelFlags,x					; | clear translevel flags on first sublevel only
		DEX : BPL -						;/
		STZ !P2TempHP-$80					;\ clear temp HP
		STZ !P2TempHP						;/
		REP #$20						;\
		LDA !Translevel						; |
		ASL A							; |
		TAX							; | init time limit (on first sublevel only)
		LDA.l LevelData_TimeLimits,x				; |
		INC A							; |
		STA !TimerSeconds					;/
		STZ !TimeElapsed+0					;\
		STZ !TimeElapsed+1					; | reset time elapsed (on first sublevel only)
		SEP #$20						;/
		LDA.b #1 : STA !TimerFrames				; set timer to update right away

		LDA #$0F						;\
		STA !P2HP-$80						; | players start with full HP
		STA !P2HP						;/

	.InitYoshiCoins
		LDA !Translevel : BEQ ..done				; unless level = 0, despawn collected yoshi coins
		LDX.b #LevelData_YoshiCoins>>16 : PHX : PLB		; bank = yoshi coin data bank
		REP #$30						;\
		STZ $2250						; |
		AND #$00FF : STA $2251					; | X = level
		TAX							; | Y = level * 25
		LDA.w #25 : STA $2253					; |
		NOP : BRA $00						; |
		LDY $2306						;/
		LDA !LevelHeight : STA $2251				; prepare multiplication with level height
		STZ $00							; will hold the "yoshi coins collected" flags (rotated in ROR, so they will end up in $01)
		LDA !LevelTable1,x : STA $02				; holds currently collected yoshi coins
		JSR .DestroyCoin					;\
		JSR .DestroyCoin					; |
		JSR .DestroyCoin					; | despawn collected yoshi coins
		JSR .DestroyCoin					; |
		JSR .DestroyCoin					;/
		LDA !MegaLevelID					;\ check for mega level
		AND #$00FF : BEQ ..done					;/
		TAX							;\
		STA $0E							; |
		ASL #2 : ADC $0E					; | *25
		STA $0E							; |
		ASL #2 : ADC $0E					; |
		TAY							;/
		LDA !LevelTable1,x : STA $02				;\
		JSR .DestroyCoin					; |
		JSR .DestroyCoin					; | despawn collected yoshi coins
		JSR .DestroyCoin					; |
		JSR .DestroyCoin					; |
		JSR .DestroyCoin					;/
		..done

		PLP
		PLB
		RTL


; data format per Yoshi Coin:
; [XX] [xy] [YY] [-s] [sS]
;
; X and Y are expected to be 3-digit hexadecimal numbers (but they can be entered as decimal too)
; they point to the tile coordinates of the coin
; if sublevel number is $FFFF, the Yoshi Coin does not exist
	.DestroyCoin
		LSR $02 : BCC ..return				; if yoshi coin is not collected, return
		LDA LevelData_YoshiCoins+3,y : BMI ..return	; if yoshi coin doesn't exist, return
		AND #$01FF					;\ if yoshi coin is in another level, return
		CMP !Level : BNE ..return			;/
		LDA LevelData_YoshiCoins+0,y			;\ index offset from X screen
		AND #$00FF : STA $2253				;/
		LDA LevelData_YoshiCoins+1,y			;\ add with offset from X/Y position
		CLC : ADC $2306					;/
		TAX						;\
		SEP #$20					; |
		LDA #$25 : STA $40C800,x : STA $40C810,x	; | erase yoshi coin
		LDA #$00 : STA $41C800,x : STA $41C810,x	; |
		REP #$20					;/
		..return					;\
		TYA						; | update index
		CLC : ADC #$0005				; |
		TAY						;/
		RTS						; return





	;===============;
	; SA-1 THREAD 3 ;
	;===============;
	; init sprite engine


	;===============;
	; SA-1 THREAD 4 ;
	;===============;
	; light auto-mixer
	; Camera_BG
	CalcBG2BaseV:
		PHP
		REP #$20
		SEP #$10
		LDA !BG2ModeV					;\ X = factor table index
		ASL A : TAX					;/
		STZ $2250					; prepare multiplication
		LDA !BG2Height
		BIT #$0080 : BNE .RelativeToFG			; check for this setting
		BIT #$0040 : BNE .AutoCoord

	.SimpleCoord
		LDA !BigRAM
		SEC : SBC $20
		STA !BG2BaseV					; !BG2BaseV = static BG2 - scroll BG2
		CLC : ADC $20
		STA $20
		PLP
		RTL


	.RelativeToFG
		AND #$001F
		ASL #4
		BIT #$0100 : BEQ +
		ORA #$FF00
		CMP #$FF00 : BNE ++
		LDA #$0000 : BRA +++
	+	AND #$00F0
	++	CLC : ADC $1C
	+++	STA $00
		JSL BG2Controller_CalcVert
		EOR #$FFFF
		SEC : ADC $00
		STA !BG2BaseV
		LDA $00 : STA $20
		PLP
		RTL

	.AutoCoord
		STZ !BG2BaseV
		LDX !BG2ModeV
		CPX #$01 : BNE ..calc

		..constant
		LDA $1C : STA $20
		PLP
		RTL

		..calc
		AND #$001F
		INC A
		ASL #4
		; A = height of BG2

		SEC : SBC #$00E0
		PHA
		; push bottomBG2

		LDY #$01					; division bit
		LDA !LevelHeight
		BIT !HorzLevelMode-1
		BVS $04 : SEC : SBC #$0010
		SEC : SBC #$00E0
		PEI ($1C)
		STA $1C
		JSL BG2Controller_CalcVert
		PLA : STA $1C
		PLA
		SEC : SBC $20
		STA !BG2BaseV
		JSL BG2Controller_CalcVert
		PLP
		RTL


		; AND #$001F					; according to LM this is a value 0x0E-0x1F (displayed num -1)
		; SEC : SBC #$000E				; so this is a value 0x00-0x11
		; BIT !HorzLevelMode-1
		; BVC $01 : INC A					; and it's now 0x01-0x12
		; ASL #4						; get height in px
		; STA $2251					; so negative values won't be a problem
		; LDA.l BG2Controller_ScrollDivisor,x : STA $2253
		; LDY #$01
		; BRA $00
		; LDA $2306
		; STY $2250
		; STA $2251
		; LDA.l BG2Controller_ScrollFactor,x : STA $2253
		; NOP : BRA $00
		; LDA $2306
		; LSR #4						; get height in tiles
		; STA $00						; $00 = reverse-scrolled max BG2 Y

		; LDA !LevelHeight
		; LSR #4
		; DEC A						; V is still determined by previous BIT op
		; BVC $01 : INC A
		; SEC : SBC #$000E
		; CMP $00 : BCS +

		; EOR #$FFFF
		; SEC : ADC $00
		; ASL #4
		; PEI ($20)
		; PEI ($1C)
		; STA $1C
		; JSL BG2Controller_CalcVert
		; BRA ++

	; +	SBC $00
		; ASL #4
		; PEI ($20)
		; PEI ($1C)
		; STA $1C
		; JSL BG2Controller_CalcVert
		; EOR #$FFFF : INC A

	; ++	STA !BG2BaseV
		; PLA : STA $1C					; restore BG1 Y
		; PLA
		; CLC : ADC !BG2BaseV
		; STA $20
		; PLP
		; RTL


	;===============;
	; SA-1 THREAD 5 ;
	;===============;
	InitPlayers:
		PHB : PHK : PLB					;\ wrapper start
		PHP						;/
		SEP #$30					; all regs 8-bit

	.Anim
		LDA !DoorCounter : BNE ..nofallanim		; only force animation on first sublevel
		LDA !P2Pipe-$80					;\ pipes have their own animation
		ORA !P2Pipe : BNE ..nofallanim			;/
		LDA !P2Entrance-$80 : BPL ..normalanim		; check for fall entrance
		LDA #$10 : STA !P2Stasis			;\
		DEC !MarioYPosHi				; |
		DEC !P2YPosHi-$80				; | falling entrance animation
		DEC !P2YPosHi					; |
		BRA ..nofallanim				;/
		..normalanim					;\
		LDA #$3F : STA !P2Entrance-$80			; | normal entrance animation
		LDA #$4F : STA !P2Entrance			; |
		..nofallanim					;/

	.CallPCE
		LDA !P2Direction-$80 : PHA			;\ preserve player directions
		LDA !P2Direction : PHA				;/
		JSL PCE						; call PCE
		PLA : STA !P2Direction				;\ restore player directions
		PLA : STA !P2Direction-$80			;/
		PLP						;\ wrapper end
		PLB						;/
		RTL						; return






















;=====================;
; OBJECT LOADER EDITS ;
;=====================;
OBJECT_LOADER:
	pushpc
	org $058415
		RTL					; make this routine end in RTL instead of PLP : RTS

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
		BIT !LevelEntry : BVC ..return
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







