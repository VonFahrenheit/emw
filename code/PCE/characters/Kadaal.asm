;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

namespace Kadaal

<<<<<<< Updated upstream
; --Build 6.4--
;
;
; Upgrade data:
;	bit 0 (01)	Senku smash
;	bit 1 (02)	Can senku in 8 directions
;	bit 2 (04)	Can start senku in midair
;	bit 3 (08)	Landslide (hold down when landing with enough X-speed)
;	bit 4 (10)	Down + Y in midair to perform a shell drill attack, breaks bricks
;	bit 5 (20)	+1 HP, protects against some attacks while ducking
;	bit 6 (40)	Ground spin (can spin attack while ducking or sliding)
;	bit 7 (80)	Push X to perform ultimate attack


=======
; --Build 7.2--
;


; new upgrade layout:
;	01	drop kick
;	02	directional senku
;	04	air senku
;	08	---- ????
;	10	fancy footwork (backdash/pivot)
;	20	---- ????
;	40	---- ????
;	80	ultimate: shun koopa satsu
>>>>>>> Stashed changes

	!Kad_Idle	= $00
	!Kad_Walk	= $04
	!Kad_Spin	= $08
	!Kad_Squat	= $0C
	!Kad_Shell	= $0D
	!Kad_Fall	= $11
	!Kad_Turn	= $12
	!Kad_Senku	= $13
	!Kad_Punch1	= $14
	!Kad_Punch2	= $18
	!Kad_Hurt	= $1C
	!Kad_Dead	= $1D
	!Kad_Dash	= $1E
	!Kad_Climb	= $24
	!Kad_Duck	= $26
	!Kad_SenkuSmash	= $28
	!Kad_ShellDrill	= $2D
	!Kad_DrillLand	= $32


<<<<<<< Updated upstream


	MAINCODE:
		PHB : PHK : PLB
=======
	MAINCODE:
		PHB : PHK : PLB


	LDA $16
	AND #$20 : BEQ +
	LDA !KadaalUpgrades
	EOR #$FF : STA !KadaalUpgrades
	+


		LDA !P2Init : BNE .Main

		.Init
		INC !P2Init
		REP #$30
		LDY.w #!File_PlayerObjects : JSL GetFileAddress
		LDA.w #ANIM_EffectDynamo : JSL CORE_GENERATE_RAMCODE_24bit

		.Main

		.Freeze
		LDA $9D : BEQ ..done
		DEC !P2AnimTimer
		JMP ANIMATION_CheckPlayer
		..done


		.AutoAnim
		LDA !P2Anim
		REP #$30
		AND #$00FF
		ASL #3 : TAY
		LDA ANIM+$00,y
		SEP #$20
		LDA !P2AnimTimer
		INC A
		CMP ANIM+$02,y : BCC ..sameanim
		..newanim
		LDA ANIM+$03,y : STA !P2Anim
		LDA #$00
		..sameanim
		STA !P2AnimTimer
		SEP #$30
>>>>>>> Stashed changes

	LDA #$FF : STA !KadaalUpgrades

		LDA #$02 : STA !P2Character
		LDA #$02 : STA !P2MaxHP
		LDA !KadaalUpgrades		;\
		AND #$20			; | +1 Max HP with upgrade
		BEQ $03 : INC !P2MaxHP		;/
		LDA !P2Status : BEQ .Process
		STZ !P2Invinc
		CMP #$02 : BEQ .SnapToP1
		CMP #$03 : BNE .KnockedOut

		.Snapped			; State 03
		REP #$20
		LDA $94 : STA !P2XPosLo
		LDA $96 : STA !P2YPosLo
		SEP #$20
		PLB
		RTS

<<<<<<< Updated upstream
		.KnockedOut			; State 01
		JSR CORE_KNOCKED_OUT
		BMI .Fall
		BCC .Fall
=======
		.KnockedOut				; State 01
		JSL CORE_KNOCKED_OUT : BCC .Fall
>>>>>>> Stashed changes
		LDA #$02 : STA !P2Status
		PLB
		RTS

		.Fall
		LDA #!Kad_Dead : STA !P2Anim
		STZ !P2AnimTimer
		JMP ANIMATION_CheckPlayer

		.SnapToP1			; State 02
		REP #$20
		LDA !P2XPosLo
		CMP $94
		BCS +
		ADC #$0004
		BRA ++
	+	SBC #$0004
	++	STA !P2XPosLo
		SEC : SBC $94
		BPL $03 : EOR #$FFFF
		CMP #$0008
		BCS +
		INC !P2Status
	+	SEP #$20

<<<<<<< Updated upstream
		.Return
		PLB
		RTS

		.Process				; State 00
		LDA !P2MaxHP				;\
		CMP !P2HP				; | Enforce max HP
		BCS $03 : STA !P2HP			;/
		LDA !P2Platform				;\
		BEQ ++					; |
		CMP !P2SpritePlatform : BEQ +		; | Account for platforms
	++	STA !P2PrevPlatform			; |
		+					;/
=======
		.Process				; state 00
		LDA !P2DashSmoke : BEQ .NoSmoke
		JSL CORE_DASH_SMOKE
		.NoSmoke


	; timers
		LDA !P2DashTimerR
		BEQ $03 : DEC !P2DashTimerR
		LDA !P2DashTimerL
		BEQ $03 : DEC !P2DashTimerL
		LDA !P2WalkTimer
		BEQ $03 : DEC !P2WalkTimer
>>>>>>> Stashed changes
		LDA !P2JumpLag
		BEQ $03 : DEC !P2JumpLag
		LDA !P2HurtTimer
		BEQ $03 : DEC !P2HurtTimer
		LDA !P2Invinc
		BEQ $03 : DEC !P2Invinc
		LDA !P2Senku
		BEQ $03 : DEC !P2Senku
		LDA !P2Punch1
		BEQ $03 : DEC !P2Punch1
		LDA !P2Punch2
		BEQ $03 : DEC !P2Punch2
		LDA !P2SlantPipe
		BEQ $03 : DEC !P2SlantPipe
		LDA !P2BackDash
		BEQ $03 : DEC !P2BackDash

<<<<<<< Updated upstream
		LDA !P2Kick
		BEQ +
		BPL ++
		INC !P2Kick
		BRA +
	++	DEC !P2Kick : BNE +
		LDA #$F0 : STA !P2Kick
		LDA !P2ShellSlide : BNE ++
		BIT !P2Water : BPL ++
		LDA #!Kad_Duck+1
		BRA +++
	++	LDA #!Kad_Shell
	+++	STA !P2Anim
=======
	; shell spin timer, a bit more complex
		.ShellSpin
		LDA !P2ShellSpin
		BEQ ..done
		BPL ..active
		..endlag
		INC !P2ShellSpin
		BRA ..done
		..active
		DEC !P2ShellSpin : BNE ..done
		LDA #$F0 : STA !P2ShellSpin
		LDA !P2ShellSlide : BNE ..shellanim
		LDA !P2Ducking : BEQ ..shellanim
		..duckanim
		LDA #!Kad_Duck+1 : BRA ..setanim
		..shellanim
		LDA #!Kad_Shell
		..setanim
		STA !P2Anim
>>>>>>> Stashed changes
		STZ !P2AnimTimer
		STZ !P2Buffer
		..done


	PIPE:
		JSR CORE_PIPE
		BCC $03 : JMP ANIMATION_HandleUpdate



	CONTROLS:
<<<<<<< Updated upstream

		JSR CORE_COYOTE_TIME
=======
		PEA PHYSICS-1
		JSL CORE_COYOTE_TIME

		.Headbutt
		LDA !P2Headbutt : BEQ ..done		;\
		LDA !P2Direction			; |
		AND #$01				; |
		INC A					; | force forward input during headbutt
		TRB $15					; |
		EOR #$03 : TSB $15			; |
		..done					;/


		.WalkCancelPunch
		LDA $16					;\
		AND #$03 : BEQ ..done			; | end punch on left/right press
		STZ !P2Punch				; |
		..done					;/


		.ForceCrouch
		LDA !P2InAir : BNE ..done		;\
		JSL CORE_CHECK_ABOVE : BCC ..done	; |
		LDA #$04 : TSB $15			; | force down input if kadaal is on ground with a solid block above
		LDA #$01 : STA !P2ShellSlide		; |
		..done					;/
>>>>>>> Stashed changes

	; determine if kadaal can turn around

<<<<<<< Updated upstream
		LDX !P2Direction
		LDA !P2Water
		LSR A : BCS .Turn
		LDA !P2Blocked
		AND #$04
		ORA !P2Platform
		BEQ .NoTurn
=======
; kadaal turn priority:
;	backdash or headbutt		-> never turn
;	shell slide, climb, or swim	-> can turn
;	in water or on ground		-> can turn
>>>>>>> Stashed changes


		.CanTurn
		STZ !P2CanTurn				; default = can't turn
		LDA !P2BackDash				;\
		ORA !P2Headbutt				; | can't turn during backdash or headbutt
		BNE ..done				;/
		LDA !P2Water				;\
		AND #$40				; |
		ORA !P2ShellSlide			; | when in water, shell sliding, or climbing, can turn
		ORA !P2Climbing				; |
		BNE ..turn				;/
		LDA !P2InAir : BNE ..done		;\
		..turn					; | otherwise, can only turn when on the ground
		INC !P2CanTurn				; |
		..done					;/


<<<<<<< Updated upstream
		LDA !P2HurtTimer : BEQ $01 : RTS

		LDA !P2Water
		LSR A
		BCC $03 : JMP .NoDuck

		LDA !P2Blocked
		AND #$04
		ORA !P2Platform
		ORA !P2SpritePlatform
		BNE ..Ground
		JMP .NoGround

	..Ground
		LDA !P2BackDash
		CMP #$08 : BCC ..BackDash
		BRA ..NoDir

	..BackDash
		LDA $6DA9
		AND #$30 : BEQ .NoBackDash
		AND #$10 : BEQ +
		LDA !P2Direction			; R is perfect pivot
		INC A
		TSB $6DA3
		EOR #$03
		TRB $6DA3

	+	LDA #$10 : STA !P2BackDash
		LDA $6DA3
		AND #$03 : BEQ +
		CMP #$03 : BEQ +
		DEC A
		EOR #$01
		STA !P2Direction
		BRA ++
	+	LDA !P2Direction
	++	EOR #$01
		TAY
		LDA .XSpeedSenku,y : JSR CORE_SET_XSPEED
		LDA #$2D : STA !SPC1			; slide SFX
		STZ !P2Punch1
		STZ !P2Punch2
		STZ !P2Senku
	..NoDir	LDA #$0F				;\
		TRB $6DA3				; | clear directionals during back dash
		TRB $6DA7				;/
		LDA #$01 : STA !P2Dashing
		.NoBackDash


		LDA !P2ShellDrill : BEQ .NoPound	;\
		STZ !P2ShellDrill			; |
		JSR .StartSpin				; | shell drill landing
		LDA #$09 : STA !SPC4			; > smash SFX
		LDA #$17 : STA !P2JumpLag		; |
		LDA #!Kad_DrillLand : STA !P2Anim	; |
		RTS					; |
		.NoPound				;/


		LDA !P2Anim				;\
		CMP #!Kad_DrillLand : BCC .NoDrillLand	; | force crouch physics during drill land
		BRA .ForceCrouch			; |
		.NoDrillLand				;/


		LDA $6DA3				;\
		AND #$04 : BNE +			; |
		STZ !P2ShellSlide			; |
		STZ !P2ShellSpeed			; |
		BRA .NoGround				; |
	+	LDA !P2ShellSlide : BEQ .NoGround	; |
	-	JSR .GSpin				; > Hook ground spin here
		LDA !P2Blocked				; |
		AND #$03 : BEQ +			; |
		DEC A					; |
		AND #$01				; | Shell slide code
		STA !P2Direction			; |
		LDA #$01 : STA !SPC1			; |
	+	LDY !P2Direction			; |
		LDA .XSpeedSenku,y : JSR CORE_SET_XSPEED; |
		LDA #$01 : STA !P2ShellSpeed		; |
		LDA #$03				; |
		TRB $6DA3				; |
		TRB $6DA5				; |
		BRA .NoDuck				; |
		.NoGround				;/

		LDA !P2Senku : BEQ +
		CMP #$20 : BCC .NoDuck
	+	LDA !P2Blocked
		LDY !P2Platform
		BEQ $02 : ORA #$04
		AND $6DA3
		AND #$04 : BEQ .NoDuck
		BIT $6DA7
		BPL $03 : JMP .SenkuJump

		LDA !KadaalUpgrades			;\
		AND #$08 : BEQ .ForceCrouch		; |
		LDA !P2XSpeed				; |
		BPL $03 : EOR #$FF : INC A		; | allow shell slide with upgrade
		CMP #$20 : BCC .ForceCrouch		; |
		JSR StartSlide				; |
		BRA -					;/


	.ForceCrouch
		LDA #$00 : JSR CORE_SET_XSPEED
		LDA #$80 : TSB !P2Water
		STZ !P2Punch1
		STZ !P2Punch2
		STZ !P2Dashing
		STZ !P2Senku
	.GSpin	LDA !P2Kick : BNE .SpinR		;\
		LDA !KadaalUpgrades			; |
		AND #$40 : BEQ .SpinR			; |
		BIT $6DA7 : BVC .SpinR			; | Allow ground spin with upgrade
		.StartSpin				; > JSR here to start spin
		LDA #$10 : STA !P2Kick			; |
		LDA #!Kad_Spin : STA !P2Anim		; |
		LDA #$3E : STA !SPC4			; | > spin SFX
		STZ !P2IndexMem1			; |
		STZ !P2IndexMem2			; |
		STZ !P2AnimTimer			;/
	.SpinR	RTS
		.NoDuck
=======
	; check hurt
		LDA !P2HurtTimer : BEQ $03 : JMP .Friction_main	; go to friction without shell slide check


	; check climb
		LDA !P2Climbing : BEQ $03 : JMP .NoDuck


	; throw item code
		.ThrowItem
		LDX !P2Carry : BEQ ..done
		STZ !P2DashTimerR				;\ can't dash with object
		STZ !P2DashTimerL				;/
		STZ !P2ShellSlide				;\ can't shell slide with object
		STZ !P2ShellSpeed				;/
		LDA !P2InAir : BNE +				;\ end dash state on ground
		STZ !P2Dashing					;/ (but it can be kept in midair)
	+	STZ !P2Headbutt					; end headbutt
		STZ !P2Punch					; end punch
		LDA !P2Ducking : BNE ..throw			;\
		BIT $18 : BMI ..throw				; | throw if: ducking, pressing A, or letting go of Y
		BIT $15 : BVS ..done				;/
		LDA #$08 : STA !P2Throw				; throw timer = 8
		LDA #!Kad_Throw : STA !P2Anim			;\ animation
		STZ !P2AnimTimer				;/
		..throw						;\
		DEX						; |
		LDA #$0A : STA !SpriteStatus,x			; |
		LDA !P2Direction : TAY				; | get throw direction
		EOR #$01 : STA !SpriteDir,x			; |
		LDA $15						; |
		AND #$0C : BEQ ..setspeed			; |
		CMP #$08 : BNE ..drop				;/
		..high						;\ high: index +4
		INY #2						;/
		..drop						;\
		LDA #$09 : STA !SpriteStatus,x			; | drop: index +2
		INY #2						;/
		..setspeed					;\
		LDA DATA_ThrowSpeedX,y : STA !SpriteXSpeed,x	; |
		LDA DATA_ThrowSpeedY,y : STA !SpriteYSpeed,x	; |
		LDA #$10					; | shared: set speed and interaction disable timers
		STA !SpriteDisP1,x				; |
		STA !SpriteDisP2,x				; |
		STZ !P2Carry					; |
		..done						;/

		LDA !P2Throw : BEQ $03 : JMP .Friction		; throw -> go to friction code (even if in midair!)



	; air/ground split
		LDA !P2InAir : BEQ .Ground


	; air-only code
		.Air
		LDA !P2ShellSlide : BEQ $03 : JMP .ShellSlide	; maintain shell slide in midair

		; the only air-only move Kadaal has is dropkick
		LDA !P2DropKick : BEQ ..checkdropkick		;\
		..rundropkick					; |
		STZ !P2Carry					; |
		LDA !P2Hitbox1IndexMem1				; | if dropkick is happening, look for a hit
		ORA !P2Hitbox1IndexMem2				; |
		ORA !P2Hitbox2IndexMem1				; |
		ORA !P2Hitbox2IndexMem2				; |
		BEQ ..done					;/
		..dropkickhit					;\
		STZ !P2SenkuUsed				; |
		STZ !P2DropKick					; |
		LDA #$C8					; |
		BIT $15						; | on a hit, bounce and regain air special
		BPL $02 : LDA #$A8				; | (bounce heights are in-lined in code)
		STA !P2YSpeed					; |
		LDA #!Kad_DropKickBounce : STA !P2Anim		; |
		STZ !P2AnimTimer				; |
		BRA ..done					;/
		..checkdropkick					;\
		LDA !KadaalUpgrades				; |
		AND #$01 : BEQ ..done				; |
		LDA !P2ShellSpin : BNE ..done			; | conditions for starting dropkick
		LDA $15						; |
		AND #$04 : BEQ ..done				; |
		BIT $16 : BPL ..done				;/
		..startdropkick					;\ start dropkick
		LDA #$01 : STA !P2DropKick			;/
		STZ !P2Buffer					; clear buffer when starting dropkick
		LDA !P2XSpeed
		BPL $03 : EOR #$FF : INC A
		STA $00
		LDA !P2YSpeed
		SEC : SBC $00
		BMI +
		BVC +
		LDA #$80
	+	STA !P2YSpeed
		..done

		JMP .SharedMoves


	; ground-only code
	.Ground
		STZ !P2DropKick					; dropkick always ends on ground
		LDA !P2CoyoteTime				;\ jump buffer
		AND #$80 : TSB !P2Buffer			;/

		.BackDash
		LDA !KadaalUpgrades				;\ must have upgrade to backdash
		AND #$10 : BEQ ..done				;/
		LDA !P2Headbutt					;\ can cancel endlag of headbutt with backdash
		CMP #$11 : BCS ..done				;/
		LDA !P2BackDash					;\ can backdash out of last 8 frames of a backdash
		CMP #$08 : BCC ..canbackdash			;/
		BRA ..backdashing				; during first 8 frames of backdash, d-pad is locked
		..canbackdash					;\
		LDA $18						; | check L/R
		AND #$30 : BEQ ..done				; |
		BIT #$10 : BEQ ..nopivot			;/
		..pivot						;\
		LDA !P2Direction				; |
		INC A						; | R = pivot
		TSB $15						; |
		EOR #$03 : TRB $15				; |
		..nopivot					;/
		LDA #$10 : STA !P2BackDash			; backdash lasts for 16 frames
		LDA $15						;\
		AND #$03 : BEQ ..dir				; |
		DEC A : EOR #$01				; | if holding a direction, use that
		STA !P2Direction				; |
		BRA ..setspeed					;/
		..dir						;\ otherwise use facing direction
		LDA !P2Direction				;/
		..setspeed					;\
		EOR #$01 : TAY					; | instantly get speed
		LDA DATA_XSpeedSenku,y : JSL CORE_SET_XSPEED	;/
		LDA #$2D : STA !SPC1				; slide SFX
		STZ !P2Punch					;\
		STZ !P2ShellSpin				; | clear attacks and senku
		STZ !P2Headbutt					; |
		STZ !P2Senku					;/
		..backdashing					;\
		LDA #$0F					; | clear directionals during first 8 frames of backdash
		TRB $15						; |
		TRB $16						;/
		LDA #$01 : STA !P2Dashing			; set dashing state
		..done


	; shell slide
		.ShellSlide
		LDA $15						;\ must hold down to maintain shell slide
		AND #$04 : BNE ..keepslide			;/
		LDA !P2ShellSlide : BEQ ..endshellspeed		;\
		..endslide					; |
		LDA #$01 : STA !P2Dashing			; | ending the slide lets kadaal keep dash state
		STZ !P2ShellSlide				; | but he can never keep the shell speed flag
		..endshellspeed					; |
		STZ !P2ShellSpeed				; |
		BRA ..done					;/
		..keepslide					;\ return if not sliding
		LDA !P2ShellSlide : BEQ ..done			;/

	LDA !P2Slope : BEQ ..noslope
	EOR !P2XSpeed : BMI ..upslope
	..downslope
	LDA #$02 : STA !P2ShellSpin
	BRA ..noslope
	..upslope
	JSR StartSlide
	..noslope

		JSR ShellSpin					; > can shell spin during slide
		LDA !P2Blocked					;\ check bonk
		AND #$03 : BEQ ..nobonk				;/
		..bonk						;\
		DEC A						; |
		AND #$01					; |
		STA !P2Direction				; | bonk code
		LDA !P2XSpeed					; |
		EOR #$FF : INC A				; |
		STA !P2XSpeed					; |
		LDA #$01 : STA !SPC1				; > bonk SFX
		..nobonk					;/

		LDY !P2Direction				;\
		LDA DATA_XSpeedSenku,y				; | slide acceleration
		LDY #$02					; |
		JSL CORE_ACCEL_X				;/
		LDA #$01 : STA !P2ShellSpeed			; shell speed flag
		LDA #$03					;\
		TRB $15						; | eat side inputs
		TRB $16						;/
