HappySlime:

	namespace HappySlime


; Plan:
;
; $BE   - F-----H
;	  F is falling down after hit flag
;	  H is number of hits taken
; $3280 - Ceiling data
;	  C-------
;	  C is climbing ceiling flag
; $3290 - Wall data
;	  CD------
;	  C is climbing wall flag
;	  D is direction (0 = down, 1 = up)
; $32A0 - Ceiling Ypos
; $32B0 - Wall Xpos
; $32D0 - Invinc timer
; $3340 - Used to determine if slime is red or not
;
; $3390 - Happiness value:
;	  00 - prioritize reaching goal
;	  01 - randomly wander/jump
;	  02 - hop in place twice
;	  03 - hop in place once
;	  04 - jump over target
;	  05 - carry target
;	  06 - juggle target
;	  80-FF - pissed (NOT TRUE THIS ISN'T USED!!)
; $35A0 - Direction towards target:
;	  00 - up + right
;	  01 - up + left
;	  02 - down + right
;	  03 - down + left
;	  04 - straight right
;	  05 - straight left
; $35B0 - Satisfaction timer:
;	  When the slime targets something, this timer starts counting down from 255.
;	  When it reaches 0, the slime makes a decision.
; $35D0 - GGtttttt
;	  GG is goal (00 = follow creature, 01 = play in area, 10 = wander, 11 = play with object)
;	  tttttt is lo bits of target, see below
; $35E0 - High bits of target. Combines like this:
;	  Follow creature/play with object:
;	  t = index of sprite to interact with, value 0x10 means P1 and value 0x11 means P2.
;	  TTTTTTTT is unused.
;	  Play in area/wander:
;	  tttttt Y position (tiles) of area (X position in vertical levels)
;	  TTTTTTTT X position (tiles) of area (Y position in vertical levels)


		!SlimeInvincTimer	= $32D0,x

		!Happiness		= $3390,x

		!TargetQuadrant		= $35A0,x
		!BounceOffset		= $35B0,x
		!Goal1			= $35D0,x
		!Goal2			= $35E0,x



	MAIN:
		STZ $33C0,x
		LDA !GameMode
		CMP #$14 : BEQ +
		RTL

	+	PHB : PHK : PLB
		LDA !ExtraBits,x : BMI .Main

		.Init
		ORA #$80
		STA !ExtraBits,x
		LDA #$00 : JSL !GetDynamicTile
		BCS +
		STZ $3230,x
		PLB
		RTL

	+	TYA
		ORA #$10
		STA !ClaimedGFX			; which slot this sprite has
		TXA : STA !DynamicTile,y	; which sprite has the slot

		JSR SUB_HORZ_POS
		TYA : STA $3320,x
		PEA INIT-2
		LDA !ExtraBits,x
		AND #$04 : BEQ .Follow

		.Play
		JMP PLAY

		.Follow
		JMP FOLLOW


		.Main
		JSR SPRITE_OFF_SCREEN
		LDA $3230,x
		SEC : SBC #$08
		ORA $9D
		BEQ AI
		JMP GRAPHICS

	DATA:
		.Speed
		db $1C,$E4
		db $20,$E0
		db $E0,$20

		.QuadrantJumps
		db $02,$01
		db $0B,$0B
		db $02,$01

		.WallX
		db $00,$01

		.WallBits
		db $FE,$FC


	; Figure out quadrant of target and set proper happiness value
	AI:
		PEA PHYSICS-1
		LDA !Goal1
		ROL #3
		AND #$03
		ASL A
		TAX
		JMP (.Ptr,x)

		.Ptr
		dw .Follow
		dw .Play
		dw .Wander
		dw .Objects

		.Follow
		LDX !SpriteIndex
		LDA #$03 : STA !TargetQuadrant		; > Unspecified quadrant
		LDA !Goal1
		LDY !P1Dead
		BEQ $02 : AND.b #$01^$FF
		LDY !P2Status
		BEQ $02 : ORA #$01
		STA !Goal1
		AND #$1F
		CMP #$10
	;	BCC ..Sprite

..Player	LSR A					; Get specific player bit into carry
		LDA $3210,x : STA $00
		LDA $3240,x : STA $01
		LDA $3250,x
		XBA
		LDA $3220,x
		REP #$20
		BCS ..P2

..P1		SEC : SBC $94
		BPL +
		EOR #$FFFF : INC A
		DEC !TargetQuadrant
	+	STA $02					; > |Slime X - target X|
		LDA $00
		SEC : SBC $96
		BRA ++					; > Go to shared code

..P2		SEC : SBC !P2XPosLo
		BPL +
		EOR #$FFFF : INC A
		DEC !TargetQuadrant
	+	STA $02					; > |Slime X - target X|
		LDA $00
		SEC : SBC !P2YPosLo
	++	BPL +
		EOR #$FFFF : INC A
		CMP #$0050 : BCC ..Straight		;\
		BRA ++					; |
..Straight	INC !TargetQuadrant			; | See if within straight territory
		INC !TargetQuadrant			; |
		BRA ++					;/
	+	DEC !TargetQuadrant
		DEC !TargetQuadrant
	++	CMP #$0020 : BCS ..TooFar		;\
		LDA $02					; | Must be within a $40*$40 box centered on target
		CMP #$0020 : BCS ..TooFar		;/

..InRange	SEP #$20
		LDA $3280,x				;\
		ORA $3290,x				; | Must not be climbing
		BNE ..Return				;/
		LDA $3330,x				;\ Must be on ground
		AND #$04 : BEQ ..Return			;/
		LDA $3340,x : BEQ ..Happy

		JMP PHYSICS_GroundJump			; angry jump


..Happy		LDA !Happiness
		CMP #$02 : BCS ..Return
		LDA #$02 : STA !Happiness
		RTS


..Sprite	RTS


..TooFar	SEP #$20
		STZ !Happiness

..Return	RTS



		.Play
		LDX !SpriteIndex
		LDA !SpriteAnimIndex
		CMP #$32 : BEQ ..search
		LDY !Goal2
		DEY
		CMP #$35 : BEQ ..bounce

..bind		LDA !SpriteAnimTimer
		LSR A
		STA $00
		STZ $01
		LDA !BounceOffset : STA $02
		STZ $03
		LDA $3240,x : XBA
		LDA $3210,x
		REP #$20
		SEC : SBC $02
		CLC : ADC $00
		SEP #$20
		STA $3210,y
		XBA : STA $3240,y
		LDA $3200,y				;\
		CMP #$21 : BEQ +			; | sprites that are held in place
		CMP #$74 : BEQ +			;/
		JMP ..anim
	+	LDA $3220,x : STA $3220,y		;\
		LDA $3250,x : STA $3250,y		; |
		LDA $30AE,y				; |
		EOR #$FF				; | hold in place
		INC A					; |
		STA $3530,y				; |
		LDA #$FF : STA $3570,y			;/
		BRA ..anim

..bounce	LDA !SpriteAnimTimer : BNE ..ok		; only bounce once
		LDA #$A0 : STA $309E,y
		LDA #$08 : STA !SPC4			; handle bounce
		BRA ..anim

..search	JSL !GetSpriteClipping04
		PHX
		LDX #$0F
	-	CPX !SpriteIndex : BEQ ..next
		LDA !NewSpriteNum,x : BNE +		;\
		LDA !ExtraBits,x			; |
		AND #!CustomBit : BEQ +			; | two slimes can't bounce eachother at the same time
		LDA !Goal2 : BEQ +			; |
		DEC A					; |
		CMP !SpriteIndex : BEQ ..next		;/

	+	LDA $3230,x : BEQ ..next
		LDA $9E,x : BMI ..next
		JSL !GetSpriteClipping00
		JSL !CheckContact
		BCC ..next
		LDA #$10 : STA $34E0,x			; set stasis timer
		TXA
		TXY
		PLX
		INC A
		STA !Goal2

		LDA $3210,x				; store bounce offset so animation will look smooth
		SEC : SBC $3210,y
		STA !BounceOffset

		LDA #$33 : STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		BRA ..ok

..next		DEX : BPL -
		PLX



	..anim	LDA #$32
		CMP !SpriteAnimIndex : BCC ..ok
		STA !SpriteAnimIndex
		..ok


		RTS





		.Wander
		LDX !SpriteIndex
		LDA #$01 : STA !Happiness
		RTS

		.Objects
		LDX !SpriteIndex
		RTS



	PHYSICS:
		STZ $3340,x				;\
		LDA $BE,x : BEQ +			; |
		LDA #$19 : STA $3340,x			; | Handle angry animation and mood
		LDA #$00 : STA !Happiness		; |
		+					;/

		BIT !Happiness : BMI .Go
		LDA !ExtraBits,x
		AND #$04 : BEQ .Go
		JSL !SpriteApplySpeed
		JMP INTERACTION
		.Go



		LDA $14
		AND #$07 : BNE .NoTurn
		LDA $3330,x
		AND #$04
		BNE .TurnValid
		BIT $3280,x
		BPL .NoTurn

		.TurnValid
		LDA !Goal1
		CMP #$40 : BCC .Follow
		CMP #$80 : BCS .NoTurn
		LDA !TargetQuadrant
		AND #$01
		STA $3320,x
		BRA .NoTurn

		.Follow
		LSR A
		BCC ..1
		PEA ..1-1+3
		JMP SUB_HORZ_POS_2
..1		JSR SUB_HORZ_POS
		TYA : STA $3320,x
		.NoTurn


		BIT $BE,x : BPL +
		JSL $01802A				; > Apply speed
		LDA $3330,x
		AND #$04 : BEQ +
		STZ $9E,x				; > Kill Yspeed
		LDA #$01 : STA $BE,x
		LDA #$18
		LDY !SpriteAnimIndex
		CPY #$07 : BEQ $04
		CLC : ADC $3340,x
		STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		JMP .End
		+

		LDA !SpriteAnimIndex
		SEC : SBC $3340,x
		CMP #$06 : BEQ .Return
		CMP #$08 : BEQ .Return
		CMP #$10 : BEQ .Return
		CMP #$12 : BEQ .Return
		CMP #$14 : BCC .Process

		.Return
		JMP .End

		.Process
		PEA .End-1
		TXA
		CLC : ADC !RNG
		AND #$7F
		BEQ +
	-	JMP .NoJump
	+	LDA $3330,x
		AND #$0F : BEQ -
		LDA !Happiness				;\ Only jump while seeking or wandering
		CMP #$02 : BCS -			;/
		CMP #$01 : BEQ .Jump			; > Don't toggle anything if !Happiness = 1
		LDY !TargetQuadrant			;\
		LDA $3330,x				; |
		BIT $3280,x				; | Determine allowed jumps
		BPL $02 : ORA #$08			; |
		AND DATA_QuadrantJumps,y		; |
		BEQ -					;/

		.Jump
		STZ $3330,x
		BIT $3280,x
		BPL +
		LDA #$08
		CLC : ADC $3340,x
		STA !SpriteAnimIndex			;\
		STZ !SpriteAnimTimer			; |
		LDA #$20 : STA $9E,x			; |
		LDY $3320,x				; | Jump from ceiling
		LDA DATA_Speed,y			; |
		STA $AE,x				; |
		STZ $3280,x				; |
		STZ $3290,x				; |
		RTS					;/

	+	BIT $3290,x
		BPL .GroundJump
		LDA $3320,x
		EOR #$01
		STA $3320,x
		BVC +
		LDA #$10
		CLC : ADC $3340,x
		STA !SpriteAnimIndex			;\
		STZ !SpriteAnimTimer			; |
		LDA #$E0 : STA $9E,x			; |
		LDY $3320,x				; | Jump up from wall
		LDA DATA_Speed+4,y			; |
		STA $AE,x				; |
		STZ $3290,x				; |
		RTS					;/

	+	LDA #$12
		CLC : ADC $3340,x
		STA !SpriteAnimIndex			;\
		STZ !SpriteAnimTimer			; |
		STZ $9E,x				; |
		LDY $3320,x				; | Jump down from wall
		LDA DATA_Speed+4,y			; |
		STA $AE,x				; |
		STZ $3290,x				; |
		RTS					;/

		.GroundJump
		LDA !SpriteAnimIndex
		CMP #$18 : BEQ ..r
		CMP #$31 : BEQ ..r
		LDA #$06
		CLC : ADC $3340,x
		STA !SpriteAnimIndex			;\
		STZ !SpriteAnimTimer			; |
		LDA #$D0 : STA $9E,x			; |
		LDY $3320,x				; | Jump from ground
		LDA DATA_Speed+2,y			; |
		STA $AE,x				; |
		STZ $3330,x				; |
	..r	RTS					;/


		.NoJump
		LDA !Happiness
		CMP #$01 : BEQ ..Normal
		CMP #$02 : BEQ ..PlaceHop
		CMP #$03 : BEQ ..PlaceHop
		CMP #$04 : BNE ..Normal

..BigHop	LDA $3330,x				;\
		AND #$04 : BEQ ..Return			; |
		STZ $3330,x				; |
		LDA #$06				; |
		CLC : ADC $3340,x			; |
		STA !SpriteAnimIndex			; | Handle big hop
		STZ !SpriteAnimTimer			; |
		LDA #$C0 : STA $9E,x			; |
		LDY $3320,x				; |
		LDA DATA_Speed,y			; |
		STA $AE,x				; |
		STZ $3330,x				; |
		RTS					;/

..PlaceHop	LDA $3330,x				;\
		AND #$04 : BEQ ..Return			; |
		STZ $3330,x				; |
		INC !Happiness				; | Handle place hop
		LDA #$06				; |
		CLC : ADC $3340,x			; |
		STA !SpriteAnimIndex			; |
		LDA #$02 : STA !SpriteAnimTimer		; |
		LDA #$E0 : STA $9E,x			; |
		STZ $AE,x				; |
		LDA !Goal1				; |
		LSR A					; |
		BCC ..P1				; |
		PEA ..P1-1+3				; |
		JMP SUB_HORZ_POS_2			; |
..P1		JSR SUB_HORZ_POS			; |
		TYA : STA $3320,x			; |
		STZ $3330,x				; |
		RTS					;/

..Return	JSL $01802A				;\ Apply speed
		RTS					;/


..Normal


		LDA $3330,x
		AND #$04 : BEQ ..write
		LDY $3320,x
		LDA !SpriteAnimIndex : BEQ ..getspeed
		CMP #$03 : BEQ ..getspeed
		CMP #$19 : BEQ ..getspeed
		CMP #$1C : BEQ ..getspeed
		LDA $AE,x : BPL +
		INC $AE,x : BRA ..write
	+	DEC $AE,x : BRA ..write
..getspeed	LDA DATA_Speed,y : STA $AE,x
..write


	;	LDY $3320,x				;\
	;	LDA DATA_Speed,y			; | Xspeed
	;	STA $AE,x				;/
		BIT $3280,x : BPL .NoCeiling

		.Ceiling
		LDA #$F0 : STA $9E,x			; > Stick up
		JSL $01802A				; > Apply speed
		LDA $32A0,x				;\ Ypos
		STA $3210,x				;/
		LDA $3330,x				;\
		AND #$03 : BEQ +			; | Detect corner
		JMP .Down				;/
	+	LDA $3330,x				;\
		AND #$08 : BEQ .Fall			; | Detect end of ceiling
		RTS					;/

		.Fall
		LDA #$08
		CLC : ADC $3340,x
		STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		LDA #$10 : STA $9E,x			;\
		STZ $3280,x				; | Fall
		STZ $3290,x				; |
		RTS					;/

		.NoCeiling
		BIT $3290,x : BPL .Walk

		.Wall
		LDY #$00				;\
		BIT $3290,x				; |
		BVC $01 : INY				; | Yspeed

		LDA !SpriteAnimIndex
		CMP #$0A : BEQ ..getspeed
		CMP #$0D : BEQ ..getspeed
		CMP #$23 : BEQ ..getspeed
		CMP #$26 : BEQ ..getspeed
		LDA $9E,x : BPL +
		INC $9E,x : BRA ..write
	+	DEC $9E,x : BRA ..write

..getspeed	LDA DATA_Speed,y : STA $9E,x
..write		LDY $3320,x
		LDA DATA_Speed,y : STA $AE,x

		LDA $9E,x : PHA
		JSL $01802A				; > Apply speed
		PLA : STA $9E,x

		LDA $32B0,x				;\ Xpos
		STA $3220,x				;/
		LDA $3330,x				;\ Detect ceiling
		AND #$08 : BEQ +			; |
		JMP .CeilingDir				;/
	+	LDA $3330,x				;\ Detect ground
		AND #$04 : BEQ $03 : JMP .GroundDir	;/
		LDA $3320,x				;\
		INC A					; |
		AND $3330,x				; | Detect end of wall
		BEQ .WallEnd				; |
		RTS					;/

		.WallEnd
		LDA #$07
		CLC : ADC $3340,x
		STA !SpriteAnimIndex			; > Animation
		LDA #$F8 : STA $9E,x			;\
		STZ $3280,x				; | Just keep walking
		STZ $3290,x				; |
		RTS					;/

		.Walk
		JSL $01802A				; > Apply speed
		LDA $3330,x
		AND #$04
		BEQ +
	;	LDA #$10 : STA $9E,x
		LDA !SpriteAnimIndex
		SEC : SBC $3340,x
		CMP #$04
		BCC ++
		LDA $3340,x
		STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		BRA ++
	+	LDA !SpriteAnimIndex
		SEC : SBC $3340,x
		CMP #$04
		BCS ++ : JMP .GroundJump
	++	LDA $3330,x
		AND #$03 : BNE .Up
		LDA $3330,x
		AND #$08
		BNE .CeilingStick
		RTS

		.GroundDir
		LDA $3320,x
		EOR #$01
		STA $3320,x
		STZ $3280,x
		STZ $3290,x
		LDA #$17
		CLC : ADC $3340,x
		STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		RTS

		.CeilingStick
		LDA #$03
		CLC : ADC $3340,x
		STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		LDA $3320,x				;\
		BEQ .Right				; | Jumping into ceiling
		BRA .Left				;/

		.Up
		LDA $3220,x
		LDY $3320,x
		CLC : ADC DATA_WallX,y
		AND DATA_WallBits,y
		STA $32B0,x
		LDA #$C0
		STA $3290,x
		STZ $3280,x
		LDA #$14
		CLC : ADC $3340,x
		STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		RTS

		.Down
		LDA $3220,x
		LDY $3320,x
		CLC : ADC DATA_WallX,y
		AND DATA_WallBits,y
		STA $32B0,x
		LDA #$80
		STA $3290,x
		STZ $3280,x
		LDA #$16
		CLC : ADC $3340,x
		STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		RTS

		.CeilingDir
		LDA #$15
		CLC : ADC $3340,x
		STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		LDA $3320,x				;\ Climbing into ceiling
		BNE .Right				;/

		.Left
		LDA $3210,x
		STA $32A0,x
		LDA #$80
		STA $3280,x
		LDA #$01 : STA $3320,x
		RTS

		.Right
		LDA $3210,x
		STA $32A0,x
		LDA #$80
		STA $3280,x
		STZ $3320,x
		RTS

		.End


	INTERACTION:
		JSR HITBOX_BODY
		SEC : JSL !PlayerClipping
		BCC .NoContact
		LDY $7490 : BEQ .NoStar
		PEA GRAPHICS-1
		JMP SPRITE_STAR

		.NoStar
		LDY #$00
		LSR A : BCC .P2
		PHA
		JSR PlayerContact
		PLA

		.P2
		LDY #$80
		LSR A : BCC .NoContact
		JSR PlayerContact

		.NoContact
		JSR P2Attack
		BCC .NoAttack
		JSR HURT
		LDA #$10 : STA !Goal1
		.NoAttack



	GRAPHICS:
		.ProcessAnim
		LDA !SpriteAnimIndex
		ASL #2
		TAY
		LDA !SpriteAnimTimer
		INC A
		CMP.w Anim+2,y
		BNE .SameAnim

		.NewAnim
		LDA Anim+3,y
		CMP #$FF : BNE +
		STZ $3230,x
		PLB
		RTL

	+	STA !SpriteAnimIndex
		ASL #2
		TAY
		LDA #$00

		.SameAnim
		STA !SpriteAnimTimer
		LDA !SlimeInvincTimer			;\ Flicker during i-frames
		AND #$02 : BEQ .Draw			;/
		PLB
		RTL


		.Draw
		LDA.w Anim+0,y : STA $04
		LDA.w Anim+1,y : STA $05

		LDA ($04) : STA !BigRAM+$02
		STZ !BigRAM+$05

		REP #$20
		LDA #$0004
		STA !BigRAM+$00
		STZ !BigRAM+$03
		LDA #$000E : STA !BigRAM+$06
		LDA #$0040
		STA !BigRAM+$08
		STA !BigRAM+$0F
		LDY #$01
		LDA ($04),y
		AND #$00FF
		ASL #5
		CLC : ADC #$DA08
		STA !BigRAM+$0A
		CLC : ADC #$0200
		STA !BigRAM+$11
		LDA #$6000
		STA !BigRAM+$0D
		ORA #$0100
		STA !BigRAM+$14

		LDA.w #!BigRAM+0 : STA $04
		LDA.w #!BigRAM+6 : STA $0C

		SEP #$20
		LDA #$30
		STA !BigRAM+$0C
		STA !BigRAM+$13

		JSL !UpdateClaimedGFX
		JSR LOAD_CLAIMED


		LDA !ExtraBits,x			; move slime to hi prio OAM if it's bouncy
		AND #$04 : BEQ .Invis
		JSR HI_PRIO_OAM				; note that A is always 4 here


		.Invis
		PLB

	INIT:
		RTL


	Anim:
	.Anim_Horz00
		dw .TM_Horz00 : db $07,$01		; 00
		dw .TM_Horz01 : db $07,$02		; 01
		dw .TM_Horz02 : db $14,$00		; 02
	.Anim_Horz80
		dw .TM_Horz80 : db $07,$04		; 03
		dw .TM_Horz81 : db $07,$05		; 04
		dw .TM_Horz82 : db $14,$03		; 05
	.Anim_HorzJump00
		dw .TM_HorzJump00 : db $10,$07		; 06
		dw .TM_HorzJump01 : db $FF,$07		; 07
	.Anim_HorzJump80
		dw .TM_HorzJump80 : db $10,$09		; 08
		dw .TM_HorzJump81 : db $FF,$09		; 09

	.Anim_Vert00
		dw .TM_Vert00 : db $07,$0B		; 0A
		dw .TM_Vert01 : db $07,$0C		; 0B
		dw .TM_Vert02 : db $14,$0A		; 0C
	.Anim_Vert80
		dw .TM_Vert80 : db $07,$0E		; 0D
		dw .TM_Vert81 : db $07,$0F		; 0E
		dw .TM_Vert82 : db $14,$0D		; 0F
	.Anim_VertJump00
		dw .TM_VertJump00 : db $10,$11		; 10
		dw .TM_HorzJump01 : db $FF,$11		; 11
	.Anim_VertJump80
		dw .TM_VertJump80 : db $10,$13		; 12
		dw .TM_HorzJump81 : db $FF,$13		; 13

	.Anim_CornerGU
		dw .TM_Corner00 : db $0C,$0A		; 14
	.Anim_CornerUC
		dw .TM_Corner81 : db $0C,$03		; 15
	.Anim_CornerCD
		dw .TM_Corner80 : db $0C,$0D		; 16
	.Anim_CornerDG
		dw .TM_Corner01 : db $0C,$00		; 17

	.Anim_Stunned
		dw .TM_Stunned : db $20,$19		; 18

	.Angry_Horz00
		dw Angry_TM_Horz00 : db $07,$1A		; 19
		dw Angry_TM_Horz01 : db $07,$1B		; 1A
		dw Angry_TM_Horz02 : db $14,$19		; 1B
	.Angry_Horz80
		dw Angry_TM_Horz80 : db $07,$1D		; 1C
		dw Angry_TM_Horz81 : db $07,$1E		; 1D
		dw Angry_TM_Horz82 : db $14,$1C		; 1E
	.Angry_HorzJump00
		dw Angry_TM_HorzJump00 : db $10,$20	; 1F
		dw Angry_TM_HorzJump01 : db $FF,$20	; 20
	.Angry_HorzJump80
		dw Angry_TM_HorzJump80 : db $10,$22	; 21
		dw Angry_TM_HorzJump81 : db $FF,$22	; 22

	.Angry_Vert00
		dw Angry_TM_Vert00 : db $07,$24		; 23
		dw Angry_TM_Vert01 : db $07,$25		; 24
		dw Angry_TM_Vert02 : db $14,$23		; 25
	.Angry_Vert80
		dw Angry_TM_Vert80 : db $07,$27		; 26
		dw Angry_TM_Vert81 : db $07,$28		; 27
		dw Angry_TM_Vert82 : db $14,$26		; 28
	.Angry_VertJump00
		dw Angry_TM_VertJump00 : db $10,$2A	; 29
		dw Angry_TM_HorzJump01 : db $FF,$2A	; 2A
	.Angry_VertJump80
		dw Angry_TM_VertJump80 : db $10,$2C	; 2B
		dw Angry_TM_HorzJump81 : db $FF,$2C	; 2C

	.Angry_CornerGU
		dw Angry_TM_Corner00 : db $0C,$23	; 2D
	.Angry_CornerUC
		dw Angry_TM_Corner81 : db $0C,$1C	; 2E
	.Angry_CornerCD
		dw Angry_TM_Corner80 : db $0C,$26	; 2F
	.Angry_CornerDG
		dw Angry_TM_Corner01 : db $0C,$19	; 30

	.Angry_Stunned
		dw Angry_TM_Stunned : db $20,$FF	; 31

	.Await_Bounce
		dw .TM_Horz00 : db $FF,$32		; 32
	.Bounce_1
		dw .TM_HorzJump00 : db $06,$34		; 33
	.Bounce_2
		dw .TM_Stunned : db $0A,$35		; 34
	.Bounce_3
		dw .TM_HorzJump01 : db $20,$32		; 35






	.TM_Horz00
		db $3A,$00
	.TM_Horz01
		db $3A,$02
	.TM_Horz02
		db $3A,$04
	.TM_Horz80
		db $BA,$00
	.TM_Horz81
		db $BA,$02
	.TM_Horz82
		db $BA,$04

	.TM_HorzJump00
		db $3A,$06
	.TM_HorzJump01
		db $3A,$08
	.TM_HorzJump80
		db $BA,$06
	.TM_HorzJump81
		db $BA,$08

	.TM_Vert00
		db $3A,$0A
	.TM_Vert01
		db $3A,$0C
	.TM_Vert02
		db $3A,$0E
	.TM_Vert80
		db $BA,$0A
	.TM_Vert81
		db $BA,$0C
	.TM_Vert82
		db $BA,$0E

	.TM_VertJump00
		db $7A,$20
	.TM_VertJump80
		db $FA,$20

	.TM_Corner00
		db $3A,$22
	.TM_Corner01
		db $7A,$22
	.TM_Corner80
		db $BA,$22
	.TM_Corner81
		db $FA,$22

	.TM_Stunned
		db $3A,$24


	Angry:
	.TM_Horz00
		db $38,$26
	.TM_Horz01
		db $38,$28
	.TM_Horz02
		db $38,$2A
	.TM_Horz80
		db $B8,$26
	.TM_Horz81
		db $B8,$28
	.TM_Horz82
		db $B8,$2A

	.TM_HorzJump00
		db $38,$2C
	.TM_HorzJump01
		db $38,$2E
	.TM_HorzJump80
		db $B8,$2C
	.TM_HorzJump81
		db $B8,$2E

	.TM_Vert00
		db $38,$40
	.TM_Vert01
		db $38,$42
	.TM_Vert02
		db $38,$44
	.TM_Vert80
		db $B8,$40
	.TM_Vert81
		db $B8,$42
	.TM_Vert82
		db $B8,$44

	.TM_VertJump00
		db $78,$46
	.TM_VertJump80
		db $F8,$46

	.TM_Corner00
		db $38,$48
	.TM_Corner01
		db $78,$48
	.TM_Corner80
		db $B8,$48
	.TM_Corner81
		db $F8,$48

	.TM_Stunned
		db $38,$4A


	PlayerContact:
		LDA #$01 : STA !P2SenkuSmash-$80,y
		LDA $3240,x : XBA
		LDA $3210,x
		REP #$20
		SEC : SBC !P2YPosLo-$80,y
		SEP #$20
		BCC .HurtPlayer
		CMP #$04 : BCC .HurtPlayer

		.HurtSlime
		LDA #$10
		CPY #$80
		BNE $01 : INC A
		STA !Goal1
		JSR HURT
		JSR P2Bounce
		JMP P2ContactGFX

		.HurtPlayer
		LDA !SlimeInvincTimer			;\ Don't deal damage for 32 frames after taking damage
		CMP #$20 : BCS .Return			;/
		TYA
		CLC : ROL #2
		INC A
		JSL !HurtPlayers
		LDA $3330,x				;\
		AND #$04 : BNE .Return			; | Slime bounces on player
		LDA #$E0 : STA $9E,x			; |
		LDA #$08 : STA !SPC4			;/
	.Return	RTS



	HITBOX:
		.BODY
		LDA $3220,x				;\
		CLC : ADC #$02				; |
		STA $04					; | Hitbox xpos
		LDA $3250,x				; |
		ADC #$00				; |
		STA $0A					;/
		LDA #$0C				;\ Hitbox width
		STA $06					;/
		LDA $3210,x				;\
		CLC : ADC #$02				; |
		STA $05					; | Hitbox ypos
		LDA $3240,x				; |
		ADC #$00				; |
		STA $0B					;/
		LDA #$0E				;\ Hitbox height
		STA $07					;/
		RTS

	FOLLOW:
		LDA !RNG				;\
		AND #$01				; | Randomly choose player to follow
		ORA #$10				; |
		STA !Goal1				;/
		JSR SUB_HORZ_POS
		TYA
		STA $3320,x
		RTS

	PLAY:
		LDA #$40 : STA !Goal1
		RTS


	WANDER:

	OBJECTS:

	HURT:
		LDA !SlimeInvincTimer : BNE .SFX
		LDA !ExtraBits,x		; clear extra bit
		AND.b #$04^$FF
		STA !ExtraBits,x
		LDA #$40 : STA !SlimeInvincTimer
		LDA #$08 : STA $32E0,x
		STZ $AE,x
		LDA #$10 : STA $9E,x
		STZ !SpriteAnimTimer
		LDA $3330,x
		AND #$04 : BNE +
		LDA #$07
		CLC : ADC $3340,x
		STA !SpriteAnimIndex
		LDA #$81			; Hit + fall
		BRA ++
	+	LDA #$18
		CLC : ADC $3340,x
		STA !SpriteAnimIndex
		LDA #$01			; Hit
	++	STA $BE,x
	.SFX	LDA #$02 : STA !SPC1		; > Contact sound
		RTS



	namespace off





