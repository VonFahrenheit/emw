
; bug list:
; 49		- growing pipe (generates weird tiles)




; $02BE4B - this RTL had been replaced somehow, breaking wall followers
;	    keep this in mind if they start crashing the game again



; this table, located at $188250, holds the VRAM mapping for each sublevel
; the values are the following:
; 00 - default mapping
; 01 - expansion mapping:
;	with this enabled, layer 3 is 512x256 instead of 512,512, and can only use the GFX28/GFX29 slots
;	GFX2A/GFX2B are instead used for layer1/2, meaning you have 8 4bpp files to use for level objects and backgrounds
;	note that the level must use map16 remapping in levelcode to be able to make use of these extra graphics
; 02 - mode 2 map:
;	mode 2 is enabled
;	map works the same as map 1, except all layer 3 data is replaced with a 64x64 displacement map

; values 03 and above are currently unused and will default to 00

; $188250
	print "VRAM map mode data stored at $", pc, "."

	;  xx0 xx1 xx2 xx3 xx4 xx5 xx6 xx7 xx8 xx9 xxA xxB xxC xxD xxE xxF
	db $01,$00,$00,$00,$02,$00,$00,$01,$00,$00,$00,$00,$00,$00,$00,$00	; 00x
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; 01x
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; 02x
	db $00,$00,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; 03x
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; 04x
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; 05x
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; 06x
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; 07x
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; 08x
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; 09x
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; 0Ax
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; 0Bx
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; 0Cx
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; 0Dx
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; 0Ex
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; 0Fx
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; 10x
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; 11x
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; 12x
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; 13x
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; 14x
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; 15x
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; 16x
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; 17x
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; 18x
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; 19x
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; 1Ax
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; 1Bx
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; 1Cx
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; 1Dx
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; 1Ex
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; 1Fx



	print "Sprite GFX file table stored at $", pc, "."
; $188450

LoadTable:
; this is which file each sprite corresponds to
; the value here is used as an index to .List above
; offsets 000-0FF are vanilla sprites
; offsets 100-1FF are custom sprites
; a value of 0xFC is another special command that marks both para goomba and para bomb
; a value of 0xFD is a special command for exploding block and does not correspond to a file
; a value of 0xFE means the sprite is included in SP1 and should have its offsets set to 0
; a value of 0xFF means the sprite is dynamic and does not load anything at level init
; note that if value is 0xFF, the super dynamic table will be searched so see if there's a match

	;  --0 --1 --2 --3 --4 --5 --6 --7 --8 --9 --A --B --C --D --E --F
	db $70,$70,$71,$70,$00,$00,$81,$00,$A5,$A5,$A5,$A5,$A5,$01,$02,$03 ; 00-
	db $0A,$1D,$FF,$0D,$0D,$45,$45,$45,$45,$FF,$04,$1E,$05,$0E,$10,$13 ; 01-
	db $13,$FE,$14,$14,$14,$14,$15,$16,$3C,$FF,$04,$33,$FF,$FF,$1F,$07 ; 02-
	db $46,$55,$54,$17,$50,$FF,$FF,$3D,$56,$56,$2D,$2D,$2D,$2E,$08,$8F ; 03-
	db $90,$2F,$2F,$2F,$30,$06,$47,$45,$23,$0F,$FF,$10,$FD,$34,$34,$04 ; 04-
	db $04,$39,$91,$FE,$3E,$25,$26,$25,$26,$FE,$FE,$24,$25,$27,$27,$24 ; 05-
	db $FF,$20,$24,$25,$28,$29,$29,$40,$2A,$FF,$FF,$FE,$FE,$09,$4E,$4F ; 06-
	db $35,$36,$36,$92,$FE,$FE,$06,$FF,$FE,$04,$FF,$FF,$FF,$11,$6B,$6B ; 07-
	db $02,$FF,$FF,$09,$09,$FF,$12,$5C,$FF,$FF,$3B,$FF,$FF,$FF,$FF,$2B ; 08-
	db $93,$47,$47,$47,$47,$47,$FF,$47,$47,$37,$38,$48,$5A,$57,$18,$49 ; 09-
	db $FF,$51,$52,$24,$2C,$59,$41,$FF,$21,$FF,$19,$4A,$42,$42,$58,$0C ; 0A-
	db $3D,$09,$1A,$43,$40,$FF,$1B,$4B,$4B,$FF,$4C,$1C,$44,$00,$22,$4D ; 0B-
	db $26,$09,$31,$32,$24,$3C,$3A,$FF,$FE,$05,$30,$56,$8F,$90,$FC,$2F ; 0C-
	db $2F,$45,$FF,$36,$57,$05,$05,$05,$43,$FF,$5B,$5B,$5B,$5B,$56,$5B ; 0D-
	db $24,$3D,$3D,$3D,$22,$3D,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; 0E-
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; 0F-
	db $FF,$80,$4A,$82,$FF,$83,$FF,$FF,$FF,$A4,$FF,$84,$84,$FF,$FF,$09 ; 10-
	db $FF,$0B,$FF,$00,$00,$FF,$85,$85,$86,$87,$87,$88,$89,$89,$8A,$8A ; 11-
	db $FF,$8C,$8B,$FF,$FF,$FF,$FF,$8D,$FF,$8E,$FF,$05,$A1,$A2,$A3,$24 ; 12-
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; 13-
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; 14-
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; 15-
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; 16-
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; 17-
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; 18-
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; 19-
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; 1A-
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; 1B-
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; 1C-
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; 1D-
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; 1E-
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; 1F-

; $188650

PalsetDefaults:
	db $FF		; pal 8
	db $FF		; pal 9
	db $0A		; pal A
	db $0B		; pal B
	db $0C		; pal C
	db $0D		; pal D
	db $FF		; pal E
	db $FF		; pal F


	!FileMark		= $418200
	!SuperDynamicMark	= $418300


	GFXIndex:

		PHP						; preserve P
		SEP #$30					; all regs 8-bit
		STZ !PalsetA					;\
		STZ !PalsetB					; |
		STZ !PalsetC					; | clear palset regs
		STZ !PalsetD					; |
		STZ !PalsetE					; |
		STZ !PalsetF					;/
		LDA.b #ReadLevelData : STA $3180		;\
		LDA.b #ReadLevelData>>8 : STA $3181		; |
		LDA.b #ReadLevelData>>16 : STA $3182		; | have SA-1 scan level
		JSR $1E80					; |
		PLP						;/
		JSR GetFiles					; upload files
		PHP						;\
		SEP #$20					; |
		LDA !GFX_ReznorFireball : BNE .NoMarioFire	; |
		LDA !MultiPlayer : BEQ +			; |
		LDA !Characters					; |
		AND #$0F : BNE +				; | mario fireball can be included in mario's file
		LDA #$16 : BRA ++				; |
	+	LDA !Characters					; |
		AND #$F0 : BNE .NoMarioFire			; |
		LDA #$06					; |
	++	STA !GFX_ReznorFireball				; |
		LDA #$01 : STA !SuperDynamicMark+$04		; |
		.NoMarioFire					;/

		LDA !MultiPlayer : BEQ +			;\
		LDA !Characters					; |
		AND #$0F					; |
		CMP #$01 : BNE +				; |
		LDA #$1D : BRA ++				; |
	+	LDA !Characters					; | luigi fireball
		AND #$F0					; |
		CMP #$10 : BNE .NoLuigiFire			; |
		LDA #$0D					; |
	++	STA !GFX_LuigiFireball				; |
		LDA #$01 : STA !SuperDynamicMark+$06		; |
		.NoLuigiFire					;/


		LDA !MultiPlayer : BEQ +			;\
		AND #$0F					; |
		CMP #$20 : BNE .NoKadaalSwim			; |
		BRA ++						; |
	+	LDA !Characters					; | super-dynamic kadaal swim frames
		AND #$F0					; |
		CMP #$20 : BNE .NoKadaalSwim			; |
	++	LDA #$01 : STA !SuperDynamicMark+$08		; |
		.NoKadaalSwim					;/






		PLP						;
		JSR SuperDynamicFiles				; upload super-dynamic files
		PHP
		SEP #$30

		LDY #$07					;\
	-	LDA !Palset8,y : BNE +				; |
		LDA #$80 : STA !Palset8,y			; | unused rows are marked 0x80, meaning they are free
		BRA ++						; |
	+	LDA PalsetDefaults,y : BMI ++			; | A-D load their default palsets if they are used
		STA !Palset8,y					; |
	++	DEY						; |
		CPY #$02 : BCS -				;/


		LDA #$00 : STA !GFX_status+$FD			; 0xFD is a command, not a file
		LDA #$00 : STA !GFX_status+$FE			; SP1 sprites should be set to offset 0
		LDA #$E0 : STA !GFX_Dynamic			; dynamic area is the lowest 2 rows of SP4

		LDX #$25					;\
	-	LDA !GFX_status+$5A,x : STA $00			; |
		AND #$0F					; |
		STA $01						; |
		LDA $00						; |
		AND #$70					; |
		ASL A						; |
		ORA $01						; | unpack data for extra files
		STA !Extra_Tiles,x				; |
		LDA $00						; |
		ASL A						; |
		ROL A						; |
		AND #$01					; |
		STA !Extra_Prop,x				; |
		DEX : BPL -					;/

		PLP
		RTS



; file format:
; - header	2 b	size of DMA data (highest 2 bits determine priority)
; - GFX file	2 b	which LM GFX file to use
; - GFX status	1 b	index to GFX status table
; - block count	1 b	how many blocks (8x16px chunks) the file needs
; - DMA data	var	each row has 3 bytes: offset in file, offset in VRAM, and number of 8x8 tiles
; - commands	var	used to include and mark other files, usually only hi prio files have these
; - FF		1 b	signals the end of the file
;
; super-dynamic file format:
; - width	2 b	width encoding of file
; - size	2 b	RAM required (including command-generated images)
; - GFX address	2 b	ExGFX file to load from
; - GFX status	1 b	index to super-dynamic load table
; - chunk count	1 b	how many chunks the file has
; - chunk w	1 b	horizontal size of chunks (/2)
; - chunk h	1 b	vertical size of chunks
; - commands	var	used to scale and rotate chunks
; - FF		1 b	signals the end of the file
;
; 00 - rotate (80 - maintain image width)
; - chunk	1 b	which chunk should be rotated
; - iterations	1 b	how many chunks should be rotated (uses the same angle and copies)
; - angle	1 b	which angle to apply
; - copies	1 b	how many times each rotated chunk should be copied with the rotation applied again
;
; 01 - scale (81 - maintain image width)
; - chunk	1 b	which chunk should be scaled
; - iterations	1 b	how many chunks should be scaled in the same way
; - x scaling	1 b	x scaling
; - y scaling	1 b	y scaling
;
; images generated by commands will simply be placed at the end of the original file




; idea
; i still use the file system, and each sprite is associated with a file
; then i mark a file as "should load" in a RAM table if the corresponding sprite is found in the data
; this way dupes won't cause any issues
; a "file" consists of a dynamo expanded to include source GFX, since the graphics are compressed
; i should order files based on which source GFX they use, to minimize decompression time