>>>>>>> Stashed changes

		JMP .NoDuck					;
		..done						;

<<<<<<< Updated upstream
		LDA #$80 : TRB !P2Water
		LDA !P2Senku
		BNE $03 : JMP .InitSenku
		CMP #$20 : BCC .ProcessSenku
		BNE .NoInitSenku			;\ Set invulnerability timer
		STA !P2Invinc				;/
		LDA !KadaalUpgrades			;\
		AND #$02 : BEQ ..Basic			; | Store all-range senku direction if upgrade is attained
		LDA $6DA3				; |
		AND #$0F : STA !P2AllRangeSenku		;/
		..Basic
		LDA $6DA3
		LSR A
		BCC +
		LDA #$01 : STA !P2SenkuDir
		BRA .ProcessSenku
	+	LSR A
		BCS +

		.NoInitSenku
		LDA #$00
		LDA !P2Direction : STA !P2SenkuDir
		BRA .ReturnSenku
=======


>>>>>>> Stashed changes

	; moves that can be used in the air AND on the ground
	.SharedMoves

<<<<<<< Updated upstream
		.ProcessSenku
		LDA #$01 : STA !P2ShellSpeed
		LDA #$0F
		STA !P2DashTimerR2
		STA !P2DashTimerL2
		LDA #$01 : STA !P2Dashing

		LDY !P2AllRangeSenku : BEQ ..Basic	;\
		CPY #$03 : BCC ..Fast			; |
		STZ !P2ShellSpeed			; |
	..Fast	LDA .AllRangeSpeedY,y : STA !P2YSpeed	; | Allow for 2-dimensional travel with upgrade
		LDA .AllRangeSpeedX,y			; |
		BRA .ReturnSenku_Write			;/

	..Basic	LDY !P2SenkuDir
		LDA .XSpeedSenku,y

		.ReturnSenku
		STZ !P2YSpeed
	..Write	JSR CORE_SET_XSPEED
		STZ !P2JumpLag
		STZ !P2DashTimerR1
		STZ !P2DashTimerL1
		STZ !P2Buffer
		LDA #$01 : TRB !P2Water
		LDA !P2Senku
		CMP #$20
		BCS +
		LDA !P2SenkuDir				;\
		EOR #$01				; |
		INC A					; | Don't keep momentum after senku-ing into a block
		AND !P2Blocked				; |
		BEQ $06					; |
		STZ !P2XSpeed : STZ !P2Dashing		;/
		LDA !P2Blocked
		AND #$04
		ORA !P2Platform
		BNE ++
		LDA #$01 : STA !P2SenkuUsed
		++
		BIT $6DA7
		BPL $06 : STZ !P2Invinc : JMP .SenkuJump
	+	RTS

		.InitSenku
		LDA !P2SenkuUsed : BNE .NoSenku
		LDA !KadaalUpgrades			;\
		ORA !P2Blocked				; | Air senku is only allowed with proper upgrade
		AND #$04				; |
		BEQ .NoSenku				;/

		BIT $6DA9 : BPL .NoSenku
		STZ !P2ShellSlide
		LDA !P2Kick : BMI $02 : BNE .NoSenku
		LDA #$30 : STA !P2Senku
		LDA #$01 : STA !P2SenkuUsed
		STZ !P2ShellDrill
		RTS
		.NoSenku


		LDA !P2Water			; Check for vine/net climb
		LSR A : BCC .NoClimb
		STZ !P2ShellSlide
		LDA $6DA3
		LSR A
		BCC +
		LDA #$01 : STA !P2Direction
		BRA ++
	+	LSR A
		BCC ++
		STZ !P2Direction
	++	BIT $6DA7
		BPL +
		LDA #$01 : TRB !P2Water		; vine/net jump
		LDA #$B8 : STA !P2YSpeed
		LDA #$2B : STA !SPC1		; jump SFX
	+	RTS
		.NoClimb


		LDA !P2Blocked			;\
		AND #$04			; |
		LDY !P2Platform			; | $01 = ground flag
		BEQ $02 : ORA #$04		; |
		STA $01				;/
		BIT !P2Water			;\ Water check
		BVS .Water : JMP .NoWater	;/
=======

	; senku code
		.Senku
		LDA !P2Senku : BNE ..process			; no senku -> can't senku jump

		..initsenku					;\ can not senku if already used
		LDA !P2SenkuUsed : BNE +			;/
		LDA !KadaalUpgrades				;\
		ORA !P2Blocked					; | air senku is only allowed with proper upgrade
		AND #$04 : BEQ +				;/
		BIT $18 : BPL +					; triggered by A press
		STZ !P2Climbing					; drop from net/vine
		LDA !P2ShellSpin : BMI $02 : BNE +		; can senku during shell spin endlag but not active frames
		STZ !P2ShellSlide				;\ end slide
		STZ !P2ShellSpeed				;/
		STZ !P2Ducking					; end crouch
		STZ !P2Dashing					; end dash
		STZ !P2XSpeed					; clear X speed
		STZ !P2Headbutt					; clear headbutt
		STZ !P2ShellSpin				; clear spin attack
		STZ !P2DropKick					; clear drop kick
		LDA #$30 : STA !P2Senku				; senku timer
		LDA #$34 : STA !P2FlashPal			; flash black
		LDA #$01 : STA !P2SenkuUsed			; senku used
		RTS						; end CONTROLS
	+
	-	JMP ..done					; go to crouch code

		..process
		STZ !P2Carry					; end carry when senku starts
		CMP #$20					;\ 01-1F -> moving
		BCC ..moving					;/
		BEQ ..takeoff					; 20 -> takeoff
		..startup					; 21-30 -> startup
		LDA $16						;\ can cancel startup with down press (not hold)
		AND #$04 : BNE -				;/
		LDA #$00 : BRA ..cleary				; no movement during startup

		..takeoff
		STA !P2Invinc					; i-frames
		LDA #$05 : STA !P2DashSmoke			; smoke timer
		LDA !KadaalUpgrades				;\
		AND #$02 : BEQ ..basic				; | store all-range senku direction if upgrade is attained
		LDA $15						; |
		AND #$0F : STA !P2AllRangeSenku			;/
		..basic						;\
		LDA $15						; |
		AND #$03 : BEQ ..dir				; |
		CMP #$02					; |
		BNE $02 : LDA #$00				; | direction without upgrade
		BRA ..setdir					; |
		..dir						; |
		LDA !P2Direction				; |
		..setdir					; |
		STA !P2SenkuDir					;/

		..moving
		BIT $16 : BPL ..nosenkujump			; see if kadaal is jumping out of senku
		LDA !P2InAir : BEQ ..jumpfromsenku		;\
		LDA !KadaalUpgrades				; |
		AND #$01 : BEQ ..jumpfromsenku			; | with upgrade, kadaal can dropkick out of senku
		LDA $15						; |
		AND #$04 : BEQ ..jumpfromsenku			; |
		LDA #$01 : STA !P2DropKick			;/
		..jumpfromsenku					;\ lose i-frames when jumping/kicking out of senku
		STZ !P2Invinc					;/
		JMP .TriggerJump				;\ senku jump
		..nosenkujump					;/

		LDA #$01					;\
		STA !P2ShellSpeed				; | get shell speed + dash from senku
		STA !P2Dashing					;/
		LDA #$0F					;\
		STA !P2DashTimerR				; | set both dash timers, can always dash out of senku
		STA !P2DashTimerL				;/
		LDY !P2AllRangeSenku : BEQ ..sideways		;\
		CPY #$03 : BCC ..fast				; |
		..slow						; |
		STZ !P2ShellSpeed				; | allow for 2-dimensional travel with upgrade
		..fast						; |
		LDA DATA_AllRangeSpeedY,y : STA !P2YSpeed	; |
		LDA DATA_AllRangeSpeedX,y : BRA ..setxspeed	;/
		..sideways					;\
		LDY !P2SenkuDir					; |
		LDA DATA_XSpeedSenku,y				; | sideways senku
		..cleary					; |
		STZ !P2YSpeed					;/
		..setxspeed					;\ set x speed
		STA !P2XSpeed					;/
		STZ !P2JumpLag					; clear jump lag
		STZ !P2Buffer					; clear input buffer
		STZ !P2Climbing					; clear climb flag
		LDA !P2SenkuDir					;\
		EOR #$01					; |
		INC A						; |
		AND !P2Blocked : BEQ ..nobonk			; | lose momentum if senku-ing into a block
		..bonk						; |
		STZ !P2XSpeed : STZ !P2Dashing			; |
		..nobonk					;/
		LDA #$01 : STA !P2SenkuUsed			; set senku used flag
		RTS						; end CONTROLS
		..done



	; crouch code
		.Crouch
		LDA !P2Blocked					;\
		AND $15						; | must hold down while on the ground to crouch
		AND #$04 : BEQ ..done				;/
		LDA !P2Headbutt					;\ can't shell slide during first half of headbutt
		CMP #$11 : BCS ..done				;/ (but the end of it can be cancelled into slide)
		BIT !P2Water : BVS ..inshell			; can't shell slide underwater
		LDA !P2Slope : BNE ..slide			; always start sliding on slopes
		LDA !P2XSpeed					;\
		BPL $03 : EOR #$FF : INC A			; | start shell slide with enough speed
		CMP #$20 : BCC ..inshell			;/
		..slide						;\ start slide
		JSR StartSlide					;/
		JMP .ShellSlide					; go to shell slide code
		..inshell					;\
		STZ !P2XSpeed					; |
		LDA #$01 : STA !P2Ducking			; |
		LDA #$04 : STA !P2JumpLag			; | crouch code
		STZ !P2Punch					; |
		STZ !P2Headbutt					; |
		STZ !P2Dashing					; |
		STZ !P2Senku					;/
		JSR ShellSpin					; can start shell spin
		JMP .Jump					; go to jump handler
		..done



		; a few things jump directly here
		.NoDuck
		LDA !P2Ducking : BEQ .NoDuckEnd			; not ducking: do nothing
		STZ !P2Ducking					;\ ducking: end duck AND spin
		STZ !P2ShellSpin				;/
		.NoDuckEnd




	; climb
		.Climb
		LDA !P2Climbing : BEQ ..done			; check for vine/net climb
		STZ !P2ShellSlide
		LDA $15
		AND #$03 : BEQ ..dirdone
		DEC A
		EOR #$01 : STA !P2Direction
		..dirdone
		BIT $16 : BPL ..return
		STZ !P2Climbing					; vine/net jump
		LDA #$A8 : STA !P2YSpeed
		LDA #$2B : STA !SPC1				; jump SFX
		..return
		RTS
		..done


>>>>>>> Stashed changes

	; codes for starting attacks
		.AttackInputs
		LDA !P2ShellSlide				; can't punch during shell slide
		ORA !P2Carry : BNE ..skip			; can't attack when holding an item
		BIT !P2Buffer : BVS ..attack			; skip regular input if buffered
		BIT $16 : BVC ..skip

		..attack
		STZ !P2BackDash					; clear back dash when an attack is started
		LDA !P2ShellSpin				;\ not spinning: can start a new one
		BEQ ..eatbuffer					;/
		BPL ..done					; spinning: can't buffer or start new spin
		..buffer					;\ endlag: can buffer attack
		LDA #$40 : STA !P2Buffer			;/
		..skip						;\ skip
		JMP ..done					;/
		..eatbuffer					;\ clear attack from buffer
		LDA #$40 : TRB !P2Buffer			;/
		LDA !P2InAir : BEQ ..nospin			;\ must be in midair to air spin
		..airspin					;/
		JSR ShellSpin_Main
		BRA ..done
		..nospin

		LDA !P2TouchingItem : BNE ..done		; can't punch/headbutt when touching item
		LDA !P2Punch					;\
		CMP !P2Headbutt					; |
		BCS $03 : LDA !P2Headbutt			; | can only buffer attack during last 4 frames of punch/headbutt
		CMP #$00 : BEQ ..groundattack			; |
		CMP #$04 : BCS ..done				;/
		LDA #$40 : TSB !P2Buffer			;\ set punch buffer and clear jump buffer
		LDA #$80 : TRB !P2Buffer			;/
		BRA ..done					;

		..groundattack
		STZ !P2JumpLag					; always end jump lag when starting an attack
		LDA !P2XSpeed					;\
		CLC : ADC #$1A					; | headbutt req 1: at least |0x1A| X speed
		CMP #$34 : BCC ..punch				;/
		LDA $15						;\
		AND #$03 : BEQ ..punch				; |
		DEC A						; | headbutt req 2: must hold same direction as moving
		ROR #2						; |
		EOR !P2XSpeed : BMI ..punch			;/
		..headbutt					;\
		LDA #$23 : STA !P2Headbutt			; |
		STZ !P2Punch					; | headbutt
		LDA #$2D : STA !SPC1				; > headbutt init SFX
		LDA #$03 : STA !P2DashSmoke			; > dash smoke for 3 frames
		BRA ..attackshared				;/
		..punch						;\
		LDA #$0E : STA !P2Punch				; |
		STZ !P2Headbutt					; | punch
		LDA #$3D : STA !SPC4				;/> punch init SFX
		..attackshared					;\ eat attack buffer
		LDA #$40 : TRB !P2Buffer			;/
		..done


	; water
		.Water
<<<<<<< Updated upstream
		STZ !P2ShellSlide		; no shell slide underwater
		LDA !P2Anim			;\
		CMP #$11			; |
		BNE +				; | Fall -> swim animation
		LDA #!Kad_Shell : STA !P2Anim	; |
		STZ !P2AnimTimer		; |
		+				;/
		LDA $6DA3			;\
		AND #$0F			; | Swim speed index
		TAY				;/
		LDA !P2YSpeed			;\
		CMP .AllRangeSpeedY,y		; |
		BEQ +				; | Swimming Y speed
		BPL $02 : INC #2		; |
		DEC A				; |
	+	STA !P2YSpeed			;/
		LDA $01 : BEQ +			; Check ground flag
		LDA $6DA3			;\
		AND #$03			; | Walking speed index
		TAY				;/
		BEQ .NoSwimDir			;\
		LDA .SwimDir,y			; | Walking direction
		STA !P2Direction		; |
		.NoSwimDir			;/
		LDA !P2XSpeed			;\
		CMP .WaterSpeedX,y		; | Walking X speed
		BEQ ++				; |
		BPL $02 : INC #2		; |
		DEC A				; |
		STA !P2XSpeed			; |
		BRA ++				; |
		+				;/
		LDA !P2XSpeed			;\
		CMP .AllRangeSpeedX,y		; |
		BEQ +				; | Swimming X speed
		BPL $02 : INC #2		; |
		DEC A				; |
		STA !P2XSpeed			; |
		+				;/
		BPL $02 : EOR #$FF		;\ Store absolute X speed
		STA $00				;/
		LDA !P2YSpeed			;\
		BPL $02 : EOR #$FF		; | Do animation if there is speed
		CLC : ADC $00			; |
		BNE +				;/
		LDA !P2Kick			;\ Always animate spin at 50% rate
		BNE ++				;/
		STZ !P2AnimTimer		;\ Otherewise no animation
		BRA +++				;/
	+	CMP #$20			;\ Animate at 100% rate if |X|+|Y|>0x1F
		BCS +++				;/
	++	LDA $14				;\
		LSR A				; | Animate at 50% rate
		BCC +++				; |
		DEC !P2AnimTimer		;/
	+++	STZ !P2SenkuUsed		; > No animation
		LDA $14				;\
		AND #$7F			; | Only spawn every 128 frames
		BNE +				;/
		LDY #!Ex_Amount-1		; > Number of indexes
	-	DEY				;\
		BMI +				; | Loop for slot
		LDA !Ex_Num,y			; |
		BNE -				;/
		LDA #$12+!ExtendedOffset : STA !Ex_Num,y		;\
		LDA !P2YPosLo			; |
		SEC : SBC #$08			; |
		STA !Ex_YLo,y			; |
		LDA !P2YPosHi			; |
		SBC #$00			; |
		STA !Ex_YHi,y			; | Spawn bubble
		LDX !P2Direction		; |
		LDA .BubbleX,x			; |
		CLC : ADC !P2XPosLo		; |
		STA !Ex_XLo,y			; |
		LDA !P2XPosHi			; |
		ADC #$00			; |
		STA !Ex_XHi,y			;/
	+	RTS
		.NoWater


		LDA !P2ShellSlide : BNE ..Skip		; > Can't punch during shell slide
		BIT !P2Buffer				;\ Skip regular input if buffered
		BVS +					;/
		BIT $6DA7
		BVS $03
	..Skip	JMP .NoPunch
	+	STZ !P2BackDash				; > clear back dash when an attack is started
		LDA !P2Kick : BEQ +			; see if a spin is happening already
		LDA !KadaalUpgrades			;\
		AND #$10 : BEQ ..NoC			; | kadaal can cancel spin into drill
		LDA $6DA3				; |
		AND #$04 : BNE .StartKick_Drill		;/
	..NoC	LDA #$40 : STA !P2Buffer		;\ don't change buffer here if spin is active
		JMP .NoPunch				;/
	+	LDA !P2Anim				;\ can't start spin or shell drill during smash
		CMP #$28 : BCC $03 : JMP .NoPunch	;/
		LDA !P2Blocked
		AND #$04
		ORA !P2Platform
		BEQ .StartKick
		BRA .NoKick

		.StartKick
		LDA !KadaalUpgrades
		AND #$10 : BEQ ..Spin
		LDA $6DA3
		AND #$04 : BEQ ..Spin
	..Drill	LDA #$01 : STA !P2ShellDrill		; start shell drill
		STZ !P2Kick				; cancel shell spin
		LDA #!Kad_ShellDrill : STA !P2Anim
		STZ !P2AnimTimer
		STZ !P2ShellSlide
		STZ !P2ShellSpeed
		BRA .NoPunch

	..Spin	LDA #$10 : STA !P2Kick
		LDA #!Kad_Spin : STA !P2Anim
		LDA #$3E : STA !SPC4			; spin SFX
		STZ !P2AnimTimer
		STZ !P2Punch1
		STZ !P2Punch2
		STZ !P2IndexMem1
		STZ !P2IndexMem2
		BRA .NoPunch

		.PunchBuffer
		LDA #$40 : TSB !P2Buffer		;\ Set punch buffer and clear jump buffer
		LDA #$80 : TRB !P2Buffer		;/
		BRA .NoPunch

		.NoKick
		LDA !P2Punch1
		CMP #$08
		BCS .PunchBuffer
		LDA !P2Punch2
		CMP #$08
		BCS .PunchBuffer
		TAX
		BNE .Punch1

		.Punch2
		LDA #$14 : STA !P2Punch2
		LDA #$40 : TRB !P2Buffer
		LDA #$37 : STA !SPC4			; SFX
		STZ !P2Punch1
		STZ !P2IndexMem1
		STZ !P2IndexMem2
		BRA .NoPunch

		.Punch1
		LDA #$14 : STA !P2Punch1
		LDA #$40 : TRB !P2Buffer
		LDA #$38 : STA !SPC4			; SFX
		STZ !P2Punch2
		STZ !P2IndexMem1
		STZ !P2IndexMem2
		.NoPunch


		LDA !P2ShellDrill : BEQ .NoDrill	;\
		LDA $6DA7				; |
		AND #$08 : BEQ +			; |
		STZ !P2ShellDrill			; | Can cancel drill with up
		LDA #!Kad_Squat : STA !P2Anim		; |
		STZ !P2AnimTimer			; |
		BRA .NoDrill				;/

	+	STZ !P2XSpeed				;\
		LDA #$08 : STA !P2Invinc		; > invulnerable during shell drill
		LDA #$14				; |
		LDY !P2Anim				; |
		CPY #!Kad_ShellDrill : BEQ +		; | Shell drill code
		LDA #$40				; |
	+	STA !P2YSpeed				; |
		RTS					; |
		.NoDrill				;/



		LDA !P2CoyoteTime : BMI +		;\ coyote time
		BNE .InitJump				;/
	+	LDA !P2JumpLag				;\
		BEQ .ProcessJump			; |
		BIT $6DA7 : BPL $05			; | Allow jump buffer from land lag
		LDA #$80 : TSB !P2Buffer		; |
		JMP .Friction				;/
