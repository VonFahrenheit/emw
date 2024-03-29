;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

namespace Kadaal

; --Build 7.0--
;
;
; Upgrade data:
;	bit 0 (01)	Senku smash
;	bit 1 (02)	Can senku in 8 directions
;	bit 2 (04)	Can start senku in midair
;	bit 3 (08)	----
;	bit 4 (10)	----
;	bit 5 (20)	+1 HP, getting hit during shell slide will not deal damage to you (but will still knock you back)
;	bit 6 (40)	----
;	bit 7 (80)	Push X to perform ultimate attack


; new upgrade layout:
;	bit 0	drop kick
;	bit 1	directional senku
;	bit 2	air senku
;	bit 3	shadow step
;	bit 4	fancy footwork (backdash/pivot)
;	bit 5	---- ????
;	bit 6	---- ????
;	bit 7	ultimate: shun koopa satsu



	MAINCODE:
		PHB : PHK : PLB

		LDA #$02 : STA !P2Character
		LDA #$08			;\
		CLC : ADC !PlayerBonusHP	; | max HP
		STA !P2MaxHP			;/

		LDA !P2Init : BNE .Main

		.Init
		INC !P2Init
		PHP
		LDA.b #!VRAMbank : PHA
		REP #$30
		LDY.w #!File_Kadaal : JSL GetFileAddress
		JSL GetVRAM
		PLB
		LDA #$0140*$20
		CLC : ADC !FileAddress
		STA !VRAMtable+$02,x
		CLC : ADC #$0200
		STA !VRAMtable+$09,x
		LDA !FileAddress+2
		STA !VRAMtable+$04,x
		STA !VRAMtable+$0B,x
		LDA !CurrentPlayer
		AND #$00FF
		BEQ $03 : LDA #$0200
		CLC : ADC.w #(!P1Tile6*$10)+$6000
		STA !VRAMtable+$05,x
		CLC : ADC #$0100
		STA !VRAMtable+$0C,x
		LDA #$00C0
		STA !VRAMtable+$00,x
		STA !VRAMtable+$07,x
		PHK : PLB
		PLP

		.Main



		LDA !P2Status : BEQ .Process
		CMP #$01 : BEQ .KnockedOut

		.Snap
		REP #$20
		LDA $94 : STA !P2XPosLo
		LDA $96 : STA !P2YPosLo
		SEP #$20
		PLB
		RTL

		.KnockedOut			; State 01
		JSL CORE_KNOCKED_OUT
		BMI .Fall
		BCC .Fall
		LDA #$02 : STA !P2Status
		PLB
		RTL

		.Fall
		BIT !P2YSpeed : BMI +
		LDA $14
		LSR #3
		AND #$01
		STA !P2Direction
	+	STZ !P2Carry
		STZ !P2Invinc
		LDA #!Kad_Dead : STA !P2Anim
		STZ !P2AnimTimer
		JMP ANIMATION_HandleUpdate


		.Process				; state 00
		LDA !P2MaxHP						;\
		CMP !P2HP						; | enforce max HP
		BCS $03 : STA !P2HP					;/
		REP #$20						;\
		LDA !P2Hitbox1IndexMem					; |
		ORA !P2Hitbox2IndexMem					; | merge hitboxes
		STA !P2Hitbox1IndexMem					; |
		STA !P2Hitbox2IndexMem					; |
		SEP #$20						;/

		LDA !P2DashSmoke : BEQ .NoSmoke
		JSL CORE_DASH_SMOKE
		.NoSmoke

		LDA !P2JumpLag
		BEQ $03 : DEC !P2JumpLag
		LDA !P2HurtTimer
		BEQ $03 : DEC !P2HurtTimer
		LDA !P2Invinc
		BEQ $03 : DEC !P2Invinc
		LDA !P2Senku
		BEQ $03 : DEC !P2Senku
		LDA !P2Punch
		BEQ $03 : DEC !P2Punch
		LDA !P2Headbutt
		BEQ $03 : DEC !P2Headbutt
		LDA !P2SlantPipe
		BEQ $03 : DEC !P2SlantPipe
		LDA !P2BackDash
		BEQ $03 : DEC !P2BackDash
		LDA !P2Throw
		BEQ $03 : DEC !P2Throw
		LDA !P2DashSmoke
		BEQ $03 : DEC !P2DashSmoke

		LDA !P2ShellSpin
		BEQ +
		BPL ++
		INC !P2ShellSpin
		BRA +
	++	DEC !P2ShellSpin : BNE +
		LDA #$F0 : STA !P2ShellSpin
		LDA !P2ShellSlide : BNE ++
		LDA !P2Ducking : BEQ ++
		LDA #!Kad_Duck+1
		BRA +++
	++	LDA #!Kad_Shell
	+++	STA !P2Anim
		STZ !P2AnimTimer
		STZ !P2Buffer
		+


	PIPE:
		JSL CORE_PIPE : BCC CONTROLS
		JMP ANIMATION



	CONTROLS:
		JSL CORE_COYOTE_TIME

		LDA !P2Headbutt : BEQ .NoHeadbutt	;\
		LDA !P2Direction			; |
		AND #$01				; |
		EOR #$01				; | force forward input during headbutt
		INC A					; |
		TSB $15					; |
		EOR #$03 : TRB $15			; |
		.NoHeadbutt				;/


		LDA $16					;\
		AND #$03 : BEQ .NoPunchDashCancel	; |
		CMP #$03 : BEQ .NoPunchDashCancel	; | end punch on left/right press
		STZ !P2Punch				; |
		.NoPunchDashCancel			;/


		LDA !P2InAir : BNE .NoForceCrouch	;\
		JSL CORE_CHECK_ABOVE			; |
		BCC .NoForceCrouch			; | force down input if kadaal is on ground with a solid block above
		LDA #$04 : TSB $15			; |
		LDA #$01 : STA !P2ShellSlide
		.NoForceCrouch				;/


		LDX !P2Direction
		LDA !P2Headbutt : BNE .NoTurn		; can't turn during headbutt
		LDA !P2ShellSlide : BNE .Turn
		LDA !P2Climbing : BNE .Turn
		LDA !P2Water : BNE .Turn
		LDA !P2Blocked
		AND #$04
		ORA !P2Platform
		BEQ .NoTurn

		.Turn
		LDX #$FF

		.NoTurn
		PHX
		PEA PHYSICS-1

		LDA !P2HurtTimer : BEQ $03 : JMP .Friction_main	; go to friction without shell slide check

		LDA !P2Climbing : BEQ $03 : JMP .NoDuck


		LDX !P2Carry : BEQ .NoThrow
		STZ !P2DashTimerR2				;\ can't dash with object
		STZ !P2DashTimerL2				;/
		STZ !P2ShellSlide				;\ can't shell slide with object
		STZ !P2ShellSpeed				;/
		LDA !P2InAir : BNE +
		STZ !P2Dashing					; end dash state
	+	STZ !P2Headbutt					; end headbutt
		STZ !P2Punch					; end punch
		LDA !P2Ducking : BNE .Throw
		BIT $18 : BMI .Throw
		BIT $15 : BVS .NoThrow
		LDA #$08 : STA !P2Throw
		LDA #!Kad_Throw : STA !P2Anim
		STZ !P2AnimTimer
		.Throw
		DEX
		LDA #$0A : STA $3230,x
		LDA !P2Direction : TAY
		EOR #$01 : STA $3320,x
		LDA $15
		AND #$04 : BEQ ..throw
		..drop
		LDA #$09 : STA $3230,x
		INY #2
		..throw
		LDA .ThrowSpeed,y : STA !SpriteXSpeed,x
		LDA #$F0 : STA !SpriteYSpeed,x
		LDA #$10
		STA !SpriteDisP1,x
		STA !SpriteDisP2,x
		STZ !P2Carry
		.NoThrow

		LDA !P2Throw : BEQ $03 : JMP .Friction



		LDA !P2Blocked
		AND #$04
		ORA !P2Platform
		BNE ..Ground
		LDA !P2ShellSlide : BNE .ShellSlide		; maintain shell slide in midair
	-	JMP .NoGround

	..Ground
		LDA !KadaalUpgrades
		AND #$10 : BEQ .NoBackDash
		LDA !P2BackDash
		CMP #$08 : BCC ..BackDash
		BRA ..NoDir

	..BackDash
		LDA $18
		AND #$30 : BEQ .NoBackDash
		AND #$10 : BEQ +
		LDA !P2Direction				; R is perfect pivot
		INC A
		TSB $15
		EOR #$03 : TRB $15
	+	LDA #$10 : STA !P2BackDash
		LDA $15
		AND #$03 : BEQ +
		CMP #$03 : BEQ +
		DEC A
		EOR #$01
		STA !P2Direction
		BRA ++
	+	LDA !P2Direction
	++	EOR #$01
		TAY
		LDA .XSpeedSenku,y : JSL CORE_SET_XSPEED
		LDA #$2D : STA !SPC1				; slide SFX
		STZ !P2Punch
		STZ !P2Senku
	..NoDir	LDA #$0F					;\
		TRB $15						; | clear directionals during back dash
		TRB $16						;/
		LDA #$01 : STA !P2Dashing
		.NoBackDash


		.ShellSlide					;\
		LDA $15						; |
		AND #$04 : BNE +				; |
		LDA !P2ShellSlide : BEQ ++			; |
		LDA #$01 : STA !P2Dashing			; > shell slide can be canceled into a dash
		STZ !P2ShellSlide				; |
	++	STZ !P2ShellSpeed				; |
		BRA .NoGround					; |
	+	LDA !P2ShellSlide : BEQ .NoGround		; |
	-	JSR .GSpin					; > Hook ground spin here
		LDA !P2Blocked					; |
		AND #$03 : BEQ +				; |
		DEC A						; |
		AND #$01					; | Shell slide code
		STA !P2Direction				; |
		LDA !P2XSpeed					; |
		EOR #$FF : INC A				; |
		STA !P2XSpeed					; |
		LDA #$01 : STA !SPC1				; |
	+	LDY !P2Direction				; |
		LDA .XSpeedSenku,y				; |
		LDY #$02					; |
		JSL CORE_ACCEL_X				; |
		LDA #$01 : STA !P2ShellSpeed			; |
		LDA #$03					; |
		TRB $15						; |
		TRB $16						; |
	-	JMP .NoDuck					; |
		.NoGround					;/

		LDA !P2Senku : BEQ +
		STZ !P2Carry				; end carry when senku starts
		CMP #$20 : BCC -
	+	LDA !P2Blocked
		LDY !P2Platform
		BEQ $02 : ORA #$04
		AND $15
		AND #$04 : BEQ .NoDuck
		BIT $16
		BPL $03 : JMP .SenkuJump
		LDA !P2Senku : BEQ +			;\
		LDA $16					; | must press (not hold) down to cancel senku (this allows senku out of shell slide)
		AND #$04 : BEQ .NoDuck			; |
		+					;/

		LDA !P2Headbutt				;\ can cancel ending of headbutt into headbutt
		CMP #$11 : BCS .NoDuck			;/
		LDA !P2Water : BNE .ForceCrouch		; can't shell slide underwater
		LDA !P2Slope : BNE +			; > always start sliding on slopes
		LDA !P2XSpeed				; |
		BPL $03 : EOR #$FF : INC A		; | start shell slide with enough speed
		CMP #$20 : BCC .ForceCrouch		; |
	+	JSR StartSlide				; |
		JMP .Friction				;/ > skip remaining inputs this frame


	.ForceCrouch
		STZ !P2XSpeed
		LDA #$01 : STA !P2Ducking
		LDA #$04 : STA !P2JumpLag
		STZ !P2Punch
		STZ !P2Headbutt
		STZ !P2Dashing
		STZ !P2Senku
	.GSpin	LDA !P2ShellSpin : BNE .SpinR		;\
		BIT $16 : BVC .SpinR			; | ground spin
		.StartSpin				; > JSR here to start spin
		LDA #$10 : STA !P2ShellSpin		; |
		LDA #!Kad_Spin : STA !P2Anim		; |
		LDA #$3E : STA !SPC4			; | > spin SFX
		LDA #$40 : TRB $16
		TRB $15
		TRB !P2Buffer
	;	STZ !P2Hitbox1IndexMem1			; |
	;	STZ !P2Hitbox1IndexMem2			; |
	;	STZ !P2Hitbox2IndexMem1			; |
	;	STZ !P2Hitbox2IndexMem2			; |
		STZ !P2AnimTimer			;/
	.SpinR	RTS
		.NoDuck


		LDA !P2Ducking : BEQ .NoDuckEnd
		STZ !P2Ducking
		STZ !P2ShellSpin
		.NoDuckEnd

		LDA !P2Senku
		BNE $03 : JMP .InitSenku
		CMP #$20 : BCC .ProcessSenku
		BNE .NoInitSenku			;\ set invulnerability timer
		STA !P2Invinc				;/
		LDA !KadaalUpgrades			;\
		AND #$02 : BEQ ..Basic			; | store all-range senku direction if upgrade is attained
		LDA $15					; |
		AND #$0F : STA !P2AllRangeSenku		;/
		..Basic
		LDA $15
		LSR A : BCC +
		LDA #$01 : STA !P2SenkuDir
		BRA .ProcessSenku
	+	LSR A : BCS +

		.NoInitSenku
		LDA !P2Direction : STA !P2SenkuDir
		LDA #$00
		BRA .ReturnSenku

	+	STZ !P2SenkuDir

		.ProcessSenku
		LDA !P2Senku
		CMP #$1F : BNE ..notakeoff
		LDA #$05 : STA !P2DashSmoke
		..notakeoff
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
	..Write	STA !P2XSpeed
		STZ !P2JumpLag
		STZ !P2DashTimerR1
		STZ !P2DashTimerL1
		STZ !P2Buffer
		STZ !P2Climbing
		LDA !P2Senku
		CMP #$20 : BCC ..process
	; SHADOWSTEP CEHCK
	; shadow step
	LDA !KadaalUpgrades
	AND #$08 : BEQ +
	BIT $18 : BPL +
	LDA !P2Direction
	ASL A : TAY
	REP #$20
	LDA !P2XPosLo
	CLC : ADC .ShadowstepDistance,y
	STA !P2XPosLo
	SEP #$20
	STZ !P2Senku
	RTS

		..process
		LDA !P2SenkuDir					;\
		EOR #$01					; |
		INC A						; | Don't keep momentum after senku-ing into a block
		AND !P2Blocked					; |
		BEQ $06						; |
		STZ !P2XSpeed : STZ !P2Dashing			;/
		LDA !P2Blocked
		AND #$04
		ORA !P2Platform
		BNE ++
		LDA #$01 : STA !P2SenkuUsed
		++
		BIT $16 : BPL +
		STZ !P2Invinc
		JMP .SenkuJump
	+	RTS


	.ShadowstepDistance
	dw $FFB0
	dw $0050

		.InitSenku
		LDA !P2SenkuUsed : BNE .NoSenku
		LDA !KadaalUpgrades				;\
		ORA !P2Blocked					; | air senku is only allowed with proper upgrade
		AND #$04					; |
		BEQ .NoSenku					;/

		BIT $18 : BPL .NoSenku
		STZ !P2Climbing					; drop from net/vine
		LDA !P2ShellSpin : BMI $02 : BNE .NoSenku
		STZ !P2ShellSlide				;\ end slide
		STZ !P2ShellSpeed				;/
		STZ !P2Ducking					; end crouch
		STZ !P2Dashing					; end dash
		STZ !P2XSpeed					; clear X speed
		STZ !P2Headbutt					; clear headbutt
		STZ !P2ShellSpin				; clear spin attack
		LDA #$30 : STA !P2Senku
		LDA #$34 : STA !P2FlashPal			; flash black
		LDA #$01 : STA !P2SenkuUsed
		STZ !P2DropKick
		RTS
		.NoSenku


		LDA !P2Climbing : BEQ .NoClimb			; Check for vine/net climb
		STZ !P2ShellSlide
		LDA $15
		LSR A : BCC +
		LDA #$01 : STA !P2Direction
		BRA ++
	+	LSR A : BCC ++
		STZ !P2Direction
	++	BIT $16 : BPL +
		STZ !P2Climbing					; vine/net jump
		LDA #$A8 : STA !P2YSpeed
		LDA #$2B : STA !SPC1				; jump SFX
	+	RTS
		.NoClimb


		.CheckWater
		LDA !P2Blocked					;\
		AND #$04					; |
		LDY !P2Platform					; | $01 = ground flag
		BEQ $02 : ORA #$04				; |
		STA $01						;/
		LDA !P2Water					;\ Water check
		BNE .Water : JMP .NoWater			;/

		.Water
		STZ !P2ShellSlide				;\ no shell slide underwater
		STZ !P2ShellSpeed				;/
		STZ !P2Dashing					; no dash underwater
		LDA !P2Anim					;\
		CMP #!Kad_Fall+1 : BEQ ++
		CMP #!Kad_Fall+2 : BNE +			; |
	++	LDA #!Kad_Swim : STA !P2Anim			; | fall -> swim anim
		STZ !P2AnimTimer				; |
		+						;/

		LDA !P2Water
		ORA !P2Blocked
		AND #$08 : BNE ..nojump
		BIT $16 : BPL ..nojump
		JMP .SenkuJump
		..nojump

		LDA $15						;\
		AND #$0F					; | swim speed index
		TAY						;/
		LDA !P2YSpeed					;\
		CMP .AllRangeSpeedY,y				; |
		BEQ +						; | swimming Y speed
		BPL $04 : INC #4				; |
		DEC #2						; |
	+	STA !P2YSpeed					;/
		LDA $01 : BNE .WaterGround
		LDA !P2XSpeed
		CMP #$F0 : BCS +
		CMP #$10 : BCC +
		ASL A
		ROL A
		AND #$01
		EOR #$01
		STA !P2Direction
		BRA +

		.WaterGround
		LDA $15						;\
		AND #$03					; |
		TAY						; | underwater dir
		LDA .SwimDir,y : BMI .NoSwimDir			; |
		STA !P2Direction				; |
		.NoSwimDir					;/
		LDA $15
		AND #$88 : BEQ ..norise
		BPL ..rise
		..jump
		LDA #$2B : STA !SPC1				; jump SFX
		LDA #$C0 : STA !P2YSpeed
		BRA +
		..rise
		LDA #$F8 : STA !P2YSpeed
		BRA +
		..norise
		LDA !P2Punch					;\ index 0 while punching
		BEQ $02 : LDY #$00				;/
		LDA !P2XSpeed					;\
		CMP .WaterSpeedX,y				; |
		BEQ ++						; |
		BPL $02 : INC #2				; | underwater walking X speed
		DEC A						; |
		STA !P2XSpeed					; |
		BRA ++						; |
		+						;/
		LDA !P2XSpeed					;\
		CMP .AllRangeSpeedX,y				; |
		BEQ +						; | swimming X speed
		BPL $04 : INC #4				; |
		DEC #2						; |
		STA !P2XSpeed					; |
		+						;/
		BPL $02 : EOR #$FF				;\ store absolute X speed
		STA $00						;/
		LDA !P2YSpeed					;\
		BPL $02 : EOR #$FF				; | do animation if there is speed
		CLC : ADC $00					; |
		BNE +						;/
		LDA !P2ShellSpin : BNE ++			; always animate spin at 50% rate
		STZ !P2AnimTimer				;\ otherewise no animation
		BRA +++						;/
	+	CMP #$20					;\ animate at 100% rate if |X|+|Y|>0x1F
		BCS +++						;/
	++	LDA $14						;\
		LSR A						; | animate at 50% rate
		BCC +++						; |
		DEC !P2AnimTimer				;/
	+++	STZ !P2SenkuUsed				; > no animation
		LDA $14						;\ only spawn every 128 frames
		AND #$7F : BNE .NoWater				;/

		PHB						;\
		JSL GetParticleIndex				; |
		LDA.w #!prt_bubble : STA !Particle_Type,x	; |
		LDA.l !P2YPosLo					; |
		SEC : SBC #$0008				; |
		STA !Particle_Y,x				; |
		PLB						; | spawn bubble
		LDA !P2Direction				; |
		AND #$00FF : TAY				; |
		LDA .BubbleX,y					; |
		AND #$00FF					; |
		CLC : ADC !P2XPosLo				; |
		STA !41_Particle_X,x				; |
		SEP #$30					;/
		.NoWater

		LDA !P2ShellSlide : BNE ..Skip			; can't punch during shell slide
		BIT !P2Buffer : BVS +				; skip regular input if buffered
		BIT $16
		BVS $03
	..Skip	JMP .NoPunch
	+	STZ !P2BackDash					; > clear back dash when an attack is started
		LDA !P2ShellSpin : BEQ +			; see if a spin is happening already
	..NoC	LDA #$40 : STA !P2Buffer			;\ don't change buffer here if spin is active
		JMP .NoPunch					;/
	+	LDA !P2Blocked
		AND #$04
		ORA !P2Platform
		BEQ .AirSpin
		BRA .NoSpin

		.AirSpin
		LDA #$10 : STA !P2ShellSpin
		LDA #!Kad_Spin : STA !P2Anim
		LDA #$3E : STA !SPC4				; spin SFX
		STZ !P2AnimTimer
		STZ !P2Punch
		STZ !P2Headbutt
	;	STZ !P2Hitbox1IndexMem1
	;	STZ !P2Hitbox1IndexMem2
	;	STZ !P2Hitbox2IndexMem1
	;	STZ !P2Hitbox2IndexMem2
		BRA .NoPunch
		.NoSpin

		LDA !P2TouchingItem : BNE .NoPunch

		LDA !P2Punch
		ORA !P2Headbutt
		BEQ .Attack
		LDA #$40 : TSB !P2Buffer			;\ Set punch buffer and clear jump buffer
		LDA #$80 : TRB !P2Buffer			;/
		BRA .NoPunch
		.Attack
		LDA !P2XSpeed					;\
		CLC : ADC #$1A					; | headbutt req 1: at least |0x1A| X speed
		CMP #$34 : BCC .Punch				;/
		LDA $15						;\
		AND #$03 : BEQ .Punch				; |
		CMP #$03 : BEQ .Punch				; | headbutt req 2: must hold same direction as moving
		DEC A						; |
		ROR #2						; |
		EOR !P2XSpeed : BMI .Punch			;/
		.Headbutt
		LDA #$23 : STA !P2Headbutt
		STZ !P2Punch
		LDA #$2D : STA !SPC1				; headbutt init SFX
		LDA #$03 : STA !P2DashSmoke			; dash smoke for 3 frames
		BRA .AttackShared
		.Punch
		LDA #$0E : STA !P2Punch
		STZ !P2Headbutt
		LDA #$3D : STA !SPC4				; punch init SFX
		.AttackShared
		LDA #$40 : TRB !P2Buffer
	;	STZ !P2Hitbox1IndexMem1
	;	STZ !P2Hitbox1IndexMem2
	;	STZ !P2Hitbox2IndexMem1
	;	STZ !P2Hitbox2IndexMem2
		.NoPunch


