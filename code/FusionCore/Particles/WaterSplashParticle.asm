
; incrementing timer

	WaterSplashParticle:
		LDX $00							; reload index
		SEP #$20						; 8-bit A

		LDA !Particle_Timer,x					;\
		CMP #$10 : BCC .Process					; |
		REP #$20						; |
		STZ !Particle_XSpeed,x					; |
		STZ !Particle_YSpeed,x					; |
		SEP #$20						; | after 16 frames, transform into smoke puff
		STZ !Particle_XAcc,x					; |
		STZ !Particle_YAcc,x					; |
		LDA.b #!prt_smoke16x16 : STA !Particle_Type,x		; |
		LDA #$08 : STA !Particle_Timer,x			; |
		JMP SmokeParticle16x16					;/

		.Process
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


