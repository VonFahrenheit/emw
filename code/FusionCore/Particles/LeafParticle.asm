
; incrementing timer
	LeafParticle:
		LDX $00							; reload index
		SEP #$20						; 8-bit A
		INC !Particle_Timer,x					; increment timer

		JSR ParticleSpeed					; move particle
		LDA !Particle_Tile,x
		AND #$3000
		ORA #$0A00
		ORA !GFX_LeafParticle
		STA !Particle_TileTemp					;/

		LDA !Particle_Tile,x
		AND #$0040
		TSB !Particle_TileTemp+1

		LDA !Particle_Timer,x
		AND #$0010 : BEQ +
		CLC : ADC !Particle_TileTemp
		STA !Particle_TileTemp

	+	STZ !Particle_TileTemp+2				;
		JSR ParticleDrawSimple_BG1				; draw particle without ratio
		JMP ParticleDespawn					; off-screen check