;		LDA !P2ShellDrill : BEQ .NoDrill		;\
;		LDA $16						; |
;		AND #$08 : BEQ +				; |
;		STZ !P2ShellDrill				; | Can cancel drill with up
;		LDA #!Kad_Squat : STA !P2Anim			; |
;		STZ !P2AnimTimer				; |
;		BRA .NoDrill					;/
;	+	STZ !P2XSpeed					;\
;		LDA #$08 : STA !P2Invinc			; > invulnerable during shell drill
;		LDA #$14					; |
;		LDY !P2Anim					; |
;		CPY #!Kad_ShellDrill : BEQ +			; | Shell drill code
;		LDA #$40					; |
;	+	STA !P2YSpeed					; |
;		RTS						; |
;		.NoDrill					;/


		LDA !P2Water : BEQ +				;\
		RTS						; | return here if underwater
		+						;/




		LDA !P2CoyoteTime : BMI +			;\ coyote time
		BNE .InitJump					;/
	+	LDA !P2JumpLag					;\
		BEQ .ProcessJump				; |
		BIT $16 : BPL $05				; | allow jump buffer from land lag
		LDA #$80 : TSB !P2Buffer			; |
		JMP .Friction					;/


	; THIS IS THE MAIN JUMP CODE

		.ProcessJump
		LDA !P2Blocked
		AND #$04
		ORA !P2Platform
		BEQ .NoJump
	;	LDA !P2Floatiness		;\
	;	CMP #$1A : BCS .NoJump		; |
	;	BIT $15 : BMI .NoJump		; |
	;	STZ !P2Floatiness		; | stop ascent if player lets go of B
	;	BIT !P2YSpeed : BPL .NoJump	; |
	;	LDA !P2YSpeed			; |
	;	CLC : ADC #$20			; |
	;	BMI $02 : LDA #$00		; |
	;	STA !P2YSpeed			; |
	;	BRA .NoJump			;/

		.InitJump
		LDA !P2Buffer
		ORA $16
		BPL .NoJump
		LDA !P2ShellSlide : BNE ..maintainspin	; if not in shell slide...
		STZ !P2ShellSpin			; ...clear shell spin
		LDA #!Kad_Rise : STA !P2Anim		; ...set anim right away
		..maintainspin
		STZ !P2CoyoteTime			; clear coyote time
		STZ !P2AnimTimer
	;	LDA !P2Punch1				;\
	;	ORA !P2Punch2				; |
	;	BEQ .SenkuJump				; | Allow players to buffer jump from punch
	;	LDA #$80 : STA !P2Buffer		; |
	;	BRA .NoJump				;/

		.SenkuJump
		LDA #$80 : TRB !P2Buffer		; clear jump from buffer
		STZ !P2Punch				; clear punch
		STZ !P2Headbutt				; clear headbutt
		STZ !P2BackDash				; clear back dash
		STZ !P2Senku				; clear senku
		LDA !P2XSpeed				;\
		BPL $03 : EOR #$FF : INC A		; |
		LDX !P2Dashing				; |
		BEQ $02 : LDA #$24			; > use 0x24 during dash to prevent jumps from being inconsistent
		LDX !P2Carry : BEQ ..nocarry		; |
		LDX #$01 : STX !P2Dashing		; > set dash flag when jumping with object
		..nocarry				; | (deliberately placed here so you can get a super jump by combining with coyote jump)
		LDX !P2ShellSlide			; |
		BEQ $02 : LDA #$10			; > use 0x10 during shell slide for a really big jump
		STA $00					; | calculate max jump speed based on X speed
		ASL A					; |
		CLC : ADC $00				; |
		LSR #3					; |
		SEC : SBC #$58				; |
		STA !P2YSpeed				;/

		LDA #$04 : TRB !P2Blocked		; instantly leave ground
		LDA #$2B : STA !SPC1			; jump SFX
		.NoJump


		LDA !P2Punch : BNE +			;\
		LDA !P2Headbutt : BEQ ++		; |
		CMP #$18 : BCS ++			; | friction during punch and endlag of headbutt
	+	JMP .Friction				; |
		++					;/


		LDA !P2Blocked
		AND #$04
		ORA !P2Platform
		BNE +
		LDA !P2XSpeed : BEQ .NoDashCancel	; no dash cancel from X speed = 0
		AND #$80
		CLC : ROL #2
		EOR #$01
		INC A					; > 2 = right, 1 = left
		AND $15 : BEQ .NoDashCancel
		BRA ++

	+	LDA $15
		AND #$03 : BEQ ++
		CMP #$03 : BNE .NoDashCancel		; end dash if pressing left and right at the same time
	++	STZ !P2Dashing
		.NoDashCancel

		LDA !P2Blocked
		AND #$04
		ORA !P2Platform
		BEQ +
		LDA $16
		LSR A : BCC +
		LDX !P2DashTimerR2 : BEQ +
		STX !P2Dashing
	+	LSR A : BCC +
		LDX !P2DashTimerL2 : BEQ +
		STX !P2Dashing
		+

		LDA !P2Blocked
		AND #$04
		ORA !P2Platform
		BEQ ++
		LDA $15
		LSR A
		BCS .ResetRight
		LDX #$08 : STX !P2DashTimerR1
		LDX !P2DashTimerR2 : BEQ +
		DEC !P2DashTimerR2
		BRA +
		.ResetRight
		LDX #$0F : STX !P2DashTimerR2
		LDY !P2Dashing
		BEQ $03 : STX !P2DashTimerL2
		LDX !P2DashTimerR1 : BEQ +
		DEC !P2DashTimerR1
		+

		LSR A : BCS .ResetLeft
		LDX #$08 : STX !P2DashTimerL1
		LDX !P2DashTimerL2 : BEQ +
		DEC !P2DashTimerL2
		BRA +
		.ResetLeft
		LDX #$0F : STX !P2DashTimerL2
		LDY !P2Dashing
		BEQ $03 : STX !P2DashTimerR2
		LDX !P2DashTimerL1 : BEQ +
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
		LDA !P2ShellSpeed : BNE +
		LDA !P2Headbutt : BEQ ++
	+	LDX #$03
		++

		LDA !P2Blocked
		AND #$04
		ORA !P2Platform
		STA $00
		LDA $15
		AND #$03
		CMP #$01 : BEQ .Right
		CMP #$02 : BEQ .Left
		CMP #$03 : BEQ .Friction
		LDA !P2InAir : BEQ .Friction	;\
		LDA !P2XSpeed			; |
		CMP #$40 : BCC .Friction	; | no air friction if moving faster than 0x40
		CMP #$C0+1 : BCS .Friction	; |
		LDA #$03 : TSB $15		;/

		.Friction
		LDA !P2ShellSlide : BEQ ..main	; return if sliding in shell
		RTS
		..main
		STZ !P2ShellSpeed
		LDA !P2Slope
		CLC : ADC #$04
		TAX
		LDY #$02
		LDA !IceLevel : BEQ ..notice	;\
		LDA !P2InAir : BNE ..notice	; |
		LDA $14				; | 25% accel on icy ground
		AND #$01 : TAY			; |
		..notice			;/
		LDA .SlopeSpeed,x
		JSL CORE_ACCEL_X
		RTS


		.Right
		LDA #$01 : STA !P2Direction	; face right
		LDA !P2ShellSpeed : BNE ..fast
		LDA !P2DashTimerR1 : BEQ ..fast
		LDX #$00
		..fast
		LDY #$03
		BIT !P2XSpeed
		BMI $02 : LDY #$06
		LDA .XSpeedRight,x : BRA .HorzAccel

		.Left
		STZ !P2Direction		; face left
		LDA !P2ShellSpeed : BNE ..fast
		LDA !P2DashTimerL1 : BEQ ..fast
		LDX #$00
		..fast
		LDY #$03
		BIT !P2XSpeed
		BPL $02 : LDY #$06
		LDA .XSpeedLeft,x

		.HorzAccel
		STA $00
		LDA !IceLevel : BEQ ..notice	;\
		LDA !P2InAir : BNE ..notice	; |
		TYA				; | 50% accel on icy ground
		LSR A				; |
		TAY				; |
		LDA $00				; |
		CMP !P2XSpeed : BEQ ..return	; |
		LDX !P2Anim
		CPX.b #!Kad_Dash_over : BCS +
		INC !P2AnimTimer		; > animate faster when accelerating on icy ground
		CPX.b #!Kad_Walk_over : BCC +
		PHA
		PHY
		JSL CORE_SMOKE_AT_FEET_Always
		PLY
		PLA
	+	JSL CORE_ACCEL_X		; |
		RTS				;/
		..notice			;\
		LDA $00				; | full accel on normal ground and in midair
		JSL CORE_ACCEL_X		;/
		..return
		RTS


		.XSpeed
		.XSpeedLeft
		db $F4,$E8,$DC,$D0		; Startup, walk, dash, shell slide

		.XSpeedRight
		db $0C,$18,$24,$30		; Startup, walk, dash, shell slide

		.XSpeedSenku
		db $D0,$30			; Left, right

		.AllRangeSpeedX			; For improved senku and swimming
		db $00,$30,$D0,$00
		db $00,$22,$DD,$00
		db $00,$22,$DD,$00
		db $00,$30,$D0,$00
		.AllRangeSpeedY
		db $00,$00,$00,$00
		db $30,$22,$22,$30
		db $D0,$DD,$DD,$D0
		db $00,$00,$00,$00

		.WaterSpeedX			; For walking underwater
		db $00,$10,$F0,$00

		.SwimDir
		db $FF,$01,$00,$FF

		.BubbleX
		db $00,$08

		.SlopeSpeed
		db $E0,$F0,$00,$00,$00,$00,$00,$10,$20

		.ShellSlideAcc
		db $FC,$04			; added on top of friction, that's why this is so high

		.ThrowSpeed
		db $C0,$40
		db $E0,$20


	PHYSICS:
		PLA
		BMI $03 : STA !P2Direction

		.SlantPipe
		LDA !P2SlantPipe : BEQ ..done
		LDA #$40 : STA !P2XSpeed
		LDA #$C0 : STA !P2YSpeed
		LDA #$01 : STA !P2Dashing
		..done

	.Collisions
		LDA !P2Blocked
		AND #$04
		ORA !P2Platform
		BNE .OnGround
		LDA !P2XSpeed : BEQ .NoWall
		CLC : ROL #2
		INC A				; 1 = right, 2 = left
		AND !P2Blocked : BEQ .NoWall
		STZ !P2Dashing
		STZ !P2XSpeed
		BRA .NoWall

		.OnGround
		STZ !P2KillCount
		STZ !P2SenkuUsed
		LDA !P2XSpeed
		BEQ .NoWall
		BMI .LeftWall

		.RightWall
		LDA !P2Blocked
		LSR A
		BCC .NoWall
		STZ !P2XSpeed
		BRA .NoWall

		.LeftWall
		LDA !P2Blocked
		AND #$02
		BEQ .NoWall
		STZ !P2XSpeed

		.NoWall



	SPRITE_INTERACTION:
		LDA !P2Senku : BEQ .Process
		CMP #$20 : BCC UPDATE_SPEED
		.Process
		JSL CORE_SPRITE_INTERACTION


	UPDATE_SPEED:
		LDA #$03				; gravity when holding B is 3
		BIT $15					;\ gravity without holding B is 6
		BMI $02 : LDA #$06			;/
		BIT !P2Water				;\ gravity in water is 0
		BVC $02 : LDA #$00			;/
		STA !P2Gravity				; store gravity
		LDA #$46 : STA !P2FallSpeed		; fall speed is 0x46
		JSL CORE_UPDATE_SPEED
		LDA !P2Platform
		BEQ +
		LDA #$04 : TSB !P2Blocked
		+

		LDX !P2Carry : BEQ .NoCarry
		JSL CORE_CARRY		
		.NoCarry


	OBJECTS:
		LDA !P2Blocked : PHA
		REP #$30
		LDA !P2Anim
		AND #$00FF
		ASL #3
		TAY
		LDA ANIM+$06,y : JSL CORE_COLLISION

		LDA !P2Climbing : BEQ .NotClimbing
		STZ !P2Senku
		STZ !P2SenkuUsed
		STZ !P2ShellSpin
		STZ !P2DropKick
		STZ !P2Dashing
		STZ !P2ShellSpeed
		STZ !P2Throw
		.NotClimbing

		PLA
		EOR !P2Blocked
		AND #$04 : BEQ .LandingDone
		LDA !P2Blocked
		AND #$04 : BEQ .LandingDone

	; landing code

		LDA !P2ShellSpin : BEQ .HardLanding	;\
		LDA $15					; | if holding down during shell spin, get smooth landing
		AND #$04 : BNE .LandingDone		;/

		.HardLanding
		LDA #$07 : STA !P2JumpLag
		STZ !P2ShellSpin
		LDA !P2Water : BNE .LandingDone		; can't shell slide underwater
		LDA !P2Slope : BNE +			;\
		LDA !P2XSpeed				; |
		BPL $03 : EOR #$FF : INC A		; |
		CMP #$20 : BCC .LandingDone		; | shell slide check
	+	LDA $15					; |
		AND #$04 : BEQ .LandingDone		; |
		JSR StartSlide				; |
		.LandingDone				;/


	SCREEN_BORDER:			; This might bug with auto-scrollers
		JSL CORE_SCREEN_BORDER


	ATTACK:
		JSR HITBOX


	ANIMATION:
		LDA !P2ExternalAnimTimer : BEQ .ClearExternal	;\
		DEC !P2ExternalAnimTimer			; |
		LDA !P2ExternalAnim : STA !P2Anim		; | enforce external animations
		DEC !P2AnimTimer				; |
		JMP .HandleUpdate				;/

		.ClearExternal
		STZ !P2ExternalAnim

	; pipe check
		LDA !P2Pipe					;\
		ORA !P2SlantPipe				; |
		BEQ .NoPipe					; |
		LDA !P2Anim					; |
		CMP #!Kad_Shell : BCC +				; | pipe animations
		CMP #!Kad_Shell_over : BCC ++			; | (includes slant)
	+	LDA #!Kad_Shell : STA !P2Anim			; |
		STZ !P2AnimTimer				; |
	++	JMP .HandleUpdate				; |
		.NoPipe						;/

	; hurt check
		LDA !P2HurtTimer : BEQ .NoHurt
		LDA #!Kad_Hurt : STA !P2Anim
	-	JMP .HandleUpdate
		.NoHurt

	; carry check
		LDA !P2Carry : BEQ .NoCarry
		LDA !P2InAir : BEQ ..noair
		LDA #!Kad_Carry+2 : BRA +
		..noair
		LDA !P2XSpeed : BNE ..anim
		LDA #!Kad_Carry : BRA +
		..anim
		LDA !P2Anim
		CMP #!Kad_Carry : BCC +++
		CMP #!Kad_Carry_over : BCC ++
	+++	LDA #!Kad_Carry
	+	STA !P2Anim
		STZ !P2AnimTimer
	++	JMP .HandleUpdate
		.NoCarry

	; throw check
		LDA !P2Throw : BEQ .NoThrow
		LDA #!Kad_Throw : STA !P2Anim
		STZ !P2AnimTimer
		JMP .HandleUpdate
		.NoThrow



	; spin check before duck and slide checks
		LDA !P2Anim
		CMP #!Kad_Fall : BNE +
		STZ !P2ShellSpin
	+	LDA !P2ShellSpin
		BEQ $03 : JMP .HandleUpdate

	; slide check
		LDA !P2ShellSlide : BEQ .NoSlide
		LDA !P2Anim
		CMP #!Kad_Shell : BCC +
		CMP #!Kad_Shell_over : BCC ++
	+	LDA #!Kad_Shell : STA !P2Anim
		STZ !P2AnimTimer
	++	JMP .HandleUpdate
		.NoSlide

	; climb check
		LDA !P2Climbing : BEQ .NoClimb
		LDA !P2Anim
		CMP #!Kad_Climb : BCC +
		CMP #!Kad_Climb_over : BCC ++
	+	LDA #!Kad_Climb : STA !P2Anim
		STZ !P2AnimTimer
	++	LDA $15
		AND #$0F : BNE +
		STZ !P2AnimTimer
	+	JMP .HandleUpdate
		.NoClimb

	; duck check
		LDA !P2Ducking : BEQ .NoDuck
		LDA !P2Anim
		CMP #!Kad_Duck : BCC +
		CMP #!Kad_Duck_over : BCC ++
	+	LDA #!Kad_Duck : STA !P2Anim
		STZ !P2AnimTimer
	++	JMP .HandleUpdate
		.NoDuck

	; punch check
		LDA !P2Punch : BEQ .NoPunch
		LDA !P2Anim
		CMP #!Kad_Punch : BCC +
		CMP #!Kad_Punch_over : BCC .ReturnPunch
	+	LDA #!Kad_Punch : STA !P2Anim
		STZ !P2AnimTimer
		.ReturnPunch
		JMP .HandleUpdate
		.NoPunch

	; headbutt check
		LDA !P2Headbutt : BEQ .NoHeadbutt
		LDA !P2Anim
		CMP #!Kad_Headbutt : BCC +
		CMP #!Kad_Headbutt_over : BCC .ReturnHeadbutt
	+	LDA #!Kad_Headbutt : STA !P2Anim
		STZ !P2AnimTimer
		.ReturnHeadbutt
		JMP .HandleUpdate
		.NoHeadbutt

	; senku check
		LDA !P2Senku : BEQ .NoSenku
		CMP #$20 : BCC .Senku
		LDA #!Kad_Walk+3
		STZ !P2AnimTimer
		BRA .SenkuEnd
		.Senku
		LDA #!Kad_Senku
		.SenkuEnd
		STA !P2Anim
		JMP .HandleUpdate
		.NoSenku

	; squat/swim check
		LDA !P2JumpLag : BEQ +
	-	LDA !P2InAir : BEQ ++
		LDA #!Kad_Rise : BRA +++
	++	LDA #!Kad_Squat
	+++	STA !P2Anim
		STZ !P2AnimTimer
		JMP .HandleUpdate
	+	LDA !P2Blocked
		AND #$04
		ORA !P2Platform
		BNE .OnGround
		BIT !P2Water : BVC .NotInWater
		LDA !P2Anim
		CMP #!Kad_Spin : BCC ++			;\ can't cancel spin into swim anim
		CMP #!Kad_Spin_over : BCC +		;/
	++	CMP #!Kad_Swim : BCC .Swim
		CMP #!Kad_Swim_over : BCC +
	.Swim	LDA #!Kad_Swim : STA !P2Anim
		STZ !P2AnimTimer
	+	JMP .HandleUpdate
		.NotInWater

		LDA !P2YSpeed : BMI +
		CMP #$08 : BCC .Fall_set		; > Half-shell frame at 0x00 < speed < 0x08
	;	LDA !P2Anim
	;	CMP #!Kad_Squat : BNE $03 : JMP .HandleUpdate
	;	CMP #!Kad_Shell : BCC .Fall
	;	CMP #!Kad_Shell_over : BCC -

	.Fall	LDA !P2Anim
		CMP #!Kad_Fall : BCC ..set
		CMP #!Kad_Fall_over : BCC ++
	..set	LDA #!Kad_Fall : STA !P2Anim
		STZ !P2AnimTimer
	-
	++	JMP .HandleUpdate
	+	LDA !P2Anim
		CMP #!Kad_Rise : BEQ +
		CMP #!Kad_Fall : BNE ++
	+	JMP .HandleUpdate
	++	BCS +
		CMP #!Kad_Shell : BCS -
	+	LDA #!Kad_Shell : STA !P2Anim
		STZ !P2AnimTimer
		BRA .HandleUpdate

		.OnGround
		LDA $15
		AND #$03
		ORA !P2XSpeed
		BNE .Move

		.Idle
		LDA !P2Anim
		CMP #!Kad_Squat : BEQ .HandleUpdate
		CMP #!Kad_Idle_over : BCC .HandleUpdate
		STZ !P2Anim
		STZ !P2AnimTimer
		BRA .HandleUpdate

		.Move
		LDX !P2BackDash : BNE .Turn		; back dash frame
		LDX !P2Dashing : BEQ .Walk
		BIT !P2Water : BVS .Walk
		ROL #2
		EOR !P2Direction
		LSR A
		BCS .NoTurn
		LDA !P2XSpeed
		BPL $03 : EOR #$FF : INC A
		CMP #$10
		BCC .NoTurn
	.Turn	LDA #!Kad_Turn : STA !P2Anim
		LDA #$2D : STA !SPC1
		JSL CORE_SMOKE_AT_FEET
		BRA .HandleUpdate
		.NoTurn

		.Dash
		LDA !P2Blocked				;\ dash becomes walk if running into a wall
		AND #$03 : BNE .Walk			;/
		LDA !P2Anim
		CMP #!Kad_Dash : BCC +
		CMP #!Kad_Dash_over : BCC .HandleUpdate
	+	LDA #!Kad_Dash : STA !P2Anim
		STZ !P2AnimTimer
		BRA .HandleUpdate

		.Walk
		LDA !P2Anim
		CMP #!Kad_Walk : BCC +
		CMP #!Kad_Walk_over : BCC .HandleUpdate
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
		CMP ANIM+$02,y : BCC .NoUpdate
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
		LDA $14
		AND #$01
		CMP !CurrentPlayer : BEQ .ThisOne

		.OtherOne
		REP #$30
		LDA !P2Anim2
		AND #$00FF
		ASL #3
		TAY
		LDA ANIM+$00,y
		STA $0E
		SEP #$30
		JMP GRAPHICS

		.ThisOne
		REP #$30
		LDA ANIM+$04,y : STA $00


