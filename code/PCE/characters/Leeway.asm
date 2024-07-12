;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

namespace Leeway

<<<<<<< Updated upstream
; --Build 2.7--
=======
; --Build 3.3--
>>>>>>> Stashed changes
;


	!Lee_Idle	= $00
	!Lee_Walk	= $03
	!Lee_Cut	= $07
	!Lee_Slash	= $0C
	!Lee_Dash	= $10
	!Lee_DashSlash	= $13
	!Lee_Jump	= $18
	!Lee_Fall	= $19
	!Lee_SlowFall	= $1B
	!Lee_Ceiling	= $1E
	!Lee_Crouch	= $24
	!Lee_Crawl	= $26
	!Lee_CrouchEnd	= $2A
	!Lee_AirSlash	= $2B
	!Lee_Hang	= $2F
	!Lee_HangSlash	= $30
	!Lee_WallCling	= $34
	!Lee_WallSlash	= $35
	!Lee_WallClimb	= $39
	!Lee_ClimbTop	= $3D
	!Lee_ClimbBG	= $3E
	!Lee_Hurt	= $40
	!Lee_Dead	= $41
	!Lee_Victory	= $42

<<<<<<< Updated upstream
=======
	LDA $16
	AND #$20 : BEQ +
	LDA !LeewayUpgrades
	EOR #$FF : STA !LeewayUpgrades
	+


		LDA !P2Init : BNE .Main

		.Init
		INC !P2Init
		REP #$10
	;	LDX #$FFFF : STX !P2Particle
		SEP #$30

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


	MAINCODE:
		PHB : PHK : PLB
		LDA #$03 : STA !P2Character
		LDA #$02 : STA !P2MaxHP
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

		.KnockedOut
<<<<<<< Updated upstream
		JSR CORE_KNOCKED_OUT
		BMI .Fall
		BCC .Fall
=======
		LDA !P2DroppedSword : BNE ..move
		INC !P2DroppedSword
		JSR DropSword
		..move
		JSL CORE_KNOCKED_OUT : BCC .Fall
>>>>>>> Stashed changes
		LDA #$02 : STA !P2Status
		PLB
		RTS

		.Fall
		LDA #!Lee_Dead : STA !P2Anim
		STZ !P2AnimTimer
<<<<<<< Updated upstream
		JMP ANIMATION_HandleUpdate

		.SnapToP1
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
=======
		JMP ANIMATION_CheckPlayer
>>>>>>> Stashed changes

		.Return
		PLB
		RTS

		.Process
<<<<<<< Updated upstream
		LDA !P2MaxHP				;\
		CMP !P2HP				; | Enforce max HP
		BCS $03 : STA !P2HP			;/
		LDA !P2Platform				;\
		BEQ ++					; |
		CMP !P2SpritePlatform : BEQ +		; | Account for platforms
	++	STA !P2PrevPlatform			; |
		+					;/
		LDA $6DA5
=======

	; merge L into A
		LDA $17
>>>>>>> Stashed changes
		AND #$20
		ASL #2
		TSB $6DA5
		LDA $6DA9
		AND #$20
		ASL #2
<<<<<<< Updated upstream
		TSB $6DA9
=======
		TSB $18

		REP #$20						;\
		LDA !P2Hitbox1IndexMem					; |
		ORA !P2Hitbox2IndexMem					; | merge hitboxes
		STA !P2Hitbox1IndexMem					; |
		STA !P2Hitbox2IndexMem					; |
		SEP #$20						;/


>>>>>>> Stashed changes

	; timers
		LDA !P2HurtTimer
		BEQ $03 : DEC !P2HurtTimer
		LDA !P2Invinc
		BEQ $03 : DEC !P2Invinc
<<<<<<< Updated upstream
		LDA !P2DashTimerR2
		BEQ $03 : DEC !P2DashTimerR2
		LDA !P2Dashing
		BEQ $05 : DEC !P2Dashing : BRA $03 : STZ !P2DashSlash	; only 1 attack per dash
		LDA !P2SlantPipe
		BEQ $03 : DEC !P2SlantPipe
		LDA !P2ClimbTop
		BEQ $03 : DEC !P2ClimbTop
		LDA !P2ComboDash
		BEQ $03 : DEC !P2ComboDash


		LDA !P2SwordTimer : BNE +
		STZ !P2ComboDisable
		STZ !P2SwordAttack
		STZ !P2Buffer
		BRA ++
	+	DEC !P2SwordTimer
		LDA $6DA3			; Leeway can drop down during a dash slash by pushing down
		AND #$04 : BEQ +
		STZ !P2Dashing
		BRA ++
=======
		LDA !P2KickTimer
		BEQ $03 : DEC !P2KickTimer
		LDA !P2WallAnim
		BEQ $03 : DEC !P2WallAnim


		LDA !P2SwordTimer : BEQ +
		DEC !P2SwordTimer : BNE +
		STZ !P2SwordAttack
		+


		LDA !P2BraveDashCooldown : BEQ +
		DEC !P2BraveDashCooldown : BNE +
		LDA #$B4 : STA !P2FlashPal
		+

		LDA !P2DashSmoke : BEQ +				;\
		DEC !P2DashSmoke					; | dash smoke
		JSL CORE_DASH_SMOKE					; |
		+							;/
		LDA !P2SlantPipe
		BEQ $03 : DEC !P2SlantPipe


	; dash timer
		.Dashing
		LDA !P2Dashing : BEQ ..done				; check dash timer
		DEC !P2Dashing : BNE ..done				; decrement timer
		LDA #!Lee_DashTransition : STA !P2Anim			;\
		LDA #$04 : STA !P2AnimTimer				; | dash done anim
		..done
>>>>>>> Stashed changes


<<<<<<< Updated upstream
		LDA !P2DashTimerL2
		BEQ $03 : DEC !P2DashTimerL2
		BEQ +
		LDA !P2DashTimerL1 : TSB $6DA3
		LDA !P2ButtonDis : TRB $6DA3
		BRA ++
	+	STZ !P2DashTimerL1
		STZ !P2ButtonDis
		++


	PIPE:
		JSR CORE_PIPE
		BCC CONTROLS
		LDA #$04 : TRB $6DA3
		JMP ANIMATION_HandleUpdate


	CONTROLS:

		JSR CORE_COYOTE_TIME

		LDA !P2Buffer			;\
		AND #$80			; |
		TSB $6DA3			; | apply jump buffer
		TSB $6DA7			; |
		TRB !P2Buffer			;/

		LDA !P2HurtTimer
		BEQ $03 : JMP PHYSICS

		PEA PHYSICS-1

	; Crouch check

		LDA !P2Anim
		CMP #!Lee_Cut : BCS .NoCrouch
		LDA $6DA3
		AND #$04 : BEQ .NoCrouch
		LDA #$80 : TSB !P2Water
		.NoCrouch

	; Climb check here

		LDA !P2SwordAttack
		AND #$7F
		CMP #$05 : BCC +
		BNE ++

	++	LDA #$00 : JSR CORE_SET_XSPEED
		STZ !P2YSpeed
		RTS

	+	LDA !P2Climb
		BEQ $03 : JMP .ProcessClimb

		LDA $6DA3
		ORA #$04
		AND !P2Blocked
		LDY !P2Platform
		BEQ $02 : ORA #$04
		AND #$0F
		CMP #$08 : BCS .ClingUp
		CMP #$04 : BCS .GroundCheck
		XBA
		LDA !P2YSpeed : BPL +			; can't cling while ascending
		CMP #$F8 : BCS +
		JMP .NoClimb
	+	XBA
		LSR A : BCS .ClingRight
		LSR A : BCS .ClingLeft
		LDA !P2YSpeed
		BPL +
	-	JMP .NoClimb
	+	JSR CheckAbove
		BCC -
		LDA $6DA3
		AND #$08 : BEQ -

		.ClingUp
		LDA !P2ClimbTimer : BEQ .nogrip		; can't grip without stamina
		LDA !LeewayUpgrades			;\ can never cling to ceilings without dino grip
		AND #$20 : BEQ .nogrip			;/
		LDA !IceLevel : BEQ +			; can't cling to ceilings on icy levels
	.nogrip	STZ !P2Climb
		JMP .NoClimb
	+	LDA #$80 : STA !P2Climb
		BRA .ProcessClimb

		.GroundCheck
		LSR A : BCC +
		LDA $6DA3
		AND #$08 : BNE .ClingRight
		JMP .NoClimb
	+	LSR A : BCC +
		LDA $6DA3
		AND #$08 : BNE .ClingLeft
	+	JMP .NoClimb

		.ClingRight
		LDA #!Lee_WallClimb : STA !P2Anim
		STZ !P2AnimTimer
		LDA #$01 : STA !P2Climb
		STA !P2Direction

		.ProcessClimb
		PHP
		JSR CORE_NO_CLIMB
		STZ !P2DashTimerR2
		STZ !P2Dashing
		STZ !P2DashJump
		STZ !P2SwordAttack
		STZ !P2SwordTimer
		STZ !P2SenkuUsed
		PLP
		BPL .Wall
		JMP .Ceiling
=======
		.WallJump
		LDA !P2WallJumpTimer : BEQ ..clear
		DEC !P2WallJumpTimer
		LDA !P2WallJumpInput : TSB $15
		EOR #$03 : TRB $15
		BRA ..done
		..clear
		STZ !P2WallJumpInput
		..done



	; snorez particles
		; LDA $14
		; AND #$7F : BNE +
		; PHP
		; PHB
		; JSL GetParticleIndex
		; LDA.l !P2Dir
		; AND #$00FF
		; BEQ $03 : LDA #$0008
		; ADC.l !P2X
		; STA !Particle_X,x
		; LDA.l !P2Y
		; SEC : SBC #$0004
		; STA !Particle_Y,x
		; SEP #$20
		; LDA #!prt_snorez : STA !Particle_Type,x
		; LDA #$F0 : STA !Particle_Prop,x
		; PLB
		; PLP
		; +







	PIPE:
		JSL CORE_PIPE : BCC CONTROLS
		LDA #$04 : TRB $15
		JMP ANIMATION


	CONTROLS:
		PEA PHYSICS-1
		JSL CORE_COYOTE_TIME

	; hurt check
		.Hurt
		LDA !P2HurtTimer : BEQ ..done
		JMP .Friction
		..done


	; air/ground split
		LDA !P2InAir : BEQ .Ground
>>>>>>> Stashed changes

	; air-only moves
		.Air
		STZ !P2Ducking					; leeway can't crouch in midair
		LDA !P2WallCoyote
		BEQ $03 : DEC !P2WallCoyote

	; double jump code
		.DoubleJump
		LDA $16						;\
		AND !LeewayUpgrades				; | must have upgrade and press B
		BPL ..done					;/
		LDA !P2WallClimb : BNE ..done			; can't double jump from wall/ceiling
		LDA !P2CoyoteTime : BMI $02 : BNE ..done
		LDA !P2AirDashUsed				;\ only one double jump per jump
		AND #$02 : BNE ..done				;/
		LDA #$02 : TSB !P2AirDashUsed
		LDA #$D0 : STA !P2YSpeed
		LDA #!Lee_Jump : STA !P2Anim
		STZ !P2AnimTimer
<<<<<<< Updated upstream
		LDA #$02 : STA !P2Climb
		STZ !P2Direction
		BRA .ProcessClimb

		.Wall
		LDA !P2Blocked
		LDY !P2Platform
		BEQ $02 : ORA #$04
		STA $00
		AND #$04 : BEQ .Go
	.Floor	STZ !P2Climb
		STZ !P2VectorY
		STZ !P2VectorTimeY

	.Go	LDA $00
		AND #$0B : BNE $03 : JMP .Top
		CMP #$08 : BCC +
		LDA #$03 : TRB !P2Blocked
		LDA #$80 : STA !P2Climb
		PHP : REP #$20
		DEC !P2XPosLo
		PLP
		JMP ++
	+	LDX !P2Direction
		LDA .ClimbX,x : STA !P2XSpeed

		LDA !P2ClimbTimer : BEQ .slide		; slip without stamina
		LDA !LeewayUpgrades			;\ always slide down without dino grip
		AND #$20 : BEQ .slide			;/
		LDA !IceLevel : BEQ .done		; slide down on icy levels
	.slide	LDA !P2VectorY : BMI .drop
		CMP #$40 : BCS .time
	.drop	INC !P2VectorY
		INC !P2VectorY
	.time	LDA #$02
		CMP !P2VectorTimeY : BCC .done
		STA !P2VectorTimeY
		STZ !P2VectorAccY
		.done
=======
		STZ !P2Dashing
		..done
>>>>>>> Stashed changes

		BRA .SharedMoves

<<<<<<< Updated upstream
		LDA $6DA3
		LSR #2
		AND #$03
		TAX
		LDA .XSpeed,x : STA !P2YSpeed		; climb up/down speed
		BNE +
		LDX !P2Direction
		LDA $6DA3
		AND .WallAnim,x
		BNE .HoldOut
	+	LDA !P2Anim
		CMP #!Lee_WallCling : BNE .NoHoldOut
		LDA #!Lee_WallClimb : STA !P2Anim
		BRA .NoHoldOut

		.HoldOut
		LDA #!Lee_WallCling : STA !P2Anim
		STZ !P2AnimTimer
		BRA .ClimbJump
=======
>>>>>>> Stashed changes

	; ground-only moves
		.Ground
		STZ !P2KillCount
		STZ !P2AirDashUsed
		STZ !P2DashJump
		STZ !P2WallClimb
		STZ !P2WallCoyote
		STZ !P2JumpHold
		LDA !LeewayUpgrades
		AND #$08
		BEQ $02 : LDA !LeewayMaxStamina
		STA !P2Stamina

<<<<<<< Updated upstream
		.Ceiling
		LDA !P2ClimbTimer : BEQ +++			; drop when stamina runs out
		LDA !P2Blocked
		LSR A : BCC +
		LDA #$08 : TRB !P2Blocked
		JMP .ClingRight
	+	LSR A : BCC ++
		LDA #$08 : TRB !P2Blocked
		JMP .ClingLeft
	++	JSR CheckAbove : BCS .stick
	+++	JMP .Fall
	.stick	STZ !P2ClimbTop					; Clear getup
		LDA $6DA3
		AND #$03
		TAX
		LDA .Direction,x
		BMI $03 : STA !P2Direction
		LDA .XSpeed,x : STA !P2XSpeed
		BNE +
		LDA #!Lee_Hang : STA !P2Anim
	+	STZ !P2YSpeed
		LDA !P2YPosLo
		AND #$F0
		ORA #$0D
		STA !P2YPosLo

		.ClimbJump
		BIT $6DA7
		BVS .ClimbSlash
		BPL .EndClimb
		BIT !P2Climb : BMI .Fall
		STZ !P2ClimbTop					; wall jump here
		LDX !P2Direction
		LDA .ClimbX+2,x : STA !P2XSpeed
		LDA .ClimbLock+2,x : STA !P2DashTimerL1
		STZ !P2VectorY
		STZ !P2VectorTimeY
		LDA #$10 : STA !P2DashTimerL2
		LDY #$C8
		LDA !P2ClimbTimer : BEQ .nospd			; low vertical speed without stamina
		LDA !LeewayUpgrades				;\ very low vertical speed without dino grip
		AND #$20 : BEQ .nospd				;/
		LDA !IceLevel : BEQ +				;\ very low vertical speed on icy levels
	.nospd	LDY #$E0					;/
		LDA .ClimbLock+3,x : STA !P2ButtonDis		; lock input
	+	STY !P2YSpeed					; Y speed
		LDA !P2ClimbTimer				;\
		SEC : SBC #$28					; | wall jump costs 0x28 stamina
		BPL $02 : LDA #$00				; |
		STA !P2ClimbTimer				;/
		LDA #$2B : STA !SPC1				; jump SFX
		BIT $6DA5 : BPL .Fall
		LDA #$01 : STA !P2DashJump

		.Fall
		BIT !P2Climb : BMI +
		LDA #!Lee_ClimbTop : STA !P2Anim
		STZ !P2AnimTimer
	+	STZ !P2Climb
=======
		.Crouch
		JSL CORE_CHECK_ABOVE : BCC ..noforce
		LDA #$04 : TSB $15
		..noforce
		LDA $15
		AND #$04 : STA !P2Ducking
		..done

>>>>>>> Stashed changes


<<<<<<< Updated upstream
		.ClimbSlash
		LDA !P2ClimbTop : BNE .EndClimb			; No normal climb attacks during get-up
		LDA #$05
		BIT !P2Climb
		BPL .WallSlash
=======
	; moves that can be used in midair and on the ground
	.SharedMoves

	; slide
		.Sliding
		LDA $15						;\ A = input
		LDY !P2InAir : BEQ ..ground			;/ air/ground split
		..air						;\ AIR: keep slide if not touching d-pad
		AND #$03 : BEQ ..canslide			;/
		ROR #2						;\ holding backwards in midair -> end slide
		EOR !P2XSpeed : BPL ..endslide			;/ (note the lack of DEC A)
		LDA !P2XSpeed					;\
		CLC : ADC #$28					; | holding forward in midair with 0x28+ speed maintains the slide
		CMP #$50 : BCS ..done				;/
		BRA ..endslide
		..ground					;\
		AND #$07					; | GROUND: check for holding down -> can slide
		CMP #$04 : BCS ..canslide			;/
		LDY !P2Sliding : BEQ ..done			; if not holding down and not sliding -> done
		AND #$03 : BEQ ..canslide			; if not holding anything -> can slide
		..endslide					;\ end slide
		LDA #$00 : BRA ..setslide			;/
		..canslide					;\
		LDA !P2Slope : BNE ..setslide			; | can slide on a slope
		LDA !P2Sliding : BEQ ..done			; | keep slide on flat ground if speed > 0
		LDA !P2XSpeed					;/
		..setslide					;\
		STA !P2Sliding					; | set slide
		..done						;/

	; dash code
		.Dash
		LDA !P2WallClimb : BNE ..clear			; clear if grabbing something
		LDA !P2Dashing : BEQ ..done			;\ always set dash jump when dashing
		STA !P2DashJump					;/
		LDA !P2InAir : BEQ ..allow			;\
		LDA !P2CoyoteTime				; | clear aerial dash unless air dashing
		BMI $02 : BNE ..done				; | (but maintain it during coyote time)
		LDA !P2AirDash : BEQ ..clear			; |
		..allow						;/
		STZ !P2YSpeed
		LDA !P2SwordAttack : BNE ..done
		BIT $17 : BMI ..done
		..clear
		STZ !P2Dashing
		STZ !P2AirDash
		..done
>>>>>>> Stashed changes

	; start attack code
		.StartAttack
		BIT $16 : BVC ..done
		LDA !P2Dashing : BNE ..dashattack
		LDA !P2InAir  : BEQ ..groundattack
		LDA !P2SwordAttack : BNE ..done
		LDA !P2WallClimb
		BEQ ..airattack
		BPL ..wallattack

		..ceilingattack
		LDA #$06 : BRA ..setattack

<<<<<<< Updated upstream
		.Top
		LDA !P2YSpeed
		BMI $04 : CMP #$10 : BCS .EndClimb-3
		LDX !P2Direction
		LDA .ClimbX,x : STA !P2XSpeed
		LDA .ClimbLock,x : STA !P2DashTimerL1
		LDA .ClimbLock+2,x : STA !P2ButtonDis
		LDA #$10 : STA !P2DashTimerL2
		STZ !P2Climb
		LDA !P2ClimbTop : BNE +
		LDA #$1C : STA !P2ClimbTop
	+	RTS
=======
		..wallattack
		LDA #$05 : BRA ..setattack
>>>>>>> Stashed changes

		..airattack
		LDA !LeewayUpgrades
		LSR A : BCS +
		LDA #$04 : BRA ..setattack
	+	LDA #$07 : BRA ..setattack

		..dashattack
		LDA !P2SwordAttack : BNE ..done
		LDA #$03 : BRA ..setattack

		..groundattack
		BIT $16 : BVC ..done
		LDA !P2SwordAttack
		AND #$7F : BEQ ..groundattack1
		CMP #$01 : BNE ..done
		LDA !P2SwordTimer
		CMP #$0C : BCS ..done
		LDA #$40 : TSB !P2Buffer
		BRA ..done
		..groundattack1
		LDA #$01
		..setattack
		STA !P2SwordAttack
		..done

<<<<<<< Updated upstream
	; Dash check before ground check because air dash will be unlocked

		LDA !P2DashTimerR2			;\
		BEQ $03					; | I don't know what this does but I did put it here
	-	JMP .NoDash				;/
		BIT $6DA9 : BPL -			; check input
		LDA !P2Water				;\ No dashing from nets
		LSR A : BCS .NoDash			;/

		LDA !P2SwordAttack : BEQ .NoCombo	;\
		LDA !P2ComboDisable : BNE .NoDash	; |
		LDA !LeewayUpgrades			; |
		AND #$09 : BEQ .NoDash			; | check for combo dash trigger
		CMP #$08 : BCS +			; |
		LDA !P2Blocked				; |
		AND #$04 : BEQ .NoDash			; |
	+	LDA !P2ComboDash : BEQ .NoDash		;/
		LDA #$03 : STA !P2SwordAttack		;\
		LDA #$1A : STA !P2Invinc		; |
		INC !P2ComboDisable			; | set up combo dash
		STZ !P2IndexMem1			; |
		STZ !P2IndexMem2			;/
		.NoCombo
=======




	; horizontal movement code
	.HorizontalMovement
		LDA !P2SwordAttack				;\
		AND #$7F : BEQ ..notattacking			; | friction during ground attack 1
		CMP #$01 : BEQ .Friction			; |
		..notattacking					;/

		.HandleSlide
		LDA !P2Sliding : BEQ ..done			; check slide
		LDA !P2XSpeed					;\
		ROL #2						; | slide direction
		AND #$01					; |
		EOR #$01 : STA !P2Dir				;/
		LDA !P2Slope					;\
		CLC : ADC #$04					; |
		ASL A : TAX					; | get slide speed and acc
		REP #$30					; |
		LDY DATA_SlideXAcc,x				; |
		LDA DATA_SlideXSpeed,x : BNE ..getdir		;/
		LDA !P2InAir
		AND #$00FF : BNE ..keepspeed
		..accjump
		JMP .ApplyAcc

		..getdir
		BMI ..left					;\
		..right						; |
		BIT !P2XSpeedFraction : BMI ..accjump		; |
		CMP !P2XSpeedFraction : BCS ..accjump		; |
		..keepspeed
		LDA !P2XSpeedFraction : BRA .ApplyAcc		; | handle slide speed
		..left						; |
		BIT !P2XSpeedFraction : BPL .ApplyAcc		; |
		CMP !P2XSpeedFraction : BCC .ApplyAcc		; |
		LDA !P2XSpeedFraction : BRA .ApplyAcc		; |
		..done						;/

>>>>>>> Stashed changes

		LDA $15
		AND #$03 : BNE .Move
		LDA !P2Dashing : BEQ .Friction
		LDA !P2Direction
		EOR #$01
		ASL A
		BRA .Move_dashing

<<<<<<< Updated upstream
		STZ !P2ClimbTop				; Clear getup when starting a dash
		LDA !P2Blocked
		AND #$04
		ORA !P2Platform
		BNE .GroundDash
=======
		.Friction
		REP #$30
		LDY #$0800
		LDA #$0000 : BRA .ApplyAcc

		.Move
		LDY !P2SwordAttack				;\
		CPY #$82 : BEQ ..dirdone			; | can't turn during ground attack 2 or air attack
		CPY #$84 : BEQ ..dirdone			;/
		AND #$01 : STA !P2Direction			;\ set dir
		..dirdone					;/
		LDY #$00					; base index = walking
		LDA $15						;\ get left bit
		..dashing					; > special hook for dash branch
		AND #$02					;/
		LDX !P2DashJump : BNE ..setdash			;\
		LDX !P2Dashing : BEQ ..dashdone			; |
		..setdash					; | dash index
		ORA #$04					; |
		LDY #$02					;/
		..dashdone					;
		TAX						; X = speed index
		LDA !P2XSpeed : BEQ ..turn			;\> 0 speed counts as turning
		ROL #2						; |
		EOR !P2Direction				; |
		LSR A : BCS ..noturn				; | increase acceleration when turning
		..turn						; |
		LDY #$04					; |
		..noturn					;/
		LDA !IceLevel : BEQ ..instant
		LDA !P2InAir : BNE ..instant
		..ice
		REP #$30
		LDA DATA_XAccIce,y : TAY
		BRA ..getspeed
		..instant
		REP #$30
		LDY #$7FFF
		..getspeed
		LDA DATA_XSpeed,x
>>>>>>> Stashed changes

		.ApplyAcc
		JSL CORE_ACCEL_X_16Bit
		SEP #$30
		.HorizontalMovementDone

<<<<<<< Updated upstream
		LDA !P2SenkuUsed
		BEQ $03 : JMP .Shared
		LDA #$2D : STA !SPC1
		LDA #$98 : STA !P2Dashing
		LDA #$01
		STA !P2SenkuUsed
		STA !P2DashJump
		JMP .Shared

		.GroundDash
		LDA #$2D : STA !SPC1			; dash SFX
		LDA #$18 : STA !P2Dashing

		.NoDash
=======


	; ceiling climb code
		.CeilingClimb
		LDA !P2WallClimb : BMI ..climbing
		..init
		LDA !P2Stamina : BEQ ..done
		LDA !P2Blocked
		AND $15
		AND !LeewayUpgrades
		AND #$08 : BEQ ..done
		LDA #$80 : STA !P2WallClimb			; cling to ceiling off of bonk
		REP #$20
		LDA !P2Y
		CLC : ADC #$0006
		STA !P2Y
		SEP #$20
		STZ !P2SwordAttack
		..climbing
		STZ !P2DashJump
		STZ !P2AirDashUsed
		STZ !P2Carry					; can't hold item while climbing
		LDA $15
		BIT #$08 : BEQ ..drop
		JSL CORE_CHECK_ABOVE : BCC ..drop
		LDA $15
		AND #$03 : TAX
		LDA !P2SwordAttack
		BEQ $02 : LDX #$00
		LDA DATA_ClimbSpeed,x : STA !P2XSpeed
		STZ !P2YSpeed
		BIT $16 : BMI $03 : JMP .WallClimb_done
		..drop
		STZ !P2WallClimb
		STZ !P2YSpeed
		..done


	; wall slide/climb code
		.WallClimb
		LDA !P2WallClimb : BNE ..canclimb		;\ can't grab wall with upwards y speed
		BIT !P2YSpeed : BPL ..canclimb			;/
		..donejump
		JMP ..done					;
		..canclimb					;
		LDA !P2InAir : BEQ ..update			; let go if touching ground
		LDA !P2Blocked
		AND $15
		AND #$03
		BEQ $03 : STA !P2WallJumpDir			; only update wall if actually touching one
		CMP !P2WallClimb : BEQ ..main
		STZ !P2YSpeed					; reset Y-speed when grabbing or falling off
		STZ !P2JumpHold
		STZ !P2SwordAttack
		..update
		STA !P2WallClimb
>>>>>>> Stashed changes

		..main
		LDA !P2WallClimb : BEQ ..donejump
		..clinging
		LDA $15
		AND #$03 : TAX
		LDA DATA_ClimbSpeed,x : STA !P2XSpeed
		LDA $15						;\ ignore ledge if holding down
		AND #$04 : BNE ..noledge			;/
		LDA !P2Dir					;\
		ASL A : TAX					; |
		REP #$30					; |
		LDY !P2Y					; |
		LDA !P2X					; |
		CLC : ADC DATA_ClimbTileX,x			; | check for ledge
		TAX						; |
		JSL GetMap16					; |
		CMP #$0025					; |
		SEP #$30					; |
		BNE ..noledge					;/
		LDA !P2SwordAttack : BNE ..sticktoledge		; prio for sword animation
		LDA #!Lee_WallClimbTop : STA !P2Anim		;\
		STZ !P2AnimTimer				; | ledge hang anim
		..sticktoledge					;/
		LDA #$08 : STA !P2WallAnim			; set timer for climb animation (can play even without stamina)
		LDA !P2Y					;\
		AND #$F0					; |
		ORA #$06					; | snap to ledge
		STA !P2Y					; |
		STZ !P2YSpeed					; |
		..noledge					;/

		STZ !P2Carry					; can't hold item while climbing
		STZ !P2DashJump
		STZ !P2AirDashUsed
		LDA #$03 : STA !P2WallCoyote
		STZ !P2Dashing

<<<<<<< Updated upstream
		LDA !P2Water				; Check for vine/net climb
		LSR A
		BCC .NoVineClimb
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
		LDA #$01 : TRB !P2Water			; vine/net jump
		LDA #$B8 : STA !P2YSpeed
		LDA #$2B : STA !SPC1			; jump SFX
		RTS
		.NoVineClimb
=======
		..dinogrip
		LDA !P2Anim					;\ can always climb when hanging from a ledge
		CMP #!Lee_WallClimbTop : BEQ ..climb		;/
		LDA !LeewayUpgrades
		AND #$08 : BEQ ..done
		LDA !P2Stamina : BEQ ..done
		..climb
		LDA $15
		AND #$0C
		LSR #2
		TAX
		LDA !P2SwordAttack
		BEQ $02 : LDX #$00
		LDA DATA_ClimbSpeed,x : STA !P2YSpeed
		..done
>>>>>>> Stashed changes


