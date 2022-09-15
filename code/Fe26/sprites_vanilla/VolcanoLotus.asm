

	!LotusState	= $BE



	MAIN:

	.Physics
		JSL APPLY_SPEED						; move (really just gravity)

	.Attack
		LDA !LotusState,x : BNE ..aggro
		REP #$20
		LDA.w #DATA_AggroSightBox : JSL LOAD_HITBOX
		JSL PlayerContact : BCC ..done
		..aggro
		LDA $32D0,x : BNE ..done
		LDA #$40 : STA $32D0,x
		LDY !LotusState,x
		LDA DATA_NextAnim,y : STA !SpriteAnimIndex,x
		STZ !SpriteAnimTimer,x
		LDA DATA_NextState,y : STA !LotusState,x
		CMP #$02 : BNE ..done
		..fire
		LDY #$03
	-	LDA #$04 : STA $00
		STZ $01
		LDA DATA_FireXSpeed,y : STA $02
		LDA DATA_FireYSpeed,y : STA $03
		PHY
		LDA.b #!VolcanoLotusFire_Num : JSL SpawnExSprite
		PLY
		DEY : BPL -
		..done


	.Interaction
		JSL GetSpriteClippingE8
		JSL InteractAttacks : BCC ..nocontact			;\
		LDA #$04 : STA !SpriteStatus,x				; | if hit, turn to smoke puff
		..nocontact						;/
		JSL P2Standard						; spiky surface, so no checks after


	.Graphics
		REP #$20
		LDA.w #ANIM : JSL UPDATE_ANIM
		JSL LOAD_PSUEDO_DYNAMIC

	INIT:
		RTS


	DATA:
	.NextState
		db $01,$02,$00
	.NextAnim
		db $02,$04,$00

	.AggroSightBox
		dw $FFB0,$FF80 : db $B0,$FF

	.FireXSpeed
		db $10,$F0,$06,$FA
	.FireYSpeed
		db $EC,$EC,$E8,$E8

	ANIM:
		; idle
		dw .Closed_idle	: db $10,$01	; 00
		dw .Half_idle	: db $10,$00	; 01

		; prepare
		dw .Closed_prep	: db $03,$03	; 02
		dw .Half_prep	: db $03,$02	; 03

		; fire
		dw .Half_prep	: db $04,$05	; 04
		dw .Open	: db $FF,$05	; 05



		.Closed
		..idle
		dw $0018
		db $20,$F8,$08,$10
		db $20,$00,$08,$11
		db $60,$08,$08,$11
		db $60,$10,$08,$10
		db $29,$00,$01,$00
		db $29,$08,$01,$01
		..prep
		dw $0018
		db $20,$F8,$08,$10
		db $20,$00,$08,$11
		db $60,$08,$08,$11
		db $60,$10,$08,$10
		db $29,$00,$00,$00
		db $29,$08,$00,$01

		.Half
		..idle
		dw $0018
		db $20,$F8,$08,$10
		db $20,$00,$08,$11
		db $60,$08,$08,$11
		db $60,$10,$08,$10
		db $29,$00,$01,$02
		db $29,$08,$01,$03
		..prep
		dw $0018
		db $20,$F8,$08,$10
		db $20,$00,$08,$11
		db $60,$08,$08,$11
		db $60,$10,$08,$10
		db $29,$00,$00,$02
		db $29,$08,$00,$03

		.Open
		dw $0018
		db $20,$F8,$08,$10
		db $20,$00,$08,$11
		db $60,$08,$08,$11
		db $60,$10,$08,$10
		db $29,$00,$00,$12
		db $29,$08,$00,$13


