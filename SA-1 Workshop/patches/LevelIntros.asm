header
sa1rom

;============;
;LEVEL INTROS;
;============;
;
; This patch gives playable characters (PCE.asm) intro quotes when entering a level, like in Shovel Knight.
; Which character's intro quote is used depends on the frame counter. It's pretty much random.

; --Defines--

	!BaseDistance	= $00

	incsrc "Defines.asm"

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


	org $0091D3

		JMP $8494			;\ Source: INX : CPX #$08 : BNE $07
		NOP : NOP			;/

	org $0091E9				; This chunk of code is 70 bytes long and writes "MARIO START !" to OAM

		autoclean JML DRAW_TEXT		;\ Source: LDA $9139,x : STA $030B,y
		NOP : NOP			;/

	org $0097B1				; Routine that writes "GAME OVER" to OAM

		JMP $8494			; Source: INX : TYA : SEC

	org $00A7C2				; Routine that uploads "MARIO START !" to VRAM

		autoclean JML UPLOAD_FONT	; Source: REP #$20 : LDX #$80



freecode

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
		LDA #$10			;\
		STA $6D9D			; | Hide everything except sprites
		STZ $6D9E			;/
		LDA !GameMode			;\
		CMP #$17			; | Draw intro unless game mode is GAME OVER
		BNE .Intro			;/
		LDA $6DBE			;\
		CMP #$FF			; |
		BNE +				; | Get death message index
		LDX #$04			; |
		BRA ++				;/
	+	LDX #$00			;\
	++	LDA.w DEATH_QUOTES,x		; |
		STA $03				; | Set up text pointer
		LDA.w DEATH_QUOTES+$01,x	; |
		STA $04				; |
		LDY #$00			;/
		STZ $05				; > Reset OAM index
		LDA ($03),y			;\
		STA $00				; |
		INY				; | Set up initial text data
		LDA ($03),y			; |
		STA $01				; |
		INY				;/
		BRA .Loop			; > Initiate loop

.Intro		LDA !RNG
		AND #$01 : STA $03
		LDA !MultiPlayer : BEQ .Player1
		LDA !RNG
		AND #$02 : BNE .Player2
.Player1	LDA !Characters
		LSR #4
		BRA .StartWrite
.Player2	LDA !Characters
		AND #$0F
.StartWrite	ASL A
		CLC : ADC $03
		ASL A				;\
		TAX				; |
		LDA.w INTRO_QUOTES_Ptr,x	; |
		STA $03				; | Set up text pointer
		LDA.w INTRO_QUOTES_Ptr+$01,x	; |
		STA $04				; |
		LDY #$00			;/
		STZ $05				; > Reset OAM index
		LDA ($03),y			;\
		STA $00				; |
		INY				; | Set up initial text data
		LDA ($03),y			; |
		STA $01				; |
		INY				;/

.Loop		LDA ($03),y			;\
		CMP #$FF			; | Check for 0xFF byte
		BNE .Process			; |
		BRL .Return			;/

.Process	STA $0F				;\
		ASL A				; |
		CLC : ADC $0F			; |
		TAX				; |
		LDA.w CHARACTER_DATA,x		; | Set up text header
		ORA #$80			; |
		STA $06				; |
		LDA.w CHARACTER_DATA+$01,x	; |
		STA $07				; |
		LDA.w CHARACTER_DATA+$02,x	; |
		STA $08				;/
		LDX $05				; X = OAM index
		LDA $00				;\
	-	STA !OAM+$00,x			; | Write Xpos
		STA !OAM+$04,x			;/
		LDA $01				;\
		STA !OAM+$01,x			; | Write Ypos
		CLC : ADC #$08			; |
		STA !OAM+$05,x			;/
		LDA #$34			;\
		STA !OAM+$03,x			; | Write YXPPCCCT
		STA !OAM+$07,x			;/
		LDA $06				;\
		STA !OAM+$02,x			; | Write tile
		CLC : ADC #$10			; |
		STA !OAM+$06,x			;/
		LDA $07				;\ Break loop if all tiles are written
		BEQ +				;/
		DEC $07				;\
		TXA				; |
		CLC : ADC #$08			; |
		TAX				; |
		INC $06				; | Increment things and loop
		LDA $00				; |
		CLC : ADC #$08			; |
		BRA -				;/
	+	TXA				;\
		CLC : ADC #$08			; | Increment OAM index
		STA $05				;/
		LDA $00				;\
		CLC : ADC $08			; |
		if !BaseDistance == $00		; |
		else				; | Increment Xpos
		CLC : ADC #!BaseDistance	; |
		endif				; |
		STA $00				;/
		INY				;\ Loop
		BRL .Loop			;/

