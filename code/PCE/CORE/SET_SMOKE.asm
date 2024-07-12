

SMOKE_PUFF:
		PHB
		PHP
		SEP #$30
		LDY #$07*2
		.Loop
		REP #$30
		PHY
		JSL GetParticleIndex
		PLY
		PHK : PLB
		LDA !P2XPosLo
		CLC : ADC .XDisp,y
		STA !41_Particle_X,x
		LDA !P2YPosLo
		CLC : ADC .YDisp,y
		STA !41_Particle_Y,x
		LDA .XSpeed,y : STA !41_Particle_XSpeed,x
		LDA .YSpeed,y : STA !41_Particle_YSpeed,x
		SEP #$20
		LDA.b #!prt_smoke16x16 : STA !41_Particle_Type,x
		LDA #$C0 : STA !41_Particle_Prop,x
		LDA #$00
		STA !41_Particle_XAcc,x
		STA !41_Particle_YAcc,x
		DEY #2 : BPL .Loop
		PLP
		PLB
		RTL

		.XDisp
		dw $0002,$0001
		dw $0000,-$0001
		dw -$0002,-$0001
		dw $0000,$0001

		.YDisp
		dw -$0004,-$000C
		dw -$0010,-$000C
		dw -$0004,$0004
		dw $0008,$0004

		.XSpeed
		dw $0100,$00B5
		.YSpeed
		dw $0000,-$00B5
		dw -$0100,-$00B5
		dw $0000,$00B5
		dw $0100,$00B5


DOUBLE_JUMP_SMOKE:
		PHP
		REP #$20
		LDA !P2XPosLo : STA $00				; x pos
		LDA !P2YPosLo : STA $02				; y pos
		LDA !P2XSpeed					;\
		AND #$00FF					; |
		ASL #3						; |
		CMP #$0400					; | particle x speed
		BCC $03 : ORA #$F800				; |
		EOR #$FFFF : INC A				; |
		STA $04						;/
		LDA !RNG : STA $06				; RNG value

		PHB
		REP #$30
		LDY #$0007					;/
		.Loop
		PHY
		JSL GetParticleIndex

		LDA $06
		AND #$0003
		ASL #2
		PHA
		DEC #2
		ADC $00
		STA !Particle_X,x
		PLA
		ASL #4
		SBC #$0060
		ADC $04
		STA !Particle_XSpeed,x


		LDA $06
		AND #$0003*2
		ASL A
		PHA
		DEC #2
		ADC $02
		STA !Particle_Y,x
		PLA
		ASL #4
		ADC #$0200-$60
		STA !Particle_YSpeed,x

		STZ !Particle_XAcc,x
		STZ !Particle_YAcc,x

		LDA $06
		AND #$0003
		ASL A : STA !Particle_Timer,x
		LDA.w #!prt_smoke8x8 : STA !Particle_Type,x
		LDA #$00C0 : STA !Particle_Prop,x
		LSR $06
		PLY
		DEY : BPL .Loop
		PLB

		PLP
		RTL
