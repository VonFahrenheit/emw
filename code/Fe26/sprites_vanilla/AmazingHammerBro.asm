
; TODO:
; TO DO:
; - make it work with platforms
;	- maybe just place it on any other sprite?


	INIT:
	MAIN:
		LDA !SpriteStatus,x
		CMP #$08 : BNE .Graphics

	.Attack
		LDA $32D0,x : BNE ..done
		LDY !Difficulty
		LDA .WaitTimer,y : STA $32D0,x
		LDA !SpriteDir,x
		EOR #$01 : STA !SpriteDir,x
		TAY
		LDA .HammerX,y : STA $00
		LDA #$00 : STA $01
		LDA .HammerSpeed,y : STA $02
		LDA #$D0 : STA $03
		LDA.b #!Hammer_Num : JSL SpawnExSprite
		..done

	.Physics
		JSL APPLY_SPEED

	.Interaction
		JSL GetSpriteClippingE8
		JSL InteractAttacks : BCS ..die
		JSL P2Standard : BEQ ..nocontact
		..fall
		STZ !SpriteYSpeed,x
		..die
		LDA #$02 : STA !SpriteStatus,x
		..nocontact

	.Graphics
		REP #$20
		LDA.w #.Tilemap : STA $04
		SEP #$20
		JSL LOAD_PSUEDO_DYNAMIC

		RTS


		.Tilemap
		dw ..end-..start
		..start
		db $22,$F8,$00,$00
		db $22,$08,$00,$02
		db $20,$00,$F8,$04
		db $20,$08,$F8,$14
		..end

	.WaitTimer
		db $20,$10,$08
	.HammerX
		db $08,$F8
	.HammerSpeed
		db $20,$E0





