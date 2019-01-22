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
		LDA !ExSpriteXPosLo,x : STA $04			;\
		LDA !ExSpriteYPosLo,x : STA $05			; |
		LDA !ExSpriteXPosHi,x : STA $0A			; |
		LDA !ExSpriteYPosHi,x : STA $0B			; | Generate hitbox in RAM
		LDA #$10					; |
		STA $06						; |
		STA $07						;/
		SEC : JSL !PlayerClipping			;\ Check for contact
		BCC .NoContact					;/
		BIT !ExSpriteMisc,x : PHP			;\
		BPL .NoHurt					; | If highest bit is set, hurt players
		JSL !HurtPlayers				;/
	.NoHurt	PLP : BVC .NoContact				;\ If second highest bit is set, kill sprite
		BRA .Kill					;/
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

	warnpc $029E36
	pullpc





