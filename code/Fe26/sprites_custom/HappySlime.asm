

	!SlimeAnger			= $BE		; 0 = calm, 80 = angry

	!SlimeDrop			= $3280		; 0 = not dropping, 1+ = dropping
	!SlimeJumpAttack		= $3290		; which jump the slime is on


	!SlimeInvincTimer		= $32D0

	!SlimeOwnedSprite		= $3400
	!SlimeBounceOffset		= $3410
	!SlimeRageTimer			= $3420

	!SlimeAI_CantWrap		= $3500
	!SlimeAI_TargetBelow		= $3510
	!SlimeAI_CantTurn		= $3520
	!SlimeAI_CanJump		= $3530



	!Temp = 0
	%def_anim(Slime_Ground, 3)
	%def_anim(Slime_Ceiling, 3)
	%def_anim(Slime_WallUp, 3)
	%def_anim(Slime_WallDown, 3)
	%def_anim(Slime_Midair, 1)
	%def_anim(Slime_CornerUG, 1)
	%def_anim(Slime_CornerUC, 1)
	%def_anim(Slime_CornerDC, 1)
	%def_anim(Slime_CornerDG, 1)
	%def_anim(Slime_GroundSquat, 1)
	%def_anim(Slime_CeilingSquat, 1)
	%def_anim(Slime_WallSquat, 1)
	%def_anim(Slime_Bounce, 4)
	%def_anim(Slime_Stunned, 3)
	%def_anim(Slime_Dead, 2)



