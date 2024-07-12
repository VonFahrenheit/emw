

	!Blargg_State		= $3280

	!Blargg_SpawnXLo	= $3500
	!Blargg_SpawnXHi	= $3510
	!Blargg_SpawnYLo	= $3520
	!Blargg_SpawnYHi	= $3530


	INIT:
		LDA !SpriteXLo,x : STA !Blargg_SpawnXLo,x
		LDA !SpriteXHi,x : STA !Blargg_SpawnXHi,x
		LDA !SpriteYLo,x
		CLC : ADC #$18
		STA !Blargg_SpawnYLo,x
		LDA !SpriteYHi,x
		ADC #$00
		STA !Blargg_SpawnYHi,x
		STZ !SpriteFloat,x
		LDA #$02 : STA !SpriteGravity,x
		LDA #$18 : STA !SpriteFallSpeed,x
		RTS

	MAIN:

		LDA !Blargg_State,x : BMI .Attack

	.Spy
		BNE ..main
		..init
		JSR ResetPosition
		LDA #$F0 : STA !SpriteYSpeed,x
		BRA ..next

		..main
		LDY !Blargg_State,x
		LDA .YSpeed,y : STA !SpriteYSpeed,x
		STZ !SpriteXSpeed,x
		LDA $32D0,x : BNE ..done

		..next
		INC !Blargg_State,x
		LDY !Blargg_State,x
		CPY #$06 : BCS .StartAttack
		LDA .Time,y : STA $32D0,x
		..done


		BRA .Physics


	.XSpeed	db $18,$E8
	.YSpeed	db $00,$00,$F8,$00,$10,$00
	.Time	db $FF,$20,$20,$40,$10,$20



	.StartAttack
		JSR ResetPosition
		LDA #$80 : STA !Blargg_State,x
		LDA #$30 : STA $32D0,x
		LDA #$D1 : STA !SpriteYSpeed,x
		LDY !SpriteDir,x
		LDA .XSpeed,y : STA !SpriteXSpeed,x
		LDA #$25 : STA !SPC1				; > roar sfx

	.Attack
		LDA $32D0,x : BNE ..done
		STZ !Blargg_State,x
		..done


	.Physics
		JSL APPLY_SPEED


	.Graphics
		REP #$20
		LDY !Blargg_State,x : BMI ..attacking
		..spying
		LDA.w #.SpyTilemap : BRA ..draw

		..attacking
		LDA.w #.MouthClosed
		LDY !SpriteYSpeed,x : BPL ..draw
		LDA.w #.MouthOpen

		..draw
		STA $04
		SEP #$20
		LDA $64 : PHA
		STZ $64
		JSL LOAD_PSUEDO_DYNAMIC_p1
		PLA : STA $64

		RTS



		.SpyTilemap
		dw ..end-..start
		..start
		db $02,$00,$00,$00
		..end

		.MouthOpen
		dw ..end-..start
		..start
		db $02,$F0,$00,$02
		db $02,$00,$00,$04
		db $02,$F0,$10,$06
		db $02,$00,$10,$08
		db $02,$10,$10,$0E
		..end

		.MouthClosed
		dw ..end-..start
		..start
		db $02,$F0,$00,$02
		db $02,$00,$00,$04
		db $02,$F0,$10,$0A
		db $02,$00,$10,$0C
		db $02,$10,$10,$0E
		..end


	ResetPosition:
		LDA !Blargg_SpawnXLo,x : STA !SpriteXLo,x
		LDA !Blargg_SpawnXHi,x : STA !SpriteXHi,x
		LDA !Blargg_SpawnYLo,x : STA !SpriteYLo,x
		LDA !Blargg_SpawnYHi,x : STA !SpriteYHi,x
		JSL SUB_HORZ_POS
		TYA : STA !SpriteDir,x
		RTS


