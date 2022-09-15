; data 1: hammer owner

	Hammer:
		LDX !SpriteIndex

	.Physics
		JSR ApplySpeed
		.Gravity
		LDA !Ex_YSpeed,x : BMI ..acc
		CMP #$40 : BCS ..done
		..acc
		INC !Ex_YSpeed,x
		INC !Ex_YSpeed,x
		..done

	.GetClipping
		LDA !Ex_Data1,x : BEQ ..process
		JMP .Graphics
		..process
		LDA !Ex_XLo,x : STA $E8
		LDA !Ex_XHi,x : STA $E9
		LDA !Ex_YLo,x : STA $EA
		LDA !Ex_YHi,x : STA $EB
		REP #$20
		INC $E8
		INC $E8
		INC $EA
		INC $EA
		LDA #$000C
		STA $EC
		STA $EE

	.AttackInteraction
		LDX #$00
		..loop
		REP #$20						; required because !CheckContact returns A 8-bit
		LDY .HitboxIndexes,x
		LDA !P2Hitbox1W-$80,y : BEQ ..next
		AND #$00FF : STA $E4
		LDA !P2Hitbox1H-$80,y
		AND #$00FF : STA $E6
		LDA !P2Hitbox1X-$80,y : STA $E0
		LDA !P2Hitbox1Y-$80,y : STA $E2
		JSL CheckContact : BCC ..next
		..claimhammer
		LDX !SpriteIndex
		LDA !P2Hitbox1XSpeed-$80,y : STA !Ex_XSpeed,x
		LDA !P2Hitbox1YSpeed-$80,y : STA !Ex_YSpeed,x
		INC !Ex_Data1,x
		STZ $02
		STZ $03
		STZ $04
		STZ $05
		LDA #$F0 : STA $07
		LDA.b #!prt_contact : JSL SpawnParticleContact
		BRA .Graphics
		..next
		INX
		CPX #$04 : BCC ..loop

	.HurtPlayers
		SEP #$20
		LDX !SpriteIndex
		JSL PlayerContact : BCC ..done
		JSL HurtPlayers
		..done

	.Graphics
		JSR DrawExSprite
		dw !GFX_Hammer_offset
		db $00,$73

	.Return
		RTS



	.HitboxIndexes
	db $00
	db !P2Hitbox2Offset
	db $80
	db $80+!P2Hitbox2Offset

