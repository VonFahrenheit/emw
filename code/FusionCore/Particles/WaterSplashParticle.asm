
; incrementing timer

	WaterSplashParticle:
		LDX $00							; reload index
		SEP #$20						; 8-bit A

		LDA !Particle_Timer,x : BEQ .Init			;\
		CMP #$10 : BCC .End					; | check which stage water splash is in
		CMP #$20 : BCC .Process					;/
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

		.End
		INC !Particle_Timer,x
		REP #$20
		JMP ParticleDespawn

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

		.Init
		TXY							;\
		JSL GetParticleIndex					; |
		LDA !Particle_X,y : STA !Particle_X,x			; |
		LDA !Particle_Y,y : STA !Particle_Y,x			; |
		LDA #$00C0 : STA !Particle_XSpeed,x			; |
		LDA #$FE80 : STA !Particle_YSpeed,x			; | spawn particle 1
		LDA #$305E : STA !Particle_Tile,x			; |
		SEP #$20						; |
		LDA #$18 : STA !Particle_YAcc,x				; |
		LDA.b #!prt_spritepart : STA !Particle_Type,x		; |
		LDA #$28 : STA !Particle_Timer,x			; |
		STZ !Particle_Layer,x					;/

		JSL GetParticleIndex					;\
		LDA !Particle_X,y : STA !Particle_X,x			; |
		LDA !Particle_Y,y : STA !Particle_Y,x			; |
		LDA #$FF40 : STA !Particle_XSpeed,x			; |
		LDA #$FE80 : STA !Particle_YSpeed,x			; |
		LDA #$705E : STA !Particle_Tile,x			; | spawn particle 2
		SEP #$20						; |
		LDA #$18 : STA !Particle_YAcc,x				; |
		LDA.b #!prt_spritepart : STA !Particle_Type,x		; |
		LDA #$28 : STA !Particle_Timer,x			; |
		STZ !Particle_Layer,x					; |
		TYX							;/

		JMP .End

