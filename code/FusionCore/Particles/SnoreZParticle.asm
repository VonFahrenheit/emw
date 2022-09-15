

; incrementing timer (ends at ..end)
; tile + prop are based on !GFX_SnoreZ

	SnoreZParticle:
		LDX $00							; reload index
		SEP #$20						; 8-bit A
		STZ !Particle_TileTemp+2				; size = 8x8
		LDA !Particle_Timer,x					;\
		CMP.b #(.TileNum_end-.TileNum)*4 : BCS .Despawn		; | timer
		INC !Particle_Timer,x					;/

		.UpdateTimer						;\
		REP #$20						; |
		AND #$000F						; |
		BIT #$0003 : BNE ..done					; | move sideways
		DEC !Particle_Y,x					; > move up
		AND #$000C : BEQ ..r					; |
		CMP #$0004 : BEQ ..r					; |
	..l	DEC !Particle_X,x : BRA ..done				; |
	..r	INC !Particle_X,x					; |
		..done							;/

		LDA !Particle_Timer,x					;\
		AND #$00FF						; |
		LSR #2 : TAX						; |
		LDA.l .TileNum,x					; | get tile num + prop
		LDX $00							; |
		AND #$00FF						; |
		CLC : ADC !GFX_SnoreZ					; |
		ORA #$3600 : STA !Particle_TileTemp			;/
		JSR ParticleDrawSimple_BG1				; draw particle without ratio
		JMP ParticleDespawn					; off-screen check

		.Despawn						;\
		LDA.b #(ParticleMain_List_End-ParticleMain_List)/2	; |
		STA !Particle_Type,x					; | if timer hits 0, erase particle and set index to the one that was just freed up
		REP #$20						; | then return
		TXA : STA.l !Particle_Index				; |
		RTS							;/

		.TileNum
		rep 4 : db $00
		rep 7 : db $01
		rep 7 : db $10
		db $11
		..end


