
	Window:
		LDX $00						; X = BG object index

		LDA !BG_object_Misc,x				;\ check for queued break
		AND #$00FF : BNE .Break				;/
		JSR CheckHitbox : BCS .Break			;\ return unless hitbox contact
		RTS						;/

		.Break
		LDA !VRAMbase+!TileUpdateTable			;\
		CMP #$00C0 : BCC ..yes				; |
		..queue						; | queue if it can't update on this frame
		INC !BG_object_Misc,x				; |
		RTS						;/
		..yes
		LDA !BG_object_X,x : STA $9A
		LDA !BG_object_Y,x : STA $98
		PHX
		PHP
		PHB : PHK : PLB
		LDA #$0312 : JSL ChangeMap16
		LDA $9A
		CLC : ADC #$0010
		STA $9A
		LDA #$0313 : JSL ChangeMap16
		LDA $98
		CLC : ADC #$0010
		STA $98
		LDA #$0323 : JSL ChangeMap16
		LDA $9A
		SEC : SBC #$0010
		STA $9A
		LDA #$0322 : JSL ChangeMap16
		PLB
		PLP
		PLX
		STZ !BG_object_Type,x
		RTS







