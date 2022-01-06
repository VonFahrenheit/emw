

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

		LDA !OW_sprite_Y,x
		STA $05
		STA $0A
		LDA !OW_sprite_Anim,x : STA $06
		LDA !OW_sprite_X,x
		SEP #$20
		STA $04
		XBA : STA $0A
		PHX
		SEP #$30

		.CheckP2
		LDA !MultiPlayer : BEQ ..done
		LDA !P2MapX : STA $00
		LDA !P2MapX+1 : STA $08
		LDA !P2MapY : STA $01
		LDA !P2MapY+1 : STA $09
		LDA #$10
		STA $02
		STA $03
		JSL !Contact16 : BCC ..done
		LDA !BigRAM : STA !P2MapGhost
		CMP #$0F : BEQ ..done
		AND #$03 : BNE ..sety
		..setx
		LDA $04 : STA !P2MapX
		LDA $0A : STA !P2MapX+1
		BRA ..done
		..sety
		LDA $05 : STA !P2MapY
		LDA $0B : STA !P2MapY+1
		..done

		.CheckP1
		LDA !P1MapX : STA $00
		LDA !P1MapX+1 : STA $08
		LDA !P1MapY : STA $01
		LDA !P1MapY+1 : STA $09
		LDA #$10
		STA $02
		STA $03
		JSL !Contact16 : BCC ..done
		LDA !BigRAM : STA !P1MapGhost
		CMP #$0F : BEQ ..done
		AND #$03 : BNE ..sety
		..setx
		LDA $04 : STA !P1MapX
		LDA $0A : STA !P1MapX+1
		BRA ..done
		..sety
		LDA $05 : STA !P1MapY
		LDA $0B : STA !P1MapY+1
		..done

		REP #$30
		PLX
		RTS


