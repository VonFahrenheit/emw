

;
; method:
;	- read input zip
;		- increment counters for raw tiles that come on-screen
;		- copy zip to RAM in raw format
;	- read delete zip
;		- decrement counters for raw tiles that go off-screen
;		- unload any tile that hits 0 as a result
;	- translate zip data
;		- translate raw num -> dynamic num
;		- for any tile that is not yet loaded, find a VRAM slot for it and queue the transfer in !loadbuffer
;	- process tile data
;		- translate as many entries in !loadbuffer as possible to VR2 format
;
; it has to be done this way to maximize space efficiency
;

;
; decompression map:
;
; $407000	HUD GFX composite (4KiB)

; $408000	map 21
; $408800	map 22
; $409000	map 23
; $409800	map 24
; $40A000	map 25
; $40A800	map 26

; $40B000	map 31
; $40B800	map 32
; $40C000	map 33
; $40C800	map 34
; $40D000	map 35
; $40D800	map 36
; $40E000	map 11
; $40E800	map 12
; $40F000	map 13
; $40F800	map 14

; $41C000	map 41
; $41C800	map 42
; $41D000	map 43
; $41D800	map 44
; $41E000	map 43
; $41E800	map 44
; $41F000	map 15
; $41F800	map 16

; $412000	HUD GFX (base layer)
; $413000	HUD GFX (sprite layer)







; $00		24-bit pointer to tilemap data
; $03		----
; $04		scratch
; $06		index+ for each tile loop (2 for horizontal, 0x40 for vertical)
; $08		base offset to tilemap (added to pointer)
; $0A		index cutoff to find the next tilemap at (0x40 - base X offset for horizontal, 0x800 - base Y offset for vertical)
; $0C		number of tiles left to check (later used as loop check for loader)
; $0E		number of incremented (from 0) indexes cached

; !BigRAM+$00	base index of second possible tilemap
; !BigRAM+$02	index cutoff for second possible tilemap
; !BigRAM+$04	pointer to second possible tilemap (24-bit)
; !BigRAM+$08	base index of third possible tilemap
; !BigRAM+$0A	index cutoff for third possible tilemap
; !BigRAM+$0C	pointer to third possible tilemap (24-bit)
; !BigRAM+$10	initial X of zip
; !BigRAM+$12	initial Y of zip



	!tilecount		= $410000	; 2 KiB, index = raw tile num, how many instances of each tile are currently live
	!tileaddress		= $410800	; 2 KiB, index = raw tile num, which vram index each tile gfx uses
	!vramalloc		= $411000	; 512 B, index = vram slot, which raw tile is loaded in each vram slot
	!loadcache		= $411200	; 1 KiB, keeps track of which non-loaded tiles (raw num) are about to scroll on-screen
	!loadbuffer		= $411600	; 1280 ($500) B, list of tiles (raw num) to load, and to where (simplified feed -> !VRAMtable)
	!loadindex		= $411B00	; 2 B, index to !loadbuffer
	!prev1A			= $411B02
	!prev1C			= $411B04
	!initzipcount		= $411B06	; 2 B, counts up from 0 to initialize zips
	;next			= $411B08

	!zipbuffer		= $411C00	; 512 B, tilemap data buffer
	;next			= $411E00


; zip buffer format:
; $000-$001: header (number of bytes to transfer)
; $002-$003: VRAM address (if highest bit is set, this is a column)
; $004-$1FF: - tilemap data

; if header != 0, the buffer is uploaded
; horizontal row -> VR2 table
; vertical column -> tile update table



	InitZips:
		PHB
		PEA $4141 : PLB : PLB
		PHP
		REP #$30
		LDA.w !initzipcount
		ASL #3
		ADC $1A
		SEC : SBC #$0010
		STA $00
		LDA $1C
		CLC : ADC #$0010
		STA $02
		LDA #$0001 : STA $04
		JSR HandleZips_Increment
		JSR HandleZips_LoadTilemap
		INC.w !initzipcount
		PLP
		PLB
		RTL


