

; timer: 17 tops

	SmokeParticle16x16:
		LDX $00							; reload index
		SEP #$20						; 8-bit A
		LDA !Particle_Timer,x : BEQ .NoTimer			;\ check and decrement timer
		DEC !Particle_Timer,x					;/
		JSR ParticleSpeed					; move particle (this lets smoke be affected by wind)
		PHX							;\
		LDA !Particle_Timer,x					; |
		AND #$00FF						; |
		LSR #2							; | get tile num
		TAX							; |
		LDA.l $0296D8,x						; |
		AND #$00FF						; |
		CMP #$0066 : BEQ .8x8					;/
	.16x16	ORA #$3400						;\
		STA !Particle_TileTemp					; | 16x16 size
		PLX							;/
		LDA #$0002 : STA !Particle_TileTemp+2			; oam size bit
		JMP ParticleDrawSimple_BG1				; draw particle without ratio

	.8x8	LDA #$345E						;\
		STA !Particle_TileTemp					; | 8x8 size
		PLX							;/
		STZ !Particle_TileTemp+2				; oam size bit
		LDA !Particle_XLo,x : PHA				;\
		CLC : ADC #$0004					; |
		STA !Particle_XLo,x					; | move particle 4px right and 4px down
		LDA !Particle_YLo,x : PHA				; |
		CLC : ADC #$0004					; |
		STA !Particle_YLo,x					;/
		JSR ParticleDrawSimple_BG1				; draw particle without ratio
		PLA : STA !Particle_YLo,x				;\ restore position
		PLA : STA !Particle_XLo,x				;/
		RTS							; return

		.NoTimer						;\
		LDA.b #(ParticleMain_List_End-ParticleMain_List)/2	; |
		STA !Particle_Type,x					; | if timer hits 0, erase particle and set index to the one that was just freed up
		REP #$20						; | then return
		TXA : STA.l !Particle_Index				; |
		RTS							;/



