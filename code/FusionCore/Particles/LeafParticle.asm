
	LeafParticle:
		LDX $00							; reload index
		SEP #$20						; 8-bit A
		LDA !Particle_Timer,x : BEQ .NoTimer			;\ check and decrement timer
		DEC !Particle_Timer,x					;/

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

		.NoTimer						;\
		LDA.b #(ParticleMain_List_End-ParticleMain_List)/2	; |
		STA !Particle_Type,x					; | if timer hits 0, erase particle and set index to the one that was just freed up
		REP #$20						; | then return
		TXA : STA.l !Particle_Index				; |
		RTS							;/

