
	MAIN:

	.Physics
		LDA !ExtraBits,x
		AND #$04 : BNE ..done
		LDY !SpriteDir,x
		LDA DATA_XSpeed,y : STA !SpriteXSpeed,x
		JSL APPLY_SPEED
		..done

	.Interaction
		JSL GetSpriteClippingE8
		JSL P2Attack : BCC ..noattack
		TYA
		ASL A : ROL A
		TAY
		BRA ..collect
		..noattack
		JSL PlayerContact : BCC ..nocontact
		DEC A
		CMP #$02
		BCC $02 : LDA #$00
		TAY
		..collect
		STZ !SpriteStatus,x
		LDA !P1CoinIncrease,y
		INC A : STA !P1CoinIncrease,y
		STZ $00
		STZ $01
		LDA.b #!Glitter_Num : JSL SpawnExSprite
		..nocontact

	.Graphics
		REP #$20
		LDA.w #ANIM : JSL UPDATE_ANIM
		JSL LOAD_TILEMAP_COLOR
	INIT:
		RTS

	DATA:
	.XSpeed
		db $08,$F8


	ANIM:
	dw .Frame0	: db $04,$01	; 00
	dw .Frame1	: db $04,$02	; 01
	dw .Frame2	: db $04,$03	; 02
	dw .Frame1	: db $04,$00	; 03

	.Frame0
	dw $0004
	db $22,$00,00,$45

	.Frame1
	dw $0008
	db $20,$04,$00,$47
	db $A0,$04,$08,$47

	.Frame2
	dw $0008
	db $20,$04,$00,$57
	db $A0,$04,$08,$57