; -- dynamo format --
;
; 1 byte header (size)
; for each upload:
; +00 	cccssss-
; +01	Fccccccc
; +02	ttttt---
;
; ssss:		DMA size (shift left 4)
; cccccccccc:	character (formatted for source address)
; F:		second file flag (when set, file stored at !FileAddress+4 should be used for the rest of the dynamo)
; ttttt:	tile number (shift left 1 then add VRAM offset)

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
		LDA !FileAddress+0
		CLC : ADC $2306
		STA !FileAddress+0
		BRA ..update
		..normalfile
		LDY.w #!File_Kadaal : JSL GetFileAddress
		..update


		LDA $00 : JSL CORE_GENERATE_RAMCODE_24bit

		SEP #$30
		LDA !P2Anim : STA !P2Anim2







	GRAPHICS:
		JSL CORE_FLASHPAL
		LDA !P2HurtTimer : BNE .DrawTiles

		LDA !P2Anim
		CMP #!Kad_SenkuSmash : BCS .DrawTiles
		CMP #!Kad_Spin : BCC +
		CMP #!Kad_Spin_over : BCC .DrawTiles
		+

		.Flash
		LDA !P2Invinc : BEQ .DrawTiles
		LSR #3 : TAX
		LDA.l $00E292,x
		AND !P2Invinc : BEQ OUTPUT_HURTBOX

		.DrawTiles
		LDA $0E : STA $04
		LDA $0F : STA $05
		JSL CORE_LOAD_TILEMAP






	OUTPUT_HURTBOX:

		LDX !P2Carry : BEQ .NoCarry
		LDY !P2Anim
		CPY #!Kad_Carry : BCC .NoCarry
		DEX
		LDA !P2Direction
		BEQ $02 : LDA #$FF
		STA $00
		STZ $01
		BEQ $02 : INC $01
		ASL $01
		LDA .XOffset-(!Kad_Carry),y
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
		CLC : ADC .YOffset-(!Kad_Carry),y
		STA !SpriteYLo,x
		LDA !P2YPosHi
		ADC #$FF
		STA !SpriteYHi,x
		.NoCarry


		REP #$30
		LDA.w #ANIM
		JSL CORE_OUTPUT_HURTBOX
		PLB
		RTL



		.XOffset
		db $04
		db $05
		db $05

		.YOffset
		db $F0
		db $F3
		db $EF


	StartSlide:
		LDA #$01 : STA !P2ShellSlide			;\
		STZ !P2Headbutt					; > clear headbutt
		LDA !P2Slope : BEQ .NoSlope			; |
		BRA .GetDir					; |
		.NoSlope					; |
		LDA !P2XSpeed					; |
		.GetDir						; | set slide
		ROL #2						; |
		AND #$01					; |
		EOR #$01					; |
		STA !P2Direction				; |
	.Return	RTS						;/