=======
		BIT !P2Water : BVC ..done			; water check
		STZ !P2ShellSlide				;\ no shell slide underwater
		STZ !P2ShellSpeed				;/
		LDA !P2Anim					;\
		CMP #!Kad_Fall+1 : BEQ ..setanim		; |
		CMP #!Kad_Fall+2 : BNE ..animdone		; |
		..setanim					; | fall -> swim anim
		LDA #!Kad_Swim : STA !P2Anim			; |
		STZ !P2AnimTimer				; |
		..animdone					;/
		LDA !P2Water					;\
		ORA !P2Blocked					; |
		AND #$08 : BNE ..nojump				; | jump check: must have head above water and not blocked
		BIT $16 : BPL ..nojump				; |
		JMP .TriggerJump				; |
		..nojump					;/
		JMP WaterPhysics				;\ run water physics
		..done						;/ then end CONTROLS





>>>>>>> Stashed changes

	; this is last because so many things can mess with it

	.HorizontalMovement
		LDA !P2Punch : BNE ..cantmove			;\
		LDA !P2Headbutt : BEQ ..canmove			; |
		CMP #$18 : BCS ..canmove			; | friction during punch and endlag of headbutt
		..cantmove					; |
		JMP .Friction					; |
		..canmove					;/

<<<<<<< Updated upstream
		.ProcessJump
		LDA !P2Blocked
		AND #$04
		ORA !P2Platform
		BEQ .NoJump
	;	LDA !P2Floatiness		;\
	;	CMP #$1A : BCS .NoJump		; |
	;	BIT $6DA3 : BMI .NoJump		; |
	;	STZ !P2Floatiness		; | stop ascent if player lets go of B
	;	BIT !P2YSpeed : BPL .NoJump	; |
	;	LDA !P2YSpeed			; |
	;	CLC : ADC #$20			; |
	;	BMI $02 : LDA #$00		; |
	;	STA !P2YSpeed			; |
	;	BRA .NoJump			;/

		.InitJump
		LDA !P2ShellSlide		;\ This is necessary for some platforms to work
		BNE $03 : STZ !P2Kick		;/
		LDA !P2Buffer
		ORA $6DA7
		BPL .NoJump
		STZ !P2CoyoteTime		; clear coyote time
		STZ !P2ShellSlide		; Clear shell slide
		LDA #!Kad_Squat : STA !P2Anim
		STZ !P2AnimTimer
	;	LDA !P2Punch1			;\
	;	ORA !P2Punch2			; |
	;	BEQ .SenkuJump			; | Allow players to buffer jump from punch
	;	LDA #$80 : STA !P2Buffer	; |
	;	BRA .NoJump			;/

		.SenkuJump
		LDA #$80 : TRB !P2Buffer	; > Clear jump from buffer
		STZ !P2Punch1			;\ Clear punch
		STZ !P2Punch2			;/
		STZ !P2BackDash			; > Clear back dash
		STZ !P2Senku			; > Clear senku
		LDA !P2XSpeed			;\
		BPL $03 : EOR #$FF : INC A	; |
		LDX !P2Dashing			; |
		BEQ $02 : LDA #$30		; |
		STA $00				; | Calculate max jump speed based on X speed
		ASL A				; |
		CLC : ADC $00			; |
		LSR #3				; |
		SEC : SBC #$58			; |
		STA !P2YSpeed			;/

	LDA #$04 : TRB !P2Blocked		; Instantly leave ground

		LDA #$2B : STA !SPC1		; > jump SFX
		LDA #!Kad_Squat : STA !P2Anim	; > Start next animation right away for clipping purposes
		.NoJump


		LDA !P2Punch1
		ORA !P2Punch2
		BEQ $03 : JMP .Friction



		LDA !P2Blocked
		AND #$04
		ORA !P2Platform
		BNE +
		LDA !P2XSpeed
		AND #$80
		CLC : ROL #2
		EOR #$01
		INC A				; > 2 = right, 1 = left
		AND $6DA3
		BEQ .NoDashCancel
		BRA ++

	+	LDA $6DA3
		AND #$03
		BNE .NoDashCancel
	++	STZ !P2Dashing
		.NoDashCancel

		LDA !P2Blocked
		AND #$04
		ORA !P2Platform
		BEQ +
		LDA $6DA7
		LSR A
		BCC +
		LDX !P2DashTimerR2
		BEQ +
		STX !P2Dashing
		+
		LSR A
		BCC +
		LDX !P2DashTimerL2
		BEQ +
		STX !P2Dashing
		+

		LDA !P2Blocked
		AND #$04
		ORA !P2Platform
		BEQ ++
		LDA $6DA3
		LSR A
		BCS .ResetRight
		LDX #$08 : STX !P2DashTimerR1
		LDX !P2DashTimerR2
		BEQ +
		DEC !P2DashTimerR2
		BRA +
		.ResetRight
		LDX #$0F : STX !P2DashTimerR2
		LDY !P2Dashing
		BEQ $03 : STX !P2DashTimerL2
		LDX !P2DashTimerR1
		BEQ +
		DEC !P2DashTimerR1
		+

		LSR A
		BCS .ResetLeft
		LDX #$08 : STX !P2DashTimerL1
		LDX !P2DashTimerL2
		BEQ +
		DEC !P2DashTimerL2
		BRA +
		.ResetLeft
		LDX #$0F : STX !P2DashTimerL2
		LDY !P2Dashing
		BEQ $03 : STX !P2DashTimerR2
		LDX !P2DashTimerL1
		BEQ +
		DEC !P2DashTimerL1
		+
		BRA +++
		++
		STZ !P2DashTimerR1
		STZ !P2DashTimerR2
		STZ !P2DashTimerL1
		STZ !P2DashTimerL2
		+++

		LDX #$01			; Base index = 0
		LDA !P2Dashing
		BEQ $02 : LDX #$02
		LDA !P2ShellSpeed
		BEQ $02 : LDX #$03

		LDA !P2Blocked
		AND #$04
		ORA !P2Platform
		STA $00
		LDA $6DA3
		LSR A
		BCS .Right
		LSR A
		BCS .Left
		LDA $00
		BEQ ++

		.Friction			; This code definitely only runs on the ground
		LDA !P2ShellSlide : BNE ++	;\ Clear shell speed upon touching the ground without shell slide
		STZ !P2ShellSpeed		;/
		++


		LDA !P2XSpeed : BEQ +
		BMI .StopLeft

		.StopRight
		DEC A
		BEQ $01 : DEC A
		JSR CORE_SET_XSPEED
		RTS
=======


	; conditions for starting or ending dash
		.ToggleDash
		LDA !P2InAir : BEQ ..ground			;\ air/ground split
		..air						;/
		LDA !P2XSpeed : BEQ ..done			;\
		ROL #2						; |
		AND #$01					; | in midair, end dash if not holding forward
		INC A						; |
		AND $15 : BEQ ..end				; |
		BRA ..done					;/
		..ground					;\
		LDA $16						; |
		AND #$03 : BEQ ..notstart			; | on ground, start dash if pressing the same direction twice in a row
		TAX						; |
		LDA !P2DashTimerR-1,x : BEQ ..notstart		; |
		LDA #$01 : STA !P2Dashing			;/
		..notstart					;\
		LDA $15						; |
		AND #$03 : BNE ..done				; | on ground, end dash if not holding left/right
		..end						; |
		STZ !P2Dashing					; |
		..done						;/


	; timers
		.DashTimers
		LDA !P2InAir : BNE ..done			;\
		LDA $15						; |
		AND #$03 : BEQ ..done				; | set a direction's dash timer when that direction is held
		TAX						; |
		LDA #$0F : STA !P2DashTimerR-1,x		; |
		..done						;/


	; get speed index
		.SpeedIndex
		LDX #$01					; base index = 1
		LDA !P2Dashing : BEQ ..notdashing		;\ dashing index = 2
		LDX #$02					;/
		LDA #$0F					;\
		STA !P2DashTimerR				; | when dashing, set both timers so kadaal can turn around
		STA !P2DashTimerL				; |
		..notdashing					;/
		LDA !P2ShellSpeed : BNE ..max			;\
		LDA !P2Headbutt : BEQ ..done			; |
		..max						; | shell slide / headbutt index = 3
		LDX #$03					; |
		..done						;/

		LDA $15						;\
		LSR A : BCS .MoveRight				; | acceleration dir
		LSR A : BCS .MoveLeft				;/
>>>>>>> Stashed changes

		.StopLeft
		INC A
		BEQ $01 : INC A
		JSR CORE_SET_XSPEED
	+	RTS

<<<<<<< Updated upstream
		.Right
		LDA !P2ShellSpeed : BNE $07	; Shell speed flag has priority over lacking dash flag
		LDA !P2DashTimerR1
		BEQ $02 : LDX #$00
		LDA !P2XSpeed
		BMI +
		LDY $00 : BNE +++		;\
		CMP .XSpeedRight,x		; | Don't turn abruptly in mid-air
		BCC +				;/
	+++	LDA .XSpeedRight,x
		BRA ++
	+	INC #3
	++	JSR CORE_SET_XSPEED
		LDA #$01 : STA !P2Direction
		RTS

		.Left
		LDA !P2ShellSpeed : BNE $07	; Shell speed flag has priority over lacking dash flag
		LDA !P2DashTimerL1
		BEQ $02 : LDX #$00
		LDA !P2XSpeed
		BEQ +
		BPL +
	++	LDY $00 : BNE +++		;\
		CMP .XSpeedLeft,x		; | Don't turn abruptly in mid-air
		BCS +				;/
	+++	LDA .XSpeedLeft,x
		BRA ++
	+	DEC #3
	++	JSR CORE_SET_XSPEED
		STZ !P2Direction
		RTS

		.XSpeed
		.XSpeedLeft
		db $F4,$E8,$DC,$D0		; Startup, walk, dash, shell slide
=======
	; grounded friction code
		.Friction
		LDA #$08 : STA !P2WalkTimer			; reset walk timer
		LDA !P2ShellSlide : BNE ..return		; return if sliding in shell
		..main						;\
		STZ !P2ShellSpeed				; > kill shell speed
		LDA !P2Slope					; | get slope index to read resting speed
		CLC : ADC #$04					; | base friction = 2
		TAX						; |
		LDY #$02					;/
		LDA !IceLevel : BEQ ..noice			;\
		LDA !P2InAir : BNE ..noice			; |
		LDA $14						; | 25% accel (0.5) on icy ground
		AND #$01 : TAY					; |
		..noice						;/
		LDA DATA_SlopeSpeed,x				;\ accelerate (apply friction)
		JSL CORE_ACCEL_X				;/
		..return					;\ go to jump handler
		BRA .Jump					;/


		.MoveRight
		LDA !P2CanTurn : BEQ +				; check if allowed to turn
		LDA #$01 : STA !P2Direction			; face right
	+	LDA !P2ShellSpeed : BNE ..fast			;\
		LDA !P2WalkTimer : BEQ ..fast			; | during walk startup, use index 0
		LDX #$00					; |
		..fast						;/
		LDY #$03					;\
		BIT !P2XSpeed					; | if turning, accel = 3, otherwise it is 6
		BMI $02 : LDY #$06				; |
		LDA DATA_XSpeedRight,x : BRA .HorzAccel		;/

		.MoveLeft
		LDA !P2CanTurn : BEQ +				; check if allowed to turn
		STZ !P2Direction				; face left
	+	LDA !P2ShellSpeed : BNE ..fast			;\
		LDA !P2WalkTimer : BEQ ..fast			; | during walk startup, use index 0
		LDX #$00					; |
		..fast						;/
		LDY #$03					;\
		BIT !P2XSpeed					; | if turning, accel = 3, otherwise it is 6
		BPL $02 : LDY #$06				; |
		LDA DATA_XSpeedLeft,x				;/

		.HorzAccel
		STA $00						;\
		LDA !IceLevel : BEQ ..noice			; |
		LDA !P2InAir : BNE ..noice			; | 50% accel on icy ground
		TYA						; |
		LSR A						; |
		TAY						;/
		LDA $00						;\
		CMP !P2XSpeed : BEQ ..done			; |
		LDX !P2Anim					; |
		CPX.b #!Kad_Dash_over : BCS +			; |
		INC !P2AnimTimer				; > animate faster when accelerating on icy ground
		CPX.b #!Kad_Walk_over : BCC +			; | running/walking on ice = animate faster when accelerating
		PHA						; | running on ice = spawn smoke while accelerating
		PHY						; |
		JSL CORE_SMOKE_AT_FEET_Always			; |
		PLY						; |
		PLA						;/
	+	JSL CORE_ACCEL_X				;\ icy accel
		BRA ..done					;/
		..noice						;\
		LDA $00						; | full accel on normal ground and in midair
		JSL CORE_ACCEL_X				; |
		..done						;/


>>>>>>> Stashed changes


	; THIS IS THE MAIN JUMP CODE

		.Jump
		LDA $15						;\
		AND #$80					; | clear jump buffer unless jump is held
		EOR #$80					; |
		TRB !P2Buffer					;/
		LDA !P2Buffer					;\ apply jump buffer
		AND #$80 : TSB $16				;/
		LDA !P2CoyoteTime				;\
		BMI +						; |
		BNE ..init					; | can jump if on ground or coyote time is still set
	+	LDA !P2InAir : BNE .NoJump			; |
		..init						;/
		LDA $16 : BPL .NoJump				; check B press
		STZ !P2CoyoteTime				; clear coyote time
		STZ !P2AnimTimer				; clear anim timer

		.TriggerJump
		LDA #$80 : TRB !P2Buffer			; clear jump from buffer
		STZ !P2Punch					; clear punch
		STZ !P2Headbutt					; clear headbutt
		STZ !P2BackDash					; clear back dash
		STZ !P2Senku					; clear senku
		LDA !P2XSpeed					;\
		BPL $03 : EOR #$FF : INC A			; |
		LDX !P2Dashing					; |
		BEQ $02 : LDA #$24				; > use 0x24 during dash to prevent jumps from being inconsistent
		LDX !P2Carry : BEQ ..nocarry			; |
		LDX #$01 : STX !P2Dashing			; > set dash flag when jumping with object
		..nocarry					; | (deliberately placed here so you can get a super jump by combining with coyote jump)
		LDX !P2ShellSlide				; |
		BEQ $02 : LDA #$10				; > use 0x10 during shell slide for a really big jump
		STA $00						; | calculate max jump speed based on X speed
		ASL A : ADC $00					; |
		ROR A : LSR #2					; |
		TAX						; > X = rise timer index
		SEC : SBC #$58					; |
		STA !P2YSpeed					;/
		LDA .RiseTimer,x : STA !P2JumpLag		; set rising frame based on speed
		LDA #$2B : STA !SPC1				; jump SFX
		LDA $16						;\ if player pressed Y on the same frame, buffer it
		AND #$40 : TSB !P2Buffer			;/
		.NoJump
		RTS						; end CONTROLS


<<<<<<< Updated upstream
		.SwimDir
		db $00,$01,$00,$01
=======
	.RiseTimer
	db $09		; 00 - max jump
	db $08		; 01
	db $08		; 02
	db $07		; 03
	db $07		; 04 - startup jump
	db $06		; 05
	db $06		; 06
	db $06		; 07
	db $05		; 08
	db $05		; 09 - walk jump
	db $05		; 0A
	db $04		; 0B
	db $04		; 0C
	db $03		; 0D - dash jump
>>>>>>> Stashed changes

	db $03		; 0E (possible with boost)
	db $03		; 0F (possible with boost)
	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02	; 10-1F (possible with boost)
	db $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01	; 20-2F (possible with boost)

<<<<<<< Updated upstream
	PHYSICS:

		PLA
		BMI $03 : STA !P2Direction
=======

>>>>>>> Stashed changes


	.SenkuSmash			; This has to be before sprite interaction so custom sprites can set the flag
		LDA !KadaalUpgrades
		LSR A : BCC ..Return
		LDA !P2Senku : BEQ ..Return
		LDA !P2SenkuSmash : BEQ ..Return
		BIT $6DA7 : BVC ..Return
		LDA #!Kad_SenkuSmash : STA !P2Anim
		STZ !P2AnimTimer
		LDA #$A0 : STA !P2YSpeed
		LDA #$1C : STA !P2Invinc
		STZ !P2Senku
		LDA #$02 : STA !SPC1		; SFX
		LDA !P2Direction
		EOR #$01
		STA !P2Direction
		ASL #2
		INC A
		TAY
		LDA CONTROLS_XSpeed,y : STA !P2XSpeed
		STZ !P2SenkuUsed
		PEA .Collisions-1
		JMP HITBOX_Smash
		..Return

<<<<<<< Updated upstream
=======
	PHYSICS:
		.Gravity
		LDA !P2DropKick : BEQ ..nodropkick	;\
		LDA #$08 : STA !P2Gravity		; |
		LDA #$60				; |
		BIT !P2Water				; | during dropkick, gravity is 8 and fall speed is 0x60
		BVC $01 : LSR A				; | (underwater, fall speed is halved)
		STA !P2FallSpeed			; |
		BRA ..done				; |
		..nodropkick				;/

		BIT !P2Water : BVC ..nowater		;\
		STZ !P2Gravity				; |
		LDA #$20 : STA !P2FallSpeed		; | lower gravity and fall speed underwater
		BRA ..done				; |
		..nowater				;/

		LDA #$03				; gravity when holding B is 3
		BIT $15					;\ gravity without holding B is 6
		BMI $02 : LDA #$06			;/
		STA !P2Gravity				; store gravity
		LDA #$46 : STA !P2FallSpeed		; fall speed is 0x46
		..done

>>>>>>> Stashed changes

		LDA !P2SlantPipe : BEQ +
		LDA #$40 : STA !P2XSpeed
		LDA #$C0 : STA !P2YSpeed
		+


		JSR HITBOX


<<<<<<< Updated upstream
	.Collisions
		LDA !P2Blocked
		AND #$04
		ORA !P2Platform
		BNE .OnGround
		LDA !P2XSpeed
		BEQ .NoWall
		CLC : ROL #2
		INC A				; 1 = right, 2 = left
		AND !P2Blocked
		BEQ .NoWall
		STZ !P2Dashing
=======
		.Collisions
		LDA !P2XSpeed
		CLC : ADC !P2VectorX
		BEQ ..notblocked
		ROL #2
		AND #$01
		INC A
		AND !P2Blocked : BEQ ..notblocked
		..bonk
>>>>>>> Stashed changes
		STZ !P2XSpeed
		STZ !P2Dashing
		..notblocked
		LDA !P2InAir : BNE ..done
		..ground
		STZ !P2KillCount
		STZ !P2SenkuUsed
		..done





	SPRITE_INTERACTION:
		JSR CORE_SPRITE_INTERACTION


	EXSPRITE_INTERACTION:
		JSR CORE_EXSPRITE_INTERACTION

		.CarryFail
		LDA !P2ShellSlide
		ORA !P2DropKick
		BEQ ..done
		..fail
		STZ !P2Carry				; can't carry during drop kick
		..done



	UPDATE_SPEED:
<<<<<<< Updated upstream
		LDA #$03				; gravity when holding B is 3
		BIT $6DA3				;\ gravity without holding B is 6
		BMI $02 : LDA #$06			;/
		BIT !P2Water				;\ gravity in water is 0
		BVC $02 : LDA #$00			;/
		STA !P2Gravity				; store gravity
		LDA #$46 : STA !P2FallSpeed		; fall speed is 0x46


		LDA !P2Platform
		BEQ .Main
		AND #$0F
		TAX
		LDA $9E,x : STA !P2YSpeed
		LDA $3260,x : STA !P2YFraction
		LDA !P2Blocked : PHA
		LDA !P2XSpeed : PHA
		LDA !P2XFraction : PHA
		BIT !P2Platform
		BVC .Horizontal

		.Vertical
		STZ !P2XSpeed
		BRA .Platform

		.Horizontal
		LDA $AE,x : STA !P2XSpeed
		LDA $3270,x : STA !P2XFraction

		.Platform
		JSR CORE_UPDATE_SPEED
		PLA : STA !P2XFraction
		PLA : STA !P2XSpeed
		PLA : TSB !P2Blocked
		STZ !P2YSpeed

		.Main
		JSR CORE_UPDATE_SPEED
		LDA !P2Platform
		BEQ +
		LDA #$04 : TSB !P2Blocked
		+

=======
		JSL CORE_UPDATE_SPEED

		.Item
		LDX !P2Carry : BEQ ..done
		JSL CORE_CARRY
		..done

>>>>>>> Stashed changes

	OBJECTS:
		LDA !P2InAir : PHA
		REP #$30
		LDA !P2Anim
		AND #$00FF
		ASL #3
		TAY
<<<<<<< Updated upstream
		LDA ANIM+$06,y				;\
		STA $F0					; |
		CLC : ADC #$0004			; | Pointers to clipping
		STA $F2					; |
		CLC : ADC #$0004			; |
		STA $F4					;/
		SEP #$30
		JSR CORE_LAYER_INTERACTION
		PLA
		EOR !P2Blocked
		AND #$04
		BEQ +
		LDA !P2Blocked
		AND #$04
		BEQ +
		LDA #$07 : STA !P2JumpLag
		STZ !P2Kick

		LDA !KadaalUpgrades			;\
		AND #$08 : BEQ +			; |
		LDA !P2XSpeed				; |
		BPL $03 : EOR #$FF : INC A		; |
		CMP #$20 : BCC +			; |
		LDA $6DA3				; | Allow shell slide with upgrade
		AND #$04 : BEQ +			; |
		JSR StartSlide				; |
		+					;/
