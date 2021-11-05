;============;
;LEVEL INTROS;
;============;
;
; This patch gives playable characters (PCE.asm) intro quotes when entering a level, like in Shovel Knight.
; Which character's intro quote is used depends on the frame counter. It's pretty much random.

; --NOTES--
;
; Code that displays "MARIO START !" starts at $0091E9.
; Code that uploads "MARIO START !" GFX to VRAM starts at $00A7C2.
;
; --TO DO--
;
; - Have the character in question jump up from the bottom of the screen in a returning arc.
; - Make it fast. It can't take longer than unmodified SMW.
; - Make sure it pauses a bit in case of SA-1 (so it still has time to show the entire animation).


	pushpc
	org $0091D3
		JMP $8494			;\ Source: INX : CPX #$08 : BNE $07
		NOP : NOP			;/
	org $0091E9				; This chunk of code is 70 bytes long and writes "MARIO START !" to OAM
		JML DRAW_TEXT			;\ Source: LDA $9139,x : STA $030B,y
		NOP : NOP			;/
	org $0093E8
		LDY #$00			; subscreen (org: LDY #$04)
	org $0097B1				; Routine that writes "GAME OVER" to OAM
		JMP $8494			; Source: INX : TYA : SEC
	pullpc



;
; at the point of htis hijack, all interrupts are disabled ($4200 = 0) and f-blank is enabled ($2100 = 0x80)
;
;


;==================;
;DISPLAYING ROUTINE;
;==================;
; This routine writes the text on the screen.

; -- Plan --
;
; $00 is Xpos to write to OAM. Incremented by the value in CHARACTER_DATA.
; $01 is Ypos to write to OAM.
; $03 is a 16-bit pointer to message data.
; $05 is OAM index
; $06 is tile number from CHARACTER_DATA.
; $07 is number of 8x16 tiles from CHARACTER_DATA.
; $08 is character width from CHARACTER_DATA.

DRAW_TEXT:

		PHB : PHK : PLB			; > Bank wrapper
		STZ !HDMA			;\
		STZ $1F0C			; | no HDMA
		STZ $420C			;/
		LDA #$10			;\
		STA $212C			; |
		STA !MainScreen			; | sprites only
		STZ $212D			; |
		STZ !SubScreen			;/

		STZ $2123			;\
		STZ $2124			; |
		STZ $2125			; |
		STZ !2123			; | no clipping windows
		STZ !2124			; |
		STZ !2125			; |
		STZ $212E			; |
		STZ $212F			;/

		STZ $2121
		STZ $2122
		STZ $2122


		REP #$20
		LDX #$80 : STX $2115
		LDA #$6800 : STA $2116
		LDA #$1801 : STA $4300
		LDA.w #GFX_SOURCE : STA $4302
		LDA.w #GFX_SOURCE>>8 : STA $4303
		LDA #$1000 : STA $4305
		SEP #$20
		LDA #$01 : STA $420B


		LDA !MultiPlayer : BEQ .p1
		BIT $13 : BPL .p1
	.p2	LDA !Characters
		AND #$0F
		BRA +
	.p1	LDA !Characters
		LSR #4
	+	TAX
		LDA $13
		AND #$01
		CLC : ADC.w .CharIndex,x
		ASL A
		TAX
		REP #$20
		LDA .Ptr,x : STA $0E
		LDA ($0E) : STA $00		; base X/Y
		INC $0E				;\ skip past these bytes
		INC $0E				;/
		LDX #$00
		LDY #$00
		SEP #$20

	.loop	LDA ($0E),y
		CMP #$FF : BEQ .done

		PHY				; push index
		STA $02				;\
		ASL A				; | get index to tile data
		ADC $02				; |
		TAY				;/
		LDA .TileData+0,y : STA $02	; $02 = base tile num
		LDA .TileData+1,y : STA $03	; $03 = number of 8x16 blocks
		LDA $00 : STA $04		; $04 = temp Xpos

	-	LDA $04				;\
		STA !OAM_p3+0,x			; | Xpos
		STA !OAM_p3+4,x			;/
		LDA $01 : STA !OAM_p3+1,x	;\
		CLC : ADC #$08			; | Ypos
		STA !OAM_p3+5,x			;/
		LDA $02 : STA !OAM_p3+2,x	;\
		CLC : ADC #$10			; | tile num
		STA !OAM_p3+6,x			;/
		LDA #$34			;\
		STA !OAM_p3+3,x			; | prop
		STA !OAM_p3+7,x			;/
		TXA				;\
		LSR #2				; |
		TAX				; | hi bytes
		LDA #$00			; |
		STA !OAMhi_p3+0,x		; |
		STA !OAMhi_p3+1,x		;/
		INX #2				;\
		TXA				; | increment
		ASL #2				; |
		TAX				;/
		DEC $03 : BMI .next		; check remaining tiles on characters
		LDA $04				;\
		CLC : ADC #$08			; | increment temp Xpos
		STA $04				;/
		INC $02				; increment tile num
		BRA -				; mini loop

		.next
		LDA .TileData+2,y		;\
		CLC : ADC $00			; | increment Xpos
		STA $00				;/
		PLY				; pull index
		INY
		BRA .loop

		.done
		LDA !Translevel : BEQ +

		TXA : STA !OAMindex_p3
		LDA #$00
		STA !OAMindex_p0
		STA !OAMindex_p1
		STA !OAMindex_p2
		JSL !BuildOAM
		LDA !OAMindex_p3_prev : STA !OAMindex_p3
	+	PLB


		STZ $4304
		REP #$20
		LDA #$0400 : STA $4300
		LDA #$6200 : STA $4302
		LDA #$0220 : STA $4305
		SEP #$20
		LDA #$01 : STA $420B

		LDA #$E0 : STA $2132
		LDA #$0F
		STA !2100
		STA $2100

		PLA : PLA			; kill first RTS

		JML $00922E			; > Return to RTS


		.CharIndex
		db $00			; mario
		db $02			; luigi
		db $04			; kadaal
		db $06			; leeway
		db $08			; alter
		db $0A			; peach

		.Ptr
		dw .Mario_1
		dw .Mario_2
		dw .Luigi_1
		dw .Luigi_2
		dw .Kadaal_1
		dw .Kadaal_2
		dw .Leeway_1
		dw .Leeway_2
		dw .Alter_1
		dw .Alter_2
		dw .Peach_1
		dw .Peach_2


