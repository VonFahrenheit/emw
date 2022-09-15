
	CoinFromBlock:
		LDX !SpriteIndex

		LDA !Ex_YSpeed,x
		INC #3 : STA !Ex_YSpeed,x
		CMP #$20 : BMI .Physics
		LDA #!Glitter_Num : STA !Ex_Num,x
		LDA #$10 : STA !Ex_Data1,x

		LDY !Ex_Data3,x
		LDA !P1CoinIncrease,y
		INC A : STA !P1CoinIncrease,y
		BRA .Graphics

		.Physics
		JSR ApplySpeed

		.Graphics
		TXA
		CLC : ADC $14
		LSR #2
		AND #$03 : BEQ ..frame1
		TAY
		LDA !Ex_XLo,x : PHA
		CLC : ADC #$04
		STA !Ex_XLo,x
		LDA !Ex_XHi,x : PHA
		ADC #$00
		STA !Ex_XHi,x
		CPY #$02 : BEQ ..frame3

		..frame2
		JSR DrawExSprite
		dw $0000		; use SP1
		db $47,$30
		LDA !Ex_YLo,x : PHA
		CLC : ADC #$08
		STA !Ex_YLo,x
		LDA !Ex_YHi,x : PHA
		ADC #$00
		STA !Ex_YHi,x
		JSR DrawExSprite
		dw $0000		; use SP1
		db $47,$B0
		PLA : STA !Ex_YHi,x
		PLA : STA !Ex_YLo,x
		BRA ..returnmulti

		..frame3
		JSR DrawExSprite
		dw $0000		; use SP1
		db $57,$30
		LDA !Ex_YLo,x : PHA
		CLC : ADC #$08
		STA !Ex_YLo,x
		LDA !Ex_YHi,x : PHA
		ADC #$00
		STA !Ex_YHi,x
		JSR DrawExSprite
		dw $0000		; use SP1
		db $57,$B0
		PLA : STA !Ex_YHi,x
		PLA : STA !Ex_YLo,x

		..returnmulti
		PLA : STA !Ex_XHi,x
		PLA : STA !Ex_XLo,x
		RTS

		..frame1
		JSR DrawExSprite
		dw $0000		; use SP1
		db $45,$32
		RTS