<<<<<<< Updated upstream
		.Air
		LDA !P2CoyoteTime				;\
		BMI ..nope					; |
		BEQ ..nope					; | coyote time
		BIT $6DA7 : BMI .Jump				; |
		..nope						;/

		LDA !P2DashTimerR2 : BNE +
		LDA #$80 : TRB !P2Water
	+	LDA !P2Dashing
		BEQ +
		BMI .Shared
		STA !P2DashJump
		STZ !P2Dashing
		BRA .Shared
	+	LDA !P2ClimbTop : BNE .Shared			; No air attack during get-up
		BIT $6DA7 : BVC .Shared
		LDA !P2Water
		LSR A : BCS .Shared
		LDA !P2SwordAttack : BNE .Shared
		LDA #$04 : STA !P2SwordAttack
		LDA #$3D : STA !SPC4				; slash sfx
		BRA .Shared

		.Ground
		LDA #$78 : STA !P2ClimbTimer
		BIT $6DA7
		BMI .Jump
		BVC .Shared
		LDA !P2SwordAttack
		ORA !P2DashTimerR2
		BNE +
		LDA !P2Dashing : BNE .Shared
		LDA #$01 : STA !P2SwordAttack			; Start attack
		LDA #$3C : STA !SPC4				; slice SFX
	+	RTS

=======
	; dash start check after climb
		.InitDash
		BIT $18 : BPL ..done
		LDA !P2WallClimb				;\ can never dash from wall
		AND #$03 : BNE ..done				;/
		LDA !P2Dashing
		ORA !P2SwordAttack
		BNE ..done
		LDA !P2InAir : BEQ ..allow
		LDX !P2WallClimb : BMI ..allow			; can always dash from ceiling
		AND !LeewayUpgrades : BEQ ..done
		LDA !P2AirDashUsed
		AND #$01 : BNE ..done
		LDA #$01 : TSB !P2AirDashUsed
		..allow
		STA !P2AirDash
		LDX #$28 : STX !P2Dashing			; X = dash timer
		STZ !P2WallClimb				; clear wall climb
		LDA !LeewayUpgrades				;\ see if leeway has brave dash
		AND #$02 : BEQ ..done				;/
		LDA !P2HP					;\ ignore cooldown when at 1 heart or less
		CMP #$04+1 : BCC ..skipcooldown			;/
		LDA !P2BraveDashCooldown : BNE ..done		; no brave dash during cooldown
		..skipcooldown
		STX !P2BraveDash				; set brave dash
		LDA #$78 : STA !P2BraveDashCooldown		; brave dash cooldown = 2 seconds
		..done



	; main jump code
>>>>>>> Stashed changes
		.Jump
		LDA $15						;\
		AND #$80					; | clear jump buffer unless jump is held
		EOR #$80 : TRB !P2Buffer			;/
		LDA !P2Buffer					;\ apply jump buffer
		AND #$80 : TSB $16				;/
		BIT $16 : BPL .JumpDone				; check B
		LDA !P2WallClimb				;\
		AND #$03					; | wall jump clause
		ORA !P2WallCoyote				; |
		BEQ ..nowalljump				;/
		..walljump
		LDA $17
		AND #$80
		STA !P2Dashing
		LDA !P2Anim					;\ don't force directional inputs when jumping from ledge hang
		CMP #!Lee_WallClimbTop : BEQ ..triggerwalljump	;/
		LDA !P2WallJumpDir
		AND #$03
		EOR #$03
		BIT $17
		BPL $02 : ORA #$04
		TAX
		AND #$03 : STA !P2WallJumpInput
		LDA #$10 : STA !P2WallJumpTimer
		LDA DATA_WallJumpSpeed,x : STA !P2XSpeed
		..triggerwalljump
		STZ !P2WallCoyote
		LDA #$C0 : BRA .TriggerJump_main
		..nowalljump

		LDA !P2Climbing : BNE .TriggerJump		;\
		LDA !P2CoyoteTime				; |
		BMI +						; | must be on ground or have coyote time
		BNE .TriggerJump				; | or be climbing
	+	LDA !P2InAir : BNE .JumpDone			;/

		.TriggerJump
		LDA #$B0					; default jump y speed
		..main
		STA !P2YSpeed					; jump y speed
		LDA #$2B : STA !SPC1				; jump SFX
		LDA #$01 : STA !P2JumpHold			; jump hold
		STZ !P2CoyoteTime				; clear coyote time
<<<<<<< Updated upstream
		STZ !P2SwordAttack
		LDA #$B0 : STA !P2YSpeed
		LDA #$2B : STA !SPC1				; jump SFX
		LDA !P2Dashing : BEQ .Shared
		LDA #$01 : STA !P2DashJump

		.Shared
		LDA !P2Dashing
		ORA !P2DashJump
		BEQ .Walk
		BMI .Dash
		LDA !P2DashJump : BEQ .Dash
		LDA $6DA3
		AND #$03
	-	ORA #$04
		BRA +

		.Dash
		LDA $6DA3
		AND #$03
		BNE -
		ORA !P2Direction
		EOR #$01
		INC A
		BRA -

		.Walk
		LDA !P2Blocked
		AND #$04 : BEQ ++
		LDA !P2SwordAttack
		ORA !P2DashTimerR2
		BNE ..R
	++	LDA $6DA3
		AND #$03
	+	TAX
		LDA .XSpeed,x : JSR CORE_SET_XSPEED
		LDA .Direction,x
		BMI $03 : STA !P2Direction
	..R	RTS

		.XSpeed
		db $00,$18,$E8,$00
		db $00,$30,$D0,$00

		.Direction
		db $FF,$01,$00,$FF
		db $FF,$01,$00,$FF
=======
		STZ !P2SwordAttack				; clear sword attack
		STZ !P2Ducking					; clear crouch status
		LDA !P2Dashing : STA !P2DashJump		; dash jump flag
		STZ !P2Dashing					; clear dash
		STZ !P2AirDash					; clear air dash
		STZ !P2WallClimb				; clear wall jump
		.JumpDone


		RTS




>>>>>>> Stashed changes

	PHYSICS:

<<<<<<< Updated upstream
		.ClimbLock
		db $0A,$09
		db $01,$02,$01				; third byte used for easier indexing
=======
		.Gravity
		LDA #$03					; gravity when holding B is 3
		LDY !P2SwordAttack				;\ force low g during ground attack 2
		CPY #$82 : BEQ ..lowg				;/
		BIT $15						;\ gravity without holding B is 6
		BMI $02 : LDA #$06				;/
		..lowg
		LDY #$46					; default fall speed = 0x46
		BIT !P2Water : BVC ..nowater			;\
		..water						; |
		LDY #$24					; | water fall speed = 0x24
		LSR A						; | halve gravity (round down) underwater
		..nowater					;/
		LDX !P2WallClimb : BEQ ..noclimb		;\
		LDY #$10					; | fall speed during wall slide = 0x10
		LDA #$01					; | gravity during wall slide = 0x01
		..noclimb					;/
		STA !P2Gravity					; store gravity
		STY !P2FallSpeed				; store fall speed
		..done
>>>>>>> Stashed changes


<<<<<<< Updated upstream
=======
		.JumpSnap
		LDA !P2JumpHold : BEQ ..done
		LDA $15 : BMI ..done
		STZ !P2JumpHold
		LDA !P2YSpeed : BPL ..done
		CLC : ADC #$20
		BMI $02 : LDA #$00
		STA !P2YSpeed
		..done

>>>>>>> Stashed changes

		.BraveDash
		LDA !P2Dashing : BNE ..process
		STZ !P2BraveDash
		..process
		LDA !P2BraveDash : BEQ ..done			; must be brave dashing
		LDA !P2Anim					;\
		CMP #!Lee_DashTransition : BEQ ..done		; | no i-frames during startup of dash or dash slash
		CMP #!Lee_DashAttack+0 : BEQ ..done		;/
		LDA !P2Dashing
		AND #$03
		ORA #$04
		CMP !P2Invinc : BCC ..done
		STA !P2Invinc
		..done



		.Stamina
<<<<<<< Updated upstream
		LDA !P2Climb : BEQ .NoStamina		;\
		LDA !P2ClimbTimer : BEQ .NoStamina	; |
		LDA !P2XSpeed : BEQ ..nox		; |
		ASL A					; |
		ROL A					; |
		INC A					; |
		EOR !P2Blocked				; |
		AND #$03 : BNE .ClimbTimer		; |
		..nox					; |
		LDA !P2YSpeed : BEQ .NoClimb		; |
		ASL A					; | climb timer
		ROL A					; | (1/16th speed when still)
		INC A					; |
		ASL #2					; |
		EOR !P2Blocked				; |
		AND #$0C : BNE .ClimbTimer		; |
	.NoClimb					; |
		LDA $14					; |
		AND #$0F : BNE .NoStamina		; |
	.ClimbTimer					; |
		DEC !P2ClimbTimer			; |
		.NoStamina				;/




		LDA !P2ClimbTop : BEQ .NoGetUpAttack	;\
		BIT $6DA7 : BVC .NoGetUpAttack		; | Can buffer get-up attack
		LDA #$02 : STA !P2ClimbTop		;/
		.NoGetUpAttack

=======
		LDA !P2WallClimb : BEQ ..done			;\
		LDA !P2Stamina : BEQ ..done			; |
		LDA !P2XSpeed : BEQ ..nox			; |
		ASL A						; |
		ROL A						; |
		INC A						; |
		EOR !P2Blocked					; |
		AND #$03 : BNE ..timer				; |
		..nox						; |
		LDA !P2YSpeed : BEQ ..checkinput		; |
		ASL A						; | climb timer
		ROL A						; | (1/16th speed when still)
		INC A						; |
		ASL #2						; |
		EOR !P2Blocked					; |
		AND #$0C : BNE ..timer				; |
		..checkinput					; |
		LDA $14						; |
		AND #$0F : BNE ..done				; |
		..timer						; |
		DEC !P2Stamina					; |
		..done						;/
>>>>>>> Stashed changes


		LDA !P2SlantPipe : BEQ +
		LDA #$40 : STA !P2XSpeed
		LDA #$C0 : STA !P2YSpeed
		+

<<<<<<< Updated upstream
		LDA !P2Blocked
		AND #$04
		ORA !P2Platform
		BEQ ++
		LDA !P2ClimbTop				;\
		CMP #$02 : BNE +			; | Clear get-up state upon touching the ground
		LDA #$01 : STA !P2SwordAttack		; | (and start attack if buffered)
		LDA #$3C : STA !SPC4			; | (slice SFX)
	+	STZ !P2ClimbTop				;/
		STZ !P2KillCount
		JSR CheckAbove
		BCS .ForceCrouch

		BIT !P2Water : BPL ++
		LDA !P2Blocked
		LDY !P2Platform
		BEQ $02 : ORA #$04
		AND $6DA3
		AND #$04
		BEQ +
		LDA !P2Dashing
		ORA !P2SwordAttack
		BNE +
		BRA .NoForceCrouch

		.ForceCrouch
		LDA #$08 : STA !P2DashTimerR2

		.NoForceCrouch
		STZ !P2YSpeed
		STZ !P2Dashing
		STZ !P2SwordAttack
		STZ !P2DashJump
		LDA #$04 : TSB !P2Blocked
		LDA $6DA3
		AND #$03
		TAX
		LDA CONTROLS_XSpeed,x : JSR CORE_SET_XSPEED
		LDA CONTROLS_Direction,x
		BMI ++
		STA !P2Direction
		BRA ++
	+	LDA !P2DashTimerR2
		BNE ++
		LDA #$80 : TRB !P2Water
		++


	;	LDA !P2Floatiness : BEQ +
	;	BIT $6DA3 : BMI ++
	;	STZ !P2Floatiness
	;	LDA !P2YSpeed
	;	BPL +
	;	EOR #$FF
	;	LSR A
	;	EOR #$FF
	;	STA !P2YSpeed
	;	BRA +
	;++	LDA !P2Blocked
	;	AND #$08 : BEQ +
	;	STZ !P2Floatiness
	;	+

		.HandleDash
		LDA !P2Dashing
		BEQ .NoDash
		BPL .GroundDash
		STZ !P2YSpeed
		BRA .Dash

		.GroundDash
		LDA !P2Blocked
		AND #$04
		ORA !P2Platform
		BEQ .NoDash

		.Dash
		LDA !P2DashSlash : BNE .NoDash
		LDA !P2SwordAttack : BNE .NoDash
		BIT $6DA7 : BVC +
		LDA #$03 : STA !P2SwordAttack
		LDA #$3C : STA !SPC4				; slice SFX
		LDA #$01 : STA !P2DashSlash
		BRA .NoDash
	+	BIT $6DA5 : BMI .NoDash
		LDA #$01 : STA !P2Dashing
		.NoDash


	ATTACKS:
		PEA SPRITE_INTERACTION-1
		LDA !P2SwordAttack
		DEC A
		ASL A
		TAX
		BCC +
		LDA $6DA7 : TSB !P2Buffer		; Allow buffering, but not during frame 1
	+	CPX.b #.End-.Ptr
		BCC .Go
		STZ !P2IndexMem1
		STZ !P2IndexMem2
=======



	SPRITE_INTERACTION:
		JSL CORE_SPRITE_INTERACTION


	UPDATE_SPEED:
		BIT !P2Water : BVC .Move		;\
		LDA !P2XSpeed				; |
		CMP #$80 : ROR A			; |
		CMP #$80 : ROR A			; | reduce x speed by 25% underwater
		EOR #$FF : INC A			; |
		CLC : ADC !P2XSpeed			; |
		STA !P2XSpeed				;/

		.Move
		JSL CORE_UPDATE_SPEED			; apply speed


		.Item
		LDX !P2Carry : BEQ ..done
		JSL CORE_CARRY
		..done


	OBJECTS:
		SEP #$20
		LDA !P2InAir : PHA
		REP #$30
		LDA !P2Anim
		AND #$00FF
		ASL #3
		TAY
		LDA ANIM+$06,y : JSL CORE_COLLISION

		.Climbing
		LDA !P2Climbing : BEQ ..done
		STZ !P2SwordAttack
		STZ !P2SwordTimer
		STZ !P2AirDashUsed
		STZ !P2Dashing
		STZ !P2DashJump
		LDA !LeewayMaxStamina : STA !P2Stamina
		..done


		.Landing
		PLA : BEQ ..done
		LDA !P2InAir : BNE ..done
		..land

		LDA $15					;\
		AND #$04 : BEQ ..grindset		; |
		LDA !P2XSpeed				; |
		CLC : ADC #$38				; |
		CMP #$70 : BCC ..grinddone		; | can start a slide by holding down when landing with high speed
		LDA #$04				; | (always end slide if landing without holding down)
		..grindset				; |
		STA !P2Sliding				; |
		..grinddone				;/

		STZ !P2SwordAttack
		STZ !P2SwordTimer
		..done




	SCREEN_BORDER:
		JSL CORE_SCREEN_BORDER


	ATTACK:
		PEA ANIMATION-1
		LDA !P2SwordAttack
		DEC A
		ASL A : TAX
		CPX.b #.End-.Ptr : BCC .Go
		.Return
		STZ !P2SwordAttack
>>>>>>> Stashed changes
		RTS

		.Go
		JMP (.Ptr,x)

		.Return
		RTS

		.Ptr
		dw .GroundAttack1			; 1
		dw .GroundAttack2			; 2
		dw .DashAttack				; 3
		dw .AirAttack				; 4
		dw .WallAttack				; 5
		dw .CeilingAttack			; 6
		dw .SpinAttack				; 7
		.End

	.GroundAttack1
		LDA !P2SwordTimer
		CMP #$01 : BNE ..nocombo
		BIT !P2Buffer : BVC ..nocombo
		LDA #$02 : STA !P2SwordAttack
		BRA .GroundAttack2
		..nocombo
		LDA !P2SwordAttack : BMI ..main
		..init
		ORA #$80 : STA !P2SwordAttack
		LDA #!Lee_GroundAttack1 : STA !P2Anim
		STZ !P2AnimTimer
<<<<<<< Updated upstream
		LDA #$1E : STA !P2SwordTimer
		..Process
	;	LDX !P2Direction
	;	LDA $6DA3
	;	AND ..Bits,x
	;	BEQ ..ZeroX
	;	LDA !P2Anim
	;	CMP #$07 : BNE ..ZeroX+3
	;	LDA !P2XSpeed
	;	BEQ ..ZeroX+3
	;	BMI ..NegX
	;	..PosX
	;	LDA !P2XSpeed
	;	SEC : SBC #$04
	;	BMI ..ZeroX
	;	STA !P2XSpeed
	;	BRA ..ZeroX+3
	;	..NegX
	;	LDA !P2XSpeed
	;	CLC : ADC #$04
	;	STA !P2XSpeed
	;	BMI ..ZeroX+3
	;	..ZeroX
		LDA #$00 : JSR CORE_SET_XSPEED
=======
		LDA #$14 : STA !P2SwordTimer
		STZ !P2Buffer				; clear buffer when starting the attack
		..main
>>>>>>> Stashed changes
		LDA !P2Anim
		CMP #!Lee_GroundAttack1+1 : BEQ ..hitbox1
		CMP #!Lee_GroundAttack1+2 : BEQ ..hitbox2
		RTS
<<<<<<< Updated upstream
	++	LDA.b #CUT_1-BOX_START : JMP HITBOX
	+	LDA.b #CUT_0-BOX_START : JMP HITBOX

		..Bits
		db $02,$01

		.Slash
		LDA !P2SwordAttack : BMI ..Process
=======
		..hitbox1
		LDA #$3C : STA !SPC4			; slice SFX
		LDY #$00 : JMP HITBOX
		..hitbox2
		LDY #$02 : JMP HITBOX

	.GroundAttack2
		LDA !P2SwordAttack : BMI ..main
		..init
>>>>>>> Stashed changes
		ORA #$80 : STA !P2SwordAttack
		LDA #$E0 : STA !P2YSpeed
		LDA #!Lee_GroundAttack2 : STA !P2Anim
		STZ !P2AnimTimer
<<<<<<< Updated upstream
		LDA #$18 : STA !P2SwordTimer
		STZ !P2IndexMem1
		STZ !P2IndexMem2
		..Process
	;	LDX !P2Direction
	;	LDA $6DA3
	;	AND .Cut_Bits,x
	;	BEQ ..ZeroX
	;	LDA !P2Anim
	;	CMP #$07 : BNE ..ZeroX+3
	;	LDA !P2XSpeed
	;	BEQ ..ZeroX+3
	;	BMI ..NegX
	;	..PosX
	;	LDA !P2XSpeed
	;	SEC : SBC #$04
	;	BMI ..ZeroX
	;	STA !P2XSpeed
	;	BRA ..ZeroX+3
	;	..NegX
	;	LDA !P2XSpeed
	;	CLC : ADC #$04
	;	STA !P2XSpeed
	;	BMI ..ZeroX+3
	;	..ZeroX
		LDA #$00 : JSR CORE_SET_XSPEED
=======
		LDA #$0C : STA !P2SwordTimer
		STZ !P2Hitbox1IndexMem1
		STZ !P2Hitbox1IndexMem2
		STZ !P2Hitbox2IndexMem1
		STZ !P2Hitbox2IndexMem2
		..main
>>>>>>> Stashed changes
		LDA !P2Anim
		CMP #!Lee_GroundAttack2 : BEQ ..hitbox1
		CMP #!Lee_GroundAttack2+1 : BEQ ..hitbox2
		RTS
<<<<<<< Updated upstream
	++	LDA.b #SLASH_1-BOX_START : JMP HITBOX
	+	LDA.b #SLASH_0-BOX_START : JMP HITBOX
=======
		..hitbox1
		LDA #$3D : STA !SPC4			; slash SFX
		LDY #$04 : JMP HITBOX
		..hitbox2
		LDY #$06 : JMP HITBOX
>>>>>>> Stashed changes

	.DashAttack
		LDA !P2SwordAttack : BMI ..main
		..init
		ORA #$80 : STA !P2SwordAttack
		LDA #!Lee_DashAttack : STA !P2Anim
		STZ !P2AnimTimer
		LDA #$14 : STA !P2SwordTimer
		..main
		LDA !P2Dashing : BEQ .ClearAttack
		LDA #$04 : TSB !P2Dashing
		LDA !P2SwordTimer : STA !P2Dashing
		LDA !P2Anim
		CMP #!Lee_DashAttack+1 : BEQ ..hitbox1
		CMP #!Lee_DashAttack+2 : BEQ ..hitbox2
		RTS
		..hitbox1
		LDA #$3C : STA !SPC4			; slice SFX
		LDY #$08 : JMP HITBOX
		..hitbox2
		LDY #$0A : JMP HITBOX

	.AirAttack
		LDA !P2SwordAttack : BMI ..main
		..init
		ORA #$80 : STA !P2SwordAttack
		LDA #!Lee_AirAttack : STA !P2Anim
		STZ !P2AnimTimer
		LDA #$1A : STA !P2SwordTimer
<<<<<<< Updated upstream
		..Process
		LDA !P2Anim
		CMP #!Lee_DashSlash+1 : BEQ +
		CMP #!Lee_DashSlash+2 : BEQ ++
		RTS
	++	LDA.b #DASHSLASH_1-BOX_START : JMP HITBOX
	+	LDA.b #DASHSLASH_0-BOX_START : JMP HITBOX
=======
		..main
		LDA !P2Anim
		CMP #!Lee_AirAttack+5 : BEQ ..hitbox1
		CMP #!Lee_AirAttack+6 : BEQ ..hitbox2
		RTS
		..hitbox1
		LDA #$3D : STA !SPC4			; slash SFX
		LDY #$0C : JMP HITBOX
		..hitbox2
		LDY #$0E : JMP HITBOX
>>>>>>> Stashed changes

	.ClearAttack
		STZ !P2SwordAttack
		STZ !P2SwordTimer
		RTS

	.WallAttack
		LDA !P2SwordAttack : BMI ..main
		..init
		ORA #$80 : STA !P2SwordAttack
		LDA #!Lee_WallAttack : STA !P2Anim
		STZ !P2AnimTimer
		LDA #$14 : STA !P2SwordTimer
		..main
		LDA !P2WallClimb
		AND #$03 : BEQ .ClearAttack
		LDA !P2Anim
		CMP #!Lee_WallAttack+2 : BEQ ..hitbox1
		CMP #!Lee_WallAttack+3 : BEQ ..hitbox2
		RTS
<<<<<<< Updated upstream
	++	LDA.b #AIRSLASH_1-BOX_START : JMP HITBOX
	+	LDA.b #AIRSLASH_0-BOX_START : JMP HITBOX
=======
		..hitbox1
		LDA #$3D : STA !SPC4			; slash SFX
		LDY #$10 : JMP HITBOX
		..hitbox2
		LDY #$12 : JMP HITBOX
>>>>>>> Stashed changes

	.CeilingAttack
		LDA !P2SwordAttack : BMI ..main
		..init
		ORA #$80 : STA !P2SwordAttack
		LDA #!Lee_CeilingAttack : STA !P2Anim
		STZ !P2AnimTimer
<<<<<<< Updated upstream
		LDA #$1C : STA !P2SwordTimer
		..Process
		LDA !P2Direction
		EOR #$01
		TAX
		LDA CONTROLS_ClimbLock+2,x
		STA !P2DashTimerL1
		LDA #$03 : STA !P2DashTimerL2
		LDA CONTROLS_ClimbX+2,x : STA !P2XSpeed
=======
		LDA #$14 : STA !P2SwordTimer
		..main
		LDA !P2WallClimb : BPL .ClearAttack
		STZ !P2XSpeed
>>>>>>> Stashed changes
		LDA !P2Anim
		CMP #!Lee_CeilingAttack+1 : BEQ ..hitbox1
		CMP #!Lee_CeilingAttack+2 : BEQ ..hitbox2
		RTS
<<<<<<< Updated upstream
	++	LDA.b #WALLSLASH_1-BOX_START : JMP HITBOX
	+	LDA.b #WALLSLASH_0-BOX_START : JMP HITBOX
=======
		..hitbox1
		LDA #$3D : STA !SPC4			; slash SFX
		LDY #$14 : JMP HITBOX
		..hitbox2
		LDY #$16 : JMP HITBOX
>>>>>>> Stashed changes

	.SpinAttack
		LDA !P2SwordAttack : BMI ..main
		..init
		ORA #$80 : STA !P2SwordAttack
		LDA #!Lee_SpinAttack : STA !P2Anim
		STZ !P2AnimTimer
<<<<<<< Updated upstream
		LDA #$16 : STA !P2SwordTimer
		..Process
=======
		LDA #$1A : STA !P2SwordTimer
		..main
		LDA $14
		AND #$03 : BNE ..nosfx
		LDA #$3D : STA !SPC4			; slash SFX
		..nosfx
>>>>>>> Stashed changes
		LDA !P2Anim
		SEC : SBC #!Lee_SpinAttack
		ASL A : ADC #$18
		CMP #$1F : BCS ..end
		TAY
		JMP HITBOX

		..end
		STZ !P2SwordAttack
		STZ !P2SwordTimer
		RTS
<<<<<<< Updated upstream
	++	LDA.b #HANGSLASH_1-BOX_START : JMP HITBOX
	+	LDA.b #HANGSLASH_0-BOX_START : JMP HITBOX


	SPRITE_INTERACTION:
		JSR CORE_SPRITE_INTERACTION


	EXSPRITE_INTERACTION:
		JSR CORE_EXSPRITE_INTERACTION


	UPDATE_SPEED:
		LDA #$46 : STA !P2FallSpeed	; normal fall speed is 0x46
		LDA #$03			; gravity is 3 when holding B
		BIT $6DA3			;\ gravity is 6 when not holding B
		BMI $02 : LDA #$06		;/
		BIT !P2Water : BVC .G		;\
		LSR A				; | in water, gravity is halved (rounded up)
		BCC $01 : INC A			;/
		LDX #$30 : STX !P2FallSpeed	; in water, fall speed is 0x30
	.G	STA !P2Gravity			; store gravity


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
		LDA !LeewayUpgrades
		AND #$10 : BEQ .NoCape
		LDA $6DA3 : BPL .NoCape
		AND #$04 : BNE .NoCape
		LDA !P2YSpeed : BMI .NoCape
		CMP #$20 : BCC .NoCape
		LDA #$20 : STA !P2YSpeed
		.NoCape




		BIT !P2Water : BVC +
		LDA !P2YSpeed : BMI +
		CMP #$28 : BCC +
		LDA #$28 : STA !P2YSpeed
	+	JSR CORE_UPDATE_SPEED
		LDA !P2Platform : BEQ +
		LDA #$04 : TSB !P2Blocked
	+	BIT !P2Water : BVC +
		LDA !P2Blocked
		AND #$04 : BNE +
		DEC !P2YSpeed
		+

		LDA !P2Climb				;\
		AND #$02 : BEQ +			; |
		PHP : REP #$20				; | Put Leeway 1px further left when sticking to left wall
		DEC !P2XPosLo				; |
		PLP					; |
		+					;/

	OBJECTS:
		REP #$30
		LDA !P2Anim
		AND #$00FF
		ASL #3
		TAY
		LDA ANIM+$06,y				;\
		STA $F0					; |
		CLC : ADC #$0004			; | Pointers to clipping
		STA $F2					; |
		CLC : ADC #$0004			; |
		STA $F4					;/
		SEP #$30
		LDA !P2Blocked : PHA
		JSR CORE_LAYER_INTERACTION
=======


>>>>>>> Stashed changes

		LDA !P2PrevPlatform : BNE +
		LDA !P2Platform
		ORA !P2SpritePlatform
		BEQ +
		PLA : BRA .Landing

	+	PLA
		EOR !P2Blocked
		AND #$04 : BEQ .End
		LDA !P2Blocked
		AND #$04 : BEQ .End
		BIT !P2Climb : BMI .End

		.Landing
		LDA !P2SwordAttack
		AND #$7F
		CMP #$04 : BNE ..cancel
		LDA !P2SwordTimer
		SEC : SBC #$08
		BMI ..cancel
		STA !P2SwordTimer
		LDA !P2SwordAttack
		AND #$80
		ORA #$02
		STA !P2SwordAttack
		LDA !P2Anim
		SEC : SBC #(!Lee_AirSlash-!Lee_Slash)
		STA !P2Anim
		STZ !P2AnimTimer
		BRA ..landlag

	..cancel
		STZ !P2SwordAttack
		STZ !P2SwordTimer
	..landlag
		STZ !P2Dashing
		STZ !P2SenkuUsed
		STZ !P2DashJump
		STZ !P2Climb

		.End

		JSR CORE_CLIMB_GROUND

	SCREEN_BORDER:
		JSR CORE_SCREEN_BORDER

	ANIMATION:
		.External
		LDA !P2ExternalAnimTimer			;\
		BEQ ..clear					; |
		DEC !P2ExternalAnimTimer			; | enforce external animations
		LDA !P2ExternalAnim : STA !P2Anim		; |
		DEC !P2AnimTimer				; |
		JMP .CheckPlayer				;/
		..clear						;\ clear when timer runs out
		STZ !P2ExternalAnim				;/

<<<<<<< Updated upstream
		LDA !P2HurtTimer
		BEQ .NoHurt
		LDA #!Lee_Hurt : STA !P2Anim
		JMP .HandleUpdate
		.NoHurt

		LDA !P2DashTimerR2
		BEQ $03 : JMP .Crouch
