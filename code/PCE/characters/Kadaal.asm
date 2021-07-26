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
;	bit 0	senku smash
;	bit 1	directional senku
;	bit 2	air senku
;	bit 3	shadow step
;	bit 4	fancy footwork (backdash/pivot)
;	bit 5	sturdy shell
;	bit 6	---- ????
;	bit 7	ultimate: shun koopa satsu



	MAINCODE:
		PHB : PHK : PLB

		LDA #$02 : STA !P2Character
		LDA #$02 : STA !P2MaxHP
		LDA !KadaalUpgrades		;\
		AND #$20			; | +1 Max HP with upgrade
		BEQ $03 : INC !P2MaxHP		;/


		LDA !P2Status : BEQ .Process
		CMP #$01 : BEQ .KnockedOut

		.Snap
		REP #$20
		LDA $94 : STA !P2XPosLo
		LDA $96 : STA !P2YPosLo
		SEP #$20
		PLB
		RTS

		.KnockedOut			; State 01
		JSL CORE_KNOCKED_OUT
		BMI .Fall
		BCC .Fall
		LDA #$02 : STA !P2Status
		PLB
		RTS

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


		.Process				; State 00
		LDA !P2MaxHP				;\
		CMP !P2HP				; | Enforce max HP
		BCS $03 : STA !P2HP			;/

		REP #$20						;\
		LDA !P2Hitbox2IndexMem1 : TSB !P2Hitbox1IndexMem1	; | merge index mem for hitboxes
		SEP #$20						;/

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
		EOR #$01				; |
		INC A					; | force forward input during headbutt
		TSB $6DA3				; |
		EOR #$03				; |
		TRB $6DA3				; |
		.NoHeadbutt				;/


		LDA $6DA7				;\
		AND #$03 : BEQ .NoPunchDashCancel	; |
		CMP #$03 : BEQ .NoPunchDashCancel	; | end punch on left/right press
		STZ !P2Punch				; |
		.NoPunchDashCancel			;/


		LDA !P2InAir : BNE .NoForceCrouch	;\
		JSL CORE_CHECK_ABOVE			; |
		BCC .NoForceCrouch			; | force down input if kadaal is on ground with a solid block above
		LDA #$04 : TSB $6DA3			; |
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

		LDA !P2HurtTimer : BEQ $03 : JMP .Friction

		LDA !P2Climbing : BEQ $03 : JMP .NoDuck

		LDA !P2Blocked
		AND #$04
		ORA !P2Platform
		ORA !P2SpritePlatform
		BNE ..Ground
		LDA !P2ShellSlide : BNE .ShellSlide	; maintain shell slide in midair
		JMP .NoGround

	..Ground
;		LDA !P2BackDash
;		CMP #$08 : BCC ..BackDash
;		BRA ..NoDir

	..BackDash
