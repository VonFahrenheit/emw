

HappySlime:

	namespace HappySlime


	!Temp = 0
	%def_anim(HappySlime_Ground, 3)
	%def_anim(HappySlime_Ceiling, 3)
	%def_anim(HappySlime_WallUp, 3)
	%def_anim(HappySlime_WallDown, 3)
	%def_anim(HappySlime_Midair, 1)
	%def_anim(HappySlime_CornerUG, 1)
	%def_anim(HappySlime_CornerUC, 1)
	%def_anim(HappySlime_CornerDC, 1)
	%def_anim(HappySlime_CornerDG, 1)
	%def_anim(HappySlime_GroundSquat, 1)
	%def_anim(HappySlime_CeilingSquat, 1)
	%def_anim(HappySlime_WallSquat, 1)
	%def_anim(HappySlime_Bounce, 4)
	%def_anim(HappySlime_Stunned, 1)
	%def_anim(HappySlime_Dead, 1)



; Plan:
;
; $BE   - Fhhhhhhh
;	  F is falling down after hit flag
;	  h is number of hits taken
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
; $33C0 - green if A, red if 8
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
		!SlimeBounceOffset	= $35B0,x
		!Goal1			= $35D0,x
		!Goal2			= $35E0,x

	INIT:
		JSL SUB_HORZ_POS
		TYA : STA $3320,x
		RTL

	MAIN:
		PHB : PHK : PLB
		LDA !ExtraBits,x : BMI .Main

		.Init
		ORA #$80
		STA !ExtraBits,x
		LDA #$00 : JSL GET_SQUARE
		BCS +
		STZ $3230,x
		PLB
		RTL

	+	LDA $3290,x : BMI +
		JSL SUB_HORZ_POS
		TYA : STA $3320,x
	+	PEA.w RETURN-2			; yes, an extra byte here
		LDA !ExtraBits,x
		AND #$04 : BEQ .Follow

		.Play
		JMP PLAY

		.Follow
		JMP FOLLOW


		.Main
		JSL SPRITE_OFF_SCREEN
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

		.WallDisp
		db $03,$0F

		.WallBits
		db $FE,$FC

		.SlimeX
		db $F0,$10


	; Figure out quadrant of target and set proper happiness value
	AI:
		LDA !SpriteAnimIndex
		CMP #!HappySlime_Dead : BNE .NotDead
		JMP GRAPHICS
		.NotDead

		PEA.w PHYSICS-1
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
		LDA $33C0,x
		CMP #$08 : BNE ..Happy

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
		CMP #!HappySlime_Bounce : BNE $03 : JMP ..search
		LDY !Goal2
		DEY
		CMP #!HappySlime_Bounce+3 : BEQ ..bounce

..bind		LDA !SpriteAnimTimer
		LSR A
		STA $00
		STZ $01
		LDA !SlimeBounceOffset : STA $02
		STZ $03
		LDA $3240,x : XBA
		LDA $3210,x
		REP #$20
		SEC : SBC $02
		CLC : ADC $00
		SEP #$20
		STA $3210,y
		XBA : STA $3240,y

		LDA #$02 : STA !SpritePhaseTimer,y	; prevent object clipping for held sprite while it's held

		LDA $3200,y				;\
		CMP #$0F : BNE ++			; |
		LDA #$08 : STA $3230,y			; > goomba state
		BRA +					; |
	++	CMP #$21 : BEQ +			; | sprites that are held in place
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

..bounce	LDA !SpriteAnimTimer : BEQ $01 : RTS	; only bounce once
		LDA #$A0 : STA $309E,y			; bounce yspeed
		LDA $3200,y				;\
		CMP #$0F : BNE +			; | goomba is knocked out lmao
		LDA #$09 : STA $3230,y			;/
	+	LDA #$08 : STA !SPC4			; handle bounce
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

	+	LDA $3230,x
		CMP #$08 : BCC ..next
		LDA !SpriteYSpeed,x : BMI ..next
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
		STA !SlimeBounceOffset

		LDA #!HappySlime_Bounce+1 : STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		BRA ..ok

