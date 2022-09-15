

; 00 - small (16x16)
; 01 - tall (16x32)
; 02 - big (32x32)
; 03 - tiny (8x8)
; 04 - big block (32x32, tile-aligned)
; 05 - slightly bigger (20x18)
; ----
; 16 - sight box (128x128, both directions)
; 17 - sight box (128x64, both directions)
; 18 - sight box (64x40, right)
; 19 - sight box (64x40, left)
; 1A - sight box (128x40, right)
; 1B - sight box (128x40, left)
; 1C - sight box (160x64, both directions)
; 1D - sight box (256x64, both directions)


pushpc
org $03B56C
SpriteClippingX:
	dw $0002,$0002,$FFFC,$0005,$0000,$FFFE,$AAAA,$AAAA
	dw $AAAA,$AAAA,$AAAA,$AAAA,$AAAA,$AAAA,$AAAA,$AAAA
	dw $AAAA,$AAAA,$AAAA,$AAAA,$AAAA,$AAAA,$FFC8,$FFC8
	dw $0000,$FFC0,$0000,$FF80,$FFB8,$FF88
SpriteClippingY:
	dw $0003,$FFF8,$FFF8,$0002,$0000,$FFFE,$AAAA,$AAAA
	dw $AAAA,$AAAA,$AAAA,$AAAA,$AAAA,$AAAA,$AAAA,$AAAA
	dw $AAAA,$AAAA,$AAAA,$AAAA,$AAAA,$AAAA,$FFC8,$FFD0
	dw $FFE8,$FFE8,$FFE8,$FFE8,$FFD0,$FFD0
SpriteClippingW:
	dw $000C,$000C,$0018,$0006,$0020,$0014,$AAAA,$AAAA
	dw $AAAA,$AAAA,$AAAA,$AAAA,$AAAA,$AAAA,$AAAA,$AAAA
	dw $AAAA,$AAAA,$AAAA,$AAAA,$AAAA,$AAAA,$0080,$0080
	dw $0040,$0040,$0080,$0080,$00A0,$0100
SpriteClippingH:
	dw $000A,$0013,$0018,$0006,$0020,$0012,$AAAA,$AAAA
	dw $AAAA,$AAAA,$AAAA,$AAAA,$AAAA,$AAAA,$AAAA,$AAAA
	dw $AAAA,$AAAA,$AAAA,$AAAA,$AAAA,$AAAA,$0080,$0040
	dw $0028,$0028,$0028,$0028,$0040,$0040
warnpc $03B65C
org $03B65C
	CheckContact:						; $03B662 CheckContact
		REP #$20					; A 16-bit
		LDA $E0						;\
		CLC : ADC $E4					; | Ax + Aw - Bx
		CMP $E8 : BCC .Return				;/
		LDA $E8						;\
		CLC : ADC $EC					; | Bx + Bw - Ax
		CMP $E0 : BCC .Return				;/
		LDA $E2						;\
		CLC : ADC $E6					; | Ay + Ah - By
		CMP $EA : BCC .Return				;/
		LDA $EA						;\
		CLC : ADC $EE					; | By + Bh - Ay
		CMP $E2						;/
		.Return						;\ A 8-bit
		SEP #$20					;/
		RTL						; return
	; sprites should call the main labels below directly
	; these "pointers" are for external use

	GetSpriteClippingE0:
		LDA !SpriteTweaker2,x				;\ get tweaker value
		AND #$1F					;/
		.A
		PHX						; push X
		LDY !SpriteXLo,x : STY $E0			;\
		LDY !SpriteXHi,x : STY $E1			; | sprite base coords
		LDY !SpriteYLo,x : STY $E2			; |
		LDY !SpriteYHi,x : STY $E3			;/
		ASL A : TAX					; clipping index
		REP #$20					; A 16-bit
		LDA.l SpriteClippingX,x				;\
		CLC : ADC $E0					; | hitbox X
		STA $E0						;/
		LDA.l SpriteClippingY,x				;\
		CLC : ADC $E2					; | hitbox Y
		STA $E2						;/
		LDA.l SpriteClippingW,x : STA $E4		; hitbox W
		LDA.l SpriteClippingH,x : STA $E6		; hitbox H
		SEP #$20					; A 8-bit
		PLX						; restore X
		RTL						; return

	GetSpriteClippingE8:
		LDA !SpriteTweaker2,x				;\ get tweaker value
		AND #$1F					;/
		.A
		PHX						; push X
		LDY !SpriteXLo,x : STY $E8			;\
		LDY !SpriteXHi,x : STY $E9			; | sprite base coords
		LDY !SpriteYLo,x : STY $EA			; |
		LDY !SpriteYHi,x : STY $EB			;/
		ASL A : TAX					; clipping index
		REP #$20					; A 16-bit
		LDA.l SpriteClippingX,x				;\
		CLC : ADC $E8					; | hitbox X
		STA $E8						;/
		LDA.l SpriteClippingY,x				;\
		CLC : ADC $EA					; | hitbox Y
		STA $EA						;/
		LDA.l SpriteClippingW,x : STA $EC		; hitbox W
		LDA.l SpriteClippingH,x : STA $EE		; hitbox H
		SEP #$20					; A 8-bit
		PLX						; restore X
		RTL						; return

warnpc $03B75C
pullpc


