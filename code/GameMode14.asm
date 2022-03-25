;====================;
;GAME MODE 14 REWRITE;
;====================;

; TO DO:
; TODO:
; - generators
; - scroll sprites ??



; - trim:
;	- VR3 OAM handler
;	- Fe26 extra hijacks





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
		ORA !MsgTrigger+1				; |
		BEQ .NoMSG					; | MSG
		JSL read3($00A1DF+1)				; |
		BRA .RETURN					; |
		.NoMSG						;/



	; disable down and X/Y during animations and level end
		LDA !MarioAnim
		ORA !LevelEnd
		BEQ +
		LDA #$04 : TRB $15
		LDA #$40
		TRB $16
		TRB $18
		+

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
		CMP !2100
		BEQ $03 : DEC !2100

		; RETURN
		.RETURN
		LDA #$00				;\ bank = 0x00
		PHA : PLB				;/
		JML $00A289				; JML to RTS
		.PauseDone
		LDA #$0F
		CMP !2100
		BEQ $03 : INC !2100


;		LDA !MsgTrigger : BEQ ++		; > always clear if there's no message box
;		LDA !WindowDir : BNE +			; > don't clear while window is closing
;		LDA.l !MsgMode : BNE +			;\ don't clear OAM during !MsgMode non-zero
;	++	;JSL !KillOAM				;/
		+