; Values are, in order: base tile number, number of 8x16 tiles -1, character width.
; Character height is always 16 pixels.

		.TileData
	.A	db $80,$00,$08
	.B	db $81,$01,$09
	.C	db $83,$00,$08
	.D	db $84,$01,$09
	.E	db $86,$00,$08
	.F	db $87,$00,$08
	.G	db $88,$00,$08
	.H	db $89,$00,$08
	.I	db $8A,$00,$04
	.J	db $8B,$00,$08
	.K	db $8C,$01,$09
	.L	db $8E,$00,$08
	.M	db $A0,$01,$0B
	.N	db $A2,$00,$08
	.O	db $A3,$00,$08
	.P	db $A4,$01,$09
	.Q	db $A6,$01,$09
	.R	db $A8,$01,$09
	.S	db $AA,$00,$08
	.T	db $AB,$00,$08
	.U	db $AC,$00,$08
	.V	db $AD,$00,$08
	.W	db $AE,$01,$0C
	.X	db $C0,$00,$08
	.Y	db $C1,$00,$08
	.Z	db $C2,$00,$08

		db $C3,$00,$04			; '
		db $C4,$00,$08			; -
		db $C5,$00,$04			; !
		db $C6,$00,$04			; ,
		db $C7,$00,$04			; .
		db $C8,$00,$08			; ?
		db $C9,$00,$08			; space


cleartable
table "IntroTable.txt"


	.Mario
		..1
		db $40,$68
		db "IT'S-A-ME!"
		db $FF
		..2
		db $48,$68
		db "IT'S-A GO TIME!"
		db $FF

	.Luigi
		..1
		db $48,$68
		db "OH YEAH, LUIGI TIME!"
		db $FF
		..2
		db $60,$68
		db "GO-IGI!"
		db $FF

	.Kadaal
		..1
		db $32,$68
		db "KOOPA VENGEANCE!"
		db $FF
		..2
		db $3C,$68
		db "JUST TRY TO KEEP UP!"
		db $FF

	.Leeway
		..1
		db $58,$68
		db "GET REXT!"
		db $FF
		..2
		db $48,$68
		db "SLICE AND DICE!"
		db $FF

	.Alter
		..1
		..2
	.Peach
		..1
		..2
		db $44,$68
		db "COMING SOON..."
		db $FF


GFX_SOURCE:	incbin "IntroQuotes.bin"	; GFX file to load font from