

	!BirdState		= $BE

	!BirdPanicTimer		= $3280
	!BirdCounter		= $3290
	!BirdHomeX		= $32A0

	!BirdHopTimer		= $32B0
	!BirdPeckTimer		= $32D0


	INIT:
		LDA !SpriteYLo,x
		ORA #$08 : STA !SpriteYLo,x

		LDA !SpriteXLo,x : STA !BirdHomeX,x
		LSR #4
		AND #$03 : TAY
		LDA DATA_Color,y : STA !SpriteOAMProp,x

		TXA
		ASL #3
		ADC !RNG
		AND #$1F
		ORA #$20
		STA !BirdPanicTimer,x				; panic timer

		RTS


	MAIN:
		%decreg(!BirdHopTimer)
		LDA !BirdPanicTimer,x : BNE .Process

		.StartPanic
		LDA #$02 : STA !BirdState,x

		.Process
		LDA !BirdState,x
		ASL A
		CMP.b #.StatePtr_end-.StatePtr
		BCC $02 : LDA #$00
		TAX
		JMP (.StatePtr,x)

		.StatePtr
		dw .Hop
		dw .Peck
		dw .Panic
		..end


	.Hop
		LDX !SpriteIndex

		LDY !SpriteDir,x
		LDA DATA_HopXSpeed,y : STA !SpriteXSpeed,x
		LDA !SpriteYSpeed,x : BMI ..done
		LDA !SpriteBlocked,x
		AND #$04 : BEQ ..done

		LDA #$F0 : STA !SpriteYSpeed,x
		LDA !BirdCounter,x : BEQ ..peck
		DEC !BirdCounter,x
		LDA !SpriteXLo,x
		SEC : SBC !BirdHomeX,x
		CLC : ADC #$30
		CMP #$60 : BCC ..done

		..tryturning
		LDA !BirdHopTimer,x : BNE ..done
		LDA #$10 : STA !BirdHopTimer,x
		BRA .Peck_turn

		..peck
		INC !BirdState,x
		TXA
		AND #$07 : TAY
		LDA !RNG
	-	ROR A
		DEY : BPL -
		AND #$03 : TAY
		LDA DATA_BirdRNG,y : STA !BirdCounter,x

		..done
		BRA .LookForThreats


	.Peck
		LDX !SpriteIndex
		STZ !SpriteXSpeed,x
		STZ !SpriteYSpeed,x
		LDA !BirdPeckTimer,x : BEQ ..rollpeck
		CMP #$08 : BNE ..done
		LDA #$01 : STA !SpriteAnimIndex,x
		STZ !SpriteAnimTimer,x
		BRA ..done

		..rollpeck
		LDA !BirdCounter,x : BEQ ..hop
		DEC !BirdCounter,x
		LDA !RNG
		AND #$1F
		ORA #$0A
		STA !BirdPeckTimer,x
		BRA ..done

		..hop
		STZ !BirdState,x
		LDA !RNG
		AND #$01 : BNE ..keepdir
		..turn
		LDA !SpriteDir,x
		EOR #$01 : STA !SpriteDir,x
		LDA #$02 : STA !SpriteAnimIndex,x
		STZ !SpriteAnimTimer,x
		..keepdir
		LDA !RNG
		AND #$03
		CLC : ADC #$02
		STA !BirdCounter,x

		..done


	.LookForThreats
		LDA.b #!Hitbox_128x128 : JSL GetSpriteClippingE8_A
		JSL PlayerContact : BCS ..panictime
		JSL FireballContact : BCC ..lookforsprites
		..panictime
		JMP .StartPanic

		..lookforsprites
		LDA !SpriteNum,x : STA $00
		LDX #$0F
		..loop
		CPX !SpriteIndex : BEQ ..next
		LDA !SpriteStatus,x
		CMP #$08 : BNE ..next
		LDA !ExtraBits,x
		AND #$08 : BNE ..next
		LDA !SpriteNum,x
		CMP $00 : BNE ..next
		LDA !BirdState,x
		CMP #$02 : BNE ..next
		JSL GetSpriteClippingE0
		JSL CheckContact : BCC ..next
		LDX !SpriteIndex
		DEC !BirdPanicTimer,x
		BRA ..done
		..next
		DEX : BPL ..loop
		LDX !SpriteIndex
		..done
		JSL APPLY_SPEED
		BRA .Graphics


	.Panic
		LDX !SpriteIndex
		LDA #$02 : STA !BirdState,x
		JSL SUB_HORZ_POS
		TYA
		EOR #$01 : STA !SpriteDir,x
		TAY
		LDA.w DATA_FlyXSpeed,y : JSL AccelerateX_Unlimit1
		LDA #$F0 : JSL AccelerateY_Unlimit1
		STZ !SpriteGravity,x
		LDA !SpriteAnimIndex,x
		CMP #$03 : BCS ..done
		LDA #$03 : STA !SpriteAnimIndex,x
		STZ !SpriteAnimTimer,x
		..done
		JSL APPLY_SPEED_X
		JSL APPLY_SPEED_Y




	.Graphics
		REP #$20
		LDA.w #ANIM : JSL UPDATE_ANIM
		JSL LOAD_PSUEDO_DYNAMIC
		RTS





	DATA:
	.Color
		db $0A,$08,$06,$04

	.HopXSpeed
		db $08,$F8

	.FlyXSpeed
		db $40,$C0

	.BirdRNG
		db $02,$03,$05,$01



	ANIM:
		dw .Idle	: db $FF,$00	; 00
		dw .Peck	: db $08,$00	; 01
		dw .Turn	: db $08,$00	; 02
		dw .Fly0	: db $04,$04	; 03
		dw .Fly1	: db $04,$03	; 04

		.Idle
		dw $0004
		db $20,$04,$00,$10

		.Peck
		dw $0004
		db $20,$04,$00,$11

		.Turn
		dw $0004
		db $20,$04,$00,$02

		.Fly0
		dw $0004
		db $20,$04,$00,$00

		.Fly1
		dw $0004
		db $20,$04,$00,$01



