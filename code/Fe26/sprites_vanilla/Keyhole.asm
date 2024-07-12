

	MAIN:

	.GetBlockType
		REP #$30
		LDA #$0000
		LDY #$FFF0
		JSL GetMap16_Sprite
		CMP #$0000 : BEQ .Water
		CMP #$0002 : BNE .Air
		.Water
		LDA #$00FF : STA !BigRAM
		BRA +
		.Air
		STZ !BigRAM
		+
		SEP #$30


	.GetExit
	; vanilla sprites don't have extra prop...

		; LDA !ExtraProp1,x : STA $04
		; LDA !ExtraProp2,x : STA $05
		; BNE ..done
		; LDA $04 : BNE ..done
		; LDA !SpriteXLo,x : STA $94
		; LDA !SpriteXHi,x : STA $95
		; LDA !SpriteYLo,x : STA $96
		; LDA !SpriteYHi,x : STA $97
		; JSL TranslateOldExitNumber
		; LDA !LevelEntry : STA $04
		; LDA !LevelEntry+1 : STA $05
		; ..done


	.SpawnObject
		JSL GetItemMem
		; $00 = 16-bit item memory index
		; $02 = 0, spawn locked door
		; $02 != 0, spawn unlocked door
		PHB
		LDA #$41
		PHA : PLB
		REP #$30
		LDY #$0000
		..loop
		LDA !BG_object_Type,y
		AND #$00FF : BNE ..next
		SEP #$20
		LDA.l !ExtraBits,x				;\ check type
		AND #$04 : BNE ..block				;/

		..door
		LDA $02 : STA !BG_object_Timer,y		; bit key for key door
		; LDA $04 : STA !BG_object_Tile,y			;\ exit value for key door
		; LDA $05 : STA !BG_object_Misc,y			;/
		LDA #$07 : BRA ..shared				; key door type

		..block
		LDA.l !BigRAM : STA !BG_object_Timer,y		; tile type for key block
		LDA $02 : STA !BG_object_Misc,y			; bit key for key block
		LDA #$09 : BRA ..shared				; key block type

		..shared
		STA !BG_object_Type,y				; set type
		LDA.l !SpriteXLo,x : STA !BG_object_XLo,y	;\
		LDA.l !SpriteXHi,x : STA !BG_object_XHi,y	; | object position
		LDA.l !SpriteYLo,x : STA !BG_object_YLo,y	; |
		LDA.l !SpriteYHi,x : STA !BG_object_YHi,y	;/
		LDA $00 : STA !BG_object_W,y			;\ item memory index
		LDA $01 : STA !BG_object_H,y			;/
		LDA.l !HeaderItemMem				;\ check level item mem
		CMP #$03 : BCC ..return				;/
		LDA #$FF : STA !BG_object_H,y			; mark as invalid if item mem >= 3
		BRA ..return
		..next
		TYA
		CLC : ADC.w #!BG_object_Size
		TAY
		CPY.w #(!BG_object_Size)*(!BG_object_Count) : BCC ..loop
		..return
		SEP #$30
		PLB



	.Return
		STZ !SpriteStatus,x
		PHX
		LDA !SpriteID,x : TAX
		LDA #$EE : STA !SpriteLoadStatus,x
		PLX

	INIT:
		RTS

