
	FLASHPAL:
		LDA !P2FlashPal
		AND #$1F : BNE .Flash

		.Reset
		STZ !P2FlashPal
		STZ !P2LockPalset
		RTL

		.Flash
		CMP #$08 : BCS ..go
		LDY !StarTimer : BNE .Reset
		..go
		DEC A
		STA $00
		LDA !P2FlashPal
		AND #$E0
		ORA $00
		STA !P2FlashPal
		AND #$E0
		LSR #4
		TAX
		LDA #$01 : STA !P2LockPalset
		REP #$20
		LDA.l .Color,x : STA $00
		LDA !CurrentPlayer
		AND #$00FF
		BEQ $03 : LDA #$0020
		TAX
		LDA $00
		STA.l !PaletteCacheRGB+$102,x
		STA.l !PaletteCacheRGB+$104,x
		STA.l !PaletteCacheRGB+$106,x
		STA.l !PaletteCacheRGB+$108,x
		STA.l !PaletteCacheRGB+$10A,x
		STA.l !PaletteCacheRGB+$10C,x
		STA.l !PaletteCacheRGB+$10E,x
		STA.l !PaletteCacheRGB+$110,x
		STA.l !PaletteCacheRGB+$112,x
		STA.l !PaletteCacheRGB+$114,x
		STA.l !PaletteCacheRGB+$116,x
		STA.l !PaletteCacheRGB+$118,x
		STA.l !PaletteCacheRGB+$11A,x
		STA.l !PaletteCacheRGB+$11C,x
		STA.l !PaletteCacheRGB+$11E,x
		SEP #$20
		LDA !CurrentPlayer
		BEQ $02 : LDA #$10
		CLC : ADC #$81
		TAX
		LDY #$0F
		LDA !P2FlashPal
		AND #$1F
		CMP #$10 : BCC +
		SBC #$10
		ASL #3
		BRA ++
	+	ASL A
		EOR #$1F
	++	JSL MixRGB_Upload
		RTL


		.Color
		dw $7FFF	; white
		dw $0000	; black
		dw $009F	; red
		dw $03E0	; green
		dw $7C00	; blue
		dw $03FF	; yellow
		dw $7FE0	; cyan
		dw $7C1F	; purple








