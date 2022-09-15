
; this file has codes for loading GFX and tilemaps for level INIT
; codes are NOT part of INIT, but run before it



	!SourceIndex	= $03
	!OutputIndex	= $05
	!ByteCount	= $07


; these codes replace Lunar Magic's GFX/tilemap loaders




	GFX_Loader:
	pushpc
	org $0085FD						; this routine is probably not supposed to run...
		LDA #$80 : STA $2115				;\
		BRA +						;/ org: LDA #$FC : STA $00 : STZ $2115
	org $008640
		+

	org $00A390
		-
	org $00A395						; patch out LM's initialization for vanilla animations
		PHP
		REP #$20
		STZ $6D7C
		STZ $6D7E
		STZ $6D80
		PLP
		BRA -
	warnpc $00A3F0


	; patch out vanilla palette loarders
	org $00ABED			; full loader
		RTS : RTS		; org: REP #$30
	org $00ACED			; halfrow loader
		RTS : RTS : RTS		; org: LDY #$0007
	org $00ACFF			; row loader
		RTS : RTS		; org: LDX $04




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

		LDA.l LevelData_VRAM_map,x			;\
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
		AND #$3000					; | $0A = size of BG3 tilemap
		XBA						; |
		LSR #3 : TAX					; |
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
		LDA.w #.Some0014+1 : STA $4312			; | if 2, clear displacement map
		LDA.w #(.Some0014+1)>>8 : STA $4313		; |
		JMP +						;/
		.CheckBG3Upload					;\
		ASL A						; | prepare to load BG3 tilemap
		TAX						; |
		INY #2						;/
		LDA $0C						;\ see if a tilemap should even be loaded (layer 3 bypass)
		AND #$2000 : BEQ .NoBG3Tilemap			;/
		LDA [$03],y					;\
		AND #$0FFF					; | check for BG3 tilemap
		CMP #$007F : BEQ .NoBG3Tilemap			;/
		PHA						;\
		PHX						; |
		AND #$00FF : TAX				; | BG3 tilemap resolution
		LDA #$0003 : TRB !2109				; |
		LDA.l LevelData_BG3_Resolution,x		; |
		AND #$0003 : TSB !2109				;/
		CMP #$0003 : BNE ..notbiggest			;\
		LDA !VRAMmap					; |
		AND #$00FF					; | in map mode 01, 64x64 tilemaps become 64x32 instead
		CMP #$0001 : BNE ..notbiggest			; |
		LDA #$0002 : TRB !2109				; |
		..notbiggest					;/
		PLX						;\ pull stuff
		PLA						;/
		JSL !DecompressFile				; decompress BG3 tilemap
		LDA #$1801 : STA $4310				;\
		LDA.w #!DecompBuffer : STA $4312		; |
		LDA.w #!DecompBuffer>>8 : STA $4313		; | set up DMA to upload BG3 tilemap
		LDA $0A : STA $4315				; |
		LDA.l .VRAM+8,x : STA $2116			; |
		BRA .Shared					;/
		.NoBG3Tilemap					;\
		LDA #$1808 : STA $4310				; |
		LDA.w #.Some0014 : STA $4312			; |
		LDA.w #.Some0014>>8 : STA $4313			; |
		LDA #$1000 : STA $4315				; | wipe even bytes of BG3 tilemap
		LDA.l .VRAM+8,x : STA $2116			; |
		SEP #$20					; |
		STZ $2115					; |
		LDA #$02 : STA $420B				;/
		LDA #$80 : STA $2115				;\
		REP #$20					; |
		LDA #$1908 : STA $4310				; |
		LDA.w #.Some0014+1 : STA $4312			; | set up DMA to wipe odd bytes of BG3 tilemap
		LDA.w #(.Some0014+1)>>8 : STA $4313		; |
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


		STZ !BigRAM+2					;\
		LDA $06 : BEQ +					; | mark whether files 0x02A and 0x02B can be loaded
		LDA #$8000 : STA !BigRAM+2			; |
		+						;/


	.Loop	INY #2						;\
		LDA [$03],y					; |
		AND #$0FFF					; |
		CMP #$007F : BEQ .NoDecomp			; | files that are not allowed to be decompressed
		CMP #$0001 : BEQ .NoDecomp			; |
		CMP #$0002 : BEQ .NoDecomp			; |
		CMP #$0003 : BEQ .NoDecomp			;/
		BIT !BigRAM+2 : BPL ..allow_bg3			;\
		CMP #$002A : BEQ .NoDecomp			; | in expanded VRAM maps, files 0x02A and 0x02B are ignored
		CMP #$002B : BEQ .NoDecomp			; |
		..allow_bg3					;/
		JSL !DecompressFile				; > decompress
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


		.InitAnim
		STZ $13							; clear both frame counters
		LDA #$1801 : STA $4310					; DMA mode
		LDY.w #!File_DynamicVanilla : JSL GetFileAddress	; get file address
		LDA !FileAddress+2 : STA $4314				; source bank
		..loop							;\
		SEP #$30						; |
		JSL $05BB39						; | get anim data
		REP #$20						; |
		SEP #$10						;/
		LDX #$02						; > X = DMA bit
		LDA $6D7C : BEQ ..1done					;\
		STA $2116						; |
		LDA $6D76						; |
		SEC : SBC #$7D00					; |
		CLC : ADC !FileAddress					; | first block
		STA $4312						; |
		LDA #$0080 : STA $4315					; |
		STX $420B						; |
		..1done							;/
		LDA $6D7E : BEQ ..2done					;\
		STA $2116						; |
		LDA $6D78						; |
		SEC : SBC #$7D00					; |
		CLC : ADC !FileAddress					; | second block
		STA $4312						; |
		LDA #$0080 : STA $4315					; |
		STX $420B						; |
		..2done							;/
		LDA $6D80 : BEQ ..3done					;\
		STA $2116						; |
		LDA $6D7A						; |
		SEC : SBC #$7D00					; |
		CLC : ADC !FileAddress					; | third block
		STA $4312						; |
		LDA #$0080 : STA $4315					; |
		STX $420B						; |
		..3done							;/
		LDX $14
		CPX #$08 : BEQ ..done
		INC $14
		BRA ..loop
		..done

		PLP						; restore P
		RTL						; return

		.Some0014
		dw $0014



; FG1: 0000
; FG2: 0800
; BG1: 1000
; FG3: 1800
; BG2: 2000
; BG3: 2800
; (if enabled)
; LG3: 3000
; LG4: 3800

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
		dw $2000			; UNUSED, here just in case

