;		LDA $6DA9
;		AND #$30 : BEQ .NoBackDash
;		AND #$10 : BEQ +
;		LDA !P2Direction			; R is perfect pivot
;		INC A
;		TSB $6DA3
;		EOR #$03
;		TRB $6DA3
;	+	LDA #$10 : STA !P2BackDash
;		LDA $6DA3
;		AND #$03 : BEQ +
;		CMP #$03 : BEQ +
;		DEC A
;		EOR #$01
;		STA !P2Direction
;		BRA ++
;	+	LDA !P2Direction
;	++	EOR #$01
;		TAY
;		LDA .XSpeedSenku,y : JSL CORE_SET_XSPEED
;		LDA #$2D : STA !SPC1			; slide SFX
;		STZ !P2Punch1
;		STZ !P2Punch2
;		STZ !P2Senku
;	..NoDir	LDA #$0F				;\
;		TRB $6DA3				; | clear directionals during back dash
;		TRB $6DA7				;/
;		LDA #$01 : STA !P2Dashing
		.NoBackDash


	;	LDA !P2ShellDrill : BEQ .NoPound		;\
	;	STZ !P2ShellDrill				; |
	;	JSR .StartSpin					; | shell drill landing
	;	LDA #$09 : STA !SPC4				; > smash SFX
	;	LDA #$17 : STA !P2JumpLag			; |
	;	LDA #!Kad_DrillLand : STA !P2Anim		; |
	;	RTS						; |
	;	.NoPound					;/


	;	LDA !P2Anim					;\
	;	CMP #!Kad_DrillLand : BCC .NoDrillLand		; | force crouch physics during drill land
	;	JMP .ForceCrouch				; |
	;	.NoDrillLand					;/


		.ShellSlide					;\
		LDA $6DA3					; |
		AND #$04 : BNE +				; |
		LDA !P2ShellSlide : BEQ ++			; |
		LDA #$01 : STA !P2Dashing			; > shell slide can be canceled into a dash
	++	STZ !P2ShellSlide				; |
		STZ !P2ShellSpeed				; |
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
		LDA !P2XSpeed					; |
		SEC : SBC .XSpeedSenku,y			; |
		INC A						; |
		CMP #$03 : BCC +				; |
		LDA !P2XSpeed					; |
		CLC : ADC .ShellSlideAcc,y			; |
		BRA ++						; |
	+	LDA .XSpeedSenku,y				; |
	++	JSL CORE_SET_XSPEED				; |
		LDA #$01 : STA !P2ShellSpeed			; |
		LDA #$03					; |
		TRB $6DA3					; |
		TRB $6DA7					; |
	-	JMP .NoDuck					; |
		.NoGround					;/

		LDA !P2Senku : BEQ +
		CMP #$20 : BCC -
	+	LDA !P2Blocked
		LDY !P2Platform
		BEQ $02 : ORA #$04
		AND $6DA3
		AND #$04 : BEQ .NoDuck
		BIT $6DA7
		BPL $03 : JMP .SenkuJump
		LDA !P2Senku : BEQ +			;\
		LDA $6DA7				; | must press (not hold) down to cancel senku (this allows senku out of shell slide)
		AND #$04 : BEQ .NoDuck			; |
		+					;/

		LDA !P2Headbutt				;\ can cancel ending of headbutt into headbutt
		CMP #$11 : BCS .NoDuck			;/
		LDA !P2Water : BNE .ForceCrouch		; can't shell slide underwater
	;	LDA !KadaalUpgrades			;\
	;	AND #$08 : BEQ .ForceCrouch		; > no more upgrade requirement for shell slide
		LDA !P2Slope : BNE +			; > always start sliding on slopes
		LDA !P2XSpeed				; |
		BPL $03 : EOR #$FF : INC A		; | start shell slide with enough speed
		CMP #$20 : BCC .ForceCrouch		; |
	+	JSR StartSlide				; |
		JMP .Friction				;/ > skip remaining inputs this frame


	.ForceCrouch
		LDA #$00 : JSL CORE_SET_XSPEED
		LDA #$01 : STA !P2Ducking
		LDA #$04 : STA !P2JumpLag
		STZ !P2Punch
		STZ !P2Headbutt
		STZ !P2Dashing
		STZ !P2Senku
	.GSpin	LDA !P2ShellSpin : BNE .SpinR		;\
	;	LDA !KadaalUpgrades			; |
	;	AND #$40 : BEQ .SpinR			; |
		BIT $6DA7 : BVC .SpinR			; | ground spin
		.StartSpin				; > JSR here to start spin
		LDA #$10 : STA !P2ShellSpin		; |
		LDA #!Kad_Spin : STA !P2Anim		; |
		LDA #$3E : STA !SPC4			; | > spin SFX
		LDA #$40 : TRB $6DA7
		TRB $6DA3
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
		BNE .NoInitSenku			;\ Set invulnerability timer
		STA !P2Invinc				;/
		LDA !KadaalUpgrades			;\
		AND #$02 : BEQ ..Basic			; | Store all-range senku direction if upgrade is attained
		LDA $6DA3				; |
		AND #$0F : STA !P2AllRangeSenku		;/
		..Basic
		LDA $6DA3
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
	..Write	JSL CORE_SET_XSPEED
		STZ !P2JumpLag
		STZ !P2DashTimerR1
		STZ !P2DashTimerL1
		STZ !P2Buffer
		STZ !P2Climbing
		LDA !P2Senku
		CMP #$20 : BCS +
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
		BIT $6DA7
		BPL $06 : STZ !P2Invinc : JMP .SenkuJump
	+	RTS

		.InitSenku
		LDA !P2SenkuUsed : BNE .NoSenku
		LDA !KadaalUpgrades				;\
		ORA !P2Blocked					; | air senku is only allowed with proper upgrade
		AND #$04					; |
		BEQ .NoSenku					;/

		BIT $6DA9 : BPL .NoSenku
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
		LDA #$01 : STA !P2SenkuUsed
		STZ !P2ShellDrill
		RTS
		.NoSenku


		LDA !P2Climbing : BEQ .NoClimb			; Check for vine/net climb
		STZ !P2ShellSlide
		LDA $6DA3
		LSR A : BCC +
		LDA #$01 : STA !P2Direction
		BRA ++
	+	LSR A : BCC ++
		STZ !P2Direction
	++	BIT $6DA7 : BPL +
		STZ !P2Climbing					; vine/net jump
		LDA #$B8 : STA !P2YSpeed
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
		BIT $6DA7 : BPL ..nojump
		JMP .SenkuJump
		..nojump

		LDA $6DA3					;\
		AND #$0F					; | Swim speed index
		TAY						;/
		LDA !P2YSpeed					;\
		CMP .AllRangeSpeedY,y				; |
		BEQ +						; | Swimming Y speed
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
		LDA $6DA3					;\
		AND #$03					; |
		TAY						; | underwater dir
		LDA .SwimDir,y : BMI .NoSwimDir			; |
		STA !P2Direction				; |
		.NoSwimDir					;/
		LDA $6DA3
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
		BEQ +						; | Swimming X speed
		BPL $04 : INC #4				; |
		DEC #2						; |
		STA !P2XSpeed					; |
		+						;/
		BPL $02 : EOR #$FF				;\ Store absolute X speed
		STA $00						;/
		LDA !P2YSpeed					;\
		BPL $02 : EOR #$FF				; | Do animation if there is speed
		CLC : ADC $00					; |
		BNE +						;/
		LDA !P2ShellSpin : BNE ++			; always animate spin at 50% rate
		STZ !P2AnimTimer				;\ Otherewise no animation
		BRA +++						;/
	+	CMP #$20					;\ Animate at 100% rate if |X|+|Y|>0x1F
		BCS +++						;/
	++	LDA $14						;\
		LSR A						; | Animate at 50% rate
		BCC +++						; |
		DEC !P2AnimTimer				;/
	+++	STZ !P2SenkuUsed				; > No animation
		LDA $14						;\ only spawn every 128 frames
		AND #$7F : BNE .NoWater				;/
		%Ex_Index_X_fast()				;\
		LDA #$12+!ExtendedOffset : STA !Ex_Num,x	; |
		LDA !P2YPosLo					; |
		SEC : SBC #$08					; |
		STA !Ex_YLo,x					; |
		LDA !P2YPosHi					; |
		SBC #$00					; | spawn bubble
		STA !Ex_YHi,x					; |
		LDY !P2Direction				; |
		LDA .BubbleX,y					; |
		CLC : ADC !P2XPosLo				; |
		STA !Ex_XLo,x					; |
		LDA !P2XPosHi					; |
		ADC #$00					; |
		STA !Ex_XHi,x					;/
		.NoWater

		LDA !P2ShellSlide : BNE ..Skip			; can't punch during shell slide
		BIT !P2Buffer : BVS +				; skip regular input if buffered
		BIT $6DA7
		BVS $03
	..Skip	JMP .NoPunch
	+	STZ !P2BackDash					; > clear back dash when an attack is started
		LDA !P2ShellSpin : BEQ +			; see if a spin is happening already
