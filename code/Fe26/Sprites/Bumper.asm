Bumper:

	namespace Bumper


	; $32D0,x = bumper timer


	MAIN:
		PHB : PHK : PLB
		LDA $3230,x
		CMP #$08 : BCC .GFX

		LDA $3220,x
		SEC : SBC #$04
		STA $04
		LDA $3250,x
		SBC #$00
		STA $0A
		LDA $3210,x
		SEC : SBC #$04
		STA $05
		LDA $3240,x
		SBC #$00
		STA $0B
		LDA #$18
		STA $06
		STA $07
		SEC : JSL !PlayerClipping
		BCC .GFX
		PHA
		LDA #$10 : STA $32D0,x		; animation
		LDA #$08 : STA !SPC4		; SFX
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
		REP #$20
		LDA.w #ANIM_TM0 : STA $04
		LDA $32D0,x
		AND #$0002 : BEQ .Draw
		LDA.w #ANIM_TM1 : STA $04
		.Draw
		SEP #$30
		JSL LOAD_PSUEDO_DYNAMIC
		.Return
		PLB
	INIT:
		RTL

	ANIM:
		.TM0
		dw $0010
		db $32,$F8,$F8,$00
		db $72,$F7,$F8,$00
		db $B2,$F8,$08,$00
		db $F2,$F7,$08,$00

		.TM1
		dw $0010
		db $32,$F9,$F9,$00
		db $72,$F8,$F9,$00
		db $B2,$F9,$07,$00
		db $F2,$F8,$07,$00


	Interact:
		LDA !P2Status-$80,y : BNE .Return
		LDA !P2XPosLo-$80,y
		CMP $3220,x
		LDA !P2XPosHi-$80,y
		SBC $3250,x
		EOR #$30
		STA !P2XSpeed-$80,y
		LDA !P2YPosLo-$80,y
		CMP $3210,x
		LDA !P2YPosHi-$80,y
		SBC $3240,x
		EOR #$30
		STA !P2YSpeed-$80,y
		LDA !P2Character-$80,y : BNE .PCE
		.Mario
		LDA !P2XSpeed-$80,y : STA !MarioXSpeed
		LDA !P2YSpeed-$80,y : STA !MarioYSpeed
		.PCE
		LDA !P2YSpeed-$80,y : BPL .Return
		JSL P2Bounce
		.Return
		RTS


	namespace off