=======
		LDA ANIM+$06,y : JSL CORE_COLLISION

		.Climbing
		LDA !P2Climbing : BEQ ..done
		STZ !P2Senku
		STZ !P2SenkuUsed
		STZ !P2ShellSpin
		STZ !P2DropKick
		STZ !P2Dashing
		STZ !P2ShellSpeed
		STZ !P2Throw
		..done

		.Landing
		PLA : BEQ ..done			;\ landing detection: midair previous frame, grounded this frame
		LDA !P2InAir : BNE ..done		;/

	; landing code
		LDA !P2ShellSpin : BEQ ..hardlanding	;\
		..softlanding				; | if holding down during shell spin, get soft landing
		LDA $15					; |
		AND #$04 : BNE ..done			;/

		..hardlanding
		LDA #$07 : STA !P2JumpLag
		STZ !P2ShellSpin
		BIT !P2Water : BVS ..done		; can't shell slide underwater
		LDA !P2Slope : BNE +			;\
		LDA !P2XSpeed				; |
		BPL $03 : EOR #$FF : INC A		; |
		CMP #$20 : BCC ..done			; | shell slide check
	+	LDA $15					; |
		AND #$04 : BEQ ..done			; |
		JSR StartSlide				; |
		..done					;/

>>>>>>> Stashed changes

		JSR CORE_CLIMB_GROUND


<<<<<<< Updated upstream
	SCREEN_BORDER:			; This might bug with auto-scrollers
		JSR CORE_SCREEN_BORDER


	ANIMATION:

		LDA !P2ExternalAnimTimer			;\
		BEQ .ClearExternal				; |
		DEC !P2ExternalAnimTimer			; | Enforce external animations
		LDA !P2ExternalAnim : STA !P2Anim		; |
=======
	ATTACK:
		.Punch
		LDA !P2Punch					;\
		CMP #$04 : BCC ..done				; | punch timer thresholds
		CMP #$0D : BCS ..done				;/
		LDY #$00 : BRA .Load				;\ hitbox index 0
		..done						;/

		.Headbutt
		LDA !P2Headbutt : BEQ ..done			;\> if this isn't here it has to be in ..checkair
		CMP #$14 : BCC ..checkair			; |
		CMP #$18 : BCC ..3				; | headbutt timer thresholds
		CMP #$1E : BCC ..2				; |
		CMP #$20 : BCS ..done				;/
	..1	LDY #$02 : BRA .Load				; hitbox index 2
	..2	LDY #$04 : BRA .Load				; hitbox index 4
	..3	LDY #$06 : BRA .Load				; hitbox index 6
		..checkair					;\
		LDA !P2InAir : BEQ ..done			; |
		STZ !P2Headbutt					; | end headbutt early in midair
		LDA #!Kad_Fall : STA !P2Anim			; |
		STZ !P2AnimTimer				;/
		..done

		.Spin
		LDA !P2ShellSpin				;\
		BMI ..done					; |
		BEQ ..done					; | shell spin: hitbox index 8
		LDY #$08 : BRA .Load				; |
		..done						;/

		.DropKick
		LDA !P2DropKick : BEQ .AttacksDone		;\
		LDA !P2Anim					; | dropkick: hitbox index A
		CMP #!Kad_DropKick+2 : BCC .AttacksDone		; |
		LDY #$0A					;/

		.Load
		REP #$20
		LDA DATA_HitboxTable,y : JSL CORE_ATTACK_LoadHitbox
		REP #$20
		LDA !P2Hitbox1IndexMem1
		ORA !P2Hitbox2IndexMem1
		STA !P2Hitbox1IndexMem1
		STA !P2Hitbox2IndexMem1
		SEP #$20
		JSL CORE_GET_TILE_Attack			; terrain collision for attack
		.AttacksDone

		REP #$20					;\
		LDA !P2Hitbox1IndexMem				; |
		ORA !P2Hitbox2IndexMem				; | merge hitboxes
		STA !P2Hitbox1IndexMem				; |
		STA !P2Hitbox2IndexMem				; |
		SEP #$20					;/



	ANIMATION:
		.External
		LDA !P2ExternalAnimTimer : BEQ ..clear		;\
		DEC !P2ExternalAnimTimer			; |
		LDA !P2ExternalAnim : STA !P2Anim		; | enforce external animations
>>>>>>> Stashed changes
		DEC !P2AnimTimer				; |
		JMP .CheckPlayer				;/
		..clear						;\ clear when timer runs out
		STZ !P2ExternalAnim				;/



<<<<<<< Updated upstream

		LDA !P2HurtTimer : BEQ .NoHurt
		LDA #!Kad_Hurt : STA !P2Anim
	-	JMP .HandleUpdate
		.NoHurt

	; drill land check
		LDA !P2Anim
		CMP #!Kad_DrillLand : BCC .NoDrillLand
		LDA !P2JumpLag : BNE -
		STZ !P2Anim
		STZ !P2AnimTimer
		.NoDrillLand
=======
	; pipe check
		.Pipe
		LDA !P2Pipe					;\
		ORA !P2SlantPipe				; |
		BEQ ..done					; |
		LDA !P2Anim					; |
		CMP #!Kad_Shell : BCC ..set			; | pipe animations
		CMP #!Kad_Shell_over : BCC .GoToDraw		; | (includes slant)
		..set						; |
		LDA #!Kad_Shell : BRA .SetAnim			; |
		..done						;/


	; entrance check
		.Entrance
		LDA !P2Entrance : BEQ ..done			;\ animate on timer 1-20
		CMP #$21 : BCS ..done				;/
		CMP #$10 : BCC ..handleanim			;\
		CMP #$18 : BCC ..half				; |
		..full						; |
		LDA $14						; |
		BRA ..finish					; |
		..half						; |
		LDA $14						; |
		LSR A : BCC ..handleanim			; | spawn smoke
		..finish					; |
		AND #$01					; |
		BEQ $02 : LDA #$40				; |
		SBC #$20					; |
		STA !P2XSpeed					; |
		JSL CORE_DASH_SMOKE				; |
		..handleanim					;/
		STZ !P2XSpeed					; zero x speed
		LDA !P2Anim					;\
		CMP #!Kad_Victory : BCC ..set			; |
		CMP #!Kad_Victory_over : BCS ..set		; |
		JMP .GoToDraw					; | set animation
		..set						; |
		LDA #!Kad_Victory : BRA .SetAnim		; |
		..done						;/


	; hurt check
		.Hurt
		LDA !P2HurtTimer : BEQ ..done
		LDA #!Kad_Hurt : BRA .SetAnim
		..done

	; carry check
		.Carry
		LDA !P2Carry : BEQ ..done
		LDA !P2InAir : BEQ ..ground
		..air
		LDA #!Kad_Carry+2 : BRA .SetAnim
		..ground
		LDA !P2XSpeed : BNE ..walk
		LDA #!Kad_Carry : BRA .SetAnim
		..walk
		LDA !P2Anim
		CMP #!Kad_Carry : BCC ..set
		CMP #!Kad_Carry_over : BCC .GoToDraw
		..set
		LDA #!Kad_Carry : BRA .SetAnim
		..done

	; throw check
		.Throw
		LDA !P2Throw : BEQ +
		LDA #!Kad_Throw

	; branch assist 1
		.SetAnim
		STA !P2Anim
		STZ !P2AnimTimer
		.GoToDraw
		JMP .CheckPlayer
		+

>>>>>>> Stashed changes

	; spin check before duck and slide checks
		.ShellSpin
		LDA !P2ShellSpin
		BEQ ..done
		BMI ..done
		LDA !P2Anim
<<<<<<< Updated upstream
		CMP #!Kad_Fall : BNE +
		STZ !P2Kick
	+	LDA !P2Kick
		BEQ $03 : JMP .HandleUpdate

	; slide check
		LDA !P2ShellSlide
		BEQ .NoSlide
		LDA !P2Anim
		CMP #!Kad_Shell : BCC +
		CMP #!Kad_Shell+4 : BCC ++
	+	LDA #!Kad_Shell : STA !P2Anim
		STZ !P2AnimTimer
	++	JMP .HandleUpdate
		.NoSlide


		LDA !P2Water
		LSR A : BCC .NoClimb
		LDA !P2Anim
		CMP #!Kad_Climb : BEQ +
		CMP #!Kad_Climb+1 : BEQ +
		LDA #!Kad_Climb : STA !P2Anim
		STZ !P2AnimTimer
	+	LDA $6DA3
		AND #$0F
		BNE +
=======
		CMP #!Kad_Spin : BCC ..set
		CMP #!Kad_Spin_over : BCC .GoToDraw
		..set
		LDA #!Kad_Spin : BRA .SetAnim
		..done


	; slide check
		.Slide
		LDA !P2ShellSlide : BEQ ..done
		LDA !P2Anim
		CMP #!Kad_Shell : BCC ..set
		CMP #!Kad_Shell_over : BCC .GoToDraw
		..set
		LDA #!Kad_Shell : BRA .SetAnim
		..done

	; climb check
		.Climb
		LDA !P2Climbing : BEQ ..done
		LDA !P2Anim
		CMP #!Kad_Climb : BCC ..startclimb
		CMP #!Kad_Climb_over : BCC ..climbing
		..startclimb
		LDA #!Kad_Climb : BRA .SetAnim
		..climbing
		LDA $15
		AND #$0F : BNE .GoToDraw
>>>>>>> Stashed changes
		STZ !P2AnimTimer
		JMP .CheckPlayer
		..done

<<<<<<< Updated upstream
	; duck check
		BIT !P2Water : BPL .NoDuck
		LDA !P2Anim
		CMP #!Kad_Duck : BEQ +
		CMP #!Kad_Duck+1 : BEQ +
		LDA #!Kad_Duck : STA !P2Anim
		STZ !P2AnimTimer
	+	JMP .HandleUpdate
		.NoDuck

		LDA !P2Punch1 : BEQ .NoPunch1
		CMP #!Kad_Punch1 : BNE .ReturnPunch
		LDA #!Kad_Punch1 : STA !P2Anim
		STZ !P2AnimTimer

		.ReturnPunch
		JMP .HandleUpdate
		.NoPunch1

		LDA !P2Punch2 : BEQ .NoPunch2
		CMP #!Kad_Punch1 : BNE .ReturnPunch
		LDA #!Kad_Punch2 : STA !P2Anim
		STZ !P2AnimTimer
		JMP .HandleUpdate
		.NoPunch2

		LDA !P2Senku : BEQ +
		CMP #$20 : BCC .Senku
		LDA #!Kad_Walk+1
		STZ !P2AnimTimer
		BRA .SenkuEnd

		.Senku
		LDA #!Kad_Senku

		.SenkuEnd
		STA !P2Anim
		JMP .HandleUpdate

	+	LDA !P2Anim
		CMP #!Kad_SenkuSmash : BCC $03 : JMP .HandleUpdate

		LDA !P2JumpLag : BEQ +
	-	LDA #!Kad_Squat : STA !P2Anim
		STZ !P2AnimTimer
		JMP .HandleUpdate
	+	LDA !P2Blocked
		AND #$04
		ORA !P2Platform
		ORA !P2SpritePlatform
		BNE .OnGround
		BIT !P2Water : BVS +
		LDA !P2YSpeed : BMI +
		CMP #$08 : BCC -		; > Half-shell frame at 0x00 < speed < 0x08
		LDA !P2Anim
		CMP #!Kad_Squat : BNE $03 : JMP .HandleUpdate
		CMP #!Kad_Shell : BCC .Fall
		CMP #!Kad_Shell+4 : BCC -

	.Fall	LDA #!Kad_Fall : STA !P2Anim
		STZ !P2AnimTimer
		JMP .HandleUpdate
	+	LDA !P2Anim
		CMP #!Kad_Fall
		BNE $03 : JMP .HandleUpdate
		BCS +
		CMP #!Kad_Shell : BCS .HandleUpdate
	+	LDA #!Kad_Shell : STA !P2Anim
		STZ !P2AnimTimer
		BRA .HandleUpdate
=======
	; crouch check
		.Crouch
		LDA !P2Ducking : BEQ ..done
		LDA !P2Anim
		CMP #!Kad_Duck : BCC ..set
		CMP #!Kad_Duck_over : BCC .GoToDraw
		..set
		LDA #!Kad_Duck : BRA .SetAnim
		..done

	; punch check
		.Punch
		LDA !P2Punch : BEQ ..done
		LDA !P2Anim
		CMP #!Kad_Punch : BCC ..set
		CMP #!Kad_Punch_over : BCC .GoToDraw
		..set
		LDA #!Kad_Punch : BRA .SetAnim2
		..done

	; headbutt check
		.Headbutt
		LDA !P2Headbutt : BEQ ..done
		LDA !P2Anim
		CMP #!Kad_Headbutt : BCC ..set
		CMP #!Kad_Headbutt_over : BCC .GoToDraw2
		..set
		LDA #!Kad_Headbutt : BRA .SetAnim2
		..done

	; drop kick check
		.DropKick
		LDA !P2DropKick : BEQ ..done
		LDA !P2Anim
		CMP #!Kad_DropKick : BCC ..set
		CMP #!Kad_DropKick_over : BCC .GoToDraw2
		..set
		LDA #!Kad_DropKick : BRA .SetAnim2
		..done


	; senku check
		.Senku
		LDA !P2Senku : BEQ ..done
		CMP #$20 : BCC ..main
		..startup
		LDA #!Kad_Walk+3 : BRA .SetAnim2
		..main
		LDA #!Kad_Senku : BRA .SetAnim2
		..done

	; squat/jump lag
		.Squat
		LDA !P2JumpLag : BEQ ..done
		LDA !P2InAir : BEQ ..ground
		..air
		LDA #!Kad_Fall+0 : BRA .SetAnim2		; different frames depending on air/ground
		..ground
		LDA #!Kad_Squat : BRA .SetAnim2
		..done



	; air/ground split
		LDA !P2InAir : BEQ .OnGround

	; air
		.Air
		BIT !P2Water : BVC +

		.Water
		LDA !P2Anim
		CMP #!Kad_Spin : BCC ..swim			;\ can't cancel spin into swim anim
		CMP #!Kad_Spin_over : BCC .GoToDraw2		;/
		..swim
		CMP #!Kad_Swim : BCC ..setswim
		CMP #!Kad_Swim_over : BCC .GoToDraw2
		..setswim
		LDA #!Kad_Swim

	; branch assist 2
		.SetAnim2
		STA !P2Anim
		STZ !P2AnimTimer
		.GoToDraw2
		JMP .CheckPlayer
		+

	; drop kick bounce check
		.DropKickBounce
		LDA !P2Anim					;\
		CMP #!Kad_DropKickBounce : BCC ..done		; |
		CMP #!Kad_DropKickBounce_over : BCS ..done	; | drop kick bounce has priority when Y speed < 8
		LDA !P2YSpeed : BMI .GoToDraw2			; |
		CMP #$08 : BCC .GoToDraw2			;/
		LDA #!Kad_Fall+1 : BRA .SetAnim2		;\ transition into fall without using first frame
		..done						;/

	; air speed check
		.AirSpeed
		LDA !P2YSpeed : BMI .Rise

	; fall check
		.Fall
		CMP #$08 : BCC ..set				; > half-shell frame at 0x00 < speed < 0x08
		LDA !P2Anim
		CMP #!Kad_Fall : BCC ..set
		CMP #!Kad_Fall_over : BCC .GoToDraw2
		..set
		LDA #!Kad_Fall : BRA .SetAnim2

	; rise check
		.Rise
		LDA !P2Anim
		CMP #!Kad_Shell : BCS .GoToDraw2
		LDA #!Kad_Shell : BRA .SetAnim2

>>>>>>> Stashed changes

	; ground
		.OnGround
		LDA $6DA3
		AND #$03
		ORA !P2XSpeed
		BNE .Move

	; idle
		.Idle
		LDA !P2Anim
<<<<<<< Updated upstream
		CMP #!Kad_Idle+4 : BCC .HandleUpdate
=======
		CMP #!Kad_Squat : BEQ .CheckPlayer
		CMP #!Kad_Idle_over : BCC .CheckPlayer
>>>>>>> Stashed changes
		STZ !P2Anim
		STZ !P2AnimTimer
		BRA .CheckPlayer

	; moving on ground
		.Move
		LDX !P2BackDash : BNE .Turn		; back dash frame
		LDX !P2Dashing
		BEQ .Walk
		BIT !P2Water
		BVS .Walk
		ROL #2
		EOR !P2Direction
		LSR A : BCS .NoTurn
		LDA !P2XSpeed
		BPL $03 : EOR #$FF : INC A
		CMP #$10 : BCC .NoTurn

	; turn
		.Turn
		LDA #!Kad_Turn : STA !P2Anim
		LDA #$2D : STA !SPC1
<<<<<<< Updated upstream
		BRA .HandleUpdate
=======
		JSL CORE_SMOKE_AT_FEET
		BRA .CheckPlayer
>>>>>>> Stashed changes
		.NoTurn

	; dash
		.Dash
		LDA !P2Anim
<<<<<<< Updated upstream
		CMP #!Kad_Dash-1 : BCC +
		CMP #!Kad_Dash+6 : BCC .HandleUpdate
	+	LDA #!Kad_Dash : STA !P2Anim
=======
		CMP #!Kad_Dash : BCC ..set
		CMP #!Kad_Dash_over : BCC .CheckPlayer
		..set
		LDA #!Kad_Dash : STA !P2Anim
>>>>>>> Stashed changes
		STZ !P2AnimTimer
		BRA .CheckPlayer

	; walk
		.Walk
		LDA !P2Anim
<<<<<<< Updated upstream
		CMP #!Kad_Walk-1 : BCC +
		CMP #!Kad_Walk+4 : BCC .HandleUpdate
	+	LDA #!Kad_Walk
		STA !P2Anim
		STZ !P2AnimTimer

		.HandleUpdate
		LDA !P2Anim
		REP #$30
		AND #$00FF
		ASL #3
		TAY
		LDA ANIM+$00,y
		STA $0E
		SEP #$20
		LDA !P2AnimTimer
		INC A
		CMP ANIM+$02,y
		BNE .NoUpdate
		LDA ANIM+$03,y
		STA !P2Anim
		REP #$20
		AND #$00FF
		ASL #3
		TAY
		LDA ANIM+$00,y
		STA $0E
		SEP #$20
		LDA #$00

		.NoUpdate
		STA !P2AnimTimer
		LDA !MultiPlayer : BEQ .ThisOne		; animate at 60fps on single player
		LDA !CurrentPlayer
		BEQ +
		LDA $14
		LSR A
		BCS .ThisOne
		BRA .OtherOne
	+	LDA $14
		LSR A
		BCC .ThisOne

		.OtherOne
=======
		CMP #!Kad_Walk : BCC ..set
		CMP #!Kad_Walk_over : BCC .CheckPlayer
		..set
		LDA #!Kad_Walk
		STA !P2Anim
		STZ !P2AnimTimer


	; unpack
	.CheckPlayer
		LDA !MultiPlayer : BEQ ..thisone	; animate at 60fps on single player
		LDA $14
		AND #$01
		CMP !CurrentPlayer : BEQ ..thisone
		..otherone
>>>>>>> Stashed changes
		REP #$30
		LDA !P2Anim2
		AND #$00FF
		ASL #3 : TAY
		LDA ANIM+$00,y : STA $0E
		SEP #$30
		BRA GRAPHICS
<<<<<<< Updated upstream

		.ThisOne
=======
		..thisone
>>>>>>> Stashed changes
		REP #$30
		LDA !P2Anim
		AND #$00FF
		ASL #3 : TAY
		LDA ANIM+$04,y : STA $00
		LDA ANIM+$00,y : STA $0E


; -- dynamo format --
;
; 1 byte header (size)
; for each upload:
; 	cccssss-
; 	-ccccccc
; 	ttttt---
;
; ssss:		DMA size (shift left 4)
; cccccccccc:	character (formatted for source address)
; ttttt:	tile number (shift left 1 then add VRAM offset)

<<<<<<< Updated upstream
		LDY.w #!File_Kadaal
		JSL !GetFileAddress
=======
		LDA !P2Anim
		AND #$00FF
		CMP.w #!Kad_Swim : BCC ..normalfile
		CMP.w #!Kad_Swim_over : BCS ..normalfile
		..linearfile
		LDA !SD_KadaalLinear-1
		AND #$FC00 : STA !FileAddress
		LDA !SD_KadaalLinear
		AND #$0003 : TAX
		LDA.l CORE_SD_BANK,x : STA !FileAddress+2
		STZ $2250
		LDA $785F
		BPL $04 : EOR #$FFFF : INC A
		XBA
		AND #$00FF
		STA $2251
		LDA #$0200 : STA $2253
		NOP
		LDA !FileAddress+0
		CLC : ADC $2306
		STA !FileAddress+0
		BRA ..update
		..normalfile
		LDY.w #!File_Kadaal : JSL GetFileAddress
		..update