;		LDA !KadaalUpgrades				;\
;		AND #$10 : BEQ ..NoC				; | kadaal can cancel spin into drill
;		LDA $6DA3					; |
;		AND #$04 : BNE .StartSpin_Drill			;/
	..NoC	LDA #$40 : STA !P2Buffer			;\ don't change buffer here if spin is active
		JMP .NoPunch					;/
	+	;LDA !P2Anim					;\ can't start spin or shell drill during smash
		;CMP #$28 : BCC $03 : JMP .NoPunch		;/
		LDA !P2Blocked
		AND #$04
		ORA !P2Platform
		BEQ .AirSpin
		BRA .NoSpin

		.AirSpin
	;	LDA !KadaalUpgrades
	;	AND #$10 : BEQ ..Spin
	;	LDA $6DA3
	;	AND #$04 : BEQ ..Spin
	;..Drill	LDA #$01 : STA !P2ShellDrill			; start shell drill
	;	STZ !P2ShellSpin				; cancel shell spin
	;	LDA #!Kad_ShellDrill : STA !P2Anim
	;	STZ !P2AnimTimer
	;	STZ !P2ShellSlide
	;	STZ !P2ShellSpeed
	;	BRA .NoPunch

	..Spin	LDA #$10 : STA !P2ShellSpin
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
		LDA $6DA3					;\
		AND #$03 : BEQ .Punch				; |
		CMP #$03 : BEQ .Punch				; | headbutt req 2: must hold same direction as moving
		DEC A						; |
		ROR #2						; |
		EOR !P2XSpeed : BMI .Punch			;/
		.Headbutt
		LDA #$23 : STA !P2Headbutt
		STZ !P2Punch
		LDA #$2D : STA !SPC1				; headbutt init SFX
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
;		LDA $6DA7					; |
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
		BIT $6DA7 : BPL $05				; | allow jump buffer from land lag
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
	;	BIT $6DA3 : BMI .NoJump		; |
	;	STZ !P2Floatiness		; | stop ascent if player lets go of B
	;	BIT !P2YSpeed : BPL .NoJump	; |
	;	LDA !P2YSpeed			; |
	;	CLC : ADC #$20			; |
	;	BMI $02 : LDA #$00		; |
	;	STA !P2YSpeed			; |
	;	BRA .NoJump			;/

		.InitJump
		LDA !P2Buffer
		ORA $6DA7
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
	;	LDA #$80 : STA !P2Buffer			; |
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
		AND $6DA3 : BEQ .NoDashCancel
		BRA ++

	+	LDA $6DA3
		AND #$03 : BEQ ++
		CMP #$03 : BNE .NoDashCancel		; end dash if pressing left and right at the same time
	++	STZ !P2Dashing
		.NoDashCancel

		LDA !P2Blocked
		AND #$04
		ORA !P2Platform
		BEQ +
		LDA $6DA7
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
		LDA $6DA3
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
		LDA $6DA3
		LSR A : BCS .Right
		LSR A : BCS .Left
		LDA $00
		BEQ ++

		.Friction			; This code definitely only runs on the ground
		LDA !P2ShellSlide : BNE ++	;\ Clear shell speed upon touching the ground without shell slide
		STZ !P2ShellSpeed		;/
		++


		LDA !P2Slope
		CLC : ADC #$04
		TAX
		LDA !P2XSpeed
		SEC : SBC .SlopeSpeed,x
		BEQ +
		BMI .StopLeft
		.StopRight
		DEC A
		BEQ $01 : DEC A
		BRA ++
		.StopLeft
		INC A
		BEQ $01 : INC A
	++	CLC : ADC .SlopeSpeed,x
		JSL CORE_SET_XSPEED
	+	RTS

		.Right
		LDA !P2ShellSpeed : BNE $07	; shell speed flag has priority over lacking dash flag
		LDA !P2DashTimerR1
		BEQ $02 : LDX #$00
		LDA !P2XSpeed : BMI +
		LDY $00 : BNE +++		;\ don't turn abruptly in mid-air
		CMP .XSpeedRight,x : BCC +	;/
	+++	LDA .XSpeedRight,x
		BRA ++
	+	INC #3
	++	JSL CORE_SET_XSPEED
		LDA #$01 : STA !P2Direction
		RTS

		.Left
		LDA !P2ShellSpeed : BNE $07	; shell speed flag has priority over lacking dash flag
		LDA !P2DashTimerL1
		BEQ $02 : LDX #$00
		LDA !P2XSpeed
		BEQ +
		BPL +
	++	LDY $00 : BNE +++		;\
		CMP .XSpeedLeft,x		; | don't turn abruptly in mid-air
		BEQ ++				; |
		BCS +				;/
	+++	LDA .XSpeedLeft,x
		BRA ++
	+	DEC #3
	++	JSL CORE_SET_XSPEED
		STZ !P2Direction
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


	PHYSICS:
		PLA
		BMI $03 : STA !P2Direction