..next		DEX : BPL -
		PLX



	..anim	LDA !SpriteAnimIndex
		CMP #!HappySlime_Bounce : BCC +
		CMP #!HappySlime_Bounce_over : BCC ..ok
	+	LDA #!HappySlime_Bounce : STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
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
		LDA $BE,x				;\
		AND #$7F : BEQ +			; |
		STZ !Happiness				; |
		LDA !SpriteAnimIndex			; | mood + color
		CMP #!HappySlime_Stunned : BEQ +	; |
		CMP #!HappySlime_Midair : BEQ +		; > don't change color until after the stun animation is over
		LDA #$08 : STA $33C0,x			; |
		+					;/

		BIT !Happiness : BMI .Go
		LDA !ExtraBits,x
		AND #$04 : BEQ .Go
		JSL !SpriteApplySpeed
		JMP INTERACTION
		.Go



		TXA
		CLC : ADC $14
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
		JSL SUB_HORZ_POS_P2 : BRA +
..1		JSL SUB_HORZ_POS
	+	TYA : STA $3320,x
		.NoTurn


		BIT $BE,x : BPL +
		JSL !SpriteApplySpeed			; > Apply speed
		LDA $3330,x
		AND #$04 : BEQ ++
		STZ !SpriteYSpeed,x			; > Kill Yspeed
		LDA $BE,x
		AND #$7F
		STA $BE,x
		LDA #!HappySlime_Stunned : STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
	++	JMP GRAPHICS
		+

		LDA !SpriteAnimIndex
		CMP #!HappySlime_CornerUG : BCC .Process

		.Return
		JMP .End

		.Process
		PEA.w .End-1
		LDA !RNGtable,x
		AND #$7F : BEQ +
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
		LDA #!HappySlime_CeilingSquat : STA !SpriteAnimIndex		;\
		STZ !SpriteAnimTimer						; |
		LDA #$20 : STA !SpriteYSpeed,x					; |
		LDY $3320,x							; | Jump from ceiling
		LDA DATA_Speed,y : STA !SpriteXSpeed,x				; |
		STZ $3280,x							; |
		STZ $3290,x							; |
		RTS								;/

	+	BIT $3290,x
		BPL .GroundJump
		LDA $3320,x
		EOR #$01
		STA $3320,x
		BVC +
		LDA #!HappySlime_WallSquat : STA !SpriteAnimIndex		;\
		STZ !SpriteAnimTimer						; |
		LDA #$E0 : STA !SpriteYSpeed,x					; |
		LDY $3320,x							; | Jump up from wall
		LDA DATA_Speed+4,y : STA !SpriteXSpeed,x			; |
		STZ $3290,x							; |
		RTS								;/

	+	LDA #!HappySlime_WallSquat : STA !SpriteAnimIndex		;\
		STZ !SpriteAnimTimer						; |
		STZ !SpriteYSpeed,x						; |
		LDY $3320,x							; | Jump down from wall
		LDA DATA_Speed+4,y : STA !SpriteXSpeed,x			; |
		STZ $3290,x							; |
		RTS								;/

		.GroundJump
		LDA !SpriteAnimIndex
		CMP #!HappySlime_Stunned : BEQ ..r
		CMP #!HappySlime_Dead : BEQ ..r
		LDA #!HappySlime_GroundSquat : STA !SpriteAnimIndex		;\
		STZ !SpriteAnimTimer						; |
		LDA #$D0 : STA !SpriteYSpeed,x					; |
		LDY $3320,x							; | Jump from ground
		LDA DATA_Speed+2,y : STA !SpriteXSpeed,x			; |
		STZ $3330,x							; |
	..r	RTS								;/


		.NoJump
		LDA !Happiness
		CMP #$01 : BEQ ..Normal
		CMP #$02 : BEQ ..PlaceHop
		CMP #$03 : BEQ ..PlaceHop
		CMP #$04 : BNE ..Normal

