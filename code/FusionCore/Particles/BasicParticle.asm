	BasicParticle:
<<<<<<< Updated upstream
		LDX $00							; reload index
		SEP #$20						;\
		LDA !Particle_Timer,x : BEQ .NoTimer			; | check and decrement timer
		DEC !Particle_Timer,x : BNE .NoTimer			;/
		STZ !Particle_Type,x					;\
		REP #$20						; | if timer hits 0, erase particle and set index to the one that was just freed up
		TXA : STA.l !Particle_Index				; | then return
=======
	.BG1	LDX $00							; reload index
		SEP #$20						; 8-bit A
		LDA !Particle_Timer,x : BEQ +				;\ check and decrement timer
		DEC !Particle_Timer,x : BEQ .NoTimer			;/
	+	JSR ParticleSpeed					; move particle
		LDA !Particle_Tile,x					;\
		AND #$3FFF						; | tile number + property byte (X/Y flip clear)
		STA !Particle_TileTemp					;/
		LDA !Particle_Layer,x					;\
		AND #$0002						; | oam size bit
		STA !Particle_TileTemp+2				;/
		JSR ParticleDrawSimple_BG1				; draw particle without ratio
		JMP ParticleDespawn					; off-screen check

	.BG2	LDX $00							; reload index
		SEP #$20						; 8-bit A
		LDA !Particle_Timer,x : BEQ +				;\ check and decrement timer
		DEC !Particle_Timer,x : BEQ .NoTimer			;/
	+	JSR ParticleSpeed					; move particle
		LDA !Particle_Tile,x					;\
		AND #$3FFF						; | tile number + property byte (X/Y flip clear)
		STA !Particle_TileTemp					;/
		LDA !Particle_Layer,x					;\
		AND #$0002						; | oam size bit
		STA !Particle_TileTemp+2				;/
		JSR ParticleDrawSimple_BG2				; draw particle without ratio
		JMP ParticleDespawn					; off-screen check

		.NoTimer						;\
		LDA.b #(ParticleMain_List_end-ParticleMain_List)/2	; |
		STA !Particle_Type,x					; | if timer hits 0, erase particle and set index to the one that was just freed up
		REP #$20						; | then return
		TXA : STA.l !Particle_Index				; |
>>>>>>> Stashed changes
		RTS							;/
		.NoTimer
		JSR ParticleSpeed					; move particle
		LDA !Particle_Tile,x					;\
		AND #$3FFF						; | tile number + property byte (X/Y flip clear)
		STA !Particle_TileTemp					;/
		LDA !Particle_Layer,x					;\
		AND #$0010						; | oam size bit
		BEQ $03 : LDA #$0002					; |
		STA !Particle_TileTemp+2				;/
		JMP ParticleDraw					; draw particle