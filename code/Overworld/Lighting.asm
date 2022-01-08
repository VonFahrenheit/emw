

; light point:
;	X Y
;	R G B
;	R (range factor, $0100 default)

;
; $00	center X
; $02	center Y
; $04	scratch temp R
; $06	scratch temp G
; $08	total light factor (if < 1, 1 - total light factor is added to R, G and B)
; $0A	accumulating R
; $0C	accumulating G
; $0E	accumulating B
;

	CalcLightPoints:

	LDA !Translevel
	ASL A : TAX
	LDA MapLight_R,x : STA $00
	LDA MapLight_G,x : STA $02
	LDA MapLight_B,x : STA $04
	JSL !FadeLight
	JMP .End


		LDA $1A
		CLC : ADC #$0080
		STA $00
		LDA $1C
		CLC : ADC #$0080
		STA $02
		STZ $08
		STZ $0A
		STZ $0C
		STZ $0E
		STZ $2250
		LDX #$0000


		.Loop
		LDA !MapLight_X,x
		SEC : SBC $00
		BPL $04 : EOR #$FFFF : INC A
		STA $04
		LDA !MapLight_Y,x
		SEC : SBC $02
		BPL $04 : EOR #$FFFF : INC A
		CLC : ADC $04
		SEC : SBC !MapLight_S,x
		BPL .Next
		EOR #$FFFF : INC A
		CMP #$0100
		BCC $03 : LDA #$0100
		STA $2251
		CLC : ADC $08
		STA $08

		LDA !MapLight_R,x : STA $2253
		NOP : BRA $00
		LDA $2307 : STA $04
		LDA !MapLight_G,x : STA $2253
		NOP : BRA $00
		LDA $2307 : STA $06
		LDA !MapLight_B,x : STA $2253

		LDA $04					;\
		CLC : ADC $0A				; |
		STA $0A					; |
		LDA $06					; |
		CLC : ADC $0C				; | add adjusted RGB values
		STA $0C					; |
		LDA $2307				; |
		CLC : ADC $0E				; |
		STA $0E					;/


		.Next
		TXA
		CLC : ADC #$000C
		CMP #$0060 : BCS .Finish
		TAX
		JMP .Loop

		.Finish
		LDA $08
		CMP #$0100 : BCS ..nocomplement
		SBC #$0100
		EOR #$FFFF
		STA $08
		CLC : ADC $0A
		STA $0A
		LDA $08
		CLC : ADC $0C
		STA $0C
		LDA $08
		CLC : ADC $0E
		STA $0E
		..nocomplement

		LDA $0A : STA !LightR
		LDA $0C : STA !LightG
		LDA $0E : STA !LightB


	.End
		SEP #$20
		LDA #$80 : TRB !ProcessLight
		LDA !ProcessLight
		CMP #$02 : BNE +
		LDA #$01 : STA !ShaderRowDisable+$7
		LDA #$01 : STA !ShaderRowDisable+$F
		STZ !ProcessLight
		+
		REP #$20

		RTS




	MapLight:
	.R
	dw $0100		; 00
	dw $0100		; 01
	dw $0100		; 02
	dw $0100		; 03
	dw $0100		; 04
	dw $0140		; 05
	dw $0140		; 06
	dw $0100		; 07
	dw $0100		; 08
	dw $0100		; 09
	dw $0100		; 0A
	dw $0100		; 0B
	dw $0100		; 0C
	.G
	dw $0100		; 00
	dw $0100		; 01
	dw $0100		; 02
	dw $0100		; 03
	dw $0100		; 04
	dw $0100		; 05
	dw $0100		; 06
	dw $0100		; 07
	dw $0100		; 08
	dw $0100		; 09
	dw $0100		; 0A
	dw $0100		; 0B
	dw $0100		; 0C
	.B
	dw $0100		; 00
	dw $0100		; 01
	dw $0100		; 02
	dw $0100		; 03
	dw $0100		; 04
	dw $0100		; 05
	dw $00C0		; 06
	dw $00C0		; 07
	dw $0100		; 08
	dw $0100		; 09
	dw $0100		; 0A
	dw $0100		; 0B
	dw $0100		; 0C








