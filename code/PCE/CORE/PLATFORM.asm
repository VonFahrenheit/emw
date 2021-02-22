; this module handles rotating platforms (sprite 0x5F, 0xA3, and 0xE0)
; the hijack is in PCE.asm, just search for "JSL CORE_PLATFORM"

	PLATFORM:

	.Cloud						; lakitu cloud entry point
		STZ !BigRAM
		LDA #$00 : STA !BigRAM+1
		STZ $35E0,x				; clear interaction flag
		BRA .Bank02_2

	.Bank01						; bank 01 entry point
		LDA #$01 : STA !BigRAM
		LDA #$15 : STA !BigRAM+1
		STZ !BigRAM+2
		BRA .Main

	.Bank02						; bank 02 entry point
		LDA #$02 : STA !BigRAM
		LDA #$0F : STA !BigRAM+1
		LDA $32B0,x : STA $7491
	..2	LDA $3210,x : STA $74BA
		LDA $3240,x : STA $74BB
		JSL !GetSpriteClipping04
		STZ !BigRAM+2

	.Main
		LDA !P2Character-$80 : BEQ .P2		; check PCE slot 1
		BIT !P2YSpeed-$80 : BMI .P2
		LDA #$01
		CLC : JSL !PlayerClipping
		LDA $03
		LSR A
		STA $03
		CLC : ADC $01				; lower half of hitbox only
		STA $01
		LDA $09
		ADC #$00
		STA $09
		JSL !CheckContact : BCC .P2
		LDY #$00
		JSR .Interact

	.P2
		LDA !MultiPlayer : BEQ .Return		; check PCE slot 2
		LDA !P2Character : BEQ .Return
		BIT !P2YSpeed : BMI .Return
		LDA #$02
		CLC : JSL !PlayerClipping
		LDA $03
		LSR A
		STA $03
		CLC : ADC $01				; lower half of hitbox only
		STA $01
		LDA $09
		ADC #$00
		STA $09
		JSL !CheckContact : BCC .Return
		LDY #$80
		JSR .Interact


	.Return
		LDA !BigRAM : BEQ ..Cloud
		CMP #$01 : BEQ ..Bank01

		..Bank02
		LDA !CurrentMario : BEQ ...R
		JML $01B44F			; overwritten code
	...R	CLC : RTL			; if mario is not in play, he can't have contact

		..Bank01
		LDA !CurrentMario : BEQ ...R
		JSL !GetP1Clipping		; overwritten code
		RTL				; return to handle mario interaction
	...R	REP #$20			;\
		PLA				; | skip the next JSL
		CLC : ADC #$0004		; |
		PHA				;/
		SEP #$20
		CLC : RTL			; return with no contact if mario is not in play

		..Cloud
		LDA $35E0,x : BNE +
		LDA #$00 : JSR .X+3
		LDA #$00 : JSR .Y+3
		LDA $9E,x
		ORA $AE,x : BEQ +
		JSL !SpriteApplySpeed
	+	LDA !CurrentMario : BEQ ...R
		PHK : PEA.w ...Rr-1		;\
		PEA.w $CCC6-1			; |
		JML $01A7F7			; | check mario contact through faux JSR across banks
	...Rr	BCC ...R			; |
		JML $01E80E			; | then simulate overwritten branch
	...R	JML $01E83D			;/


	.Interact
		LDA !BigRAM : BNE .Shared

	.Fly
		INC $35E0,x			; set interaction flag
		PHB : PHK : PLB
		PHY
		TYA
		ASL A
		ROL A
		TAY
		LDA $6DA2,y
		AND #$0F : TAY
		JSR .X
		JSR .Y

		..Done
		JSL !SpriteApplySpeed
		PLY
		LDA $3220,x : STA !P2XPosLo-$80,y
		LDA $3250,x : STA !P2XPosHi-$80,y
		LDA $3210,x : STA $74BA
		LDA $3240,x : STA $74BB
		STZ $7491
		PLB

	.Shared
		REP #$20
		LDA $74BA
		SEC : SBC !BigRAM+1
		STA !P2YPosLo-$80,y
		LDA $7491
		AND #$00FF
		CMP #$0080
		BCC $03 : ORA #$FF00
		CLC : ADC !P2XPosLo-$80,y
		STA !P2XPosLo-$80,y
		SEP #$20
		LDA #$80 : STA !P2SpritePlatform-$80,y
		LDA #$00 : STA !P2YSpeed-$80,y
		LDA !BigRAM
		CMP #$01 : BNE ..R
		PHK : PEA.w ..R-1		; RTL address: ..R
		PEA.w $CCC6-1			; RTS address: $CCC6
		JML $01CA79			; faux JSR across banks
	..R	RTS

		.X
		LDA .CloudSpeedX,y : BPL ..pos
	..neg	BIT $AE,x : BPL ..dec
		CMP $AE,x : BEQ ..R
		BCC ..dec
		BRA ..inc
	..pos	BIT $AE,x : BMI ..inc
		CMP $AE,x : BEQ ..R
		BCS ..inc
	..dec	DEC $AE,x : DEC $AE,x
	..inc	INC $AE,x
	..R	RTS
		.Y
		LDA .CloudSpeedY,y : BPL ..pos
	..neg	BIT $9E,x : BPL ..dec
		CMP $9E,x : BEQ ..R
		BCC ..dec
		BRA ..inc
	..pos	BIT $9E,x : BMI ..inc
		CMP $9E,x : BEQ ..R
		BCS ..inc
	..dec	DEC $9E,x : DEC $9E,x
	..inc	DEC $9E,x : DEC $9E,x
	..R	RTS


	.CloudSpeedX
		db $00,$20,$E0,$00
		db $00,$17,$E9,$00
		db $00,$17,$E9,$00
		db $00,$20,$E0,$00

	.CloudSpeedY
		db $10,$10,$10,$10
		db $20,$17,$17,$20
		db $E0,$E9,$E9,$E0
		db $10,$10,$10,$10




