;=================;
;KINGKING TILEMAPS;
;=================;
; Prop, X1, Y1, T1, X2, Y2, T2

	; -- Head --

	.HeadIdle00
		%LTM32x32($30, $F0, $D0, $0004)
	.HeadIdle01
		%LTM32x32($30, $F0, $D0, $011C)
	.HeadIdle02
		%LTM32x32($30, $F0, $D0, $022C)
	.HeadIdle03
		%LTM32x32($30, $F0, $D0, $026C)

	.HeadRoar00
		%LTM32x32($30, $F0, $D0, $0000)

	.HeadBreath00
		%LTM32x32($30, $F0, $D0, $0008)

	.HeadHurt00
		%LTM32x32($30, $F0, $D0, $0100)

	.HeadSquat00
		%LTM32x32($30, $F0, $D5, $0200)

	.HeadJump00
		%LTM40x32($30, $F0, $D0, $0226)

	.HeadCharge00
		%LTM32x32($30, $E8, $E4, $02AC)
	.HeadCharge01
		%LTM32x32($30, $E8, $E4, $01CC)
	.HeadCharge02
		%LTM32x32($30, $E8, $E4, $02A0)


	; -- Crown --

	.CrownIdle00
		%Crown($66, $01, $C7, $00)
	.CrownIdle01
		%Crown($66, $01, $C7, $00)
	.CrownIdle02
		%Crown($66, $01, $C7, $00)
	.CrownIdle03
		%Crown($66, $01, $C7, $00)

	.CrownRoar00
		%Crown($66, $05, $C8, $02)

	.CrownBreath00
		%Crown($66, $F0, $D0, $00)

	.CrownHurt00
		%Crown($66, $00, $BC, $01)

	.CrownSquat00
		%Crown($66, $01, $CC, $00)

	.CrownJump00
		%Crown($66, $05, $C8, $02)

	.CrownCharge00
		%Crown($26, $1B, $DE, $02)
	.CrownCharge01
		%Crown($26, $1B, $DE, $02)
	.CrownCharge02
		%Crown($26, $1B, $DE, $02)


	; -- Body --

	.BodyIdle00
		%LTM40x32($30, $F0, $F0, $0040)

	.BodyWalk00
		%LTM40x32($30, $F0, $F0, $0040)
	.BodyWalk01
		%LTM40x32($30, $F0, $F0, $0045)
	.BodyWalk02
		%LTM40x32($30, $F0, $F0, $004A)
	.BodyWalk03
		%LTM40x32($30, $F0, $F0, $00A0)
	.BodyWalk04
		%LTM40x32($30, $F0, $F0, $00A5)

	.BodyThrow00
		%LTM40x32($30, $F0, $F0, $01A0)

	.BodyStomp00
		%LTM40x32($30, $F0, $F0, $00AA)

	.BodyHurt00
		%LTM40x32($30, $F0, $F0, $0140)

	.BodySquat00
		%LTM40x32($30, $F8, $F0, $0241)

	.BodyJump00
		%LTM40x32($30, $F7, $F0, $0267)

	.BodyCharge00
		%LTM40x32($30, $F8, $F0, $0127)
	.BodyCharge01
		%LTM40x32($30, $F8, $F0, $0187)
	.BodyCharge02
		%LTM40x32($30, $F8, $F0, $01E7)