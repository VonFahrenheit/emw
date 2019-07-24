;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

namespace Leeway

; --Build 2.3--
;


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
		REP #$20
		LDA !P2YPosLo
		CLC : ADC #$0004
		STA !P2YPosLo
		SEC : SBC $1C
		CMP #$0180
		SEP #$20
		BMI .Fall
		BCC .Fall
		LDA #$02 : STA !P2Status
		PLB
		RTS

		.Fall
		LDA #$41 : STA !P2Anim
		STZ !P2AnimTimer
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

		.Return
		PLB
		RTS

		.Process
		LDA !P2MaxHP				;\
		CMP !P2HP				; | Enforce max HP
		BCS $03 : STA !P2HP			;/
		LDA !P2Platform				;\
		BEQ ++					; |
		CMP !P2SpritePlatform : BEQ +		; | Account for platforms
	++	STA !P2PrevPlatform			; |
		+					;/
		LDA $6DA5
		AND #$20
		ASL #2
		TSB $6DA5
		LDA $6DA9
		AND #$20
		ASL #2
		TSB $6DA9

		LDA !P2Floatiness
		BEQ $03 : DEC !P2Floatiness
		LDA !P2HurtTimer
		BEQ $03 : DEC !P2HurtTimer
		LDA !P2Invinc
		BEQ $03 : DEC !P2Invinc
		LDA !P2DashTimerR2
		BEQ $03 : DEC !P2DashTimerR2
		LDA !P2Dashing
		BEQ $05 : DEC !P2Dashing : BRA $03 : STZ !P2DashSlash	; only 1 attack per dash
		LDA !P2SlantPipe
		BEQ $03 : DEC !P2SlantPipe
		LDA !P2ClimbTop
		BEQ $03 : DEC !P2ClimbTop

		LDA !P2SwordTimer
		BNE +
		STZ !P2SwordAttack
		STZ !P2Buffer
		BRA ++
	+	DEC !P2SwordTimer
		LDA $6DA3			; Leeway can drop down during a dash slash by pushing down
		AND #$04 : BEQ +
		STZ !P2Dashing
		BRA ++

	+	LDA !P2Dashing : BEQ ++
		AND #$80
		ORA #$04
		STA !P2Dashing
		++

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

		LDA !P2HurtTimer
		BEQ $03 : JMP PHYSICS

		PEA PHYSICS-1

	; Crouch check

		LDA !P2Anim
		CMP #$07 : BCS .NoCrouch
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
		BNE .ProcessClimb

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
		LDA !IceLevel : BEQ +
		STZ !P2Climb
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
		LDA #$39 : STA !P2Anim
		STZ !P2AnimTimer
		LDA #$01 : STA !P2Climb
		STA !P2Direction

		.ProcessClimb
		PHP
		JSR CORE_NO_CLIMB
		STZ !P2DashTimerR2
		STZ !P2Dashing
		STZ !P2DashJump
		STZ !P2Floatiness
		STZ !P2SwordAttack
		STZ !P2SwordTimer
		STZ !P2SenkuUsed
		PLP
		BPL .Wall
		JMP .Ceiling

		.ClingLeft
		LDA #$39 : STA !P2Anim
		STZ !P2AnimTimer
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
		BRA ++
	+	LDX !P2Direction
		LDA .ClimbX,x : STA !P2XSpeed


		LDA !IceLevel : BEQ .done		; slide down on icy levels
		LDA !P2VectorY : BMI .drop
		CMP #$40 : BCS .time
	.drop	INC !P2VectorY
		INC !P2VectorY
	.time	LDA #$02
		CMP !P2VectorTimeY : BCC .done
		STA !P2VectorTimeY
		STZ !P2VectorAccY
		.done


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
		CMP #$34 : BNE .NoHoldOut
		LDA #$39 : STA !P2Anim
		BRA .NoHoldOut

		.HoldOut
		LDA #$34 : STA !P2Anim
		STZ !P2AnimTimer
		BRA .ClimbJump

		.NoHoldOut
		LDA !P2YSpeed
		BNE .ClimbJump
		STZ !P2AnimTimer
		BRA .ClimbJump

		.Ceiling
		LDA !P2Blocked
		LSR A : BCC +
		LDA #$08 : TRB !P2Blocked
		JMP .ClingRight
	+	LSR A : BCC ++
		LDA #$08 : TRB !P2Blocked
		JMP .ClingLeft
	++	JSR CheckAbove : BCC .Fall
		STZ !P2ClimbTop					; Clear getup
		LDA $6DA3
		AND #$03
		TAX
		LDA .Direction,x
		BMI $03 : STA !P2Direction
		LDA .XSpeed,x : STA !P2XSpeed
		BNE +
		LDA #$2F : STA !P2Anim
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
		STZ !P2ClimbTop
		LDX !P2Direction
		LDA .ClimbX+2,x : STA !P2XSpeed
		LDA .ClimbLock+2,x : STA !P2DashTimerL1
		STZ !P2VectorY
		STZ !P2VectorTimeY
		LDA #$10 : STA !P2DashTimerL2
		LDA #$20 : STA !P2Floatiness
		LDA #$C8 : STA !P2YSpeed
		LDA #$2B : STA !SPC1				; jump SFX
		BIT $6DA5 : BPL .Fall
		LDA #$01 : STA !P2DashJump

		.Fall
		BIT !P2Climb : BMI +
		LDA #$3D : STA !P2Anim
		STZ !P2AnimTimer
	+	STZ !P2Climb

		.EndClimb
		RTS

		.ClimbSlash
		LDA !P2ClimbTop : BNE .EndClimb			; No normal climb attacks during get-up
		LDA #$05
		BIT !P2Climb
		BPL .WallSlash

		.HangSlash
		INC A

		.WallSlash
		STA !P2SwordAttack
		LDA #$3D : STA !SPC4			; slash SFX
		RTS

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

		.NoClimb


		LDA !P2SwordAttack
		BEQ +
		CMP #$02 : BCS +
		RTS
		+

	; Dash check before ground check because air dash will be unlocked

		LDA !P2DashTimerR2
		ORA !P2SwordAttack
		BNE .NoDash
		BIT $6DA9 : BPL .NoDash
		LDA !P2Water				;\ No dashing from nets
		LSR A : BCS .NoDash			;/

		STZ !P2ClimbTop				; Clear getup when starting a dash
		LDA !P2Blocked
		AND #$04
		ORA !P2Platform
		BNE .GroundDash
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
		LDA #$20 : STA !P2Floatiness
		RTS
		.NoVineClimb

		LDA !P2Blocked
		AND #$04
		ORA !P2Platform
		BNE .Ground

		.Air
		LDA !P2DashTimerR2
		BNE +
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

		.Jump
		STZ !P2SwordAttack
		LDA #$20 : STA !P2Floatiness
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

		.ClimbX
		db $F0,$10
		db $10,$F0

		.ClimbLock
		db $0A,$09
		db $01,$02

		.WallAnim
		db $01,$02


	PHYSICS:

		LDA !P2ClimbTop : BEQ .NoGetUpAttack	;\
		BIT $6DA7 : BVC .NoGetUpAttack		; | Can buffer get-up attack
		LDA #$02 : STA !P2ClimbTop		;/
		.NoGetUpAttack



		LDA !P2SlantPipe
		BEQ +
		LDA #$40 : STA !P2XSpeed
		LDA #$C0 : STA !P2YSpeed
		+

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
		LDA !P2Floatiness
		ORA !P2Dashing
		ORA !P2SwordAttack
		BNE +
		BRA .NoForceCrouch

		.ForceCrouch
		LDA #$08 : STA !P2DashTimerR2

		.NoForceCrouch
		STZ !P2Floatiness
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


		LDA !P2Floatiness : BEQ +
		BIT $6DA3 : BMI ++
		STZ !P2Floatiness
		LDA !P2YSpeed
		BPL +
		EOR #$FF
		LSR A
		EOR #$FF
		STA !P2YSpeed
		BRA +
	++	LDA !P2Blocked
		AND #$08 : BEQ +
		STZ !P2Floatiness
		+

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
		RTS

		.Go
		JMP (.Ptr,x)

		.Return
		RTS

		.Ptr
		dw .Cut
		dw .Slash
		dw .DashSlash
		dw .AirSlash
		dw .WallSlash
		dw .HangSlash
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
		LDA #$07 : STA !P2Anim
		STZ !P2AnimTimer
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
		LDA !P2Anim
		CMP #$08 : BEQ +
		CMP #$09 : BEQ ++
		RTS
	++	LDA #$0C : JMP HITBOX
	+	LDA #$00 : JMP HITBOX

		..Bits
		db $02,$01

		.Slash
		LDA !P2SwordAttack : BMI ..Process
		ORA #$80 : STA !P2SwordAttack
		LDA #$0C : STA !P2Anim
		STZ !P2AnimTimer
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
		LDA !P2Anim
		CMP #$0C : BEQ +
		CMP #$0D : BEQ ++
		RTS
	++	LDA #$24 : JMP HITBOX
	+	LDA #$18 : JMP HITBOX

		.DashSlash
		LDA !P2SwordAttack : BMI ..Process
		ORA #$80 : STA !P2SwordAttack
		LDA #$13 : STA !P2Anim
		STZ !P2AnimTimer
		LDA #$1A : STA !P2SwordTimer
		..Process
		LDA !P2Anim
		CMP #$14 : BEQ +
		CMP #$15 : BEQ ++
		RTS
	++	LDA #$3C : JMP HITBOX
	+	LDA #$30 : JMP HITBOX

		.AirSlash
		LDA !P2SwordAttack : BMI ..Process
		ORA #$80 : STA !P2SwordAttack
		LDA #$2B : STA !P2Anim
		STZ !P2AnimTimer
		LDA #$20 : STA !P2SwordTimer
		..Process
		LDA !P2Anim
		CMP #$2C : BEQ +
		CMP #$2D : BEQ ++
		RTS
	++	LDA #$54 : JMP HITBOX
	+	LDA #$48 : JMP HITBOX

		.WallSlash
		LDA !P2SwordAttack : BMI ..Process
		ORA #$80 : STA !P2SwordAttack
		LDA #$35 : STA !P2Anim
		STZ !P2AnimTimer
		LDA #$1C : STA !P2SwordTimer
		..Process
		LDA !P2Direction
		EOR #$01
		TAX
		LDA CONTROLS_ClimbLock+2,x
		STA !P2DashTimerL1
		LDA #$03 : STA !P2DashTimerL2
		LDA CONTROLS_ClimbX+2,x : STA !P2XSpeed
		LDA !P2Anim
		CMP #$36 : BEQ +
		CMP #$37 : BEQ ++
		RTS
	++	LDA #$6C : JMP HITBOX
	+	LDA #$60 : JMP HITBOX

		.HangSlash
		LDA !P2SwordAttack : BMI ..Process
		ORA #$80 : STA !P2SwordAttack
		LDA #$30 : STA !P2Anim
		STZ !P2AnimTimer
		LDA #$16 : STA !P2SwordTimer
		..Process
		LDA !P2Anim
		CMP #$31 : BEQ +
		CMP #$32 : BEQ ++
		RTS
	++	LDA #$84 : JMP HITBOX
	+	LDA #$78 : JMP HITBOX


	SPRITE_INTERACTION:
		JSR CORE_SPRITE_INTERACTION


	EXSPRITE_INTERACTION:
		JSR CORE_EXSPRITE_INTERACTION


	UPDATE_SPEED:
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
		STZ !P2SwordAttack
		STZ !P2SwordTimer
		STZ !P2Dashing
		STZ !P2SenkuUsed
		STZ !P2DashJump
		STZ !P2Climb

		.End

		JSR CORE_CLIMB_GROUND

	SCREEN_BORDER:
		JSR CORE_SCREEN_BORDER

	ANIMATION:
		LDA !P2ExternalAnimTimer			;\
		BEQ .ClearExternal				; |
		DEC !P2ExternalAnimTimer			; | Enforce external animations
		LDA !P2ExternalAnim : STA !P2Anim		; |
		DEC !P2AnimTimer				; |
		JMP .HandleUpdate				;/

		.ClearExternal
		STZ !P2ExternalAnim

		LDA !P2HurtTimer
		BEQ .NoHurt
		LDA #$40 : STA !P2Anim
		JMP .HandleUpdate
		.NoHurt

		LDA !P2DashTimerR2
		BEQ $03 : JMP .Crouch


		LDA !P2ClimbTop : BEQ .NoGetUp
		LDA #$3D : STA !P2Anim
		LDA #$10 : STA !P2AnimTimer
		.NoGetUp

		LDA !P2Anim
		CMP #$3D
		BNE $03 : JMP .HandleUpdate

		LDA !P2SwordAttack
		BEQ $03
	-	JMP .HandleUpdate

		LDA !P2Climb
		BEQ .NoClimb
		BMI .Ceiling
		LDA !P2Anim
		CMP #$34 : BCC .Stick
		CMP #$3D : BCS .Stick
		BRA -
	.Stick	LDA #$34 : STA !P2Anim
		STZ !P2AnimTimer
		BRA -


		.Ceiling
		LDA !P2XSpeed
		BEQ -
		LDA !P2Anim
		CMP #$1E : BCC +
		CMP #$23 : BCS +
		JMP .HandleUpdate
	+	LDA #$1E : STA !P2Anim
		STZ !P2AnimTimer
		JMP .HandleUpdate
		.NoClimb


		LDA !P2Water
		LSR A
		BCC .NoVineClimb
		LDA !P2Anim
		CMP #$3E : BEQ +
		CMP #$3F : BEQ +
		LDA #$3E : STA !P2Anim
		STZ !P2AnimTimer
	+	LDA $6DA3
		AND #$0F
		BNE +
		STZ !P2AnimTimer
	+	JMP .HandleUpdate
		.NoVineClimb

		LDA !P2Dashing : BEQ .NoDash

		.Dash
		LDA !P2Anim
		CMP #$10 : BCC +
		CMP #$13 : BCS +
		JMP .HandleUpdate
	+	LDA #$10 : STA !P2Anim
		STZ !P2AnimTimer
		JMP .HandleUpdate

		.NoDash
		LDA !P2Blocked
		AND #$04
		ORA !P2Platform
		ORA !P2SpritePlatform
		BNE .Ground

		.Air
		BIT !P2YSpeed : BPL .Falling

		.Jump
		LDA #$18 : STA !P2Anim
		JMP .HandleUpdate

		.Falling
		LDA !P2Anim
		CMP #$19 : BEQ .HandleUpdate
		CMP #$1A : BEQ .HandleUpdate
		LDA #$19 : STA !P2Anim
		STZ !P2AnimTimer
		BRA .HandleUpdate

		.Ground
		BIT !P2Water : BPL .NoCrawl

		.Crouch
		LDA !P2XSpeed
		BNE .Crawl
		LDA !P2Anim
		CMP #$24 : BEQ .Crawl
		CMP #$25 : BEQ .Crawl
		DEC !P2AnimTimer

		.Crawl
		LDA !P2Anim
		CMP #$24 : BCC +
		CMP #$2A : BCC .HandleUpdate
	+	LDA #$24 : STA !P2Anim
		STZ !P2AnimTimer
		BRA .HandleUpdate

		.NoCrawl
		LDA !P2Anim
		CMP #$24 : BCC +
		CMP #$2A : BCS +
		LDA #$2A : STA !P2Anim
		STZ !P2AnimTimer
		BRA .HandleUpdate

	+	CMP #$2A : BEQ .HandleUpdate
		LDA !P2XSpeed
		BNE .Walk
		LDA !P2Anim
		CMP #$03 : BCC .HandleUpdate
		STZ !P2Anim
		STZ !P2AnimTimer
		BRA .HandleUpdate

		.Walk
		LDA !P2Anim
		CMP #$03 : BCC +
		CMP #$07 : BCC .HandleUpdate
	+	LDA #$03 : STA !P2Anim
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
		LDA ANIM+$04,y
		PHY
		JSR CORE_GENERATE_RAMCODE
		REP #$30
		PLY
		LDA SWORD+$00,y : STA $00		;\ Sword data in $00-$03
		LDA SWORD+$02,y : STA $02		;/


	GRAPHICS:
		LDA SWORD+$04,y				;\ Get priority setting
		STA $06					;/
		SEP #$30
		LDA !P2HurtTimer
		BNE .DrawTiles
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
		PLB
		RTS


