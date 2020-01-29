FlamePillar:

	namespace FlamePillar


	!FlamePillarHeight	= $3280,x	; measured in 8px chunks
	!FlamePillarLife	= $32D0,x	; life timer, if 0 sprite lasts forever
	!FlamePillarMaxHeight	= $32A0,x



	INIT:
		PHB : PHK : PLB
		LDA #$08 : STA !FlamePillarMaxHeight
		PLB
		RTL


	MAIN:
		PHB : PHK : PLB
		JSL SPRITE_OFF_SCREEN_Long

		LDA !FlamePillarLife
		CMP #$01 : BNE .Live
		STZ $3230,x

	.Live
		LDA !SpriteAnimTimer
		INC A
		CMP #$10 : BNE .Rise
		LDA !FlamePillarHeight
		INC A
		STA !FlamePillarHeight
		CMP !FlamePillarMaxHeight : BNE .Ok
		STZ !FlamePillarHeight
	.Ok	LDA #$00
	.Rise	STA !SpriteAnimTimer


		LDY !FlamePillarHeight : BEQ .Smallest

	.Pillar
		LDA !FlamePillarHeight
		ASL #3
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
		INC A
		ASL #2
		STA !BigRAM+0
		STZ !BigRAM+1
		LDA !FlamePillarHeight
		ASL #2
		TAY
		STZ $00
		LDA !SpriteAnimTimer
		AND #$04
		ASL #4
		STA $01
	-	LDA #$25
		EOR $01
		STA !BigRAM+2,y
		LDA #$00 : STA !BigRAM+3,y
		LDA $00 : STA !BigRAM+4,y
		LDA !GFX_status+$19
		CPY #$00 : BEQ .Top
		INC #2
	.Top	STA !BigRAM+5,y
		LDA $00
		SEC : SBC #$08
		CPY #$04 : BNE .08
		SEC : SBC #$08
	.08	STA $00
		DEY #4 : BPL -

		LDA.b #!BigRAM : STA $04
		LDA.b #!BigRAM>>8 : STA $05
		JSL LOAD_TILEMAP_HiPrio_Long

		PLB
		RTL








	namespace off