;
; there are something like 100 files that are loaded by tileset sprites
; with the global sprites, fusion core sprites and custom sprites added, 256 files in total will probably do
; so i need a RAM table with 256 entries that start off but are toggled on during the scan
; after than, files are loaded until they are all done or sprite VRAM is full
;

; format:
; - header (16-bit, byte count of file information) highest bit is priority, if that is set then this should be uploaded in pass 1
; - source GFX (16-bit)
; - GFX status (8-bit)
; - total size (8-bit, number of 8x16 chunks)
; (repeat the following 3 for each entry)
; - VRAM offset (8-bit, 8x8 tiles)
; - source start (8-bit, 8x8 tile number)
; - size (8-bit, number of 8x8 tiles)
; (ending bytes)
; - a series of commands
;	- $00,$XX,$YY: set status $XX to file offset + $YY
;	- $01,$XX: load extra file $XX during pass 3
;	- $02,$XX: mark super-dynamic file
;	- $FF: end
; hi priority files are uploaded in pass 1 (these have complex shapes and/or include lo priority files)
; lo priority files are uploaded in pass 2 (these have simple shapes and do not include other files)
; support files are uploaded in pass 3
;
;
; processing should go:
; - store size of file information
; - unpack ExGFX
; - start uploading from ..start
; - stop uploading at ..end
;
;

; this is a simple source command, which will upload a 16px tall stripe of variable length (max 128px/16 characters wide)
; it will set one byte in !GFX_status
macro src(GFX, start, width, status)
	dw ..end-..start
	dw <GFX>
	db <status>
	db <width>
	..start
	db $00,<start>,<width>
	db $10,(<start>+$10),<width>
	..end
	db $FF
endmacro

; same as above, but allows commands
; make sure to put db $FF after!!
macro cmd(GFX, start, width, status)
	dw ..end-..start
	dw <GFX>
	db <status>
	db <width>
	..start
	db $00,<start>,<width>
	db $10,(<start>+$10),<width>
	..end
endmacro

; marks another file as included in this one
macro include(GFX, offset)
	db $00
	db <GFX>
	db <offset>
endmacro

; marks another file to be loaded
macro mark(GFX)
	db $01
	db <GFX>
endmacro

; marks a super-dynamic file for loading
macro super(GFX)
	db $02
	db <GFX>
endmacro

; marks a certain palette row for use
macro defaultpal(index)
	db $03
	db $<index>&$07
endmacro



; here, !BigRAM holds information on how many tiles are free on each row
; when a file is uploaded, it is sent to the first area large enough to hold it (no line break allowed)
; this means that large files tend to start at new rows, with small ones filling in the gaps at the end of rows
; offset	location	address
;	0x00	SP2 row 1	$6800
;	0x02	SP2 row 2	$6A00
;	0x04	SP2 row 3	$6C00
;	0x06	SP2 row 4	$6E00
;	0x08	SP3 row 1	$7000
;	0x0A	SP3 row 2	$7200
;	0x0C	SP3 row 3	$7400
;	0x0E	SP3 row 4	$7600
;	0x10	SP4 row 1	$7800
;	0x12	SP4 row 2	$7A00
;	0x14	SP4 row 3	$7C00
;	0x16	SP4 row 4	$7E00

GetFiles:
		REP #$30				; all regs 16-bit
		LDX #$0016				;\
		LDA #$0010				; | clear VRAM allocation table
	-	STA !BigRAM,x				; |
		DEX #2 : BPL -				;/

	.Pass0	LDX #$0000				;\
	..Check	LDA !FileMark,x				; |
		AND #$00FF : BNE ..Load			; |
	..Next	INX					; |
		CPX #$0100 : BCC ..Check		; |
		BRA .Pass1				; |
	..Load	TXA					; |
		ASL A					; |
		CMP #$0100 : BCC ..List1		; |
	..List2	SBC #$0100				; |
		TAY					; | pass 0, signified by both the two highest bit set
		LDA File_List2,y			; | this takes care of files that need to mark hi prio files
		BRA +					; |
	..List1	TAY					; |
		LDA File_List,y				; |
	+	STA $00					; |
		LDY #$0000				; |
		LDA ($00),y				; |
		CMP #$C000 : BCC ..Next			; |
		PEA.w ..Check-1				; |
		JMP .Load				;/

	.Pass1	LDX #$0000				; X = starting index
	..Check	CPX #$005A : BCC +			;\
		CPX #$0080 : BCS +			; | $5A-$7F is reserved for pass 3
		LDX #$0080				;/
	+	LDA !FileMark,x				;\ load marked files
		AND #$00FF : BNE ..Load			;/
	..Next	INX					;\ check all files for pass 1
		CPX #$0100 : BCC ..Check		;/
		BRA .Pass2				; then go to pass 2
	..Load	TXA					;\
		ASL A					; |
		CMP #$0100 : BCC ..List1		; |
	..List2	SBC #$0100				; |
		TAY					; | get pointer from table
		LDA File_List2,y			; |
		BRA +					; |
	..List1	TAY					; |
		LDA File_List,y				; |
	+	STA $00					;/
		LDY #$0000				;\
		LDA ($00),y : BPL ..Next		; | if it's a hi prio file, upload it
		PEA.w ..Check-1				; | otherwise go to the next file
		BRA .Load				;/

	.Pass2	LDX #$0000				; X = starting index
	..Check	CPX #$005A : BCC +			;\
		CPX #$0080 : BCS +			; | $5A-$7F is reserved for pass 3
		LDX #$0080				;/
	+	LDA !FileMark,x				;\ load marked files
		AND #$00FF : BNE ..Load			;/
	..Next	INX					;\ check all files for pass 2
		CPX #$0100 : BCC ..Check		;/
		BRA .Pass3				; finally, go to pass 3
	..Load	TXA					;\
		ASL A					; |
		CMP #$0100 : BCC ..List1		; |
	..List2	SBC #$0100				; |
		TAY					; | get pointer from table
		LDA File_List2,y			; |
		BRA +					; |
	..List1	TAY					; |
		LDA File_List,y				; |
	+	STA $00					;/
		LDY #$0000				;\
		LDA ($00),y : BMI ..Next		; | if it's a lo prio file, upload it
		PEA.w ..Check-1				; | otherwise go to the next file
		BRA .Load				;/

	.Pass3	LDX #$005A				; start at file $5A for pass 3
	..Check	LDA !FileMark,x				;\ load marked files
		AND #$00FF : BNE ..Load			;/
	..Next	INX					;\ check files $5A-$7F for pass 3
		CPX #$0080 : BCC ..Check		;/
		RTS					; then return
	..Load	TXA					;\
		ASL A					; |
	..List1	TAY					; | get pointer from table
		LDA File_List,y : STA $00		; |
		LDY #$0000				; |
		LDA ($00),y				;/
		PEA.w ..Check-1				; set return address, then load (file prio does not matter in pass 3)


	.Load	AND #$3FFF : BNE +			; see if this is a file...
		LDA $00					;\
		CLC : ADC #$0006			; |
		STA $00					; |
		LDA #$0000				; | if file size is 0, just set the GFX status flags
		SEP #$20				; |
		LDY #$0000				; |
		JMP .LoadFlags				;/

	+	PHA					; push file size
		INY #2					;\ get LM file number
		LDA ($00),y				;/
		PEI ($00)				; push pointer
		LDY.w #!DecompBuffer : STY $00		;\ decompression buffer pointer
		LDY.w #!DecompBuffer>>8 : STY $01	;/
		PHX					;\
		PHP					; |
		SEP #$10				; | wrapped decompress
		JSL $0FF900				; | (maintain processor and X)
		PLP					; |
		PLX					;/
		PLA					;\
	++	CLC : ADC #$0004			; | get pointer to tile information
		STA $00					;/
		PLA : STA $0E				; $0E = file information size

		LDY #$0000				;\
		LDA ($00),y				; | $06 = GFX status info
		AND #$00FF				; |
		STA $06					;/
		INY					;\
		LDA ($00),y				; | $08 = total number of 8x16px blocks used
		AND #$00FF				; |
		STA $08					;/
		INC $00					;\ increment pointer
		INC $00					;/ (Y stays at 1)
		LDY #$0000