; JSR-ables

	; Load index in A (8-bit)
	HITBOX:
		LDY !P2SwordTimer
		BNE .Process
		RTS

		.Process
		JSR CORE_ATTACK_Setup

		LDA !P2SwordAttack
		AND #$7F
		DEC A
		ASL A
		CLC : ADC !P2Direction
		ASL A
		STA $00
		ASL A
		CLC : ADC $00
		TAY
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
		LDA $3590,x
		AND #$08
		BEQ +
		LDA $35C0,x
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

		LDA $3590,x
		AND #$08
		BEQ .LoBlock

		.HiBlock
		LDY $35C0,x
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

	CUT:
	.0					; Start at sword coords + 1;4
	dw $FFED,$FFF6 : db $3F,$10		; Left
	dw $FFE4,$FFF6 : db $3F,$10		; Right
	.1					; Start at sword coords + 3;4
;	dw $FFFF,$FFF6 : db $2D,$10		; Left
;	dw $FFE4,$FFF6 : db $2D,$10		; Right

	SLASH:
	.0					; Start at sword coords + 3;-20 (sword, not lil' cut tile)
	dw $FFDE,$FFDE : db $30,$38		; Left
	dw $0002,$FFDE : db $30,$38		; Right
	.1					; Start at sword coords + 5;8
;	dw $FFEB,$000E : db $23,$08		; Left
;	dw $0002,$000E : db $23,$08		; Right

	DASHSLASH:
	.0					; Start at sword coords + 1;4
	dw $FFEC,$FFF4 : db $3F,$10		; Left
	dw $FFE5,$FFF4 : db $3F,$10		; Right
	.1					; Start at sword coords + 3;4
;	dw $FFFC,$FFF4 : db $2D,$10		; Left
;	dw $FFE7,$FFF4 : db $2D,$10		; Right

	AIRSLASH:
	.0					; Start at sword coords + 3;-20 (sword, not lil' cut tile)
	dw $FFF0,$FFDC : db $30,$40		; Left
	dw $0000,$FFDC : db $30,$40		; Right
	.1					; Start at sword coords + 5;8
;	dw $FFED,$000C : db $23,$08		; Left
;	dw $0000,$000C : db $23,$08		; Right

	WALLSLASH:
	.0					; Start at sword coords + 3;-20 (sword, not lil' cut tile)
	dw $0009,$FFDD : db $2D,$38		; Left
	dw $FFDA,$FFDD : db $2D,$38		; Right
	.1					; Start at sword coords + 5;8
;	dw $0009,$000D : db $23,$08		; Left
;	dw $FFE4,$000D : db $23,$08		; Right

	HANGSLASH:
	.0					; Start at sword coords + 3;0
	dw $FFD5,$FFFD : db $2D,$18		; Left
	dw $000E,$FFFD : db $2D,$18		; Right
	.1					; Start at sword coords + 5;8
;	dw $FFDF,$0010 : db $23,$08		; Left
;	dw $000E,$0010 : db $23,$08		; Right


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
		AND #$04
		BNE .Aggro
		CPY #$01
		BNE +
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
		LDA $35B0,x : BNE .Return
	+	LDA #$40 : STA $35B0,x
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


; Data

	ANIM:

	.Idle0				; 00
	dw .IdleTM : db $08,$01
	dw .IdleDynamo0
	dw .ClippingStandard
	.Idle1				; 01
	dw .IdleTM : db $08,$02
	dw .IdleDynamo1
	dw .ClippingStandard
	.Idle2				; 02
	dw .IdleTM : db $08,$00
	dw .IdleDynamo2
	dw .ClippingStandard

	.Walk0				; 03
	dw .32x32TM : db $06,$04
	dw .WalkDynamo0
	dw .ClippingStandard
	.Walk1				; 04
	dw .24x32TM : db $06,$05
	dw .WalkDynamo1
	dw .ClippingStandard
	.Walk2				; 05
	dw .32x32TM : db $06,$06
	dw .WalkDynamo2
	dw .ClippingStandard
	.Walk3				; 06
	dw .32x32TM : db $06,$03
	dw .WalkDynamo3
	dw .ClippingStandard

	.CutStart			; 07
	dw .24x32TM : db $06,$08
	dw .CutStartDynamo
	dw .ClippingStandard

	.Cut0				; 08
	dw .32x32TM : db $04,$09
	dw .CutDynamo0
	dw .ClippingStandard
	.Cut1				; 09
	dw .32x32TM : db $04,$0A
	dw .CutDynamo1
	dw .ClippingStandard
	.Cut2				; 0A
	dw .32x32TM : db $08,$0B
	dw .CutDynamo2
	dw .ClippingStandard
	.Cut3				; 0B
	dw .32x32TM : db $08,$00
	dw .CutDynamo3
	dw .ClippingStandard

	.Slash0				; 0C
	dw .32x32TM : db $04,$0D
	dw .SlashDynamo0
	dw .ClippingStandard
	.Slash1				; 0D
	dw .32x32TM : db $04,$0E
	dw .SlashDynamo1
	dw .ClippingStandard
	.Slash2				; 0E
	dw .32x32TM : db $08,$0F
	dw .SlashDynamo2
	dw .ClippingStandard
	.Slash3				; 0F
	dw .32x32TM : db $08,$00
	dw .SlashDynamo3
	dw .ClippingStandard

	.Dash0				; 10
	dw .32x32TM : db $06,$11
	dw .DashDynamo0
	dw .ClippingStandard
	.Dash1				; 11
	dw .32x32TM : db $06,$12
	dw .DashDynamo1
	dw .ClippingStandard
	.Dash2				; 12
	dw .32x32TM : db $06,$10
	dw .DashDynamo2
	dw .ClippingStandard

	.DashSlash0			; 13
	dw .32x32TM : db $06,$14
	dw .DashSlashDynamo0
	dw .ClippingStandard
	.DashSlash1			; 14
	dw .32x32TM : db $04,$15
	dw .DashSlashDynamo1
	dw .ClippingStandard
	.DashSlash2			; 15
	dw .32x32TM : db $04,$16
	dw .DashSlashDynamo2
	dw .ClippingStandard
	.DashSlash3			; 16
	dw .32x32TM : db $06,$17
	dw .DashSlashDynamo3
	dw .ClippingStandard
	.DashSlash4			; 17
	dw .32x32TM : db $06,$10
	dw .DashSlashDynamo4
	dw .ClippingStandard

	.Jump				; 18
	dw .24x32TM : db $FF,$18
	dw .JumpDynamo
	dw .ClippingStandard

	.Fall0				; 19
	dw .24x40TM : db $04,$1A
	dw .FallDynamo0
	dw .ClippingStandard
	.Fall1				; 1A
	dw .24x40TM : db $04,$19
	dw .FallDynamo1
	dw .ClippingStandard

	.SlowFall0			; 1B
	dw .24x32TM : db $06,$1C
	dw .SlowFallDynamo0
	dw .ClippingStandard
	.SlowFall1			; 1C
	dw .24x32TM : db $06,$1D
	dw .SlowFallDynamo1
	dw .ClippingStandard
	.SlowFall2			; 1D
	dw .24x32TM : db $06,$1B
	dw .SlowFallDynamo2
	dw .ClippingStandard

	.CeilingClimb0			; 1E
	dw .24x32TM : db $0A,$1F
	dw .CeilingClimbDynamo0
	dw .ClippingStandard
	.CeilingClimb1			; 1F
	dw .24x40TM : db $0A,$20
	dw .CeilingClimbDynamo1
	dw .ClippingStandard
	.CeilingClimb2			; 20
	dw .24x40TM : db $0A,$21
	dw .CeilingClimbDynamo2
	dw .ClippingStandard
	.CeilingClimb3			; 21
	dw .24x40TM : db $0A,$22
	dw .CeilingClimbDynamo3
	dw .ClippingStandard
	.CeilingClimb4			; 22
	dw .24x40TM : db $0A,$23
	dw .CeilingClimbDynamo4
	dw .ClippingStandard
	.CeilingClimb5			; 23
	dw .24x40TM : db $0A,$1E
	dw .CeilingClimbDynamo5
	dw .ClippingStandard

	.CrouchStart0			; 24
	dw .32x32TM : db $06,$25
	dw .CrouchStartDynamo0
	dw .ClippingStandard
	.CrouchStart1			; 25
	dw .32x24TM : db $06,$26
	dw .CrouchStartDynamo1
	dw .ClippingCrawl

	.Crawl0				; 26
	dw .32x24TM : db $06,$27
	dw .CrawlDynamo0
	dw .ClippingCrawl
	.Crawl1				; 27
	dw .40x16TM : db $06,$28
	dw .CrawlDynamo1
	dw .ClippingCrawl
	.Crawl2				; 28
	dw .32x24TM : db $06,$29
	dw .CrawlDynamo0
	dw .ClippingCrawl
	.Crawl3				; 29
	dw .32x16TM : db $06,$26
	dw .CrawlDynamo2
	dw .ClippingCrawl

	.CrouchEnd			; 2A
	dw .24x32TM : db $08,$00
	dw .CrouchEndDynamo
	dw .ClippingStandard

	.AirSlash0			; 2B
	dw .32x32TM : db $08,$2C
	dw .AirSlashDynamo0
	dw .ClippingStandard
	.AirSlash1			; 2C
	dw .32x32TM : db $04,$2D
	dw .AirSlashDynamo1
	dw .ClippingStandard
	.AirSlash2			; 2D
	dw .32x32TM : db $04,$2E
	dw .AirSlashDynamo2
	dw .ClippingStandard
	.AirSlash3			; 2E
	dw .32x32TM : db $10,$19
	dw .AirSlashDynamo3
	dw .ClippingStandard

	.Hang				; 2F
	dw .24x32TM : db $FF,$2F
	dw .HangDynamo
	dw .ClippingStandard

	.HangSlash0			; 30
	dw .24x40TM : db $06,$31
	dw .HangSlashDynamo0
	dw .ClippingStandard
	.HangSlash1			; 31
	dw .24x32TM : db $04,$32
	dw .HangSlashDynamo1
	dw .ClippingStandard
	.HangSlash2			; 32
	dw .24x32TM : db $04,$33
	dw .HangSlashDynamo2
	dw .ClippingStandard
	.HangSlash3			; 33
	dw .24x40TM : db $08,$2F
	dw .HangSlashDynamo3
	dw .ClippingStandard

	.WallCling			; 34
	dw .24x32TM : db $FF,$34
	dw .WallClingDynamo
	dw .ClippingStandard

	.WallSlash0			; 35
	dw .24x32TM : db $0A,$36
	dw .WallSlashDynamo0
	dw .ClippingStandard
	.WallSlash1			; 36
	dw .24x32TM : db $04,$37
	dw .WallSlashDynamo1
	dw .ClippingStandard
	.WallSlash2			; 37
	dw .24x32TM : db $04,$38
	dw .WallSlashDynamo2
	dw .ClippingStandard
	.WallSlash3			; 38
	dw .24x32TM : db $0A,$34
	dw .WallSlashDynamo3
	dw .ClippingStandard

	.WallClimb0			; 39
	dw .24x32TM : db $08,$3A
	dw .WallClimbDynamo0
	dw .ClippingWall
	.WallClimb1			; 3A
	dw .24x32TM : db $08,$3B
	dw .WallClimbDynamo1
	dw .ClippingWall
	.WallClimb2			; 3B
	dw .24x32TM : db $08,$3C
	dw .WallClimbDynamo2
	dw .ClippingWall
	.WallClimb3			; 3C
	dw .24x32TM : db $08,$39
	dw .WallClimbDynamo3
	dw .ClippingWall

	.ClimbTop			; 3D
	dw .32x32TM : db $12,$00
	dw .ClimbTopDynamo
	dw .ClippingStandard

	.ClimbBG0			; 3E
	dw .24x32TM : db $10,$3F
	dw .ClimbBGDynamo
	dw .ClippingStandard
	.ClimbBG1			; 3F
	dw .24x32ReverseTM : db $10,$3E
	dw .ClimbBGDynamo
	dw .ClippingStandard

	.Hurt				; 40
	dw .32x32TM : db $FF,$40
	dw .HurtDynamo
	dw .ClippingStandard

	.Dead				; 41
	dw .24x32TM : db $FF,$41
	dw .DeadDynamo
	dw .ClippingStandard

	.Victory0			; 42
	dw .24x32TM : db $14,$43
	dw .VictoryDynamo0
	dw .ClippingStandard
	.Victory1			; 43
	dw .24x32TM : db $14,$42
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

	.32x32TM
	dw $0010
	db $2E,$00,$F0,!P2Tile1
	db $2E,$10,$F0,!P2Tile2
	db $2E,$00,$00,!P2Tile3
	db $2E,$10,$00,!P2Tile4

	.24x32TM
	dw $0010
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


macro LeeDyn(TileCount, TileNumber, Dest)
	dw <TileCount>*$20
	dl <TileNumber>*$20+$358000
	dw <Dest>*$10+$6000
endmacro

macro SwdDyn(TileCount, TileNumber, Dest)
	dw <TileCount>*$20
	dl <TileNumber>*$20+$348008
	dw <Dest>*$10+$6000
endmacro


	.IdleDynamo0
	dw ..End-..Start
	..Start
	%LeeDyn(2, $000, !P2Tile1)
	%LeeDyn(2, $010, !P2Tile1+$10)
	%LeeDyn(3, $020, !P2Tile2)
	%LeeDyn(3, $030, !P2Tile2+$10)
	%SwdDyn(3, $008, !P2Tile5)
	%SwdDyn(3, $018, !P2Tile5+$10)
	..End
	.IdleDynamo1
	dw ..End-..Start
	..Start
	%LeeDyn(2, $000, !P2Tile1)
	%LeeDyn(2, $010, !P2Tile1+$10)
	%LeeDyn(3, $023, !P2Tile2)
	%LeeDyn(3, $033, !P2Tile2+$10)
	%SwdDyn(3, $008, !P2Tile5)
	%SwdDyn(3, $018, !P2Tile5+$10)
	..End
	.IdleDynamo2
	dw ..End-..Start
	..Start
	%LeeDyn(2, $000, !P2Tile1)
	%LeeDyn(2, $010, !P2Tile1+$10)
	%LeeDyn(3, $026, !P2Tile2)
	%LeeDyn(3, $036, !P2Tile2+$10)
	%SwdDyn(3, $008, !P2Tile5)
	%SwdDyn(3, $018, !P2Tile5+$10)
	..End

	.WalkDynamo0
	dw ..End-..Start
	..Start
	%LeeDyn(4, $040, !P2Tile1)
	%LeeDyn(4, $050, !P2Tile1+$10)
	%LeeDyn(4, $060, !P2Tile3)
	%LeeDyn(4, $070, !P2Tile3+$10)
	%SwdDyn(3, $008, !P2Tile5)
	%SwdDyn(3, $018, !P2Tile5+$10)
	..End
	.WalkDynamo1
	dw ..End-..Start
	..Start
	%LeeDyn(3, $044, !P2Tile1)
	%LeeDyn(3, $054, !P2Tile1+$10)
	%LeeDyn(3, $064, !P2Tile3)
	%LeeDyn(3, $074, !P2Tile3+$10)
	%SwdDyn(3, $028, !P2Tile5)
	%SwdDyn(3, $038, !P2Tile5+$10)
	..End
	.WalkDynamo2
	dw ..End-..Start
	..Start
	%LeeDyn(4, $047, !P2Tile1)
	%LeeDyn(4, $057, !P2Tile1+$10)
	%LeeDyn(4, $067, !P2Tile3)
	%LeeDyn(4, $077, !P2Tile3+$10)
	%SwdDyn(3, $028, !P2Tile5)
	%SwdDyn(3, $038, !P2Tile5+$10)
	..End
	.WalkDynamo3
	dw ..End-..Start
	..Start
	%LeeDyn(4, $04B, !P2Tile1)
	%LeeDyn(4, $05B, !P2Tile1+$10)
	%LeeDyn(4, $06B, !P2Tile3)
	%LeeDyn(4, $07B, !P2Tile3+$10)
	%SwdDyn(3, $008, !P2Tile5)
	%SwdDyn(3, $018, !P2Tile5+$10)
	..End

	.CutStartDynamo
	dw ..End-..Start
	..Start
	%LeeDyn(3, $00C, !P2Tile1)
	%LeeDyn(3, $01C, !P2Tile1+$10)
	%LeeDyn(3, $02C, !P2Tile3)
	%LeeDyn(3, $03C, !P2Tile3+$10)
	%SwdDyn(3, $008, !P2Tile5)
	%SwdDyn(3, $018, !P2Tile5+$10)
	..End

	.CutDynamo0
	dw ..End-..Start
	..Start
	%LeeDyn(4, $080, !P2Tile1)
	%LeeDyn(4, $090, !P2Tile1+$10)
	%LeeDyn(4, $0A0, !P2Tile3)
	%LeeDyn(4, $0B0, !P2Tile3+$10)
	%SwdDyn(8, $038, !P2Tile5)
	%SwdDyn(8, $048, !P2Tile5+$10)
	..End
	.CutDynamo1
	dw ..End-..Start
	..Start
	%LeeDyn(4, $084, !P2Tile1)
	%LeeDyn(4, $094, !P2Tile1+$10)
	%LeeDyn(4, $0A4, !P2Tile3)
	%LeeDyn(4, $0B4, !P2Tile3+$10)
	%SwdDyn(6, $057, !P2Tile5)
	%SwdDyn(6, $067, !P2Tile5+$10)
	..End
	.CutDynamo2
	dw ..End-..Start
	..Start
	%LeeDyn(4, $088, !P2Tile1)
	%LeeDyn(4, $098, !P2Tile1+$10)
	%LeeDyn(4, $0A8, !P2Tile3)
	%LeeDyn(4, $0B8, !P2Tile3+$10)
	%SwdDyn(3, $05D, !P2Tile6)
	%SwdDyn(3, $06D, !P2Tile6+$10)
	..End
	.CutDynamo3
	dw ..End-..Start
	..Start
	%LeeDyn(4, $08C, !P2Tile1)
	%LeeDyn(4, $09C, !P2Tile1+$10)
	%LeeDyn(4, $0AC, !P2Tile3)
	%LeeDyn(4, $0BC, !P2Tile3+$10)
	%SwdDyn(3, $05D, !P2Tile6)
	%SwdDyn(3, $06D, !P2Tile6+$10)
	..End

	.SlashDynamo0
	dw ..End-..Start
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
	dw ..End-..Start
	..Start
	%LeeDyn(4, $0C4, !P2Tile1)
	%LeeDyn(4, $0D4, !P2Tile1+$10)
	%LeeDyn(4, $0E4, !P2Tile3)
	%LeeDyn(4, $0F4, !P2Tile3+$10)
	%SwdDyn(5, $040, !P2Tile5)
	%SwdDyn(5, $050, !P2Tile5+$10)
	..End
	.SlashDynamo2
	dw ..End-..Start
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
	dw ..End-..Start
	..Start
	%LeeDyn(4, $0CC, !P2Tile1)
	%LeeDyn(4, $0DC, !P2Tile1+$10)
	%LeeDyn(4, $0EC, !P2Tile3)
	%LeeDyn(4, $0FC, !P2Tile3+$10)
	..End


	.DashDynamo0
	dw ..End-..Start
	..Start
	%LeeDyn(4, $100, !P2Tile1)
	%LeeDyn(4, $110, !P2Tile1+$10)
	%LeeDyn(4, $120, !P2Tile3)
	%LeeDyn(4, $130, !P2Tile3+$10)
	%SwdDyn(3, $008, !P2Tile5)
	%SwdDyn(3, $018, !P2Tile5+$10)
	..End
	.DashDynamo1
	dw ..End-..Start
	..Start
	%LeeDyn(4, $104, !P2Tile1)
	%LeeDyn(4, $114, !P2Tile1+$10)
	%LeeDyn(4, $124, !P2Tile3)
	%LeeDyn(4, $134, !P2Tile3+$10)
	%SwdDyn(3, $008, !P2Tile5)
	%SwdDyn(3, $018, !P2Tile5+$10)
	..End
	.DashDynamo2
	dw ..End-..Start
	..Start
	%LeeDyn(4, $108, !P2Tile1)
	%LeeDyn(4, $118, !P2Tile1+$10)
	%LeeDyn(4, $128, !P2Tile3)
	%LeeDyn(4, $138, !P2Tile3+$10)
	%SwdDyn(3, $008, !P2Tile5)
	%SwdDyn(3, $018, !P2Tile5+$10)
	..End
	.DashSlashDynamo0
	dw ..End-..Start
	..Start
	%LeeDyn(4, $10C, !P2Tile1)
	%LeeDyn(4, $11C, !P2Tile1+$10)
	%LeeDyn(4, $12C, !P2Tile3)
	%LeeDyn(4, $13C, !P2Tile3+$10)
	%SwdDyn(3, $008, !P2Tile5)
	%SwdDyn(3, $018, !P2Tile5+$10)
	..End
	.DashSlashDynamo1
	dw ..End-..Start
	..Start
	%LeeDyn(4, $140, !P2Tile1)
	%LeeDyn(4, $150, !P2Tile1+$10)
	%LeeDyn(4, $160, !P2Tile3)
	%LeeDyn(4, $170, !P2Tile3+$10)
	%SwdDyn(8, $038, !P2Tile5)
	%SwdDyn(8, $048, !P2Tile5+$10)
	..End
	.DashSlashDynamo2
	dw ..End-..Start
	..Start
	%LeeDyn(4, $144, !P2Tile1)
	%LeeDyn(4, $154, !P2Tile1+$10)
	%LeeDyn(4, $164, !P2Tile3)
	%LeeDyn(4, $174, !P2Tile3+$10)
	%SwdDyn(6, $057, !P2Tile5)
	%SwdDyn(6, $067, !P2Tile5+$10)
	..End
	.DashSlashDynamo3
	dw ..End-..Start
	..Start
	%LeeDyn(4, $148, !P2Tile1)
	%LeeDyn(4, $158, !P2Tile1+$10)
	%LeeDyn(4, $168, !P2Tile3)
	%LeeDyn(4, $178, !P2Tile3+$10)
	%SwdDyn(3, $05D, !P2Tile6)
	%SwdDyn(3, $06D, !P2Tile6+$10)
	..End
	.DashSlashDynamo4
	dw ..End-..Start
	..Start
	%LeeDyn(4, $14C, !P2Tile1)
	%LeeDyn(4, $15C, !P2Tile1+$10)
	%LeeDyn(4, $16C, !P2Tile3)
	%LeeDyn(4, $17C, !P2Tile3+$10)
	%SwdDyn(3, $05D, !P2Tile6)
	%SwdDyn(3, $06D, !P2Tile6+$10)
	..End

	.JumpDynamo
	dw ..End-..Start
	..Start
	%LeeDyn(3, $190, !P2Tile1)
	%LeeDyn(3, $1A0, !P2Tile1+$10)
	%LeeDyn(3, $1B0, !P2Tile3)
	%LeeDyn(3, $1C0, !P2Tile3+$10)
	%SwdDyn(3, $05D, !P2Tile6)
	%SwdDyn(3, $06D, !P2Tile6+$10)
	..End

	.FallDynamo0
	dw ..End-..Start
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
	dw ..End-..Start
	..Start
	%LeeDyn(3, $186, !P2Tile1)
	%LeeDyn(3, $196, !P2Tile1+$10)
	%LeeDyn(3, $1A6, !P2Tile2+$01)
	%LeeDyn(3, $1B6, !P2Tile2+$11)
	%LeeDyn(3, $1B6, !P2Tile4)
	%LeeDyn(3, $1C6, !P2Tile4+$10)
	..End

	.SlowFallDynamo0
	dw ..End-..Start
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
	dw ..End-..Start
	..Start
	%LeeDyn(3, $1E3, !P2Tile1)
	%LeeDyn(3, $1F3, !P2Tile1+$10)
	%LeeDyn(3, $203, !P2Tile3)
	%LeeDyn(3, $213, !P2Tile3+$10)
	..End
	.SlowFallDynamo2
	dw ..End-..Start
	..Start
	%LeeDyn(3, $1E6, !P2Tile1)
	%LeeDyn(3, $1F6, !P2Tile1+$10)
	%LeeDyn(3, $206, !P2Tile3)
	%LeeDyn(3, $216, !P2Tile3+$10)
	..End

	.CeilingClimbDynamo0
	dw ..End-..Start
	..Start
	%LeeDyn(3, $1CA, !P2Tile1)
	%LeeDyn(3, $1DA, !P2Tile1+$10)
	%LeeDyn(3, $1EA, !P2Tile3)
	%LeeDyn(3, $1FA, !P2Tile3+$10)
	..End
	.CeilingClimbDynamo1
	dw ..End-..Start
	..Start
	%LeeDyn(3, $1CD, !P2Tile1)
	%LeeDyn(3, $1DD, !P2Tile1+$10)
	%LeeDyn(3, $1ED, !P2Tile2+$01)
	%LeeDyn(3, $1FD, !P2Tile2+$11)
	%LeeDyn(3, $1FD, !P2Tile4)
	%LeeDyn(3, $20D, !P2Tile4+$10)
	..End
	.CeilingClimbDynamo2
	dw ..End-..Start
	..Start
	%LeeDyn(3, $21A, !P2Tile1)
	%LeeDyn(3, $22A, !P2Tile1+$10)
	%LeeDyn(3, $23A, !P2Tile2+$01)
	%LeeDyn(3, $24A, !P2Tile2+$11)
	%LeeDyn(3, $24A, !P2Tile4)
	%LeeDyn(3, $25A, !P2Tile4+$10)
	..End
	.CeilingClimbDynamo3
	dw ..End-..Start
	..Start
	%LeeDyn(3, $21D, !P2Tile1)
	%LeeDyn(3, $22D, !P2Tile1+$10)
	%LeeDyn(3, $23D, !P2Tile2+$01)
	%LeeDyn(3, $24D, !P2Tile2+$11)
	%LeeDyn(3, $24D, !P2Tile4)
	%LeeDyn(3, $25D, !P2Tile4+$10)
	..End
	.CeilingClimbDynamo4
	dw ..End-..Start
	..Start
	%LeeDyn(3, $26A, !P2Tile1)
	%LeeDyn(3, $27A, !P2Tile1+$10)
	%LeeDyn(3, $28A, !P2Tile2+$01)
	%LeeDyn(3, $29A, !P2Tile2+$11)
	%LeeDyn(3, $29A, !P2Tile4)
	%LeeDyn(3, $2AA, !P2Tile4+$10)
	..End
	.CeilingClimbDynamo5
	dw ..End-..Start
	..Start
	%LeeDyn(3, $26D, !P2Tile1)
	%LeeDyn(3, $27D, !P2Tile1+$10)
	%LeeDyn(3, $28D, !P2Tile2+$01)
	%LeeDyn(3, $29D, !P2Tile2+$11)
	%LeeDyn(3, $29D, !P2Tile4)
	%LeeDyn(3, $2AD, !P2Tile4+$10)
	..End

	.CrouchStartDynamo0
	dw ..End-..Start
	..Start
	%LeeDyn(4, $189, !P2Tile1)
	%LeeDyn(4, $199, !P2Tile1+$10)
	%LeeDyn(4, $1A9, !P2Tile3)
	%LeeDyn(4, $1B9, !P2Tile3+$10)
	%SwdDyn(3, $008, !P2Tile5)
	%SwdDyn(3, $018, !P2Tile5+$10)
	..End
	.CrouchStartDynamo1
	dw ..End-..Start
	..Start
	%LeeDyn(4, $265, !P2Tile1)
	%LeeDyn(4, $275, !P2Tile1+$10)
	%LeeDyn(4, $275, !P2Tile3)
	%LeeDyn(4, $285, !P2Tile3+$10)
	%SwdDyn(3, $028, !P2Tile5)
	%SwdDyn(3, $038, !P2Tile5+$10)
	..End
	.CrawlDynamo0
	dw ..End-..Start
	..Start
	%LeeDyn(4, $260, !P2Tile1)
	%LeeDyn(4, $270, !P2Tile1+$10)
	%LeeDyn(4, $270, !P2Tile3)
	%LeeDyn(4, $280, !P2Tile3+$10)
	..End
	.CrawlDynamo1
	dw ..End-..Start
	..Start
	%LeeDyn(5, $290, !P2Tile1)
	%LeeDyn(5, $2A0, !P2Tile1+$10)
	..End
	.CrawlDynamo2
	dw ..End-..Start
	..Start
	%LeeDyn(4, $295, !P2Tile1)
	%LeeDyn(4, $2A5, !P2Tile1+$10)
	..End
	.CrouchEndDynamo
	dw ..End-..Start
	..Start
	%LeeDyn(3, $18D, !P2Tile1)
	%LeeDyn(3, $19D, !P2Tile1+$10)
	%LeeDyn(3, $1AD, !P2Tile3)
	%LeeDyn(3, $1BD, !P2Tile3+$10)
	..End

	.AirSlashDynamo0
	dw ..End-..Start
	..Start
	%LeeDyn(4, $3C7, !P2Tile1)
	%LeeDyn(4, $3D7, !P2Tile1+$10)
	%LeeDyn(4, $3E7, !P2Tile3)
	%LeeDyn(4, $3F7, !P2Tile3+$10)
	%SwdDyn(3, $008, !P2Tile5)
	%SwdDyn(3, $018, !P2Tile5+$10)
	..End
	.AirSlashDynamo1
	dw ..End-..Start
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
	dw ..End-..Start
	..Start
	%LeeDyn(4, $224, !P2Tile1)
	%LeeDyn(4, $234, !P2Tile1+$10)
	%LeeDyn(4, $244, !P2Tile3)
	%LeeDyn(4, $254, !P2Tile3+$10)
	%SwdDyn(5, $040, !P2Tile5)
	%SwdDyn(5, $050, !P2Tile5+$10)
	..End
	.AirSlashDynamo3
	dw ..End-..Start
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
	dw ..End-..Start
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
	dw ..End-..Start
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
	dw ..End-..Start
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
	dw ..End-..Start
	..Start
	%LeeDyn(3, $2B9, !P2Tile1)
	%LeeDyn(3, $2C9, !P2Tile1+$10)
	%LeeDyn(3, $2D9, !P2Tile3)
	%LeeDyn(3, $2E9, !P2Tile3+$10)
	%SwdDyn(5, $040, !P2Tile5)
	%SwdDyn(5, $050, !P2Tile5+$10)
	..End
	.HangSlashDynamo3
	dw ..End-..Start
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
	dw ..End-..Start
	..Start
	%LeeDyn(3, $300, !P2Tile1)
	%LeeDyn(3, $310, !P2Tile1+$10)
	%LeeDyn(3, $320, !P2Tile3)
	%LeeDyn(3, $330, !P2Tile3+$10)
	%SwdDyn(3, $028, !P2Tile5)
	%SwdDyn(3, $038, !P2Tile5+$10)
	..End

	.WallSlashDynamo0
	dw ..End-..Start
	..Start
	%LeeDyn(3, $303, !P2Tile1)
	%LeeDyn(3, $313, !P2Tile1+$10)
	%LeeDyn(3, $323, !P2Tile3)
	%LeeDyn(3, $333, !P2Tile3+$10)
	%SwdDyn(3, $05D, !P2Tile6)
	%SwdDyn(3, $06D, !P2Tile6+$10)
	..End
	.WallSlashDynamo1
	dw ..End-..Start
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
	dw ..End-..Start
	..Start
	%LeeDyn(3, $309, !P2Tile1)
	%LeeDyn(3, $319, !P2Tile1+$10)
	%LeeDyn(3, $329, !P2Tile3)
	%LeeDyn(3, $339, !P2Tile3+$10)
	%SwdDyn(5, $040, !P2Tile5)
	%SwdDyn(5, $050, !P2Tile5+$10)
	..End
	.WallSlashDynamo3
	dw ..End-..Start
	..Start
	%SwdDyn(2, $00C, !P2Tile7)
	%SwdDyn(2, $01C, !P2Tile7+$10)
	%SwdDyn(2, $01B, !P2Tile8)
	%SwdDyn(2, $02B, !P2Tile8+$10)
	..End

	.WallClimbDynamo0
	dw ..End-..Start
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
	dw ..End-..Start
	..Start
	%LeeDyn(3, $343, !P2Tile1)
	%LeeDyn(3, $353, !P2Tile1+$10)
	%LeeDyn(3, $363, !P2Tile3)
	%LeeDyn(3, $373, !P2Tile3+$10)
	..End
	.WallClimbDynamo2
	dw ..End-..Start
	..Start
	%LeeDyn(3, $346, !P2Tile1)
	%LeeDyn(3, $356, !P2Tile1+$10)
	%LeeDyn(3, $366, !P2Tile3)
	%LeeDyn(3, $376, !P2Tile3+$10)
	..End
	.WallClimbDynamo3
	dw ..End-..Start
	..Start
	%LeeDyn(3, $349, !P2Tile1)
	%LeeDyn(3, $359, !P2Tile1+$10)
	%LeeDyn(3, $369, !P2Tile3)
	%LeeDyn(3, $379, !P2Tile3+$10)
	..End

	.ClimbTopDynamo
	dw ..End-..Start
	..Start
	%LeeDyn(4, $387, !P2Tile1)
	%LeeDyn(4, $397, !P2Tile1+$10)
	%LeeDyn(4, $3A7, !P2Tile3)
	%LeeDyn(4, $3B7, !P2Tile3+$10)
	%SwdDyn(3, $008, !P2Tile5)
	%SwdDyn(3, $018, !P2Tile5+$10)
	..End

	.ClimbBGDynamo
	dw ..End-..Start
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
	dw ..End-..Start
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
	dw ..End-..Start
	..Start
	%LeeDyn(3, $390, !P2Tile1)
	%LeeDyn(3, $3A0, !P2Tile1+$10)
	%LeeDyn(3, $3B0, !P2Tile3)
	%LeeDyn(3, $3C0, !P2Tile3+$10)
	%SwdDyn(3, $05D, !P2Tile6)
	%SwdDyn(3, $06D, !P2Tile6+$10)
	..End

	.VictoryDynamo0
	dw ..End-..Start
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
	dw ..End-..Start
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


	.ClippingStandard
	db $0D,$02,$05,$05		; < X offset
	db $FF,$FF,$10,$F4		; < Y offset
	db $10,$10,$05,$05		; < Size

	.ClippingCrawl
	db $0D,$02,$05,$05		; < X offset
	db $05,$05,$10,$00		; < Y offset
	db $0A,$0A,$05,$05		; < Size

	.ClippingWall
	db $0D,$02,$05,$05		; < X offset
	db $FF,$FF,$10,$F4		; < Y offset
	db $04,$04,$05,$05		; < Size



	SWORD:

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


	.HorzTM
	dw $0008
	db $2E,$00,$00,!P2Tile5
	db $2E,$08,$00,!P2Tile5+$01

	.DiaTM
	dw $0008
	db $2E,$00,$00,!P2Tile7
	db $2E,$F8,$08,!P2Tile8

	.PrepTM
	dw $0008
	db $6E,$00,$00,!P2Tile5
	db $6E,$08,$00,!P2Tile5+$01

	.CutTM0
	dw $0010
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


	.SmallSlashTM
	dw $0010
	db $2E,$00,$00,!P2Tile5
	db $2E,$08,$08,!P2Tile6
	db $2E,$18,$08,!P2Tile7
	db $2E,$20,$08,!P2Tile7+$01
	.SlashTM0
	dw $0018
	db $2E,$00,$00,!P2Tile5
	db $2E,$08,$08,!P2Tile6
	db $2E,$18,$08,!P2Tile7
	db $2E,$20,$08,!P2Tile7+$01
	db $2E,$08,$E8,$8C
	db $2E,$18,$E8,$8E
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
	dw $0018
	db $6E,$00,$00,!P2Tile5
	db $6E,$08,$08,!P2Tile6
	db $6E,$18,$08,!P2Tile7
	db $6E,$20,$08,!P2Tile7+$01
	db $6E,$08,$E8,$8C
	db $6E,$18,$E8,$8E
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

	.NoTM
	dw $0000


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












