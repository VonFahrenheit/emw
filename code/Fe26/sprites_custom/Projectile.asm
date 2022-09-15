

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
;	prop = !SpriteProp + !SpriteOAMProp
;


	MAIN:
		PHB : PHK : PLB					; bank wrapper start

		.Timer
		LDA !ProjectileTimer,x : BEQ ..done		;\
		DEC !ProjectileTimer,x : BNE ..done		; |
		JSR Death					; | die if timer runs out
		BRA GRAPHICS					; |
		..done						;/

		JSR Physics					; execute physics code


		STZ $2250					; set multiplication
		REP #$30					;\
		LDA !ProjectileType,x				; |
		AND #$003F					; |
		STA $00						; | Y = type * 6
		ASL A						; | load hitbox
		ADC $00						; |
		ASL A						; |
		ADC.w #Hitbox					; |
		JSL LOAD_HITBOX					;/
		SEP #$30					; all regs 8-bit

		JSL SpriteAttack_NoKnockback			; attack with no knockback

		JSR ParticlePattern				; particles


	GRAPHICS:
		LDA !SpriteAnimTimer,x				;\
		INC A						; | increment anim timer
		CMP !ProjectileAnimTime,x : BNE .SameAnim	;/
		.NewAnim					;\
		LDA !SpriteOAMProp,x				; |
		AND #$10					; | add 1 for 8x8 tile or 2 for 16x16 tile
		BEQ $02 : LDA #$01				; |
		INC A						; |
		CLC : ADC !SpriteAnimIndex,x			;/
		CMP !ProjectileAnimFrames,x : BCC .SameCycle	;\
		.NewCycle					; |
		LDA #$00					; | update anim frame
		.SameCycle					; |
		STA !SpriteAnimIndex,x				;/
		LDA #$00					;\
		.SameAnim					; | update anim timer
		STA !SpriteAnimTimer,x				;/


		LDA !SpriteProp,x				;\
		ORA !SpriteOAMProp,x				; | base prop = !SpriteProp|$33C0
		STA !BigRAM+2					;/
		TXA						;\
		CLC : ADC $14					; |
		AND #$02					; |
		BEQ $02 : LDA #$C0				; | apply flip bits
		AND !ProjectileAnimType,x			; |
		EOR !BigRAM+2					; |
		STA !BigRAM+2					;/
		LDA !SpriteAnimIndex,x				;\
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
		LDA !SpriteBlocked,x : BNE .Death		; kill upon touching an object
		RTS						; return

		.Death
		LDX !SpriteIndex				; X = sprite index
		LDA #$04 : STA !SpriteStatus,x
		LDA #$1B : STA $32D0,x
		RTS



	Homing:
		LDX !SpriteIndex				; X = sprite index
		LDA !ExtraBits,x				;\
		BIT #$20 : BNE .Main				; |
		.Init						; |
		ORA #$20 : STA !ExtraBits,x			; |
		LDA !RNG					; |
		AND #$80					; |
		TAY						; | init random target player
		LDA !P2Status-$80,y : BEQ ..target		; | (extra bit 0x20 used for init)
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
		LDA !SpriteBlocked,x : BNE .Death		; kill upon touching an object
		RTS						; return

		.Death
		LDX !SpriteIndex				; X = sprite index
		LDA #$04 : STA !SpriteStatus,x
		LDA #$1B : STA $32D0,x
		RTS


	Speed:
		BIT !ProjectileType,x : BMI .PhaseDone		;\
		LDA #$02 : STA !SpritePhaseTimer,x		; | phase if no collision
		.PhaseDone					;/
		JSL APPLY_SPEED					; apply speed
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