>>>>>>> Stashed changes


		LDA ($00)					;\
		AND #$00FF					; |
		STA $02						; |
		LDX #$0000					; |
		LDY #$0000					; |
		INC $00						; |
	-	LDA ($00),y					; |
		AND #$001E					; |
		ASL #4						; |
		STA !BigRAM+$00+2,x				; |
		LDA ($00),y					; |
		AND #$7FE0					; |
		CLC : ADC !FileAddress				; |
		STA !BigRAM+$02+2,x				; | unpack dynamo data
		LDA !FileAddress+2 : STA !BigRAM+$04+2,x	; |
		INY #2						; |
		LDA ($00),y					; |
		ASL A						; |
		AND #$01F0					; |
		ORA #$6200					; |
		STA !BigRAM+$05+2,x				; |
		INY						; |
		TXA						; |
		CLC : ADC #$0007				; |
		TAX						; |
		CPY $02 : BCC -					;/
		STX !BigRAM+0					; > set size

		LDA.w #!BigRAM : JSR CORE_GENERATE_RAMCODE
		SEP #$30
		LDA !P2Anim : STA !P2Anim2


<<<<<<< Updated upstream
=======


>>>>>>> Stashed changes
	GRAPHICS:
		LDA !P2HurtTimer : BNE .DrawTiles
		LDA !P2Anim
<<<<<<< Updated upstream
		CMP #!Kad_SenkuSmash : BCS .DrawTiles
		CMP #!Kad_Spin : BCC +
		CMP #!Kad_Spin+4 : BCC .DrawTiles
		+
=======
		CMP #!Kad_Spin : BCC .Flash
		CMP #!Kad_Spin_over : BCC .DrawTiles
>>>>>>> Stashed changes


		LDA !P2Invinc : BEQ .DrawTiles
		AND #$06 : BNE .DrawTiles
		PLB
		RTS


		.DrawTiles
		REP #$20
		LDA $0E : STA $04
<<<<<<< Updated upstream
		LDA $0F : STA $05
		JSR CORE_LOAD_TILEMAP
		PLB
		RTS
=======
		SEP #$20
		JSL CORE_LOAD_TILEMAP
>>>>>>> Stashed changes



	StartSlide:
		LDA #$01 : STA !P2ShellSlide		;\
		LDA !P2XSpeed				; |
		ROL #2					; |
		AND #$01				; | Set slide
		EOR #$01				; |
		STA !P2Direction			; |
		RTS					;/



;==============;
;HITBOX HANDLER;
;==============;

<<<<<<< Updated upstream
	HITBOX:

		LDA !P2Kick : BEQ .CheckPunch

		.Spin
		REP #$20
		LDY #$00
		LDA !P2XPosLo
		CLC : ADC SPIN+0,y
		STA $00
		STA $07
		STA !P2Hitbox+0
		LDA !P2YPosLo
		CLC : ADC SPIN+2,y
		STA !P2Hitbox+2
		SEP #$20
		STA $01
		XBA
		STA $09
		LDA SPIN+4,y
		STA $02
		STA !P2Hitbox+4
		LDA SPIN+5,y
		STA $03
		STA !P2Hitbox+5
		BRA .GetClipping

		.CheckPunch
		LDA !P2Punch1
		ORA !P2Punch2
		CMP #$05 : BCS .DoPunch
		STZ !P2IndexMem1
		STZ !P2IndexMem2
		RTS
=======
		.Carry
		LDX !P2Carry : BEQ ..done
		LDY !P2Anim
		CPY #!Kad_Carry : BCC ..done
		DEX
		LDA !P2Direction
		BEQ $02 : LDA #$FF
		STA $00
		STZ $01
		BEQ $02 : INC $01
		ASL $01
		LDA DATA_CarryXOffset-(!Kad_Carry),y
		SEC : SBC $01
		EOR $00
		STZ $00
		BPL $02 : DEC $00
		CLC : ADC !P2XPosLo
		STA !SpriteXLo,x
		LDA !P2XPosHi
		ADC $00
		STA !SpriteXHi,x
		LDA !P2YPosLo
		CLC : ADC DATA_CarryYOffset-(!Kad_Carry),y
		STA !SpriteYLo,x
		LDA !P2YPosHi
		ADC #$FF
		STA !SpriteYHi,x
		..done
>>>>>>> Stashed changes

		.DoPunch
		CMP #$0E
		BCS .Punch0
		LDY #$0C
		LDA !P2Direction
		BEQ .PunchShared
		LDY #$12
		BRA .PunchShared

		.Punch0
		LDY !P2Direction			;\ Direction
		BEQ $02 : LDY #$06			;/

		.PunchShared
		REP #$20				; > A 16 bit
		LDA !P2XPosLo				;\ Get Xpos
		CLC : ADC PUNCH+0,y			;/
		STA $00					; > Lo byte in $00
		STA $07					; > Hi byte in $08
		STA !P2Hitbox+0				; Store hitbox X
		LDA !P2YPosLo				;\ Get Ypos
		CLC : ADC PUNCH+2,y			;/
		STA !P2Hitbox+2				; Store hitbox Y
		SEP #$20				; > A 8 bit
		STA $01					; > Lo byte in $01
		XBA					;\ Hi byte in $09
		STA $09					;/
		LDA PUNCH+4,y : STA $02			; > Width
		STA !P2Hitbox+4				; Store hitbox W
		LDA PUNCH+5,y : STA $03			; > Height
		STA !P2Hitbox+5				; Store hitbox H

		.GetClipping
		LDX #$0F

		.Loop
		CPX #$08 : BCS +			;\
		LDA !P2IndexMem1 : BRA ++		; | check index memory
	+	LDA !P2IndexMem2			; |
	++	AND CORE_BITS,x : BNE .LoopEnd		;/



		LDA !AnimToggle				;\ If animation is off, there's an advanced enemy nearby
		BEQ .Normal				;/

		.Advanced
		LDA $3230,x
		CMP #$02 : BEQ .Valid
		CMP #$08 : BCC .LoopEnd
	.Valid	LDA !ExtraBits,x
		AND #$08
		BEQ +
		LDA !NewSpriteNum,x
		CMP #$08
		BNE +
		JSR CaptainWarrior
		BRA ++

		.Normal
		LDA $3230,x
		CMP #$02 : BEQ +
		CMP #$08 : BCC .LoopEnd
	+	JSL $03B69F
	++	JSL $03B72B
		BCC .LoopEnd

		JSR CORE_ATTACK_Setup

<<<<<<< Updated upstream
		LDA !ExtraBits,x
		AND #$08
		BEQ .LoBlock

		.HiBlock
		LDY !NewSpriteNum,x
		LDA HIT_TABLE+$100,y
		BRA .AnyBlock

		.LoBlock
		LDY $3200,x
		LDA HIT_TABLE,y

		.AnyBlock
		ASL A : TAY
		PEA .LoopEnd-1
		REP #$20
		LDA HIT_Ptr+0,y
		DEC A
		PHA
		SEP #$20
		RTS

		.LoopEnd
		DEX : BPL .Loop

		LDX #!Ex_Amount-1

		.HammerLoop
		LDA !Ex_Num,x
		AND #$7F
		CMP #$04+!ExtendedOffset : BNE .HammerEnd
		LDA !Ex_Data3,x
		LSR A : BCS .HammerEnd
		LDA !Ex_XLo,x : STA $04		;\ Xpos
		LDA !Ex_XHi,x : STA $0A		;/
		LDA !Ex_YLo,x : STA $05		;\ Ypos
		LDA !Ex_YHi,x : STA $0B		;/
		LDA #$10 : STA $06		; > Width
		STA $07				; > Height
		JSL $03B72B			;\ Check for contact
		BCC .HammerEnd			;/
		JSR CORE_DISPLAYCONTACT		; contact gfx
		LDA #$02 : STA !SPC1
		STZ !Ex_YSpeed,x		; > Yspeed = 0
		LDY !P2Direction		;\
		LDA KNOCKOUT_XSpeed,y		; | XSpeed depends on p2 direction
		STA !Ex_XSpeed,x		;/
		LDA !Ex_Data3,x
		ORA #$01
		STA !Ex_Data3,x			; > Hammer belongs to players

		.HammerEnd
		DEX
		BPL .HammerLoop

		.Return
		RTS

	.Smash
		LDY #$06
		JMP .Spin


	; Hitbox format is Xdisp (lo+hi), Ydisp (lo+hi), width, height.

	PUNCH:
	.0
	dw $FFF8,$FFFA : db $08,$0C		; Left
	dw $0010,$FFFA : db $08,$0C		; Right
	.1
	dw $FFF4,$FFFA : db $0C,$0C		; Left
	dw $0010,$FFFA : db $0C,$0C		; Right


	SPIN:
	dw $FFF8,$0000 : db $20,$10		; Same for both directions

	SMASH:
	dw $FFF8,$FFF8 : db $20,$20		; Same for both directions


	CaptainWarrior:
		LDY $3320,x
		BEQ $02 : LDY #$06
		LDA $3220,x
		CLC : ADC .Data+$00,y
		STA $04
		LDA $3250,x
		ADC .Data+$01,y
		STA $0A
		LDA $3210,x
		CLC : ADC .Data+$02,y
		STA $05
		LDA $3240,x
		ADC .Data+$03,y
		STA $0B
		LDA .Data+$04,y : STA $06
		LDA .Data+$05,y : STA $07
		RTS

	.Data
	dw $FFF8,$FFE4 : db $18,$30		; Right
	dw $FFF8,$FFE4 : db $18,$30		; Left


	HIT_Ptr:
	dw HIT_00
	dw HIT_01
	dw HIT_02
	dw HIT_03
	dw HIT_04
	dw HIT_05
	dw HIT_06
	dw HIT_07
	dw HIT_08
	dw HIT_09
	dw HIT_0A
	dw HIT_0B
	dw HIT_0C
	dw HIT_0D
	dw HIT_0E
	dw HIT_0F
	dw HIT_10
	dw HIT_11
	dw HIT_12
	dw HIT_13
	dw HIT_14
	dw HIT_15
	dw HIT_16
	dw HIT_17
	dw HIT_18
	dw HIT_19
	dw HIT_1A
	dw HIT_1B	; < Captain Warrior
	dw HIT_1C
	dw HIT_1D


	HIT_00:
		RTS

	HIT_01:
		; Knock out always
		JMP KNOCKOUT

	HIT_02:
		; Knock out of shell, send shell flying
		LDA $3230,x
		CMP #$02 : BEQ .Knockback
		CMP #$08 : BEQ .Standard
		CMP #$09 : BEQ .Knockback
		CMP #$0A : BNE HIT_00
		LDA $3200,x			;\
		CMP #$07 : BNE .Knockback	; | Shiny shell is immune to attacks
		LDA #$02 : STA !SPC1		; |
		RTS				;/

		.Knockback
		JSR CORE_ATTACK_Main
		LDA #$09 : STA $3230,x
		JMP KNOCKBACK

		.Standard
		LDA $3200,x
		CMP #$08
		BCS .Stun

		JSL $02A9DE			; Get new sprite number into Y
		BMI .Stun			; If there are no empty slots, don't spawn

		LDA $3200,x
		SEC : SBC #$04
		STA $3200,y			; Store sprite number for new sprite
		LDA #$08 : STA $3230,y		; > Status: normal
		LDA $3220,x			;\
		STA $3220,y			; |
		LDA $3250,x			; |
		STA $3250,y			; | Set positions
		LDA $3210,x			; |
		STA $3210,y			; |
		LDA $3240,x			; |
		STA $3240,y			;/
		PHX				;\
		TYX				; | Reset tables for new sprite
		JSL $07F7D2			; |
		PLX				;/
		LDA #$10			;\
		STA $32B0,y			; | Some sprite tables that SMW normally sets
		STA $32D0,y			; |
		LDA #$01 : STA $3310,y		;/


		LDA CORE_BITS,y
		CPY #$08 : BCS +
		TSB !P2IndexMem1 : BRA ++
	+	TSB !P2IndexMem2
		++

		LDA #$10 : STA $3300,y		; > Temporarily disable player interaction
		LDA $3430,x			;\ Copy "is in water" flag from sprite
		STA $3430,y			;/
		LDA #$02 : STA $32D0,y		;\ Some sprite tables
		LDA #$01 : STA $30BE,y		;/

		PHX
		LDA !P2Direction
		EOR #$01
		STA $3320,y
		TAX				; X = new sprite direction
		LDA CORE_KOOPA_XSPEED,x		; Load X speed table indexed by direction
		STA $30AE,y			; Store to new sprite X speed
		PLX

		.Stun
		LDA #$09 : STA $3230,x		; > Stun sprite
		LDA $3200,x			;\
		CMP #$08			; | Check if sprite is a Koopa
		BCC .DontStun			;/
		LDA #$FF : STA $32D0,x		; > Stun if not

		.DontStun
		RTS


	HIT_03:
		; Knock back and clip wings
		LDA $3230,x
		CMP #$08
		BNE HIT_02_DontStun
		LDA $3200,x			; Load sprite sprite number
		SEC : SBC #$08			; Subtract base number of Parakoopa sprite numbers
		TAY
		LDA CORE_PARAKOOPACOLOR,y	; Load new sprite number
		STA $3200,x			; Set new sprite number
		LDA #$01 : STA $3230,x		; > Initialize sprite
		JSR CORE_ATTACK_Main
		JMP KNOCKBACK

	HIT_04:
		; Knock back and stun
		LDA $3230,x
		CMP #$08
		BEQ .Main
		CMP #$09
		BNE HIT_07

		.Main
		JSR CORE_ATTACK_Main
		LDA $3200,x
		CMP #$40
		BEQ .ParaBomb
		LDA #$09			;\
		STA $3230,x			; | Regular Bobomb code (stuns it)
		BRA .Shared			;/

		.ParaBomb
		LDA #$0D : STA $3200,x		; > Sprite = Bobomb
		LDA #$01 : STA $3230,x		; > Initialize sprite
		JSL $07F7D2			; > Reset sprite tables

		.Shared
		JMP KNOCKBACK

	HIT_05:
		; Knock back and stun
		LDA $3230,x
		CMP #$08
		BEQ .Main
		CMP #$09
		BNE HIT_07

		.Main
		JSR CORE_ATTACK_Main
		LDA #$09 : STA $3230,x
		LDA #$FF : STA $32D0,x
		JMP KNOCKBACK

	HIT_06:
		; Knock back, stun, and clip wings
		LDA $3230,x
		CMP #$08
		BNE HIT_07
		LDA #$0F : STA $3200,x		; Set new sprite number
		JSL $07F7D2			; Reset sprite tables
		BRA HIT_05_Main			; Handle like normal

	HIT_07:
		; Do nothing
		RTS

	HIT_08:
		; Knock out always
	HIT_09:
		; Knock out always
	HIT_0A:
		; Knock out always
		JMP KNOCKOUT

	HIT_0B:
		; Collect
		JMP CORE_INT_0B+3		; skip LDX $7695 to avoid index confusion

	HIT_0C:
		; Knock out if at same depth
		LDA $3410,x			;\ Don't process interaction while sprite is behind scenery
		BNE HIT_0D			;/
		JMP KNOCKOUT

	HIT_0D:
		; Do nothing
		RTS

	HIT_0E:
		; Collapse
		LDA $32C0,x
		BNE .Return
		LDA #$01 : STA $32C0,x
		LDA #$FF : STA $32D0,x
		LDA #$07 : STA !SPC1
		LDY !P2Direction
		JMP KNOCKBACK_GFX

		.Return
		RTS

=======
;=====================================;
;	S U B - R O U T I N E S       ;
;=====================================;

	StartSlide:
		LDA #$01 : STA !P2ShellSlide			;\
		STZ !P2Headbutt					; > clear headbutt
		LDA !P2Slope : BEQ .NoSlope			; |
		BRA .GetDir					; |
		.NoSlope					; |
		LDA !P2XSpeed					; | set slide
		.GetDir						; |
		ROL #2						; |
		AND #$01					; |
		EOR #$01					; |
		STA !P2Direction				;/
		.Return						;\ return
		RTS						;/


	ShellSpin:
		LDA !P2ShellSpin : BNE .Return			; can't start spin during another spin
		BIT $16 : BVC .Return				; triggered by pressing Y

		.Main
		LDA #$10 : STA !P2ShellSpin			; spin lasts for 16 frames
		LDA #$3E : STA !SPC4				; spin SFX
		LDA #$40					;\
		TRB $16						; | eat all Y inputs this frame
		TRB $15						; |
		TRB !P2Buffer					;/
		STZ !P2BackDash					;\ clear backdash and senku
		STZ !P2Senku					;/
		STZ !P2Punch					;\
		STZ !P2Headbutt					; | clear other attacks
		STZ !P2DropKick					;/
		STZ !P2JumpLag					; clear jump lag

		.Return						;\ return
		RTS						;/
>>>>>>> Stashed changes

	HIT_0F:
		; Do nothing
		RTS

<<<<<<< Updated upstream
	HIT_10:
		; Stun and damage
		JSR CORE_ATTACK_Main
		STZ $3420,x			; Reset unknown sprite table
		LDA $BE,x			;\
		CMP #$03			; |
		BEQ HIT_0F			;/> Return if sprite is still recovering from a stomp
		INC $32B0,x			; Increment sprite stomp count
		LDA $32B0,x
		CMP #$03
		BEQ .Kill
		LDA #$03 : STA $BE,x		; Stun sprite
		LDA #$03 : STA $32D0,x		; Set sprite stunned timer to 3 frames
		STZ $3310,x			; Reset follow player timer
		LDY !P2Direction
		JMP KNOCKBACK_GFX

		.Kill
		JMP KNOCKOUT


	HIT_11:
		; Do nothing
		RTS

	HIT_12:
		; Knock out if emerged
		LDA $BE,x			;\
		BEQ .Return			; | Only interact if sprite has emerged from the ground
		LDA $32D0,x			; |
		BEQ .Process			;/

		.Return
		RTS

		.Process
		JMP KNOCKOUT


	HIT_13:
		; Knock back and damage
		LDA $3200,x
		CMP #$6E
		BEQ .Large

		.Small
		JMP KNOCKOUT

		.Large
		LDA #$6F : STA $3200,x		; Sprite num
		LDA #$01 : STA $3230,x		; Init sprite
		JSL $07F7D2			; Reset sprite tables
		LDA #$02 : STA $BE,x		; Action: fire breath up
		JMP KNOCKBACK


	HIT_14:
		; Do nothing
		RTS

	HIT_15:
		; Knock back and damage
		LDY $BE,x
		LDA $3280,x
		AND #$04 : BNE .Aggro
		CPY #$01 : BNE +
		LDA #$20 : STA $32F0,x
		LDA #$02 : STA $BE,x
		JMP KNOCKOUT
	+	LDA #$04 : STA $34D0,x		; Half smush timer
		BRA .Shared

		.Return
		RTS

		.Aggro
		LDA $35D0,x : BNE .Return
		LDA #$40 : STA $35D0,x
		LDA $33E0,x
		BEQ .NoRoar
		LDA #$01 : STA $33E0,x

		.NoRoar
		CPY #$02
		BNE .Shared
		LDA #$20 : STA $32F0,x
		JMP KNOCKOUT

		.Shared
		INC $BE,x
		JSR CORE_ATTACK_Main
		LDA $3340,x			;\
		ORA #$0D			; | Set jump, getup, and knockback flags
		STA $3340,x			;/
		LDA $3330,x			;\
		AND.b #$04^$FF			; | Put sprite in midair
		STA $3330,x			;/
		LDA $3280,x			;\
		AND.b #$08^$FF			; | Clear movement disable
		STA $3280,x			;/
		BIT $3280,x			;\
		BVC .NoChase			; |
		BIT $3340,x			; |
		BVS .NoChase			; | Aggro off of being punched
		LDA !CurrentPlayer		; |
		CLC : ROL #4			; |
		ORA #$40			; |
		ORA $3340,x			; |
		STA $3340,x			;/

		.NoChase
		STZ $32A0,x			; > Disable hammer
		JMP KNOCKBACK



	HIT_16:
		; Do nothing
	HIT_17:
		; Do nothing
		RTS

	HIT_18:
		; Knock back without doing damage
		LDA !P2Direction
		EOR #$01
		STA $3320,x
		JMP KNOCKBACK


	HIT_19:
		; Do nothing
		RTS

	HIT_1A:
		; Collect
		LDA !CurrentPlayer : BNE +
		LDA $32E0,x : BNE HIT_19
		JMP CORE_INT_1A+$03
	+	LDA $35F0,x : BNE HIT_19
		JMP CORE_INT_1A+$03

	HIT_1B:
		LDA !BossData+0
		CMP #$81 : BNE .Return
		LDA !BossData+2
		AND #$7F
		CMP #$04 : BEQ .Return
		LDA $3420,x
		BNE .Return
		LDA !Difficulty
		AND #$03 : TAY
		LDA .InvincTime,y
		STA $3420,x
		LDA #$28 : STA !SPC4		; > OW! sound
		LDY !P2Direction
		LDA .XSpeed,y
		STA $AE,x
		LDA #$07 : STA !BossData+2
		LDA #$7F : STA !BossData+3
		DEC !BossData+1

		.Return
		RTS

		.InvincTime
		db $4F,$5F,$7F

		.XSpeed
		db $F0,$10

	HIT_1C:
		LDA !ExtraBits,x
		AND #$04 : BNE HIT_19		; can't hit mask
		LDA $3280,x
		AND #$03
		CMP #$01 : BNE HIT_19
		LDA $BE,x
		AND #$0F
		ORA #$C0
		STA $BE,x
		JMP CORE_ATTACK_Main

	HIT_1D:
		LDA #$3F : STA $3360,x		; > Set hurt timer
		LDA #$28 : STA !SPC4		; > OW! sound
		STZ $32D0,x			; > Reset main timer
		DEC $3280,x			; > Deal damage
		LDA CORE_BITS,x
		CPX #$08
		BCS +
		TSB !P2IndexMem1
		RTS
		+
		TSB !P2IndexMem2

		.Return
		RTS


	KNOCKOUT:
		LDA #$02 : STA $3230,x
		LDA #$D8 : STA $9E,x
		LDA #$02 : STA !SPC1
		LDY !P2Direction
		LDA !P2Character			;\
		CMP #$01				; | luigi borrows this routine
		BNE $02 : INY #2			;/
		LDA .XSpeed,y
		STA $AE,x

		TXY
		LDA CORE_BITS,y
		CPY #$08 : BCS +
		TSB !P2IndexMem1 : BRA ++
	+	TSB !P2IndexMem2
		++

		JSR CORE_DISPLAYCONTACT
		RTS

	.XSpeed
	db $F0,$10
	db $E0,$20


	KNOCKBACK:
		LDA #$E8 : STA $9E,x
		LDY !P2Direction
		LDA !P2Character			;\
		CMP #$01				; | luigi borrows this routine
		BNE $02 : INY #2			;/
		LDA KNOCKOUT_XSpeed,y
		STA $AE,x
		LDA !P2Kick : BEQ .GFX			;\
		TXY					; | spin has increased i-frames
		LDA #$20 : STA ($0E),y			;/
		LDA CORE_BITS,y
		CPY #$08 : BCS +
		TSB !P2IndexMem1 : BRA ++
	+	TSB !P2IndexMem2
		++

		.GFX
		LDA #$02 : STA !SPC1
		JSR CORE_DISPLAYCONTACT
		RTS
