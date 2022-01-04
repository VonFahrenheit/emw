

	GhostZone:
		PLX

	STZ $7FFF

		LDA !OW_sprite_Y,x
		STA $05
		STA $0A
		LDA #$1010 : STA $06
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
		INC !P2Ghost
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
		INC !P1Ghost
		..done

		REP #$30
		PLX
		RTS