; TO DO:
; - add exception for when moving horizontally and vertically on the same frame!
;	corner tiles overlap, so the same tile might get decremented twice, possibly into a negative number!
; - add exception to skip processing of any tile outside the map boundaries (no increment/decrement/tile load of any kind)
;	increment: adjust starting VRAM, adjust size
;	decrement: adjust starting VRAM, adjust size
;	tile load: adjust... probably the same? starting VRAM and size?
;

	HandleZips:
		PHB							;\ B wrapper to bank $41
		PEA $4141 : PLB : PLB					;/
		PHP							;\ P wrapper to all regs 16-bit
		REP #$30						;/


		.Column
		LDA $1A
		EOR.w !prev1A
		AND #$0008 : BEQ ..done
		LDA $1C
		CLC : ADC #$0010
		STA $02
		LDA #$0001 : STA $04
		LDX #$0000
		LDA $1A
		CMP.w !prev1A
		BCS $02 : INX #2
		CLC : ADC.l .HorzOffset,x
		PHA
		CMP #$0600 : BCS ..noincrement
		STA $00
		JSR .Increment
		..noincrement

		LDA.w !prev1C
		CLC : ADC #$0010
		STA $02
		LDA #$0001 : STA $04
		LDX #$0000
		LDA.w !prev1A
		CMP $1A
		BCC $02 : INX #2
		CLC : ADC.l .HorzOffset+2,x
		CMP #$0600 : BCS ..nodecrement
		STA $00
		JSR .Decrement
		..nodecrement

		PLA
		CMP #$0600 : BCS ..done
		JSR .LoadTilemap
		..done


		.Row
		LDA $1C
		EOR.w !prev1C
		AND #$0008 : BEQ ..done
		LDA $1A
		SEC : SBC #$0010
		STA $00
		STZ $04
		LDX #$0000
		LDA $1C
		CMP.w !prev1C
		BCS $02 : INX #2
		CLC : ADC.l .VertOffset,x
		PHA
		CMP #$0400 : BCS ..noincrement
		STA $02
		JSR .Increment
		..noincrement

		LDA.w !prev1A
		SEC : SBC #$0010
		STA $00
		STZ $04
		LDX #$0000
		LDA.w !prev1C
		CMP $1C
		BCC $02 : INX #2
		CLC : ADC.l .VertOffset+2,x
		CMP #$0400 : BCS ..nodecrement
		STA $02
		JSR .Decrement
		..nodecrement

		PLA
		CMP #$0400 : BCS ..done
		JSR .LoadTilemap
		..done


		LDA $1A : STA.w !prev1A
		LDA $1C : STA.w !prev1C


		LDX #$03FF*2
		LDA #$0000
		CLC
	-	ADC.w !tilecount,x
		DEX #2 : BPL -
		STA.w $411B08

		PLP							; P wrapper end
		PLB							; B wrapper end
		RTL							; long return


		.HorzOffset
		dw $0108,$FFF0,$0108

		.VertOffset
		dw $00E8,$0010,$00E8



;------------------------------
; subroutines
;------------------------------


	; increment new tiles
		.Increment						;\
		LDA $00							; |
		BPL $03 : LDA #$0000
		AND #$00F8						; |
		LSR #3							; |
		STA $06							; |
		LDA $02							; |
		BPL $03 : LDA #$0000
		AND #$00F8						; |
		ASL #2							; | starting VRAM address of zip
		TSB $06							; |
		LDA $00							; |
		BPL $03 : LDA #$0000
		AND #$0100						; |
		ASL #2							; |
		ORA $06							; |
		ORA.l !BG1Address					; |
		STA.w !zipbuffer+2					;/
		LDA $04							;\
		BEQ $03 : LDA #$8000					; | set zip direction
		TSB.w !zipbuffer+2					;/
		JSR .GetPointer						;\
		LDX #$0000						; | setup
		LDY #$0000						;/
		..loop							;\
		LDA [$00],y : STA.w !zipbuffer+4,x			; |
		PHX							; |
		AND #$03FF						; |
		ASL A							; | get raw tilemap word and increment tile counter
		TAX							; |
		INC.w !tilecount,x					; |
		PLX							; |
		INX #2							;/
		TYA							;\
		CLC : ADC $06						; |
		CMP $0A : BCC ..sametilemap				; |
		JSR .NextTilemap					; | loop, getting updating tilemap pointer as necessary
		LDA #$0000						; |
		..sametilemap						; |
		TAY							; |
		DEC $0C : BNE ..loop					;/
		..done							;\ store byte count of zip
		STX.w !zipbuffer+0					;/
		RTS



	; decrement old tiles
		.Decrement						;\
		JSR .GetPointer						; | setup
		LDY #$0000						;/
		..loop							;\
		LDA [$00],y						; |
		AND #$03FF						; | check tile
		ASL A							; |
		TAX							; |
		DEC.w !tilecount,x : BNE ..next				;/
		..unload						;\
		LDA.w !tileaddress,x					; |
		STZ.w !tileaddress,x					; | count = 0
		DEC.w !tileaddress,x					; | remapped num = 0xFFFF (not loaded)
		ASL A							; | vram alloc = 0xFFFF (free)
		TAX							; |
		LDA #$FFFF : STA.w !vramalloc,x				; |
		..next							;/
		TYA							;\
		CLC : ADC $06						; |
		CMP $0A : BCC ..sametilemap				; |
		JSR .NextTilemap					; | loop
		LDA #$0000						; | (zip into next tilemap as necessary)
		..sametilemap						; |
		TAY							; |
		DEC $0C : BNE ..loop					;/
		RTS