=======

	WaterPhysics:

		.GetIndex
		LDA $15						;\ swim speed index
		AND #$0F : TAX					;/
		CPX #$08 : BCC ..done				;\
		STZ !P2DropKick					; | underwater, drop kick can be cancelled with up
		..done						;/

		.YSpeed
		LDA !P2YSpeed					;\
		CMP DATA_AllRangeSpeedY,x			; |
		BEQ ..done					; |
		BPL ..up					; |
		..down						; |
		INC #2						; |
		CMP DATA_AllRangeSpeedY,x : BMI ..write		; |
		BRA ..set					; | Y acceleration
		..up						; |
		DEC #2						; |
		CMP DATA_AllRangeSpeedY,x : BPL ..write		; |
		..set						; |
		LDA DATA_AllRangeSpeedY,x			; |
		..write						; |
		STA !P2YSpeed					;/
		..done

		LDA !P2InAir : BNE .Swimming

		.Ground
		LDA !P2CanTurn : BEQ ..nodir			; see if can turn around
		LDA $15						;\
		AND #$03 : BEQ ..nodir				; |
		DEC A						; | direction when walking on ground
		EOR #$01 : STA !P2Direction			; |
		..nodir						;/
		LDA $15						;\
		AND #$88					; | up or B can leave the ground
		BEQ ..norise					; |
		BPL ..rise					;/
		..jump						;\
		LDA #$2B : STA !SPC1				; > jump SFX
		LDA #$C0 : STA !P2YSpeed			; |
		BRA .SwimXSpeed					; | upwards speed
		..rise						; |
		LDA #$F8 : STA !P2YSpeed			; |
		BRA .SwimXSpeed					; |
		..norise					;/

		.WalkXSpeed
		LDA !P2Punch					;\ speed index 0 while punching
		BEQ $02 : LDX #$00				;/
		LDA DATA_WaterSpeedX,x				;\
		LDY #$02					; | X accel when walking
		JSL CORE_ACCEL_X_8Bit				;/
		BRA .SwimAnimation_50percent			; animate underwater ground movement at 50%

		.Swimming
		LDA !P2DropKick : BNE .SwimXSpeed		; don't turn during dropkick
		LDA !P2XSpeed					;\
		CMP #$F0 : BCS .SwimXSpeed			; | don't turn if |X speed| < 0x10
		CMP #$10 : BCC .SwimXSpeed			;/
		ROL #2						;\
		AND #$01					; | otherwise just face X speed direction
		EOR #$01					; |
		STA !P2Direction				;/

		.SwimXSpeed
		LDA DATA_AllRangeSpeedX,x			;\
		LDY #$02					; | X accel when swimming
		JSL CORE_ACCEL_X_8Bit				;/
		STZ !P2Dashing					;\
		LDA !P2XSpeed					; |
		CMP #$E0 : BCS ..nodash				; |
		CMP #$20 : BCC ..nodash				; | set dash if |X speed| > 0x20
		..dash						; |
		LDA #$01 : STA !P2Dashing			; |
		..nodash					;/

		.SwimAnimation
		LDA !P2XSpeed					;\
		BPL $03 : EOR #$FF : INC A			; |
		STA $00						; |
		LDA !P2YSpeed					; | get |X|+|Y|
		BPL $03 : EOR #$FF : INC A			; |
		CLC : ADC $00					; |
		BNE ..animate					;/
		LDA !P2ShellSpin : BNE ..50percent		; always animate spin at 50% rate
		STZ !P2AnimTimer				;\ otherewise no animation
		BRA ..100percent				;/ (note that timer is locked here)
		..animate					;\ animate at 100% rate if |X|+|Y|>0x1F
		CMP #$20 : BCS ..100percent			;/
		..50percent					;\
		LDA $14						; | otherwise animate at 50% rate
		LSR A : BCC ..100percent			; |
		DEC !P2AnimTimer				;/
		..100percent					;
		STZ !P2SenkuUsed				; regain air special
		LDA $14						;\ only spawn every 128 frames
		AND #$7F : BNE .Return				;/

		PHB						;\
		JSL GetParticleIndex				; |
		LDA.w #!prt_bubble : STA !Particle_Type,x	; |
		LDA.l !P2YPosLo					; |
		SEC : SBC #$0008				; |
		STA !Particle_Y,x				; |
		PLB						; | spawn bubble
		LDA !P2Direction				; |
		AND #$00FF : TAY				; |
		LDA DATA_BubbleX,y				; |
		AND #$00FF					; |
		CLC : ADC !P2XPosLo				; |
		STA !41_Particle_X,x				; |
		SEP #$30					;/
>>>>>>> Stashed changes

		.Return
		RTS





;=====================;
;	D A T A       ;
;=====================;


	; Anim format:
	; dw $TTTT : db $tt,$NN
	; dw $DDDD
	; dw $CCCC
	; TTTT is tilemap pointer.
	; tt is frame count.
	; NN is next anim.
	; DDDD is dynamo pointer.
	; CCCC is clipping pointer.




	ANIM:
<<<<<<< Updated upstream
	.Idle0				; 00
	dw .IdleTM : db $06,!Kad_Idle+1
	dw .IdleDynamo0
	dw .ClippingStandard
	.Idle1				; 01
	dw .IdleTM : db $06,!Kad_Idle+2
	dw .IdleDynamo1
	dw .ClippingStandard
	.Idle2				; 02
	dw .IdleTM : db $06,!Kad_Idle+3
	dw .IdleDynamo0
	dw .ClippingStandard
	.Idle3				; 03
	dw .IdleTM : db $06,!Kad_Idle
	dw .IdleDynamo3
	dw .ClippingStandard

	.Walk0				; 04
	dw .IdleTM : db $06,!Kad_Walk+1
	dw .WalkDynamo0
	dw .ClippingStandard
	.Walk1				; 05
	dw .WalkTM : db $06,!Kad_Walk+2
	dw .WalkDynamo1
	dw .ClippingStandard
	.Walk2				; 06
	dw .IdleTM : db $06,!Kad_Walk+3
	dw .WalkDynamo2
	dw .ClippingStandard
	.Walk3				; 07
	dw .WalkTM : db $06,!Kad_Walk
	dw .WalkDynamo3
	dw .ClippingStandard

	.Spin0				; 08
	dw .SpinTM0 : db $02,!Kad_Spin+1
	dw .SpinDynamo0
	dw .ClippingShell
	.Spin1				; 09
	dw .SpinTM1 : db $02,!Kad_Spin+2
	dw .SpinDynamo1
	dw .ClippingShell
	.Spin2				; 0A
	dw .SpinTM2 : db $02,!Kad_Spin+3
	dw .SpinDynamo0
	dw .ClippingShell
	.Spin3				; 0B
	dw .SpinTM3 : db $02,!Kad_Spin
	dw .SpinDynamo1
	dw .ClippingShell

	.Squat				; 0C
	dw .SquatTM : db $04,!Kad_Fall
	dw .SquatDynamo
	dw .ClippingShell

	.Shell0				; 0D
	dw .ShellTM : db $06,!Kad_Shell+1
	dw .ShellDynamo0
	dw .ClippingShell
	.Shell1				; 0E
	dw .ShellTM : db $06,!Kad_Shell+2
	dw .ShellDynamo1
	dw .ClippingShell
	.Shell2				; 0F
	dw .ShellTM : db $06,!Kad_Shell+3
	dw .ShellDynamo2
	dw .ClippingShell
	.Shell3				; 10
	dw .ShellTMX : db $08,!Kad_Shell
	dw .ShellDynamo1
	dw .ClippingShell

	.Fall				; 11
	dw .IdleTM : db $FF,!Kad_Fall
	dw .FallDynamo
	dw .ClippingShell

	.Turn				; 12
	dw .DashTM0 : db $FF,!Kad_Turn
	dw .TurnDynamo
	dw .ClippingStandard

	.Senku				; 13
	dw .IdleTM : db $FF,!Kad_Senku
	dw .SenkuDynamo
	dw .ClippingStandard

	.1Punch0			; 14
	dw .IdleTM : db $02,!Kad_Punch1+1
	dw .PunchDynamo0
	dw .ClippingStandard
	.1Punch1			; 15
	dw .IdleTM : db $04,!Kad_Punch1+2
	dw .1PunchDynamo1
	dw .ClippingStandard
	.1Punch2			; 16
	dw .EndPunchTM : db $04,!Kad_Punch1+3
	dw .1PunchDynamo2
	dw .ClippingStandard
	.1Punch3			; 17
	dw .EndPunchTM : db $04,!Kad_Idle+1
	dw .1PunchDynamo3
	dw .ClippingStandard

	.2Punch0			; 18
	dw .IdleTM : db $02,!Kad_Punch2+1
	dw .PunchDynamo0
	dw .ClippingStandard
	.2Punch1			; 19
	dw .IdleTM : db $04,!Kad_Punch2+2
	dw .2PunchDynamo1
	dw .ClippingStandard
	.2Punch2			; 1A
	dw .EndPunchTM : db $04,!Kad_Punch2+3
	dw .2PunchDynamo2
	dw .ClippingStandard
	.2Punch3			; 1B
	dw .EndPunchTM : db $04,!Kad_Idle+1
	dw .2PunchDynamo3
	dw .ClippingStandard

	.Hurt				; 1C
	dw .IdleTM : db $FF,!Kad_Hurt
	dw .HurtDynamo
	dw .ClippingStandard

	.Dead				; 1D
	dw .IdleTM : db $FF,!Kad_Dead
	dw .DeadDynamo
	dw .ClippingStandard

	.Dash0				; 1E
	dw .DashTM0 : db $06,!Kad_Dash+1
	dw .DashDynamo0
	dw .ClippingStandard
	.Dash1				; 1F
	dw .DashTM1 : db $06,!Kad_Dash+2
	dw .DashDynamo1
	dw .ClippingStandard
	.Dash2				; 20
	dw .DashTM1 : db $06,!Kad_Dash+3
	dw .DashDynamo2
	dw .ClippingStandard
	.Dash3				; 21
	dw .DashTM0 : db $06,!Kad_Dash+4
	dw .DashDynamo0
	dw .ClippingStandard
	.Dash4				; 22
	dw .DashTM1 : db $06,!Kad_Dash+5
	dw .DashDynamo3
	dw .ClippingStandard
	.Dash5				; 23
	dw .DashTM1 : db $06,!Kad_Dash
	dw .DashDynamo4
	dw .ClippingStandard

	.Climb0				; 24
	dw .IdleTM : db $10,!Kad_Climb+1
	dw .ClimbDynamo
	dw .ClippingStandard
	.Climb1				; 25
	dw .ClimbTM : db $10,!Kad_Climb
	dw .ClimbDynamo
	dw .ClippingStandard

	.Duck0				; 26
	dw .SquatTM : db $06,!Kad_Duck+1
	dw .SquatDynamo
	dw .ClippingShell
	.Duck1				; 27
	dw .ShellTM : db $FF,!Kad_Duck+1
	dw .ShellDynamo1
	dw .ClippingShell

	.SenkuSmash0			; 28
	dw .SmashTM0 : db $04,!Kad_SenkuSmash+1
	dw .SenkuSmashDynamo0
	dw .ClippingStandard
	.SenkuSmash1			; 29
	dw .SmashTM0 : db $04,!Kad_SenkuSmash+2
	dw .SenkuSmashDynamo1
	dw .ClippingStandard
	.SenkuSmash2			; 2A
	dw .SmashTM0 : db $04,!Kad_SenkuSmash+3
	dw .SenkuSmashDynamo2
	dw .ClippingStandard
	.SenkuSmash3			; 2B
	dw .SmashTM0 : db $08,!Kad_SenkuSmash+4
	dw .SenkuSmashDynamo3
	dw .ClippingStandard
	.SenkuSmash4			; 2C
	dw .SmashTM1 : db $08,!Kad_Fall
	dw .SenkuSmashDynamo4
	dw .ClippingStandard

	.ShellDrill0			; 2D
	dw .SmashTM0 : db $04,!Kad_ShellDrill+1
	dw .ShellDrillDynamoInit
	dw .ClippingStandard
	.ShellDrill1			; 2E
	dw .ShellDrillTM00 : db $02,!Kad_ShellDrill+2
	dw .ShellDynamo0
	dw .ClippingShell
	.ShellDrill2			; 2F
	dw .ShellDrillTM01 : db $02,!Kad_ShellDrill+3
	dw .ShellDynamo1
	dw .ClippingShell
	.ShellDrill3			; 30
	dw .ShellDrillTM02 : db $02,!Kad_ShellDrill+4
	dw .ShellDynamo2
	dw .ClippingShell
	.ShellDrill4			; 31
	dw .ShellDrillTMX : db $02,!Kad_ShellDrill+1
	dw .ShellDynamo1
	dw .ClippingShell

	.DrillLand0			; 32
	dw .FlipSpinTM0 : db $02,!Kad_DrillLand+1
	dw .SpinDynamo0
	dw .ClippingShell
	.DrillLand1			; 33
	dw .FlipSpinTM1 : db $02,!Kad_DrillLand+2
	dw .SpinDynamo1
	dw .ClippingShell
	.DrillLand2			; 34
	dw .FlipSpinTM2 : db $02,!Kad_DrillLand+3
	dw .SpinDynamo0
	dw .ClippingShell
	.DrillLand3			; 35
	dw .FlipSpinTM3 : db $02,!Kad_DrillLand
	dw .SpinDynamo1
	dw .ClippingShell
=======
	; idle
		.Idle0
		dw .IdleTM : db $06,!Kad_Idle+1
		dw .IdleDynamo0
		dw .ClippingStandard
		.Idle1
		dw .IdleTM : db $06,!Kad_Idle+2
		dw .IdleDynamo1
		dw .ClippingStandard
		.Idle2
		dw .IdleTM : db $06,!Kad_Idle+3
		dw .IdleDynamo2
		dw .ClippingStandard
		.Idle3
		dw .IdleTM : db $06,!Kad_Idle
		dw .IdleDynamo3
		dw .ClippingStandard

	; walk
		.Walk0
		dw .IdleTM : db $06,!Kad_Walk+1
		dw .WalkDynamo0
		dw .ClippingStandard
		.Walk1
		dw .IdleTM : db $06,!Kad_Walk+2
		dw .WalkDynamo1
		dw .ClippingStandard
		.Walk2
		dw .WalkTM : db $06,!Kad_Walk+3
		dw .WalkDynamo2
		dw .ClippingStandard
		.Walk3
		dw .IdleTM : db $06,!Kad_Walk
		dw .WalkDynamo3
		dw .ClippingStandard

	; dash
		.Dash0
		dw .DashTM : db $06,!Kad_Dash+1
		dw .DashDynamo0
		dw .ClippingDash
		.Dash1
		dw .DashTMU3 : db $06,!Kad_Dash+2
		dw .DashDynamo1
		dw .ClippingDash
		.Dash2
		dw .DashTMU2 : db $06,!Kad_Dash+3
		dw .DashDynamo2
		dw .ClippingDash
		.Dash3
		dw .DashTM : db $06,!Kad_Dash+4
		dw .DashDynamo0
		dw .ClippingDash
		.Dash4
		dw .DashTMU3 : db $06,!Kad_Dash+5
		dw .DashDynamo3
		dw .ClippingDash
		.Dash5
		dw .DashTMU2 : db $06,!Kad_Dash
		dw .DashDynamo4
		dw .ClippingDash

	; spin
		.Spin0
		dw .SpinTM0 : db $02,!Kad_Spin+1
		dw .SpinDynamo0
		dw .ClippingShell
		.Spin1
		dw .SpinTM1 : db $02,!Kad_Spin+2
		dw .SpinDynamo1
		dw .ClippingShell
		.Spin2
		dw .SpinTM2 : db $02,!Kad_Spin+3
		dw .SpinDynamo1
		dw .ClippingShell
		.Spin3
		dw .SpinTM3 : db $02,!Kad_Spin
		dw .SpinDynamo0
		dw .ClippingShell

	; squat
		.Squat
		dw .SquatTM : db $04,!Kad_Idle
		dw .SquatDynamo
		dw .ClippingStandard

	; fall has to be before shell
	; fall
		.Fall0
		dw .SquatTM : db $04,!Kad_Fall+1
		dw .HeadbuttDynamo0
		dw .ClippingShell
		.Fall1
		dw .IdleTM : db $04,!Kad_Fall+2
		dw .FallDynamo0
		dw .ClippingShell
		.Fall2
		dw .IdleTM : db $04,!Kad_Fall+1
		dw .FallDynamo1
		dw .ClippingShell

	; shell
		.Shell0
		dw .ShellTM : db $06,!Kad_Shell+1
		dw .ShellDynamo0
		dw .ClippingShell
		.Shell1
		dw .ShellTM : db $06,!Kad_Shell+2
		dw .ShellDynamo1
		dw .ClippingShell
		.Shell2
		dw .ShellTM : db $06,!Kad_Shell+3
		dw .ShellDynamo2
		dw .ClippingShell
		.Shell3
		dw .ShellTMX : db $08,!Kad_Shell
		dw .ShellDynamo1
		dw .ClippingShell

	; turn
		.Turn
		dw .TurnTM : db $FF,!Kad_Turn
		dw .TurnDynamo
		dw .ClippingStandard

	; senku
		.Senku
		dw .IdleTM : db $FF,!Kad_Senku
		dw .SenkuDynamo
		dw .ClippingStandard

	; punch
		.Punch0
		dw .IdleTM : db $02,!Kad_Punch+1
		dw .PunchDynamo0
		dw .ClippingStandard
		.Punch1
		dw .PunchTM : db $04,!Kad_Punch+2
		dw .PunchDynamo1
		dw .ClippingStandard
		.Punch2
		dw .PunchTM : db $04,!Kad_Punch+3
		dw .PunchDynamo2
		dw .ClippingStandard
		.Punch3
		dw .IdleTM : db $04,!Kad_Idle+1
		dw .PunchDynamo3
		dw .ClippingStandard

	; hurt
		.Hurt
		dw .IdleTM : db $FF,!Kad_Hurt
		dw .HurtDynamo
		dw .ClippingStandard

	; dead
		.Dead
		dw .IdleTM : db $FF,!Kad_Dead
		dw .DeadDynamo
		dw .ClippingStandard

	; climb
		.Climb0
		dw .IdleTM : db $10,!Kad_Climb+1
		dw .ClimbDynamo
		dw .ClippingStandard
		.Climb1
		dw .ClimbTM : db $10,!Kad_Climb
		dw .ClimbDynamo
		dw .ClippingStandard

	; duck
		.Duck0
		dw .SquatTM : db $06,!Kad_Duck+1
		dw .SquatDynamo
		dw .ClippingShell
		.Duck1
		dw .ShellTM : db $FF,!Kad_Duck+1
		dw .ShellDynamo1
		dw .ClippingShell

	; swim
		.Swim0
		dw .ShellTMX : db $06,!Kad_Swim+1
		dw .SwimDynamo0
		dw .ClippingShell
		.Swim1
		dw .ShellTMX : db $06,!Kad_Swim+2
		dw .SwimDynamo1
		dw .ClippingShell
		.Swim2
		dw .ShellTMX : db $06,!Kad_Swim+3
		dw .SwimDynamo2
		dw .ClippingShell
		.Swim3
		dw .ShellTMX : db $08,!Kad_Swim
		dw .SwimDynamo3
		dw .ClippingShell

	; drop kick
		.DropKick0
		dw .IdleTM : db $02,!Kad_DropKick+1
		dw .DropKickDynamo0
		dw .ClippingStandard
		.DropKick1
		dw .IdleTM : db $02,!Kad_DropKick+2
		dw .DropKickDynamo1
		dw .ClippingStandard
		.DropKick2
		dw .IdleTM : db $08,!Kad_DropKick+3
		dw .DropKickDynamo2
		dw .ClippingStandard
		.DropKick3
		dw .IdleTM : db $02,!Kad_DropKick+4
		dw .DropKickDynamo3
		dw .ClippingStandard
		.DropKick4
		dw .IdleTM : db $02,!Kad_DropKick+3
		dw .DropKickDynamo4
		dw .ClippingStandard

	; drop kick bounce
		.DropKickBounce0
		dw .24x32TM : db $08,!Kad_DropKickBounce+1
		dw .DropKickBounceDynamo0
		dw .ClippingStandard
		.DropKickBounce1
		dw .24x32TM : db $FF,!Kad_DropKickBounce+1
		dw .DropKickBounceDynamo1
		dw .ClippingStandard


	; headbutt
		.Headbutt0
		dw .SquatTM : db $04,!Kad_Headbutt+1
		dw .HeadbuttDynamo0
		dw .ClippingStandard
		.Headbutt1
		dw .HeadbuttTM : db $0C,!Kad_Headbutt+2
		dw .HeadbuttDynamo1
		dw .ClippingStandard
		.Headbutt2
		dw .SquatTM : db $04,!Kad_Headbutt+3
		dw .HeadbuttDynamo0
		dw .ClippingStandard
		.Headbutt3
		dw .TurnTM : db $10,!Kad_Turn
		dw .TurnDynamo
		dw .ClippingStandard

	; carry
		.Carry0
		dw .IdleTM : db $04,!Kad_Carry+1
		dw .CarryDynamo0
		dw .ClippingStandard
		.Carry1
		dw .CarryWalkTM0 : db $04,!Kad_Carry+2
		dw .CarryDynamo1
		dw .ClippingStandard
		.Carry2
		dw .CarryWalkTM1 : db $08,!Kad_Carry+0
		dw .CarryDynamo2
		dw .ClippingStandard

	; throw
		.Throw
		dw .CarryWalkTM1 : db $10,!Kad_Idle
		dw .ThrowDynamo
		dw .ClippingStandard

	; victory
		.Victory
		dw .IdleTM : db $FF,!Kad_Victory
		dw .VictoryDynamo
		dw .ClippingStandard