..BigHop	LDA $3330,x							;\
		AND #$04 : BEQ ..Return						; |
		STZ $3330,x							; |
		LDA #!HappySlime_GroundSquat : STA !SpriteAnimIndex		; | Handle big hop
		STZ !SpriteAnimTimer						; |
		LDA #$C0 : STA !SpriteYSpeed,x					; |
		LDY $3320,x							; |
		LDA DATA_Speed,y : STA !SpriteXSpeed,x				; |
		STZ $3330,x							; |
		RTS								;/

..PlaceHop	LDA $3330,x							;\
		AND #$04 : BEQ ..Return						; |
		STZ $3330,x							; |
		INC !Happiness							; | Handle place hop
		LDA #!HappySlime_GroundSquat : STA !SpriteAnimIndex		; |
		LDA #$02 : STA !SpriteAnimTimer					; |
		LDA #$E0 : STA !SpriteYSpeed,x					; |
		STZ !SpriteXSpeed,x						; |
		LDA !Goal1							; |
		LSR A								; |
		BCC ..P1							; |
		JSL SUB_HORZ_POS_P2 : BRA +					; |
..P1		JSL SUB_HORZ_POS						; |
	+	TYA : STA $3320,x						; |
		STZ $3330,x							; |
		RTS								;/

..Return	JSL !SpriteApplySpeed						;\ Apply speed
		RTS								;/


..Normal	LDA $3330,x
		AND #$04 : BEQ ..write
		LDY $3320,x
		LDA !SpriteAnimIndex : BEQ ..getspeed
		CMP #!HappySlime_Ceiling : BEQ ..getspeed
		LDA !SpriteXSpeed,x : BPL +
		INC !SpriteXSpeed,x : BRA ..write
	+	DEC !SpriteXSpeed,x : BRA ..write
..getspeed	LDA DATA_Speed,y : STA !SpriteXSpeed,x
..write


	;	LDY $3320,x				;\
	;	LDA DATA_Speed,y			; | Xspeed
	;	STA $AE,x				;/
		BIT $3280,x : BPL .NoCeiling

		.Ceiling
		LDA #$F0 : STA !SpriteYSpeed,x		; > Stick up
		JSL !SpriteApplySpeed			; > Apply speed
		LDA $32A0,x				;\ Ypos
		STA $3210,x				;/
		LDA $3330,x				;\
		AND #$03 : BEQ +			; | Detect corner
		JMP .Down				;/
	+	LDA $3330,x				;\
		AND #$08 : BEQ .Fall			; | Detect end of ceiling
		RTS					;/

		.Fall
		LDA #!HappySlime_CeilingSquat : STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		LDA #$10 : STA !SpriteYSpeed,x		;\
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
		CMP #!HappySlime_WallUp : BEQ ..getspeed
		CMP #!HappySlime_WallDown : BEQ ..getspeed
		LDA !SpriteYSpeed,x : BPL +
		INC !SpriteYSpeed,x : BRA ..write
	+	DEC !SpriteYSpeed,x : BRA ..write

