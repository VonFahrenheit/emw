

; _Tile = 00 for player 1, 01 for player 2


; timer = 0
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



	; input A = 0x000 - 0x100
		; .FinalAnim
		; SBC #$0040
		; ASL A : TAX
		; LDA.l .Rate,x
		; LDX $00
		; STA $00
		; LDA #$0000 : STA.l $2250

		; LDA $00 : STA.l $2251

		; LDA !Particle_Tile,x
		; AND #$00FF
		; BEQ $03 : LDA #$00C8
		; ADC #$0010
		; ADC $1A
		; STA.l $2253
		; NOP : BRA $00
		; LDA.l $2307 : STA $E0
		; LDA $1C
		; CLC : ADC #$00E0
		; STA.l $2253
		; NOP : BRA $00
		; LDA.l $2307 : STA $E2

		; LDA #$0100
		; SEC : SBC $00
		; STA $00
		; STA.l $2251
		; LDA !Particle_X,x : STA.l $2253
		; PHA
		; NOP
		; LDA.l $2307
		; CLC : ADC $E0
		; STA !Particle_X,x
		; LDA !Particle_Y,x : STA.l $2253
		; PHA
		; NOP
		; LDA.l $2307
		; CLC : ADC $E2
		; STA !Particle_Y,x

		; JSR .Draw
		; PLA : STA !Particle_Y,x
		; PLA : STA !Particle_X,x
		; RTS




; macro TextParticleRate(acc)
	; dw !Temp
	; !Temp := !Temp+<acc>
; endmacro

		; .Rate
		; !Temp = 0
		; %TextParticleRate(-1)
		; %TextParticleRate(-1)
		; %TextParticleRate(-2)
		; %TextParticleRate(-2)
		; %TextParticleRate(-3)
		; %TextParticleRate(-3)
		; %TextParticleRate(-4)
		; %TextParticleRate(-4)
		; %TextParticleRate(-5)
		; %TextParticleRate(-5)
		; %TextParticleRate(-6)
		; %TextParticleRate(-6)
		; %TextParticleRate(-7)
		; %TextParticleRate(-7)
		; %TextParticleRate(-8)
		; %TextParticleRate(-8)
		; %TextParticleRate(-8)
		; %TextParticleRate(-8)
		; %TextParticleRate(-8)
		; %TextParticleRate(-8)
		; %TextParticleRate(-7)
		; %TextParticleRate(-7)
		; %TextParticleRate(-6)
		; %TextParticleRate(-6)
		; %TextParticleRate(-5)
		; %TextParticleRate(-5)
		; %TextParticleRate(-4)
		; %TextParticleRate(-4)
		; %TextParticleRate(-3)
		; %TextParticleRate(-3)
		; %TextParticleRate(-2)
		; %TextParticleRate(-2)
		; %TextParticleRate(-1)
		; %TextParticleRate(-1)
		; %TextParticleRate(0)
		; %TextParticleRate(0)
		; %TextParticleRate(0)
		; %TextParticleRate(0)
		; %TextParticleRate(0)
		; %TextParticleRate(0)
		; %TextParticleRate(1)
		; %TextParticleRate(1)
		; %TextParticleRate(2)
		; %TextParticleRate(2)
		; %TextParticleRate(3)
		; %TextParticleRate(3)
		; %TextParticleRate(4)
		; %TextParticleRate(4)
		; %TextParticleRate(5)
		; %TextParticleRate(5)
		; %TextParticleRate(6)
		; %TextParticleRate(6)
		; %TextParticleRate(7)
		; %TextParticleRate(7)
		; %TextParticleRate(8)
		; %TextParticleRate(8)
		; %TextParticleRate(9)
		; %TextParticleRate(9)
		; %TextParticleRate(10)
		; %TextParticleRate(10)
		; %TextParticleRate(11)
		; %TextParticleRate(11)
		; %TextParticleRate(12)
		; %TextParticleRate(12)
		; %TextParticleRate(13)
		; %TextParticleRate(13)
		; %TextParticleRate(14)
		; %TextParticleRate(14)
		; %TextParticleRate(15)
		; %TextParticleRate(15)
		; %TextParticleRate(16)
		; %TextParticleRate(16)
		; %TextParticleRate(16)
		; %TextParticleRate(16)
		; %TextParticleRate(16)
		; %TextParticleRate(16)
		; %TextParticleRate(16)
		; %TextParticleRate(16)
		; %TextParticleRate(16)
		; %TextParticleRate(16)
		; %TextParticleRate(16)
		; ..end