HappySlime:

	namespace HappySlime


	INIT:
		LDA #$78 : STA !SlimeRageTimer,x
		LDA #$00 : JSL GET_SQUARE : BCS .Return
		STZ !SpriteStatus,x
		.Return
		RTL


	MAIN:
		PHB : PHK : PLB
		%decreg(!SlimeAI_CantTurn)

		LDA !ExtraBits,x
		AND #$04 : BNE BOUNCERMODE
		JMP AI


	BOUNCERMODE:
		%decreg(!SlimeRageTimer) : BNE .Process
		INC !SpriteHP,x
		LDA #$80 : STA !SlimeAnger,x
		LDA #$08 : STA !SpriteOAMProp,x
		LDA #$08 : STA !ExtraBits,x
		JMP INTERACTION

		.Process
		LDA !SpriteAnimIndex,x
		CMP #!Slime_Bounce : BEQ .Search
		LDY !SlimeOwnedSprite,x
		DEY
		CMP #!Slime_Bounce+3 : BEQ .Bounce
		JMP .Bind

	.Bounce
		LDA !SpriteAnimTimer,x : BEQ ..process			;\
		JMP .Done						; | only bounce once
		..process						;/
		LDA #$78 : STA !SlimeRageTimer,x			; if item doesn't return in 2 seconds, RAGE!
		LDA #$A0 : STA.w !SpriteYSpeed,y			; bounce yspeed
		LDA !SpriteNum,y					;\
		CMP #$0F : BNE +					; | goomba is knocked out lmao
		LDA #$09 : STA !SpriteStatus,y				;/
	+	LDA #$08 : STA !SPC4					; bounce sfx
		JMP .Done

	.Search
		JSL GetSpriteClippingE8					;\
		PHX							; |
		LDX #$0F						; | loop over all sprites, but don't interact with self
		..loop							; |
		CPX !SpriteIndex : BEQ ..next				;/
		LDA !SpriteStatus,x					;\
		CMP #$08 : BCC ..next					; | general interaction conditions
		LDA !SpriteYSpeed,x : BMI ..next			;/
		LDA !ExtraBits,x					;\
		AND #$0C						; |
		CMP #$0C : BNE ..thisone				; |
		LDA !SpriteNum,x : BNE ..thisone			; | can't interact with a slime that is carrying this one
		LDA !SlimeOwnedSprite,x					; |
		DEC A							; |
		CMP !SpriteIndex : BNE ..thisone			;/
		LDY !SpriteIndex					;\
		LDA #$78 : STA !SlimeRageTimer,y			; | reset rage timer if bounced
		BRA ..next						; |
		..thisone						;/
		JSL GetSpriteClippingE0					;\ check for contact
		JSL CheckContact : BCC ..next				;/
		LDA #$10 : STA !SpriteStasis,x				; set stasis timer
		TXA							;\
		TXY							; | grab this sprite
		PLX							; |
		INC A : STA !SlimeOwnedSprite,x				;/
		LDA !SpriteYLo,x					;\
		SEC : SBC !SpriteYLo,y					; | store bounce offset so animation will look smooth
		STA !SlimeBounceOffset,x				;/
		LDA #!Slime_Bounce+1 : STA !SpriteAnimIndex,x		;\ restart anim
		STZ !SpriteAnimTimer,x					;/
		BRA .Done						; end
		..next							;\
		DEX : BPL ..loop					; | restore sprite index and run animation
		PLX							; |
		BRA .Anim						;/

	.Bind
		LDA !SpriteAnimTimer,x					;\
		LSR A : STA $00						; |
		STZ $01							; |
		LDA !SlimeBounceOffset,x : STA $02			; |
		STZ $03							; |
		LDA !SpriteYHi,x : XBA					; |
		LDA !SpriteYLo,x					; | update held sprite y position
		REP #$20						; |
		SEC : SBC $02						; |
		CLC : ADC $00						; |
		SEP #$20						; |
		STA !SpriteYLo,y					; |
		XBA : STA !SpriteYHi,y					;/
		LDA #$02 : STA !SpritePhaseTimer,y			; prevent object clipping for held sprite while it's held
		LDA !SpriteNum,y					;\
		CMP #$0F : BNE ..notgoomba				; |
		..goomba						; |
		LDA #$08 : STA !SpriteStatus,y				; > goomba state
		BRA ..vectorlock					; |
		..notgoomba						; |
		CMP #$21 : BEQ ..vectorlock				; | sprites that are held in place
		CMP #$74 : BEQ ..vectorlock				; |
		BRA .Anim						;/
		..vectorlock						;\
		LDA !SpriteXLo,x : STA !SpriteXLo,y			; |
		LDA !SpriteXHi,x : STA !SpriteXHi,y			; |
		LDA.w !SpriteXSpeed,y					; | hold in place
		EOR #$FF : INC A					; |
		STA !SpriteVectorX,y					; |
		LDA #$FF : STA !SpriteVectorTimeX,y			;/


	.Anim
		LDA !SpriteAnimIndex,x					;\
		CMP #!Slime_Bounce : BCC ..updateanim			; |
		CMP #!Slime_Bounce_over : BCC .Done			; | update animation
		..updateanim						; |
		LDA #!Slime_Bounce : STA !SpriteAnimIndex,x		; |
		STZ !SpriteAnimTimer,x					;/

	.Done
		JSL APPLY_SPEED						; basic physics
		JMP INTERACTION						; go to interaction


	AI:
		.Wrap
		STZ !SlimeAI_CantWrap,x					;\
		REP #$30						; |
		LDA #$0008						; |
		LDY #$0018						; |
		JSL GetMap16_Sprite					; |
		CMP #$0100						; | can't wrap off of a platform type tile
		SEP #$20						; |
		BCC ..done						; |
		CMP #$11 : BCS ..done					; |
		INC !SlimeAI_CantWrap,x					; |
		..done							;/

		.TargetBelow
		STZ !SlimeAI_TargetBelow,x				;\
		REP #$20						; |
		LDA.w #DATA_DropDownSight : JSL LOAD_HITBOX		; | slime can drop from ceiling if player is below
		JSL PlayerContact : BCC ..done				; |
		INC !SlimeAI_TargetBelow,x				; |
		..done							;/

		.JumpOverLedges
		STZ !SlimeAI_CanJump,x					;\
		LDY !SpriteDir,x					; |
		REP #$30						; |
		LDA DATA_LedgeTileOffset,y				; |
		AND #$00FF						; |
		SEC : SBC #$0010					; |
		LDY #$0010						; | detect holes in ground that slime can jump over
		JSL GetMap16_Sprite					; |
		CMP #$0025						; |
		SEP #$20						; |
		BNE ..done						; |
		INC !SlimeAI_CanJump,x					; |
		..done							;/


	PHYSICS:
		.FreezeFrames
		LDA !SpriteAnimIndex,x					;\
		CMP.b #!Slime_Stunned : BEQ ..fullfreeze		; | frames that fully freeze (skip PHYSICS and INTERACTION)
		CMP.b #!Slime_Stunned+2 : BCS ..fullfreeze		; |
		CMP.b #!Slime_Stunned+1 : BNE +				;/
		..turnred						;\
		LDA #$08 : STA !SpriteOAMProp,x				; |
		LDA #$80 : STA !SlimeAnger,x				; | turn red halfway through stun animation
		JSL SUB_HORZ_POS					; |
		TYA : STA !SpriteDir,x					;/
		..fullfreeze						;\ full freeze
		JMP GRAPHICS						;/
	+	CMP.b #!Slime_CeilingSquat : BEQ ..freeze		;\
		CMP.b #!Slime_GroundSquat : BEQ ..freeze		; |
		CMP.b #!Slime_WallSquat : BEQ ..freeze			; | frames that half freeze (skip PHSYICS but still run INTERACTION)
		CMP.b #!Slime_CornerUG : BCC ..done			; |
		CMP.b #!Slime_CornerDG_over : BCS ..done		;/
		..freeze						;\ half freeze
		JMP .Done						;/
		..done


		.BaseSpeed
		LDA !SpriteBlocked,x					;\
		AND #$0F : TAY						; |
		..x							; |
		LDA DATA_StickXSpeed,y : BEQ ..y			; |
		STA !SpriteXSpeed,x					; | stick to surfaces
		..y							; |
		LDA DATA_StickYSpeed,y : BEQ ..done			; |
		STA !SpriteYSpeed,x					; |
		..done							;/


		LDA !SpriteBlocked,x					;\
		BIT #$0C : BNE .FloorCeiling				; | determine movement mode
		AND #$03 : BNE .Wall					;/


	.FreeFall
		LDA #$03 : STA !SpriteGravity,x				; enable gravity
		LDA.b #!Slime_Midair : STA !SpriteAnimIndex,x		; update animation
		JMP .Move						; go to main movement code


	.Wall
		TAY							;\ update direction
		LDA DATA_WallDirection,y : STA !SpriteDir,x		;/
		LDA !SpriteAnimIndex,x					;\
		CMP.b #!Slime_Midair : BNE ..nostick			; |
		STZ !SpriteYSpeed,x					; | reset y speed to stick to wall if coming from midair
		LDA.b #!Slime_WallSquat : STA !SpriteAnimIndex,x	; | (as opposed to corner/wraparound)
		STZ !SpriteAnimTimer,x					; |
		..nostick						;/

		LDA #$00 : STA !SpriteGravity,x				; disable gravity
		LDA !SlimeAI_CantTurn,x : BEQ ..chase			;\
		LDA !SpriteYSpeed,x					; |
		ROL #2							; |
		AND #$01 : TAY						; |
		BRA +							; |
		..chase							; |
		JSL SUB_VERT_POS					; | get direction and update animation
	+	LDA !SpriteAnimIndex,x					; |
		CMP DATA_WallAnim,y : BCC ..updateanim			; |
		CMP DATA_WallAnimOver,y : BCC ..keepanim		; |
		..updateanim						; |
		LDA DATA_WallAnim,y : STA !SpriteAnimIndex,x		; |
		STZ !SpriteAnimTimer,x					; |
		..keepanim						;/

		.AccelY
		LDA !SpriteAnimIndex,x					;\
		CMP DATA_WallAccelFrame,y : BNE ..friction		; |
		..accel							; |
		LDA DATA_Speed,y					; |
		BIT !SlimeAnger,x : BPL +				; |
		LDA DATA_Speed+2,y					; | update speed, then go to main movement code
	+	JSL AccelerateY						; |
		JSL AccelerateY						; |
		JMP .Move						; |
		..friction						; |
		JSL AccelerateY_Friction1				; |
		JMP .Move						;/


	.FloorCeiling
		LDA #$03 : STA !SpriteGravity,x				; enable gravity
		LDA !SlimeDrop,x : BEQ ..nodrop				;\
		STZ !SlimeDrop,x					; |
		LDA !SpriteHP,x						; |
		CMP #$02 : BCS ..die					; |
		..stun							; |
		LDA.b #!Slime_Stunned : BRA ..setanim			; |
		..die							; | handle hurt/death animations
		LDA.b #!Slime_Dead					; |
		..setanim						; |
		STA !SpriteAnimIndex,x					; |
		STZ !SpriteAnimTimer,x					; |
		JMP .Done						; |
		..nodrop						;/

		LDA !SlimeAI_CantTurn,x : BEQ ..chase			;\
		LDY !SpriteDir,x : BRA ..checksurface			; |
		..chase							; | update direction
		JSL SUB_HORZ_POS					; |
		TYA : STA !SpriteDir,x					;/
		..checksurface
		LDA !SpriteBlocked,x					;\ determine floor/ceiling mode
		AND #$08 : BEQ .Ground					;/

	.Ceiling
		LDA !SlimeAI_TargetBelow,x : BEQ ..anim			;\
		LDA.b #!Slime_CeilingSquat : STA !SpriteAnimIndex,x	; |
		STZ !SpriteAnimTimer,x					; |
		STZ !SpriteXSpeed,x					; | handle drop from ceiling move
		LDA #$20 : STA !SpriteYSpeed,x				; |
		STZ !SpriteBlocked,x					; |
		JMP .Done						;/
		..anim							;\
		LDA !SpriteAnimIndex,x					; |
		CMP.b #!Slime_Ceiling : BCC ..updateanim		; |
		CMP.b #!Slime_Ceiling_over : BCC +			; | update animation, then go to horizontal movement code
		..updateanim						; |
		LDA.b #!Slime_Ceiling : STA !SpriteAnimIndex,x		; |
		STZ !SpriteAnimTimer,x					; |
	+	BRA .HorzMovement					;/


	.Ground
		REP #$20						;\
		LDA.w #DATA_LedgeJumpSight : JSL LOAD_HITBOX		; |
		JSL PlayerContact : BCS ..noledgejump			; | detect ledge to jump over it, unless a player is in the disable zone
		LDA !SlimeAI_CanJump,x : BNE ..handlejumpattack		; |
		..noledgejump						;/
		REP #$20						;\
		LDA.w #DATA_JumpAttackSight : JSL LOAD_HITBOX		; |
		JSL PlayerContact : BCS ..handlejumpattack		; | detect nearby players to jump at them
		STZ !SlimeJumpAttack,x					; |
		BRA ..nojump						;/
		..handlejumpattack					;\
		LDA.b #!Slime_GroundSquat : STA !SpriteAnimIndex,x	; | squat animation
		STZ !SpriteAnimTimer,x					;/
		STZ !SpriteBlocked,x					; detach from ground
		LDA !SlimeAI_CanJump,x : BNE ..meanjump			;\
		BIT !SlimeAnger,x : BPL ..easyjump			; |
		..meanjump						; | aggressive jump
		LDA #$D0 : STA !SpriteYSpeed,x				; |
		LDY !SpriteDir,x					; |
		LDA DATA_Speed+2,y : BRA ..setjumpx			;/
		..easyjump						;\
		LDY !SlimeJumpAttack,x					; |
		LDA DATA_JumpAttackY,y : STA !SpriteYSpeed,x		; |
		CPY #$02 : BCS ..forwardjump				; |
		INC !SlimeJumpAttack,x					; |
		LDA #$00 : BRA ..setjumpx				; | highly telegraphed jump
		..forwardjump						; |
		STZ !SlimeJumpAttack,x					; |
		LDY !SpriteDir,x					; |
		LDA DATA_Speed,y					; |
		..setjumpx						; |
		STA !SpriteXSpeed,x					;/
		JMP .Done						;\ done
		..nojump						;/

		LDA !SpriteAnimIndex,x					;\
		CMP.b #!Slime_Ground_over : BCC .HorzMovement		; | update anim
		STZ !SpriteAnimIndex,x					; |
		STZ !SpriteAnimTimer,x					;/

	.HorzMovement
		LDA !SpriteAnimIndex,x					;\
		CMP.b #!Slime_Ground+1 : BEQ ..accel			; | accelerate in these frames, otherwise friction
		CMP.b #!Slime_Ceiling+1 : BNE ..friction		; |
		..accel							;/
		LDA DATA_Speed,y					;\
		BIT !SlimeAnger,x : BPL +				; |
		LDA DATA_Speed+2,y					; |
	+	JSL AccelerateX						; | update speed
		JSL AccelerateX						; |
		BRA .Move						; |
		..friction						; |
		JSL AccelerateX_Friction1				;/



	.Move
		JSL APPLY_SPEED						; basic physics
		LDA !SpriteBlocked,x					;\ if entering freefall, check for wraparaound
		AND #$0F : BEQ .HandleWrap				;/
		JMP .HandleCorners					; otherwise look for corners

	.HandleWrap
		LDA !SlimeAI_CantWrap,x : BNE ..cantwrap		; can't wrap off of platform type tile
		LDA $F4							;\
		BIT #$0C : BNE ..wraptowall				; |
		BIT #$03 : BNE ..wraptoceiling				; | wrap checks
		..cantwrap						; |
		JMP .Done						;/

		..wraptoceiling
		BIT !SpriteDeltaY,x : BMI ..cantwrap			; mush be moving down
		LDA !SpriteDeltaX,x					;\
		ROR #2							; |
		AND #$01 : STA !SpriteDir,x				; |
		TAY							; |
		LDA !SpriteXLo,x					; |
		AND #$F0						; | update position and snap to ceiling
		ORA #$08 : STA !SpriteXLo,x				; |
		LDA !SpriteYLo,x					; |
		AND #$F0						; |
		ORA #$0E : STA !SpriteYLo,x				; |
		LDA #$08 : STA !SpriteBlocked,x				;/
		LDA DATA_Speed,y : STA !SpriteXSpeed,x			;\ speed
		LDA #$F0 : STA !SpriteYSpeed,x				;/
		LDA.b #!Slime_Ceiling : STA !SpriteAnimIndex,x		;\ update animation
		STZ !SpriteAnimTimer,x					;/
		LDA #$7F : STA !SlimeAI_CantTurn,x			; > can't turn for 2 seconds
		JMP .Done						; done

		..wraptowall
		LDA !SpriteDeltaX,x					;\
		ROR #2							; |
		AND #$01						; |
		EOR #$01 : STA !SpriteDir,x				; |
		TAY							; | update position and snap to wall
		LDA !SpriteXLo,x					; |
		AND #$F0						; |
		ORA DATA_WrapAroundX,y : STA !SpriteXLo,x		; |
		LDA DATA_Speed,y : STA !SpriteXSpeed,x			; |
		LDA DATA_WallCollision,y : STA !SpriteBlocked,x		;/
		LDA $F4							;\ check direction
		BIT #$08 : BNE +					;/
		LDA #$10 : STA !SpriteYSpeed,x				;\
		LDA !SpriteYLo,x					; |
		AND #$F0						; | floor -> wall
		ORA #$08 : STA !SpriteYLo,x				; |
		LDA.b #!Slime_WallDown : BRA ++				;/
	+	LDA #$F0 : STA !SpriteYSpeed,x				;\
		LDA !SpriteYLo,x					; |
		AND #$F0						; | ceiling -> wall
		ORA #$08 : STA !SpriteYLo,x				; |
		LDA.b #!Slime_WallUp					;/
	++	STA !SpriteAnimIndex,x					;\ update anim
		STZ !SpriteAnimTimer,x					;/
		LDA #$7F : STA !SlimeAI_CantTurn,x			; > can't turn for 2 seconds
		JMP .Done


	.HandleCorners
		CMP #$05 : BEQ ..bottomright				;\
		CMP #$06 : BEQ ..bottomleft				; | corner detection
		CMP #$09 : BEQ ..topright				; |
		CMP #$0A : BNE ..done					;/
		..topleft						;\
		LDA $F4							; | top left corner
		AND #$02 : BEQ ..DC					;/
		..UC							;\
		LDA !SpriteBlocked,x					; |
		AND #$03 : TAY						; |
		LDA DATA_CornerDirection,y : STA !SpriteDir,x		; | from wall, up to ceiling
		TAY							; |
		LDA DATA_Speed,y : STA !SpriteXSpeed,x			; |
		LDA #$08 : STA !SpriteBlocked,x				; |
		LDA.b #!Slime_CornerUC : BRA ..setanim			;/
		..topright						;\
		LDA $F4							; | top right corner
		AND #$01 : BNE ..UC					;/
		..DC							;\
		LDA #$10 : STA !SpriteYSpeed,x				; |
		LDA !SpriteDeltaX,x					; |
		ROL #2							; | from ceiling, down to wall
		AND #$01						; |
		INC A							; |
		STA !SpriteBlocked,x					; |
		LDA.b #!Slime_CornerDC : BRA ..setanim			;/
		..bottomleft						;\
		LDA $F4							; | bot left corner
		AND #$02 : BNE ..DG					;/
		..UG							;\
		LDA #$F0 : STA !SpriteYSpeed,x				; |
		LDA !SpriteDeltaX,x					; |
		ROL #2							; | from ground, up to wall
		AND #$01						; |
		INC A							; |
		STA !SpriteBlocked,x					; |
		LDA.b #!Slime_CornerUG : BRA ..setanim			;/
		..bottomright						;\
		LDA $F4							; | bot right corner
		AND #$01 : BEQ ..UG					;/
		..DG							;\
		LDA !SpriteBlocked,x					; |
		AND #$03 : TAY						; |
		LDA DATA_CornerDirection,y : STA !SpriteDir,x		; | from wall, down to ground
		TAY							; |
		LDA DATA_Speed,y : STA !SpriteXSpeed,x			; |
		LDA #$04 : STA !SpriteBlocked,x				; |
		LDA.b #!Slime_CornerDG					;/
		..setanim						;\
		STA !SpriteAnimIndex,x					; | set corner animation
		STZ !SpriteAnimTimer,x					;/
		LDA #$7F : STA !SlimeAI_CantTurn,x			; > can't turn for 2 seconds
		..done							;


		.Done



	INTERACTION:
		JSL GetSpriteClippingE8					; get clipping
		LDA !SlimeInvincTimer,x : BNE .CheckBody		; can't get hurt while invincible
		JSL InteractAttacks : BCS .Hurt				; otherwise get hurt by any attack
		.CheckBody						;\
		JSL P2Standard : BEQ .NoContact				; | always interact, but slime can't be hurt while invincible
		LDA !SlimeInvincTimer,x : BNE .NoContact		;/
		.Hurt							;\
		LDA #$08 : STA !ExtraBits,x				; |
		LDA.b #!Slime_Midair : STA !SpriteAnimIndex,x		; |
		LDA #$40 : STA !SlimeInvincTimer,x			; |
		INC !SlimeDrop,x					; | hurt, detach from surfaces and fall
		INC !SpriteHP,x						; |
		STZ !SpriteBlocked,x					; |
		STZ !SpriteXSpeed,x					; |
		STZ !SpriteYSpeed,x					;/
		JSR HurtParticles					; small slime particles
		.NoContact




	GRAPHICS:
		.ProcessAnim
		LDA !SpriteAnimIndex,x					;\
		ASL #2 : TAY						; |
		LDA.w ANIM+2,y						; |
		AND #$3F : STA $00					; |
		LDA !SpriteAnimTimer,x					; |
		INC A							; |
		CMP $00 : BNE ..sameanim				; | update animation
		..newanim						; |
		LDA.w ANIM+3,y						; |
		CMP #$FF : BNE ..valid					; > die if anim updates to -1
		STZ !SpriteStatus,x					; |
		..return						; |
		PLB							; |
		RTL							;/
		..valid							;\
		STA !SpriteAnimIndex,x					; | store new anim and update index
		ASL #2 : TAY						;/
		CPY.b #!Slime_Midair*4 : BNE ..nobounce			;\
		LDA #$08 : STA !SPC4					; | bounce SFX at end of squat frames
		..nobounce						;/
		LDA #$00						;\
		..sameanim						; | default timer to 0
		STA !SpriteAnimTimer,x					;/
		LDA !SlimeInvincTimer,x					;\ flicker during i-frames
		AND #$02 : BNE ..return					;/


		.Draw
		REP #$20						;\
		LDA.w ANIM+0,y : STA !BigRAM+2				; |
		LDA #$0002 : STA !BigRAM+0				; |
		LDA !SpriteOAMProp,x					; | calculate source tile offset
		AND #$000E						; |
		CMP #$0008 : BNE ..notred				; |
		LDA !BigRAM+2						; |
		CMP.w #$2C*$20 : BCS ..notred				;/
		CMP.w #$0A*$20 : BCC ..add				;\ account for new line
		CMP.w #$10*$20 : BCS ..add				;/
		CLC : ADC.w #$10*$20					; add a new line
	..add	CLC : ADC.w #$26*$20					; add red offset
		STA !BigRAM+2						;\
		..notred						; |
		LDA.w #!BigRAM : STA $0C				; |
		LDA.w ANIM+2-1,y					; |
		AND #$C000						; | get pointers to dynamo and tilemap
		CLC : ROL #3						; |
		ASL A							; |
		TAY							; |
		LDA ANIM_TilemapPtr+0,y : STA $04			; |
		SEP #$20						;/

		LDY.b #!File_HappySlime					;\ dynamic GFX update
		JSL LOAD_SQUARE_DYNAMO					;/
		JSL SETUP_SQUARE					;\
		LDA !ExtraBits,x					; |
		AND #$04 : BEQ .p2					; | load tilemap
	.p1	JSL LOAD_DYNAMIC_p1 : BRA .Return			; |
	.p2	JSL LOAD_DYNAMIC_p2					;/

		.Return
		PLB
		RTL



	HurtParticles:
		LDA #$04 : STA $00
		LDA #$04 : STA $01
		LDA !RNG
		AND #$20
		SBC #$10
		STA $02
		LDA #$E0 : STA $03
		STZ $04
		LDA #$18 : STA $05
		LDA !GFX_SlimeParticles_tile : STA $06
		LDA !GFX_SlimeParticles_prop
		ORA !SpriteOAMProp,x
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


