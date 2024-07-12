
	INIT:
		JSL SUB_HORZ_POS : TYA : STA !SpriteDir,x
		LDA #$09 : STA !SPC4				; bullet bill shoot sfx
		STZ !SpriteGravity,x
		RTS

	MAIN:

	.Physics
		LDY !SpriteDir,x
		LDA .XSpeed,y : STA !SpriteXSpeed,x
		JSL APPLY_SPEED
		LDA !SpriteStatus,x
		CMP #$08 : BNE .Graphics

	.Interaction
		LDA !SpriteXLo,x
		CLC : ADC #$E4
		STA $E8
		LDA !SpriteXHi,x
		ADC #$FF
		STA $E9
		LDA !SpriteYLo,x
		CLC : ADC #$E4
		STA $EA
		LDA !SpriteYHi,x
		ADC #$FF
		STA $EB
		LDA #$38
		STA $EC
		STA $EE
		STZ $ED
		STZ $EF
		JSL InteractAttacks
		JSL P2Standard : BEQ ..nocontact
		LDA #$02 : STA !SpriteStatus,x
		LDA #$06 : STA !SpriteGravity,x
		..nocontact


	.Graphics
		REP #$20
		LDA.w #.Tilemap : STA $04
		SEP #$20
		JSL LOAD_PSUEDO_DYNAMIC
		RTS


		.Tilemap
		dw ..end-..init
		..init
		db $02,$E8,$E8,$00
		db $02,$F8,$E8,$02
		db $02,$08,$E8,$04
		db $02,$18,$E8,$06
		db $02,$E8,$F8,$08
		db $02,$F8,$F8,$0A
		db $02,$08,$F8,$0C
		db $02,$18,$F8,$0E
		db $02,$E8,$08,$20
		db $02,$F8,$08,$22
		db $82,$08,$08,$0C
		db $82,$18,$08,$0E
		db $02,$E8,$18,$24
		db $02,$F8,$18,$26
		db $82,$08,$18,$04
		db $82,$18,$18,$06
		..end


	.XSpeed
		db $20,$E0


