

GigaThwomp:

	namespace GigaThwomp



; this boy is displayed on BG2
; he should be 4x5 tiles or something like that
; the sprite coordinate is the top left corner
; the image should be put in the top left corner of BG2


	MAIN:
		PHB : PHK : PLB

	STZ !BG2ModeH
	STZ !BG2ModeV

		LDA $3220,x
		EOR #$FF
		CLC : ADC $1A
		STA $1E
		LDA $3250,x
		EOR #$FF
		ADC $1B
		STA $1F
		LDA $3210,x
		EOR #$FF
		CLC : ADC $1C
		STA $20
		LDA $3240,x
		EOR #$FF
		ADC $1D
		STA $21

		LDA $14
		AND #$40
		SEC : SBC #$20
		STA $AE,x
		STZ $9E,x
		JSL APPLY_SPEED


		STZ !BigRAM+6

		LDA $3210,x
		CLC : ADC #$4C
		STA !BigRAM+2
		LDA $3240,x
		ADC #$00
		STA !BigRAM+3

		LDA $3250,x : XBA
		LDA $3220,x
		REP #$30
		CLC : ADC #$0004
		STA !BigRAM+0
		CLC : ADC #$0038
		STA !BigRAM+4


	.Loop	REP #$10
		SEP #$20
		LDX !BigRAM+0
		LDY !BigRAM+2
		JSL GetMap16
		CMP #$0100 : BCC .Free
		CMP #$016E : BCS .Free

	.Block	LDX !SpriteIndex			;\
		PHP					; |
		SEP #$30				; |
		LDY !BigRAM+6				; |
		LDA DATA_BlockDisp,y : STA $02		; |
		STZ $03					; | break block
		LDA #$4C : STA $04			; |
		STZ $05					; |
		STZ $00					; |
		STZ $7C					; |
		LDA #$02 : STA $9C			; |
		LDY #$01				; |
	;	JSL !GenerateBlock			; |
		PLP					;/

	.Free	LDA !BigRAM+0				; add 0x10 each time
		CMP !BigRAM+4 : BEQ .Done		;
		CLC : ADC #$0010			; do an additional check with the rightmost limit
		CMP !BigRAM+4 : BCC .Next		; 
		LDA !BigRAM+4				; break loop after the last check
	.Next	STA !BigRAM+0				; 
		INC !BigRAM+6				; 
		BRA .Loop				; 

	.Done	SEP #$30
		LDX !SpriteIndex


		PLB

	INIT:
		RTL



	DATA:
		.BlockDisp
		db $04,$14,$24,$34,$38




	namespace off