; standard for a 16x16 dynamic sprite:
;	- 4-byte animation table: 2 bytes for %SquareDyn(), 1 byte for timer, 1 byte for sequence
;	- square dynamo is copied to !BigRAM+2, !BigRAM+0 is set to 2, $0C is set to #!BigRAM
;
; exception for happy slime is that highest 2 bits of timer is an index to the tilemap table (because the slime has 4 tilemaps depending on which YX bits are set)
; also if !SpriteOAMProp,x is 08 (red), 0x26*$20 is added to the square dynamo, unless it is already 0x2C*$20 or greater


	ANIM:
	; ground
		%SquareDyn($000) : db $07|$00,!Slime_Ground+1
		%SquareDyn($002) : db $07|$00,!Slime_Ground+2
		%SquareDyn($004) : db $14|$00,!Slime_Ground+0
	; ceiling
		%SquareDyn($000) : db $07|$80,!Slime_Ceiling+1
		%SquareDyn($002) : db $07|$80,!Slime_Ceiling+2
		%SquareDyn($004) : db $14|$80,!Slime_Ceiling+0
	; wall up
		%SquareDyn($00A) : db $07|$00,!Slime_WallUp+1
		%SquareDyn($00C) : db $07|$00,!Slime_WallUp+2
		%SquareDyn($00E) : db $14|$00,!Slime_WallUp+0
	; wall down
		%SquareDyn($00A) : db $07|$80,!Slime_WallDown+1
		%SquareDyn($00C) : db $07|$80,!Slime_WallDown+2
		%SquareDyn($00E) : db $14|$80,!Slime_WallDown+0
	; midair
		%SquareDyn($008) : db $3F|$00,!Slime_Midair

	; the following animations have no innate speed
	; corner up from ground
		%SquareDyn($022) : db $0C|$00,!Slime_WallUp
	; corner up to ceiling
		%SquareDyn($022) : db $0C|$C0,!Slime_Ceiling
	; corner down from ceiling
		%SquareDyn($022) : db $0C|$80,!Slime_WallDown
	; corner down to ground
		%SquareDyn($022) : db $0C|$40,!Slime_Ground
	; ground squat
		%SquareDyn($006) : db $10|$00,!Slime_Midair
	; ceiling squat
		%SquareDyn($006) : db $10|$80,!Slime_Midair
	; wall squat
		%SquareDyn($020) : db $10|$00,!Slime_WallDown
	; bounce
		%SquareDyn($000) : db $3F|$00,!Slime_Bounce+0
		%SquareDyn($006) : db $06|$00,!Slime_Bounce+2
		%SquareDyn($024) : db $0A|$00,!Slime_Bounce+3
		%SquareDyn($008) : db $20|$00,!Slime_Bounce+0
	; stunned
		%SquareDyn($024) : db $10|$00,!Slime_Stunned+1
		%SquareDyn($024) : db $20|$00,!Slime_Stunned+2
		%SquareDyn($006) : db $10|$00,!Slime_Ground
	; dead
		%SquareDyn($024) : db $10|$00,!Slime_Dead+1
		%SquareDyn($04C) : db $20|$00,$FF			; 0xFF = kill in this animation


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


	DATA:
	.StickXSpeed
		db $00,$10,$F0,$00
		db $00,$10,$F0,$00
		db $00,$10,$F0,$00
		db $00,$10,$F0,$00

	.StickYSpeed
		db $00,$00,$00,$00
		db $10,$10,$10,$10
		db $F0,$F0,$F0,$F0
		db $00,$00,$00,$00

	.Speed
		db $1C,$E4
		db $24,$DC

	.JumpAttackY
		db $E0,$D4,$C0

	.LedgeTileOffset
		db $20,$0F

	.LedgeJumpSight
		dw $FF00,$0020 : db $FF,$FF

	.JumpAttackSight
		dw $FFD0,$FFF0 : db $30,$30

	.DropDownSight
		dw $0000,$0000 : db $10,$FF

	.WrapAroundX
		db $01,$0F

	.CornerDirection
		db $00,$01,$00,$00

	.WallDirection
		db $00,$00,$01,$00

	.WallCollision
		db $01,$02

	.WallAnim
		db !Slime_WallDown
		db !Slime_WallUp
	.WallAnimOver
		db !Slime_WallDown_over
		db !Slime_WallUp_over

	.WallAccelFrame
		db !Slime_WallDown+1
		db !Slime_WallUp+1

	namespace off





