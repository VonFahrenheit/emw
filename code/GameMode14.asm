;====================;
;GAME MODE 14 REWRITE;
;====================;

;
; TO DO:
; TODO:
; - PCE
;	- side exit and camera border interaction
;	- mario powerup anim
;	- starman sparkles (Leeway crawl X offset)
;	- mario tile interaction: continue past level borders
; - FusionCore
;	- particles
; - generators
; - scroll sprites ??
; - transitions (level -> level and level -> realm)
; - replace alt palset with light shader



; - trim:
;	- VR3 OAM handler
;	- Fe26 extra hijacks
;	- PCE extra Mario hijacks
;	- smooth camera setting
;	- SP_Patch
;		- camera hijacks












GAMEMODE14:
namespace GAMEMODE14



;
; structure
;
; phase 1:
; - combined
;	- MSG
;	- pause code
;
; phase 2:
; - SNES
;	- MAIN_Level
;	- camera
; - SA-1
;	- status bar
;	- rainbow shifter + simple rotate
;	- starman effect (maybe move color shader to SNES side)
;
; phase 3:
; - SNES
;	- vanilla animations
; - SA-1
;	- scroll sprites
;	- camera shake
;	- PCE
;	- Fe26
;	- FusionCore
;	- build OAM
;
;
; rationale
;	- MSG and pause code are first because they have the right to end the routine, meaning they can't be dual-threaded
;	- the bottleneck is MAIN_Level, which has to be run by SNES and has to be run before camera
;	- since the major systems (PCE, Fe26, FusionCore) have to be run after camera, this leaves the SA-1 with few things to do before MAIN_Level is done
;	- with this setup, i'm putting as much as possible in SA-1 phase 2 to maximize the dual thread yield
;	- during phase 3, SNES runs vanilla animations (because it can only be run by SNES, that's the only reason)
;	- this means that SA-1 will run at 50% speed while SNES is processing, which is only when it otherwise would have run at 0% speed (waiting), most of the time SA-1 will run at 100% speed
;


; phase 1: accelerator mode
<<<<<<< Updated upstream
		LDA !MsgTrigger : BEQ .NoMSG		;\
		JSL read3($00A1DF+1)			; | MSG
		BRA .RETURN				; |
		.NoMSG					;/

	; disable down and X/Y during animations and level end
		LDA !MarioAnim
		ORA !LevelEnd
		BEQ +
		LDA #$04 : TRB $15
		LDA #$40
		TRB $16
		TRB $18
		+
=======

	GAMEMODE_14:

		.PlayersDead					;\
		LDA !P2Status-$80 : BEQ ..alive			; |
		LDA !MultiPlayer : BEQ ..music			; | (ignore p2 on singleplayer)
		LDA !P2Status : BEQ ..alive			; | if both players are dead, play death music
		..music						; |
		LDA #$01 : STA !SPC3				; |
		LDA #$FF : STA !MusicBackup			;/
		REP #$20					;\
		STZ !P1Coins					; | lose coins
		STZ !P2Coins					; |
		SEP #$20					;/
		STZ !EnableHScroll				;\ lock camera
		STZ !EnableVScroll				;/
		LDA !DeathTimer : BNE ..noinit			;\
		LDA #$E0 : STA !DeathTimer			; | timer to let music finish playing
		..noinit					; |
		DEC !DeathTimer : BNE ..alive			;/
		LDA #$0B : STA !GameMode			;\ exit level when timer runs out
		..alive						;/


		.Freeze
		LDA $9D : BEQ ..done				; 0 = no time alteration
		BPL ..stop					;\
		INC $9D						; | neg = slow motion (25% speed)
		AND #$03 : BEQ ..done				; |
		JMP .RETURN					;/
		..stop						; pos = stop
		DEC $9D : BEQ ..done				; this has to be done to not drop the buffered input
	;	AND #$0F : TAX
	;	LDA !RNGtable,x : STA !RNG
	;	LDA $14
	;	AND #$1F
	;	EOR #$10 : TAY
	;	LDA !RNGtable+$10,x : STA !RNGtable,y
	;	LDA.b #PCE : STA $3180
	;	LDA.b #PCE>>8 : STA $3181
	;	LDA.b #PCE>>16 : STA $3182
	;	JSR $1E80
	;	LDA.b #ParticleMain_RunFreeze : STA $3180	;\
	;	LDA.b #ParticleMain_RunFreeze>>8 : STA $3181	; |
	;	LDA.b #ParticleMain_RunFreeze>>16 : STA $3182	; | run mario's flame particles only
	;	JSR $1E80					; |
		JMP .RETURN					;/
		..done

		LDA !ProcessLight				;\
		CMP #$02 : BNE ..noshade			; |
		LDA !AnimToggle					; |
		LSR A : BCS ..noshine				; |
		LDA $14						; |
		AND #$1C					; | start new shade operation when previous one finishes
		LSR A						; | (also pass yoshi coin colors unless vanilla is disabled)
		TAX						; |
		LDA.l $B60C,x : STA !ShaderInput+($64*2)+0	; |
		LDA.l $B60D,x : STA !ShaderInput+($64*2)+1	; |
		..noshine					; |
		STZ !ProcessLight				; |
		..noshade					;/

		LDA !MsgTrigger					;\
		ORA !MsgTrigger+1 : BEQ .NoMSG			; |
		JSL MESSAGE_ENGINE				; | MSG
		BRA .RETURN					; |
		.NoMSG						;/

>>>>>>> Stashed changes

	; optimized pause code
		LDA !PauseTimer : BEQ .CheckPause
		DEC !PauseTimer
		BRA .CheckSelect

		.CheckPause
<<<<<<< Updated upstream
		LDA !MultiPlayer : BEQ .P1
		LDA !P2Status-$80 : BNE .notP1
	.notP1	LDA !P2Status : BNE .PauseDone
	.P2	LDA $6DA7
		BRA .W
	.both	LDA $6DA7
	.P1	ORA $6DA6
	.W	STA $00
=======
		LDA !MultiPlayer : BEQ ..p1
		..p2
		LDA !P2Status : BNE ..p1
		LDA $6DA7 : TSB $00
		..p1
		LDA !P2Status-$80 : BNE +
		LDA $6DA6 : TSB $00
	+	LDA $00
>>>>>>> Stashed changes
		AND #$10 : BEQ .CheckSelect
		LDA !MsgTrigger : BNE +
		LDA !Pause
		EOR #$01
		STA !Pause
		EOR #$01
		CLC : ADC #$11
		STA !SPC1
		LDA #$3C : STA !PauseTimer

		.CheckSelect
		LDA !Pause : BEQ .PauseDone
		LDA $00
		AND #$20 : BEQ .GameIsPaused
		LDX !Translevel
		LDA !LevelTable1,x : BPL .PauseDone
		LDA #$0B : STA !GameMode
		.GameIsPaused
<<<<<<< Updated upstream
		; RETURN
		.RETURN
		LDA #$00				;\ bank = 0x00
		PHA : PLB				;/
		JML $00A289				; JML to RTS
=======
		LDA #$08
		CMP !2100 : BEQ .RETURN
		DEC !2100

		.RETURN
		LDA #$00 : PHA : PLB				; B = 0x00
		RTL
>>>>>>> Stashed changes
		.PauseDone

<<<<<<< Updated upstream
		LDA !MsgTrigger : BEQ ++		; > always clear if there's no message box
		LDA !WindowDir : BNE +			; > don't clear while window is closing
		LDA.l !MsgMode : BNE +			;\ don't clear OAM during !MsgMode non-zero
	++	JSL !KillOAM				;/
		+
=======
	; i want SA-1 to handle level main, so this has to be run in phase 1 (accelerator mode) since SA-1 will need DP 0
	.MainLevelCode
		LDA.b #.CallLevelMain : STA $3180		;\
		LDA.b #.CallLevelMain>>8 : STA $3181		; |
		LDA.b #.CallLevelMain>>16 : STA $3182		; | SA-1 call (accelerator mode)
		LDA #$80 : STA $2200				; |
		JSR.w MPU_Light					;/
		..done
		SEP #$30					; all regs 8-bit just in case
		JSL Camera					; camera (run in accelerator mode)
>>>>>>> Stashed changes


<<<<<<< Updated upstream
		STZ !MPU_SNES				;\ start new MPU operation
		STZ !MPU_SA1				;/

		LDA.b #.SA1 : STA $3180			;\
		LDA.b #.SA1>>8 : STA $3181		; | start SA-1 thread
		LDA.b #.SA1>>16 : STA $3182		; |
		LDA #$80 : STA $2200			;/

	.SNES
	; SNES phase 1, executed on DP 0
		JSR MAIN_Level				; SNES thread is just MAIN level code
		JSL Camera				; camera (ran in accelerator mode)
		%MPU_SNES($01)				; end of SNES phase 1

	; SNES phase 2, executed on DP $0100
		PHD					; push DP
		%MPU_copy()				; set up SNES MPU DP
		JSL read3($00A2A5+1)			; call routine
		PLD					; restore DP
		JSR !MPU_light				; SNES will process light shader while SA-1 is running the main game
		BRA .RETURN


	.SA1
		PHB					;\
		PHP					; | start of SA-1 thread
		SEP #$30				;/

	; SA-1 phase 1, executed on DP $0100
		PHD					; push DP
		%MPU_copy()				; set up SA-1 MPU DP
		JSL $008E1A				; status bar
		LDA $14					;\
		AND #$1F				; |
		TAY					; | index RNG table
		DEC A					; |
		AND #$1F				; |
		TAX					;/
		JSL !Random				; get vanilla RN
		ADC !RNGtable,x				; add RNG from last frame
		ADC $13					; add true frame counter
		ADC $6DA2				;\
		ADC $6DA3				; |
		ADC $6DA4				; |
		ADC $6DA5				; | add player controller input
		ADC $6DA6				; |
		ADC $6DA7				; |
		ADC $6DA8				; |
		ADC $6DA9				;/
		ADC !P2XSpeed-$80			;\ add player 1 speed
		ADC !P2YSpeed-$80			;/
		ADC !P2XPosLo-$80			;\ add player 1 position
		ADC !P2YPosLo-$80			;/
		ADC !P2XSpeed				;\ add player 2 speed
		ADC !P2YSpeed				;/
		ADC !P2XPosLo				;\ add player 2 position
		ADC !P2YPosLo				;/
		STA !RNGtable,y				; store new RN
		STA !RNG				; most recently generated
		PLD					; restore DP
		%MPU_SA1($01)				; end of SA-1 phase 1

	; SA-1 phase 2, executed on DP 0
		JSL HandleGraphics			; rotate simple + starman handler (part of SP_Level.asm)
		SEP #$30				; all regs 8-bit
		LDA !ProcessLight			;\
		CMP #$02 : BNE ..noshade		; | start new shade operation when previous one finishes
		STZ !ProcessLight			; |
		..noshade				;/
		JSL $05BC00				; scroll sprites (includes LM's hijack for BG3 controller, which i have KILLED >:D)
		PEI ($1C)				;\
		REP #$20				; |
		STZ $7888				; |
		LDA $7887 : BEQ ..noshake		; > note that $7888 was JUST cleared so hi byte is fine
		DEC $7887				; |
		AND #$0003				; |
		ASL A					; |
		TAY					; | camera shake routine
		LDA $A1CE,y : STA $7888			; |
		BIT $6BF4				; |
		BVC $02 : DEC #2			; |
		STA $7888				; |
		CLC : ADC $1C				; |
		STA $1C					; |
		..noshake				; |
		SEP #$30				;/
		JSL $158008				; call PCE
		JSL $168000				; call Fe26 main loop
		JSL $148000				; call FusionCore (fusion sprites + particles)
		REP #$20				;\
		PLA : STA $1C				; | restore BG1 Y
		SEP #$30				;/
		JSL !BuildOAM				; build OAM at the end of the game mode code
=======
; phase 2: MPU operation
		STZ !MPU_SNES					;\ start new MPU operation
		STZ !MPU_SA1					;/
		LDA.b #.SA1 : STA $3180				;\
		LDA.b #.SA1>>8 : STA $3181			; | start SA-1 thread
		LDA.b #.SA1>>16 : STA $3182			; |
		LDA #$80 : STA $2200				;/


; SNES thread
	.SNES
	; SNES thread, executed on DP $0100
		PHD						; push DP
		%MPU_copy()					; set up SNES MPU DP
		JSL read3($00A2A5+1)				; call animation setup routine
		PLD						; restore DP
		JSR.w MPU_Light					; SNES will process light shader while SA-1 is running the main game
		JMP .RETURN



; input: !Level = sublevel num
; output: void
	.CallLevelMain
		PHB						;\ wrapper start
		PHP						;/
		REP #$30					; all regs 16-bit
		LDA !Level					;\
		ASL A : ADC !Level				; |
		TAX						; | check for main level pointer
		LDA.l LevelPtr,x : BEQ ..return			; |
		STA $00						;/
		SEP #$20					;\
		LDA.l LevelPtr+2,x : PHA : PLB			; | B = bank byte of pointer
		REP #$20					;/

		..checkbox
		LDY #$0006					;\ check for camera box
		LDA ($00),y : BEQ ..checkmain			;/
		PEI ($00)					;\
		JSL LoadCameraBox				; | load camera box
		REP #$30					; | (preserve pointer at $00)
		PLA : STA $00					;/

		..checkmain
		LDY #$0002					;\ check for main
		LDA ($00),y : BEQ ..return			;/
		STA $00						;\
		SEP #$30					; |
		PHB : PLA : STA $00+2				; | call .Main
		PHK : PEA ..return-1				; | (with all regs 8-bit)
		JML [$3000]					; |
		..return					;/

		PLP						;\ wrapper end
		PLB						;/
		RTL						; return



; SA-1 thread
	.SA1
		PHB						;\ start of SA-1 thread
		PHP						;/

	; SA-1 thread, executed on DP 0
		LDA !Translevel : BNE ..processyoshicoins	;\ unless level = 0, run normal yoshi coin checks
		JMP ..yoshicoindone				;/
		..processyoshicoins
		LDX.b #LevelData_YoshiCoins>>16 : PHX : PLB	; bank = yoshi coin data bank
		REP #$30					;\
		STZ $2250					; |
		AND #$00FF : STA $2251				; | X = level
		TAX						; | Y = level * 25
		LDA.w #25 : STA $2253				; |
		NOP : BRA $00					; |
		LDY $2306					;/
		LDA !LevelHeight : STA $2251			; prepare multiplication with level height
		STZ $00						; will hold the "yoshi coins collected" flags (rotated in ROR, so they will end up in $01)
		LDA !LevelTable1,x : STA $02			; holds currently collected yoshi coins
		PHX						;\
		JSR .ReadYoshiCoin				; |
		JSR .ReadYoshiCoin				; |
		JSR .ReadYoshiCoin				; |
		JSR .ReadYoshiCoin				; |
		JSR .ReadYoshiCoin				; | update yoshi coin flags
		PLX						; |
		SEP #$20					; |
		LDA $01					 	; |
		LSR #3						; |
		ORA !LevelTable1,x				; |
		STA !LevelTable1,x				;/

		LDA !MegaLevelID : BEQ ..yoshicoindone		; check for mega level 
		REP #$20					;\
		AND #$00FF : STA $0E				; |
		TAX						; | X = level
		ASL #2 : ADC $0E				; | Y = level * 25
		STA $0E						; | (multiplication regs already in use here)
		ASL #2 : ADC $0E				; |
		TAY						;/
		STZ $00						; will hold the "yoshi coins collected" flags (rotated in ROR, so they will end up in $01)
		LDA !LevelTable1,x : STA $02			; holds currently collected yoshi coins
		PHX						;\
		JSR .ReadYoshiCoin				; |
		JSR .ReadYoshiCoin				; |
		JSR .ReadYoshiCoin				; |
		JSR .ReadYoshiCoin				; |
		JSR .ReadYoshiCoin				; | update yoshi coin flags
		PLX						; |
		SEP #$20					; |
		LDA $01				 		; |
		LSR #3						; |
		ORA !LevelTable1,x				; |
		STA !LevelTable1,x				;/
		..yoshicoindone


		SEP #$30					; all regs 8-bit
		PEA $0000 : PLB					; bank = 00, with an extra 00 on stack
		JSL StatusBar					; status bar


		LDA $14						;\
		AND #$1F					; |
		TAY						; | index RNG table
		DEC A						; |
		AND #$1F					; |
		TAX						;/
		LDA !RNGtable,x : STA !RNG_Seed3		; > update seed 3
		BIT #$01 : BEQ +				;\
		ASL A : ADC !RNG_Seed3				; | apply 3N+1 on previous RN
		STA !RNG_Seed3 : BRA ++				; |
	+	LSR !RNG_Seed3					;/
	++	LDA !RNG_Seed1					;\
		ASL #2						; |
		SEC : ADC !RNG_Seed1				; |
		STA !RNG_Seed1					; |
		ASL !RNG_Seed2					; |
		LDA #$20					; |
		BIT !RNG_Seed2					; | vanilla RN algorithm
		BCC +						; |
		BEQ +++						; |
		BNE ++						; |
	+	BNE +++						; |
	++	INC !RNG_Seed2					; |
	+++	LDA !RNG_Seed2					; |
		EOR !RNG_Seed1 : STA !RNG_Seed4			;/ > update seed 4
		ADC !RNG_Seed3					; add seed 3 (RNG from last frame)
		ADC $13						; add true frame counter
		ADC $6DA2					;\
		ADC $6DA3					; |
		ADC $6DA4					; |
		ADC $6DA5					; | add player controller input
		ADC $6DA6					; |
		ADC $6DA7					; |
		ADC $6DA8					; |
		ADC $6DA9					;/
		ADC !P2XSpeed-$80				;\ add player 1 speed
		ADC !P2YSpeed-$80				;/
		ADC !P2XPosLo-$80				;\ add player 1 position
		ADC !P2YPosLo-$80				;/
		ADC !P2XSpeed					;\ add player 2 speed
		ADC !P2YSpeed					;/
		ADC !P2XPosLo					;\ add player 2 position
		ADC !P2YPosLo					;/
		STA !RNGtable,y					; store new RN to table
		STA !RNG					; store most recently generated


		SEP #$30					; all regs 8-bit
		INC $14						; increment frame counter
		PHK : PLB					; B = K

; RAM
; $00	9-bit tile num
; $02	SD status: page address
; $04	size
; $06	animation rate (n/v flag triggers)
; $08	rotation direction
; $0A	SD status: bank

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
		..process					;\
		STA $00						; | $00 = tile num (000-1FF)
		XBA : STA $01					;/
		LDA .RotationData+5,y : TAX			;\
		LDA !SD_status,x : STA $03			; |
		AND #$03 : TRB $03				; | $02 = SD page address
		TAX						; | $0A = SD bank
		LDA .SuperDynamicBank,x : STA $0A		; |
		STZ $02						;/
		LDA .RotationData+2,y : BNE +			;\
		STZ $04						; |
		LDA #$82 : STA $05				; |
		BRA ++						; | $04 = size (highest bit signals that this will have 4 uploads)
	+	STA $04						; |
		STZ $05						; |
		++						;/
		LDA .RotationData+3,y : STA $07			; $06 = animation rate (n/v flag triggers)
		LDA .RotationData+4,y : STA $08			;\ $08 = rotation direction
		STZ $09						;/
		JSL GetVRAM
		PHB : LDA.b #!VRAMbank
		PHA : PLB
		REP #$20
		LDA $00
		ASL #4
		ORA #$6000
		STA.w !VRAMtable+$05,x
		CLC : ADC #$0100
		STA.w !VRAMtable+$0C,x
		BIT $04 : BPL +
		SBC #$0100-$40-1 : STA.w !VRAMtable+$13,x
		ADC #$0100-1 : STA.w !VRAMtable+$1A,x
		+
		LDA $14
		BIT $06
		BPL $01 : LSR A
		BVC $01 : LSR A
		AND #$000F
		EOR $08
		STA.l $2251
		LDA $04
		AND #$7FFF : STA.l $2253			; skip highest bit
		NOP
		LDA $02
		CLC : ADC.l $2306
		STA.w !VRAMtable+$02,x
		BIT $04 : BPL ..small
		..big
		ADC #$0080 : STA.w !VRAMtable+$09,x
		ADC #$0080 : STA.w !VRAMtable+$10,x
		ADC #$0080 : STA.w !VRAMtable+$17,x
		BRA ..getsize
		..small
		ADC #$0040 : STA.w !VRAMtable+$09,x
		..getsize
		LDA $04 : BMI ..32x32
		AND #$7FFF
		CMP #$0040 : BCS ..16x16
		..8x8
		LDA #$0020 : STA.w !VRAMtable+$00,x
		BRA ..shared
		..16x16
		LDA #$0040
		STA.w !VRAMtable+$00,x
		STA.w !VRAMtable+$07,x
		BRA ..shared
		..32x32
		LDA #$0080
		STA.w !VRAMtable+$00,x
		STA.w !VRAMtable+$07,x
		STA.w !VRAMtable+$0E,x
		STA.w !VRAMtable+$15,x
		..shared
		SEP #$20
		LDA $0A
		STA.w !VRAMtable+$04,x
		STA.w !VRAMtable+$0B,x
		BIT $04+1 : BPL +
		STA.w !VRAMtable+$12,x
		STA.w !VRAMtable+$19,x
		+
		PLB

		..next
		PLA
		CLC : ADC #$06
		CMP.b #.RotationData_end-.RotationData : BCS ..done
		TAY
		JMP ..loop
		..done

	; handler for portal sprite
	.UpdatePortal
		LDA $14
		AND #$03 : BNE ..done
		REP #$30
		LDA !GFX_Portal : BEQ ..done
		LDY.w #!File_Portal : JSL GetFileAddress
		JSL GetVRAM
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
		..done

	; handler for player rainbow effect
	.RainbowShifter
		SEP #$30
		LDA !StarTimer : BNE ..shift
		LDA #$80
		..p1
		LDX !P2LockPalset-$80 : BNE ..p2
		TRB !Palset8
		..p2
		LDX !P2LockPalset : BNE ..ret
		TRB !Palset9
		..ret
		JMP ..done
		..shift
		XBA
		LDA $14
		AND #$03
		BNE $03 : DEC !StarTimer
		LDA #$00
		XBA
		LSR #5
		TAX
		LDA $13
		AND.w .SparkleTime,x : BNE ..nosparkle
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
		JSL RGBtoHSL
		LDX #$009F*3
		..loop
		LDA !StarTimer
		ASL #2
		CLC : ADC !PaletteHSL,x
		CMP #$F0
		BCC $02 : SBC #$F0
		STA !PaletteHSL,x
		LDA #$30 : STA !PaletteHSL+1,x
		LDA #$20 : STA !PaletteHSL+2,x
		DEX #3
		CPX #$0081*3 : BCS ..loop
		LDX #$0081
		LDY #$001F
		JSL HSLtoRGB
		LDX #$0081
		LDY #$001F
		LDA !StarTimer
		CMP #$10
		BCC $02 : LDA #$10
		SEC : SBC #$20
		EOR #$FF : INC A
		JSL MixRGB
		SEP #$30
		..done

	; handler for light update
	.UpdateLight
		LDA !GlobalLightMix				;\
		CMP !GlobalLightMixPrev : BEQ ..done		; | see if there was a change this frame
		JSR .UpdateLightSub				; | done this way so .UpdateLightSub can also be called on level init
		..done						;/

	; cleanup for palset allocation
	.UpdatePalset
		LDX #$07					;\
	-	STZ $00,x					; | clear $00-$07
		DEX : BPL -					;/
		LDY #$0F					;\
	-	LDA !SpriteOAMProp,y				; |
		LSR A						; |
		AND #$07					; | mark palettes as used if an existing sprite uses them
		TAX						; |
		LDA !SpriteStatus,y				; |
		BEQ $02 : STA $00,x				; |
		DEY : BPL -					;/
		LDY.b #!Ex_Amount-1				;\
	-	LDA !Ex_Palset,y				; |
		CMP #$FF : BEQ +				; |
		LSR A						; | mark palettes as used if a FusionCore sprite uses them
		AND #$07					; |
		TAX						; |
		LDA #$01 : STA $00,x				; |
	+	DEY : BPL -					;/
		LDA !MsgPal					;\
		AND #$7F					; |
		LSR #4						; |
		STA $0E						; |
		INC A						; |
		STA $0F						; |
		LDA !MsgTrigger					; | mark palsets used by portrait
		ORA !MsgTrigger+1				; |
		BEQ ..nomsg					; |
		LDA !WindowDir : BEQ ..msg			; |
		..nomsg						; |
		LDA #$FF					; |
		STA $0E						; |
		STA $0F						; |
		..msg						;/
		LDX !PalsetStart				;\
	-	CPX $0E : BEQ +					; |
		CPX $0F : BEQ +					; |
		LDA !Palset8,x					; |
		AND #$7F					; |
		CMP PalsetDefaults,x : BEQ +			; |
		LDA $00,x : BNE +				; |
		PHX						; |
		LDA #$00 : XBA					; > clear B
		LDA !Palset8,x					; | if palset is non-default AND unused, unload it
		AND #$7F					; | (unless it is used by msg portraits)
		TAX						; |
		LDA #$00 : STA !Palset_status,x			; |
		PLX						; |
		LDA #$80 : STA !Palset8,x			; |
	+	DEX						; |
		CPX #$02 : BCS -				;/
		LDY !PalsetStart				; loop through all sprite palsets
		REP #$10
		..loop
		LDA !Palset8,y : BMI ..next			; if already loaded, go to next			
		STA $00 : STZ $01				; $00 = palset to load
		XBA : LDA #$00					;\ clear B
		XBA						;/
		TAX						;\
		ORA #$80 : STA !Palset8,y			; | mark palset as loaded
		TYA : STA !Palset_status,x			;/
		TYX						;\ disable this for 1 operation
		LDA #$01 : STA !ShaderRowDisable+8,x		;/
		JSL UpdatePalset				; get color data
		..next
		DEY : BPL ..loop				; loop


		PLB						; B = 0


	;	JSL $05BC00					; scroll sprites (includes LM's hijack for BG3 controller, which i have KILLED >:D)
		; these will have to be ported to Fe26 if we want to use them
		; running the old scroll sprite code is not going to be sustainable


		PEI ($1C)					;\
		REP #$20					; |
		STZ $7888					; |
		LDA !ShakeTimer : BEQ ..noshake			; > note that $7888 was JUST cleared so hi byte is fine
		DEC !ShakeTimer					; |
		AND #$0003					; |
		ASL A						; |
		TAY						; | camera shake routine
		LDA $A1CE,y : STA $7888				; |
		BIT !HorzLevelMode-1				; |
		BVC $02 : DEC #2				; |
		STA $7888					; |
		CLC : ADC $1C					; > this only applies to sprites, actual camera offset is in camera routine
		STA $1C						; |
		..noshake					; |
		SEP #$30					;/

.CODE_00C533	LDY $74AD					;\
		CPY $74AE					; |
		BCS $03 : LDY $74AE				; |
		CPY !StarTimer					; |
		BCS $03 : LDY !StarTimer			; |
		LDA $6DDA : BMI +				; |
		CPY #$01 : BNE +				; | POW (blue and silver) + star power timer + music
		LDY $790C : BNE +				; |
		STA !SPC3					; |
	+	CMP #$FF : BEQ .CODE_00C55C			; |
		CPY #$1E : BNE .CODE_00C55C			; |
		LDA #$24 : STA !SPC4				;/
.CODE_00C55C	LDA $14						;\ only decrement these every 4 frames
		AND #$03 : BNE +				;/
		LDX #$06					;\
	-	LDA $74A8,x					; | auto-decrement $74A9-$74AE (only notable ones are $74AD and $74AE, the P switch timers)
		BEQ $03 : DEC $74A8,x				; | (note the BNE: $74A8 is not decremented)
		DEX : BNE -					;/
		+

		JSL PCE						; call PCE
		LDA #$01 : STA !ProcessingSprites		; mark sprites as currently processing
		LDA #$00 : STA !NPC_TalkSign			; reset NPC talk sign
		JSL MainSpriteLoop				; call Fe26 main loop
		JSL FusionCore					; call FusionCore (fusion sprites + particles + BG objects)
		LDA #$00 : STA !ProcessingSprites		; mark sprites as no longer processing


		REP #$20					;\
		PLA : STA $1C					; | restore BG1 Y
		SEP #$30					;/
		JSL BuildOAM					; build OAM at the end of the game mode code

		PLP						;\
		PLB						; | end of SA-1 thread
		RTL						;/


; data format per Yoshi Coin:
; [XX] [xy] [YY] [-s] [sS]
;
; X and Y are expected to be 3-digit hexadecimal numbers (but they can be entered as decimal too)
; they point to the tile coordinates of the coin
; if sublevel number is $FFFF, the Yoshi Coin does not exist
	.ReadYoshiCoin
		LSR $02 : BCS ..collectcoin			; return if coin is already collected
		LDA LevelData_YoshiCoins+3,y : BMI ..nocoin	; coin must exist
		AND #$01FF					;\ coin must be on this level
		CMP !Level : BNE ..nocoin			;/
		LDA LevelData_YoshiCoins+0,y			;\ index offset from X screen
		AND #$00FF : STA $2253				;/
		LDA LevelData_YoshiCoins+1,y			;\ add with offset from X/Y position
		CLC : ADC $2306					;/
		TAX						;\
		SEP #$20					; |
		LDA $41C800,x : XBA				; | read map16
		LDA $40C800,x					; |
		REP #$20					;/
		CMP #$002D : BNE ..collectcoin			; check for top half of yoshi coin
		..nocoin					;\ clear collected flag
		CLC : ROR $00					;/
		BRA ..incrementindex				; go to increment index
		..collectcoin					;\ set collected flag
		SEC : ROR $00					;/
		..incrementindex				;\
		TYA						; | increase index
		CLC : ADC #$0005				; |
		TAY						;/
		RTS						; return





	.SuperDynamicBank
		db $7E,$7F,$40,$41


	; format:
	; - GFX status index
	; - width ($20 for 8x8, $80 for 16x16, $00 for 32x32)
	; - animation speed (00 = every frame, 40/80 = every other frame, C0 = every 4 frames)
	; - direction (00 = clockwise, 0F = counterclockwise)
	; - SD index

	.RotationData
		dw !GFX_Hammer_offset		: db $80,$00,$0F,!SD_Hammer_offset
		dw !GFX_Bone_offset		: db $80,$40,$0F,!SD_Bone_offset
		dw !GFX_SmallFireball_offset	: db $20,$00,$00,!SD_Fireball8x8_offset
		dw !GFX_ReznorFireball_offset	: db $80,$00,$0F,!SD_Fireball16x16_offset
		dw !GFX_Goomba_offset		: db $80,$00,$0F,!SD_Goomba_offset
		dw !GFX_LuigiFireball_offset	: db $20,$00,$00,!SD_LuigiFireball_offset
		dw !GFX_Baseball_offset		: db $20,$40,$0F,!SD_Baseball_offset

		dw !GFX_Fireball32x32_offset	: db $00,$40,$0F,!SD_Fireball32x32_offset
		dw !GFX_EnemyFireball_offset	: db $80,$00,$0F,!SD_EnemyFireball_offset

		..end


	.UpdateLightSub
		STZ $2250					; prepare multiplication
		REP #$20					;\
		LDA !GlobalLight1				; |
		AND #$00FF					; |
		ASL A						; |
		STA $00						; |
		ASL A						; | RGB values of light 1
		ADC $00						; |
		TAX						; |
		LDA.w .LightValues+0,x : STA $04		; |
		LDA.w .LightValues+2,x : STA $06		; |
		LDA.w .LightValues+4,x : STA $08		;/
		LDA !GlobalLight2				;\
		AND #$00FF					; |
		ASL A						; |
		STA $00						; |
		ASL A						; | RGB values of light 2
		ADC $00						; |
		TAX						; |
		LDA.w .LightValues+0,x : STA $0A		; |
		LDA.w .LightValues+2,x : STA $0C		; |
		LDA.w .LightValues+4,x : STA $0E		;/
		LDA !GlobalLightMix				;\
		AND #$00FF					; |
		CMP #$0021					; | (min 0x00, max 0x20)
		BCC $03 : LDA #$0020				; | strength of lights 1 and 2
		STA $02						; |
		LDA #$0020					; |
		SEC : SBC $02					; |
		STA $00						;/
		STA $2251					;\
		LDA $04 : STA $2253				; |
		NOP : BRA $00					; |
		LDA $2306 : STA $04				; |
		LDA $06 : STA $2253				; |
		NOP : BRA $00					; | update light 1
		LDA $2306 : STA $06				; |
		LDA $08 : STA $2253				; |
		LDA #$0020					; |
		SEC : SBC $00					; |
		STA $02						; |
		LDA $2306 : STA $08				;/
		LDA $02 : STA $2251				;\
		LDA $0A : STA $2253				; |
		NOP						; |
		LDA $04						; |
		CLC : ADC $2306					; |
		LSR #5						; |
		STA !LightR					; |
		LDA $0C : STA $2253				; |
		NOP						; |
		LDA $06						; | update light 2, merge with light 1, then update light RGB values
		CLC : ADC $2306					; |
		LSR #5						; |
		STA !LightG					; |
		LDA $0E : STA $2253				; |
		NOP						; |
		LDA $08						; |
		CLC : ADC $2306					; |
		LSR #5						; |
		STA !LightB					; |
		SEP #$20					;/
		LDA !GlobalLightMix : STA !GlobalLightMixPrev	; update for next frame
		..return
		RTS



	; alt palset light values:
	.LightValues	;    R     G     B
	..default	dw $0100,$0100,$0100	; 00
	..dawn		dw $00F8,$00EE,$00D4	; 01
	..sunset	dw $0120,$00E0,$00C0	; 02
	..night		dw $0080,$00C0,$00E0	; 03
	..lava		dw $0180,$0080,$0080	; 04
	..water		dw $00C0,$00E0,$00F0	; 05



	.SparkleTime
		db $07,$03,$03,$01,$01,$01,$01,$01		; from 028AA9 in all.log


	.SpawnSparkles
		LDA #$1F : STA $0C				;\ AND value for Y coord
		STZ $0D						;/
		LDA #$EE : STA $0E				;\ Y offset = -18
		LDA #$FF : STA $0F				;/

		LDA !P2HurtboxH-$80,y
		CMP #$11 : BCS +
		LDA #$0F : STA $0C
		LDA #$FE : STA $0E
		+

		LDA #$0F : STA $04				;\ AND value for X coord
		STZ $05						;/
		STZ $06						;\ X offset
		STZ $07						;/

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
		ADC !P2XPosLo-$80,y
		STA $00
		TXA
		EOR #$0010
		TAX
		LDA !RNGtable+1,x
		AND $0C
		CLC : ADC $0E
		ADC !P2YPosLo-$80,y
		STA $02

		PHB
		JSL GetParticleIndex
		LDA.w #!prt_sparkle : STA !Particle_Type,x
		LDA #$F000 : STA !Particle_Tile,x		; max prio
		LDA $00 : STA !Particle_X,x
		LDA $02 : STA !Particle_Y,x
		STZ !Particle_XSpeed,x
		STZ !Particle_YSpeed,x
		STZ !Particle_XAcc,x
		STZ !Particle_YAcc,x
		PLB
		SEP #$30

		RTS



	; run from level init
	.CallLight
		PHB : PHK : PLB
		PHP
		SEP #$30
		JSR .UpdateLightSub
		PLP
		PLB
		RTL




>>>>>>> Stashed changes

		PLP					;\
		PLB					; | end of SA-1 thread
		RTL					;/

	pushpc
	org $05BC42
		JML .BypassLM
		NOP
	pullpc
	.BypassLM
		BNE ..return
		LDA !BG3BaseSettings
		LSR A : BCS ..return
		PEA.w $05BC47-1
		LDA !BG3TideSettings : BEQ ..notide
	..tide
		JML $05C494
	..notide
		JML $05C414
	..return
		JML $05BC47





;
; OAM in order
; - MSG (needs prio recode)
; - kill OAM
; - MAIN_Level (needs prio recode)
; - status bar to _p3
; - mario to _p2
; - PCE to _p2
; - sprites to any mirror (usually _p1 or _p2)
; - FusionCore to _p3
; - particles
; - build OAM
;
; probably change status bar to before MAIN_Level so HUD goes in front of sprite FG
; if possible, integrate mario into PCE (finally...)
;
;




; vanilla documentation, used differently in emw

; $7404		if vertical scroll at will is enabled, this flag makes the camera scroll up to the player

; $742A		where player has to be for camera to move X
; $742C		$742A - 0xC
; $742E		$742A + 0xC

; $7446		layer 1 X speed
; $7448		layer 1 Y speed
; $744A		layer 2 X speed
; $744C		layer 2 Y speed

; $7458		layer 3 X speed
; $745A		layer 3 Y speed
; $745C		related to layer 3 X position???
; $745E		Lunar Magic layer 3 settings

; $7462		layer 1 X position next frame
; $7464		layer 1 Y position next frame
; $7466		layer 2 X position next frame
; $7468		layer 2 Y position next frame
; $746A		layer 3 initial X position

<<<<<<< Updated upstream
=======
;
; $00 - level size (rightmost/lowest allowed camera coordinate for horizontal/vertical scrolling respectively)
; $02 - ideal camera target X (without taking speed into account)
; $04 - player x speed (composite in multiplayer)
; $06 - player y speed (composite in multiplayer)
; $08 - used as a forbiddance flag during co-op if players are too far apart
; $0A - player Y position within screen
; $0C - camera target X
; $0E - camera target Y
;
>>>>>>> Stashed changes

;
; method:
;	- do all the backups (including lunar magic backups)
;	- calculate X/Y coordinate of P1, P2 or the average distance between them
;	- use composite distance to scroll camera
;	- apply force camera
;	- apply camera boundaries (including camera box)
;	- call HDMA pointer
;	- call unlimited scroll works (BG2)
;	- finish by setting up backups for next frame (+zip stuff)
;
;

pushpc
	org $009712
		JSL Camera
	org $009A58
		JSL Camera
	org $00A299
		JSL Camera
pullpc



; the vanilla routine is also called once during level init
; sending that here is almost certainly fine
; $00F6DB (scroll routine)
<<<<<<< Updated upstream
Camera:
		LDA.b #.SA1 : STA $3180				;\
		LDA.b #.SA1>>8 : STA $3181			; |
		LDA.b #.SA1>>16 : STA $3182			; | have SA-1 run most of the routine
		LDA #$80 : STA $2200				; | (while SNES works on shading)
		JSR !MPU_light					;/
=======
	Camera:

	.Cutscenes
		LDA !Cutscene : BEQ ..end
		LDA !MsgTrigger
		ORA !MsgTrigger+1 : BNE ..run
		LDA !CutsceneSmoothness
		CMP #$08 : BEQ ..run
		INC !CutsceneSmoothness
		..run
		LDA.b #Cutscene : STA $3180
		LDA.b #Cutscene>>8 : STA $3181
		LDA.b #Cutscene>>16 : STA $3182
		JSR $1E80
		JMP .ExecutePtr
		..end
		LDA !MsgTrigger
		ORA !MsgTrigger+1 : BNE ..done
		LDA !CutsceneSmoothness : BEQ ..done
		DEC !CutsceneSmoothness : BNE ..done
		LDA #$80 : TRB !HDMA
		..done


	.Main
		LDA !P2Status : BEQ ..run			;\
		LDA !P2Status-$80 : BEQ ..run			; | disable camera while both players are dead/dying
		JMP .Return					; |
		..run						;/
		LDA.b #.SA1 : STA $3180				;\
		LDA.b #.SA1>>8 : STA $3181			; | SA-1 code pointer
		LDA.b #.SA1>>16 : STA $3182			;/
		LDA !GameMode					;\
		CMP #$14 : BEQ ..light				; | if not in level game mode, just wait for SA-1
		JSR $1E80					; |
		BRA .ExecutePtr					;/
		..light						;\
		LDA #$80 : STA $2200				; | if in level game mode, have SNES work on shading
		JSR.w MPU_Light					;/


	.ExecutePtr
>>>>>>> Stashed changes
		REP #$20					;\
		LDA.l !HDMAptr+0 : BEQ ..done			; |
		STA $00						; |
		LDA.l !HDMAptr+1 : STA $00+1			; | execute HDMA code
		PHB						; |
		LDY $00+2 : PHY : PLB				; > wrap bank
		PHK : PEA ..return-1				; |
		JML [$3000]					;/
		..return					;
		REP #$20					;\ clear pointer
		LDA #$0000 : STA !HDMAptr+0			;/
		PLB						; > restore bank
		..done						;


	.ProcessModules
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
		LDA !HDMA2module+1,x : STA $00+1		;/
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


<<<<<<< Updated upstream
		.SA1
		PHB
		PHP
		SEP #$20
		LDA #$00
		PHA : PLB
		REP #$20
		LDA $742A
		SEC
		SBC #$000C
		STA $742C
		CLC : ADC #$0018
		STA $742E
; 99% sure this is not needed
;		LDX #$06
;	-	LDA $1A : STA $7F831F,x			; back up BG1/BG2 coords
;		DEX #2 : BPL -				; not sure why but lunar magic wants these
		LDA $7462 : STA $1A
		LDA $7464 : STA $1C
		LDA $7466 : STA $1E
		LDA $7468 : STA $20

		STZ $08					; clear "forbid X" flag (used for composite)
=======
	.Return
		REP #$20					;\
		LDA $1A						; |
		SEC : SBC !CameraPrevX				; |
		STA !CameraXDelta				; | camera delta
		LDA $1C						; |
		SEC : SBC !CameraPrevY				; |
		STA !CameraYDelta				;/
		LDA !CameraBackupX : STA !BG1ZipRowX		;\
		LDA !CameraBackupY : STA !BG1ZipRowY		; | coordinates from previous frame
		LDA !CameraPrevBG2X : STA !BG2ZipRowX		; | (used for updating tilemap)
		LDA !CameraPrevBG2Y : STA !BG2ZipRowY		;/
		LDA $1A : STA !CameraPrevX : STA !CameraBackupX	;\
		LDA $1C : STA !CameraPrevY : STA !CameraBackupY	; | i believe these act as work buffers for scroll sprites
		LDA $1E : STA !CameraPrevBG2X			; |
		LDA $20 : STA !CameraPrevBG2Y			;/
		LDA #$0000 : STA.l !HDMAptr			; clear pointer
		SEP #$30					; all regs 8-bit
		RTL						; return





; INIT ROUTINE
	.Init
		PHB						; preserve B
		PHP						; preserve P
		REP #$30					; all regs 16-bit
		STZ !CameraForceTimer				; clear forced camera movement

		LDA !Level					;\
		ASL A : ADC !Level				; |
		TAX						; |
		LDA.l LevelPtr,x : BEQ ..nobox			; | check if this level has a camera box
		STA $00						; |
		LDA.l LevelPtr+1,x : STA $00+1			; |
		LDY #$0006					; |
		LDA [$00],y : BNE ..box				;/

		..nobox						;\
		LDA #$FFFF : STA !CameraBoxU			; | disable camera box if this level doesn't have one
		BRA ..boxdone					;/

		..box						;\
		STA $00						; |
		SEP #$30					; | load camera box
		LDA $00+2 : PHA : PLB				; |
		REP #$20					; |
		LDA $00 : JSL LoadCameraBox			;/
		REP #$20					;\
		LDA !CameraBoxL					; |
		CMP !CameraBoxR : BNE ..boxdone			; |
		STA $1A						; | if width = 1, force camera X
		STA !CameraBackupX				; |
		STA !CameraPrevX				; |
		BRA ..return					;/
		..boxdone

		LDA $1A : STA !CameraPrevX			;\ keep initial X/Y from level load
		LDA $1C : STA !CameraPrevY			;/

		..return					;
		PLP						; restore P
		PLB						; restore B
		RTL						; return

		..camcenter
		dw $005E
		dw $0090



; BG ONLY CALL
	.BG
		PHP
		REP #$20
		SEP #$10
		JSL BG2Controller
		JSL BG3Controller
		PLP
		RTL



; SA-1 THREAD
; handles actual camera logic
	.SA1
		PHB : PHK : PLB
		PHP
		REP #$20
		LDA !CameraPrevX : STA $1A
		LDA !CameraPrevY : STA $1C
		LDA !CameraPrevBG2X : STA $1E
		LDA !CameraPrevBG2Y : STA $20
		STZ $08						; clear "forbid X" flag (used for composite)
>>>>>>> Stashed changes

		.GetCameraTarget
		SEP #$30
<<<<<<< Updated upstream
		LDA !MultiPlayer : BEQ .P1
		LDA !P2Status : BEQ +
		LDA !P2Status-$80 : BEQ .P1
		; only P1 alive: P1
		; both dead: flow to composite

		.Composite
		REP #$20
		LDA !P2XPosLo-$80
		CLC : ADC !P2XPosLo
		LSR A
		STA $0C
		LDA !P2YPosLo-$80
		CLC : ADC !P2YPosLo
		STA $0E

		LDA !P2XPosLo-$80
		SEC : SBC !P2XPosLo
		BPL $04 : EOR #$FFFF : INC A
		CMP #$00C0
		BCC ++
		INC $08
		BRA ++

	+	LDA !P2Status-$80 : BEQ .Composite
		; both alive: composite
		; only P2 alive: P2

		.P2
		REP #$20
		LDA !P2XPosLo : STA $0C
		LDA !P2YPosLo : STA $0E
		BRA ++

		.P1
		REP #$20
		LDA !P2XPosLo-$80 : STA $0C
		LDA !P2YPosLo-$80 : STA $0E
		++

		LDX !GameMode
		CPX #$14 : BEQ +
		LDA $94 : STA $0C
		+


		LDA $6BF5
		AND #$0040
		BEQ $03 : LDA #$000F
		ADC !LevelHeight
		SBC #$00EF				; note: C was for sure cleared so this subtracts 0xE0
		LDX !EnableVScroll : BNE .ScrollVertically
		JMP .ReturnVScroll

		.ScrollVertically
		STA $04					; $04 = height of level
		LDY #$00				; Y = 0
		LDA $0E
		SEC : SBC $1C
		STA $00					; $00 = mario Y pos on screen
		CMP #$0070				;\
		BMI $02 : LDY #$02			; > if lower half, Y = 2
		STY $55					; |
		STY $56					; |
		SEC : SBC $F69F,y			;/
		STA $02					; $02 = mario Y pos on screen -0x0064 for up/-0x007C for down
		EOR $F6A3,y				;\ if mario is ON upper half of screen, camera should move up
		BMI $04 : LDY #$02 : STZ $02		;/

; negative if:
;	mario above screen
;	mario on lower half of screen
;	which means...
;	if mario is ON the upper half of screen (but not above it), camera is set to move up



		.Space00F8
		LDA $02 : BMI ..2A
		LDX #$00 : STX $7404
		BRA ..83
	..2A	SEP #$20
;		LDA $73E3				; wall running flag
;		CMP  #$06 : BCS ..45

; i'll have to update these to work with co-op!!
; -----------------------
		LDA $749F				; mario jump timer
		ORA $74					; mario climbing flag
		ORA $73F3				; mario inflation flag (beginning animation)
		ORA $78C2				; mario in lakitu cloud flag
		ORA $7406				; mario bouncing on springboard flag
; -----------------------

	..45	TAX
		REP #$20
		BNE ..69
		LDX $75 : BEQ ..5E			; mario in water flag
		LDX $72 : BNE ..69			; mario is in midair flag
	..5E	LDX !EnableVScroll
		DEX : BEQ ..75
		LDX $73F1 : BNE ..75
	..69	STX $73F1				; some logic with a copy of the vscroll flag?
		LDX $73F1 : BNE ..81
;		; LM call (from $00F871)
;		; UNDOCUMENTED!!
	..75	LDX $7404 : BNE ..81
		LDX $72 : BNE .ReturnVScroll		; mario is in midair flag
		INC $7404				; set "scroll up to player" flag
	..81	LDA $02					; mario on screen Y + offset
	..83	SEC : SBC $F6A7,y			;
		EOR $F6A7,y				; subtract and EOR the same thing...
		ASL A
		LDA $02 : BCS ..92
		LDA $F6A7,y
	..92	CLC : ADC $1C
		CMP $F6AD,y
		BPL $03 : LDA $F6AD,y

		LDX !GameMode					;\ unlimit speed during other game modes
		CPX #$14 : BNE .UnlimitY			;/
=======
		LDA !MultiPlayer : BEQ ..p1			; single player: p1
		LDA !P2Status					;\
		CMP #$02 : BNE ..checkp2			; | only p1 alive: p1
		LDA !P2Status-$80				; |
		CMP #$02 : BNE ..p1				;/
		..composite					; both dead: flow to composite
		REP #$20					;\
		LDA !P2X-$80					; |
		CLC : ADC !P2X					; |
		ROR A : STA $0C					; | multiplayer camera target
		LDA !P2Y-$80					; |
		CLC : ADC !P2Y					; |
		ROR A : STA $0E					;/
		SEP #$20					;\
		LDA !P2XSpeed-$80				; |
		CMP #$80 : ROR A				; |
		STA $04						; |
		LDA !P2XSpeed					; | multiplayer X speed
		CMP #$80 : ROR A				; |
		CLC : ADC $04					; |
		STA $04						; |
		STZ $05						; |
		BPL $02 : DEC $05				;/
		LDA !P2YDelta-$80				;\
		CMP #$80 : ROR A				; |
		STA $06						; |
		LDA !P2YDelta					; |
		CMP #$80 : ROR A				; | multiplayer Y speed
		CLC : ADC $06					; |
		STA $06						; |
		STZ $07						; |
		BPL $02 : DEC $07				; |
		REP #$20					;/
		LDA !P2X-$80					;\
		SEC : SBC !P2X					; | if players are 12+ tiles apart, horizontal scrolling is disabled
		BPL $04 : EOR #$FFFF : INC A			; |
		CMP #$00C0 : BCC ..settarget			; |
		INC $08						; |
		BRA ..settarget					;/

		..checkp2					;\ both alive: composite
		LDA !P2Status-$80				;/
		CMP #$02 : BNE ..composite			; only p2 alive: flow to p2
		..p2						;\
		LDY #$80 : JSR .GetPlayerCoords			; | p2 cam
		BRA ..settarget					;/
		..p1						;\ p1 cam
		LDY #$00 : JSR .GetPlayerCoords			;/
		..settarget
		REP #$20					;\
>>>>>>> Stashed changes


<<<<<<< Updated upstream
		LDA $04					;\
		CMP $1C : BPL .ReturnVScroll		; | prevent camera from moving too far down
		STA $1C					;/
		STA $73F1				; also set this flag, i guess
		.ReturnVScroll

		LDY $08 : BNE .BanH
		LDY !EnableHScroll : BNE .ScrollHorizontally
	.BanH	JMP .FinishCamera

		.ScrollHorizontally
		LDY #$02
		SEP #$20				; make sure camera movements are smooth for custom characters too
		LDA #$77				;\
		CLC : ADC !CameraPower			; | left value (0x77 + power)
		STA $00					;/
		LDA #$77				;\
		SEC : SBC !CameraPower			; | right value (0x77 - power)
		STA $01					;/

		REP #$20
		LDA $0C
		SEC : SBC !CameraXMem
		CMP #$0018 : BCC ++
		CMP #$8000 : BCC ..R
		CMP #$FFE8 : BCS ++
	..L	SEP #$20
		LDA $742A
		CMP $00 : BEQ +++
		INC A
		CMP $00 : BEQ +++
		INC A
		BRA +
	..R	SEP #$20
		LDA $742A
		CMP $01 : BEQ +++
		DEC A
		CMP $01 : BEQ +++
		DEC A
		BRA +
	+++	PHA
		REP #$20
		LDA $0C : STA !CameraXMem		; save this to know when to scroll again
		SEP #$20
		PLA
	+	STA $742A
	++	REP #$20
		LDA $0C
		SEC : SBC $1A
		STA $00
		CMP $742A
		BPL $02 : LDY #$00
		STY $55
		STY $56
		SEC : SBC $742C,y
		BEQ .FinishCamera
		STA $02
		EOR $F6A3,y : BPL .FinishCamera
		LDA $02
		CLC : ADC $1A
		BPL $03 : LDA #$0000
=======

>>>>>>> Stashed changes

; tweakable variables:
; - power (how camera distance scales with speed)
; - minimum power (threshold for camera to be allowed to move backwards)
; - maximum power (how far off-center camera is allowed to move)
; - pause time (how long it takes until speed mem 1 starts degrading)
; - slowdown rate (how quickly speed mem 1 degrades)
; - acceleration rate (how quickly speed mem 1 reaches speed value)
; - camera y threshold (how far from the camera center the player has to be for the camera to scroll vertically)

	; camera horizontal settings
		LDA #$0080 : STA !CameraPower
		LDA #$000F : STA !CameraMinPower
		LDA #$0050 : STA !CameraMaxPower
		LDA #$0030 : STA !CameraPauseTime
		LDA #$0080 : STA !CameraSlowdown
		LDA #$0200 : STA !CameraAccel

<<<<<<< Updated upstream
		LDA $5E						;\
		DEC A						; |
		XBA						; |
		AND #$FF00					; | cap at right edge of level
		BPL $03 : LDA #$0080				; |
		CMP $1A						; |
		BPL $02 : STA $1A				;/


		.FinishCamera
		LDX !GameMode					;\
		CPX #$11 : BNE .NoInit				; | check for init
		JMP .InitCamera					;/
	.NoInit	CPX #$14 : BNE .NoBox				; if not game mode 0x14, no camera box
=======
	; camera vertical settings
		LDA #$0020 : STA !CameraYThreshold


>>>>>>> Stashed changes

		.ForceCam					;\
		LDY #$01					; |
<<<<<<< Updated upstream
	-	LDX !CameraForceTimer,y : BEQ .NextForce	; |
=======
		..loop						; |
		LDX !CameraForceTimer,y : BEQ ..next		; |
>>>>>>> Stashed changes
		DEX						; |
		TXA						; |
		SEP #$20					; |
		STA !CameraForceTimer,y				; |
		REP #$20					; |
		LDX !CameraForceDir,y				; |
		PHY						; |
		LDY #$00					; |
		TXA						; |
		AND #$0002					; | apply forced camera movement
		BNE $02 : LDY #$02				; |
		STY $55						; |
		PLY						; |
		LDA !CameraBackupX				; |
		CLC : ADC .ForceTableX,x			; |
		AND #$FFF8					; |
		STA $1A						; |
		LDA !CameraBackupY				; |
		CLC : ADC .ForceTableY,x			; |
		AND #$FFF8					; |
		STA $1C						; |
<<<<<<< Updated upstream
		BRA .NoBox					; |
.NextForce	DEY : BPL -					;/

		BIT !CameraBoxU : BMI .NoBox			;\
		JSR .CameraBox					; | run camera box if it's enabled
;		JMP .CameraBackup				;/

		.NoBox
;		LDX !SmoothCamera : BEQ .CameraBackup		; > see if smooth cam is enabled
;		PHB : PHK : PLB					;\
;		STZ $00						; |
;		LDX $5D						; |
;		DEX						; |
;		STX $01						; |
;		LDA !LevelHeight				; |
;		SEC : SBC #$00E0				; |
;		STA $02						; |
;		LDA !P2XPosLo-$80				; |
;		CLC : ADC !P2XPosLo				; |
;		LSR A						; |
;		SEC : SBC #$0080				; |
;		BPL $03 : LDA #$0000				; |
;		CMP $00						; |
;		BCC $02 : LDA $00				; |
;		STA $1A						; |
;		LDY !EnableVScroll : BEQ +			; |
;		LDA !P2YPosLo-$80				; |
;		CLC : ADC !P2YPosLo				; | smooth cam logic
;		BPL $03 : LDA #$0000				; |
;		LSR A						; |
;		SEC : SBC #$0070				; |
;		BPL $03 : LDA #$0000				; |
;		CMP $02						; |
;		BCC $02 : LDA $02				; |
;		STA $1C						; |
;	+	LDX #$02					; |
;	-	LDA !CameraBackupX,x				; |
;		CMP $1A,x : BEQ +				; |
;		LDY #$00					; |
;		BCC $02 : LDY #$02				; |
;		CLC : ADC.w .SmoothSpeed,y			; |
;		STA $00						; |
;		LDA !CameraBackupX,x				; |
;		SEC : SBC $1A,x					; |
;		BPL $04 : EOR #$FFFF : INC A			; |
;		CMP #$0006 : BCC +				; |
;		LDA $00 : STA $1A,x				; |
;	+	DEX #2 : BPL -					; |
;		PLB						;/

		JSL BG2Controller
		LDA !MsgTrigger : BNE .EndBox
		JSL BG3Controller

		.EndBox
; 99% sure this is not needed
	; LM call
;		PHP
;		LDX #$06
;		LDY #$03
;		REP #$20
;	-	LDA $1A,x : STA $7462,x		; heh, i'll handle this
;		CMP $7F831F,x : BEQ +
;		SEP #$20
;		BMI ++
;		LDA #$02
;		BRA +++
;	++	LDA #$00
;	+++	PHX
;		TYX
;		STA $7F831B,x
;		PLX
;		REP #$20
;	+	DEX #2
;		DEY : BPL -
;		PLP
	; LM return
		SEP #$20				;\
		LDA $1A					; |
		SEC : SBC $7462				; |
		STA !BG1_X_Delta			; |
		LDA $1C					; |
		SEC : SBC $7464				; |
		STA !BG1_X_Delta			; | delta, probably not needed but i'll keep it for now
		LDA $1E					; |
		SEC : SBC $7466				; |
		STA !BG1_X_Delta			; |
		LDA $20					; |
		SEC : SBC $7468				; |
		STA !BG1_X_Delta			; |
		REP #$20				;/
		LDA !CameraBackupX : STA !BG1ZipRowX	;\
		LDA !CameraBackupY : STA !BG1ZipRowY	; | coordinates from previous frame
		LDA $7466 : STA !BG2ZipRowX		; | (used for updating tilemap)
		LDA $7468 : STA !BG2ZipRowY		;/
		LDA $1A : STA $7462			;\
		LDA $1C : STA $7464			; | i believe these act as work buffers for scroll sprites
		LDA $1E : STA $7466			; |
		LDA $20 : STA $7468			;/
		LDA $1A : STA !CameraBackupX		;\ backup for next frame
		LDA $1C : STA !CameraBackupY		;/
=======
		JMP .CalcLightPoints				; |
		..next						; |
		DEY : BPL ..loop				;/


		.ConvertSpeeds
	; THIS IS ALREADY DONE
	;	LDA $04						;\
	;	CMP #$0080					; |
	;	BCC $03 : ORA #$FF00				; |
	;	STA $04						; | convert speeds to 16-bit format
	;	LDA $06						; |
	;	CMP #$0080					; |
	;	BCC $03 : ORA #$FF00				; |
	;	STA $06						;/
		LDA $04 : BEQ ..memdone				;\
		STA !CameraSpeedMem2				; | last nonzero speed value (non-adjusted)
		..memdone					;/


		.HandleTimers
		LDA $04-1					;\ format conversion
		AND #$FF00 : STA $00				;/
		BEQ ..slowdown					; check if memory is accelerating or slowing down
		..accelerate					;\ acceleration
		LDA !CameraAccel : BRA ..memorytick		;/
		..slowdown					;\
		LDA !CameraPauseTimer : BEQ ..handletimer	; |
		DEC !CameraPauseTimer : BRA ..done		; | process pause time
		..handletimer					; |
		LDA !CameraSlowdown				;/> slowdown rate
		..memorytick					;\
		STA $02						; > $02 = delta
		LDA !CameraSpeedMem1				; |
		SEC : SBC $00					; | see if a snap occurs
		BPL $04 : EOR #$FFFF : INC A			; |
		CMP $02 : BCS ..calc				; |
		..snap						; |
		LDA $00 : BRA ..set				;/
		..calc						;\
		LDA !CameraSpeedMem1 : BMI ..neg		; |
		..pos						; |
		BIT $00 : BMI ..sub				; |
		CMP $00 : BCS ..sub				; |
		..add						; |
		CLC : ADC $02					; |
		BRA ..set					; | move memory [delta] units toward target
		..neg						; |
		BIT $00 : BPL ..add				; |
		CMP $00 : BCC ..add				; |
		..sub						; |
		SEC : SBC $02					; |
		..set						; |
		STA !CameraSpeedMem1				; |
		..done						;/


		.SpeedMemory
		LDA $00						;\ speed = 0 -> always use mem instead
		BEQ ..usemem					;/
		BMI ..goingleft					; see if going left
		..goingright					;\
		BIT !CameraSpeedMem1 : BMI ..zeromem		; | comparison with right-facing speed
		CMP !CameraSpeedMem1 : BCS ..pausecamera	; |
		BRA ..usemem					;/
		..zeromem					;\ snap speed mem to 0 if current speed is 0
		STZ !CameraSpeedMem1				;/
		..pausecamera					;\
		LDA !CameraPauseTime : STA !CameraPauseTimer	; > pause time
	BRA ..usemem
		BRA ..done					;/
		..goingleft					;\
		BIT !CameraSpeedMem1 : BPL ..zeromem		; | comparison with left-facing speed
		CMP !CameraSpeedMem1 : BCC ..pausecamera	;/
		..usemem					;\
		LDA !CameraSpeedMem1				; |
		AND #$FF00					; |
		BPL $03 : ORA #$00FF				; | overwrite speed with memory
		XBA						; |
		STA $04						; |
		..done						;/



		.SpeedAdjust
		LDA $04						;\
		BPL $04 : EOR #$FFFF : INC A			; |
		STZ $2250					; | camera power calc setup
		STA $2251					; |
		LDA !CameraPower : STA $2253			;/
		LDA $06 : BEQ ..locky				; 0 -> lock
		LDA #$0060					;\
		SEC : SBC !CameraYThreshold			; | get camera up threshold
		STA $00						;/
		LDA #$0060					;\
		CLC : ADC !CameraYThreshold			; | get camera down threshold
		STA $02						;/
		CMP $00 : BEQ ..playery				; zero threshold check
		LDA $0E						;\
		SEC : SBC $1C					; | player on-screen Y
		STA $0A						;/
		BMI ..moveup					; negative -> always move up
		CMP $00						;\
		BEQ ..moveup					; | check up threshold
		BCC ..moveup					;/
		CMP $02 : BCS ..movedown			; check down threshold
		LDA !CameraYDir : BEQ ..locky			; no dir set -> lock
		EOR $06 : BPL +					;\ player moving in different dir from camera -> clear
		STZ !CameraYDir					;/
	+	LDA !CameraYDir					;\
		BMI ..moveup					; | allow camera to keep moving even if player is in center
		BNE ..movedown					;/ (as long as dir is set)

		..locky						;\ lock: keep current coordinate
		LDA $1C : BRA ..sety				;/
		..movedown					;\
		LDA #$0001 : STA !CameraYDir			; |
		LDA $1C						; | move down coord
		CLC : ADC $02					; |
		BRA ..calcy					;/
		..moveup					;\
		LDA !CameraYDir					; |
		BEQ $02 : BPL ..movedown			; |
		LDA #$FFFF : STA !CameraYDir			; | move up coord
		LDA $1C						; |
		CLC : ADC $00					; |
		CMP $0E : BCS ..calcy				; |
		..playery					; |
		LDA $0E						;/
		..calcy						;\
		SEC : SBC #$0070				; |
		BPL $03 : LDA #$0000				; | adjust target Y coord
		..sety						; |
		STA $0E						;/

		LDA $0C						;\
		SEC : SBC #$0077				; | get ideal camera X
		BPL $03 : LDA #$0000				; |
		STA $02						;/
		LDA $2307					;\
		CMP !CameraMaxPower				; |
		BCC $03 : LDA !CameraMaxPower			; > camera max power
		BIT $04						; | adjust target X coord based on camera power
		BPL $04 : EOR #$FFFF : INC A			; |
		CLC : ADC $0C					; |
		SEC : SBC #$0077				; |
		BPL $03 : LDA #$0000				;/
		LDY !CameraPauseTimer : BEQ ..setx		;\
		CMP $1A : BCC ..moveleft			; |
		..moveright					; |
		BIT !CameraSpeedMem2 : BPL ..setx		; |
		BRA ..lockx					; |
		..moveleft					; | camera can never move backwards while pause timer is set
		BIT !CameraSpeedMem2 : BMI ..setx		; |
		..lockx						; |
		LDA $1A						; |
		..setx						; |
		STA $0C						;/


		.CameraSpeed
		LDA $04						;\
		BPL $04 : EOR #$FFFF : INC A			; |
		LSR #4						; |
		INC A						; | camera X speed
		CMP #$0007					; |
		BCC $03 : LDA #$0007				; |
		STA !CameraXSpeed				;/
		LDA $06						;\
		BPL $04 : EOR #$FFFF : INC A			; |
	; Y uses whole px now
	;	LSR #4						; |
		INC A						; | camera Y speed
		CMP #$0007					; |
		BCC $03 : LDA #$0007				; |
		STA !CameraYSpeed				;/
		REP #$30					; all regs 16-bit for these


		.HorizontalScroll
		LDA !EnableHScroll				;\
		AND #$00FF : BEQ ..done				; | horizontal scroll checks
		LDA $08 : BNE ..done				;/
		LDA !LevelWidth					;\
		AND #$00FF					; | $00 = level width
		DEC A						; |
		XBA : STA $00					;/

		LDA $02						;\
		SEC : SBC $1A					; | X = |distance to ideal target|
		BPL $04 : EOR #$FFFF : INC A			; |
		TAX						;/
		LDA $0C						;\
		SEC : SBC $1A					; |
		BPL $04 : EOR #$FFFF : INC A			; | check for snap
		CMP !CameraXSpeed : BCS ..calc			; |
		..snap						; |
		LDA $0C : BRA ..set				;/
		..calc						;\
		LDA $1A						; | check direction
		CMP $0C : BCC ..add				;/
		..sub						;\
		BIT !CameraSpeedMem2 : BMI +			; | move left
	++	CPX !CameraMinPower : BCC ..done		; > minimum power
	+	SBC !CameraXSpeed : BRA ..set			;/
		..add						;\
		BIT !CameraSpeedMem2 : BPL +			; | move right
	++	CPX !CameraMinPower : BCC ..done		; > minimum power
		CLC						; |
	+	ADC !CameraXSpeed				;/
		..set						;\
		BPL $03 : LDA #$0000				; |
		CMP $00						; | update camera X coordinate
		BCC $02 : LDA $00				; |
		STA $1A						; |
		..done						;/


		.VerticalScroll
		LDA !EnableVScroll				;\ vertical scroll check
		AND #$00FF : BEQ ..done				;/
		LDA !HorzLevelMode				; horizontal level mode (second highest bit is "show bottom row of level")
		AND #$0040					;\
		BEQ $03 : LDA #$000F				; |
		CLC : ADC !LevelHeight				; | $00 = level height
		SBC #$00EF					; > note: C was for sure cleared so this subtracts 0xE0
		STA $00						;/

		LDA $0E						;\
		SEC : SBC $1C					; |
		BPL $04 : EOR #$FFFF : INC A			; |
		CMP !CameraYSpeed : BCS ..calc			; | check for snap threshold
		..snap						; |
		LDA $1C						; |
		LDA $0E : BRA ..set				;/
		..calc						;\
		LDA $1C						; | check direction
		CMP $0E : BCC ..add				;/
		..sub						;\
		SBC !CameraYSpeed				; | move up
		BRA ..set					;/
		..add						;\ move down
		ADC !CameraYSpeed				;/
		..set						;\
		BPL $03 : LDA #$0000				; |
		CMP $00						; | update camera Y coordinate
		BCC $02 : LDA $00				; |
		STA $1C						; |
		..done						;/

		SEP #$10					; index 8-bit






	.CameraBox
		LDA !CameraBoxU : BMI ..done			;\> if top border < 0, no camera box exists
		CMP $1C						; | camera box top border
		BCC $02 : STA $1C				;/
		LDA !CameraBoxD					;\
		CMP $1C						; | camera box bottom border
		BCS $02 : STA $1C				;/
		LDA !CameraBoxL					;\
		CMP $1A						; | camera box left border
		BCC $02 : STA $1A				;/
		LDA !CameraBoxR					;\
		CMP $1A						; | camera box right border
		BCS $02 : STA $1A				;/

		LDX #$02					;\
		..loop						; |
		LDY #$00					; |
		LDA $1A,x					; |
		CMP !CameraBackupX,x : BEQ ..next		; | special backup for camera box
		BCC $02 : LDY #$02				; |
		STY $55						; |
		..next						; |
		DEX #2 : BPL ..loop				;/
		..done



	.CalcLightPoints
		LDA !LightPointIndex : BNE ..process		; if there are light points, process them
		JMP ..done					; otherwise skip
		..process					;
		PHP						;\ reg setup
		REP #$30					;/
		LDA $1A						;\
		CLC : ADC #$0080				; |
		STA $00						; | center coords
		LDA $1C						; |
		CLC : ADC #$0070				; |
		STA $02						;/
		STZ $08						;\
		STZ $0A						; | reset counters
		STZ $0C						; |
		STZ $0E						;/
		STZ $2250					; multiplication
		LDX #$0000					; index = 0
		..loop						;\
		LDA !LightPointX,x				; |
		SEC : SBC $00					; |
		BPL $04 : EOR #$FFFF : INC A			; |
		STA $04						; |
		LDA !LightPointY,x				; | total distance - size
		SEC : SBC $02					; |
		BPL $04 : EOR #$FFFF : INC A			; |
		CLC : ADC $04					; |
		SEC : SBC !LightPointS,x			; |
		BPL ..next					;/
		EOR #$FFFF : INC A				;\
		CMP #$0100					; |
		BCC $03 : LDA #$0100				; | strength is size - 256, capped at 256
		STA $2251					; |
		CLC : ADC $08					; |
		STA $08						;/
		LDA !LightPointR,x : STA $2253			;\
		NOP : BRA $00					; |
		LDA $2307 : STA $04				; |
		LDA !LightPointG,x : STA $2253			; | scale R, G and B based on distance
		NOP : BRA $00					; |
		LDA $2307 : STA $06				; |
		LDA !LightPointB,x : STA $2253			;/
		LDA $04						;\
		CLC : ADC $0A					; |
		STA $0A						; |
		LDA $06						; |
		CLC : ADC $0C					; | add scaled RGB values
		STA $0C						; |
		LDA $2307					; |
		CLC : ADC $0E					; |
		STA $0E						;/
		..next						;\
		TXA						; |
		CLC : ADC #$000C				; | loop through all loaded light points
		CMP !LightPointIndex : BCS ..finish		; |
		TAX						; |
		JMP ..loop					;/
		..finish					;\
		LDA $08						; |
		CMP #$0100 : BCS ..nocomplement			; | make sure at least 100% of light variance is accounted for
		SBC #$0100					; |
		EOR #$FFFF					; |
		STA $08						;/
		CLC : ADC $0A					;\
		STA $0A						; |
		LDA $08						; |
		CLC : ADC $0C					; |
		STA $0C						; | complement with white light up to 100%
		LDA $08						; |	
		CLC : ADC $0E					; |
		STA $0E						; |
		..nocomplement					;/
		LDA $0A : STA !LightR				;\
		LDA $0C : STA !LightG				; | update RGB
		LDA $0E : STA !LightB				;/
		PLP						;\ restore P
		..done						;/

	.Backgrounds
		JSL BG2Controller				; scroll BG2
		LDA !WindowDir					;\
		AND #$00FF : BEQ ..notclosing			; |
		..correctBG3					; | check for text box closing
		JSL BG3Controller				; | this is necessary on modes 1 and 2
		LDA $22 : STA $400000+!MsgBackup22		; | otherwise BG3 can jump when the background is restored
		LDA $24 : STA $400000+!MsgBackup24		; |
		BRA ..done					;/
		..notclosing					;\
		LDA !MsgTrigger : BNE ..done			; | otherwise, ignore BG3 while text box is open
		JSL BG3Controller				; |
		..done						;/

>>>>>>> Stashed changes
		PLP
		PLB
		RTL


	.ForceTableY
		dw $0000,$0000
	.ForceTableX
		dw $0008,$FFF8,$0000,$0000

	.SmoothSpeed
		dw $0006,$FFFA

<<<<<<< Updated upstream
	.CameraOffset
		dw $0100,$00E0
	.CameraCenter
		dw $0080,$0070


		.CameraBox
		PHB : PHK : PLB
		PHP
		SEP #$10
		REP #$20

		JSR .Aim					; get camera target
		JSR .Forbiddance				; apply forbiddance box
		JSR .Process					; process movement

		LDX #$02					;\
	-	LDY #$00					; |
		LDA $1A,x					; |
		CMP !CameraBackupX,x : BEQ +			; | special backup for camera box
		BCC $02 : LDY #$02				; |
		STY $55						; |
	+	DEX #2 : BPL -					;/

		LDA !CameraBoxL					;\
		SEC : SBC #$0020				; |
		STA $04						; |
		LDA !CameraBoxR					; |
		CLC : ADC #$0110				; |
		STA $06						; | coords from box borders
		LDA !CameraBoxU					; |
		SEC : SBC #$0020				; |
		STA $08						; |
		LDA !CameraBoxD					; |
		CLC : ADC #$00F0				; |
		STA $0A						;/

		LDX #$0F					;\
	-	LDY $3230,x : BNE $03 : JMP .Next		; |
		LDA $3470,x					; |
		ORA #$0004					; |
		STA $3470,x					; |
		LDY !CameraForceTimer : BNE .Freeze		; |
		LDY $3220,x : STY $00				; | search for sprites to interact with
		LDY $3250,x : STY $01				; |
		LDY $3210,x : STY $02				; |
		LDY $3240,x : STY $03				; |
		LDA $00						; |
		SEC : SBC $04					; |
		BPL .CheckR					; |
		CMP #$FF00 : BCC .Delete			; |
		CMP #$FFE0 : BCC .Freeze			;/

	.Delete	LDA $3230,x					;\
		AND #$FF00					; |
		STA $3230,x					; |
		LDY $33F0,x					; |
		CPY #$FF : BEQ .Next				; |
		PHX						; |
		TYX						; | delete sprite
		LDA $418A00,x					; |
		AND #$00FF					; |
		CMP #$00EE : BEQ +				; |
		LDA $418A00,x					; |
		AND #$FF00					; |
		STA $418A00,x					; |
	+	PLX						; |
		BRA .Next					;/

	.CheckR	LDA $00						;\
		SEC : SBC $06					; |
		BMI .GoodX					; | see if fully outside
		CMP #$0020 : BCC .Delete			; |
		CMP #$0100 : BCS .Delete			;/

	.Freeze	LDA !SpriteStasis,x				;\
		ORA #$0002					; | freeze sprite
		STA !SpriteStasis,x				; |
		BRA .Next					;/

	.GoodX	LDA $02						;\
		CMP $08 : BMI .Freeze				; | see if sprite should freeze
		CMP $0A : BPL .Freeze				;/
	.Next	DEX : BMI $03 : JMP -				; > next sprite

		PLP						; return
		PLB
		RTS


		.Aim
		LDA !P2XPosLo-$80				;\
		CLC : ADC !P2XPosLo				; |
		LSR A						; |
		SEC : SBC #$0080				; |
		CMP #$4000					; |
		BCC $03 : LDA #$0000				; |
		STA $1A						; |
		LDA !P2YPosLo-$80				; | logic for finding camera target
		CLC : ADC !P2YPosLo				; |
		LSR A						; |
		SEC : SBC #$0070				; |
		CMP #$4000					; |
		BCC $03 : LDA #$0000				; |
		STA $1C						; |
		RTS						;/

		.Process
		LDX #$02
	-	LDA $1A,x
		CMP !CameraBoxL,x : BCS +
		LDA !CameraBoxL,x : STA $1A,x
		BRA ++
	+	CMP !CameraBoxR,x : BCC ++ : BEQ ++
		LDA !CameraBoxR,x : STA $1A,x
	++	LDA !CameraBackupX,x				; apply smooth camera
		CMP $1A,x : BEQ +
		LDY #$00
		BCC $02 : LDY #$02
		CLC : ADC.w .SmoothSpeed,y
		STA $00
		LDA !CameraBackupX,x
		SEC : SBC $1A,x
		BPL $04 : EOR #$FFFF : INC A
		CMP #$0006 : BCC +
		LDA $00 : STA $1A,x
	;	TXA
	;	EOR #$0002
	;	TAX
	;	LDA !CameraBackupX,x : STA $1A,x
	;	BRA .Absolute
	+	DEX #2 : BPL -
	..R	RTS


		.Absolute
		LDA $1A,x
		CMP !CameraBoxL,x : BCS +
		LDA !CameraBoxL,x : STA $1A,x
		RTS
	+	CMP !CameraBoxR,x : BCC + : BEQ +
		LDA !CameraBoxR,x : STA $1A,x
	+	RTS


		.Forbiddance
		LDX !CameraForbiddance
		CPX #$FF : BEQ .Process_R
		LDA !CameraForbiddance
		AND #$003F
		TAX

		LDA !CameraBoxU : STA $0A	; forbiddance top border start
		LDA !CameraBoxL
	-	CPX #$00 : BEQ +
		DEX
		CLC : ADC #$0100
		STA $08
		CMP !CameraBoxR : BCC - : BEQ -
		LDA $0A
		CLC : ADC #$00E0
		STA $0A				; forbiddance top border
		LDA !CameraBoxL
		BRA -

	+	STA $08				; forbiddance left border
		LDA !CameraForbiddance
		ASL #2
		AND #$1F00
		CLC : ADC $08
		CLC : ADC #$0100
		STA $0C				; forbiddance right border
		LDA !CameraForbiddance
		AND #$F800
		LSR #3
		PHA
		LSR #3
		STA $0E
		PLA
		SEC : SBC $0E
		CLC : ADC $0A
		CLC : ADC #$00E0
		STA $0E				; forbiddance bottom border


		LDA $1A
		CMP $0C : BCS .NoForbid
		ADC #$0100
		CMP $08 : BCC .NoForbid
		LDA $1C
		CMP $0E : BCS .NoForbid
		ADC #$00E0
		CMP $0A : BCC .NoForbid


		LDX #$02
	-	LDA $08,x
		CLC : ADC $0C,x
		LSR A
		STA !BigRAM+0
		LDA $1A,x
		CLC : ADC .CameraCenter,x
		CMP !BigRAM+0
		BCS ..RD
	..LU	LDA $08,x : STA $00,x
		SEC : SBC .CameraOffset,x
		BRA +
	..RD	LDA $0C,x : STA $00,x
	+	SEC : SBC $1A,x
		BPL $04 : EOR #$FFFF : INC A
		STA $04,x
		DEX #2 : BPL -


		LDX #$00
		LDA $04
		CMP $06
		BCC $02 : LDX #$02
		LDA $00,x
		CMP !CameraBoxL,x : BNE +
		TXA
		EOR #$0002
		TAX
		LDA $00,x
	+	CMP $08,x : BNE +
		SEC : SBC .CameraOffset,x
		BPL $03 : LDA #$0000
	+	STA $1A,x

		.NoForbid
		RTS



	.InitCamera
		PHP						;\
		SEP #$20					; |
		LDX !Level					; |
		LDA.l .LevelTable,x				; |
		LDX !Level+1					; |
		AND.l .LevelSwitch,x				; |
		BEQ .NormalCoords				; |
		CMP #$10 : BCC +				; |
		LSR #4						; | game mode 0x11 = INIT camera
	+	DEC A						; |
		ASL A						; |
		CMP.b #.CoordsEnd-.CoordsPtr			; |
		BCS .NormalCoords				; |
		TAX						; |
		JSR (.CoordsPtr,x)				; |
	.NormalCoords						; |
		PLP						; |
		JMP .EndBox					;/


; honestly i don't really know what this is...
; some way of setting camera coords on level init?

; lo nybble is used by levels 0x000-0x0FF, hi nybble is used by levels 0x100-0x1FF
; 0 means it's unused, so just use normal coords
; any other number is treated as an index to the coordinate routine pointer table

.LevelTable	db $00,$00,$00,$00,$00,$00,$00,$00		; 00-07
		db $00,$00,$00,$00,$00,$00,$00,$00		; 08-0F
		db $00,$00,$00,$00,$01,$00,$00,$00		; 10-17
		db $00,$00,$00,$00,$00,$00,$00,$00		; 18-1F
		db $00,$00,$00,$00,$00,$00,$00,$00		; 20-27
		db $00,$00,$00,$00,$00,$00,$00,$00		; 28-2F
		db $00,$00,$00,$00,$01,$00,$00,$00		; 30-37
		db $00,$00,$00,$00,$00,$00,$00,$00		; 38-3F
		db $00,$00,$00,$00,$00,$00,$00,$00		; 40-47
		db $00,$00,$00,$00,$00,$00,$00,$00		; 48-4F
		db $00,$00,$00,$00,$00,$00,$00,$00		; 50-57
		db $00,$00,$00,$00,$00,$00,$00,$00		; 58-5F
		db $00,$00,$00,$00,$00,$00,$00,$00		; 60-67
		db $00,$00,$00,$00,$00,$00,$00,$00		; 68-6F
		db $00,$00,$00,$00,$00,$00,$00,$00		; 70-77
		db $00,$00,$00,$00,$00,$00,$00,$00		; 78-7F
		db $00,$00,$00,$00,$00,$00,$00,$00		; 80-87
		db $00,$00,$00,$00,$00,$00,$00,$00		; 88-8F
		db $00,$00,$00,$00,$00,$00,$00,$00		; 90-97
		db $00,$00,$00,$00,$00,$00,$00,$00		; 98-9F
		db $00,$00,$00,$00,$00,$00,$00,$00		; A0-A7
		db $00,$00,$00,$00,$00,$00,$00,$00		; A8-AF
		db $00,$00,$00,$00,$00,$00,$00,$00		; B0-B7
		db $00,$00,$00,$00,$00,$00,$00,$00		; B8-BF
		db $00,$00,$00,$00,$00,$00,$00,$00		; C0-C7
		db $00,$00,$00,$00,$00,$00,$00,$00		; C8-CF
		db $00,$00,$00,$00,$00,$00,$00,$00		; D0-D7
		db $00,$00,$00,$00,$00,$00,$00,$00		; D8-DF
		db $00,$00,$00,$00,$00,$00,$00,$00		; E0-E7
		db $00,$00,$00,$00,$00,$00,$00,$00		; E8-EF
		db $00,$00,$00,$00,$00,$00,$00,$00		; F0-F7
		db $00,$00,$00,$00,$00,$00,$00,$00		; F8-FF


.LevelSwitch	db $0F,$F0

	; this is entered with all regs 8-bit
	; PLP is used at return, so no need to bother keeping track of P
	.CoordsPtr
	dw .Coords1
	.CoordsEnd
=======
	.GetPlayerCoords
		LDA !P2InAir-$80,y : BNE ..air			; airborne flag
		..ground					;\
		STZ !CameraYDir					; | camera y direction
		STZ !CameraYDir+1				; |
		..air						;/

		LDA !P2XSpeed-$80,y : STA $04			;\
		STZ $05						; | player X speed
		BPL $02 : DEC $05				;/
		LDA !P2YDelta-$80,y : STA $06			;\
		STZ $07						; | player Y speed
		BPL $02 : DEC $07				;/

		REP #$20					; A 16-bit
		LDA !P2VectorX-1-$80,y				;\
		AND #$FF00					; |
		STA $0C						; | vector speed bits
		LDA !P2VectorY-1-$80,y				; |
		AND #$FF00					; |
		STA $0E						;/
		LDX #$00					;\
		LDA !P2XSpeedFraction-$80,y			; |
		CLC : ADC $0C					; |
		LSR #4						; |
		AND #$0FF0					; |
		CMP #$0800					; |
		BCC $04 : ORA #$F000 : DEX			; |
		SEP #$20					; | X position
		CLC : ADC !P2XFraction-$80,y			; |
		XBA						; |
		ADC !P2XPosLo-$80,y				; |
		STA $0C						; |
		TXA						; |
		ADC !P2XPosHi-$80,y				; |
		STA $0D						;/
		LDX #$00					;\
		REP #$20					; |
		LDA !P2YSpeedFraction-$80,y			; |
		CLC : ADC $0E					; |
		LSR #4						; |
		AND #$0FF0					; |
		CMP #$0800					; |
		BCC $04 : ORA #$F000 : DEX			; | Y position
		SEP #$20					; |
		CLC : ADC !P2YFraction-$80,y			; |
		XBA						; |
		ADC !P2YPosLo-$80,y				; |
		STA $0E						; |
		TXA						; |
		ADC !P2YPosHi-$80,y				; |
		STA $0F						;/
>>>>>>> Stashed changes

		LDX !P2Platform-$80,y : BEQ ..noplat		; check for platform
		REP #$20					;\
		DEX						; |
		LDA !SpriteDeltaX,x				; |
		AND #$00FF					; |
		CMP #$0080					; |
		BCC $03 : ORA #$FF00				; |
		CLC : ADC $0C					; |
		STA $0C						; | apply platform displacement
		LDA !SpriteDeltaY,x				; |
		AND #$00FF					; |
		CMP #$0080					; |
		BCC $03 : ORA #$FF00				; |
		CLC : ADC $0E					; |
		STA $0E						; |
		SEP #$20					; |
		..noplat					;/

		RTS						; return





; BG2 controller
	BG2Controller:
		LDY #$01			; Y = division bit

	.CalcHorz
		LDA !BG2ModeH
		ASL A : TAX
		LDA.l .ScrollFactor,x
		CMP #$0001 : BNE ..multi
		LDA $1A : BRA ..div

		..multi
		STZ $2250
		STA $2251
		LDA $1A : STA $2253
		NOP : BRA $00
		LDA $2306

		..div
		STY $2250
		STA $2251
		LDA.l .ScrollDivisor,x : STA $2253
		NOP : BRA $00
		LDA $2306 : STA $1E

	.CalcVert
		LDA !BG2ModeV
		ASL A : TAX
		LDA.l .ScrollFactor,x
		CMP #$0001 : BNE ..multi
		LDA $1C : BRA ..div

		..multi
		STZ $2250
		STA $2251
		LDA $1C : STA $2253
		NOP : BRA $00
		LDA $2306

		..div
		STY $2250
		STA $2251
		LDA.l .ScrollDivisor,x : STA $2253
		NOP
		LDA !BG2BaseV
		CLC : ADC $2306
		STA $20
		RTL

; cheat sheet:
; 0 = 0%	none
; 1 = 100%	constant
; 2 = 50%	variable
; 3 = 6.25%	variable 4	changed from lunar magic's slow (3.125%)
; 4 = 25%	variable 2
; 5 = 12.5%	variable 3
; 6 = 87.5%	close		changed from lunar magic's variable 4 (6.25%)
; 7 = 75%	close 2		changed from lunar magic's slow 2 (1.5625%)
; 8 = 43.75%	close half
; 9 = 37.5%	close 2 half
; A = 40%	40%
; B = 200%	double


	.ScrollFactor
		dw $0000	; 00
		dw $0001	; 01
		dw $0001	; 02
		dw $0001	; 03
		dw $0001	; 04
		dw $0001	; 05
		dw $0007	; 06
		dw $0003	; 07
		dw $0007	; 08
		dw $0003	; 09
		dw $0002	; 0A
		dw $0002	; 0B

	.ScrollDivisor
		dw $0001	; 00
		dw $0001	; 01
		dw $0002	; 02
		dw $0010	; 03
		dw $0004	; 04
		dw $0008	; 05
		dw $0008	; 06
		dw $0004	; 07
		dw $0010	; 08
		dw $0008	; 09
		dw $0005	; 0A
		dw $0001	; 0B


; LM hijack at $05C40C (JSL)
	BG3Controller:
		LDA !BG3BaseSettings
		LSR A : BCS .Bypass
		RTL

		.Bypass
		LDY !BG3ScrollSettings
		REP #$20
		TYA
		AND #$000F
		ASL A
		TAX
		LDA $1A
		JMP (.HPtr,x)

		.HPtr
		dw .NoHorz		; 0 - 0%
		dw .ConstantHorz	; 1 - 100%
		dw .VariableHorz	; 2 - 50%
		dw .Variable2Horz	; 3 - 25%
		dw .Slow2Horz		; 4 - 3%
		dw .SlowHorz		; 5 - 6% (unused by LM)
		dw .AutoXSlow		; 6 - speed + slow
		dw .AutoXConstant	; 7 - speed + constant
		dw .AutoXFast		; 8 - speed + variable
		dw .AutoXFast2		; 9 - speed + constant
		dw .AutoXSlow		; A - speed + slow
		dw .AutoXConstant	; B - speed + constant
		dw .AutoXFast		; C - speed + variable
		dw .AutoXFast2		; D - speed + constant
		dw .Variable3Horz	; E - 12% (unused by LM)
		dw .NoHorz		; F - 0% (UNUSED)

.AutoXFast2	JSR .AutoX
		BRA .ConstantHorz

.AutoXFast	JSR .AutoX
		BRA .VariableHorz

.AutoXSlow	JSR .AutoX
		BRA .SlowHorz

.AutoXConstant	JSR .AutoX
		BRA .ConstantHorz

.AutoX		LDX $9D : BEQ ..run
		LDA !BG3XFraction
		BRA +
	..run	LDA !BG3XSpeed
		JSR .12percent
		CLC : ADC !BG3XFraction
		STA !BG3XFraction
	+	LSR #3
		BIT !BG3XFraction
		BPL $03 : ORA #$E000
		CLC : ADC $1A
		RTS

.Slow2Horz	LSR A
.SlowHorz	LSR A
.Variable3Horz	LSR A
.Variable2Horz	LSR A
.VariableHorz	LSR A
.ConstantHorz	CLC : ADC !BG3BaseH
		BRA +
.NoHorz		LDA !BG3BaseH
	+	STA $22


		LDA !BG3BaseSettings
		AND #$00F8
		ASL A
		STA $00

		TYA
		AND #$00F0
		LSR #3
		TAX
		LDA $1C
		JMP (.VPtr,x)

		.VPtr
		dw .NoVert		; 0 - 0%
		dw .ConstantVert	; 1 - 100%
		dw .VariableVert	; 2 - 50%
		dw .Variable2Vert	; 3 - 25%
		dw .Slow2Vert		; 4 - 3%
		dw .SlowVert		; 5 - 6% (unused by LM)
		dw .AutoYSlow		; 6 - speed + slow
		dw .AutoYConstant	; 7 - speed + constant
		dw .AutoYFast		; 8 - speed + variable
		dw .AutoYFast2		; 9 - speed + constant
		dw .AutoYSlow		; A - speed + slow
		dw .AutoYConstant	; B - speed + constant
		dw .AutoYFast		; C - speed + variable
		dw .AutoYFast2		; D - speed + constant
		dw .Variable3Vert	; E - 12% (unused by LM)
		dw .NoVert		; F - 0% (UNUSED)

.AutoYFast2	JSR .AutoY
		BRA .ConstantVert

.AutoYFast	JSR .AutoY
		BRA .VariableVert

.AutoYSlow	JSR .AutoY
		BRA .SlowVert

.AutoYConstant	JSR .AutoY
		BRA .ConstantVert

.AutoY		LDX $9D : BEQ ..run
		LDA !BG3YFraction
		BRA +
	..run	LDA !BG3YSpeed
		JSR .12percent
		CLC : ADC !BG3YFraction
		STA !BG3YFraction
	+	LSR #3
		BIT !BG3YFraction
		BPL $03 : ORA #$E000
		CLC : ADC $1C
		RTS

.Slow2Vert	LSR A
.SlowVert	LSR A
.Variable3Vert	LSR A
.Variable2Vert	LSR A
.VariableVert	LSR A
.ConstantVert	CLC : ADC $00
		BRA +
.NoVert		LDA $00
	+	STA $24
		SEP #$20
		RTL


.12percent	BPL ..pos
	..neg	EOR #$FFFF
		LSR #3
		EOR #$FFFF
		RTS
	..pos	LSR #3
		RTS




<<<<<<< Updated upstream
namespace off
=======


	LoadCameraBox:
		STA $00						; $00 = .RoomPointers
		SEP #$10					; index 8-bit
		LDA ($00) : STA $08				; $08 = screen matrix
		LDY #$02					;\ $0A = box table
		LDA ($00),y : STA $0A				;/
		SEP #$20					; A 8-bit

		.HandleTransition
		LDA !CameraForceTimer : BEQ ..done		; check for door transition
		LDA !CameraForceDir				;\
		CMP #$04 : BCS ..done				; |
		EOR #$02					; |
		BEQ $02 : LDA #$28				; |
		SEC : SBC #$14					; |
		STA $00						; |
		SEC : SBC !P2XSpeed-$80				; | player X speeds during door transitions
		STA !P2VectorX-$80				; |
		LDA $00						; |
		SEC : SBC !P2XSpeed				; |
		STA !P2VectorX					; |
		STZ !P2VectorAccX-$80				; |
		STZ !P2VectorAccX				; |
		..done						;/

		LDA !P2Status-$80 : BEQ .GetCoords		;\ if at least one player is alive, run rest of camera box code
		LDA !P2Status : BEQ .GetCoords			;/
		RTL						; otherwise return


		.GetCoords
		LDA !P2Status-$80 : BNE ..p2			; P1 dead -> P2 camera
		LDA !P2Status : BNE ..p1			; P2 dead -> P1 camera
		..composite					; both alive -> composite camera
		REP #$20					;\
		LDA !P2XPosLo-$80				; |
		CLC : ADC !P2XPosLo				; |
		ROR A : STA $00					; | composite coords
		LDA !P2YPosLo-$80				; |
		CLC : ADC !P2YPosLo				; |
		ROR A : STA $02					; |
		BRA ..snap0					;/
		..p1						;\
		REP #$20					; |
		LDA !P2XPosLo-$80 : STA $00			; | P1 coords
		LDA !P2YPosLo-$80 : STA $02			; |
		BRA ..snap0					;/
		..p2						;\
		REP #$20					; | P2 coords
		LDA !P2XPosLo : STA $00				; |
		LDA !P2YPosLo : STA $02				;/
		..snap0						;\
		LDA $00						; |
		BPL $03 : LDA #$0000				; | don't allow negative coords
		XBA : STA $00					; | also swap X lo/hi
		LDA $02						; |
		BPL $02 : STZ $02				;/

		.CalcRoom
		LDX #$01 : STX $2250				;\
		LDA $02						; |
		CMP !LevelHeight				; | calculate y screen (y / 0xE0)
		BCC $04 : LDA !LevelHeight : DEC A		; |
		STA $2251					; |
		LDA #$00E0 : STA $2253				;/
		LDA !LevelWidth					;\
		AND #$00FF					; |
		LDX $2306					; | 
		STZ $2250					; | calculate y component of index (y screen * level width)
		STA $2251					; |
		TXA						; |
		AND #$00FF : STA $2253				;/
		LDA $00						;\
		AND #$00FF					; | add x component of index (x screen)
		CLC : ADC $2306					;/

		TAY						;\ read room number
		LDA ($08),y					;/
		AND #$00FF : STA !BigRAM+0			; !BigRAM+0 = room number
		STZ !BigRAM+2					; clear new room flag
		STZ !BigRAM+4					;\ !BigRAM+4 = index of current room (16-bit format)
		STY !BigRAM+4					;/
		TAY						;\
		CPY !CameraBoxRoom				; | store room index and check for change
		STY !CameraBoxRoom				; |
		BEQ ..done					;/
		INC !BigRAM+2					; set new room flag
		..done


		.HorzTransition
		LDX !GameMode
		CPX #$14 : BNE +
		LDX !LockBox : BNE +
		LDX !CameraForceTimer : BNE +
		..p1
		LDX !P2Status-$80 : BNE ..p2
		LDY #$00 : JSR ..checkborder
		..p2
		LDX !P2Status : BNE +
		LDY #$80 : JSR ..checkborder
	+	JMP ..done

		..checkborder
		LDA !P2XSpeed-$80,y
		CLC : ADC !P2VectorX-$80,y
		BIT #$0080 : BEQ +
		LDA !CameraBoxL : BEQ +
		LDA !P2XPosLo-$80,y
		SEC : SBC !CameraBoxL
		BMI ..l
		BEQ ..l
	+	LDA !P2XSpeed-$80,y
		CLC : ADC !P2VectorX-$80,y
		BIT #$0080 : BNE ...return
		LDA !LevelWidth
		DEC A : XBA
		AND #$FF00
		CMP !CameraBoxR : BEQ ...return
		LDA !P2XPosLo-$80,y
		SEC : SBC #$0100
		SEC : SBC !CameraBoxR
		BPL ..r
		CMP #$FFF0 : BCS ..r
		...return
		RTS
		..r
		INC !BigRAM+4					; room index +1
		LDA #$0000 : BRA +
		..l
		DEC !BigRAM+4					; room index -1
		LDA #$0002
	+	SEP #$20
		STA !CameraForceDir
		LDA #$20					;\
		STA !CameraForceTimer				; | move camera + players
		STA !P2VectorTimeX-$80				; |
		STA !P2VectorTimeX				;/
		REP #$20					;\
		LDA !P2XPosLo-$80,y : STA $0C			; |
		LDA !P2YPosLo-$80,y : STA $0E			; |
		TYA						; | make sure both players are in position
		EOR #$0080 : TAY				; |
		LDA $0C : STA !P2XPosLo-$80,y			; |
		LDA $0E : STA !P2YPosLo-$80,y			;/

		LDY !BigRAM+4					;\
		LDA ($08),y					; | get room number of room camera is moving into
		AND #$00FF					;/
		ASL #2						;\
		INC A						; > +2 with the ASL A after
		ASL A						; | get index to box data
		ADC $0A						; |
		STA $0C						;/
		LDY #$04					;\ $0E = bottom border
		LDA ($0C),y : STA $0E				;/
		LDA ($0C) : STA $0C				; $0C = top border
		LDA $1C						;\
		CMP $0C : BCC ..chain				; |
		CMP $0E						; |
		BEQ ..nochain					; | only chain if vertically out of bounds
		BCC ..nochain					; |
		..chain						; |
		JSR .CameraChain				; |
		..nochain					;/
		REP #$20
		RTS
		..done


	; camera box
	.HandleBox
		LDA !BigRAM+0					;\
		ASL #3						; | get index to room's camera box data
		ADC $0A						; |
		STA $0A						;/
		LDY !GameMode					;\ same room in other game modes
		CPY #$14 : BNE ..samebox			;/
		LDA !LevelMainFlag				;\ same room if level is not in MAIN
		AND #$00FF : BEQ ..samebox			;/
		LDA !BigRAM+2 : BNE ..newbox			; check for new room
		..samebox					;\
		JSR .Load					; | load box data and return
		RTL						;/

		..newbox
		LDA !SpriteEraseMode				;\
		AND #$003F					; | sprite erase mode 4: camera box not allowed to touch
		CMP #$0004 : BEQ ..noerase			;/
		LDY #$0F					;\
		..loop						; |
		LDX !SpriteXLo,y : STX $02			; | get sprite coords
		LDX !SpriteXHi,y : STX $03			; |
		LDX !SpriteYLo,y : STX $04			; |
		LDX !SpriteYHi,y : STX $05			;/
		LDX #$02					;\
		..nextcoord					; |
		LDA $02,x					; | check if sprite is within old room's camera box
		CMP !CameraBoxL,x : BCC ..next			; |
		SBC .Offset,x					; |
		CMP !CameraBoxR,x : BCS ..next			;/
		..erase						;\
		LDA !SpriteStatus,y				; |
		AND #$FF00 : STA !SpriteStatus,y		; |
		PHX						; |
		LDX !SpriteID,y					; |
		LDA !SpriteLoadStatus,x				; | if not, despawn it and mark it for respawn
		AND #$00FF					; | (unless marked as "never respawn")
		CMP #$00EE : BEQ ..keep				; |
		LDA !SpriteLoadStatus,x				; |
		AND #$FF00 : STA !SpriteLoadStatus,x		; |
		..keep						; |
		PLX						;/
		..next						;\ check X/Y coords
		DEX #2 : BPL ..nextcoord			;/
		DEY : BPL ..loop				; loop for all sprites
		..noerase

		JSR .Load					; load box data for new room

		LDA !CameraForceTimer : BNE .End		; checks both slots at once with 16-bit A
		.Y
		LDA !CameraBackupY				;\
		AND #$FFF8 : STA !CameraBackupY			; | check if camera has to be pushed vertically
		CMP !CameraBoxU : BEQ .X : BCC ..down		; |
		CMP !CameraBoxD : BEQ .X : BCC .X		;/
		..up						;\
		SBC !CameraBoxD					; |
		LSR #3						; |
		SEP #$20					; | push camera up
		STA !CameraForceTimer				; |
		LDA #$06 : STA !CameraForceDir			; |
		BRA .X						;/
		..down						;\
		SEC : SBC !CameraBoxU				; |
		EOR #$FFFF : INC A				; |
		LSR #3						; | push camera down
		SEP #$20					; |
		STA !CameraForceTimer				; |
		LDA #$04 : STA !CameraForceDir			;/
		.X
		REP #$20					;\
		LDA !CameraBackupX				; |
		AND #$FFF8 : STA !CameraBackupX			; | check if camera has to be pushed horizontally
		CMP !CameraBoxL : BEQ .End : BCC ..right	; |
		CMP !CameraBoxR : BEQ .End : BCC .End		;/
		..left						;\
		SBC !CameraBoxR					; |
		LSR #3						; |
		SEP #$20					; | push camera left
		STA !CameraForceTimer+1				; |
		LDA #$02 : STA !CameraForceDir+1		; |
		BRA .End					;/
		..right						;\
		SEC : SBC !CameraBoxL				; |
		EOR #$FFFF : INC A				; |
		LSR #3						; | push camera right
		SEP #$20					; |
		STA !CameraForceTimer+1				; |
		STZ !CameraForceDir+1				;/

		.End
		RTL


		.Offset
		dw $0100,$00E0




	.Load
		LDY #$06				; reset index
	-	LDA ($0A),y : STA !CameraBoxL,y		;\ get camera box data
		DEY #2 : BPL -				;/

		LDA !LevelHeight			;\
		SEC : SBC #$00E0			; |
		BPL $03 : LDA #$0000			; |
		CMP !CameraBoxD : BCS ..return		; | force camera box vertical boundaries within level borders
		STA !CameraBoxD				; |
		CMP !CameraBoxU : BCS ..return		; |
		STA !CameraBoxU				; |
		..return				;/

		RTS


; figure out which $E0 block the door is on vertically, then chain to that

	.CameraChain
		PHB : PHK : PLB
		LDY.b #.VerticalScreens_end-.VerticalScreens-2
		REP #$20
		LDA $1C
	-	CMP .VerticalScreens,y : BCS +
		DEY #2 : BPL -
		PLB
		RTS

	+	LDA .VerticalScreens,y
		SEC : SBC !CameraBackupY
		STA $02
		BPL $04 : EOR #$FFFF : INC A
		CMP #$0008 : BCS +
		LDA .VerticalScreens,y : STA !CameraBackupY
		PLB
		RTS

	+	LDA $02
		SEP #$20
		BPL ..D

	..U	EOR #$FF : INC A
		LDY #$06 : BRA +
	..D	LDY #$04
	+	STY !CameraForceDir+1
		LSR #3
		STA !CameraForceTimer+1
		STA !P2Stasis-$80
		STA !P2Stasis
		PLB
		RTS

		.VerticalScreens
		dw $E0*0
		dw $E0*1
		dw $E0*2
		dw $E0*3
		dw $E0*4
		dw $E0*5
		dw $E0*6
		dw $E0*7
		dw $E0*8
		dw $E0*9
		dw $E0*10
		dw $E0*11
		dw $E0*12
		dw $E0*13
		dw $E0*14
		dw $E0*15
		dw $E0*16
		dw $E0*17
		dw $E0*18
		dw $E0*19
		dw $E0*20
		dw $E0*21
		dw $E0*22
		dw $E0*23
		dw $E0*24
		dw $E0*25
		dw $E0*26
		dw $E0*27
		dw $E0*28
		dw $E0*29
		dw $E0*30
		dw $E0*31
		..end





macro cutscenewait(time)
		db $00,<time>
		endmacro

macro cutscenetextbox(msg)
		db $01
		dw <msg>
		endmacro

macro cutscenemusic(song)
		db $02,<song>
		endmacro

macro input6DA2(byte)
		db $03,<byte>
		endmacro
macro input6DA3(byte)
		db $04,<byte>
		endmacro
macro input6DA4(byte)
		db $05,<byte>
		endmacro
macro input6DA5(byte)
		db $06,<byte>
		endmacro
macro input6DA6(byte)
		db $07,<byte>
		endmacro
macro input6DA7(byte)
		db $08,<byte>
		endmacro
macro input6DA8(byte)
		db $09,<byte>
		endmacro
macro input6DA9(byte)
		db $0A,<byte>
		endmacro

macro endstay()
		db $0B
		endmacro

macro endloadlevel(level)
		db $0C
		dw <level>
		endmacro

macro endloadoverworld()
		db $0D
		endmacro

macro endonmsgend()
		db $0E
		endmacro


; cutscene:
;	- NPC cam (camera controlled by NPC)
;	- black border on top and bottom (replaces status bar)
;	- timer used as command index
;	- commands:
;		- wait
;		- text box
;		- write to NPC
;		- input byte
;		- end cutscene (stay in level)
;		- end cutscene (load new level)
;		- end cutscene (load overworld)
	Cutscene:
		PHB : PHK : PLB
		PHP
		SEP #$30
		JSL Camera_SA1
		LDA !Cutscene6DA2 : STA $6DA2		;\
		LDA !Cutscene6DA3 : STA $6DA3		; |
		LDA !Cutscene6DA4 : STA $6DA4		; |
		LDA !Cutscene6DA5 : STA $6DA5		; | cutscene input override
		LDA !Cutscene6DA6 : STA $6DA6		; |
		LDA !Cutscene6DA7 : STA $6DA7		; |
		LDA !Cutscene6DA8 : STA $6DA8		; |
		LDA !Cutscene6DA9 : STA $6DA9		;/
		LDA !CutsceneWait : BEQ .Process	; if no wait, execute next command
		LDA !MsgTrigger				;\
		ORA !MsgTrigger+1			; | if no text box, decrement wait timer
		BNE .Return				; |
		DEC !CutsceneWait			;/
		.Return
		PLP
		PLB
		RTL

		.Process
		LDA !Cutscene
		ASL A : TAX
		REP #$20
		LDA .CutscenePtr-2,x : STA $00
		SEP #$20
		LDY !CutsceneIndex
		INC !CutsceneIndex
		LDA ($00),y
		ASL A
		TAX
		JSR (.CutsceneCommand,x)
		PLP
		PLB
		RTL


		.CutscenePtr
		dw .MeetKadaal			; 01
		dw .ArriveAtCrashSite		; 02

		.MeetKadaal
		%cutscenewait(240)
		%endonmsgend()

		.ArriveAtCrashSite
		%cutscenewait(60)
		%input6DA2($01)
		%cutscenewait(120)
		%input6DA2($00)
		%cutscenewait(16)
		%cutscenetextbox(!MSG_CrashSite_1)
		%endonmsgend()

		.CutsceneCommand
		dw .Wait
		dw .TextBox
		dw .Music
		dw .Input6DA2
		dw .Input6DA3
		dw .Input6DA4
		dw .Input6DA5
		dw .Input6DA6
		dw .Input6DA7
		dw .Input6DA8
		dw .Input6DA9
		dw .EndStay
		dw .EndLoadLevel
		dw .EndLoadOverworld
		dw .EndOnMsgEnd

	.Wait
		INY
		LDA ($00),y : STA !CutsceneWait
		INC !CutsceneIndex
		RTS
	.TextBox
		INY
		REP #$20
		LDA ($00),y : STA !MsgTrigger
		SEP #$20
		INC !CutsceneIndex
		INC !CutsceneIndex
		RTS
	.Music
		INY
		LDA ($00),y : STA !SPC3
		INC !CutsceneIndex
		RTS
	.Input6DA2
		INY
		LDA ($00),y : STA !Cutscene6DA2
		INC !CutsceneIndex
		RTS
	.Input6DA3
		INY
		LDA ($00),y : STA !Cutscene6DA3
		INC !CutsceneIndex
		RTS
	.Input6DA4
		INY
		LDA ($00),y : STA !Cutscene6DA4
		INC !CutsceneIndex
		RTS
	.Input6DA5
		INY
		LDA ($00),y : STA !Cutscene6DA5
		INC !CutsceneIndex
		RTS
	.Input6DA6
		INY
		LDA ($00),y : STA !Cutscene6DA6
		INC !CutsceneIndex
		RTS
	.Input6DA7
		INY
		LDA ($00),y : STA !Cutscene6DA7
		INC !CutsceneIndex
		RTS
	.Input6DA8
		INY
		LDA ($00),y : STA !Cutscene6DA8
		INC !CutsceneIndex
		RTS
	.Input6DA9
		INY
		LDA ($00),y : STA !Cutscene6DA9
		INC !CutsceneIndex
		RTS
	.EndStay
		STZ !Cutscene
		STZ !CutsceneIndex
		STZ !CutsceneWait
		BRA .Clean
	.EndLoadLevel
		STZ !Cutscene
		STZ !CutsceneIndex
		STZ !CutsceneWait
		INY
		REP #$20
		LDA ($00),y
		SEP #$20
		LDX #$1F
	-	STA $79B8,x
		DEX : BPL -
		XBA
		LDX #$1F
	-	STA $79D8,x
		DEX : BPL -
		LDA #$06 : STA $71
		STZ $88
		STZ $89
		BRA .Clean
	.EndLoadOverworld
		STZ !Cutscene
		STZ !CutsceneIndex
		STZ !CutsceneWait
		LDA #$0B : STA !GameMode
		BRA .Clean
	.EndOnMsgEnd
		LDA !MsgTrigger
		ORA !MsgTrigger+1
		BEQ .EndStay
		DEC !CutsceneIndex
		RTS

	.Clean
		STZ !Cutscene6DA2			;\
		STZ !Cutscene6DA3			; |
		STZ !Cutscene6DA4			; |
		STZ !Cutscene6DA5			; | kill cutscene input
		STZ !Cutscene6DA6			; |
		STZ !Cutscene6DA7			; |
		STZ !Cutscene6DA8			; |
		STZ !Cutscene6DA9			;/
		RTS




>>>>>>> Stashed changes

