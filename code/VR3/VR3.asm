header
sa1rom

;============;
;INTRODUCTION;
;============;
; -- VRAM Table Format --
;
; For each upload:
;	- Data Size		2 bytes
;	- Data Source		3 bytes
;	- Dest VRAM		2 bytes
;
; VRAM upload table starts at !VRAMtable.
; data size of 0x0000 is not uploaded
; setting the highest bit of dest VRAM causes the transfer to become a download instead of an upload
; setting the highest bit of data size turns the upload into a background mode upload
; if a background mode download is not finished in one frame, it sets the index to 0 rather than storing its own
; this means that other transfers will have priority over it on subsequent frames
; because of this, background mode transfers should be written at the end of the table
; normal transfers are worked on until completion before the next one is started
; the second highest bit of data size enables fixed transfer, which uploads the same 2 bytes over and over (not used for downloads)
;
; -- CGRAM Table Format --
;
; For each upload:
;	- Data size		2 bytes
;	- Data source		3 bytes
;	- Dest CGRAM		1 byte
;
; CGRAM upload table starts at !VRAMtable+$100.
;
; -- Tile update optimizer --
;
; At !VRAMtable+$200, there is a table that holds data for tile updates.
; each 8x8 tile has 4 bytes: 2 for VRAM address and 2 for tilemap data
; 
;
;
;=======;
;DEFINES;
;=======;

	incsrc "../Defines.asm"


;=============;
;OAM REMAPPING;
;=============;

; --Remap sprites--

	org $0180D2
	;	JML OAM_handler				;\ Source: PHX : TXA : LDX $1692
	;	NOP					;/
		PHX
		TXA
		LDX $7692



; --Remap minor extended sprites--

	;%minorOAMremap1($028CFF)			;\
	;%minorOAMremap1($028D8B)			; |
	;%minorOAMremap1($028E20)			; |
	;%minorOAMremap2($028E94)			; | Remap minor extended sprite indexes
	;%minorOAMremap1($028EE1)			; |
	;%minorOAMremap1($028F4D)			; |
	;%minorOAMremap1($028FDD)			;/

; --Remap extended sprites--

	org $029D10
	RETURN:
	;	JML OAM_handler_extG			;\ Source: LDY $A153,x : STY $0F
	;	NOP					;/
		.extG
	org $02A362
	;	JML OAM_handler_ext01special		;\ Source: LDY $A153,x : CPY #$08
	;	NOP					;/
		.ext01special
	org $02A367
	;	JML OAM_handler_ext01			;\ Source: BCC $03 : LDY $9FA3,x
	;	NOP					;/
		.ext01
	org $02A180
	;	JML OAM_handler_ext02			;\ Source: LDY $A153,x : LDA $14
	;	NOP					;/
		.ext02
	org $02A235
	;	JML OAM_handler_ext03			;\ Source: LDY $A153,x : LDA $1765,x
	;	NOP #2					;/
		.ext03
	org $02A31A
	;	JML OAM_handler_ext04			;\ Source: LDY $A153,x : LDA $1765,x
	;	NOP #2					;/
		.ext04
	org $02A03B
	;	JML OAM_handler_ext05			;\ Source : LDY $9FA3,x : JSR $A1A7
	;	NOP #2					;/
	org $02A1A4
	;	JML OAM_handler_ext05			;\ Source : LDY $A153,x : LDA $1747,x
	;	NOP #2					;/
		.ext05
	org $029E9D
	;	JML OAM_handler_ext07			;\ Source: LDY $A153,x : LDA $171F,x
	;	NOP #2					;/
		.ext07
	org $029E5F
	;	JML OAM_handler_ext08			; Source: LDY $A153,x : PLA
		.ext08
	org $029B51
	;	JML OAM_handler_ext0C			;\ Source: LDY $A153,x : LDA $171F,x
	;	NOP #2					;/
		.ext0C
	org $02A287
	;	JML OAM_handler_ext0D			;\ Source: LDY $A153,x : LDA $00
	;	NOP					;/
		.ext0D
	org $02A2A3
	;	LDA $0E					; get tile number from RAM
	org $02A2B0
	;	ORA $0F					; get YXPPCCCT from RAM

	org $029C41
	;	JML OAM_handler_ext0F			;\ Source: LDY $A153,x : LDA $176F,x
	;	NOP #2					;/
		.ext0F
	org $029C8B
	;	JML OAM_handler_ext10			;\ Source: LDY $A153,x : LDA #$34
	;	NOP					;/
		.ext10
	org $029F76
	;	JML OAM_handler_ext11			;\ Source: LDY $A153,x : LDA #$04
	;	NOP					;/
		.ext11
	;org $029F46
	;	JML OAM_handler_ext12			;\ Source: LDY $A153,x : LDA $0200,y
	;	NOP #2					;/
	org $029F40
	TAX
	LDA $9EEA,x
	STA $00
	LDX $75E9
	LDA !OAM,y
		.ext12

; --Remap smoke sprites--

	org $02999F
	;	JML OAM_handler_smokeG			;\ Source: LDY $96BC,x : LDA $17C8,x
	;	NOP #2					;/
		.smokeG
	org $029701
	;	JML OAM_handler_smoke01special		;\ Source: LDY $96BC,x : LDA $17C8,x
	;	NOP #2					;/
		.smoke01special
	org $02974A
	;	JML OAM_handler_smoke01
	;	NOP #2
		.smoke01
	org $0297B2
	;	JML OAM_handler_smoke02			;\ Source: LDY #$F0 : LDA $17C8,x
	;	NOP					;/
		.smoke02
	org $029936
	;	JML OAM_handler_smoke03l		;\ Source: LDY $96BC,x : LDA #$F0
	;	NOP					;/
		.smoke03l
	org $02996F
	;	JML OAM_handler_smoke03h		; > Source: LDA $77C8,x : SEC
		.smoke03h

; --Remap bounce sprites--

	org $02922D
	;	JML OAM_handler_bounce			;\ Source: LDY $91ED,x : LDA $16A1,x
	;	NOP #2					;/
		.bounce

; -- Remap coin sprites --

	org $029A3D
	;	JML OAM_handler_coin			;\ org: LDY $99E9,x : STY $0F
	;	NOP
		.coin


; -- Remap $7474 to $7475 --
	org $03C53F
		STA $7475
	org $03C595
		LDA $7475

;==============;
;LAYER PRIORITY;
;==============;
; these are indexed by level mode setting
; 00 - horizontal level, layer 2 background
; 01 - horizontal level, layer 2 level (no interaction)
; 02 - horizontal level, layer 2 level (with interaction)
; 03 - 
; 04 - 
; 05 - 
; 06 - 
; 07 - vertical level, layer 2 level (no interaction)
; 08 - vertical level, layer 2 level (with interaction)
; 09 - BOSS
; 0A - vertical level, layer 2 background
; 0B - BOSS
; 0C - dark horizontal level, layer 2 background
; 0D - dark vertical level, layer 2 background
; 0E - ???
; 0F - ???
; 10 - BOSS
; 11 - dark horizontal level, layer 2 background
; 12 - 
; 13 - 
; 14 - 
; 15 - 
; 16 - 
; 17 - 
; 18 - 
; 19 - 
; 1A - 
; 1B - 
; 1C - 
; 1D - 
; 1E - translucent horizontal level, layer 2 background
; 1F - translucent horizontal level, layer 2 level (with interaction)

; the most commonly used one is 00
; after that, 01 and 02 are useful for a more detailed layer 2
; vertical layouts are obsolete due to LM 3.0+ flexible level sizes
; the ones marked BOSS are useless
; the dark and translucent ones might be useful, or it might be better to use custom setups...

