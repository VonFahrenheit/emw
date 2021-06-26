

	!SourceIndex	= $03
	!OutputIndex	= $05
	!ByteCount	= $07


; these codes replace Lunar Magic's GFX/tilemap loaders




	UploadFiles:
	pushpc
	org $0085FD						; this routine is probably not supposed to run...
		LDA #$80 : STA $2115				;\
		BRA +						;/ org: LDA #$FC : STA $00 : STZ $2115
	org $008640
		+


	; $05BE8A is called from $00A5BF in all.log
	; however, LM hijacks $00A5BF and calls $05BE8A from within its own hijack!
	; the hijack at $00A5BF only uploads the level palette, as far as i can tell
	; when called, $FE is the level number of the level to load the palette from, +1
	; it then loads the pointer from $0EF600,[$FE*3]
	; if the pointer's lo + hi bytes = 0, just return
	; otherwise read 2 bytes from the pointer into !2132, then read 512 bytes into !PaletteRGB

	org $05BE8A
		REP #$20
		LDA $1C : STA $24
		SEP #$20
		RTL						; this routine SUCKS!

	org $00A9DF
		JSL .Main					;\ org: LDX #$03 : LDA $792B
		RTS						;/

	org $05DA1E						;\
		BRA +						; |
		NOP #4						; | patch out "no yoshi" intro
	warnpc $05DA24						; |
	org $05DA24						; |
		+						;/

	pullpc
	.Main
		PHP						; push P
		REP #$30					; all regs 16-bit
		LDA.w #!DecompBuffer : STA $00			;\ $00 = pointer to decompression buffer
		LDA.w #!DecompBuffer>>8 : STA $01		;/
		LDA.l $0FF7FF+0 : STA $03			;\ $03 = pointer to GFX list
		LDA.l $0FF7FF+1 : STA $04			;/
		LDA !Level					;\
		TAX						; | X = level index
		ASL #5						; | Y = GFX list index
		TAY						;/

		LDA.l !VRAM_map_table,x				;\
		AND #$00FF					; | $06 = VRAM map mode
		STA $06						;/


		LDA [$03],y					;\
		AND #$0FFF					; |
		CMP #$007F : BEQ .NoAN2				; |
		JSL !DecompressFile				; |
		STZ $2182					; |
		LDA #$AD00 : STA $2181				; |
		LDA #$8000 : STA $4310				; | check for and upload AN2 file
		LDA.w #!DecompBuffer : STA $4312		; |
		LDA.w #!DecompBuffer>>8 : STA $4313		; |
		LDA #$1B00 : STA $4315				; |
		SEP #$20					; |
		LDA #$02 : STA $420B				; |
		REP #$20					; |
		.NoAN2						;/


		PHX						;\ push X/Y
		PHY						;/
		LDA [$03],y					;\ AN2: G3T----
		AND #$F000					;/
		STA $0C						; > $0C = bypass flags

		INY #2						;\
		LDA [$03],y					; | LT3: DDFF----
		AND #$3000					; |
		CMP #$3000					; |
		BNE $03 : LDA #$0000				; | $0A = size of BG3 tilemap
		XBA						; |
		LSR #3						; |
		TAX						; |
		LDA.l .BG3TilemapSize,x : STA $0A		;/

		INY #2						;\
		LDA [$03],y					; | BG3: AAAA----
		AND #$F000					;/

		TYA						;\
		CLC : ADC #$0010				; |
		TAY						; |
	;	LDA [$03],y					; | SP3: yyyy----
	;	AND #$F000					; | (hi nybble of !BG3BaseSettings)
	;	XBA						; | (UNUSED???)
	;	STA $08						;/

	; NOTE: if you comment this out you need to chance the ADC #$0010 above to ADC #$000E
	;
	;	INY #2						;\
	;	LDA [$03],y					; | SP2: YY------
	;	AND #$F000					;/ these bits seem useless?

		INY #2						;\
		LDA [$03],y					; |
		AND #$F000					; | SP1: SCXX----
		XBA						; |
		LSR #4						; |
		STA $0E						; |
		AND #$0004					; |
		TSB !2131					; > set BG3 translucency
		LDA $0E						; |
		AND #$0008					; |
		LSR A						; |
		TRB !MainScreen					; > BG3 main/sub allocation
		TSB !SubScreen					; |
		LDA $0E						; |
		AND #$0003					; |
		XBA						; |
		LSR A						; |
		STA !BG3BaseH					;/> BG3 base X position

		INY #2						;\
		LDA [$03],y					; |
		AND #$F000					; |
		XBA						; |
		LSR #4						; | LG4: y0IB----
		SEP #$20					; | (lo nybble of !BG3BaseSettings)
	;	ORA $08						; |
		STA !BG3BaseSettings				; |
		REP #$20					;/

		INY #2						;\
		LDA [$03],y					; | LG3: YYYY----
		AND #$F000					;/
		XBA : TSB !BG3BaseSettings			; hi nybble of !BG3BaseSettings

		INY #2						;\
		LDA [$03],y					; |
		AND #$F000					; | LG2: HHHH----
		XBA						; | (lo nybble of BG3 scroll settings)
		LSR #4						; |
		STA $08						;/
		BIT $0C : BVC .NoBypassX			;\
		ASL A						; |
		TAX						; | base BG3 X speed (only if bypass enabled)
		LDA.l .BG3Speed,x : STA !BG3XSpeed		; |
		.NoBypassX					;/

		INY #2						;\
		LDA [$03],y					; |
		AND #$F000					; | LG1: VVVV----
		XBA						; | (hi nybble of BG3 scroll settings)
		SEP #$20					; |
		ORA $08						; |
		STA !BG3ScrollSettings				; |
		REP #$20					;/
		BIT $0C : BVC .NoBypassY			;\
		LDA [$03],y					; |
		AND #$F000					; |
		XBA						; | base BG3 Y speed (only if bypass enabled)
		LSR #3						; |
		TAX						; |
		LDA.l .BG3Speed,x : STA !BG3YSpeed		; |
		.NoBypassY					;/

		PLY						;\ pull X/Y
		PLX						;/

		LDA $06						;\ check VRAM map mode
		CMP #$0002 : BNE .CheckBG3Upload		;/
		.ClearBG3Tilemap				;\
		INY #2						; > skip past BG3 tilemap (LT3)
		LDA #$1908 : STA $4310				; |
		LDA.w #.Some00F8+1 : STA $4312			; | if 2, clear displacement map
		LDA.w #(.Some00F8+1)>>8 : STA $4313		; |
		BRA +						;/
		.CheckBG3Upload					;\
		ASL A						; | prepare to load BG3 tilemap
		TAX						; |
		INY #2						;/
		LDA $0C						;\ see if a tilemap should even be loaded (layer 3 bypass)
		AND #$2000 : BEQ .NoBG3Tilemap			;/
		LDA [$03],y					;\
		AND #$0FFF					; | decompress ExGFX
		CMP #$007F : BEQ .NoBG3Tilemap			; |
		JSL !DecompressFile				;/
		LDA #$1801 : STA $4310				;\
		LDA.w #!DecompBuffer : STA $4312		; |
		LDA.w #!DecompBuffer>>8 : STA $4313		; | set up DMA to upload BG3 tilemap
		LDA $0A : STA $4315				; |
		LDA.l .VRAM+8,x : STA $2116			; |
		BRA .Shared					;/
		.NoBG3Tilemap					;\
		LDA #$1808 : STA $4310				; |
		LDA.w #.Some00F8 : STA $4312			; |
		LDA.w #.Some00F8>>8 : STA $4313			; |
		LDA #$1000 : STA $4315				; | wipe even bytes of BG3 tilemap
		LDA.l .VRAM+8,x : STA $2116			; |
		SEP #$20					; |
		STZ $2115					; |
		LDA #$02 : STA $420B				;/
		LDA #$80 : STA $2115				;\
		REP #$20					; |
		LDA #$1908 : STA $4310				; |
		LDA.w #.Some00F8+1 : STA $4312			; | set up DMA to wipe odd bytes of BG3 tilemap
		LDA.w #(.Some00F8+1)>>8 : STA $4313		; |
	+	LDA #$1000 : STA $4315				; |
		LDA.l .VRAM+8,x : STA $2116			;/
		.Shared						;\
		SEP #$20					; | DMA to BG3 tilemap
		LDA #$02 : STA $420B				; |
		REP #$20					;/
		LDA $06						;\
		ASL A						; | X = index to file size and VRAM tables
		CLC : ADC #$0010				; |
		TAX						;/

	.Loop	INY #2						;\
		LDA [$03],y					; |
		AND #$0FFF					; | if there is a file, decompress it
		CMP #$007F : BEQ .NoDecomp			; |
		JSL !DecompressFile				;/
		LDA #$1801 : STA $4310				;\
		LDA.w #!DecompBuffer : STA $4312		; |
		LDA.w #!DecompBuffer>>8 : STA $4313		; |
		LDA.l .FileSize,x : STA $4315			; | DMA file to VRAM
		LDA.l .VRAM,x : STA $2116			; |
		SEP #$20					; |
		LDA #$02 : STA $420B				; |
		REP #$20					;/
		.NoDecomp					;\
		TXA						; |
		CLC : ADC #$0008				; | loop
		TAX						; |
		CPX.w #.VRAM-.FileSize : BCC .Loop		;/

		PLP						; restore P
		RTL						; return

		.Some00F8
		dw $00F8