;	.SenkuSmash			; This has to be before sprite interaction so custom sprites can set the flag
;		LDA !KadaalUpgrades
;		LSR A : BCC ..Return
;		LDA !P2Senku : BEQ ..Return
;		LDA !P2SenkuSmash : BEQ ..Return
;		BIT $6DA7 : BVC ..Return
;		LDA #!Kad_SenkuSmash : STA !P2Anim
;		STZ !P2AnimTimer
;		LDA #$A0 : STA !P2YSpeed
;		LDA #$1C : STA !P2Invinc
;		STZ !P2Senku
;		LDA #$02 : STA !SPC1			; SFX
;		LDA !P2Direction
;		EOR #$01
;		STA !P2Direction
;		ASL #2
;		INC A
;		TAY
;		LDA CONTROLS_XSpeed,y : STA !P2XSpeed
;		STZ !P2SenkuUsed
;		PEA .Collisions-1
;		JMP HITBOX_Smash
;		..Return


		LDA !P2SlantPipe : BEQ +
		LDA #$40 : STA !P2XSpeed
		LDA #$C0 : STA !P2YSpeed
		+

	.Collisions
		LDA !P2Blocked
		AND #$04
		ORA !P2Platform
		BNE .OnGround
		LDA !P2XSpeed : BEQ .NoWall
		CLC : ROL #2
		INC A				; 1 = right, 2 = left
		AND !P2Blocked
		BEQ .NoWall
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


	EXSPRITE_INTERACTION:
		JSL CORE_EXSPRITE_INTERACTION


	UPDATE_SPEED:
		LDA #$03				; gravity when holding B is 3
		BIT $6DA3				;\ gravity without holding B is 6
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
		STZ !P2ShellDrill
		STZ !P2Dashing
		STZ !P2ShellSpeed
		.NotClimbing

		PLA
		EOR !P2Blocked
		AND #$04 : BEQ .LandingDone
		LDA !P2Blocked
		AND #$04 : BEQ .LandingDone

	; landing code

		LDA !P2ShellSpin : BEQ .HardLanding	;\
		LDA $6DA3				; | if holding down during shell spin, get smooth landing
		AND #$04 : BNE .LandingDone		;/

		.HardLanding
		LDA #$07 : STA !P2JumpLag
		STZ !P2ShellSpin
		LDA !P2Water : BNE .LandingDone		; can't shell slide underwater
	;	LDA !KadaalUpgrades			;\
	;	AND #$08 : BEQ +			; |
		LDA !P2Slope : BNE +
		LDA !P2XSpeed				; |
		BPL $03 : EOR #$FF : INC A		; |
		CMP #$20 : BCC .LandingDone		; | allow shell slide with upgrade
	+	LDA $6DA3				; |
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
		LDA !P2Pipe : BEQ .NoPipe			;\
		LDA !P2Anim					; |
		CMP #!Kad_Shell : BCC +				; |
		CMP #!Kad_Shell_over : BCC ++			; | pipe animations
	+	LDA #!Kad_Shell : STA !P2Anim			; |
		STZ !P2AnimTimer				; |
	++	JMP .HandleUpdate				; |
		.NoPipe						;/

	; hurt check
		LDA !P2HurtTimer : BEQ .NoHurt
		LDA #!Kad_Hurt : STA !P2Anim
	-	JMP .HandleUpdate
		.NoHurt

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
	++	LDA $6DA3
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

	; senku smash check
		LDA !P2Anim
		CMP #!Kad_SenkuSmash : BCC $03 : JMP .HandleUpdate

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
		ORA !P2SpritePlatform
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
		LDA $6DA3
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
; 	cccssss-
; 	-ccccccc
; 	ttttt---
;
; ssss:		DMA size (shift left 4)
; cccccccccc:	character (formatted for source address)
; ttttt:	tile number (shift left 1 then add VRAM offset)

		LDY.w #!File_Kadaal
		JSL !GetFileAddress

		SEP #$20
		STZ $2250
		LDA !P2Anim
		CMP.b #!Kad_Swim : BCC +
		CMP.b #!Kad_Swim_over : BCS +
		LDA !SD_KadaalLinear : STA $02
		AND #$C0 : BMI .40
	.7E	LDA #$7E : BRA ++
	.40	LDA #$40
	++	BIT $02
		BVC $01 : INC A
		STA !FileAddress+2
		REP #$20
		LDA !SD_KadaalLinear-1
		AND #$3F00
		ASL #2
		STA !FileAddress+0

		LDA $785F
		BPL $04 : EOR #$FFFF : INC A
		XBA
		AND #$00FF
		STA $2251
		LDA #$0200 : STA $2253
		LDA !FileAddress+0
		CLC : ADC $2306
		STA !FileAddress+0

	+	REP #$20


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

		LDA.w #!BigRAM : JSL CORE_GENERATE_RAMCODE
		SEP #$30
		LDA !P2Anim : STA !P2Anim2


	GRAPHICS:
		LDA !P2HurtTimer : BNE .DrawTiles

		LDA !P2Anim
		CMP #!Kad_SenkuSmash : BCS .DrawTiles
		CMP #!Kad_Spin : BCC +
		CMP #!Kad_Spin_over : BCC .DrawTiles
		+

		LDA !P2Invinc : BEQ .DrawTiles
		AND #$06 : BEQ OUTPUT_HURTBOX

		.DrawTiles
		LDA $0E : STA $04
		LDA $0F : STA $05
		JSL CORE_LOAD_TILEMAP


	OUTPUT_HURTBOX:
		REP #$30
		LDA.w #ANIM
		JSL CORE_OUTPUT_HURTBOX
		PLB
		RTS




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

		JSL CORE_ATTACK_Setup

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

		STZ !P2Hitbox1IndexMem1				;\
		STZ !P2Hitbox1IndexMem2				; | clear hitbox index mem if there is no hitbox
		STZ !P2Hitbox2IndexMem1				; |
		STZ !P2Hitbox2IndexMem2				;/
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
		JSL CORE_ATTACK_ActivateHitbox1
		JSR .GetClipping
		LDA !P2Hitbox2W					;\
		ORA !P2Hitbox2H					; | only process hitbox 2 if it actuallly exists
		BEQ .Return					;/
		JSL CORE_ATTACK_ActivateHitbox2
		JSR .GetClipping
		.Return
		REP #$20
		LDA !P2Hitbox1IndexMem1
		ORA !P2Hitbox2IndexMem1
		STA !P2Hitbox1IndexMem1
		STA !P2Hitbox2IndexMem1
		SEP #$20
		JSL CORE_GET_TILE_Attack
		RTS


		.GetClipping
		LDY !P2ActiveHitbox
		LDA !P2Hitbox1Shield,y : BNE .ClippingFail

		LDX #$0F

		.Loop
		TXY
		LDA ($0E),y : BNE .LoopEnd

		LDY !P2ActiveHitbox				;\
		CPX #$08 : BCS +				; |
		LDA !P2Hitbox1IndexMem1,y : BRA ++		; | check index memory
	+	LDA !P2Hitbox1IndexMem2,y			; |
	++	AND CORE_BITS,x : BNE .LoopEnd			;/
		LDA $3230,x					;\
		CMP #$02 : BEQ .Hit				; | check sprite status
		CMP #$08 : BCC .LoopEnd				;/
	.Hit	LDA $0F : PHA					;\
		JSL !GetSpriteClipping04			; |
		JSL !CheckContact				; | check contact
		PLA : STA $0F					; |
		BCC .LoopEnd					;/

		LDA !ExtraBits,x
		AND #$08 : BNE .HiBlock
		.LoBlock
		LDY $3200,x
		LDA HIT_TABLE,y
		BRA .AnyBlock
		.HiBlock
		LDY !NewSpriteNum,x
		LDA HIT_TABLE_Custom,y
		.AnyBlock
		ASL A : TAY
		PEA .LoopEnd-1
		REP #$20
		LDA HIT_Ptr+0,y
		DEC A
		PHA
		SEP #$20
		.ClippingFail
		RTS

		.LoopEnd
		DEX : BPL .Loop

		.HammerCheck
		LDX #!Ex_Amount-1
		.HammerLoop
		LDA !Ex_Num,x
		AND #$7F
		CMP #$04+!ExtendedOffset : BNE .HammerEnd
		LDA !Ex_Data3,x
		LSR A : BCS .HammerEnd
		LDA !Ex_XLo,x : STA $04				;\ x
		LDA !Ex_XHi,x : STA $0A				;/
		LDA !Ex_YLo,x : STA $05				;\ y
		LDA !Ex_YHi,x : STA $0B				;/
		LDA #$10 : STA $06				; w
		STA $07						; h
		JSL !CheckContact				;\ check for contact
		BCC .HammerEnd					;/
		JSL CORE_DISPLAYCONTACT				; contact gfx
		LDY !P2ActiveHitbox				; Y = hitbox index
		LDA !P2Hitbox1SFX1,y : BEQ ..skipSFX1		;\
		STA !SPC1					; | SFX 1
		..skipSFX1					;/
		LDA !P2Hitbox1SFX2,y : BEQ ..skipSFX2		;\
		STA !SPC4					; | SFX 2
		..skipSFX2					;/
		LDA !P2Hitbox1XSpeed,y : STA !Ex_XSpeed,x	; x speed
		LDA !P2Hitbox1YSpeed,y : STA !Ex_YSpeed,x	; y speed
		LDA !Ex_Data3,x
		ORA #$01
		STA !Ex_Data3,x					; hammer belongs to players
		.HammerEnd
		DEX
		BPL .HammerLoop

		RTS


	.Smash
		LDY #$06
		JMP .Spin


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
	db $06				; hitstun
	db $02,$00			; SFX
	dw $FFFF,$FFF5 : db $11,$16	; X/Y + W/H
	db $18,$C8			; speeds
	db $30				; timer
	db $06				; hitstun
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
		JSL CORE_ATTACK_Main
		LDA #$09 : STA $3230,x
		JMP KNOCKBACK

		.Standard
		LDA $3200,x
		CMP #$08 : BCC $03
	-	JMP .Stun

		JSL $02A9DE			; Get new sprite number into Y
		BMI -				; If there are no empty slots, don't spawn

		LDA $3200,x
		SEC : SBC #$04
		STA $3200,y			; Store sprite number for new sprite
		LDA #$08 : STA $3230,y		; > Status: normal
		LDA $3220,x : STA $3220,y	;\
		LDA $3250,x : STA $3250,y	; | coords
		LDA $3210,x : STA $3210,y	; |
		LDA $3240,x : STA $3240,y	;/
		PHX				;\
		TYX				; | reset tables for new sprite
		JSL !ResetSprite		; |
		PLX				;/
		LDA #$10			;\
		STA $32B0,y			; | Some sprite tables that SMW normally sets
		STA $32D0,y			; |
		STA !SpriteDisP1,y		; > don't interact
		STA !SpriteDisP2,y		; > don't interact
		LDA #$01 : STA $3310,y		;/

		LDA CORE_BITS,y
		CPY #$08 : BCS +
		TSB !P2Hitbox1IndexMem1 : BRA ++
	+	TSB !P2Hitbox1IndexMem2
		++

		LDA #$10 : STA $3300,y		; > Temporarily disable player interaction
		LDA $3430,x			;\ Copy "is in water" flag from sprite
		STA $3430,y			;/
		LDA #$02 : STA $32D0,y		;\ Some sprite tables
		LDA #$01 : STA $30BE,y		;/

		LDA $3330,x : STA $3330,y

		PHX
		LDA !P2Direction
		EOR #$01
		STA $3320,y
		TAX				; X = new sprite direction
		LDA CORE_KOOPA_XSPEED,x		; Load X speed table indexed by direction
		STA $30AE,y			; Store to new sprite X speed
		PLX

		; applying hitstun here causes the spawn to fail because SMW totally rules dude...
		LDY !P2ActiveHitbox
		LDA !P2Hitbox1SFX1,y : BEQ ..skipSFX1
		STA !SPC1
		..skipSFX1
		LDA !P2Hitbox1SFX2,y : BEQ ..skipSFX2
		STA !SPC4
		..skipSFX2
		JSL CORE_DISPLAYCONTACT


		.Stun
		LDA #$09 : STA $3230,x		; > Stun sprite
		LDA $3200,x			;\
		CMP #$08			; | Check if sprite is a Koopa
		BCC .DontStun			;/
		LDA #$FF : STA $32D0,x		; > Stun if not

		.DontStun
		LDA CORE_BITS,x
		CPX #$08 : BCS +
		TSB !P2Hitbox1IndexMem1 : BRA ++
	+	TSB !P2Hitbox1IndexMem2
		++

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
		JSL CORE_ATTACK_Main
		JMP KNOCKBACK

	HIT_04:
		; Knock back and stun
		LDA $3230,x
		CMP #$08
		BEQ .Main
		CMP #$09
		BNE HIT_07

		.Main
		JSL CORE_ATTACK_Main
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
		JSL CORE_ATTACK_Main
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
		PHK : PEA.w .Return-1
		PEA.w CORE_SPRITE_INTERACTION_RTL-1
		JML CORE_INT_0B+$03
		.Return
		RTS

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


	HIT_0F:
		; Do nothing
		RTS

	HIT_10:
		; Stun and damage
		JSL CORE_ATTACK_Main
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
		JSL CORE_ATTACK_Main
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
		STZ $32A0,x			; > disable hammer
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
		BRA ++
	+	LDA $35F0,x : BNE HIT_19
	++	PHK : PEA.w .Return-1
		PEA.w CORE_SPRITE_INTERACTION_RTL-1
		JML CORE_INT_1A+$03
		.Return
		RTS





	KNOCKOUT:
		LDA #$02 : STA $3230,x

		LDY !P2ActiveHitbox
		LDA !P2Hitbox1Hitstun,y : STA $9D
		LDA !P2Hitbox1YSpeed,y
		SEC : SBC #$10
		STA !SpriteYSpeed,x
		LDA !P2Hitbox1XSpeed,y : STA !SpriteXSpeed,x
		LDA !P2Hitbox1SFX1,y : BEQ .SkipSFX1			;\
		STA !SPC1						; |
		.SkipSFX1						; | SFX
		LDA !P2Hitbox1SFX2,y : BEQ .SkipSFX2			; |
		STA !SPC4						; |
		.SkipSFX2						;/

		JSL CORE_ATTACK_Main
		JSL CORE_DISPLAYCONTACT
		RTS


	KNOCKBACK:
		LDY !P2ActiveHitbox
		LDA !P2Hitbox1Hitstun,y : STA $9D
		LDA !P2Hitbox1XSpeed,y : STA !SpriteXSpeed,x
		LDA !P2Hitbox1YSpeed,y : STA !SpriteYSpeed,x
		LDA !P2Hitbox1SFX1,y : BEQ .SkipSFX1			;\
		STA !SPC1						; |
		.SkipSFX1						; | SFX
		LDA !P2Hitbox1SFX2,y : BEQ .SkipSFX2			; |
		STA !SPC4						; |
		.SkipSFX2						;/

		.GFX
		JSL CORE_DISPLAYCONTACT
		RTS



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





	.IdleTM
	dw $0008
	db $2E,$00,$F0,!P2Tile1
	db $2E,$00,$00,!P2Tile2

	.WalkTM
	dw $0008
	db $2E,$00,$EF,!P2Tile1
	db $2E,$00,$FF,!P2Tile2

	.DashTM
	dw $0010
	db $2E,$F4,$F8,!P2Tile1
	db $2E,$FC,$F8,!P2Tile1+1
	db $2E,$F4,$00,!P2Tile3
	db $2E,$FC,$00,!P2Tile3+1
	.DashTMU2
	dw $0010
	db $2E,$F4,$F6,!P2Tile1
	db $2E,$FC,$F6,!P2Tile1+1
	db $2E,$F4,$FE,!P2Tile3
	db $2E,$FC,$FE,!P2Tile3+1
	.DashTMU3
	dw $0010
	db $2E,$F4,$F5,!P2Tile1
	db $2E,$FC,$F5,!P2Tile1+1
	db $2E,$F4,$FD,!P2Tile3
	db $2E,$FC,$FD,!P2Tile3+1

	.TurnTM
	dw $0010
	db $2E,$F8,$F8,!P2Tile1
	db $2E,$00,$F8,!P2Tile1+1
	db $2E,$F8,$00,!P2Tile3
	db $2E,$00,$00,!P2Tile3+1

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
	db $2E,$00,$F0,!P2Tile1+1
	db $2E,$F8,$00,!P2Tile3
	db $2E,$00,$00,!P2Tile3+1

	.HeadbuttTM
	dw $0008
	db $2E,$F0,$F8,!P2Tile1
	db $2E,$00,$F8,!P2Tile2

	.SpinTM0
	dw $0008
	db $2E,$FC,$00,!P2Tile1
	db $2E,$04,$00,!P2Tile1+1
	.SpinTM1
	dw $0010
	db $2E,$08,$09,!P2Tile4
	db $2E,$FC,$00,!P2Tile1
	db $2E,$04,$00,!P2Tile1+1
	db $6E,$F8,$03,!P2Tile4
	.SpinTM2
	dw $0008
	db $6E,$04,$00,!P2Tile1
	db $6E,$FC,$00,!P2Tile1+1
	.SpinTM3
	dw $0010
	db $6E,$F8,$07,!P2Tile4
	db $6E,$04,$00,!P2Tile1
	db $6E,$FC,$00,!P2Tile1+1
	db $2E,$08,$01,!P2Tile4

	.ClimbTM
	dw $0008
	db $6E,$00,$F0,!P2Tile1
	db $6E,$00,$00,!P2Tile2

	.SmashTM0
	dw $0010
	db $6E,$04,$F8,!P2Tile1
	db $6E,$FC,$F8,!P2Tile1+1
	db $6E,$04,$00,!P2Tile3
	db $6E,$FC,$00,!P2Tile3+1
	.SmashTM1
	dw $0008
	db $6E,$00,$F0,!P2Tile1
	db $6E,$00,$00,!P2Tile2


