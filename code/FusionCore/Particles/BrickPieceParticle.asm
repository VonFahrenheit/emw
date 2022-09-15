
; incrementing timer
	BrickPieceParticle:
		LDX $00							; reload index
		SEP #$20						; 8-bit A
		INC !Particle_Timer,x					; update timer
		LDA #$30 : STA !Particle_YAcc,x				; enforce gravity
		STZ !Particle_XAcc,x					; no x acc
		REP #$20

		JSR ParticleSpeed					; move particle

		LDA !Particle_Timer,x					;\
		AND #$0008						; | animation
		ASL A							; |
		ORA #$3444 : STA !Particle_TileTemp			;/
		STZ !Particle_TileTemp+2				; 8x8

		JSR ParticleDrawSimple_BG1				; draw particle without ratio
		JMP ParticleDespawn					; off-screen check

