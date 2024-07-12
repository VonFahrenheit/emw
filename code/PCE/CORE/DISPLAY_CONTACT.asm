;===============;
;DISPLAY CONTACT;
;===============;
DISPLAY_CONTACT:


	DISPLAYCONTACT:
		PHX
		%Ex_Index_X()
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
<<<<<<< Updated upstream
=======
		STA !41_Particle_YLo,x
		LDA $0C : STA !41_Particle_XLo,x
		PLP
		PLX
		RTL

		.Big
		PHX
		PHP
		PHB
		JSL GetParticleIndex
		LDA #$0007 : STA !Particle_Timer,x
		LDA.w #!prt_contactbig : STA !Particle_Type,x
		LDA.l !CurrentPlayer
		AND #$00FF
		BEQ $03 : LDA.w #!P2TileOffset			; set lowest c bit
		CLC : ADC.w #!P1Tile7
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
>>>>>>> Stashed changes
		SEP #$20
		STA !Ex_YLo,x
		XBA : STA !Ex_YHi,x
		LDA $0C : STA !Ex_XLo,x
		LDA $0D : STA !Ex_XHi,x
		LDA #$02+!SmokeOffset : STA !Ex_Num,x
		LDA #$07 : STA !Ex_Data1,x
		PLX
		RTS
