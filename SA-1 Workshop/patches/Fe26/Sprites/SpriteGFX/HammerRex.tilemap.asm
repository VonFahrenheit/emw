;===================;
;HAMMER REX TILEMAPS;
;===================;

	.TM_Idle00
		%TM24x32($00, $00, $00, $2B)

	.TM_Walk00
		%TM24x32($00, $00, $00, $2B)
	.TM_Walk01
		%TM24x32($00, $00, $03, $2B)
	.TM_Walk02
		%TM24x32($00, $FF, $06, $2B)
	.TM_Walk03
		%TM24x32($00, $00, $09, $2B)
	.TM_Walk04
		dw $000C
		db $2B,$00,$EF,$0C
		db $2B,$00,$FF,$2C
		db $2B,$08,$FF,$2D


	.TM_Hurt00
		dw $000C
		db $2B,$00,$F8,$40
		db $2B,$00,$00,$42
		db $2B,$08,$00,$43

	.TM_Smush00
		%TM16($00, $00, $45, $2B)
	.TM_Smush01
		%TM16($00, $00, $47, $2B)

	.TM_Dead00
		%TM16($00, $00, $49, $2B)

	.TM_Prep00
		dw $0014
		db $27,$06,$FA,$0E
		db $2B,$00,$F0,$00
		db $2B,$08,$F0,$01
		db $2B,$00,$00,$20
		db $2B,$08,$00,$21

	.TM_Throw00
		dw $000C
		db $2B,$00,$F0,$4B
		db $2B,$00,$00,$4D
		db $2B,$08,$00,$4E