=======
	; pipe check
		.Pipe
		LDA !P2Pipe					;\
		BEQ ..done					; |
		BMI ..vert					; |
		..horz						; | pipe animations
		JMP .Walk					; |
		..vert						; |
		LDA #!Lee_Victory+1 : BRA .SetAnim		; |
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
		CMP #!Lee_Victory : BCC ..set			; |
		CMP #!Lee_Victory_over : BCC .GoToDraw		; | set animation
		..set						; |
		LDA #!Lee_Victory : BRA .SetAnim		; |
		..done						;/


	; hurt check
		.Hurt
		LDA !P2HurtTimer : BEQ ..done			;\
		LDA #!Lee_Hurt : BRA .SetAnim			; | hurt animation
		..done						;/


	; sword check
		.SwordAttack
		LDA !P2SwordAttack : BEQ .NoSword
		JMP .CheckPlayer

>>>>>>> Stashed changes

	; branch assist
		.SetAnim
		STA !P2Anim
		STZ !P2AnimTimer
		.GoToDraw
		JMP .CheckPlayer

<<<<<<< Updated upstream
		LDA !P2ClimbTop : BEQ .NoGetUp
		LDA #!Lee_ClimbTop : STA !P2Anim
		LDA #$10 : STA !P2AnimTimer
		.NoGetUp
=======
		.NoSword
>>>>>>> Stashed changes


	; kick / throw animations
		.Kick
		LDA !P2KickTimer : BEQ ..done			;\
		LDA #!Lee_Kick : BRA .SetAnim			; | kick
		..done						;/


<<<<<<< Updated upstream
		LDA !P2Climb
		BEQ .NoClimb
		BMI .Ceiling
=======
	; climb checks
		.Climb
		LDA !P2Climbing : BNE .ClimbBG
		LDA !P2WallClimb
		BMI .ClimbCeiling
		BNE .ClimbWall
		JMP .ClimbDone

		.ClimbWall
		LDY !P2Anim					; anim checked in Y here
		LDA $15						;\ ignore climb top check if holding down
		AND #$04 : BNE +				;/
		CPY #!Lee_WallClimbTop : BEQ .GoToDraw		; climb top frame 1 has priority
	+	LDA !LeewayUpgrades
		AND #$08 : BNE ..dinogrip
		LDA !P2WallAnim : BNE ..climbanim
		JSL CORE_SMOKE_AT_WALL
		BRA ..idle
		..dinogrip
		LDA !P2Stamina : BEQ ..rapidanim
		..climbanim
		LDA !P2Y
		AND #$1F
		EOR #$1F
		LSR #3 : BRA ..getanim
		..idle
		LDA #$00
		..getanim
		CLC : ADC.b #!Lee_WallClimb
		BRA .SetAnim
		..rapidanim
		JSL CORE_SMOKE_AT_WALL
		LDY !P2Anim					; anim checked in Y here
		CPY #!Lee_WallClimb : BCC ..set
		CPY #!Lee_WallClimb_over : BCC .GoToDraw2
		..set
		LDA #!Lee_WallClimb : BRA .SetAnim2

		.ClimbCeiling
		LDA !P2XSpeed : BNE ..moving
		..idle
		LDA #!Lee_CeilingHang : BRA .SetAnim2
		..moving
>>>>>>> Stashed changes
		LDA !P2Anim
		CMP #!Lee_CeilingClimb : BCC ..set
		CMP #!Lee_CeilingClimb_over : BCC .GoToDraw2
		..set
		LDA #!Lee_CeilingClimb : BRA .SetAnim2

<<<<<<< Updated upstream

		.Ceiling
		LDA !P2XSpeed
		BEQ -
		LDA !P2Anim
		CMP #!Lee_Ceiling : BCC +
		CMP #!Lee_Ceiling+6 : BCS +
		JMP .HandleUpdate
	+	LDA #!Lee_Ceiling : STA !P2Anim
=======
		.ClimbBG
		LDA !P2Anim
		CMP #!Lee_ClimbBG : BCC ..startclimb
		CMP #!Lee_ClimbBG_over : BCC ..climbing
		..startclimb
		LDA #!Lee_ClimbBG : BRA .SetAnim2
		..climbing
		LDA $15
		AND #$0F : BNE .GoToDraw2
		STZ !P2AnimTimer
		JMP .CheckPlayer

	; branch support
		.SetAnim2
		STA !P2Anim
>>>>>>> Stashed changes
		STZ !P2AnimTimer
		.GoToDraw2
		JMP .CheckPlayer

		.ClimbDone

<<<<<<< Updated upstream
		LDA !P2Water
		LSR A
		BCC .NoVineClimb
		LDA !P2Anim
		CMP #!Lee_ClimbBG : BEQ +
		CMP #!Lee_ClimbBG+1 : BEQ +
		LDA #!Lee_ClimbBG : STA !P2Anim
		STZ !P2AnimTimer
	+	LDA $6DA3
		AND #$0F
		BNE +
		STZ !P2AnimTimer
	+	JMP .HandleUpdate
		.NoVineClimb
=======
	; climb top
		.ClimbTop
		LDA !P2Anim
		CMP #!Lee_WallClimbTop : BCC ..done
		CMP #!Lee_WallClimbTop_over : BCC .GoToDraw2
		..done
>>>>>>> Stashed changes


	; dash check
		.Dash
<<<<<<< Updated upstream
		LDA !P2Anim
		CMP #!Lee_Dash : BCC +
		CMP #!Lee_Dash+3 : BCS +
		JMP .HandleUpdate
	+	LDA #!Lee_Dash : STA !P2Anim
		STZ !P2AnimTimer
		JMP .HandleUpdate

		.NoDash
		LDA !P2Blocked
		AND #$04
		ORA !P2Platform
		ORA !P2SpritePlatform
		BNE .Ground
=======
		LDA !P2Dashing : BEQ ..done
		JSL CORE_SMOKE_AT_FEET
		LDA !P2Anim
		CMP #!Lee_DashTransition : BCC ..set
		CMP #!Lee_Dash_over : BCC .GoToDraw2
		..set
		LDA #!Lee_DashTransition : BRA .SetAnim2
		..done

	; slide check
		.Slide
		LDA !P2Sliding : BEQ ..done
		JSL CORE_SMOKE_AT_FEET
		LDA !P2Anim
		LDY !P2InAir : BEQ ..ground
		LDY !P2XSpeed
		CPY #$11 : BCC ..set0
		CPY #$41 : BCC ..surf1
		CPY #$F0 : BCS ..set0
		CPY #$C0 : BCS ..surf1
		BRA ..surf2
		..ground
		LDY !P2Slope : BNE ..checkslope
		..set0
		LDA #!Lee_Surf0 : BRA .SetAnim2
		..checkslope
		CPY #$03 : BEQ ..surf2
		CPY #$FD : BEQ ..surf2
		..surf1
		CMP #!Lee_Surf1 : BCC ..set1
		CMP #!Lee_Surf1_over : BCC .GoToDraw2
		..set1
		LDA #!Lee_Surf1 : BRA .SetAnim2
		..surf2
		CMP #!Lee_Surf2 : BCC ..set2
		CMP #!Lee_Surf2_over : BCC .GoToDraw2
		..set2
		LDA #!Lee_Surf2 : BRA .SetAnim2
		..done

>>>>>>> Stashed changes

	; air/ground split
		LDA !P2InAir : BEQ .Ground

	; air only animations
		.Air

		.DoubleJump
		LDA !P2Anim
		CMP #!Lee_DoubleJump : BCC ..done
		CMP #!Lee_DoubleJump_over : BCC .GoToDraw3
		..done

		BIT !P2YSpeed : BPL .Falling

		.Jump
		LDA #!Lee_Jump : BRA .SetAnim3

		.Falling
<<<<<<< Updated upstream
		LDA !LeewayUpgrades				; check for slow fall upgrade
		AND #$10 : BEQ ..fast
		BIT $6DA3 : BPL ..fast
	..slow	LDA !P2Anim
		CMP #!Lee_SlowFall : BCC +
		CMP #!Lee_SlowFall+3 : BCC -
	+	LDA #!Lee_SlowFall : BRA ++
	..fast	LDA !P2Anim
		CMP #!Lee_Fall : BEQ .HandleUpdate
		CMP #!Lee_Fall+1 : BEQ .HandleUpdate
		LDA #!Lee_Fall
	++	STA !P2Anim
=======
		LDA !P2Anim
		CMP #!Lee_Fall : BCC ..set
		CMP #!Lee_Fall_over : BCC .GoToDraw3
		..set
		LDA #!Lee_Fall : BRA .SetAnim3


	; branch assist 2
		.SetAnim3
		STA !P2Anim
>>>>>>> Stashed changes
		STZ !P2AnimTimer
		.GoToDraw3
		JMP .CheckPlayer


	; ground only animations
		.Ground
<<<<<<< Updated upstream
		BIT !P2Water : BPL .NoCrawl
=======
>>>>>>> Stashed changes

	; crouch/crawl animation
		.Crouch
<<<<<<< Updated upstream
		LDA !P2XSpeed
		BNE .Crawl
		LDA !P2Anim
		CMP #!Lee_Crouch : BEQ .Crawl
		CMP #!Lee_Crouch+1 : BEQ .Crawl
		DEC !P2AnimTimer
=======
		LDA !P2Ducking : BEQ ..done			; not crouching -> skip
		LDA !P2Anim					;\
		CMP #!Lee_CrouchTransition : BCC ..set		; | enforce crawl animation
		CMP #!Lee_Crouch_over : BCS ..set		;/
		CMP #!Lee_Crouch : BCC ..update			; can't freeze during transition anim
		LDA $15						;\
		AND #$03 : BNE .CheckPlayer			; |
		DEC !P2AnimTimer				; | freeze when not moving
		..update					; |
		BRA .CheckPlayer				;/
		..set						;\
		LDA #!Lee_CrouchTransition : BRA .SetAnim3	; | set
		..done						;/


	; prioritize crouch and dash transition frames over idle/walk
		.CrouchToStand
		LDA !P2Anim
		CMP #!Lee_CrouchTransition+1 : BEQ .CheckPlayer
		CMP #!Lee_CrouchTransition : BCC ..done
		CMP #!Lee_Crouch_over : BCS ..done
		LDA #!Lee_CrouchTransition+1 : BRA .SetAnim3
		..done
>>>>>>> Stashed changes

		.DashToStand
		CMP #!Lee_DashTransition+1 : BEQ .CheckPlayer
		CMP #!Lee_Dash : BCC ..done
		CMP #!Lee_Dash_over : BCS ..done
		LDA #!Lee_DashTransition+1 : BRA .SetAnim3
		..done


<<<<<<< Updated upstream
	+	CMP #!Lee_CrouchEnd : BEQ .HandleUpdate
		LDA !P2XSpeed
		BNE .Walk
=======
	; idle/walk check
		.Standing
		LDA !P2XSpeed : BNE .Walk

		.Idle
>>>>>>> Stashed changes
		LDA !P2Anim
		INC !P2IdleTimer
		LDY !P2IdleTimer : BEQ ..transition
		CPY #$40 : BCC ..normal
		..transition
		CMP #!Lee_Idle1_over : BCS ..2
		..1
		CPY #$00 : BNE ..normal
		LDA #!Lee_IdleTransition : BRA ..settransition
		..2
		CPY #$40 : BNE ..normal
		LDA #!Lee_IdleTransition+1
		..settransition
		STZ !P2IdleTimer
		BRA .SetAnim3
		..normal
		CMP #!Lee_Idle2_over : BCC .CheckPlayer
		STZ !P2Anim
		STZ !P2AnimTimer
		BRA .CheckPlayer

		.Walk
		LDA !P2Anim
<<<<<<< Updated upstream
		CMP #!Lee_Walk : BCC +
		CMP #!Lee_Walk+4 : BCC .HandleUpdate
	+	LDA #!Lee_Walk : STA !P2Anim
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
		CMP #!Lee_Walk : BCC ..set
		CMP #!Lee_Walk_over : BCC .CheckPlayer
		..set
		LDA #!Lee_Walk : STA !P2Anim
		STZ !P2AnimTimer


	; unpack
	.CheckPlayer
		LDA !MultiPlayer : BEQ ..thisone		; animate at 60fps on single player
		LDA $14
		AND #$01
		CMP !CurrentPlayer : BEQ ..thisone
		..otherone
>>>>>>> Stashed changes
		REP #$30
		LDA !P2Anim2
		AND #$00FF
		ASL #3 : TAY
		BRA GRAPHICS
		..thisone
		LDA !P2Anim : STA !P2Anim2
		REP #$30