org $058417	; level mode table (don't use)
org $058437	; main screen table
	db $1D
org $058457	; sub screen table
	db $02
org $058477	; CGADSUB table (2131)
	db $20
org $058497	; used to be special table ($6D9B) but we don't use that
org $0584B7	; OAM priority table ($64)

org $0584FF
	LDA.l $058437,x : STA !MainScreen
	LDA.l $058457,x : STA !SubScreen
	LDA.l $058477,x : STA $40
	LDA.l $0584B7,x : STA $64
	LDA.l $058417,x : STA $5B		; this one has to go last
	BRA +
warnpc $058526
org $058526
	+

;=======;
;HIJACKS;
;=======;

; Things that SMW wants to get done during v-blank (NMI) are as follows:
; - Read $4210
; - Update music ports ($2140-$2143)
; - Set f-blank
; - Disable HDMA (?)
; - Update windowing regs ($2123-$2125, $2130)
; - Update CGADSUB ($2131)
; - Set BG mode ($2105)
; - Run $00A488 (dynamic palette routine)
; - Draw status bar
; - Run $0087AD (zip loader)
; - Update GFX depending on $143A (because of "MARIO START !"
; - Run $00A390 (SMW's dynamic sprite routine)
; - Run $00A436 (uploads "MARIO START !" if approperiate)
; - Run $00A300 (Mario GFX DMA)
; - Run $0085D2 (stripe image loader)
; - Run $008449 (OAM upload)
; - Run $008650 (controller update)
; - Update layer positions ($210D-$2110)
; - Enable IRQ ($4209-$420A, $4211)
; - Set $4200
; - Set brightness ($2100)
; - Enable HDMA
;
; I can probably kill SMW's dynamic sprites, as well as the dynamic blocks...
;


	org $00816A					; Start of NMI routine
		SEI
		JML NMI					; PHP : REP #$30 : PHA

	org $00806B
		JMP FinalShade				; org: JMP $1E8F

	org $008070
		INC $13					;\ source: INC $13 : JSR $9322
		JSR MainExpand				;/

	org $0081CE					; unused NMI code
	MainExpand:
		JSR $9322				; overwritten code (GetGameMode)
		LDA !GameMode
		CMP #$05 : BCC Return_RAM_Code
		CMP #$11 : BEQ Return_RAM_Code
		JML Build_RAM_Code
	Return_RAM_Code:
		RTS
	FinalShade:
		LDA !GameMode				;\ only run final shade on game mode 05+
		CMP #$05 : BCC +			;/
		LDA.b #.SA1 : STA $3180			;\
		LDA.b #.SA1>>8 : STA $3181		; | have SA-1 keep track of when NMI occurs
		LDA.b #.SA1>>16 : STA $3182		; |
		LDA #$80 : STA $2200			;/
		JSR !MPU_light				; have SNES run shading operation
	+	JMP $1E8F				; go to end of game loop
		.SA1
		LDA $10 : BNE +				; skip this if CPU is behind PPU
	+	STZ !MPU_NMI				;\
	-	LDA !MPU_NMI : BEQ -			; | otherwise wait for NMI, then clear MPU NMI flag
	+	STZ !MPU_NMI				;/
		RTL					; return
	warnpc $008217

	org $00838F
		JML IRQ
	org $0083B2
		JML ReturnNMI				; REP #$30 : PLB : PLY
	org $008293
		db $D6					; IRQ scanline

	org $0097C1
		STA !2106				; STA instead of STZ (A is already 0x0F)
	org $009F66					; prevent 2106 write
		LDA #$0F : TSB !2106
		RTS
		NOP
		RTS
	warnpc $009F6E
	org $00A0A3
		LDA #$FF				; 2106 value
	org $00C9EB
		LDX #$FF				; 2106 value


	; prevent SMW from getting tilemap update parameters
	org $05877E
		RTS					; source: PHP

	; prevent the tilemap update code from running
	org $00A2A1
		BRA $02 : NOP #2			; source: JSL $0586F1


	org $00AACD
	;	JML LoadGFX
		LDX #$07
		LDA [$00]
	ReturnGFX:
		RTS



	org read3($00A2A5+1)+$97A707-$97A4A0		; lunar magic palette exanimation code
	print "Lunar Magic palette Exanimation fix at $", pc
	PaletteExAnimFix:
	;	RTS					;\
	;	RTS					; | org: STA.l $6905,x
	;	RTS					; |
	;	RTS					;/
		STA.l !ShaderInput,x
	warnpc PaletteExAnimFix+4



; documentation, $0FFA2B
;	SEP #$20
;	LDX #$03
;
;	TXA
;	CLC : ADC #$0C
;	JSR $F84E		; this will decompress the GFX file into $7EAD00
;	XBA
;	BEQ .Next
;
; this is the code that actually uploads custom ExGFX ($0FFA39)
;	REP #$20
;	PHX
;	TXA
;	ASL A
;	TAX
;	PHB : PHK : PLB
;	LDA $FA7F,x		; yes, really
;	PLB
;	STA $2116
;	LDA #$AD00 : STA $4312
;	LDA #$0800 : STA $4315	; hardcoded 2KB size
;	LDX #$80 : STX $2115
;	LDA #$1801 : STA $4310
;	LDX #$7E : STX $4314
;	LDX #$02 : STX $420B
;
; $0FFA6A
;	SEP #$20
;	PLX
;
; $0FFA6D
; .Next
;	DEX : BPL .Loop
;	REP #$20
;	PLA : STA $7FC007
;	SEP #$20
;	PLA : STA $7FC006
;	RTS

	; this is Lunar Magic's layer 3 GFX uploader (it can actually load anything, so we'll abuse that)
	org $0FFA39
;		JML BG3Fix_GFX				; source: REP #$20 : PHX : TXA
		REP #$20 : PHX : TXA
	Return_BG3_GFX:
	org $0FFA6A
	.Next
	; let the default code take over here



	; this is Lunar Magic's layer 3 tilemap uploader
	org $0FFE7B					; source:
;		JSL BG3Fix_Tilemap			; STA $4325
		RTS : NOP				; STX $2116
		NOP #6					; LDA #$1801 : STA $4320
;		NOP #3					; STY $4322
;		NOP #2					; SEP #$20
;		NOP #5					; LDA #$7E : STA $4324
;		NOP #5					; LDA #$80 : STA $2115
;		NOP #5					; LDA #$04 : STA $420B
;		RTS					; RTS
	warnpc $0FFE9C





org $12B000
print "-- VR3 --"
print "VR3 inserted at $", pc, "."
;LoadGFX:	LDA #$1801 : STA $4300			;\
;		LDA $00 : STA $4302			; |
;		LDX $02 : STX $4304			; | load GFX using DMA instead of CPU loop
;		TYA					; | this should load a level ~5 frames faster than the old method
;		INC A					; | (saves almost exactly 80 scanlines per 4KB chunk)
;		XBA					; |
;		LSR #3					; |
;		STA $4305				; |
;		LDX #$01 : STX $420B			; |
;		SEP #$20				; |
;		JML ReturnGFX				;/
;
;
; this is a hijack of Lunar Magic's BG3 tilemap uploader
; when we get here:
; A = size of file
; X = VRAM address
; Y = source address
; source bank is always $7E
; DMA parameters are always 0x1801 (video port control = 0x80)
; A should return 8-bit and index should return unchanged
;	BG3Fix:
;
;	.Tilemap
;		STA $4325
;		LDA #$1801 : STA $4320
;		CPX #$50A0				;\ remap source $50A0 to $5000
;		BNE $03 : LDX #$5000			;/ (fixes LM's "below status bar" option)
;		STX $2116				; VRAM address
;
;		CPY #$AE40				;\ remap source $AE40 to $AD00
;		BNE $03 : LDY #$AD00			;/ (fixes LM's "below status bar" option)
;		STY $4322				; source address
;
;		SEP #$20
;		LDA #$7E : STA $4324
;		LDA #$80 : STA $2115
;		LDX !Level
;		LDA.l !VRAM_map_table,x
;		CMP #$01 : BEQ ..M01
;		CMP #$02 : BNE ..M00
;
;	..M02
;	..M01	LDA #$58 : STA $2117			; remap VRAM page to 0x5800 area
;		LDA #$10				;\
;		CMP $4326 : BCS ..M00			; | cap upload size at 4KB (you can actually read these)
;		STA $4326				; |
;		STZ $4325				;/
;
;	..M00	LDA #$04 : STA $420B
;		RTL
;
; here is Lunar Magic's BG3 GFX uploader!
; it can actually upload anything... even 4bpp files >:D
; it uses hardcoded VRAM addresses, so we can easily repoint those
; VRAM map mode
;	.GFX
;		PHX
;		REP #$10
;		LDX !Level
;		LDA.l !VRAM_map_table,x
;		SEP #$10
;		CMP #$01 : BEQ ..map01
;		CMP #$02 : BEQ ..map02
;
;	..map00
;		REP #$20
;		PLX : PHX
;		TXA
;		JML Return_BG3_GFX
;
;	..map02					; these use the same setup, except...
;		LDA $01,s			;\
;		CMP #$03 : BNE ..map01		; |
;		LDA #$80 : STA $2115		; |
;		REP #$20			; |
;		LDA #$1809 : STA $4310		; | clear displacement map when uploading the first BG3 file
;		LDA.w #..some00 : STA $4312	; |
;		LDX.b #..some00>>16 : STX $4314	; |
;		LDA #$1000 : STA $4315		; |
;		LDA #$5800 : STA $2116		; |
;		LDX #$02 : STX $420B		;/
;		LDX #$7E : STX $4314		; > restore source bank
;
;	..map01
;		REP #$20			; A 16-bit
;		LDX #$80 : STX $2115		; word writes
;		PLX : PHX			; get index from stack without removing it
;		CPX #$02 : BCC ...4bpp		; GFX28 and GFX29 are still 2bpp
;
;	...2bpp	TXA				;\
;		ASL A				; |
;		TAX				; | move LM VRAM address from 0x4000 to 0x5000
;		LDA.l $0FFA7F,x			; |
;		ORA #$1000			; |
;		STA $2116			;/
;		LDA #$1801 : STA $4310		; DMA parameters
;		LDA #$AD00 : STA $4312		;\ source: $7EAD00
;		LDX #$7E : STX $4314		;/
;		LDA #$0800 : STA $4315		; 2KB
;		LDX #$02 : STX $420B		; start DMA
;		JML Return_BG3_GFX_Next
;
;	...4bpp	LDA.l ...addr-1,x		;\
;		AND #$FF00			; | VRAM address
;		STA $2116			;/
;		LDA #$AD00 : STA $4312		;\
;		LDX #$7E : STX $4314		; |
;		LDA #$1000 : STA $4315		; | upload 4bpp GFX
;		LDX #$02 : STX $420B		; |
;		JML Return_BG3_GFX_Next		;/
;
;	...addr	db $38,$30			; hi byte of VRAM address for GFX2A and GFX2B with map 01 (reverse order)
;	..some00
;		db $00



macro DMAsettings(word)
		LDA.w #<word>
		CMP $0C : BEQ ?Same
	?New:
		STA $0C
		LDA.w #$00A9 : STA.w !RAMcode+$00,y
		LDA.w #<word> : STA.w !RAMcode+$01,y
		LDA.w #$0085 : STA.w !RAMcode+$03,y
		TYA
		CLC : ADC #$0005
		TAY
	?Same:
endmacro

macro videoport(byte)
		LDA.w #<byte>
		CMP $0A : BEQ ?Same
	?New:
		STA $0A
		LDA.w #<byte><<8+$A2 : STA.w !RAMcode+$00,y
		LDA.w #$008E : STA.w !RAMcode+$02,y
		LDA.w #$2115 : STA.w !RAMcode+$03,y
		TYA
		CLC : ADC #$0005
		TAY
	?Same:
endmacro

macro sourcebank(byte)
		LDA.w #<byte>
		CMP $08 : BEQ ?Same
	?New:
		STA $08
	if <byte> = 0
		LDA.w #$0464 : STA.w !RAMcode+$00,y
		INY #2
	else
		LDA.w #<byte><<8+$A2 : STA.w !RAMcode+$00,y
		LDA.w #$0486 : STA.w !RAMcode+$02,y
		INY #4
	endif
	?Same:
endmacro


; must be used with 16-bit A
macro sourcebankA()
		AND #$00FF
		CMP $08 : BEQ ?Same
	?New:
		STA $08
		CMP #$0000 : BNE ?Non0
		LDA.w #$0464 : STA.w !RAMcode+$00,y
		INY #2
		BRA ?End
	?Non0:
		XBA
		ORA #$00A2
		STA.w !RAMcode+$00,y
		LDA.w #$0486 : STA.w !RAMcode+$02,y
		INY #4
	?End:
	?Same:
endmacro



macro writecode(label)
		STA.w !RAMcode+<label>-..code+1,y
endmacro


macro makecode(word)
		LDA.w #<word> : STA.w !RAMcode+!Temp,y
		!Temp := !Temp+2
endmacro



Build_RAM_Code:

		.Playtime					;\
		LDA !GameMode					; | increment playtime counter on game modes 0x0B and up
		CMP #$0B : BCC ..done				;/
		LDA !Playtime+0					;\
		INC A						; |
		CMP.b #60					; | frame counter
		BCC $02 : LDA #$00				; |
		STA !Playtime+0					; |
		BNE ..done					;/
		LDA !Playtime+1					;\
		INC A						; |
		CMP.b #60					; | second counter
		BCC $02 : LDA #$00				; |
		STA !Playtime+1					; |
		BNE ..done					;/
		LDA !Playtime+2					;\
		INC A						; |
		CMP.b #60					; | minute counter
		BCC $02 : LDA #$00				; |
		STA !Playtime+2					; |
		BNE ..done					;/
		REP #$20					;\
		LDA !Playtime+3					; |
		INC A						; |
		CMP.w #999					; | hour counter
		BCC $03 : LDA.w #999				; |
		STA !Playtime+3					; |
		SEP #$20					; |
		..done						;/

		%TrackSetup(!TrackVR3)

		LDA.b #.SA1 : STA $3180
		LDA.b #.SA1>>8 : STA $3181
		LDA.b #.SA1>>16 : STA $3182

		LDA !GameMode
		CMP #$14 : BEQ .Light
		JSR $1E80
		BRA +

	.Light	LDA #$80 : STA $2200				;\ SNES will run light shader while SA-1 is generating NMI code
		JSR !MPU_light					;/
		+

		LDA !HDMA : STA $1F0C				; double mirror HDMA enable to minimize errors caused by lag

	if !TrackOAM == 1
	endif



	if !TrackCPU == 1
	; 00 - call count
	; 02 - average
	; 03 - max
	; 04 - min
	; 05 - working mem for average
	; 0E - scratch
		LDA $2137
		LDA $213D : XBA
		LDA $213D
		AND #$01
		XBA
		REP #$20
		CMP #$0010 : BCC .Max
		CMP #$00E0 : BCC .Good
	.Max	LDA #$00FF
	.Good	PHB : PHK : PLB
		LDX #$40
		PHX : PLB
		STA.w !DebugData+$0E
		STA.l !OAM+$1FD					; current cost = slot 127

		LDA.w !DebugData+$00
		AND #$0007
		TAX
		INC.w !DebugData+$00
		SEP #$20
		LDA.w !DebugData+$0E : STA.w !DebugData+$05,x
		LDY.w !DebugData+$03 : BEQ +
		CMP.w !DebugData+$03
		BCS $03
	+	STA.w !DebugData+$03
		CMP !DebugData+$04
		BCC $03 : STA.w !DebugData+$04
		LDY #$00
		LDA.w !DebugData+$05
		CLC : ADC.w !DebugData+$06
		BCC $01 : INY
		CLC : ADC.w !DebugData+$07
		BCC $01 : INY
		CLC : ADC.w !DebugData+$08
		BCC $01 : INY
		CLC : ADC.w !DebugData+$09
		BCC $01 : INY
		CLC : ADC.w !DebugData+$0A
		BCC $01 : INY
		CLC : ADC.w !DebugData+$0B
		BCC $01 : INY
		CLC : ADC.w !DebugData+$0C
		BCC $01 : INY
		STA.w !DebugData+$0E
		STY.w !DebugData+$0F
		REP #$20
		LDA.w !DebugData+$0E
		LSR #3
		SEP #$20
		STA.w !DebugData+$02
		PLB

		STA !OAM+$1F9					; average cost = slot 126
		STZ !OAM+$1F8
		STZ !OAM+$1FC
		LDA #$48
		STA !OAM+$1FA
		STA !OAM+$1FE
		LDA #$36 : STA !OAM+$1FB			; current = blue
		LDA #$34 : STA !OAM+$1FF			; average = yellow
		STZ !OAMhi+$7E
		STZ !OAMhi+$7F


		LDA !GameMode
		CMP #$14 : BEQ .Track
		JML Return_RAM_Code				; go back to main game loop

		.Track
		%TrackCPU(!TrackVR3)
		JML Return_RAM_Code				; go back to main game loop
	else
		JML Return_RAM_Code
	endif


	.SA1
		PHP
		SEP #$30
		JSR .Main
		PLP
		RTL

	.Main
		REP #$20
		LDA #$0000
		STA !OAMindex					; clear OAM index regs
		STA.l !OAMindex_p0
		STA.l !OAMindex_p1
		STA.l !OAMindex_p2
		STA.l !OAMindex_p3
		SEP #$20
		LDA !AnimToggle					;\ check for disabled tilemap update
		AND #$02 : BNE .NoScrollData			;/
		LDA !GameMode
		CMP #$14 :  BNE .NoScrollData
		PHP
		JSR GetTilemapData
		PLP
		.NoScrollData


; mode 7 matrix math:
;	A = cos(v) * scale
;	B = sin(v) * scale
;	C = -sin(v) * scale
;	D = cos(v) * scale

		.Mode7
		LDA !Mode7Settings
		AND #$08 : BEQ ..done
		STZ $2250
		PHP
		REP #$30
		LDA !Mode7Scale : STA $2251
	; cos(v) * scale setup
		LDA !Mode7Rotation
		CLC : ADC #$0080
		AND #$01FF
		TAY
		ASL A
		CMP #$0200
		BCC $04 : EOR #$FFFF : INC A
		AND #$01FF
		TAX
		LDA.l !TrigTable,x
		CPY #$0100
		BCC $04 : EOR #$FFFF : INC A
		STA $2253
	; sin(v) setup
		LDA !Mode7Rotation
		AND #$01FF
		TAY
		ASL A
		CMP #$0200
		BCC $04 : EOR #$FFFF : INC A
		AND #$01FF
		TAX
	; A and D = cos(v) * scale
		LDA $2307				;\
		STA !Mode7MatrixA			; | write A and D here to save cycles on the math reg
		STA !Mode7MatrixD			;/
	; B = sin(v) * scale
		LDA !Mode7Scale : STA $2251
		LDA.l !TrigTable,x
		CPY #$0100
		BCC $04 : EOR #$FFFF : INC A
		STA $2253
		NOP : BRA $00
		LDA $2307 : STA !Mode7MatrixB
	; C = -sin(v) * scale
		EOR #$FFFF : INC A
		STA !Mode7MatrixC
		PLP
		..done



		.MarioAddress
		LDA !GameMode					;\ not on the realm select menu
		CMP #$0F : BCC .NoMarioAddress			;/
		LDA !CurrentMario : BEQ .NoMarioAddress		;\ see if mario is in play and who controls him
		CMP #$01 : BEQ ..Mario1				;/
		..Mario2
		LDA #$20 : STA !MarioTileOffset			; > tile offset for P2 Mario
		LDA #$02 : STA !MarioPropOffset			; > prop offset for P2 Mario
		REP #$20					;\
		LDX #$02					; | Mario GFX parameters
		LDA #$6200 : STA !MarioGFX1			; |
		LDA #$6300 : STA !MarioGFX2			;/
		BRA .NoMarioAddress
		..Mario1
		STZ !MarioTileOffset				; > tile offset for P1 Mario
		STZ !MarioPropOffset				; > prop offset for P1 Mario
		REP #$20					;\
		LDX #$02					; | Mario GFX parameters
		LDA #$6000 : STA !MarioGFX1			; |
		LDA #$6100 : STA !MarioGFX2			;/
		.NoMarioAddress


		REP #$20					; A 16-bit
		LDA !AnimToggle					;\ no palette update if vanilla animations are disabled
		AND #$0001 : BNE .SkipPal			;/
		LDA #$6682					;\
		LDY $6680 : BEQ .0682				; | if index = 0, use $6682, if index = 6, use $6703
		CPY #$06 : BNE .SkipPal				; | otherwise skip
	.0703	LDA #$6703					;/
	.0682	STZ $01						;\ store 24-bit pointer to palette data
		STA $00						;/
		LDX #$00					;\
	-	LDA.l !VRAMbase+!CGRAMtable+$00,x : BEQ .GotPal	; |
		TXA						; |
		CLC : ADC #$0006				; | get CGRAM table index (skip if table is somehow full)
		TAX						; |
		CMP #$00FC : BCC -				; |
		BRA .SkipPal					;/
	.GotPal	LDA [$00]					;\
		AND #$00FF : BEQ .SkipPal			; | set palette size
		STA.l !VRAMbase+!CGRAMtable+$00,x		;/
		LDA [$00]					;\
		AND #$FF00					; | set CGRAM address (also bank = 00)
		STA.l !VRAMbase+!CGRAMtable+$04,x		;/
		LDA $00						;\
		INC #2						; | source address
		STA.l !VRAMbase+!CGRAMtable+$02,x		;/

		STZ $6680					; clear table index
		STZ $6682					; clear sprite table header
		STZ $6703					; clear palette table header

		.SkipPal
		SEP #$20

;
;	!AnimToggle: uuuubesv
;		v: disable vanilla animations
;		s: disable scrolling tilemap update
;		e: disable ExAnimation
;		b: disable block update
;		uuuu: upload size; add 1, multiply by 256, then add 2KB to get maximum allowed size (max 6KB)
;			because it already sits in the upper nybble, you only need to left shift it 4 times to complete the multiplication
;		cheat sheet:
;		0000 - 2.25 KB
;		0001 - 2.5 KB
;		0010 - 2.75 KB
;		0011 - 3 KB
;		0100 - 3.25 KB
;		0101 - 3.5 KB
;		0110 - 3.75 KB
;		0111 - 4 KB
;		1000 - 4.25 KB
;		1001 - 4.5 KB
;		1010 - 4.75 KB
;		1011 - 5 KB
;		1100 - 5.25 KB
;		1101 - 5.5 KB
;		1110 - 5.75 KB
;		1111 - 6 KB
;
;		the reason to use extremely small limiters is that the translation process takes up quite a bit of CPU time
;		doing to can lead to graphical glitches for dynamic sprites, however
;		the reason to use large limiters is of course that more transfers can occur
;		when it comes to the limited
;
;
;		how to apply the limiter:
;		1. count up all the currently queued transfers
;		2. if limit is not reached, don't limit anything
;		3. assign a limit to each type (this is the most complicated part)
;
;
;		the problem is CCDMA, which is given priority and is not limited
;		at the very least, CCDMA should be accounted for in the limiter
;		most likely, CCDMA should be limited as well
;
;		4 limited types:
;		- VR2 GFX
;		- VR2 palettes
;		- ExAnimation
;		- CCDMA
;
;		normally, VR2 palettes should be handled first because of how small they are
;		generally, ExAnimation is cyclic and skipping a transfer will have minimal conequences, meaning that it should have the lowest priority
;		as for VR2 GFX and CCDMA, there is no obvious priority
;		VR2 GFX tend to be larger, but this is not guaranteed
;		most likely, something like alternating priority every frame could work
;		the issue with CCDMA is that you can't easily adjust the source address due to the zero bit limitation, meaning that it only operates tile by tile (rather than word by word)
;		- 8px:		16, 32, 64 byte skips
;		- 16px:		32, 64, 128 byte skips
;		- 32px:		64, 128, 256 byte skips
;		- 64px:		128, 256, 512 byte skips
;		- 128px:	256, 512, 1024 byte skips
;		- 256px:	512, 1024, 2048 byte skips
;		so... the amount you can adjust a CCDMA upload ranges from 16 bytes all the way up to 2KB
;		this means that large uploads have to be done in one go
;
;		potentially, i could buffer CCDMA into a VR3 table, then split it into "small CCDMA" (=<256 bytes) and "large CCDMA" (>256 bytes)
;		priority then goes as follow:
;		- VR2 palettes
;		- up to 1KB of large CCDMA (selected by index)
;		- dynamic tiles
;		- VR2 GFX
;		- small CCDMA
;		- remaining large CCDMA
;		- ExAnimation
;
;		VR2 paletets are so small that they hardly make a difference.
;		the reason to prioritize some large CCMDA per frame is that otherwise it will likely never be done
;		the limit was chosen so that the text box CCDMA will always be prioritized here with its 2 * 512 byte size
;		dynamic tiles are effectively "high priority VR2 uploads", which is why they go right before VR2 GFX
;		VR2 GFX have the most flexible limiter, which is why they are placed in the middle
;		you might expect this to mean they should be placed last, but this is not the case as they are often the most important transfers
;		this way they are likely to be worked on every frame
;		small CCDMA is prioritized after that, as it is likely that some progress will be made even on intense frames
;		remaining large CCDMA is prioritized if there is bandwidth remaining, otherwise large CCDMA is locked to 1KB / frame
;		this means that the largest possible CCDMA (256px 8bpp) kind of gets shafted, but every other combination can be multi-staged
;		ExAnimation is prioritized last because dropping a frame is unlikely to produce significant effects
;		this type has an arbitrary size and can't easily be limited, so i'm electing to simply drop it on intense frames
;
;
;
;		package from PCE: subtracts its data size from current limit	(up to 2048 bytes)
;		vanilla palettes: merged into CGRAM table			(unknown size, probably never more than 32 bytes)
;		tilemap zip: subtracts its data size from current limit		(272 bytes with layer 2 background, 282 bytes with layer 2 level)
;		block update: subtracts its data size from current limit	(up to 252 bytes)
;		mario: subtracts his data size from current limit		(512 bytes)
;		vanilla GFX: subtract their data size from current limit	(0, 128, 256, or 384 bytes)
;		-- because PCE and mario will not occur on the same frame...
;		-- up to this point, the maximum upload size is 2998 bytes
;		-- this WILL hit the limit using the minimum setting (2.25 KB)
;		-- the default setting (4KB) will be safe, however
;
;		exanimation: subtracts its data from current limit		(arbitrary size, should be limited)
;		VR2 palettes: subtract from current limit, not limited		(arbitrary size, should be limited)
;		VR2 GFX: advanced limiter					(arbitrary size, already limited)
;		
;
; seemingly, DMA transfers ~178 bytes per scanline (roughly 5.6 4bpp 8x8 tiles)
;

; CCDMA table:
;	256 bytes, split across two subtables:
;	big CCDMA, first 128 bytes, 16 slots
;	small CCDMA, second 128 bytes, 16 slots
;
; slot:
; $00 - size (16-bit)
; $02 - source (24-bit)
; $05 - VRAM (16-bit)
; $07 - CCDMA settings (8-bit)




		PHB
		LDA.b #!VRAMbank : PHA
		REP #$30

		STZ !RAMcode_flag				; don't allow RAMcode execution while routine is being built
		LDA !AnimToggle					;\
		AND #$00F0					; |
		CLC : ADC #$0010				; | transfer size = (uuuu bits +1) * 16 + 2048
		ASL #4						; |
		ADC #$0800					; |
		SEC : SBC.l !VRAMbase+!VRAMsize			; > subtract number of bytes uploaded by player GFX
		STA $0E						;/

		LDY !RAMcode_offset
		PLB


		LDA #$0060 : STA $08				; reset source bank (0x60 will never be used by SNES)
		STZ $0A						; reset video port
		STZ $0C						; reset DMA settings

		LDA.l !GameMode					;\
		AND #$00FF					; | some of these only happen during levels
		CMP #$0014 : BEQ .Level				; |
		CMP #$0007 : BEQ .NoScroll			; > title screen counts as level for the purposes of this
		JMP .NotLevel					;/

	.Level
		LDA !AnimToggle
		AND #$0002 : BNE .NoScroll			; if bit 1 is set, disable tilemap update


		LDA.l !UpdateBG1Column				;\ update column
		BEQ $03 : JSR .AppendColumn1			;/
		LDA.l !UpdateBG1Row				;\ update row
		BEQ $03 : JSR .AppendRow1			;/
		LDA.l $7925					;\
		AND #$00FF : BEQ .Layer2BG			; |
		CMP #$0003 : BCC .Layer2Level			; |
		CMP #$0007 : BEQ .Layer2Level			; | check for level modes that have level data on layer 2
		CMP #$0008 : BEQ .Layer2Level			; |
		CMP #$000F : BEQ .Layer2Level			; |
		CMP #$001F : BEQ .Layer2Level			;/
	.Layer2BG
		LDA.l !UpdateBG2Row : BEQ .NoScroll		;\
		PEA .NoScroll-1					; | update background
		JMP .AppendBackground				;/
	.Layer2Level
		LDA.l !UpdateBG2Column				;\ update column
		BEQ $03 : JSR .AppendColumn2			;/
		LDA.l !UpdateBG2Row				;\ update row
		BEQ $03 : JSR .AppendRow2			;/
		.NoScroll


;		SEP #$20					;\
;		LDA !CurrentMario : BEQ .NoMario		; | check if mario is in play and who plays him
;		XBA						; |
;		LDA !MultiPlayer : BEQ .Mario			;/
;		XBA						;\
;		DEC A						; | P1 on frame 0, P2 on frame 1
;		EOR $14						; |
;		LSR A : BCS .NoMario				;/
;	.Mario
;		REP #$20
;		JSR .AppendMario
;		.NoMario


		REP #$20
		LDA !AnimToggle					;\ bit 0 disables vanilla animations
		AND #$0001 : BNE .SkipSMW			;/
		PHY						;\
		LDY.w #!File_DynamicVanilla			; | get address of "GFX33"
		JSL !GetFileAddress				; |
		PLY						;/
		LDA !FileAddress+2 : %sourcebankA()		; source bank for these uploads
		LDA.l $6D7C : BEQ .No0D7C			;\
		CMP #$0800 : BEQ .No0D7C			; | update slot 1
		JSR .AppendSMW0D7C				; |
		.No0D7C						;/
		LDA.l $6D7E					;\ update slot 2
		BEQ $03 : JSR .AppendSMW0D7E			;/
		LDA.l $6D80					;\ update slot 3
		BEQ $03 : JSR .AppendSMW0D80			;/


	; removed for shader compatibility
	;	LDA #$0100					;\
	;	CMP.l !LightR : BNE ..coinshine			; |
	;	CMP.l !LightG : BNE ..coinshine			; |
	;	CMP.l !LightB : BEQ ..nocoinshine		; | coin shine, unless there's a lighting effect
	;	..coinshine					; |
	;	JSR .AppendSMWPalette				; |
	;	..nocoinshine					;/
		.SkipSMW


		.NotLevel


		LDA !AnimToggle					;\
		AND #$0008 : BNE .NoBlock			; > if bit 3 is set, disable block update
		LDA.w !TileUpdateTable : BEQ .NoBlock		; | block updates (replaces stripe image)
		JSR .AppendTile					; |
		.NoBlock					;/
		STZ.w !TileUpdateTable				; always clear, even when not uploaded, to prevent overflow



	;
	; VR2 CGRAM block
	;
		JSR .AppendPalette



	;
	; light shader
	;
		LDA.l !LightBuffer-1 : BPL .NoLight		;\
		AND #$7FFF : STA.l !LightBuffer-1		; | if a new shade operation is complete, clear the flag and append it
		JSR .AppendLight				;/
		STZ.w !ShaderRowDisable+$0			;\
		STZ.w !ShaderRowDisable+$2			; |
		STZ.w !ShaderRowDisable+$4			; |
		STZ.w !ShaderRowDisable+$6			; |
		STZ.w !ShaderRowDisable+$8			; | clear temporary disable flags when the operation is complete
		STZ.w !ShaderRowDisable+$A			; |
		STZ.w !ShaderRowDisable+$C			; |
		STZ.w !ShaderRowDisable+$E			; |
		.NoLight					;/





	;
	; high priority big CCDMA block
	;
		PHY						; preserve RAMcode index
		LDA $0E
		PHD
		PEA $0100 : PLD					; DP = $0100 (to easily reach $3190)
		CMP #$0400					;\
		BCC $03 : LDA #$0400				; | bandwidth for high priority big CCDMA = 1KB
		STA $00						;/
		STA $04						; > backup of bandwidth for adjustment later
		LDX #$0000
		LDA $7F
		AND #$00FF
		ASL #3
		TAY
	.LoopBigCCDMA
		CPX #$0050 : BCC $03 : JMP .BigCCDMADone
		LDA !CCDMAtable+$00,y : BNE $03 : JMP .NextBigCCDMA	;\ check size
		CMP $00 : BCS $03 : JMP .AddBigCCDMA			;/ (if it fits normally, just upload it as is)
	.LimitBigCCDMA
		PHX
		LDA !CCDMAtable+$07,y
		AND #$001F
		ASL A
		TAX
		LDA.l .CCDMAminimum,x				; adjustment unit
		PLX
		CMP $00 : BCC $03 : JMP .NextBigCCDMA
	.AdjustBigCCDMA
		STA $02
	-	CLC : ADC $02
		CMP $00 : BCC -
		BEQ .AdjustedBigCCDMA
		SEC : SBC $02
	.AdjustedBigCCDMA
		STA $02						; adjusted size
		STA $90,x					; upload size this frame
		LDA !CCDMAtable+$06,y : STA $96,x		; write CCDMA settings with hi byte
		LDA !CCDMAtable+$00,y				;\
		SEC : SBC $90,x					; | adjust remaining upload size
		STA !CCDMAtable+$00,y				;/
		LDA !CCDMAtable+$03,y : STA $93,x		; bank
		LDA !CCDMAtable+$02,y : STA $92,x		; source address
		CLC : ADC $02					;\ adjust source address
		STA !CCDMAtable+$02,y				;/
		LDA !CCDMAtable+$05,y : STA $95,x		; dest VRAM
		ASL A						;\
		CLC : ADC $02					; | adjust dest VRAM
		LSR A						; |
		STA !CCDMAtable+$05,y				;/
		TXA						;\
		CLC : ADC #$0008				; | update output index
		TAX						; | and proceed to small CCDMA
		BRA .BigCCDMADone				;/
	; index = 2 * mode bits
	.CCDMAminimum
		dw $0040,$0020,$0010,$FFFF	; 8px
		dw $0080,$0040,$0020,$FFFF	; 16px
		dw $0100,$0080,$0040,$FFFF	; 32px
		dw $0200,$0100,$0080,$FFFF	; 64px
		dw $0400,$0200,$0100,$FFFF	; 128px
		dw $0800,$0400,$0200,$FFFF	; 256px
		dw $FFFF,$FFFF,$FFFF,$FFFF	; 512px, invalid
		dw $FFFF,$FFFF,$FFFF,$FFFF	; 1024px, invalid
	.AddBigCCDMA
		STA $90,x					; set size
		LDA $00						;\
		SEC : SBC $90,x					; | update remaining bandwidth
		STA $00						;/
		LDA #$0000 : STA !CCDMAtable+$00,y		; clear entry from table
		LDA !CCDMAtable+$06,y : STA $96,x		; write CCDMA settings with hi byte
		LDA !CCDMAtable+$02,y : STA $92,x		;\ source address
		LDA !CCDMAtable+$03,y : STA $93,x		;/
		LDA !CCDMAtable+$05,y : STA $95,x		; dest VRAM
		TXA						;\
		CLC : ADC #$0008				; | update output index
		TAX						;/
	.NextBigCCDMA
		TYA						;\
		CLC : ADC #$0008				; | update input index
		TAY						; | and loop
		CPY #$0080 : BCS $03 : JMP .LoopBigCCDMA	;/
	.BigCCDMADone
		TXA
		LSR #3
		SEP #$20
		STA $7F						; enable CCDMA for NMI
		REP #$20
		LDA $04						;\ initial bandwidth - remaining bandwidth = used bandwidth
		SEC : SBC $00					;/
		PLD						; restore DP
		SEC : SBC $0E					;\
		EOR #$FFFF : INC A				; | update remaining transfer size after CCDMA
		STA $0E						;/
		PLY						; restore RAMcode index


	;
	; square dynamo block
	;


	; DMA whole block of code at once
	; modify code, each tile using the next "slot"

		LDA.l !DynamicCount : BEQ .NoSquare
		JSR .AppendSquare
		.NoSquare


	;
	; VR2 VRAM block
	;
		JSR .AppendVR2



	;
	; small CCDMA block
	;
		PHY						; preserve RAMcode index
		LDA $0E
		PHD
		PEA $0100 : PLD
		STA $00
		STA $04
		LDA $7F
		AND #$00FF
		ASL #3
		TAX
		LDY #$0080
	.LoopSmallCCDMA
		CPX #$0050 : BCS .SmallCCDMADone
		LDA !CCDMAtable+$00,y : BEQ .NextSmallCCDMA
		CMP $00 : BCS .NextSmallCCDMA
		STA $90,x					; upload size
		LDA $00						;\
		SEC : SBC $90,x					; | remaining transfer size
		STA $00						;/
		LDA #$0000 : STA !CCDMAtable+$00,y		; > clear slot
		LDA !CCDMAtable+$06,y : STA $96,x		; write CCDMA settings with hi byte
		LDA !CCDMAtable+$02,y : STA $92,x		;\ source address
		LDA !CCDMAtable+$03,y : STA $93,x		;/
		LDA !CCDMAtable+$05,y : STA $95,x		; dest VRAM
		TXA						;\
		CLC : ADC #$0008				; | update output index
		TAX						;/
	.NextSmallCCDMA
		TYA						;\
		CLC : ADC #$0008				; | update input index
		TAY						; | and loop
		CPY #$0100 : BCC .LoopSmallCCDMA		;/
	.SmallCCDMADone
		; keep output index here


	;
	; low priority big CCDMA block
	;
		LDY #$0000
	.LoopFinalCCDMA
		CPX #$0050 : BCC $03 : JMP .FinalCCDMADone
		LDA !CCDMAtable+$00,y : BNE $03 : JMP .NextFinalCCDMA	;\ check size
		CMP $00 : BCS $03 : JMP .AddFinalCCDMA			;/ (if it fits normally, just upload it as is)
	.LimitFinalCCDMA
		PHX
		LDA !CCDMAtable+$07,y
		AND #$001F
		ASL A
		TAX
		LDA.l .CCDMAminimum,x				; adjustment unit
		PLX
		CMP $00 : BCC $03 : JMP .NextFinalCCDMA
	.AdjustFinalCCDMA
		STA $02
	-	CLC : ADC $02
		CMP $00 : BCC -
		BEQ .AdjustedFinalCCDMA
		SEC : SBC $02
	.AdjustedFinalCCDMA
		STA $02						; adjusted size
		STA $90,x					; upload size this frame
		LDA !CCDMAtable+$06,y : STA $96,x		; write CCDMA settings with hi byte
		LDA !CCDMAtable+$00,y				;\
		SEC : SBC $90,x					; | adjust remaining upload size
		STA !CCDMAtable+$00,y				;/
		LDA !CCDMAtable+$03,y : STA $93,x		; bank
		LDA !CCDMAtable+$02,y : STA $92,x		; source address
		CLC : ADC $02					;\ adjust source address
		STA !CCDMAtable+$02,y				;/
		LDA !CCDMAtable+$05,y : STA $95,x		; dest VRAM
		ASL A						;\
		CLC : ADC $02					; | adjust dest VRAM
		LSR A						; |
		STA !CCDMAtable+$05,y				;/
		TXA						;\
		CLC : ADC #$0008				; | update output index
		TAX						; | and proceed to small CCDMA
		BRA .FinalCCDMADone				;/
	.AddFinalCCDMA
		STA $90,x					; set size
		LDA $00						;\
		SEC : SBC $90,x					; | update remaining bandwidth
		STA $00						;/
		LDA #$0000 : STA !CCDMAtable+$00,y		; clear entry from table
		LDA !CCDMAtable+$06,y : STA $96,x		; write CCDMA settings with hi byte
		LDA !CCDMAtable+$02,y : STA $92,x		;\ source address
		LDA !CCDMAtable+$03,y : STA $93,x		;/
		LDA !CCDMAtable+$05,y : STA $95,x		; dest VRAM
		TXA						;\
		CLC : ADC #$0008				; | update output index
		TAX						;/
	.NextFinalCCDMA
		TYA						;\
		CLC : ADC #$0008				; | update input index
		TAY						; | and loop
		CPY #$0080 : BCS $03 : JMP .LoopFinalCCDMA	;/
	.FinalCCDMADone
		TXA
		LSR #3
		SEP #$20
		STA $7F
		REP #$20
		LDA $04						;\ initial bandwidth - remaining bandwidth = used bandwidth
		SEC : SBC $00					;/
		PLD						; restore DP
		SEC : SBC $0E					;\
		EOR #$FFFF : INC A				; | update remaining transfer size after CCDMA
		STA $0E						;/
		PLY						; restore RAMcode index


	;
	; ExAnimation block
	; NOTE: when reading this code, note that .l $0080 is bank 0 (I-RAM), but .w $0080 is bank $40 (same as $6080 (!BigRAM), BW-RAM)
		LDA !AnimToggle
		AND #$0004 : BNE .NoExAnimation
		%videoport($80)					; always use video port $80 for these
		LDA.w #FetchExAnim : STA.l $0183		;\
		LDA.w #FetchExAnim>>8 : STA.l $0184		; |
		SEP #$20					; |
		LDA #$D0 : STA.l $2209				; | request data from SNES WRAM
	-	LDA.l $018A : BEQ -				; | (dumped in $6180 since that can be accessed as $400180 by SA-1)
		LDA #$00 : STA.l $018A				; | (mirroring is OP)
		REP #$20					;/
		LDX #$0000
	.LoopExAnimation
		CPX #$0031 : BCS .NoExAnimation
		PEA.w .LoopExAnimation-1
		LDA.w $0080,x
		BEQ .NextExAnimation
		BMI ..pal
	..gfx	JMP .AppendExAnimationGFX
	..pal	JMP .AppendExAnimationPalette
	.NextExAnimation
		TXA
		CLC : ADC #$0007
		TAX
		RTS
		.NoExAnimation




		.EndCode
		LDA #$6B6B : STA.w !RAMcode,y			; end RAM code routine with RTL
		PLB						; restore bank
		STY !RAMcode_offset				; store RAM code offset
		LDA #$1234 : STA !RAMcode_flag			; enable RAM code execution


		SEP #$30
		RTS






; rough comparisons:
;
; cost of SA-1 DMA: 82 cycles + 1 cycle/byte
; cost of MVN/MVP: 33 cycles + 7 cycles/byte
; cost of %makecode(): 4.5 cycles/byte (9 cycles/word)
;
; MVN/MVP is faster than DMA if data is 8 bytes or less, but for data that small %makecode() outclasses both of them
; so... MVN/MVP is definitely completely useless
; %makecode() is faster than DMA if data is 23 bytes or less
; so the conclusion:
;	< 23 bytes, use %makecode()
;	> 23 bytes, use DMA
; (and never use MVN/MVP)

; for curiosity's sake, the old LDA.l,x : STA.w,y method was 21 cycles/word (10.5 cycles/byte), making it by far the worst option




; loop
;	check slot
;	branch: upload or download
;	%DMAsettings(depends on type: $1801, $1809 or $3981)
;	%videoport($80)
;	%makecode() is faster than DMA for this, since chunks are so small (even download at 26 bytes, since %makecode() can skip some bytes)
;	(insert data while making code)
;	update RAM code index




	.AppendVR2
		LDX.w !VRAMslot					; continue on last transfer

		..loop						;\
		LDA $0E : BEQ ..return				; | check slot
		LDA.w !VRAMtable+$00,x : BNE ..processslot	; | (always return if no bandwidth remaining)
		..next						;/
		TXA						;\
		CLC : ADC #$0007				; |
		CMP #$00FC					; | loop through entire table, regardless of entry point
		BCC $03 : LDA #$0000				; |
		TAX						; |
		CPX.w !VRAMslot : BNE ..loop			;/
		STZ.w !VRAMslot					; if entire table is processed, reset entry point to 0
		..return					;\ return
		RTS						;/

		..processslot
		AND #$8000 : STA $02				; background mode flag
		LDA.w !VRAMtable+$04,x : %sourcebankA()		; source bank for this transfer
		LDA.w !VRAMtable+$00,x				;\
		AND #$3FFF					; | get size without background mode flag or fixed flag
		STA $00						;/
		LDA.w !VRAMtable+$05,x : BMI ..download		; check up/download
		JMP ..upload

		..download
		STZ $04						; download doesn't have fixed mode
		%DMAsettings($3981)				; $2139, mode 0x81 (word downloads)
		%videoport($80)					; video port: word transfers
		!Temp = 0					; make new RAM code
		%makecode($00A9)				; LDA #$xxxx
		!Temp := !Temp+1				; skip hi byte since it will be written by modification
		%makecode($0285)				; STA $02
		%makecode($00A9)				; LDA #$xxxx
		!Temp := !Temp+1				; skip hi byte since it will be written by modification
		%makecode($0585)				; STA $05
		%makecode($00A9)				; LDA #$xxxx
		!Temp := !Temp+1				; skip hi byte since it will be written by modification
		%makecode($168D)				; STA $xx16
		%makecode($AD21)				; $21 (previous opcode) : LDA $xxxx (note: addr, not #const)
		%makecode($2139)				; $2139 (previous opcode)
		%makecode($008C)				; STY $xxxx
		!Temp := !Temp-1				; prevent overflow
		%makecode($420B)				; $420B (previous opcode)
		LDA.w #!Temp					; code size
		JMP ..shared					; go to shared

		..upload
		LDA.w !VRAMtable+$00,x				;\
		AND #$4000 : STA $04				; | fixed/normal mode
		BNE ..fixed					; |
		..normal					;/
		%DMAsettings($1801)				; 2118, 2 regs write once
		%videoport($80)					; video port: word transfers
		JMP ..handleupload				;
		..fixed						;
		LDA.w !VRAMtable+$04,x				;\
		AND #$00FF					; |
		CMP #$007E : BEQ ..fixedvariable		; |
		CMP #$007F : BEQ ..fixedvariable		; |
		CMP #$0040 : BEQ ..fixedvariable		; | if from ROM: 2118, 2 regs write once, video port: word transfers
		CMP #$0041 : BEQ ..fixedvariable		; |
		..fixednormal					; |
		%DMAsettings($1809)				; |
		%videoport($80)					; |
		JMP ..handleupload				;/
		..fixedvariable					; if from RAM...
		LDA.w !VRAMtable+$02,x				;
		AND #$0001 : BEQ ..fixedlo			; even: lo byte only, odd: hi byte only
		..fixedhi					;
		%DMAsettings($1908)				; 2119, 1 reg write once
		%videoport($80)					; video port: hi byte only
		BRA ..handleupload				;
		..fixedlo					;
		%DMAsettings($1808)				; 2119, 1 reg write once
		%videoport($00)					; video port: lo byte only
		..handleupload					;
		!Temp = 0					; make new RAM code
		%makecode($00A9)				; LDA #$xxxx
		!Temp := !Temp+1				; skip hi byte since it will be written by modification
		%makecode($0285)				; STA $02
		%makecode($00A9)				; LDA #$xxxx
		!Temp := !Temp+1				; skip hi byte since it will be written by modification
		%makecode($0585)				; STA $05
		%makecode($00A9)				; LDA #$xxxx
		!Temp := !Temp+1				; skip hi byte since it will be written by modification
		%makecode($168D)				; STA $xx16
		%makecode($8C21)				; $21 (previous opcode) : STY $xxxx
		%makecode($420B)				; $420B (previous opcode)
		LDA.w #!Temp					; code size

		..shared
		STA $06						; set code size
		LDA $0E						;\
		SEC : SBC $00					; | subtract transfer size from remaining bytes allowed
		BCC ..captransfer				;/

		..fulltransfer
		STA $0E						; store remaining transfer size allowed
		LDA.w !VRAMtable+$02,x : %writecode(..src)	; source address
		LDA $00 : %writecode(..size)			; upload size
		LDA.w !VRAMtable+$05,x				;\ VRAM address
		AND #$7FFF : %writecode(..vram)			;/
		LDA #$0000 : STA.w !VRAMtable+$00,x		; clear this slot
		TXA						;\
		CLC : ADC #$0007				; | add 7 to VRAM table index
		TAX						;/
		TYA						;\
		CLC : ADC $06					; | increase RAM code index
		TAY						;/
		JMP ..loop					; loop

		..captransfer
		EOR #$FFFF : INC A				;\
		ORA $02						; > include background mode flag
		ORA $04						; > include fixed mode flag
		STA.w !VRAMtable+$00,x				; |
		LDA $0E : %writecode(..size)			; |
		LDA.w !VRAMtable+$02,x : %writecode(..src)	; |
		BIT $04 : BVS +					; > don't update source for fixed mode
		CLC : ADC $0E					; |
		STA.w !VRAMtable+$02,x				; |
	+	LDA.w !VRAMtable+$05,x				; | if entire transfer can't fit, transfer as much as possible
		AND #$7FFF : %writecode(..vram)			; | (then update table to continue next frame)
		LDA $0E						; |
		LSR A						; |
		CLC : ADC.w !VRAMtable+$05,x			; |
		STA.w !VRAMtable+$05,x				; |
		STZ.w !VRAMslot					; |
		BIT $02 : BMI +					; > background mode transfers don't store their index
		STX.w !VRAMslot					;/
	+	STZ $0E						; clear remaining bytes allowed
		TYA						;\
		CLC : ADC $06					; | increase RAM code index
		TAY						;/
		RTS						; return


	; this is not read directly, it's just kept for reference
		..code
	..src	LDA.w #$0000 : STA $02				; source address
	..size	LDA.w #$0000 : STA $05				; upload size
	..vram	LDA.w #$0000 : STA $2116			; VRAM address
		; LDA.w $2139	; download only
		STY.w $420B					; DMA toggle
		..end


	.AppendTile
		%DMAsettings($1604)
		%videoport($80)
		%sourcebank(!VRAMbank)

		LDA #$00A9 : STA.w !RAMcode+$00,y		; LDA #$xxxx
		LDA.w !TileUpdateTable : STA.w !RAMcode+$01,y	; byte count from header
		!Temp = 3					; starting code make offset
		%makecode($0585)				; STA $05
		%makecode(!TileUpdateTable+2<<8+$A9)		; LDA #$xx[!TileUpdateTable+2]
		%makecode(!TileUpdateTable>>8+$8500)		; hi byte of !TileUpdateTable (previous opcode) : STA $xx
		%makecode($8C02)				; $02 (previous opcode) : STY $xxxx
		%makecode($420B)				; $420B (previous opcode)

		LDA $0E						;\
		SEC : SBC.w !TileUpdateTable			; | update remaining transfer size
		STA $0E						;/

		TYA						;\
		CLC : ADC.w #!Temp				; | increase RAM code index
		TAY						;/
		RTS


	.AppendSquare
		%DMAsettings($1801)
		%videoport($80)

		PHB : PHK : PLB					; bank wrapper start
		STZ $2250					;\
		LDA.w #..nexttile-..code : STA $2251		; | calculate number of bytes to DMA
		LDA !DynamicCount : STA $2253			;/
		XBA						;\
		LSR A						; |
		SEC : SBC $0E					; | update remaining transfer size
		EOR #$FFFF : INC A				; |
		STA $0E						;/
		STZ !DynamicCount				; > clear this for next frame
		LDA.w #..code : STA $2232			;\
		LDA $2306 : STA $2238				; |
		TYA						; |
		CLC : ADC.w #!RAMcode				; |
		STA $2235					; | copy code to RAM with SA-1 DMA
		SEP #$20					; |
		LDA #$90 : STA $220A				; > disable DMA IRQ
		LDA #$C4 : STA $2230				; > DMA settings
		LDA.b #..code>>16 : STA $2234			; > bank
		LDA.b #!RAMcode>>16 : STA $2237			; > dest bank (this write starts the DMA)
		STZ $2230					;/
		LDA #$F0 : STA $220B				; clear all IRQ flags
		LDA #$B0 : STA $220A				; enable DMA IRQ
		PLB						; bank wrapper end
		REP #$30					; all regs 16-bit

		LDX #$0000					; X = index to square data
	-	LDA.w !SquareTable+0,x : BEQ +			; check status
		%writecode(..src1)				; source address 1 lo + hi
		CLC : ADC #$0200				;\ source address 2 lo + hi
		%writecode(..src2)				;/
		SEP #$20					;\
		LDA.w !SquareTable+2,x : %writecode(..bnk)	; | source bank (always included because of clustered DMA)
		STA $08						;/ > save source bank for later codes
		REP #$20					;\
		PHX						; |
		TXA						; |
		LSR A						; |
		TAX						; | matrix address
		LDA.w !DynamicMatrix&$1FFF,x			; |
		ASL #4						; |
		ORA #$6000					; |
		PLX						;/
		%writecode(..vram1)				;\
		CLC : ADC #$0100				; | VRAM address 1 and 2
		%writecode(..vram2)				;/
		STZ.w !SquareTable+0,x				; clear this square
		TYA						;\
		CLC : ADC.w #..nexttile-..code			; | increase RAM code index
		TAY						;/
	+	INX #4						;\ loop through all 16 squares
		CPX #$0040 : BCC -				;/

		RTS

		..code
		; tile 0
	..bnk	LDX.b #$00 : STX $04				; source bank
	..src1	LDA.w #$0000 : STA $02				; source address
	..size1	LDA.w #$0040 : STA $05				; upload size (always 0x0040)
	..vram1	LDA.w #$0000 : STA $2116			; VRAM address
		STY.w $420B					; DMA toggle
	..src2	LDA.w #$0000 : STA $02				; source address
	..size2	LDA.w #$0040 : STA $05				; upload size (always 0x0040)
	..vram2	LDA.w #$0000 : STA $2116			; VRAM address
		STY.w $420B					; DMA toggle
		..nexttile
		; tile 1
		LDX.b #$00 : STX $04
		LDA.w #$0000 : STA $02
		LDA.w #$0040 : STA $05
		LDA.w #$0000 : STA $2116
		STY.w $420B
		LDA.w #$0000 : STA $02
		LDA.w #$0040 : STA $05
		LDA.w #$0000 : STA $2116
		STY.w $420B
		; tile 2
		LDX.b #$00 : STX $04
		LDA.w #$0000 : STA $02
		LDA.w #$0040 : STA $05
		LDA.w #$0000 : STA $2116
		STY.w $420B
		LDA.w #$0000 : STA $02
		LDA.w #$0040 : STA $05
		LDA.w #$0000 : STA $2116
		STY.w $420B
		; tile 3
		LDX.b #$00 : STX $04
		LDA.w #$0000 : STA $02
		LDA.w #$0040 : STA $05
		LDA.w #$0000 : STA $2116
		STY.w $420B
		LDA.w #$0000 : STA $02
		LDA.w #$0040 : STA $05
		LDA.w #$0000 : STA $2116
		STY.w $420B
		; tile 4
		LDX.b #$00 : STX $04
		LDA.w #$0000 : STA $02
		LDA.w #$0040 : STA $05
		LDA.w #$0000 : STA $2116
		STY.w $420B
		LDA.w #$0000 : STA $02
		LDA.w #$0040 : STA $05
		LDA.w #$0000 : STA $2116
		STY.w $420B
		; tile 5
		LDX.b #$00 : STX $04
		LDA.w #$0000 : STA $02
		LDA.w #$0040 : STA $05
		LDA.w #$0000 : STA $2116
		STY.w $420B
		LDA.w #$0000 : STA $02
		LDA.w #$0040 : STA $05
		LDA.w #$0000 : STA $2116
		STY.w $420B
		; tile 6
		LDX.b #$00 : STX $04
		LDA.w #$0000 : STA $02
		LDA.w #$0040 : STA $05
		LDA.w #$0000 : STA $2116
		STY.w $420B
		LDA.w #$0000 : STA $02
		LDA.w #$0040 : STA $05
		LDA.w #$0000 : STA $2116
		STY.w $420B
		; tile 7
		LDX.b #$00 : STX $04
		LDA.w #$0000 : STA $02
		LDA.w #$0040 : STA $05
		LDA.w #$0000 : STA $2116
		STY.w $420B
		LDA.w #$0000 : STA $02
		LDA.w #$0040 : STA $05
		LDA.w #$0000 : STA $2116
		STY.w $420B
		; tile 8
		LDX.b #$00 : STX $04
		LDA.w #$0000 : STA $02
		LDA.w #$0040 : STA $05
		LDA.w #$0000 : STA $2116
		STY.w $420B
		LDA.w #$0000 : STA $02
		LDA.w #$0040 : STA $05
		LDA.w #$0000 : STA $2116
		STY.w $420B
		; tile 9
		LDX.b #$00 : STX $04
		LDA.w #$0000 : STA $02
		LDA.w #$0040 : STA $05
		LDA.w #$0000 : STA $2116
		STY.w $420B
		LDA.w #$0000 : STA $02
		LDA.w #$0040 : STA $05
		LDA.w #$0000 : STA $2116
		STY.w $420B
		; tile 10
		LDX.b #$00 : STX $04
		LDA.w #$0000 : STA $02
		LDA.w #$0040 : STA $05
		LDA.w #$0000 : STA $2116
		STY.w $420B
		LDA.w #$0000 : STA $02
		LDA.w #$0040 : STA $05
		LDA.w #$0000 : STA $2116
		STY.w $420B
		; tile 11
		LDX.b #$00 : STX $04
		LDA.w #$0000 : STA $02
		LDA.w #$0040 : STA $05
		LDA.w #$0000 : STA $2116
		STY.w $420B
		LDA.w #$0000 : STA $02
		LDA.w #$0040 : STA $05
		LDA.w #$0000 : STA $2116
		STY.w $420B
		; tile 12
		LDX.b #$00 : STX $04
		LDA.w #$0000 : STA $02
		LDA.w #$0040 : STA $05
		LDA.w #$0000 : STA $2116
		STY.w $420B
		LDA.w #$0000 : STA $02
		LDA.w #$0040 : STA $05
		LDA.w #$0000 : STA $2116
		STY.w $420B
		; tile 13
		LDX.b #$00 : STX $04
		LDA.w #$0000 : STA $02
		LDA.w #$0040 : STA $05
		LDA.w #$0000 : STA $2116
		STY.w $420B
		LDA.w #$0000 : STA $02
		LDA.w #$0040 : STA $05
		LDA.w #$0000 : STA $2116
		STY.w $420B
		; tile 14
		LDX.b #$00 : STX $04
		LDA.w #$0000 : STA $02
		LDA.w #$0040 : STA $05
		LDA.w #$0000 : STA $2116
		STY.w $420B
		LDA.w #$0000 : STA $02
		LDA.w #$0040 : STA $05
		LDA.w #$0000 : STA $2116
		STY.w $420B
		; tile 15
		LDX.b #$00 : STX $04
		LDA.w #$0000 : STA $02
		LDA.w #$0040 : STA $05
		LDA.w #$0000 : STA $2116
		STY.w $420B
		LDA.w #$0000 : STA $02
		LDA.w #$0040 : STA $05
		LDA.w #$0000 : STA $2116
		STY.w $420B
		..end




	; always doing full DMA here saves cycles on 3-part transfer and loses cycles on 2-part transfer
	; checking before the DMA will save ~5 cycles on 2-part transfer and lose ~10 cycles on 3-part transfer
	.AppendRow1
		%DMAsettings($1801)
		%videoport($80)
		%sourcebank($00)

		PHB : PHK : PLB					;\
		LDA.w #..code : STA $2232			; |
		LDA.w #..end-..code : STA $2238			; | copy code to RAM with SA-1 DMA
		TYA						; |
		CLC : ADC.w #!RAMcode				; |
		STA $2235					; |
		SEP #$20					; |
		LDA #$90 : STA $220A				; > disable DMA IRQ
		LDA #$C4 : STA $2230				; > DMA settings
		LDA.b #..code>>16 : STA $2234			; > bank
		LDA.b #!RAMcode>>16 : STA $2237			; > dest bank (this write starts the DMA)
		STZ $2230					; |
		LDA #$F0 : STA $220B				; clear all IRQ flags
		LDA #$B0 : STA $220A				; enable DMA IRQ
		PLB						; |
		REP #$30					;/

		LDA $0E						;\
		SEC : SBC #$0050				; | update transfer size
		STA $0E						;/

		LDA.l !BG1ZipRowX				;\
		AND #$00F0					; | lowest 5 bits determined by x position (ignore 8px bit)
		STA $02						; > save this
		LSR #3						; |
		STA $00						;/
		LDA.l !BG1ZipRowY				;\
		AND #$00F8					; | following 5 bits determined by y position
		ASL #2						; |
		TSB $00						;/
		LDA.l !BG1ZipRowX				;\
		AND #$0100					; |
		ASL #2						; | determine which tilemap to use
		ORA $00						; |
		ORA.l !BG1Address				; |
		%writecode(..vram1)				;/
		EOR #$0400					;\
		AND #$FFE0					; | continue into next tilemap
		%writecode(..vram2)				;/
		EOR #$0400					;\ row 3
		%writecode(..vram3)				;/

		LDA $02
		LSR #2
		STA $02
		CMP #$0031 : BCC ..two				; only 2 rows if w < 33


; three:
; row 1: 6950+0, w bytes
; row 2: 6950+w, 64 bytes
; row 3: 6950+w+64, 16-w bytes

; two:
; row 1: 6950+0, w bytes
; row 2: 6950+w, 80-w bytes

		..three
		SEC : SBC #$0040
		EOR #$FFFF : INC A
		STA $02
		%writecode(..size1)
		LDA #$0040 : %writecode(..size2)
		LDA #$0010
		SEC : SBC $02
		%writecode(..size3)

		LDA $02
		CLC : ADC #$6950
		%writecode(..src2)
		CLC : ADC #$0040
		%writecode(..src3)

		TYA
		CLC : ADC.w #..end-..code
		TAY
		RTS



		..two
		SEC : SBC #$0040
		EOR #$FFFF : INC A
		%writecode(..size1)				; size of first row (32 - w)
		STA $02
		LDA #$0050
		SEC : SBC $02
		%writecode(..size2)				; size of second row (40 - (32 - w))

		LDA $02						;\
		CLC : ADC #$6950				; | source address of second row
		%writecode(..src2)				;/

		TYA						;\
		CLC : ADC.w #..end2-..code			; | increase RAM code index
		TAY						;/
		RTS


		..code
	..vram1	LDA #$0000 : STA $2116	; modify 0A-0B
	..src1	LDA #$6950 : STA $02	; modify 10-11
	..size1	LDA #$0050 : STA $05	; modify 15-16
		STY $420B		;
	..vram2	LDA #$0000 : STA $2116	; modify 1D-1E
	..src2	LDA #$6950 : STA $02	; modify 23-24
	..size2	LDA #$0050 : STA $05	; modify 28-29
		STY $420B		;
		..end2
	..vram3	LDA #$0000 : STA $2116	; modify 30-31
	..src3	LDA #$6950 : STA $02	; modify 36-37
	..size3	LDA #$0050 : STA $05	; modify 3B-3C
		STY $420B		;
		..end



	.AppendRow2
		%DMAsettings($1801)
		%videoport($80)
		%sourcebank($00)

		PHB : PHK : PLB					;\
		LDA.w #..code : STA $2232			; |
		LDA.w #..end-..code : STA $2238			; | copy code to RAM with SA-1 DMA
		TYA						; |
		CLC : ADC.w #!RAMcode				; |
		STA $2235					; |
		SEP #$20					; |
		LDA #$90 : STA $220A				; > disable DMA IRQ
		LDA #$C4 : STA $2230				; > DMA settings
		LDA.b #..code>>16 : STA $2234			; > bank
		LDA.b #!RAMcode>>16 : STA $2237			; > dest bank (this write starts the DMA)
		STZ $2230					; |
		LDA #$F0 : STA $220B				; clear all IRQ flags
		LDA #$B0 : STA $220A				; enable DMA IRQ
		PLB						; |
		REP #$30					;/

		LDA $0E						;\
		SEC : SBC #$0050				; | update transfer size
		STA $0E						;/

		LDA.l !BG2ZipRowX				;\
		AND #$00F0					; | lowest 5 bits determined by x position (ignore 8px bit)
		STA $02						; > save this
		LSR #3						; |
		STA $00						;/
		LDA.l !BG2ZipRowY				;\
		AND #$00F8					; | following 5 bits determined by y position
		ASL #2						; |
		TSB $00						;/
		LDA.l !BG2ZipRowX				;\
		AND #$0100					; |
		ASL #2						; | determine which tilemap to use
		ORA $00						; |
		ORA.l !BG2Address				; |
		%writecode(..vram1)				;/
		EOR #$0400					;\
		AND #$FFE0					; | continue into next tilemap
		%writecode(..vram2)				;/
		EOR #$0400					;\ row 3
		%writecode(..vram3)				;/

		LDA $02
		LSR #2
		STA $02
		CMP #$0031 : BCC ..two				; only 2 rows if w < 33


; three:
; row 1: 6150+0, w bytes
; row 2: 6150+w, 64 bytes
; row 3: 6150+w+64, 16-w bytes

; two:
; row 1: 6150+0, w bytes
; row 2: 6150+w, 80-w bytes

		..three
		SEC : SBC #$0040
		EOR #$FFFF : INC A
		STA $02
		%writecode(..size1)
		LDA #$0040 : %writecode(..size2)
		LDA #$0010
		SEC : SBC $02
		%writecode(..size3)

		LDA $02
		CLC : ADC #$69E0
		%writecode(..src2)
		CLC : ADC #$0040
		%writecode(..src3)

		TYA
		CLC : ADC.w #..end-..code
		TAY
		RTS



		..two
		SEC : SBC #$0040
		EOR #$FFFF : INC A
		%writecode(..size1)				; size of first row (32 - w)
		STA $02
		LDA #$0050
		SEC : SBC $02
		%writecode(..size2)				; size of second row (40 - (32 - w))

		LDA $02						;\
		CLC : ADC #$69E0				; | source address of second row
		%writecode(..src2)				;/

		TYA						;\
		CLC : ADC.w #..end2-..code			; | increase RAM code index
		TAY						;/
		RTS


		..code
	..vram1	LDA #$0000 : STA $2116	; modify 0A-0B
	..src1	LDA #$69E0 : STA $02	; modify 10-11
	..size1	LDA #$0050 : STA $05	; modify 15-16
		STY $420B		;
	..vram2	LDA #$0000 : STA $2116	; modify 1D-1E
	..src2	LDA #$69E0 : STA $02	; modify 23-24
	..size2	LDA #$0050 : STA $05	; modify 28-29
		STY $420B		;
		..end2
	..vram3	LDA #$0000 : STA $2116	; modify 30-31
	..src3	LDA #$69E0 : STA $02	; modify 36-37
	..size3	LDA #$0050 : STA $05	; modify 3B-3C
		STY $420B		;
		..end


	.AppendColumn1
		%DMAsettings($1801)
		%videoport($81)
		%sourcebank($00)

		PHB : PHK : PLB					;\
		LDA.w #..code : STA $2232			; |
		LDA.w #..end-..code : STA $2238			; | copy code to RAM with SA-1 DMA
		TYA						; |
		CLC : ADC.w #!RAMcode				; |
		STA $2235					; |
		SEP #$20					; |
		LDA #$90 : STA $220A				; > disable DMA IRQ
		LDA #$C4 : STA $2230				; > DMA settings
		LDA.b #..code>>16 : STA $2234			; > bank
		LDA.b #!RAMcode>>16 : STA $2237			; > dest bank (this write starts the DMA)
		STZ $2230					; |
		LDA #$F0 : STA $220B				; clear all IRQ flags
		LDA #$B0 : STA $220A				; enable DMA IRQ
		PLB						; |
		REP #$30					;/

		LDA $0E						;\
		SEC : SBC #$0040				; | update transfer size
		STA $0E						;/

		LDA.l !BG1ZipColumnX				;\
		AND #$00F8					; | lowest 5 bits determined by x position
		LSR #3						; |
		STA $00						;/
		LDA.l !BG1ZipColumnY				;\
		AND #$00F0					; | following 5 bits determined by y position (ignore 8px bit)
		STA $02						; > save this
		ASL #2						; |
		TSB $00						;/
		LDA.l !BG1ZipColumnX				;\
		AND #$0100					; |
		ASL #2						; | determine which tilemap to use
		ORA $00						; |
		ORA.l !BG1Address				; |
		%writecode(..vram1)				;/

	; h = start of first column (height of second column)
	; h = 32 - y (256 - y in pixels)
	; h = 0 -> skip first column
	; h = 32 -> skip second column

		AND #$F41F
		%writecode(..vram2)				; same, but y = 0
		LDA $02
		LSR #2
		STA $02 : BEQ ..one				; check if only 1 column should be used
		CMP #$0040 : BNE ..both

		..one
		TYA
		CLC : ADC.w #..end2-..code
		TAY
		RTS

		..both
		SEC : SBC #$0040
		EOR #$FFFF : INC A
		CLC : ADC #$6910
		%writecode(..src2)				; source address of second column
		LDA $02 : %writecode(..size2)			; second column = h tall
		SEC : SBC #$0040
		EOR #$FFFF : INC A
		%writecode(..size1)				; first column = 32 - h tall
		TYA						;\
		CLC : ADC.w #..end-..code			; | increase RAM code index
		TAY						;/
		RTS

		..code
	..vram1	LDA #$0000 : STA $2116	; modify 0F-10
	..src1	LDA #$6910 : STA $02	; modify 15-16
	..size1	LDA #$0040 : STA $05	; modify 1A-1B
		STY $420B		;
		..end2
	..vram2	LDA #$0000 : STA $2116	; modify 22-23
	..src2	LDA #$6910 : STA $02	; modify 28-29
	..size2	LDA #$0040 : STA $05	; modify 2D-2E
		STY $420B
		..end


	.AppendColumn2
		%DMAsettings($1801)
		%videoport($81)
		%sourcebank($00)

		PHB : PHK : PLB					;\
		LDA.w #..code : STA $2232			; |
		LDA.w #..end-..code : STA $2238			; | copy code to RAM with SA-1 DMA
		TYA						; |
		CLC : ADC.w #!RAMcode				; |
		STA $2235					; |
		SEP #$20					; |
		LDA #$90 : STA $220A				; > disable DMA IRQ
		LDA #$C4 : STA $2230				; > DMA settings
		LDA.b #..code>>16 : STA $2234			; > bank
		LDA.b #!RAMcode>>16 : STA $2237			; > dest bank (this write starts the DMA)
		STZ $2230					; |
		LDA #$F0 : STA $220B				; clear all IRQ flags
		LDA #$B0 : STA $220A				; enable DMA IRQ
		PLB						; |
		REP #$30					;/

		LDA $0E						;\
		SEC : SBC #$0040				; | update transfer size
		STA $0E						;/

		LDA.l !BG2ZipColumnX				;\
		AND #$00F8					; | lowest 5 bits determined by x position
		LSR #3						; |
		STA $00						;/
		LDA.l !BG2ZipColumnY				;\
		AND #$00F0					; | following 5 bits determined by y position (ignore 8px bit)
		STA $02						; > save this
		ASL #2						; |
		TSB $00						;/
		LDA.l !BG2ZipColumnX				;\
		AND #$0100					; |
		ASL #2						; | determine which tilemap to use
		ORA $00						; |
		ORA.l !BG2Address				; |
		%writecode(..vram1)				;/

	; h = start of first column (height of second column)
	; h = 32 - y (256 - y in pixels)
	; h = 0 -> skip first column
	; h = 32 -> skip second column

		AND #$FC1F
		%writecode(..vram2)				; same, but y = 0
		LDA $02
		LSR #2
		STA $02 : BEQ ..one				; check if only 1 column should be used
		CMP #$0040 : BNE ..both

		..one
		TYA
		CLC : ADC.w #..end3-..code
		TAY
		RTS

		..both
		SEC : SBC #$0040
		EOR #$FFFF : INC A
		CLC : ADC #$69A0
		%writecode(..src2)				; source address of second column
		LDA $02 : %writecode(..size2)			; second column = h tall
		SEC : SBC #$0040
		EOR #$FFFF : INC A
		%writecode(..size1)				; first column = 32 - h tall
		TYA						;\
		CLC : ADC.w #..end-..code			; | increase RAM code index
		TAY						;/
		RTS

		..code
	..vram1	LDA #$0000 : STA $2116	; modify 0F-10
	..src1	LDA #$69A0 : STA $02	; modify 15-16
	..size1	LDA #$0040 : STA $05	; modify 1A-1B
		STY $420B		;
		..end3
	..vram2	LDA #$0000 : STA $2116	; modify 22-23
	..src2	LDA #$69A0 : STA $02	; modify 28-29
	..size2	LDA #$0040 : STA $05	; modify 2D-2E
		STY $420B
		..end2
		..end



	.AppendBackground
		%DMAsettings($1801)
		%videoport($80)
		%sourcebank(!BG2Tilemap>>16)

		PHB : PHK : PLB					;\
		LDA.w #..code : STA $2232			; |
		LDA.w #..end-..code : STA $2238			; | copy code to RAM with SA-1 DMA
		TYA						; |
		CLC : ADC.w #!RAMcode				; |
		STA $2235					; |
		SEP #$20					; |
		LDA #$90 : STA $220A				; > disable DMA IRQ
		LDA #$C4 : STA $2230				; > DMA settings
		LDA.b #..code>>16 : STA $2234			; > bank
		LDA.b #!RAMcode>>16 : STA $2237			; > dest bank (this write starts the DMA)
		STZ $2230					; |
		LDA #$F0 : STA $220B				; clear all IRQ flags
		LDA #$B0 : STA $220A				; enable DMA IRQ
		PLB						; |
		REP #$30					;/

		LDA $0E						;\
		SEC : SBC #$0080				; | update transfer size
		STA $0E						;/

		LDA.l !BG2ZipRowY				;\
		AND #$01F8					; |
		ASL #3						; |
		CLC : ADC.w #!BG2Tilemap			; | read directly from the raw copy of the BG2 tilemap
		%writecode(..src1)				; | (note that the raw is twice as large as the VRAM space)
		CLC : ADC #$1000				; |
		%writecode(..src2)				;/

		LDA.l !BG2ZipRowY				;\
		AND #$00F8					; |
		ASL #2						; |
		ORA.l !BG2Address				; | VRAM address
		%writecode(..vram1)				; |
		EOR #$0400					; |
		%writecode(..vram2)				;/

		TYA
		CLC : ADC.w #..end-..code
		TAY
		RTS


		..code
	..vram1	LDA #$0000 : STA $2116		; modify 0A-0B
	..src1	LDA #$0000 : STA $02		; modify 10-11
	..size1	LDA #$0040 : STA $05
		STY $420B
	..vram2	LDA #$0000 : STA $2116		; modify 1D-1E
	..src2	LDA #$0000 : STA $02		; modify 23-24
	..size2	LDA #$0040 : STA $05
		STY $420B
		..end


	.AppendPalette
		LDX #$0000

		..loop
		LDA.w !CGRAMtable+$00,x : BNE ..process
		TXA
		CLC : ADC #$0006
		TAX
		CMP #$00FC : BCC ..loop
		RTS

		..process
		%DMAsettings($2202)
		LDA.w !CGRAMtable+$04,x : %sourcebankA()

		!Temp = 0					; make new RAM code
		%makecode($00A9)				; LDA #$xxxx
		!Temp := !Temp+1				; skip hi byte since it will be written by modification
		%makecode($0285)				; STA $02
		%makecode($00A9)				; LDA #$xxxx
		!Temp := !Temp+1				; skip hi byte since it will be written by modification
		%makecode($0585)				; STA $05
		%makecode($00A2)				; LDX #$xx
		%makecode($218E)				; STX $xx21
		%makecode($8C21)				; $21 (previous opcode) : STY $xxxx
		%makecode($420B)				; $420B (previous opcode)

		LDA.w !CGRAMtable+$02,x : %writecode(..src)	; source address
		SEP #$20					;\
		LDA.w !CGRAMtable+$05,x : %writecode(..cgram)	; | destination CGRAM
		REP #$20					;/
		LDA.w !CGRAMtable+$00,x : %writecode(..size)	; upload size
		LDA $0E						;\
		SEC : SBC.w !CGRAMtable+$00,x			; | update transfer size
		STA $0E						;/
		STZ.w !CGRAMtable+$00,x				; clear this slot

		TYA						;\
		CLC : ADC.w #..end-..code			; | increase RAM code index
		TAY						;/

		..next
		TXA						;\
		CLC : ADC #$0006				; | add 6 to CGRAM table index
		CMP #$00FC : BCS ..return			; |
		TAX						;/
		JMP ..loop

		..return
		RTS

	; this code is not inserted, just here as reference (read by %writecode macro)
		..code
	..src	LDA #$0000 : STA $02
	..size	LDA #$0000 : STA $05
	..cgram	LDX #$00 : STX $2121
		STY $420B
		..end


	; .AppendSMWPalette
		; !Temp = 0					; new RAM code
		; %makecode($64A2)				; LDX #$64
		; %makecode($218E)				; STX $xx21
		; %makecode($A221)				; $21xx : LDX #
		; LDA $14						;\
		; AND #$001C					; |
		; LSR A						; | read color data
		; TAX						; |
		; LDA.l $00B60C,x					;/
		; STA.w !RAMcode+$06,y				; > first half of color (lo byte)
		; STA.w !RAMcode+$0B-1,y				; > second half of color (hi byte)
		; !Temp := !Temp+1				; skip 1 byte (8-bit color value)
		; %makecode($228E)				; STX $xx22
		; %makecode($A221)				; $21xx : LDX #
		; !Temp := !Temp+1				; skip 1 byte (8-bit color value)
		; %makecode($008E)				; STX $xxxx
		; !Temp := !Temp-1				; prevent overflow
		; %makecode($2122)				; $2122
		; TYA						;\
		; CLC : ADC.w #!Temp				; | increment RAM code index
		; TAY						;/
		; RTS



	.AppendLight
		%DMAsettings($2202)
		%sourcebank(!LightData_SNES>>16)
		PHD						; push DP
		LDA #$0100 : TCD				; access !LightList on DP
		LDA.b !LightIndexStart				;\
		ASL #3						; |
		XBA						; | X = !LightList index
		AND #$000F					; |
		TAX						;/
	-	LDA.b !LightList,x				;\
		ORA.w !ShaderRowDisable,x			; | see if this row is excluded or disabled for this op
		AND #$00FF : BEQ ..includethis			;/
		..exclude					;\
		INX						; | loop through list
		CPX #$0010 : BCC -				; |
		PLD						; |
		RTS						;/

		..includethis					; include code
		!Temp = 0					; new RAM code
		%makecode($00A9)				; LDA #$xxxx
		!Temp := !Temp-1				; write to xxxx
		LDA.b !LightBuffer-1				;\
		AND #$0100					; |
		EOR #$0100					; |
		ASL A						; |
		ADC.w #!LightData_SNES+2			; | source address (skip first transparent color)
		STA.w !RAMcode+!Temp,y				; | (takes the place of previous XXXX)
		TXA						; |
		XBA						; |
		LSR #3						; |
		CLC : ADC.w !RAMcode+!Temp,y			; |
		STA.w !RAMcode+!Temp,y				;/
		!Temp := !Temp+2				; advance offset
		%makecode($0285)				; STA $02
		%makecode($1EA9)				; LDA #$xx1E
		%makecode($8500)				; $00 (previous opcode) : STA $xx
		%makecode($A205)				; $05 (previous opcode) : LDX #$xx
		TXA						;\
		ASL #4						; | dest CGRAM (previous opcode) : STX $xxxx
		ORA #$8E01					; |
		STA.w !RAMcode+!Temp,y				;/
		!Temp := !Temp+2				; advance offset
		%makecode($2121)				; $2121 (previous opcode)
		%makecode($008C)				; STY $xxxx
		!Temp := !Temp-1				; write to xxxx
		%makecode($420B)				; $420B (previous opcode)

		LDA.l $0E					;\
		SEC : SBC #$001E				; | update remaining size
		STA.l $0E					;/

	-	INX						;\
		CPX #$0010 : BCS ..done				; |
		LDA.b !LightList,x				; |
		ORA.w !ShaderRowDisable,x			; |
		AND #$00FF : BNE ..next				; | increment upload size to minimize number of uploads
		LDA.w !RAMcode+$06,y				; |
		CLC : ADC #$0020				; |
		STA.w !RAMcode+$06,y				; |
		LDA.l $0E					; |
		SEC : SBC #$0020				; > update size remaining 
		STA.l $0E					; |
		BRA -						;/

		..next						;\
		TYA						; |
		CLC : ADC.w #!Temp				; | add another upload
		TAY						; |
		JMP ..exclude					;/

		..done
		TYA						;\
		CLC : ADC.w #!Temp				; | increment RAM code index
		TAY						;/
		PLD						; restore DP
		RTS						; return


	.AppendSMW0D7C
		%DMAsettings($1801)				;\ base settings
		%videoport($80)					;/

		!Temp = 0					; new RAM code
		%makecode($00A9)				; LDA #$xxxx
		!Temp := !Temp-1				;\ VRAM address (previous opcode)
		LDA.l $6D7C : STA.w !RAMcode+!Temp,y		;/
		!Temp := !Temp+2				; increment index
		%makecode($168D)				; STA $xx16
		%makecode($A921)				; $21 (previous opcode) : LDA #$xxxx
		LDA.l $6D76					;\
		CLC : ADC.l !FileAddress+0			; | source address (previous opcode)
		SEC : SBC #$7D00				; |
		STA.w !RAMcode+!Temp,y				;/
		!Temp := !Temp+2				; increment index
		%makecode($0285)				; STA $02
		%makecode($80A9)				; LDA #$xx80
		%makecode($8500)				; $00 (previous opcode) : STA $xx
		%makecode($8C05)				; $05 (previous opcode) : STY $xxxx
		%makecode($420B)				; $420B (previous opcode)
		LDA $0E						;\
		SEC : SBC #$0080				; | update transfer size
		STA $0E						;/
		TYA						;\
		CLC : ADC.w #!Temp				; | increment RAM code index
		TAY						;/
		RTS						; return

		..code
	..vram1	LDA #$0000 : STA $2116		;\
	..src1	LDA #$0000 : STA $02		; | 0x80 bytes from $6D76 -> $6D7C
		LDA #$0080 : STA $05		; |
		STY $420B			;/
		..end


	.AppendSMW0D7E
		%DMAsettings($1801)				;\ base settings
		%videoport($80)					;/

		!Temp = 0					; new RAM code
		%makecode($00A9)				; LDA #$xxxx
		!Temp := !Temp-1				;\ VRAM address (previous opcode)
		LDA.l $6D7E : STA.w !RAMcode+!Temp,y		;/
		!Temp := !Temp+2				; increment index
		%makecode($168D)				; STA $xx16
		%makecode($A921)				; $21 (previous opcode) : LDA #$xxxx
		LDA.l $6D78					;\
		CLC : ADC.l !FileAddress+0			; | source address (previous opcode)
		SEC : SBC #$7D00				; |
		STA.w !RAMcode+!Temp,y				;/
		!Temp := !Temp+2				; increment index
		%makecode($0285)				; STA $02
		%makecode($80A9)				; LDA #$xx80
		%makecode($8500)				; $00 (previous opcode) : STA $xx
		%makecode($8C05)				; $05 (previous opcode) : STY $xxxx
		%makecode($420B)				; $420B (previous opcode)
		LDA $0E						;\
		SEC : SBC #$0080				; | update transfer size
		STA $0E						;/
		TYA						;\
		CLC : ADC.w #!Temp				; | increment RAM code index
		TAY						;/
		RTS						; return

		..code
	..bnk	LDX #$00 : STX $04		; bank
	..vram	LDA #$0000 : STA $2116		;\
	..src	LDA #$0000 : STA $02		; | 0x80 bytes from $6D78 -> $6D7E
		LDA #$0080 : STA $05		; |
		STY $420B			;/
		..end


	.AppendSMW0D80
		%DMAsettings($1801)				;\ base settings
		%videoport($80)					;/

		!Temp = 0					; new RAM code
		%makecode($00A9)				; LDA #$xxxx
		!Temp := !Temp-1				;\ VRAM address (previous opcode)
		LDA.l $6D80 : STA.w !RAMcode+!Temp,y		;/
		!Temp := !Temp+2				; increment index
		%makecode($168D)				; STA $xx16
		%makecode($A921)				; $21 (previous opcode) : LDA #$xxxx
		LDA.l $6D7A					;\
		CLC : ADC.l !FileAddress+0			; | source address (previous opcode)
		SEC : SBC #$7D00				; |
		STA.w !RAMcode+!Temp,y				;/
		!Temp := !Temp+2				; increment index
		%makecode($0285)				; STA $02
		%makecode($80A9)				; LDA #$xx80
		%makecode($8500)				; $00 (previous opcode) : STA $xx
		%makecode($8C05)				; $05 (previous opcode) : STY $xxxx
		%makecode($420B)				; $420B (previous opcode)
		LDA $0E						;\
		SEC : SBC #$0080				; | update transfer size
		STA $0E						;/
		TYA						;\
		CLC : ADC.w #!Temp				; | increment RAM code index
		TAY						;/
		RTS						; return

		..code
	..vram	LDA #$0000 : STA $2116		;\
	..src	LDA #$0000 : STA $02		; | 0x80 bytes from $6D7A -> $6D80
		LDA #$0080 : STA $05		; |
		STY $420B			;/
		..end


; DMA
;	$6D7A	0x80 B	->	$6D80
;	$6D78	0x80 B	->	$6D7E
;	$6D76	0x80 B	->	$6D7C
;
; source bank is always $7E
; if the destination address is set to 0, the upload should be terminated
;
; special case: $6D7C = 0x0800
;	$6D76	0x40 B	->	0x0800
;	+0x40	0x40 B	->	0x0900
; followed by special color code:
;	LDA #$64 : STA $2121
;	LDA $14
;	AND #$1C
;	LSR A
;	TAY
;	LDA $B60C,y : STA $2122
;	LDA $B60D,y : STA $2122
;
; this updates color 0x64, which is the flashing Yoshi Coin color
;
; frame 0
; 0x0000
; 0x0000
; 0x0400 - depends on tileset
; frame 1
; 0x0000
; 0x0000
; 0x0000
; frame 2
; 0x0680 - still turn block
; 0x0640 - note block
; 0x0600 - ?block (normal)
; frame 3
; 0x0800 - berry, upper tile (special case that also updates lower tile)
; 0x0EA0 - turning block (our brick)
; 0x0740 - midway gate
; frame 4
; 0x0580 - solid brown block
; 0x0540 - coin that shows up with P
; 0x0500 - upper half of door, for some reason
; frame 5
; 0x07C0 - completely unused
; 0x0780 - ?block that shows up with P
; 0x05C0 - muncher
; frame 6
; 0x0700 - water
; 0x06C0 - coin
; 0x0DA0 - on/off block
; frame 7
; 0x0480 - depends on tileset
; 0x0440 - depends on tileset
; 0x04C0 - depends on tileset (usually lava)
;

	.AppendMario	; GFX + palette (palette scrapped, now handled by palset loader)
		%DMAsettings($1801)
		%videoport($80)

		PHY
		LDY.w #!File_Mario : JSL !GetFileAddress
		PLY
		LDA.l !FileAddress+2 : %sourcebankA()

		PHB : PHK : PLB					;\
		LDA.w #..code : STA $2232			; |
		LDA.w #..end-..code : STA $2238			; | copy code to RAM with SA-1 DMA
		TYA						; |
		CLC : ADC.w #!RAMcode				; |
		STA $2235					; |
		SEP #$20					; |
		LDA #$90 : STA $220A				; > disable DMA IRQ
		LDA #$C4 : STA $2230				; > DMA settings
		LDA.b #..code>>16 : STA $2234			; > bank
		LDA.b #!RAMcode>>16 : STA $2237			; > dest bank (this write starts the DMA)
		STZ $2230					; |
		LDA #$F0 : STA $220B				; clear all IRQ flags
		LDA #$B0 : STA $220A				; enable DMA IRQ
		PLB						; |
		REP #$30					;/

		LDA $0E						;\
		SEC : SBC #$0200				; | update transfer size
		STA $0E						;/

		LDA.l !MarioGFX1 : %writecode(..vram1)		; VRAM address for upper half
		LDA.l $6D85					;\
		CLC : ADC.l !FileAddress+0			; | source address 1
		%writecode(..src1)				;/
		LDA.l $6D87					;\
		CLC : ADC.l !FileAddress+0			; | source address 2
		%writecode(..src2)				;/
		LDA.l $6D89					;\
		CLC : ADC.l !FileAddress+0			; | source address 3
		%writecode(..src3)				;/

		LDA.l !MarioGFX2 : %writecode(..vram2)		; VRAM address for lower half
		LDA.l $6D8F					;\
		CLC : ADC.l !FileAddress+0			; | source address 4
		%writecode(..src4)				;/
		LDA.l $6D91					;\
		CLC : ADC.l !FileAddress+0			; | source address 5
		%writecode(..src5)				;/
		LDA.l $6D93					;\
		CLC : ADC.l !FileAddress+0			; | source address 6
		%writecode(..src6)				;/

		TYA						;\
		CLC : ADC.w #..end-..code			; | increment RAM code index
		TAY						;/
		RTS


		..code
	..vram1	LDA #$0000 : STA $2116		; this applies for the next 4 transfers (!MarioGFX1)
	..src1	LDA #$0000 : STA $02		;\
		LDA #$0040 : STA $05		; | $6D85 -> !MarioGFX1
		STY $420B			;/
	..src2	LDA #$0000 : STA $02		;\
		LDA #$0040 : STA $05		; | $6D87 -> !MarioGFX1 + 0x40
		STY $420B			;/
	..src3	LDA #$0000 : STA $02		;\
		LDA #$0040 : STA $05		; | $6D89 -> !MarioGFX1 + 0x80
		STY $420B			;/
	..vram2	LDA #$0000 : STA $2116		; this applies for the next 3 transfers (!MarioGFX2)
	..src4	LDA #$0000 : STA $02		;\
		LDA #$0040 : STA $05		; | $6D8F -> !MarioGFX1
		STY $420B			;/
	..src5	LDA #$0000 : STA $02		;\
		LDA #$0040 : STA $05		; | $6D91 -> !MarioGFX1 + 0x40
		STY $420B			;/
	..src6	LDA #$0000 : STA $02		;\
		LDA #$0040 : STA $05		; | $6D93 -> !MarioGFX1 + 0x80
		STY $420B			;/
		..end



; $6D84 - number of Mario tiles (if 0, palette will not be updated either)
; $6D82 - holds the address of Mario's palette (bank = $00)
; $6D85 - holds 10 16-bit addresses to Mario's tiles (bank = $7E)
; $6D99 - holds the address of tile 0x7F (bank = $7E)
; for all upper VRAM addresses, add !MarioGFX1 and for all lower VRAM addresses, add !MarioGFX2
; destination CGRAM for Mario's palette is !MarioPropOffset & 0x0E * 8 + 0x86
;
; DMA
;	!MarioPalData	0x14 B	->	0x86 or 0x96 (!MarioPropOffset & 0x0E * 8 + 0x86)
;
;	$6D85		0x40 B	->	!MarioGFX1
;	$6D87		0x40 B	->	[not updated]
;	$6D89		0x40 B	->	[not updated]
;	$6D8B		0x40 B	->	[not updated]
;
;	$6D8F		0x40 B	->	!MarioGFX2
;	$6D91		0x40 B	->	[not updated]
;	$6D93		0x40 B	->	[not updated]
;	$6D95		0x40 B	->	[not updated]
;
;	$6D99		0x20 B	->	!MarioGFX1 + 0x70





;
; attempt at BG1 tilemap update replacement
;
; get a column at an arbitrary distance outside the screen, then get the data like:
;
;
; when we get here, coordinates of BG1/BG2 are stored in the BG zip row registers
; overwriting these are fine since they're not used in anything else
; but they have to be used to determine which side to update
;
; procedure to get layer 2 background data:
;	- have SNES fetch map16 numbers from $7FBC00 and $7FC300 into $3700 (64 bytes)
;	- highest nybble (-8) is used as an index to !Map16BG (24-bit pointers)
;	- rest of number is multiplied by 8 and used to index the pointer
;	- compile tilemap data into BG2 buffer
;
; layer 2 level is easier to read (because it's in BWRAM) but more complex to understand
;	- the level's width is halved, and layer 2 uses the second half of the map16
;	- layer 2 map16 is stored att offset [level height] * [level width] / 2
;	- if level width is odd, it is reduced by 1 and the layer 2 data is aligned to the end of the table
;	- this means that the offset formula becomes:
;		[level height] * ([level width] - 1) + [level height] * 16
;	  or, more streamlined:
;		[level height] * ([level width] + 15)
;
; or you can just use the $6C26 pointer, which *supposedly* points to the start of the layer 2 data
; (only on horizontal levels though, on vertical levels layer 2 data always starts at address $E400 / offset $1C00)
;


	.AppendExAnimationGFX
		%DMAsettings($1801)				; DMA settings
		LDA.w $0086,x : %sourcebankA()			; source bank

		LDA.w $0082,x : BPL ..row			; check type
		JMP ..square

		..row
		!Temp = 0					; new RAM code
		%makecode($00A9)				; LDA #$xxxx
		!Temp := !Temp-1				;\ source address (previous opcode)
		LDA.w $0084,x : STA.w !RAMcode+!Temp,y		;/
		!Temp := !Temp+2				; increase RAM code index
		%makecode($0285)				; STA $02
		%makecode($00A9)				; LDA #$xxxx
		!Temp := !Temp-1				;\ upload size (previous opcode)
		LDA.w $0080,x : STA.w !RAMcode+!Temp,y		;/
		!Temp := !Temp+2				; increase RAM code index
		%makecode($0585)				; STA $05
		%makecode($00A9)				; LDA #$xxxx
		!Temp := !Temp-1				;\ VRAM address (previous opcode)
		LDA.w $0082,x : STA.w !RAMcode+!Temp,y		;/
		!Temp := !Temp+2				; increase RAM code index
		%makecode($168D)				; STA $xx16
		%makecode($8C21)				; $21 (previous opcode) : STY $xxxx
		%makecode($420B)				; $420B (previous opcode)

		LDA $0E						;\
		SEC : SBC.w $0080,x				; | update remaining size
		STA $0E						;/
		STZ.w $0080,x					; clear exanim slot
		TYA						;\
		CLC : ADC.w #!Temp				; | increase RAM code index
		TAY						;/
		TXA						;\
		CLC : ADC #$0007				; | increase exanimation index
		TAX						;/
		RTS						; return


		..square
		LDA.w $0086,x : %sourcebankA()			; source bank

		PHB : PHK : PLB					;\
		LDA.w #..code : STA $2232			; |
		LDA.w #..end-..code : STA $2238			; | copy code to RAM with SA-1 DMA
		TYA						; |
		CLC : ADC.w #!RAMcode				; |
		STA $2235					; |
		SEP #$20					; |
		LDA #$90 : STA $220A				; > disable DMA IRQ
		LDA #$C4 : STA $2230				; > DMA settings
		LDA.b #..code>>16 : STA $2234			; > bank
		LDA.b #!RAMcode>>16 : STA $2237			; > dest bank (this write starts the DMA)
		STZ $2230					; |
		LDA #$F0 : STA $220B				; clear all IRQ flags
		LDA #$B0 : STA $220A				; enable DMA IRQ
		PLB						; |
		REP #$30					;/

	;	LDA.w $0080,x
	;	%writecode(..size1)
	;	%writecode(..size2)
		LDA.w $0082,x : %writecode(..vram1)
		CLC : ADC #$0100
		%writecode(..vram2)
		LDA.w $0084,x : %writecode(..src1)
		CLC : ADC #$0040
		%writecode(..src2)

		LDA $0E						;\
		SEC : SBC.w $0080,x				; | update remaining size
		STA $0E						;/
		STZ.w $0080,x					; clear exanim slot
		TYA						;\
		CLC : ADC.w #..end-..code			; | increase RAM code index
		TAY						;/
		TXA						;\
		CLC : ADC #$0007				; | increase exanimation index
		TAX						;/
		RTS						; return

		..code
	..src1	LDA.w #$0000 : STA $02				; source address
	..size1	LDA.w #$0040 : STA $05				; upload size
	..vram1	LDA.w #$0000 : STA $2116			; VRAM address
		STY.w $420B					; DMA toggle
	..src2	LDA.w #$0000 : STA $02				; address (DMA settings + bank are the same)
	..size2	LDA.w #$0040 : STA $05				; upload size
	..vram2	LDA.w #$0000 : STA $2116			; reset address (1 row below so can't use continuous)
		STY.w $420B					; DMA toggle
		..end


	.AppendExAnimationPalette
		..feedshader
		; LDA.w $0080,x					;\ number of colors to transfer
		; AND #$00FF : STA $04				;/
		; PHX						; push X
		; LDA.l !ProcessLight				;\
		; ORA #$0080					; | SA-1 writing to shader input
		; STA.l !ProcessLight				;/
		; LDA.w $0084,x					;\
		; SEC : SBC #$0202				; |
		; TAX						; | copy color data to shader input
	; -	LDA.l !PaletteRGB,x : STA.l !ShaderInput,x	; |
		; INX #2						; |
		; DEC $04 : BPL -					;/
		; LDA.l !ProcessLight				;\
		; AND.w #$0080^$FFFF				; | SA-1 no longer writing to shader input
		; STA.l !ProcessLight				;/
		; PLX						; pull X
		LDA #$0100					;\
		CMP.l !LightR : BNE ..return			; | if no light is enabled, upload colors raw
		CMP.l !LightG : BNE ..return			; | (preshading exanimation is too expensive, just feed it to shader and wait 2-3 frames)
		CMP.l !LightB : BEQ ..upload			;/
		..return
		STZ.w $0080,x					; clear exanim slot
		TXA						;\
		CLC : ADC #$0007				; | increase exanimation index
		TAX						;/
		RTS						; return

		..upload
		%DMAsettings($2202)				; DMA settings
		LDA.w $0086,x : %sourcebankA()			; source bank
		!Temp = 0					; make new RAM code
		%makecode($00A9)				; LDA #$xxxx
		!Temp := !Temp+1				; skip hi byte since it will be written by modification
		%makecode($0285)				; STA $02
		%makecode($00A9)				; LDA #$xxxx
		!Temp := !Temp+1				; skip hi byte since it will be written by modification
		%makecode($0585)				; STA $05
		%makecode($00A2)				; LDX #$xx
		%makecode($218E)				; STX $xx21
		%makecode($8C21)				; $21 (previous opcode) : STY $xxxx
		%makecode($420B)				; $420B (previous opcode)
		LDA.w $0084,x					;\
		SEC : SBC #$0202				; | source address
		%writecode(..src)				;/

	if !Debug
	STA $00
	STZ $02
	LDA [$00] : STA.l !P1Coins
	endif

		SEP #$20					;\
		LDA.w $0082,x : %writecode(..cgram)		; | destination CGRAM
		REP #$20					;/
	PHX
	LSR #4
	AND #$000F
	TAX
	LDA.l !ShaderRowDisable,x
	ORA #$0001 : STA.l !ShaderRowDisable,x
	PLX
		LDA.w $0080,x					;\
		ASL A						; | upload size
		%writecode(..size)				;/
		SEC : SBC $0E					;\
		EOR #$FFFF : INC A				; | update transfer size
		STA $0E						;/
		TYA						;\
		CLC : ADC.w #..end-..code			; | increase RAM code index
		TAY						;/
		STZ.w $0080,x					; clear exanim slot
		TXA						;\
		CLC : ADC #$0007				; | increase exanimation index
		TAX						;/
		RTS						; return

	; this code is not inserted, just here as reference (read by %writecode macro)
		..code
	..src	LDA #$0000 : STA $02
	..size	LDA #$0000 : STA $05
	..cgram	LDX #$00 : STX $2121
		STY $420B
		..end



; LM has:
; 32 global exanim slots
; 32 level exanim slots
; 16 manual triggers (value is which frame should be displayed)
; 16 custom triggers (0 = don't run animation, 1 = run animation)
; 32 one shot triggers (same as custom, but the bit is cleared once the animation is finished)


; so we have quite a bit of RAM to document before we can use this!
; (bank $7F)
; $C070-$C07F: manual exanim triggers (1 byte/trigger)
; $C080-$C09F: level exanim frame counter (1 byte/slot)
; $C0A0-$C0BF: global exanim frame counter (1 byte/slot)
; $C0F8-$C0FB: one shot exanim triggers (1 bit/trigger)
; $C0FC-$C0FD: exanim custom triggers (1 bit/trigger)

; unknown:
; $C000-$C06F: 112 bytes
; $C0C0-$C0F7: 56 bytes
; $C0FE-$C0FF: 2 bytes

; seemingly:
; $C000: 24-bit	pointer to anim data (index 0 will read the first pointer, so the header is skipped)
; $C003: 8-bit	copy of frame counter ($14)
; $C004: 8-bit	$C019 / 8
; sometimes 0xFFFF is stored to $C003, overwriting both of these
; $C005: unknown
; $C006: 24-bit	pointer used during level load, eventually stored to $8A (presumably this is a pointer to compressed GFX)
; $C009: 8-bit	used during level load
; $C00A: 8-bit	written during level load, seems to hold flags PTLG---- (toggles different animations)
; $C00B: 8-bit	used during level load, purpose unknown
; $C00C: 16-bit	written during level load: first byte after header * 2 (used for breaking loops during exanim)
; $C00E: 16-bit	cleared during level load, purpose unknown
; $C010: 24-bit	pointer, copied from table at $03BCC0 (which is indexed by second byte after header * 3)
; $C013: unknown
; $C016: 24-bit	cleared during level load, purpose unknown
; $C019: 8-bit	LM internal frame counter, increments
; $C01A: 8-bit	used during level load, purpose unknown
; $C01B: unknown

; current theory:
; table at $03BCC0 holds addresses of alt GFX files
; $C010 therefore holds the pointer to the alt GFX file

; $C0C0: LM dynamo data!!!
; 00 - size
; 02 - VRAM / CGRAM
; 04 - source
; 06 - bank
; $C0C0: dynamo 0
; $C0C7: dynamo 1
; $C0CE: dynamo 2
; $C0D5: dynamo 3
; $C0DC: dynamo 4
; $C0E3: dynamo 5
; $C0EA: dynamo 6
; $C0F1: dynamo 7
; if highest bit of size is set, it is a color package
; A is then doubled and written to $4315
; for color packages, byte 03 is ignored
; additionally, if a color package contains just 1 color, bytes 04-05 hold the raw color data instead of a pointer, and byte 06 is ignored
; if bit 15 of VRAM address is set, this is a square package
; in this case, the 2 tiles just after the ones we uploaded should be uploaded to the row below

; $C0FE: unknown

; we're scrapping global exanim
; level exanim is found in the table at read3(read3($0583AE)+$EA)
; (index with level*3)
; data is formatted like this:
; - HEADER -
; N	- 1 byte	- how many animation slots are used
; X	- 1 byte	- which alt ExGFX this level uses
; CC ii	- 4 bytes	- custom trigger data, LDA $C0FC : AND [table],2 : ORA [table],4 : STA $C0FC is used to initialize them
; MM MM	- 2 bytes	- 1 bit per manual trigger: 0 = don't initialize, 1 = initialize
; mm...	- 0-16 bytes	- 1 byte per manual trigger marked above, stored to $C070 table
; - POINTERS -
; PP...	- 2 bytes/slot	- points to body data (for reference, 0000 is the first byte of the pointer table)
;			  ...also, if a slot's pointer is 0000, the slot should not be used
; - BODY -
; A	- 1 byte	- animation type (multiplied by 2 and used as an index to a code pointer table)
; T	- 1 byte	- trigger
; F	- 1 byte	- number of frames -1 (loop counter)
; DD	- 2 bytes	- for tiles: VRAM address; for palettes: colors -1 (loop counter) followed by CGRAM address
; PP...	- ???????	- presumably, this holds a 16-bit value for each frame
;			  i believe this is so because all unpacked GFX are in bank $7E, meaning no bank byte is necessary
;			  ...for alt GFX source, you would simply use the value here as an offset
;			  ...and of course for colors it is simply a color value
; (repeat for each slot)


GetTilemapData:

		REP #$30
		STZ !UpdateBG1Row			;\ clear update flags
		STZ !UpdateBG1Column			;/

		LDA $1A					;\
		AND #$FFF8				; |
		CMP !BG1ZipRowX : BCS .Right		; | (compare to row because the column jumps left/right)
	.Left	SEC : SBC #$0008 ;#$0010		; | x position of zip column
		BRA +					; |
	.Right	CLC : ADC #$0110			; |
	+	BPL $03 : LDA #$0000			; > no negative numbers allowed
		CMP !BG1ZipColumnX			; |
		BEQ $03 : INC !UpdateBG1Column		; > if different, set update flag
		STA !BG1ZipColumnX			;/
		LDA $1C : STA !BG1ZipColumnY		; > y coordinate of zip column
		LDA $1C					;\
		AND #$FFF8				; |
		CMP !BG1ZipRowY				; | (somehow this comparison is fine)
		BEQ .Up					; |
		BCS .Down				; |
	.Up	SEC : SBC #$0004 ;#$0008		; | y position of zip row
		BRA +					; |
	.Down	CLC : ADC #$00EC ;#$00F0		; |
	+	AND #$FFF8				; |
		BPL $03 : LDA #$0000			; > no negative numbers allowed
		CMP !BG1ZipRowY				; |
		BEQ $03 : INC !UpdateBG1Row		; > if different, set update flag
		STA !BG1ZipRowY				;/
		LDA $1A					;\
		SEC : SBC #$0010			; | x coordinate of zip row
		BPL $03 : LDA #$0000			; > no negative numbers allowed
		STA !BG1ZipRowX				;/


		; what are these for???
		LDA $1A					;\
		SEC : SBC #$0010			; | L = -16
		BPL $03 : LDA #$0000			; |
		STA !BG1ZipBoxL				;/
		CLC : ADC #$0120			;\ R = +272
		STA !BG1ZipBoxR				;/
		LDA $1C					;\
		SEC : SBC #$0008			; | U = -8
		BPL $03 : LDA #$0000			; |
		STA !BG1ZipBoxU				;/
		CLC : ADC #$00F8			;\ D = +240
		STA !BG1ZipBoxD				;/


		LDA $7925				;\
		AND #$00FF : BEQ .Layer2BG		; |
		CMP #$0003 : BCC .Layer2Level		; |
		CMP #$0007 : BEQ .Layer2Level		; | check for level modes that have level data on layer 2
		CMP #$0008 : BEQ .Layer2Level		; |
		CMP #$000F : BEQ .Layer2Level		; |
		CMP #$001F : BEQ .Layer2Level		;/

	.Layer2BG
		PEA .Layer1-1
		JMP .BackgroundRow			; get layer 2 data

	.Layer2Level
		JSR Layer2Level

	.Layer1
		SEP #$30
		LDA !BG1ZipRowY				;\
		AND #$08				; |
		LSR #2					; | upper or lower half of map16 row
		STA $00					; |
		STZ $01					;/
		LDX #$00				; starting index
		LDA !BG1ZipRowY+0			;\
		AND #$F0				; |
		STA $05					; | lo byte of index = yyyyxxxx
		LDA !BG1ZipRowX+0			; |
		LSR #4					; |
		TSB $05					;/
		LDA !RAM_ScreenMode			;\ see if level uses vertical layout
		LSR A : BCC .HorzRow			;/

	.VertRow
		LDA !BG1ZipRowY+1			;\
		ASL A					; | for vertical levels, hi byte is just 2 Y + X (screen numbers)
		ADC !BG1ZipRowX+1			; |
		ADC #$C8				; |
		BRA .GetRow				;/

	.HorzRow
		LDA $05
		LDY !BG1ZipRowX+1
		CLC : ADC $6CB6,y
		STA $05					; $05 = position within screen + value from $6CB6 table
		LDA $6CD6,y
		ADC !BG1ZipRowY+1			; for horizontal levels, add Y screen and $6CD6 value to get hi byte
	.GetRow	STA $06					; store hi byte (later code gets bank byte)


		LDA !UpdateBG1Row			;\ if camera has moved vertically, update row
		BEQ $03 : JSR .Row			;/

		LDA !UpdateBG1Column			;\ if camera hasn't moved horizontally, return without updating column
		BNE $01 : RTS				;/



		LDA !BG1ZipColumnX			;\
		AND #$08				; |
		LSR A					; | left or right side of map16 column
		STA $00					; |
		STZ $01					;/
		LDX #$00				; starting index
		LDA !BG1ZipColumnY+0
		AND #$F0
		STA $05
		LDA !BG1ZipColumnX+0
		LSR #4
		TSB $05
		LDA !RAM_ScreenMode			;\ see if level uses vertical layout
		LSR A : BCC .HorzColumn			;/

	.VertColumn
		LDA !BG1ZipColumnY+1			;\
		ASL A					; | easy on vertical levels (2 * Y + X)
		ADC !BG1ZipColumnX+1			; |
		ADC #$C8				; |
		BRA .GetColumn				;/
	.HorzColumn
		LDA $05
		LDY !BG1ZipColumnX+1
		CLC : ADC $6CB6,y
		STA $05					; $05 = position within screen + value from $6CB6 table
		LDA $6CD6,y
		ADC !BG1ZipColumnY+1
	.GetColumn
		STA $06					; $06 = hi byte of Y position + $6CD6 table


	.Column	LDA #$41 : STA $07			; $07 = map16 bank
		LDA [$05]
		PHX					;
		TAX : XBA				; get hi byte of map16 into B and X
		LDA !Map16Remap,x			;\
		STA $03					; | map16 remap
		STZ $02					;/
		PLX					;
		DEC $07
		LDA [$05]
		REP #$30				; A = 16-bit map16 number
	if !DebugZips == 1
		PHA
		LDA $15
		AND #$0020 : BEQ +
		PLA
		LDA #$0000
		BRA $01
	+	PLA
	endif
		ASL A					; double to index 16-bit pointer
		PHX
		PHP
		JSL $06F540				; this will store the bank byte to $0C and return with the address in A
		PLP
		PLX
		STA $0A
		LDY $00					;\ > left or right half
		LDA [$0A],y				; |
		BIT $02 : BMI +				; |
		AND #$0300^$FFFF			; |
		ORA $02					; |
	+	STA $6910+$00,x				; | get layer 1 column tilemap data from map16 tile
		INY #2					; |
		LDA [$0A],y				; |
		BIT $02 : BMI +				; |
		AND #$0300^$FFFF			; |
		ORA $02					; |
	+	STA $6910+$02,x				;/

		INX #4					; increment X
		SEP #$30				; all regs 8-bit
		CPX #$40 : BCS .Done			; get 24 tiles 16x16 tiles (0x18 * 2 * 4 = 0xC0)
		PEA.w .Column-1				; get next index, then loop
		LDA !RAM_ScreenMode			;\
		LSR A : BCC ..Horz			; |
	..Vert	LDA $05					; |
		CLC : ADC #$10				; | on vertical levels we add 16 for 1 step, or 512 when crossing borders
		STA $05					; |
		BCC $04 : INC $06 : INC $06		; |
		RTS					;/
	..Horz	REP #$20				;\
		LDA $05					; |
		CLC : ADC #$0010			; | map16 data is formatted in vertical stripes so this will work
		STA $05					; | (overflow shouldn't show up since it's outside the camera)
		SEP #$20				;/
	.Done	RTS

	.Row	LDA #$41 : STA $07
		LDA [$05]
		PHX					;
		TAX : XBA				; get hi byte of map16 into B and X
		LDA !Map16Remap,x			;\
		STA $03					; | map16 remap
		STZ $02					;/
		PLX					;
		DEC $07
		LDA [$05]
		REP #$30
	if !DebugZips == 1
		PHA
		LDA $15
		AND #$0020 : BEQ +
		PLA
		LDA #$0000
		BRA $01
	+	PLA
	endif
		ASL A
		PHX
		PHP
		JSL $06F540
		PLP
		PLX
		STA $0A
		LDY $00					;\ > upper or lower half
		LDA [$0A],y				; |
		BIT $02 : BMI +				; |
		AND #$0300^$FFFF			; |
		ORA $02					; |
	+	STA $6950+$00,x				; | get layer 1 row tilemap data from map16 tile
		INY #4					; |
		LDA [$0A],y				; |
		BIT $02 : BMI +				; |
		AND #$0300^$FFFF			; |
		ORA $02					; |
	+	STA $6950+$02,x				;/

		INX #4
		SEP #$30
		CPX #$50 : BCS .Done
		PEA.w .Row-1

		LDA $05					;\
		INC A					; | go 1 step right, but check for going into the next stripe
		STA $05					; |
		AND #$0F : BNE .Return			;/
		LDA $05					;\
		SEC : SBC #$10				; | go back so we're on the same row
		STA $05					;/
		LDA !RAM_ScreenMode			;\ check if layout is horizontal or vertical
		LSR A : BCC ..Horz			;/
	..Vert	INC $06					; just add 256 to pointer on vertical levels
		RTS
	..Horz	REP #$20				;\
		LDA !LevelHeight			; |
		AND #$FFF0				; | add level height (in tiles) to index
		CLC : ADC $05				; |
		STA $05					; |
		SEP #$20				;/
	.Return	RTS




; since the map16 tiles are laid out in two 16x32 chunks, and we're getting a 32-tile wide row, index calculation is simple
; it is just equal to Y, but with the lo nybble cleared
; note that for this mode, !BG2ZipColumnY holds the previous BG2 Y coordinate and is used to determine whether update should be above or below

	.BackgroundRow
		STZ !UpdateBG2Row			; clear update flag
		LDA $20
		AND #$FFF8
		CMP !BG2ZipColumnY
		STA !BG2ZipColumnY
		BEQ ..r
		BPL ..down
	..up	LDA $20
		SEC : SBC #$0008 ;#$0004
		BRA +
	..down	LDA $20
		CLC : ADC #$00F0 ;#$00EC
	+	AND #$01F8
		CMP !BG2ZipRowY
		BEQ $03 : INC !UpdateBG2Row		; set update flag if different
		STA !BG2ZipRowY
	;	LDA !UpdateBG2Row			;\
	;	BNE $01					; | if no change, don't update
	..r	RTS					;/


		LDA !BG2ZipRowY
		AND #$01F0
		STA $0E

		LDA.w #..SNES : STA $0183		;\
		LDA.w #..SNES>>8 : STA $0184		; |
		SEP #$20				; |
		LDA #$D0 : STA $2209			; | request data from SNES WRAM
	-	LDA $018A : BEQ -			; |
		STZ $018A				; |
		REP #$20				;/

; the 16-bit map16 numbers are now stored in order in $3700-$373F

		LDA !BG2ZipRowY				;\
		AND #$0008				; | map16 data offset (upper/lower half)
		LSR #2					; |
		STA $0E					;/

		LDX !Level				;\
		LDA.l !Layer2Type,x			; |
		AND #$0004 : BEQ +			; | get map16 BG bank
		LDA.l !Layer2Type-1,x			; |
		AND #$F000				; |
	+	STA $0C					;/

		LDX #$0000				; tilemap buffer index
		LDY #$0000				; map16 buffer index

	-	PHY					; push map16 buffer index
		PHX					; push tilemap buffer index
		LDA $3700,y				;\
		ORA $0C					; > include map16 BG bank
		AND #$F000				; |
		XBA					; |
		LSR #3					; | X = index to main pointer table
		STA $00					; |
		LSR A					; |
		CLC : ADC $00				; |
		TAX					;/
		LDA.l !Map16BG+0,x : STA $00		;\ store pointer in $00
		LDA.l !Map16BG+1,x : STA $01		;/
		PLX					; X = tilemap buffer index
		LDA $3700,y				;\
		AND #$0FFF				; | Y = index to background map16 data
		ASL #3					; |
		CLC : ADC $0E				;/> add offset (upper/lower half)
		TAY					;\
		LDA [$00],y : STA $69E0+$00,x		; | get background tilemap data
		INY #4					; |
		LDA [$00],y : STA $69E0+$02,x		;/
		PLY					; Y = map16 buffer index
		INX #4					;\
		INY #2					; | loop through 64 input bytes
		CPY #$0040 : BNE -			;/
		RTS


		..SNES
		PHP					;\
		REP #$10				; | preserve processor and set up register size
		SEP #$20				;/
		LDX $0E					; X = background index
		LDY #$0000				; Y = buffer index
	-	LDA $7FBC00,x : STA $3700,y		;\
		LDA $7FC300,x : STA $3701,y		; | copy map16 numbers
		LDA $7FBE00,x : STA $3720,y		; |
		LDA $7FC500,x : STA $3721,y		;/
		INX					;\
		INY #2					; | loop
		CPY #$0020 : BCC -			;/
		PLP					;\ restore processor and return
		RTL					;/


Layer2Level:
		STZ !UpdateBG2Row			;\ clear update flags
		STZ !UpdateBG2Column			;/

		LDA $1E					;\
		AND #$FFF8				; |
		CMP !BG2ZipRowX : BCS .Right		; | (compare to row because column jumps left/right)
	.Left	SEC : SBC #$0010			; | x position of zip column
		BRA +					; |
	.Right	CLC : ADC #$0110			; |
	+	BPL $03 : LDA #$0000			; > no negative numbers allowed
		CMP !BG2ZipColumnX			; |
		BEQ $03 : INC !UpdateBG2Column		; > if different, set update flag
		STA !BG2ZipColumnX			;/
		LDA $20 : STA !BG2ZipColumnY		; > y coordinate of zip column
		LDA $20					;\
		AND #$FFF8				; |
		CMP !BG2ZipRowY				; |
		BEQ .Up					; |
		BCS .Down				; |
	.Up	SEC : SBC #$0000 ;#$0004 ;#$0008	; | y position of zip row
		BRA +					; |
	.Down	CLC : ADC #$00F0 ;#$00EC ;#$00F8	; |
	+	BPL $03 : LDA #$0000			; > no negative numbers allowed
		AND #$FFF8				; |
		CMP !BG2ZipRowY				; |
		BEQ $03 : INC !UpdateBG2Row		; > if different, set update flag
		STA !BG2ZipRowY				;/
		LDA $1E					;\
		SEC : SBC #$0010			; | x coordinate of zip row
		BPL $03 : LDA #$0000			; > no negative numbers allowed
		STA !BG2ZipRowX				;/

		SEP #$30
		LDA !BG2ZipRowY				;\
		AND #$08				; |
		LSR #2					; | upper or lower half of map16 row
		STA $00					; |
		STZ $01					;/
		LDX #$00				; starting index
		LDA !BG2ZipRowY+0			;\
		AND #$F0				; |
		STA $05					; | lo byte of index = yyyyxxxx
		LDA !BG2ZipRowX+0			; |
		LSR #4					; |
		TSB $05					;/
		LDA !RAM_ScreenMode			;\ see if level uses vertical layout
		LSR A : BCC .HorzRow			;/
	.VertRow
		LDA !BG2ZipRowY+1			;\
		ASL A					; | for vertical levels, hi byte is just 2 Y + X (screen numbers)
		ADC !BG2ZipRowX+1			; |
		ADC #$C8				; |
		BRA .GetRow				;/
	.HorzRow
		LDA $05
		LDY !BG2ZipRowX+1
		CLC : ADC $6CB6,y
		STA $05					; $05 = position within screen + value from $6CB6 table
		LDA $6CD6,y
		ADC !BG2ZipRowY+1			; for horizontal levels, add Y screen and $6CD6 value to get hi byte
	.GetRow	STA $06					; store hi byte (later code gets bank byte)

		LDA !UpdateBG2Row : BEQ .RowDone	;\
		JSR .AddOffset				; | if camera has moved vertically, update row
		JSR .Row				; |
		.RowDone				;/

		LDA !UpdateBG2Column			;\ if camera hasn't moved horizontally, return without updating column
		BNE $01 : RTS				;/


		LDA !BG2ZipColumnX			;\
		AND #$08				; |
		LSR A					; | left or right side of map16 column
		STA $00					; |
		STZ $01					;/
		LDX #$00				; starting index
		LDA !BG2ZipColumnY+0
		AND #$F0
		STA $05
		LDA !BG2ZipColumnX+0
		LSR #4
		TSB $05
		LDA !RAM_ScreenMode			;\ see if level uses vertical layout
		LSR A : BCC .HorzColumn			;/
	.VertColumn
		LDA !BG2ZipColumnY+1			;\
		ASL A					; | easy on vertical levels (2 * Y + X)
		ADC !BG2ZipColumnX+1			; |
		ADC #$C8				; |
		BRA .GetColumn				;/
	.HorzColumn
		LDA $05
		LDY !BG2ZipColumnX+1
		CLC : ADC $6CB6,y
		STA $05					; $05 = position within screen + value from $6CB6 table
		LDA $6CD6,y
		ADC !BG2ZipColumnY+1
	.GetColumn
		STA $06					; $06 = hi byte of Y position + $6CD6 table
		JSR .AddOffset

	.Column	LDA #$41 : STA $07			; $07 = map16 bank
		LDA [$05]
		PHX					;
		TAX : XBA				; get hi byte of map16 into B and X
		LDA !Map16Remap,x			;\
		STA $03					; | map16 remap
		STZ $02					;/
		PLX					;
		DEC $07
		LDA [$05]
		REP #$30				; A = 16-bit map16 number
	if !DebugZips == 1
		PHA
		LDA $15
		AND #$0020 : BEQ +
		PLA
		LDA #$0000
		BRA $01
	+	PLA
	endif
		ASL A					; double to index 16-bit pointer
		PHX
		PHP
		JSL $06F540				; this will store the bank byte to $0C and return with the address in A
		PLP
		PLX
		STA $0A
		LDY $00					;\ > left or right half
		LDA [$0A],y				; |
		BIT $02 : BMI +				; |
		AND #$0300^$FFFF			; |
		ORA $02					; |
	+	STA $69A0+$00,x				; | get layer 2 column tilemap data from map16 tile
		INY #2					; |
		LDA [$0A],y				; |
		BIT $02 : BMI +				; |
		AND #$0300^$FFFF			; |
		ORA $02					; |
	+	STA $69A0+$02,x				;/

		INX #4					; increment X
		SEP #$30				; all regs 8-bit
		CPX #$40 : BCS .Done			; get 24 tiles 16x16 tiles (0x18 * 2 * 4 = 0xC0)
		PEA.w .Column-1				; get next index, then loop
		LDA !RAM_ScreenMode			;\
		LSR A : BCC ..Horz			; |
	..Vert	LDA $05					; |
		CLC : ADC #$10				; | on vertical levels we add 16 for 1 step, or 512 when crossing borders
		STA $05					; |
		BCC $04 : INC $06 : INC $06		; |
		RTS					;/
	..Horz	REP #$20				;\
		LDA $05					; |
		CLC : ADC #$0010			; | map16 data is formatted in vertical stripes so this will work
		STA $05					; | (overflow shouldn't show up since it's outside the camera)
		SEP #$20				;/
	.Done	RTS

	.Row	LDA #$41 : STA $07
		LDA [$05]
		PHX					;
		TAX : XBA				; get hi byte of map16 into B and X
		LDA !Map16Remap,x			;\
		STA $03					; | map16 remap
		STZ $02					;/
		PLX					;
		DEC $07
		LDA [$05]
		REP #$30
	if !DebugZips == 1
		PHA
		LDA $15
		AND #$0020 : BEQ +
		PLA
		LDA #$0000
		BRA $01
	+	PLA
	endif
		ASL A
		PHX
		PHP
		JSL $06F540
		PLP
		PLX
		STA $0A
		LDY $00					;\ > upper or lower half
		LDA [$0A],y				; |
		BIT $02 : BMI +				; |
		AND #$0300^$FFFF			; |
		ORA $02					; |
	+	STA $69E0+$00,x				; | get layer 2 row tilemap data from map16 tile
		INY #4					; |
		LDA [$0A],y				; |
		BIT $02 : BMI +				; |
		AND #$0300^$FFFF			; |
		ORA $02					; |
	+	STA $69E0+$02,x				;/

		INX #4
		SEP #$30
		CPX #$50 : BCS .Done
		PEA.w .Row-1

		LDA $05					;\
		INC A					; | go 1 step right, but check for going into the next stripe
		STA $05					; |
		AND #$0F : BNE .Return			;/
		LDA $05					;\
		SEC : SBC #$10				; | go back so we're on the same row
		STA $05					;/
		LDA !RAM_ScreenMode			;\ check if layout is horizontal or vertical
		LSR A : BCC ..Horz			;/
	..Vert	INC $06					; just add 256 to pointer on vertical levels
		RTS
	..Horz	REP #$20				;\
		LDA !LevelHeight			; |
		AND #$FFF0				; | add level height (in tiles) to index
		CLC : ADC $05				; |
		STA $05					; |
		SEP #$20				;/
	.Return	RTS



	.AddOffset
		LDA !RAM_ScreenMode
		LSR A
		REP #$20
		BCC ..Horz

	..Vert	LDA #$E400-$C800			;\ > only offset
		CLC : ADC $05				; | on vertical levels, layer 2 map16 data always starts at $E400
		STA $05					; |
		SEP #$20				;/
		RTS

	..Horz	LDA $6C26				;\
		SEC : SBC #$C800			; > only offset
		CLC : ADC $05				; | add layer 2 map16 data offset from LM pointer
		STA $05					; |
		SEP #$20				;/
		RTS




macro movedynamo(offset)
	LDA $C0C0+<offset> : STA $80+<offset>
endmacro

; data: $C0C0-$C0F7
;

FetchExAnim:
		PHB
		PEA $7F7F : PLB : PLB
		PHP
		PHD
		REP #$20
		LDA.w #$6000 : TCD		; we're dumping it in $6080 because that can be accessed at $0080 in bank $40 by SA-1
		%movedynamo($00)		; this will make RAM code generation much smoother
		%movedynamo($02)
		%movedynamo($04)
		%movedynamo($06)
		%movedynamo($08)
		%movedynamo($0A)
		%movedynamo($0C)
		%movedynamo($0E)
		%movedynamo($10)
		%movedynamo($12)
		%movedynamo($14)
		%movedynamo($16)
		%movedynamo($18)
		%movedynamo($1A)
		%movedynamo($1C)
		%movedynamo($1E)
		%movedynamo($20)
		%movedynamo($22)
		%movedynamo($24)
		%movedynamo($26)
		%movedynamo($28)
		%movedynamo($2A)
		%movedynamo($2C)
		%movedynamo($2E)
		%movedynamo($30)
		%movedynamo($32)
		%movedynamo($34)
		%movedynamo($36)
		STZ $C0C0			;\
		STZ $C0C7			; |
		STZ $C0CE			; |
		STZ $C0D5			; | clear exanim slots
		STZ $C0DC			; |
		STZ $C0E3			; |
		STZ $C0EA			; |
		STZ $C0F1			;/
		PLD
		PLP
		PLB
		RTL




;===============================================;
; documentation on smkdan's tilemap update code ;
;===============================================;
; scrolling tilemap update:
;	- $05877E: run by SNES
;	- $80C448: bunch of SA-1 side stuff every other frame
;
;	- $0586F7 goes to $80B9E9
;	- $80B9E9 calls $80B0A5, which writes tilemap data to $7F820B (only on frames that the screen will update)
;	here we go, we found it baybeeeee!
;
;
;	$7BE6-$7CE5 holds tilemap data when screen is scrolling vertically
;	$7BE4 supposedly holds the VRAM address for layer 1 update
;
;
; layer 2 tilemap is copied to $7FBC00 (lo bytes) and $7FC300 (hi bytes)
;
; level modes:
;	- 00: horz + bg
;	- 01: horz + level bg
;	- 02: horz + level
;	- 03-06: ----
;	- 07: vert + level bg
;	- 08: vert + level
;	- 09: BOSS
;	- 0A: vert + bg
;	- 0B: BOSS
;	- 0C: horz + bg (dark)
;	- 0D: vert + bg (dark)
;	- 0E: horz + bg (BG3 prio)
;	- 0F: horz + level bg (BG3 prio)
;	- 10: BOSS
;	- 11: horz + bg (dark)
;	- 12-1D: ----
;	- 1E: horz + bg (translucent)
;	- 1F: horz + level (translucent)
;


macro CCDMA(slot)
	LDY $97+(<slot>*8) : STY.w $2231	; CCDMA mode
	LDA $92+(<slot>*8)			;\
	STA.w $2232				; | source address
	STA.w $4302				;/
	LDY $94+(<slot>*8)			;\
	STY.w $2234				; | source bank
	STY.w $4304				;/
	LDA #$3700 : STA.w $2235		; buffer address
	CLI					;\
?Sync:	LDY $8D : BEQ ?Sync			; | sync with SA-1 CPU
	LDY #$00 : STY $8D			; |
	SEI					;/
	LDA $90+(<slot>*8) : STA.w $4305	; upload size
	LDA $95+(<slot>*8) : STA.w $2116	; VRAM address
	LDY #$01 : STY.w $420B			; execute CCDMA
	DEX : BNE ?Next				;\ check remaining slots
	JMP .EndCCDMA				;/
	?Next:
endmacro


;==============;
;NMI CODE BELOW;
;==============;
NMI:		PHP					;\
		REP #$30				; |
		PHA					; |
		PHX					; | push everything
		PHY					; |
		PHB					; |
		PHD					;/


	; initialize NMI
		PHK : PLB				; set bank
		SEP #$30				; all regs 8-bit
		LDA $4210				; clear NMI flag
		LDA #$80 : STA $2100			; enable f-blank
		STZ $420C				; disable HDMA
		INC !MPU_NMI				; set NMI flag for SA-1


	; check lag
		LDA $3010 : BEQ .NoLag			; DP is undefined currently, so we need to use 16-bit address
		PEA $3000 : PLD				; DP = $3000
		LDA !2105 : STA $2105			;\
		LDA !2109 : STA $2109			; |
		LDA $22 : STA $2111			; |
		LDA $23 : STA $2111			; |
		LDA $24 : STA $2112			; |
		LDA $25 : STA $2112			; | just update these regs on lag frames
		LDA $42 : STA $2124			; | (these are changed during status bar IRQ so they have to be updated every v-blank)
		LDA !MainScreen				; |
		STA $212C				; |
		STA $212E				; |
		LDA $44 : STA $2130			; |
		LDA $40 : STA $2131			;/
		JMP .Lag				; skip most of NMI on lag frames
		.NoLag


		REP #$20				; A 16-bit
		LDY #$01				;\ setup: Y = 01, DP = $4300
		LDA #$4300 : TCD			;/

	; OAM update
		STZ $00					;\
		STZ $2102				; |
		LDA #$0004 : STA $01			; | $6200 -> OAM
		LDA #$0062 : STA $03			; |
		LDA #$0220 : STA $05			; |
		STY $420B				;/


	; HDMA update

;	LDA !RAMcode_flag : PHA

		LDX !MsgTrigger : BNE +			; > let message boxes use indirect mode
		LDX !GameMode				;\
		CPX #$02 : BCC .NoRAMcode		; | presents screen has no HDMA or dynamic BG3
		CPX #$0B : BCC +			;/
		LDA !HDMA2source : STA $22		;\
	+	LDA !HDMA3source : STA $32		; |
		LDA !HDMA4source : STA $42		; | HDMA source mirrors to prevent tearing
		LDA !HDMA5source : STA $52		; |
		LDA !HDMA6source : STA $62		; |
		LDA !HDMA7source : STA $72		;/
		STZ $04					; bank 00
		LDA #$2202 : STA $00			;\
		LDA #$00A0 : STA $02			; |
		LDA #$000E : STA $05			; | upload dynamic BG3 color
		STY $2121				; |
		STY $420B				;/

	; RAM code (requires DP = $4300)
		LDA !RAMcode_flag
		CMP #$1234 : BNE .NoRAMcode
		JSL !RAMcode
		STZ !RAMcode_flag
		STZ !RAMcode_offset
	.NoRAMcode
		LDA #$3000 : TCD			; DP = $3000


	; direct color update
		LDA !2132_RGB
		ASL #3
		SEP #$21
		ROR #3
		XBA
		ORA #$40
		STA $2132
		LDA $6702
		LSR A
		SEC : ROR A
		STA $2132
		XBA
		STA $2132

	; color 0 update
		STZ $2121
		LDA !Color0 : STA $2122
		LDA !Color0+1 : STA $2122


		INC $10					; set processing frame flag (anywhere in .NoLag where DP = $3000 and A is 8-bit will do)


	; misc registers
		REP #$10				; 16-bit index
		TSX					;\ preserve stack in Y
		TXY					;/
		LDX #$2131 : TXS			; S = $2131
		LDA $40 : PHA				; $40 -> 2131
		LDA $44 : PHA				; $44 -> 2130
		LDA !SubScreen				;\
		PHA					; | !SubScreen -> 212D and 212F
		STA $212D				;/
		LDA !MainScreen				;\
		PHA					; | !MainScreen -> 212C and 212E
		STA $212C				;/

		; S = 212D
		; 212A-212B: window combination logic, left at 0000 (OR)


		LDX #$2125 : TXS			; this is actually faster than LDA dp : STA addr x3
		LDA $43 : PHA				; $43 -> 2125
		PEI ($41)				; $41-$42 -> 2123-2124


		.Mode7
		LDA !Mode7Settings			;\ skip mode 7 if disabled
		BIT #$08 : BEQ ..skip			;/
		AND #$C3 : STA $211A			; $211A: mode 7 settings (hardware bits only)
		LDX #$2120 : TXS			; S = $2120
		LDA !Mode7CenterY : PHA			;\ $2120: mode 7 center Y
		LDA !Mode7CenterY+1 : STA $2120		;/
		LDA !Mode7CenterX : PHA			;\ $211F: mode 7 center X
		LDA !Mode7CenterX+1 : STA $211F		;/
		LDA !Mode7MatrixD : PHA			;\ $211E: mode 7 matrix D
		LDA !Mode7MatrixD+1 : STA $211E		;/
		LDA !Mode7MatrixC : PHA			;\ $211D: mode 7 matrix C
		LDA !Mode7MatrixC+1 : STA $211D		;/
		LDA !Mode7MatrixB : PHA			;\ $211C: mode 7 matrix B
		LDA !Mode7MatrixB+1 : STA $211C		;/
		LDA !Mode7MatrixA : PHA			;\ $211B: mode 7 matrix A
		LDA !Mode7MatrixA+1 : STA $211B		;/
		LDX #$210E : TXS			; S = $210E
		LDA !Mode7Y : PHA			;\ $210E: mode 7 Y position
		LDA !Mode7Y+1 : STA $210E		;/
		LDA !Mode7X : PHA			;\ $210D: mode 7 X position
		LDA !Mode7X+1 : STA $210D		;/
		BRA .NormalMode_done			; go to $210C write area (S = $210C after these writes)
		..skip


		.NormalMode
		LDX #$2114 : TXS			; S = $2114
		STZ $2114				;\
		PEA $0000				; | 2113: BG4 horizontal scroll and 2114: BG4 vertical scroll both = 00
		STZ $2113				;/
		LDA $24 : PHA				;\ 2112: BG3 vertical scroll
		LDA $25 : STA $2112			;/
		LDA $22 : PHA				;\ 2111: BG3 horizontal scroll
		LDA $23 : STA $2111			;/
		LDA $20 : PHA				;\ 2110: BG2 vertical scroll
		LDA $21 : STA $2110			;/
		LDA $1E : PHA				;\ 210F: BG2 horizontal scroll
		LDA $1F : STA $210F			;/
		LDA $1C					;\
		CLC : ADC $7888				; |
		PHA					; | 210E: BG1 vertical scroll
		LDA $1D					; |
		ADC $7889				; |
		STA $210E				;/
		LDA $1A : PHA				;\ 210D: BG1 horizontal scroll
		LDA $1B : STA $210D			;/
		..done


		LDA !210C : PHA				; 210C: BG3 and BG4 chr address
		PEA $0000				; 210A: BG4 tilemap address and 210B: BG1 and BG2 chr address both = 00
		LDA !2109 : PHA				; 2109: BG3 tilemap address
		LDA !2108 : PHA				; 2108: BG2 tilemap address
		LDA !2107 : PHA				; 2107: BG1 tilemap address
		LDA !2106 : PHA				; 2106: mosaic
		LDA !2105 : PHA				; 2105: screen mode
		LDA #$80 : STA $2103			; 2103: OAM priority bit
		LDA $3F : STA $2102			; 2102: OAM address

		TYX					;\ restore stack pointer from Y
		TXS					;/
		SEP #$10				; index 8-bit



	; CCDMA
		REP #$20
;	PLA						;\ only process CCDMA if RAM code was finished this frame
;	CMP #$1234 : BNE .SkipCCDMA			;/
		LDX.w $317F : BNE .RunCCDMA
		.SkipCCDMA
		JMP .NoCCDMA
		.RunCCDMA
		LDA #$3100 : TCD			; DP = $3100
		LDA #$1801 : STA.w $4300		;\
		LDY #$81 : STY.w $2200			; | prepare DMA
		DEY					; |
		STY.w $2115				;/
	-	LDY $8D : BEQ -				;\ wait for SA-1 CPU to get ready
		LDY #$00 : STY $8D			;/
		%CCDMA(0)				;\
		%CCDMA(1)				; |
		%CCDMA(2)				; |
		%CCDMA(3)				; |
		%CCDMA(4)				; | execute CCDMA
		%CCDMA(5)				; |
		%CCDMA(6)				; |
		%CCDMA(7)				; |
		%CCDMA(8)				; |
		%CCDMA(9)				;/
		.EndCCDMA
		LDY #$80 : STY.w $2231			;\ end CCDMA
		LDY #$82 : STY.w $2200			;/
		LDY #$00 : STY $7F			; > clear upload count
		LDA #$3000 : TCD			; DP = $3000
		.NoCCDMA


	; enable HDMA
		.Lag
		SEP #$20				;\ this is double-mirrored to prevent oddities on lag frames
		LDA $1F0C : STA $420C			;/


	; finish v-blank
		LDY #$D6				;\
		LDA $4211				; | set IRQ scanline
		STY $4209				; |
		STZ $420A				;/
		STZ $11					; clear IRQ counter (probably unused, but for safety...)
		LDA #$A1 : STA $4200			; enable NMI + controller
		LDA $6DAE : STA $2100			; set screen brightness



	; controller stuff (can be done outside of v-blank but still has to be done every frame)
		PHD					;\ DP optimization
		PEA $6D00 : PLD				;/

		LDA $309D : BEQ .LoadJoypad



; 4218
;	-> $A2 (hold)
; 4219
;	-> $A4 (hold)

; 4218 ^ $A2 & 4218
;	-> $A6 (press)
; 4219 ^ $A4 & 4219
;	-> $A8 (press)



; 421A
;	-> $A3 (hold)
; 421B
;	-> $A5 (hold)

; 421A ^ $A3 & 421A
;	-> $A7 (press)
; 421B ^ $A5 & 421B
;	-> $A9 (press)

		.BufferJoypad
		LDA $AA : TRB $A8			;\
		LDA $AB : TRB $A6			; |
		LDA $AC : TRB $A9			; |
		LDA $AD : TRB $A7			; | clear press input from before buffer
		STZ $AA					; |
		STZ $AB					; |
		STZ $AC					; |
		STZ $AD					;/
		LDA $4218				;\
		EOR $A4					; |
		AND $4218				; |
		AND #$F0 : TSB $A8			; |
		LDA $4218				; |
		AND #$F0 : TSB $A4			; | buffer joypad 1
		LDA $4219				; |
		EOR $A2					; |
		AND $4219				; |
		TSB $A6					; |
		LDA $4219 : TSB $A2			;/
		LDA $421A				;\
		EOR $A5					; |
		AND $421A				; |
		AND #$F0 : TSB $A9			; |
		LDA $421A				; |
		AND #$F0 : TSB $A5			; | buffer joypad 2
		LDA $421B				; |
		EOR $A3					; |
		AND $421B				; |
		TSB $A7					; |
		LDA $421B : TSB $A3			;/
		BRA .BuildMarioJoypad			; go to build mario joypad

		.LoadJoypad
		LDA $4218				;\
		EOR $A4					; |
		AND $4218				; |
		AND #$F0 : STA $A8 : STA $AA		; > press flags in case buffer mode turns on
		LDA $4218				; |
		AND #$F0 : STA $A4			; | load joypad 1
		LDA $4219				; |
		EOR $A2					; |
		AND $4219				; |
		STA $A6 : STA $AB			; > press flags in case buffer mode turns on
		LDA $4219 : STA $A2			;/
		LDA $421A				;\
		EOR $A5					; |
		AND $421A				; |
		AND #$F0 : STA $A9 : STA $AC		; > press flags in case buffer mode turns on
		LDA $421A				; |
		AND #$F0 : STA $A5			; | load joypad 2
		LDA $421B				; |
		EOR $A3					; |
		AND $421B				; |
		STA $A7 : STA $AD			; > press flags in case buffer mode turns on
		LDA $421B : STA $A3			;/

		.BuildMarioJoypad
		PLD					; restore DP here since indexing adds no cycles to addr read but adds 1 cycle to dp read
		LDX #$00				;\
		LDA !CurrentMario			; | index to joypad to use for mario
		CMP #$02				; |
		BNE $01 : INX				;/
		LDA $6DA4,x				;\
		AND #$C0				; |
		ORA $6DA2,x				; |
		STA $15					; |
		LDA $6DA4,x : STA $17			; |
		LDA $6DA8,x				; | build mario joypad
		AND #$40				; |
		ORA $6DA6,x				; |
		STA $16					; |
		LDA $6DA8,x : STA $18			; |
		.ControlsDone				;/


	; some RAM stuff
		REP #$20
		LDA #$0000 : STA $7F837B		; clear stripe image table


ReturnNMI:	REP #$30
		PLD					;\
		PLB					; |
		PLY					; | restore everything
		PLX					; |
		PLA					; |
		PLP					;/
		RTI					; > return from interrupt


		




;=============;
;IRQ EXPANSION;
;=============;
; regs used:
; 2100 - brightness + f-blank
; 2105 - screen mode
; 2106 - mosaic
; 2109 - BG3 tilemap address
; 2111 - BG3 hscroll
; 2112 - BG3 vscroll
; 2115 - VRAM transfer stuff
; 2116 - VRAM transfer stuff
; 2121 - CGRAM address
; 2122 - CGRAM write
; 2124 - BG3/BG4 window settings
; 212C - main screen settings
; 212E - main screen settings
; 2130 - color math
; 2131 - color math
IRQ:
		PHD					; > push direct page
		LDA #$43 : XBA				;\ DP = 0x4300
		LDA #$00 : TCD				;/

		LDX !GameMode
		LDA.l .GameModeEnable,x : BEQ +		; 00 -> return
		BPL .Level				; 01 -> level
		LDA !P2Status-$80 : BEQ +		;\ FF -> return if at least one player alive, otherwise level
		LDA !P2Status : BNE .Level		;/
	+	JMP .Return

.Level		BIT $4212 : BVC .Level			; wait for f-blank to prevent tearing
		LDA #$80 : STA $2100			; enable f-blank
		LDA !210C				;\
		ASL #4					; | BG3 tilemap location (inside GFX)
		STA $2109				;/
		STZ $420C				; disable HDMA
		STZ $2115				; byte uploads
		LDY #$01				; channel bit
		REP #$20				;\
		LDA !210C				; |
		AND #$000F				; |
		XBA					; |
		ASL #4					; |
		ORA #$0080				; > tiles 0x010-0x013
		PHA					; |
		STA $2116				; |
		LDA #$1800 : STA $00			; |
		LDA #$6EF9 : STA $02			; | upload status bar tilemap
		LDX #$00 : STX $04			; |
		LDA #$0020 : STA $05			; |
		STY $420B				;/
		LDX #$80 : STX $2115			; > word uploads (we're kinda cheating but it's ok)
		PLA : STA $2116				;\
		LDA #$1900 : STA $00			; |
		LDA.w #!StatusProp : STA $02		; | upload status bar YXPCCCTT
		STZ $04					; |
		LDA #$0020 : STA $05			; |
		STY $420B				;/
		LDA #$2202 : STA $00			;\
		LDA.w #.StatusPal : STA $02		; |
		LDX.b #.StatusPal>>16 : STX $04		; | upload status bar palette
		LDA #$000E : STA $05			; |
		STY $2121				; |
		STY $420B				;/
		LDA #$2100 : TCD			; > DP = 0x2100
		SEP #$20				; > A 8 bit
		LDA !StatusX : STA $11			;\ BG3 Hscroll
		STZ $11					;/
		LDA #$47 : STA $12			;\ BG3 Vscroll
		LDA #$FF : STA $12			;/
.Shared		LDA #$04 : STA $2C			; > main screen designation
		STZ $24					;\ disable windowing
		STZ $2E					;/
		STZ $30					;\ color math settings
		STZ $31					;/
		STZ $21					;\
		STZ $22					; | color 0 to black
		STZ $22					;/
		LDA #$09 : STA $05			; > GFX mode 1 + Layer 3 priority
		STZ $06					; > no mosaic
	-	BIT $4212 : BVC -			;\ wait for h-blank and restore brightness
		LDA $6DAE : STA $00			;/
.Return		REP #$30				;\
		PLD					; |
		PLB					; |
		PLY					; | return from interrupt
		PLX					; |
		PLA					; |
		PLP					; |
		RTI					;/


.StatusPal
incbin "../../PaletteData/statusbar.mw3":2-10


.GameModeEnable
		db $00,$00,$00,$00,$00,$00,$00,$00	; 00-07
		db $00,$00,$00,$FF,$00,$00,$00,$01	; 08-0F
		db $00,$00,$00,$01,$01,$00,$00,$00	; 10-17
		db $00,$00,$00,$00,$00,$00,$00,$00	; 18-1F
		db $00,$00,$00,$00,$00,$00,$00,$00	; 20-27
		db $00,$00,$00,$00,$00,$00,$00,$00	; 28-2F


;==========;
;GFX LOADER;
;==========;
incsrc "GFX_Loader.asm"




End:
print "VR3 is $", hex(End-$12A000), " bytes long."
print "VR3 ends at $", pc, "."
print " "

;=========;
;DMA REMAP;
;=========;
incsrc "DMA_Remap.asm"


