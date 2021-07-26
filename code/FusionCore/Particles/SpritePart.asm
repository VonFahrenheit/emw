
	SpritePart:
		LDX $00							; reload index
		SEP #$20						; 8-bit A
		LDA !Particle_Timer,x : BEQ .NoTimer			;\ check and decrement timer
		DEC !Particle_Timer,x					;/
		JSR ParticleSpeed					; move particle
		LDA !Particle_Tile,x : STA !Particle_TileTemp		; tile number + property byte
		PHA							;\
		ORA #$C000						; | _p3, push prop
		STA !Particle_Tile,x					;/
		LDA !Particle_Layer,x					;\
		AND #$0002						; | oam size bit
		STA !Particle_TileTemp+2				;/
		JSR ParticleDrawSimple_BG1				; draw particle without ratio
		JSR ParticleDespawn					; off-screen check
		PLA : STA !Particle_Tile,x				; restore prop
		RTS							; return

		.NoTimer						;\
		LDA.b #(ParticleMain_List_End-ParticleMain_List)/2	; |
		STA !Particle_Type,x					; | if timer hits 0, erase particle and set index to the one that was just freed up
		REP #$20						; | then return
		TXA : STA.l !Particle_Index				; |
		RTS							;/
