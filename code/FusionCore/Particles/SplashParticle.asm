;
; _Tile		splash type
;		0 - water splash
;		1 - lava splash
;		2 - full water splash (with 16x16 splash + puff)
; _Prop		sprite weight
; _Layer	copied to spawned particles
; _XSpeed	sprite's input X speed (converted to particle format by sprite)
; _YSpeed	sprite's input Y speed (converted to particle format by sprite)
;
; incrementing timer

	SplashParticle:
		LDX $00							; reload index
		SEP #$20						; 8-bit A

		LDA !Particle_Tile,x
		CMP #$02 : BNE .OtherSplash

		.FullWaterSplash
		LDA !Particle_Timer,x					;\
		CMP #$10 : BCC .SpawnParticle				; | check which stage water splash is in
		CMP #$20 : BCC .Splash16x16				;/

		.Smoke
		REP #$20						;\
		STZ !Particle_XSpeed,x					; |
		STZ !Particle_YSpeed,x					; |
		SEP #$20						; |
		STZ !Particle_XAcc,x					; | transform into smoke puff
		STZ !Particle_YAcc,x					; |
		LDA.b #!prt_smoke16x16 : STA !Particle_Type,x		; |
		LDA #$08 : STA !Particle_Timer,x			; |
		JMP SmokeParticle16x16					;/

		.OtherSplash
		LDA !Particle_Timer,x
		CMP #$10 : BCC .SpawnParticle

		.End
		INC !Particle_Timer,x
		REP #$20
		JMP ParticleDespawn

		.Splash16x16
		AND #$08						;\ C is already cleared
		BEQ $02 : LDA #$02					;/
		ADC !GFX_WaterEffects_tile				;\
		STA !Particle_TileTemp					; |
		LDA !GFX_WaterEffects_prop				; | get tile settings
		ORA #$36 : STA !Particle_TileTemp+1			; |
		LDA #$02 : STA !Particle_TileTemp+2			;/
		INC !Particle_Timer,x					; inc timer
		REP #$20						; A 16-bit
		JSR ParticleDrawSimple_BG1				; draw particle without ratio
		JMP ParticleDespawn					; off-screen check

		.SpawnParticle
		TXY							;\
		JSL GetParticleIndex					; |
		LDA !Particle_X,y : STA !Particle_X,x			; |
		LDA !Particle_Y,y : STA !Particle_Y,x			; |
		LDA !Particle_XSpeed,y : STA !Particle_XSpeed,x		; | spawn particle (shared)
		LDA !Particle_YSpeed,y : STA !Particle_YSpeed,x		; |
		SEP #$20						; |
		LDA #$18 : STA !Particle_YAcc,x				; |
		LDA !Particle_Layer,y : STA !Particle_Layer,x		;/
		LDA !Particle_Tile,y					;\ check splash type
		CMP #$01 : BEQ ..lava					;/

		..water
		LDA #$5E : STA !Particle_Tile,x				;\
		LDA #$30 : STA !Particle_Prop,x				; |
		LDA.b #!prt_spritepart : STA !Particle_Type,x		; | water settings
		LDA #$28 : STA !Particle_Timer,x			; |
		TYX							; |
		JMP .End						;/

		..lava
		LDA.b #!prt_lavaparticle : STA !Particle_Type,x		;\
		TYX							; | lava settings
		JMP .End						;/