>>>>>>> Stashed changes


	.IdleTM
	dw $0008
	db $2E,$00,$F0,!P2Tile1
	db $2E,$00,$00,!P2Tile2

	.WalkTM
	dw $0008
	db $2E,$00,$EF,!P2Tile1
	db $2E,$00,$FF,!P2Tile2

	.DashTM0
	dw $0010
	db $2E,$F8,$F8,!P2Tile1
	db $2E,$08,$F8,!P2Tile2
	db $2E,$F8,$00,!P2Tile3
	db $2E,$08,$00,!P2Tile4
	.DashTM1
	dw $0010
	db $2E,$FC,$F8,!P2Tile1
	db $2E,$04,$F8,!P2Tile1+1
	db $2E,$FC,$00,!P2Tile3
	db $2E,$04,$00,!P2Tile3+1

	.24x32TM
	dw $0010
	db $20,$F8,$F0,!P1Tile1
	db $20,$00,$F0,!P1Tile1+1
	db $20,$F8,$00,!P1Tile3
	db $20,$00,$00,!P1Tile3+1

	.SquatTM
	dw $0008
	db $2E,$00,$F8,!P2Tile1
	db $2E,$00,$00,!P2Tile2

	.ShellTM
	dw $0004
	db $2E,$00,$00,!P2Tile1
	.ShellTMX
	dw $0004
	db $6E,$00,$00,!P2Tile1

	.PunchTM
	dw $0010
	db $2E,$F8,$F0,!P2Tile1
	db $2E,$00,$F0,!P2Tile2
	db $2E,$F8,$00,!P2Tile3
	db $2E,$00,$00,!P2Tile4
	.EndPunchTM
	dw $0010
	db $2E,$F8,$F0,!P2Tile1
	db $2E,$00,$F0,!P2Tile1+1
	db $2E,$F8,$00,!P2Tile3
	db $2E,$00,$00,!P2Tile3+1

	.SpinTM0
	dw $0008
	db $2E,$FC,$FC,!P2Tile1
	db $2E,$04,$FC,!P2Tile1+1
	.SpinTM1
	dw $0010
	db $2E,$08,$05,!P2Tile4
	db $2E,$FC,$FC,!P2Tile1
	db $2E,$04,$FC,!P2Tile1+1
	db $6E,$08,$FF,!P2Tile4
	.SpinTM2
	dw $0008
	db $6E,$FC,$FC,!P2Tile1
	db $6E,$04,$FC,!P2Tile1+1
	.SpinTM3
	dw $0010
	db $6E,$08,$05,!P2Tile4
	db $6E,$FC,$FC,!P2Tile1
	db $6E,$04,$FC,!P2Tile1+1
	db $2E,$08,$FF,!P2Tile4

	.FlipSpinTM0
	dw $0008
	db $AE,$FC,$FC,!P2Tile1
	db $AE,$04,$FC,!P2Tile1+1
	.FlipSpinTM1
	dw $0010
	db $AE,$08,$05,!P2Tile4
	db $AE,$FC,$FC,!P2Tile1
	db $AE,$04,$FC,!P2Tile1+1
	db $EE,$08,$FF,!P2Tile4
	.FlipSpinTM2
	dw $0008
	db $EE,$FC,$FC,!P2Tile1
	db $EE,$04,$FC,!P2Tile1+1
	.FlipSpinTM3
	dw $0010
	db $EE,$08,$05,!P2Tile4
	db $EE,$FC,$FC,!P2Tile1
	db $EE,$04,$FC,!P2Tile1+1
	db $AE,$08,$FF,!P2Tile4


	.ShellDrillTM00
	dw $000C
	db $EE,$08,$01,!P2Tile7
	db $AE,$08,$FD,!P2Tile7
	db $AE,$00,$00,!P2Tile1
	.ShellDrillTM01
	dw $0004
	db $AE,$00,$00,!P2Tile1
	.ShellDrillTM02
	dw $000C
	db $AE,$08,$01,!P2Tile7
	db $EE,$08,$FD,!P2Tile7
	db $AE,$00,$00,!P2Tile1
	.ShellDrillTMX
	dw $0004
	db $EE,$00,$00,!P2Tile1


	.ClimbTM
	dw $0008
	db $6E,$00,$F0,!P2Tile1
	db $6E,$00,$00,!P2Tile2

	.SmashTM0
	dw $0010
	db $6E,$FC,$F8,!P2Tile1
	db $6E,$04,$F8,!P2Tile1+1
	db $6E,$FC,$00,!P2Tile3
	db $6E,$04,$00,!P2Tile3+1
	.SmashTM1
	dw $0008
	db $6E,$00,$F0,!P2Tile1
	db $6E,$00,$00,!P2Tile2


;macro KadDyn(TileCount, TileNumber, Dest)
;	dw <TileCount>*$20
;	dl <TileNumber>*$20+$328008
;	dw <Dest>*$10+$6000
;endmacro

<<<<<<< Updated upstream
macro KadDyn(TileCount, TileNumber, Dest)
	db (<TileCount>*2)|((<TileNumber>&$07)<<5)
	db <TileNumber>>>3
	db <Dest>*8
endmacro




	.IdleDynamo0				; Used by 0, 2
	db ..End-..Start
	..Start
	%KadDyn(2, $000, !P2Tile1)
	%KadDyn(2, $010, !P2Tile1+$10)
	%KadDyn(2, $020, !P2Tile2)
	%KadDyn(2, $030, !P2Tile2+$10)
	..End
	.IdleDynamo1				; Used by 1
	db ..End-..Start
	..Start
	%KadDyn(2, $002, !P2Tile1)
	%KadDyn(2, $012, !P2Tile1+$10)
	%KadDyn(2, $022, !P2Tile2)
	%KadDyn(2, $032, !P2Tile2+$10)
	..End
	.IdleDynamo3				; Used by 3
	db ..End-..Start
	..Start
	%KadDyn(2, $004, !P2Tile1)
	%KadDyn(2, $014, !P2Tile1+$10)
	%KadDyn(2, $024, !P2Tile2)
	%KadDyn(2, $034, !P2Tile2+$10)
	..End

	.WalkDynamo0
	db ..End-..Start
	..Start
	%KadDyn(2, $000, !P2Tile1)
	%KadDyn(2, $010, !P2Tile1+$10)
	%KadDyn(2, $020, !P2Tile2)
	%KadDyn(2, $030, !P2Tile2+$10)
	..End
	.WalkDynamo1
	db ..End-..Start
	..Start
	%KadDyn(2, $006, !P2Tile1)
	%KadDyn(2, $016, !P2Tile1+$10)
	%KadDyn(2, $026, !P2Tile2)
	%KadDyn(2, $036, !P2Tile2+$10)
	..End
	.WalkDynamo2
	db ..End-..Start
	..Start
	%KadDyn(2, $008, !P2Tile1)
	%KadDyn(2, $018, !P2Tile1+$10)
	%KadDyn(2, $028, !P2Tile2)
	%KadDyn(2, $038, !P2Tile2+$10)
	..End
	.WalkDynamo3
	db ..End-..Start
	..Start
	%KadDyn(2, $00A, !P2Tile1)
	%KadDyn(2, $01A, !P2Tile1+$10)
	%KadDyn(2, $02A, !P2Tile2)
	%KadDyn(2, $03A, !P2Tile2+$10)
	..End

	.DashDynamo0				; Used by frames 0, 3
	db ..End-..Start
	..Start
	%KadDyn(4, $07C, !P2Tile1)
	%KadDyn(4, $08C, !P2Tile1+$10)
	%KadDyn(4, $08C, !P2Tile3)
	%KadDyn(4, $09C, !P2Tile3+$10)
	..End
	.DashDynamo1				; Used by frame 1
	db ..End-..Start
	..Start
	%KadDyn(3, $0A0, !P2Tile1)
	%KadDyn(3, $0B0, !P2Tile1+$10)
	%KadDyn(3, $0B0, !P2Tile3)
	%KadDyn(3, $0C0, !P2Tile3+$10)
	..End
	.DashDynamo2				; Used by frame 2
	db ..End-..Start
	..Start
	%KadDyn(3, $0A3, !P2Tile1)
	%KadDyn(3, $0B3, !P2Tile1+$10)
	%KadDyn(3, $0B3, !P2Tile3)
	%KadDyn(3, $0C3, !P2Tile3+$10)
	..End
	.DashDynamo3				; Used by frame 4
	db ..End-..Start
	..Start
	%KadDyn(3, $0A6, !P2Tile1)
	%KadDyn(3, $0B6, !P2Tile1+$10)
	%KadDyn(3, $0B6, !P2Tile3)
	%KadDyn(3, $0C6, !P2Tile3+$10)
	..End
	.DashDynamo4				; Used by frame 5
	db ..End-..Start
	..Start
	%KadDyn(3, $0A9, !P2Tile1)
	%KadDyn(3, $0B9, !P2Tile1+$10)
	%KadDyn(3, $0B9, !P2Tile3)
	%KadDyn(3, $0C9, !P2Tile3+$10)
	..End

	.SquatDynamo				; Also used by .Duck0
	db ..End-..Start
	..Start
	%KadDyn(2, $060, !P2Tile1)
	%KadDyn(2, $070, !P2Tile1+$10)
	%KadDyn(2, $070, !P2Tile2)
	%KadDyn(2, $080, !P2Tile2+$10)
	..End

	.ShellDynamo0				; Also used by .Duck1
	db ..End-..Start
	..Start
	%KadDyn(2, $040, !P2Tile1)
	%KadDyn(2, $050, !P2Tile1+$10)
	..End
	.ShellDynamo1
	db ..End-..Start
	..Start
	%KadDyn(2, $042, !P2Tile1)
	%KadDyn(2, $052, !P2Tile1+$10)
	..End
	.ShellDynamo2
	db ..End-..Start
	..Start
	%KadDyn(2, $044, !P2Tile1)
	%KadDyn(2, $054, !P2Tile1+$10)
	..End

	.FallDynamo
	db ..End-..Start
	..Start
	%KadDyn(2, $064, !P2Tile1)
	%KadDyn(2, $074, !P2Tile1+$10)
	%KadDyn(2, $084, !P2Tile2)
	%KadDyn(2, $094, !P2Tile2+$10)
	..End

	.TurnDynamo
	db ..End-..Start
	..Start
	%KadDyn(4, $04C, !P2Tile1)
	%KadDyn(4, $05C, !P2Tile1+$10)
	%KadDyn(4, $05C, !P2Tile3)
	%KadDyn(4, $06C, !P2Tile3+$10)
	..End

	.SenkuDynamo
	db ..End-..Start
	..Start
	%KadDyn(2, $062, !P2Tile1)
	%KadDyn(2, $072, !P2Tile1+$10)
	%KadDyn(2, $082, !P2Tile2)
	%KadDyn(2, $092, !P2Tile2+$10)
	..End

	.PunchDynamo0				; Used by both punches
	db ..End-..Start
	..Start
	%KadDyn(2, $00C, !P2Tile1)
	%KadDyn(2, $01C, !P2Tile1+$10)
	%KadDyn(2, $02C, !P2Tile2)
	%KadDyn(2, $03C, !P2Tile2+$10)
	..End

	.1PunchDynamo1
	db ..End-..Start
	..Start
	%KadDyn(2, $00E, !P2Tile1)
	%KadDyn(2, $01E, !P2Tile1+$10)
	%KadDyn(2, $02E, !P2Tile2)
	%KadDyn(2, $03E, !P2Tile2+$10)
	..End
	.1PunchDynamo2
	db ..End-..Start
	..Start
	%KadDyn(3, $066, !P2Tile1)
	%KadDyn(3, $076, !P2Tile1+$10)
	%KadDyn(3, $086, !P2Tile3)
	%KadDyn(3, $096, !P2Tile3+$10)
	..End
	.1PunchDynamo3
	db ..End-..Start
	..Start
	%KadDyn(3, $069, !P2Tile1)
	%KadDyn(3, $079, !P2Tile1+$10)
	%KadDyn(3, $089, !P2Tile3)
	%KadDyn(3, $099, !P2Tile3+$10)
	..End

	.2PunchDynamo1
	db ..End-..Start
	..Start
	%KadDyn(2, $0D0, !P2Tile1)
	%KadDyn(2, $0E0, !P2Tile1+$10)
	%KadDyn(2, $0F0, !P2Tile2)
	%KadDyn(2, $100, !P2Tile2+$10)
	..End
	.2PunchDynamo2
	db ..End-..Start
	..Start
	%KadDyn(3, $0D2, !P2Tile1)
	%KadDyn(3, $0E2, !P2Tile1+$10)
	%KadDyn(3, $0F2, !P2Tile3)
	%KadDyn(3, $102, !P2Tile3+$10)
	..End
	.2PunchDynamo3
	db ..End-..Start
	..Start
	%KadDyn(3, $0D5, !P2Tile1)
	%KadDyn(3, $0E5, !P2Tile1+$10)
	%KadDyn(3, $0F5, !P2Tile3)
	%KadDyn(3, $105, !P2Tile3+$10)
	..End

	.HurtDynamo
	db ..End-..Start
	..Start
	%KadDyn(2, $0AC, !P2Tile1)
	%KadDyn(2, $0BC, !P2Tile1+$10)
	%KadDyn(2, $0CC, !P2Tile2)
	%KadDyn(2, $0DC, !P2Tile2+$10)
	..End

	.DeadDynamo
	db ..End-..Start
	..Start
	%KadDyn(2, $0AE, !P2Tile1)
	%KadDyn(2, $0BE, !P2Tile1+$10)
	%KadDyn(2, $0CE, !P2Tile2)
	%KadDyn(2, $0DE, !P2Tile2+$10)
	..End

	.SpinDynamo0
	db ..End-..Start
	..Start
	%KadDyn(3, $046, !P2Tile1)
	%KadDyn(3, $056, !P2Tile1+$10)
	..End
	.SpinDynamo1
	db ..End-..Start
	..Start
	%KadDyn(3, $049, !P2Tile1)
	%KadDyn(3, $059, !P2Tile1+$10)
	%KadDyn(2, $0DA, !P2Tile4)
	%KadDyn(2, $0EA, !P2Tile4+$10)
	..End

	.ClimbDynamo				; Used by both frames
	db ..End-..Start
	..Start
	%KadDyn(2, $0D8, !P2Tile1)
	%KadDyn(2, $0E8, !P2Tile1+$10)
	%KadDyn(2, $0F8, !P2Tile2)
	%KadDyn(2, $108, !P2Tile2+$10)
	..End

	.SenkuSmashDynamo0
	db ..End-..Start
	..Start
	%KadDyn(3, $110, !P2Tile1)
	%KadDyn(3, $120, !P2Tile1+$10)
	%KadDyn(3, $120, !P2Tile3)
	%KadDyn(3, $130, !P2Tile3+$10)
	..End
	.SenkuSmashDynamo1
	db ..End-..Start
	..Start
	%KadDyn(3, $113, !P2Tile1)
	%KadDyn(3, $123, !P2Tile1+$10)
	%KadDyn(3, $123, !P2Tile3)
	%KadDyn(3, $133, !P2Tile3+$10)
	..End
	.SenkuSmashDynamo2
	db ..End-..Start
	..Start
	%KadDyn(3, $116, !P2Tile1)
	%KadDyn(3, $126, !P2Tile1+$10)
	%KadDyn(3, $126, !P2Tile3)
	%KadDyn(3, $136, !P2Tile3+$10)
	..End
	.SenkuSmashDynamo3
	db ..End-..Start
	..Start
	%KadDyn(3, $119, !P2Tile1)
	%KadDyn(3, $129, !P2Tile1+$10)
	%KadDyn(3, $129, !P2Tile3)
	%KadDyn(3, $139, !P2Tile3+$10)
	..End
	.SenkuSmashDynamo4
	db ..End-..Start
	..Start
	%KadDyn(2, $11C, !P2Tile1)
	%KadDyn(2, $12C, !P2Tile1+$10)
	%KadDyn(2, $13C, !P2Tile2)
	%KadDyn(2, $14C, !P2Tile2+$10)
	..End

	.ShellDrillDynamoInit
	db ..End-..Start
	..Start
	%KadDyn(3, $119, !P2Tile1)
	%KadDyn(3, $129, !P2Tile1+$10)
	%KadDyn(3, $129, !P2Tile3)
	%KadDyn(3, $139, !P2Tile3+$10)
	%KadDyn(2, $0DA, !P2Tile7)
	%KadDyn(2, $0EA, !P2Tile7+$10)
	..End