;macro KadDyn(TileCount, TileNumber, Dest)
;	dw <TileCount>*$20
;	dl <TileNumber>*$20+$328008
;	dw <Dest>*$10+$6000
;endmacro

macro KadDyn(TileCount, TileNumber, Dest)
	db (<TileCount>*2)|((<TileNumber>&$07)<<5)
	db <TileNumber>>>3
	db <Dest>*8
endmacro



	; idle
		.IdleDynamo0
		db ..End-..Start
		..Start
		%KadDyn(2, $000, !P2Tile1)
		%KadDyn(2, $010, !P2Tile1+$10)
		%KadDyn(2, $020, !P2Tile2)
		%KadDyn(2, $030, !P2Tile2+$10)
		..End
		.IdleDynamo1
		db ..End-..Start
		..Start
		%KadDyn(2, $002, !P2Tile1)
		%KadDyn(2, $012, !P2Tile1+$10)
		%KadDyn(2, $022, !P2Tile2)
		%KadDyn(2, $032, !P2Tile2+$10)
		..End
		.IdleDynamo2
		db ..End-..Start
		..Start
		%KadDyn(2, $004, !P2Tile1)
		%KadDyn(2, $014, !P2Tile1+$10)
		%KadDyn(2, $024, !P2Tile2)
		%KadDyn(2, $034, !P2Tile2+$10)
		..End
		.IdleDynamo3
		db ..End-..Start
		..Start
		%KadDyn(2, $006, !P2Tile1)
		%KadDyn(2, $016, !P2Tile1+$10)
		%KadDyn(2, $026, !P2Tile2)
		%KadDyn(2, $036, !P2Tile2+$10)
		..End

	; walk
		.WalkDynamo0
		db ..End-..Start
		..Start
		%KadDyn(2, $008, !P2Tile1)
		%KadDyn(2, $018, !P2Tile1+$10)
		%KadDyn(2, $028, !P2Tile2)
		%KadDyn(2, $038, !P2Tile2+$10)
		..End
		.WalkDynamo1
		db ..End-..Start
		..Start
		%KadDyn(2, $00A, !P2Tile1)
		%KadDyn(2, $01A, !P2Tile1+$10)
		%KadDyn(2, $02A, !P2Tile2)
		%KadDyn(2, $03A, !P2Tile2+$10)
		..End
		.WalkDynamo2
		db ..End-..Start
		..Start
		%KadDyn(2, $00C, !P2Tile1)
		%KadDyn(2, $01C, !P2Tile1+$10)
		%KadDyn(2, $02C, !P2Tile2)
		%KadDyn(2, $03C, !P2Tile2+$10)
		..End
		.WalkDynamo3
		db ..End-..Start
		..Start
		%KadDyn(2, $00E, !P2Tile1)
		%KadDyn(2, $01E, !P2Tile1+$10)
		%KadDyn(2, $02E, !P2Tile2)
		%KadDyn(2, $03E, !P2Tile2+$10)
		..End

	; dash
		.DashDynamo0				; Used by frames 0, 3
		db ..End-..Start
		..Start
		%KadDyn(3, $083, !P2Tile1)
		%KadDyn(3, $093, !P2Tile1+$10)
		%KadDyn(3, $093, !P2Tile3)
		%KadDyn(3, $0A3, !P2Tile3+$10)
		..End
		.DashDynamo1				; Used by frame 1
		db ..End-..Start
		..Start
		%KadDyn(3, $086, !P2Tile1)
		%KadDyn(3, $096, !P2Tile1+$10)
		%KadDyn(3, $096, !P2Tile3)
		%KadDyn(3, $0A6, !P2Tile3+$10)
		..End
		.DashDynamo2				; Used by frame 2
		db ..End-..Start
		..Start
		%KadDyn(3, $089, !P2Tile1)
		%KadDyn(3, $099, !P2Tile1+$10)
		%KadDyn(3, $099, !P2Tile3)
		%KadDyn(3, $0A9, !P2Tile3+$10)
		..End
		.DashDynamo3				; Used by frame 4
		db ..End-..Start
		..Start
		%KadDyn(3, $0B0, !P2Tile1)
		%KadDyn(3, $0C0, !P2Tile1+$10)
		%KadDyn(3, $0C0, !P2Tile3)
		%KadDyn(3, $0D0, !P2Tile3+$10)
		..End
		.DashDynamo4				; Used by frame 5
		db ..End-..Start
		..Start
		%KadDyn(3, $0B3, !P2Tile1)
		%KadDyn(3, $0C3, !P2Tile1+$10)
		%KadDyn(3, $0C3, !P2Tile3)
		%KadDyn(3, $0D3, !P2Tile3+$10)
		..End

	; squat
		.SquatDynamo				; Also used by .Duck0
		db ..End-..Start
		..Start
		%KadDyn(2, $08E, !P2Tile1)
		%KadDyn(2, $09E, !P2Tile1+$10)
		%KadDyn(2, $09E, !P2Tile2)
		%KadDyn(2, $0AE, !P2Tile2+$10)
		..End


	; shell
		.ShellDynamo0				; Also used by .Duck1
		db ..End-..Start
		..Start
		%KadDyn(2, $0BA, !P2Tile1)
		%KadDyn(2, $0CA, !P2Tile1+$10)
		..End
		.ShellDynamo1
		db ..End-..Start
		..Start
		%KadDyn(2, $0BC, !P2Tile1)
		%KadDyn(2, $0CC, !P2Tile1+$10)
		..End
		.ShellDynamo2
		db ..End-..Start
		..Start
		%KadDyn(2, $0BE, !P2Tile1)
		%KadDyn(2, $0CE, !P2Tile1+$10)
		..End

	; fall
		.FallDynamo0
		db ..End-..Start
		..Start
		%KadDyn(2, $04A, !P2Tile1)
		%KadDyn(2, $05A, !P2Tile1+$10)
		%KadDyn(2, $06A, !P2Tile2)
		%KadDyn(2, $07A, !P2Tile2+$10)
		..End
		.FallDynamo1
		db ..End-..Start
		..Start
		%KadDyn(2, $04C, !P2Tile1)
		%KadDyn(2, $05C, !P2Tile1+$10)
		%KadDyn(2, $06C, !P2Tile2)
		%KadDyn(2, $07C, !P2Tile2+$10)
		..End

	; turn
		.TurnDynamo
		db ..End-..Start
		..Start
		%KadDyn(4, $080, !P2Tile1)
		%KadDyn(4, $090, !P2Tile1+$10)
		%KadDyn(4, $090, !P2Tile3)
		%KadDyn(4, $0A0, !P2Tile3+$10)
		..End

	; senku
		.SenkuDynamo
		db ..End-..Start
		..Start
		%KadDyn(2, $048, !P2Tile1)
		%KadDyn(2, $058, !P2Tile1+$10)
		%KadDyn(2, $068, !P2Tile2)
		%KadDyn(2, $078, !P2Tile2+$10)
		..End

	; punch
		.PunchDynamo0
		.PunchDynamo3
		db ..End-..Start
		..Start
		%KadDyn(2, $046, !P2Tile1)
		%KadDyn(2, $056, !P2Tile1+$10)
		%KadDyn(2, $066, !P2Tile2)
		%KadDyn(2, $076, !P2Tile2+$10)
		..End
		.PunchDynamo1
		db ..End-..Start
		..Start
		%KadDyn(3, $040, !P2Tile1)
		%KadDyn(3, $050, !P2Tile1+$10)
		%KadDyn(3, $060, !P2Tile3)
		%KadDyn(3, $070, !P2Tile3+$10)
		..End
		.PunchDynamo2
		db ..End-..Start
		..Start
		%KadDyn(3, $043, !P2Tile1)
		%KadDyn(3, $053, !P2Tile1+$10)
		%KadDyn(3, $063, !P2Tile3)
		%KadDyn(3, $073, !P2Tile3+$10)
		..End

	; hurt
		.HurtDynamo
		db ..End-..Start
		..Start
		%KadDyn(2, $04E, !P2Tile1)
		%KadDyn(2, $05E, !P2Tile1+$10)
		%KadDyn(2, $06E, !P2Tile2)
		%KadDyn(2, $07E, !P2Tile2+$10)
		..End

	; dead
		.DeadDynamo
		db ..End-..Start
		..Start
		%KadDyn(2, $11A, !P2Tile1)
		%KadDyn(2, $12A, !P2Tile1+$10)
		%KadDyn(2, $13A, !P2Tile2)
		%KadDyn(2, $14A, !P2Tile2+$10)
		..End

	; spin
		.SpinDynamo0
		db ..End-..Start
		..Start
		%KadDyn(3, $120, !P2Tile1)
		%KadDyn(3, $130, !P2Tile1+$10)
		..End
		.SpinDynamo1
		db ..End-..Start
		..Start
		%KadDyn(3, $123, !P2Tile1)
		%KadDyn(3, $133, !P2Tile1+$10)
		%KadDyn(2, $140, !P2Tile4)
		%KadDyn(2, $150, !P2Tile4+$10)
		..End

	; climb
		.ClimbDynamo				; Used by both frames
		db ..End-..Start
		..Start
		%KadDyn(2, $116, !P2Tile1)
		%KadDyn(2, $126, !P2Tile1+$10)
		%KadDyn(2, $136, !P2Tile2)
		%KadDyn(2, $146, !P2Tile2+$10)
		..End

	; senku smash
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

	; shell drill init
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

	; swim
		.SwimDynamo0
		db ..End-..Start
		..Start
		%KadDyn(2, $00C, !P2Tile1)
		%KadDyn(2, $00E, !P2Tile1+$10)
		..End
		.SwimDynamo1
		db ..End-..Start
		..Start
		%KadDyn(2, $008, !P2Tile1)
		%KadDyn(2, $00A, !P2Tile1+$10)
		..End
		.SwimDynamo2
		db ..End-..Start
		..Start
		%KadDyn(2, $004, !P2Tile1)
		%KadDyn(2, $006, !P2Tile1+$10)
		..End
		.SwimDynamo3
		db ..End-..Start
		..Start
		%KadDyn(2, $000, !P2Tile1)
		%KadDyn(2, $002, !P2Tile1+$10)
		..End

	; dash attck
		.HeadbuttDynamo0
		db ..End-..Start
		..Start
		%KadDyn(2, $08C, !P2Tile1)
		%KadDyn(2, $09C, !P2Tile1+$10)
		%KadDyn(2, $09C, !P2Tile2)
		%KadDyn(2, $0AC, !P2Tile2+$10)
		..End
		.HeadbuttDynamo1
		db ..End-..Start
		..Start
		%KadDyn(4, $0B6, !P2Tile1)
		%KadDyn(4, $0C6, !P2Tile1+$10)
		..End



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



