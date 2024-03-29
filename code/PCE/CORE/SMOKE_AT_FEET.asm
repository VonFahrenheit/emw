
SMOKE_AT_FEET:
		PHP
		SEP #$30
		LDA !P2Water : BNE .Return
		LDA !P2InAir : BNE .Return		; no smoke in midair
	.Speed	LDA !P2XSpeed
		CLC : ADC #$08
		CMP #$10 : BCC .Return			; abs speed must be > 16
	.Frame	LDA $14
		AND #$03 : BEQ .Spawn
	.Return	PLP
		RTL

	.Spawn	PHB
		JSL GetParticleIndex
		STZ !Particle_XSpeed,x
		STZ !Particle_YSpeed,x
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
		STA !41_Particle_XLo,x			;/
		LDA !P2YPosLo				;\
		CLC : ADC #$000C			; | spawn at player Y + 12 pixels
		STA !41_Particle_YLo,x			;/
		PLP
		RTL

	.Always	PHP
		SEP #$30
		BRA .Frame


