
	DASH_SMOKE:
		PHP
		SEP #$30
		LDA !P2XSpeed : BEQ .Return
		LDA !P2Water : BNE .Clear
		LDA !P2InAir : BEQ .Spawn

		.Clear
		STZ !P2DashSmoke
		.Return
		PLP
		RTL

		.Spawn
		REP #$20
		LDA !P2XSpeed
		AND #$0080
		BEQ $03 : LDA #$0400
		SEC : SBC #$0200
		STA $00
		LDA !RNG
		AND #$00F0
		SEC : SBC #$0080
		CLC : ADC $00
		STA $00
		LDA !RNG
		AND #$000F
		ASL #4
		ORA #$FF00
		STA $02

		PHB
		JSL GetParticleIndex
		LDA $00 : STA !Particle_XSpeed,x
		LDA $02 : STA !Particle_YSpeed,x
		STZ !Particle_XAcc,x
		LDA.w #!prt_smoke8x8 : STA !Particle_Type,x
		LDA #$00C0 : STA !Particle_Prop,x
		PLB
		LDA !P2XSpeed				;\
		AND #$00FF				; |
		LSR #4					; |
		CMP #$0008				; | spawn at player X + 4 pixels + offset based on speed
		BCC $03 : ORA #$FFF0			; |
		CLC : ADC !P2XPosLo			; |
		CLC : ADC #$0004			; |
		STA $410000+!Particle_XLo,x		;/
		LDA !P2YPosLo				;\
		CLC : ADC #$000C			; | spawn at player Y + 12 pixels
		STA $410000+!Particle_YLo,x		;/
		PLP
		RTL