; use of scratch RAM, 16-bit regs
; $00: pointer to file information
; $02: starting VRAM of file
; $04: 
; $06: GFX status offset
; $08: total number of 8x16 blocks used
; $0A: number of rows needed (used for big files)
; $0C: starting tile of tile (PYYYXXXX format)
; $0E: size of file information, used for loop



		PHX					; push X
		LDX #$0000				; index
		LDA $08					; number of 8x16 blocks required
		CMP #$0011 : BCC .small

		.big
		LSR #4					;\
		AND #$000F				; |
		TAY					; | Y = number of full rows needed
		LDA $08					; |
		AND #$000F				; |
		BEQ $01 : INY				;/
		STY $0A					; store to $0A
	-	LDA !BigRAM,x				;\
		CMP #$0010 : BEQ +			; | look for an empty row to start at
		INX #2					; |
		CPX #$0018 : BCC -			;/
		PLX					;\
		INX					; | if there's not enough space, go to next file
		RTS					;/

	+	LDA .VRAM,x : STA $02			; preliminary starting VRAM
		CPX #$0008 : BCS .SP34

	.SP2	TXA					;\
		SEC : SBC #$0008			; | number of rows free in SP2
		EOR #$FFFF : INC A			; |
		LSR A					;/
		CMP $0A : BCS .mark			; compare to number of rows required
		LDX #$0008				;\ if there's not enough room, check next page
		BRA -					;/

	.SP34	TXA					;\
		SEC : SBC #$0018			; | number of rows free on second page
		EOR #$FFFF : INC A			; |
		LSR A					;/
		CMP $0A : BCS .mark			; compare to number of rows required
		PLX					;\
		INX					; | if there's no space, go to next file
		RTS					;/


		.small
	-	CMP !BigRAM,x				;\
		BEQ +					; |
		BCC +					; | look for a row with an equal or greater number of free tiles
		INX #2					; |
		CPX #$0018 : BCC -			;/
		PLX					;\
		INX					; | if none are found, go to the next file
		RTS					;/
	+	LDA #$0010				;\
		SEC : SBC !BigRAM,x			; |
		ASL #4					; | starting dest VRAM
		CLC : ADC .VRAM,x			; | (*16 instead of *32 because word address)
		STA $02					;/

		.mark
		LDA $02
		AND #$00F0				;\
		LSR #4					; |
		STA $0C					; |
		LDA $02					; | starting tile number of file (PYYYXXXX format)
		AND #$1E00				; |
		LSR #5					; |
		TSB $0C					;/

		LDA $08					;\
	-	CMP #$0010 : BCC +			; |
		SBC #$0010				; | loop through full rows
		STZ !BigRAM,x				; |
		INX #2					; |
		DEY : BNE -				;/
	+	SEC : SBC !BigRAM,x			;\
		EOR #$FFFF : INC A			; | update free tiles remaining on current row
		STA !BigRAM,x				;/
		PLX					; restore X
		LDY #$0000				; Y = starting index to file information


	.Upload	LDA ($00),y				;\
		AND #$00FF				; |
		ASL #4					; | dest VRAM
		CLC : ADC $02				; |
		STA $2116				;/
		INY					;\
		LDA ($00),y				; |
		AND #$00FF				; |
		XBA					; | source address
		LSR #3					; |
		CLC : ADC.w #!DecompBuffer		; |
		STA $4302				;/
		INY					;\
		LDA ($00),y				; |
		AND #$00FF				; | upload size
		XBA					; |
		LSR #3					; |
		STA $4305				;/
		LDA #$1801 : STA $4300			; DMA parameters
		INY					; > update index

		SEP #$20				;\
		LDA.b #!DecompBuffer>>16 : STA $4304	; |
		LDA #$80 : STA $2115			; | finish DMA after setting source bank and video port
		LDA #$01 : STA $420B			; |
		REP #$20				;/
		CPY $0E : BCC .Upload			; loop through upload stripes

	; GFX status
		LDA #$0000				; clear B
		SEP #$20				; A 8-bit
		PHX					;\
		LDA $06 : TAX				; |
		LDA $0C : STA !GFX_status,x		; | set main GFX status
		LDA #$00 : STA !FileMark,x		; > don't reload this
		PLX					;/

		.LoadFlags
		LDA ($00),y : BEQ .Include		;\
		CMP #$01 : BEQ .Mark			; | determine command code
		CMP #$02 : BEQ .SuperDynamic		; |
		CMP #$03 : BEQ .DefaultPal		; |
		CMP #$FF : BEQ .Done			;/
		BRA .Done				; > don't accept garbage values

		.DefaultPal
		PHX					;\
		INY					; |
		LDA ($00),y				; |
		CMP #$07				; |
		BCC $02 : LDA #$00			; | mark selected palset as used
		TAX					; |
		LDA #$01 : STA !Palset8,x		; |
		INY					; |
		PLX					; |
		BRA .LoadFlags				;/

		.Mark					;\
		PHX					; |
		INY					; |
		LDA ($00),y : TAX			; | mark file for loading, then loop
		LDA #$01 : STA !FileMark,x		; |
		INY					; |
		PLX					; |
		BRA .LoadFlags				;/

		.Include				;\
		PHX					; |
		INY					; |
		LDA ($00),y : TAX			; |
		INY					; | mark file as included
		LDA ($00),y				; |
		CLC : ADC $0C				; |
		STA !GFX_status,x			; |
		LDA #$00 : STA !FileMark,x		; > don't reload this
		INY					; |
		PLX					;/
		BRA .LoadFlags				; loop until 0xFF is found

		.SuperDynamic				;\
		PHX					; |
		INY					; |
		LDA ($00),y : TAX			; | mark super dynamic file for loading, then loop
		LDA #$01 : STA !SuperDynamicMark,x	; |
		INY					; |
		PLX					; |
		BRA .LoadFlags				;/

	.Done
		REP #$30
		INX
		RTS					; go to next file


; starting address of each row
.VRAM	dw $6800
	dw $6A00
	dw $6C00
	dw $6E00
	dw $7000
	dw $7200
	dw $7400
	dw $7600
	dw $7800
	dw $7A00
	dw $7C00
	dw $7E00



; note that these correspond to GFX status offsets
File:
.List
	dw .KoopaGreenRedYellow	; 00
	dw .BobOmb		; 01
	dw .Key			; 02
	dw .Goomba		; 03
	dw .PiranhaPlant	; 04
	dw .BulletBill		; 05
	dw .Starman		; 06
	dw .SpringBoard		; 07
	dw .PSwitch		; 08
	dw .Blocks		; 09
	dw .ParaGoomba		; 0A
	dw .Sign		; 0B
	dw .BooBlock		; 0C
	dw .Spiny		; 0D
	dw .HoppingFlame	; 0E
	dw .GrowingPipe		; 0F
	dw .Lakitu		; 10
	dw .PBalloon		; 11
	dw .Wiggler		; 12
	dw .Magikoopa		; 13
	dw .NetKoopa		; 14
	dw .Thwomp		; 15
	dw .Thwimp		; 16
	dw .Podoboo		; 17
	dw .BallAndChain	; 18
	dw .FishBone		; 19
	dw .FallingSpike	; 1A
	dw .BouncingPodoboo	; 1B
	dw .MovingBlock		; 1C
	dw .BuzzyBeetle		; 1D
	dw .Football		; 1E
	dw .SpikeTop		; 1F
	dw .FloatingSkulls	; 20
	dw .Blargg		; 21
	dw .SwooperBat		; 22
	dw .ChuckRock		; 23
	dw .BrownGreyPlat	; 24
	dw .CheckerPlat		; 25
	dw .RockPlat		; 26
	dw .OrangePlat		; 27
	dw .Rope		; 28
	dw .Chainsaw		; 29
	dw .Fuzzy		; 2A
	dw .ScalePlat		; 2B
	dw .SpikeBall		; 2C
	dw .Urchin		; 2D
	dw .RipVanFish		; 2E
	dw .Dolphin		; 2F
	dw .TorpedoTed		; 30
	dw .BlurpFish		; 31
	dw .PorcuPuffer		; 32
	dw .SumoLightning	; 33
	dw .MontyMole		; 34
	dw .Pokey		; 35
	dw .SuperKoopa		; 36
	dw .VolcanoLotus	; 37
	dw .SumoBro		; 38
	dw .Ninji		; 39
	dw .Spotlight		; 3A
	dw .SmallBird		; 3B
	dw .BigBoo		; 3C
	dw .Boo			; 3D
	dw .ClimbingDoor	; 3E
	dw .CastlePlat		; 3F
	dw .Grinder		; 40
	dw .HotHead		; 41
	dw .WoodenSpike		; 42
	dw .StatueFireball	; 43
	dw .BowserStatue	; 44
	dw .Fish		; 45
	dw .DryBones1		; 46
	dw .Chuck		; 47
	dw .AmazingHammerBro	; 48
	dw .BanzaiBill		; 49
	dw .Rex			; 4A
	dw .CarrotPlat		; 4B
	dw .TimerPlat		; 4C
	dw .MegaMole		; 4D
	dw .DinoRhino		; 4E
	dw .DinoTorch		; 4F
	dw .BossFireball	; 50
	dw .BowlingBall		; 51
	dw .MechaKoopa		; 52
	dw .Reznor		; 53
	dw .DryBones2		; 54
	dw .BonyBeetle		; 55
	dw .Eerie		; 56
	dw .CarrierBubble	; 57
	dw .FishingBoo		; 58
	dw .Sparky		; 59


	; support files start at index 0x5A
	dw .Wings		; 5A (no file)
	dw .Shell		; 5B (no file)
	dw .LakituCloud		; 5C (no file)
	dw .Hammer		; 5D (marks VRAM location of super-dynamic hammer tile)
	dw .SmallFireball	; 5E
	dw .ReznorFireball	; 5F
	dw .LotusPollen		; 60
	dw .Baseball		; 61
	dw .WaterEffects	; 62 \ these should probably be marked by special sprites
	dw .LavaEffects		; 63 / scanning the entire map16 might be too slow
	dw .SkeletonRubble	; 64
	dw .Bone		; 65
	dw .PlantStalk		; 66
	dw .BombStar		; 67
	dw .Parachute		; 68
	dw .Mechanism		; 69
	dw .DinoFire		; 6A
	dw .AngelWings		; 6B
	dw .RexLegs1		; 6C (no file)
	dw .RexLegs2		; 6D (no file)
	dw .RexSmall		; 6E (no file)
	dw .LuigiFireball	; 6F (no file)
	dw .ShellessKoopa	; 70 (no file)
	dw .KickerKoopa		; 71 (no file)
	dw .SmushedKoopa	; 72 (no file)



; the following have been excluded because they should always be loaded:
; - smoke puff
; - small star
; - brick piece
; - sparkle
; - contact


	.List2
	; custom sprites start at 0x80
	dw .GoombaSlave		; 80
	dw .KoopaBlue		; 81
	dw .HammerRex		; 82
	dw .NoviceShaman	; 83
	dw .MagicMole		; 84
	dw .Thif		; 85
	dw .KompositeKoopa	; 86
	dw .Birdo		; 87
	dw .Bumper		; 88
	dw .Monkey		; 89
	dw .TerrainPlat		; 8A
	dw .YoshiCoin		; 8B
	dw .CoinGolem		; 8C
	dw .BooHoo		; 8D
	dw .FlamePillar		; 8E
	dw .ParachuteGoomba	; 8F
	dw .ParachuteBobomb	; 90
	dw .MovingLedge		; 91
	dw .SuperKoopa2		; 92 (also loads normal koopa)
	dw .GasBubble		; 93
	dw .RexHat1		; 94
	dw .RexHat2		; 95
	dw .RexHat3		; 96
	dw .RexHat4		; 97
	dw .RexHat5		; 98
	dw .RexHat6		; 99
	dw .RexHat7		; 9A
	dw .RexHelmet		; 9B
	dw .RexBag1		; 9C
	dw .RexBag2		; 9D
	dw .RexBag3		; 9E
	dw .RexBag4		; 9F
	dw .RexSword		; A0
	dw .FlyingRex		; A1
	dw .UltraFuzzy		; A2
	dw .Shield		; A3
	dw .TarCreeperHands	; A4
	dw .ParaKoopa		; A5


;=============================;
; -- vanillla sprite files -- ;
;=============================;

.KoopaGreenRedYellow
dw ..end-..start|$8000	; hi prio file
dw $F00
db $00
db $10			; 1 full row
..start
db $00,$00,$20
..end
%mark($5B)		; load shell
%mark($70)		; load shelless koopa
db $FF

.KoopaBlue
dw ..end-..start|$8000	; hi prio file
dw $F00
db $00
db $10			; 1 full row
..start
db $00,$00,$20
..end
%mark($5B)		; load shell
%mark($71)		; load kicker koopa
db $FF

.ParaKoopa
dw ..end-..start|$8000	; hi prio file
dw $F00
db $00
db $10			; 1 full row
..start
db $00,$00,$20
..end
%mark($5A)		; load wings
%mark($5B)		; load shell
%mark($70)		; load shelless koopa
db $FF





; 00-0F
; 00
.BobOmb
dw ..end-..start	; lo prio file
dw $F01
db $01
db $04
..start
db $00,$00,$04
db $10,$10,$04
..end
%mark($67)	; mark bomb star
db $FF

.Key		%src($F02, $00, $04, $02)

.Goomba		%cmd($F03, $00, $08, $03)
		%super($05)
		db $FF

.PiranhaPlant	; lo prio file
dw ..end-..start
dw $F04
db $04
db $06		; plant needs an empty 8x8 tile for its tilemap
..start
db $00,$00,$06
db $10,$10,$06
..end
%mark($66)	; load plant stalk
%mark($5E)	; small fireball
db $FF


