
	Window:
		LDX $00						; X = BG object index
		LDA !BG_object_Misc,x				;\
		AND #$00FF : BEQ .Breakable			; | check for queued break
		JMP .QueuedBreak				;/

		.Breakable					;\
		LDA !BG_object_X,x				; |
		STA $04						; |
		STA $09						; |
		LDA !BG_object_Y,x				; |
		SEP #$20					; |
		STA $05						; | clipping
		XBA : STA $0B					; |
		LDA !BG_object_W,x				; |
		ASL #3						; |
		STA $06						; |
		LDA !BG_object_H,x				; |
		ASL #3						; |
		STA $07						;/

		PHX						;\
		PHB : PHK : PLB					; | reg/bank setup
		SEP #$30					;/

		.P1Hitbox1					;\
		LDA !P2Hitbox1W-$80 : BEQ ..nocontact		; |
		STA $02						; |
		LDA !P2Hitbox1H-$80 : STA $03			; |
		LDA !P2Hitbox1XLo-$80 : STA $00			; | check for hitbox overlap
		LDA !P2Hitbox1XHi-$80 : STA $08			; | (player 1 hitbox 1)
		LDA !P2Hitbox1YLo-$80 : STA $01			; |
		LDA !P2Hitbox1YHi-$80 : STA $09			; |
		JSL !CheckContact : BCS .Break			; |
		..nocontact					;/
		.P1Hitbox2					;\
		LDA !P2Hitbox2W-$80 : BEQ ..nocontact		; |
		STA $02						; |
		LDA !P2Hitbox2H-$80 : STA $03			; |
		LDA !P2Hitbox2XLo-$80 : STA $00			; | check for hitbox overlap
		LDA !P2Hitbox2XHi-$80 : STA $08			; | (player 1 hitbox 2)
		LDA !P2Hitbox2YLo-$80 : STA $01			; |
		LDA !P2Hitbox2YHi-$80 : STA $09			; |
		JSL !CheckContact : BCS .Break			; |
		..nocontact					;/
		.P2Hitbox1					;\
		LDA !P2Hitbox1W : BEQ ..nocontact		; |
		STA $02						; |
		LDA !P2Hitbox1H : STA $03			; |
		LDA !P2Hitbox1XLo : STA $00			; | check for hitbox overlap
		LDA !P2Hitbox1XHi : STA $08			; | (player 2 hitbox 1)
		LDA !P2Hitbox1YLo : STA $01			; |
		LDA !P2Hitbox1YHi : STA $09			; |
		JSL !CheckContact : BCS .Break			; |
		..nocontact					;/
		.P2Hitbox2					;\
		LDA !P2Hitbox2W : BEQ ..nocontact		; |
		STA $02						; |
		LDA !P2Hitbox2H : STA $03			; |
		LDA !P2Hitbox2XLo : STA $00			; | check for hitbox overlap
		LDA !P2Hitbox2XHi : STA $08			; | (player 2 hitbox 2)
		LDA !P2Hitbox2YLo : STA $01			; |
		LDA !P2Hitbox2YHi : STA $09			; |
		JSL !CheckContact : BCS .Break			; |
		..nocontact					;/

		REP #$30					;\
		PLB						; | restore and return
		PLX						; |
		RTS						;/



		.Break
		REP #$30
		PLB
		PLX

		.QueuedBreak

		LDA #$0000 : STA.l $2250
		LDA !BG_object_X+1,x
		AND #$00FF : STA.l $2251
		LDA.l !LevelHeight : STA.l $2253
		LDA !BG_object_X,x
		AND #$00FF
		LSR #4
		STA $00
		LDA !BG_object_Y,x
		AND #$FFF0
		CLC : ADC $00
		CLC : ADC.l $2306
		PHX
		TAX
		SEP #$20
		LDA #$12 : STA $40C800,x
		LDA #$22 : STA $40C810,x

		LDA $00
		CMP #$0F : BNE +
		REP #$20
		TXA
		CLC : ADC.l !LevelHeight
		SEC : SBC #$0010
		TAX
		SEP #$20

	+	LDA #$13 : STA $40C801,x
		LDA #$23 : STA $40C811,x

		REP #$20
		PLX


		LDA !VRAMbase+!TileUpdateTable
		CMP #$00C0 : BCC .Valid
		SEP #$20
		LDA #$01 : STA !BG_object_Misc,x
		REP #$20
		RTS

		.Valid
		STZ !BG_object_Type,x
		LDA.w #.TileData : STA $00
		JMP TileUpdate


		.TileData
		dw $1424,$1425,$1426,$1427
		dw $1434,$1435,$1436,$1437
		dw $1444,$1445,$1446,$1447
		dw $1454,$1455,$1456,$1457





