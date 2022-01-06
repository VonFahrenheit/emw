


	WarpPipe:
		PLX

		LDA !P1MapX : STA !OW_sprite_X,x
		LDA !P1MapY
		INC A
		STA !OW_sprite_Y,x

		SEP #$20
		LDA #$01 : STA !WarpPipe
		LDA #$01 : STA !OW_sprite_Direction,x
		LDA !OW_sprite_Anim,x
		CMP #$03 : BEQ .HandleEntrance

		.AnimGrow
		LDA !OW_sprite_AnimTimer,x
		INC A
		STA !OW_sprite_AnimTimer,x
		CMP #$06 : BNE .Draw
		INC !OW_sprite_Anim,x
		STZ !OW_sprite_AnimTimer,x
		BRA .Draw

		.HandleEntrance
		SEP #$20
		LDA !OW_sprite_Timer,x
		CMP #$07 : BEQ +
		INC !OW_sprite_Timer,x
	+	LDA !MultiPlayer : BEQ +
		LDA !P2MapZ
		ORA !P2MapZ+1 : BNE .Draw
		BRA ++
	+	LDA !P1MapZ
		ORA !P1MapZ+1 : BNE .Draw
	++	STZ !Translevel
		LDA #$15 : STA !GameMode
		LDA #$80 : STA !SPC3
		REP #$20
		LDA !P1MapX : STA !SRAM_overworldX
		LDA !P1MapY : STA !SRAM_overworldY
		SEP #$20
		PHX
		JSL !SaveGame
		PLX

		.Draw
		REP #$20
		LDA !P1MapZ : BEQ +
		CMP #$0010 : BCS +
		BIT !P1MapZSpeed-1 : BPL +
		BRA ..sfx
		+
		LDA !P2MapZ : BEQ +
		CMP #$0010 : BCS +
		BIT !P2MapZSpeed-1 : BPL +
		..sfx
		SEP #$20
		LDA #$04 : STA !SPC1
		REP #$20
		+


		LDA !OW_sprite_Anim,x
		AND #$00FF
		ASL A
		TAY
		LDA .Anim,y : JSR DrawSpriteMain
		LDA !OW_sprite_Anim,x
		AND #$00FF
		CMP #$0003 : BNE .Return

		.DrawPrio
		DEC !OW_sprite_Y,x
		LDA !OW_sprite_Timer,x
		AND #$00FF : STA !OW_sprite_Z,x
		LDA.w #.TM3_main : JSR DrawSpriteMain
		LDA !OW_sprite_Y,x : PHA
		SEC : SBC #$0028
		SEC : SBC !OW_sprite_Z,x
		STA !OW_sprite_Y,x
		LDA #$FFE0 : STA !OW_sprite_Z,x
		LDA.w #.TM1 : JSR DrawSpriteMain
		STZ !OW_sprite_Z,x
		PLA
		INC A
		STA !OW_sprite_Y,x

		.Return
		RTS


		.Anim
		dw .TM0
		dw .TM1
		dw .TM2
		dw .TM3_bottom




	.TM0
	db ..end-..start
	..start
	db $FC,$08,$40,$14,$00
	db $04,$08,$41,$14,$00
	db $0C,$08,$42,$14,$00
	..end

	.TM1
	db ..end-..start
	..start
	db $FC,$08,$50,$14,$00
	db $04,$08,$51,$14,$00
	db $0C,$08,$52,$14,$00
	..end

	.TM2
	db ..end-..start
	..start
	db $FC,$00,$43,$14,$00
	db $04,$00,$44,$14,$00
	db $0C,$00,$45,$14,$00
	db $FC,$08,$53,$14,$00
	db $04,$08,$54,$14,$00
	db $0C,$08,$55,$14,$00
	..end

	.TM3_bottom
	db ..end-..start
	..start
	db $FC,$08,$56,$14,$00
	db $04,$08,$57,$14,$00
	db $0C,$08,$58,$14,$00
	..end

	.TM3_main
	db ..end-..start
	..start
	db $FC,$00,$59,$14,$00
	db $04,$00,$5A,$14,$00
	db $0C,$00,$5B,$14,$00
	db $FC,$08,$46,$14,$00
	db $04,$08,$47,$14,$00
	db $0C,$08,$48,$14,$00
	..end






