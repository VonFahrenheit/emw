; tile + prop are hardcoded
; tile reg is added to timer


	SparkleParticle:
		LDX $00							; reload index
		SEP #$20						; 8-bit A
		STZ !Particle_TileTemp+2				; size = 8x8
		LDA !Particle_Timer,x					;\
		CLC : ADC !Particle_Tile,x				; | check and decrement timer
		BEQ .NoTimer						; | (tile num reg is added to it)
		DEC !Particle_Timer,x					;/
		.CalcTile						;\
		CMP #$18 : BCS ..49					; |
		CMP #$10 : BCS ..4A					; |
		CMP #$08 : BCS ..59					; |
	..5A	LDA #$5A : BRA ..writetile				; | tile number
	..59	LDA #$59 : BRA ..writetile				; |
	..4A	LDA #$4A : BRA ..writetile				; |
	..49	LDA #$49						; |
		..writetile						; |
		STA !Particle_TileTemp					;/
		LDA #$36 : STA !Particle_TileTemp+1			; prop
		REP #$20						; 16-bit A
		JSR ParticleSpeed					; move particle
		JSR ParticleDrawSimple_BG1				; draw particle without ratio
		JMP ParticleDespawn					; off-screen check

		.NoTimer						;\
		LDA.b #(ParticleMain_List_End-ParticleMain_List)/2	; |
		STA !Particle_Type,x					; | if timer hits 0, erase particle and set index to the one that was just freed up
		REP #$20						; | then return
		TXA : STA.l !Particle_Index				; |
		RTS							;/



