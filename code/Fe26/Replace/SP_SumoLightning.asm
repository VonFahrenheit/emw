


	pushpc
	org $02DEE6
		JSL SumoLightning		; source: JSL $028A44
	pullpc
	SumoLightning:

		PHX
		LDX #$04
	.Loop	PHX
		JSL !GetSpriteSlot
		BMI .NoSpawn

		LDA #$36 : STA $3200,y
		LDA #$29 : STA !NewSpriteNum,y
		TYX
		JSL $07F7D2			; | > Reset sprite tables
		JSL $0187A7			; | > Reset custom sprite tables
		LDA #$08
		STA !ExtraBits,x
		STA $3230,x
		LDA #$30 : STA $3290,x		; height
		LDA #$01 : STA $32B0,x		; speed
		LDA #$20 : STA $35D0,x		; delay at top
		TXY
		PLX
		LDA.l .X+0,x : STA $00
		LDA.l .X+5,x : STA $01
		STZ $02
		STZ $03
		PHX
		LDX !SpriteIndex
		JSR SPRITE_A_SPRITE_B_ADD
		PLX
		LDA.l .Time,x : STA $32A0,y	; delay timer
		CLC : ADC $3290,y
		CLC : ADC $3290,y
		CLC : ADC $35D0,y
		STA $32D0,y			; life timer = total time required to go back down
		DEX : BPL .Loop
		PHX

		.NoSpawn
		PLX
		PLX
		JML $028A44

	.X	db $00,$F0,$10,$E0,$20
		db $00,$FF,$00,$FF,$00

	.Time	db $00,$20,$20,$40,$40

