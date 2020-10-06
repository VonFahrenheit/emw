FlamePillar:

	namespace FlamePillar


	!FlamePillarHeight	= $3280,x	;
	!FlamePillarMaxHeight	= $3290,x	;
	!FlamePillarLife	= $32D0,x	; life timer, if 0 sprite lasts forever
	!FlamePillarWait	= $32A0,x	; when set, pillar does not rise or descend
	!FlamePillarSpeed	= $32B0,x	; amount to add to height going up (each frame)
	!FlamePillarDelay1	= $35D0,x	; amount to wait when reaching top
	!FlamePillarDelay2	= $35E0,x	; amount to wait when reaching bottom

	INIT:
		PHB : PHK : PLB
		LDA #$01
		STA !FlamePillarSpeed
		LDA #$20 : STA !FlamePillarWait
		LDA #$40 : STA !FlamePillarMaxHeight
		LDA #$40 : STA !FlamePillarDelay1
		LDA #$40 : STA !FlamePillarDelay2
		PLB
		RTL


	MAIN:
		PHB : PHK : PLB
		JSL SPRITE_OFF_SCREEN_Long

		LDA !FlamePillarLife
		CMP #$01 : BNE .Live
		STZ $3230,x

	.Live

		LDA !FlamePillarWait : BEQ .Move
		DEC !FlamePillarWait
		BRA .NoMove

	.Move	LDA !FlamePillarSpeed : BPL .Rise

	.Fall	CLC : ADC !FlamePillarHeight
		BPL .Ok
		LDA !FlamePillarDelay2 : STA !FlamePillarWait
		LDA !FlamePillarSpeed
		EOR #$FF
		INC A
		STA !FlamePillarSpeed
		LDA #$00 : BRA .Ok

	.Rise	CLC : ADC !FlamePillarHeight
		CMP !FlamePillarMaxHeight : BCC .Ok
		LDA !FlamePillarDelay1 : STA !FlamePillarWait
		LDA !FlamePillarSpeed
		EOR #$FF
		INC A
		STA !FlamePillarSpeed
		LDA !FlamePillarMaxHeight
	.Ok	STA !FlamePillarHeight
		.NoMove

		LDY !FlamePillarHeight : BEQ .Smallest

	.Pillar
		LDA !FlamePillarHeight
		STA $07				; height = 8px for each chunk
		CPY #$01 : BEQ .Small
		CPY #$02 : BEQ .Medium

	.Large
		LDA $07
		SEC : SBC #$10
		STA $00
		LDA $3210,x
		SEC : SBC $00
		STA $05
		LDA $3240,x
		SBC #$00
		BRA ++

	.Medium
		LDA #$00 : BRA +

	.Small
		LDA #$08 : BRA +

	.Smallest
		LDA #$01 : STA $07
		LDA #$0F
	+	CLC : ADC $3210,x
		STA $05
		LDA $3240,x
		ADC #$00
	++	STA $0B



	.Shared
		LDA #$0C : STA $06
		LDA $3220,x
		CLC : ADC #$02
		STA $04
		LDA $3250,x
		ADC #$00
		STA $0A
		SEC : JSL !PlayerClipping
		BCC $04 : JSL !HurtPlayers



		LDA !FlamePillarHeight
		LSR #3
		INC #2
		ASL #2
		STA !BigRAM+0
		STZ !BigRAM+1

		LDA !FlamePillarHeight
		LSR #3
		INC A
		ASL #2
		TAY

		LDA !FlamePillarHeight
		EOR #$FF : INC A
		STA $00
		LDA !SpriteTile,x : STA $01
		LDA $14
		CLC : ADC !SpriteIndex
		AND #$04
		BEQ $02 : LDA #$40
		STA $02
		LDA #$10 : STA $03

	-	LDA #$34
		EOR $02
		ORA !SpriteProp,x
		STA !BigRAM+2,y
		LDA #$00 : STA !BigRAM+3,y
		LDA $00 : STA !BigRAM+4,y
		CLC : ADC $03
		STA $00
		LDA $01 : STA !BigRAM+5,y
		LDA !SpriteTile,x
		INC #2
		STA $01
		LDA #$08 : STA $03
		DEY #4 : BPL -

		LDA.b #!BigRAM : STA $04
		LDA.b #!BigRAM>>8 : STA $05
		JSL LOAD_TILEMAP_HiPrio_Long

		PLB
		RTL








	namespace off




