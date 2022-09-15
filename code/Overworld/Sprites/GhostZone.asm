

	GhostZone:
		PLX

	if !DebugOverworld = 1
	LDA.w #.DebugTilemap : STA !OW_sprite_Tilemap,x
	BRA +
	.DebugTilemap
	db ..end-..start
	..start
	db $00,$00,$90,$3E,$02
	..end
	+
	endif

		LDA !OW_sprite_YSpeed,x
		AND #$00FF : TAY
		LDA !LevelTable4-1,y : BMI +
		STZ !OW_sprite_Num,x
		RTS
		+


		LDA !OW_sprite_XSpeed,x				;\ collision disable bits
		AND #$00FF : STA !BigRAM			;/

		LDA !OW_sprite_X,x : STA $E8
		LDA !OW_sprite_Y,x : STA $EA
		LDA !OW_sprite_Anim,x : STA $EE-1
		AND #$00FF : STA $EC
		SEP #$20
		STZ $EF
		PHX
		SEP #$30

		.CheckP2
		LDA !MultiPlayer : BEQ ..done

		REP #$20
		LDA !P2MapX : STA $E0
		LDA !P2MapY : STA $E2
		LDA #$0010
		STA $E4
		STA $E6
		SEP #$20
		JSL CheckContact : BCC ..done
		LDA !BigRAM : STA !P2MapGhost
		CMP #$0F : BEQ ..done
		AND #$03 : BNE ..sety
		..setx
		REP #$20
		LDA $E8 : STA !P2MapX
		SEP #$20
		BRA ..done
		..sety
		REP #$20
		LDA $EA : STA !P2MapY
		SEP #$20
		..done

		.CheckP1
		REP #$20
		LDA !P1MapX : STA $E0
		LDA !P1MapY : STA $E2
		LDA #$0010
		STA $E4
		STA $E6
		SEP #$20
		JSL CheckContact : BCC ..done
		LDA !BigRAM : STA !P1MapGhost
		CMP #$0F : BEQ ..done
		AND #$03 : BNE ..sety
		..setx
		REP #$20
		LDA $E8 : STA !P1MapX
		SEP #$20
		BRA ..done
		..sety
		REP #$20
		LDA $EA : STA !P1MapY
		SEP #$20
		..done

		REP #$30
		PLX
		RTS


