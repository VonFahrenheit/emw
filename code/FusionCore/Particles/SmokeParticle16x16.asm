
; incrementing timer (ends at 0x18)

	SmokeParticle16x16:
		LDX $00							; reload index
		SEP #$20						; 8-bit A
		LDA !Particle_Timer,x					;\
		CMP #$18 : BCS .NoTimer					; | check and increment timer
		INC !Particle_Timer,x					;/
		JSR ParticleSpeed					; move particle (this lets smoke be affected by wind)
		PHX							;\
		LDA !Particle_Timer,x					; |
		AND #$00FF						; |
		LSR #2							; |
		TAX							; | get tile num
		LDA.l .TileNum,x					; |
		AND #$00FF						; |
		ORA #$3400						; |
		STA !Particle_TileTemp					; |
		CMP #$3460 : BCC .8x8					;/
	.16x16	PLX							; restore index
		LDA #$0002 : STA !Particle_TileTemp+2			; oam size bit
		JSR ParticleDrawSimple_BG1				; draw particle without ratio
		JMP ParticleDespawn					; off-screen check

	.8x8	PLX							; restore index
		STZ !Particle_TileTemp+2				; oam size bit
		LDA !Particle_XLo,x : PHA				;\
		CLC : ADC #$0004					; |
		STA !Particle_XLo,x					; | move particle 4px right and 4px down
		LDA !Particle_YLo,x : PHA				; |
		CLC : ADC #$0004					; |
		STA !Particle_YLo,x					;/
		JSR ParticleDrawSimple_BG1				; draw particle without ratio
		JSR ParticleDespawn					; off-screen check
		PLA : STA !Particle_YLo,x				;\ restore position
		PLA : STA !Particle_XLo,x				;/
		RTS							; return

		.NoTimer						;\
		LDA.b #(ParticleMain_List_End-ParticleMain_List)/2	; |
		STA !Particle_Type,x					; | if timer hits 0, erase particle and set index to the one that was just freed up
		REP #$20						; | then return
		TXA : STA.l !Particle_Index				; |
		RTS							;/



		.TileNum
		db $60,$60,$5D,$5D,$5E,$5F,$5F



