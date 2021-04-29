;
; In SMW, extended sprite 0x09 is unused and has no function.
; This module replaces that sprite with the Malleable Extended Sprite!
; It can be set to display a single tile, and it can also have a hitbox.



; Use of ExSprite data:
;
;	!Ex_Palset:		YXPPCCCT byte
;	!Ex_Data1:		this is the GFX tile, as well as its hitbox mode:
;				tttHtttt
;				H - hitbox: if this is set, the ExSprite hurts players upon contact
;				t - tile (lowest bit in hi nybble is clear because of 8x16 block format)
;	!Ex_Data2:		life timer, reduced every other frame
;	!Ex_Data3:		Dso--GGG
;				D - die upon contact with player
;				s - tile size (0 = 8x8, 1 = 16x16)
;				o - offscreen (0 = despawn, 1 = keep going)
;				G - gravity value, added to Y speed every frame



; KNOWN BUG:
; despawns immediately when offscreen, unlike other exsprite...



	pushpc
	org $029B2B+($09*2)
		dw MalleableExtendedSprite			; repoint this


	org $02A213
		STA !Ex_Num,x


	org $029D5E
	print "Malleable Extended Sprite inserted at $", pc
	MalleableExtendedSprite:
		LDA $14						;\
		LSR A						; | timer decrements every other frame
		BCC $03 : INC !Ex_Data2,x			;/
		LDA !Ex_Data2,x : BNE .Main			;\
	.Kill	STZ !Ex_Num,x					; | despawn when timer hits 0
		RTS						;/

		.Main
		LDA !Ex_Data3,x					;\
		AND #$07					; |
		CLC : ADC !Ex_YSpeed,x				; |
		BMI +						; | apply gravity
		CMP #$40					; | (cap downward speed at 64)
		BCC $02 : LDA #$40				; |
	+	STA !Ex_YSpeed,x				;/
		JSR $B554					;\ process speed
		JSR $B560					;/
		BIT !Ex_Data1,x : BMI .CheckContact		; if sprite can hurt player, check contact
		BIT !Ex_Data3,x : BPL .NoContact		; if sprite is destroyed by player, check contact (otherwise skip)

		.CheckContact
		LDA !Ex_XLo,x					;\
		CLC : ADC #$02					; |
		STA $04						; |
		LDA !Ex_XHi,x					; |
		ADC #$00					; |
		STA $0A						; |
		LDA !Ex_YLo,x					; | generate hitbox
		CLC : ADC #$02					; |
		STA $05						; |
		LDA !Ex_YHi,x					; |
		ADC #$00					; |
		STA $0B						; |
		LDA #$0C					; |
		STA $06						; |
		STA $07						;/
		SEC : JSL !PlayerClipping			;\ check for contact
		BCC .NoContact					;/
		BIT !Ex_Data1,x					;\
		AND #$10 : BEQ .NoHurt				; | if hitbox is enabled, hurt players
		JSL !HurtPlayers				;/
	.NoHurt	BIT !Ex_Data3,x : BPL .NoContact		;\
		LDA #$01 : STA !Ex_Num,x			; | if death is set, puff sprite
		LDA #$0F : STA !Ex_Data2,x			; |
		RTS						;/
		.NoContact

		.GFX
		LDA !Ex_Data3,x
		AND #$40 : BEQ ..8x8
	..16x16	JSL DisplayGFX
		db $04,$FF
		db $00,$00,$00,$02
		BRA ..finish
	..8x8	JSL DisplayGFX
		db $04,$FF
		db $00,$00,$00,$00
		..finish
		LDA $00 : BEQ .Return				; return if no tile is on-screen
		LDY #$02					;\
		LDA !Ex_Data1,x					; | set tile
		AND #$EF					; |
		STA [$02],y					;/
		LDY #$03					;\ set YXPPCCCT
		LDA !Ex_Palset,x : STA [$02],y			;/

		.Return
		RTS						; > return

	warnpc $029E36
	pullpc





