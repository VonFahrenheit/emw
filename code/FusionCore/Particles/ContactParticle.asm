

; timer: 00, increments

	ContactParticle:
		LDX $00							; reload index
		SEP #$20						; 8-bit A
		LDA !Particle_Timer,x					;\
		INC !Particle_Timer,x					; |
		CMP #$03 : BEQ .Split
		CMP #$06 : BEQ .Delete

		.DrawBig
		REP #$20						; 16-bit A
		LDA #$3462 : STA !Particle_TileTemp			; tile num + prop
		LDA #$0002 : STA !Particle_TileTemp+2			; OAM size bit
		JSR ParticleDrawSimple_BG1				; draw particle without ratio
		JMP ParticleDespawn					; off-screen check

		.Delete
		LDA.b #(ParticleMain_List_End-ParticleMain_List)/2	;\
		STA !Particle_Type,x					; |
		REP #$20						; | delete
		TXA : STA.l !Particle_Index				; |
		RTS							;/


		.Split
		REP #$20						;\
		LDA.l !RNG						; |
		AND #$00FF						; |
		ASL #2 : STA $0E					; |
		LDX #$0000						; |
	-	LDA $0E							; | get random offsets for small particles
		AND #$0004						; |
		CLC : ADC.l .BaseOffset,x				; |
		STA $E0,x						; |
		LSR $0E							; |
		INX #2							; |
		CPX #$0010 : BCC -					;/
		LDA $14							;\
		EOR #$0010						; |
		AND #$001F : TAX					; | secondary RNG value
		LDA.l !RNGtable,x					; |
		AND #$00FF : STA $02					;/
		LDX $00							; X = index



		JSL !GetParticleIndex					;\
		LDY $00							; |
		LDA.w #!prt_spritepart : STA !Particle_Type,x		; |
		LDA !Particle_X,y					; |
		CLC : ADC $E0						; |
		STA !Particle_X,x					; |
		LDA !Particle_Y,y					; |
		CLC : ADC $E2						; |
		STA !Particle_Y,x					; |
		LDA #$3474 : STA !Particle_Tile,x			; |
		STZ !Particle_Layer,x					; | spawn top left tile
		STZ !Particle_YAcc,x					; |
		LDA #$0005 : STA !Particle_Timer,x			; |
		LDA $02							; |
		AND #$0001						; |
		BEQ $03 : LDA #$0080					; |
		CLC : ADC #$FE80					; |
		STA !Particle_XSpeed,x					; |
		STA !Particle_YSpeed,x					;/

		JSL !GetParticleIndex					;\
		LDY $00							; |
		LDA.w #!prt_spritepart : STA !Particle_Type,x		; |
		LDA !Particle_X,y					; |
		CLC : ADC $E4						; |
		STA !Particle_X,x					; |
		LDA !Particle_Y,y					; |
		CLC : ADC $E6						; |
		STA !Particle_Y,x					; |
		LDA #$7474 : STA !Particle_Tile,x			; |
		STZ !Particle_Layer,x					; | spawn top right tile
		STZ !Particle_YAcc,x					; |
		LDA #$0005 : STA !Particle_Timer,x			; |
		LDA $02							; |
		AND #$0002						; |
		BEQ $03 : LDA #$0080					; |
		ORA #$0100 : STA !Particle_XSpeed,x			; |
		EOR #$FFFF : STA !Particle_YSpeed,x			;/

		JSL !GetParticleIndex					;\
		LDY $00							; |
		LDA.w #!prt_spritepart : STA !Particle_Type,x		; |
		LDA !Particle_X,y					; |
		CLC : ADC $E8						; |
		STA !Particle_X,x					; |
		LDA !Particle_Y,y					; |
		CLC : ADC $EA						; |
		STA !Particle_Y,x					; |
		LDA #$B474 : STA !Particle_Tile,x			; |
		STZ !Particle_Layer,x					; | spawn bottom left tile
		STZ !Particle_YAcc,x					; |
		LDA #$0005 : STA !Particle_Timer,x			; |
		LDA $02							; |
		AND #$0004						; |
		BEQ $03 : LDA #$0080					; |
		ORA #$0100 : STA !Particle_YSpeed,x			; |
		EOR #$FFFF : STA !Particle_XSpeed,x			;/

		JSL !GetParticleIndex					;\
		LDY $00							; |
		LDA.w #!prt_spritepart : STA !Particle_Type,x		; |
		LDA !Particle_X,y					; |
		CLC : ADC $EC						; |
		STA !Particle_X,x					; |
		LDA !Particle_Y,y					; |
		CLC : ADC $EE						; |
		STA !Particle_Y,x					; |
		LDA #$F474 : STA !Particle_Tile,x			; |
		STZ !Particle_Layer,x					; | spawn bottom right tile
		STZ !Particle_YAcc,x					; |
		LDA #$0005 : STA !Particle_Timer,x			; |
		LDA $02							; |
		AND #$0008						; |
		BEQ $03 : LDA #$0080					; |
		ORA #$0100						; |
		STA !Particle_XSpeed,x					; |
		STA !Particle_YSpeed,x					;/

		LDX $00
		JMP .DrawBig						; return


		.BaseOffset
		dw $0001,$0001
		dw $0003,$0001
		dw $0001,$0003
		dw $0003,$0003



