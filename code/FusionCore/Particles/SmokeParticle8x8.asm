
; incrementing timer (ends at 0x10)

	SmokeParticle8x8:
		LDX $00							; reload index
		SEP #$20						; 8-bit A
		LDA !Particle_Timer,x					;\
		CMP.b #(.TileNum_end-.TileNum)*4 : BCS .NoTimer		; | timer
		INC !Particle_Timer,x					;/

		PHX							;\
		REP #$20						; |
		AND #$00FF						; |
		LSR #2 : TAX						; |
		LDA.l .TileNum,x					; | get tile num
		AND #$00FF						; |
		ORA #$3400						; |
		STA !Particle_TileTemp					; |
		PLX							;/
		STZ !Particle_TileTemp+2				; oam size bit

		JSR ParticleSpeed					; move particle (this lets smoke be affected by wind)
		JSR ParticleDrawSimple_BG1				; draw particle without ratio
		JMP ParticleDespawn					; off-screen check


		.NoTimer						;\
		LDA.b #(ParticleMain_List_end-ParticleMain_List)/2	; |
		STA !Particle_Type,x					; | if timer hits 0, erase particle and set index to the one that was just freed up
		REP #$20						; | then return
		TXA : STA.l !Particle_Index				; |
		RTS							;/


		.TileNum
		rep 2 : db $5D
		db $5E
		rep 2 : db $5F
		..end




