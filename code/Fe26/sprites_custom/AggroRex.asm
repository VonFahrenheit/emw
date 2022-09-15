

	!Temp = 0
	%def_anim(AggroRex_Idle, 1)
	%def_anim(AggroRex_Lookout, 1)
	%def_anim(AggroRex_Scratch, 2)
	%def_anim(AggroRex_Walk, 4)
	%def_anim(AggroRex_Roar, 3)
	%def_anim(AggroRex_Run, 8)
	%def_anim(AggroRex_Jump, 1)
	%def_anim(AggroRex_Climb, 3)
	%def_anim(AggroRex_Hurt, 1)

	!AggroRexChase		= $3400
	!AggroRexIFrames	= $3410
	!AggroRexPrevFrame	= $3420
	!AggroRexWall		= $3430
	!AggroRexStunTimer	= $3440
	!AggroRexIdleTimer	= $3450
	!AggroRexTargetPlayer	= $3460




AggroRex:

	namespace AggroRex



	INIT:
		LDA !ExtraBits,x					;\
		AND #$04 : BEQ +					; |
		LDA !SpriteXLo,x					; | X+8 with ambush
		ORA #$08 : STA !SpriteXLo,x				; |
		+							;/
		LDA #$FF : STA !AggroRexPrevFrame,x			; reload GFX
		LDA #$03 : JSL GET_SQUARE : BCS .Return			;\ get 4 squares or despawn
		STZ !SpriteStatus,x					;/

		.Return
		RTL							; return


	MAIN:
		PHB : PHK : PLB

		%decreg(!AggroRexIFrames)
		%decreg(!AggroRexStunTimer)

		LDA !SpriteStatus,x
		CMP #$08 : BEQ PHYSICS
		CMP #$02 : BNE .Return

		.Dead
		LDA #!AggroRex_Hurt : STA !SpriteAnimIndex,x
		STZ !AggroRexIFrames,x
		JMP GRAPHICS_HandleUpdate

		.Return
		PLB
		RTL


	PHYSICS:
		LDA !SpriteHP,x						;\
		CMP #$03 : BCC .NotDead					; |
		LDA #$02 : STA !SpriteStatus,x				; |
		LDA !SpriteXSpeed,x					; |
		ROL #2							; |
		AND #$01						; |
		TAY							; |
		LDA DATA_XSpeed,y					; | death code
		BPL $03 : EOR #$FF : INC A				; |
		STA $00							; |
		LDA !SpriteXSpeed,x					; |
		BPL $03 : EOR #$FF : INC A				; |
		CMP $00 : BCS MAIN_Dead					; |
		LDA DATA_XSpeed,y : STA !SpriteXSpeed,x			; |
		BRA MAIN_Dead						; |
		.NotDead						;/


		LDA !SpriteAnimIndex,x					;\
		CMP #!AggroRex_Climb : BNE .NotHolding			; | stasis during this frame
		LDA #$02 : STA !SpriteStasis,x				; |
		.NotHolding						;/

		STZ !AggroRexWall,x					; clear wall at start of physics


		.Alert							;\
		LDA !AggroRexChase,x : BEQ ..checkchase			; | use sight box if not chasing
		JMP ..nochase						; |
		..checkchase						;/
		LDA !ExtraBits,x					;\
		AND #$04 : BEQ ..notwaiting				; |
		JSL SUB_HORZ_POS					; | face player while in ambush mode
		TYA : STA !SpriteDir,x					; |
		..notwaiting						;/
		LDA !ExtraBits,x					;\
		AND #$04 : BEQ ..longsight				; |
		..shortsight						; |
		LDA #$18 : BRA +					; | sight box
		..longsight						; |
		LDA #$1A						; |
	+	CLC : ADC !SpriteDir,x					; |
		JSL GetSpriteClippingE8_A				;/
		JSL PlayerContact : BCC ..nochase			; check contact
		TAY							;\
		LDA DATA_TargetPlayer,y : STA !AggroRexTargetPlayer,x	; | target player
		TAY							;/
		JSL SUB_HORZ_POS_Target					;\ face target
		TYA : STA !SpriteDir,x					;/
		LDA #$25 : STA !SPC1					; roar SFX
		LDA #$01 : STA !AggroRexChase,x				; start chase
		LDA !ExtraBits,x					;\
		AND #$04 : BEQ ..nojump					; |
		..jump							; |
		LDA !ExtraBits,x					; |
		AND #$04^$FF						; |
		STA !ExtraBits,x					; |
		STZ !SpriteBlocked,x					; |
		LDA !Difficulty						; | ambush mode: jump upon detecting a player
		ASL A							; |
		ADC !SpriteDir,x					; |
		TAY							; |
		LDA DATA_XSpeed+2,y : STA !SpriteXSpeed,x		; |
		LDA #$D0 : STA !SpriteYSpeed,x				; |
		BRA ..nochase						;/
		..nojump						;\
		LDA #!AggroRex_Roar : STA !SpriteAnimIndex,x		; |
		STZ !SpriteAnimTimer,x					; | normal mode: roar animation upon detecting a player
		LDA #$20 : STA !AggroRexStunTimer,x			; |
		STZ !SpriteXSpeed,x					; |
		..nochase						;/


		.Speed							;\
		LDA !SpriteBlocked,x					; |
		BIT #$04 : BNE ..ground					; | different speed codes depending on ground/air
		..air							; |
		AND #$08 : BEQ ..nobonk
		STA !SpriteYSpeed,x					; > bonk code 
		..nobonk
		JMP ..nospeed						; |
		..ground						;/
		JSL GroundSpeed						; Y speed on ground
		LDA !AggroRexStunTimer,x : BNE ..nochase		;\
		LDA !SpriteAnimIndex,x					; |
		CMP #!AggroRex_Hurt : BEQ ..nochase			; |
		LDA !AggroRexChase,x : BEQ ..nochase			; |
		LDY !AggroRexTargetPlayer,x				; |
		LDA #$C0 : JSL SUB_VERT_POS_Target			; |
		CPY #$01 : BEQ ..forward				; > don't turn on ground if target is more than 64px above
		LDA #$20 : JSL SUB_VERT_POS_Target			; |
		CPY #$00 : BEQ ..forward				; > ...or 32px below
		LDA #$80 : STA !SpriteTweaker6,x			; > can jump at ledges
		LDY !AggroRexTargetPlayer,x				; |
		JSL SUB_HORZ_POS_Target					; |
		TYA : STA !SpriteDir,x					; |
		..forward						; |
		LDA !Difficulty						; | acceleration for chase
		ASL A							; |
		ADC !SpriteDir,x					; |
		TAY							; |
		LDA DATA_XSpeed+2,y : JSL AccelerateX			; |
		STZ !SpriteTweaker6,x					; > can't jump at ledges
		BRA ..nospeed						; |
		..nochase						;/
		LDA !SpriteAnimIndex,x					;\
		CMP #!AggroRex_Hurt : BNE ..noslide			; |
		LDA !SpriteXSpeed,x					; |
		CLC : ADC #$08						; |
		CMP #$10 : BCC ..friction				; |
		LDA $14							; |
		AND #$03 : BNE ..friction				; |
		LDA !SpriteXSpeed,x					; |
		ROL #2							; | friction + smoke while hurt on ground
		AND #$01						; |
		TAY							; |
		LDA DATA_DustOffset,y : STA $00				; |
		LDA #$0C : STA $01					; |
		LDA.b #!prt_smoke8x8 : JSL SpawnParticle_NoSpeedAcc	; |
		..friction						; |
		JSL AccelerateX_Friction1				; |
		..noslide						;/
		LDA !AggroRexChase,x : BNE ..nospeed			; return if chasing
		LDA !AggroRexStunTimer,x : BNE ..nospeed		; return if stunned
		LDA !ExtraBits,x					;\ return if still in ambush mode
		AND #$04 : BNE ..nospeed				;/
		LDY !SpriteDir,x					;\
		LDA DATA_XSpeed,y : STA !SpriteXSpeed,x			; | walk speed
		..nospeed						;/



		JSL APPLY_SPEED						; apply speed

		LDA !SpriteYSpeed,x					;\
		CMP #$C0 : BNE ..nojump					; |
		LDY !AggroRexTargetPlayer,x				; |
		JSL SUB_HORZ_POS_Target					; |
		TYA : STA !SpriteDir,x					; |
		LDA !Difficulty						; | gain full X speed upon jumping
		ASL A							; |
		ADC !SpriteDir,x					; |
		TAY							; |
		LDA DATA_XSpeed+2,y : STA !SpriteXSpeed,x		; |
		..nojump						;/

		LDA !AggroRexStunTimer,x : BNE ..done			; no climb when stunned
		LDA !AggroRexChase,x : BEQ ..done			; no climb when idle
		..checkclimb						;\
		LDA !SpriteDir,x					; | check for climb when chasing
		INC A							; |
		AND !SpriteBlocked,x : BEQ ..done			;/
		..climb							;\
		LDA !SpriteBlocked,x					; |
		AND #$08 : BEQ ..noceiling				; | special wall jump when hitting ceiling
		STZ !SpriteYSpeed,x					; |
		BRA ..walljump						; |
		..noceiling						; |
		LDY !AggroRexTargetPlayer,x				; |
		JSL SUB_HORZ_POS_Target					; |
		TYA : CMP !SpriteDir,x : BEQ ..nowalljump		; |
		LDY !AggroRexTargetPlayer,x				; |
		LDA #$F0 : JSL SUB_VERT_POS_Target			; | wall jump if target is 16px above or more
		CPY #$01 : BEQ ..nowalljump				; | (and away from wall)
		LDA #$D0 : STA !SpriteYSpeed,x				; |
		..walljump						; |
		LDY !SpriteDir,x					; |
		LDA DATA_WallJumpSpeed,y : STA !SpriteXSpeed,x		; |
		TYA							; |
		EOR #$01 : STA !SpriteDir,x				; |
		BRA ..done						; |
		..nowalljump						;/
		LDA #$01 : STA !AggroRexWall,x				;\
		LDY !SpriteDir,x					; |
		LDA DATA_WallXSpeed,y : STA !SpriteXSpeed,x		; |
		LDA #$E0 : STA !SpriteYSpeed,x				; | set climb status and clear ground flag
		LDA !SpriteBlocked,x					; |
		AND #$04^$FF : STA !SpriteBlocked,x			; |
		..done							;/





	INTERACTION:
		JSL GetSpriteClippingE8					; get sprite body hitbox


		.Attacks
		LDA !AggroRexIFrames,x : BNE .Body
		JSL InteractAttacks : BCS .HurtSprite

		.Body
		LDA #$04 : STA !dmg
		JSL P2Standard : BEQ .Done
		..stomp
		LDA !AggroRexIFrames,x : BEQ .HurtSprite
		..deflect
		LDA #$02 : STA !SPC1
		BRA .Done

		.HurtSprite
		LDA !SpriteStatus,x
		CMP #$04 : BNE ..main
		PLB
		RTL
		..main
		STZ !SpriteYSpeed,x
		LDA !ExtraBits,x					;\ clear extra bit
		AND.b #$04^$FF : STA !ExtraBits,x			;/
		LDA #$20 : STA !AggroRexStunTimer,x			; stun
		LDY !Difficulty						;\ i-frames depend on difficulty
		LDA DATA_IFrames,y : STA !AggroRexIFrames,x		;/
		LDA #!AggroRex_Hurt : STA !SpriteAnimIndex,x		;\ update anim
		STZ !SpriteAnimTimer,x					;/
		INC !SpriteHP,x						; +1 damage taken
		INC !AggroRexChase,x					; make sure rex is chasing

		.Done






	GRAPHICS:

		LDA !AggroRexStunTimer,x : BNE ++

	; wall check
		LDA !AggroRexWall,x : BEQ .NoWall
		LDA !SpriteAnimIndex,x
		CMP #!AggroRex_Climb : BCC +
		CMP #!AggroRex_Climb_over : BCC ++
	+	LDA #!AggroRex_Climb : STA !SpriteAnimIndex,x
		STZ !SpriteAnimTimer,x
	++	JMP .HandleUpdate
		.NoWall

	; air check
		LDA !SpriteBlocked,x
		AND #$04 : BNE .NoJump
		LDA #!AggroRex_Jump : STA !SpriteAnimIndex,x
		STZ !SpriteAnimTimer,x
		BRA .HandleUpdate
		.NoJump

	; start walk check
		LDA !ExtraBits,x
		AND #$04 : BNE .NoWalk
		LDA !SpriteAnimIndex,x
		CMP #!AggroRex_Walk : BCS .NotIdle
		LDA #!AggroRex_Walk : STA !SpriteAnimIndex,x
		STZ !SpriteAnimTimer,x
		BRA .HandleUpdate
		.NoWalk

	; idle anims check
		INC !AggroRexIdleTimer,x
		LDA !AggroRexIdleTimer,x
		AND #$3F : BNE .NotRandomIdle
		LDA #!AggroRex_Idle
		BIT !RNGtable,x : BVC ++
		LDA #!AggroRex_Lookout
		BIT !RNGtable,x
		BPL $02 : LDA #!AggroRex_Scratch
		STA !SpriteAnimIndex,x
		STZ !SpriteAnimTimer,x
		.NotRandomIdle
		LDA !SpriteAnimIndex,x
		CMP #!AggroRex_Lookout : BEQ +
		CMP #!AggroRex_Scratch : BEQ +
		CMP #!AggroRex_Scratch+1 : BEQ +
		LDA #!AggroRex_Idle
	++	STA !SpriteAnimIndex,x
	+	BRA .HandleUpdate
		.NotIdle

	; run check
		LDA !AggroRexChase,x : BEQ .NoChase
		LDA !SpriteAnimIndex,x
		CMP #!AggroRex_Run : BCC +
		CMP #!AggroRex_Run_over : BCC .HandleUpdate
	+	LDA #!AggroRex_Run : STA !SpriteAnimIndex,x
		STZ !SpriteAnimTimer,x
		BRA .HandleUpdate
		.NoChase

	; walk check
		LDA !SpriteAnimIndex,x
		CMP #!AggroRex_Walk : BCC +
		CMP #!AggroRex_Walk_over : BCC .HandleUpdate
	+	LDA #!AggroRex_Walk : STA !SpriteAnimIndex,x
		STZ !SpriteAnimTimer,x



	; standard update code (6-byte table, smoke + SFX on footsteps)
		.HandleUpdate
		LDA !SpriteAnimIndex,x : STA $00
		ASL A
		ADC $00
		ASL A
		TAY
		LDA !SpriteAnimTimer,x
		INC A
		CMP.w ANIM+4,y : BNE .SameAnim
		.NewAnim
		LDA.w ANIM+5,y : STA !SpriteAnimIndex,x
		STA $00
		ASL A
		ADC $00
		ASL A
		TAY
		LDA !SpriteAnimIndex,x
		CMP #!AggroRex_Climb+1 : BNE +
		PHY
		LDY !SpriteDir,x
		LDA DATA_SmokeX,y : STA $00
		LDA #$F8
		BRA ++

	+	CMP #!AggroRex_Run+0 : BEQ ..smoke
		CMP #!AggroRex_Run+4 : BNE ..nosmoke
		..smoke
		LDA #$01 : STA !SPC1
		PHY
		LDY !SpriteDir,x
		LDA DATA_DustOffset,y : STA $00
		LDA #$0C
	++	STA $01
		LDA.b #!prt_smoke8x8 : JSL SpawnParticle_NoSpeedAcc
		PLY
		..nosmoke
		LDA #$00
		.SameAnim
		STA !SpriteAnimTimer,x


		REP #$20
		LDA.w ANIM+0,y : STA $04
		LDA.w ANIM+2,y : STA $0C
		SEP #$20
		LDA !SpriteAnimIndex,x
		CMP !AggroRexPrevFrame,x
		STA !AggroRexPrevFrame,x
		BEQ .NoDynamo

		LDY #!File_AggroRex : JSL LOAD_SQUARE_DYNAMO
		.NoDynamo

		LDA !AggroRexStunTimer,x : BNE .Draw
		LDA !AggroRexIFrames,x
		AND #$02 : BNE .Return

		.Draw
		JSL SETUP_SQUARE
		JSL LOAD_DYNAMIC

		.Return
		PLB
		RTL


	ANIM:
	; idle
		dw .TM32,.IdleDyn00 : db $FF,!AggroRex_Idle
	; lookout
		dw .TM32,.LookoutDyn00 : db $C0,!AggroRex_Idle
	; scratch
		dw .TM32,.ScratchDyn00 : db $08,!AggroRex_Scratch+1
		dw .TM32,.ScratchDyn01 : db $08,!AggroRex_Scratch+0
	; walk
		dw .TM32,.WalkDyn00 : db $10,!AggroRex_Walk+1
		dw .TM32U1,.WalkDyn01 : db $10,!AggroRex_Walk+2
		dw .TM32,.WalkDyn00 : db $10,!AggroRex_Walk+3
		dw .TM32U1,.WalkDyn02 : db $10,!AggroRex_Walk+0
	; roar
		dw .TM32,.RoarDyn00 : db $08,!AggroRex_Roar+1
		dw .TM32X2,.RoarDyn01 : db $10,!AggroRex_Roar+2
		dw .TM32,.RoarDyn00 : db $08,!AggroRex_Run+1
	; run
		dw .TM32,.RunDyn00 : db $05,!AggroRex_Run+1
		dw .TM32U1,.RunDyn01 : db $05,!AggroRex_Run+2
		dw .TM32U2,.RunDyn02 : db $05,!AggroRex_Run+3
		dw .TM32U1,.RunDyn01 : db $05,!AggroRex_Run+4
		dw .TM32,.RunDyn00 : db $05,!AggroRex_Run+5
		dw .TM32U1,.RunDyn03 : db $05,!AggroRex_Run+6
		dw .TM32U2,.RunDyn04 : db $05,!AggroRex_Run+7
		dw .TM32U1,.RunDyn03 : db $05,!AggroRex_Run+0
	; jump
		dw .TM32,.JumpDyn00 : db $FF,!AggroRex_Jump
	; climb
		dw .TM32X,.ClimbDyn00 : db $08,!AggroRex_Climb+1
		dw .TM32X,.ClimbDyn01 : db $08,!AggroRex_Climb+2
		dw .TM32X,.ClimbDyn02 : db $08,!AggroRex_Climb+0
	; hurt
		dw .TM32,.HurtDyn00 : db $FF,!AggroRex_Hurt


	.TM32X
		dw $0010
		db $22,$00,$F0,$00
		db $22,$10,$F0,$01
		db $22,$00,$00,$02
		db $22,$10,$00,$03
	.TM32X2
		dw $0010
		db $22,$F0,$F0,$00
		db $22,$00,$F0,$01
		db $22,$F0,$00,$02
		db $22,$00,$00,$03
	.TM32
		dw $0010
		db $22,$F8,$F0,$00
		db $22,$08,$F0,$01
		db $22,$F8,$00,$02
		db $22,$08,$00,$03
	.TM32U1
		dw $0010
		db $22,$F8,$EF,$00
		db $22,$08,$EF,$01
		db $22,$F8,$FF,$02
		db $22,$08,$FF,$03
	.TM32U2
		dw $0010
		db $22,$F8,$EE,$00
		db $22,$08,$EE,$01
		db $22,$F8,$FE,$02
		db $22,$08,$FE,$03


	.WalkDyn00
	.IdleDyn00
		dw ..end-..start
		..start
		%SquareDyn($000)
		%SquareDyn($002)
		%SquareDyn($020)
		%SquareDyn($022)
		..end
	.LookoutDyn00
		dw ..end-..start
		..start
		%SquareDyn($004)
		%SquareDyn($006)
		%SquareDyn($024)
		%SquareDyn($026)
		..end
	.ScratchDyn00
		dw ..end-..start
		..start
		%SquareDyn($008)
		%SquareDyn($00A)
		%SquareDyn($028)
		%SquareDyn($02A)
		..end
	.ScratchDyn01
		dw ..end-..start
		..start
		%SquareDyn($00C)
		%SquareDyn($00E)
		%SquareDyn($02C)
		%SquareDyn($02E)
		..end
	.WalkDyn01
		dw ..end-..start
		..start
		%SquareDyn($040)
		%SquareDyn($042)
		%SquareDyn($060)
		%SquareDyn($062)
		..end
	.WalkDyn02
		dw ..end-..start
		..start
		%SquareDyn($044)
		%SquareDyn($046)
		%SquareDyn($064)
		%SquareDyn($066)
		..end
	.RoarDyn01
		dw ..end-..start
		..start
		%SquareDyn($048)
		%SquareDyn($04A)
		%SquareDyn($068)
		%SquareDyn($06A)
		..end
	.RoarDyn00
	.RunDyn00
		dw ..end-..start
		..start
		%SquareDyn($080)
		%SquareDyn($082)
		%SquareDyn($0A0)
		%SquareDyn($0A2)
		..end
	.RunDyn01
		dw ..end-..start
		..start
		%SquareDyn($084)
		%SquareDyn($086)
		%SquareDyn($0A4)
		%SquareDyn($0A6)
		..end
	.JumpDyn00
	.RunDyn02
		dw ..end-..start
		..start
		%SquareDyn($088)
		%SquareDyn($08A)
		%SquareDyn($0A8)
		%SquareDyn($0AA)
		..end
	.RunDyn03
		dw ..end-..start
		..start
		%SquareDyn($08C)
		%SquareDyn($08E)
		%SquareDyn($0AC)
		%SquareDyn($0AE)
		..end
	.RunDyn04
		dw ..end-..start
		..start
		%SquareDyn($0C0)
		%SquareDyn($0C2)
		%SquareDyn($0E0)
		%SquareDyn($0E2)
		..end
	.ClimbDyn00
		dw ..end-..start
		..start
		%SquareDyn($0C4)
		%SquareDyn($0C6)
		%SquareDyn($0E4)
		%SquareDyn($0E6)
		..end
	.ClimbDyn01
		dw ..end-..start
		..start
		%SquareDyn($0C8)
		%SquareDyn($0CA)
		%SquareDyn($0E8)
		%SquareDyn($0EA)
		..end
	.ClimbDyn02
		dw ..end-..start
		..start
		%SquareDyn($0CC)
		%SquareDyn($0CE)
		%SquareDyn($0EC)
		%SquareDyn($0EE)
		..end
	.HurtDyn00
		dw ..end-..start
		..start
		%SquareDyn($04C)
		%SquareDyn($04E)
		%SquareDyn($06C)
		%SquareDyn($06E)
		..end


	DATA:
		.XSpeed
		db $08,$F8	; walk
		db $18,$E8	; run EASY
		db $20,$E0	; run NORMAL
		db $24,$DC	; run INSANE

		.WallXSpeed
		db $10,$F0

		.WallJumpSpeed
		db $E0,$20

		.SmokeX
		db $08,$00

		.IFrames
		db $40,$60,$80

		.DustOffset
		db $0A,$FE

		.TargetPlayer
		db $00,$00,$80,$00




	namespace off


