EXSPRITE_INTERACTION:

		LDY #!Ex_Amount-1		; > Highest exsprite index

		.Loop
		LDA !Ex_Num,y
		AND #$7F
		SEC : SBC #!ExtendedOffset
		CMP #$0E : BCC $03 : JMP .End	; 0E+ are invalid
		CMP #$02 : BCC .End		; 00-01 are invalid
		CMP #$05 : BCC .Valid		; 02-04 are valid
		BEQ .End			; 05 is invalid
		CMP #$06 : BEQ .Valid		; 06 is valid
		CMP #$0A : BCC .End		; 07-09 are invalid

		.Valid
		CMP #$04 : BNE .NoHammer
		XBA
		LDA !Ex_Data3,y
		LSR A : BCS .End
		XBA

		.NoHammer
		TAX				;\ X = clipping index
		DEX #2				;/
		LDA !Ex_XLo,y			;\
		CLC : ADC $02A4E9,x		; |
		STA $04				; | Clipping xpos
		LDA !Ex_XHi,y			; |
		ADC #$00			; |
		STA $0A				;/
		LDA !Ex_YLo,y			;\
		CLC : ADC $02A4F5,x		; |
		STA $05				; | Clipping ypos
		LDA !Ex_YHi,y			; |
		ADC #$00			; |
		STA $0B				;/
		LDA $02A501,x : STA $06		; > Clipping width
		LDA $02A50D,x : STA $07		; > Clipping height
		JSL $03B72B			; > Check for contact
		BCC .End
		LDA !Ex_Num,y
		AND #$7F
		SEC : SBC #!ExtendedOffset
		CMP #$0A : BNE .Hurt

		.Coin
		LDA #$00 : STA !Ex_Num,y
		PHY
		JSR SET_GLITTER
		TYX
		PLY
		LDA !Ex_YLo,y : STA !Ex_YLo,x
		LDA !Ex_XLo,y : STA !Ex_XLo,x
		LDA !CurrentPlayer		;\
		TAX				; | Give coins
		INC !P1CoinIncrease,x		;/

		.End
		DEY
		BMI .Return
		JMP .Loop

		.Hurt
		LDA !P2Invinc
		BNE .End
		LDA $7490
		BEQ .NoStar
		LDA #$00 : STA !Ex_Num,y
		BRA .End

		.NoStar
		JSR HURT
		LDY #$FF			; This is somehow necessary... yeah, I'm not sure why

		.Return		
		RTS



