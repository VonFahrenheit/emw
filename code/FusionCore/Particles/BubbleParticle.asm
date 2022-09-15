
; incrementing timer (looping)

	BubbleParticle:
		LDX $00							; reload index

		.UpdateTimer
		SEP #$20						; 8-bit A
		INC !Particle_Timer,x					;\
		LDA !Particle_Timer,x					; |
		REP #$20						; |
		AND #$000F						; |
		BIT #$0003 : BNE ..done					; | move sideways
		AND #$000C : BEQ ..r					; |
		CMP #$0004 : BEQ ..r					; |
	..l	DEC !Particle_X,x : BRA ..done				; |
	..r	INC !Particle_X,x					; |
		..done							;/

		DEC !Particle_Y,x					; move up


		.WaterCheck
		LDA.l !3DWater						;\
		AND #$00FF : BEQ ..map16				; | skip map16 check if bubble is below 3D water surface
		LDA !Particle_Y,x : BMI ..map16				; |
		CMP.l !Level+2 : BCS ..done				;/
		..map16							;\
		PHX							; |
		PHP							; |
		LDA !Particle_Y,x					; |
		CLC : ADC #$0004					; |
		TAY							; |
		LDA !Particle_X,x					; |
		CLC : ADC #$0004					; | otherwise, bubble must be in a water tile or despawn
		TAX							; |
		PHB : PHK : PLB						; |
		JSL GetMap16						; |
		PLB							; |
		PLP							; |
		PLX							; |
		CMP #$0004 : BCS .Despawn				; |
		..done							;/


		JSR ParticleSpeed					; move particle

		LDA !GFX_WaterEffects					;\
		CLC : ADC #$0004					; |
		ORA #$3600 : STA !Particle_TileTemp			; | draw particle without ratio
		STZ !Particle_TileTemp+2				; |
		JSR ParticleDrawSimple_BG1				;/
		JMP ParticleDespawn					; off-screen check



		.Despawn						;\
		LDA.w #(ParticleMain_List_End-ParticleMain_List)/2	; > note the .w
		STA !Particle_Type,x					; | erase when leaving water
		TXA : STA.l !Particle_Index				; |
		RTS							;/



