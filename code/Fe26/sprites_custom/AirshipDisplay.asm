
AirshipDisplay:

	namespace AirshipDisplay

	INIT:
		LDA #$01 : STA !SpriteDir,x
	MAIN:
		PHB : PHK : PLB
		LDA !SPC3 : BPL +
		LDA #$01 : STA !SpriteAnimIndex
		+
		LDA !SpriteAnimIndex : BEQ +
		INC $3280,x
		LDA $3280,x
		REP #$20
		AND #$00FF
		LSR A
		SEC : SBC #$0040
		BPL $03 : EOR #$FFFF
		CLC : ADC #$0080
		STA !LightG
		STA !LightB
		SEP #$20
		LDA !SpriteAnimIndex
	+	ASL A
		TAY
		REP #$20
		LDA .Anim,y : STA $04
		SEP #$20
		JSL LOAD_TILEMAP
		PLB
		RTL

		.Anim
		dw .GreenTM
		dw .RedTM


		.GreenTM
		dw $0014
		db $3B,$10,$0A,$E0	; map
		db $3B,$20,$0A,$E2
		db $3B,$30,$0A,$E4	; text
		db $3B,$40,$FF,$EA	; text
		db $3B,$48,$17,$EC	; ?

		.RedTM
		dw $0010
		db $39,$10,$0A,$E6	; ALERT
		db $39,$20,$0A,$E8
		db $39,$40,$FF,$EA	; text
		db $39,$48,$17,$EE	; !

	namespace off
