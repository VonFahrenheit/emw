

; timer: 07 tops

	ContactParticle:
		LDX $00							; reload index
		SEP #$20						; 8-bit A
		LDA !Particle_Timer,x : BEQ .NoTimer			;\ check and decrement timer
		DEC !Particle_Timer,x					;/
		REP #$20						; 16-bit A
		PHX							;\
		LDA !Particle_Timer,x					; |
		AND #$00FF						; | get tile num
		TAX							; |
		LDA.l $0297CB,x						; |
		AND #$00FF						;/
		ORA #$3400						;\
		STA !Particle_TileTemp					; | 16x16 size
		PLX							;/
		LDA #$0002 : STA !Particle_TileTemp+2			; oam size bit
		JMP ParticleDrawSimple_BG1				; draw particle without ratio

		.NoTimer						;\
		LDA.b #(ParticleMain_List_End-ParticleMain_List)/2	; |
		STA !Particle_Type,x					; | if timer hits 0, erase particle and set index to the one that was just freed up
		REP #$20						; | then return
		TXA : STA.l !Particle_Index				; |
		RTS							;/



