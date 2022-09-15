
; incrementing timer (ends at 0x60)

	Text100Particle:
		LDX $00							; reload index
		LDA #$0000						;\> clear B
		SEP #$20						; |
		LDA !Particle_Tile,x : BMI .NoCoins			; |
		BEQ $02 : LDA #$01					; |
		TAX							; |
		SEP #$20						; |
		LDA.l !P1CoinIncrease,x					; | give coins
		CLC : ADC #$64						; |
		STA.l !P1CoinIncrease,x					; |
		.NoCoins						; |
		LDX $00							; |
		LDA #$FF : STA !Particle_Tile,x				; |
		REP #$20						;/
		LDA !Particle_Timer,x					;\ check and increment timer
		INC !Particle_Timer,x					;/
		AND #$00FF
		CMP #$0060 : BEQ .NoTimer
		CMP #$0020 : BCC .Move
		CMP #$0040 : BCC .Draw
		AND #$0002 : BEQ .Draw
		RTS
		BRA .Draw

		.Move
		LDA $14
		LSR A : BCC ..done
		DEC !Particle_Y,x
		..done

		.Draw
		LDA #$00C0 : STA !Particle_Prop,x			; _p3
		LDA #$3464 : STA !Particle_TileTemp			; left tile
		STZ !Particle_TileTemp+2				; OAM size bit
		JSR ParticleDrawSimple_BG1				; draw particle without ratio
		LDA !Particle_X,x : PHA					;\
		CLC : ADC #$0008					; | push X, add 8
		STA !Particle_X,x					;/
		LDA #$3465 : STA !Particle_TileTemp			; left tile
		STZ !Particle_TileTemp+2				; OAM size bit
		JSR ParticleDrawSimple_BG1				; draw particle without ratio
		PLA : STA !Particle_X,x					; restore X
		RTS							; return

		.NoTimer						;\
		LDA.w #(ParticleMain_List_End-ParticleMain_List)/2	; |
		STA !Particle_Type,x					; | delete
		TXA : STA.l !Particle_Index				; |
		RTS							;/