; $00 = byte count
; $02 = starting VRAM address
; $04 = VRAM cutoff for zip split
;
;
; $0C = current !vramalloc index
; $0E = current source address for !VRAMtable (starts at !zipbuffer+4)



	; load tilemap
		.LoadTilemap						;\
		LDA.w !zipbuffer+0					; | skip if header = 0 bytes
		AND #$01FF : BNE ..process				; |
		JMP .Convert						;/
		..process						;\ set byte count
		STA $00							;/

		LDY #$01FE : STY $0C

		TAY
		DEY #2

		..loop
		LDA.w !zipbuffer+4,y : STA $04
		AND #$03FF^$FFFF : STA $06
		LDA $04
		AND #$03FF
		ASL A
		TAX
		LDA.w !tileaddress,x : BPL ..loaded

		..findvram
		PHY
		LDY $0C
	-	LDA.w !vramalloc,y : BMI ..thisone
		DEY #2 : BPL -
		BRK							; crash upon overflow to make sure i catch it

		..thisone
		TYA
		LSR A
		STA.w !tileaddress,x
		TXA
		LSR A
		STA.w !vramalloc,y
		DEY #2
		STY $0C
		LDY.w !loadindex
		XBA
		LSR A
		SEC
		ROR A
		STA.w !loadbuffer+0,y
		CPX #$0200*2 : BCS ..secondbank
		..firstbank
		LDA #$003D : BRA ..setbank				; > hardcoded for speedup
		..secondbank
		; opcode here
		..setbank
		STA.w !loadbuffer+2,y
		LDA $0C
		INC #2
		ASL #4
		STA.w !loadbuffer+3,y
		TYA
		CLC : ADC #$0005
		STA.w !loadindex
		PLY
		LDA $0C
		LSR A
		INC A
		..loaded
		ORA $06
		STA.w !zipbuffer+4,y
		DEY #2 : BPL ..loop

		STZ.w !zipbuffer+0					; |
		LDA.w !zipbuffer+2 : BMI .LoadColumn			;/

		.LoadRow						;\ RTS address
		PEA.w .Convert-1					;/
		LDX.w #!zipbuffer+4 : STX $0E				; starting source address
		LSR $00							; |

		..loop							;\
		STA $02							; |
		AND #$7FE0						; | setup
		CLC : ADC #$0020					; |
		STA $04							; |
		LDA $02							;/
		CLC : ADC $00						;\ check if this is the final part
		CMP $04 : BCC ..finish					;/
		LDA $04							;\
		SEC : SBC $02						; | split off a part of the zip and send it
		STA $0C							; |
		JSR ..sendrow						;/
		LDA $00							;\
		SEC : SBC $0C						; |
		BEQ ..return						; > exception: return if remaining size is 0
		STA $00							; |
		LDA $0C							; |
		ASL A							; |
		CLC : ADC $0E						; | update stuff and loop
		STA $0E							; |
		LDA $02							; |
		AND #$7FE0						; |
		EOR #$0400						; |
		BRA ..loop						;/
		..finish						;\ final part
		LDA $00 : STA $0C					;/
		..sendrow						;\
		JSL !GetVRAM : BCS ..return				; |
		LDA $0C							; |
		ASL A							; |
		STA !VRAMbase+!VRAMtable+$00,x				; | transfer a zip row part
		LDA.w #!zipbuffer>>16 : STA !VRAMbase+!VRAMtable+$04,x	; |
		LDA $0E : STA !VRAMbase+!VRAMtable+$02,x		; |
		LDA $02 : STA !VRAMbase+!VRAMtable+$05,x		; |
		..return						; |
		RTS							;/

		.LoadColumn						;\
		AND #$7FFF : STA $02					; |
		LDA $00							; |
		ASL A							; |
		STA !VRAMbase+!TileUpdateTable+0			; |
		LDA $02							; | setup
		AND #$7C00						; |
		CLC : ADC #$0400					; |
		STA $04							; |
		LDX #$0000						; |
		LDY #$0000						;/
		..loop							;\
		LDA $02 : STA !VRAMbase+!TileUpdateTable+2,x		; | VRAM address + tile data for column
		LDA.w !zipbuffer+4,y : STA !VRAMbase+!TileUpdateTable+4,x
		INY #2							;\
		INX #4							; |
		LDA $02							; |
		CLC : ADC #$0020					; | increment stuff
		CMP $04							; |
		BCC $03 : SBC #$0400					; |
		STA $02							;/
		DEC $00							;\
		DEC $00							; | loop
		BNE ..loop						;/