; FG1: 0000
; FG2: 0800
; BG1: 1000
; FG3: 1800
; BG2: 2000
; BG3: 2800

		.BG3Speed
		dw $0000		; 0 - no
		dw $0000		; 1 - constant
		dw $0000		; 2 - variable
		dw $0000		; 3 - variable 2
		dw $0000		; 4 - slow 2
		dw $0000		; 5 - slow
		dw $0080		; 6 - auto slow (negative)
		dw $0080		; 7 - auto constant (negative)
		dw $0080		; 8 - auto variable (negative)
		dw $0080		; 9 - auto constant (negative, x2 speed)
		dw $0080		; A - auto slow (positive)
		dw $0080		; B - auto constant (positive)
		dw $0080		; C - auto variable (positive)
		dw $0080		; D - auto variable (positive, x2 speed)
		dw $0000		; E - variable 3
		dw $0000		; F - UNUSED


		; format: file by file, each file has one entry per map

		.FileSize
		; |map 0|map 1|map 2|map 3
		dw $1B00,$1B00,$1B00,$FFFF	; AN2	goes in RAM
		dw $FFFF,$FFFF,$FFFF,$FFFF	; LT3	layer 3 tilemap
		dw $1000,$1000,$1000,$FFFF	; BG3	BG file 6
		dw $1000,$1000,$1000,$FFFF	; BG2	BG file 5
		dw $1000,$1000,$1000,$FFFF	; FG3	BG file 4
		dw $1000,$1000,$1000,$FFFF	; BG1	BG file 3
		dw $1000,$1000,$1000,$FFFF	; FG2	BG file 2
		dw $1000,$1000,$1000,$FFFF	; FG1	BG file 1
		dw $1000,$1000,$1000,$FFFF	; SP4	sprite file 4
		dw $1000,$1000,$1000,$FFFF	; SP3	sprite file 3
		dw $1000,$1000,$1000,$FFFF	; SP2	sprite file 2
		dw $1000,$1000,$1000,$FFFF	; SP1	sprite file 1
		dw $0800,$1000,$1000,$FFFF	; LG4	BG3 file 4
		dw $0800,$1000,$1000,$FFFF	; LG3	BG3 file 3
		dw $0800,$0800,$0800,$FFFF	; LG2	BG3 file 2
		dw $0800,$0800,$0800,$FFFF	; LG1	BG3 file 1

		; same order
		.VRAM
		; |map 0|map 1|map 2|map 3
		dw $FFFF,$FFFF,$FFFF,$FFFF	; AN2
		dw $5000,$5800,$5800,$FFFF	; LT3
		dw $2800,$2800,$2800,$FFFF	; BG3
		dw $2000,$2000,$2000,$FFFF	; BG2
		dw $1800,$1800,$1800,$FFFF	; FG3
		dw $1000,$1000,$1000,$FFFF	; BG1
		dw $0800,$0800,$0800,$FFFF	; FG2
		dw $0000,$0000,$0000,$FFFF	; FG1
		dw $7800,$7800,$7800,$FFFF	; SP4
		dw $7000,$7000,$7000,$FFFF	; SP3
		dw $6800,$6800,$6800,$FFFF	; SP2
		dw $6000,$6000,$6000,$FFFF	; SP1
		dw $4C00,$3800,$3800,$FFFF	; LG4
		dw $4800,$3000,$3000,$FFFF	; LG3
		dw $4400,$5400,$5400,$FFFF	; LG2
		dw $4000,$5000,$5000,$FFFF	; LG1

		.BG3TilemapSize
		dw $2000
		dw $1000
		dw $0800





	DecompressBackground:
	pushpc
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
	;	JSL .GetMap16					; > lunar magic sussy baka
		PLP						; |
		JMP .Return					;/


	..SA1
		PHP						;\
		SEP #$20					; | reg setup
		REP #$10					;/
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


		LDA #$0025 : STA $40C800			;\
		LDA #$0000 : STA $41C800			; |
		REP #$30					; |
		LDX #$C800					; |
		LDY #$C801					; | set all map16 tiles to 0x025 (air)
		LDA #$3800					; |
		MVN $40,$40					; |
		LDX #$C800					; |
		LDY #$C801					; |
		LDA #$3800					; |
		MVN $41,$41					;/

		PLA : STA $08					; restore $08
		RTL						; return


