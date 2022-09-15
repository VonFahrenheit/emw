;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

namespace Leeway

; --Build 3.2--
;
;
; Upgrade data:
;	bit 0 (01)	Dash after hitting an enemy to cancel into a dash slash
;	bit 1 (02)	Can dash in midair, but not from a dash jump
;	bit 2 (04)	Can dash in midair, even from a dash jump
;	bit 3 (08)	Can use combo slash in midair
;	bit 4 (10)	Hold B to slow descent in midair
;	bit 5 (20)	Enables stamina for climbing
;	bit 6 (40)	Rexcalibur
;	bit 7 (80)	Push X to perform ultimate attack


	MAINCODE:
		PHB : PHK : PLB

		LDA #$03 : STA !P2Character
		LDA #$08			;\
		CLC : ADC !PlayerBonusHP	; | max HP
		STA !P2MaxHP			;/


		LDA !P2Status : BEQ .Process
		CMP #$01 : BEQ .KnockedOut

		.Snap
		REP #$20
		LDA $94 : STA !P2XPosLo
		LDA $96 : STA !P2YPosLo
		SEP #$20
		PLB
		RTL

		.KnockedOut
		JSL CORE_KNOCKED_OUT
		BMI .Fall
		BCC .Fall
		LDA #$02 : STA !P2Status
		PLB
		RTL

		.Fall
		STZ !P2Carry
		STZ !P2Invinc
		BIT !P2ShowHP
		BMI ++
		BVS ++
		LDA !P2Anim
		CMP #!Lee_Dead : BEQ +
		CMP #!Lee_Dead+1 : BEQ +
	++	LDA #!Lee_Dead : STA !P2Anim
		STZ !P2AnimTimer
	+	JMP ANIMATION_HandleUpdate


		.Process
		LDA !P2MaxHP						;\
		CMP !P2HP						; | enforce max HP
		BCS $03 : STA !P2HP					;/
		LDA $17
		AND #$20
		ASL #2
		TSB $17
		LDA $18
		AND #$20
		ASL #2
		TSB $18

		REP #$20						;\
		LDA !P2Hitbox1IndexMem					; |
		ORA !P2Hitbox2IndexMem					; | merge hitboxes
		STA !P2Hitbox1IndexMem					; |
		STA !P2Hitbox2IndexMem					; |
		SEP #$20						;/

		LDA !P2DashSmoke : BEQ .NoDashSmoke
		JSL CORE_DASH_SMOKE
		.NoDashSmoke



		LDA !P2HurtTimer
		BEQ $03 : DEC !P2HurtTimer
		LDA !P2Invinc
		BEQ $03 : DEC !P2Invinc
		LDA !P2CrouchTimer
		BEQ $03 : DEC !P2CrouchTimer
		LDA !P2DashSmoke
		BEQ $03 : DEC !P2DashSmoke



		LDA !P2Dashing : BEQ .NotDashing	; check dash timer
		DEC !P2Dashing : BNE .DashDone		; decrement timer
		LDA #!Lee_CrouchEnd : STA !P2Anim	;\
		LDA #$04 : STA !P2AnimTimer		; | dash done anim
		BRA .DashDone				;/
		.NotDashing				;\ regain dash slash when dash ends
		STZ !P2DashSlash			;/
		.DashDone

		LDA !P2SlantPipe
		BEQ $03 : DEC !P2SlantPipe
		LDA !P2WallClimbTop
		BEQ $03 : DEC !P2WallClimbTop
		LDA !P2ComboDash
		BEQ $03 : DEC !P2ComboDash


		LDA !P2SwordTimer : BNE +
		STZ !P2ComboDisable
		STZ !P2SwordAttack
		STZ !P2Buffer
		BRA ++
	+	DEC !P2SwordTimer
		LDA $15			; Leeway can crouch during a dash slash by pushing down
		AND #$04 : BEQ +
		STZ !P2Dashing
		BRA ++

	+	LDA !P2Dashing : BEQ ++
		AND #$80
		ORA #$04
		STA !P2Dashing
		++

		LDA !P2WallJumpInputTimer
		BEQ $03 : DEC !P2WallJumpInputTimer
		BEQ +
		LDA !P2WallJumpInput : TSB $15
		EOR #$03 : TRB $15
		BRA ++
	+	STZ !P2WallJumpInput
		++


	PIPE:
		JSL CORE_PIPE : BCC CONTROLS
		LDA #$04 : TRB $15
		JMP ANIMATION

	BITS:
		db $01,$02,$04,$08,$10,$20,$40,$80


	CONTROLS:
		JSL CORE_COYOTE_TIME

		LDA !P2Buffer			;\
		AND #$80			; |
		TSB $15				; | apply jump buffer
		TSB $16				; |
		TRB !P2Buffer			;/

		PEA PHYSICS-1

		LDA !P2HurtTimer
		BEQ $03 : JMP .Friction

	; crouch check
		LDA !P2Anim
		CMP #!Lee_Cut : BCS .NoCrouch
		LDA $15
		AND #$04 : BEQ .NoCrouch
		LDA #$01 : STA !P2Ducking
		.NoCrouch

	; climb check here
		LDA !P2SwordAttack
		AND #$7F
		CMP #$05 : BCC +
		BNE ++

	++	;LDA #$00 : JSL CORE_SET_XSPEED
		STZ !P2YSpeed
		RTS

	+	LDA !P2WallClimb
		BEQ $03 : JMP .ProcessClimb

		LDA $15
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
	+	JSL CORE_CHECK_ABOVE
		BCC -
		LDA $15
		AND #$08 : BEQ -

		.ClingUp
		LDA !P2Stamina : BEQ .nogrip		; can't grip without stamina
		LDA !LeewayUpgrades			;\ can never cling to ceilings without dino grip
		AND #$20 : BEQ .nogrip			;/
		LDA !IceLevel : BEQ +			; can't cling to ceilings on icy levels
	.nogrip	STZ !P2WallClimb
		JMP .NoClimb
	+	LDA #$80 : STA !P2WallClimb
		BRA .ProcessClimb

		.GroundCheck
		LSR A : BCC +
		LDA $15
		AND #$08 : BNE .ClingRight
		JMP .NoClimb
	+	LSR A : BCC +
		LDA $15
		AND #$08 : BNE .ClingLeft
	+	JMP .NoClimb

		.ClingRight
		LDA #!Lee_WallClimb : STA !P2Anim
		STZ !P2AnimTimer
		LDA #$01 : STA !P2WallClimb
		STA !P2Direction

		.ProcessClimb
		PHP
		STZ !P2Climbing
		STZ !P2CrouchTimer
		STZ !P2Dashing
		STZ !P2DashJump
		STZ !P2SwordAttack
		STZ !P2SwordTimer
		STZ !P2AirDashUsed
		PLP
		BPL .Wall
		JMP .Ceiling

		.ClingLeft
		LDA #!Lee_WallClimb : STA !P2Anim
		STZ !P2AnimTimer
		LDA #$02 : STA !P2WallClimb
		STZ !P2Direction
		BRA .ProcessClimb

		.Wall
		LDA !P2Blocked
		LDY !P2Platform
		BEQ $02 : ORA #$04
		STA $00
		AND #$04 : BEQ .Go
	.Floor	STZ !P2WallClimb
		STZ !P2VectorY
		STZ !P2VectorTimeY

	.Go	LDA $00
		AND #$0B : BNE $03 : JMP .Top
		CMP #$08 : BCC +
		LDA #$03 : TRB !P2Blocked
		LDA #$80 : STA !P2WallClimb
		PHP : REP #$20
		DEC !P2XPosLo
		PLP
		JMP ++
	+	LDX !P2Direction
		LDA .ClimbX,x : STA !P2XSpeed

		LDA !P2Stamina : BEQ .slide		; slip without stamina
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


		LDA $15
		LSR #2
		AND #$03
		TAX
		LDA .XSpeed,x : STA !P2YSpeed		; climb up/down speed
		BNE +
		LDX !P2Direction
		LDA $15
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

		.NoHoldOut
		LDA !P2YSpeed
		BNE .ClimbJump
		STZ !P2AnimTimer
		BRA .ClimbJump

		.Ceiling
		LDA !P2Stamina : BEQ +++		; drop when stamina runs out
		LDA !P2Blocked
		LSR A : BCC +
		LDA #$08 : TRB !P2Blocked
		JMP .ClingRight
	+	LSR A : BCC ++
		LDA #$08 : TRB !P2Blocked
		JMP .ClingLeft
	++	JSL CORE_CHECK_ABOVE : BCS .stick
	+++	JMP .Fall
	.stick	STZ !P2WallClimbTop					; Clear getup
		LDA $15
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
		BIT !P2WallClimb : BPL ..nodash				; can only do this out of ceiling climb
		BIT $18 : BPL ..nodash
		STZ !P2WallClimb
		JMP .DashCheck
		..nodash
		BIT $16
		BVS .ClimbSlash
		BPL .EndClimb
		BIT !P2WallClimb : BMI .Fall
		STZ !P2WallClimbTop					; wall jump here
		LDX !P2Direction
		LDA .ClimbX+2,x : STA !P2XSpeed
		LDA .ClimbLock+2,x : STA !P2WallJumpInput
		STZ !P2VectorY
		STZ !P2VectorTimeY
		LDA #$10 : STA !P2WallJumpInputTimer
		LDY #$C8
		LDA !P2Stamina : BEQ .nospd			; low vertical speed without stamina
		LDA !LeewayUpgrades				;\ very low vertical speed without dino grip
		AND #$20 : BEQ .nospd				;/
		LDA !IceLevel : BEQ +				;\ very low vertical speed on icy levels
	.nospd	LDY #$E0					;/
	+	STY !P2YSpeed					; Y speed
		LDA !P2Stamina					;\
		SEC : SBC #$28					; | wall jump costs 0x28 stamina
		BPL $02 : LDA #$00				; |
		STA !P2Stamina					;/
		LDA #$2B : STA !SPC1				; jump SFX
		BIT $17 : BPL .Fall
		LDA #$01 : STA !P2DashJump

		.Fall
		BIT !P2WallClimb : BMI +
		LDA #!Lee_ClimbTop : STA !P2Anim
		STZ !P2AnimTimer
	+	STZ !P2WallClimb

		.EndClimb
		RTS

		.ClimbSlash
		LDA !P2WallClimbTop : BNE .EndClimb			; No normal climb attacks during get-up
		LDA #$05
		BIT !P2WallClimb
		BPL .WallSlash

		.HangSlash
		INC A

		.WallSlash
		STA !P2SwordAttack
		LDA #$3D : STA !SPC4				; slash SFX
		RTS

		.Top
		LDA !P2YSpeed
		BMI $04 : CMP #$10 : BCS .EndClimb-3
		LDX !P2Direction
		LDA .ClimbX,x : STA !P2XSpeed
		LDA .ClimbLock,x : STA !P2WallJumpInput
		LDA #$10 : STA !P2WallJumpInputTimer
		STZ !P2WallClimb
		LDA !P2WallClimbTop : BNE +
		LDA #$1C : STA !P2WallClimbTop
	+	RTS

		.NoClimb


		LDA !P2SwordAttack : BEQ +
		CMP #$02 : BCS +
		RTS
		+




	; Dash check before ground check because air dash will be unlocked

		.DashCheck
		LDA !P2CrouchTimer			;\
		BEQ $03					; | check crouch timer, can't dash during
	-	JMP .NoDash				;/
		BIT $18 : BPL -				; check input
	;	LDA !P2Climbing : BNE -			; no dashing from nets

		LDA !P2SwordAttack : BEQ .NoCombo	;\
		LDA !P2ComboDisable : BNE .NoDash	; |
		LDA !LeewayUpgrades			; |
		AND #$09 : BEQ .NoDash			; | check for combo dash trigger
		CMP #$08 : BCS +			; |
		LDA !P2Blocked				; |
		AND #$04 : BEQ .NoDash			; |
	+	LDA !P2ComboDash : BEQ .NoDash		;/
		LDA #$03 : STA !P2SwordAttack		;\
		LDA #$1A : STA !P2Invinc		; | setup combo slash
		INC !P2ComboDisable			;/
		JSL CORE_ATTACK_Combo			; start combo
		.NoCombo


		STZ !P2WallClimbTop			; Clear getup when starting a dash
		LDA !P2Blocked
		AND #$04
		ORA !P2Platform
		BNE .GroundDash

		LDA !LeewayUpgrades			;\ air dash required to dash in midair
		AND #$06 : BEQ .NoDash			;/
		CMP #$04 : BCS +			;\
		LDA !P2DashJump : BNE .NoDash		; | air dash+ required to dash out of dash jump
		+					;/

		LDA !P2AirDashUsed
		BEQ $03 : JMP .Shared
		LDA #$2D : STA !SPC1
		LDA #$98 : STA !P2Dashing
		LDA #$01
		STA !P2AirDashUsed
		STA !P2DashJump
		STZ !P2Climbing				; drop from climb
		JMP .Shared

		.GroundDash
		LDA #$2D : STA !SPC1			; dash SFX
		LDA #$18 : STA !P2Dashing
		LDA #$05 : STA !P2DashSmoke		; dash smoke for 5 frames
		.NoDash

		LDA !P2Blocked				;\
		AND #$03 : BEQ .NotBlocked		; |
		DEC A					; |
		LSR A					; | reset X speed when bonking a wall
		ROR A					; |
		EOR !P2XSpeed : BMI .NotBlocked		; |
		STZ !P2XSpeed				; |
		.NotBlocked				;/




		LDA !P2Climbing : BEQ .NoVineClimb	; Check for vine/net climb
		LDA $15
		LSR A : BCC +
		LDA #$01 : STA !P2Direction
		BRA ++
	+	LSR A : BCC ++
		STZ !P2Direction
	++	BIT $16 : BPL +
		STZ !P2Climbing				; vine/net jump
		LDA #$B8 : STA !P2YSpeed
		LDA #$2B : STA !SPC1			; jump SFX
		RTS
		.NoVineClimb

		LDA !P2Blocked
		AND #$04
		ORA !P2Platform
		BNE .Ground

		.Air
		LDA !P2CoyoteTime				;\
		BMI ..nope					; |
		BEQ ..nope					; | coyote time
		BIT $16 : BMI .Jump				; |
		..nope						;/

		LDA !P2CrouchTimer : BNE +
		STZ !P2Ducking
	+	LDA !P2Dashing : BEQ +
		BMI .Shared
		STA !P2DashJump
		STZ !P2Dashing
		BRA .Shared
	+	LDA !P2WallClimbTop : BNE .Shared			; No air attack during get-up
		BIT $16 : BVC .Shared
		LDA !P2Climbing : BNE .Shared
		LDA !P2SwordAttack : BNE .Shared
		LDA #$04 : STA !P2SwordAttack
		LDA #$3D : STA !SPC4				; slash sfx
		BRA .Shared

		.Ground
		LDA !LeewayMaxStamina : STA !P2Stamina
		BIT $16
		BMI .Jump
		BVC .Shared
		LDA !P2SwordAttack
		ORA !P2CrouchTimer
		BNE +
		LDA !P2Dashing : BNE .Shared
		LDA #$01 : STA !P2SwordAttack			; start attack
		LDA #$3C : STA !SPC4				; slice SFX
	+	RTS


		; normal ground jump
		; main jump code
		.Jump
		STZ !P2CoyoteTime				; clear coyote time
		STZ !P2SwordAttack				; clear sword attack
		STZ !P2CrouchTimer				; clear crouch timer
		STZ !P2Ducking					; clear crouch status
		LDA #$B0 : STA !P2YSpeed			; base jump y speed
		LDA #$2B : STA !SPC1				; jump SFX
		LDA #$01 : STA !P2JumpCancel			; load jump cancel
		LDA !P2Dashing : BEQ .Shared			;\
		..dashjump					; | dash jump flag
		LDA #$01 : STA !P2DashJump			;/

		.Shared
		LDA !P2Dashing
		ORA !P2DashJump
		BEQ .Walk
		BMI .Dash
		LDA !P2DashJump : BEQ .Dash
		LDA $15
		AND #$03
	-	ORA #$04
		BRA +

		.Dash
		LDA $15
		AND #$03
		BNE -
		ORA !P2Direction
		EOR #$01
		INC A
		BRA -

		.Walk
		LDA !P2Blocked
		AND #$04 : BEQ ++
		LDA !P2SwordAttack			;\
		ORA !P2CrouchTimer			; |
		BEQ ++					; | go straight to friction when swinging or going in/out of crouch
		LDA #$00				; |
		BRA +					;/
	++	LDA $15
		AND #$03
	+	TAX
		LDA .XSpeed,x : BNE .NoFriction

		.Friction				;\
		LDA !P2Slope				; |
		CLC : ADC #$04				; |
		TAX					; |
		LDA !P2XSpeed				; |
		SEC : SBC .SlopeSpeed,x			; |
		BEQ .Return				; |
		BPL ..pos				; |
	..neg	INC A					; |
		BEQ $01 : INC A				; | apply friction
		BEQ $01 : INC A				; |
		BRA ..set				; |
	..pos	DEC A					; |
		BEQ $01 : DEC A				; |
		BEQ $01 : DEC A				; |
	..set	CLC : ADC .SlopeSpeed,x			; |
		LDX #$00				; |
		BRA ++					; |
		.NoFriction				;/


		LDA !P2XSpeed				;\
		CMP .XSpeedMin,x : BCC +		; |
		CMP .XSpeedMax,x : BCS +		; | clamp speed
		LDA .XSpeed,x				; |
		BRA ++					;/
	+	LDA .XAcc,x				;\
		CLC : ADC !P2XSpeedFraction		; |
		STA !P2XSpeedFraction			; | apply acceleration
		LDA .XAccHi,x				; |
		ADC !P2XSpeed				;/
	++	JSL CORE_SET_XSPEED			; update speed
		LDA .Direction,x : BMI .Flip		;\
		CMP !P2Direction : BEQ .Return		; | update direction
		STA !P2Direction			;/
		.Flip
		LDA !P2XSpeed : BNE ..add
		LDA .DirSpeedOffset,x : STA !P2XSpeed
		RTS
		..add
		LDA .DirSpeedOffset,x			;\
		CLC : ADC !P2XSpeed			; |
		TAY					; | speed boost when turning around
		EOR !P2XSpeed				; |
		BMI $02 : LDY #$00			; > cap speed boost at 0x00: it only helps you stop, not accelerate
		STY !P2XSpeed				;/
	.Return	RTS					; return


		.XAcc
		db $00,$80,$80,$00
		db $00,$80,$80,$00
		.XAccHi
		db $00,$02,$FD,$00
		db $00,$06,$F9,$00

		.XSpeedMin
		db $00,$18,$80,$00
		db $00,$30,$80,$00
		.XSpeedMax
		db $00,$80,$E8,$00
		db $00,$80,$D0,$00
		.XSpeed
		db $00,$18,$E8,$00
		db $00,$30,$D0,$00

		.Direction
		db $FF,$01,$00,$FF
		db $FF,$01,$00,$FF
		.DirSpeedOffset
		db $FF,$20,$E0,$FF
		db $FF,$20,$E0,$FF


		.ClimbX
		db $F0,$10
		db $10,$F0

		.ClimbLock
		db $0A,$09
		db $01,$02					; third byte used for easier indexing

		.WallAnim
		db $01,$02

		.SlopeSpeed
		db $E0,$F0,$00,$00,$00,$00,$00,$10,$20
		


	PHYSICS:

		.Stamina
		LDA !P2WallClimb : BEQ .NoStamina		;\
		LDA !P2Stamina : BEQ .NoStamina			; |
		LDA !P2XSpeed : BEQ ..nox			; |
		ASL A						; |
		ROL A						; |
		INC A						; |
		EOR !P2Blocked					; |
		AND #$03 : BNE .ClimbTimer			; |
		..nox						; |
		LDA !P2YSpeed : BEQ .NoClimb			; |
		ASL A						; | climb timer
		ROL A						; | (1/16th speed when still)
		INC A						; |
		ASL #2						; |
		EOR !P2Blocked					; |
		AND #$0C : BNE .ClimbTimer			; |
	.NoClimb						; |
		LDA $14						; |
		AND #$0F : BNE .NoStamina			; |
	.ClimbTimer						; |
		DEC !P2Stamina					; |
		.NoStamina					;/




		LDA !P2WallClimbTop : BEQ .NoGetUpAttack	;\
		BIT $16 : BVC .NoGetUpAttack			; | Can buffer get-up attack
		LDA #$02 : STA !P2WallClimbTop			;/
		.NoGetUpAttack



		.SlantPipe
		LDA !P2SlantPipe : BEQ ..done
		LDA #$40 : STA !P2XSpeed
		LDA #$C0 : STA !P2YSpeed
		LDA #$01
		STA !P2Dashing
		STA !P2DashJump
		..done

		LDA !P2Blocked
		AND #$04
		ORA !P2Platform
		BEQ ++
		LDA !P2WallClimbTop				;\
		CMP #$02 : BNE +				; | Clear get-up state upon touching the ground
		LDA #$01 : STA !P2SwordAttack			; | (and start attack if buffered)
		LDA #$3C : STA !SPC4				; | (slice SFX)
	+	STZ !P2WallClimbTop				;/
		STZ !P2KillCount
		JSL CORE_CHECK_ABOVE
		BCS .ForceCrouch

		LDA !P2Ducking : BEQ ++
		LDA !P2Blocked
		LDY !P2Platform
		BEQ $02 : ORA #$04
		AND $15
		AND #$04 : BEQ +
		LDA !P2Dashing
		ORA !P2SwordAttack
		ORA !P2Slope
		BNE +
		BRA .NoForceCrouch

		.ForceCrouch
		LDA #$08 : STA !P2CrouchTimer

		.NoForceCrouch
		STZ !P2YSpeed
		STZ !P2Dashing
		STZ !P2SwordAttack
		STZ !P2DashJump
		LDA #$04 : TSB !P2Blocked
		LDA $15
		AND #$03
		TAX
		LDA CONTROLS_XSpeed,x : JSL CORE_SET_XSPEED
		LDA CONTROLS_Direction,x : BMI ++
		STA !P2Direction : BRA ++
	+	LDA !P2CrouchTimer : BNE ++
		STZ !P2Ducking
		++


	;	LDA !P2Floatiness : BEQ +
	;	BIT $15 : BMI ++
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
		BIT $16 : BVC +
		LDA #$03 : STA !P2SwordAttack
		LDA #$3C : STA !SPC4				; slice SFX
		LDA #$01 : STA !P2DashSlash
		BRA .NoDash
	+	BIT $17 : BMI .NoDash
		LDA #$01 : STA !P2Dashing
		.NoDash


	SPRITE_INTERACTION:
		JSL CORE_SPRITE_INTERACTION


	UPDATE_SPEED:
		LDX #$46				; normal fall speed is 0x46
		LDA !LeewayUpgrades			;\
		AND #$10 : BEQ .NoCape			; |
		LDA $15 : BPL .NoCape			; | fall speed when slow falling with cape is 0x20
		AND #$04 : BNE .NoCape			; | (overwritten by water since you can't use the cape underwater)
		LDX #$20				; |
		.NoCape					;/
		LDA #$03				; gravity is 3 when holding B
		BIT $15 : BMI .G			;\
		LDA !P2JumpCancel : BEQ +		; |
		STZ !P2JumpCancel			; |
		LDA !P2YSpeed : BPL +			; | gravity is 6 when not holding B
		CLC : ADC #$18				; | (jump cancel: add 0x18 to y speed if moving up, cap at 00)
		BMI $02 : LDA #$00			; |
		STA !P2YSpeed				; |
	+	LDA #$06				;/
	.G	STA !P2Gravity				; store gravity
		LDA !P2Water				;\
		AND #$10 : BEQ .F			; |
		LDA !P2Gravity				; | gravity is halved (rounded up) in water
		LSR A					; |
		BCC $01 : INC A				; |
		STA !P2Gravity				;/
		LDX #$24				; fall speed in water is 0x24
	.F	STX !P2FallSpeed			; store fall speed

		LDA !P2XSpeed : PHA			;\
		LDA !P2Water				; |
		AND #$10 : BEQ +			; |
		LDA !P2XSpeed : BPL ++			; |
		EOR #$FF				; |
		LSR A					; |
		STA $00					; |
		LSR A					; | reduce horizontal speed by 25% underwater
		CLC : ADC $00				; |
		EOR #$FF				; |
		BRA +++					; |
	++	LSR A					; |
		STA $00					; |
		LSR A					; |
		CLC : ADC $00				; |
	+++	STA !P2XSpeed				;/
	+	JSL CORE_UPDATE_SPEED			; apply speed
		PLA : STA !P2XSpeed			; restore horizontal speed
		LDA !P2Platform : BEQ +			;\
		LDA #$04 : TSB !P2Blocked		; | set blocked flag if on platform
		+					;/

		LDA !P2WallClimb			;\
		AND #$02 : BEQ +			; |
		PHP : REP #$20				; | put Leeway 1px further left when sticking to left wall
		DEC !P2XPosLo				; |
		PLP					; |
		+					;/


	OBJECTS:
		SEP #$20
		LDA !P2Blocked : PHA
		REP #$30
		LDA !P2Anim
		AND #$00FF
		ASL #3
		TAY
		LDA ANIM+$06,y : JSL CORE_COLLISION

		LDA !P2Climbing : BEQ +
		STZ !P2SwordAttack
		STZ !P2SwordTimer
		STZ !P2AirDashUsed
		STZ !P2Dashing
		STZ !P2DashJump
		LDA !LeewayMaxStamina : STA !P2Stamina
		+


		LDA !P2Blocked
		AND $15
		AND #$08 : BEQ +
		LDA !P2Stamina : BEQ +
		LDA !LeewayUpgrades
		AND #$20 : BEQ +
		LDA #$80 : STA !P2WallClimb		; cling to ceiling off of bonk
		+



		LDA !P2Platform : BEQ +
		PLA : BRA .Landing

	+	PLA
		EOR !P2Blocked
		AND #$04 : BEQ .End
		LDA !P2Blocked
		AND #$04 : BEQ .End
		BIT !P2WallClimb : BMI .End

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
		SEC : SBC.b #(!Lee_AirSlash)-(!Lee_Slash)
		STA !P2Anim
		STZ !P2AnimTimer
		BRA ..landlag

	..cancel
		STZ !P2SwordAttack
		STZ !P2SwordTimer
	..landlag
		STZ !P2Dashing
		STZ !P2AirDashUsed
		STZ !P2DashJump
		STZ !P2WallClimb

		.End



	SCREEN_BORDER:
		JSL CORE_SCREEN_BORDER


	ATTACK:
		PEA ANIMATION-1
		LDA !P2SwordAttack
		DEC A
		ASL A
		TAX
		BCC +
		LDA $16 : TSB !P2Buffer			; Allow buffering, but not during frame 1
	+	CPX.b #.End-.Ptr
		BCC .Go
		.Return
		RTS

		.Go
		JMP (.Ptr,x)

		.Ptr
		dw .Cut					; 1
		dw .Slash				; 2
		dw .DashSlash				; 3
		dw .AirSlash				; 4
		dw .WallSlash				; 5
		dw .HangSlash				; 6
		.End

		.Cut
		LDA !P2SwordTimer
		CMP #$01
		BNE +
		BIT !P2Buffer : BVC +
		LDA #$02 : STA !P2SwordAttack
		LDA #$3D : STA !SPC4			; slash SFX
		BRA .Slash
	+	LDA !P2SwordAttack : BMI ..Process
		ORA #$80 : STA !P2SwordAttack
		LDA #!Lee_Cut : STA !P2Anim
		STZ !P2AnimTimer
		LDA #$1E : STA !P2SwordTimer
		..Process
	;	LDA #$00 : JSL CORE_SET_XSPEED
		LDA !P2Anim
		CMP #!Lee_Cut+1 : BEQ +
		CMP #!Lee_Cut+2 : BEQ ++
		RTS
	+	LDY #$00 : JMP HITBOX
	++	LDY #$02 : JMP HITBOX

		..Bits
		db $02,$01

		.Slash
		LDA !P2SwordAttack : BMI ..Process
		ORA #$80 : STA !P2SwordAttack
		LDA #!Lee_Slash : STA !P2Anim
		STZ !P2AnimTimer
		LDA #$18 : STA !P2SwordTimer
		STZ !P2Hitbox1IndexMem1
		STZ !P2Hitbox1IndexMem2
		STZ !P2Hitbox2IndexMem1
		STZ !P2Hitbox2IndexMem2
		..Process
	;	LDA #$00 : JSL CORE_SET_XSPEED
		LDA !P2Anim
		CMP #!Lee_Slash : BEQ +
		CMP #!Lee_Slash+1 : BEQ ++
		RTS
	+	LDY #$04 : JMP HITBOX
	++	LDY #$06 : JMP HITBOX

		.DashSlash
		LDA !P2SwordAttack : BMI ..Process
		ORA #$80 : STA !P2SwordAttack
		LDA #!Lee_DashSlash : STA !P2Anim
		STZ !P2AnimTimer
		LDA #$1A : STA !P2SwordTimer
		..Process
	;	LDA !P2InAir : BNE +
	;	JSL CORE_SMOKE_AT_FEET
	+	LDA !P2Anim
		CMP #!Lee_DashSlash+1 : BEQ +
		CMP #!Lee_DashSlash+2 : BEQ ++
		RTS
	+	LDY #$08 : JMP HITBOX
	++	LDY #$0A : JMP HITBOX

		.AirSlash
		LDA !P2SwordAttack : BMI ..Process
		ORA #$80 : STA !P2SwordAttack
		LDA #!Lee_AirSlash : STA !P2Anim
		STZ !P2AnimTimer
		LDA #$20 : STA !P2SwordTimer
		..Process
		LDA !P2Anim
		CMP #!Lee_AirSlash+1 : BEQ +
		CMP #!Lee_AirSlash+2 : BEQ ++
		RTS
	+	LDY #$0C : JMP HITBOX
	++	LDY #$0E : JMP HITBOX

		.WallSlash
		LDA !P2SwordAttack : BMI ..Process
		ORA #$80 : STA !P2SwordAttack
		LDA #!Lee_WallSlash : STA !P2Anim
		STZ !P2AnimTimer
		LDA #$1C : STA !P2SwordTimer
		..Process
		LDA !P2Direction
		EOR #$01
		TAX
		LDA CONTROLS_ClimbLock+2,x
		STA !P2WallJumpInput
		LDA #$03 : STA !P2WallJumpInputTimer
		LDA CONTROLS_ClimbX+2,x : STA !P2XSpeed
		LDA !P2Anim
		CMP #!Lee_WallSlash+1 : BEQ +
		CMP #!Lee_WallSlash+2 : BEQ ++
		RTS
	+	LDY #$10 : JMP HITBOX
	++	LDY #$12 : JMP HITBOX

		.HangSlash
		LDA !P2SwordAttack : BMI ..Process
		ORA #$80 : STA !P2SwordAttack
		LDA #!Lee_HangSlash : STA !P2Anim
		STZ !P2AnimTimer
		LDA #$16 : STA !P2SwordTimer
		..Process
		LDA #$00 : JSL CORE_SET_XSPEED
		LDA !P2Anim
		CMP #!Lee_HangSlash+1 : BEQ +
		CMP #!Lee_HangSlash+2 : BEQ ++
		RTS
	+	LDY #$14 : JMP HITBOX
	++	LDY #$16 : JMP HITBOX



	ANIMATION:
		LDA !P2ExternalAnimTimer			;\
		BEQ .ClearExternal				; |
		DEC !P2ExternalAnimTimer			; | Enforce external animations
		LDA !P2ExternalAnim : STA !P2Anim		; |
		DEC !P2AnimTimer				; |
		JMP .HandleUpdate				;/

		.ClearExternal
		STZ !P2ExternalAnim

	; pipe check
		LDA !P2Pipe : BEQ .NoPipe			;\
		BMI .VertPipe					; |
		.HorzPipe					; |
		JMP .Walk					; |
		.VertPipe					; | pipe animations
		LDA #!Lee_Victory : STA !P2Anim			; |
		STZ !P2AnimTimer				; |
		JMP .HandleUpdate				; |
		.NoPipe						;/


	; hurt check
		LDA !P2HurtTimer
		BEQ .NoHurt
		LDA #!Lee_Hurt : STA !P2Anim
		JMP .HandleUpdate
		.NoHurt

	; crouch check
		LDA !P2CrouchTimer
		BEQ $03 : JMP .Crouch


		LDA !P2WallClimbTop : BEQ .NoGetUp
		LDA #!Lee_ClimbTop : STA !P2Anim
		LDA #$10 : STA !P2AnimTimer
		.NoGetUp

		LDA !P2Anim
		CMP #!Lee_ClimbTop
		BNE $03 : JMP .HandleUpdate

		LDA !P2SwordAttack
		BEQ $03
	-	JMP .HandleUpdate

		LDA !P2WallClimb
		BEQ .NoClimb
		BMI .Ceiling
		LDA !P2Anim
		CMP #!Lee_WallCling : BCC .Stick
		CMP #!Lee_ClimbTop : BCS .Stick
		BRA -
	.Stick	LDA #!Lee_WallCling : STA !P2Anim
		STZ !P2AnimTimer
		BRA -


		.Ceiling
		LDA !P2XSpeed : BEQ -
		LDA !P2Anim
		CMP #!Lee_Ceiling : BCC +
		CMP #!Lee_Ceiling_over : BCS +
		JMP .HandleUpdate
	+	LDA #!Lee_Ceiling : STA !P2Anim
		STZ !P2AnimTimer
		JMP .HandleUpdate
		.NoClimb


		LDA !P2Climbing : BEQ .NoVineClimb
		LDA !P2Anim
		CMP #!Lee_ClimbBG : BCC +
		CMP #!Lee_ClimbBG_over : BCC ++
	+	LDA #!Lee_ClimbBG : STA !P2Anim
		STZ !P2AnimTimer
	++	LDA $15
		AND #$0F : BNE +
		STZ !P2AnimTimer
	+	JMP .HandleUpdate
		.NoVineClimb

		LDA !P2Dashing : BEQ .NoDash

		.Dash
	;	JSL CORE_SMOKE_AT_FEET
		LDA !P2Anim
		CMP #!Lee_Dash : BCC +
		CMP #!Lee_Dash_over : BCS +
		JMP .HandleUpdate
	+	LDA #!Lee_Dash : STA !P2Anim
		STZ !P2AnimTimer
		JMP .HandleUpdate

		.NoDash
		LDA !P2Blocked
		AND #$04
		ORA !P2Platform
		BNE .Ground

		.Air
		BIT !P2YSpeed : BPL .Falling

		.Jump
		LDA #!Lee_Jump : STA !P2Anim
	-	JMP .HandleUpdate

		.Falling
		LDA !LeewayUpgrades				; check for slow fall upgrade
		AND #$10 : BEQ ..fast
		BIT $15 : BPL ..fast
	..slow	LDA !P2Anim
		CMP #!Lee_SlowFall : BCC +
		CMP #!Lee_SlowFall_over : BCC -
	+	LDA #!Lee_SlowFall : BRA ++
	..fast	LDA !P2Anim
		CMP #!Lee_Fall : BCC +
		CMP #!Lee_Fall_over : BCC .HandleUpdate
	+	LDA #!Lee_Fall
	++	STA !P2Anim
		STZ !P2AnimTimer
		BRA .HandleUpdate

		.Ground
		LDA !P2Ducking : BEQ .NoCrawl

		.Crouch
		LDA !P2XSpeed : BNE .Crawl
		LDA !P2Anim
		CMP #!Lee_Crouch : BCC +
		CMP #!Lee_Crouch_over : BCC .Crawl
	+	DEC !P2AnimTimer

		.Crawl
		LDA !P2Anim
		CMP #!Lee_Crouch : BCC +
		CMP #!Lee_CrouchEnd : BCC .HandleUpdate
	+	LDA #!Lee_Crouch : STA !P2Anim
		STZ !P2AnimTimer
		BRA .HandleUpdate

		.NoCrawl
		LDA !P2Anim
		CMP #!Lee_Crouch : BCC +
		CMP #!Lee_CrouchEnd : BCS +
		LDA #!Lee_CrouchEnd : STA !P2Anim
		STZ !P2AnimTimer
		BRA .HandleUpdate

	+	CMP #!Lee_CrouchEnd : BEQ .HandleUpdate
		LDA !P2XSpeed : BNE .Walk
		LDA !P2Anim
		CMP #!Lee_Walk : BCC .HandleUpdate
		STZ !P2Anim
		STZ !P2AnimTimer
		BRA .HandleUpdate

		.Walk
		LDA !P2Anim
		CMP #!Lee_Walk : BCC +
		CMP #!Lee_Walk_over : BCC .HandleUpdate
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
		LDA SWORD+$00,y : STA $00		;\ Sword data in $00-$03
		LDA SWORD+$02,y : STA $02		;/
		BRA GRAPHICS

		.ThisOne
		LDA !P2Anim
		STA !P2Anim2
		REP #$30
		LDA ANIM+$04,y : STA $00		; (we're gonna overwrite $00-$03 soon so this is fine)


		PHY
		; LDA ($00)				;\
		; AND #$00FF				; |
		; STA $02					; |
		; LDX #$0000				; |
		; LDY #$0000				; |
		; INC $00					; |
	; -	LDA ($00),y				; |
		; AND #$001E				; |
		; ASL #4					; |
		; STA !BigRAM+$00+2,x			; |
		; LDA ($00),y : BPL .Swd			; |
	; .Body	AND #$7FE0				; |
		; ORA #$8000				; |
		; STA !BigRAM+$02+2,x			; |
		; LDA #$0035 : BRA .Shared		; |
	; .Swd	AND #$7FE0				; |
		; ORA #$8008				; |
		; STA !BigRAM+$02+2,x			; |
		; LDA #$0034				; | unpack dynamo data
	; .Shared	STA !BigRAM+$04+2,x			; |
		; INY #2					; |
		; LDA ($00),y				; |
		; ASL A					; |
		; AND #$01F0				; |
		; ORA #$6200				; |
		; STA !BigRAM+$05+2,x			; |
		; INY					; |
		; TXA					; |
		; CLC : ADC #$0007			; |
		; TAX					; |
		; CPY $02 : BCC -				;/
		; STX !BigRAM+0				; > set size

	;	LDA.w #!BigRAM : JSL CORE_GENERATE_RAMCODE
	LDY.w #!File_Leeway : JSL GetFileAddress	; primary file
	LDA.w #!File_Leeway_Sword : STA !FileAddress+4	; second file
	LDA $00 : JSL CORE_GENERATE_RAMCODE_24bit

		REP #$30
		PLY
		LDA SWORD+$00,y : STA $00		;\ Sword data in $00-$03
		LDA SWORD+$02,y : STA $02		;/


	GRAPHICS:
		LDA SWORD+$04,y				;\ Get priority setting
		STA $06					;/
		SEP #$30
		LDA !P2HurtTimer : BNE .DrawTiles
		LDA !P2ComboDisable : BNE .DrawTiles	; always draw during combo dash invinc
		LDA !P2Invinc : BEQ .DrawTiles

		.Flash
		LDA !P2Invinc : BEQ .DrawTiles
		LSR #3 : TAX
		LDA.l $00E292,x
		AND !P2Invinc : BNE .DrawTiles
		JMP OUTPUT_HURTBOX

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


		JSL CORE_LOAD_TILEMAP


	OUTPUT_HURTBOX:
		JSL CORE_FLASHPAL
		REP #$30
		LDA.w #ANIM
		JSL CORE_OUTPUT_HURTBOX
		PLB
		RTL


; JSR-ables

	; Load index in A (8-bit)
	HITBOX:
		LDA !P2SwordTimer : BNE .Process
		RTS

		.Process
		REP #$20
		LDA HitboxTable,y : JSL CORE_ATTACK_LoadHitbox
		.Return
		REP #$20
		LDA !P2Hitbox1IndexMem1
		ORA !P2Hitbox2IndexMem1
		STA !P2Hitbox1IndexMem1
		STA !P2Hitbox2IndexMem1
		SEP #$20
		JSL CORE_GET_TILE_Attack
		RTS



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
		dw .Cut0
		dw .Cut1
		dw .Slash0
		dw .Slash1
		dw .DashSlash0
		dw .DashSlash1
		dw .AirSlash0
		dw .AirSlash1
		dw .WallSlash0
		dw .WallSlash1
		dw .HangSlash0
		dw .HangSlash1

	.Cut0
	dw $0004,$FFFA : db $1F,$10	; X/Y + W/H
	db $10,$E8			; speeds
	db $10				; timer
	db $04				; hitstun
	db $02,$00			; SFX
	dw $FFE4,$FFF6 : db $20,$10
	db $F0,$E8
	db $10				; timer
	db $04				; hitstun
	db $02,$00			; SFX
	.Cut1
	dw $0004,$FFF6 : db $0D,$13
	db $10,$E8
	db $10				; timer
	db $04				; hitstun
	db $02,$00			; SFX
	dw $FFE4,$FFF6 : db $20,$10
	db $F0,$E8
	db $10				; timer
	db $04				; hitstun
	db $02,$00			; SFX

	.Slash0
	dw $0002,$FFFA : db $30,$1C
	db $20,$E8
	db $10				; timer
	db $04				; hitstun
	db $02,$00			; SFX
	dw $0012,$FFE6 : db $1D,$14
	db $20,$E8
	db $10				; timer
	db $04				; hitstun
	db $02,$00			; SFX
	.Slash1
	dw $0002,$0006 : db $27,$10
	db $20,$E8
	db $10				; timer
	db $04				; hitstun
	db $02,$00			; SFX
	db $00

	.DashSlash0
	dw $0014,$FFF6 : db $1F,$20
	db $00,$E8
	db $18				; timer
	db $04				; hitstun
	db $02,$00			; SFX
	dw $FFF1,$FFF4 : db $23,$1E
	db $F0,$E8
	db $18				; timer
	db $04				; hitstun
	db $02,$00			; SFX
	.DashSlash1
	dw $0014,$FFF2 : db $0D,$23
	db $00,$E8
	db $18				; timer
	db $04				; hitstun
	db $02,$00			; SFX
	dw $FFF1,$FFF4 : db $23,$1E
	db $F0,$E8
	db $18				; timer
	db $04				; hitstun
	db $02,$00			; SFX

	.AirSlash0
	dw $0002,$FFF8 : db $30,$1C
	db $20,$E8
	db $10				; timer
	db $04				; hitstun
	db $02,$00			; SFX
	dw $0012,$FFE4 : db $1D,$14
	db $20,$E8
	db $10				; timer
	db $04				; hitstun
	db $02,$00			; SFX
	.AirSlash1
	dw $0002,$0004 : db $27,$10
	db $20,$E8
	db $10				; timer
	db $04				; hitstun
	db $02,$00			; SFX
	db $00

	.WallSlash0				; note: this one is reverse (since leeway's direction is inverted while wall-clinging)
	dw $FFD4,$FFFC : db $30,$1C
	db $20,$E8
	db $10				; timer
	db $04				; hitstun
	db $02,$00			; SFX
	dw $FFD7,$FFE8 : db $1D,$14
	db $E0,$E8
	db $10				; timer
	db $04				; hitstun
	db $02,$00			; SFX
	.WallSlash1
	dw $FFDE,$0008 : db $27,$10
	db $E0,$E8
	db $10				; timer
	db $04				; hitstun
	db $02,$00			; SFX
	db $00

	.HangSlash0
	dw $000E,$FFF2 : db $30,$23
	db $20,$08
	db $10				; timer
	db $04				; hitstun
	db $02,$00			; SFX
	db $00
	.HangSlash1
	dw $000E,$0003 : db $25,$12
	db $20,$08
	db $10				; timer
	db $04				; hitstun
	db $02,$00			; SFX
	db $00




; Data

	ANIM:

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
	dw .WalkTM0 : db $06,!Lee_Walk+1
	dw .WalkDynamo0
	dw .ClippingStandard
	.Walk1				; 04
	dw .WalkTM1 : db $06,!Lee_Walk+2
	dw .WalkDynamo1
	dw .ClippingStandard
	.Walk2				; 05
	dw .WalkTM0 : db $06,!Lee_Walk+3
	dw .WalkDynamo2
	dw .ClippingStandard
	.Walk3				; 06
	dw .WalkTM0 : db $06,!Lee_Walk
	dw .WalkDynamo3
	dw .ClippingStandard

	.CutStart			; 07
	dw .24x32TM_Back : db $06,!Lee_Cut+1
	dw .CutStartDynamo
	dw .ClippingCut1

	.Cut0				; 08
	dw .32x32TM_Back : db $04,!Lee_Cut+2
	dw .CutDynamo0
	dw .ClippingCut2
	.Cut1				; 09
	dw .32x32TM_Back : db $04,!Lee_Cut+3
	dw .CutDynamo1
	dw .ClippingCut2
	.Cut2				; 0A
	dw .32x32TM_Back : db $08,!Lee_Cut+4
	dw .CutDynamo2
	dw .ClippingCut2
	.Cut3				; 0B
	dw .32x32TM_Back : db $08,!Lee_Idle
	dw .CutDynamo3
	dw .ClippingCut2

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

	.DashStart			; 10
	dw .32x32TM : db $04,!Lee_Dash+1
	dw .CrouchStartDynamo0
	dw .ClippingStandard
	.Dash0				; 11
	dw .32x32TM_Forward : db $06,!Lee_Dash+2
	dw .DashDynamo0
	dw .ClippingDash
	.Dash1				; 12
	dw .32x32TM_Forward : db $06,!Lee_Dash+3
	dw .DashDynamo1
	dw .ClippingDash
	.Dash2				; 13
	dw .32x32TM_Forward : db $06,!Lee_Dash+1
	dw .DashDynamo2
	dw .ClippingDash

	.DashSlash0			; 14
	dw .32x32TM_Forward : db $06,!Lee_DashSlash+1
	dw .DashSlashDynamo0
	dw .ClippingDash
	.DashSlash1			; 15
	dw .32x32TM_Forward : db $04,!Lee_DashSlash+2
	dw .DashSlashDynamo1
	dw .ClippingDash
	.DashSlash2			; 16
	dw .32x32TM_Forward : db $04,!Lee_DashSlash+3
	dw .DashSlashDynamo2
	dw .ClippingDash
	.DashSlash3			; 17
	dw .32x32TM_Forward : db $06,!Lee_DashSlash+4
	dw .DashSlashDynamo3
	dw .ClippingDash
	.DashSlash4			; 18
	dw .32x32TM_Forward : db $06,!Lee_Dash
	dw .DashSlashDynamo4
	dw .ClippingDash

	.Jump				; 19
	dw .24x32TM : db $FF,!Lee_Jump
	dw .JumpDynamo
	dw .ClippingStandard

	.Fall0				; 1A
	dw .24x40TM_Up : db $04,!Lee_Fall+1
	dw .FallDynamo0
	dw .ClippingStandard
	.Fall1				; 1B
	dw .24x40TM_Up : db $04,!Lee_Fall
	dw .FallDynamo1
	dw .ClippingStandard

	.SlowFall0			; 1C
	dw .24x32TM : db $06,!Lee_SlowFall+1
	dw .SlowFallDynamo0
	dw .ClippingStandard
	.SlowFall1			; 1D
	dw .24x32TM : db $06,!Lee_SlowFall+2
	dw .SlowFallDynamo1
	dw .ClippingStandard
	.SlowFall2			; 1E
	dw .24x32TM : db $06,!Lee_SlowFall
	dw .SlowFallDynamo2
	dw .ClippingStandard

	.CeilingClimb0			; 1F
	dw .24x32TM : db $0A,!Lee_Ceiling+1
	dw .CeilingClimbDynamo0
	dw .ClippingStandard
	.CeilingClimb1			; 20
	dw .24x40TM : db $0A,!Lee_Ceiling+2
	dw .CeilingClimbDynamo1
	dw .ClippingStandard
	.CeilingClimb2			; 21
	dw .24x40TM : db $0A,!Lee_Ceiling+3
	dw .CeilingClimbDynamo2
	dw .ClippingStandard
	.CeilingClimb3			; 22
	dw .24x40TM : db $0A,!Lee_Ceiling+4
	dw .CeilingClimbDynamo3
	dw .ClippingStandard
	.CeilingClimb4			; 23
	dw .24x40TM : db $0A,!Lee_Ceiling+5
	dw .CeilingClimbDynamo4
	dw .ClippingStandard
	.CeilingClimb5			; 24
	dw .24x40TM : db $0A,!Lee_Ceiling
	dw .CeilingClimbDynamo5
	dw .ClippingStandard

	.CrouchStart0			; 25
	dw .32x32TM : db $06,!Lee_Crouch+1
	dw .CrouchStartDynamo0
	dw .ClippingStandard
	.CrouchStart1			; 26
	dw .32x24TM : db $06,!Lee_Crawl
	dw .CrouchStartDynamo1
	dw .ClippingCrawl

	.Crawl0				; 27
	dw .32x24TM : db $06,!Lee_Crawl+1
	dw .CrawlDynamo0
	dw .ClippingCrawl
	.Crawl1				; 28
	dw .40x16TM : db $06,!Lee_Crawl+2
	dw .CrawlDynamo1
	dw .ClippingCrawl
	.Crawl2				; 29
	dw .32x24TM : db $06,!Lee_Crawl+3
	dw .CrawlDynamo0
	dw .ClippingCrawl
	.Crawl3				; 2A
	dw .32x16TM : db $06,!Lee_Crawl
	dw .CrawlDynamo2
	dw .ClippingCrawl

	.CrouchEnd			; 2B
	dw .24x32TM : db $08,!Lee_Idle
	dw .CrouchEndDynamo
	dw .ClippingStandard

	.AirSlash0			; 2C
	dw .32x32TM : db $08,!Lee_AirSlash+1
	dw .AirSlashDynamo0
	dw .ClippingStandard
	.AirSlash1			; 2D
	dw .32x32TM : db $04,!Lee_AirSlash+2
	dw .AirSlashDynamo1
	dw .ClippingStandard
	.AirSlash2			; 2E
	dw .32x32TM : db $04,!Lee_AirSlash+3
	dw .AirSlashDynamo2
	dw .ClippingStandard
	.AirSlash3			; 2F
	dw .32x32TM : db $10,!Lee_Fall
	dw .AirSlashDynamo3
	dw .ClippingStandard

	.Hang				; 30
	dw .24x32TM : db $FF,!Lee_Hang
	dw .HangDynamo
	dw .ClippingStandard

	.HangSlash0			; 31
	dw .24x40TM : db $06,!Lee_HangSlash+1
	dw .HangSlashDynamo0
	dw .ClippingStandard
	.HangSlash1			; 32
	dw .24x32TM_F3 : db $04,!Lee_HangSlash+2
	dw .HangSlashDynamo1
	dw .ClippingStandard
	.HangSlash2			; 33
	dw .24x32TM_F3 : db $04,!Lee_HangSlash+3
	dw .HangSlashDynamo2
	dw .ClippingStandard
	.HangSlash3			; 34
	dw .24x40TM : db $08,!Lee_Hang
	dw .HangSlashDynamo3
	dw .ClippingStandard

	.WallCling			; 35
	dw .24x32TM_Back : db $FF,!Lee_WallCling
	dw .WallClingDynamo
	dw .ClippingStandard

	.WallSlash0			; 36
	dw .24x32TM_Back : db $0A,!Lee_WallSlash+1
	dw .WallSlashDynamo0
	dw .ClippingStandard
	.WallSlash1			; 37
	dw .24x32TM_Back : db $04,!Lee_WallSlash+2
	dw .WallSlashDynamo1
	dw .ClippingStandard
	.WallSlash2			; 38
	dw .24x32TM_Back : db $04,!Lee_WallSlash+3
	dw .WallSlashDynamo2
	dw .ClippingStandard
	.WallSlash3			; 39
	dw .24x32TM_Back : db $0A,!Lee_WallCling
	dw .WallSlashDynamo3
	dw .ClippingStandard

	.WallClimb0			; 3A
	dw .24x32TM_Back : db $08,!Lee_WallClimb+1
	dw .WallClimbDynamo0
	dw .ClippingWall
	.WallClimb1			; 3B
	dw .24x32TM_Back : db $08,!Lee_WallClimb+2
	dw .WallClimbDynamo1
	dw .ClippingWall
	.WallClimb2			; 3C
	dw .24x32TM_Back : db $08,!Lee_WallClimb+3
	dw .WallClimbDynamo2
	dw .ClippingWall
	.WallClimb3			; 3D
	dw .24x32TM_Back : db $08,!Lee_WallClimb
	dw .WallClimbDynamo3
	dw .ClippingWall

	.ClimbTop			; 3E
	dw .32x32TM : db $12,!Lee_Idle
	dw .ClimbTopDynamo
	dw .ClippingStandard

	.ClimbBG0			; 3F
	dw .24x32TM : db $10,!Lee_ClimbBG+1
	dw .ClimbBGDynamo
	dw .ClippingStandard
	.ClimbBG1			; 40
	dw .24x32TM_X : db $10,!Lee_ClimbBG
	dw .ClimbBGDynamo
	dw .ClippingStandard

	.Hurt				; 41
	dw .32x32TM : db $FF,!Lee_Hurt
	dw .HurtDynamo
	dw .ClippingStandard

	.Dead				; 42
	dw .24x32TM : db $08,!Lee_Dead+1
	dw .DeadDynamo
	dw .ClippingStandard
	dw .24x32TM_X : db $08,!Lee_Dead+0
	dw .DeadDynamo
	dw .ClippingStandard

	.Victory0
	dw .24x32TM : db $14,!Lee_Victory+1
	dw .VictoryDynamo0
	dw .ClippingStandard
	.Victory1
	dw .24x32TM : db $14,!Lee_Victory
	dw .VictoryDynamo1
	dw .ClippingStandard


	.IdleTM
	dw $000C
	db $20,$FC,$F0,!P1Tile1
	db $20,$FC,$00,!P1Tile2
	db $20,$04,$00,!P1Tile2+$01

	.WalkTM0
	dw $0010
	db $20,$FC,$F0,!P1Tile1
	db $20,$0C,$F0,!P1Tile2
	db $20,$FC,$00,!P1Tile3
	db $20,$0C,$00,!P1Tile4
	.WalkTM1
	dw $0010
	db $20,$FC,$F0,!P1Tile1
	db $20,$04,$F0,!P1Tile1+$01
	db $20,$FC,$00,!P1Tile3
	db $20,$04,$00,!P1Tile3+$01



	.40x16TM
	dw $000C
	db $20,$00,$00,!P1Tile1
	db $20,$10,$00,!P1Tile2
	db $20,$18,$00,!P1Tile2+$01

	.32x24TM
	dw $0010
	db $20,$00,$F8,!P1Tile1
	db $20,$10,$F8,!P1Tile2
	db $20,$00,$00,!P1Tile3
	db $20,$10,$00,!P1Tile4

	.32x16TM
	dw $0008
	db $20,$00,$00,!P1Tile1
	db $20,$10,$00,!P1Tile2

	.32x32TM
	dw $0010
	db $20,$FC,$F0,!P1Tile1
	db $20,$0C,$F0,!P1Tile2
	db $20,$FC,$00,!P1Tile3
	db $20,$0C,$00,!P1Tile4
	..Forward
	dw $0010
	db $20,$F4,$F0,!P1Tile1
	db $20,$04,$F0,!P1Tile2
	db $20,$F4,$00,!P1Tile3
	db $20,$04,$00,!P1Tile4
	..Back
	dw $0010
	db $20,$00,$F0,!P1Tile1
	db $20,$10,$F0,!P1Tile2
	db $20,$00,$00,!P1Tile3
	db $20,$10,$00,!P1Tile4

	.24x32TM
	dw $0010
	db $20,$FC,$F0,!P1Tile1
	db $20,$04,$F0,!P1Tile1+$01
	db $20,$FC,$00,!P1Tile3
	db $20,$04,$00,!P1Tile3+$01
	..Back
	dw $0010
	db $20,$00,$F0,!P1Tile1
	db $20,$08,$F0,!P1Tile1+$01
	db $20,$00,$00,!P1Tile3
	db $20,$08,$00,!P1Tile3+$01
	..F3
	dw $0010
	db $20,$F9,$F0,!P1Tile1
	db $20,$01,$F0,!P1Tile1+$01
	db $20,$F9,$00,!P1Tile3
	db $20,$01,$00,!P1Tile3+$01
	..X
	dw $0010
	db $60,$04,$F0,!P1Tile1
	db $60,$FC,$F0,!P1Tile1+$01
	db $60,$04,$00,!P1Tile3
	db $60,$FC,$00,!P1Tile3+$01

	.24x40TM
	dw $0018
	db $20,$FC,$F0,!P1Tile1
	db $20,$04,$F0,!P1Tile1+$01
	db $20,$FC,$00,!P1Tile2+$01
	db $20,$04,$00,!P1Tile3
	db $20,$FC,$08,!P1Tile4
	db $20,$04,$08,!P1Tile4+$01
	..Up
	dw $0018
	db $20,$FC,$EC,!P1Tile1
	db $20,$04,$EC,!P1Tile1+$01
	db $20,$FC,$FC,!P1Tile2+$01
	db $20,$04,$FC,!P1Tile3
	db $20,$FC,$04,!P1Tile4
	db $20,$04,$04,!P1Tile4+$01




macro LeeDyn(TileCount, TileNumber, Dest)
	db (<TileCount>*2)|((<TileNumber>&$07)<<5)
	db ((<TileNumber>>>3)&$7F)
	db <Dest>*8
endmacro

macro SwdDyn(TileCount, TileNumber, Dest)
	db (<TileCount>*2)|((<TileNumber>&$07)<<5)
	db (<TileNumber>>>3)&$7F|$80
	db <Dest>*8
endmacro


; -- dynamo format --
;
; 1 byte header (size)
; for each upload:
; 	cccssss-
; 	Fccccccc
; 	ttttt---
;
; ssss:		DMA size (shift left 4)
; cccccccccc:	character (shift left 1 for source address)
; F:		second file flag (when set, file stored at !FileAddress+4 should be used for the rest of the dynamo)
; ttttt:	tile number (shift left 1 then add VRAM offset)


; NOTE: leeway dynamo has to be stored before sword dynamo!


	.IdleDynamo0
	db ..end-..start
	..start
	%LeeDyn(2, $000, !P1Tile1)
	%LeeDyn(2, $010, !P1Tile1+$10)
	%LeeDyn(3, $020, !P1Tile2)
	%LeeDyn(3, $030, !P1Tile2+$10)
	%SwdDyn(3, $008, !P1Tile5)
	%SwdDyn(3, $018, !P1Tile5+$10)
	..end
	.IdleDynamo1
	db ..end-..start
	..start
	%LeeDyn(2, $000, !P1Tile1)
	%LeeDyn(2, $010, !P1Tile1+$10)
	%LeeDyn(3, $023, !P1Tile2)
	%LeeDyn(3, $033, !P1Tile2+$10)
	%SwdDyn(3, $008, !P1Tile5)
	%SwdDyn(3, $018, !P1Tile5+$10)
	..end
	.IdleDynamo2
	db ..end-..start
	..start
	%LeeDyn(2, $000, !P1Tile1)
	%LeeDyn(2, $010, !P1Tile1+$10)
	%LeeDyn(3, $026, !P1Tile2)
	%LeeDyn(3, $036, !P1Tile2+$10)
	%SwdDyn(3, $008, !P1Tile5)
	%SwdDyn(3, $018, !P1Tile5+$10)
	..end

	.WalkDynamo0
	db ..end-..start
	..start
	%LeeDyn(4, $040, !P1Tile1)
	%LeeDyn(4, $050, !P1Tile1+$10)
	%LeeDyn(4, $060, !P1Tile3)
	%LeeDyn(4, $070, !P1Tile3+$10)
	%SwdDyn(3, $008, !P1Tile5)
	%SwdDyn(3, $018, !P1Tile5+$10)
	..end
	.WalkDynamo1
	db ..end-..start
	..start
	%LeeDyn(3, $044, !P1Tile1)
	%LeeDyn(3, $054, !P1Tile1+$10)
	%LeeDyn(3, $064, !P1Tile3)
	%LeeDyn(3, $074, !P1Tile3+$10)
	%SwdDyn(3, $028, !P1Tile5)
	%SwdDyn(3, $038, !P1Tile5+$10)
	..end
	.WalkDynamo2
	db ..end-..start
	..start
	%LeeDyn(4, $047, !P1Tile1)
	%LeeDyn(4, $057, !P1Tile1+$10)
	%LeeDyn(4, $067, !P1Tile3)
	%LeeDyn(4, $077, !P1Tile3+$10)
	%SwdDyn(3, $028, !P1Tile5)
	%SwdDyn(3, $038, !P1Tile5+$10)
	..end
	.WalkDynamo3
	db ..end-..start
	..start
	%LeeDyn(4, $04B, !P1Tile1)
	%LeeDyn(4, $05B, !P1Tile1+$10)
	%LeeDyn(4, $06B, !P1Tile3)
	%LeeDyn(4, $07B, !P1Tile3+$10)
	%SwdDyn(3, $008, !P1Tile5)
	%SwdDyn(3, $018, !P1Tile5+$10)
	..end

	.CutStartDynamo
	db ..end-..start
	..start
	%LeeDyn(3, $00C, !P1Tile1)
	%LeeDyn(3, $01C, !P1Tile1+$10)
	%LeeDyn(3, $02C, !P1Tile3)
	%LeeDyn(3, $03C, !P1Tile3+$10)
	%SwdDyn(3, $008, !P1Tile5)
	%SwdDyn(3, $018, !P1Tile5+$10)
	..end

	.CutDynamo0
	db ..end-..start
	..start
	%LeeDyn(4, $080, !P1Tile1)
	%LeeDyn(4, $090, !P1Tile1+$10)
	%LeeDyn(4, $0A0, !P1Tile3)
	%LeeDyn(4, $0B0, !P1Tile3+$10)
	%SwdDyn(8, $038, !P1Tile5)
	%SwdDyn(8, $048, !P1Tile5+$10)
	..end
	.CutDynamo1
	db ..end-..start
	..start
	%LeeDyn(4, $084, !P1Tile1)
	%LeeDyn(4, $094, !P1Tile1+$10)
	%LeeDyn(4, $0A4, !P1Tile3)
	%LeeDyn(4, $0B4, !P1Tile3+$10)
	%SwdDyn(6, $057, !P1Tile5)
	%SwdDyn(6, $067, !P1Tile5+$10)
	..end
	.CutDynamo2
	db ..end-..start
	..start
	%LeeDyn(4, $088, !P1Tile1)
	%LeeDyn(4, $098, !P1Tile1+$10)
	%LeeDyn(4, $0A8, !P1Tile3)
	%LeeDyn(4, $0B8, !P1Tile3+$10)
	%SwdDyn(3, $05D, !P1Tile6)
	%SwdDyn(3, $06D, !P1Tile6+$10)
	..end
	.CutDynamo3
	db ..end-..start
	..start
	%LeeDyn(4, $08C, !P1Tile1)
	%LeeDyn(4, $09C, !P1Tile1+$10)
	%LeeDyn(4, $0AC, !P1Tile3)
	%LeeDyn(4, $0BC, !P1Tile3+$10)
	%SwdDyn(3, $05D, !P1Tile6)
	%SwdDyn(3, $06D, !P1Tile6+$10)
	..end

	.SlashDynamo0
	db ..end-..start
	..start
	%LeeDyn(4, $0C0, !P1Tile1)
	%LeeDyn(4, $0D0, !P1Tile1+$10)
	%LeeDyn(4, $0E0, !P1Tile3)
	%LeeDyn(4, $0F0, !P1Tile3+$10)
	%SwdDyn(2, $000, !P1Tile5)
	%SwdDyn(2, $010, !P1Tile5+$10)
	%SwdDyn(5, $011, !P1Tile6)
	%SwdDyn(5, $021, !P1Tile6+$10)
	..end
	.SlashDynamo1
	db ..end-..start
	..start
	%LeeDyn(4, $0C4, !P1Tile1)
	%LeeDyn(4, $0D4, !P1Tile1+$10)
	%LeeDyn(4, $0E4, !P1Tile3)
	%LeeDyn(4, $0F4, !P1Tile3+$10)
	%SwdDyn(5, $040, !P1Tile5)
	%SwdDyn(5, $050, !P1Tile5+$10)
	..end
	.SlashDynamo2
	db ..end-..start
	..start
	%LeeDyn(4, $0C8, !P1Tile1)
	%LeeDyn(4, $0D8, !P1Tile1+$10)
	%LeeDyn(4, $0E8, !P1Tile3)
	%LeeDyn(4, $0F8, !P1Tile3+$10)
	%SwdDyn(2, $00C, !P1Tile7)
	%SwdDyn(2, $01C, !P1Tile7+$10)
	%SwdDyn(2, $01B, !P1Tile8)
	%SwdDyn(2, $02B, !P1Tile8+$10)
	..end
	.SlashDynamo3
	db ..end-..start
	..start
	%LeeDyn(4, $0CC, !P1Tile1)
	%LeeDyn(4, $0DC, !P1Tile1+$10)
	%LeeDyn(4, $0EC, !P1Tile3)
	%LeeDyn(4, $0FC, !P1Tile3+$10)
	..end


	.DashDynamo0
	db ..end-..start
	..start
	%LeeDyn(4, $100, !P1Tile1)
	%LeeDyn(4, $110, !P1Tile1+$10)
	%LeeDyn(4, $120, !P1Tile3)
	%LeeDyn(4, $130, !P1Tile3+$10)
	%SwdDyn(3, $008, !P1Tile5)
	%SwdDyn(3, $018, !P1Tile5+$10)
	..end
	.DashDynamo1
	db ..end-..start
	..start
	%LeeDyn(4, $104, !P1Tile1)
	%LeeDyn(4, $114, !P1Tile1+$10)
	%LeeDyn(4, $124, !P1Tile3)
	%LeeDyn(4, $134, !P1Tile3+$10)
	%SwdDyn(3, $008, !P1Tile5)
	%SwdDyn(3, $018, !P1Tile5+$10)
	..end
	.DashDynamo2
	db ..end-..start
	..start
	%LeeDyn(4, $108, !P1Tile1)
	%LeeDyn(4, $118, !P1Tile1+$10)
	%LeeDyn(4, $128, !P1Tile3)
	%LeeDyn(4, $138, !P1Tile3+$10)
	%SwdDyn(3, $008, !P1Tile5)
	%SwdDyn(3, $018, !P1Tile5+$10)
	..end
	.DashSlashDynamo0
	db ..end-..start
	..start
	%LeeDyn(4, $10C, !P1Tile1)
	%LeeDyn(4, $11C, !P1Tile1+$10)
	%LeeDyn(4, $12C, !P1Tile3)
	%LeeDyn(4, $13C, !P1Tile3+$10)
	%SwdDyn(3, $008, !P1Tile5)
	%SwdDyn(3, $018, !P1Tile5+$10)
	..end
	.DashSlashDynamo1
	db ..end-..start
	..start
	%LeeDyn(4, $140, !P1Tile1)
	%LeeDyn(4, $150, !P1Tile1+$10)
	%LeeDyn(4, $160, !P1Tile3)
	%LeeDyn(4, $170, !P1Tile3+$10)
	%SwdDyn(8, $038, !P1Tile5)
	%SwdDyn(8, $048, !P1Tile5+$10)
	..end
	.DashSlashDynamo2
	db ..end-..start
	..start
	%LeeDyn(4, $144, !P1Tile1)
	%LeeDyn(4, $154, !P1Tile1+$10)
	%LeeDyn(4, $164, !P1Tile3)
	%LeeDyn(4, $174, !P1Tile3+$10)
	%SwdDyn(6, $057, !P1Tile5)
	%SwdDyn(6, $067, !P1Tile5+$10)
	..end
	.DashSlashDynamo3
	db ..end-..start
	..start
	%LeeDyn(4, $148, !P1Tile1)
	%LeeDyn(4, $158, !P1Tile1+$10)
	%LeeDyn(4, $168, !P1Tile3)
	%LeeDyn(4, $178, !P1Tile3+$10)
	%SwdDyn(3, $05D, !P1Tile6)
	%SwdDyn(3, $06D, !P1Tile6+$10)
	..end
	.DashSlashDynamo4
	db ..end-..start
	..start
	%LeeDyn(4, $14C, !P1Tile1)
	%LeeDyn(4, $15C, !P1Tile1+$10)
	%LeeDyn(4, $16C, !P1Tile3)
	%LeeDyn(4, $17C, !P1Tile3+$10)
	%SwdDyn(3, $05D, !P1Tile6)
	%SwdDyn(3, $06D, !P1Tile6+$10)
	..end

	.JumpDynamo
	db ..end-..start
	..start
	%LeeDyn(3, $190, !P1Tile1)
	%LeeDyn(3, $1A0, !P1Tile1+$10)
	%LeeDyn(3, $1B0, !P1Tile3)
	%LeeDyn(3, $1C0, !P1Tile3+$10)
	%SwdDyn(3, $05D, !P1Tile6)
	%SwdDyn(3, $06D, !P1Tile6+$10)
	..end

	.FallDynamo0
	db ..end-..start
	..start
	%LeeDyn(3, $183, !P1Tile1)
	%LeeDyn(3, $193, !P1Tile1+$10)
	%LeeDyn(3, $1A3, !P1Tile2+$01)
	%LeeDyn(3, $1B3, !P1Tile2+$11)
	%LeeDyn(3, $1B3, !P1Tile4)
	%LeeDyn(3, $1C3, !P1Tile4+$10)
	%SwdDyn(2, $006, !P1Tile5+$01)
	%SwdDyn(2, $016, !P1Tile5+$11)
	%SwdDyn(2, $016, !P1Tile6+$01)
	%SwdDyn(2, $026, !P1Tile6+$11)
	..end
	.FallDynamo1
	db ..end-..start
	..start
	%LeeDyn(3, $186, !P1Tile1)
	%LeeDyn(3, $196, !P1Tile1+$10)
	%LeeDyn(3, $1A6, !P1Tile2+$01)
	%LeeDyn(3, $1B6, !P1Tile2+$11)
	%LeeDyn(3, $1B6, !P1Tile4)
	%LeeDyn(3, $1C6, !P1Tile4+$10)
	..end

	.SlowFallDynamo0
	db ..end-..start
	..start
	%LeeDyn(3, $1E0, !P1Tile1)
	%LeeDyn(3, $1F0, !P1Tile1+$10)
	%LeeDyn(3, $200, !P1Tile3)
	%LeeDyn(3, $210, !P1Tile3+$10)
	%SwdDyn(2, $00C, !P1Tile7)
	%SwdDyn(2, $01C, !P1Tile7+$10)
	%SwdDyn(2, $01B, !P1Tile8)
	%SwdDyn(2, $02B, !P1Tile8+$10)
	..end
	.SlowFallDynamo1
	db ..end-..start
	..start
	%LeeDyn(3, $1E3, !P1Tile1)
	%LeeDyn(3, $1F3, !P1Tile1+$10)
	%LeeDyn(3, $203, !P1Tile3)
	%LeeDyn(3, $213, !P1Tile3+$10)
	..end
	.SlowFallDynamo2
	db ..end-..start
	..start
	%LeeDyn(3, $1E6, !P1Tile1)
	%LeeDyn(3, $1F6, !P1Tile1+$10)
	%LeeDyn(3, $206, !P1Tile3)
	%LeeDyn(3, $216, !P1Tile3+$10)
	..end

	.CeilingClimbDynamo0
	db ..end-..start
	..start
	%LeeDyn(3, $1CA, !P1Tile1)
	%LeeDyn(3, $1DA, !P1Tile1+$10)
	%LeeDyn(3, $1EA, !P1Tile3)
	%LeeDyn(3, $1FA, !P1Tile3+$10)
	..end
	.CeilingClimbDynamo1
	db ..end-..start
	..start
	%LeeDyn(3, $1CD, !P1Tile1)
	%LeeDyn(3, $1DD, !P1Tile1+$10)
	%LeeDyn(3, $1ED, !P1Tile2+$01)
	%LeeDyn(3, $1FD, !P1Tile2+$11)
	%LeeDyn(3, $1FD, !P1Tile4)
	%LeeDyn(3, $20D, !P1Tile4+$10)
	..end
	.CeilingClimbDynamo2
	db ..end-..start
	..start
	%LeeDyn(3, $21A, !P1Tile1)
	%LeeDyn(3, $22A, !P1Tile1+$10)
	%LeeDyn(3, $23A, !P1Tile2+$01)
	%LeeDyn(3, $24A, !P1Tile2+$11)
	%LeeDyn(3, $24A, !P1Tile4)
	%LeeDyn(3, $25A, !P1Tile4+$10)
	..end
	.CeilingClimbDynamo3
	db ..end-..start
	..start
	%LeeDyn(3, $21D, !P1Tile1)
	%LeeDyn(3, $22D, !P1Tile1+$10)
	%LeeDyn(3, $23D, !P1Tile2+$01)
	%LeeDyn(3, $24D, !P1Tile2+$11)
	%LeeDyn(3, $24D, !P1Tile4)
	%LeeDyn(3, $25D, !P1Tile4+$10)
	..end
	.CeilingClimbDynamo4
	db ..end-..start
	..start
	%LeeDyn(3, $26A, !P1Tile1)
	%LeeDyn(3, $27A, !P1Tile1+$10)
	%LeeDyn(3, $28A, !P1Tile2+$01)
	%LeeDyn(3, $29A, !P1Tile2+$11)
	%LeeDyn(3, $29A, !P1Tile4)
	%LeeDyn(3, $2AA, !P1Tile4+$10)
	..end
	.CeilingClimbDynamo5
	db ..end-..start
	..start
	%LeeDyn(3, $26D, !P1Tile1)
	%LeeDyn(3, $27D, !P1Tile1+$10)
	%LeeDyn(3, $28D, !P1Tile2+$01)
	%LeeDyn(3, $29D, !P1Tile2+$11)
	%LeeDyn(3, $29D, !P1Tile4)
	%LeeDyn(3, $2AD, !P1Tile4+$10)
	..end

	.CrouchStartDynamo0
	db ..end-..start
	..start
	%LeeDyn(4, $189, !P1Tile1)
	%LeeDyn(4, $199, !P1Tile1+$10)
	%LeeDyn(4, $1A9, !P1Tile3)
	%LeeDyn(4, $1B9, !P1Tile3+$10)
	%SwdDyn(3, $008, !P1Tile5)
	%SwdDyn(3, $018, !P1Tile5+$10)
	..end
	.CrouchStartDynamo1
	db ..end-..start
	..start
	%LeeDyn(4, $265, !P1Tile1)
	%LeeDyn(4, $275, !P1Tile1+$10)
	%LeeDyn(4, $275, !P1Tile3)
	%LeeDyn(4, $285, !P1Tile3+$10)
	%SwdDyn(3, $028, !P1Tile5)
	%SwdDyn(3, $038, !P1Tile5+$10)
	..end
	.CrawlDynamo0
	db ..end-..start
	..start
	%LeeDyn(4, $260, !P1Tile1)
	%LeeDyn(4, $270, !P1Tile1+$10)
	%LeeDyn(4, $270, !P1Tile3)
	%LeeDyn(4, $280, !P1Tile3+$10)
	..end
	.CrawlDynamo1
	db ..end-..start
	..start
	%LeeDyn(5, $290, !P1Tile1)
	%LeeDyn(5, $2A0, !P1Tile1+$10)
	..end
	.CrawlDynamo2
	db ..end-..start
	..start
	%LeeDyn(4, $295, !P1Tile1)
	%LeeDyn(4, $2A5, !P1Tile1+$10)
	..end
	.CrouchEndDynamo
	db ..end-..start
	..start
	%LeeDyn(3, $18D, !P1Tile1)
	%LeeDyn(3, $19D, !P1Tile1+$10)
	%LeeDyn(3, $1AD, !P1Tile3)
	%LeeDyn(3, $1BD, !P1Tile3+$10)
	..end

	.AirSlashDynamo0
	db ..end-..start
	..start
	%LeeDyn(4, $3C7, !P1Tile1)
	%LeeDyn(4, $3D7, !P1Tile1+$10)
	%LeeDyn(4, $3E7, !P1Tile3)
	%LeeDyn(4, $3F7, !P1Tile3+$10)
	%SwdDyn(3, $008, !P1Tile5)
	%SwdDyn(3, $018, !P1Tile5+$10)
	..end
	.AirSlashDynamo1
	db ..end-..start
	..start
	%LeeDyn(4, $220, !P1Tile1)
	%LeeDyn(4, $230, !P1Tile1+$10)
	%LeeDyn(4, $240, !P1Tile3)
	%LeeDyn(4, $250, !P1Tile3+$10)
	%SwdDyn(2, $000, !P1Tile5)
	%SwdDyn(2, $010, !P1Tile5+$10)
	%SwdDyn(5, $011, !P1Tile6)
	%SwdDyn(5, $021, !P1Tile6+$10)
	..end
	.AirSlashDynamo2
	db ..end-..start
	..start
	%LeeDyn(4, $224, !P1Tile1)
	%LeeDyn(4, $234, !P1Tile1+$10)
	%LeeDyn(4, $244, !P1Tile3)
	%LeeDyn(4, $254, !P1Tile3+$10)
	%SwdDyn(5, $040, !P1Tile5)
	%SwdDyn(5, $050, !P1Tile5+$10)
	..end
	.AirSlashDynamo3
	db ..end-..start
	..start
	%LeeDyn(4, $224, !P1Tile1)
	%LeeDyn(4, $234, !P1Tile1+$10)
	%LeeDyn(4, $244, !P1Tile3)
	%LeeDyn(4, $254, !P1Tile3+$10)
	%SwdDyn(2, $00C, !P1Tile7)
	%SwdDyn(2, $01C, !P1Tile7+$10)
	%SwdDyn(2, $01B, !P1Tile8)
	%SwdDyn(2, $02B, !P1Tile8+$10)
	..end

	.HangDynamo
	db ..end-..start
	..start
	%LeeDyn(3, $2B0, !P1Tile1)
	%LeeDyn(3, $2C0, !P1Tile1+$10)
	%LeeDyn(3, $2D0, !P1Tile3)
	%LeeDyn(3, $2E0, !P1Tile3+$10)
	%SwdDyn(2, $00C, !P1Tile7)
	%SwdDyn(2, $01C, !P1Tile7+$10)
	%SwdDyn(2, $01B, !P1Tile8)
	%SwdDyn(2, $02B, !P1Tile8+$10)
	..end

	.HangSlashDynamo0
	db ..end-..start
	..start
	%LeeDyn(3, $2B3, !P1Tile1)
	%LeeDyn(3, $2C3, !P1Tile1+$10)
	%LeeDyn(3, $2D3, !P1Tile2+$01)
	%LeeDyn(3, $2E3, !P1Tile2+$11)
	%LeeDyn(3, $2E3, !P1Tile4)
	%LeeDyn(3, $2F3, !P1Tile4+$10)
	%SwdDyn(3, $05D, !P1Tile6)
	%SwdDyn(3, $06D, !P1Tile6+$10)
	..end
	.HangSlashDynamo1
	db ..end-..start
	..start
	%LeeDyn(3, $2B6, !P1Tile1)
	%LeeDyn(3, $2C6, !P1Tile1+$10)
	%LeeDyn(3, $2D6, !P1Tile3)
	%LeeDyn(3, $2E6, !P1Tile3+$10)
	%SwdDyn(2, $000, !P1Tile5)
	%SwdDyn(2, $010, !P1Tile5+$10)
	%SwdDyn(5, $011, !P1Tile6)
	%SwdDyn(5, $021, !P1Tile6+$10)
	..end
	.HangSlashDynamo2
	db ..end-..start
	..start
	%LeeDyn(3, $2B9, !P1Tile1)
	%LeeDyn(3, $2C9, !P1Tile1+$10)
	%LeeDyn(3, $2D9, !P1Tile3)
	%LeeDyn(3, $2E9, !P1Tile3+$10)
	%SwdDyn(5, $040, !P1Tile5)
	%SwdDyn(5, $050, !P1Tile5+$10)
	..end
	.HangSlashDynamo3
	db ..end-..start
	..start
	%LeeDyn(3, $2BC, !P1Tile1)
	%LeeDyn(3, $2CC, !P1Tile1+$10)
	%LeeDyn(3, $2DC, !P1Tile2+$01)
	%LeeDyn(3, $2EC, !P1Tile2+$11)
	%LeeDyn(3, $2EC, !P1Tile4)
	%LeeDyn(3, $2FC, !P1Tile4+$10)
	%SwdDyn(2, $00C, !P1Tile7)
	%SwdDyn(2, $01C, !P1Tile7+$10)
	%SwdDyn(2, $01B, !P1Tile8)
	%SwdDyn(2, $02B, !P1Tile8+$10)
	..end

	.WallClingDynamo
	db ..end-..start
	..start
	%LeeDyn(3, $300, !P1Tile1)
	%LeeDyn(3, $310, !P1Tile1+$10)
	%LeeDyn(3, $320, !P1Tile3)
	%LeeDyn(3, $330, !P1Tile3+$10)
	%SwdDyn(3, $028, !P1Tile5)
	%SwdDyn(3, $038, !P1Tile5+$10)
	..end

	.WallSlashDynamo0
	db ..end-..start
	..start
	%LeeDyn(3, $303, !P1Tile1)
	%LeeDyn(3, $313, !P1Tile1+$10)
	%LeeDyn(3, $323, !P1Tile3)
	%LeeDyn(3, $333, !P1Tile3+$10)
	%SwdDyn(3, $05D, !P1Tile6)
	%SwdDyn(3, $06D, !P1Tile6+$10)
	..end
	.WallSlashDynamo1
	db ..end-..start
	..start
	%LeeDyn(3, $306, !P1Tile1)
	%LeeDyn(3, $316, !P1Tile1+$10)
	%LeeDyn(3, $326, !P1Tile3)
	%LeeDyn(3, $336, !P1Tile3+$10)
	%SwdDyn(2, $000, !P1Tile5)
	%SwdDyn(2, $010, !P1Tile5+$10)
	%SwdDyn(5, $011, !P1Tile6)
	%SwdDyn(5, $021, !P1Tile6+$10)
	..end
	.WallSlashDynamo2
	db ..end-..start
	..start
	%LeeDyn(3, $309, !P1Tile1)
	%LeeDyn(3, $319, !P1Tile1+$10)
	%LeeDyn(3, $329, !P1Tile3)
	%LeeDyn(3, $339, !P1Tile3+$10)
	%SwdDyn(5, $040, !P1Tile5)
	%SwdDyn(5, $050, !P1Tile5+$10)
	..end
	.WallSlashDynamo3
	db ..end-..start
	..start
	%SwdDyn(2, $00C, !P1Tile7)
	%SwdDyn(2, $01C, !P1Tile7+$10)
	%SwdDyn(2, $01B, !P1Tile8)
	%SwdDyn(2, $02B, !P1Tile8+$10)
	..end

	.WallClimbDynamo0
	db ..end-..start
	..start
	%LeeDyn(3, $340, !P1Tile1)
	%LeeDyn(3, $350, !P1Tile1+$10)
	%LeeDyn(3, $360, !P1Tile3)
	%LeeDyn(3, $370, !P1Tile3+$10)
	%SwdDyn(2, $00C, !P1Tile7)
	%SwdDyn(2, $01C, !P1Tile7+$10)
	%SwdDyn(2, $01B, !P1Tile8)
	%SwdDyn(2, $02B, !P1Tile8+$10)
	..end
	.WallClimbDynamo1
	db ..end-..start
	..start
	%LeeDyn(3, $343, !P1Tile1)
	%LeeDyn(3, $353, !P1Tile1+$10)
	%LeeDyn(3, $363, !P1Tile3)
	%LeeDyn(3, $373, !P1Tile3+$10)
	..end
	.WallClimbDynamo2
	db ..end-..start
	..start
	%LeeDyn(3, $346, !P1Tile1)
	%LeeDyn(3, $356, !P1Tile1+$10)
	%LeeDyn(3, $366, !P1Tile3)
	%LeeDyn(3, $376, !P1Tile3+$10)
	..end
	.WallClimbDynamo3
	db ..end-..start
	..start
	%LeeDyn(3, $349, !P1Tile1)
	%LeeDyn(3, $359, !P1Tile1+$10)
	%LeeDyn(3, $369, !P1Tile3)
	%LeeDyn(3, $379, !P1Tile3+$10)
	..end

	.ClimbTopDynamo
	db ..end-..start
	..start
	%LeeDyn(4, $387, !P1Tile1)
	%LeeDyn(4, $397, !P1Tile1+$10)
	%LeeDyn(4, $3A7, !P1Tile3)
	%LeeDyn(4, $3B7, !P1Tile3+$10)
	%SwdDyn(3, $008, !P1Tile5)
	%SwdDyn(3, $018, !P1Tile5+$10)
	..end

	.ClimbBGDynamo
	db ..end-..start
	..start
	%LeeDyn(3, $39B, !P1Tile1)
	%LeeDyn(3, $3AB, !P1Tile1+$10)
	%LeeDyn(3, $3BB, !P1Tile3)
	%LeeDyn(3, $3CB, !P1Tile3+$10)
	%SwdDyn(2, $00C, !P1Tile7)
	%SwdDyn(2, $01C, !P1Tile7+$10)
	%SwdDyn(2, $01B, !P1Tile8)
	%SwdDyn(2, $02B, !P1Tile8+$10)
	..end

	.HurtDynamo
	db ..end-..start
	..start
	%LeeDyn(4, $393, !P1Tile1)
	%LeeDyn(4, $3A3, !P1Tile1+$10)
	%LeeDyn(4, $3B3, !P1Tile3)
	%LeeDyn(4, $3C3, !P1Tile3+$10)
	%SwdDyn(2, $00C, !P1Tile7)
	%SwdDyn(2, $01C, !P1Tile7+$10)
	%SwdDyn(2, $01B, !P1Tile8)
	%SwdDyn(2, $02B, !P1Tile8+$10)
	..end

	.DeadDynamo
	db ..end-..start
	..start
	%LeeDyn(3, $390, !P1Tile1)
	%LeeDyn(3, $3A0, !P1Tile1+$10)
	%LeeDyn(3, $3B0, !P1Tile3)
	%LeeDyn(3, $3C0, !P1Tile3+$10)
	%SwdDyn(3, $05D, !P1Tile6)
	%SwdDyn(3, $06D, !P1Tile6+$10)
	..end

	.VictoryDynamo0
	db ..end-..start
	..start
	%LeeDyn(3, $30C, !P1Tile1)
	%LeeDyn(3, $31C, !P1Tile1+$10)
	%LeeDyn(3, $32C, !P1Tile3)
	%LeeDyn(3, $33C, !P1Tile3+$10)
	%SwdDyn(2, $006, !P1Tile5+$01)
	%SwdDyn(2, $016, !P1Tile5+$11)
	%SwdDyn(2, $016, !P1Tile6+$01)
	%SwdDyn(2, $026, !P1Tile6+$11)
	..end
	.VictoryDynamo1
	db ..end-..start
	..start
	%LeeDyn(3, $34C, !P1Tile1)
	%LeeDyn(3, $35C, !P1Tile1+$10)
	%LeeDyn(3, $36C, !P1Tile3)
	%LeeDyn(3, $37C, !P1Tile3+$10)
	%SwdDyn(2, $006, !P1Tile5+$01)
	%SwdDyn(2, $016, !P1Tile5+$11)
	%SwdDyn(2, $016, !P1Tile6+$01)
	%SwdDyn(2, $026, !P1Tile6+$11)
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
	db $0D,$18			; W/H

	.ClippingCrawl
	; X
	db $0E,$01,$0E,$01		; R/L/R/L
	db $04,$0B,$08,$08		; D/D/U/C
	; Y
	db $06,$06,$0A,$0A		; R/L/R/L
	db $10,$10,$00,$08		; D/D/U/C
	; hurtbox
	dw $FFF0,$0002			; X/Y
	db $20,$0E			; W/H

	.ClippingWall
	; X
	db $0E,$01,$0E,$01		; R/L/R/L
	db $04,$0B,$08,$08		; D/D/U/C
	; Y
	db $FF,$FF,$03,$03		; R/L/R/L
	db $10,$10,$F4,$04		; D/D/U/C
	; hurtbox
	dw $0001,$FFF8			; X/Y
	db $0D,$18			; W/H


	.ClippingCut1
	; X
	db $0E,$01,$0E,$01		; R/L/R/L
	db $04,$0B,$08,$08		; D/D/U/C
	; Y
	db $FF,$FF,$0A,$0A		; R/L/R/L
	db $10,$10,$F8,$02		; D/D/U/C
	; hurtbox
	dw $FFFF,$FFF8			; X/Y
	db $0D,$18			; W/H
	.ClippingCut2
	; X
	db $0E,$01,$0E,$01		; R/L/R/L
	db $04,$0B,$08,$08		; D/D/U/C
	; Y
	db $FF,$FF,$0A,$0A		; R/L/R/L
	db $10,$10,$F8,$02		; D/D/U/C
	; hurtbox
	dw $FFFB,$FFF8			; X/Y
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


.End
print "  Anim data: $", hex(.End-ANIM), " bytes"
print "  - sequence data: $", hex(.IdleTM-ANIM), " bytes (", dec((.IdleTM-ANIM)*100/(.End-ANIM)), "%)"
print "  - tilemap data:  $", hex(.IdleDynamo0-.IdleTM), " bytes (", dec((.IdleDynamo0-.IdleTM)*100/(.End-ANIM)), "%)"
print "  - dynamo data:   $", hex(.ClippingStandard-.IdleDynamo0), " bytes (", dec((.ClippingStandard-.IdleDynamo0)*100/(.End-ANIM)), "%)"
print "  - clipping data: $", hex(.End-.ClippingStandard), " bytes (", dec((.End-.ClippingStandard)*100/(.End-ANIM)), "%)"



	SWORD:

	.Idle0				;
	dw .HorzTM : db $F1,$08
	dw $0000,$0000
	.Idle1				;
	dw .HorzTM : db $F1,$08
	dw $0000,$0000
	.Idle2				;
	dw .HorzTM : db $F1,$08
	dw $0000,$0000

	.Walk0				;
	dw .HorzTM : db $F1,$07
	dw $0000,$0000
	.Walk1				;
	dw .HorzTM : db $EC,$02
	dw $0000,$0000
	.Walk2				;
	dw .HorzTM : db $EF,$04
	dw $0000,$0000
	.Walk3				;
	dw .HorzTM : db $F3,$06
	dw $0000,$0000

	.CutStart			;
	dw .PrepTM : db $19,$05
	dw $0000,$0000
	.Cut0				;
	dw .CutTM0 : db $EC,$F2
	dw $FFFF,$0000
	.Cut1				;
	dw .CutTM1 : db $FC,$F2
	dw $FFFF,$0000
	.Cut3				;
	dw .HoldBackTM : db $14,$F3
	dw $0000,$0000
	.Cut4				;
	dw .HoldBackTM : db $14,$F3
	dw $0000,$0000

	.Slash0				;
	dw .SlashTM0 : db $DA,$FE
	dw $0000,$0000
	.Slash1				;
	dw .SlashTM1 : db $E2,$06
	dw $0000,$0000
	.Slash2				;
	dw .DiaTM : db $FA,$06
	dw $0000,$0000
	.Slash3				;
	dw .DiaTM : db $FA,$06
	dw $0000,$0000

	.DashStart			;
	dw .HorzTM : db $EF,$07
	dw $0000,$0000
	.Dash0				;
	dw .HorzTM : db $F1,$06
	dw $0000,$0000
	.Dash1				;
	dw .HorzTM : db $F1,$06
	dw $0000,$0000
	.Dash2				;
	dw .HorzTM : db $F1,$06
	dw $0000,$0000

	.DashSlash0			;
	dw .PrepTM : db $0D,$05
	dw $0000,$0000
	.DashSlash1			;
	dw .CutTM0 : db $DF,$F0
	dw $FFFF,$0000
	.DashSlash2			;
	dw .CutTM1 : db $EF,$F0
	dw $FFFF,$0000
	.DashSlash3			;
	dw .HoldBackTM : db $07,$F1
	dw $FFFF,$0000
	.DashSlash4			;
	dw .HoldBackTM : db $07,$F1
	dw $FFFF,$0000

	.Jump				;
	dw .HoldBackTM : db $09,$EF
	dw $0000,$0000
	.Fall0				;
	dw .FallTM : db $05,$04
	dw $0000,$0000
	.Fall1				;
	dw .FallTM : db $05,$04
	dw $0000,$0000

	.SlowFall0			;
	dw .DiaTM : db $01,$03
	dw $0000,$0000
	.SlowFall1			;
	dw .DiaTM : db $01,$03
	dw $0000,$0000
	.SlowFall2			;
	dw .DiaTM : db $01,$03
	dw $0000,$0000

	.CeilingClimb0			;
	dw .NoTM : db $00,$00
	dw $0000,$0000
	.CeilingClimb1			;
	dw .NoTM : db $00,$00
	dw $0000,$0000
	.CeilingClimb2			;
	dw .NoTM : db $00,$00
	dw $0000,$0000
	.CeilingClimb3			;
	dw .NoTM : db $00,$00
	dw $0000,$0000
	.CeilingClimb4			;
	dw .NoTM : db $00,$00
	dw $0000,$0000
	.CeilingClimb5			;
	dw .NoTM : db $00,$00
	dw $0000,$0000

	.CrouchStart0			;
	dw .HorzTM : db $EE,$07
	dw $0000,$0000
	.CrouchStart1			;
	dw .HorzTM : db $F1,$09
	dw $0000,$0000

	.Crawl0				;
	dw .HorzTM : db $F2,$09
	dw $0000,$0000
	.Crawl1				;
	dw .HorzTM : db $F5,$09
	dw $0000,$0000
	.Crawl2				;
	dw .HorzTM : db $F2,$09
	dw $0000,$0000
	.Crawl3				;
	dw .HorzTM : db $EF,$09
	dw $0000,$0000

	.CrouchEnd			;
	dw .HorzTM : db $EE,$07
	dw $0000,$0000

	.AirSlash0			;
	dw .PrepTM : db $0E,$F9
	dw $FFFF,$0000
	.AirSlash1			;
	dw .SlashTM0 : db $DC,$FC
	dw $0000,$0000
	.AirSlash2			;
	dw .SlashTM1 : db $E4,$04
	dw $0000,$0000
	.AirSlash3			;
	dw .DiaTM : db $FC,$04
	dw $0000,$0000

	.Hang				;
	dw .DiaTM : db $FE,$07
	dw $0000,$0000

	.HangSlash0			;
	dw .HoldBackTM : db $0A,$EB
	dw $0000,$0000
	.HangSlash1			;
	dw .SmallSlashTM : db $D0,$FD
	dw $0000,$0000
	.HangSlash2			;
	dw .SlashTM1 : db $D8,$05
	dw $0000,$0000
	.HangSlash3			;
	dw .DiaTM : db $FA,$06
	dw $0000,$0000

	.WallCling			;
	dw .WHorzTM : db $19,$03
	dw $0000,$0000

	.WallSlash0			;
	dw .WHoldBackTM : db $FB,$F4
	dw $FFFF,$0000
	.WallSlash1			;
	dw .WSlashTM0 : db $2E,$00
	dw $0000,$0000
	.WallSlash2			;
	dw .WSlashTM1 : db $26,$08
	dw $0000,$0000
	.WallSlash3			;
	dw .WDiaTM : db $0E,$08
	dw $0000,$0000

	.WallClimb0			;
	dw .ClimbTM : db $14,$07
	dw $FFFF,$0000
	.WallClimb1			;
	dw .ClimbTM : db $14,$07
	dw $FFFF,$0000
	.WallClimb2			;
	dw .ClimbTM : db $14,$07
	dw $FFFF,$0000
	.WallClimb3			;
	dw .ClimbTM : db $14,$07
	dw $FFFF,$0000

	.ClimbTop			;
	dw .PrepTM : db $11,$03
	dw $0000,$0000

	.ClimbBG0			;
	dw .DiaTM : db $00,$FC
	dw $0000,$0000
	.ClimbBG1			;
	dw .DiaTM : db $02,$FD
	dw $0000,$0000

	.Hurt				;
	dw .DiaTM : db $01,$02
	dw $0000,$0000

	.Dead				;
	dw .HoldBackTM : db $0A,$F4
	dw $0000,$0000
	dw .HoldBackTM : db $0E,$F0
	dw $0000,$0000

	.Victory0			;
	dw .HoldUpTM : db $01,$E7
	dw $0000,$0000
	.Victory1			;
	dw .HoldUpTM : db $00,$E5
	dw $0000,$0000


	.HorzTM
	dw $0008
	db $20,$00,$00,!P1Tile5
	db $20,$08,$00,!P1Tile5+$01

	.DiaTM
	dw $0008
	db $20,$00,$00,!P1Tile7
	db $20,$F8,$08,!P1Tile8

	.PrepTM
	dw $0008
	db $60,$00,$00,!P1Tile5
	db $60,$F8,$00,!P1Tile5+$01

	.CutTM0
	dw $0010
	db $20,$00,$00,!P1Tile5
	db $20,$10,$00,!P1Tile6
	db $20,$20,$00,!P1Tile7
	db $20,$30,$00,!P1Tile8
	.CutTM1
	dw $000C
	db $20,$00,$00,!P1Tile5
	db $20,$10,$00,!P1Tile6
	db $20,$20,$00,!P1Tile7

	.HoldBackTM
	dw $0008
	db $20,$00,$00,!P1Tile6
	db $20,$08,$00,!P1Tile6+$01


	.SmallSlashTM
	dw $0010
	db $20,$00,$00,!P1Tile5
	db $20,$08,$08,!P1Tile6
	db $20,$18,$08,!P1Tile7
	db $20,$20,$08,!P1Tile7+$01
	.SlashTM0
	dw $001C
	db $20,$00,$00,!P1Tile5
	db $20,$08,$08,!P1Tile6
	db $20,$18,$08,!P1Tile7
	db $20,$20,$08,!P1Tile7+$01
	db $20,$08,$E8,$4B
	db $21,$18,$E8,$4D
	db $21,$20,$E8,$4E
	.SlashTM1
	dw $000C
	db $20,$00,$00,!P1Tile5
	db $20,$10,$00,!P1Tile6
	db $20,$18,$00,!P1Tile6+$01

	.WHorzTM
	dw $0008
	db $60,$00,$00,!P1Tile5
	db $60,$F8,$00,!P1Tile5+$01

	.WSlashTM0
	dw $001C
	db $60,$00,$00,!P1Tile5
	db $60,$F8,$08,!P1Tile6
	db $60,$E8,$08,!P1Tile7
	db $60,$E0,$08,!P1Tile7+$01
	db $60,$F8,$E8,$4B
	db $61,$F0,$E8,$4D
	db $61,$E8,$E8,$4E
	.WSlashTM1
	dw $000C
	db $60,$00,$00,!P1Tile5
	db $60,$F0,$00,!P1Tile6
	db $60,$E8,$00,!P1Tile6+$01
	.WDiaTM
	dw $0008
	db $60,$00,$00,!P1Tile7
	db $60,$08,$08,!P1Tile8
	.WHoldBackTM
	dw $0008
	db $40,$00,$00,!P1Tile6
	db $40,$F8,$00,!P1Tile6+$01

	.HoldDownTM
	dw $0008
	db $20,$00,$00,!P1Tile5
	db $20,$08,$00,!P1Tile5+$01

	.HoldUpTM
	dw $0008
	db $20,$00,$00,!P1Tile5+$01
	db $20,$00,$08,!P1Tile6+$01

	.FallTM
	dw $0008
	db $A0,$00,$08,!P1Tile5+$01
	db $A0,$00,$00,!P1Tile6+$01

	.ClimbTM
	dw $0008
	db $60,$00,$00,!P1Tile7
	db $60,$08,$08,!P1Tile8

	.NoTM
	dw $0000




.End
print "  Sword data: $", hex(.End-SWORD), " bytes"
print "  - sequence data: $", hex(.HorzTM-SWORD), " bytes (", dec((.HorzTM-SWORD)*100/(.End-SWORD)), "%)"
print "  - tilemap data:  $", hex(.End-.HorzTM), " bytes (", dec((.End-.HorzTM)*100/(.End-SWORD)), "%)"




namespace off