; load buffer:
; +0	source address
; +3	dest address
; (5 bytes / slot)


	; convert as many !loadbuffer slots to !VRAMtable as possible
		.Convert
		LDY.w !loadindex : BEQ ..full				; skip if buffer is empty
		..loop							;\
		TYA							; |
		SEC : SBC #$0005					; | Y = buffer index (skip if all have been gone through)
		TAY							; |
		BMI ..full						;/
		JSL !GetVRAM : BCS ..full				; X = VRAM table index (skip if table is full)
		LDA #$0040 : STA !VRAMbase+!VRAMtable+$00,x		; size is always 64 bytes
		LDA.w !loadbuffer+0,y : STA !VRAMbase+!VRAMtable+$02,x	;\ source address + bank
		LDA.w !loadbuffer+1,y : STA !VRAMbase+!VRAMtable+$03,x	;/
		LDA.w !loadbuffer+3,y : STA !VRAMbase+!VRAMtable+$05,x	; VRAM address
		BRA ..loop						;\ loop
		..full							;/
		TYA
		BPL $03 : LDA #$0000
		STA.w !loadindex

		RTS















; input:
;	$00 = X offset (global)
;	$02 = Y offset (global)
;	$04 = 0 for horizontal, 1 for vertical

		.GetPointer
		PHB : PHK : PLB
		LDX #$0000						;\
		LDY #$0000						; |
		LDA $00 : STA !BigRAM+$10				; > store initial X
		BPL $05 : LDA #$0000 : STZ $00				; |
		..xloop							; | $00 -> X offset
		CMP #$0100 : BCC ..xdone				; |
		SBC #$0100						; |
		INX #2							; |
		BRA ..xloop						; |
		..xdone							;/
		AND #$00F8						;\
		LSR #2							; | base X offset (+8px -> +2 to index)
		STA $08							;/
		LDA $02 : STA !BigRAM+$12				;\> store initial Y
		BPL $05 : LDA #$0000 : STZ $02				; |
		..yloop							; |
		CMP #$0100 : BCC ..ydone				; | $02 -> Y offset
		SBC #$0100						; |
		INY							; |
		BRA ..yloop						; |
		..ydone							;/
		AND #$00F8						;\
		ASL #3							; | base Y offset (+8px -> +40 to index)
		CLC : ADC $08						; |
		STA $08							;/
		TXA							;\
		CLC : ADC .TilemapMatrix_y,y				; |
		AND #$00FF						; |
		TAX							; |
		LDY .TilemapMatrix,x					; | set up pointer
		LDA DecompressionMap+2,y : STA $01			; |
		LDA DecompressionMap+1,y				; |
		CLC : ADC $08						; |
		STA $00							;/
		LDA $04 : BEQ ..horizontal				; check direction


	; vertical values
		..vertical
		LDA #$001C : STA $0C					; number of tiles to process
		LDA #$0040 : STA $06					; index+

		; negative never actually happens for vertical
		LDA !BigRAM+$12
		SEC : SBC #$0328
		BEQ +
		BMI +
		LSR #3
		SEC : SBC $0C
		EOR #$FFFF : INC A
		STA $0C
		+

		LDA $08							;\
		AND #$07C0						; |
		SEC : SBC #$0800					; | vertical index cutoff
		EOR #$FFFF : INC A					; |
		STA $0A							;/
		LDA $08							;\
		AND #$003E						; |
		STA $08							; > clear Y bits from $08
		STA !BigRAM+$00						; | base index/cutoff + pointer to second possible tilemap
		LDA #$0800 : STA !BigRAM+$02				; |
		LDY .TilemapMatrix+12,x					; |
		LDA DecompressionMap+1,y : STA !BigRAM+$04		; |
		LDA DecompressionMap+2,y : STA !BigRAM+$05		;/
		PLB
		RTS


	; horizontal values
		..horizontal
		LDA #$0024 : STA $0C					; number of tiles to process
		LDA #$0002 : STA $06					; index+

		; adjusting size for negative offset breaks the equilibrium, so we can't do it
		LDA !BigRAM+$10
		SEC : SBC #$04F0
		BEQ +
		BMI +
		LSR #3
		SEC : SBC $0C
		EOR #$FFFF : INC A
		STA $0C
		+

		LDA $08							;\
		AND #$003E						; |
		SEC : SBC #$0040					; | horizontal index cutoff
		EOR #$FFFF : INC A					; |
		STA $0A							;/
		LDA $08							;\
		AND #$07C0						; |
		STA $08							; > clear X bits from $08
		STA !BigRAM+$00						; | base index/cutoff for second and third possible tilemaps
		STA !BigRAM+$08						; |
		LDA #$0040						; |
		STA !BigRAM+$02						; |
		STA !BigRAM+$0A						;/
		LDY .TilemapMatrix+2,x					;\
		LDA DecompressionMap+1,y : STA !BigRAM+$04		; | pointer to second possible tilemap
		LDA DecompressionMap+2,y : STA !BigRAM+$05		;/
		LDY .TilemapMatrix+4,x					;\
		LDA DecompressionMap+1,y : STA !BigRAM+$0C		; | pointer to third possible tilemap
		LDA DecompressionMap+2,y : STA !BigRAM+$0D		;/
		PLB
		RTS


		.NextTilemap
		PHB : PHK : PLB
		LDA !BigRAM+$05 : STA $01
		LDA !BigRAM+$04
		CLC : ADC !BigRAM+$00
		STA $00
		LDA !BigRAM+$02 : STA $0A
		LDA !BigRAM+$08 : STA !BigRAM+$00
		LDA !BigRAM+$0A : STA !BigRAM+$02
		LDA !BigRAM+$0C : STA !BigRAM+$04
		LDA !BigRAM+$0D : STA !BigRAM+$05
		PLB
		RTS




