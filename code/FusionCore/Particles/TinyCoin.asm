
; incrementing timer (0x00-0x1F move, 0x20 find target, 0x21+ magnet)
; tile: updates each frame to determine coin spin
;
; prop: state
;	00 - idle
;	01 - go towards player 1
;	02 - go towards player 2


	TinyCoin:
		LDX $00							; reload index
		SEP #$20						; 8-bit A

		DEC !Particle_Tile,x					; update tile
		LDA !Particle_Timer,x
		CMP #$21 : BCS .Magnet
		INC !Particle_Timer,x
		CMP #$20 : BEQ .FindTarget
		JMP .Move

		.FindTarget
		LDA.l !RNG
		AND #$01
		INC A : STA !Particle_Prop,x

		.Magnet
		STZ !Particle_XAcc,x
		STZ !Particle_YAcc,x
		REP #$20
		LDA !Particle_Prop,x
		AND #$0003
		DEC A
		BEQ $03 : LDA #$0080
		TXY
		TAX
		LDA !Particle_XLo,y					;\
		CLC : ADC #$0008					; | dx
		SEC : SBC.l !P2XPosLo-$80,x				; |
		STA $0C							;/
		LDA !Particle_YLo,y					;\
		CLC : ADC #$0008					; | dY
		SEC : SBC.l !P2YPosLo-$80,x				; |
		STA $0E							;/

		LDA $14
		LSR A : BCC ..xfirst
		..yfirst
		LDA $0E : BPL $03 : JMP ..accdown
		CMP #$0010 : BCC $03 : JMP ..accup
		SEP #$20
		LDA !Particle_YSpeed+1,y
		AND #$80
		EOR #$80
		LSR A
		CLC : ADC #$60
		STA !Particle_YAcc,y
		REP #$20

		..xfirst
		LDA $0C : BMI ..accright
		CMP #$0010 : BCS ..accleft
		SEP #$20
		LDA !Particle_XSpeed+1,y
		AND #$80
		EOR #$80
		LSR A
		CLC : ADC #$60
		STA !Particle_XAcc,y
		REP #$20

		..ysecond
		LDA $14
		LSR A : BCS ..collect
		LDA $0E : BMI ..accdown
		CMP #$0010 : BCS ..accup
		..collect
		TXA
		SEP #$20
		ASL A
		ROL A
		TAX
		LDA !MultiPlayer
		BNE $03 : LDX #$0000
		LDA.l !P1CoinIncrease,x
		INC A : STA.l !P1CoinIncrease,x
		LDX $00
		LDA.b #(ParticleMain_List_End-ParticleMain_List)/2	; |
		STA !Particle_Type,x					; | if timer hits 0, erase particle and set index to the one that was just freed up
		REP #$20						; | then return
		TXA : STA.l !Particle_Index				; |
		RTS							;/

		..accright
		SEP #$20
		LDA !Particle_XSpeed+1,y
		CMP #$03 : BEQ ..done
		LDA #$60 : STA !Particle_XAcc,y
		BRA ..done
		..accleft
		SEP #$20
		LDA !Particle_XSpeed+1,y
		CMP #$FD : BEQ ..done
		LDA #$A0 : STA !Particle_XAcc,y
		BRA ..done

		..accdown
		SEP #$20
		LDA !Particle_YSpeed+1,y
		CMP #$03 : BEQ ..done
		LDA #$60 : STA !Particle_YAcc,y
		BRA ..done
		..accup
		SEP #$20
		LDA !Particle_YSpeed+1,y
		CMP #$FD : BEQ ..done
		LDA #$A0 : STA !Particle_YAcc,y

		..done
		LDX $00

		.Move
		LDA !Particle_Prop,x
		ORA #$C0 : STA !Particle_Prop,x
		JSR ParticleSpeed					; move particle
		LDA !Particle_Tile,x
		AND #$0010
		ORA #$3400
		ORA !GFX_TinyCoin
		STA !Particle_TileTemp					;
		STZ !Particle_TileTemp+2				;
		JSR ParticleDrawSimple_BG1				; draw particle without ratio
		JMP ParticleDespawn					; off-screen check


