;===============;
;DISPLAY CONTACT;
;===============;
	DISPLAY_CONTACT:
	DISPLAYCONTACT:

		.CheckSize
		LDA !P2Character
		CMP #$02 : BNE .Small
		LDY !P2ActiveHitbox
		REP #$20
		LDA !P2Hitbox1W,y
		SEP #$20
		BEQ .Small
		LDA !P2Hitbox1Hitstun,y
		CMP #$06 : BCC .Small
		JMP .Big

		.Small
		PHX
		PHP
		PHB
		JSL !GetParticleIndex
		STZ !Particle_Timer,x
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
		STA !41_Particle_YLo,x
		LDA $0C : STA !41_Particle_XLo,x
		PLP
		PLX
		RTL

		.Big
		PHX
		PHP
		PHB
		JSL !GetParticleIndex
		LDA #$0007 : STA !Particle_Timer,x
		LDA.w #!prt_contactbig : STA !Particle_Type,x
		LDA.l !CurrentPlayer
		AND #$00FF
		BEQ $03 : LDA #$0220				; set lowest c bit as well as add 0x20 to tile num
		CLC : ADC.w #!P2Tile7-$20
		ORA #$F000
		STA !Particle_Tile,x
		SEP #$20
		LDA #$02 : STA !Particle_Layer,x
		PLB
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
		SEC : SBC #$000E
		STA !41_Particle_YLo,x
		LDA $0C : STA !41_Particle_XLo,x
		LDA !P2Direction
		AND #$00FF
		BEQ $03 : LDA #$0040
		STA !41_Particle_XSpeed,x
		PLP
		PLX
		RTL