<<<<<<< Updated upstream
		LDA ANIM+$04,y : STA $00		; (we're gonna overwrite $00-$03 soon so this is fine)


; -- dynamo format --
;
; 1 byte header (size)
; for each upload:
; 	cccssss-
; 	Bccccccc
; 	ttttt---
;
; ssss:		DMA size (shift left 3)
; cccccccccc:	character (shift left 1 for source address)
; B:		bank (add 1 to source bank when set)
; ttttt:	tile number (shift left 1 then add VRAM offset)


		PHY
		LDA ($00)				;\
		AND #$00FF				; |
		STA $02					; |
		LDX #$0000				; |
		LDY #$0000				; |
		INC $00					; |
	-	LDA ($00),y				; |
		AND #$001E				; |
		ASL #4					; |
		STA !BigRAM+$00+2,x			; |
		LDA ($00),y : BPL .Swd			; |
	.Body	AND #$7FE0				; |
		ORA #$8000				; |
		STA !BigRAM+$02+2,x			; |
		LDA #$0035 : BRA .Shared		; |
	.Swd	AND #$7FE0				; |
		ORA #$8008				; |
		STA !BigRAM+$02+2,x			; |
		LDA #$0034				; | unpack dynamo data
	.Shared	STA !BigRAM+$04+2,x			; |
		INY #2					; |
		LDA ($00),y				; |
		ASL A					; |
		AND #$01F0				; |
		ORA #$6200				; |
		STA !BigRAM+$05+2,x			; |
		INY					; |
		TXA					; |
		CLC : ADC #$0007			; |
		TAX					; |
		CPY $02 : BCC -				;/
		STX !BigRAM+0				; > set size

		LDA.w #!BigRAM : JSR CORE_GENERATE_RAMCODE
=======
		AND #$00FF
		ASL #3 : TAY
		LDA ANIM+$04,y : STA $00			; dynamo (we're gonna overwrite $00-$03 soon so this is fine)
		PHY
		LDY.w #!File_Leeway : JSL GetFileAddress	; primary file
		LDA.w #!File_Leeway_Sword : STA !FileAddress+4	; second file
		LDA $00 : JSL CORE_GENERATE_RAMCODE_24bit
>>>>>>> Stashed changes
		REP #$30
		PLY


	GRAPHICS:
		LDA ANIM+$00,y : STA $E0			; $E0 = body tilemap
		LDA SWORD+$00,y : STA $E2			; $E2 = sword tilemap
		LDA SWORD+$02,y : STA $E4			; $E4 = sword offsets
		LDA SWORD+$04,y					;\ $E6 = sword priority setting
		AND #$00FF : STA $E6				;/
		LDA SWORD+$06,y : STA $E8			; $E8 = held item offsets
		SEP #$30
<<<<<<< Updated upstream
		LDA !P2HurtTimer : BNE .DrawTiles
		LDA !P2ComboDisable : BNE .DrawTiles	; always draw during combo dash invinc
		LDA !P2Invinc
		BEQ .DrawTiles
		AND #$06
		BNE .DrawTiles
		PLB
		RTS


		.DrawTiles
		REP #$30				; > Regs 16 bit
		LDA $06 : BEQ .SwordPrio

		.BodyPrio
		LDA #$6082 : STA $04			; > Pointer to tilemap assembly area
		LDA ($0E)				;\
		CLC : ADC ($00)				; |
		STA $6080				; |
		LDA ($0E)				; | Set up header and increment pointer
		INC $0E : INC $0E			; |
		TAY					; |
		DEY #2					;/
	-	LDA ($0E),y : STA ($04),y		;\
		DEY #2					; | Upload body tilemap
		BPL -					;/
		LDA #$6080 : STA $04			; > Tilemap always at $6080
		LDX $6080				;\
		LDA ($00)				; |
		INC $00 : INC $00			; |
		TAY					; | Set up sword upload
		SEP #$30				; |
		DEY : BMI .NoSword			; |
		DEX					;/
	-	LDA ($00),y				;\
		STA $6082,x				; | > Tile number
		DEX : DEY				; |
		LDA ($00),y				; |
		CLC : ADC $03				; | > Add Y disp
		STA $6082,x				; |
		DEX : DEY				; |
		LDA ($00),y				; |
		CLC : ADC $02				; | > Add X disp
		STA $6082,x				; |
		DEX : DEY				; |
		LDA ($00),y				; |
		STA $6082,x				; | > Prop
		DEX : DEY				; |
		BPL -					;/
		BRA .NoSword				; > End

		.SwordPrio
		LDA ($00)				;\
		CLC : ADC #$6082			; | Pointer to assembly area for body tilemap
		STA $04					;/
		LDA ($0E)				;\
		CLC : ADC ($00)				; |
		STA $6080				; | Set up header and increment pointer
		INC $0E : INC $0E			; |
		TAY					; |
		DEY #2					;/
	-	LDA ($0E),y : STA ($04),y		;\
		DEY #2					; | Upload body tilemap
		BPL -					;/
		LDA ($00) : TAY				;\
		INC $00 : INC $00			; | Set up sword upload
		LDA #$6080 : STA $04			; > Tilemap always at $6080
		SEP #$30				; |
		DEY : BMI .NoSword			;/
	-	LDA ($00),y				;\
		STA $6082,y				; | > Tile number
		DEY					; |
		LDA ($00),y				; |
		CLC : ADC $03				; | > Add Y disp
		STA $6082,y				; |
		DEY					; |
		LDA ($00),y				; |
		CLC : ADC $02				; | > Add X disp
		STA $6082,y				; |
		DEY					; |
		LDA ($00),y : STA $6082,y		; | > Prop
		DEY					; |
		BPL -					;/
		.NoSword


		JSR CORE_LOAD_TILEMAP
=======

	; set carried item position
		.Carry
		LDX !P2Carry : BEQ ..done			; check if carrying item
		DEX						; X = carried sprite index
		LDA $E8						;\
		LDY !P2Dir					; | get lo byte of x offset
		BEQ $03 : EOR #$FF : INC A			; |
		STA $00						;/
		LDA $E9						;\
		STZ $03						; |
		BPL $02 : DEC $03				; |
		CLC : ADC !P2YLo				; | apply y offset
		STA !SpriteYLo,x				; |
		LDA $03						; |
		ADC !P2YHi					; |
		STA !SpriteYHi,x				;/
		LDA $00						;\
		STZ $01						; | get hi byte of x offset
		BPL $02 : DEC $01				;/  (doing it here is a little faster)
		CLC : ADC !P2XLo				;\
		STA !SpriteXLo,x				; |
		LDA $01						; | apply x offset
		ADC !P2XHi					; |
		STA !SpriteXHi,x				;/
		..done


		REP #$20
		LDA $E6 : BNE .DrawBody				; 00 = hi prio sword, 01 = lo prio sword

		.HiPrioSword
		LDA $E2 : BEQ ..done
		STA $04
		LDA !P2X : PHA
		LDA !P2Y : PHA
		LDA $E4
		LDX !P2Dir
		BEQ $04 : EOR #$FFFF : INC A
		AND #$00FF
		CMP #$0080
		BCC $03 : ORA #$FF00
		CLC : ADC !P2X
		STA !P2X
		LDA $E5
		AND #$00FF
		CMP #$0080
		BCC $03 : ORA #$FF00
		CLC : ADC !P2Y
		STA !P2Y
		JSL CORE_LOAD_TILEMAP
		REP #$20
		PLA : STA !P2Y
		PLA : STA !P2X
		..done

		.DrawBody
		LDA $E0 : STA $04
		SEP #$20
		LDA !P2HurtTimer : BNE ..draw
		LDA !P2Invinc : BEQ ..draw
		LSR #3 : TAX
		LDA.l $00E292,x
		AND !P2Invinc : BEQ ..done
		..draw
		JSL CORE_LOAD_TILEMAP
		..done

		.LoPrioSword
		LDA $E6 : BEQ ..done				; 00 = hi prio sword, 01 = lo prio sword
		REP #$20
		LDA $E2 : BEQ ..done
		STA $04
		LDA !P2X : PHA
		LDA !P2Y : PHA
		LDA $E4
		LDX !P2Dir
		BEQ $04 : EOR #$FFFF : INC A
		AND #$00FF
		CMP #$0080
		BCC $03 : ORA #$FF00
		CLC : ADC !P2X
		STA !P2X
		LDA $E5
		AND #$00FF
		CMP #$0080
		BCC $03 : ORA #$FF00
		CLC : ADC !P2Y
		STA !P2Y
		JSL CORE_LOAD_TILEMAP
		REP #$20
		PLA : STA !P2Y
		PLA : STA !P2X
		..done


		.Done
		SEP #$30
		LDX !P2Carry : BEQ OUTPUT_HURTBOX
		DEX
		LDA !P2X


	OUTPUT_HURTBOX:
		JSL CORE_FLASHPAL
		REP #$30
		LDA.w #ANIM
		JSL CORE_OUTPUT_HURTBOX
>>>>>>> Stashed changes
		PLB
		RTS


; JSR-ables

; input: Y = hitbox index
	HITBOX:
<<<<<<< Updated upstream
		LDY !P2SwordTimer
		BNE .Process
		RTS

		.Process
		TAY
		JSR CORE_ATTACK_Setup

		LDA !P2Direction
		BEQ $06 : INY #6

	;	LDA !P2SwordAttack
	;	AND #$7F
	;	DEC A
	;	ASL A
	;	CLC : ADC !P2Direction
	;	ASL A
	;	STA $00
	;	ASL A
	;	CLC : ADC $00
	;	TAY
		REP #$20
		LDA !P2XPosLo
		CLC : ADC CUT+0,y
		STA $00
		STA $07
		STA !P2Hitbox+0
		LDA !P2YPosLo
		CLC : ADC CUT+2,y
		STA !P2Hitbox+2
		SEP #$20
		STA $01
		XBA
		STA $09
		LDA CUT+4,y
		STA $02
		STA !P2Hitbox+4
		LDA CUT+5,y
		STA $03
		STA !P2Hitbox+5

		LDX #$0F

		.Loop
		CPX #$08				;\
		BCS +					; |
		LDA !P2IndexMem1			; |
		BRA ++					; | Check index memory
	+	LDA !P2IndexMem2			; |
	++	AND CORE_BITS,x				; |
		BNE .LoopEnd				;/

		LDA $35F0,x
		BNE .LoopEnd

		LDA !AnimToggle				;\ If animation is off, there's an advanced enemy nearby
		BEQ .Normal				;/

		.Advanced
		LDA $3230,x
		CMP #$08 : BCC .LoopEnd
		LDA !ExtraBits,x
		AND #$08
		BEQ +
		LDA !NewSpriteNum,x
		CMP #$08
		BNE +
		JSR CaptainWarrior
		BRA ++

		.Normal
		LDA $3230,x
		CMP #$08 : BCC .LoopEnd
	+	JSL $03B69F
	++	JSL $03B72B
		BCC .LoopEnd

		JSR CORE_ATTACK_Setup

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
=======
		REP #$20
		LDA HitboxTable,y
		.SetHitbox
		JSL CORE_ATTACK_LoadHitbox
		.Return
>>>>>>> Stashed changes
		REP #$20
		LDA HIT_Ptr+0,y
		DEC A
		PHA
		SEP #$20
		CPY #$00 : BEQ .NoHit
		LDA #$08 : STA !P2ComboDash
		.NoHit
		RTS

		.LoopEnd
		DEX : BPL .Loop

<<<<<<< Updated upstream
		.Return
		RTS

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


	; Hitbox format is Xdisp (lo+hi), Ydisp (lo+hi), width, height.
	BOX_START:
	CUT:
	.0					; Start at sword coords + 1;4
	dw $FFED,$FFF6 : db $3F,$10		; Left
	dw $FFE4,$FFF6 : db $3F,$10		; Right
	.1					; Start at sword coords + 3;4
	dw $FFFF,$FFF6 : db $2D,$10		; Left
	dw $FFE4,$FFF6 : db $2D,$10		; Right

	SLASH:
	.0					; Start at sword coords + 3;-20 (sword, not lil' cut tile)
	dw $FFDE,$FFDE : db $30,$38		; Left
	dw $0002,$FFDE : db $30,$38		; Right
	.1					; Start at sword coords + 5;8
	dw $FFEB,$000E : db $23,$08		; Left
	dw $0002,$000E : db $23,$08		; Right

	DASHSLASH:
	.0					; Start at sword coords + 1;4
	dw $FFEC,$FFF4 : db $3F,$20		; Left
	dw $FFE5,$FFF4 : db $3F,$20		; Right
	.1					; Start at sword coords + 3;4
	dw $FFFC,$FFF4 : db $2D,$20		; Left
	dw $FFE7,$FFF4 : db $2D,$20		; Right

	AIRSLASH:
	.0					; Start at sword coords + 3;-20 (sword, not lil' cut tile)
	dw $FFE0,$FFE0 : db $30,$40		; Left
	dw $0000,$FFE0 : db $30,$40		; Right
	.1					; Start at sword coords + 5;8
	dw $FFED,$000C : db $23,$08		; Left
	dw $0000,$000C : db $23,$08		; Right

	WALLSLASH:
	.0					; Start at sword coords + 3;-20 (sword, not lil' cut tile)
	dw $0009,$FFDD : db $2D,$38		; Left
	dw $FFDA,$FFDD : db $2D,$38		; Right
	.1					; Start at sword coords + 5;8
	dw $0009,$000D : db $23,$08		; Left
	dw $FFE4,$000D : db $23,$08		; Right

	HANGSLASH:
	.0					; Start at sword coords + 3;0
	dw $FFD5,$FFFD : db $2D,$18		; Left
	dw $000E,$FFFD : db $2D,$18		; Right
	.1					; Start at sword coords + 5;8
	dw $FFDF,$0010 : db $23,$08		; Left
	dw $000E,$0010 : db $23,$08		; Right


	HIT_00:
		RTS

	HIT_01:
		; Knock out always
		JMP KNOCKOUT

	HIT_02:
		; Knock out of shell, send shell flying
		LDA $3230,x
		CMP #$08 : BEQ .Standard
		CMP #$09 : BEQ .Knockback
		CMP #$0A : BNE HIT_00
		LDA $3200,x			;\
		CMP #$07 : BNE .Knockback	; | Shiny shell is immune to sword
		LDA #$02 : STA !SPC1		; |
		RTS				;/

		.Knockback
		JSR CORE_ATTACK_Main
		LDA #$09 : STA $3230,x
		JSR KNOCKBACK
		STZ $9E,x
		STZ $AE,x
		RTS

		.Standard
		LDA $3200,x
		CMP #$08 : BCS .Stun

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
		CPY #$08
		BCS +
		TSB !P2IndexMem1
		BRA ++
		+
		TSB !P2IndexMem2
		++

		LDA #$10 : STA $3300,y		; > Temporarily disable player interaction
		LDA $3430,x			;\ Copy "is in water" flag from sprite
		STA $3430,y			;/
		LDA #$02 : STA $32D0,y		;\ Some sprite tables
		LDA #$01 : STA $30BE,y		;/

		PHX
		LDA !P2Direction
		LDX !P2SwordAttack
		CPX #$85
		BEQ $02 : EOR #$01
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
		JMP CORE_INT_0B

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
=======
	DropSword:
		PHP
		LDA !P2Dir
		ASL A : TAX
		REP #$20
		LDA .XSpeed,x : STA $E0
		LDA !P2X
		CLC : ADC .XOffset1,x
		STA $E2
		LDA !P2X
		CLC : ADC .XOffset2,x
		STA $E4
		PHB
		JSL GetParticleIndex
		SEP #$20
		LDA.b #!prt_spritepart : STA !Particle_Type,x
		LDA !CurrentPlayer
		BEQ $02 : LDA.b #!P2TileOffset
		CLC : ADC.b #!P1Tile7
		STA !Particle_Tile,x
		LDA !CurrentPlayer
		ORA #$30
		BIT $E0+1
		BMI $02 : EOR #$40
		STA !Particle_Prop,x
		LDA #$02 : STA !Particle_Layer,x
		STZ !Particle_XAcc,x
		LDA #$18 : STA !Particle_YAcc,x
		REP #$30
		LDA $E2 : STA !Particle_X,x
		LDA.l !P2Y
		CLC : ADC #$FFF5
		STA !Particle_Y,x
		LDA $E0 : STA !Particle_XSpeed,x
		LDA #$FD00 : STA !Particle_YSpeed,x
		JSL GetParticleIndex
		SEP #$20
		LDA.b #!prt_spritepart : STA !Particle_Type,x
		LDA !CurrentPlayer
		BEQ $02 : LDA.b #!P2TileOffset
		CLC : ADC.b #!P1Tile7+1
		STA !Particle_Tile,x
		LDA !CurrentPlayer
		ORA #$30
		BIT $E0+1
		BMI $02 : EOR #$40
		STA !Particle_Prop,x
		LDA #$02 : STA !Particle_Layer,x
		STZ !Particle_XAcc,x
		LDA #$18 : STA !Particle_YAcc,x
		REP #$30
		LDA $E4 : STA !Particle_X,x
		LDA.l !P2Y
		CLC : ADC #$FFF5
		STA !Particle_Y,x
		LDA $E0 : STA !Particle_XSpeed,x
		LDA #$FD00 : STA !Particle_YSpeed,x
		PLB
		PLP
		RTS

		.XSpeed
		dw $FF80,$0080
		.XOffset1
		dw $FFE8,$0018
		.XOffset2
		dw $FFF0,$0010



;=====================;
;	D A T A       ;
;=====================;

; hitbox data is based on facing right
; xdisp and xspeed are automatically flipped when facing left
; lo byte of x on second hitbox can not be 00, as that signals that there is no second hitbox
;
; format:
;	16-bit Xdisp
;	16-bit Ydisp
;	8-bit W
;	8-bit H
;	8-bit X speed
;	8-bit Y speed
;	8-bit interaction disable timer
;	8-bit input for !SPC1
;	8-bit input for !SPC4


	HitboxTable:
		dw .GroundAttack1_hitbox1	; 00
		dw .GroundAttack1_hitbox2	; 02
		dw .GroundAttack2_hitbox1	; 04
		dw .GroundAttack2_hitbox2	; 06
		dw .DashAttack_hitbox1		; 08
		dw .DashAttack_hitbox2		; 0A
		dw .AirAttack_hitbox1		; 0C
		dw .AirAttack_hitbox2		; 0E
		dw .WallAttack_hitbox1		; 10
		dw .WallAttack_hitbox2		; 12
		dw .CeilingAttack_hitbox1	; 14
		dw .CeilingAttack_hitbox2	; 16
		dw .SpinAttack_hitbox1		; 18
		dw .SpinAttack_hitbox2		; 1A
		dw .SpinAttack_hitbox3		; 1C
		dw .SpinAttack_hitbox4		; 1E


	.GroundAttack1
	..hitbox1
	dw $0010,$FFEE : db $18,$2E	; X/Y + W/H
	db $0C,$E8			; speeds
	db $10				; timer
	db $02				; hitstun
	db $02,$00			; SFX
	dw $0028,$FFF5 : db $0C,$20	; X/Y + W/H
	db $06,$F0			; speeds
	db $10				; timer
	db $02				; hitstun
	db $02,$00			; SFX
	..hitbox2
	dw $0018,$0008 : db $18,$10	; X/Y + W/H
	db $10,$E8			; speeds
	db $10				; timer
	db $02				; hitstun
	db $02,$00			; SFX
	dw $0008,$0004 : db $14,$10	; X/Y + W/H
	db $20,$E8			; speeds
	db $10				; timer
	db $02				; hitstun
	db $02,$00			; SFX

	.GroundAttack2
	..hitbox1
	dw $0010,$FFEC : db $18,$2E	; X/Y + W/H
	db $20,$C8			; speeds
	db $10				; timer
	db $06				; hitstun
	db $02,$00			; SFX
	dw $0028,$FFF3 : db $0C,$20	; X/Y + W/H
	db $10,$C8			; speeds
	db $10				; timer
	db $06				; hitstun
	db $02,$00			; SFX
	..hitbox2
	dw $0018,$FFE8 : db $18,$10	; X/Y + W/H
	db $20,$E8			; speeds
	db $10				; timer
	db $06				; hitstun
	db $02,$00			; SFX
	dw $0008,$FFE4 : db $20,$10	; X/Y + W/H
	db $00,$B8			; speeds
	db $10				; timer
	db $06				; hitstun
	db $02,$00			; SFX

	.DashAttack
	..hitbox1
	dw $0010,$FFF4 : db $18,$2E	; X/Y + W/H
	db $20,$F0			; speeds
	db $20				; timer
	db $04				; hitstun
	db $02,$00			; SFX
	dw $0028,$FFFB : db $0C,$20	; X/Y + W/H
	db $20,$F0			; speeds
	db $20				; timer
	db $04				; hitstun
	db $02,$00			; SFX
	..hitbox2
	dw $0018,$000F : db $18,$10	; X/Y + W/H
	db $20,$F0			; speeds
	db $20				; timer
	db $04				; hitstun
	db $02,$00			; SFX
	dw $FFFC,$0008 : db $20,$10	; X/Y + W/H
	db $10,$F0			; speeds
	db $20				; timer
	db $04				; hitstun
	db $02,$00			; SFX


	.AirAttack
	..hitbox1
	dw $0010,$FFEC : db $18,$2E	; X/Y + W/H
	db $20,$D8			; speeds
	db $10				; timer
	db $06				; hitstun
	db $02,$00			; SFX
	dw $0028,$FFF3 : db $0C,$20	; X/Y + W/H
	db $10,$D8			; speeds
	db $10				; timer
	db $06				; hitstun
	db $02,$00			; SFX
	..hitbox2
	dw $0018,$FFE8 : db $18,$10	; X/Y + W/H
	db $10,$D8			; speeds
	db $10				; timer
	db $06				; hitstun
	db $02,$00			; SFX
	dw $0008,$FFE4 : db $20,$10	; X/Y + W/H
	db $00,$B8			; speeds
	db $10				; timer
	db $06				; hitstun
	db $02,$00			; SFX

	; note: this one is reverse (since leeway's direction is inverted while wall-clinging)
	.WallAttack
	..hitbox1
	dw $FFE0,$FFE6 : db $18,$2E	; X/Y + W/H
	db $F0,$00			; speeds
	db $10				; timer
	db $04				; hitstun
	db $02,$00			; SFX
	dw $FFD4,$FFED : db $0C,$20	; X/Y + W/H
	db $F0,$00			; speeds
	db $10				; timer
	db $04				; hitstun
	db $02,$00			; SFX
	..hitbox2
	dw $FFD9,$0008 : db $18,$10	; X/Y + W/H
	db $F0,$00			; speeds
	db $10				; timer
	db $04				; hitstun
	db $02,$00			; SFX
	dw $FFED,$000A : db $10,$12	; X/Y + W/H
	db $00,$46			; speeds
	db $10				; timer
	db $04				; hitstun
	db $02,$00			; SFX

	.CeilingAttack
	..hitbox1
	dw $000C,$FFED : db $18,$2E	; X/Y + W/H
	db $10,$10			; speeds
	db $10				; timer
	db $04				; hitstun
	db $02,$00			; SFX
	dw $0024,$FFF4 : db $0C,$20	; X/Y + W/H
	db $10,$10			; speeds
	db $10				; timer
	db $04				; hitstun
	db $02,$00			; SFX
	..hitbox2
	dw $0018,$0009 : db $18,$10	; X/Y + W/H
	db $10,$10			; speeds
	db $10				; timer
	db $04				; hitstun
	db $02,$00			; SFX
	dw $0008,$000B : db $10,$12	; X/Y + W/H
	db $00,$46			; speeds
	db $10				; timer
	db $04				; hitstun
	db $02,$00			; SFX

	.SpinAttack
	..hitbox1
	dw $000B,$FFEE : db $10,$2E	; X/Y + W/H
	db $10,$10			; speeds
	db $10				; timer
	db $02				; hitstun
	db $02,$00			; SFX
	dw $001B,$FFF5 : db $0C,$20	; X/Y + W/H
	db $10,$10			; speeds
	db $10				; timer
	db $02				; hitstun
	db $02,$00			; SFX
	..hitbox2
	dw $FFEE,$0003 : db $2E,$10	; X/Y + W/H
	db $F0,$10			; speeds
	db $10				; timer
	db $02				; hitstun
	db $02,$00			; SFX
	dw $FFF5,$0013 : db $20,$0C	; X/Y + W/H
	db $F0,$10			; speeds
	db $10				; timer
	db $02				; hitstun
	db $02,$00			; SFX
	..hitbox3
	dw $FFF5,$FFE6 : db $10,$2E	; X/Y + W/H
	db $F0,$F0			; speeds
	db $10				; timer
	db $02				; hitstun
	db $02,$00			; SFX
	dw $FFE9,$FFED : db $0C,$20	; X/Y + W/H
	db $F0,$F0			; speeds
	db $10				; timer
	db $02				; hitstun
	db $02,$00			; SFX
	..hitbox4
	dw $FFF2,$FFED : db $2E,$10	; X/Y + W/H
	db $10,$F0			; speeds
	db $10				; timer
	db $02				; hitstun
	db $02,$00			; SFX
	dw $FFF9,$FFE1 : db $20,$0C	; X/Y + W/H
	db $10,$F0			; speeds
	db $10				; timer
	db $02				; hitstun
	db $02,$00			; SFX
>>>>>>> Stashed changes

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
		JMP KNOCKOUT
	+	LDA #$04 : STA $34D0,x		; Half smush timer
		BRA .Shared

		.Return
		RTS

		.Aggro
		LDA !P2SwordAttack		;\
		AND #$7F			; | Slash ignores I-frames
		CMP #$02 : BEQ +		;/
		LDA $35D0,x : BNE .Return
	+	LDA #$40 : STA $35D0,x
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
		BVS .NoChase			; | Aggro off of being cut
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
		LDA .XSpeed,y
		STA $AE,x
		JSR CORE_DISPLAY_CONTACT
		RTS

	.XSpeed
	db $E0,$20
	db $F0,$10


	KNOCKBACK:
		LDA #$E8 : STA $9E,x
		LDY !P2Direction
	LDA !P2SwordAttack
	AND #$7F
	CMP #$05
	BNE +
	TYA
	EOR #$01
	TAY
	+

		LDA !P2Dashing : BEQ +			;\
		PHY					; |
		TXY					; |
		LDA #$18 : STA ($0E),y			; | enemy speed set to 0 if Leeway is dashing (+50% i-frames)
		PLY					; |
		LDA #$00 : BRA ++			;/
	+	LDA KNOCKOUT_XSpeed+2,y
	++	STA $AE,x

		.GFX
		LDA #$02 : STA !SPC1
		JSR CORE_DISPLAY_CONTACT
		RTS



	CheckAbove:
		REP #$30
		LDA !P2XPosLo
		CLC : ADC #$0008
		TAX
		LDA !P2YPosLo
		SEC : SBC #$000F
		TAY
		SEP #$20
		JSL !GetMap16
		CMP #$0111
		SEP #$20
		BCC .Return
		CMP #$37 : BEQ .Fall
		CMP #$38 : BEQ .Fall
		CMP #$6E : BCS .Fall
		SEC
		RTS

		.Fall
		CLC

		.Return
		RTS




<<<<<<< Updated upstream
	.Idle0				; 00
	dw .IdleTM : db $08,!Lee_Idle+1
	dw .IdleDynamo0
	dw .ClippingStandard
	.Idle1				; 01
	dw .IdleTM : db $08,!Lee_Idle+2
	dw .IdleDynamo1
	dw .ClippingStandard
	.Idle2				; 02
	dw .IdleTM : db $08,!Lee_Idle
	dw .IdleDynamo2
	dw .ClippingStandard

	.Walk0				; 03
	dw .32x32TM : db $06,!Lee_Walk+1
	dw .WalkDynamo0
	dw .ClippingStandard
	.Walk1				; 04
	dw .24x32TM : db $06,!Lee_Walk+2
	dw .WalkDynamo1
	dw .ClippingStandard
	.Walk2				; 05
	dw .32x32TM : db $06,!Lee_Walk+3
	dw .WalkDynamo2
	dw .ClippingStandard
	.Walk3				; 06
	dw .32x32TM : db $06,!Lee_Walk
	dw .WalkDynamo3
	dw .ClippingStandard

	.CutStart			; 07
	dw .24x32TM : db $06,!Lee_Cut+1
	dw .CutStartDynamo
	dw .ClippingStandard

	.Cut0				; 08
	dw .32x32TM : db $04,!Lee_Cut+2
	dw .CutDynamo0
	dw .ClippingStandard
	.Cut1				; 09
	dw .32x32TM : db $04,!Lee_Cut+3
	dw .CutDynamo1
	dw .ClippingStandard
	.Cut2				; 0A
	dw .32x32TM : db $08,!Lee_Cut+4
	dw .CutDynamo2
	dw .ClippingStandard
	.Cut3				; 0B
	dw .32x32TM : db $08,!Lee_Idle
	dw .CutDynamo3
	dw .ClippingStandard

	.Slash0				; 0C
	dw .32x32TM : db $04,!Lee_Slash+1
	dw .SlashDynamo0
	dw .ClippingStandard
	.Slash1				; 0D
	dw .32x32TM : db $04,!Lee_Slash+2
	dw .SlashDynamo1
	dw .ClippingStandard
	.Slash2				; 0E
	dw .32x32TM : db $08,!Lee_Slash+3
	dw .SlashDynamo2
	dw .ClippingStandard
	.Slash3				; 0F
	dw .32x32TM : db $08,!Lee_Idle
	dw .SlashDynamo3
	dw .ClippingStandard

	.Dash0				; 10
	dw .32x32TM : db $06,!Lee_Dash+1
	dw .DashDynamo0
	dw .ClippingStandard
	.Dash1				; 11
	dw .32x32TM : db $06,!Lee_Dash+2
	dw .DashDynamo1
	dw .ClippingStandard
	.Dash2				; 12
	dw .32x32TM : db $06,!Lee_Dash
	dw .DashDynamo2
	dw .ClippingStandard

	.DashSlash0			; 13
	dw .32x32TM : db $06,!Lee_DashSlash+1
	dw .DashSlashDynamo0
	dw .ClippingStandard
	.DashSlash1			; 14
	dw .32x32TM : db $04,!Lee_DashSlash+2
	dw .DashSlashDynamo1
	dw .ClippingStandard
	.DashSlash2			; 15
	dw .32x32TM : db $04,!Lee_DashSlash+3
	dw .DashSlashDynamo2
	dw .ClippingStandard
	.DashSlash3			; 16
	dw .32x32TM : db $06,!Lee_DashSlash+4
	dw .DashSlashDynamo3
	dw .ClippingStandard
	.DashSlash4			; 17
	dw .32x32TM : db $06,!Lee_Dash
	dw .DashSlashDynamo4
	dw .ClippingStandard

	.Jump				; 18
	dw .24x32TM : db $FF,!Lee_Jump
	dw .JumpDynamo
	dw .ClippingStandard

	.Fall0				; 19
	dw .24x40TM : db $04,!Lee_Fall+1
	dw .FallDynamo0
	dw .ClippingStandard
	.Fall1				; 1A
	dw .24x40TM : db $04,!Lee_Fall
	dw .FallDynamo1
	dw .ClippingStandard

	.SlowFall0			; 1B
	dw .24x32TM : db $06,!Lee_SlowFall+1
	dw .SlowFallDynamo0
	dw .ClippingStandard
	.SlowFall1			; 1C
	dw .24x32TM : db $06,!Lee_SlowFall+2
	dw .SlowFallDynamo1
	dw .ClippingStandard
	.SlowFall2			; 1D
	dw .24x32TM : db $06,!Lee_SlowFall
	dw .SlowFallDynamo2
	dw .ClippingStandard

	.CeilingClimb0			; 1E
	dw .24x32TM : db $0A,!Lee_Ceiling+1
	dw .CeilingClimbDynamo0
	dw .ClippingStandard
	.CeilingClimb1			; 1F
	dw .24x40TM : db $0A,!Lee_Ceiling+2
	dw .CeilingClimbDynamo1
	dw .ClippingStandard
	.CeilingClimb2			; 20
	dw .24x40TM : db $0A,!Lee_Ceiling+3
	dw .CeilingClimbDynamo2
	dw .ClippingStandard
	.CeilingClimb3			; 21
	dw .24x40TM : db $0A,!Lee_Ceiling+4
	dw .CeilingClimbDynamo3
	dw .ClippingStandard
	.CeilingClimb4			; 22
	dw .24x40TM : db $0A,!Lee_Ceiling+5
	dw .CeilingClimbDynamo4
	dw .ClippingStandard
	.CeilingClimb5			; 23
	dw .24x40TM : db $0A,!Lee_Ceiling
	dw .CeilingClimbDynamo5
	dw .ClippingStandard

	.CrouchStart0			; 24
	dw .32x32TM : db $06,!Lee_Crouch+1
	dw .CrouchStartDynamo0
	dw .ClippingStandard
	.CrouchStart1			; 25
	dw .32x24TM : db $06,!Lee_Crawl
	dw .CrouchStartDynamo1
	dw .ClippingCrawl

	.Crawl0				; 26
	dw .32x24TM : db $06,!Lee_Crawl+1
	dw .CrawlDynamo0
	dw .ClippingCrawl
	.Crawl1				; 27
	dw .40x16TM : db $06,!Lee_Crawl+2
	dw .CrawlDynamo1
	dw .ClippingCrawl
	.Crawl2				; 28
	dw .32x24TM : db $06,!Lee_Crawl+3
	dw .CrawlDynamo0
	dw .ClippingCrawl
	.Crawl3				; 29
	dw .32x16TM : db $06,!Lee_Crawl
	dw .CrawlDynamo2
	dw .ClippingCrawl

	.CrouchEnd			; 2A
	dw .24x32TM : db $08,!Lee_Idle
	dw .CrouchEndDynamo
	dw .ClippingStandard

	.AirSlash0			; 2B
	dw .32x32TM : db $08,!Lee_AirSlash+1
	dw .AirSlashDynamo0
	dw .ClippingStandard
	.AirSlash1			; 2C
	dw .32x32TM : db $04,!Lee_AirSlash+2
	dw .AirSlashDynamo1
	dw .ClippingStandard
	.AirSlash2			; 2D
	dw .32x32TM : db $04,!Lee_AirSlash+3
	dw .AirSlashDynamo2
	dw .ClippingStandard
	.AirSlash3			; 2E
	dw .32x32TM : db $10,!Lee_Fall
	dw .AirSlashDynamo3
	dw .ClippingStandard

	.Hang				; 2F
	dw .24x32TM : db $FF,!Lee_Hang
	dw .HangDynamo
	dw .ClippingStandard

	.HangSlash0			; 30
	dw .24x40TM : db $06,!Lee_HangSlash+1
	dw .HangSlashDynamo0
	dw .ClippingStandard
	.HangSlash1			; 31
	dw .24x32TM : db $04,!Lee_HangSlash+2
	dw .HangSlashDynamo1
	dw .ClippingStandard
	.HangSlash2			; 32
	dw .24x32TM : db $04,!Lee_HangSlash+3
	dw .HangSlashDynamo2
	dw .ClippingStandard
	.HangSlash3			; 33
	dw .24x40TM : db $08,!Lee_Hang
	dw .HangSlashDynamo3
	dw .ClippingStandard

	.WallCling			; 34
	dw .24x32TM : db $FF,!Lee_WallCling
	dw .WallClingDynamo
	dw .ClippingStandard

	.WallSlash0			; 35
	dw .24x32TM : db $0A,!Lee_WallSlash+1
	dw .WallSlashDynamo0
	dw .ClippingStandard
	.WallSlash1			; 36
	dw .24x32TM : db $04,!Lee_WallSlash+2
	dw .WallSlashDynamo1
	dw .ClippingStandard
	.WallSlash2			; 37
	dw .24x32TM : db $04,!Lee_WallSlash+3
	dw .WallSlashDynamo2
	dw .ClippingStandard
	.WallSlash3			; 38
	dw .24x32TM : db $0A,!Lee_WallCling
	dw .WallSlashDynamo3
	dw .ClippingStandard

	.WallClimb0			; 39
	dw .24x32TM : db $08,!Lee_WallClimb+1
	dw .WallClimbDynamo0
	dw .ClippingWall
	.WallClimb1			; 3A
	dw .24x32TM : db $08,!Lee_WallClimb+2
	dw .WallClimbDynamo1
	dw .ClippingWall
	.WallClimb2			; 3B
	dw .24x32TM : db $08,!Lee_WallClimb+3
	dw .WallClimbDynamo2
	dw .ClippingWall
	.WallClimb3			; 3C
	dw .24x32TM : db $08,!Lee_WallClimb
	dw .WallClimbDynamo3
	dw .ClippingWall

	.ClimbTop			; 3D
	dw .32x32TM : db $12,!Lee_Idle
	dw .ClimbTopDynamo
	dw .ClippingStandard

	.ClimbBG0			; 3E
	dw .24x32TM : db $10,!Lee_ClimbBG+1
	dw .ClimbBGDynamo
	dw .ClippingStandard
	.ClimbBG1			; 3F
	dw .24x32ReverseTM : db $10,!Lee_ClimbBG
	dw .ClimbBGDynamo
	dw .ClippingStandard

	.Hurt				; 40
	dw .32x32TM : db $FF,!Lee_Hurt
	dw .HurtDynamo
	dw .ClippingStandard

	.Dead				; 41
	dw .24x32TM : db $FF,!Lee_Dead
	dw .DeadDynamo
	dw .ClippingStandard

	.Victory0			; 42
	dw .24x32TM : db $14,!Lee_Victory+1
	dw .VictoryDynamo0
	dw .ClippingStandard
	.Victory1			; 43
	dw .24x32TM : db $14,!Lee_Victory
	dw .VictoryDynamo1
	dw .ClippingStandard


	.IdleTM
	dw $000C
	db $2E,$00,$F0,!P2Tile1
	db $2E,$00,$00,!P2Tile2
	db $2E,$08,$00,!P2Tile2+$01

	.40x16TM
	dw $000C
	db $2E,$00,$00,!P2Tile1
	db $2E,$10,$00,!P2Tile2
	db $2E,$18,$00,!P2Tile2+$01

	.32x24TM
	dw $0010
	db $2E,$00,$F8,!P2Tile1
	db $2E,$10,$F8,!P2Tile2
	db $2E,$00,$00,!P2Tile3
	db $2E,$10,$00,!P2Tile4

	.32x16TM
	dw $0008
	db $2E,$00,$00,!P2Tile1
	db $2E,$10,$00,!P2Tile2
=======


; Data
	ANIM:

	; idle 1
		.Idle1Frame0
		dw .24x32TM : db $08,!Lee_Idle1+1
		dw .Idle1Dynamo0
		dw .ClippingStandard
		.Idle1Frame1
		dw .24x32TM : db $08,!Lee_Idle1+2
		dw .Idle1Dynamo1
		dw .ClippingStandard
		.Idle1Frame2
		dw .24x32TM : db $08,!Lee_Idle1
		dw .Idle1Dynamo2
		dw .ClippingStandard

	; sleep (counted as part of idle 1)
		.Sleep
		dw .24x32TM_sleep : db $FF,!Lee_Sleep
		dw .SleepDynamo
		dw .ClippingStandard

	; idle transition
		.IdleTransition0
		dw .24x32TM : db $08,!Lee_Idle2
		dw .IdleTransitionDynamo
		dw .ClippingStandard
		.IdleTransition1
		dw .24x32TM : db $08,!Lee_Idle1
		dw .IdleTransitionDynamo
		dw .ClippingStandard

	; idle 2
		.Idle2Frame0
		dw .24x32TM : db $08,!Lee_Idle2+1
		dw .Idle2Dynamo0
		dw .ClippingStandard
		.Idle2Frame1
		dw .24x32TM : db $08,!Lee_Idle2+2
		dw .Idle2Dynamo1
		dw .ClippingStandard
		.Idle2Frame2
		dw .24x32TM : db $08,!Lee_Idle2
		dw .Idle2Dynamo2
		dw .ClippingStandard

	; walk
		.Walk0
		dw .WalkTM0 : db $06,!Lee_Walk+1
		dw .WalkDynamo0
		dw .ClippingStandard
		.Walk1
		dw .WalkTM1 : db $06,!Lee_Walk+2
		dw .WalkDynamo1
		dw .ClippingStandard
		.Walk2
		dw .WalkTM2 : db $06,!Lee_Walk+3
		dw .WalkDynamo2
		dw .ClippingStandard
		.Walk3
		dw .WalkTM3 : db $06,!Lee_Walk+4
		dw .WalkDynamo3
		dw .ClippingStandard
		.Walk4
		dw .WalkTM4 : db $06,!Lee_Walk+5
		dw .WalkDynamo4
		dw .ClippingStandard
		.Walk5
		dw .WalkTM5 : db $06,!Lee_Walk+0
		dw .WalkDynamo5
		dw .ClippingStandard

	; kick
		.Kick
		dw .24x32TM : db $FF,!Lee_Kick
		dw .KickDynamo
		dw .ClippingStandard

	; crouch transition
		.CrouchTransition0
		dw .32x24TM : db $04,!Lee_Crouch
		dw .CrouchTransitionDynamo
		dw .ClippingCrawl
		.CrouchTransition1
		dw .32x24TM : db $04,!Lee_Idle1
		dw .CrouchTransitionDynamo
		dw .ClippingCrawl

	; crouch
		.Crouch0
		dw .32x24TM : db $08,!Lee_Crouch+1
		dw .CrouchDynamo0
		dw .ClippingCrawl
		.Crouch1
		dw .32x24TM : db $08,!Lee_Crouch+2
		dw .CrouchDynamo1
		dw .ClippingCrawl
		.Crouch2
		dw .32x24TM : db $08,!Lee_Crouch+3
		dw .CrouchDynamo0
		dw .ClippingCrawl
		.Crouch3
		dw .32x24TM : db $08,!Lee_Crouch+0
		dw .CrouchDynamo2
		dw .ClippingCrawl

	; surf 0
		.Surf0
		dw .24x32TM : db $FF,!Lee_Surf0
		dw .Surf0Dynamo
		dw .ClippingStandard

	; surf 1
		.Surf1Frame0
		dw .24x32TM : db $04,!Lee_Surf1+1
		dw .Surf1Dynamo0
		dw .ClippingStandard
		.Surf1Frame1
		dw .24x32TM : db $04,!Lee_Surf1+0
		dw .Surf1Dynamo1
		dw .ClippingStandard

	; surf 2
		.Surf2Frame0
		dw .24x32TM : db $02,!Lee_Surf2+1
		dw .Surf2Dynamo0
		dw .ClippingStandard
		.Surf2Frame1
		dw .24x32TM : db $02,!Lee_Surf2+0
		dw .Surf2Dynamo1
		dw .ClippingStandard

	; ground attack 1
		.GroundAttack1Frame0
		dw .24x32TM : db $08,!Lee_GroundAttack1+1
		dw .GroundAttackDynamo0
		dw .ClippingStandard
		.GroundAttack1Frame1
		dw .24x32TM : db $02,!Lee_GroundAttack1+2
		dw .GroundAttackDynamo1
		dw .ClippingStandard
		.GroundAttack1Frame2
		dw .24x32TM : db $02,!Lee_GroundAttack1+3
		dw .GroundAttackDynamo2
		dw .ClippingStandard
		.GroundAttack1Frame3
		dw .24x32TM : db $08,!Lee_Idle1
		dw .GroundAttackDynamo3
		dw .ClippingStandard

	; ground attack 2
		.GroundAttack2Frame0
		dw .24x32TM : db $02,!Lee_GroundAttack2+1
		dw .UpSlashDynamo0
		dw .ClippingStandard
		.GroundAttack2Frame1
		dw .24x32TM : db $02,!Lee_GroundAttack2+2
		dw .UpSlashDynamo1
		dw .ClippingStandard
		.GroundAttack2Frame2
		dw .24x32TM : db $08,!Lee_Fall+1
		dw .UpSlashDynamo2
		dw .ClippingStandard

	; dash transition
		.DashTransition0
		dw .32x32TM : db $08,!Lee_Dash
		dw .DashTransitionDynamo
		dw .ClippingDash
		.DashTransition1
		dw .32x32TM : db $08,!Lee_Idle1
		dw .DashTransitionDynamo
		dw .ClippingDash

	; dash
		.Dash0
		dw .32x24TM : db $04,!Lee_Dash+1
		dw .DashDynamo0
		dw .ClippingDash
		.Dash1
		dw .32x24TM : db $04,!Lee_Dash+0
		dw .DashDynamo1
		dw .ClippingDash

	; dash attack
		.DashAttack0
		dw .32x24TM : db $08,!Lee_DashAttack+1
		dw .DashAttackDynamo0
		dw .ClippingDash
		.DashAttack1
		dw .32x24TM : db $02,!Lee_DashAttack+2
		dw .DashAttackDynamo1
		dw .ClippingDash
		.DashAttack2
		dw .32x24TM : db $02,!Lee_DashTransition
		dw .DashAttackDynamo2
		dw .ClippingDash

	; jump
		.Jump
		dw .24x32TM : db $FF,!Lee_Jump
		dw .JumpDynamo
		dw .ClippingStandard

	; fall
		.Fall0
		dw .24x32TM : db $08,!Lee_Fall+1
		dw .FallDynamo0
		dw .ClippingStandard
		.Fall1
		dw .24x32TM : db $04,!Lee_Fall+2
		dw .FallDynamo1
		dw .ClippingStandard
		.Fall2
		dw .24x32TM : db $04,!Lee_Fall+1
		dw .FallDynamo2
		dw .ClippingStandard

	; air attack
		.AirAttack0
		dw .24x32TM : db $04,!Lee_AirAttack+1
		dw .AirAttackDynamo0
		dw .ClippingStandard
		.AirAttack1
		dw .24x32TM : db $04,!Lee_AirAttack+2
		dw .AirAttackDynamo1
		dw .ClippingStandard
		.AirAttack2
		dw .24x32TM_reverse : db $02,!Lee_AirAttack+3
		dw .AirAttackDynamo2
		dw .ClippingStandard
		.AirAttack3
		dw .24x32TM_reverse : db $02,!Lee_AirAttack+4
		dw .AirAttackDynamo3
		dw .ClippingStandard
		.AirAttack4
		dw .24x32TM_reverse : db $02,!Lee_AirAttack+5
		dw .AirAttackDynamo4
		dw .ClippingStandard
		.AirAttack5
		dw .24x32TM : db $02,!Lee_AirAttack+6
		dw .UpSlashDynamo0
		dw .ClippingStandard
		.AirAttack6
		dw .24x32TM : db $02,!Lee_AirAttack+7
		dw .UpSlashDynamo1
		dw .ClippingStandard
		.AirAttack7
		dw .24x32TM : db $08,!Lee_Fall+1
		dw .UpSlashDynamo2
		dw .ClippingStandard

	; double jump
		.DoubleJump0
		dw .32x32TM_flip : db $02,!Lee_DoubleJump+1
		dw .DoubleJumpDynamo0
		dw .ClippingStandard
		.DoubleJump1
		dw .32x32TM : db $02,!Lee_DoubleJump+2
		dw .DoubleJumpDynamo1
		dw .ClippingStandard
		.DoubleJump2
		dw .32x32TM : db $02,!Lee_DoubleJump+3
		dw .DoubleJumpDynamo2
		dw .ClippingStandard
		.DoubleJump3
		dw .32x32TM_flip : db $02,!Lee_DoubleJump+0
		dw .DoubleJumpDynamo3
		dw .ClippingStandard

	; spin attack
		.SpinAttack0
		dw .32x32TM : db $02,!Lee_SpinAttack+1
		dw .SpinAttackDynamo0
		dw .ClippingStandard
		.SpinAttack1
		dw .32x32TM : db $02,!Lee_SpinAttack+2
		dw .SpinAttackDynamo1
		dw .ClippingStandard
		.SpinAttack2
		dw .32x32TM : db $02,!Lee_SpinAttack+3
		dw .SpinAttackDynamo2
		dw .ClippingStandard
		.SpinAttack3
		dw .32x32TM_flip : db $02,!Lee_SpinAttack+0
		dw .SpinAttackDynamo1
		dw .ClippingStandard

	; climb BG
		.ClimbBG
		dw .24x32TM : db $FF,!Lee_ClimbBG
		dw .ClimbBGDynamo
		dw .ClippingStandard

	; wall climb
		.WallClimb0
		dw .WallClimbTM : db $02,!Lee_WallClimb+1
		dw .WallClimbDynamo0
		dw .ClippingStandard
		.WallClimb1
		dw .WallClimbTM : db $02,!Lee_WallClimb+2
		dw .WallClimbDynamo1
		dw .ClippingStandard
		.WallClimb2
		dw .WallClimbTM : db $02,!Lee_WallClimb+3
		dw .WallClimbDynamo2
		dw .ClippingStandard
		.WallClimb3
		dw .WallClimbTM : db $02,!Lee_WallClimb+0
		dw .WallClimbDynamo3
		dw .ClippingStandard

	; wall climb top
		.WallClimbTop0
		dw .WallClimbTopTM : db $02,!Lee_WallClimbTop+1
		dw .WallClimbTopDynamo0
		dw .ClippingStandard
		.WallClimbTop1
		dw .32x24TM_forward : db $04,!Lee_WallClimbTop+2
		dw .WallClimbTopDynamo1
		dw .ClippingStandard
		.WallClimbTop2
		dw .32x32TM : db $04,!Lee_Idle1
		dw .WallClimbTopDynamo2
		dw .ClippingStandard

	; wall attack
		.WallAttack0
		dw .WallClimbTM : db $04,!Lee_WallAttack+1
		dw .WallAttackDynamo0
		dw .ClippingStandard
		.WallAttack1
		dw .WallClimbTM : db $04,!Lee_WallAttack+2
		dw .WallAttackDynamo1
		dw .ClippingStandard
		.WallAttack2
		dw .WallClimbTM : db $02,!Lee_WallAttack+3
		dw .WallAttackDynamo2
		dw .ClippingStandard
		.WallAttack3
		dw .WallClimbTM : db $02,!Lee_WallAttack+4
		dw .WallAttackDynamo3
		dw .ClippingStandard
		.WallAttack4
		dw .WallClimbTM : db $08,!Lee_WallClimb
		dw .WallAttackDynamo3
		dw .ClippingStandard

	; ceiling hang
		.CeilingHang
		dw .24x32TM : db $FF,!Lee_CeilingHang
		dw .CeilingHangDynamo
		dw .ClippingStandard

	; ceiling climb
		.CeilingClimb0
		dw .24x32TM : db $08,!Lee_CeilingClimb+1
		dw .CeilingClimbDynamo0
		dw .ClippingStandard
		.CeilingClimb1
		dw .24x32TM : db $08,!Lee_CeilingClimb+2
		dw .CeilingClimbDynamo1
		dw .ClippingStandard
		.CeilingClimb2
		dw .24x32TM : db $08,!Lee_CeilingClimb+3
		dw .CeilingClimbDynamo2
		dw .ClippingStandard
		.CeilingClimb3
		dw .24x32TM : db $08,!Lee_CeilingClimb+4
		dw .CeilingClimbDynamo3
		dw .ClippingStandard
		.CeilingClimb4
		dw .24x32TM : db $08,!Lee_CeilingClimb+5
		dw .CeilingClimbDynamo4
		dw .ClippingStandard
		.CeilingClimb5
		dw .24x32TM : db $08,!Lee_CeilingClimb
		dw .CeilingClimbDynamo5
		dw .ClippingStandard

	; ceiling attack
		.CeilingAttack0
		dw .24x32TM : db $08,!Lee_CeilingAttack+1
		dw .CeilingAttackDynamo0
		dw .ClippingStandard
		.CeilingAttack1
		dw .24x32TM : db $02,!Lee_CeilingAttack+2
		dw .CeilingAttackDynamo1
		dw .ClippingStandard
		.CeilingAttack2
		dw .24x32TM : db $02,!Lee_CeilingAttack+3
		dw .CeilingAttackDynamo2
		dw .ClippingStandard
		.CeilingAttack3
		dw .24x32TM : db $08,!Lee_CeilingHang
		dw .CeilingAttackDynamo2
		dw .ClippingStandard

	; hurt
		.Hurt
		dw .24x32TM : db $FF,!Lee_Hurt
		dw .HurtDynamo
		dw .ClippingStandard

	; dead
		.Dead
		dw .24x32TM : db $FF,!Lee_Dead
		dw .DeadDynamo
		dw .ClippingStandard

	; victory
		.Victory0
		dw .24x32TM : db $08,!Lee_Victory+1
		dw .VictoryDynamo0
		dw .ClippingStandard
		.Victory1
		dw .24x32TM : db $08,!Lee_Victory+0
		dw .VictoryDynamo1
		dw .ClippingStandard



>>>>>>> Stashed changes

	.WalkTM0
	.WalkTM2
	.WalkTM3
	.WalkTM5
	.24x32TM
	dw $0010
<<<<<<< Updated upstream
	db $2E,$00,$F0,!P2Tile1
	db $2E,$10,$F0,!P2Tile2
	db $2E,$00,$00,!P2Tile3
	db $2E,$10,$00,!P2Tile4
=======
	db $20,$FC,$F0,!P1Tile1
	db $20,$04,$F0,!P1Tile1+1
	db $20,$FC,$00,!P1Tile5
	db $20,$04,$00,!P1Tile5+1
	..reverse
	dw $0010
	db $60,$04,$F0,!P1Tile1
	db $60,$FC,$F0,!P1Tile1+1
	db $60,$04,$00,!P1Tile5
	db $60,$FC,$00,!P1Tile5+1
	..sleep
	dw $0010
	db $20,$FC,$F3,!P1Tile1
	db $20,$04,$F3,!P1Tile1+1
	db $20,$FC,$03,!P1Tile5
	db $20,$04,$03,!P1Tile5+1
>>>>>>> Stashed changes

	.32x24TM
	dw $0010
<<<<<<< Updated upstream
	db $2E,$00,$F0,!P2Tile1
	db $2E,$08,$F0,!P2Tile1+$01
	db $2E,$00,$00,!P2Tile3
	db $2E,$08,$00,!P2Tile3+$01

	.24x32ReverseTM
	dw $0010
	db $6E,$F8,$F0,!P2Tile1
	db $6E,$00,$F0,!P2Tile1+$01
	db $6E,$F8,$00,!P2Tile3
	db $6E,$00,$00,!P2Tile3+$01

	.24x40TM
	dw $0018
	db $2E,$00,$F0,!P2Tile1
	db $2E,$08,$F0,!P2Tile1+$01
	db $2E,$00,$00,!P2Tile2+$01
	db $2E,$08,$00,!P2Tile3
	db $2E,$00,$08,!P2Tile4
	db $2E,$08,$08,!P2Tile4+$01	


;macro LeeDyn(TileCount, TileNumber, Dest)
;	dw <TileCount>*$20
;	dl <TileNumber>*$20+$358000
;	dw <Dest>*$10+$6000
;endmacro

;macro SwdDyn(TileCount, TileNumber, Dest)
;	dw <TileCount>*$20
;	dl <TileNumber>*$20+$348008
;	dw <Dest>*$10+$6000
;endmacro
=======
	db $20,$F8,$F8,!P1Tile1
	db $20,$08,$F8,!P1Tile2
	db $20,$F8,$00,!P1Tile1+$10
	db $20,$08,$00,!P1Tile2+$10
	..forward
	dw $0010
	db $20,$F0,$F8,!P1Tile1
	db $20,$00,$F8,!P1Tile2
	db $20,$F0,$00,!P1Tile1+$10
	db $20,$00,$00,!P1Tile2+$10

	.32x32TM
	dw $0010
	db $20,$F8,$F0,!P1Tile1
	db $20,$08,$F0,!P1Tile2
	db $20,$F8,$00,!P1Tile5
	db $20,$08,$00,!P1Tile6
	..flip
	dw $0010
	db $E0,$08,$00,!P1Tile1
	db $E0,$F8,$00,!P1Tile2
	db $E0,$08,$F0,!P1Tile5
	db $E0,$F8,$F0,!P1Tile6

	.WalkTM1
	dw $0010
	db $20,$FC,$ED,!P1Tile1
	db $20,$04,$ED,!P1Tile1+1
	db $20,$FC,$FD,!P1Tile5
	db $20,$04,$FD,!P1Tile5+1
>>>>>>> Stashed changes

	.WalkTM4
	dw $0010
	db $20,$FC,$EE,!P1Tile1
	db $20,$04,$EE,!P1Tile1+1
	db $20,$FC,$FE,!P1Tile5
	db $20,$04,$FE,!P1Tile5+1

<<<<<<< Updated upstream
macro LeeDyn(TileCount, TileNumber, Dest)
	db (<TileCount>*2)|((<TileNumber>&$07)<<5)
	db ((<TileNumber>>>3)&$7F)|$80
	db <Dest>*8
endmacro

macro SwdDyn(TileCount, TileNumber, Dest)
	db (<TileCount>*2)|((<TileNumber>&$07)<<5)
	db (<TileNumber>>>3)&$7F
	db <Dest>*8
endmacro


; -- possible change --
;
; 1 byte header (size)
; for each upload:
; 	cccssss-
; 	Bccccccc
; 	ttttt---
;
; ssss:		DMA size (shift left 4)
; cccccccccc:	character (shift left 1 for source address)
; B:		bank (add 1 to source bank when set)
; ttttt:	tile number (shift left 1 then add VRAM offset)


	.IdleDynamo0
	db ..End-..Start
	..Start
	%LeeDyn(2, $000, !P2Tile1)
	%LeeDyn(2, $010, !P2Tile1+$10)
	%LeeDyn(3, $020, !P2Tile2)
	%LeeDyn(3, $030, !P2Tile2+$10)
	%SwdDyn(3, $008, !P2Tile5)
	%SwdDyn(3, $018, !P2Tile5+$10)
	..End
	.IdleDynamo1
	db ..End-..Start
	..Start
	%LeeDyn(2, $000, !P2Tile1)
	%LeeDyn(2, $010, !P2Tile1+$10)
	%LeeDyn(3, $023, !P2Tile2)
	%LeeDyn(3, $033, !P2Tile2+$10)
	%SwdDyn(3, $008, !P2Tile5)
	%SwdDyn(3, $018, !P2Tile5+$10)
	..End
	.IdleDynamo2
	db ..End-..Start
	..Start
	%LeeDyn(2, $000, !P2Tile1)
	%LeeDyn(2, $010, !P2Tile1+$10)
	%LeeDyn(3, $026, !P2Tile2)
	%LeeDyn(3, $036, !P2Tile2+$10)
	%SwdDyn(3, $008, !P2Tile5)
	%SwdDyn(3, $018, !P2Tile5+$10)
	..End

	.WalkDynamo0
	db ..End-..Start
	..Start
	%LeeDyn(4, $040, !P2Tile1)
	%LeeDyn(4, $050, !P2Tile1+$10)
	%LeeDyn(4, $060, !P2Tile3)
	%LeeDyn(4, $070, !P2Tile3+$10)
	%SwdDyn(3, $008, !P2Tile5)
	%SwdDyn(3, $018, !P2Tile5+$10)
	..End
	.WalkDynamo1
	db ..End-..Start
	..Start
	%LeeDyn(3, $044, !P2Tile1)
	%LeeDyn(3, $054, !P2Tile1+$10)
	%LeeDyn(3, $064, !P2Tile3)
	%LeeDyn(3, $074, !P2Tile3+$10)
	%SwdDyn(3, $028, !P2Tile5)
	%SwdDyn(3, $038, !P2Tile5+$10)
	..End
	.WalkDynamo2
	db ..End-..Start
	..Start
	%LeeDyn(4, $047, !P2Tile1)
	%LeeDyn(4, $057, !P2Tile1+$10)
	%LeeDyn(4, $067, !P2Tile3)
	%LeeDyn(4, $077, !P2Tile3+$10)
	%SwdDyn(3, $028, !P2Tile5)
	%SwdDyn(3, $038, !P2Tile5+$10)
	..End
	.WalkDynamo3
	db ..End-..Start
	..Start
	%LeeDyn(4, $04B, !P2Tile1)
	%LeeDyn(4, $05B, !P2Tile1+$10)
	%LeeDyn(4, $06B, !P2Tile3)
	%LeeDyn(4, $07B, !P2Tile3+$10)
	%SwdDyn(3, $008, !P2Tile5)
	%SwdDyn(3, $018, !P2Tile5+$10)
	..End

	.CutStartDynamo
	db ..End-..Start
	..Start
	%LeeDyn(3, $00C, !P2Tile1)
	%LeeDyn(3, $01C, !P2Tile1+$10)
	%LeeDyn(3, $02C, !P2Tile3)
	%LeeDyn(3, $03C, !P2Tile3+$10)
	%SwdDyn(3, $008, !P2Tile5)
	%SwdDyn(3, $018, !P2Tile5+$10)
	..End

	.CutDynamo0
	db ..End-..Start
	..Start
	%LeeDyn(4, $080, !P2Tile1)
	%LeeDyn(4, $090, !P2Tile1+$10)
	%LeeDyn(4, $0A0, !P2Tile3)
	%LeeDyn(4, $0B0, !P2Tile3+$10)
	%SwdDyn(8, $038, !P2Tile5)
	%SwdDyn(8, $048, !P2Tile5+$10)
	..End
	.CutDynamo1
	db ..End-..Start
	..Start
	%LeeDyn(4, $084, !P2Tile1)
	%LeeDyn(4, $094, !P2Tile1+$10)
	%LeeDyn(4, $0A4, !P2Tile3)
	%LeeDyn(4, $0B4, !P2Tile3+$10)
	%SwdDyn(6, $057, !P2Tile5)
	%SwdDyn(6, $067, !P2Tile5+$10)
	..End
	.CutDynamo2
	db ..End-..Start
	..Start
	%LeeDyn(4, $088, !P2Tile1)
	%LeeDyn(4, $098, !P2Tile1+$10)
	%LeeDyn(4, $0A8, !P2Tile3)
	%LeeDyn(4, $0B8, !P2Tile3+$10)
	%SwdDyn(3, $05D, !P2Tile6)
	%SwdDyn(3, $06D, !P2Tile6+$10)
	..End
	.CutDynamo3
	db ..End-..Start
	..Start
	%LeeDyn(4, $08C, !P2Tile1)
	%LeeDyn(4, $09C, !P2Tile1+$10)
	%LeeDyn(4, $0AC, !P2Tile3)
	%LeeDyn(4, $0BC, !P2Tile3+$10)
	%SwdDyn(3, $05D, !P2Tile6)
	%SwdDyn(3, $06D, !P2Tile6+$10)
	..End

	.SlashDynamo0
	db ..End-..Start
	..Start
	%LeeDyn(4, $0C0, !P2Tile1)
	%LeeDyn(4, $0D0, !P2Tile1+$10)
	%LeeDyn(4, $0E0, !P2Tile3)
	%LeeDyn(4, $0F0, !P2Tile3+$10)
	%SwdDyn(2, $000, !P2Tile5)
	%SwdDyn(2, $010, !P2Tile5+$10)
	%SwdDyn(5, $011, !P2Tile6)
	%SwdDyn(5, $021, !P2Tile6+$10)
	..End
	.SlashDynamo1
	db ..End-..Start
	..Start
	%LeeDyn(4, $0C4, !P2Tile1)
	%LeeDyn(4, $0D4, !P2Tile1+$10)
	%LeeDyn(4, $0E4, !P2Tile3)
	%LeeDyn(4, $0F4, !P2Tile3+$10)
	%SwdDyn(5, $040, !P2Tile5)
	%SwdDyn(5, $050, !P2Tile5+$10)
	..End
	.SlashDynamo2
	db ..End-..Start
	..Start
	%LeeDyn(4, $0C8, !P2Tile1)
	%LeeDyn(4, $0D8, !P2Tile1+$10)
	%LeeDyn(4, $0E8, !P2Tile3)
	%LeeDyn(4, $0F8, !P2Tile3+$10)
	%SwdDyn(2, $00C, !P2Tile7)
	%SwdDyn(2, $01C, !P2Tile7+$10)
	%SwdDyn(2, $01B, !P2Tile8)
	%SwdDyn(2, $02B, !P2Tile8+$10)
	..End
	.SlashDynamo3
	db ..End-..Start
	..Start
	%LeeDyn(4, $0CC, !P2Tile1)
	%LeeDyn(4, $0DC, !P2Tile1+$10)
	%LeeDyn(4, $0EC, !P2Tile3)
	%LeeDyn(4, $0FC, !P2Tile3+$10)
	..End


	.DashDynamo0
	db ..End-..Start
	..Start
	%LeeDyn(4, $100, !P2Tile1)
	%LeeDyn(4, $110, !P2Tile1+$10)
	%LeeDyn(4, $120, !P2Tile3)
	%LeeDyn(4, $130, !P2Tile3+$10)
	%SwdDyn(3, $008, !P2Tile5)
	%SwdDyn(3, $018, !P2Tile5+$10)
	..End
	.DashDynamo1
	db ..End-..Start
	..Start
	%LeeDyn(4, $104, !P2Tile1)
	%LeeDyn(4, $114, !P2Tile1+$10)
	%LeeDyn(4, $124, !P2Tile3)
	%LeeDyn(4, $134, !P2Tile3+$10)
	%SwdDyn(3, $008, !P2Tile5)
	%SwdDyn(3, $018, !P2Tile5+$10)
	..End
	.DashDynamo2
	db ..End-..Start
	..Start
	%LeeDyn(4, $108, !P2Tile1)
	%LeeDyn(4, $118, !P2Tile1+$10)
	%LeeDyn(4, $128, !P2Tile3)
	%LeeDyn(4, $138, !P2Tile3+$10)
	%SwdDyn(3, $008, !P2Tile5)
	%SwdDyn(3, $018, !P2Tile5+$10)
	..End
	.DashSlashDynamo0
	db ..End-..Start
	..Start
	%LeeDyn(4, $10C, !P2Tile1)
	%LeeDyn(4, $11C, !P2Tile1+$10)
	%LeeDyn(4, $12C, !P2Tile3)
	%LeeDyn(4, $13C, !P2Tile3+$10)
	%SwdDyn(3, $008, !P2Tile5)
	%SwdDyn(3, $018, !P2Tile5+$10)
	..End
	.DashSlashDynamo1
	db ..End-..Start
	..Start
	%LeeDyn(4, $140, !P2Tile1)
	%LeeDyn(4, $150, !P2Tile1+$10)
	%LeeDyn(4, $160, !P2Tile3)
	%LeeDyn(4, $170, !P2Tile3+$10)
	%SwdDyn(8, $038, !P2Tile5)
	%SwdDyn(8, $048, !P2Tile5+$10)
	..End
	.DashSlashDynamo2
	db ..End-..Start
	..Start
	%LeeDyn(4, $144, !P2Tile1)
	%LeeDyn(4, $154, !P2Tile1+$10)
	%LeeDyn(4, $164, !P2Tile3)
	%LeeDyn(4, $174, !P2Tile3+$10)
	%SwdDyn(6, $057, !P2Tile5)
	%SwdDyn(6, $067, !P2Tile5+$10)
	..End
	.DashSlashDynamo3
	db ..End-..Start
	..Start
	%LeeDyn(4, $148, !P2Tile1)
	%LeeDyn(4, $158, !P2Tile1+$10)
	%LeeDyn(4, $168, !P2Tile3)
	%LeeDyn(4, $178, !P2Tile3+$10)
	%SwdDyn(3, $05D, !P2Tile6)
	%SwdDyn(3, $06D, !P2Tile6+$10)
	..End
	.DashSlashDynamo4
	db ..End-..Start
	..Start
	%LeeDyn(4, $14C, !P2Tile1)
	%LeeDyn(4, $15C, !P2Tile1+$10)
	%LeeDyn(4, $16C, !P2Tile3)
	%LeeDyn(4, $17C, !P2Tile3+$10)
	%SwdDyn(3, $05D, !P2Tile6)
	%SwdDyn(3, $06D, !P2Tile6+$10)
	..End

	.JumpDynamo
	db ..End-..Start
	..Start
	%LeeDyn(3, $190, !P2Tile1)
	%LeeDyn(3, $1A0, !P2Tile1+$10)
	%LeeDyn(3, $1B0, !P2Tile3)
	%LeeDyn(3, $1C0, !P2Tile3+$10)
	%SwdDyn(3, $05D, !P2Tile6)
	%SwdDyn(3, $06D, !P2Tile6+$10)
	..End

	.FallDynamo0
	db ..End-..Start
	..Start
	%LeeDyn(3, $183, !P2Tile1)
	%LeeDyn(3, $193, !P2Tile1+$10)
	%LeeDyn(3, $1A3, !P2Tile2+$01)
	%LeeDyn(3, $1B3, !P2Tile2+$11)
	%LeeDyn(3, $1B3, !P2Tile4)
	%LeeDyn(3, $1C3, !P2Tile4+$10)
	%SwdDyn(2, $006, !P2Tile5+$01)
	%SwdDyn(2, $016, !P2Tile5+$11)
	%SwdDyn(2, $016, !P2Tile6+$01)
	%SwdDyn(2, $026, !P2Tile6+$11)
	..End
	.FallDynamo1
	db ..End-..Start
	..Start
	%LeeDyn(3, $186, !P2Tile1)
	%LeeDyn(3, $196, !P2Tile1+$10)
	%LeeDyn(3, $1A6, !P2Tile2+$01)
	%LeeDyn(3, $1B6, !P2Tile2+$11)
	%LeeDyn(3, $1B6, !P2Tile4)
	%LeeDyn(3, $1C6, !P2Tile4+$10)
	..End

	.SlowFallDynamo0
	db ..End-..Start
	..Start
	%LeeDyn(3, $1E0, !P2Tile1)
	%LeeDyn(3, $1F0, !P2Tile1+$10)
	%LeeDyn(3, $200, !P2Tile3)
	%LeeDyn(3, $210, !P2Tile3+$10)
	%SwdDyn(2, $00C, !P2Tile7)
	%SwdDyn(2, $01C, !P2Tile7+$10)
	%SwdDyn(2, $01B, !P2Tile8)
	%SwdDyn(2, $02B, !P2Tile8+$10)
	..End
	.SlowFallDynamo1
	db ..End-..Start
	..Start
	%LeeDyn(3, $1E3, !P2Tile1)
	%LeeDyn(3, $1F3, !P2Tile1+$10)
	%LeeDyn(3, $203, !P2Tile3)
	%LeeDyn(3, $213, !P2Tile3+$10)
	..End
	.SlowFallDynamo2
	db ..End-..Start
	..Start
	%LeeDyn(3, $1E6, !P2Tile1)
	%LeeDyn(3, $1F6, !P2Tile1+$10)
	%LeeDyn(3, $206, !P2Tile3)
	%LeeDyn(3, $216, !P2Tile3+$10)
	..End

	.CeilingClimbDynamo0
	db ..End-..Start
	..Start
	%LeeDyn(3, $1CA, !P2Tile1)
	%LeeDyn(3, $1DA, !P2Tile1+$10)
	%LeeDyn(3, $1EA, !P2Tile3)
	%LeeDyn(3, $1FA, !P2Tile3+$10)
	..End
	.CeilingClimbDynamo1
	db ..End-..Start
	..Start
	%LeeDyn(3, $1CD, !P2Tile1)
	%LeeDyn(3, $1DD, !P2Tile1+$10)
	%LeeDyn(3, $1ED, !P2Tile2+$01)
	%LeeDyn(3, $1FD, !P2Tile2+$11)
	%LeeDyn(3, $1FD, !P2Tile4)
	%LeeDyn(3, $20D, !P2Tile4+$10)
	..End
	.CeilingClimbDynamo2
	db ..End-..Start
	..Start
	%LeeDyn(3, $21A, !P2Tile1)
	%LeeDyn(3, $22A, !P2Tile1+$10)
	%LeeDyn(3, $23A, !P2Tile2+$01)
	%LeeDyn(3, $24A, !P2Tile2+$11)
	%LeeDyn(3, $24A, !P2Tile4)
	%LeeDyn(3, $25A, !P2Tile4+$10)
	..End
	.CeilingClimbDynamo3
	db ..End-..Start
	..Start
	%LeeDyn(3, $21D, !P2Tile1)
	%LeeDyn(3, $22D, !P2Tile1+$10)
	%LeeDyn(3, $23D, !P2Tile2+$01)
	%LeeDyn(3, $24D, !P2Tile2+$11)
	%LeeDyn(3, $24D, !P2Tile4)
	%LeeDyn(3, $25D, !P2Tile4+$10)
	..End
	.CeilingClimbDynamo4
	db ..End-..Start
	..Start
	%LeeDyn(3, $26A, !P2Tile1)
	%LeeDyn(3, $27A, !P2Tile1+$10)
	%LeeDyn(3, $28A, !P2Tile2+$01)
	%LeeDyn(3, $29A, !P2Tile2+$11)
	%LeeDyn(3, $29A, !P2Tile4)
	%LeeDyn(3, $2AA, !P2Tile4+$10)
	..End
	.CeilingClimbDynamo5
	db ..End-..Start
	..Start
	%LeeDyn(3, $26D, !P2Tile1)
	%LeeDyn(3, $27D, !P2Tile1+$10)
	%LeeDyn(3, $28D, !P2Tile2+$01)
	%LeeDyn(3, $29D, !P2Tile2+$11)
	%LeeDyn(3, $29D, !P2Tile4)
	%LeeDyn(3, $2AD, !P2Tile4+$10)
	..End

	.CrouchStartDynamo0
	db ..End-..Start
	..Start
	%LeeDyn(4, $189, !P2Tile1)
	%LeeDyn(4, $199, !P2Tile1+$10)
	%LeeDyn(4, $1A9, !P2Tile3)
	%LeeDyn(4, $1B9, !P2Tile3+$10)
	%SwdDyn(3, $008, !P2Tile5)
	%SwdDyn(3, $018, !P2Tile5+$10)
	..End
	.CrouchStartDynamo1
	db ..End-..Start
	..Start
	%LeeDyn(4, $265, !P2Tile1)
	%LeeDyn(4, $275, !P2Tile1+$10)
	%LeeDyn(4, $275, !P2Tile3)
	%LeeDyn(4, $285, !P2Tile3+$10)
	%SwdDyn(3, $028, !P2Tile5)
	%SwdDyn(3, $038, !P2Tile5+$10)
	..End
	.CrawlDynamo0
	db ..End-..Start
	..Start
	%LeeDyn(4, $260, !P2Tile1)
	%LeeDyn(4, $270, !P2Tile1+$10)
	%LeeDyn(4, $270, !P2Tile3)
	%LeeDyn(4, $280, !P2Tile3+$10)
	..End
	.CrawlDynamo1
	db ..End-..Start
	..Start
	%LeeDyn(5, $290, !P2Tile1)
	%LeeDyn(5, $2A0, !P2Tile1+$10)
	..End
	.CrawlDynamo2
	db ..End-..Start
	..Start
	%LeeDyn(4, $295, !P2Tile1)
	%LeeDyn(4, $2A5, !P2Tile1+$10)
	..End
	.CrouchEndDynamo
	db ..End-..Start
	..Start
	%LeeDyn(3, $18D, !P2Tile1)
	%LeeDyn(3, $19D, !P2Tile1+$10)
	%LeeDyn(3, $1AD, !P2Tile3)
	%LeeDyn(3, $1BD, !P2Tile3+$10)
	..End

	.AirSlashDynamo0
	db ..End-..Start
	..Start
	%LeeDyn(4, $3C7, !P2Tile1)
	%LeeDyn(4, $3D7, !P2Tile1+$10)
	%LeeDyn(4, $3E7, !P2Tile3)
	%LeeDyn(4, $3F7, !P2Tile3+$10)
	%SwdDyn(3, $008, !P2Tile5)
	%SwdDyn(3, $018, !P2Tile5+$10)
	..End
	.AirSlashDynamo1
	db ..End-..Start
	..Start
	%LeeDyn(4, $220, !P2Tile1)
	%LeeDyn(4, $230, !P2Tile1+$10)
	%LeeDyn(4, $240, !P2Tile3)
	%LeeDyn(4, $250, !P2Tile3+$10)
	%SwdDyn(2, $000, !P2Tile5)
	%SwdDyn(2, $010, !P2Tile5+$10)
	%SwdDyn(5, $011, !P2Tile6)
	%SwdDyn(5, $021, !P2Tile6+$10)
	..End
	.AirSlashDynamo2
	db ..End-..Start
	..Start
	%LeeDyn(4, $224, !P2Tile1)
	%LeeDyn(4, $234, !P2Tile1+$10)
	%LeeDyn(4, $244, !P2Tile3)
	%LeeDyn(4, $254, !P2Tile3+$10)
	%SwdDyn(5, $040, !P2Tile5)
	%SwdDyn(5, $050, !P2Tile5+$10)
	..End
	.AirSlashDynamo3
	db ..End-..Start
	..Start
	%LeeDyn(4, $224, !P2Tile1)
	%LeeDyn(4, $234, !P2Tile1+$10)
	%LeeDyn(4, $244, !P2Tile3)
	%LeeDyn(4, $254, !P2Tile3+$10)
	%SwdDyn(2, $00C, !P2Tile7)
	%SwdDyn(2, $01C, !P2Tile7+$10)
	%SwdDyn(2, $01B, !P2Tile8)
	%SwdDyn(2, $02B, !P2Tile8+$10)
	..End

	.HangDynamo
	db ..End-..Start
	..Start
	%LeeDyn(3, $2B0, !P2Tile1)
	%LeeDyn(3, $2C0, !P2Tile1+$10)
	%LeeDyn(3, $2D0, !P2Tile3)
	%LeeDyn(3, $2E0, !P2Tile3+$10)
	%SwdDyn(2, $00C, !P2Tile7)
	%SwdDyn(2, $01C, !P2Tile7+$10)
	%SwdDyn(2, $01B, !P2Tile8)
	%SwdDyn(2, $02B, !P2Tile8+$10)
	..End

	.HangSlashDynamo0
	db ..End-..Start
	..Start
	%LeeDyn(3, $2B3, !P2Tile1)
	%LeeDyn(3, $2C3, !P2Tile1+$10)
	%LeeDyn(3, $2D3, !P2Tile2+$01)
	%LeeDyn(3, $2E3, !P2Tile2+$11)
	%LeeDyn(3, $2E3, !P2Tile4)
	%LeeDyn(3, $2F3, !P2Tile4+$10)
	%SwdDyn(3, $05D, !P2Tile6)
	%SwdDyn(3, $06D, !P2Tile6+$10)
	..End
	.HangSlashDynamo1
	db ..End-..Start
	..Start
	%LeeDyn(3, $2B6, !P2Tile1)
	%LeeDyn(3, $2C6, !P2Tile1+$10)
	%LeeDyn(3, $2D6, !P2Tile3)
	%LeeDyn(3, $2E6, !P2Tile3+$10)
	%SwdDyn(2, $000, !P2Tile5)
	%SwdDyn(2, $010, !P2Tile5+$10)
	%SwdDyn(5, $011, !P2Tile6)
	%SwdDyn(5, $021, !P2Tile6+$10)
	..End
	.HangSlashDynamo2
	db ..End-..Start
	..Start
	%LeeDyn(3, $2B9, !P2Tile1)
	%LeeDyn(3, $2C9, !P2Tile1+$10)
	%LeeDyn(3, $2D9, !P2Tile3)
	%LeeDyn(3, $2E9, !P2Tile3+$10)
	%SwdDyn(5, $040, !P2Tile5)
	%SwdDyn(5, $050, !P2Tile5+$10)
	..End
	.HangSlashDynamo3
	db ..End-..Start
	..Start
	%LeeDyn(3, $2BC, !P2Tile1)
	%LeeDyn(3, $2CC, !P2Tile1+$10)
	%LeeDyn(3, $2DC, !P2Tile2+$01)
	%LeeDyn(3, $2EC, !P2Tile2+$11)
	%LeeDyn(3, $2EC, !P2Tile4)
	%LeeDyn(3, $2FC, !P2Tile4+$10)
	%SwdDyn(2, $00C, !P2Tile7)
	%SwdDyn(2, $01C, !P2Tile7+$10)
	%SwdDyn(2, $01B, !P2Tile8)
	%SwdDyn(2, $02B, !P2Tile8+$10)
	..End

	.WallClingDynamo
	db ..End-..Start
	..Start
	%LeeDyn(3, $300, !P2Tile1)
	%LeeDyn(3, $310, !P2Tile1+$10)
	%LeeDyn(3, $320, !P2Tile3)
	%LeeDyn(3, $330, !P2Tile3+$10)
	%SwdDyn(3, $028, !P2Tile5)
	%SwdDyn(3, $038, !P2Tile5+$10)
	..End

	.WallSlashDynamo0
	db ..End-..Start
	..Start
	%LeeDyn(3, $303, !P2Tile1)
	%LeeDyn(3, $313, !P2Tile1+$10)
	%LeeDyn(3, $323, !P2Tile3)
	%LeeDyn(3, $333, !P2Tile3+$10)
	%SwdDyn(3, $05D, !P2Tile6)
	%SwdDyn(3, $06D, !P2Tile6+$10)
	..End
	.WallSlashDynamo1
	db ..End-..Start
	..Start
	%LeeDyn(3, $306, !P2Tile1)
	%LeeDyn(3, $316, !P2Tile1+$10)
	%LeeDyn(3, $326, !P2Tile3)
	%LeeDyn(3, $336, !P2Tile3+$10)
	%SwdDyn(2, $000, !P2Tile5)
	%SwdDyn(2, $010, !P2Tile5+$10)
	%SwdDyn(5, $011, !P2Tile6)
	%SwdDyn(5, $021, !P2Tile6+$10)
	..End
	.WallSlashDynamo2
	db ..End-..Start
	..Start
	%LeeDyn(3, $309, !P2Tile1)
	%LeeDyn(3, $319, !P2Tile1+$10)
	%LeeDyn(3, $329, !P2Tile3)
	%LeeDyn(3, $339, !P2Tile3+$10)
	%SwdDyn(5, $040, !P2Tile5)
	%SwdDyn(5, $050, !P2Tile5+$10)
	..End
	.WallSlashDynamo3
	db ..End-..Start
	..Start
	%SwdDyn(2, $00C, !P2Tile7)
	%SwdDyn(2, $01C, !P2Tile7+$10)
	%SwdDyn(2, $01B, !P2Tile8)
	%SwdDyn(2, $02B, !P2Tile8+$10)
	..End

	.WallClimbDynamo0
	db ..End-..Start
	..Start
	%LeeDyn(3, $340, !P2Tile1)
	%LeeDyn(3, $350, !P2Tile1+$10)
	%LeeDyn(3, $360, !P2Tile3)
	%LeeDyn(3, $370, !P2Tile3+$10)
	%SwdDyn(2, $00C, !P2Tile7)
	%SwdDyn(2, $01C, !P2Tile7+$10)
	%SwdDyn(2, $01B, !P2Tile8)
	%SwdDyn(2, $02B, !P2Tile8+$10)
	..End
	.WallClimbDynamo1
	db ..End-..Start
	..Start
	%LeeDyn(3, $343, !P2Tile1)
	%LeeDyn(3, $353, !P2Tile1+$10)
	%LeeDyn(3, $363, !P2Tile3)
	%LeeDyn(3, $373, !P2Tile3+$10)
	..End
	.WallClimbDynamo2
	db ..End-..Start
	..Start
	%LeeDyn(3, $346, !P2Tile1)
	%LeeDyn(3, $356, !P2Tile1+$10)
	%LeeDyn(3, $366, !P2Tile3)
	%LeeDyn(3, $376, !P2Tile3+$10)
	..End
	.WallClimbDynamo3
	db ..End-..Start
	..Start
	%LeeDyn(3, $349, !P2Tile1)
	%LeeDyn(3, $359, !P2Tile1+$10)
	%LeeDyn(3, $369, !P2Tile3)
	%LeeDyn(3, $379, !P2Tile3+$10)
	..End

	.ClimbTopDynamo
	db ..End-..Start
	..Start
	%LeeDyn(4, $387, !P2Tile1)
	%LeeDyn(4, $397, !P2Tile1+$10)
	%LeeDyn(4, $3A7, !P2Tile3)
	%LeeDyn(4, $3B7, !P2Tile3+$10)
	%SwdDyn(3, $008, !P2Tile5)
	%SwdDyn(3, $018, !P2Tile5+$10)
	..End

	.ClimbBGDynamo
	db ..End-..Start
	..Start
	%LeeDyn(3, $39B, !P2Tile1)
	%LeeDyn(3, $3AB, !P2Tile1+$10)
	%LeeDyn(3, $3BB, !P2Tile3)
	%LeeDyn(3, $3CB, !P2Tile3+$10)
	%SwdDyn(2, $00C, !P2Tile7)
	%SwdDyn(2, $01C, !P2Tile7+$10)
	%SwdDyn(2, $01B, !P2Tile8)
	%SwdDyn(2, $02B, !P2Tile8+$10)
	..End

	.HurtDynamo
	db ..End-..Start
	..Start
	%LeeDyn(4, $393, !P2Tile1)
	%LeeDyn(4, $3A3, !P2Tile1+$10)
	%LeeDyn(4, $3B3, !P2Tile3)
	%LeeDyn(4, $3C3, !P2Tile3+$10)
	%SwdDyn(2, $00C, !P2Tile7)
	%SwdDyn(2, $01C, !P2Tile7+$10)
	%SwdDyn(2, $01B, !P2Tile8)
	%SwdDyn(2, $02B, !P2Tile8+$10)
	..End

	.DeadDynamo
	db ..End-..Start
	..Start
	%LeeDyn(3, $390, !P2Tile1)
	%LeeDyn(3, $3A0, !P2Tile1+$10)
	%LeeDyn(3, $3B0, !P2Tile3)
	%LeeDyn(3, $3C0, !P2Tile3+$10)
	%SwdDyn(3, $05D, !P2Tile6)
	%SwdDyn(3, $06D, !P2Tile6+$10)
	..End

	.VictoryDynamo0
	db ..End-..Start
	..Start
	%LeeDyn(3, $30C, !P2Tile1)
	%LeeDyn(3, $31C, !P2Tile1+$10)
	%LeeDyn(3, $32C, !P2Tile3)
	%LeeDyn(3, $33C, !P2Tile3+$10)
	%SwdDyn(2, $006, !P2Tile5+$01)
	%SwdDyn(2, $016, !P2Tile5+$11)
	%SwdDyn(2, $016, !P2Tile6+$01)
	%SwdDyn(2, $026, !P2Tile6+$11)
	..End
	.VictoryDynamo1
	db ..End-..Start
	..Start
	%LeeDyn(3, $34C, !P2Tile1)
	%LeeDyn(3, $35C, !P2Tile1+$10)
	%LeeDyn(3, $36C, !P2Tile3)
	%LeeDyn(3, $37C, !P2Tile3+$10)
	..End


; Clipping format is:
;	Xdisp of vertical bar, right then left
;	Xdisp of horizontal bar, down then up
;	Ydisp of vertical bar, right then left
;	Ydisp of horizontal bar, down then up
;	Length of vertical bar, right then left
;	Length of horizontal bar, down then up
; A clipping table is always exactly 12 bytes.
=======
	.WallClimbTM
	dw $0010
	db $20,$00,$F0,!P1Tile1
	db $20,$08,$F0,!P1Tile1+1
	db $20,$00,$00,!P1Tile5
	db $20,$08,$00,!P1Tile5+1

	.WallClimbTopTM
	dw $0010
	db $20,$F9,$F6,!P1Tile1
	db $20,$01,$F6,!P1Tile1+1
	db $20,$F9,$06,!P1Tile5
	db $20,$01,$06,!P1Tile5+1




; NOTE: leeway dynamo has to be stored before sword dynamo!


	; idle 1
		.Idle1Dynamo0
		db ..end-..start
		..start
		%Dyn24Bit(3, $000, !P1Tile1)
		%Dyn24Bit(3, $010, !P1Tile1+$10)
		%Dyn24Bit(3, $020, !P1Tile5)
		%Dyn24Bit(3, $030, !P1Tile5+$10)
		%Dyn24BitFile2(3, $023, !P1Tile7)
		%Dyn24BitFile2(3, $033, !P1Tile7+$10)
		..end
		.Idle1Dynamo1
		db ..end-..start
		..start
		%Dyn24Bit(3, $003, !P1Tile1)
		%Dyn24Bit(3, $013, !P1Tile1+$10)
		%Dyn24Bit(3, $023, !P1Tile5)
		%Dyn24Bit(3, $033, !P1Tile5+$10)
		..end
		.Idle1Dynamo2
		db ..end-..start
		..start
		%Dyn24Bit(3, $006, !P1Tile1)
		%Dyn24Bit(3, $016, !P1Tile1+$10)
		%Dyn24Bit(3, $026, !P1Tile5)
		%Dyn24Bit(3, $036, !P1Tile5+$10)
		..end

	; idle transition
		.IdleTransitionDynamo
		db ..end-..start
		..start
		%Dyn24Bit(3, $009, !P1Tile1)
		%Dyn24Bit(3, $019, !P1Tile1+$10)
		%Dyn24Bit(3, $029, !P1Tile5)
		%Dyn24Bit(3, $039, !P1Tile5+$10)
		%Dyn24BitFile2(3, $030, !P1Tile7)
		..end

	; idle 2
		.Idle2Dynamo0
		db ..end-..start
		..start
		%Dyn24Bit(3, $040, !P1Tile1)
		%Dyn24Bit(3, $050, !P1Tile1+$10)
		%Dyn24Bit(3, $060, !P1Tile5)
		%Dyn24Bit(3, $070, !P1Tile5+$10)
		%Dyn24BitFile2(3, $023, !P1Tile7)
		%Dyn24BitFile2(3, $033, !P1Tile7+$10)
		..end
		.Idle2Dynamo1
		db ..end-..start
		..start
		%Dyn24Bit(3, $043, !P1Tile1)
		%Dyn24Bit(3, $053, !P1Tile1+$10)
		%Dyn24Bit(3, $063, !P1Tile5)
		%Dyn24Bit(3, $073, !P1Tile5+$10)
		..end
		.Idle2Dynamo2
		db ..end-..start
		..start
		%Dyn24Bit(3, $046, !P1Tile1)
		%Dyn24Bit(3, $056, !P1Tile1+$10)
		%Dyn24Bit(3, $066, !P1Tile5)
		%Dyn24Bit(3, $076, !P1Tile5+$10)
		..end

	; walk
		.WalkDynamo0
		db ..end-..start
		..start
		%Dyn24Bit(3, $140, !P1Tile1)
		%Dyn24Bit(3, $150, !P1Tile1+$10)
		%Dyn24Bit(3, $160, !P1Tile5)
		%Dyn24Bit(3, $170, !P1Tile5+$10)
		%Dyn24BitFile2(3, $030, !P1Tile7)
		..end
		.WalkDynamo1
		db ..end-..start
		..start
		%Dyn24Bit(3, $143, !P1Tile1)
		%Dyn24Bit(3, $153, !P1Tile1+$10)
		%Dyn24Bit(3, $163, !P1Tile5)
		%Dyn24Bit(3, $173, !P1Tile5+$10)
		%Dyn24BitFile2(3, $023, !P1Tile7)
		%Dyn24BitFile2(3, $033, !P1Tile7+$10)
		..end
		.WalkDynamo2
		db ..end-..start
		..start
		%Dyn24Bit(3, $146, !P1Tile1)
		%Dyn24Bit(3, $156, !P1Tile1+$10)
		%Dyn24Bit(3, $166, !P1Tile5)
		%Dyn24Bit(3, $176, !P1Tile5+$10)
		%Dyn24BitFile2(3, $030, !P1Tile7)
		..end
		.WalkDynamo3
		db ..end-..start
		..start
		%Dyn24Bit(3, $149, !P1Tile1)
		%Dyn24Bit(3, $159, !P1Tile1+$10)
		%Dyn24Bit(3, $169, !P1Tile5)
		%Dyn24Bit(3, $179, !P1Tile5+$10)
		%Dyn24BitFile2(3, $023, !P1Tile7)
		%Dyn24BitFile2(3, $033, !P1Tile7+$10)
		..end
		.WalkDynamo4
		db ..end-..start
		..start
		%Dyn24Bit(3, $180, !P1Tile1)
		%Dyn24Bit(3, $190, !P1Tile1+$10)
		%Dyn24Bit(3, $1A0, !P1Tile5)
		%Dyn24Bit(3, $1B0, !P1Tile5+$10)
		%Dyn24BitFile2(3, $027, !P1Tile4+$10)
		%Dyn24BitFile2(3, $036, !P1Tile7+$01)
		%Dyn24BitFile2(2, $029, !P1Tile7+$11)
		..end
		.WalkDynamo5
		db ..end-..start
		..start
		%Dyn24Bit(3, $183, !P1Tile1)
		%Dyn24Bit(3, $193, !P1Tile1+$10)
		%Dyn24Bit(3, $1A3, !P1Tile5)
		%Dyn24Bit(3, $1B3, !P1Tile5+$10)
		%Dyn24BitFile2(3, $023, !P1Tile7)
		%Dyn24BitFile2(3, $033, !P1Tile7+$10)
		..end

	; kick
		.KickDynamo
		db ..end-..start
		..start
		%Dyn24Bit(3, $106, !P1Tile1)
		%Dyn24Bit(3, $116, !P1Tile1+$10)
		%Dyn24Bit(3, $126, !P1Tile5)
		%Dyn24Bit(3, $136, !P1Tile5+$10)
		%Dyn24BitFile2(3, $027, !P1Tile4+$10)
		%Dyn24BitFile2(3, $036, !P1Tile7+$01)
		%Dyn24BitFile2(2, $029, !P1Tile7+$11)
		..end

	; crouch transition
		.CrouchTransitionDynamo
		db ..end-..start
		..start
		%Dyn24Bit(4, $13C, !P1Tile1)
		%Dyn24Bit(4, $14C, !P1Tile1+$10)
		%Dyn24Bit(4, $15C, !P1Tile5)
		%Dyn24BitFile2(3, $023, !P1Tile7)
		%Dyn24BitFile2(3, $033, !P1Tile7+$10)
		..end

	; crouch
		.CrouchDynamo0
		db ..end-..start
		..start
		%Dyn24Bit(4, $16C, !P1Tile1)
		%Dyn24Bit(4, $17C, !P1Tile1+$10)
		%Dyn24Bit(4, $18C, !P1Tile5)
		%Dyn24BitFile2(3, $030, !P1Tile7)
		..end
		.CrouchDynamo1
		db ..end-..start
		..start
		%Dyn24Bit(4, $19C, !P1Tile1)
		%Dyn24Bit(4, $1AC, !P1Tile1+$10)
		%Dyn24Bit(4, $1BC, !P1Tile5)
		%Dyn24BitFile2(3, $030, !P1Tile7)
		..end
		.CrouchDynamo2
		db ..end-..start
		..start
		%Dyn24Bit(4, $1CC, !P1Tile1)
		%Dyn24Bit(4, $1DC, !P1Tile1+$10)
		%Dyn24Bit(4, $1EC, !P1Tile5)
		%Dyn24BitFile2(3, $030, !P1Tile7)
		..end


	; surf 0
		.Surf0Dynamo
		db ..end-..start
		..start
		%Dyn24Bit(3, $0C0, !P1Tile1)
		%Dyn24Bit(3, $0D0, !P1Tile1+$10)
		%Dyn24Bit(3, $0E0, !P1Tile5)
		%Dyn24Bit(3, $0F0, !P1Tile5+$10)
		%Dyn24BitFile2(3, $030, !P1Tile7)
		..end

	; surf 1
		.Surf1Dynamo0
		db ..end-..start
		..start
		%Dyn24Bit(3, $186, !P1Tile1)
		%Dyn24Bit(3, $196, !P1Tile1+$10)
		%Dyn24Bit(3, $1A6, !P1Tile5)
		%Dyn24Bit(3, $1B6, !P1Tile5+$10)
		%Dyn24BitFile2(3, $023, !P1Tile7)
		%Dyn24BitFile2(3, $033, !P1Tile7+$10)
		..end
		.Surf1Dynamo1
		db ..end-..start
		..start
		%Dyn24Bit(3, $189, !P1Tile1)
		%Dyn24Bit(3, $199, !P1Tile1+$10)
		%Dyn24Bit(3, $1A9, !P1Tile5)
		%Dyn24Bit(3, $1B9, !P1Tile5+$10)
		..end

	; surf 2
		.Surf2Dynamo0
		db ..end-..start
		..start
		%Dyn24Bit(3, $1C0, !P1Tile1)
		%Dyn24Bit(3, $1D0, !P1Tile1+$10)
		%Dyn24Bit(3, $1E0, !P1Tile5)
		%Dyn24Bit(3, $1F0, !P1Tile5+$10)
		%Dyn24BitFile2(3, $027, !P1Tile4+$10)
		%Dyn24BitFile2(3, $036, !P1Tile7+$01)
		%Dyn24BitFile2(2, $029, !P1Tile7+$11)
		..end
		.Surf2Dynamo1
		db ..end-..start
		..start
		%Dyn24Bit(3, $1C3, !P1Tile1)
		%Dyn24Bit(3, $1D3, !P1Tile1+$10)
		%Dyn24Bit(3, $1E3, !P1Tile5)
		%Dyn24Bit(3, $1F3, !P1Tile5+$10)
		..end

	; ground attack 1
		.GroundAttackDynamo0
		db ..end-..start
		..start
		%Dyn24Bit(3, $049, !P1Tile1)
		%Dyn24Bit(3, $059, !P1Tile1+$10)
		%Dyn24Bit(3, $069, !P1Tile5)
		%Dyn24Bit(3, $079, !P1Tile5+$10)
		%Dyn24BitFile2(3, $020, !P1Tile7)
		..end
		.GroundAttackDynamo1
		db ..end-..start
		..start
		%Dyn24Bit(3, $080, !P1Tile1)
		%Dyn24Bit(3, $090, !P1Tile1+$10)
		%Dyn24Bit(3, $0A0, !P1Tile5)
		%Dyn24Bit(3, $0B0, !P1Tile5+$10)
		%Dyn24BitFile2(4, $000, !P1Tile3)
		%Dyn24BitFile2(4, $004, !P1Tile3+$10)
		%Dyn24BitFile2(4, $008, !P1Tile7)
		%Dyn24BitFile2(4, $00C, !P1Tile7+$10)
		..end
		.GroundAttackDynamo2
		db ..end-..start
		..start
		%Dyn24Bit(3, $083, !P1Tile1)
		%Dyn24Bit(3, $093, !P1Tile1+$10)
		%Dyn24Bit(3, $0A3, !P1Tile5)
		%Dyn24Bit(3, $0B3, !P1Tile5+$10)
		%Dyn24BitFile2(3, $027, !P1Tile4+$10)
		%Dyn24BitFile2(3, $036, !P1Tile7+$01)
		%Dyn24BitFile2(2, $029, !P1Tile7+$11)
		..end
		.GroundAttackDynamo3
		db ..end-..start
		..start
		%Dyn24Bit(3, $086, !P1Tile1)
		%Dyn24Bit(3, $096, !P1Tile1+$10)
		%Dyn24Bit(3, $0A6, !P1Tile5)
		%Dyn24Bit(3, $0B6, !P1Tile5+$10)
		..end

	; ground attack 2
		.UpSlashDynamo0
		db ..end-..start
		..start
		%Dyn24Bit(3, $100, !P1Tile1)
		%Dyn24Bit(3, $110, !P1Tile1+$10)
		%Dyn24Bit(3, $120, !P1Tile5)
		%Dyn24Bit(3, $130, !P1Tile5+$10)
		%Dyn24BitFile2(4, $000, !P1Tile3)
		%Dyn24BitFile2(4, $004, !P1Tile3+$10)
		%Dyn24BitFile2(4, $008, !P1Tile7)
		%Dyn24BitFile2(4, $00C, !P1Tile7+$10)
		..end
		.UpSlashDynamo1
		db ..end-..start
		..start
		%Dyn24Bit(3, $103, !P1Tile1)
		%Dyn24Bit(3, $113, !P1Tile1+$10)
		%Dyn24Bit(3, $123, !P1Tile5)
		%Dyn24Bit(3, $133, !P1Tile5+$10)
		%Dyn24BitFile2(3, $027, !P1Tile4+$10)
		%Dyn24BitFile2(3, $036, !P1Tile7+$01)
		%Dyn24BitFile2(2, $029, !P1Tile7+$11)
		..end
		.UpSlashDynamo2
		db ..end-..start
		..start
		%Dyn24Bit(3, $103, !P1Tile1)
		%Dyn24Bit(3, $113, !P1Tile1+$10)
		%Dyn24Bit(3, $123, !P1Tile5)
		%Dyn24Bit(3, $133, !P1Tile5+$10)
		..end

	; dash transition
		.DashTransitionDynamo
		db ..end-..start
		..start
		%Dyn24Bit(4, $00C, !P1Tile1)
		%Dyn24Bit(4, $01C, !P1Tile1+$10)
		%Dyn24Bit(4, $02C, !P1Tile5)
		%Dyn24Bit(4, $03C, !P1Tile5+$10)
		%Dyn24BitFile2(3, $027, !P1Tile4+$10)
		%Dyn24BitFile2(3, $036, !P1Tile7+$01)
		%Dyn24BitFile2(2, $029, !P1Tile7+$11)
		..end

	; dash
		.DashDynamo0
		db ..end-..start
		..start
		%Dyn24Bit(4, $04C, !P1Tile1)
		%Dyn24Bit(4, $05C, !P1Tile1+$10)
		%Dyn24Bit(4, $06C, !P1Tile5)
		%Dyn24BitFile2(3, $023, !P1Tile7)
		%Dyn24BitFile2(3, $033, !P1Tile7+$10)
		..end
		.DashDynamo1
		db ..end-..start
		..start
		%Dyn24Bit(4, $07C, !P1Tile1)
		%Dyn24Bit(4, $08C, !P1Tile1+$10)
		%Dyn24Bit(4, $09C, !P1Tile5)
		%Dyn24BitFile2(3, $023, !P1Tile7)
		%Dyn24BitFile2(3, $033, !P1Tile7+$10)
		..end

	; dash attack
		.DashAttackDynamo0
		db ..end-..start
		..start
		%Dyn24Bit(4, $0AC, !P1Tile1)
		%Dyn24Bit(4, $0BC, !P1Tile1+$10)
		%Dyn24Bit(4, $0CC, !P1Tile5)
		%Dyn24BitFile2(3, $020, !P1Tile7)
		..end
		.DashAttackDynamo1
		db ..end-..start
		..start
		%Dyn24Bit(4, $0DC, !P1Tile1)
		%Dyn24Bit(4, $0EC, !P1Tile1+$10)
		%Dyn24Bit(4, $0FC, !P1Tile5)
		%Dyn24BitFile2(4, $000, !P1Tile3)
		%Dyn24BitFile2(4, $004, !P1Tile3+$10)
		%Dyn24BitFile2(4, $008, !P1Tile7)
		%Dyn24BitFile2(4, $00C, !P1Tile7+$10)
		..end
		.DashAttackDynamo2
		db ..end-..start
		..start
		%Dyn24Bit(4, $10C, !P1Tile1)
		%Dyn24Bit(4, $11C, !P1Tile1+$10)
		%Dyn24Bit(4, $12C, !P1Tile5)
		%Dyn24BitFile2(3, $027, !P1Tile4+$10)
		%Dyn24BitFile2(3, $036, !P1Tile7+$01)
		%Dyn24BitFile2(2, $029, !P1Tile7+$11)
		..end

	; jump
		.JumpDynamo
		db ..end-..start
		..start
		%Dyn24Bit(3, $089, !P1Tile1)
		%Dyn24Bit(3, $099, !P1Tile1+$10)
		%Dyn24Bit(3, $0A9, !P1Tile5)
		%Dyn24Bit(3, $0B9, !P1Tile5+$10)
		%Dyn24BitFile2(3, $023, !P1Tile7)
		%Dyn24BitFile2(3, $033, !P1Tile7+$10)
		..end

	; fall
		.FallDynamo0
		db ..end-..start
		..start
		%Dyn24Bit(3, $0C0, !P1Tile1)
		%Dyn24Bit(3, $0D0, !P1Tile1+$10)
		%Dyn24Bit(3, $0E0, !P1Tile5)
		%Dyn24Bit(3, $0F0, !P1Tile5+$10)
		%Dyn24BitFile2(3, $030, !P1Tile7)
		..end
		.FallDynamo1
		db ..end-..start
		..start
		%Dyn24Bit(3, $0C3, !P1Tile1)
		%Dyn24Bit(3, $0D3, !P1Tile1+$10)
		%Dyn24Bit(3, $0E3, !P1Tile5)
		%Dyn24Bit(3, $0F3, !P1Tile5+$10)
		%Dyn24BitFile2(3, $023, !P1Tile7)
		%Dyn24BitFile2(3, $033, !P1Tile7+$10)
		..end
		.FallDynamo2
		db ..end-..start
		..start
		%Dyn24Bit(3, $0C6, !P1Tile1)
		%Dyn24Bit(3, $0D6, !P1Tile1+$10)
		%Dyn24Bit(3, $0E6, !P1Tile5)
		%Dyn24Bit(3, $0F6, !P1Tile5+$10)
		%Dyn24BitFile2(3, $023, !P1Tile7)
		%Dyn24BitFile2(3, $033, !P1Tile7+$10)
		..end

	; air attack
		.AirAttackDynamo0
		db ..end-..start
		..start
		%Dyn24Bit(3, $289, !P1Tile1)
		%Dyn24Bit(3, $299, !P1Tile1+$10)
		%Dyn24Bit(3, $2A9, !P1Tile5)
		%Dyn24Bit(3, $2B9, !P1Tile5+$10)
		%Dyn24BitFile2(3, $027, !P1Tile4+$10)
		%Dyn24BitFile2(3, $036, !P1Tile7+$01)
		%Dyn24BitFile2(2, $029, !P1Tile7+$11)
		..end
		.AirAttackDynamo1
		db ..end-..start
		..start
		%Dyn24BitFile2(3, $023, !P1Tile7)
		%Dyn24BitFile2(3, $033, !P1Tile7+$10)
		..end
		.AirAttackDynamo2
		db ..end-..start
		..start
		%Dyn24Bit(3, $089, !P1Tile1)
		%Dyn24Bit(3, $099, !P1Tile1+$10)
		%Dyn24Bit(3, $0A9, !P1Tile5)
		%Dyn24Bit(3, $0B9, !P1Tile5+$10)
		%Dyn24BitFile2(3, $030, !P1Tile7)
		..end
		.AirAttackDynamo3
		db ..end-..start
		..start
		%Dyn24BitFile2(3, $023, !P1Tile7)
		%Dyn24BitFile2(3, $033, !P1Tile7+$10)
		..end
		.AirAttackDynamo4
		db ..end-..start
		..start
		%Dyn24BitFile2(3, $027, !P1Tile4+$10)
		%Dyn24BitFile2(3, $036, !P1Tile7+$01)
		%Dyn24BitFile2(2, $029, !P1Tile7+$11)
		..end

	; double jump
		.DoubleJumpDynamo0
		db ..end-..start
		..start
		%Dyn24Bit(4, $308, !P1Tile1)
		%Dyn24Bit(4, $318, !P1Tile1+$10)
		%Dyn24Bit(4, $328, !P1Tile5)
		%Dyn24Bit(4, $338, !P1Tile5+$10)
		%Dyn24BitFile2(3, $020, !P1Tile7)
		..end
		.DoubleJumpDynamo1
		db ..end-..start
		..start
		%Dyn24Bit(4, $304, !P1Tile1)
		%Dyn24Bit(4, $314, !P1Tile1+$10)
		%Dyn24Bit(4, $324, !P1Tile5)
		%Dyn24Bit(4, $334, !P1Tile5+$10)
		%Dyn24BitFile2(3, $023, !P1Tile7)
		%Dyn24BitFile2(3, $033, !P1Tile7+$10)
		..end
		.DoubleJumpDynamo2
		db ..end-..start
		..start
		%Dyn24Bit(4, $308, !P1Tile1)
		%Dyn24Bit(4, $318, !P1Tile1+$10)
		%Dyn24Bit(4, $328, !P1Tile5)
		%Dyn24Bit(4, $338, !P1Tile5+$10)
		%Dyn24BitFile2(3, $020, !P1Tile7)
		..end
		.DoubleJumpDynamo3
		db ..end-..start
		..start
		%Dyn24Bit(4, $304, !P1Tile1)
		%Dyn24Bit(4, $314, !P1Tile1+$10)
		%Dyn24Bit(4, $324, !P1Tile5)
		%Dyn24Bit(4, $334, !P1Tile5+$10)
		%Dyn24BitFile2(3, $023, !P1Tile7)
		%Dyn24BitFile2(3, $033, !P1Tile7+$10)
		..end

	; spin attack
		.SpinAttackDynamo0
		db ..end-..start
		..start
		%Dyn24Bit(4, $300, !P1Tile1)
		%Dyn24Bit(4, $310, !P1Tile1+$10)
		%Dyn24Bit(4, $320, !P1Tile5)
		%Dyn24Bit(4, $330, !P1Tile5+$10)
		%Dyn24BitFile2(4, $000, !P1Tile3)
		%Dyn24BitFile2(4, $004, !P1Tile3+$10)
		%Dyn24BitFile2(4, $008, !P1Tile7)
		%Dyn24BitFile2(4, $00C, !P1Tile7+$10)
		..end
		.SpinAttackDynamo1
		db ..end-..start
		..start
		%Dyn24Bit(4, $304, !P1Tile1)
		%Dyn24Bit(4, $314, !P1Tile1+$10)
		%Dyn24Bit(4, $324, !P1Tile5)
		%Dyn24Bit(4, $334, !P1Tile5+$10)
		%Dyn24BitFile2(4, $010, !P1Tile3)
		%Dyn24BitFile2(4, $014, !P1Tile3+$10)
		%Dyn24BitFile2(4, $018, !P1Tile7)
		%Dyn24BitFile2(4, $01C, !P1Tile7+$10)
		..end
		.SpinAttackDynamo2
		db ..end-..start
		..start
		%Dyn24Bit(4, $308, !P1Tile1)
		%Dyn24Bit(4, $318, !P1Tile1+$10)
		%Dyn24Bit(4, $328, !P1Tile5)
		%Dyn24Bit(4, $338, !P1Tile5+$10)
		%Dyn24BitFile2(4, $000, !P1Tile3)
		%Dyn24BitFile2(4, $004, !P1Tile3+$10)
		%Dyn24BitFile2(4, $008, !P1Tile7)
		%Dyn24BitFile2(4, $00C, !P1Tile7+$10)
		..end

	; climb bg
		.ClimbBGDynamo
		db ..end-..start
		..start
		%Dyn24Bit(3, $246, !P1Tile1)
		%Dyn24Bit(3, $256, !P1Tile1+$10)
		%Dyn24Bit(3, $266, !P1Tile5)
		%Dyn24Bit(3, $276, !P1Tile5+$10)
		..end

	; wall climb
		.WallClimbDynamo0
		db ..end-..start
		..start
		%Dyn24Bit(3, $1C6, !P1Tile1)
		%Dyn24Bit(3, $1D6, !P1Tile1+$10)
		%Dyn24Bit(3, $1E6, !P1Tile5)
		%Dyn24Bit(3, $1F6, !P1Tile5+$10)
		%Dyn24BitFile2(3, $027, !P1Tile4+$10)
		%Dyn24BitFile2(3, $036, !P1Tile7+$01)
		%Dyn24BitFile2(2, $029, !P1Tile7+$11)
		..end
		.WallClimbDynamo1
		db ..end-..start
		..start
		%Dyn24Bit(3, $1C9, !P1Tile1)
		%Dyn24Bit(3, $1D9, !P1Tile1+$10)
		%Dyn24Bit(3, $1E9, !P1Tile5)
		%Dyn24Bit(3, $1F9, !P1Tile5+$10)
		%Dyn24BitFile2(3, $020, !P1Tile7)
		..end
		.WallClimbDynamo2
		db ..end-..start
		..start
		%Dyn24Bit(3, $200, !P1Tile1)
		%Dyn24Bit(3, $210, !P1Tile1+$10)
		%Dyn24Bit(3, $220, !P1Tile5)
		%Dyn24Bit(3, $230, !P1Tile5+$10)
		%Dyn24BitFile2(3, $020, !P1Tile7)
		..end
		.WallClimbDynamo3
		db ..end-..start
		..start
		%Dyn24Bit(3, $203, !P1Tile1)
		%Dyn24Bit(3, $213, !P1Tile1+$10)
		%Dyn24Bit(3, $223, !P1Tile5)
		%Dyn24Bit(3, $233, !P1Tile5+$10)
		%Dyn24BitFile2(3, $027, !P1Tile4+$10)
		%Dyn24BitFile2(3, $036, !P1Tile7+$01)
		%Dyn24BitFile2(2, $029, !P1Tile7+$11)
		..end

	; wall climb top
		.WallClimbTopDynamo0
		db ..end-..start
		..start
		%Dyn24Bit(3, $206, !P1Tile1)
		%Dyn24Bit(3, $216, !P1Tile1+$10)
		%Dyn24Bit(3, $226, !P1Tile5)
		%Dyn24Bit(3, $236, !P1Tile5+$10)
		%Dyn24BitFile2(3, $023, !P1Tile7)
		%Dyn24BitFile2(3, $033, !P1Tile7+$10)
		..end
		.WallClimbTopDynamo1
		db ..end-..start
		..start
		%Dyn24Bit(4, $13C, !P1Tile1)
		%Dyn24Bit(4, $14C, !P1Tile1+$10)
		%Dyn24Bit(4, $15C, !P1Tile5)
		%Dyn24BitFile2(3, $030, !P1Tile7)
		..end
		.WallClimbTopDynamo2
		db ..end-..start
		..start
		%Dyn24Bit(4, $00C, !P1Tile1)
		%Dyn24Bit(4, $01C, !P1Tile1+$10)
		%Dyn24Bit(4, $02C, !P1Tile5)
		%Dyn24Bit(4, $03C, !P1Tile5+$10)
		%Dyn24BitFile2(3, $030, !P1Tile7)
		..end

	; wall attack
		.WallAttackDynamo0
		db ..end-..start
		..start
		%Dyn24Bit(3, $209, !P1Tile1)
		%Dyn24Bit(3, $219, !P1Tile1+$10)
		%Dyn24Bit(3, $229, !P1Tile5)
		%Dyn24Bit(3, $239, !P1Tile5+$10)
		%Dyn24BitFile2(3, $027, !P1Tile4+$10)
		%Dyn24BitFile2(3, $036, !P1Tile7+$01)
		%Dyn24BitFile2(2, $029, !P1Tile7+$11)
		..end
		.WallAttackDynamo1
		db ..end-..start
		..start
		%Dyn24Bit(3, $20C, !P1Tile1)
		%Dyn24Bit(3, $21C, !P1Tile1+$10)
		%Dyn24Bit(3, $22C, !P1Tile5)
		%Dyn24Bit(3, $23C, !P1Tile5+$10)
		%Dyn24BitFile2(3, $020, !P1Tile7)
		..end
		.WallAttackDynamo2
		db ..end-..start
		..start
		%Dyn24Bit(3, $240, !P1Tile1)
		%Dyn24Bit(3, $250, !P1Tile1+$10)
		%Dyn24Bit(3, $260, !P1Tile5)
		%Dyn24Bit(3, $270, !P1Tile5+$10)
		%Dyn24BitFile2(4, $000, !P1Tile3)
		%Dyn24BitFile2(4, $004, !P1Tile3+$10)
		%Dyn24BitFile2(4, $008, !P1Tile7)
		%Dyn24BitFile2(4, $00C, !P1Tile7+$10)
		..end
		.WallAttackDynamo3
		db ..end-..start
		..start
		%Dyn24Bit(3, $243, !P1Tile1)
		%Dyn24Bit(3, $253, !P1Tile1+$10)
		%Dyn24Bit(3, $263, !P1Tile5)
		%Dyn24Bit(3, $273, !P1Tile5+$10)
		%Dyn24BitFile2(3, $027, !P1Tile4+$10)
		%Dyn24BitFile2(3, $036, !P1Tile7+$01)
		%Dyn24BitFile2(2, $029, !P1Tile7+$11)
		..end

	; ceiling hang
		.CeilingHangDynamo
		db ..end-..start
		..start
		%Dyn24Bit(3, $2C3, !P1Tile1)
		%Dyn24Bit(3, $2D3, !P1Tile1+$10)
		%Dyn24Bit(3, $2E3, !P1Tile5)
		%Dyn24Bit(3, $2F3, !P1Tile5+$10)
		%Dyn24BitFile2(3, $027, !P1Tile4+$10)
		%Dyn24BitFile2(3, $036, !P1Tile7+$01)
		%Dyn24BitFile2(2, $029, !P1Tile7+$11)
		..end

	; ceiling climb
		.CeilingClimbDynamo0
		db ..end-..start
		..start
		%Dyn24Bit(3, $280, !P1Tile1)
		%Dyn24Bit(3, $290, !P1Tile1+$10)
		%Dyn24Bit(3, $2A0, !P1Tile5)
		%Dyn24Bit(3, $2B0, !P1Tile5+$10)
		%Dyn24BitFile2(3, $023, !P1Tile7)
		%Dyn24BitFile2(3, $033, !P1Tile7+$10)
		..end
		.CeilingClimbDynamo1
		db ..end-..start
		..start
		%Dyn24Bit(3, $283, !P1Tile1)
		%Dyn24Bit(3, $293, !P1Tile1+$10)
		%Dyn24Bit(3, $2A3, !P1Tile5)
		%Dyn24Bit(3, $2B3, !P1Tile5+$10)
		%Dyn24BitFile2(3, $027, !P1Tile4+$10)
		%Dyn24BitFile2(3, $036, !P1Tile7+$01)
		%Dyn24BitFile2(2, $029, !P1Tile7+$11)
		..end
		.CeilingClimbDynamo2
		db ..end-..start
		..start
		%Dyn24Bit(3, $286, !P1Tile1)
		%Dyn24Bit(3, $296, !P1Tile1+$10)
		%Dyn24Bit(3, $2A6, !P1Tile5)
		%Dyn24Bit(3, $2B6, !P1Tile5+$10)
		%Dyn24BitFile2(3, $027, !P1Tile4+$10)
		%Dyn24BitFile2(3, $036, !P1Tile7+$01)
		%Dyn24BitFile2(2, $029, !P1Tile7+$11)
		..end
		.CeilingClimbDynamo3
		db ..end-..start
		..start
		%Dyn24Bit(3, $289, !P1Tile1)
		%Dyn24Bit(3, $299, !P1Tile1+$10)
		%Dyn24Bit(3, $2A9, !P1Tile5)
		%Dyn24Bit(3, $2B9, !P1Tile5+$10)
		%Dyn24BitFile2(3, $023, !P1Tile7)
		%Dyn24BitFile2(3, $033, !P1Tile7+$10)
		..end
		.CeilingClimbDynamo4
		db ..end-..start
		..start
		%Dyn24Bit(3, $28C, !P1Tile1)
		%Dyn24Bit(3, $29C, !P1Tile1+$10)
		%Dyn24Bit(3, $2AC, !P1Tile5)
		%Dyn24Bit(3, $2BC, !P1Tile5+$10)
		%Dyn24BitFile2(3, $027, !P1Tile4+$10)
		%Dyn24BitFile2(3, $036, !P1Tile7+$01)
		%Dyn24BitFile2(2, $029, !P1Tile7+$11)
		..end
		.CeilingClimbDynamo5
		db ..end-..start
		..start
		%Dyn24Bit(3, $2C0, !P1Tile1)
		%Dyn24Bit(3, $2D0, !P1Tile1+$10)
		%Dyn24Bit(3, $2E0, !P1Tile5)
		%Dyn24Bit(3, $2F0, !P1Tile5+$10)
		%Dyn24BitFile2(3, $027, !P1Tile4+$10)
		%Dyn24BitFile2(3, $036, !P1Tile7+$01)
		%Dyn24BitFile2(2, $029, !P1Tile7+$11)
		..end

	; ceiling attack
		.CeilingAttackDynamo0
		db ..end-..start
		..start
		%Dyn24Bit(3, $2C6, !P1Tile1)
		%Dyn24Bit(3, $2D6, !P1Tile1+$10)
		%Dyn24Bit(3, $2E6, !P1Tile5)
		%Dyn24Bit(3, $2F6, !P1Tile5+$10)
		%Dyn24BitFile2(3, $023, !P1Tile7)
		%Dyn24BitFile2(3, $033, !P1Tile7+$10)
		..end
		.CeilingAttackDynamo1
		db ..end-..start
		..start
		%Dyn24Bit(3, $2C9, !P1Tile1)
		%Dyn24Bit(3, $2D9, !P1Tile1+$10)
		%Dyn24Bit(3, $2E9, !P1Tile5)
		%Dyn24Bit(3, $2F9, !P1Tile5+$10)
		%Dyn24BitFile2(4, $000, !P1Tile3)
		%Dyn24BitFile2(4, $004, !P1Tile3+$10)
		%Dyn24BitFile2(4, $008, !P1Tile7)
		%Dyn24BitFile2(4, $00C, !P1Tile7+$10)
		..end
		.CeilingAttackDynamo2
		db ..end-..start
		..start
		%Dyn24Bit(3, $2CC, !P1Tile1)
		%Dyn24Bit(3, $2DC, !P1Tile1+$10)
		%Dyn24Bit(3, $2EC, !P1Tile5)
		%Dyn24Bit(3, $2FC, !P1Tile5+$10)
		%Dyn24BitFile2(3, $027, !P1Tile4+$10)
		%Dyn24BitFile2(3, $036, !P1Tile7+$01)
		%Dyn24BitFile2(2, $029, !P1Tile7+$11)
		..end

	; hurt
		.HurtDynamo
		db ..end-..start
		..start
		%Dyn24Bit(3, $0C9, !P1Tile1)
		%Dyn24Bit(3, $0D9, !P1Tile1+$10)
		%Dyn24Bit(3, $0E9, !P1Tile5)
		%Dyn24Bit(3, $0F9, !P1Tile5+$10)
		%Dyn24BitFile2(3, $023, !P1Tile7)
		%Dyn24BitFile2(3, $033, !P1Tile7+$10)
		..end

	; dead
		.DeadDynamo
		db ..end-..start
		..start
		%Dyn24Bit(3, $109, !P1Tile1)
		%Dyn24Bit(3, $119, !P1Tile1+$10)
		%Dyn24Bit(3, $129, !P1Tile5)
		%Dyn24Bit(3, $139, !P1Tile5+$10)
		%Dyn24BitFile2(3, $023, !P1Tile7)
		%Dyn24BitFile2(3, $033, !P1Tile7+$10)
		..end

	; victory
		.VictoryDynamo0
		db ..end-..start
		..start
		%Dyn24Bit(3, $249, !P1Tile1)
		%Dyn24Bit(3, $259, !P1Tile1+$10)
		%Dyn24Bit(3, $269, !P1Tile5)
		%Dyn24Bit(3, $279, !P1Tile5+$10)
		%Dyn24BitFile2(3, $020, !P1Tile7)
		..end
		.VictoryDynamo1
		db ..end-..start
		..start
		%Dyn24Bit(3, $24C, !P1Tile1)
		%Dyn24Bit(3, $25C, !P1Tile1+$10)
		%Dyn24Bit(3, $26C, !P1Tile5)
		%Dyn24Bit(3, $27C, !P1Tile5+$10)
		%Dyn24BitFile2(3, $020, !P1Tile7)
		..end

	; sleep
		.SleepDynamo
		db ..end-..start
		..start
		%Dyn24Bit(3, $30C, !P1Tile1)
		%Dyn24Bit(3, $31C, !P1Tile1+$10)
		%Dyn24Bit(3, $32C, !P1Tile5)
		%Dyn24Bit(3, $33C, !P1Tile5+$10)
		%Dyn24BitFile2(3, $020, !P1Tile7)
		..end
>>>>>>> Stashed changes


	.ClippingStandard
	db $0D,$02,$05,$05		; < X offset
	db $FF,$FF,$10,$F4		; < Y offset
	db $10,$10,$05,$05		; < Size

	.ClippingCrawl
	db $0D,$02,$05,$05		; < X offset
	db $05,$05,$10,$00		; < Y offset
	db $0A,$0A,$05,$05		; < Size

	.ClippingWall
<<<<<<< Updated upstream
	db $0D,$02,$05,$05		; < X offset
	db $FF,$FF,$10,$F4		; < Y offset
	db $04,$04,$05,$05		; < Size

=======
	; X
	db $0E,$01,$0E,$01		; R/L/R/L
	db $04,$0B,$08,$08		; D/D/U/C
	; Y
	db $FF,$FF,$03,$03		; R/L/R/L
	db $10,$10,$F4,$04		; D/D/U/C
	; hurtbox
	dw $0001,$FFF8			; X/Y
	db $0D,$18			; W/H


	.ClippingDash
	; X
	db $0E,$01,$0E,$01		; R/L/R/L
	db $04,$0B,$08,$08		; D/D/U/C
	; Y
	db $FF,$FF,$0A,$0A		; R/L/R/L
	db $10,$10,$F8,$02		; D/D/U/C
	; hurtbox
	dw $0001,$FFFC			; X/Y
	db $10,$14			; W/H
>>>>>>> Stashed changes


.End
print "  Anim data: $", hex(.End-ANIM), " bytes"




<<<<<<< Updated upstream
	.Idle0				; 00
	dw .HorzTM : db $F5,$08
	dw $0000,$0000
	.Idle1				; 01
	dw .HorzTM : db $F5,$08
	dw $0000,$0000
	.Idle2				; 02
	dw .HorzTM : db $F5,$08
	dw $0000,$0000

	.Walk0				; 03
	dw .HorzTM : db $F5,$07
	dw $0000,$0000
	.Walk1				; 04
	dw .HorzTM : db $EF,$02
	dw $0000,$0000
	.Walk2				; 05
	dw .HorzTM : db $F3,$04
	dw $0000,$0000
	.Walk3				; 06
	dw .HorzTM : db $F7,$06
	dw $0000,$0000

	.CutStart			; 07
	dw .PrepTM : db $E7,$05
	dw $0000,$0000
	.Cut0				; 08
	dw .CutTM0 : db $EC,$F2
	dw $FFFF,$0000
	.Cut1				; 09
	dw .CutTM1 : db $FC,$F2
	dw $FFFF,$0000
	.Cut3				; 0A
	dw .HoldBackTM : db $14,$F3
	dw $0000,$0000
	.Cut4				; 0B
	dw .HoldBackTM : db $14,$F3
	dw $0000,$0000

	.Slash0				; 0C
	dw .SlashTM0 : db $DE,$FE
	dw $0000,$0000
	.Slash1				; 0D
	dw .SlashTM1 : db $E6,$06
	dw $0000,$0000
	.Slash2				; 0E
	dw .DiaTM : db $FE,$06
	dw $0000,$0000
	.Slash3				; 0F
	dw .DiaTM : db $FE,$06
	dw $0000,$0000

	.Dash0				; 10
	dw .HorzTM : db $FC,$06
	dw $0000,$0000
	.Dash1				; 11
	dw .HorzTM : db $FC,$06
	dw $0000,$0000
	.Dash2				; 12
	dw .HorzTM : db $FC,$06
	dw $0000,$0000

	.DashSlash0			; 13
	dw .PrepTM : db $E7,$05
	dw $0000,$0000
	.DashSlash1			; 14
	dw .CutTM0 : db $EB,$F0
	dw $FFFF,$0000
	.DashSlash2			; 15
	dw .CutTM1 : db $FB,$F0
	dw $FFFF,$0000
	.DashSlash3			; 16
	dw .HoldBackTM : db $13,$F1
	dw $FFFF,$0000
	.DashSlash4			; 17
	dw .HoldBackTM : db $13,$F1
	dw $FFFF,$0000

	.Jump				; 18
	dw .HoldBackTM : db $0D,$EF
	dw $0000,$0000
	.Fall0				; 19
	dw .FallTM : db $09,$08
	dw $0000,$0000
	.Fall1				; 1A
	dw .FallTM : db $09,$08
	dw $0000,$0000

	.SlowFall0			; 1B
	dw .DiaTM : db $05,$03
	dw $0000,$0000
	.SlowFall1			; 1C
	dw .DiaTM : db $05,$03
	dw $0000,$0000
	.SlowFall2			; 1D
	dw .DiaTM : db $05,$03
	dw $0000,$0000

	.CeilingClimb0			; 1E
	dw .NoTM : db $00,$00
	dw $0000,$0000
	.CeilingClimb1			; 1F
	dw .NoTM : db $00,$00
	dw $0000,$0000
	.CeilingClimb2			; 20
	dw .NoTM : db $00,$00
	dw $0000,$0000
	.CeilingClimb3			; 21
	dw .NoTM : db $00,$00
	dw $0000,$0000
	.CeilingClimb4			; 22
	dw .NoTM : db $00,$00
	dw $0000,$0000
	.CeilingClimb5			; 23
	dw .NoTM : db $00,$00
	dw $0000,$0000

	.CrouchStart0			; 24
	dw .HorzTM : db $F2,$07
	dw $0000,$0000
	.CrouchStart1			; 25
	dw .HorzTM : db $F1,$09
	dw $0000,$0000

	.Crawl0				; 26
	dw .HorzTM : db $F2,$09
	dw $0000,$0000
	.Crawl1				; 27
	dw .HorzTM : db $F5,$09
	dw $0000,$0000
	.Crawl2				; 28
	dw .HorzTM : db $F2,$09
	dw $0000,$0000
	.Crawl3				; 29
	dw .HorzTM : db $EF,$09
	dw $0000,$0000

	.CrouchEnd			; 2A
	dw .HorzTM : db $F2,$07
	dw $0000,$0000

	.AirSlash0			; 2B
	dw .PrepTM : db $EE,$F9
	dw $FFFF,$0000
	.AirSlash1			; 2C
	dw .SlashTM0 : db $E0,$FC
	dw $0000,$0000
	.AirSlash2			; 2D
	dw .SlashTM1 : db $E8,$04
	dw $0000,$0000
	.AirSlash3			; 2E
	dw .DiaTM : db $00,$04
	dw $0000,$0000

	.Hang				; 2F
	dw .DiaTM : db $02,$07
	dw $0000,$0000

	.HangSlash0			; 30
	dw .HoldBackTM : db $0E,$EB
	dw $0000,$0000
	.HangSlash1			; 31
	dw .SmallSlashTM : db $D7,$FD
	dw $0000,$0000
	.HangSlash2			; 32
	dw .SlashTM1 : db $DF,$05
	dw $0000,$0000
	.HangSlash3			; 33
	dw .DiaTM : db $FE,$06
	dw $0000,$0000

	.WallCling			; 34
	dw .WHorzTM : db $E7,$03
	dw $0000,$0000

	.WallSlash0			; 35
	dw .WHoldBackTM : db $01,$F4
	dw $FFFF,$0000
	.WallSlash1			; 36
	dw .WSlashTM0 : db $D2,$00
	dw $0000,$0000
	.WallSlash2			; 37
	dw .WSlashTM1 : db $DA,$08
	dw $0000,$0000
	.WallSlash3			; 38
	dw .WDiaTM : db $F2,$08
	dw $0000,$0000

	.WallClimb0			; 39
	dw .ClimbTM : db $EC,$07
	dw $FFFF,$0000
	.WallClimb1			; 3A
	dw .ClimbTM : db $EC,$07
	dw $FFFF,$0000
	.WallClimb2			; 3B
	dw .ClimbTM : db $EC,$07
	dw $FFFF,$0000
	.WallClimb3			; 3C
	dw .ClimbTM : db $EC,$07
	dw $FFFF,$0000

	.ClimbTop			; 3D
	dw .PrepTM : db $EB,$03
	dw $0000,$0000

	.ClimbBG0			; 3E
	dw .DiaTM : db $04,$FC
	dw $0000,$0000
	.ClimbBG1			; 3F
	dw .DiaTM : db $04,$FE
	dw $0000,$0000

	.Hurt				; 40
	dw .DiaTM : db $05,$02
	dw $0000,$0000

	.Dead				; 41
	dw .HoldBackTM : db $0E,$F4
	dw $0000,$0000

	.Victory0			; 42
	dw .HoldUpTM : db $05,$E7
	dw $0000,$0000
	.Victory1			; 43
	dw .HoldUpTM : db $04,$E5
	dw $0000,$0000
=======
; format:
; 00 - tilemap
; 02 - X offset
; 03 - Y offset
; 04 - sword priority (0 = sword in front, anything else = body in front)
; 05 - held item priority (0 = item in front, anything else = body in front), checked by sprite
; 06 - held item X offset
; 07 - held item Y offset

>>>>>>> Stashed changes

; these are base coordinates for held items
	!tempx = $FD
	!tempy = $F3


	SWORD:
	; idle 1
		.Idle1Frame0
		dw .SlantDownTM : db $FD,$04
		db $00
		db $00
		db !tempx+$0F,!tempy+$02
		.Idle1Frame1
		dw .SlantDownTM : db $FD,$04
		db $00
		db $00
		db !tempx+$0F,!tempy+$02
		.Idle1Frame2
		dw .SlantDownTM : db $FD,$04
		db $00
		db $00
		db !tempx+$0F,!tempy+$02

	; sleep
		.Sleep
		dw .StuckTM : db $0A,$00
		db $FF
		db $FF
		db !tempx+$F8,!tempy+$0C

	; idle transition
		.IdleTransition0
		dw .HorzTM : db $FD,$02
		db $00
		db $00
		db !tempx+$0F,!tempy+$02
		.IdleTransition1
		dw .HorzTM : db $FD,$02
		db $00
		db $00
		db !tempx+$0F,!tempy+$02

	; idle 2
		.Idle2Frame0
		dw .SlantUpTM : db $FF,$FF
		db $00
		db $00
		db !tempx+$0F,!tempy+$03
		.Idle2Frame1
		dw .SlantUpTM : db $FF,$FF
		db $00
		db $00
		db !tempx+$0F,!tempy+$03
		.Idle2Frame2
		dw .SlantUpTM : db $FF,$FF
		db $00
		db $00
		db !tempx+$0F,!tempy+$03

	; walk
		.Walk0
		dw .HorzTM : db $02,$02
		db $00
		db $00
		db !tempx+$07,!tempy+$02
		.Walk1
		dw .SlantUpTM : db $FC,$FD		; body tilemap displaced (-3 Y)
		db $00
		db $00
		db !tempx+$0E,!tempy+$04
		.Walk2
		dw .HorzTM : db $FF,$02
		db $00
		db $00
		db !tempx+$0D,!tempy+$03
		.Walk3
		dw .SlantDownTM : db $06,$01
		db $FF
		db $00
		db !tempx+$06,!tempy+$01
		.Walk4
		dw .DiagonalDownTM : db $0E,$00		; body tilemap displaced (-2 Y)
		db $FF
		db $00
		db !tempx+$FF,!tempy+$FF
		.Walk5
		dw .SlantDownTM : db $0C,$01
		db $FF
		db $00
		db !tempx+$03,!tempy+$02

	; kick
		.Kick
		dw .DiagonalUpTM_reverse : db $0F,$FB
		db $00
		db $00
		db !tempx+$0F,!tempy+$03

	; crouch transition
		.CrouchTransition0
		dw .SlantDownTM : db $06,$06
		db $00
		db $FF
		db !tempx+$06,!tempy+$06
		.CrouchTransition1
		dw .SlantDownTM : db $06,$06
		db $00
		db $FF
		db !tempx+$06,!tempy+$FD

	; crouch
		.Crouch0
		dw .HorzTM : db $03,$0C
		db $00
		db $FF
		db !tempx+$03,!tempy+$07
		.Crouch1
		dw .HorzTM : db $05,$0C
		db $00
		db $FF
		db !tempx+$03,!tempy+$07
		.Crouch2
		dw .HorzTM : db $03,$0C
		db $00
		db $FF
		db !tempx+$03,!tempy+$07
		.Crouch3
		dw .HorzTM : db $01,$0C
		db $00
		db $FF
		db !tempx+$03,!tempy+$07

	; surf 0
		.Surf0
		dw .HorzTM : db $12,$0C
		db $FF
		db $00
		db !tempx+$0F,!tempy+$FD

	; surf 1
		.Surf1Frame0
		dw .SlantDownTM : db $10,$06
		db $FF
		db $00
		db !tempx+$0E,!tempy+$FC
		.Surf1Frame1
		dw .SlantDownTM : db $10,$06
		db $FF
		db $00
		db !tempx+$0E,!tempy+$FC

	; surf 2
		.Surf2Frame0
		dw .DiagonalDownTM : db $0F,$03
		db $FF
		db $00
		db !tempx+$0D,!tempy+$F9
		.Surf2Frame1
		dw .DiagonalDownTM : db $0F,$03
		db $FF
		db $00
		db !tempx+$0D,!tempy+$F9

	; ground attack 1
		.GroundAttack1Frame0
		dw .StraightUpTM : db $FF,$F0
		db $00
		db $00
		db !tempx+$0D,!tempy+$00
		.GroundAttack1Frame1
		dw .BigSlashDownTM : db $FC,$02
		db $00
		db $00
		db !tempx+$0F,!tempy+$03
		.GroundAttack1Frame2
		dw .AfterSlashDownTM : db $FE,$08
		db $00
		db $00
		db !tempx+$0E,!tempy+$00
		.GroundAttack1Frame3
		dw .DiagonalDownTM : db $FF,$07
		db $00
		db $00
		db !tempx+$0E,!tempy+$00

	; ground attack 2
		.GroundAttack2Frame0
		dw .BigSlashUpTM : db $FC,$00
		db $00
		db $00
		db !tempx+$0E,!tempy+$FF
		.GroundAttack2Frame1
		dw .AfterSlashUpTM : db $FE,$F0
		db $00
		db $00
		db !tempx+$0E,!tempy+$FE
		.GroundAttack2Frame2
		dw .DiagonalUpTM : db $FE,$F0
		db $00
		db $00
		db !tempx+$0E,!tempy+$FE

	; dash transition
		.DashTransition0
		dw .DiagonalDownTM : db $0D,$00
		db $00
		db $FF
		db !tempx+$FF,!tempy+$09
		.DashTransition1
		dw .DiagonalDownTM : db $0D,$00
		db $00
		db $FF
		db !tempx+$FF,!tempy+$09

	; dash
		.Dash0
		dw .SlantDownTM_reverse : db $0C,$02
		db $00
		db $FF
		db !tempx+$FC,!tempy+$0E
		.Dash1
		dw .SlantDownTM_reverse : db $0C,$02
		db $00
		db $FF
		db !tempx+$FC,!tempy+$0E

	; dash attack
		.DashAttack0
		dw .StraightUpTM : db $06,$FA
		db $00
		db $FF
		db !tempx+$FE,!tempy+$0B
		.DashAttack1
		dw .BigSlashDownTM : db $00,$08
		db $00
		db $FF
		db !tempx+$FE,!tempy+$07
		.DashAttack2
		dw .AfterSlashDownTM_dash : db $07,$05
		db $00
		db $FF
		db !tempx+$FE,!tempy+$07

	; jump
		.Jump
		dw .SlantDownTM : db $00,$FF
		db $00
		db $00
		db !tempx+$0F,!tempy+$FF

	; fall
		.Fall0
		dw .HorzTM : db $FD,$FD
		db $00
		db $00
		db !tempx+$0F,!tempy+$FD
		.Fall1
		dw .SlantUpTM : db $FB,$F8
		db $00
		db $00
		db !tempx+$0F,!tempy+$F7
		.Fall2
		dw .SlantUpTM : db $FB,$F8
		db $00
		db $00
		db !tempx+$0F,!tempy+$F7

	; air attack
		.AirAttack0
		dw .DiagonalUpTM_reverse : db $09,$F1
		db $00
		db $00
		db !tempx+$FC,!tempy+$F0
		.AirAttack1
		dw .SlantUpTM_reverse : db $09,$F1
		db $00
		db $00
		db !tempx+$FC,!tempy+$F0
		.AirAttack2
		dw .HorzTM_reverse : db $FC,$FF
		db $00
		db $00
		db !tempx+$0B,!tempy+$FF
		.AirAttack3
		dw .SlantDownTM_reverse : db $FC,$FF
		db $00
		db $00
		db !tempx+$0B,!tempy+$FF
		.AirAttack4
		dw .DiagonalDownTM_reverse : db $FC,$FF
		db $00
		db $00
		db !tempx+$0B,!tempy+$FF
		.AirAttack5
		dw .BigSlashUpTM : db $FC,$00
		db $00
		db $00
		db !tempx+$0E,!tempy+$FF
		.AirAttack6
		dw .AfterSlashUpTM : db $FE,$F0
		db $00
		db $00
		db !tempx+$0E,!tempy+$FE
		.AirAttack7
		dw .DiagonalUpTM : db $FE,$F0
		db $00
		db $00
		db !tempx+$0E,!tempy+$FE

	; double jump
		.DoubleJump0
		dw .StraightUpTM : db $F8,$03
		db $FF
		db $00
		dw $FFFF
		.DoubleJump1
		dw .SlantDownTM : db $0B,$0A
		db $FF
		db $00
		dw $FFFF
		.DoubleJump2
		dw .StraightDownTM : db $12,$F8
		db $FF
		db $00
		dw $FFFF
		.DoubleJump3
		dw .SlantUpTM_reverse : db $00,$F0
		db $FF
		db $00
		dw $FFFF

	; spin attack
		.SpinAttack0
		dw .SpinSlashTM0 : db $F8,$03
		db $FF
		db $00
		dw $FFFF
		.SpinAttack1
		dw .SpinSlashTM1 : db $0B,$0A
		db $FF
		db $00
		dw $FFFF
		.SpinAttack2
		dw .SpinSlashTM2 : db $12,$F8
		db $FF
		db $00
		dw $FFFF
		.SpinAttack3
		dw .SpinSlashTM3 : db $00,$F0
		db $FF
		db $00
		dw $FFFF

	; climb BG
		.ClimbBG
		dw .SlantDownTM : db $E8,$05
		db $00
		db $00
		dw $FFFF

	; wall climb
		.WallClimb0
		dw .DiagonalUpTM_reverse : db $00,$F4
		db $FF
		db $00
		dw $FFFF
		.WallClimb1
		dw .StraightUpTM : db $00,$FA
		db $FF
		db $00
		dw $FFFF
		.WallClimb2
		dw .StraightUpTM : db $00,$FE
		db $FF
		db $00
		dw $FFFF
		.WallClimb3
		dw .DiagonalUpTM_reverse : db $00,$F9
		db $FF
		db $00
		dw $FFFF

	; wall climb top
		.WallClimbTop0
		dw .SlantUpTM : db $F9,$05		; body tilemap displaced (-2 X, +6 Y)
		db $FF
		db $00
		dw $FFFF
		.WallClimbTop1
		dw .HorzTM : db $FE,$06
		db $FF
		db $00
		dw $FFFF
		.WallClimbTop2
		dw .HorzTM : db $FF,$05
		db $00
		db $00
		dw $FFFF

	; wall attack
		.WallAttack0
		dw .DiagonalUpTM_reverse : db $13,$05
		db $00
		db $00
		dw $FFFF
		.WallAttack1
		dw .StraightUpTM : db $10,$EF
		db $00
		db $00
		dw $FFFF
		.WallAttack2
		dw .BigSlashDownTM_reverse : db $13,$FA
		db $00
		db $00
		dw $FFFF
		.WallAttack3
		dw .AfterSlashDownTM_reverse : db $12,$08
		db $00
		db $00
		dw $FFFF
		.WallAttack4
		dw .DiagonalDownTM_reverse : db $12,$08
		db $00
		db $00
		dw $FFFF

	; ceiling hang
		.CeilingHang
		dw .DiagonalDownTM : db $0C,$03
		db $00
		db $00
		dw $FFFF

	; ceiling climb
		.CeilingClimb0
		dw .SlantDownTM_reverse : db $01,$FA
		db $FF
		db $00
		dw $FFFF
		.CeilingClimb1
		dw .DiagonalDownTM_reverse : db $02,$F9
		db $FF
		db $00
		dw $FFFF
		.CeilingClimb2
		dw .DiagonalDownTM : db $0B,$FD
		db $00
		db $00
		dw $FFFF
		.CeilingClimb3
		dw .SlantDownTM : db $0B,$FC
		db $00
		db $00
		dw $FFFF
		.CeilingClimb4
		dw .DiagonalDownTM : db $0B,$FD
		db $00
		db $00
		dw $FFFF
		.CeilingClimb5
		dw .DiagonalDownTM_reverse : db $02,$F8
		db $FF
		db $00
		dw $FFFF

	; ceiling attack
		.CeilingAttack0
		dw .SlantUpTM : db $0D,$F5
		db $00
		db $00
		dw $FFFF
		.CeilingAttack1
		dw .SlashTM : db $FF,$01
		db $00
		db $00
		dw $FFFF
		.CeilingAttack2
		dw .AfterSlashDownTM_ceiling : db $04,$06
		db $00
		db $00
		dw $FFFF
		.CeilingAttack3
		dw .DiagonalDownTM : db $04,$06
		db $00
		db $00
		dw $FFFF

	; hurt
		.Hurt
		dw .SlantUpTM : db $FC,$00
		db $00
		db $00
		db !tempx+$0A,!tempy+$04

	; dead
		.Dead
		dw $0000 : db $FD,$FF
		db $00
		db $00
		dw $FFFF

	; victory
		.Victory0
		dw .StraightUpTM : db $FE,$F4
		db $FF
		db $00
		db !tempx+$0E,!tempy+$FD
		.Victory1
		dw .StraightUpTM : db $FE,$F1
		db $FF
		db $00
		db !tempx+$0C,!tempy+$00



; for these, !tempx and !tempy are base offsets for each tilemap
; the purpose of this is to make it so sword tilemaps can be swapped and still appear in the right place
	!tempx = $E9
	!tempy = $FE
	.HorzTM
	dw $000C
	db $21,!tempx+$00,!tempy+$00,!P1Tile7
	db $21,!tempx+$08,!tempy+$00,!P1Tile7+1
	db $21,!tempx+$10,!tempy+$00,!P1Tile8
	!tempx = $14
	!tempy = $FE
	..reverse
	dw $000C
	db $61,!tempx+$00,!tempy+$00,!P1Tile7
	db $61,!tempx+$F8,!tempy+$00,!P1Tile7+1
	db $61,!tempx+$F0,!tempy+$00,!P1Tile8

	!tempx = $EB
	!tempy = $00
	.SlantDownTM
	dw $0008
<<<<<<< Updated upstream
	db $2E,$00,$00,!P2Tile5
	db $2E,$08,$00,!P2Tile5+$01
=======
	db $20,!tempx+$00,!tempy+$00,!P1Tile7
	db $20,!tempx+$08,!tempy+$00,!P1Tile7+1
	!tempx = $0A
	!tempy = $00
	..reverse
	dw $0008
	db $60,!tempx+$00,!tempy+$00,!P1Tile7
	db $60,!tempx+$F8,!tempy+$00,!P1Tile7+1
>>>>>>> Stashed changes

	!tempx = $EB
	!tempy = $F4
	.SlantUpTM
	dw $0008
<<<<<<< Updated upstream
	db $2E,$00,$00,!P2Tile7
	db $2E,$F8,$08,!P2Tile8
=======
	db $A0,!tempx+$00,!tempy+$00,!P1Tile7
	db $A0,!tempx+$08,!tempy+$00,!P1Tile7+1
	!tempx = $0A
	!tempy = $F4
	..reverse
	dw $0008
	db $E0,!tempx+$00,!tempy+$00,!P1Tile7
	db $E0,!tempx+$F8,!tempy+$00,!P1Tile7+1
>>>>>>> Stashed changes

	!tempx = $EC
	!tempy = $01
	.DiagonalDownTM
	dw $0008
	db $20,!tempx+$00,!tempy+$08,!P1Tile7+$01
	db $20,!tempx+$08,!tempy+$00,!P1Tile4+$10
	!tempx = $09
	!tempy = $01
	..reverse
	dw $0008
<<<<<<< Updated upstream
	db $6E,$00,$00,!P2Tile5
	db $6E,$08,$00,!P2Tile5+$01
=======
	db $60,!tempx+$00,!tempy+$08,!P1Tile7+$01
	db $60,!tempx+$F8,!tempy+$00,!P1Tile4+$10
>>>>>>> Stashed changes

	!tempx = $EC
	!tempy = $01
	.AfterSlashDownTM
	dw $0010
<<<<<<< Updated upstream
	db $2E,$00,$00,!P2Tile5
	db $2E,$10,$00,!P2Tile6
	db $2E,$20,$00,!P2Tile7
	db $2E,$30,$00,!P2Tile8
	.CutTM1
	dw $000C
	db $2E,$00,$00,!P2Tile5
	db $2E,$10,$00,!P2Tile6
	db $2E,$20,$00,!P2Tile7

	.HoldBackTM
	dw $0008
	db $2E,$00,$00,!P2Tile6
	db $2E,$08,$00,!P2Tile6+$01
=======
	db $20,!tempx+$00,!tempy+$08,!P1Tile7+$01
	db $20,!tempx+$08,!tempy+$00,!P1Tile4+$10
	db $A0,!tempx+$F4,!tempy+$00,!P1Tile3
	db $A1,!tempx+$04,!tempy+$08,!P1Tile4
	..dash
	dw $0010
	db $20,!tempx+$00,!tempy+$08,!P1Tile7+$01
	db $20,!tempx+$08,!tempy+$00,!P1Tile4+$10
	db $A0,!tempx+$F0,!tempy+$0A,!P1Tile3
	db $A1,!tempx+$00,!tempy+$12,!P1Tile4
	..ceiling
	dw $0010
	db $20,!tempx+$00,!tempy+$08,!P1Tile7+$01
	db $20,!tempx+$08,!tempy+$00,!P1Tile4+$10
	db $A0,!tempx+$F4,!tempy+$03,!P1Tile3
	db $A1,!tempx+$04,!tempy+$0B,!P1Tile4
	!tempx = $09
	!tempy = $01
	..reverse
	dw $0010
	db $60,!tempx+$00,!tempy+$08,!P1Tile7+$01
	db $60,!tempx+$F8,!tempy+$00,!P1Tile4+$10
	db $E0,!tempx+$0C,!tempy+$FC,!P1Tile3
	db $E1,!tempx+$04,!tempy+$04,!P1Tile4

	!tempx = $EC
	!tempy = $F4
	.DiagonalUpTM
	dw $0008
	db $A0,!tempx+$00,!tempy+$F8,!P1Tile7+$01
	db $A0,!tempx+$08,!tempy+$00,!P1Tile4+$10
	!tempx = $09
	!tempy = $F4
	..reverse
	dw $0008
	db $E0,!tempx+$00,!tempy+$F8,!P1Tile7+$01
	db $E0,!tempx+$F8,!tempy+$00,!P1Tile4+$10
>>>>>>> Stashed changes

	!tempx = $FF
	!tempy = $FA
	.StraightUpTM
	dw $000C
	db $21,!tempx+$00,!tempy+$F0,!P1Tile7
	db $21,!tempx+$00,!tempy+$F8,!P1Tile7+1
	db $21,!tempx+$00,!tempy+$00,!P1Tile8

	!tempx = $EC
	!tempy = $F4
	.AfterSlashUpTM
	dw $0010
<<<<<<< Updated upstream
	db $2E,$00,$00,!P2Tile5
	db $2E,$08,$08,!P2Tile6
	db $2E,$18,$08,!P2Tile7
	db $2E,$20,$08,!P2Tile7+$01
	.SlashTM0
	dw $001C
	db $2E,$00,$00,!P2Tile5
	db $2E,$08,$08,!P2Tile6
	db $2E,$18,$08,!P2Tile7
	db $2E,$20,$08,!P2Tile7+$01
	db $2E,$08,$E8,$4B
	db $2F,$18,$E8,$4D
	db $2F,$20,$E8,$4E
	.SlashTM1
	dw $000C
	db $2E,$00,$00,!P2Tile5
	db $2E,$10,$00,!P2Tile6
	db $2E,$18,$00,!P2Tile6+$01

	.WHorzTM
	dw $0008
	db $6E,$00,$00,!P2Tile5
	db $6E,$08,$00,!P2Tile5+$01

	.WSlashTM0
	dw $001C
	db $6E,$00,$00,!P2Tile5
	db $6E,$08,$08,!P2Tile6
	db $6E,$18,$08,!P2Tile7
	db $6E,$20,$08,!P2Tile7+$01
	db $6E,$08,$E8,$4B
	db $6F,$18,$E8,$4D
	db $6F,$20,$E8,$4E
	.WSlashTM1
	dw $000C
	db $6E,$00,$00,!P2Tile5
	db $6E,$10,$00,!P2Tile6
	db $6E,$18,$00,!P2Tile6+$01
	.WDiaTM
	dw $0008
	db $6E,$00,$00,!P2Tile7
	db $6E,$F8,$08,!P2Tile8
	.WHoldBackTM
	dw $0008
	db $4E,$00,$00,!P2Tile6
	db $4E,$08,$00,!P2Tile6+$01

	.HoldDownTM
	dw $0008
	db $2E,$00,$00,!P2Tile5
	db $2E,$08,$00,!P2Tile5+$01

	.HoldUpTM
	dw $0008
	db $2E,$00,$00,!P2Tile5+$01
	db $2E,$00,$08,!P2Tile6+$01

	.FallTM
	dw $0008
	db $AE,$00,$08,!P2Tile5+$01
	db $AE,$00,$00,!P2Tile6+$01

	.ClimbTM
	dw $0008
	db $6E,$00,$00,!P2Tile7
	db $6E,$F8,$08,!P2Tile8
=======
	db $A0,!tempx+$00,!tempy+$F8,!P1Tile7+$01
	db $A0,!tempx+$08,!tempy+$00,!P1Tile4+$10
	db $20,!tempx+$F7,!tempy+$06,!P1Tile3
	db $21,!tempx+$07,!tempy+$06,!P1Tile4

	!tempx = $FF
	!tempy = $04
	.StraightDownTM
	dw $000C
	db $A1,!tempx+$00,!tempy+$00,!P1Tile8
	db $A1,!tempx+$00,!tempy+$08,!P1Tile7+1
	db $A1,!tempx+$00,!tempy+$10,!P1Tile7

	!tempx = $00
	!tempy = $00
	.StuckTM
	dw $0008
	db $A1,!tempx+$00,!tempy+$00,!P1Tile8
	db $A1,!tempx+$00,!tempy+$08,!P1Tile7+1

	!tempx = $DC
	!tempy = $F3
	.SlashTM
	dw $0028
	db $21,!tempx+$08,!tempy+$F8,!P1Tile4+$01
	db $21,!tempx+$10,!tempy+$F8,!P1Tile4+$10
	db $21,!tempx+$18,!tempy+$F8,!P1Tile4+$11
	db $20,!tempx+$00,!tempy+$00,!P1Tile7
	db $20,!tempx+$10,!tempy+$00,!P1Tile8
	db $A0,!tempx+$00,!tempy+$10,!P1Tile7
	db $A0,!tempx+$10,!tempy+$10,!P1Tile8
	db $A1,!tempx+$08,!tempy+$20,!P1Tile4+$01
	db $A1,!tempx+$10,!tempy+$20,!P1Tile4+$10
	db $A1,!tempx+$18,!tempy+$20,!P1Tile4+$11

	!tempx = $DC
	!tempy = $F3
	.BigSlashDownTM
	dw $0030
	db $21,!tempx+$08,!tempy+$F8,!P1Tile4+$01
	db $21,!tempx+$10,!tempy+$F8,!P1Tile4+$10
	db $21,!tempx+$18,!tempy+$F8,!P1Tile4+$11
	db $20,!tempx+$00,!tempy+$00,!P1Tile7
	db $20,!tempx+$10,!tempy+$00,!P1Tile8
	db $A0,!tempx+$00,!tempy+$10,!P1Tile7
	db $A0,!tempx+$10,!tempy+$10,!P1Tile8
	db $A1,!tempx+$08,!tempy+$20,!P1Tile4+$01
	db $A1,!tempx+$10,!tempy+$20,!P1Tile4+$10
	db $A1,!tempx+$18,!tempy+$20,!P1Tile4+$11
	db $20,!tempx+$14,!tempy+$F8,!P1Tile3
	db $21,!tempx+$24,!tempy+$F8,!P1Tile4
	!tempx = $1C
	!tempy = $F3
	..reverse
	dw $0030
	db $61,!tempx+$00,!tempy+$F8,!P1Tile4+$01
	db $61,!tempx+$F8,!tempy+$F8,!P1Tile4+$10
	db $61,!tempx+$F0,!tempy+$F8,!P1Tile4+$11
	db $60,!tempx+$00,!tempy+$00,!P1Tile7
	db $60,!tempx+$F0,!tempy+$00,!P1Tile8
	db $E0,!tempx+$00,!tempy+$10,!P1Tile7
	db $E0,!tempx+$F0,!tempy+$10,!P1Tile8
	db $E1,!tempx+$00,!tempy+$20,!P1Tile4+$01
	db $E1,!tempx+$F8,!tempy+$20,!P1Tile4+$10
	db $E1,!tempx+$F0,!tempy+$20,!P1Tile4+$11
	db $60,!tempx+$EC,!tempy+$F8,!P1Tile3
	db $61,!tempx+$E4,!tempy+$F8,!P1Tile4

	!tempx = $DC
	!tempy = $F3
	.BigSlashUpTM
	dw $0030
	db $21,!tempx+$08,!tempy+$F8,!P1Tile4+$01
	db $21,!tempx+$10,!tempy+$F8,!P1Tile4+$10
	db $21,!tempx+$18,!tempy+$F8,!P1Tile4+$11
	db $20,!tempx+$00,!tempy+$00,!P1Tile7
	db $20,!tempx+$10,!tempy+$00,!P1Tile8
	db $A0,!tempx+$00,!tempy+$10,!P1Tile7
	db $A0,!tempx+$10,!tempy+$10,!P1Tile8
	db $A1,!tempx+$08,!tempy+$20,!P1Tile4+$01
	db $A1,!tempx+$10,!tempy+$20,!P1Tile4+$10
	db $A1,!tempx+$18,!tempy+$20,!P1Tile4+$11
	db $A0,!tempx+$14,!tempy+$18,!P1Tile3
	db $A1,!tempx+$24,!tempy+$20,!P1Tile4

	!tempx = $ED
	!tempy = $F2
	.SpinSlashTM0
	dw $0030
	db $21,!tempx+$08,!tempy+$F8,!P1Tile4+$01
	db $21,!tempx+$10,!tempy+$F8,!P1Tile4+$10
	db $21,!tempx+$18,!tempy+$F8,!P1Tile4+$11
	db $20,!tempx+$00,!tempy+$00,!P1Tile7
	db $20,!tempx+$10,!tempy+$00,!P1Tile8
	db $A0,!tempx+$00,!tempy+$10,!P1Tile7
	db $A0,!tempx+$10,!tempy+$10,!P1Tile8
	db $A1,!tempx+$08,!tempy+$20,!P1Tile4+$01
	db $A1,!tempx+$10,!tempy+$20,!P1Tile4+$10
	db $A1,!tempx+$18,!tempy+$20,!P1Tile4+$11
	db $20,!tempx+$07,!tempy+$F3,!P1Tile3
	db $21,!tempx+$17,!tempy+$F3,!P1Tile4

	!tempx = $F0
	!tempy = $F8
	.SpinSlashTM1
	dw $0030
	db $21,!tempx+$F8,!tempy+$00,!P1Tile3+$01
	db $21,!tempx+$F8,!tempy+$08,!P1Tile3+$11
	db $21,!tempx+$F8,!tempy+$10,!P1Tile3+$00
	db $20,!tempx+$00,!tempy+$00,!P1Tile4
	db $20,!tempx+$00,!tempy+$10,!P1Tile8
	db $60,!tempx+$10,!tempy+$00,!P1Tile4
	db $60,!tempx+$10,!tempy+$10,!P1Tile8
	db $61,!tempx+$20,!tempy+$00,!P1Tile3+$01
	db $61,!tempx+$20,!tempy+$08,!P1Tile3+$11
	db $61,!tempx+$20,!tempy+$10,!P1Tile3+$00
	db $20,!tempx+$F2,!tempy+$01,!P1Tile7
	db $21,!tempx+$F2,!tempy+$F9,!P1Tile3+$10

	!tempx = $08
	!tempy = $F5
	.SpinSlashTM2
	dw $0030
	db $E1,!tempx+$00,!tempy+$20,!P1Tile4+$01
	db $E1,!tempx+$F8,!tempy+$20,!P1Tile4+$10
	db $E1,!tempx+$F0,!tempy+$20,!P1Tile4+$11
	db $E0,!tempx+$00,!tempy+$10,!P1Tile7
	db $E0,!tempx+$F0,!tempy+$10,!P1Tile8
	db $60,!tempx+$00,!tempy+$00,!P1Tile7
	db $60,!tempx+$F0,!tempy+$00,!P1Tile8
	db $61,!tempx+$00,!tempy+$F8,!P1Tile4+$01
	db $61,!tempx+$F8,!tempy+$F8,!P1Tile4+$10
	db $61,!tempx+$F0,!tempy+$F8,!P1Tile4+$11
	db $E0,!tempx+$EF,!tempy+$1E,!P1Tile3
	db $E1,!tempx+$E7,!tempy+$26,!P1Tile4

	!tempx = $05
	!tempy = $FE
	.SpinSlashTM3
	dw $0030
	db $E1,!tempx+$10,!tempy+$08,!P1Tile3+$01
	db $E1,!tempx+$10,!tempy+$00,!P1Tile3+$11
	db $E1,!tempx+$10,!tempy+$F8,!P1Tile3+$00
	db $E0,!tempx+$00,!tempy+$00,!P1Tile4
	db $E0,!tempx+$00,!tempy+$F0,!P1Tile8
	db $A0,!tempx+$F0,!tempy+$00,!P1Tile4
	db $A0,!tempx+$F0,!tempy+$F0,!P1Tile8
	db $A1,!tempx+$E8,!tempy+$08,!P1Tile3+$01
	db $A1,!tempx+$E8,!tempy+$00,!P1Tile3+$11
	db $A1,!tempx+$E8,!tempy+$F8,!P1Tile3+$00
	db $E0,!tempx+$0E,!tempy+$FF,!P1Tile7
	db $E1,!tempx+$16,!tempy+$0F,!P1Tile3+$10



.End
print "  Sword data: $", hex(.End-SWORD), " bytes"

>>>>>>> Stashed changes


	DATA:

		.XAccIce
		dw $0280	; walking
		dw $0680	; dashing
		dw $1000	; turning (overrides dash)

		; right, left
		.XSpeed
		dw $1800,$E800	; walking
		dw $3000,$D000	; dashing

		; indexed by dash*4 + left/right input
		.WallJumpSpeed
		db $00,$18,$E8,$00
		db $00,$30,$D0,$00

		.ClimbSpeed
		db $00,$10,$F0,$00

		.SlideXSpeed
		dw $C000,$C000,$C000,$D000
		dw $0000
		dw $3000,$4000,$4000,$4000

		.SlideXAcc
		dw $1000,$0800,$0800,$0400
		dw $0200
		dw $0400,$0800,$0800,$1000

		.ClimbTileX
		dw $FFF8,$0018






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


namespace off












