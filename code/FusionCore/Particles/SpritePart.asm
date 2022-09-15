
; decrementing timer (if set to 0x00, timer is infinite)

	SpritePart:
		LDX $00							; reload index
		LDA !Particle_Type-1,x : BPL .Main			;\
		.Stall							; |
		AND #$7FFF : STA !Particle_Type-1,x			; | stall 1 frame if highest bit is set (instead of using air resistance)
		RTS							; |
		.Main							;/
		SEP #$20						; 8-bit A
		LDA !Particle_Timer,x : BEQ +				;\ check and decrement timer
		DEC !Particle_Timer,x : BEQ .NoTimer			;/
	+	JSR ParticleSpeed					; move particle
		LDA !Particle_Tile,x : PHA				; push prop
		ORA #$3000 : STA !Particle_TileTemp			; tile number + property byte (p = 3)
		LDA $01,s						;\
		ORA #$C000						; | _p3
		STA !Particle_Tile,x					;/
		LDA !Particle_Layer,x					;\
		AND #$0002						; | oam size bit
		STA !Particle_TileTemp+2				;/
		JSR ParticleDrawSimple_BG1				; draw particle without ratio
		JSR ParticleDespawn					; off-screen check
		PLA : STA !Particle_Tile,x				; restore prop

		.Return							;\ return
		RTS							;/

		.NoTimer						;\
		LDA.b #(ParticleMain_List_End-ParticleMain_List)/2	; |
		STA !Particle_Type,x					; | if timer hits 0, erase particle and set index to the one that was just freed up
		REP #$20						; | then return
		TXA : STA.l !Particle_Index				; |
		RTS							;/