.Return		LDA.b #.SA1 : STA $3180
		LDA.b #.SA1>>8 : STA $3181
		LDA.b #.SA1>>16 : STA $3182
		JSR $1E80
		PLB				; > Pull bank
.CODE_00922E:	JML $00922E			; > Return to RTS

		.SA1
		PHP
		PHB
		STZ !OAM+$29F
		REP #$30
		LDA #$007E
		LDX #!OAM+$29F
		LDY #!OAM+$29E
		MVP $00,$00
		PLB
		PLP
		RTL

;=================;
;UPLOADING ROUTINE;
;=================;
; This routine uploads the font GFX to SP2.

UPLOAD_FONT:

		REP #$20			; > A 16 bit
		LDX #$80			;\ Word writes
		STX $2115			;/
		LDA #$1801			;\ DMA parameters and destination
		STA $4300			;/
		LDA #$6800			;\ Dest VRAM (Start of SP2)
		STA $2116			;/
		LDA #GFX_SOURCE			;\ Location of GFX (within bank)
		STA $4302			;/
		LDX #GFX_SOURCE>>16		;\ Bank with GFX
		STX $4304			;/
		LDA #$1000			;\ Data size (4kb)
		STA $4305			;/
		SEP #$20			; > A 8 bit
		LDA #$01			;\ Enable HDMA on channel 1
		STA $420B			;/
.CODE_00A82C	JML $00A82C			; Return


;========;
;MESSAGES;
;========;
cleartable
table "IntroTable.txt"
INTRO_QUOTES:

	.Ptr
		dw Mario_1
		dw Mario_2
		dw Luigi_1
		dw Luigi_2
		dw Kadaal_1
		dw Kadaal_2
		dw Leeway_1
		dw Leeway_2
		dw Alter_1
		dw Alter_2
		dw Peach_1
		dw Peach_2

DEATH_QUOTES:
		dw Defeat_Text
		dw Time_Up
		dw Game_Over


	Mario:
		.1
		db $40,$68
		db "PLUMBER JUSTICE!"
		db $FF

		.2
		db $48,$68
		db "IT'S-A GO TIME!"
		db $FF

	Luigi:
		.1
		.2
		db $60,$68
		db "GO-IGI!"
		db $FF

	Kadaal:
		.1
		db $32,$68
		db "NOW IT'S KOOPA TIME!"
		db $FF

		.2
		db $3C,$68
		db "TIME FOR SMASHING!"
		db $FF

	Leeway:
		.1
		db $58,$68
		db "GET REXT!"
		db $FF

		.2
		db $48,$68
		db "SLICE AND DICE!"
		db $FF

	Alter:
		.1
		.2
	Peach:
		.1
		.2
		db $44,$68
		db "COMING SOON..."
		db $FF


	Defeat_Text:
		db $50,$68			; Starting coords
		db "PLAYER FAIL!"		; Text
		db $FF				; End

	Time_Up:
		db $48,$68			; Starting coords
		db "TIME UP!"			; Text
		db $FF				; End

	Game_Over:
		db $58,$68			; Starting coords
		db "GAME OVER!"			; Text
		db $FF				; End


;=========;
;FONT DATA;
;=========;
CHARACTER_DATA:

; Values are, in order: base tile number, number of 8x16 tiles -1, character width.
; Character height is always 16 pixels.

	.A	db $00,$00,$08
	.B	db $01,$01,$09
	.C	db $03,$00,$08
	.D	db $04,$01,$09
	.E	db $06,$00,$08
	.F	db $07,$00,$08
	.G	db $08,$00,$08
	.H	db $09,$00,$08
	.I	db $0A,$00,$04
	.J	db $0B,$00,$08
	.K	db $0C,$01,$09
	.L	db $0E,$00,$08
	.M	db $20,$01,$0B
	.N	db $22,$00,$08
	.O	db $23,$00,$08
	.P	db $24,$01,$09
	.Q	db $26,$01,$09
	.R	db $28,$01,$09
	.S	db $2A,$00,$08
	.T	db $2B,$00,$08
	.U	db $2C,$00,$08
	.V	db $2D,$00,$08
	.W	db $2E,$01,$0C
	.X	db $40,$00,$08
	.Y	db $41,$00,$08
	.Z	db $42,$00,$08

		db $43,$00,$04			; '
		db $44,$00,$08			; -
		db $45,$00,$04			; !
		db $46,$00,$04			; ,
		db $47,$00,$04			; .
		db $48,$00,$08			; ?
		db $49,$00,$08			; space

GFX_SOURCE:	incbin "IntroQuotes.bin"	; GFX file to load font from