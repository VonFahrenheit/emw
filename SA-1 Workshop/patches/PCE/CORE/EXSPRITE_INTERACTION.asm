EXSPRITE_INTERACTION:

		LDY #$07			; > Highest exsprite index

		.Loop
		LDA $770B,y
		CMP #$0E : BCC $03 : JMP .End	; 0E+ are invalid
		CMP #$02 : BCC .End		; 00-01 are invalid
		CMP #$05 : BCC .Valid		; 02-04 are valid
		BEQ .End			; 05 is invalid
		CMP #$06 : BEQ .Valid		; 06 is valid
		CMP #$0A : BCC .End		; 07-09 are invalid

		.Valid
		CMP #$04
		BNE .NoHammer
		LDX $776F,y
		BNE .End

		.NoHammer
		TAX				;\ X = clipping index
		DEX #2				;/
		LDA $771F,y			;\
		CLC : ADC $02A4E9,x		; |
		STA $04				; | Clipping xpos
		LDA $7733,y			; |
		ADC #$00			; |
		STA $0A				;/
		LDA $7715,y			;\
		CLC : ADC $02A4F5,x		; |
		STA $05				; | Clipping ypos
		LDA $7729,y			; |
		ADC #$00			; |
		STA $0B				;/
		LDA $02A501,x : STA $06		; > Clipping width
		LDA $02A50D,x : STA $07		; > Clipping height
		JSL $03B72B			; > Check for contact
		BCC .End
		LDA $770B,y
		CMP #$0A
		BNE .Hurt

		.Coin
		LDA #$00 : STA $770B,y
		PHY
		JSR SET_GLITTER
		TYX
		PLY
		LDA $7715,y
		STA $77C4,x
		LDA $771F,y
		STA $77C8,x
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
		LDA #$00 : STA $770B,y
		BRA .End

		.NoStar
		JSR HURT
		LDY #$FF			; This is somehow necessary... yeah, I'm not sure why

		.Return		
		RTS



