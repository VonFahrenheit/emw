

	MAIN:
		PHB : PHK : PLB
		LDA $3230,x
		CMP #$08 : BEQ .Active
		CMP #$09 : BEQ .Stunned
		PLB
		RTL

	.Stunned
		; ROLLING CODE
		BRA .Interaction

	.Active
		LDY $3320,x
		LDA DATA_XSpeed,y : STA !SpriteXSpeed,x
		JSL APPLY_SPEED

	.Interaction
		; INTERACT

	.Graphics
		REP #$20
		LDA.w #ANIM : JSL UPDATE_ANIM
		JSL LOAD_PSUEDO_DYNAMIC
		PLB
	INIT:
		RTL


	DATA:
	.XSpeed
		db $08,$F8


	ANIM:
		dw .Walk0	: db $08,$01	; 00
		dw .Walk1	: db $08,$02	; 01
		dw .Walk2	: db $08,$03	; 02
		dw .Walk1	: db $08,$00	; 03
		dw .Rolling	: db $FF,$04	; 04

		.Walk0
		dw $0004
		db $30,$00,$00,$02

		.Walk1
		dw $0004
		db $30,$00,$00,$04

		.Walk2
		dw $0004
		db $30,$00,$00,$06

		.Rolling
		dw $0004
		db $30,$00,$00,$00

