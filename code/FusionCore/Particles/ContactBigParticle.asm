



; for this particle, bit 6 of X speed is used as X flip flag

	ContactBigParticle:
		LDX $00							; reload index
		SEP #$20						; 8-bit A
		LDA #$02 : STA !Particle_TileTemp+2			; tile size

		LDA !Particle_Tile,x : STA !Particle_TileTemp		; base tile
		LDA !Particle_Timer,x : BEQ .NoTimer			;\ check and decrement timer
		DEC !Particle_Timer,x					;/
		CMP #$04 : BCS .TileDone				;\
		INC !Particle_TileTemp					; | tile animation
		INC !Particle_TileTemp					; |
		.TileDone						;/

		LDA !Particle_Prop,x					;\
		AND #$3F						; |
		STA !Particle_TileTemp+1				; | prop
		LDA !Particle_XSpeed,x					; |
		AND #$40 : TSB !Particle_TileTemp+1			;/
		REP #$20						; 16-bit A
		JSR ParticleDrawSimple_BG1				; draw particle without ratio

		LDA !Particle_YLo,x : PHA				;\
		CLC : ADC #$0018					; |
		STA !Particle_YLo,x					; |
		LDA !Particle_TileTemp+1				; |
		EOR #$00C0						; |
		STA !Particle_TileTemp+1				; |
		LDA !Particle_XLo,x : PHA				; |
		LDA #$FFF8						; | draw second tile
		BIT !Particle_TileTemp+1-1				; |
		BVC $04 : EOR #$FFFF : INC A				; |
		CLC : ADC !Particle_XLo,x				; |
		STA !Particle_XLo,x					; |
		JSR ParticleDrawSimple_BG1				; |
		PLA : STA !Particle_XLo,x				; |
		PLA : STA !Particle_YLo,x				;/

		JMP ParticleDespawn					; off-screen check

		.NoTimer						;\
		LDA.b #(ParticleMain_List_End-ParticleMain_List)/2	; |
		STA !Particle_Type,x					; | if timer hits 0, erase particle and set index to the one that was just freed up
		REP #$20						; | then return
		TXA : STA.l !Particle_Index				; |
		RTS							;/



