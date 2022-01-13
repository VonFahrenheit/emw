

	CrashingAirship:
		PLX

		LDA !OW_sprite_Num-1,x : BMI .Main

	.Init
		ORA #$8000 : STA !OW_sprite_Num-1,x
		LDA #$0018 : STA !OW_sprite_X,x
		LDA #$0370 : STA !OW_sprite_Y,x
		LDA #$00D0 : STA !OW_sprite_Z,x
		LDA #$0001 : STA !OW_sprite_Direction,x

	.Main

		.CutsceneMovement
		LDA #$0001 : STA !Cutscene			; overworld cutscene 1
		INC !MapLockCamera
		INC !MapEvent
		LDA !OW_sprite_X,x	
		SEC : SBC #$0078
		BPL $03 : LDA #$0000
		LSR A
		ADC.w #$B8-$78/2
		STA $00
		LDA !OW_sprite_Y,x
		SEC : SBC #$0078+$001C
		LSR A
		ADC.w #$0370-$78/2
		STA $02
		JSR UpdateCamera

		LDA !OW_sprite_X,x
		CMP #$00B8 : BCS ..crash
		CMP #$0090 : BEQ ..dropmario
		BCC ..carrymario
		LDA #$000F : STA !P1MapGhost
		BIT !P1MapZSpeed-1 : BPL ..done
		SEP #$20
		LDA #$80 : STA !P1MapForceFlip
		REP #$20
		BRA ..done

		..carrymario
		INC !MapHidePlayers
		INC !CircleForceCenter
		LDA #$00D4 : STA !P1MapX
		LDA #$0370 : STA !P1MapY
		BRA ..done

		..dropmario
		STZ !MapHidePlayers
		SEP #$20
		LDA #$20 : STA !P1MapZSpeed
		REP #$20
		LDA !OW_sprite_X,x : STA !P1MapX
		LDA !OW_sprite_Y,x : STA !P1MapY
		LDA !OW_sprite_Z,x : STA !P1MapZ
		BRA ..done

		..crash
		STZ !OW_sprite_Num,x
		LDA.w #!event_CrashedAirship : JSR GetEventCoords
		LDA.w #!event_CrashedAirship : JSR RealTimeEvent
		SEP #$20
		LDA #$18 : STA !SPC4
		LDA #$15 : STA !GameMode
		LDA.b #!IntroLevel_UnexploredHill : STA $6109
		LDA.b #!IntroLevel_UnexploredHill>>8 : STA $7F11
		LDA #$02 : STA !StoryFlags+$00
		JSL !SaveGame
		REP #$20
		RTS
		..done


		.Wobble
		SEP #$20
		INC !OW_sprite_Timer,x
		LDA !OW_sprite_Timer,x
		LSR #4
		SEC : SBC #$08
		BPL $02 : EOR #$FF
		SEC : SBC #$10
		STA !OW_sprite_ZSpeed,x
		LDA #$0A : STA !OW_sprite_XSpeed,x
		JSR SpriteSpeed
		REP #$20

		JSR RandomExplosions

		.DrawAirship
		LDA.w #.Tilemap : STA !OW_sprite_Tilemap,x

		.DrawShadow
		LDA !OW_sprite_X,x
		SEC : SBC #$0008
		SEC : SBC $1A
		STA $00
		LDA !OW_sprite_Y,x
		SEC : SBC $1C
		STA $01
		LDA.w #.BigShadow : STA $02
		SEP #$20
		LDA #$02 : STA $0D
		LDA #$08 : STA $0E
		PHX
		JSL !SpriteBG
		PLX
		REP #$20
		RTS




	.Tilemap
	db ..end-..start
	..start
	db $F0,$F0,$CA,$1C,$02
	db $00,$F0,$CC,$1C,$02
	db $F0,$00,$EA,$1C,$02
	db $00,$00,$EC,$1C,$02
	db $10,$00,$EE,$1C,$02
	..end

	.BigShadow
	db $00,$00,$E8,$1C
	db $10,$00,$E8,$5C





