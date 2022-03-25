

; these are set during spawn (keyhole sprite)
; _W		item mem index, lo byte
; _H		item mem index, hi byte (if set to 0xFF, this object has no item mem)
; _Misc		item memory bit
; _Timer	0x00 = turn to air, 0xFF = turn to water


; other:
; _Tile		0xFF if a break is queued

	KeyBlock:
		LDX $00						; X = BG object index

		.CheckBreak
		LDA !BG_object_W,x : BMI ..checkqueue		;\
		TXY						; |
		TAX						; |
		LDA !BG_object_Misc,y				; |
		AND #$00FF					; | check if block is already opened
		AND.l !ItemMem0,x : BEQ ..notused		; |
		..used						; |
		LDA #$0001 : STA !BG_object_Tile,y		; |
		..notused					; |
		TYX						;/
		..checkqueue
		LDA !BG_object_Tile,x				;\ check for queued break
		AND #$00FF : BNE .Break				;/



		LDA !BG_object_Misc,x : STA.l !BigRAM+0		;\ item mem data
		LDA !BG_object_W,x : STA.l !BigRAM+1		;/

		.CheckContact
		PHX

		..getblockhitbox
		LDA !BG_object_Y,x				;\
		SEC : SBC #$0004				; | hitbox Y
		STA $05						; |
		STA $0B-1					;/
		LDA #$282A : STA $06				; hitbox W + H
		LDA !BG_object_X,x				;\
		SEC : SBC #$0004				; |
		STA $0A-1					; | hitbox X
		SEP #$30					; > all regs 8-bit
		STA $04						;/
		..searchkeys					;\
		PHB : PHK : PLB					; |
		LDX #$0F					; |
		..loop						; |
		LDA $3230,x					; |
		CMP #$08 : BCC ..next				; | search for key sprites and check for contact with them
		LDA !ExtraBits,x				; |
		AND #$08 : BNE ..next				; |
		LDA $3200,x					; |
		CMP #$80 : BNE ..next				; |
		JSL !GetSpriteClipping00			; |
		JSL !Contact16 : BCC ..next			;/
		..contact					;\
		LDA !BigRAM+0 : STA $02				; |
		LDA !BigRAM+1 : STA $0E				; |
		LDA !BigRAM+2 : STA $0F				; |
		JSR UnlockObject				; |
		PLB						; | puff key, mark break, and return
		REP #$30					; |
		PLX						; |
		INC !BG_object_Tile,x				; > mark break
		RTS						;/
		..next						;\ loop
		DEX : BPL ..loop				;/
		PLB						;\
		REP #$30					; | mark break and return
		PLX						; |
		RTS						;/

		.Break
		LDA !VRAMbase+!TileUpdateTable			;\
		CMP #$00C0 : BCC ..yes				; | return if it can't break on this frame
		RTS						;/
		..yes
		LDA !BG_object_X,x : STA $9A
		LDA !BG_object_Y,x : STA $98
		PHX
		PHP
		LDA !BG_object_Timer,x
		PHB : PHK : PLB
		AND #$00FF : BNE ..water
		..air
		JSR PuffTile
		LDA $9A
		CLC : ADC #$0010
		STA $9A
		JSR PuffTile
		LDA $98
		CLC : ADC #$0010
		STA $98
		JSR PuffTile
		LDA $9A
		SEC : SBC #$0010
		STA $9A
		JSR PuffTile
		BRA ..return
		..water
		JSR WaterTile
		LDA $9A
		CLC : ADC #$0010
		STA $9A
		JSR WaterTile
		LDA $98
		CLC : ADC #$0010
		STA $98
		JSR WaterTile
		LDA $9A
		SEC : SBC #$0010
		STA $9A
		JSR WaterTile
		..return
		PLB
		PLP
		PLX
		STZ !BG_object_Type,x
		RTS





