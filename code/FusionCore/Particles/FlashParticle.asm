
	FlashParticle:
		LDX $00
		SEP #$20
		LDA !Particle_Timer,x
		CMP #$10 : BCS .Draw
		AND #$02 : BEQ .Draw
		DEC !Particle_Timer,x
		REP #$20
		JMP ParticleSpeed
		.Draw
		JMP BasicParticle_BG1


