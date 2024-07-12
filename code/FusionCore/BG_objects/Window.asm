
	Window:
		LDX $00						; X = BG object index

		LDA !BG_object_Misc,x				;\ check for queued break
		AND #$00FF : BNE .Break				;/
		JSR CheckHitbox : BCS .GetHitboxData		;\ return unless hitbox contact
		RTS						;/

		.GetHitboxData
		PHB : PHK : PLB					;\
		SEP #$20					; |
		LDA #$07 : STA !SPC4				; > shatter block sfx
		LDA !P2Hitbox1XSpeed-$80,y : XBA		; |
		LDA !P2Hitbox1YSpeed-$80,y			; | hitbox X speed in _Tile
		PLB						; | hitbox Y speed in _Timer
		STA !BG_object_Timer,x				; |
		XBA : STA !BG_object_Tile,x			; |
		REP #$20					;/

		.Break
		LDA !VRAMbase+!TileUpdateTable			;\
		CMP #$00C0 : BCC ..yes				; |
		..queue						; | queue if it can't update on this frame
		INC !BG_object_Misc,x				; |
		RTS						;/
		..yes
		LDA !BG_object_X,x : STA $9A
		LDA !BG_object_Y,x : STA $98

		LDA !BG_object_Tile,x				;\
		AND #$00FF					; |
		ASL #4						; | particle base X speed
		CMP #$0800					; |
		BCC $03 : ORA #$F000				; |
		STA $F0						;/

		LDA !BG_object_Timer,x				;\
		AND #$00FF					; |
		ASL #4						; | particle base Y speed
		CMP #$0800					; |
		BCC $03 : ORA #$F000				; |
		STA $F2						;/

		PHX
		PHP
		PHB : PHK : PLB

		LDA #$0312 : JSL ChangeMap16			; update block

		LDA $F0						;\
		SBC #$0100					; |
		STA $00						; |
		LDA $F2						; | particle
		SBC #$0200					; |
		STA $02						; |
		LDA #$1800 : STA $04				; |
		LDA.w #!prt_brickpiece : JSL SpawnParticleBlock	;/

		LDA $9A						;\
		CLC : ADC #$0010				; | update block
		STA $9A						; |
		LDA #$0313 : JSL ChangeMap16			;/

		LDA $F0						;\
		ADC #$0100					; |
		STA $00						; |
		LDA $F2						; | particle
		SBC #$0200					; |
		STA $02						; |
		LDA #$1800 : STA $04				; |
		LDA.w #!prt_brickpiece : JSL SpawnParticleBlock	;/


		LDA $98						;\
		CLC : ADC #$0010				; | update block
		STA $98						; |
		LDA #$0323 : JSL ChangeMap16			;/

		LDA $F0						;\
		ADC #$0100					; |
		STA $00						; | particle
		LDA $F2 : STA $02				; |
		LDA #$1800 : STA $04				; |
		LDA.w #!prt_brickpiece : JSL SpawnParticleBlock	;/

		LDA $9A						;\
		SEC : SBC #$0010				; | update block
		STA $9A						; |
		LDA #$0322 : JSL ChangeMap16			;/

		LDA $F0						;\
		SBC #$0100					; |
		STA $00						; | particle
		LDA $F2 : STA $02				; |
		LDA #$1800 : STA $04				; |
		LDA.w #!prt_brickpiece : JSL SpawnParticleBlock	;/

		PLB
		PLP
		PLX
		STZ !BG_object_Type,x

		RTS