.BulletBill	%src($F05, $00, $08, $05)
.Starman	%cmd($F06, $00, $02, $06)
		%defaultpal(A)
		%defaultpal(C)
		db $FF
.SpringBoard	%src($F07, $00, $02, $07)
.PSwitch	%src($F08, $00, $03, $08)

.Blocks
dw ..end-..start	; lo prio file
dw $F09
db $09
db $02
..start
db $00,$00,$02
db $10,$10,$02
..end
%mark($6B)		; load angel wings
db $FF


.ParaGoomba
dw ..end-..start	; lo prio file
dw $F03
db $0A
db $04
..start
db $00,$00,$04
db $10,$10,$04
..end
%mark($6B)		; mark angel wings
db $FF

.Sign		%src($F0B, $00, $02, $0B)

.BooBlock
dw ..end-..start|$8000	; hi prio file
dw $F0C
db $0C
db $10
..start
db $00,$00,$20	; 32 tiles 0x00-0x1F
..end
%include($3D, $00)	; includes boo at offset 0x00
db $FF

.Spiny		%src($F0D, $00, $08, $0D)
.HoppingFlame	%src($F0E, $00, $05, $0E)
.GrowingPipe	%src($F0F, $00, $04, $0F)

; 10-1F
.Lakitu
dw ..end-..start|$8000	; hi prio file
dw $F10
db $10			; GFX status offset
db $0B			; 11 blocks
..start
db $00,$00,$0B		; 11 tiles 0x00-0x0A
db $10,$10,$0B		; 11 tiles 0x10-0x1A
..end
%mark($0D)		; mark spiny
%include($5C, $08)	; cloud is included as tile 0x08
db $FF

.PBalloon	%src($F11, $00, $02, $11)
.Wiggler	%src($F12, $00, $09, $12)
.Magikoopa	%src($F13, $00, $0C, $13)
.NetKoopa	%src($F14, $00, $0C, $14)
.Thwomp		%src($F15, $00, $08, $15)
.Thwimp		%src($F16, $00, $01, $16)

.Podoboo
dw ..end-..start	; lo prio file
dw $F17
db $17
db $02
..start
db $00,$00,$02
db $10,$10,$02
..end
%mark($63)		; lava effects should be loaded with fireball
db $FF

.BallAndChain	%src($F18, $00, $04, $18)
.FishBone	%src($F19, $00, $05, $19)
.FallingSpike	%src($F1A, $00, $02, $1A)
.BouncingPodoboo	%src($F1B, $00, $02, $1B)
.MovingBlock	%src($F1C, $00, $08, $1C)
.BuzzyBeetle	%src($F1D, $00, $0A, $1D)
.Football	%src($F1E, $00, $02, $1E)
.SpikeTop	%src($F1F, $00, $0C, $1F)


; 20-2F
.FloatingSkulls	%src($F20, $00, $04, $20)

.Blargg
dw ..end-..start
dw $F21
db $21
db $10
..start
db $00,$00,$10
db $10,$10,$10
..end
%mark($63)	; mark lava effects
db $FF


.SwooperBat	%src($F22, $00, $06, $22)
.ChuckRock	%src($F23, $00, $04, $23)
.BrownGreyPlat	%src($F24, $00, $06, $24)
.CheckerPlat	%src($F25, $00, $04, $25)
.RockPlat	%src($F26, $00, $05, $26)
.OrangePlat	%src($F27, $00, $06, $27)

.Rope
dw ..end-..start
dw $F28
db $28
db $04
..start
db $00,$00,$04
db $10,$10,$04
..end
%mark($69)	; include mechanism
db $FF

.Chainsaw
dw ..end-..start
dw $F29
db $29
db $04
..start
db $00,$00,$04
db $10,$10,$04
..end
%mark($69)	; include mechanism
db $FF

.Fuzzy		%src($F2A, $00, $02, $2A)
.ScalePlat	%src($F2B, $00, $02, $2B)
.SpikeBall	%src($F2C, $00, $04, $2C)
.Urchin		%src($F2D, $00, $0A, $2D)
.RipVanFish	%src($F2E, $00, $0A, $2E)
.Dolphin	%src($F2F, $00, $0E, $2F)

; 30-3F
.TorpedoTed	%src($F30, $00, $0A, $30)
.BlurpFish	%src($F31, $00, $04, $31)
.PorcuPuffer	%src($F32, $00, $0A, $32)

.SumoLightning
dw ..end-..start	; lo prio file
dw $F33
db $33
db $01
..start
db $00,$00,$01
db $10,$10,$01
..end
%mark($8E)		; load flame pillar
db $FF

.MontyMole	%src($F34, $00, $0A, $34)
.Pokey		%src($F35, $00, $04, $35)
.SuperKoopa	%src($F36, $00, $0A, $36)	; not done

.VolcanoLotus
dw ..end-..start
dw $F37
db $37
db $06
..start
db $00,$00,$06
db $10,$10,$06
..end
%mark($60)	; load lotus pollen
db $FF

.SumoBro
dw ..end-..start|$8000	; hi prio file
dw $F38
db $38
db $13			; 1 row + 2 tiles
..start
db $00,$00,$23		; 35 tiles 0x00-0x22
db $30,$30,$03		; 3 tiles 0x30-0x32
..end
%mark($33)	; mark sumo lightning
%mark($8E)	; mark flame pillar
db $FF

.Ninji		%src($F39, $00, $04, $39)
.Spotlight	%src($F3A, $00, $10, $3A)
.SmallBird	%src($F3B, $00, $03, $3B)

.BigBoo			; not done
dw ..end-..start|$8000	; hi prio file
dw $F3C
db $3C
db $22
..start
db $00,$00,$42		; 66 tiles 0x00-0x41
db $50,$50,$02		; 2 tiles 0x50-0x51
..end
%include($93, $00)	; gas bubble uses big boo's file
db $FF

.Boo		%src($F3D, $00, $0C, $3D)
.ClimbingDoor	%src($F3E, $00, $10, $3E)
.CastlePlat	%src($F3F, $00, $06, $3F)

; 40-4F
.Grinder	%src($F40, $00, $04, $40)
.HotHead	%src($F41, $00, $05, $41)
.WoodenSpike	%src($F42, $00, $04, $42)
.StatueFireball	%src($F43, $00, $02, $43)

.BowserStatue
dw ..end-..start|$8000	; hi prio file
dw $F44
db $44
db $07
..start
db $00,$00,$07
db $10,$10,$07
..end
%mark($43)	; load statue fireball
db $FF

.Fish		%src($F45, $00, $08, $45)
; unused slot

.Chuck
dw ..end-..start|$8000	; hi prio file
dw $F47
db $47	; status offset 0x47
db $38	; 0x39 blocks
..start
db $00,$00,$68	; 103 tiles 0x00-0x67
db $70,$70,$08	; 7 tiles 0x70-0x77
..end
%mark($1E)		; load football
%mark($23)		; load rock
%mark($61)		; load super dynamic dynamic baseball
%super($07)		; super dynamic baseball
db $FF

.AmazingHammerBro
dw ..end-..start|$8000	; hi prio file
dw $F48
db $48
db $05
..start
db $00,$00,$05
db $10,$10,$05
..end
%mark($5D)		; load hammer
db $FF

.BanzaiBill
dw ..end-..start|$8000	; hi prio file
dw $F49
db $49
db $28
..start
db $00,$00,$28
db $30,$30,$08
..end
db $FF

.Rex
dw ..end-..start|$8000	; hi prio file
dw $F4A
db $4A
db $02			; 2 blocks
..start
db $00,$00,$02		; 2 tiles 0x00-0x01
db $10,$10,$02		; 2 tiles 0x10-0x11
..end
%mark($6E)	; load small rex form (legs are handled by level scanner)
db $FF

.CarrotPlat	%src($F4B, $00, $06, $4B)
.TimerPlat	%src($F4C, $00, $04, $4C)
.MegaMole	%src($F4D, $00, $10, $4D)

.DinoRhino
dw ..end-..start|$8000	; hi prio file
dw $F4E
db $4E
db $2A
..start
db $00,$00,$2A
db $30,$30,$0A
..end
%mark($4F)	; load dino torch
%mark($6A)	; load dino fire
db $FF

.DinoTorch
dw ..end-..start	; lo prio file
dw $F4F
db $4F
db $0A
..start
db $00,$00,$0A
db $10,$10,$0A
..end
%mark($6A)	; load dino fire
db $FF



; 50-5F
.BossFireball	%src($F50, $00, $08, $50)
.BowlingBall	%src($F51, $00, $0A, $51)
.MechaKoopa	%src($F52, $00, $10, $52)

.Reznor
dw ..end-..start|$8000	; hi prio file
dw $F53
db $53
db $20
..start
db $00,$00,$40
..end
%mark($5F)		; mark reznor fireball for loadin
db $FF

.DryBones1
dw ..end-..start|$8000	; hi prio file
dw $F54
db $46
db $08
..start
db $00,$00,$08
db $10,$10,$08
..end
%include($54, $00)	; includes file 0x54 at offset 0x00 blocks
%mark($64)		; mark skeleton rubble for loading
%mark($65)		; mark bone for loading
db $FF

.DryBones2
dw ..end-..start	; lo prio file
dw $F54
db $54
db $08
..start
db $00,$00,$08
db $10,$10,$08
..end
%mark($64)		; mark skeleton rubble for loading
db $FF

.BonyBeetle
dw ..end-..start	; lo prio file
dw $F55
db $55
db $08
..start
db $00,$00,$08
db $10,$10,$08
..end
%mark($64)		; mark skeleton rubble for loading
db $FF


.Eerie		%src($F56, $00, $04, $56)

.CarrierBubble
dw ..end-..start|$8000	; hi prio file
dw $F57
db $57
db $03
..start
db $00,$00,$03
db $10,$10,$03
..end
%mark($01)	; load bobomb
%mark($03)	; load goomba
%mark($45)	; load fish
db $FF

.FishingBoo	%src($F58, $00, $0A, $58)
.Sparky		%src($F59, $00, $02, $59)




;===================;
; -- extra files -- ;
;===================;

.Wings		%cmd($F00, $48, $06, $5A)
		%defaultpal(D)
		db $FF

.Shell		%src($F00, $42, $06, $5B)
.LakituCloud	%src($F10, $08, $01, $5C)

.Hammer		%cmd($F5D, $00, $02, $5D)
		%defaultpal(B)
		%super($00)
		db $FF

.SmallFireball	%cmd($F5E, $00, $01, $5E)
		%defaultpal(C)
		%super($03)
		db $FF

.ReznorFireball	%cmd($F5F, $00, $02, $5F)
		%defaultpal(C)
		%super($04)
		db $FF

.LotusPollen	%cmd($F60, $00, $01, $60)
		%defaultpal(C)
		db $FF

.Baseball	%cmd($F61, $00, $01, $61)
		%defaultpal(C)
		%super($07)
		db $FF
.WaterEffects	%src($F62, $00, $05, $62)
.LavaEffects	%cmd($F63, $00, $02, $63)
		%defaultpal(C)
		db $FF

