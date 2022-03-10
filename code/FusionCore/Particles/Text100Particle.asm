
; timer = 0


	Text100Particle:
		LDX $00							; reload index

		STZ !Particle_XSpeed,x					;\ set speed
		LDA #$FF80 : STA !Particle_YSpeed,x			;/


		SEP #$20						; 8-bit A
		LDA !Particle_Timer,x					;\ check and increment timer
		INC !Particle_Timer,x					;/
		CMP #$20 : BEQ .NoTimer
		CMP #$10 : BCC .Move
		AND #$02
		REP #$20
		BEQ .Draw
		RTS


		.Move
		JSR ParticleSpeed					; move particle

		.Draw
		LDA #$C000 : STA !Particle_Tile,x			; _p3
		LDA #$3464 : STA !Particle_TileTemp			; left tile
		STZ !Particle_TileTemp+2				; OAM size bit
		JSR ParticleDrawSimple_BG1				; draw particle without ratio
		LDA !Particle_X,x : PHA					;\
		CLC : ADC #$0008					; | push X, add 8
		STA !Particle_X,x					;/
		LDA #$3465 : STA !Particle_TileTemp			; left tile
		STZ !Particle_TileTemp+2				; OAM size bit
		JSR ParticleDrawSimple_BG1				; draw particle without ratio
		PLA : STA !Particle_X,x					; restore X
		JSR ParticleDespawn					; off-screen check
		RTS							; return

		.NoTimer						;\
		LDA.b #(ParticleMain_List_End-ParticleMain_List)/2	; |
		STA !Particle_Type,x					; | if timer hits 0, erase particle and set index to the one that was just freed up
		REP #$20						; | then return
		TXA : STA.l !Particle_Index				; |
		RTS							;/


