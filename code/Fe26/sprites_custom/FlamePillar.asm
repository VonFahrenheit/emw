

FlamePillar:

	namespace FlamePillar


	!FlamePillarHeight	= $3280		;
	!FlamePillarMaxHeight	= $3290		;
	!FlamePillarWait	= $32A0		; when set, pillar does not rise or descend
	!FlamePillarSpeed	= $32B0		; amount to add to height going up (each frame)
	!FlamePillarLife	= $32D0		; life timer, if 0 sprite lasts forever
	!FlamePillarDelay1	= $3400		; amount to wait when reaching top
	!FlamePillarDelay2	= $3410		; amount to wait when reaching bottom

	INIT:
		LDA #$01
		STA !FlamePillarSpeed,x
		LDA #$20 : STA !FlamePillarWait,x
		LDA #$40 : STA !FlamePillarMaxHeight,x
		LDA #$40 : STA !FlamePillarDelay1,x
		LDA #$40 : STA !FlamePillarDelay2,x
		RTL


	MAIN:
		PHB : PHK : PLB
		LDA !FlamePillarLife,x
		CMP #$01 : BNE .Live
		STZ !SpriteStatus,x

	.Live

		LDA !FlamePillarWait,x : BEQ .Move
		DEC !FlamePillarWait,x
		BRA .NoMove

	.Move	LDA !FlamePillarSpeed,x : BPL .Rise

	.Fall	CLC : ADC !FlamePillarHeight,x
		BPL .Ok
		LDA !FlamePillarDelay2,x : STA !FlamePillarWait,x
		LDA !FlamePillarSpeed,x
		EOR #$FF
		INC A
		STA !FlamePillarSpeed,x
		LDA #$00 : BRA .Ok

	.Rise	CLC : ADC !FlamePillarHeight,x
		CMP !FlamePillarMaxHeight,x : BCC .Ok
		LDA !FlamePillarDelay1,x : STA !FlamePillarWait,x
		LDA !FlamePillarSpeed,x
		EOR #$FF
		INC A
		STA !FlamePillarSpeed,x
		LDA !FlamePillarMaxHeight,x
	.Ok	STA !FlamePillarHeight,x
		.NoMove

		LDY !FlamePillarHeight,x : BEQ .Smallest

	.Pillar
		LDA !FlamePillarHeight,x : STA $EE			; height = 8px for each chunk
		STZ $EF
		CPY #$01 : BEQ .Small
		CPY #$02 : BEQ .Medium

	.Large
		LDA $EE
		SEC : SBC #$10
		STA $00
		LDA !SpriteYLo,x
		SEC : SBC $00
		STA $EA
		LDA !SpriteYHi,x
		SBC #$00
		BRA ++

	.Medium
		LDA #$00 : BRA +

	.Small
		LDA #$08 : BRA +

	.Smallest
		LDA #$01 : STA $EE : STZ $EF
		LDA #$0F
	+	CLC : ADC !SpriteYLo,x
		STA $EA
		LDA !SpriteYHi,x
		ADC #$00
	++	STA $EB



	.Shared
		LDA #$0C : STA $EC : STZ $ED
		LDA !SpriteXLo,x
		CLC : ADC #$02
		STA $E8
		LDA !SpriteXHi,x
		ADC #$00
		STA $E9
		JSL SpriteAttack_NoKnockback		; attack with no knockback


		LDA !FlamePillarHeight,x
		LSR #4
		INC #2
		ASL #2
		STA !BigRAM+0
		STZ !BigRAM+1

		LDA !FlamePillarHeight,x
		LSR #4
		INC A
		ASL #2
		TAY

		LDA !FlamePillarHeight,x
		EOR #$FF : INC A
		STA $00
		STZ $01
		LDA $14
		CLC : ADC !SpriteIndex
		AND #$04
		BEQ $02 : LDA #$40
		STA $02
		LDA #$10 : STA $03

	-	LDA #$12
		EOR $02
		ORA !SpriteProp,x
		STA !BigRAM+2,y
		LDA #$00 : STA !BigRAM+3,y
		LDA $00 : STA !BigRAM+4,y
		CLC : ADC $03
		STA $00
		LDA $01 : STA !BigRAM+5,y
		LDA #$02 : STA $01
		LDA #$10 : STA $03
		DEY #4 : BPL -


		LDA $64 : PHA
		STZ $64

		LDA.b #!BigRAM : STA $04
		LDA.b #!BigRAM>>8 : STA $05
		JSL LOAD_PSUEDO_DYNAMIC_p2

		PLA : STA $64

		PLB
		RTL








	namespace off




