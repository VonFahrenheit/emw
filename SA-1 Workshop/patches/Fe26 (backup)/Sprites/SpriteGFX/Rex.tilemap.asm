;============;
;REX TILEMAPS;
;============;

	.TM_Idle00
		%TM24x32($00, $00, $00, $27)

	.TM_Walk00
		%TM24x32($00, $00, $00, $27)
	.TM_Walk01
		%TM24x32($00, $00, $03, $27)
	.TM_Walk02
		%TM24x32($00, $FF, $06, $27)
	.TM_Walk03
		%TM24x32($00, $00, $09, $27)
	.TM_Walk04
		%TM24x32($00, $FF, $0C, $27)

	.TM_Hurt00
		dw $000C
		db $27,$00,$F8,$40
		db $27,$00,$00,$42
		db $27,$08,$00,$43

	.TM_Smush00
		%TM16($00, $00, $45, $27)
	.TM_Smush01
		%TM16($00, $00, $47, $27)

	.TM_Dead00
		%TM16($00, $00, $49, $27)