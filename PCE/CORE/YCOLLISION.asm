YCOLLISION:
		LDA $78A7			;\
		XBA				; | Get acts like
		LDA $7693			;/
		REP #$20			; > A 16 bit

		CMP #$0029			;\ Special P coin block
		BNE $03 : JMP .CoinQBlock	;/
		CMP #$0114			;\ Direction coins
		BNE $03 : JMP .DirCoins		;/
		CMP #$0129			;\ Most container blocks
		BCC .GetInteraction		;/
		CMP #$0137			;\
		BNE $03 : JMP .VertPipe		; | Vertical pipe from below
		CMP #$0138			; |
		BNE $03 : JMP .VertPipe		;/
		SEP #$20
		RTS

		.GetInteraction
		SEC : SBC #$0117
		ASL A : TAX
		SEP #$20
		JMP (.Map16Ptr,x)

		.Map16Ptr
		dw .FlowerTBlock		; 117
		dw .FeatherTBlock		; 118
		dw .StarTBlock			; 119
		dw .VariableTBlock		; 11A
		dw .MultiCoinTBlock		; 11B
		dw .CoinTBlock			; 11C
		dw .PTBlock			; 11D
		dw .TBlock			; 11E
		dw .FlowerQBlock		; 11F
		dw .FeatherQBlock		; 120
		dw .StarQBlock			; 121
		dw .Star2QBlock			; 122
		dw .MultiCoinQBlock		; 123
		dw .CoinQBlock			; 124
		dw .VariableQBlock		; 125
		dw .YoshiQBlock			; 126
		dw .ShellQBlock			; 127
		dw .ShellQBlock			; 128

		.FlowerTBlock
		LDA #$02 : BRA .TBlockUsed

		.FeatherTBlock
		LDA #$04 : BRA .TBlockUsed

		.StarTBlock
		LDA #$03 : BRA .TBlockUsed

		.VariableTBlock
		LDA #$00 : BRA .TBlockUsed	; NOT DONE

		.MultiCoinTBlock
		BRA .CoinTBlock			; NOT DONE

		.CoinTBlock
		LDA #$06 : BRA .TBlockUsed

		.PTBlock
		LDA #$00 : BRA .TBlockUsed	; NOT DONE

		.TBlock
		LDA #$00
		LDY #$0C : STY $9C		; Turn block
		BRA .TBlockMain

		.TBlockUsed
		LDY #$0D : STY $9C		; Used block

		.TBlockMain
		STA $00
		LDA #$08			;\
		STA $02				; | X offset
		STZ $03				;/
		LDA #$F8			;\
		STA $04				; | Y offset
		LDA #$FF			; |
		STA $05				;/
		LDY #$00			; Don't shatter block
		LDA #$01			;\ Bounce sprite to spawn (turn block)
		STA $7C				;/
		JMP GENERATE_BLOCK

		.DirCoins
		SEP #$20
		LDA #$0F : BRA .QBlockMain

		.FlowerQBlock
		LDA #$01
		LDY $19
		BEQ $01 : INC A
		BRA .QBlockMain

		.FeatherQBlock
		LDA #$01
		LDY $19
		BEQ $02 : LDA #$04
		BRA .QBlockMain

		.Star2QBlock
		LDA $7490
		BEQ .CoinQBlock

		.StarQBlock
		LDA #$03 : BRA .QBlockMain

		.MultiCoinQBlock
		LDA $786B
		DEC A
		BEQ .CoinQBlock+$02
		LDA #$07 : BRA .QBlockMain

		.CoinQBlock
		SEP #$20
		LDA #$06 : BRA .QBlockMain

		.QBlockYoshi
		LDA #$0C : BRA .QBlockMain

		.ShellQBlock
		LDA #$0D

		.QBlockMain
		STA $00
		LDA #$08			;\
		STA $02				; | X offset
		STZ $03				;/
		LDA #$F8			;\
		STA $04				; | Y offset
		LDA #$FF			; |
		STA $05				;/
		LDY #$00			;> Shatter block flag
		LDA #$0D			;\ Used block
		STA $9C				;/
		LDA #$03			;\ Bounce sprite (question block)
		STA $7C				;/
		JMP GENERATE_BLOCK		; Clear block

		.VertPipe
		SEP #$20
		LDA $6DA3
		AND #$08
		BEQ +
		LDA #$06 : STA $71
		LDA #$0F : STA $88
		LDA #$02 : STA $89
		LDA !P2XPosLo : STA $94
		LDA !P2XPosHi : STA $95
		LDA !P2YPosLo : STA $96
		LDA !P2YPosHi : STA $97
	+	RTS


		.VariableQBlock
		.YoshiQBlock
		SEP #$20
		RTS


