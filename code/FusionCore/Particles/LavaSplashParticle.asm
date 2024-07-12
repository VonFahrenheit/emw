
; incrementing timer

	LavaSplashParticle:
		LDX $00							; reload index
		SEP #$20
		LDA !Particle_Timer,x
		CMP #$08 : BCS .NoTimer
		INC !Particle_Timer,x
		REP #$20

		TXY							;\
		JSL GetParticleIndex					; |
		LDA !Particle_X,y : STA !Particle_X,x			; |
		LDA !Particle_Y,y : STA !Particle_Y,x			; |
		LDA.l !RNG						; |
		SEC : SBC #$0080					; |
		AND #$00F0						; |
		CMP #$0080						; |
		BCC $03 : ORA #$FF00					; |
		STA !Particle_XSpeed,x					; | spawn particle
		LDA.l !RNG						; |
		AND #$000F						; |
		ASL #4							; |
		ORA #$FE00						; |
		STA !Particle_YSpeed,x					; |
		SEP #$20						; |
		LDA #$18 : STA !Particle_YAcc,x				; |
		LDA.b #!prt_lavaparticle : STA !Particle_Type,x		; |
		STZ !Particle_Layer,x					;/

		LDX $00
		RTS

		.NoTimer						;\
		LDA.b #(ParticleMain_List_end-ParticleMain_List)/2	; |
		STA !Particle_Type,x					; | if timer hits 0, erase particle and set index to the one that was just freed up
		REP #$20						; | then return
		TXA : STA.l !Particle_Index				; |
		RTS							;/



