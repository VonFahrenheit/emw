
	!BooStreamVerticalDir	= $BE


	!BooStreamXLo1		= $3280
	!BooStreamXHi1		= $3290
	!BooStreamYLo1		= $32A0
	!BooStreamYHi1		= $32B0
	!BooStreamDir1		= $32C0		; does not have HP

	!BooStreamXLo2		= $3410
	!BooStreamXHi2		= $3420
	!BooStreamYLo2		= $3430
	!BooStreamYHi2		= $3440
	!BooStreamDir2		= $3450

	!BooStreamXLo3		= $3460
	!BooStreamXHi3		= $3470
	!BooStreamYLo3		= $3480
	!BooStreamYHi3		= $3490
	!BooStreamDir3		= $34A0

	!BooStreamXLo4		= $34B0
	!BooStreamXHi4		= $34C0
	!BooStreamYLo4		= $34D0
	!BooStreamYHi4		= $34E0
	!BooStreamDir4		= $34F0

	!BooStreamXLo5		= $3500
	!BooStreamXHi5		= $3510
	!BooStreamYLo5		= $3520
	!BooStreamYHi5		= $3530
	!BooStreamDir5		= $3540

	!BooStreamXLo6		= $3550
	!BooStreamXHi6		= $3560
	!BooStreamYLo6		= $3570
	!BooStreamYHi6		= $3580
	!BooStreamDir6		= $3590


	INIT:
		LDA !SpriteXLo,x : STA $04
		LDA !SpriteXHi,x : STA $03
		LDA !SpriteYLo,x : STA $02
		LDA !SpriteYHi,x : STA $01
		LDA !SpriteDir,x : STA $00
		LDY #$0A

		.Loop
		LDA DATA_CoordPtr+0,y : STA $08
		LDA DATA_CoordPtr+1,y : STA $09
		STY $0F
		LDY !SpriteIndex
		LDX #$04

		..loop
		LDA $00,x : STA ($08),y
		TYA
		CLC : ADC #$10
		TAY
		DEX : BPL ..loop
		LDY $0F
		DEY #2 : BPL .Loop

		LDX !SpriteIndex
		LDA #$30 : STA $32D0,x


	MAIN:

	.CallSegments
		LDA #$08 : STA !SpriteAnimIndex,x
		JSR HandleSegment
		LDA !SpriteXLo,x : PHA
		LDA !SpriteXHi,x : PHA
		LDA !SpriteYLo,x : PHA
		LDA !SpriteYHi,x : PHA
		LDA !SpriteDir,x : PHA
		LDA !BooStreamVerticalDir,x : PHA


		LDY #$0A

		..loop
		REP #$20
		LDA DATA_CoordPtr,y : STA $00
		SEP #$20
		LDA $32D0,x
		CMP DATA_SegmentTimer,y : BCS ..next
		LDA DATA_SegmentTimer+1,y : STA !SpriteAnimIndex,x

		PHY
		TXY
		LDA ($00),y : STA !SpriteXLo,x
		TXA : ORA #$10 : TAY
		LDA ($00),y : STA !SpriteXHi,x
		TXA : ORA #$20 : TAY
		LDA ($00),y : STA !SpriteYLo,x
		TXA : ORA #$30 : TAY
		LDA ($00),y : STA !SpriteYHi,x
		TXA : ORA #$40 : TAY
		LDA ($00),y
		LSR A : STA !BooStreamVerticalDir,x
		ROL A
		AND #$01 : STA !SpriteDir,x
		PEI ($00)
		JSR HandleSegment
		PLA : STA $00
		PLA : STA $01
		TXY
		LDA !SpriteXLo,x : STA ($00),y
		TXA : ORA #$10 : TAY
		LDA !SpriteXHi,x : STA ($00),y
		TXA : ORA #$20 : TAY
		LDA !SpriteYLo,x : STA ($00),y
		TXA : ORA #$30 : TAY
		LDA !SpriteYHi,x : STA ($00),y
		TXA : ORA #$40 : TAY
		LDA !BooStreamVerticalDir,x
		ASL A
		ORA !SpriteDir,x
		STA ($00),y

		PLY

		..next
		DEY #2 : BMI $03 : JMP ..loop


		INC !SpriteAnimTimer,x
		PLA : STA !BooStreamVerticalDir,x
		PLA : STA !SpriteDir,x
		PLA : STA !SpriteYHi,x
		PLA : STA !SpriteYLo,x
		PLA : STA !SpriteXHi,x
		PLA : STA !SpriteXLo,x
		RTS



	HandleSegment:

	.Physics
		LDA !Difficulty
		ASL A
		ORA !SpriteDir,x
		TAY
		LDA DATA_Speed,y : STA !SpriteXSpeed,x
		LDA !Difficulty
		ASL A
		ORA !BooStreamVerticalDir,x
		TAY
		LDA DATA_Speed,y : STA !SpriteYSpeed,x
		JSL APPLY_SPEED
		..checkhorz
		LDA !SpriteBlocked,x
		AND #$03 : BEQ ..checkvert
		LDA !SpriteDir,x
		EOR #$01 : STA !SpriteDir,x
		..checkvert
		LDA !SpriteBlocked,x
		AND #$0C : BEQ ..done
		LDA !BooStreamVerticalDir,x
		EOR #$01 : STA !BooStreamVerticalDir,x
		..done


	.Interaction
		JSL GetSpriteClippingE8
		JSL P2Standard


	.Graphics
		LDA !SpriteAnimTimer,x
		AND #$04
		LSR A
		ORA !SpriteAnimIndex,x
		TAY
		JSL DRAW_SIMPLE_Main
		RTS



	DATA:
	.Speed
		db $08,$F8
		db $10,$F0
		db $18,$E8

	.CoordPtr
		dw !BooStreamXLo6
		dw !BooStreamXLo5
		dw !BooStreamXLo4
		dw !BooStreamXLo3
		dw !BooStreamXLo2
		dw !BooStreamXLo1

	; timer requirement, base animation tile
	.SegmentTimer
		db $01,$08
		db $09,$00
		db $11,$04
		db $19,$08
		db $21,$00
		db $29,$04