=======
	; idle
		.IdleDynamo0
		db ..end-..start
		..start
		%Dyn24Bit(2, $000, !P1Tile1)
		%Dyn24Bit(2, $010, !P1Tile1+$10)
		%Dyn24Bit(2, $020, !P1Tile2)
		%Dyn24Bit(2, $030, !P1Tile2+$10)
		..end
		.IdleDynamo1
		db ..end-..start
		..start
		%Dyn24Bit(2, $002, !P1Tile1)
		%Dyn24Bit(2, $012, !P1Tile1+$10)
		%Dyn24Bit(2, $022, !P1Tile2)
		%Dyn24Bit(2, $032, !P1Tile2+$10)
		..end
		.IdleDynamo2
		db ..end-..start
		..start
		%Dyn24Bit(2, $004, !P1Tile1)
		%Dyn24Bit(2, $014, !P1Tile1+$10)
		%Dyn24Bit(2, $024, !P1Tile2)
		%Dyn24Bit(2, $034, !P1Tile2+$10)
		..end
		.IdleDynamo3
		db ..end-..start
		..start
		%Dyn24Bit(2, $006, !P1Tile1)
		%Dyn24Bit(2, $016, !P1Tile1+$10)
		%Dyn24Bit(2, $026, !P1Tile2)
		%Dyn24Bit(2, $036, !P1Tile2+$10)
		..end

	; walk
		.WalkDynamo0
		db ..end-..start
		..start
		%Dyn24Bit(2, $008, !P1Tile1)
		%Dyn24Bit(2, $018, !P1Tile1+$10)
		%Dyn24Bit(2, $028, !P1Tile2)
		%Dyn24Bit(2, $038, !P1Tile2+$10)
		..end
		.WalkDynamo1
		db ..end-..start
		..start
		%Dyn24Bit(2, $00A, !P1Tile1)
		%Dyn24Bit(2, $01A, !P1Tile1+$10)
		%Dyn24Bit(2, $02A, !P1Tile2)
		%Dyn24Bit(2, $03A, !P1Tile2+$10)
		..end
		.WalkDynamo2
		db ..end-..start
		..start
		%Dyn24Bit(2, $00C, !P1Tile1)
		%Dyn24Bit(2, $01C, !P1Tile1+$10)
		%Dyn24Bit(2, $02C, !P1Tile2)
		%Dyn24Bit(2, $03C, !P1Tile2+$10)
		..end
		.WalkDynamo3
		db ..end-..start
		..start
		%Dyn24Bit(2, $00E, !P1Tile1)
		%Dyn24Bit(2, $01E, !P1Tile1+$10)
		%Dyn24Bit(2, $02E, !P1Tile2)
		%Dyn24Bit(2, $03E, !P1Tile2+$10)
		..end

	; dash
		.DashDynamo0				; Used by frames 0, 3
		db ..end-..start
		..start
		%Dyn24Bit(3, $083, !P1Tile1)
		%Dyn24Bit(3, $093, !P1Tile1+$10)
		%Dyn24Bit(3, $093, !P1Tile3)
		%Dyn24Bit(3, $0A3, !P1Tile3+$10)
		..end
		.DashDynamo1				; Used by frame 1
		db ..end-..start
		..start
		%Dyn24Bit(3, $086, !P1Tile1)
		%Dyn24Bit(3, $096, !P1Tile1+$10)
		%Dyn24Bit(3, $096, !P1Tile3)
		%Dyn24Bit(3, $0A6, !P1Tile3+$10)
		..end
		.DashDynamo2				; Used by frame 2
		db ..end-..start
		..start
		%Dyn24Bit(3, $089, !P1Tile1)
		%Dyn24Bit(3, $099, !P1Tile1+$10)
		%Dyn24Bit(3, $099, !P1Tile3)
		%Dyn24Bit(3, $0A9, !P1Tile3+$10)
		..end
		.DashDynamo3				; Used by frame 4
		db ..end-..start
		..start
		%Dyn24Bit(3, $0B0, !P1Tile1)
		%Dyn24Bit(3, $0C0, !P1Tile1+$10)
		%Dyn24Bit(3, $0C0, !P1Tile3)
		%Dyn24Bit(3, $0D0, !P1Tile3+$10)
		..end
		.DashDynamo4				; Used by frame 5
		db ..end-..start
		..start
		%Dyn24Bit(3, $0B3, !P1Tile1)
		%Dyn24Bit(3, $0C3, !P1Tile1+$10)
		%Dyn24Bit(3, $0C3, !P1Tile3)
		%Dyn24Bit(3, $0D3, !P1Tile3+$10)
		..end

	; squat
		.SquatDynamo				; Also used by .Duck0
		db ..end-..start
		..start
		%Dyn24Bit(2, $08E, !P1Tile1)
		%Dyn24Bit(2, $09E, !P1Tile1+$10)
		%Dyn24Bit(2, $09E, !P1Tile2)
		%Dyn24Bit(2, $0AE, !P1Tile2+$10)
		..end


	; shell
		.ShellDynamo0				; Also used by .Duck1
		db ..end-..start
		..start
		%Dyn24Bit(2, $0BA, !P1Tile1)
		%Dyn24Bit(2, $0CA, !P1Tile1+$10)
		..end
		.ShellDynamo1
		db ..end-..start
		..start
		%Dyn24Bit(2, $0BC, !P1Tile1)
		%Dyn24Bit(2, $0CC, !P1Tile1+$10)
		..end
		.ShellDynamo2
		db ..end-..start
		..start
		%Dyn24Bit(2, $0BE, !P1Tile1)
		%Dyn24Bit(2, $0CE, !P1Tile1+$10)
		..end

	; fall
		.FallDynamo0
		db ..end-..start
		..start
		%Dyn24Bit(2, $04A, !P1Tile1)
		%Dyn24Bit(2, $05A, !P1Tile1+$10)
		%Dyn24Bit(2, $06A, !P1Tile2)
		%Dyn24Bit(2, $07A, !P1Tile2+$10)
		..end
		.FallDynamo1
		db ..end-..start
		..start
		%Dyn24Bit(2, $04C, !P1Tile1)
		%Dyn24Bit(2, $05C, !P1Tile1+$10)
		%Dyn24Bit(2, $06C, !P1Tile2)
		%Dyn24Bit(2, $07C, !P1Tile2+$10)
		..end

	; turn
		.TurnDynamo
		db ..end-..start
		..start
		%Dyn24Bit(4, $080, !P1Tile1)
		%Dyn24Bit(4, $090, !P1Tile1+$10)
		%Dyn24Bit(4, $090, !P1Tile3)
		%Dyn24Bit(4, $0A0, !P1Tile3+$10)
		..end

	; senku
		.SenkuDynamo
		db ..end-..start
		..start
		%Dyn24Bit(2, $048, !P1Tile1)
		%Dyn24Bit(2, $058, !P1Tile1+$10)
		%Dyn24Bit(2, $068, !P1Tile2)
		%Dyn24Bit(2, $078, !P1Tile2+$10)
		..end

	; punch
		.PunchDynamo0
		.PunchDynamo3
		db ..end-..start
		..start
		%Dyn24Bit(2, $046, !P1Tile1)
		%Dyn24Bit(2, $056, !P1Tile1+$10)
		%Dyn24Bit(2, $066, !P1Tile2)
		%Dyn24Bit(2, $076, !P1Tile2+$10)
		..end
		.PunchDynamo1
		db ..end-..start
		..start
		%Dyn24Bit(3, $040, !P1Tile1)
		%Dyn24Bit(3, $050, !P1Tile1+$10)
		%Dyn24Bit(3, $060, !P1Tile3)
		%Dyn24Bit(3, $070, !P1Tile3+$10)
		..end
		.PunchDynamo2
		db ..end-..start
		..start
		%Dyn24Bit(3, $043, !P1Tile1)
		%Dyn24Bit(3, $053, !P1Tile1+$10)
		%Dyn24Bit(3, $063, !P1Tile3)
		%Dyn24Bit(3, $073, !P1Tile3+$10)
		..end

	; hurt
		.HurtDynamo
		db ..end-..start
		..start
		%Dyn24Bit(2, $04E, !P1Tile1)
		%Dyn24Bit(2, $05E, !P1Tile1+$10)
		%Dyn24Bit(2, $06E, !P1Tile2)
		%Dyn24Bit(2, $07E, !P1Tile2+$10)
		..end

	; dead
		.DeadDynamo
		db ..end-..start
		..start
		%Dyn24Bit(2, $11A, !P1Tile1)
		%Dyn24Bit(2, $12A, !P1Tile1+$10)
		%Dyn24Bit(2, $13A, !P1Tile2)
		%Dyn24Bit(2, $14A, !P1Tile2+$10)
		..end

	; spin
		.SpinDynamo0
		db ..end-..start
		..start
		%Dyn24Bit(3, $120, !P1Tile1)
		%Dyn24Bit(3, $130, !P1Tile1+$10)
		..end
		.SpinDynamo1
		db ..end-..start
		..start
		%Dyn24Bit(3, $123, !P1Tile1)
		%Dyn24Bit(3, $133, !P1Tile1+$10)
		..end

	; climb
		.ClimbDynamo				; Used by both frames
		db ..end-..start
		..start
		%Dyn24Bit(2, $116, !P1Tile1)
		%Dyn24Bit(2, $126, !P1Tile1+$10)
		%Dyn24Bit(2, $136, !P1Tile2)
		%Dyn24Bit(2, $146, !P1Tile2+$10)
		..end

	; swim
		.SwimDynamo0
		db ..end-..start
		..start
		%Dyn24Bit(2, $00C, !P1Tile1)
		%Dyn24Bit(2, $00E, !P1Tile1+$10)
		..end
		.SwimDynamo1
		db ..end-..start
		..start
		%Dyn24Bit(2, $008, !P1Tile1)
		%Dyn24Bit(2, $00A, !P1Tile1+$10)
		..end
		.SwimDynamo2
		db ..end-..start
		..start
		%Dyn24Bit(2, $004, !P1Tile1)
		%Dyn24Bit(2, $006, !P1Tile1+$10)
		..end
		.SwimDynamo3
		db ..end-..start
		..start
		%Dyn24Bit(2, $000, !P1Tile1)
		%Dyn24Bit(2, $002, !P1Tile1+$10)
		..end

	; drop kick
		.DropKickDynamo0
		db ..end-..start
		..start
		%Dyn24Bit(2, $0E0, !P1Tile1)
		%Dyn24Bit(2, $0F0, !P1Tile1+$10)
		%Dyn24Bit(2, $100, !P1Tile2)
		%Dyn24Bit(2, $110, !P1Tile2+$10)
		..end
		.DropKickDynamo1
		db ..end-..start
		..start
		%Dyn24Bit(2, $0E2, !P1Tile1)
		%Dyn24Bit(2, $0F2, !P1Tile1+$10)
		%Dyn24Bit(2, $102, !P1Tile2)
		%Dyn24Bit(2, $112, !P1Tile2+$10)
		..end
		.DropKickDynamo2
		db ..end-..start
		..start
		%Dyn24Bit(2, $0E4, !P1Tile1)
		%Dyn24Bit(2, $0F4, !P1Tile1+$10)
		%Dyn24Bit(2, $104, !P1Tile2)
		%Dyn24Bit(2, $114, !P1Tile2+$10)
		..end
		.DropKickDynamo3
		db ..end-..start
		..start
		%Dyn24Bit(2, $0D6, !P1Tile1)
		%Dyn24Bit(2, $0E6, !P1Tile1+$10)
		%Dyn24Bit(2, $0F6, !P1Tile2)
		%Dyn24Bit(2, $106, !P1Tile2+$10)
		..end
		.DropKickDynamo4
		db ..end-..start
		..start
		%Dyn24Bit(2, $0D8, !P1Tile1)
		%Dyn24Bit(2, $0E8, !P1Tile1+$10)
		%Dyn24Bit(2, $0F8, !P1Tile2)
		%Dyn24Bit(2, $108, !P1Tile2+$10)
		..end

	; drop kick bounce
		.DropKickBounceDynamo0
		db ..end-..start
		..start
		%Dyn24Bit(3, $0DA, !P1Tile1)
		%Dyn24Bit(3, $0EA, !P1Tile1+$10)
		%Dyn24Bit(3, $0FA, !P1Tile3)
		%Dyn24Bit(3, $10A, !P1Tile3+$10)
		..end
		.DropKickBounceDynamo1
		db ..end-..start
		..start
		%Dyn24Bit(3, $0DD, !P1Tile1)
		%Dyn24Bit(3, $0ED, !P1Tile1+$10)
		%Dyn24Bit(3, $0FD, !P1Tile3)
		%Dyn24Bit(3, $10D, !P1Tile3+$10)
		..end


	; dash attck
		.HeadbuttDynamo0
		db ..end-..start
		..start
		%Dyn24Bit(2, $08C, !P1Tile1)
		%Dyn24Bit(2, $09C, !P1Tile1+$10)
		%Dyn24Bit(2, $09C, !P1Tile2)
		%Dyn24Bit(2, $0AC, !P1Tile2+$10)
		..end
		.HeadbuttDynamo1
		db ..end-..start
		..start
		%Dyn24Bit(4, $0B6, !P1Tile1)
		%Dyn24Bit(4, $0C6, !P1Tile1+$10)
		..end

	; carry
		.CarryDynamo0
		db ..end-..start
		..start
		%Dyn24Bit(2, $11C, !P1Tile1)
		%Dyn24Bit(2, $12C, !P1Tile1+$10)
		%Dyn24Bit(2, $13C, !P1Tile2)
		%Dyn24Bit(2, $14C, !P1Tile2+$10)
		..end
		.CarryDynamo1
		db ..end-..start
		..start
		%Dyn24Bit(3, $160, !P1Tile1)
		%Dyn24Bit(3, $170, !P1Tile1+$10)
		%Dyn24Bit(3, $180, !P1Tile3)
		%Dyn24Bit(3, $190, !P1Tile3+$10)
		..end
		.CarryDynamo2
		db ..end-..start
		..start
		%Dyn24Bit(3, $163, !P1Tile1)
		%Dyn24Bit(3, $173, !P1Tile1+$10)
		%Dyn24Bit(3, $183, !P1Tile3)
		%Dyn24Bit(3, $193, !P1Tile3+$10)
		..end

	; throw
		.ThrowDynamo
		db ..end-..start
		..start
		%Dyn24Bit(3, $166, !P1Tile1)
		%Dyn24Bit(3, $176, !P1Tile1+$10)
		%Dyn24Bit(3, $186, !P1Tile3)
		%Dyn24Bit(3, $196, !P1Tile3+$10)
		..end

	; victory
		.VictoryDynamo
		db ..end-..start
		..start
		%Dyn24Bit(2, $118, !P1Tile1)
		%Dyn24Bit(2, $128, !P1Tile1+$10)
		%Dyn24Bit(2, $138, !P1Tile2)
		%Dyn24Bit(2, $148, !P1Tile2+$10)
		..end


	; spin effect
		.EffectDynamo
		db ..end-..start
		..start
		%Dyn24Bit(6, $006, !P1Tile6)
		%Dyn24Bit(6, $016, !P1Tile6+$10)
		..end
>>>>>>> Stashed changes




	.ClippingStandard
	db $0D,$02,$05,$05		; < X offset
	db $FF,$FF,$10,$F4		; < Y offset
	db $10,$10,$05,$05		; < Size

	.ClippingShell
	db $0D,$02,$05,$05		; < X offset
	db $05,$05,$10,$00		; < Y offset
	db $0A,$0A,$05,$05		; < Size



.End
print "  Anim data: $", hex(.End-ANIM), " bytes"


	DATA:
		.XSpeedLeft
		db $F4,$E8,$DC,$D0			; startup, walk, dash, shell slide
		.XSpeedRight
		db $0C,$18,$24,$30			; startup, walk, dash, shell slide

		.XSpeedSenku
		db $D0,$30				; left, right

		.AllRangeSpeedX				; for improved senku and swimming
		db $00,$30,$D0,$00
		db $00,$22,$DD,$00
		db $00,$22,$DD,$00
		db $00,$30,$D0,$00
		.AllRangeSpeedY
		db $00,$00,$00,$00
		db $30,$22,$22,$30
		db $D0,$DD,$DD,$D0
		db $00,$00,$00,$00

<<<<<<< Updated upstream
;			   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |			|
;	LO NYBBLE	   |YY0|YY1|YY2|YY3|YY4|YY5|YY6|YY7|YY8|YY9|YYA|YYB|YYC|YYD|YYE|YYF|	HI NYBBLE	|
;	--->		   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |			V

HIT_TABLE:		db $01,$01,$01,$01,$02,$02,$02,$02,$03,$03,$03,$03,$03,$04,$00,$05	;| 00X
			db $06,$02,$00,$07,$07,$08,$08,$00,$08,$00,$00,$07,$09,$07,$0A,$0A	;| 01X
			db $07,$0B,$0C,$0C,$0C,$0C,$07,$07,$07,$00,$07,$07,$00,$00,$07,$0D	;| 02X
			db $0E,$0E,$0E,$07,$07,$00,$00,$07,$07,$07,$07,$07,$07,$07,$0D,$06	;| 03X
			db $04,$0F,$0F,$0F,$07,$00,$10,$00,$07,$0F,$11,$0A,$00,$12,$12,$01	;| 04X
			db $01,$0A,$00,$00,$00,$0F,$0F,$0F,$0F,$00,$00,$0F,$0F,$0F,$0F,$00	;| 05X
			db $00,$0F,$0F,$0F,$00,$07,$07,$07,$07,$00,$00,$00,$00,$00,$13,$13	;| 06X
			db $00,$01,$01,$01,$1A,$1A,$1A,$1A,$1A,$00,$00,$11,$00,$00,$00,$00	;| 07X
			db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	;| 08X
			db $00,$10,$10,$10,$10,$10,$00,$10,$10,$07,$07,$0A,$0F,$00,$07,$14	;| 09X
			db $00,$07,$02,$00,$07,$07,$07,$00,$07,$07,$07,$15,$00,$00,$07,$16	;| 0AX
			db $07,$00,$07,$07,$07,$00,$07,$17,$17,$00,$0F,$0F,$00,$01,$0A,$18	;| 0BX
			db $0F,$00,$07,$07,$0F,$07,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	;| 0CX
			db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$02,$02,$02,$02,$07,$02	;| 0DX
			db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	;| 0EX
			db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	;| 0FX

			db $00,$01,$15,$15,$15,$15,$1C,$07,$1B,$00,$00,$1D,$00,$00,$00,$00	;| 10X
			db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	;| 11X
			db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	;| 12X
			db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	;| 13X
			db $19,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	;| 14X
			db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	;| 15X
			db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	;| 16X
			db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	;| 17X
			db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	;| 18X
			db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	;| 19X
			db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	;| 1AX
			db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	;| 1BX
			db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	;| 1CX
			db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	;| 1DX
			db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	;| 1EX
			db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	;| 1FX


=======
		.WaterSpeedX				; for walking underwater
		db $00,$10,$F0,$00
>>>>>>> Stashed changes

		.SwimDir
		db $FF,$01,$00,$FF

		.BubbleX
		db $00,$08

		.SlopeSpeed
		db $E0,$F0,$00,$00,$00,$00,$00,$10,$20

		.ThrowSpeedX
		db $C0,$40				; forward
		db $E0,$20				; down
		db $E8,$18				; up

		.ThrowSpeedY
		db $F0,$F0				; forward
		db $F0,$F0				; down
		db $C0,$C0				; up

		.CarryXOffset
		db $04
		db $05
		db $05

		.CarryYOffset
		db $F0
		db $F3
		db $EF



	.HitboxTable
		dw .HitboxPunch
		dw .HitboxHeadbutt1
		dw .HitboxHeadbutt2
		dw .HitboxHeadbutt3
		dw .HitboxSpin
		dw .HitboxDropkick


	.HitboxPunch
	dw $0008,$FFFA : db $14,$12	; X/Y + W/H
	db $10,$E8			; speeds
	db $12				; timer
	db $05				; hitstun
	db $00,$38			; SFX
	db $00

	.HitboxHeadbutt1
	dw $0010,$FFF6 : db $10,$14	; X/Y + W/H
	db $40,$D8			; speeds
	db $30				; timer
	db $08				; hitstun
	db $00,$37			; SFX
	dw $FFFF,$FFF5 : db $11,$16	; X/Y + W/H
	db $20,$C0			; speeds
	db $30				; timer
	db $06				; hitstun
	db $02,$00			; SFX

	.HitboxHeadbutt2
	dw $0010,$FFF6 : db $10,$14	; X/Y + W/H
	db $30,$E0			; speeds
	db $30				; timer
	db $05				; hitstun
	db $02,$00			; SFX
	dw $FFFF,$FFF5 : db $11,$16	; X/Y + W/H
	db $18,$C8			; speeds
	db $30				; timer
	db $05				; hitstun
	db $02,$00			; SFX

	.HitboxHeadbutt3
	dw $0000,$FFF6 : db $10,$14	; X/Y + W/H
	db $20,$E8			; speeds
	db $30				; timer
	db $04				; hitstun
	db $02,$00			; SFX
	dw $FFFF,$FFF5 : db $11,$16	; X/Y + W/H
	db $10,$D0			; speeds
	db $30				; timer
	db $04				; hitstun
	db $02,$00			; SFX

	.HitboxSpin
	dw $0008,$0000 : db $10,$10	; X/Y + W/H
	db $10,$E8			; speeds
	db $20				; timer
	db $05				; hitstun
	db $02,$00			; SFX
	dw $FFF8,$0000 : db $10,$10	; X/Y + W/H
	db $F0,$E8			; speeds
	db $20				; timer
	db $05				; hitstun
	db $02,$00			; SFX

	.HitboxDropkick
	dw $FFF8,$FFF8 : db $20,$20	; X/Y + W/H
	db $10,$40			; speeds
	db $20				; timer
	db $05				; hitstun
	db $02,$00			; SFX
	db $00






namespace off