..getspeed	LDA DATA_Speed,y : STA !SpriteYSpeed,x
..write		LDY $3320,x
		LDA DATA_Speed+2,y : STA !SpriteXSpeed,x

		LDA !SpriteYSpeed,x : PHA
		JSL !SpriteApplySpeed			; > Apply speed
		PLA : STA !SpriteYSpeed,x

		LDA $3330,x				;\
		AND #$03 : BEQ +			; |
		TAY					; |
		LDA $32B0,x				; | wall Xpos
		AND #$F0				; |
		ORA DATA_WallDisp-1,y			; |
		STA !SpriteXLo,x			;/
	+	LDA $3330,x				;\ Detect ceiling
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
		LDA #!HappySlime_Midair : STA !SpriteAnimIndex		; > Animation
		LDA #$F8 : STA !SpriteYSpeed,x				;\
		STZ $3280,x						; | Just keep walking
		STZ $3290,x						; |
		RTS							;/

		.Walk
		JSL !SpriteApplySpeed					; > Apply speed
		LDA $3330,x
		AND #$04 : BEQ +
		LDA !SpriteAnimIndex
		CMP #!HappySlime_Ceiling+1 : BCC ++
		STZ !SpriteAnimIndex
		STZ !SpriteAnimTimer
		BRA ++
	+	LDA !SpriteAnimIndex
		CMP #!HappySlime_Ceiling+1 : BCS ++
		JMP .GroundJump
	++	LDA $3330,x
		AND #$03 : BNE .Up
		LDA $3330,x
		AND #$08 : BNE .CeilingStick
		RTS

		.GroundDir
		LDA $3320,x
		EOR #$01
		STA $3320,x
		STZ $3280,x
		STZ $3290,x
		LDA #!HappySlime_CornerDG : STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		RTS

		.CeilingStick
		LDA #!HappySlime_Ceiling : STA !SpriteAnimIndex
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
		LDA #!HappySlime_CornerUG : STA !SpriteAnimIndex
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
		LDA #!HappySlime_CornerDC : STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		RTS

		.CeilingDir
		LDA #!HappySlime_CornerDC : STA !SpriteAnimIndex
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
		LDA !SlimeInvincTimer
		CMP #$20 : BCS .NoAttack

		LDA !SpriteAnimIndex
		CMP #!HappySlime_Dead : BEQ .NoAttack
		CMP #!HappySlime_Stunned : BEQ .CheckAttack

		JSR HITBOX_BODY
		JSL P2Standard
		BCC .CheckAttack
		BNE .Hurt
		LDA $3330,x				;\
		AND #$04 : BNE .CheckAttack		; | Slime bounces on player
		LDA #$E0 : STA !SpriteYSpeed,x		; |
		LDA #$08 : STA !SPC4			;/ > bounce SFX
		BRA .CheckAttack
		.Hurt
		STZ !SpriteXSpeed,x
		LDA #$10 : STA !SpriteYSpeed,x
		LDA !BigRAM+$7F
		AND #$02
		LSR A
		ORA #$10
		STA !Goal1
		TYA
		AND #$80
		TAY
		JSL SUB_HORZ_POS_Target
		LDA DATA_SlimeX,y : STA $02
		LDA #$E0 : STA $03
		JSR HURT

		.CheckAttack
		JSL P2Attack : BCC .NoAttack
		STZ $3330,x
		LDA !P2Hitbox1XSpeed-$80,y
		STA !SpriteXSpeed,x
		STA $02
		LDA !P2Hitbox1YSpeed-$80,y
		STA !SpriteYSpeed,x
		STA $03
		TYA
		ROL #2
		AND #$01
		ORA #$10
		STA !Goal1
		JSR HURT
		.NoAttack



	GRAPHICS:

		.ProcessAnim
		LDA !SpriteAnimIndex
		ASL #2
		TAY
		LDA.w ANIM+2,y
		AND #$3F : STA $00
		LDA !SpriteAnimTimer
		INC A
		CMP $00 : BNE .SameAnim
		.NewAnim
		LDA.w ANIM+3,y
		CMP #$FF : BNE +
		STZ $3230,x
		PLB
		RTL

	+	STA !SpriteAnimIndex
		ASL #2
		TAY
		CMP.b #!HappySlime_Dead*4 : BNE +		; special check for dead: can only die after taking at least 2 hits
		LDA $BE,x
		AND #$7F
		CMP #$02 : BCS +
		STZ !SpriteAnimIndex
	+	LDA #$00
		.SameAnim
		STA !SpriteAnimTimer
		LDA !SlimeInvincTimer			;\ Flicker during i-frames
		AND #$02 : BEQ .Draw			;/
		PLB
		RTL


