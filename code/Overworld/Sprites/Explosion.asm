

	Explosion:
		PLX

		JSR SpriteSpeed
		REP #$20

		.HandleAnim
		LDA !OW_sprite_Anim,x
		AND #$00FF
		ASL #2 : TAY
		SEP #$20

		LDA !OW_sprite_AnimTimer,x
		INC A
		CMP .Anim+2,y : BNE ..same
		LDA .Anim+3,y : BNE ..next
		STZ !OW_sprite_Num,x
		REP #$20
		RTS

		..next
		STA !OW_sprite_Anim,x
		ASL #2
		TAY
		LDA #$00
		..same
		STA !OW_sprite_AnimTimer,x
		REP #$20
		LDA .Anim+0,y : STA !OW_sprite_Tilemap,x

		.Return
		RTS


	.Anim
	dw .BlackOrb	: db $02,$01
	dw .WhiteOrb	: db $02,$02
	dw .Smoke1	: db $04,$03
	dw .Smoke2	: db $04,$04
	dw .Smoke3	: db $04,$00


	.BlackOrb
	db ..end-..start
	..start
	db $00,$00,$9A,$1C,$02
	..end

	.WhiteOrb
	db ..end-..start
	..start
	db $00,$00,$9C,$1C,$02
	..end

	.Smoke1
	db ..end-..start
	..start
	db $00,$00,$9E,$1C,$02
	..end

	.Smoke2
	db ..end-..start
	..start
	db $00,$00,$B0,$1C,$02
	..end

	.Smoke3
	db ..end-..start
	..start
	db $00,$00,$B2,$1C,$02
	..end













