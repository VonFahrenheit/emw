
; data 1: helix timer
; data 2: helix size
; data 3: life timer


	MarioFinale:

		.HelixSpeed
		LDY !SpriteIndex
		LDX !Ex_Data2,y
		REP #$30
		LDA !Ex_Data1,y
		AND #$003F
		ASL #4 : STA $00			; save angle
		CMP #$0200 : BCC ..positive
		..negative
		EOR #$03FF : INC A
		TAX
		LDA.l !TrigTable,x
		LSR #2
		EOR #$FFFF : INC A
		BRA ..setspeed
		..positive
		TAX
		LDA.l !TrigTable,x
		LSR #2
		..setspeed
		SEP #$30
		LDX !SpriteIndex
		STA !Ex_YSpeed,x
		INC !Ex_Data1,x
		LDA $00 : BNE ..done
		LDA $01
		CMP #$02 : BNE ..done
		LDA !Ex_Data2,x
		CMP #$02*2 : BCS ..done
		INC !Ex_Data2,x
		INC !Ex_Data2,x
		..done


		.LifeTimer
		INC !Ex_Data3,x : BNE ..done
		JMP TurnToSmoke
		..done


		.Move
		JSR ApplySpeed
		JSR DrawExSprite
		dw !GFX_ReznorFireball_offset
		db $00,$73

		RTS


		.HelixSize
		dw $0100,$0100,$0100

		.HelixRate
		dw $0004,$0002,$0001





