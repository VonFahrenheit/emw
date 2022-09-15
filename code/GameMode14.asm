;====================;
;GAME MODE 14 REWRITE;
;====================;

; TODO:
; TO DO:
; - generators
; - scroll sprites ??



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


		LDA $9D : BEQ .NoFreeze				; 0 = no time alteration
		BPL ..stop					;\
		INC $9D						; | neg = slow motion (25% speed)
		AND #$03 : BEQ .NoFreeze			; |
		JMP .RETURN					;/
		..stop						; pos = stop
		DEC $9D : BEQ .NoFreeze				; this has to be done to not drop the buffered input
		JMP .RETURN
		.NoFreeze

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


	; optimized pause code
		LDA !Cutscene : BNE .PauseDone
		STZ $00
		LDA !PauseTimer : BEQ .CheckPause
		DEC !PauseTimer
		BRA .CheckSelect

		.CheckPause
		LDA !MultiPlayer : BEQ .P1
	.P2	LDA !P2Status : BNE .P1
		LDA $6DA7 : TSB $00
	.P1	LDA !P2Status-$80 : BNE +
		LDA $6DA6 : TSB $00
	+	LDA $00
		AND #$10 : BEQ .CheckSelect
		LDA !MsgTrigger : BNE +
		LDA !Pause
		EOR #$01 : STA !Pause
		EOR #$01
		CLC : ADC #$11
		STA !SPC1
		LDA #$3C : STA !PauseTimer

		.CheckSelect
		LDA !Pause : BEQ .PauseDone
		LDA $00
		AND #$20 : BEQ .GameIsPaused
		LDX !Translevel
		LDA !LevelTable1,x : BPL .GameIsPaused
		LDA #$0B : STA !GameMode
		.GameIsPaused
		LDA #$08
		CMP !2100 : BEQ .RETURN
		DEC !2100

		; RETURN
		.RETURN
		LDA #$00					;\ bank = 0x00
		PHA : PLB					;/
		RTL
		.PauseDone
		LDA #$0F
		CMP !2100 : BEQ +
		INC !2100
		+