; phase 2: MPU operation

		STZ !MPU_SNES				;\ start new MPU operation
		STZ !MPU_SA1				;/

		LDA.b #.SA1 : STA $3180			;\
		LDA.b #.SA1>>8 : STA $3181		; | start SA-1 thread
		LDA.b #.SA1>>16 : STA $3182		; |
		LDA #$80 : STA $2200			;/

	.SNES
	; SNES phase 1, executed on DP 0
		JSR MAIN_Level				; SNES thread is just MAIN level code
		JSL Camera				; camera (run in accelerator mode)
		%MPU_SNES($01)				; end of SNES phase 1

	; SNES phase 2, executed on DP $0100
		PHD					; push DP
		%MPU_copy()				; set up SNES MPU DP

		JSL read3($00A2A5+1)			; call animation setup routine
		PLD					; restore DP
		JSR !MPU_light				; SNES will process light shader while SA-1 is running the main game
		JMP .RETURN


	.SA1
		PHB					;\
		PHP					; | start of SA-1 thread
		SEP #$30				;/
		LDA #$00				;\ bank = 00
		PHA : PLB				;/


	; SA-1 phase 1, executed on DP $0100
		PHD					; push DP
		%MPU_copy()				; set up SA-1 MPU DP

		JSL $008E1A				; status bar
		LDA #$01 : JSL !ProcessYoshiCoins	; > handle Yoshi Coins
		LDA $14					;\
		AND #$1F				; |
		TAY					; | index RNG table
		DEC A					; |
		AND #$1F				; |
		TAX					;/
		LDA !RNGtable,x				;\
		BIT #$01 : BEQ +			; |
		ASL A					; | apply 3N+1 on previous RN
		ADC !RNGtable,x				; |
		STA !RNGtable,x : BRA ++		; |
	+	LSR !RNGtable,x				;/
	++	JSL !Random				; get vanilla RN
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
		SEP #$30				; all regs 8-bit
	;	LDA $9D : BNE ..noanim
		INC $14					; increment frame counter
		JSL HandleGraphics			; rotate simple + starman handler (part of SP_Level.asm)
		..noanim
		JSL $05BC00				; scroll sprites (includes LM's hijack for BG3 controller, which i have KILLED >:D)
		PEI ($1C)				;\
		REP #$20				; |
		STZ $7888				; |
		LDA !ShakeTimer : BEQ ..noshake		; > note that $7888 was JUST cleared so hi byte is fine
		DEC !ShakeTimer				; |
		AND #$0003				; |
		ASL A					; |
		TAY					; | camera shake routine
		LDA $A1CE,y : STA $7888			; |
		BIT $6BF5-1				; |
		BVC $02 : DEC #2			; |
		STA $7888				; |
		CLC : ADC $1C				; > this only applies to sprites, actual camera offset is in camera routine
		STA $1C					; |
		..noshake				; |
		SEP #$30				;/

.CODE_00C533	LDY $74AD				;\
		CPY $74AE				; |
		BCS $03 : LDY $74AE			; |
		CPY !StarTimer				; |
		BCS $03 : LDY !StarTimer		; |
		LDA $6DDA : BMI +			; |
		CPY #$01 : BNE +			; | POW (blue and silver) + star power timer + music
		LDY $790C : BNE +			; |
		STA !SPC3				; |
	+	CMP #$FF : BEQ .CODE_00C55C		; |
		CPY #$1E : BNE .CODE_00C55C		; |
		LDA #$24 : STA !SPC4			;/
.CODE_00C55C	LDA $14					;\ only decrement these every 4 frames
		AND #$03 : BNE +			;/
		LDX #$06				;\
	-	LDA $74A8,x				; | auto-decrement $74A9-$74AE (only notable ones are $74AD and $74AE, the P switch timers)
		BEQ $03 : DEC $74A8,x			; | (note the BNE: $74A8 is not decremented)
		DEX : BNE -				;/
		+

		JSL $158008				; call PCE
		LDA #$01 : STA !ProcessingSprites	; mark sprites as currently processing
		JSL $168000				; call Fe26 main loop
		JSL $148000				; call FusionCore (fusion sprites + particles)
		LDA #$00 : STA !ProcessingSprites	; mark sprites as no longer processing


		REP #$20				;\
		PLA : STA $1C				; | restore BG1 Y
		SEP #$30				;/
		JSL !BuildOAM				; build OAM at the end of the game mode code

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
	org $009712
		JSL Camera_PreserveDP
	org $009A58
		JSL Camera
	org $00A01B			;
		JML Camera_HijackBG	;
	;org $00A023			; $00A023 is how the code is aligned after LM's edit
	org $00A044			; actually just skip all of it... we're not gonna use the vanilla layer 3 anyway
		SkipLM_BG_Setup:	;
	org $00A299
		JSL Camera
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
	.PreserveDP
		PHP						; preserve P
		PEI ($00)					;\
		PEI ($02)					; |
		PEI ($04)					; |
		PEI ($06)					; | preserve DP
		PEI ($08)					; |
		PEI ($0A)					; |
		PEI ($0C)					; |
		PEI ($0E)					;/

		REP #$30					; all regs 16-bit
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
		ADC $00						; |
		TAY						; | check if this level has a camera box
		LDA.l !BoxPtr : STA $03				; |
		LDA.l !BoxPtr+1 : STA $04			; |
		LDA [$03],y : BNE ..box				;/
		..nobox						;\
		SEP #$30					; | disable camera box if this level doesn't have one
		LDA #$FF : STA !CameraBoxU+1			; |
		BRA ..boxdone					;/
		..box						;\
		STA $00						; |
		INY						; |
		LDA [$03],y : STA $01				; |
		SEP #$30					; | load camera box
		XBA						; |
		PHB : PHA : PLB					; |
		REP #$20					; |
		LDA $00 : JSL LoadCameraBox			;/
		JSL InitCameraBox				;\
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
		JSL Camera					; +1 call with camera box
		..boxdone

		JSL Camera					; move camera once

		PEI ($1C)					;\
		REP #$20					; |
		LDA !CameraBackupY : PHA			; | preserve camera Y regs
		LDA $7464 : PHA					; |
		SEP #$20					;/
		JSL Camera					;\
		JSL Camera					; |
		JSL Camera					; |
		JSL Camera					; |
		JSL Camera					; |
		JSL Camera					; |
		JSL Camera					; |
		JSL Camera					; | move camera a bunch of times
		JSL Camera					; | (yeah... extremely scuffed)
		JSL Camera					; |
		JSL Camera					; |
		JSL Camera					; |
		JSL Camera					; |
		JSL Camera					; |
		JSL Camera					; |
		JSL Camera					;/
		REP #$20					;\
		..restore					; |
		PLA : STA $7464					; | restore camera Y regs
		PLA : STA !CameraBackupY			; |
		PLA : STA $1C					;/
		..return					;\
		PLA : STA $0E					; |
		PLA : STA $0C					; |
		PLA : STA $0A					; |
		PLA : STA $08					; | restore DP
		PLA : STA $06					; |
		PLA : STA $04					; |
		PLA : STA $02					; |
		PLA : STA $00					;/
		PLP						; restore P
		RTL						; return


	.HijackBG
		PHP
		REP #$20
		SEP #$10
		JSL BG2Controller
		JSL BG3Controller
		PLP
		JML SkipLM_BG_Setup

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


		LDX !GameMode
		CPX #$14 : BEQ +
		LDA $94 : STA $0C
		+

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
		CLC : ADC !CameraPower				; | left value (0x77 + power)
		STA $00						;/
		LDA #$77					;\
		SEC : SBC !CameraPower				; | right value (0x77 - power)
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
		BPL $03 : LDA #$0080				; |
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
		JSR .CameraBox					; | run camera box if it's enabled
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

	.SmoothSpeed
		dw $0006,$FFFA

	.CameraOffset
		dw $0100,$00E0
	.CameraCenter
		dw $0080,$0070


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




		.CameraBox
		PHB : PHK : PLB
		PHP
		SEP #$10
		REP #$20

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
	+	DEX #2 : BPL -

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
	-	LDY $3230,x : BNE +				; |
	--	JMP .Next					; |
	+	LDY !CameraBoxSpriteErase : BNE --
		LDA !SpriteTweaker4,x				; |
		ORA #$0004					; |
		STA !SpriteTweaker4,x				; |
		LDY !CameraForceTimer : BNE .Freeze		; |
		LDY !SpriteXLo,x : STY $00			; | search for sprites to interact with
		LDY !SpriteXHi,x : STY $01			; |
		LDY !SpriteYLo,x : STY $02			; |
		LDY !SpriteYHi,x : STY $03			; |
		LDA $00						; |
		SEC : SBC $04					; |
		BPL .CheckR					; |
		CMP #$FF00 : BCC .Delete			; |
		CMP #$FFE0 : BCC .Freeze			;/
		BRA .Next

	.Delete	LDA $3230,x					;\
		AND #$FF00					; | delete sprite
		STA $3230,x					;/
		LDY $33F0,x					;\ if this was a spawned sprite, don't bother with ID
		CPY #$FF : BEQ .Next				;/
		LDA !CameraBoxR					;\
		SEC : SBC !CameraBoxL				; |
		CMP #$0101 : BCS ..respawn			; |
		LDA !CameraBoxD					; | if camera box is 2x2 screens or smaller, don't respawn
		SEC : SBC !CameraBoxU				; |
		CMP #$00E1 : BCC .Next				; |
		..respawn					;/
		PHX						;\
		TYX						; |
		LDA $418A00,x					; |
		AND #$00FF					; |
		CMP #$00EE : BEQ +				; | if camera box is bigger than 2x2 screens, mark for respawn
		LDA $418A00,x					; |
		AND #$FF00					; |
		STA $418A00,x					; |
	+	PLX						; |
		BRA .Next					;/

	.CheckR	LDA $00						;\
		SEC : SBC $06					; |
		BMI .GoodX					; | see if fully outside
		CMP #$0020 : BCC .Next				; |
		CMP #$0100 : BCS .Delete			;/

	.Freeze	LDY $3230,x					;\ delete if status < 8
		CPY #$08 : BCC .Delete				;/
		..freeze
		LDA !SpriteStasis,x				;\
		ORA #$0002					; | freeze if status >= 8
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


		.Absolute
		LDA $1A,x
		CMP !CameraBoxL,x : BCS +
		LDA !CameraBoxL,x : STA $1A,x
		RTS
	+	CMP !CameraBoxR,x : BCC + : BEQ +
		LDA !CameraBoxR,x : STA $1A,x
	+	RTS



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





namespace off

