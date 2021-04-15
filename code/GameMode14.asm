;====================;
;GAME MODE 14 REWRITE;
;====================;

;
; TO DO:
; TODO:
; - Fe26
;	- HI_PRIO_OAM
;	- RexCode.asm special hi prio OAM code
; - FusionCore
;	- particles
;	- custom shooter
; - generators
; - scroll sprites ??
; - BG3 auto scroll: missing too many bits
; - MSG
; - starman sparkles (Leeway crawl X offset)
; - have SNES process colors in WRAM during phase 2 (maybe)

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
; - SA-1
;	- status bar
;	- rainbow shifter + simple rotate
;	- starman sparkles
;
; phase 3:
; - SNES
;	- vanilla animations
; - SA-1
;	- camera
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
		LDA !MsgTrigger : BEQ .NoMSG		;\
		JSL read3($00A1DF+1)			; | MSG
		RTS					; |
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

	; optimized pause code
		LDA !PauseTimer : BEQ .CheckPause
		DEC !PauseTimer
		BRA .CheckSelect

		.CheckPause
		LDA !MultiPlayer : BEQ .P1
		LDA !P2Status-$80 : BNE .notP1
	.notP1	LDA !P2Status : BNE .PauseDone
	.P2	LDA $6DA7
		BRA .W
	.both	LDA $6DA7
	.P1	ORA $6DA6
	.W	STA $00
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
		; RETURN
		JML $00A289				; JML to RTS
		.PauseDone

		LDA !MsgTrigger : BEQ ++		; > always clear if there's no message box
		LDA !WindowDir : BNE +			; > don't clear while window is closing
		LDA.l !MsgMode : BNE +			;\ don't clear OAM during !MsgMode non-zero
	++	JSL !KillOAM				;/
		+

; phase 2: MPU operation

		STZ !MPU_SNES				;\ start new MPU operation
		STZ !MPU_SA1				;/

		LDA.b #.SA1 : STA $3180			;\
		LDA.b #.SA1>>8 : STA $3181		; | start SA-1 thread
		LDA.b #.SA1>>16 : STA $3182		; |
		LDA #$80 : STA $2200			;/

	.SNES
		JSR MAIN_Level				; SNES thread is just MAIN level code
		JSL Camera				; camera (ran in accelerator mode)
		%MPU_SNES($01)				; end of SNES phase 1
		PHD					; push DP
		%MPU_copy()				; set up SNES MPU DP
		JSL read3($00A2A5+1)			; call routine
		PLD					; restore DP
	;	JSR $1E85				; wait for SA-1 to finish MPU operation

		JSR !MPU_light

		JML $00A289				; JML to RTS


	.SA1
		PHB
		PHP
		SEP #$30
		PHD
		%MPU_copy()				; set up SA-1 MPU DP
		JSL $008E1A				; status bar
		JSL HandleGraphics			; rotate simple + rainbow shifter (part of SP_Level.asm)
		PLD

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

		%MPU_SA1($01)				; end of SA-1 phase 1

		REP #$20
		LDA $1A
		LSR #2
	;	STA !LightR
		STA !LightG
		STA !LightB
		SEP #$20

		LDA !LightBuffer : BPL +
		REP #$20
		AND #$0001
		EOR #$0001
		BEQ $03 : LDA #$0200
		CLC : ADC.w #!LightData_SNES+2 : STA !VRAMbase+!CGRAMtable+$02
		LDA.w #!LightData_SNES>>16 : STA !VRAMbase+!CGRAMtable+$04
		LDA #$01FE : STA !VRAMbase+!CGRAMtable+$00
		SEP #$20
		LDA #$01 : STA !VRAMbase+!CGRAMtable+$05
		LDA #$80 : TRB !LightBuffer
		+

		%ApplyLight($01,$00)






		JSL $05BC00				; scroll sprites (includes LM's hijack for BG3 controller)
		PEI ($1C)				;\
		REP #$20				; |
		STZ $7888				; |
		LDA $7887 : BEQ .noshake		; > note that $7888 was JUST cleared so hi byte is fine
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
		.noshake				; |
		SEP #$30				;/
		JSL $158008				; call PCE
		JSL $168000				; call Fe26 main loop
		JSL $148000				; call FusionCore (fusion sprites + particles)
		REP #$20
		PLA : STA $1C
		SEP #$30

		JSL !BuildOAM				; build OAM at the end of the game mode code

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


; the vanilla routine is also called once during level init
; sending that here is almost certainly fine
; $00F6DB (scroll routine)
Camera:
		LDA.b #.SA1 : STA $3180				;\
		LDA.b #.SA1>>8 : STA $3181			; | have SA-1 run most of the routine
		LDA.b #.SA1>>16 : STA $3182			; |
		JSR $1E80					;/
		REP #$20					;\
		LDA.l !HDMAptr+0 : BEQ .Return			; |
		STA $00						; |
		LDA.l !HDMAptr+1				; |
		STA $01						; | execute HDMA code
		PHK : PLB					; |
		PHK : PEA .Return-1				; |
		JML [$3000]					;/
		.Return						;\
		SEP #$30					; | return all regs 8-bit
		RTL						;/


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

		SEP #$20
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
		STA $1C						;/

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
		STA $1A						;/

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

		.Expand						;\
		LDY #$01					; |
	-	LDX !CameraForceTimer,y : BEQ .NextForce	; |
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
		CLC : ADC !BG3XFraction
		STA !BG3XFraction
	+	LSR #7
		BIT !BG3XFraction
		BPL $03 : ORA #$FE00
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
		CLC : ADC !BG3YFraction
		STA !BG3YFraction
	+	LSR #7
		BIT !BG3YFraction
		BPL $03 : ORA #$FE00
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




namespace off