; phase 2: MPU operation

		STZ !MPU_SNES					;\ start new MPU operation
		STZ !MPU_SA1					;/

		LDA.b #.SA1 : STA $3180				;\
		LDA.b #.SA1>>8 : STA $3181			; | start SA-1 thread
		LDA.b #.SA1>>16 : STA $3182			; |
		LDA #$80 : STA $2200				;/

	.SNES
	; SNES phase 1, executed on DP 0

		LDA #$01 : STA !LevelInitFlag			;\
		REP #$30					; |
		LDA !Level					; |
		ASL A : ADC !Level				; | get level MAIN pointer
		TAX						; |
		LDA.l LevelMainPtr,x : STA $0000		; |
		LDA.l LevelMainPtr+1,x : STA $0001		; |
		SEP #$30					;/
		PHB						;\
		LDA $0002					; | wrap bank
		PHA : PLB					;/
		PHK : PEA.w ..levelcodereturn-1			;\
		JML [$0000]					; | execute pointer
		..levelcodereturn				;/
		PLB						; restore bank
		SEP #$30					; all regs 8-bit just in case
		JSL Camera					; camera (run in accelerator mode)
		%MPU_SNES($01)					; end of SNES phase 1

	; SNES phase 2, executed on DP $0100
		PHD						; push DP
		%MPU_copy()					; set up SNES MPU DP

		JSL read3($00A2A5+1)				; call animation setup routine
		PLD						; restore DP
		JSR !MPU_light					; SNES will process light shader while SA-1 is running the main game
		JMP .RETURN


	.SA1
		PHB						;\ start of SA-1 thread
		PHP						;/

	; SA-1 phase 1, executed on DP $0100
		PHD						; push DP
		%MPU_copy()					; set up SA-1 MPU DP


		LDA.b #LevelData_YoshiCoins>>16 : PHA : PLB	; bank = yoshi coin data bank
		REP #$30					;\
		LDA !Translevel					; | unless level = 0, run normal yoshi coin checks
		AND #$00FF : BEQ ..yoshicoindone		;/
		TAX						;\
		STA $0E						; |
		ASL #2 : ADC $0E				; | *25
		STA $0E						; |
		ASL #2 : ADC $0E				; |
		TAY						;/
		STZ $2250					;\ prepare multiplication with level height
		LDA !LevelHeight : STA $2251			;/
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
		AND #$00FF					; |
		TAX						; |
		STA $0E						; | *25
		ASL #2 : ADC $0E				; |
		STA $0E						; |
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
		PLD						; restore DP
		%MPU_SA1($01)					; end of SA-1 phase 1

	; SA-1 phase 2, executed on DP 0
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
		JSL $05BC00					; scroll sprites (includes LM's hijack for BG3 controller, which i have KILLED >:D)
		PEI ($1C)					;\
		REP #$20					; |
		STZ $7888					; |
		LDA !ShakeTimer : BEQ ..noshake			; > note that $7888 was JUST cleared so hi byte is fine
		DEC !ShakeTimer					; |
		AND #$0003					; |
		ASL A						; |
		TAY						; | camera shake routine
		LDA $A1CE,y : STA $7888				; |
		BIT $6BF5-1					; |
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
;

;
; $00 - position on screen (X and Y)
; $02 - position on screen + offset
; $04 - height of level
; $06 - composite flag set if player is in a state that lets camera scroll up
; $08 - used as a forbiddance flag during co-op if players are too far apart
; $0A - player in midair flag (8-bit)
; $0B - player underwater flag (8-bit)
; $0C - player X pos
; $0E - player Y pos
;

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
;	org $009712			; gamemode 11, just before decompressing background
;		JSL Camera_PreserveDP
;	org $009A58
;		JSL Camera
;	org $00A01B			;
;		JML Camera_HijackBG	;
	;org $00A023			; $00A023 is how the code is aligned after LM's edit
;	org $00A044			; actually just skip all of it... we're not gonna use the vanilla layer 3 anyway
;		SkipLM_BG_Setup:	;
;	org $00A299			; gamemode 14
;		JSL Camera
pullpc



; the vanilla routine is also called once during level init
; sending that here is almost certainly fine
; $00F6DB (scroll routine)
	Camera:
		.EnableHDMA
		LDA !CutsceneSmoothness : BEQ ..done
		LDA.b #Cutscene_HDMA>>16 : STA $4374
		REP #$20
		STZ $4370
		LDA !CutsceneSmoothness
		AND #$00FF
		ASL A
		TAX
		LDA.l Cutscene_HDMA,x : STA !HDMA7source
		SEP #$20
		LDA #$80 : TSB !HDMA
		..done


		LDA !Cutscene : BEQ .NoCutscene
		LDA !MsgTrigger
		ORA !MsgTrigger+1 : BNE +
		LDA !CutsceneSmoothness
		CMP #$08 : BEQ +
		INC !CutsceneSmoothness
		+

		LDA.b #Cutscene : STA $3180
		LDA.b #Cutscene>>8 : STA $3181
		LDA.b #Cutscene>>16 : STA $3182
		JSR $1E80
		BRA .ExecutePtr
		.NoCutscene


		LDA !MsgTrigger
		ORA !MsgTrigger+1 : BNE +
		LDA !CutsceneSmoothness : BEQ +
		DEC !CutsceneSmoothness : BNE +
		LDA #$80 : TRB !HDMA
		+


		LDA !P2Status : BEQ .Run			;\
		LDA !P2Status-$80 : BNE .Return			; | disable camera while both players are dead/dying
		.Run						;/
		LDA.b #.SA1 : STA $3180				;\
		LDA.b #.SA1>>8 : STA $3181			; | SA-1 code pointer
		LDA.b #.SA1>>16 : STA $3182			;/
		LDA !GameMode					;\
		CMP #$14 : BEQ .Light				; | if not in level game mode, just wait for SA-1
		JSR $1E80					; |
		BRA .ExecutePtr					;/

	.Light	LDA #$80 : STA $2200				;\ if in level game mode, have SNES work on shading
		JSR !MPU_light					;/

		.ExecutePtr
		REP #$20					;\
		LDA.l !HDMAptr+0 : BEQ .Return			; |
		STA $00						; |
		LDA.l !HDMAptr+1 : STA $01			; | execute HDMA code
		PHK : PLB					; |
		PHK : PEA .Return-1				; |
		JML [$3000]					;/
		.Return						;\
		REP #$20					; |
		LDA #$0000 : STA.l !HDMAptr			; > clear pointer
		SEP #$30					; | return all regs 8-bit
		RTL						;/


	; behold...
	; the SCUFFEST way to initialize the camera's x position!
	.Init
		PHP						; preserve P
		REP #$30					; all regs 16-bit
		LDA #$0000 : STA !HDMAptr			; make sure this doesn't run from bad emu init
		STZ !CameraForceTimer				; clear forced camera movement
		LDA $94						;\
		STA !P2XPosLo-$80				; |
		STA !P2XPosLo					; |
		LDA $96						; | player coords
		CLC : ADC #$0010				; |
		STA !P2YPosLo-$80				; |
		STA !P2YPosLo					;/
		LDA !Level : STA $00				;\
		ASL A						; |
		ADC $00						; | check if this level has a camera box
		TAX						; |
		LDA.l LevelData_CameraBox,x : BNE ..box		;/
		..nobox						;\
		SEP #$30					; | disable camera box if this level doesn't have one
		LDA #$FF : STA !CameraBoxU+1			; |
		BRA ..boxdone					;/
		..box						;\
		STA $00						; |
		LDA.l LevelData_CameraBox+1,x : STA $01		; |
		SEP #$30					; | load camera box
		XBA						; |
		PHB : PHA : PLB					; |
		REP #$20					; |
		LDA $00 : JSL LevelCode_LoadCameraBox		;/

		JSL LevelCode_InitCameraBox			;\
		REP #$20					; | init camera box
		PLB						;/
		LDA !CameraBoxL					;\
		CMP !CameraBoxR : BNE ..fullcalc		; |
		STA $1A						; | if width = 1, force camera X
		STA !CameraBackupX				; |
		STA $7462					; |
		BRA ..return					;/
		..fullcalc					;\
		STA $7462					;/
		SEP #$30					; all regs 8-bit
		..boxdone


		LDA !MarioDirection
		ASL A : TAX
		REP #$20
		LDA.l ..camcenter,x : STA $742A
		CLC : ADC.w !CameraPower
		STA $742C
		LDA.l ..camcenter,x
		SEC : SBC.w !CameraPower
		STA $742E
		SEP #$20

		JSL Camera					; move camera once

		..return					;
		PLP						; restore P
		RTL						; return

		..camcenter
		dw $005E
		dw $0090


	.BG
		PHP
		REP #$20
		SEP #$10
		JSL BG2Controller
		JSL BG3Controller
		PLP
		RTL




	.SA1
		PHB
		PHP
		SEP #$20
		LDA #$00					;\ bank = 0x00
		PHA : PLB					;/
		REP #$20
		LDA $742A
		SEC
		SBC #$000C
		STA $742C
		CLC : ADC #$0018
		STA $742E
		LDA $7462 : STA $1A
		LDA $7464 : STA $1C
		LDA $7466 : STA $1E
		LDA $7468 : STA $20

		STZ $08						; clear "forbid X" flag (used for composite)

		SEP #$30
		LDA !MultiPlayer : BEQ .P1
		LDA !P2Status
		CMP #$02 : BNE +
		LDA !P2Status-$80
		CMP #$02 : BNE .P1
		; only P1 alive: P1
		; both dead: flow to composite

		.Composite
		LDA !P2YSpeed-$80				;\
		CLC : ADC !P2YSpeed				; |
		AND #$80					; |
		ASL A						; | composite "can move camera up" flag
		ROL A						; |
		ORA !P2Climbing-$80				; |
		ORA !P2Climbing					; |
		STA $06						;/
		LDA !P2InAir-$80				;\
		ORA !P2InAir					; | midair flag
		STA $0A						;/
		LDA !P2Water-$80				;\
		ORA !P2Water					; | water flag
		STA $0B						;/
		REP #$20					;\
		LDA !P2XPosLo-$80				; |
		CLC : ADC !P2XPosLo				; |
		ROR A						; |
		STA $0C						; | composite coords
		LDA !P2YPosLo-$80				; |
		CLC : ADC !P2YPosLo				; |
		ROR A						; |
		STA $0E						;/
		LDA !P2XPosLo-$80				;\
		SEC : SBC !P2XPosLo				; |
		BPL $04 : EOR #$FFFF : INC A			; | if players are 12+ tiles apart, horizontal scrolling is disabled
		CMP #$00C0 : BCC ++				; |
		INC $08						; |
		BRA ++						;/

	+	LDA !P2Status-$80
		CMP #$02 : BNE .Composite
		; both alive: composite
		; only P2 alive: flow to P2

		.P2
		LDY #$80 : JSR .GetPlayerCoord
		BRA ++

		.P1
		LDY #$00 : JSR .GetPlayerCoord
	++	REP #$20

		LDA $0C						;\
		BPL $02 : STZ $0C				; | don't allow negative coords
		LDA $0E						; |
		BPL $02 : STZ $0E				;/


		LDA $6BF5					; horizontal level mode (second highest bit is "show bottom row of level")
		AND #$0040
		BEQ $03 : LDA #$000F
		ADC !LevelHeight
		SBC #$00EF					; note: C was for sure cleared so this subtracts 0xE0
		LDX !EnableVScroll : BNE .ScrollVertically
		JMP .ReturnVScroll

		.ScrollVertically
		STA $04						; $04 = height of level
		LDY #$00					; Y = 0
		LDA $0E
		SEC : SBC $1C
		STA $00						; $00 = player Y pos on screen
		CMP #$0070					;\
		BMI $02 : LDY #$02				; > if lower half, Y = 2
		STY $55						; |
		STY $56						; |
		SEC : SBC $F69F,y				;/
		STA $02						; $02 = player Y pos on screen -0x0064 for up/-0x007C for down
		EOR $F6A3,y					;\ if player is ON upper half of screen, camera should move up
		BMI $04 : LDY #$02 : STZ $02			;/

; negative if:
;	player above screen
;	player on lower half of screen
;	which means...
;	if player is ON the upper half of screen (but not above it), camera is set to move up







		.Space00F8
		LDA $02 : BMI ..2A
		LDX #$00 : STX $7404				; "scroll up to player" flag
		BRA ..83
	..2A	SEP #$20
; -----------------------
;		LDA $749F					; mario jump timer
;		ORA $74						; mario climbing flag
;		ORA $73F3					; mario inflation flag (beginning animation)
;		ORA $78C2					; mario in lakitu cloud flag
;		ORA $7406					; mario bouncing on springboard flag
; -----------------------

		REP #$20
		LDX $06 : BNE ..69				; composite flag
		LDX $0B : BEQ ..5E				; player in water flag
		LDX $0A : BNE ..69				; player is in midair flag
	..5E	LDX !EnableVScroll
		DEX : BEQ ..75
		LDX $73F1 : BNE ..75
	..69	STX $73F1					; some logic with a copy of the vscroll flag?
		LDX $73F1 : BNE ..81
	..75	LDX $7404 : BNE ..81
		LDX $0A : BNE .ReturnVScroll			; player is in midair flag
		INC $7404					; set "scroll up to player" flag
	..81	LDA $02						; player on screen Y + offset
	..83	SEC : SBC $F6A7,y				;
		EOR $F6A7,y					; subtract and EOR the same thing...
		ASL A
		LDA $02 : BCS ..92
		LDA $F6A7,y
	..92	CLC : ADC $1C
		CMP $F6AD,y
		BPL $03 : LDA $F6AD,y


		LDX !GameMode					;\ unlimit speed during other game modes
		CPX #$14 : BNE .UnlimitY			;/

		STA $00						;\
		STZ $02						; |
		SEC : SBC $1C					; |
		BPL $06 : EOR #$FFFF : INC A : INC $02		; |
		CMP #$0008 : BCC .OkY				; |
		LDA $02 : BEQ .Add7Y				; |
	.Sub7Y	LDA #$FFF9					; | cap vertical camera movement to 7 px / frame to prevent zip tears
		BRA ++						; |
	.Add7Y	LDA #$0007					; |
	++	CLC : ADC $1C					; |
		BRA +						; |
	.OkY	LDA $00						; |
	+	BPL $03 : LDA #$0000				; |
		.UnlimitY					; |
		STA $1C						;/

		LDA $04						;\
		CMP $1C : BPL .ReturnVScroll			; | prevent camera from moving too far down
		STA $1C						;/
		STA $73F1					; also set this flag, i guess
		.ReturnVScroll

		LDY $08 : BNE .BanH
		LDY !EnableHScroll : BNE .ScrollHorizontally
	.BanH	JMP .FinishCamera

		.ScrollHorizontally
		LDY #$02
		SEP #$20					; make sure camera movements are smooth for custom characters too
		LDA #$77					;\
		CLC : ADC !CameraPower				; | right value (0x77 + power)
		STA $00						;/
		LDA #$77					;\
		SEC : SBC !CameraPower				; | left value (0x77 - power)
		STA $01						;/

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
		LDA $0C : STA !CameraXMem			; save this to know when to scroll again
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

		LDX !GameMode					;\ unlimit speed during other game modes
		CPX #$14 : BNE .UnlimitX			;/

		STA $00						;\
		STZ $02						; |
		SEC : SBC $1A					; |
		BPL $06 : EOR #$FFFF : INC A : INC $02		; |
		CMP #$0008 : BCC .OkX				; |
		LDA $02 : BEQ .Add7X				; |
	.Sub7X	LDA #$FFF9					; | cap horizontal camera movement to 7 px / frame to prevent zip tears
		BRA ++						; |
	.Add7X	LDA #$0007					; |
	++	CLC : ADC $1A					; |
		BRA +						; |
	.OkX	LDA $00						; |
	+	BPL $03 : LDA #$0000				; |
		.UnlimitX					; |
		STA $1A						;/

		LDA !LevelWidth					;\
		DEC A						; |
		XBA						; |
		AND #$FF00					; | cap at right edge of level
		BPL $03 : LDA #$3F00				; |
		CMP $1A						; |
		BCS $02 : STA $1A				;/


		.FinishCamera

		.Expand						;\
		LDY #$01					; |
	-	LDX !CameraForceTimer,y : BEQ +			; |
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
		CLC : ADC.l .ForceTableX,x			; |
		AND #$FFF8					; |
		STA $1A						; |
		LDA !CameraBackupY				; |
		CLC : ADC.l .ForceTableY,x			; |
		AND #$FFF8					; |
		STA $1C						; |
		BRA .NoBox					; |
	+	DEY : BPL -					;/


		BIT !CameraBoxU : BMI .NoBox			;\
		JSR CameraBox					; | run camera box if it's enabled
		.NoBox						;/


		.CalcLightPoints				;\
		LDA !LightPointIndex : BNE ..process		; | if there are light points, process them
		JMP ..done					; | otherwise skip
		..process					;/
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






		JSL BG2Controller				; scroll BG2
		LDA !WindowDir					;\
		AND #$00FF : BEQ .NotClosing			; |
		.CorrectBG3					; | check for text box closing
		JSL BG3Controller				; | this is necessary on modes 1 and 2
		LDA $22 : STA $400000+!MsgBackup22		; | otherwise BG3 can jump when the background is restored
		LDA $24 : STA $400000+!MsgBackup24		; |
		BRA .EndBox					;/
		.NotClosing					;\
		LDA !MsgTrigger : BNE .EndBox			; | otherwise, ignore BG3 while text box is open
		JSL BG3Controller				; |
		.EndBox						;/


; 99% sure this is not needed
;	; LM call
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
;	; LM return
		SEP #$20				;\
		LDA $1A					; |
		SEC : SBC $7462				; |
		STA !BG1_X_Delta			; |
		LDA $1C					; |
		SEC : SBC $7464				; |
		STA !BG1_Y_Delta			; | delta, probably not needed but i'll keep it for now
		LDA $1E					; |
		SEC : SBC $7466				; |
		STA !BG2_X_Delta			; |
		LDA $20					; |
		SEC : SBC $7468				; |
		STA !BG2_Y_Delta			; |
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
		PLP
		PLB
		RTL


	.ForceTableY
		dw $0000,$0000
	.ForceTableX
		dw $0008,$FFF8,$0000,$0000


		.GetPlayerCoord
		LDA !P2YSpeed-$80,y			;\
		AND #$80				; |
		ASL A					; | composite "can move camera up" flag
		ROL A					; |
		ORA !P2Climbing-$80,y			; |
		STA $06					;/
		LDA !P2InAir-$80,y : STA $0A		; midair flag
		LDA !P2Water-$80,y : STA $0B		; water flag
		REP #$20				; A 16-bit
		LDA !P2VectorX-1-$80,y			;\
		AND #$FF00				; |
		STA $0C					; | vector speed bits
		LDA !P2VectorY-1-$80,y			; |
		AND #$FF00				; |
		STA $0E					;/
		LDX #$00				;\
		LDA !P2XSpeed-1-$80,y			; |
		CLC : ADC $0C				; |
		LSR #4					; |
		AND #$0FF0				; |
		CMP #$0800				; |
		BCC $04 : ORA #$F000 : DEX		; |
		SEP #$20				; | X position
		CLC : ADC !P2XFraction-$80,y		; |
		XBA					; |
		ADC !P2XPosLo-$80,y			; |
		STA $0C					; |
		TXA					; |
		ADC !P2XPosHi-$80,y			; |
		STA $0D					;/
		LDX #$00				;\
		REP #$20				; |
		LDA !P2YSpeed-1-$80,y			; |
		CLC : ADC $0E				; |
		LSR #4					; |
		AND #$0FF0				; |
		CMP #$0800				; |
		BCC $04 : ORA #$F000 : DEX		; | Y position
		SEP #$20				; |
		CLC : ADC !P2YFraction-$80,y		; |
		XBA					; |
		ADC !P2YPosLo-$80,y			; |
		STA $0E					; |
		TXA					; |
		ADC !P2YPosHi-$80,y			; |
		STA $0F					;/

		LDX !P2Platform-$80,y : BEQ ..noplat	; check for platform
		REP #$20				;\
		DEX					; |
		LDA !SpriteDeltaX,x			; |
		AND #$00FF				; |
		CMP #$0080				; |
		BCC $03 : ORA #$FF00			; |
		CLC : ADC $0C				; |
		STA $0C					; | apply platform displacement
		LDA !SpriteDeltaY,x			; |
		AND #$00FF				; |
		CMP #$0080				; |
		BCC $03 : ORA #$FF00			; |
		CLC : ADC $0E				; |
		STA $0E					; |
		SEP #$20				; |
		..noplat				;/

		RTS					; return




	CameraBox:
		PHP
		SEP #$10
		REP #$20

		.LimitCoords					;\
		LDA !CameraBoxL					; |
		CMP $1A						; |
		BCC $02 : STA $1A				; |
		LDA !CameraBoxR					; |
		CMP $1A						; |
		BCS $02 : STA $1A				; | apply box borders
		LDA !CameraBoxU					; |
		CMP $1C						; |
		BCC $02 : STA $1C				; |
		LDA !CameraBoxD					; |
		CMP $1C						; |
		BCS $02 : STA $1C				;/

		LDX #$02					;\
	-	LDY #$00					; |
		LDA $1A,x					; |
		CMP !CameraBackupX,x : BEQ +			; | special backup for camera box
		BCC $02 : LDY #$02				; |
		STY $55						; |
	+	DEX #2 : BPL -					;/

		PLP						; return
		RTS





	; this is entered with all regs 8-bit
	; PLP is used at return, so no need to bother keeping track of P
	.CoordsPtr
	dw .Coords1
	.CoordsEnd


	.Coords1
		STZ $1A
		REP #$20
		LDX #$00
		LDA $1C
	-	CMP #$00E0 : BCC ..Yes
		INX #2
		SBC #$00E0
		BRA -

	..Yes	CMP #$0070
		BCC $02 : INX #2
		LDA.l ..Y,x : STA $1C
		LDX #$02
	-	LDA $1A,x
		STA !CameraBackupX,x
		STA !CameraBoxL,x
		STA $7462,x
		INC A
		STA !CameraBoxR,x
		DEX #2
		BPL -
		RTS

	..Y	dw $0000,$00E0,$01C0,$02A0
		dw $0380,$0460,$0540,$0620



; BG2 controller
	BG2Controller:
		LDA !BG2ModeH			;\
		ASL A				; | X = pointer index
		TAX				;/
		BNE .ProcessHorz		;\ 0%
		STZ $1E				;/

		.ProcessHorz
		LDA $1A				; > A = BG1 HScroll
		JMP (.HPtr,x)			; > Execute pointer

		.HPtr
		dw .NoHorz			; 0 - 0%
		dw .ConstantHorz		; 1 - 100%
		dw .VariableHorz		; 2 - 50%
		dw .SlowHorz			; 3 - 6.25%
		dw .Variable2Horz		; 4 - 25%
		dw .Variable3Horz		; 5 - 12.5%
		dw .CloseHorz			; 6 - 87.5%
		dw .Close2Horz			; 7 - 75%
		dw .CloseHalfHorz		; 8 - 43.75%
		dw .Close2HalfHorz		; 9 - 37.5%
		dw .40PercentHorz		; A - 40%
		dw .DoubleHorz			; B - 200%

.DoubleHorz	ASL A
		BRA .ConstantHorz
.40PercentHorz	LDX #$01 : STX $2250
		ASL #2
		STA $2251
		LDA #$000A : STA $2253
		NOP : BRA $00
		LDA $2308
		CMP #$0005
		LDA $2306
		ADC #$0000
		BRA .ConstantHorz
.CloseHalfHorz	LSR A
.Close2HalfHorz	LSR #2
		SEC : SBC $1A
		EOR #$FFFF
		INC A
		LSR A
		BRA .ConstantHorz
.CloseHorz	LSR A
.Close2Horz	LSR #2
		SEC : SBC $1A
		EOR #$FFFF
		INC A
		BRA .ConstantHorz
.SlowHorz	LSR A
.Variable3Horz	LSR A
.Variable2Horz	LSR A
.VariableHorz	LSR A
.ConstantHorz	STA $1E
.NoHorz		LDA !BG2ModeV
		ASL A
		TAX
		BNE .ProcessVert		;\ 0%
		STZ $20				;/

		.ProcessVert
		LDA $1C
		JMP (.VPtr,x)

		.VPtr
		dw .NoVert			; 0 - 0%
		dw .ConstantVert		; 1 - 100%
		dw .VariableVert		; 2 - 50%
		dw .SlowVert			; 3 - 6.25%
		dw .Variable2Vert		; 4 - 25%
		dw .Variable3Vert		; 5 - 12.5%
		dw .CloseVert			; 6 - 87.5%
		dw .Close2Vert			; 7 - 75%
		dw .CloseHalfVert		; 8 - 43.75%
		dw .Close2HalfVert		; 9 - 37.5%
		dw .40PercentVert		; A - 40%
		dw .DoubleVert			; B - 200%

.DoubleVert	ASL A
		BRA .ConstantVert
.40PercentVert	LDX #$01 : STX $2250
		ASL #2
		STA $2251
		LDA #$000A : STA $2253
		NOP : BRA $00
		LDA $2308
		CMP #$0005
		LDA $2306
		ADC #$0000
		BRA .ConstantVert
.CloseHalfVert	LSR A
.Close2HalfVert	LSR #2
		SEC : SBC $1C
		EOR #$FFFF
		INC A
		LSR A
		BRA .ConstantVert
.CloseVert	LSR A
.Close2Vert	LSR #2
		SEC : SBC $1C
		EOR #$FFFF
		INC A
		BRA .ConstantVert
.SlowVert	LSR A
.Variable3Vert	LSR A
.Variable2Vert	LSR A
.VariableVert	LSR A
.ConstantVert	CLC : ADC !BG2BaseV		;\ Add temporary BG2 VScroll and write
		STA $20				;/
		RTL

.NoVert		LDA !BG2BaseV : STA $20
		RTL



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
		dw .AutoXFast2		; 9 - speed + slow
		dw .AutoXSlow		; A - speed + slow
		dw .AutoXConstant	; B - speed + constant
		dw .AutoXFast		; C - speed + variable
		dw .AutoXFast2		; D - speed + slow
		dw .Variable3Horz	; E - 12% (unused by LM)
		dw .NoHorz		; F - 0% (UNUSED)

.AutoXFast2	JSR .AutoX
		BRA .SlowHorz

.AutoXFast	JSR .AutoX
		BRA .VariableHorz

.AutoXSlow	JSR .AutoX
		BRA .SlowHorz

.AutoXConstant	JSR .AutoX
		BRA .ConstantHorz

.AutoX	;	LDX $9D : BEQ ..run
	;	LDA !BG3XFraction
	;	BRA +
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
		dw .AutoYFast2		; 9 - speed + slow
		dw .AutoYSlow		; A - speed + slow
		dw .AutoYConstant	; B - speed + constant
		dw .AutoYFast		; C - speed + variable
		dw .AutoYFast2		; D - speed + slow
		dw .Variable3Vert	; E - 12% (unused by LM)
		dw .NoVert		; F - 0% (UNUSED)

.AutoYFast2	JSR .AutoY
		BRA .SlowVert

.AutoYFast	JSR .AutoY
		BRA .VariableVert

.AutoYSlow	JSR .AutoY
		BRA .SlowVert

.AutoYConstant	JSR .AutoY
		BRA .ConstantVert

.AutoY	;	LDX $9D : BEQ ..run
	;	LDA !BG3YFraction
	;	BRA +
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
		LDA !ShakeBG3
		AND #$00FF : BEQ ..noshake
		DEC A
		SEP #$20
		STA !ShakeBG3
		REP #$20
		AND #$0003
		ASL A
		TAX
		LDA.l ..shakeoffset,x
		CLC : ADC $24
		STA $24

		..noshake
		SEP #$20
		RTL

		..shakeoffset
		dw $0000,$0002,$0004,$0002




.12percent	BPL ..pos
	..neg	EOR #$FFFF
		LSR #3
		EOR #$FFFF
		RTS
	..pos	LSR #3
		RTS




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


	.HDMA
		dw ..0
		dw ..1
		dw ..2
		dw ..3
		dw ..4
		dw ..5
		dw ..6
		dw ..7
		dw ..8

		..1
		db $02,$80
		db $6D,$0F
		db $6D,$0F
		db $01,$80
		..0
		db $00
		..2
		db $04,$80
		db $6B,$0F
		db $6B,$0F
		db $01,$80
		db $00
		..3
		db $06,$80
		db $69,$0F
		db $69,$0F
		db $01,$80
		db $00
		..4
		db $08,$80
		db $67,$0F
		db $67,$0F
		db $01,$80
		db $00
		..5
		db $0A,$80
		db $65,$0F
		db $65,$0F
		db $01,$80
		db $00
		..6
		db $0C,$80
		db $63,$0F
		db $63,$0F
		db $01,$80
		db $00
		..7
		db $0E,$80
		db $61,$0F
		db $61,$0F
		db $01,$80
		db $00
		..8
		db $10,$80
		db $5F,$0F
		db $5F,$0F
		db $01,$80
		db $00





