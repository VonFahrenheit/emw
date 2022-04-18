

	MAIN:
		PHB : PHK : PLB
		LDA $3230,x
		CMP #$08 : BEQ .Active
		CMP #$09 : BEQ .Stunned
		PLB
		RTL

	.Stunned
		LDA $32D0,x : BNE .Interaction
		; EXPLODE
		PLB
		RTL

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
		dw .Tilemap0	: db $08,$01	; 00
		dw .Tilemap1	: db $08,$00	; 01

		.Tilemap0
		dw $0004
		db $30,$00,$00,$00

		.Tilemap1
		dw $0004
		db $30,$00,$00,$02

