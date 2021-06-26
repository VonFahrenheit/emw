;===============;
;DISPLAY CONTACT;
;===============;
DISPLAY_CONTACT:


	DISPLAYCONTACT:
		PHX
		PHP
		PHB
		JSL !GetParticleIndex
		LDA #$0007 : STA !Particle_Timer,x
		LDA.w #!prt_contact : STA !Particle_Type,x
		LDA #$00C0 : STA !Particle_Prop,x
		PLB
		SEP #$20
		LDA $00 : STA $0C
		LDA $08 : STA $0D
		LDA $01 : STA $0E
		LDA $09 : STA $0F
		LDA $0A : XBA
		LDA $04
		REP #$20
		CLC : ADC $0C
		LSR A
		STA $0C
		SEP #$20
		LDA $0B : XBA
		LDA $05
		REP #$20
		CLC : ADC $0E
		LSR A
		STA $0E
		STA $410000+!Particle_YLo,x
		LDA $0C : STA $410000+!Particle_XLo,x
		PLP
		PLX
		RTL
