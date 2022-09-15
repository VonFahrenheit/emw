

	MAIN:
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

		JSL GetItemMem
		; $02 = 0, spawn locked door
		; $02 != 0, spawn unlocked door

		PHB
		LDA #$41
		PHA : PLB
		REP #$30
		LDY #$0000

		.Loop
		LDA !BG_object_Type,y
		AND #$00FF : BNE .Next
		SEP #$20
		LDA.l !ExtraBits,x				;\
		AND #$04 : BEQ +				; |
		LDA.l !BigRAM : STA !BG_object_Timer,y		; > tile type for key block
		LDA #$09 : BRA ++				; | type depends on extra bit
	+	LDA #$07					; |
	++	STA !BG_object_Type,y				;/
		LDA.l !SpriteXLo,x : STA !BG_object_XLo,y
		LDA.l !SpriteXHi,x : STA !BG_object_XHi,y
		LDA.l !SpriteYLo,x : STA !BG_object_YLo,y
		LDA.l !SpriteYHi,x : STA !BG_object_YHi,y
		LDA $02 : STA !BG_object_Misc,y			;\
		LDA $00 : STA !BG_object_W,y			; |
		LDA $01 : STA !BG_object_H,y			;/
		LDA.l !HeaderItemMem
		CMP #$03 : BCC .Return
		LDA #$FF : STA !BG_object_H,y			; mark as invalid if item mem >= 3
		BRA .Return

		.Next
		TYA
		CLC : ADC.w #!BG_object_Size
		TAY
		CPY.w #(!BG_object_Size)*(!BG_object_Count) : BCC .Loop

		.Return
		SEP #$30
		PLB
		.Kill
		STZ !SpriteStatus,x
		PHX
		LDA !SpriteID,x : TAX
		LDA #$EE : STA !SpriteLoadStatus,x
		PLX

	INIT:
		RTS

