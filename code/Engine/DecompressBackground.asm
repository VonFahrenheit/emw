
	pushpc
	org $05801E
	DecompressBackground:
		; this code is (almost) unedited but included so it can be read
		; LM hijacks at $05803B, so this code has to remain as is
		PHP
		SEP #$20
		REP #$10
		LDX #$0000
		LDA #$25
	-	STA $7EB900,x
		STA $7EBB00,x
		INX
		CPX #$0200 : BNE -
		STZ $7928					; required for object loader
		LDA $6A
	warnpc $05803B
	org $0580BB
		JML .UploadGraphics				; org: STA $55 : REP #$30
	org $058105
	.ReturnGraphics
		; this is the code here: (i'd rather not mess with it tho)
		; LDA $6D9D
		; STA $212C
		; STA $212E
		; LDA $6D9E
		; STA $212D
		; STA $212F
		; REP #$20
		; LDA #$FFFF
		; STA $4D
		; STA $4F
		; STA $51
		; STA $53
		; PLP
		; RTL
	org $058071
		JMP .Main					; used to be JSR
	org $058089
	.Return
	org $058126
	.Main
		PHP						;\
		SEP #$20					; |
		LDA.b #..SA1 : STA $3180			; |
		LDA.b #..SA1>>8 : STA $3181			; | accelerate
		LDA.b #..SA1>>16 : STA $3182			; |
		JSR $1E80					; |
		PLP						; |
		JMP .Return					;/

	..SA1
		PHP						;\
		SEP #$20					; | reg setup
		REP #$10					;/

		LDX !Level					;\
		LDA.l !Layer2Type,x				; |
		AND #$02 : BNE ..decomp				; | skip decompression (which would fail anyway) if layer 2 level
		PHB						; |
		BRA .End					;/

		..decomp
		LDY.w #!DecompBuffer : STY $0D			;\ pointer to output location
		LDA.b #!DecompBuffer>>16 : STA $0F		;/
		LDX #$0000					;\
		LDY #$0000					; | starting index
		STY !SourceIndex				;/
		PHB						;\
		LDA.b #!DecompBuffer>>16			; | swap to bank 0x40
		PHA : PLB					;/

		.Next						;\
		REP #$20					; |
		LDA [$68],y					; |
		CMP #$FFFF					; |
		SEP #$20					; | read header byte
		BEQ .End					; |
		STA !ByteCount					; |
		INY						; |
		AND #$80 : BEQ .DirectCopy			;/

		.RLE						;\
		TRB !ByteCount					; |
		LDA [$68],y					; |
		INY						; |
	-	STA.w !DecompBuffer,x				; | write RLE string
		INX #2						; > write every other byte (use 16-bit format)
		CPX #$0800					; |
		BCC $03 : LDX #$0001				; > wrap to hi byte location
		DEC !ByteCount : BPL -				; |
		BRA .Next					;/

		.DirectCopy					;\
		LDA [$68],y					; |
		INY						; |
		STA.w !DecompBuffer,x				; | write direct copy block
		INX #2						; > write every other byte (use 16-bit format)
		CPX #$0800					; |
		BCC $03 : LDX #$0001				; > wrap to hi byte location
		DEC !ByteCount : BPL .DirectCopy		; |
		BRA .Next					;/

		.End
		JSL .GetTilemap					; convert to SNES tilemap format
		PLB						; restore P
		PLP						; restore bank
		RTL						; return

		; old format:
		; $000-$1FF: left half, lo bytes
		; $200-$3FF: right half, lo bytes
		; $400-$5FF: left half, hi bytes
		; $600-$7FF: right half, hi bytes

		; current format in !DecompBuffer:
		; $000-$3FF: left half, 16-bit tile numbers
		; $400-$7FF: right half, 16-bit tile numbers

	warnpc $0581BB
	pullpc
	.GetTilemap
		REP #$20					;\
		LDA.l !Level : TAX				; |
		SEP #$20					; | skip upload if layer 2 level
		LDA.l !Layer2Type,x				; |
		AND #$02 : BNE ..getmap16			; |
		JMP ..killmap16					;/

		..getmap16
		PEI ($08)					; preserve $08
		LDA.b #!BG2Tilemap>>16 : PHA			; push output bank
		REP #$30					;\
		LDA.l !Level : TAX				; |
		LDA.l !Layer2Type,x				; |
		AND #$0004 : BEQ +				; | map16 bank
		LDA.l !Layer2Type-1,x				; |
		AND #$F000					; |
	+	STA $00						;/
		PLB						; swap to output bank
		STZ !SourceIndex				;\ starting source/output index
		STZ !OutputIndex				;/
	-	LDY !SourceIndex				;\
		LDA [$0D],y					; |
		ORA $00						; |
		AND #$F000					; |
		XBA						; |
		LSR #3						; | set up pointer to map16 tilemap data
		STA $07						; |
		LSR A						; |
		CLC : ADC $07					; |
		TAX						; |
		LDA.l !Map16BG+0,x : STA $07			; |
		LDA.l !Map16BG+1,x : STA $08			;/
		LDX !OutputIndex				;\
		LDA [$0D],y					; |
		INY #2						; |
		STY !SourceIndex				; | read map16 tile
		AND #$0FFF					; |
		ASL #3						; |
		TAY						;/
		LDA [$07],y : STA.w !BG2Tilemap+$00,x		;\
		INY #2						; |
		LDA [$07],y : STA.w !BG2Tilemap+$40,x		; |
		INY #2						; |
		LDA [$07],y : STA.w !BG2Tilemap+$02,x		; |
		INY #2						; |
		LDA [$07],y : STA.w !BG2Tilemap+$42,x		; | get map16 tilemap data
		INX #4						; |
		TXA						; |
		AND #$003F : BNE +				; |
		TXA						; |
		CLC : ADC #$0040				; |
		TAX						; |
	+	STX !OutputIndex				;/
		CPX #$2000 : BCC -				; loop until 8KB of data has been transcribed

		..killmap16
		PHB						;\
		LDA #$0025 : STA $40C800			; |
		LDA #$0000 : STA $41C800			; |
		LDX #$C800					; |
		LDY #$C801					; |
		LDA #$37FF					; | set all map16 tiles to 0x025 (air)
		MVN $40,$40					; |
		LDX #$C800					; |
		LDY #$C801					; |
		LDA #$37FF					; |
		MVN $41,$41					; |
		PLB						;/

		PLA : STA $08					; restore $08
		RTL						; return


	.UploadGraphics
		SEP #$30					; all regs 8-bit
		LDA.b #.BG1_SA1 : STA $3180			;\
		LDA.b #.BG1_SA1>>8 : STA $3181			; | wait for SA-1 to get data
		LDA.b #.BG1_SA1>>16 : STA $3182			; |
		JSR $1E80					;/

	; setup
		LDA.b #!DecompBuffer>>16 : STA $4314		; source bank
		REP #$20					; A 16-bit
		LDA #$1801 : STA $4310				; DMA settings
		LDA !BG1Address : STA $2116			; VRAM address = start of BG1 tilemap
		LDX #$02					; X = DMA bit

	; BG1
		LDA.w #!DecompBuffer : STA $4312
		LDA #$1000 : STA $4315
		STX $420B



	; BG2
		REP #$10					;\
		LDX !Level					; |
		LDA.l !Layer2Type,x				; | determine layer 2 type
		SEP #$10					; > index 8-bit
		LDX #$02					; > X = DMA bit
		AND #$0002 : BNE .BG2background			;/
		JMP .BG2level					; get level data

		.BG2background
		LDY.b #!BG2Tilemap>>16 : STY $4314		; bank
		LDA !BG2Address : STA $2116			; start of BG2
		LDA $20						;\
		SEC : SBC #$0010				; | see if simple or multi upload is needed
		AND #$00F8 : BNE ..multi			;/
		..simple					;\
		LDA $20						; |
		SEC : SBC #$0010				; |
		AND #$0100					; |
		BEQ $03 : LDA #$0800				; |
		CLC : ADC.w #!BG2Tilemap			; |
		STA $4312					; |
		LDA #$0800 : STA $4315				; | simple upload to both tilemaps
		STX $420B					; |
		STA $4315					; |
		LDA $20						; |
		SEC : SBC #$0010				; |
		AND #$0100					; |
		BEQ $03 : LDA #$0800				; |
		CLC : ADC.w #!BG2Tilemap+$800			; |
		STA $4312					; |
		STX $420B					;/
		SEP #$20					;\ return
		JML .ReturnGraphics				;/

		..multi
		LDA $20						;\
		SEC : SBC #$0010				; |
		AND #$01F8					; |
		ASL #3						; | size of block 1
		PHA						; > push offset of block 2
		AND #$07FF					; |
		STA $4315					;/
		STA $00						; > $00 = size of block 1
		LDA $20						;\
		SEC : SBC #$0010				; |
		AND #$0100					; |
		EOR #$0100					; | address of block 1
		BEQ $03 : LDA #$0800				; |
		CLC : ADC.w #!BG2Tilemap			; |
		STA $4312					;/
		STA $02						; > $02 = address of block 1
		STX $420B					; upload block 1
		LDA #$0800					;\
		SEC : SBC $00					; | size of block 2
		STA $4315					;/
		STA $04						; > $04 = size of block 2
		PLA						;\
		CLC : ADC.w #!BG2Tilemap			; | address of block 2
		STA $4312					;/
		STX $420B					; upload block 2
		STA $06						; > $06 = address of block 2
		LDA $00 : STA $4315				;\
		LDA $02						; |
		CLC : ADC #$1000				; | upload right half of block 1
		STA $4312					; |
		STX $420B					;/
		LDA $04 : STA $4315				;\
		LDA $06						; |
		CLC : ADC #$1000				; | upload right half of block 2
		STA $4312					; |
		STX $420B					;/

		SEP #$20					;\ return
		JML .ReturnGraphics				;/


	.BG1_SA1
		PHB : PHK : PLB					;\ wrapper start
		PHP						;/

		REP #$30					;\
		LDA $1C						; |
		AND #$FF00					; |
		STA $00						; |
		SEP #$10					; |
		LDA #$0000					; | starting map16 index
		LDY $1B : BEQ +					; |
	-	CLC : ADC !LevelHeight				; |
		DEY : BNE -					; |
	+	CLC : ADC $00					; |
		STA $00						;/
		PHA						; push (start of snap screen)
		REP #$10					; index 16-bit
		LDA $1C						;\
		AND #$00F0					; | $00 = start of tilemap 1
		CLC : ADC $00					; |
		STA $00						;/

		LDA $1A						;\
		AND #$0100					; | swap tilemap locations on odd screens
		BEQ $03 : LDA #$0800				; |
		STA $02						;/
		LDA $1C						;\
		AND #$00F0					; |
		ASL #3						; |
		ADC $02						; |
		TAY						; | get tilemap 1
		LDA $02						; |
		CLC : ADC #$0800				; |
		STA !BigRAM+0					; |
		JSR ..loop					;/
		LDA $1C						;\
		AND #$00F0 : BEQ ..tilemap1done			; |
		ASL #3						; |
		ADC $02						; |
		STA !BigRAM+0					; |
		LDY $02						; | complement tilemap 1
		LDA $01,s					; |
		CLC : ADC #$0100				; |
		STA $00						; |
		JSR ..loop					; |
		..tilemap1done					;/

		LDA $02						;\
		EOR #$0800					; | swap tilemaps between 1 and 2
		STA $02						;/
		LDA $1C						;\
		AND #$00F0					; |
		CLC : ADC $01,s					; |
		CLC : ADC !LevelHeight				; |
		STA $00						; |
		LDA $1C						; |
		AND #$00F0					; | get tilemap 2
		ASL #3						; |
		ADC $02						; |
		TAY						; |
		LDA $02						; |
		CLC : ADC #$0800				; |
		STA !BigRAM+0					; |
		JSR ..loop					;/
		PLA						;\
		CLC : ADC !LevelHeight				; | pull and prepare final loop
		CLC : ADC #$0100				; |
		STA $00						;/
		LDA $1C						;\
		AND #$00F0 : BEQ ..tilemap2done			; |
		ASL #3						; |
		ADC $02						; | complement tilemap 2
		STA !BigRAM+0					; |
		LDY $02						; |
		JSR ..loop					; |
		..tilemap2done					;/

	; column complement
	; 1 column on the left
	; 2 columns on the right
		LDA #$C800 : STA $05				; base map16 pointer
		LDA $94
		AND #$FF00
		DEC A
		AND #$FFF8 : BPL ..complementleft
		JMP ..leftdone					; don't go outside bounds

		..complementleft
		STA $00
		AND #$00FF
		LSR #4
		STA $08						; X (map16 index within screen)
		LDA $1C
		AND #$FFF0
		STA $02						; Y (map16 index)
		LDA $01
		AND #$00FF
		TAY
		LDA #$0000
		CPY #$0000 : BEQ +
	-	CLC : ADC !LevelHeight
		DEY : BNE -
	+	CLC : ADC $02
		ORA $08
		CLC : ADC $05
		STA $05
		; start of column
		LDA $00
		AND #$0008
		LSR A
		STA $00
		; index to side of map16 block
		LDA $94
		AND #$0100
		EOR #$0100
		BEQ $03 : LDA #$0800
		ORA #$003C
		TAX
		JSR .ComplementColumn
		..leftdone

		..complementright
		LDA #$C800 : STA $05
		LDA $94
		AND #$FF00
		CLC : ADC #$0100
		STA $00
		LDA $1C
		AND #$FFF0
		STA $02						; Y (map16 index)
		LDA $01
		AND #$00FF
		TAY
		LDA #$0000
		CPY #$0000 : BEQ +
	-	CLC : ADC !LevelHeight
		DEY : BNE -
	+	CLC : ADC $02
		CLC : ADC $05
		STA $05
		; start of column
		STZ $00
		; index to side of map16 block
		LDA $94
		AND #$0100
		EOR #$0100
		BEQ $03 : LDA #$0800
		TAX
		JSR .ComplementColumn
		LDA #$0004 : STA $00
		LDA $94
		AND #$0100
		EOR #$0100
		BEQ $03 : LDA #$0800
		TAX
		JSR .ComplementColumn



		..return
		PLP						;\ wrapper end
		PLB						;/
		RTL						; return

		..loop						;\
		SEP #$20					; |
		LDX $00						; |
		LDA $41C800,x : XBA				; |
		LDA $40C800,x					; | get 16-bit map16 tile number
		INX						; |
		REP #$20					; |
		STX $00						; |
		ASL A						;/
		CMP.w #$0300*2 : BCC ..noremap
		CMP.w #$0400*2 : BCS ..noremap
		..remap
		ASL #2
		AND #$07FF
		ADC.w #!Map16Page3
		STA $0A
		LDA.w #!Map16Page3>>16 : STA $0C
		TYX
		BRA ..readtile
		..noremap
		PHY						;\
		PHP						; |
		JSL $06F540					; | get pointer to map16 tilemap data
		PLP						; |
		PLX						; > pull Y with X to index !DecompBuffer
		STA $0A						;/
		..readtile					;\ prepare to read pointer
		LDY #$0000					;/
		LDA [$0A],y : STA !DecompBuffer+$00,x		;\
		LDY #$0002					; |
		LDA [$0A],y : STA !DecompBuffer+$40,x		; |
		LDY #$0004					; | get map16 tilemap data
		LDA [$0A],y : STA !DecompBuffer+$02,x		; |
		LDY #$0006					; |
		LDA [$0A],y : STA !DecompBuffer+$42,x		;/
		..next						;\
		TXY						; |
		TYA						; |
		CLC : ADC #$0004				; |
		AND #$003F : BNE ..same				; | increment !DecompBuffer index
	..new	TYA						; |
		CLC : ADC #$0040				; |
		TAY						; |
	..same	INY #4						;/
		CPY !BigRAM+0 : BCC ..loop			;\ loop
		RTS						; return




; possible input X (tilemap buffer index)
; 000
; 002
; 800
; 802
; 03C
; 03E
; 83C
; 83E
		.ComplementColumn
		LDA $00
		BEQ $02 : INX #2
		LDA $1C
		AND #$00F0
		ASL #3
		STA $0A
		TXA
		CLC : ADC $0A
		TAX
		LDY #$0000
	-	SEP #$20
		LDA #$41 : STA $07
		PHX
		LDA #$00 : XBA
		LDA [$05],y : XBA
		DEC $07
		LDA [$05],y
		REP #$20
		ASL A
		CMP.w #$0300*2 : BCC ..noremap
		CMP.w #$0400*2 : BCS ..noremap
		..remap
		ASL #2
		AND #$07FF
		ADC.w #!Map16Page3
		PHA
		LDA.w #!Map16Page3>>16 : STA $0C
		PLA : BRA ..readtile
		..noremap
		PHY
		PHP
		JSL $06F540				; this will store the bank byte to $0C and return with the address in A
		PLP
		PLY
		..readtile
		LDX $00
		BEQ $04 : CLC : ADC #$0004
		PLX
		STA $0A
		LDA [$0A] : STA !DecompBuffer+$00,x
		INC $0A
		INC $0A
		LDA [$0A] : STA !DecompBuffer+$40,x

		STX $0A
		TXA
		CLC : ADC #$0080
		TAX
		EOR $0A
		AND #$0800 : BEQ +
		TXA
		EOR #$0800
		TAX
	+	TYA
		CLC : ADC #$0010
		TAY
		CPY #$0100 : BCC -
		RTS





	.BG2level
		SEP #$30					; all regs 8-bit
		LDA.b #.BG2_SA1 : STA $3180			;\
		LDA.b #.BG2_SA1>>8 : STA $3181			; | wait for SA-1 to get data
		LDA.b #.BG2_SA1>>16 : STA $3182			; |
		JSR $1E80					;/

		REP #$20					; A 16-bit
		LDA !BG2Address : STA $2116			; VRAM address = start of BG2 tilemap
		LDA.w #!DecompBuffer : STA $4312
		LDA #$1000 : STA $4315
		LDX #$02 : STX $420B

		SEP #$30
		JML .ReturnGraphics				; return



	.BG2_SA1
		PHB : PHK : PLB					;\ wrapper start
		PHP						;/

		REP #$30					;\
		LDA $20						; |
		AND #$FF00					; |
		STA $00						; |
		SEP #$10					; |
		LDA #$0000					; | starting map16 index
		LDY $1F : BEQ +					; |
	-	CLC : ADC !LevelHeight				; |
		DEY : BNE -					; |
	+	CLC : ADC $00					; |
		STA $00						;/
		REP #$10					; index 16-bit
		LDA $20						;\
		AND #$00F0					; | $00 = start of tilemap 1
		CLC : ADC $00					; |
		STA $00						;/
		STZ $2250					; set up multiplication
		LDA !LevelHeight : STA $2251			;\
		LDA $5D						; | width * height = size of layer 1 data
		AND #$00FF					; | (height is in px, so no need for *16)
		STA $2253					;/
		AND #$0001					;\
		BEQ +						; | on odd-screened levels, add height (already *16 since it's in px)
		LDA !LevelHeight				;/ (on even-screened levels, layer 2 data starts right after layer 1 data)
	+	CLC : ADC $2306					;\
		CLC : ADC $00					; | starting index for layer 2
		STA $00						;/
		PHA						; push (start of snap screen)

		LDA $1E						;\
		AND #$0100					; | swap tilemap locations on odd screens
		BEQ $03 : LDA #$0800				; |
		STA $02						;/
		LDA $20						;\
		AND #$00F0					; |
		ASL #3						; |
		ADC $02						; |
		TAY						; | get tilemap 1
		LDA $02						; |
		CLC : ADC #$0800				; |
		STA !BigRAM+0					; |
		JSR ..loop					;/
		LDA $20						;\
		AND #$00F0 : BEQ ..tilemap1done			; |
		ASL #3						; |
		ADC $02						; |
		STA !BigRAM+0					; |
		LDY $02						; | complement tilemap 1
		LDA $01,s					; |
		CLC : ADC #$0100				; |
		STA $00						; |
		JSR ..loop					; |
		..tilemap1done					;/

		LDA $02						;\
		EOR #$0800					; | swap tilemaps between 1 and 2
		STA $02						;/
		LDA $01,s					;\
		CLC : ADC !LevelHeight				; |
		STA $00						; |
		LDA $20						; |
		AND #$00F0					; |
		ASL #3						; | get tilemap 2
		ADC $02						; |
		TAY						; |
		LDA $02						; |
		CLC : ADC #$0800				; |
		STA !BigRAM+0					; |
		JSR ..loop					;/
		PLA						;\
		CLC : ADC !LevelHeight				; | pull and prepare final loop
		CLC : ADC #$0100				; |
		STA $00						;/
		LDA $20						;\
		AND #$00F0 : BEQ ..tilemap2done			; |
		ASL #3						; |
		ADC $02						; | complement tilemap 2
		STA !BigRAM+0					; |
		LDY $02						; |
		JSR ..loop					; |
		..tilemap2done					;/

		..return
		PLP						;\ wrapper end
		PLB						;/
		RTL						; return

		..loop						;\
		SEP #$20					; |
		LDX $00						; |
		LDA $41C800,x : XBA				; |
		LDA $40C800,x					; | get 16-bit map16 tile number
		INX						; |
		REP #$20					; |
		STX $00						; |
		ASL A						;/
		CMP.w #$0300*2 : BCC ..noremap
		CMP.w #$0400*2 : BCS ..noremap
		..remap
		ASL #2
		AND #$07FF
		ADC.w #!Map16Page3
		STA $0A
		LDA.w #!Map16Page3>>16 : STA $0C
		TYX
		BRA ..readtile
		..noremap
		PHY						;\
		PHP						; |
		JSL $06F540					; | get pointer to map16 tilemap data
		PLP						; |
		PLX						; > pull Y with X to index !DecompBuffer
		STA $0A						;/
		..readtile					;\ prepare to read pointer
		LDY #$0000					;/
		LDA [$0A],y : STA !DecompBuffer+$00,x		;\
		LDY #$0002					; |
		LDA [$0A],y : STA !DecompBuffer+$40,x		; |
		LDY #$0004					; | get map16 tilemap data
		LDA [$0A],y : STA !DecompBuffer+$02,x		; |
		LDY #$0006					; |
		LDA [$0A],y : STA !DecompBuffer+$42,x		;/
		TXY						;\
		TYA						; |
		CLC : ADC #$0004				; |
		AND #$003F : BNE ..same				; | increment !DecompBuffer index
	..new	TYA						; |
		CLC : ADC #$0040				; |
		TAY						; |
	..same	INY #4						;/
		CPY !BigRAM+0 : BCC ..loop			;\ loop
		RTS						; return