; standard for a 16x16 dynamic sprite:
;	- 4-byte animation table: 2 bytes for %SquareDyn(), 1 byte for timer, 1 byte for sequence
;	- square dynamo is copied to !BigRAM+2, !BigRAM+0 is set to 2, $0C is set to #!BigRAM
;
; exception for happy slime is that highest 2 bits of timer is an index to the tilemap table (because the slime has 4 tilemaps depending on which YX bits are set)
; also if $33C0,x is 08 (red), 0x26*$20 is added to the square dynamo, unless it is already 0x2C*$20 or greater

		.Draw
		REP #$20
		LDA.w ANIM+0,y : STA !BigRAM+2
		LDA #$0002 : STA !BigRAM+0
		LDA $33C0,x
		AND #$000E
		CMP #$0008 : BNE ..notred
		LDA !BigRAM+2
		CMP.w #$2C*$20 : BCS ..notred
		CMP.w #$0A*$20 : BCC ..add		;\ account for new line
		CMP.w #$10*$20 : BCS ..add		;/
		CLC : ADC.w #$10*$20			; add a new line
	..add	CLC : ADC.w #$26*$20			; add red offset
		STA !BigRAM+2
		..notred
		LDA.w #!BigRAM : STA $0C
		LDA.w ANIM+2-1,y
		AND #$C000
		CLC : ROL #3
		ASL A
		TAY
		LDA ANIM_TilemapPtr+0,y : STA $04
		SEP #$20

		LDY.b #!File_HappySlime
		JSL LOAD_SQUARE_DYNAMO
		JSL SETUP_SQUARE
		LDA !ExtraBits,x
		AND #$04 : BEQ .p2
	.p1	JSL LOAD_DYNAMIC_p1 : BRA .Invis
	.p2	JSL LOAD_DYNAMIC_p2

		.Invis
		PLB
	RETURN:
		RTL


	ANIM:
	; ground
		%SquareDyn($000) : db $07|$00,!HappySlime_Ground+1
		%SquareDyn($002) : db $07|$00,!HappySlime_Ground+2
		%SquareDyn($004) : db $14|$00,!HappySlime_Ground+0
	; ceiling
		%SquareDyn($000) : db $07|$80,!HappySlime_Ceiling+1
		%SquareDyn($002) : db $07|$80,!HappySlime_Ceiling+2
		%SquareDyn($004) : db $14|$80,!HappySlime_Ceiling+0
	; wall up
		%SquareDyn($00A) : db $07|$00,!HappySlime_WallUp+1
		%SquareDyn($00C) : db $07|$00,!HappySlime_WallUp+2
		%SquareDyn($00E) : db $14|$00,!HappySlime_WallUp+0
	; wall down
		%SquareDyn($00A) : db $07|$80,!HappySlime_WallDown+1
		%SquareDyn($00C) : db $07|$80,!HappySlime_WallDown+2
		%SquareDyn($00E) : db $14|$80,!HappySlime_WallDown+0
	; midair
		%SquareDyn($008) : db $3F|$00,!HappySlime_Midair

	; the following animations have no innate speed
	; corner up from ground
		%SquareDyn($022) : db $0C|$00,!HappySlime_WallUp
	; corner up to ceiling
		%SquareDyn($022) : db $0C|$C0,!HappySlime_Ceiling
	; corner down from ceiling
		%SquareDyn($022) : db $0C|$80,!HappySlime_WallDown
	; corner down to ground
		%SquareDyn($022) : db $0C|$40,!HappySlime_Ground
	; ground squat
		%SquareDyn($006) : db $10|$00,!HappySlime_Midair
	; ceiling squat
		%SquareDyn($006) : db $10|$80,!HappySlime_Midair
	; wall squat
		%SquareDyn($020) : db $10|$00,!HappySlime_Midair
	; bounce
		%SquareDyn($000) : db $3F|$00,!HappySlime_Bounce+0
		%SquareDyn($006) : db $06|$00,!HappySlime_Bounce+2
		%SquareDyn($024) : db $0A|$00,!HappySlime_Bounce+3
		%SquareDyn($008) : db $20|$00,!HappySlime_Bounce+0
	; stunned
		%SquareDyn($024) : db $20|$00,!HappySlime_Dead
	; dead
		%SquareDyn($04C) : db $3F|$00,$FF	; < kill in this animation


	.TilemapPtr
		dw .TM00
		dw .TM40
		dw .TM80
		dw .TMC0

	.TM00
		dw $0004
		db $22,$00,$00,$00
	.TM40
		dw $0004
		db $62,$00,$00,$00
	.TM80
		dw $0004
		db $A2,$00,$00,$00
	.TMC0
		dw $0004
		db $E2,$00,$00,$00


	HITBOX:
		.BODY
		LDA $3220,x					;\
		CLC : ADC #$02					; |
		STA $04						; | hitbox xpos
		LDA $3250,x					; |
		ADC #$00					; |
		STA $0A						;/
		LDA #$0C					;\ hitbox width
		STA $06						;/
		LDA $3210,x					;\
		CLC : ADC #$02					; |
		STA $05						; | hitbox ypos
		LDA $3240,x					; |
		ADC #$00					; |
		STA $0B						;/
		LDA #$0E					;\ hitbox height
		STA $07						;/
		RTS

	FOLLOW:
		LDA !RNG					;\
		AND #$01					; | randomly choose player to follow
		ORA #$10					; |
		STA !Goal1					;/
		RTS

	PLAY:
		LDA #$40 : STA !Goal1
		RTS


	WANDER:

	OBJECTS:

	HURT:
		LDA !SlimeInvincTimer : BEQ .Hurt
		RTS

		.Hurt
		LDA !ExtraBits,x				;\
		AND.b #$04^$FF					; | clear extra bit
		STA !ExtraBits,x				;/
		LDA #$40 : STA !SlimeInvincTimer		;\ invinc timer + anim timer
		STZ !SpriteAnimTimer				;/
		LDA $3330,x					;\ on ground or in midair
		AND #$04 : BEQ .Air				;/
		.Ground						;\
		LDA #!HappySlime_Stunned : STA !SpriteAnimIndex	; |
		LDA $BE,x					; | hit
		INC A						; |
		AND #$7F : BRA .Set				;/
		.Air						;\
		LDA #!HappySlime_Midair : STA !SpriteAnimIndex	; |
		LDA $BE,x					; |
		INC A						; | hit + fall
		AND #$7F					; |
		ORA #$80					; |
		.Set						; |
		STA $BE,x					;/

		LDA #$04 : STA $00
		LDA #$04 : STA $01
		STZ $04
		LDA #$18 : STA $05
		LDA !GFX_SlimeParticles_tile : STA $06
		LDA !GFX_SlimeParticles_prop
		ORA $33C0,x
		ORA #$30
		STA $07
		LDA #!prt_basic : JSL SpawnParticle

		LDA !RNG
		AND #$0C
		STA !BigRAM
		LDA !RNG
		AND #$1F
		STA !BigRAM+1
		LDA !RNG
		AND #$07
		EOR #$07
		CLC : ADC $03
		STA $03

		LDA $06
		CLC : ADC #$10
		STA $06
		LDA $02
		SEC : SBC !BigRAM
		STA $02
		LDA #$C0 : TRB $07
		LDA #!prt_basic : JSL SpawnParticle
		LDA $02
		CLC : ADC !BigRAM+1
		STA $02
		LDA !RNG
		LSR #4
		AND #$0F
		SEC : SBC $03
		EOR #$FF
		STA $03
		LDA #$C0 : TRB $07
		LDA #!prt_basic : JSL SpawnParticle
		RTS



	namespace off





