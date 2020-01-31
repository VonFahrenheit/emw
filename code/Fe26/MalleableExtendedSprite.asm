;
; In SMW, extended sprite 0x09 is unused and has no function.
; This module replaces that sprite with the Malleable Extended Sprite!
; It can be set to display a single tile, and it can also have a hitbox.



; Use of ExSprite data:
;
;	!ExSpriteMisc:		this is the GFX tile for the ExSprite, as well as its modes:
;				HCtttttt
;				H - hitbox: if this is set, the ExSprite hurts players upon contact
;				C - contact: if this is set, the ExSprite is destroyed upon touching a player
;				t - 16x16 tile
;					multiply lo 3 bits by 2 and put in lo nybble
;					multiply hi 3 bits by 2 and put in hi nybble
;					that's what's written to OAM as the tile
;	!ExSpriteTimer:		this is the life timer for the ExSprite, reduced every other frame
;	!ExSpriteBehindBG1:	this is the YXPPCCCT byte for the ExSprite
;				





	pushpc
	org $02A213
		JMP MalleableExtendedSprite_CheckNumber		; source: STA !ExSpriteNum,x


	org $029D9D
	MalleableExtendedSprite:
		LDA $14						;\
		LSR A						; | Timer decrements at half-speed for this ExSprite
		BCC $03 : INC !ExSpriteTimer,x			;/
		LDA !ExSpriteTimer,x : BNE .Main		;\
	.Kill	STZ !ExSpriteNum,x				; | Despawn when timer hits 0
		RTS						;/

		.Main
		JSR $B554					;\ Process speed
		JSR $B560					;/
		BIT !ExSpriteMisc,x				;\
		BMI .CheckContact				; | Handle state of ExSprite
		BVC .NoContact					;/

		.CheckContact
		LDA !ExSpriteXPosLo,x				;\
		CLC : ADC #$02					; |
		STA $04						; |
		LDA !ExSpriteXPosHi,x				; |
		ADC #$00					; |
		STA $0A						; |
		LDA !ExSpriteYPosLo,x				; | Generate hitbox
		CLC : ADC #$02					; |
		STA $05						; |
		LDA !ExSpriteYPosHi,x				; |
		ADC #$00					; |
		STA $0B						; |
		LDA #$0C					; |
		STA $06						; |
		STA $07						;/
		SEC : JSL !PlayerClipping			;\ Check for contact
		BCC .NoContact					;/
		BIT !ExSpriteMisc,x : PHP			;\
		BPL .NoHurt					; | If highest bit is set, hurt players
		JSL !HurtPlayers				;/
	.NoHurt	PLP : BVC .NoContact				;\
		LDA #$01 : STA !ExSpriteNum,x			; | If second highest bit is set, puff sprite
		LDA #$0F : STA !ExSpriteTimer,x			;/
		RTS
		.NoContact

		.GFX
		JSR $A1A4					; Borrow Reznor GFX routine
		LDA !ExSpriteMisc,x				;\
		PHA						; |
		AND #$07					; |
		ASL A						; |
		STA $0F						; | Calculate tile
		PLA						; |
		AND #$38					; |
		ASL #2						; |
		ORA $0F						;/
		STA !OAM+$002,y					; > Set tile
		LDA !ExSpriteBehindBG1,x : STA !OAM+$003,y	; > Set YXPPCCCT
		TYA
		LSR #2
		TAY
		LDA #$02 : STA !OAMhi,y
		RTS						; > Return


		.CheckNumber
		LDA !ExSpriteNum,x				; prevent malleable ExSprite from despawning
		CMP #$09 : BNE .Clear
	.Draw	LDA $02
		JMP $A1D5

	.Clear	LDA #$00 : STA !ExSpriteNum,x
		RTS

	warnpc $029E36
	pullpc





