
; incrementing timer (ends at ..end)
; tile + prop are hardcoded

	SparkleSmallParticle:
		LDX $00							; reload index
		SEP #$20						; 8-bit A
		STZ !Particle_TileTemp+2				; size = 8x8
		LDA !Particle_Timer,x					;\
		CMP.b #.TileNum_end-.TileNum : BEQ .NoTimer		; | timer
		INC !Particle_Timer,x					;/

		REP #$20						;\
		AND #$00FF : TAX					; |
		LDA.l .TileNum,x					; | get tile num + prop
		LDX $00							; |
		AND #$00FF						; |
		ORA #$3600 : STA !Particle_TileTemp			;/

		JSR ParticleSpeed					; move particle
		JSR ParticleDrawSimple_BG1				; draw particle without ratio
		JMP ParticleDespawn					; off-screen check

		.NoTimer						;\
		LDA.b #(ParticleMain_List_End-ParticleMain_List)/2	; |
		STA !Particle_Type,x					; | if timer hits 0, erase particle and set index to the one that was just freed up
		REP #$20						; | then return
		TXA : STA.l !Particle_Index				; |
		RTS							;/

		.TileNum
		db $5A
		rep 2 : db $59
		rep 4 : db $58
		rep 8 : db $59
		rep 8 : db $5A
		..end