;==============;
;HITBOX HANDLER;
;==============;

	HITBOX:

		LDA !P2Punch					;\
		CMP #$04 : BCC +				; | punch timer thresholds
		CMP #$0D : BCC .Punch				;/
	+	LDA !P2Headbutt					;\
		CMP #$14 : BCC +				; |
		CMP #$18 : BCC .Headbutt3			; | headbutt timer thresholds
		CMP #$1E : BCC .Headbutt2			; |
		CMP #$20 : BCC .Headbutt1			; |
		BRA ++						;/
	+	LDA !P2InAir : BEQ ++				;\
		LDA !P2Headbutt : BEQ ++			; |
		STZ !P2Headbutt					; | end headbutt early in midair
		LDA #!Kad_Fall : STA !P2Anim			; |
		STZ !P2AnimTimer				;/
	++	LDA !P2ShellSpin				;\
		BMI .NoSpin					; | check for shell spin
		BNE .Spin					; |
		.NoSpin						;/
	;	LDA !P2SenkuSmash : BNE .Dropkick

		RTS						; return

		.Punch
		LDY #$00 : BRA .Load
		.Headbutt1
		LDY #$02 : BRA .Load
		.Headbutt2
		LDY #$04 : BRA .Load
		.Headbutt3
		LDY #$06 : BRA .Load
		.Spin
		LDY #$08 : BRA .Load
		.Dropkick
		LDY #$0A


		.Load
		REP #$20
		LDA HitboxTable,y : JSL CORE_ATTACK_LoadHitbox
		.Return
		REP #$20
		LDA !P2Hitbox1IndexMem1
		ORA !P2Hitbox2IndexMem1
		STA !P2Hitbox1IndexMem1
		STA !P2Hitbox2IndexMem1
		SEP #$20
		JSL CORE_GET_TILE_Attack			; terrain collision for attack
		RTS

	.Smash
		LDY #$06
		BRA .Spin


	; Hitbox format is Xdisp (lo+hi), Ydisp (lo+hi), width, height.

	HitboxTable:
		dw .Punch
		dw .Headbutt1
		dw .Headbutt2
		dw .Headbutt3
		dw .Spin
		dw .Dropkick

	.Punch
	dw $0008,$FFFA : db $14,$12	; X/Y + W/H
	db $10,$E8			; speeds
	db $12				; timer
	db $05				; hitstun
	db $00,$38			; SFX
	db $00

	.Headbutt1
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

	.Headbutt2
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

	.Headbutt3
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

	.Spin
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

	.Dropkick
	dw $FFF8,$FFF8 : db $20,$20	; X/Y + W/H
	db $10,$E8			; speeds
	db $10				; timer
	db $05				; hitstun
	db $02,$00			; SFX
	db $00




	; Changes:
	;
	; Shell (last frame is second frame but x-flipped), still 16x16
	; Shell $044-$048 -> $040-$044 ($04A is cut)
	; Dash
	;	$07C (32x24)
	;	$0A0 (24x24)
	;	$0A3 (24x24)
	;	$07C (32x24)	REPEATED
	;	$0A6 (24x24)
	;	$0A9 (24x24)	LOOP HERE
	; Punch 1
	;	$10D -> $0D0
	;	$14A -> $0D2
	;	$14D -> $0D5
	; Climb
	;	$148 -> $0D8
	; Spin attack (new)
	;	$046 (24x16)
	;	$049 (24x16)	+ efx
	;	$046 (24x16)	X
	;	$049 (24x16)	X + efx LOOP HERE
	; EFX (new)
	;	$0DA (16x16)


	; Plan:
	;	move dash (08-0B) -> 1A-1F
	;	put spin attack at 08-0B
	;	move punches (28-2B) -> 20-23



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

	; rise
		.Rise
		dw .SquatTM : db $04,!Kad_Shell
		dw .HeadbuttDynamo0
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

	; senku smash
		.SenkuSmash0
		dw .SmashTM0 : db $04,!Kad_SenkuSmash+1
		dw .SenkuSmashDynamo0
		dw .ClippingStandard
		.SenkuSmash1
		dw .SmashTM0 : db $04,!Kad_SenkuSmash+2
		dw .SenkuSmashDynamo1
		dw .ClippingStandard
		.SenkuSmash2
		dw .SmashTM0 : db $04,!Kad_SenkuSmash+3
		dw .SenkuSmashDynamo2
		dw .ClippingStandard
		.SenkuSmash3
		dw .SmashTM0 : db $08,!Kad_SenkuSmash+4
		dw .SenkuSmashDynamo3
		dw .ClippingStandard
		.SenkuSmash4
		dw .SmashTM1 : db $08,!Kad_Fall
		dw .SenkuSmashDynamo4
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



	.IdleTM
	dw $0008
	db $20,$00,$F0,!P1Tile1
	db $20,$00,$00,!P1Tile2

	.WalkTM
	dw $0008
	db $20,$00,$EF,!P1Tile1
	db $20,$00,$FF,!P1Tile2

	.DashTM
	dw $0010
	db $20,$F4,$F8,!P1Tile1
	db $20,$FC,$F8,!P1Tile1+1
	db $20,$F4,$00,!P1Tile3
	db $20,$FC,$00,!P1Tile3+1
	.DashTMU2
	dw $0010
	db $20,$F4,$F6,!P1Tile1
	db $20,$FC,$F6,!P1Tile1+1
	db $20,$F4,$FE,!P1Tile3
	db $20,$FC,$FE,!P1Tile3+1
	.DashTMU3
	dw $0010
	db $20,$F4,$F5,!P1Tile1
	db $20,$FC,$F5,!P1Tile1+1
	db $20,$F4,$FD,!P1Tile3
	db $20,$FC,$FD,!P1Tile3+1

	.TurnTM
	dw $0010
	db $20,$F8,$F8,!P1Tile1
	db $20,$00,$F8,!P1Tile1+1
	db $20,$F8,$00,!P1Tile3
	db $20,$00,$00,!P1Tile3+1

	.SquatTM
	dw $0008
	db $20,$00,$F8,!P1Tile1
	db $20,$00,$00,!P1Tile2

	.ShellTM
	dw $0004
	db $20,$00,$00,!P1Tile1
	.ShellTMX
	dw $0004
	db $60,$00,$00,!P1Tile1

	.PunchTM
	dw $0010
	db $20,$F8,$F0,!P1Tile1
	db $20,$00,$F0,!P1Tile1+1
	db $20,$F8,$00,!P1Tile3
	db $20,$00,$00,!P1Tile3+1

	.HeadbuttTM
	dw $0008
	db $20,$F0,$F8,!P1Tile1
	db $20,$00,$F8,!P1Tile2

	.SpinTM0
	dw $0008
	db $20,$FC,$00,!P1Tile1
	db $20,$04,$00,!P1Tile1+1
	.SpinTM1
	dw $0010
	db $20,$08,$09,!P1Tile6
	db $20,$FC,$00,!P1Tile1
	db $20,$04,$00,!P1Tile1+1
	db $60,$F8,$03,!P1Tile6
	.SpinTM2
	dw $0008
	db $60,$04,$00,!P1Tile1
	db $60,$FC,$00,!P1Tile1+1
	.SpinTM3
	dw $0010
	db $60,$F8,$07,!P1Tile6
	db $60,$04,$00,!P1Tile1
	db $60,$FC,$00,!P1Tile1+1
	db $20,$08,$01,!P1Tile6

	.ClimbTM
	dw $0008
	db $60,$00,$F0,!P1Tile1
	db $60,$00,$00,!P1Tile2

	.SmashTM0
	dw $0010
	db $60,$04,$F8,!P1Tile1
	db $60,$FC,$F8,!P1Tile1+1
	db $60,$04,$00,!P1Tile3
	db $60,$FC,$00,!P1Tile3+1
	.SmashTM1
	dw $0008
	db $60,$00,$F0,!P1Tile1
	db $60,$00,$00,!P1Tile2

	.CarryWalkTM0
	dw $0010
	db $20,$FF,$F0,!P1Tile1
	db $20,$07,$F0,!P1Tile1+1
	db $20,$FF,$00,!P1Tile3
	db $20,$07,$00,!P1Tile3+1
	.CarryWalkTM1
	dw $0010
	db $20,$FE,$EE,!P1Tile1
	db $20,$06,$EE,!P1Tile1+1
	db $20,$FE,$FE,!P1Tile3
	db $20,$06,$FE,!P1Tile3+1



