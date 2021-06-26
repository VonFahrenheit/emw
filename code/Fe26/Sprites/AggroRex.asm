

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

	!AggroRexChase		= $3280
	!AggroRexIFrames	= $3290
	!AggroRexPrevFrame	= $32A0
	!AggroRexWall		= $32B0
	!AggroRexStunTimer	= $32D0
	!AggroRexIdleTimer	= $34F0
	!AggroRexHasJump	= $34F0




AggroRex:

	namespace AggroRex



	INIT:
		PHB : PHK : PLB

		LDA #$FF : STA !AggroRexPrevFrame,x


		LDA #$03 : JSL GET_SQUARE
		BCS +
		STZ $3230,x

		+

		PLB
		RTL


	MAIN:
		PHB : PHK : PLB
		LDA $9D : BEQ .Process
	-	JMP GRAPHICS

		.Process

		%decreg(!AggroRexIFrames)

		LDA $3230,x
		CMP #$08 : BEQ PHYSICS
		CMP #$02 : BEQ -

		PLB
		RTL


	PHYSICS:


		LDA !SpriteAnimIndex
		CMP #!AggroRex_Climb : BNE +
		LDA #$02 : STA !SpriteStasis,x
		+


		STZ !AggroRexWall,x

		.Alert
		LDA !AggroRexChase,x : BEQ $03 : JMP ..nochase
		LDA !ExtraBits,x
		AND #$04 : BEQ ..notwaiting
		JSL SUB_HORZ_POS
		TYA : STA $3320,x
		..notwaiting
		LDA #$80 : STA $06					; sight box width
		LDA #$20 : STA $07					; sight box height
		LDA $3220,x						;\
		STA $04							; |
		LDA $3250,x						; |
		STA $0A							; |
		LDA $3210,x						; | sight box coords
		SEC : SBC #$18						; |
		STA $05							; |
		LDA $3240,x						; |
		SBC #$00						; |
		STA $0B							;/
		LDA $3320,x						;\
		BEQ +							; |
		LDA $04							; | move sight box 0x80 pixels left if facing left
		SEC : SBC #$80						; |
		STA $04							; |
		BCS $02 : DEC $0A					;/
	+	SEC : JSL !PlayerClipping : BCC ..nochase		; check clipping

		JSL SUB_HORZ_POS
		TYA : STA $3320,x
		LDA #$25 : STA !SPC1				; roar SFX
		LDA #$01 : STA !AggroRexChase,x
		LDA !ExtraBits,x
		AND #$04 : BEQ ..nojump
		..jump
		LDA !ExtraBits,x
		AND #$04^$FF
		STA !ExtraBits,x
		LDA !Difficulty
		AND #$03
		ASL A
		ADC $3320,x
		TAY
		LDA DATA_XSpeed+2,y : STA !SpriteXSpeed,x
		LDA #$D0 : STA !SpriteYSpeed,x
		BRA ..nochase
		..nojump
		LDA #!AggroRex_Roar : STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		LDA #$20 : STA !AggroRexStunTimer,x
		STZ !SpriteXSpeed,x
		..nochase


		.Speed
		LDA $3330,x
		AND #$04 : BEQ ..nospeed
		STZ !SpriteYSpeed,x
		STZ !AggroRexHasJump,x				; regain jump

		LDA !AggroRexStunTimer,x : BNE ..nochase
		LDA !SpriteAnimIndex
		CMP #!AggroRex_Hurt : BEQ ..nochase
		LDA !AggroRexChase,x : BEQ ..nochase
		JSL SUB_HORZ_POS
		TYA : STA $3320,x
		LDA !Difficulty
		AND #$03
		ASL A
		ADC $3320,x
		TAY
		LDA DATA_XSpeed+2,y : JSL AccelerateX
		BRA ..nospeed
		..nochase


		LDA !SpriteAnimIndex
		CMP #!AggroRex_Hurt : BNE ..noslide
		LDA !SpriteXSpeed,x : BEQ ..nospeed
		LDA $14
		AND #$03 : BNE +
		LDA #$04 : STA $00
		LDA #$0C : STA $01
		LDA #$03+!SmokeOffset : JSL SpawnExSprite_NoSpeed
	+	JSL AccelerateX_Friction1
		..noslide
		LDA !AggroRexChase,x : BNE ..nospeed


		LDA !AggroRexStunTimer,x : BNE ..nospeed
		LDA !ExtraBits,x
		AND #$04 : BNE ..nospeed
		LDY $3320,x
		LDA DATA_XSpeed,y : STA !SpriteXSpeed,x
		..nospeed
		LDA $3250,x : PHA
		LDA $3220,x : PHA

		JSL !SpriteApplySpeed

		LDA !AggroRexHasJump,x : BNE ..nojump
		LDA $3330,x
		AND #$04 : BNE ..nojump
		INC !AggroRexHasJump,x
		LDA !AggroRexStunTimer,x : BNE ..nojump
		JSL SUB_VERT_POS
		CPY #$00 : BEQ ..nojump
		LDA #$C0 : STA !SpriteYSpeed,x
		..nojump




		LDA !AggroRexStunTimer,x : BEQ +
		LDA $3330,x
		AND #$03 : BNE ..turnback
		BRA ..nowall
		+


		LDA !AggroRexChase,x : BNE ..checkclimb
		LDA $3330,x
		AND #$03 : BEQ ..nowall
		LDA $3320,x
		EOR #$01
		STA $3320,x
		BRA ..turnback

		..checkclimb
		LDA $3320,x
		INC A
		AND $3330,x : BNE ..startclimb
		LDA $3330,x
		AND #$03 : BNE ..turnback
		BRA ..nowall

		..startclimb
		LDA #$01 : STA !AggroRexWall,x
		LDY $3320,x
		LDA DATA_WallXSpeed,y : STA !SpriteXSpeed,x
		LDA #$E0 : STA !SpriteYSpeed,x
		LDA $3330,x
		AND #$04^$FF
		STA $3330,x
		..turnback
		PLA : STA $3220,x
		PLA : STA $3250,x
		BRA ..walldone
		..nowall
		PLA : PLA
		..walldone





	INTERACTION:
		LDA !SpriteAnimIndex
		CMP #!Rex_Dead : BEQ GRAPHICS
		JSL !GetSpriteClipping04

		.Body
		JSL P2Standard
		BCC ..nocontact
		BEQ ..nocontact
		LDA !AggroRexIFrames,x : BNE ..nocontact
		JSR Hurt
		..nocontact

		.Attack
		JSL P2Attack : BCC ..nocontact
		LDA !P2Hitbox1XSpeed-$80,y : STA !SpriteXSpeed,x
		LDA !P2Hitbox1YSpeed-$80,y : STA !SpriteYSpeed,x
		LDA !AggroRexIFrames,x : BNE ..nocontact
		LDA #$08 : JSL DontInteract
		STZ $3330,x
		JSR Hurt
		..nocontact





	GRAPHICS:

		LDA !AggroRexStunTimer,x : BNE ++

	; wall check
		LDA !AggroRexWall,x : BEQ .NoWall
		LDA !SpriteAnimIndex
		CMP #!AggroRex_Climb : BCC +
		CMP #!AggroRex_Climb_over : BCC ++
	+	LDA #!AggroRex_Climb : STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
	++	JMP .HandleUpdate
		.NoWall

	; air check
		LDA $3330,x
		AND #$04 : BNE .NoJump
		LDA #!AggroRex_Jump : STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		BRA .HandleUpdate
		.NoJump

	; start walk check
		LDA !ExtraBits,x
		AND #$04 : BNE .NoWalk
		LDA !SpriteAnimIndex
		CMP #!AggroRex_Walk : BCS .NotIdle
		LDA #!AggroRex_Walk : STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
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
		STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		.NotRandomIdle
		LDA !SpriteAnimIndex
		CMP #!AggroRex_Lookout : BEQ +
		CMP #!AggroRex_Scratch : BEQ +
		CMP #!AggroRex_Scratch+1 : BEQ +
		LDA #!AggroRex_Idle
	++	STA !SpriteAnimIndex
	+	BRA .HandleUpdate
		.NotIdle

	; run check
		LDA !AggroRexChase,x : BEQ .NoChase
		LDA !SpriteAnimIndex
		CMP #!AggroRex_Run : BCC +
		CMP #!AggroRex_Run_over : BCC .HandleUpdate
	+	LDA #!AggroRex_Run : STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		BRA .HandleUpdate
		.NoChase

	; walk check
		LDA !SpriteAnimIndex
		CMP #!AggroRex_Walk : BCC +
		CMP #!AggroRex_Walk_over : BCC .HandleUpdate
	+	LDA #!AggroRex_Walk : STA !SpriteAnimIndex
		STZ !SpriteAnimTimer



	; standard update code (6-byte table, smoke + SFX on footsteps)
		.HandleUpdate
		LDA !SpriteAnimIndex : STA $00
		ASL A
		ADC $00
		ASL A
		TAY
		LDA !SpriteAnimTimer
		INC A
		CMP.w ANIM+4,y : BNE .SameAnim
		.NewAnim
		LDA.w ANIM+5,y : STA !SpriteAnimIndex
		STA $00
		ASL A
		ADC $00
		ASL A
		TAY
		LDA !SpriteAnimIndex
		CMP #!AggroRex_Climb+1 : BNE +
		PHY
		LDY $3320,x
		LDA DATA_SmokeX,y : STA $00
		LDA #$F8
		BRA ++

	+	CMP #!AggroRex_Run+0 : BEQ ..smoke
		CMP #!AggroRex_Run+4 : BNE ..nosmoke
		..smoke
		LDA #$01 : STA !SPC1
		PHY
		LDA #$04 : STA $00
		LDA #$0C
	++	STA $01
		LDA #$03+!SmokeOffset : JSL SpawnExSprite_NoSpeed
		PLY
		..nosmoke
		LDA #$00
		.SameAnim
		STA !SpriteAnimTimer


		REP #$20
		LDA.w ANIM+0,y : STA $04
		LDA.w ANIM+2,y : STA $0C
		SEP #$20
		LDA !SpriteAnimIndex
		CMP !AggroRexPrevFrame,x
		STA !AggroRexPrevFrame,x
		BEQ .NoDynamo

		LDY #!File_AggroRex
		JSL LOAD_SQUARE_DYNAMO
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
		dw .TM32,.WalkDyn01 : db $10,!AggroRex_Walk+2
		dw .TM32,.WalkDyn00 : db $10,!AggroRex_Walk+3
		dw .TM32,.WalkDyn02 : db $10,!AggroRex_Walk+0
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
		db $32,$00,$F0,$00
		db $32,$10,$F0,$01
		db $32,$00,$00,$02
		db $32,$10,$00,$03
	.TM32X2
		dw $0010
		db $32,$F0,$F0,$00
		db $32,$00,$F0,$01
		db $32,$F0,$00,$02
		db $32,$00,$00,$03
	.TM32
		dw $0010
		db $32,$F8,$F0,$00
		db $32,$08,$F0,$01
		db $32,$F8,$00,$02
		db $32,$08,$00,$03
	.TM32U1
		dw $0010
		db $32,$F8,$EF,$00
		db $32,$08,$EF,$01
		db $32,$F8,$FF,$02
		db $32,$08,$FF,$03
	.TM32U2
		dw $0010
		db $32,$F8,$EE,$00
		db $32,$08,$EE,$01
		db $32,$F8,$FE,$02
		db $32,$08,$FE,$03


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

		.SmokeX
		db $08,$00

		.IFrames
		db $40,$60,$80


	Hurt:
		LDA #$20 : STA !AggroRexStunTimer,x
		LDA !Difficulty
		AND #$03
		TAY
		LDA DATA_IFrames,y : STA !AggroRexIFrames,x
		LDA #!AggroRex_Hurt : STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		INC $BE,x
		LDA #$01 : STA !AggroRexChase,x
		RTS


namespace off


