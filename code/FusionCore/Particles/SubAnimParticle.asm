
	SubAnimParticle:
	.BG1	LDX $00							; reload index
		SEP #$20						; 8-bit A
		LDA !Particle_Layer,x					;\
		AND #$02						; | size
		STA !Particle_TileTemp+2				;/
		LDA !Particle_Timer,x : BEQ .NoTimer			;\ check and decrement timer
		DEC !Particle_Timer,x					;/
		LSR #3							;\
		AND #$03						; |
		LDY !Particle_TileTemp+2				; |
		BEQ $01 : ASL A						; | tile
		EOR #$FF : INC A					; |
		CLC : ADC !Particle_Tile,x				; |
		STA !Particle_TileTemp					;/
		LDA !Particle_Prop,x					;\
		AND #$3F						; | prop
		STA !Particle_TileTemp+1				;/
		REP #$20						; 16-bit A
		JSR ParticleSpeed					; move particle
		JMP ParticleDrawSimple_BG1				; draw particle without ratio

	.BG2	LDX $00							; reload index
		SEP #$20						; 8-bit A
		LDA !Particle_Layer,x					;\
		AND #$02						; | size
		STA !Particle_TileTemp+2				;/
		LDA !Particle_Timer,x : BEQ .NoTimer			;\ check and decrement timer
		DEC !Particle_Timer,x					;/
		LSR #3							;\
		AND #$03						; |
		LDY !Particle_TileTemp+2				; |
		BEQ $01 : ASL A						; | tile
		EOR #$FF : INC A					; |
		CLC : ADC !Particle_Tile,x				; |
		STA !Particle_TileTemp					;/
		LDA !Particle_Prop,x					;\
		AND #$3F						; | prop
		STA !Particle_TileTemp+1				;/
		REP #$20						; 16-bit A
		JSR ParticleSpeed					; move particle
		JMP ParticleDrawSimple_BG2				; draw particle without ratio

		.NoTimer						;\
		LDA.b #(ParticleMain_List_End-ParticleMain_List)/2	; |
		STA !Particle_Type,x					; | if timer hits 0, erase particle and set index to the one that was just freed up
		REP #$20						; | then return
		TXA : STA.l !Particle_Index				; |
		RTS							;/

	.BG3	LDX $00							; reload index
		SEP #$20						; 8-bit A
		LDA !Particle_Layer,x					;\
		AND #$02						; | size
		STA !Particle_TileTemp+2				;/
		LDA !Particle_Timer,x : BEQ .NoTimer			;\ check and decrement timer
		DEC !Particle_Timer,x					;/
		LSR #3							;\
		AND #$03						; |
		LDY !Particle_TileTemp+2				; |
		BEQ $01 : ASL A						; | tile
		EOR #$FF : INC A					; |
		CLC : ADC !Particle_Tile,x				; |
		STA !Particle_TileTemp					;/
		LDA !Particle_Prop,x					;\
		AND #$3F						; | prop
		STA !Particle_TileTemp+1				;/
		REP #$20						; 16-bit A
		JSR ParticleSpeed					; move particle
		JMP ParticleDrawSimple_BG3				; draw particle without ratio

	.Cam	LDX $00							; reload index
		SEP #$20						; 8-bit A
		LDA !Particle_Layer,x					;\
		AND #$02						; | size
		STA !Particle_TileTemp+2				;/
		LDA !Particle_Timer,x : BEQ .NoTimer			;\ check and decrement timer
		DEC !Particle_Timer,x					;/
		LSR #3							;\
		AND #$03						; |
		LDY !Particle_TileTemp+2				; |
		BEQ $01 : ASL A						; | tile
		EOR #$FF : INC A					; |
		CLC : ADC !Particle_Tile,x				; |
		STA !Particle_TileTemp					;/
		LDA !Particle_Prop,x					;\
		AND #$3F						; | prop
		STA !Particle_TileTemp+1				;/
		REP #$20						; 16-bit A
		JSR ParticleSpeed					; move particle
		JMP ParticleDrawSimple_Cam				; draw particle without ratio