macro KadDyn(TileCount, TileNumber, Dest)
	db (<TileCount>*2)|((<TileNumber>&$07)<<5)
	db (<TileNumber>>>3)&$7F
	db <Dest>*8
endmacro



	; idle
		.IdleDynamo0
		db ..end-..start
		..start
		%KadDyn(2, $000, !P1Tile1)
		%KadDyn(2, $010, !P1Tile1+$10)
		%KadDyn(2, $020, !P1Tile2)
		%KadDyn(2, $030, !P1Tile2+$10)
		..end
		.IdleDynamo1
		db ..end-..start
		..start
		%KadDyn(2, $002, !P1Tile1)
		%KadDyn(2, $012, !P1Tile1+$10)
		%KadDyn(2, $022, !P1Tile2)
		%KadDyn(2, $032, !P1Tile2+$10)
		..end
		.IdleDynamo2
		db ..end-..start
		..start
		%KadDyn(2, $004, !P1Tile1)
		%KadDyn(2, $014, !P1Tile1+$10)
		%KadDyn(2, $024, !P1Tile2)
		%KadDyn(2, $034, !P1Tile2+$10)
		..end
		.IdleDynamo3
		db ..end-..start
		..start
		%KadDyn(2, $006, !P1Tile1)
		%KadDyn(2, $016, !P1Tile1+$10)
		%KadDyn(2, $026, !P1Tile2)
		%KadDyn(2, $036, !P1Tile2+$10)
		..end

	; walk
		.WalkDynamo0
		db ..end-..start
		..start
		%KadDyn(2, $008, !P1Tile1)
		%KadDyn(2, $018, !P1Tile1+$10)
		%KadDyn(2, $028, !P1Tile2)
		%KadDyn(2, $038, !P1Tile2+$10)
		..end
		.WalkDynamo1
		db ..end-..start
		..start
		%KadDyn(2, $00A, !P1Tile1)
		%KadDyn(2, $01A, !P1Tile1+$10)
		%KadDyn(2, $02A, !P1Tile2)
		%KadDyn(2, $03A, !P1Tile2+$10)
		..end
		.WalkDynamo2
		db ..end-..start
		..start
		%KadDyn(2, $00C, !P1Tile1)
		%KadDyn(2, $01C, !P1Tile1+$10)
		%KadDyn(2, $02C, !P1Tile2)
		%KadDyn(2, $03C, !P1Tile2+$10)
		..end
		.WalkDynamo3
		db ..end-..start
		..start
		%KadDyn(2, $00E, !P1Tile1)
		%KadDyn(2, $01E, !P1Tile1+$10)
		%KadDyn(2, $02E, !P1Tile2)
		%KadDyn(2, $03E, !P1Tile2+$10)
		..end

	; dash
		.DashDynamo0				; Used by frames 0, 3
		db ..end-..start
		..start
		%KadDyn(3, $083, !P1Tile1)
		%KadDyn(3, $093, !P1Tile1+$10)
		%KadDyn(3, $093, !P1Tile3)
		%KadDyn(3, $0A3, !P1Tile3+$10)
		..end
		.DashDynamo1				; Used by frame 1
		db ..end-..start
		..start
		%KadDyn(3, $086, !P1Tile1)
		%KadDyn(3, $096, !P1Tile1+$10)
		%KadDyn(3, $096, !P1Tile3)
		%KadDyn(3, $0A6, !P1Tile3+$10)
		..end
		.DashDynamo2				; Used by frame 2
		db ..end-..start
		..start
		%KadDyn(3, $089, !P1Tile1)
		%KadDyn(3, $099, !P1Tile1+$10)
		%KadDyn(3, $099, !P1Tile3)
		%KadDyn(3, $0A9, !P1Tile3+$10)
		..end
		.DashDynamo3				; Used by frame 4
		db ..end-..start
		..start
		%KadDyn(3, $0B0, !P1Tile1)
		%KadDyn(3, $0C0, !P1Tile1+$10)
		%KadDyn(3, $0C0, !P1Tile3)
		%KadDyn(3, $0D0, !P1Tile3+$10)
		..end
		.DashDynamo4				; Used by frame 5
		db ..end-..start
		..start
		%KadDyn(3, $0B3, !P1Tile1)
		%KadDyn(3, $0C3, !P1Tile1+$10)
		%KadDyn(3, $0C3, !P1Tile3)
		%KadDyn(3, $0D3, !P1Tile3+$10)
		..end

	; squat
		.SquatDynamo				; Also used by .Duck0
		db ..end-..start
		..start
		%KadDyn(2, $08E, !P1Tile1)
		%KadDyn(2, $09E, !P1Tile1+$10)
		%KadDyn(2, $09E, !P1Tile2)
		%KadDyn(2, $0AE, !P1Tile2+$10)
		..end


	; shell
		.ShellDynamo0				; Also used by .Duck1
		db ..end-..start
		..start
		%KadDyn(2, $0BA, !P1Tile1)
		%KadDyn(2, $0CA, !P1Tile1+$10)
		..end
		.ShellDynamo1
		db ..end-..start
		..start
		%KadDyn(2, $0BC, !P1Tile1)
		%KadDyn(2, $0CC, !P1Tile1+$10)
		..end
		.ShellDynamo2
		db ..end-..start
		..start
		%KadDyn(2, $0BE, !P1Tile1)
		%KadDyn(2, $0CE, !P1Tile1+$10)
		..end

	; fall
		.FallDynamo0
		db ..end-..start
		..start
		%KadDyn(2, $04A, !P1Tile1)
		%KadDyn(2, $05A, !P1Tile1+$10)
		%KadDyn(2, $06A, !P1Tile2)
		%KadDyn(2, $07A, !P1Tile2+$10)
		..end
		.FallDynamo1
		db ..end-..start
		..start
		%KadDyn(2, $04C, !P1Tile1)
		%KadDyn(2, $05C, !P1Tile1+$10)
		%KadDyn(2, $06C, !P1Tile2)
		%KadDyn(2, $07C, !P1Tile2+$10)
		..end

	; turn
		.TurnDynamo
		db ..end-..start
		..start
		%KadDyn(4, $080, !P1Tile1)
		%KadDyn(4, $090, !P1Tile1+$10)
		%KadDyn(4, $090, !P1Tile3)
		%KadDyn(4, $0A0, !P1Tile3+$10)
		..end

	; senku
		.SenkuDynamo
		db ..end-..start
		..start
		%KadDyn(2, $048, !P1Tile1)
		%KadDyn(2, $058, !P1Tile1+$10)
		%KadDyn(2, $068, !P1Tile2)
		%KadDyn(2, $078, !P1Tile2+$10)
		..end

	; punch
		.PunchDynamo0
		.PunchDynamo3
		db ..end-..start
		..start
		%KadDyn(2, $046, !P1Tile1)
		%KadDyn(2, $056, !P1Tile1+$10)
		%KadDyn(2, $066, !P1Tile2)
		%KadDyn(2, $076, !P1Tile2+$10)
		..end
		.PunchDynamo1
		db ..end-..start
		..start
		%KadDyn(3, $040, !P1Tile1)
		%KadDyn(3, $050, !P1Tile1+$10)
		%KadDyn(3, $060, !P1Tile3)
		%KadDyn(3, $070, !P1Tile3+$10)
		..end
		.PunchDynamo2
		db ..end-..start
		..start
		%KadDyn(3, $043, !P1Tile1)
		%KadDyn(3, $053, !P1Tile1+$10)
		%KadDyn(3, $063, !P1Tile3)
		%KadDyn(3, $073, !P1Tile3+$10)
		..end

	; hurt
		.HurtDynamo
		db ..end-..start
		..start
		%KadDyn(2, $04E, !P1Tile1)
		%KadDyn(2, $05E, !P1Tile1+$10)
		%KadDyn(2, $06E, !P1Tile2)
		%KadDyn(2, $07E, !P1Tile2+$10)
		..end

	; dead
		.DeadDynamo
		db ..end-..start
		..start
		%KadDyn(2, $11A, !P1Tile1)
		%KadDyn(2, $12A, !P1Tile1+$10)
		%KadDyn(2, $13A, !P1Tile2)
		%KadDyn(2, $14A, !P1Tile2+$10)
		..end

	; spin
		.SpinDynamo0
		db ..end-..start
		..start
		%KadDyn(3, $120, !P1Tile1)
		%KadDyn(3, $130, !P1Tile1+$10)
		..end
		.SpinDynamo1
		db ..end-..start
		..start
		%KadDyn(3, $123, !P1Tile1)
		%KadDyn(3, $133, !P1Tile1+$10)
		..end

	; climb
		.ClimbDynamo				; Used by both frames
		db ..end-..start
		..start
		%KadDyn(2, $116, !P1Tile1)
		%KadDyn(2, $126, !P1Tile1+$10)
		%KadDyn(2, $136, !P1Tile2)
		%KadDyn(2, $146, !P1Tile2+$10)
		..end

	; senku smash
		.SenkuSmashDynamo0
		db ..end-..start
		..start
		%KadDyn(3, $110, !P1Tile1)
		%KadDyn(3, $120, !P1Tile1+$10)
		%KadDyn(3, $120, !P1Tile3)
		%KadDyn(3, $130, !P1Tile3+$10)
		..end
		.SenkuSmashDynamo1
		db ..end-..start
		..start
		%KadDyn(3, $113, !P1Tile1)
		%KadDyn(3, $123, !P1Tile1+$10)
		%KadDyn(3, $123, !P1Tile3)
		%KadDyn(3, $133, !P1Tile3+$10)
		..end
		.SenkuSmashDynamo2
		db ..end-..start
		..start
		%KadDyn(3, $116, !P1Tile1)
		%KadDyn(3, $126, !P1Tile1+$10)
		%KadDyn(3, $126, !P1Tile3)
		%KadDyn(3, $136, !P1Tile3+$10)
		..end
		.SenkuSmashDynamo3
		db ..end-..start
		..start
		%KadDyn(3, $119, !P1Tile1)
		%KadDyn(3, $129, !P1Tile1+$10)
		%KadDyn(3, $129, !P1Tile3)
		%KadDyn(3, $139, !P1Tile3+$10)
		..end
		.SenkuSmashDynamo4
		db ..end-..start
		..start
		%KadDyn(2, $11C, !P1Tile1)
		%KadDyn(2, $12C, !P1Tile1+$10)
		%KadDyn(2, $13C, !P1Tile2)
		%KadDyn(2, $14C, !P1Tile2+$10)
		..end

	; shell drill init
		.ShellDrillDynamoInit
		db ..end-..start
		..start
		%KadDyn(3, $119, !P1Tile1)
		%KadDyn(3, $129, !P1Tile1+$10)
		%KadDyn(3, $129, !P1Tile3)
		%KadDyn(3, $139, !P1Tile3+$10)
		%KadDyn(2, $0DA, !P1Tile7)
		%KadDyn(2, $0EA, !P1Tile7+$10)
		..end

	; swim
		.SwimDynamo0
		db ..end-..start
		..start
		%KadDyn(2, $00C, !P1Tile1)
		%KadDyn(2, $00E, !P1Tile1+$10)
		..end
		.SwimDynamo1
		db ..end-..start
		..start
		%KadDyn(2, $008, !P1Tile1)
		%KadDyn(2, $00A, !P1Tile1+$10)
		..end
		.SwimDynamo2
		db ..end-..start
		..start
		%KadDyn(2, $004, !P1Tile1)
		%KadDyn(2, $006, !P1Tile1+$10)
		..end
		.SwimDynamo3
		db ..end-..start
		..start
		%KadDyn(2, $000, !P1Tile1)
		%KadDyn(2, $002, !P1Tile1+$10)
		..end

	; dash attck
		.HeadbuttDynamo0
		db ..end-..start
		..start
		%KadDyn(2, $08C, !P1Tile1)
		%KadDyn(2, $09C, !P1Tile1+$10)
		%KadDyn(2, $09C, !P1Tile2)
		%KadDyn(2, $0AC, !P1Tile2+$10)
		..end
		.HeadbuttDynamo1
		db ..end-..start
		..start
		%KadDyn(4, $0B6, !P1Tile1)
		%KadDyn(4, $0C6, !P1Tile1+$10)
		..end

	; carry
		.CarryDynamo0
		db ..end-..start
		..start
		%KadDyn(2, $11C, !P1Tile1)
		%KadDyn(2, $12C, !P1Tile1+$10)
		%KadDyn(2, $13C, !P1Tile2)
		%KadDyn(2, $14C, !P1Tile2+$10)
		..end
		.CarryDynamo1
		db ..end-..start
		..start
		%KadDyn(3, $160, !P1Tile1)
		%KadDyn(3, $170, !P1Tile1+$10)
		%KadDyn(3, $180, !P1Tile3)
		%KadDyn(3, $190, !P1Tile3+$10)
		..end
		.CarryDynamo2
		db ..end-..start
		..start
		%KadDyn(3, $163, !P1Tile1)
		%KadDyn(3, $173, !P1Tile1+$10)
		%KadDyn(3, $183, !P1Tile3)
		%KadDyn(3, $193, !P1Tile3+$10)
		..end

	; throw
		.ThrowDynamo
		db ..end-..start
		..start
		%KadDyn(3, $166, !P1Tile1)
		%KadDyn(3, $176, !P1Tile1+$10)
		%KadDyn(3, $186, !P1Tile3)
		%KadDyn(3, $196, !P1Tile3+$10)
		..end

	; victory
		.VictoryDynamo
		db ..end-..start
		..start
		%KadDyn(2, $118, !P1Tile1)
		%KadDyn(2, $128, !P1Tile1+$10)
		%KadDyn(2, $138, !P1Tile2)
		%KadDyn(2, $148, !P1Tile2+$10)
		..end


	.ClippingStandard
	; X
	db $0E,$01,$0E,$01		; R/L/R/L
	db $04,$0B,$08,$08		; D/D/U/C
	; Y
	db $FF,$FF,$0A,$0A		; R/L/R/L
	db $10,$10,$F8,$02		; D/D/U/C
	; hurtbox
	dw $0001,$FFF8			; X/Y
	db $0D,$17			; W/H

	.ClippingDash
	; X
	db $0E,$01,$0E,$01		; R/L/R/L
	db $04,$0B,$08,$08		; D/D/U/C
	; Y
	db $FF,$FF,$0A,$0A		; R/L/R/L
	db $10,$10,$F8,$02		; D/D/U/C
	; hurtbox
	dw $0006,$FFFE			; X/Y
	db $13,$11			; W/H

	.ClippingShell
	; X
	db $0E,$01,$0E,$01		; R/L/R/L
	db $04,$0B,$08,$08		; D/D/U/C
	; Y
	db $06,$06,$0A,$0A		; R/L/R/L
	db $10,$10,$00,$08		; D/D/U/C
	; hurtbox
	dw $0001,$0000			; X/Y
	db $0D,$0F			; W/H



.End
print "  Anim data: $", hex(.End-ANIM), " bytes"
print "  - sequence data: $", hex(.IdleTM-ANIM), " bytes (", dec((.IdleTM-ANIM)*100/(.End-ANIM)), "%)"
print "  - tilemap data:  $", hex(.IdleDynamo0-.IdleTM), " bytes (", dec((.IdleDynamo0-.IdleTM)*100/(.End-ANIM)), "%)"
print "  - dynamo data:   $", hex(.ClippingStandard-.IdleDynamo0), " bytes (", dec((.ClippingStandard-.IdleDynamo0)*100/(.End-ANIM)), "%)"
print "  - clipping data: $", hex(.End-.ClippingStandard), " bytes (", dec((.End-.ClippingStandard)*100/(.End-ANIM)), "%)"






namespace off
