.SkeletonRubble	%src($F64, $00, $06, $64)

.Bone		%cmd($F65, $00, $04, $65)	; first tile is super-dynamic, second is static and used by dry bones tilemap
		%super($02)
		db $FF

.PlantStalk	%cmd($F66, $00, $02, $66)
		%defaultpal(D)
		db $FF

.BombStar	%src($F67, $00, $01, $67)

.Parachute	%cmd($F68, $00, $04, $68)
		%defaultpal(B)
		db $FF

.Mechanism	%cmd($F69, $00, $06, $69)
		%defaultpal(B)
		db $FF

.DinoFire	%cmd($F6A, $00, $10, $6A)
		%defaultpal(A)
		%defaultpal(C)
		db $FF

.AngelWings	%cmd($F6B, $00, $03, $6B)
		%defaultpal(B)
		db $FF

.RexLegs1	%src($F4A, $40, $09, $6C)	; normal
.RexLegs2	%src($F4A, $07, $09, $6D)	; holding bag
.RexSmall	%src($F4A, $20, $0B, $6E)	; small form


.LuigiFireball	; no file

.ShellessKoopa	%cmd($F00, $20, $08, $70)
		%mark($72)			; load smushed koopa
		db $FF
.KickerKoopa	%cmd($F00, $28, $08, $71)
		%mark($72)			; load smushed koopa
		%defaultpal(B)
		db $FF
.SmushedKoopa	%src($F00, $40, $02, $72)



;===========================;
; -- custom sprite files -- ;
;===========================;

.GoombaSlave
dw ..end-..start|$8000	; hi prio file
dw $F80
db $80
db $14
..start
db $00,$00,$24
db $30,$30,$04
..end
db $FF

.VillagerRex


.HammerRex
dw ..end-..start|$8000	; hi prio file
dw $F82
db $82
db $1F		; 31 blocks
..start
db $00,$00,$2F	; 47 tiles 0x00-0x2E
db $30,$30,$0F	; 15 tiles 0x30-0x3E
..end
%mark($6E)	; load small rex
%mark($5D)	; load hammer
db $FF

.NoviceShaman
dw ..end-..start|$8000	; hi prio file
dw $F83
db $83
db $35
..start
db $00,$00,$65
db $70,$70,$05
..end
db $FF

.MagicMole
dw ..end-..start|$8000	; hi prio file
dw $F84
db $84
db $20
..start
db $00,$00,$40
..end
db $FF

.Thif		%src($F85, $00, $10, $85)
.KompositeKoopa	%src($F86, $00, $06, $86)
.Birdo		%src($F87, $00, $10, $87)
.Bumper		%src($F88, $02, $02, $88)	; slime version

.Monkey
dw ..end-..start|$8000	; hi prio file
dw $F89
db $89
db $26
..start
db $00,$00,$46
db $50,$50,$06
..end
db $FF

.TerrainPlat	%src($F8A, $00, $0E, $8A)
.YoshiCoin	%src($F8B, $00, $04, $8B)

.CoinGolem
dw ..end-..start|$8000	; hi prio file
dw $F8C
db $8C
db $10
..start
db $00,$00,$20
..end
%include($8B, $00)	; include yoshi coin in this file (offset 0x00)
db $FF

.BooHoo		%src($F8D, $00, $10, $8D)
.FlamePillar	%src($F8E, $00, $04, $8E)

.ParachuteGoomba
dw ..end-..start|$8000
dw $F8F
db $8F
db $04
..start
db $00,$00,$04
db $10,$10,$04
..end
%mark($03)	; mark goomba
%mark($68)	; mark parachute
db $FF

.ParachuteBobomb
dw ..end-..start|$8000
dw $F90
db $90
db $04
..start
db $00,$00,$04
db $10,$10,$04
..end
%mark($01)	; mark bobomb
%mark($67)	; mark bomb star
%mark($68)	; mark parachute
db $FF

.MovingLedge	%src($F91, $00, $03, $91)

.SuperKoopa2
dw ..end-..start|$C000	; MAX prio file
dw $F36
db $92
db $0A
..start
db $00,$00,$0A
db $10,$10,$0A
..end
%include($36, $00)	; this is the same as the super koopa file
%mark($71)		; load kicker koopa
db $FF

.GasBubble
dw ..end-..start	; lo prio file
dw $F3C
db $93
db $10
..start
db $00,$00,$20
..end
db $FF

.RexHat1	%cmd($F4A, $60, $02, $94)	; robin hood cap
		%defaultpal(D)
		db $FF
.RexHat2	%cmd($F4A, $62, $02, $95)	; bow hat
		%defaultpal(C)
		db $FF
.RexHat3	%src($F4A, $64, $02, $96)	; sun hat
.RexHat4	%cmd($F4A, $66, $02, $97)	; fezlike
		%defaultpal(C)
		db $FF
.RexHat5	%src($F4A, $68, $02, $98)	; bandit bandana
.RexHat6	%cmd($F4A, $49, $04, $99)	; top hat + mustache
		%defaultpal(C)
		db $FF
.RexHat7	%src($F4A, $2B, $02, $9A)	; bandana
.RexHelmet	%src($F4A, $02, $02, $9B)	; helmet
.RexBag1	%src($F4A, $2D, $03, $9C)	; sack
.RexBag2	%cmd($F4A, $4D, $03, $9D)	; food bag on stick
		%defaultpal(C)
		db $FF
.RexBag3	%src($F4A, $6A, $03, $9E)	; back pack
.RexBag4	%src($F4A, $6D, $03, $9F)	; box held in front
.RexSword	%src($F4A, $04, $03, $A0)	; sword + wings

.FlyingRex
dw ..end-..start|$8000	; hi prio file
dw $FA1
db $A1
db $20
..start
db $00,$00,$40
..end
%mark($6E)	; load small rex
db $FF

.UltraFuzzy	%src($FA2, $00, $08, $A2)
.Shield		%src($FA3, $00, $04, $A3)


.TarCreeperHands
dw ..end-..start|$8000	; hi prio file
dw $FA4
db $A4
db $1A
..start
db $00,$00,$2A
db $30,$30,$0A
..end



; $00 - acts like 00-3F pointer (lo byte)
; $03 - acts like 00-3F pointer (hi byte)
; $06 - acts like 40-7F pointer (lo byte)		\ we're actually using base $0000 for these because it makes the index calculation simpler
; $09 - acts like 40-7F pointer (hi byte)		/ (shoutout to lunar magic for actually doing something clever)
; $0C - scratch
; $0D - scratch
; $0E - scratch
; $0F - scratch

