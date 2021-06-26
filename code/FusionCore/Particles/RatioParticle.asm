
	RatioParticle:
	.BG1	LDX $00							; reload index
		SEP #$20						; 8-bit A
		LDA !Particle_Timer,x : BEQ .NoTimer			;\ check and decrement timer
		DEC !Particle_Timer,x					;/
		JSR ParticleSpeed					; move particle
		LDA !Particle_Tile,x					;\
		AND #$3FFF						; | tile number + property byte (X/Y flip clear)
		STA !Particle_TileTemp					;/
		LDA !Particle_Layer,x					;\
		AND #$0002						; | oam size bit
		STA !Particle_TileTemp+2				;/
		JMP ParticleDrawRatio_BG1				; draw particle with ratio

	.BG2	LDX $00							; reload index
		SEP #$20						; 8-bit A
		LDA !Particle_Timer,x : BEQ .NoTimer			;\ check and decrement timer
		DEC !Particle_Timer,x					;/
		JSR ParticleSpeed					; move particle
		LDA !Particle_Tile,x					;\
		AND #$3FFF						; | tile number + property byte (X/Y flip clear)
		STA !Particle_TileTemp					;/
		LDA !Particle_Layer,x					;\
		AND #$0002						; | oam size bit
		STA !Particle_TileTemp+2				;/
		JMP ParticleDrawRatio_BG2				; draw particle with ratio

	.BG3	LDX $00							; reload index
		SEP #$20						; 8-bit A
		LDA !Particle_Timer,x : BEQ .NoTimer			;\ check and decrement timer
		DEC !Particle_Timer,x					;/
		JSR ParticleSpeed					; move particle
		LDA !Particle_Tile,x					;\
		AND #$3FFF						; | tile number + property byte (X/Y flip clear)
		STA !Particle_TileTemp					;/
		LDA !Particle_Layer,x					;\
		AND #$0002						; | oam size bit
		STA !Particle_TileTemp+2				;/
		JMP ParticleDrawRatio_BG3				; draw particle with ratio

	.Cam	LDX $00							; reload index
		SEP #$20						; 8-bit A
		LDA !Particle_Timer,x : BEQ .NoTimer			;\ check and decrement timer
		DEC !Particle_Timer,x					;/
		JSR ParticleSpeed					; move particle
		LDA !Particle_Tile,x					;\
		AND #$3FFF						; | tile number + property byte (X/Y flip clear)
		STA !Particle_TileTemp					;/
		LDA !Particle_Layer,x					;\
		AND #$0002						; | oam size bit
		STA !Particle_TileTemp+2				;/
		JMP ParticleDrawRatio_Cam				; draw particle with ratio

		.NoTimer						;\
		LDA.b #(ParticleMain_List_End-ParticleMain_List)/2	; |
		STA !Particle_Type,x					; | if timer hits 0, erase particle and set index to the one that was just freed up
		REP #$20						; | then return
		TXA : STA.l !Particle_Index				; |
		RTS							;/

