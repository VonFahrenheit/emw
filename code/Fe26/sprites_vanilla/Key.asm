

	INIT:
		JSL GetItemMem : BEQ .Valid		;\
		.Kill					; | kill if already used
		STZ !SpriteStatus,x			; |
		RTS					;/

		.Valid					;\
		LDA !HeaderItemMem			; |
		CMP #$03 : BCC ..setmem			; |
		LDA !ExtraProp2,x			; | if spawning (note: only triggers in original level) with header = 3, mark invalid item mem
		AND #$C0				; |
		ORA #$03 : STA !ExtraProp2,x		; |
		RTS					;/
		..setmem				;\
		LDY #$00				; |
		LDA $02					; |
		..loop					; |
		LSR A : BEQ ..setbit			; | crunch memory bit
		INY : BRA ..loop			; |
		..setbit				; |
		TYA					; |
		ASL #2					; |
		STA $02					;/
		LDA $00 : STA !ExtraProp1,x		;\
		LDA !ExtraProp2,x			; |
		AND #$C0				; | store item memory index + bit
		ORA $01					; |
		ORA $02					; |
		STA !ExtraProp2,x			;/
		RTS

	MAIN:
		LDA !SpriteStatus,x
		CMP #$09 : BEQ .Physics
		CMP #$0A : BNE .Graphics
		LDA #$09 : STA !SpriteStatus,x


	.Physics
		JSL ITEM_PHYSICS

	.Graphics
		JSL DRAW_SIMPLE
		RTS