; matrix is 8 screens wide to leave a "buffer screen" outside the actual map
; actual map is 6 x 4 screens

		.TilemapMatrix
		dw $0000		; Y = 0
		dw $0004		;
		dw $0008		;
		dw $000C		;
		dw $0010		;
		dw $0014		;

		dw $0018		; Y = 1
		dw $001C		;
		dw $0020		;
		dw $0024		;
		dw $0028		;
		dw $002C		;

		dw $0030		; Y = 2
		dw $0034		;
		dw $0038		;
		dw $003C		;
		dw $0040		;
		dw $0044		;

		dw $0048		; Y = 3
		dw $004C		;
		dw $0050		;
		dw $0054		;
		dw $0058		;
		dw $005C		;

		; filler values for Y overflow
		dw $0048		; Y = 4
		dw $004C		;
		dw $0050		;
		dw $0054		;
		dw $0058		;
		dw $005C		;

		..y
		db 0*2,6*2,12*2,18*2,18*2




	DecompressionMap:
		db $E8 : dl $40E000
		db $E9 : dl $40E800
		db $EA : dl $40F000
		db $EB : dl $40F800
		db $EC : dl $407000
		db $ED : dl $41F800
		db $EE : dl $41F000
		db $EF : dl $408800
		db $F0 : dl $409000
		db $F1 : dl $409800
		db $F2 : dl $40A000
		db $F3 : dl $40A800
		db $F4 : dl $40B000
		db $F5 : dl $40B800
		db $F6 : dl $40C000
		db $F7 : dl $40C800
		db $F8 : dl $40D000
		db $F9 : dl $40D800
		db $FA : dl $41C000
		db $FB : dl $41C800
		db $FC : dl $41D000
		db $FD : dl $41D800
		db $FE : dl $41E000
		db $FF : dl $41E800
		.End










