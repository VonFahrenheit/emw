

Bumper:

	namespace Bumper

	; $32D0,x = bumper timer

	MAIN:
		PHB : PHK : PLB
		LDA !SpriteStatus,x
		CMP #$08 : BNE .GFX
		JSL GetSpriteClippingE8
		JSL PlayerContact : BCC .GFX
		PHA
		LDA #$10 : STA $32D0,x			; animation
		LDA #$08 : STA !SPC4			; bounce SFX
		PLA
		LSR A : BCC .P2
	.P1	PHA
		LDY #$00
		JSR Interact
		PLA
	.P2	LSR A : BCC .GFX
		LDY #$80
		JSR Interact

		.GFX
		LDX !SpriteIndex
		REP #$10
		LDY.w #ANIM_TM0
		LDA $32D0,x
		AND #$02 : BEQ .Draw
		LDY.w #ANIM_TM1
		.Draw
		STY $04
		SEP #$10
		JSL LOAD_PSUEDO_DYNAMIC
		.Return
		PLB
	INIT:
		RTL

	ANIM:
		.TM0
		dw $0010
		db $32,$F8,$F0,$00
		db $72,$08,$F0,$00
		db $B2,$F8,$00,$00
		db $F2,$08,$00,$00

		.TM1
		dw $0010
		db $32,$F9,$F1,$00
		db $72,$07,$F1,$00
		db $B2,$F9,$FF,$00
		db $F2,$07,$FF,$00


	Interact:
		LDA !P2Status-$80,y : BNE .Return
		LDA !P2XPosLo-$80,y
		CMP !SpriteXLo,x
		LDA !P2XPosHi-$80,y
		SBC !SpriteXHi,x
		EOR #$30
		STA !P2XSpeed-$80,y
		LDA !P2YPosLo-$80,y
		CMP !SpriteYLo,x
		LDA !P2YPosHi-$80,y
		SBC !SpriteYHi,x
		EOR #$30
		STA !P2YSpeed-$80,y
		LDA !P2YSpeed-$80,y : BPL .Return
		JSL P2Bounce
		.Return
		RTS


	namespace off





