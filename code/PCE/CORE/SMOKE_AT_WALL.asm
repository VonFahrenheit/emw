
SMOKE_AT_WALL:
		PHP
		SEP #$30
		LDA !P2Water : BNE .Return
		LDA !P2Blocked				;\ no smoke unless touching wall
		AND #$03 : BEQ .Return			;/
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
		LDA !P2Blocked				;\
		AND #$0003				; |
		EOR #$0003				; |
		ASL #3					; |
		SEC : SBC #$0008			; | spawn at border between tiles
		CLC : ADC !P2XPosLo			; |
		AND #$FFF0				; |
		CLC : ADC #$000C			; |
		STA !41_Particle_XLo,x			;/
		LDA !P2YPosLo				;\
		CLC : ADC #$0006			; | spawn at player Y + 6 pixels
		STA !41_Particle_YLo,x			;/
		PLP
		RTL

	.Always	PHP
		SEP #$30
		BRA .Frame


