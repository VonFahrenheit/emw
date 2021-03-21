	BasicParticle:
		LDX $00							; reload index
		SEP #$20						;\
		LDA !Particle_Timer,x : BEQ .NoTimer			; | check and decrement timer
		DEC !Particle_Timer,x : BNE .NoTimer			;/
		STZ !Particle_Type,x					;\
		REP #$20						; | if timer hits 0, erase particle and set index to the one that was just freed up
		TXA : STA.l !Particle_Index				; | then return
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