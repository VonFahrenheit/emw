Projectile:

	namespace Projectile

; draw:
;
;	increment !SpriteAnimTimer
;		when hitting !ProjectileAnimTime, reset !SpriteAnimTimer to 0, then increment !SpriteAnimIndex
;		when !SpriteAnimIndex hits !ProjectileAnimFrames, reset !SpriteAnimIndex to 0
;
;	tile = !SpriteTile + !SpriteAnimIndex
;
;	prop = !SpriteProp + $33C0
;
; NOTE:
;	!SpriteTile, !SpriteProp and $33C0 should be set at spawn


	MAIN:
		PHB : PHK : PLB					; bank wrapper start

		LDA $3230,x					;\
		CMP #$08 : BEQ .Process				; |
		.Return						; | don't process outside of state 8
		PLB						; |
		RTL						;/
		.Process					;\ check if should be processed
		LDA $9D : BNE GRAPHICS				;/

		JSL SPRITE_OFF_SCREEN				; despawn off-screen
		LDA !ProjectileTimer,x				;\
		CMP #$01 : BNE .Alive				; |
		JSR Death					; | die if timer runs out
		BRA GRAPHICS					; |
		.Alive						;/
		JSR Physics					; execute physics code

		STZ $2250					; set multiplication
		REP #$30					;\
		LDA !ProjectileType,x				; |
		AND #$003F					; |
		STA $00						; | Y = type * 6
		ASL A						; |
		ADC $00						; |
		ASL A						; |
		TAY						;/
		LDA.w Hitbox+4,y : STA $06			; w + h
		SEP #$20					; A 8-bit
		LDA.w Hitbox+0,y				;\
		CLC : ADC !SpriteXLo,x				; |
		STA $04						; | x
		LDA.w Hitbox+1,y				; |
		ADC !SpriteXHi,x				; |
		STA $0A						;/
		LDA.w Hitbox+2,y				;\
		CLC : ADC !SpriteYLo,x				; |
		STA $05						; | y
		LDA.w Hitbox+3,y				; |
		ADC !SpriteYHi,x				; |
		STA $0B						;/
		SEP #$30					; all regs 8-bit

		SEC : JSL !PlayerClipping			;\ check player contact
		BCC .NoContact					;/
		JSL !HurtPlayers				;\ hurt players
		.NoContact					;/


		JSR ParticlePattern				; particles


	GRAPHICS:
		LDA !SpriteAnimTimer				;\
		INC A						; | increment anim timer
		CMP !ProjectileAnimTime,x : BNE .SameAnim	;/
		.NewAnim					;\
		LDA $33C0,x					; |
		AND #$10					; | add 1 for 8x8 tile or 2 for 16x16 tile
		BEQ $02 : LDA #$01				; |
		INC A						; |
		CLC : ADC !SpriteAnimIndex			;/
		CMP !ProjectileAnimFrames,x : BCC .SameCycle	;\
		.NewCycle					; |
		LDA #$00					; | update anim frame
		.SameCycle					; |
		STA !SpriteAnimIndex				;/
		LDA #$00					;\
		.SameAnim					; | update anim timer
		STA !SpriteAnimTimer				;/


		LDA !SpriteProp,x				;\
		ORA $33C0,x					; | base prop = !SpriteProp|$33C0
		STA !BigRAM+2					;/
		TXA						;\
		CLC : ADC $14					; |
		AND #$02					; |
		BEQ $02 : LDA #$C0				; | apply flip bits
		AND !ProjectileAnimType,x			; |
		EOR !BigRAM+2					; |
		STA !BigRAM+2					;/
		LDA !SpriteAnimIndex				;\
		CLC : ADC !SpriteTile,x				; | tile = !SpriteAnimIndex + !SpriteTile
		STA !BigRAM+5					;/
		REP #$20					;\ size = 4 bytes
		LDA #$0004 : STA !BigRAM+0			;/
		STZ !BigRAM+3					; Xdisp and Ydisp both = 0
		LDA.w #!BigRAM : STA $04			;\ pointer
		SEP #$20					;/

		LDA !ProjectileAnimType,x			;\
		AND #$30 : BEQ .p0				; |
		CMP #$10 : BEQ .p1				; |
		CMP #$20 : BEQ .p2				; | get OAM prio and draw tilemap
	.p3	JSL LOAD_TILEMAP_p3 : BRA .Return		; |
	.p2	JSL LOAD_TILEMAP_p2 : BRA .Return		; |
	.p1	JSL LOAD_TILEMAP_p1 : BRA .Return		; |
	.p0	JSL LOAD_TILEMAP_p0				;/

		.Return
		PLB						; bank wrapper end
	INIT:
		RTL						; return



	Death:
		LDA !ProjectileType,x				;\
		AND #$3F					; |
		ASL A						; | second (death) pointer
		INC A						; |
		ASL A						;/
		BRA Physics_GetPointer				; go to shared code



	Physics:
		LDA !ProjectileType,x				;\
		AND #$3F					; | first (init/main) pointer
		ASL #2						;/
		.GetPointer					;\
		CMP.b #.Ptr_end-.Ptr				; |
		BCC $02 : AND #$02				; | execute pointer
		TAX						; |
		JMP (.Ptr,x)					;/

		.Ptr
		dw Basic,Basic_Death				; 00
		dw Homing,Homing_Death				; 01
		..end


	Basic:
		LDX !SpriteIndex				; X = sprite index
		JSR Speed					; speed
		LDA $3330,x : BNE .Death			; kill upon touching an object
		RTS						; return

		.Death
		LDX !SpriteIndex				; X = sprite index
		LDA #$04 : STA $3230,x
		LDA #$1B : STA $32D0,x
		RTS



	Homing:
		LDX !SpriteIndex				; X = sprite index
		LDA !ExtraBits,x : BMI .Main			;\
		.Init						; |
		ORA #$80 : STA !ExtraBits,x			; |
		LDA !RNG					; |
		AND #$80					; |
		TAY						; |
		LDA !P2Status-$80,y : BEQ ..target		; | init random target player
		TYA						; |
		EOR #$80					; |
		TAY						; |
		..target					; |
		TYA : STA !ProjectileTarget,x			; |
		.Main						;/

		LDY !ProjectileTarget,x				;\
		LDA !SpriteXLo,x : STA $00			; |
		LDA !SpriteXHi,x : STA $01			; |
		LDA !SpriteYHi,x : XBA				; |
		LDA !SpriteYLo,x				; |
		REP #$20					; |
		SEC : SBC !P2YLo-$80,y				; |
		STA $02						; | accelerate towards target
		LDA $00						; |
		SEC : SBC !P2XLo-$80,y				; |
		STA $00						; |
		SEP #$20					; |
		LDA !ProjectileHomingSpeed,x			; |
		JSL AIM_SHOT					; |
		LDA $04 : JSL AccelerateX_Unlimit1		; |
		LDA $06 : JSL AccelerateY_Unlimit1		;/

		JSR Speed					; speed
		LDA $3330,x : BNE .Death			; kill upon touching an object
		RTS						; return

		.Death
		LDX !SpriteIndex				; X = sprite index
		LDA #$04 : STA $3230,x
		LDA #$1B : STA $32D0,x
		RTS


	Speed:
		BIT !ProjectileType,x : BMI .PhaseDone		;\
		LDA #$02 : STA !SpritePhaseTimer,x		; | phase if no collision
		.PhaseDone					;/
		LDA !SpriteGravityMod,x : PHA			;\ push gravity regs
		LDA !SpriteGravityTimer,x : PHA			;/
		LDA !ProjectileGravity,x			;\
		SEC : SBC #$03					; |
		CLC : ADC !SpriteGravityMod,x			; | gravity = set gravity - global gravity + gravity mod
		STA !SpriteGravityMod,x				; |
		LDA #$02 : STA !SpriteGravityTimer,x		;/
		JSL !SpriteApplySpeed				; apply speed
		PLA : BEQ .Clear				;\
		DEC A : BNE .NoClear				; |
		.Clear						; | clear gravity regs when timer hits 0
		PLA						; |
		STZ !SpriteGravityMod,x				; |
		BRA .GravityDone				;/
		.NoClear					;\
		STA !SpriteGravityTimer,x			; | otherwise update gravity regs as normal
		PLA : STA !SpriteGravityMod,x			; |
		.GravityDone					;/
		RTS						; return



	Hitbox:
		dw $0002,$0002 : db $0C,$0C			; 00
		dw $0002,$0002 : db $0C,$0C			; 01



	ParticlePattern:
		LDA !ProjectileAnimType,x			;\
		AND #$0F : BNE .Process				; | return if there is no particle pattern
		RTS						;/
		.Process					;\
		DEC A						; |
		ASL A						; | $0F = pointer index
		CMP.b #.Ptr_end-.Ptr				; |
		BCC $02 : LDA #$00				; |
		STA $0F						;/

		LDA !ProjectilePrt00,x : STA $00		;\
		LDA !ProjectilePrt01,x : STA $01		; |
		LDA !ProjectilePrt02,x : STA $02		; |
		LDA !ProjectilePrt03,x : STA $03		; | particle parameters
		LDA !ProjectilePrt04,x : STA $04		; |
		LDA !ProjectilePrt05,x : STA $05		; |
		LDA !ProjectilePrt06,x : STA $06		; |
		LDA !ProjectilePrt07,x : STA $07		;/

		LDX $0F						;\ execute pointer
		JMP (.Ptr,x)					;/

		.Ptr
		dw ConstantParticle				; 01
		dw EndingParticle				; 02
		..end


	ConstantParticle:
		LDX !SpriteIndex				; X = sprite index
		TXA						;\
		CLC : ADC $14					; | spawn every 4 frames
		AND #$03 : BNE .Return				;/
		LDA !ProjectilePrtNum,x	 : JSL SpawnParticle	; spawn particle
		.Return						;\ return
		RTS						;/


	EndingParticle:
		LDX !SpriteIndex				; X = sprite index
		LDA !ProjectileTimer,x : BEQ .Return		;\ spawn each frame during last 8 frames of life time
		CMP #$09 : BCS .Return				;/
		LDA !SpriteXSpeed,x				;\
		LSR A						; |
		CMP #$40					; |
		BCC $02 : ORA #$80				; |
		STA $02						; | X speed
		LDA !RNG					; |
		LSR #4						; |
		SEC : SBC #$08					; |
		CLC : ADC $02					; |
		STA $02						;/


		LDA !SpriteYSpeed,x				;\
		LSR A						; |
		CMP #$40					; | Y speed
		BCC $02 : ORA #$80				; |
		STA $03						;/
		LDA !RNG					;\
		AND #$07					; | Y acc (X acc = 0)
		SEC : SBC #$05					; |
		STA $05						;/
		LDA !ProjectilePrtNum,x	 : JSL SpawnParticle	; spawn particle
		.Return						;\ return
		RTS						;/



	namespace off