ReadLevelData:
		PHB
		PHP
		REP #$10
		SEP #$20
		LDA.b #!FileMark>>16 : PHA : PLB	; switch banks
		LDX #$02FF				;\ (also clear GFX status, nothin personell kid)
	-	STZ.w !GFX_status,x			; | wipe all files from queue
		DEX : BPL -				;/ (including super-dynamic)

		REP #$20
		LDA.l !Map16ActsLike : STA $00		;\ acts like pointer 00-3F block (lo byte)
		LDA.l !Map16ActsLike+1 : STA $01	;/
		STA $04					; store bank of hi byte pointer
		LDA.l !Map16ActsLike			;\
		INC A					; | acts like pointer 00-3F block (hi byte)
		STA $03					;/
		LDA.l !Map16ActsLike40 : STA $06	;\
		LDA.l !Map16ActsLike40+1		; | acts like pointer 40-7F block (lo byte)
	;	ORA #$0080				; |
		STA $07					;/
		STA $0A					; store bank of hi byte pointer
		LDA.l !Map16ActsLike40			;\
	;	ORA #$8000				; | acts like pointer 40-7F block (hi byte)
		INC A					; |
		STA $09					;/

		SEP #$20
		LDA #$00 : STA.l !BigRAM		; clear brick flag
		LDX #$0000
	.TileLoop
		LDA $40C800,x				;\
		ASL A					; |
		STA $0E					; |
		LDA $C800,x				; |
		ROL A					; |
		STA $0F					; |
		BMI ..40				; |
	..00	LDY $0E					; | scan map16 data for spawnables
		LDA [$03],y : BEQ +			; |
		LDA [$00],y : BRA .Page1		; |
	+	LDA [$00],y : BRA .Page0		; |
	..40	LDY $0E					; |
		LDA [$09],y : BEQ +			; |
		LDA [$06],y : BRA .Page1		; |
	+	LDA [$06],y				; |
	.Page0	CMP #$04 : BCS ..nowater		; |
		LDA #$01 : STA.w !FileMark+$62		; > mark water effects for loading
		..nowater				; |
		JMP .NextTile				;/

	.Page1	CMP #$14 : BCC ..noblock
		CMP #$40 : BEQ ..block
		CMP #$29 : BCS ..noblock
	..block	XBA
		LDA #$01 : STA.l !PalsetA		; always load palset A if there are blocks
		XBA
		..noblock
		PHA
		CMP #$17 : BEQ ..pal			;\
		CMP #$18 : BEQ ..pal			; | mush/flower blocks load red and green
		CMP #$1F : BEQ ..pal			; |
		CMP #$20 : BEQ ..pal			;/
		CMP #$27 : BEQ ..palG			;\ shell blocks load green
		CMP #$28 : BEQ ..palG			;/
		CMP #$2A : BNE ..notpal			; mush/flower block loads red and green
	..pal	LDA #$01 : STA.l !PalsetC
	..palG	LDA #$01 : STA.l !PalsetD
		..notpal
		PLA
		CMP #$19 : BNE ..notstar		;
		..starman
		LDA #$01 : STA.w !FileMark+$06		; > starman
		JMP .NextTile
		..notstar
		CMP #$1A : BNE ..nomulti
		TXA
		AND #$0F
	-	CMP #$03 : BCC +
		SBC #$03 : BRA -
	+	CMP #$01 : BEQ .NextTile		; 1-up doesn't need to be loaded
		CMP #$00 : BEQ ..starman
		LDA #$01 : STA.w !FileMark+$04		; > piranha plant
		BRA .NextTile				;
		..nomulti
		CMP #$1D : BNE ..nopswitch
		LDA #$01 : STA.w !FileMark+$08		; > p-switch
		BRA .NextTile
		..nopswitch
		CMP #$1E : BNE ..nobrick
		LDA #$01 : STA.l !BigRAM		; set brick flag for magikoopa
		BRA .NextTile
		..nobrick
		CMP #$21 : BEQ ..starman
		CMP #$22 : BEQ ..starman
		CMP #$25 : BNE ..nomulti2
		TXA
		AND #$03 : BEQ ..key
		CMP #$01 : BEQ ..wings
		CMP #$02 : BEQ ..balloon
	..shell	LDA #$01 : STA.w !FileMark+$5B		; > shell
		BRA .NextTile
	..balloon
		LDA #$01 : STA.w !FileMark+$11		; > balloon
		BRA .NextTile
	..wings	LDA #$01 : STA.w !FileMark+$09		; > blocks (including angel wings)
		BRA .NextTile
	..key	LDA #$01 : STA.w !FileMark+$02		; > key
		BRA .NextTile
		..nomulti2
		CMP #$27 : BEQ ..shell
		CMP #$28 : BEQ ..shell
	.NextTile
		INX					;\ loop through entire level
		CPX #$3800 : BCS $03 : JMP .TileLoop	;/

		PHK : PLB

	.SpriteData
		LDX #$0000
		LDY #$0001
	.Loop	CPY #$0500 : BCS .Done
		LDA [$CE],y				; get byte
		CMP #$FF : BNE .Normal			; special code if sprite starts with 0xFF
		LDA [$CE]				;\ commands only apply if new sprite system (LM 3.0+) is used
		AND #$20 : BEQ .Done			;/
		INY					;\ if next byte is positive, this is a command
		LDA [$CE],y : BMI +			;/
	-	INY : BRA .Loop
	+	CMP #$FE : BNE .Normal			; if the next byte is 0xFE, there are no more sprites
							; otherwise, the sprite simply started with 0xFF and is 1 byte longer as a result
	.Done
		PLP
		PLB
		RTL

	.Normal
		AND #$08				;\
		LSR #3					; | custom bit acts as bit 8 of number
		XBA					; | (note that extra bits are shifted to 0x0C in level's sprite data)
		INY #2					; |
		LDA [$CE],y				;/
		TAX					; X = index to sprite file correspondance table
		STX $0E					; (save this for later)

		CPX #$0123 : BCC ..notelitekoopa	;\
		CPX #$0127 : BCS ..notelitekoopa	; | elite koopas also load normal koopas
		LDA #$01 : STA !FileMark+$00		; |
		..notelitekoopa				;/

		LDA #$00 : XBA				; clear B
		JSR MarkPalette				; remember which palette sprite uses
		LDA LoadTable,x				;\
		CMP #$FE				; |
		BCC +					; | mark file for loading
		BEQ ..cmd				; | (except 0xFE which is skipped and 0xFF which is dynamic)
		JSR SuperDynamicFiles_Search		; |
		BRA ..cmd				; |
	+	TAX					; |
		LDA #$01 : STA !FileMark,x		;/
		CPX #$0013 : BNE ..notmagikoopa		;\
		LDA !BigRAM : BEQ ..cmd			; | if the level has bricks, magikoopa will also load koopa and thwimp
		STA !FileMark+$00			; |
		STA !FileMark+$16			;/
	..cmd	JMP .Command
		..notmagikoopa

		CPX #$003B : BNE ..notsmallbird		; check for small bird
		PHY					;\
		DEY					; |
		LDA [$CE],y				; |
		PLY					; |
		LSR #4					; |
		EOR #$0F				; | load default palset based on xpos
		INC #2					; |
		PHX					; |
		TAX					; |
		LDA #$01 : STA !Palset8,x		; |
		PLX					; |
		..notsmallbird				;/

		CPX #$004A : BNE ..notrex		; check for rex
		PHY					;\
		INY					; |
		LDA [$CE],y : BNE +			; | load normal legs if bag = 00
		LDA #$01 : STA !FileMark+$6C		; |
		BRA ++					;/
	+	CMP #$FF : BNE ..notgoldenbandit	;\
		LDA #$01				; |
		STA !FileMark+$6D			; |
		STA !FileMark+$8B			; | golden bandit config
		STA !FileMark+$9C			; |
		STA !FileMark+$98			; |
		BRA +					;/

	; DON'T ADD + after this because it could break stuff!!!

		..notgoldenbandit
		PHX					;\
		CLC : ADC #$9C-1			; |
		TAX					; | load carrying legs if bag != 00
		LDA #$01 : STA !FileMark,x		; |
		LDA #$01 : STA !FileMark+$6D		; |
		PLX					;/
	++	INY					;\
		LDA [$CE],y				; |
		AND #$0F : BEQ +			; |
		PHX					; |
		CLC : ADC #$94-1			; | load hat
		TAX					; |
		LDA #$01 : STA !FileMark,x		; |
		PLX					; |
	+	PLY					;/
		..notrex

		CPX #$00FC : BNE ..notdoublegenerator	;\
		LDA #$00 : STA !FileMark,x		; |
		LDA #$01				; | 0xFC is a special command that loads both para goombas and para bombs
		STA !FileMark+$8F			; |
		STA !FileMark+$90			;/
		BRA .Command				;
		..notdoublegenerator			;
		CPX #$00FD : BNE ..notexplodingblock	;\
		LDA #$00 : STA !FileMark,x		; > this is not a file, so don't load it
		PHY					; |
		DEY					; | we need to check position of exploding block
		LDA [$CE],y				; |
		PLY					;/
		LSR #4					;\
	-	CMP #$04 : BCC +			; | get mod 4
		SBC #$04 : BRA -			;/
	+	CMP #$00 : BEQ ..fish			;\
		CMP #$01 : BEQ ..goomb			; | 2 or 3 = koopa
	..koopa	LDA #$01 : STA !FileMark+$00		; |
		BRA .Command				;/
	..goomb	LDA #$01 : STA !FileMark+$03		;\ 1 = goomba
		BRA .Command				;/
	..fish	LDA #$01 : STA !FileMark+$45		;\ 0 = fish
		BRA .Command				;/
		..notexplodingblock

		CPX #$0059 : BNE .Command		;\
		LDA $792B				; |
		CMP #$02 : BNE .Command			; | on sprite tileset 0x02, sparky should be replaced by fuzzy
		LDA #$00 : STA !FileMark+$59		; |
		LDA #$01 : STA !FileMark+$2A		;/

	.Command
		INY					; next byte
		LDX $0E					;\
		CPX #$0100				; | custom sprites have 2 extra bytes
		BCC $02 : INY #2			;/
		JMP .Loop				; loop




; how does this work?
; if a sprite's GFX index is 0xFF (dynamic) this table will be searched for a sprite number match
; if one is found, that file is uploaded
; for files that aren't found by the sprite scanner, the match number should be set to 0xFFFF since that will never match

; process:
; - find target RAM
; - chunking:
;	- SA-1 outputs 1 chunk into !GFX_buffer
;	- chunk is moved to target RAM (through SNES DMA or SA-1 CPU)
;	- loop until all chunks are loaded
; - command processing:
;	- copy chunk that should be processed into !ImageCache
;	- execute GFX transformation code
;	- copy output image into target RAM
;	- loop until all chunks are processed
; - format conversion:
;	- copy a chunk into !ImageCache
;	- convert chunk to CHR format
;	- copy output image into target RAM (overwriting the planar version)
;	- loop until all chunks are converted
;



; !BigRAM:
; 00: bytes used in $40A000-$40C7FF (10 KB)
; 02: bytes used in $7EC800-$7EFFFF (14 KB)
; 04: bytes used in $7FC800-$7FFFFF (14 KB)
; 06: bytes used in $7F0000-$7F7FFF (32 KB)
; 08: bytes used in $410000-$417FFF (32 KB)
; 0A: bytes used in $7E2000-$7EACFF (35 KB)

	SuperDynamicFiles:
		PHB : PHK : PLB
		PHP
		SEP #$30
		LDX.b #.RAMaddress-.RAMsize-1		;\
	-	STZ !BigRAM,x				; | mark all RAM areas as free
		DEX : BPL -				;/

		LDX #$00
	.Next	LDA !SuperDynamicMark,x : BNE .Load
		INX
		BNE .Next
		PLP
		PLB
		RTS

	.Return
		PLX
		PLP
		PLB
		RTS

	.Load	
		REP #$20
		TXA
		ASL A
		TAY
		LDA .List,y : STA $00
		LDY #$02
		PHX
		LDX.b #.RAMaddress-.RAMsize-2
	-	LDA .RAMsize,x					;\
		SEC : SBC !BigRAM,x				; |
		BEQ .nextM					; |
		BCS .thisM					; | look for a good spot in memory
	.nextM	DEX #2 : BMI .Return				; |
		BRA -						; |
	.thisM	CMP ($00),y : BCC .nextM			;/
		LDA !BigRAM,x					;\
		CLC : ADC .RAMaddress,x				; | address to start uploading to
		STA !BigRAM+$10					;/
		STA !BigRAM+$74					; > remember this!

		LDA ($00),y					;\
		CLC : ADC !BigRAM,x				; | mark memory as used
		STA !BigRAM,x					;/

		LDA !BigRAM+$11					;\
		AND #$00FF					; |
		LSR #2						; |
		STA $02						; > (note that this clear of $03 is necessary)
		LDA .RAMprop,x					; |
		LDY #$00					; |
		AND #$00FF					; |
		CMP #$007E : BEQ +				; |
		LDY #$40					; | bbpppppp
		CMP #$007F : BEQ +				; |
		LDY #$80					; |
		CMP #$0040 : BEQ +				; |
		LDY #$C0					; |
	+	TYA						; |
		ORA $02						; |
		STA !BigRAM+$7E					;/

		STX $02						; RAM location index (SA-1 will need this)
		LDA !BigRAM+$10 : STA !BigRAM+$7A		; back this up

		LDA !BigRAM+$00 : PHA
		LDA !BigRAM+$02 : PHA
		LDA !BigRAM+$04 : PHA
		LDA !BigRAM+$06 : PHA
		LDA !BigRAM+$08 : PHA
		LDA !BigRAM+$0A : PHA

		REP #$30					;\
		PEI ($00)					; |
		PEI ($02)					; |
		LDY #$0004					; |
		LDA ($00),y					; | decompress file
		LDY.w #!DecompBuffer : STY $00			; | (only SNES can call this so it can't be done later)
		LDY.w #!DecompBuffer>>8 : STY $01		; |
		JSL !DecompressFile				; |
		PLA : STA $02					; |
		PLA : STA $00					;/
		LDA.w #.SA1 : STA $3180				;\
		LDA.w #.SA1>>8 : STA $3181			; | call SA-1
		SEP #$30					; |
		JSR $1E80					;/
		LDY #$06					;\
		LDA ($00),y : TAX				; | store bbpppppp
		LDA !BigRAM+$7E : STA !GFX_status+$100,x	;/

		REP #$20
		PLA : STA !BigRAM+$0A
		PLA : STA !BigRAM+$08
		PLA : STA !BigRAM+$06
		PLA : STA !BigRAM+$04
		PLA : STA !BigRAM+$02
		PLA : STA !BigRAM+$00
		PLX
		INX						; next index
		SEP #$20
		JMP .Next


; solved??? i don't know
; error:
; - file 1 is processed properly
; - file 2 then has its first chunk uploaded properly
; - the other chunks are then stored over file 1's chunks
; - the garbage in the space file 2 should be using is then converted to character data



	.SA1
		PHP
		SEP #$20
		STZ $223F					; 4 bpp mode
		STZ $2250					; prepare multiplication

		JSR .ChunkFile
		JSR .Commands
		JSR .Convert
		PLP
		RTL




; 00 - 16-bit pointer to file
; 02 - RAM location index
; 04 - byte count of chunk (later holds bbpppppp)
; 06 - loop counter for chunk
; 08 - chunk width
; 0A - loop counter for rows
; 0D - 24-bit pointer to source GFX
; !BigRAM	- keeps track of memory areas for SD graphics
; !BigRAM+$10	- upload address
; !BigRAM+$12	- source GFX index
; !BigRAM+$14	- number of chunks
; !BigRAM+$6C	- copy of $0D from start of operation
; !BigRAM+$6E	- total number of iterations
; !BigRAM+$70	- total copies for current iteration
; !BigRAM+$72	- base number of chunks in file
; !BigRAM+$74	- original upload address
; !BigRAM+$76	- current chunk for transformations
; !BigRAM+$78	- iterations left (used with transformations)
; !BigRAM+$7A	- base upload address
; !BigRAM+$7C	- total chunks
; !BigRAM+$7E	- bbpppppp


	.ChunkFile
		PHB : PHK : PLB
		PHP
		REP #$30

; NOTE: only SNES can call !DecompressFile, so it can't be done here

		LDA.w #!DecompBuffer : STA $0D		;\ pointer = decompressed file
		LDA.w #!DecompBuffer>>8 : STA $0E	;/


	;	LDA ($00),y : TAY
	;	JSL !GetFileAddress
	;	LDA !FileAddress : STA $0D
	;	LDA !FileAddress+1 : STA $0E


		LDY #$0007				;\
		LDA ($00),y				; | number of chunks
		AND #$00FF				; |
		STA !BigRAM+$14 : STA !BigRAM+$7C	;/
		LDY #$0008				;\
		LDA ($00),y				; |
		AND #$FF00				; |
		XBA : STA $2251				; |
		LDA ($00),y				; |
		AND #$00FF				; | byte count of chunk
		STA $2253				; |
		STA $08					; > store chunk width in $08
		NOP					; |
		LDA $2306				;/
		STA $04					;\ get byte count + loop counter
		STA $06					;/ $06 will be the loop counter for the chunk, whereas $04 is not overwritten
		STZ !BigRAM+$12				; index to source GFX


; get w bytes from 128 x [row number]
; store to w x [row number]

	.GetFreshChunk
		LDA $08 : STA $0A			; loop counter for row
		LDX #$0000				; index to cache
		LDY !BigRAM+$12				; index to source GFX
	-	LDA [$0D],y : STA !GFX_buffer,x		;\
		INX #2					; | copy row
		INY #2					;/
		DEC $06 : DEC $06 : BEQ +		; > check for end of chunk
		DEC $0A : DEC $0A : BNE -		; > check for end of row
		TYA					;\
		SEC : SBC $08				; |
		CLC : ADC ($00)				; | get index to next row by adding width encoding
		TAY					; |
		LDA $08 : STA $0A			; > reset row loop counter
		BRA -					;/

	; formatted chunk is now stored in cache
	+	PEI ($0E)
		PEI ($0C)
		LDX $02
		LDA .RAMprop,x				;\
		AND #$00FF				; | get bank to upload to
		XBA					; |
		STA $0E					;/
		LDA !BigRAM+$10 : STA $0D		; address to upload to
		JSR DownloadChunk


	.ChunkDone
		PLA : STA $0C				;\ restore GFX pointers
		PLA : STA $0E				;/
		LDA !BigRAM+$10				;\
		CLC : ADC $04				; | update upload address
		STA !BigRAM+$10				;/
		LDA !BigRAM+$12				;\
		CLC : ADC $08				; | get next chunk to the right
		STA !BigRAM+$12				;/
		LDA ($00)				;\
		DEC A					; | check for end of row
		AND !BigRAM+$12 : BNE +			;/
		LDA ($00) : STA $2251			;\
		LDY #$0009				; | calculate byte count of size in source file
		LDA ($00),y				; |
		STA $2253				;/
		LDA !BigRAM+$12				;\
		SEC : SBC $08				; | recalculate source file index
		CLC : ADC $2306				; |
		STA !BigRAM+$12				;/
	+	DEC !BigRAM+$14 : BEQ +			; decrement number of chunks to get
		LDA $04 : STA $06
		JMP .GetFreshChunk			; keep getting chunks until done

	+	PLP
		PLB
		RTS


	.Commands
		PHB : PHK : PLB
		PHP
		REP #$30
		LDX $02
		LDA $04 : STA $2251
		LDY #$0007
		LDA ($00),y
		AND #$00FF
		STA $2253
		STA !BigRAM+$72
		LDA !BigRAM+$74
		CLC : ADC $2306
		STA $0D
		SEP #$20
		LDA .RAMprop,x : STA $0F
		LDY #$000A


	..Loop	REP #$20
		LDA $0D : STA !BigRAM+$6C
		SEP #$20
		LDA ($00),y : BEQ ..Rotate		; 00 = rotate
		CMP #$01 : BEQ ..SJump			; 01 = scale
							; all other values just end
	..Done	PLP
		PLB
		RTS

	..Next	INY #5
		BRA ..Loop

	..SJump	JMP ..Scale


	..Rotate
		REP #$20				;\
		LDA $04 : STA $2251			; |
		INY					; |
		LDA ($00),y				; | get chunk address
		AND #$00FF				; |
		STA $2253				; |
		STA !BigRAM+$76				;/

		INY					;\
		LDA ($00),y				; |
		AND #$00FF				; | iterations
		STA !BigRAM+$78				; |
		STA !BigRAM+$6E				;/

	--	LDA !BigRAM+$7A				;\
		CLC : ADC $2306				; |
		PEI ($0D)				; | update chunk address
		STA $0D					; |
		JSR ChunkToCache			; |
		PLA : STA $0D				;/

		INY					;\
		LDA ($00),y				; | angle
		AND #$00FF				; |
		STA !BigRAM+$0E				; |
		STA $0A					;/
		INY					;\
		LDA ($00),y				; | copies
		AND #$00FF				; |
		STA $06					;/
		STA !BigRAM+$70				; > total copies
		CLC : ADC !BigRAM+$7C			;\ add to number of chunks
		STA !BigRAM+$7C				;/
		INY					; adjust index

		LDA !BigRAM+$78 : BEQ ..RotateDone	; check iterations
		DEC !BigRAM+$78				; start a new iteration
	-	LDA $06 : BNE +				; check copies
		DEY #3					;\
		INC !BigRAM+$76				; |
		LDA !BigRAM+$76 : STA $2251		; | go to next iteration
		LDA $04 : STA $2253			; |
		BRA --					;/

	+	DEC $06					; start a new copy
		LDA.w #!V_cache : STA !BigRAM+$00	; image source
		LDA $08					;\
		ASL A					; | width
		STA !BigRAM+$02				;/
		LDA #$0020 : JSL !TransformGFX		; rotate with fixed size


		LDA !BigRAM+$70
		SEC : SBC $06
		STA $2251				; copy (current)
		LDA !BigRAM+$72 : STA $2253		; x base number of chunks (in file)
		LDA !BigRAM+$76				; + chunk (current)
		CLC : ADC $2306
		STA $2251
		LDA $04 : STA $2253			; () x chunk size
		NOP : BRA $00
		LDA $2306
		CLC : ADC !BigRAM+$74			; + base upload address
		STA $0D


		JSR DownloadChunk			; get chunk from output buffer
		LDA $0D					;\
		CLC : ADC $04				; | adjust address
		STA $0D					;/
		LDA !BigRAM+$0E				;\
		CLC : ADC $0A				; | adjust angle
		STA !BigRAM+$0E				;/
		BRA -					; next copy


	..RotateDone
		LDA !BigRAM+$70 : STA $2251
		LDA !BigRAM+$6E : STA $2253
		NOP : BRA $00
		LDA $2306 : STA $2251
		LDA $04 : STA $2253
		LDA !BigRAM+$6C
		NOP
		CLC : ADC $2306
		STA $0D
		JMP ..Loop


	..Scale
		REP #$20				;\
		LDA $04 : STA $2251			; |
		INY					; |
		LDA ($00),y				; | get chunk address
		AND #$00FF				; |
		STA $2253				; |
		STA !BigRAM+$76				;/

		INY					;\
		LDA ($00),y				; | iterations
		AND #$00FF				; |
		STA !BigRAM+$78				;/

	-	LDA !BigRAM+$7A				;\
		CLC : ADC $2306				; | update chunk address
		PEI ($0D)				; |
		STA $0D					; |
		JSR ChunkToCache			; |
		PLA : STA $0D				;/

		INY					;\
		LDA ($00),y				; | x scaling
		AND #$00FF				; |
		STA !BigRAM+$06				;/
		INY					;\
		LDA ($00),y				; | y scaling
		AND #$00FF				; |
		STA !BigRAM+$08				;/
		INY					; adjust index
		LDA $08					;\
		STA !BigRAM+$0A				; | scaling center (remember that w is already halved here)
		STA !BigRAM+$0C				;/

		LDA !BigRAM+$78 : BEQ ..ScaleDone	; check iterations
		DEC !BigRAM+$78				; start a new iteration

	+	LDA.w #!V_cache : STA !BigRAM+$00	; image source
		LDA $08					;\
		ASL A					; | width
		STA !BigRAM+$02				; | + height
		STA !BigRAM+$04				;/
		LDA #$0080 : JSL !TransformGFX		; scale
		JSR DownloadScaledChunk			; get chunk from output buffer
		LDA $0D					;\
		CLC : ADC $04				; | adjust address
		STA $0D					;/
		DEY #3					;\
		INC !BigRAM+$7C				; |
		INC !BigRAM+$76				; | go to next iteration
		LDA !BigRAM+$76 : STA $2251		; |
		LDA $04 : STA $2253			; |
		BRA -					;/

	..ScaleDone
		JMP ..Loop


	.Convert
		PHB : PHK : PLB
		PHP
		REP #$30				; all regs 16-bit
		LDX $02					;\
		LDA .RAMprop,x				; |
		AND #$00FF				; | RAM address
		XBA					; |
		STA $0E					; |
		LDA !BigRAM+$7A : STA $0D		;/
		LDA !BigRAM+$7C : STA $06		; number of chunks

	..Loop	JSR ChunkToCache			; upload chunk to cache
		LDA.w #!V_cache : STA !BigRAM+$00	; image to convert
		LDA $08
		ASL A
		STA !BigRAM+$02				; width of image
		LDA #$0004 : JSL !TransformGFX		; convert to planar
		JSR DownloadChunk			; put converted chunk back in RAM
		DEC $06 : BEQ ..Done			;\
		LDA $0D					; |
		CLC : ADC $04				; | loop through all chunks
		STA $0D					; |
		BRA ..Loop				;/

	..Done	PLP
		PLB
		RTS



	.RAMsize
		dw $3400
		dw $2800
		dw $3800
		dw $8000
		dw $8000
		dw $8D00	; 8D00 should be the size... unknown why setting this to something larger than FFF causes issues
	.RAMaddress
		dw $C800
		dw $A000
		dw $C800
		dw $0000
		dw $0000
		dw $2000
	.RAMprop	; lo byte = bank, hi byte = DMA allowed (0 = no, 1 = yes)
		dw $017E
		dw $0040
		dw $017F
		dw $017F
		dw $0041
		dw $017E



		.Lookup
	;	dw $FFFF : db $00	; hammer
		dw $10D : db $01	; plant head
	;	dw $FFFF : db $02	; bone
	;	dw $FFFF : db $03	; fireball 8x8
	;	dw $FFFF : db $04	; fireball 16x16
		dw $00F : db $05	; goomba
	;	dw $FFFF : db $06	; luigi fireball
	;	dw $FFFF : db $07	; baseball
	;	dw $FFFF : db $08	; kadaal swim tiles
		..End


		.List
		dw .Hammer		; 00
		dw .PlantHead		; 01
		dw .Bone		; 02
		dw .Fireball8x8		; 03
		dw .Fireball16x16	; 04
		dw .Goomba		; 05
		dw .LuigiFireball	; 06
		dw .Baseball		; 07
		dw .KadaalSwim		; 08
		..End

; big fat note:
; chunk width has to be halved in the file entry due to packed format
; for example, a 16px wide chunk is marked as 8
; note: file size MUST be rounded up to closest KB ($400 B)

macro size(size)
dw $0000|(((<size>)+$3FF)&$FC00)	; for some reason asar sets high byte to 0xFF without the $0000|
endmacro


.Hammer
dw $0008			; 00: width encoding
%size($80*16)			; 02: size: 16 16x16 chunks
dw $E00				; 04: source ExGFX
db $00				; 06: SD GFX status index
db $01				; 07: 1 chunk
db $08,$10			; 08: chunk dimensions (16x16)
db $00,$00,$01,$20,$0F		; 0A: rotate: chunk 0, iterations 1, angle 20, copies 15
db $FF				; end file

.PlantHead
dw $0040			; 00: width encoding
%size($200*64)			; 02: size: 64 32x32 chunks
dw $E01				; 04: source ExGFX
db $01				; 06: SD GFX status index
db $02				; 07: source file has 2 chunks
db $10,$20			; 08: chunk dimensions (32x32)
db $00,$00,$02,$20,$0F		; 0A: rotate: chunk 0, iterations 2, angle 20, copies 15
db $01,$00,$01,$E0,$E0		; 0F: scale: chunk 0, iterations 1, x 82%, y 82%
db $01,$02,$0F,$E0,$E0		; 14: scale: chunk 2, iterations 15, x 82%, y 82%
db $01,$00,$01,$C0,$C0		; 19: scale: chunk 0, iterations 1, x 75%, y 75%
db $01,$02,$0F,$C0,$C0		; 1E: scale: chunk 2, iterations 15, x 75%, y 75%
db $FF				; end file

.Bone
dw $0008			; 00: width encoding
%size($80*16)			; 02: size: 16 16x16 chunks
dw $E02				; 04: source ExGFX
db $02				; 06: SD GFX status index
db $01				; 07: 1 chunk
db $08,$10			; 08: chunk dimensions (16x16)
db $00,$00,$01,$20,$0F		; 0A: rotate: chunk 0, iterations 1, angle 20, copies 15
db $FF				; end file

.Fireball8x8
dw $0004			; 00: width encoding
%size($20*16)			; 02: size: 16 8x8 chunks
dw $E03				; 04: source ExGFX
db $03				; 06: SD GFX status index
db $01				; 07: 1 chunk
db $04,$08			; 08: chunk dimensions (8x8)
db $00,$00,$01,$20,$0F		; 0A: rotate: chunk 0, iterations 1, angle 20, copies 15
db $FF				; end file

.Fireball16x16
dw $0008			; 00: width encoding
%size($80*16)			; 02: size: 16 16x16 chunks
dw $E04				; 04: source ExGFX
db $04				; 06: SD GFX status index
db $01				; 07: 1 chunk
db $08,$10			; 08: chunk dimensions (16x16)
db $00,$00,$01,$20,$0F		; 0A: rotate: chunk 0, iterations 1, angle 20, copies 15
db $FF				; end file

.Goomba
dw $0008			; 00: width encoding
%size($80*16)			; 02: size: 16 16x16 chunks
dw $E05				; 04: source ExGFX
db $05				; 06: SD GFX status index
db $01				; 07: 1 chunk
db $08,$10			; 08: chunk dimensions (16x16)
db $00,$00,$01,$20,$0F		; 0A: rotate: chunk 0, iterations 1, angle 20, copies 15
db $FF				; end file

.LuigiFireball
dw $0004			; 00: width encoding
%size($20*16)			; 02: size: 16 8x8 chunks
dw $E06				; 04: source ExGFX
db $06				; 06: SD GFX status index
db $01				; 07: 1 chunk
db $04,$08			; 08: chunk dimensions (8x8)
db $00,$00,$01,$20,$0F		; 0A: rotate: chunk 0, iterations 1, angle 20, copies 15
db $FF				; end file

.Baseball
dw $0004			; 00: width encoding
%size($20*16)			; 02: size: 16 8x8 chunks
dw $E07				; 04: source ExGFX
db $07				; 06: SD GFX status index
db $01				; 07: 1 chunk
db $04,$08			; 08: chunk dimensions (8x8)
db $00,$00,$01,$20,$0F		; 0A: rotate: chunk 0, iterations 1, angle 20, copies 15
db $FF				; end file

.KadaalSwim
dw $0040			; 00: width encoding
%size($80*20)			; 02: size: 20 16x16 chunks
dw $E08				; 04: source ExGFX
db $08				; 06: SD GFX status index
db $04				; 07: source file has 3 chunks
db $08,$10			; 08: chunk dimensions (16x16)
db $00,$00,$04,$10,$04		; 0A: rotate: chunk 0, iterations 4, angle 10, copies 4
db $FF				; end file


	.Search
		PHP
		REP #$20
		TXA
		LDX #$0000
	-	CMP .Lookup+0,x : BEQ ..mark
		INX #3
		CPX.w #.Lookup_End-.Lookup : BCC -
		BRA ..r

	..mark	LDA .Lookup+2,x
		AND #$00FF
		TAX
		SEP #$20
		LDA #$01 : STA !SuperDynamicMark,x
	..r	PLP
		LDX $0E
		RTS



; chunk copier routines below
; should be called by SA-1
; input:
;	X = RAM index
;	$04 = byte count of chunk
;	$0D = 24-bit pointer to target RAM



	ChunkToCache:
		PHY
		LDX $02
		LDA SuperDynamicFiles_RAMprop,x
		CMP #$0100 : BCC .CPU

	.DMA
		LDA.w #..SNES : STA $0183		;\
		PHP					; |
		SEP #$20				; |
		LDA.b #..SNES>>16 : STA $0185		; |
		LDA #$D0 : STA $2209			; | request SNES DMA, then return
	-	LDA $018A : BEQ -			; |
		STZ $018A				; |
		PLP					; |
		PLY					; |
		RTS					;/

		..SNES					; bank is already K
		PHP					;\
		REP #$20				; |
		SEP #$10				; |
		LDA $0D : STA $2181			; |
		LDX $0F : STX $2183			; |
		LDA #$8080 : STA $4300			; | DMA chunk
		LDA.w #!ImageCache : STA $4302		; |
		LDX.b #!ImageCache>>16 : STX $4304	; |
		LDA $04 : STA $4305			; |
		LDX #$01 : STX $420B			; |
		PLP					; |
		RTL					;/

	.CPU
		LDX $04					;\
		DEX #2					; |
		TXY					; | transfer chunk
	-	LDA [$0D],y : STA !ImageCache,x		; |
		DEX #2					; |
		TXY : BPL -				;/
		PLY
		RTS


	DownloadChunk:
		PHY
		LDX $02
		LDA SuperDynamicFiles_RAMprop,x
		CMP #$0100 : BCC .CPU

	.DMA
		LDA.w #..SNES : STA $0183		;\
		PHP					; |
		SEP #$20				; |
		LDA.b #..SNES>>16 : STA $0185		; |
		LDA #$D0 : STA $2209			; | request SNES DMA, then return
	-	LDA $018A : BEQ -			; |
		STZ $018A				; |
		PLP					; |
		PLY					; |
		RTS					;/

		..SNES					; bank is already K
		PHP					;\
		REP #$20				; |
		SEP #$10				; |
		LDA $0D : STA $2181			; |
		LDX $0F : STX $2183			; |
		LDA #$8000 : STA $4300			; | DMA chunk
		LDA.w #!GFX_buffer : STA $4302		; |
		LDX.b #!GFX_buffer>>16 : STX $4304	; |
		LDA $04 : STA $4305			; |
		LDX #$01 : STX $420B			; |
		PLP					; |
		RTL					;/

	.CPU
		LDX $04					;\
		DEX #2					; |
		TXY					; | transfer chunk
	-	LDA !GFX_buffer,x : STA [$0D],y		; |
		DEX #2					; |
		TXY : BPL -				;/
		PLY
		RTS


	DownloadScaledChunk:
		PHY
		LDX $02
		LDA SuperDynamicFiles_RAMprop,x
		CMP #$0100 : BCC .CPU

	.DMA
		LDA.w #..SNES : STA $0183		;\
		PHP					; |
		SEP #$20				; |
		LDA.b #..SNES>>16 : STA $0185		; |
		LDA #$D0 : STA $2209			; | request SNES DMA, then return
	-	LDA $018A : BEQ -			; |
		STZ $018A				; |
		PLP					; |
		PLY					; |
		RTS					;/

		..SNES					; bank is already K
		PHP					;\
		REP #$20				; |
		SEP #$10				; |
		LDA $0D : STA $2181			; |
		LDX $0F : STX $2183			; |
		LDA #$8000 : STA $4300			; | DMA chunk
		LDA.w #!GFX_buffer+$800 : STA $4302	; |
		LDX.b #!GFX_buffer>>16 : STX $4304	; |
		LDA $04 : STA $4305			; |
		LDX #$01 : STX $420B			; |
		PLP					; |
		RTL					;/

	.CPU
		LDX $04					;\
		DEX #2					; |
		TXY					; | transfer chunk
	-	LDA !GFX_buffer+$800,x : STA [$0D],y	; |
		DEX #2					; |
		TXY : BPL -				;/
		PLY
		RTS



; $07F3FE, indexed by sprite number, holds palette settings for all vanilla sprites
; for custom sprites i can index $168000 by sprite num * 0xE
;
	MarkPalette:
		PHX
		REP #$20
		CPX #$0100 : BCC .Vanilla
		TXA
		AND #$00FF
		ASL A
		STA $08
		ASL #3
		SEC : SBC $08
		TAX
		LDA $168003,x
		BRA .Shared

		.Vanilla
		LDA $07F3FE,x

		.Shared
		LSR A
		AND #$0007
		TAX
		SEP #$20
		CPX #$0002 : BCC +			;\ palettes 8-9 and E-F should not be marked here
		CPX #$0006 : BCS +			;/
		LDA #$01 : STA !Palset8,x
	+	PLX
		RTS



