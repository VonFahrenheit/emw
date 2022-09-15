;================;
; MAP16 ROUTINES ;
;================;

; input:
;	A = 16-bit X coordinate
;	Y = 16-bit Y coordinate
; output:
;	A = 16-bit acts like setting
;	A returns 16-bit, index returns 8-bit
;	X/Y registers are shredded
;
; _Sprite version uses sprite-relative input coords
; _Tile version uses $9A/$98 as inputs, regs do not matter
	GetMap16:
		STX $9A
		STY $98
		BRA .Tile

	.Sprite
		STY $98
		SEP #$20
		CLC : ADC !SpriteXLo,x
		STA $9A
		XBA
		ADC !SpriteXHi,x
		STA $9A+1
		LDA !SpriteYHi,x : XBA
		LDA !SpriteYLo,x
		REP #$20
		CLC : ADC $98
		STA $98

	.Tile
		SEP #$20
		LDA #$F0 : STA $00
		LDA !Map16Width
		DEC A : STA $01

		STZ $2250
		REP #$30
		LDA !LevelHeight : STA $2251
		SEC : SBC #$0010
		STA $02

		LDA $98
		BPL $03 : LDA #$0000
		CMP $02
		BCC $02 : LDA $02
		STA $98
		LDA $9A
		BPL $03 : LDA #$0000
		CMP $00
		BCC $02 : LDA $00
		STA $9A
		XBA
		AND #$00FF : STA $2253

		LDA $9A
		LSR #4
		AND #$000F : STA $00
		LDA $98
		AND #$FFF0
		ORA $00
		CLC : ADC $2306
		PHX
		TAX
		SEP #$20
		LDA $41C800,x : XBA
		LDA $40C800,x
		REP #$20
		ASL A : TAY
		BMI .40
	.00	LDA !Map16ActsLike : STA $00
		LDA !Map16ActsLike+1 : STA $01
		LDA [$00],y
		PLX
		SEP #$10
		RTL

	.40	LDA !Map16ActsLike40 : STA $00
		LDA !Map16ActsLike40+1 : STA $01
		LDA [$00],y
		PLX
		SEP #$10
		RTL



; input:
;	A = 16-bit map16 number
;	$98 = 16-bit Ypos
;	$9A = 16-bit Xpos

; method:
; - update map16 table
; - see if tile is within zip (0, 1, 2 or 4 tiles)
; - use block update table to update any tiles within zip

; if a tile is within the zip box, it has to be updated
; otherwise it must not be updated
;
; $45	16 bytes for zip purposes
; order: left, right, top, bottom
; (first for BG1 then for BG2)
	ChangeMap16:
		PHP
		REP #$30
		STA $0E

		STZ $2250
		LDA $9A+1
		AND #$00FF : STA $2251
		LDA !LevelHeight : STA $2253
		LDA $9A
		LSR #4
		AND #$000F : STA $00
		LDA $98
		AND #$FFF0
		ORA $00
		CLC : ADC $2306
		TAX
		SEP #$20
		LDA $0F : STA $41C800,x
		XBA
		LDA $0E : STA $40C800,x
		REP #$20


		.GetPointer
		ASL A
		CMP.w #$0300*2 : BCC ..noremap
		CMP.w #$0400*2 : BCS ..noremap
		..remap
		ASL #2
		AND #$07FF
		ADC.w #!Map16Page3
		STA $0A
		LDA.w #!Map16Page3>>16 : STA $0C
		BRA ..updatetile
		..noremap
		PHP
		JSL $06F540
		PLP
		STA $0A
		..updatetile
		LDA $9A : BMI ..fail
		CMP !BG1ZipBoxL : BCC ..fail
		CMP !BG1ZipBoxR : BCS ..fail
		LDA $98 : BMI ..fail
		CMP !BG1ZipBoxU : BCC ..fail
		CMP !BG1ZipBoxD : BCC .WithinScreen
		..fail
		PLP
		RTL