;	.GetMap16
;		SEP #$20					;\
;		REP #$10					; |
;		PHB						; |
;		LDA #$7E					; |
;		PHA : PLB					; |
;		LDX #$07FE					; |
;		LDY #$03FF					; | we truly live in a society, don't we, fusoya?
;	-	LDA !DecompBuffer,x : STA $B900,y		; |
;		LDA !DecompBuffer+1,x : STA $BD00,y		; |
;		DEX #2						; |
;		DEY : BPL -					; |
;		PLB						; |
;		RTL						;/


	.UploadGraphics
		SEP #$30					; all regs 8-bit
		LDA.b #..SA1 : STA $3180			;\
		LDA.b #..SA1>>8 : STA $3181			; |wait for SA-1 to get data
		LDA.b #..SA1>>16 : STA $3182			; |
		JSR $1E80					;/


	; setup
		LDA.b #!DecompBuffer>>16 : STA $4314		; source bank
		REP #$20					; A 16-bit
		LDA #$1801 : STA $4310				; DMA settings
		LDA !BG1Address : STA $2116			; VRAM address = start of BG1 tilemap
		LDX #$02					; X = DMA bit

	; BG1
		LDA.w #!DecompBuffer : STA $4312		; source address for block 1

		LDA $1A						;\
		AND #$0100					; > which tilemap to use
		ASL #2						; |
		STA $00						; |
		LDA $1C						; | VRAM address
		AND #$00F8					; |
		ASL #2						; > offset from vertical scroll
		STA $02						; > store this to use for size calc
		ADC $00						; |
		ADC !BG1Address					; > offset from tilemap location
		STA $2116					;/
		STA $04						; $04 = VRAM address for BG1 block 1
		LDA #$0400					;\
		SEC : SBC $02					; |
		ASL A						; | upload BG1 block 1
		STA $4315					; |
		STA $06						; > $06 = size for BG1 block 1
		STX $420B					;/
		LDA $02 : BEQ +					;\
		ASL A						; |
		STA $4315					; |
		STA $08						; > $08 = size for BG1 block 2
		LDA $1A						; |
		AND #$0100					; | upload BG1 block 2
		ASL #2						; |
		ADC !BG1Address					; |
		STA $2116					; |
		STX $420B					;/
	+	LDA.w #!DecompBuffer+$800 : STA $4312		; source address for second tilemap
		LDA $04						;\
		CLC : ADC #$0400				; |
		STA $2116					; |
		LDA $06 : STA $4315				; |
		STX $420B					; |
		LDA $02 : BEQ +					; |
		LDA $08 : STA $4315				; | upload second tilemap
		LDA $1A						; |
		AND #$0100					; |
		EOR #$0100					; |
		ASL #2						; |
		ADC !BG1Address					; |
		STA $2116					; |
		STX $420B					;/
		+

	; BG2
		LDY.b #!BG2Tilemap>>16 : STY $4314		; bank
		LDA !BG2Address : STA $2116			; start of BG2
		LDA $20						;\
		SEC : SBC #$0010				; | see if simple or multi upload is needed
		AND #$00F8 : BNE ..Multi			;/
		..Simple					;\
		LDA $20						; |
		SEC : SBC #$0010				; |
		AND #$0100					; |
		BEQ $03 : LDA #$0800				; |
		CLC : ADC.w #!BG2Tilemap			; |
		STA $4312					; |
		LDA #$0400 : STA $4315				; | simple upload to both tilemaps
		STX $420B					; |
		STA $4315					; |
		LDA $20						; |
		SEC : SBC #$0010				; |
		AND #$0100					; |
		BEQ $03 : LDA #$0800				; |
		CLC : ADC.w #!BG2Tilemap+$1000			; |
		STA $4312					; |
		STX $420B					;/
		SEP #$20					;\ return
		JML .ReturnGraphics				;/

		..Multi
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


		..SA1
		PHB : PHK : PLB					;\ wrapper start
		PHP						;/
		REP #$30					;\
		LDA $1C						; |
		AND #$FFF0					; |
		STA $00						; |
		SEP #$10					; |
		LDA #$0000					; | starting map16 index
		LDY $1B : BEQ +					; |
	-	CLC : ADC !LevelHeight				; |
		DEY : BNE -					; |
	+	CLC : ADC $00					; |
		STA $00						;/
		PHA						;\
		REP #$10					; | get data for first tilemap
		LDY #$0000					; |
		JSR ..Loop					;/
		PLA						;\
		CLC : ADC !LevelHeight				; | get data for second tilemap
		STA $00						; |
		JSR ..Loop					;/
		PLP						;\ wrapper end
		PLB						;/
		RTL						; return

	..Loop	SEP #$20					;\
		LDX $00						; |
		LDA $41C800,x : XBA				; |
		LDA $40C800,x					; | get 16-bit map16 tile number
		INX						; |
		STX $00						; |
		REP #$20					; |
		ASL A						;/
		PHY						;\
		PHP						; |
		JSL $06F540					; | get pointer to map16 tilemap data
		PLP						; |
		PLX						;/ > pull Y with X to index !DecompBuffer
		STA $0A						;\ prepare to read pointer
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
		AND #$003F : BNE ..Same				; | increment !DecompBuffer index
	..New	TYA						; |
		CLC : ADC #$0040				; |
		TAY						; |
	..Same	INY #4						;/
		CPY #$0800 : BEQ ..End				;\ loop
		CPY #$1000 : BNE ..Loop				;/
	..End	RTS						; return





















