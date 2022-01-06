

	BlastHandler:
		PLX

		INC !MapEvent

		LDA !CircleRadius
		CMP #$0030 : BEQ .Process
		RTS

		.Process
		SEP #$20
		LDA #$0F : STA !P1MapGhost
		STZ !MapHidePlayers
		REP #$20

		.Explosions
		LDA !OW_sprite_AnimTimer,x
		CMP #$0040 : BNE ..done
		LDA #$0007 : STA $00
		TXY
		..loop
		JSR GetSpriteIndex
		JSR ResetSprite
		LDA #$0004 : STA !OW_sprite_Num,x
		LDA !OW_sprite_X,y : STA !OW_sprite_X,x
		LDA !OW_sprite_Y,y : STA !OW_sprite_Y,x
		LDA !OW_sprite_Z,y : STA !OW_sprite_Z,x
		PHY
		LDY $00
		SEP #$20
		LDA .ExplosionSpeed_x,y : STA !OW_sprite_XSpeed,x
		LDA .ExplosionSpeed_y,y : STA !OW_sprite_YSpeed,x
		LDA .ExplosionSpeed_z,y : STA !OW_sprite_ZSpeed,x
		REP #$20
		PLY
		DEC $00 : BPL ..loop
		TYX
		..done


		DEC !OW_sprite_AnimTimer,x

		STZ $2250
		LDA !OW_sprite_AnimTimer,x : STA $2251
		LDA !OW_sprite_X,x : STA $2253
		NOP : BRA $00
		LDA $2306 : STA $00
		LDA #$0040
		SEC : SBC !OW_sprite_AnimTimer,x
		STA $2251
		LDA !SRAM_overworldX : STA $2253
		NOP : BRA $00
		LDA $2306
		CLC : ADC $00
		ROR A
		LSR #5
		STA !P1MapX
		LDA !OW_sprite_AnimTimer,x : STA $2251
		LDA !OW_sprite_Y,x : STA $2253
		NOP : BRA $00
		LDA $2306 : STA $00
		LDA #$0040
		SEC : SBC !OW_sprite_AnimTimer,x
		STA $2251
		LDA !SRAM_overworldY : STA $2253
		NOP : BRA $00
		LDA $2306
		CLC : ADC $00
		ROR A
		LSR #5
		STA !P1MapY

		LDA !OW_sprite_AnimTimer,x : BNE .Return
		STZ !OW_sprite_Num,x
		STZ !Cutscene

		.Return

		RTS


		.ExplosionSpeed

		..x
		db $00,$00,$00,$08,$08,$08,$10,$10

		..y
		db $00,$F4,$E8,$E8,$F4,$00,$00,$F4

		..z
		db $10,$18,$20,$10,$18,$20,$10,$18