; $00	X (lo) part of address
; $02	Y part of address
; $04	X (hi) part of address
; $06	tilemap base address
; $08	assembling tilemap
; $0A	24-bit tile data pointer
; $0D	----
; $0E	remap data
;

	.WithinScreen
		LDA $98							;\
		AND #$00F0						; | > only 256px tall so cut the lowest screen bit
		ASL #2							; |
		STA $02							; |
		LDA $9A							; |
		AND #$00F0						; | address within tilemap
		LSR #3							; | -----Xyy yyyxxxxx
		STA $00							; | (word address, each tile is 2 bytes)
		LDA $9A							; | $00: x
		AND #$0100						; | $02: y
		ASL #2							; | $04: X
		STA $04							; | $06: tilemap address
		LDA !BG1Address : STA $06				;/


		PHB
		PEA $4040
		PLB : PLB
		LDX !TileUpdateTable
		LDY #$0000

		LDA [$0A],y : STA !TileUpdateTable+$04,x		;\
		LDY #$0002						; |
		LDA [$0A],y : STA !TileUpdateTable+$0C,x		; |
		LDY #$0004						; | tile data
		LDA [$0A],y : STA !TileUpdateTable+$08,x		; |
		LDY #$0006						; |
		LDA [$0A],y : STA !TileUpdateTable+$10,x		;/
		..next

		LDA $00							;\
		ORA $02							; |
		ORA $04							; | top left tile address
		ORA $06							; |
		STA !TileUpdateTable+$02,x				;/
		LDA $00							;\
		INC A							; |
		CMP #$0020						; |
		AND #$001F						; |
		BCC $03 : ORA #$0400					; | top right tile address
		STA $08							; |
		ORA $02							; |
		EOR $04							; |
		ORA $06							; |
		STA !TileUpdateTable+$06,x				;/
		LDA $02							;\
		CLC : ADC #$0020					; |
		AND #$03E0						; |
		STA $02							; | bot right tile address
		ORA $08							; |
		EOR $04							; |
		ORA $06							; |
		STA !TileUpdateTable+$0E,x				;/
		LDA $02							;\
		ORA $00							; |
		ORA $04							; | bot left tile address
		ORA $06							; |
		STA !TileUpdateTable+$0A,x				;/

		TXA
		CLC : ADC #$0010
		STA !TileUpdateTable

		PLB
		PLP
		RTL



	; NOTE!
	; if $9C = $01/$16/$17/$18, item memory bit has to be set!
	.Hijack00BEB0
		PHX
		PHP
		REP #$30
		LDA $9C
		AND #$00FF
		CMP #$0018
		BCC ..singletile
		BEQ ..yoshicoin
		CMP #$0019 : BEQ ..netdoor
		CMP #$001A : BEQ ..netdoor

		; 1B and up uses this one
	..32x32
		LDA #$0025 : JSL ChangeMap16
		LDA $98 : PHA
		CLC : ADC #$0010
		STA $98
		LDA #$0025 : JSL ChangeMap16
		PLA : STA $98
		LDA $9A
		CLC : ADC #$0010
		STA $9A

	..yoshicoin
		LDA #$0025 : JSL ChangeMap16
		LDA $98
		CLC : ADC #$0010
		STA $98
		LDA #$0025 : JSL ChangeMap16
		PLP
		PLX
		RTL

	..singletile
		ASL A
		TAX
		LDA.l ..tiletranslation,x : BMI ..fail			; some values are invalid
		JSL ChangeMap16
		..fail
		PLP
		PLX
		RTL

	..netdoor
		PLP
		PLX
		RTL

	..tiletranslation
		dw $FFFF,$0025,$0025,$0006,$0049,$0048,$002B,$00A2	; 00-07
		dw $00C6,$0152,$011B,$0123,$011E,$0132,$0113,$0115	; 08-0F
		dw $0116,$012B,$012C,$0112,$0168,$0169,$0132,$015E	; 10-17