;			   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |			|
;	LO NYBBLE	   |YY0|YY1|YY2|YY3|YY4|YY5|YY6|YY7|YY8|YY9|YYA|YYB|YYC|YYD|YYE|YYF|	HI NYBBLE	|
;	--->		   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |			V

HIT_TABLE:		db $01,$01,$01,$01,$02,$02,$02,$02,$03,$03,$03,$03,$03,$04,$00,$05	;| 00X
			db $06,$02,$00,$01,$01,$08,$08,$00,$08,$00,$00,$07,$09,$07,$0A,$0A	;| 01X
			db $07,$0B,$0C,$0C,$0C,$0C,$07,$07,$07,$00,$07,$07,$00,$00,$07,$0D	;| 02X
			db $0E,$0E,$0E,$07,$07,$00,$00,$07,$07,$07,$07,$07,$07,$01,$0D,$06	;| 03X
			db $04,$0F,$0F,$0F,$07,$00,$10,$00,$07,$0F,$11,$0A,$00,$12,$12,$01	;| 04X
			db $01,$0A,$00,$00,$00,$0F,$0F,$0F,$0F,$00,$00,$0F,$0F,$0F,$0F,$00	;| 05X
			db $00,$0F,$0F,$0F,$00,$07,$07,$07,$07,$00,$00,$00,$00,$00,$13,$13	;| 06X
			db $00,$01,$01,$01,$1A,$1A,$1A,$1A,$1A,$00,$00,$11,$00,$00,$00,$00	;| 07X
			db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	;| 08X
			db $00,$10,$10,$10,$10,$10,$00,$10,$10,$07,$07,$0A,$0F,$00,$07,$14	;| 09X
			db $00,$07,$02,$00,$07,$07,$07,$00,$07,$07,$07,$15,$00,$00,$07,$16	;| 0AX
			db $07,$00,$07,$07,$07,$00,$07,$17,$17,$00,$0F,$0F,$00,$01,$0A,$18	;| 0BX
			db $0F,$00,$01,$07,$0F,$07,$00,$00,$00					;| 0CX

.Custom			db $00,$00,$00,$00,$00,$00,$00,$07,$00,$00,$00,$00,$00,$00,$00,$00	;| 10X
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





namespace off
















