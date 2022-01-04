




	; $00A087 - start of game mode 0C (load overworld)
	LOAD:
		STZ $4200					;\
		STZ $420C					; | JSR $937D ("TurnOffIO" in all.log)
		LDA #$80 : STA $2100				;/
		; warp pipe/star check (always 0)
		REP #$10					; index 16-bit
		LDX #$03FF					;\
	-	STZ $3200,x					; | from SA-1 patch
		DEX : BPL -					;/
		LDX #$008D					;\
	-	STZ $1A,x					; | from JSR $A1A6 ("Clear_1A_13D3" in all.log)
		DEX : BPL -					;/
		LDX #$0564					;\
	-	STZ $73D3,x					; |
		DEX : BPL -					; | from SP_Patch
		LDX #$0209					; |
	-	STZ $7998,x					; |
		DEX : BPL -					;/
		LDX #$01BE					;\
		LDA #$FF					; |
	-	STZ $64A0,x					; | wipe this table too
		STA $64A1,x					; |
		DEX #2 : BPL -					;/
		LDX #$03FF					;\
	-	LDA #$00					; | wipe VR3 tables
		STA !VRAMbase+!VRAMtable,x			; |
		DEX : BPL -					;/
		SEP #$10					; index 8-bit

		LDA !Difficulty					;\
		AND.b #!HardcoreMode : BEQ .NotHardcore		; |
		LDA !P1DeathCounter				; |
		ORA !P1DeathCounter+1				; |
		ORA !P2DeathCounter				; | hardcore
		ORA !P2DeathCounter+1				; |
		BEQ .NotHardcore				; |
		JSL !EraseFile					; |
		BRK						; |
		.NotHardcore					;/


		STZ !BossData+0					;\
		STZ !BossData+1					; |
		STZ !BossData+2					; |
		STZ !BossData+3					; | clear boss data
		STZ !BossData+4					; |
		STZ !BossData+5					; |
		STZ !BossData+6					;/

		LDA #$00					; > set up clear
		STA !MsgMode					; > clear message mode
		STA !HDMAptr+0					;\
		STA !HDMAptr+1					; | clear HDMA pointer
		STA !HDMAptr+2					;/

		REP #$20					;\
		LDA !P2CoinIncrease				; |
		AND #$00FF					; |
		CLC : ADC !P2Coins				; | add up coin increase to make sure player's aren't cheated
		STA !P2Coins					; |
		LDA !P1CoinIncrease				; |
		AND #$00FF					; |
		CLC : ADC !P1Coins				;/
		CLC : ADC !P2Coins				;\
		BEQ .NoCoins					; |
		STZ !P1Coins					; |
		STZ !P2Coins					; |
		CLC : ADC !CoinHoard+0				; | put coins in hoard
		STA !CoinHoard+0				; |
		LDA !CoinHoard+2				; |
		ADC #$0000					; |
		STA !CoinHoard+2				;/

		LDA #$0F42
		CMP !CoinHoard+1
		BCC .CapHoard					; > if less, then cap hoard
		BNE .NoCoins					; > if greater than, don't cap hoard
		LDA !CoinHoard+0				;\ if equal, check lowest byte
		CMP #$423F : BCC .NoCoins			;/
		LDA #$0F42					; > if it overflows, cap hoard

		.CapHoard
		STA !CoinHoard+1
		LDA #$423F : STA !CoinHoard+0

		.NoCoins
		SEP #$20		
		STZ !P1CoinIncrease				;\ clear coin increase
		STZ !P2CoinIncrease				;/

		STZ !P1Dead					;\
		LDX #$7F					; |
	-	STZ !P2Base-$80,x				; | revive and reset players
		STZ !P2Base,x					; |
		DEX : BPL -					;/



		STZ !CharMenu
		STZ !CharMenuSize
		STZ !CharMenuCursor
		STZ !SelectingPlayer
		STZ !WarpPipe
		LDA #$FF : STA !PrevTranslevel
		LDA #$14
		STA !MapCheckpointX
		STA !MapCheckpointTargetX

		LDA #$00					;\
		LDX #$00					; |
	-	STA $400000+!MsgRAM,x				; | clear MSG RAM
		INX						; |
		CPX #$C0 : BCC -				;/

		LDA.b #!SaveGame : STA $3180			;\
		LDA.b #!SaveGame>>8 : STA $3181			; | call SA-1 to save game when loading overworld
		LDA.b #!SaveGame>>16 : STA $3182		; |
		JSR $1E80					;/

		REP #$20					;\
		LDA #$0000					; |
		STA !RAMcode_flag				; | kill any RAM code left over from level
		STA !RAMcode_offset				; |
		SEP #$20					;/

		; check whether intro level should be loaded!
		LDA !LevelTable1+$00 : BMI .LoadOverworld
		.LoadIntroLevel
		LDA #$F0 : STA $6DB0
		LDA #$10 : STA !GameMode
		LDA.b #!IntroLevel : STA $6109			; intro level (translevel num... but only kind of...)
		LDA.b #!IntroLevel>>8 : STA $7F11		; set hi bit of intro level num
		STZ !Translevel					;
		LDA #$81 : STA $4200				; enable joypad but keep interrupts disabled
		JML ReturnLoad					; return



	; $00A0B0 is the actual load overworld code in all.log
		.LoadOverworld
		LDA !StoryFlags					;\ intro cleared
		ORA #$80 : STA !StoryFlags			;/
	;	JSL !KillOAM
		STZ $2133
		STZ $2106
		STZ !2123
		STZ !2124
		STZ !2125
		STZ $212A
		STZ $212B
		STZ $212E
		STZ $212F
		LDA #$80 : STA $211A

		LDA #$03 : STA !2105				; screen mode = 3

		STZ $6DDA					; clear backup music reg
		; bunch of obsolete code at $00A0BC-$00A0E3 (opcode ends at $00A3E5)
		LDA #$03 : STA !2130				; sick
		LDA #$15
		STA $212C
		STA $212E
		LDA #$02
		STA $212D
		STA $212F
		STZ $2131
		STZ !2131

		REP #$20					; A 16-bit
		LDA #$4000 : STA !BG1Address			; BG1 tilemap address
		LDA #$4800 : STA !BG2Address			; BG2 tilemap address
		STZ $1A						;\
		STZ $1C						; |
		STZ $1E						; | all BG coords (mirrors) = 0
		STZ $20						; |
		STZ $22						; |
		STZ $24						;/
		SEP #$20					; A 8-bit
		STZ $210D					;\
		STZ $210D					; |
		STZ $210E					; |
		STZ $210E					; |
		STZ $210F					; |
		STZ $210F					; | all BG coords (regs) = 0
		STZ $2110					; |
		STZ $2110					; |
		STZ $2111					; |
		STZ $2111					; |
		STZ $2112					; |
		STZ $2112					;/

		LDA #$41					;\
		STA !2107					; | BG1 tilemap: address $4000 (0x8000), size 64x32
		STA $2107					;/
		LDA #$49					;\
		STA !2108					; | BG2 tilemap: address $4800 (0x9000), size 64x32
		STA $2108					;/


		LDA #$80 : STA !ProcessLight			; stop this

		PHB						;\ make sure these don't mess up
		PHP						;/

		PHB						;\ bank setup
		LDA #$41 : PHA					;/
		REP #$30					;\
		LDA #$0000 : STA !VRAMbase+!VRAMtable+$3FE	; |
		LDA.w #$03FE					; | kill VR3 residuals (including CCDMA)
		LDX.w #!VRAMtable+$3FF				; |
		LDY.w #!VRAMtable+$3FE				; |
		MVP $40,$40					;/
		PLB						;\
		REP #$30					; |
		LDX #$01FE					; |
		LDA #$FFFF					; |
	-	STZ.w !tilecount+$000,x				; |
		STZ.w !tilecount+$200,x				; |
		STZ.w !tilecount+$400,x				; |
		STZ.w !tilecount+$600,x				; | initialize loader system
		STA.w !tileaddress+$000,x			; |
		STA.w !tileaddress+$200,x			; |
		STA.w !tileaddress+$400,x			; |
		STA.w !tileaddress+$600,x			; |
		STA.w !vramalloc,x				; |
		DEX #2 : BPL -					; |
		STZ.w !loadindex				; |
		STZ.w !zipbuffer+0				; |
		STZ.w !initzipcount				; |
		PLB						;/


		REP #$20					; A 16-bit
		SEP #$10					; index 8-bit
		STZ $2116					; VRAM address = 0
		LDX #$80 : STX $2115				; word uploads
		LDX #$02					; X = DMA bit
		LDA #$1801 : STA $4310				; word writes to 2118-2119


		REP #$10
		LDX #$0000
		LDA #$3E00
	-	STA !DecompBuffer+$000,x
		INC A
		INX #2
		CPX #$0100 : BCC -

		LDX #$0000
		LDA #$3E80
		CLC
	-	STA !DecompBuffer+$100,x
		ADC #$0010
		STA !DecompBuffer+$140,x
		ADC #$0010
		STA !DecompBuffer+$180,x
		ADC #$0010
		STA !DecompBuffer+$1C0,x
		ADC #$0010
		STA !DecompBuffer+$120,x
		ADC #$0010
		STA !DecompBuffer+$160,x
		ADC #$0010
		STA !DecompBuffer+$1A0,x
		ADC #$0010
		STA !DecompBuffer+$1E0,x
		SBC #$006E
		INX #2
		CPX #$0020 : BCC -


		SEP #$10
		LDA #$1801 : STA $4310
		LDA.w #!DecompBuffer : STA $4312
		LDA.w #!DecompBuffer>>8 : STA $4313
		LDA #$0200 : STA $4315
		LDA #$5000 : STA $2116
		LDX #$02 : STX $420B


	; debug: clear out BG1 GFX area
	if !DebugOverworld = 1
	STZ $2116
	LDY #$00 : STY $2115
	LDA #$1808 : STA $4310
	LDA.w #..debug0 : STA $4312
	LDA.w #..debug0>>8 : STA $4313
	LDA #$2000 : STA $4315
	STX $420B
	STZ $2116
	LDY #$80 : STY $2115
	LDA #$1908 : STA $4310
	LDA.w #..debug0 : STA $4312
	LDA.w #..debug0>>8 : STA $4313
	LDA #$2000 : STA $4315
	STX $420B
	BRA ..debugdone
	..debug0
	db $00
	..debugdone
	endif


		; upload BG2 tilemap to 0x9000/$4800 here



		LDA.w #!DecompBuffer : STA $00			;\ decompression destination
		LDA.w #!DecompBuffer>>8 : STA $01		;/
		LDA #$2800 : STA $2116
		LDA.w #$00A : JSL !DecompressFile
		LDA #$1801 : STA $4310
		LDA.w #!DecompBuffer : STA $4312
		LDA.w #!DecompBuffer>>8 : STA $4313
		LDA #$1000 : STA $4315
		STX $420B





		LDA #$6000 : STA $2116				; prepare to upload sprite GFX
		LDA.w #$004 : JSL !DecompressFile		;\
		LDA #$1801 : STA $4310				; |
		LDA.w #!DecompBuffer : STA $4312		; | upload file 004
		LDA.w #!DecompBuffer>>8 : STA $4313		; |
		LDA #$1000 : STA $4315				; |
		STX $420B					;/
		LDA.w #$005 : JSL !DecompressFile		;\
		LDA #$1801 : STA $4310				; |
		LDA.w #!DecompBuffer : STA $4312		; | upload file 005
		LDA.w #!DecompBuffer>>8 : STA $4313		; |
		LDA #$1000 : STA $4315				; |
		STX $420B					;/
		LDA.w #$006 : JSL !DecompressFile		;\
		LDA #$1801 : STA $4310				; |
		LDA.w #!DecompBuffer : STA $4312		; | upload file 006
		LDA.w #!DecompBuffer>>8 : STA $4313		; |
		LDA #$1000 : STA $4315				; |
		STX $420B					;/

		LDA.w #$00B : JSL !DecompressFile		;\
		LDA #$8000 : STA $4310				; |
		LDA #$7F00 : STA $2182				; |
		STZ $2181					; | store file 00B at $7F0000
		LDA.w #!DecompBuffer : STA $4312		; |
		LDA.w #!DecompBuffer>>8 : STA $4313		; |
		LDA #$2000 : STA $4315				; |
		STX $420B					;/

		LDA.w #$007 : JSL !DecompressFile		;\
		LDA #$1801 : STA $4310				; |
		LDA.w #!DecompBuffer : STA $4312		; | upload file 007
		LDA.w #!DecompBuffer>>8 : STA $4313		; |
		LDA #$1000 : STA $4315				; |
		STX $420B					;/

		LDA.w #$014 : JSL !DecompressFile		;\
		LDA #$8000 : STA $4310				; |
		LDA.w #!DecompBuffer : STA $4312		; |
		LDA.w #!DecompBuffer>>8 : STA $4313		; | use file 014 as AN2
		LDA #$1B00 : STA $4315				; |
		LDA.w #!AN2 : STA $2181				; |
		LDA.w #!AN2>>8 : STA $2182			; |
		STX $420B					;/

		STZ $2115					;\
		REP #$20					; |
		LDA #$1808 : STA $4310				; |
		LDA.w #.Tilemap : STA $4312			; | tile numbers for first half of BG2
		LDX.b #.Tilemap>>16 : STX $4314			; |
		LDA #$0200 : STA $4315				; |
		LDA #$4800 : STA $2116				; |
		LDX #$02 : STX $420B				;/
		LDA #$1808 : STA $4310				;\
		LDA.w #.Tilemap+2 : STA $4312			; |
		LDX.b #.Tilemap>>16 : STX $4314			; | tile numbers for second half of BG2
		LDA #$0200 : STA $4315				; |
		LDX #$02 : STX $420B				;/
		LDX #$80 : STX $2115				;\
		LDA #$1908 : STA $4310				; |
		LDA.w #.Tilemap+1 : STA $4312			; |
		LDX.b #.Tilemap>>16 : STX $4314			; | YXPCCCTT for first half of BG2
		LDA #$0200 : STA $4315				; |
		LDA #$4800 : STA $2116				; |
		LDX #$02 : STX $420B				;/
		LDA #$1908 : STA $4310				;\
		LDA.w #.Tilemap+3 : STA $4312			; |
		LDX.b #.Tilemap>>16 : STX $4314			; | YXPCCCTT for second half of BG2
		LDA #$0200 : STA $4315				; |
		LDX #$02 : STX $420B				;/



	.InitPlayers
		LDA !SRAM_overworldX : STA !P1MapX
		DEC #4
		STA !P2MapX
		SEC : SBC #$0078-4
		STA $1A
		STA !zipprev1A
		LDA !SRAM_overworldY : STA !P1MapY
		DEC #4
		STA !P2MapY
		SEC : SBC #$0078-4
		STA $1C
		STA !zipprev1C
		STZ !P1MapXSpeed
		STZ !P1MapAnim
		STZ !P2MapXSpeed
		STZ !P2MapAnim

		LDA #$00FF
		STA !P1MapPrevAnim
		STA !P2MapPrevAnim

		LDA !Characters
		LSR #4
		AND #$000F : STA !P1MapChar
		LDA !Characters
		AND #$000F : STA !P2MapChar

		LDA $1A
		BPL $03 : LDA #$0000
		CMP #$0500
		BCC $03 : LDA #$0500
		STA $1A
		LDA $1C
		BPL $03 : LDA #$0000
		CMP #$031F
		BCC $03 : LDA #$031F
		STA $1C

		PHP

	.InitSprites
		REP #$30
		LDX #$0000
		..loop
		STZ !OW_sprite_Num,x
		STZ !OW_sprite_Anim,x
		STZ !OW_sprite_X,x
		STZ !OW_sprite_Y,x
		STZ !OW_sprite_Z,x
		STZ !OW_sprite_XSpeed,x
		STZ !OW_sprite_ZSpeed,x
		TXA
		CLC : ADC.w #!OW_sprite_Size
		TAX
		CPX.w #(!OW_sprite_Size)*16 : BCC ..loop

		LDA #$0002 : STA !OW_sprite_Num
		LDA #$0110 : STA !OW_sprite_X
		LDA #$0330 : STA !OW_sprite_Y
		LDA #$0002 : STA !OW_sprite_Num+((!OW_sprite_Size)*1)
		LDA #$0150 : STA !OW_sprite_X+((!OW_sprite_Size)*1)
		LDA #$02D8 : STA !OW_sprite_Y+((!OW_sprite_Size)*1)
		LDA #$0002 : STA !OW_sprite_Num+((!OW_sprite_Size)*2)
		LDA #$0150 : STA !OW_sprite_X+((!OW_sprite_Size)*2)
		LDA #$02A0 : STA !OW_sprite_Y+((!OW_sprite_Size)*2)



	.InitBG1
	; unpack overworld tilemaps
		REP #$30
		LDX.w #DecompressionMap_End-DecompressionMap-4
	-	LDA.l DecompressionMap+1,x : STA $00
		LDA.l DecompressionMap+2,x : STA $01
		LDA.l DecompressionMap+0,x
		AND #$00FF
		ORA #$0B00
		PHX
		JSL !DecompressFile
		PLX
		DEX #4 : BPL -


	; apply overworld events
		PHB : PHK : PLB
		LDX #$005F
		..eventloop
		LDA !LevelTable4-1,x : BPL +
		LDA EventTable_UnlockEvents,x
		AND #$00FF : BEQ +
		JSR .LoadEvent
	+	LDA !LevelTable1-1,x : BPL ..nextlevel
		LDA EventTable_ClearEvents,x
		AND #$00FF : BEQ ..nextlevel
		JSR .LoadEvent
		..nextlevel
		DEX : BPL ..eventloop
		PLB


	; load BG1 GFX
		..loopfull
		SEP #$30
		LDA !initzipcount
		CMP.b #!zip_w : BCS ..done
		LDA.b #InitZips : STA $3180
		LDA.b #InitZips>>8 : STA $3181
		LDA.b #InitZips>>16 : STA $3182
		JSR $1E80
		REP #$20
		LDA #$1801 : STA $4310
		LDX #$00
		LDY #$02

		..loop
		LDA !VRAMbase+!VRAMtable+$00,x : BEQ ..nextVR2
		STA $4315
		LDA #$0000 : STA !VRAMbase+!VRAMtable+$00,x
		LDA !VRAMbase+!VRAMtable+$02,x : STA $4312
		LDA !VRAMbase+!VRAMtable+$03,x : STA $4313
		LDA !VRAMbase+!VRAMtable+$05,x : STA $2116
		STY $420B
		..nextVR2
		TXA
		CLC : ADC #$0007
		TAX
		CMP #$0100 : BCC ..loop

		..gettiles
		LDA !VRAMbase+!TileUpdateTable+0 : BEQ ..loopfull
		STA $4315
		LDA #$0000 : STA !VRAMbase+!TileUpdateTable+0
		LDA.w #!TileUpdateTable+2 : STA $4312
		LDX.b #!VRAMbank : STX $4314
		LDA #$1604 : STA $4310
		STY $420B
		JMP ..loopfull

		..done


		PLP


	.InitMusic
		LDY #$33 : STY !SPC3					; overworld music


	.InitPalette
		REP #$10						;\
		LDX #$01FE						; |
	-	LDA.l Palette,x						; |
		STA !PaletteRGB,x					; | copy palette to RAM
		STA !ShaderInput,x					; |
		STA !PaletteBuffer,x					; |
		DEX #2 : BPL -						;/
		STA !Color0						; store color 0


		LDA !P1MapChar						;\
		AND #$00FF						; |
		XBA							; |
		LSR #3							; |
		TAX							; | load player 1 palette
		LDY #$0000						; |
	-	LDA !PalsetData,x : STA !PaletteRGB+($80*2),y		; |
		INX #2							; |
		INY #2							; |
		CPY #$0020 : BCC -					;/
		LDA !P2MapChar						;\
		AND #$00FF						; |
		XBA							; |
		LSR #3							; |
		TAX							; | load player 2 palette
		LDY #$0000						; |
	-	LDA !PalsetData,x : STA !PaletteRGB+($90*2),y		; |
		INX #2							; |
		INY #2							; |
		CPY #$0020 : BCC -					;/

		LDX #$003E						;\
	-	LDA !PaletteRGB+($80*2),x				; |
		STA !ShaderInput+($80*2),x				; | copy to buffers
		STA !PaletteBuffer+($80*2),x				; |
		DEX #2 : BPL -						;/


		SEP #$10						;


		LDX #$01
		STX !LightList+$7
		STX !LightList+$F
		STZ !LightList+8					; clear 8 + 9


		LDA !PaletteRGB+$02 : STA $00A0				;\
		LDA !PaletteRGB+$04 : STA $00A2				; |
		LDA !PaletteRGB+$06 : STA $00A4				; |
		LDA !PaletteRGB+$08 : STA $00A6				; |
		LDA !PaletteRGB+$0A : STA $00A8				; |
		LDA !PaletteRGB+$0C : STA $00AA				; | BG3 color mirrors
		LDA !PaletteRGB+$0E : STA $00AC				; |
		LDA !PaletteRGB+$10 : STA $00AE				; |
		LDA !PaletteRGB+$12 : STA $00B0				; |
		LDA !PaletteRGB+$14 : STA $00B2				; |
		LDA !PaletteRGB+$16 : STA $00B4				;/



		STZ !MapLight_S+(12*0)
		STZ !MapLight_S+(12*1)
		STZ !MapLight_S+(12*2)
		STZ !MapLight_S+(12*3)
		STZ !MapLight_S+(12*4)
		STZ !MapLight_S+(12*5)
		STZ !MapLight_S+(12*6)
		STZ !MapLight_S+(12*7)
		STZ !MapLight_X+(12*0)
		STZ !MapLight_X+(12*1)
		STZ !MapLight_X+(12*2)
		STZ !MapLight_X+(12*3)
		STZ !MapLight_X+(12*4)
		STZ !MapLight_X+(12*5)
		STZ !MapLight_X+(12*6)
		STZ !MapLight_X+(12*7)
		STZ !MapLight_Y+(12*0)
		STZ !MapLight_Y+(12*1)
		STZ !MapLight_Y+(12*2)
		STZ !MapLight_Y+(12*3)
		STZ !MapLight_Y+(12*4)
		STZ !MapLight_Y+(12*5)
		STZ !MapLight_Y+(12*6)
		STZ !MapLight_Y+(12*7)
		LDX.b #LightPoints_End-LightPoints-2 : BMI +
		CPX #$5E
		BCC $02 : LDX #$5E
	-	LDA.l LightPoints,x : STA !MapLight,x
		DEX #2 : BPL -
		+

		SEP #$30
		LDA.b #PreCalcLightPoints : STA $3180
		LDA.b #PreCalcLightPoints>>8 : STA $3181
		LDA.b #PreCalcLightPoints>>16 : STA $3182
		JSR $1E80
		REP #$20

		LDY #$00 : STY $2121					; CGRAM address = 0
		LDA #$2202 : STA $4310					;\
		LDA.w #!PaletteBuffer : STA $4312			; |
		LDA.w #!PaletteBuffer>>8 : STA $4313			; | upload palette to CGRAM
		LDA #$0200 : STA $4315					; |
		LDX #$02 : STX $420B					;/



	.InitWindow
		PHK : PLB
		SEP #$30

		LDA #$3F : TRB $40		;\ no color math
		STZ $44				;/
		LDA #$22 : STA $41		;\ hide BG1/BG2 inside window, show BG3 ONLY inside window
		LDA #$03 : STA $42		;/
		STZ $43				; > enable sprites within window
		STZ $4324			; bank 0x00 for both channels
		REP #$20
		LDA #$2601 : STA $4320		; > regs 2126 and 2127
		LDA #$0200 : STA !HDMA2source	; > table at $0200

		LDA #$00FF			;\
		STA $0201			; |
		STA $0204			; | Default window table (no window)
		STA $0207			; |
		STA $020A			;/

		SEP #$20
		LDA #$04 : TSB !HDMA		; Enable HDMA

		LDA #$07 : STA $0200		;\
		LDA #$40			; |
		STA $0203			; | Base windowing table
		STA $0206			; |
		LDA #$01 : STA $0209		; |
		STZ $020C			;/

		LDA !CharMenu : BEQ ..R		;\
		LDA #$07 : STA $0200		; |
		LDA #$70			; |
		STA $0203			; |
		LDA #$01 : STA $0206		; |
		STZ $0209			; | Char menu windowing table
		STZ $0202			; |
		STZ $0204			; |
		STZ $0208			; |
		LDA #$FF			; |
		STA $0201			; |
		STA $0207			; |
		LDA !CharMenuSize		; |
		STA $0205			; |
		LDA #$22			; |
		STA $41				; |
		STA $42				; |
		STZ $43				; |
		LDA !CharMenu			; |
		LSR A : BCC ..R			; > Disable sprite window when char menu is fully open
		LDA #$02 : STA $43		; |
		..R				;/


	.InitRender
		REP #$30						;\
		LDA.w #$412000 : STA $00				; | keep file 008 in $412000
		LDA.w #$412000>>8 : STA $01				; |
		LDA #$0008 : JSL !DecompressFile			;/
		LDA.w #$413000 : STA $00				;\
		LDA.w #$413000>>8 : STA $01				; | keep file 009 in $413000
		LDA #$0009 : JSL !DecompressFile			; |
		SEP #$30						;/
		PLP							;\ restore stuff
		PLB							;/

		LDA.b #InitRender_SA1 : STA $3180
		LDA.b #InitRender_SA1>>8 : STA $3181
		LDA.b #InitRender_SA1>>16 : STA $3182
		JSR $1E80



; $0200		0x20
; $0201		mainscreen value (4 bytes)
; $0205		0x01
; $0206		mainscreen value (4 bytes)
; $020A		0x00
;
;
; $0210		0x20
; $0211		tilemap value (1 byte)
; $0212		0x01
; $0213		tilemap value (1 byte)
; $0214		0x00
;
;
; $0220		0x20
; $0221		coords for HUD (4 bytes)
; $0225		0x01
; $0226		coords for map (4 bytes)
; $022A		0x00
;
;


	.End

		LDX #$00
		..loop
		LDA #$20
		STA $0200,x
		STA $0210,x
		STA $0220,x
		LDA #$01
		STA $0205,x
		STA $0212,x
		STA $0225,x
		STZ $020A,x
		STZ $0214,x
		STZ $022A,x
		LDA #$50 : STA $0211,x
		STA !2108
		LDA #$48 : STA $0213,x
		REP #$20
		LDA #$0012
		STA $0201,x
		STA $0203,x
		LDA #$0013
		STA $0206,x
		STA $0208,x
		STZ $0221,x
		LDA #$FFFF : STA $0223,x
		LDA $1A : STA $0226,x
		LDA $1C : STA $0228,x
		SEP #$20
		CPX #$80 : BEQ ..done
		LDX #$80 : BRA ..loop
		..done




		STZ $73D9						; some OW flag
		LDA #$01 : STA $6DB1					; from JSR $9F29 ("KeepModeActive" in all.log)
		LDA #$02 : STA $6D9B					; disable level IRQ
		STZ !HDMA						; enable HDMA??? for window???
		INC !GameMode						; go to game mode 0D
		LDA #$81 : STA $4200					; enable NMI and joypad
		JML ReturnLoad						; return



	.Tilemap
		dw $1869	; first half of BG2 (16 rows)
		dw $1C69	; second half of BG2(16 rows)
		dw $009F	; BG1 (invisible)



	.LoadEvent
		ASL A
		TAY
		LDA EventTable_Ptr-2,y : STA $0E
		LDA ($0E) : STA $08			; tile
		LDY #$0002				;\ w
		LDA ($0E),y : STA $04			;/
		LDY #$0004				;\ h
		LDA ($0E),y : STA $06			;/
		LDY #$0006				;\
		LDA ($0E),y : TAY			; | pointer to tilemap
		LDA DecompressionMap+1,y : STA $00	; |
		LDA DecompressionMap+2,y : STA $01	;/
		LDY #$0008				;\ Y = $0C = index to tilemap
		LDA ($0E),y : STA $0C			;/
		..loopy
		LDY $0C					; Y = index
		LDA $04 : STA $0A			; backup w
		LDA $08
		..loopx
		STA [$00],y
		INC A
		INY #2
		DEC $0A : BNE ..loopx
		DEC $06 : BEQ ..return
		SEC : SBC $04
		CLC : ADC #$0010
		STA $08
		LDA $0C
		CLC : ADC #$0040
		STA $0C
		BRA ..loopy
		..return
		RTS


	Palette:
	.BG
	incbin "../../PaletteData/overworld/overworld_BG.mw3":0-100
	.Sprite
	incbin "../../PaletteData/overworld/overworld_pal8.mw3":0-20
	incbin "../../PaletteData/overworld/overworld_pal9.mw3":0-20
	incbin "../../PaletteData/overworld/overworld_palA.mw3":0-20
	incbin "../../PaletteData/overworld/overworld_palB.mw3":0-20
	incbin "../../PaletteData/overworld/overworld_palC.mw3":0-20
	incbin "../../PaletteData/overworld/overworld_palD.mw3":0-20
	incbin "../../PaletteData/overworld/overworld_palE.mw3":0-20
	incbin "../../PaletteData/overworld/overworld_palF.mw3":0-20

	.CharName
	incbin "../../PaletteData/overworld/charname_col.mw3":0-C



	InitRender_SA1:
		PHB							;\
		PHP							; |
		SEP #$20						; | wrapper start
		LDA #$41						; |
		PHA : PLB						; |
		REP #$30						;/

		LDX #$0FFE						;\
	-	LDA $2000,x : STA !DecompBuffer,x			; | init HUD render area
		DEX #2 : BPL -						;/

		PHK : PLB						; B = K
		JSR ReloadP1Portrait
		JSR ReloadP1Name
		%LoadHUD(SwitchP1)
		JSR RenderHUD
		%LoadHUD(StartSolidP1)
		JSR RenderHUD
		%LoadHUD(StartSolidP2)
		JSR RenderHUD

		LDA !MultiPlayer
		AND #$00FF : BEQ .NoP2

		.AddP2
		JSR AddP2
		BRA +

		.NoP2
		JSR RemoveP2
		+

		JSR ReloadSelectArea

		SEP #$30						; all regs 8-bit
		LDA #$01						;\
		STA !MapUpdateHUD+0					; |
		STA !MapUpdateHUD+1					; | init HUD update
		STA !MapUpdateHUD+2					; |
		STA !MapUpdateHUD+3					;/

		JSL RenderName_Cache					; cache font for name render
		PLP							;\ wrapper end
		PLB							;/
		RTL							; return


	PreCalcLightPoints:
		PHB : PHK : PLB
		PHP
		REP #$30
		JSR CalcLightPoints
		STZ $2250

		.CalcR							;\
		LDX #$0000						; | init loop
		LDY #$0000						; |
		LDA !LightR : STA $2251					;/
		..loop							;\
		TXA							; |
		AND #$001E : BNE ..samerow				; |
		LDA !LightList,y					; |
		AND #$00FF : BEQ ..goodrow				; |
		TXA							; |
		CLC : ADC #$0020					; | check for shader row disable on new row
		TAX							; |
		INY							; |
		BRA ..loop						; |
		..goodrow						; |
		INY							; |
		..samerow						;/
		LDA !PaletteRGB,x					;\
		AND #$001F : STA $2253					; |
		NOP : BRA $00						; |
		LDA $2307						; |
		CMP #$001F						; | calc R
		BCC $03 : LDA #$001F					; |
		STA !PaletteBuffer,x					; |
		INX #2							; |
		CPX #$0200 : BCC ..loop					;/

		.CalcG							;\
		LDX #$0000						; | init loop
		LDY #$0000						; |
		LDA !LightG : STA $2251					;/
		..loop							;\
		TXA							; |
		AND #$001E : BNE ..samerow				; |
		LDA !LightList,y					; |
		AND #$00FF : BEQ ..goodrow				; |
		TXA							; |
		CLC : ADC #$0020					; | check for shader row disable on new row
		TAX							; |
		INY							; |
		BRA ..loop						; |
		..goodrow						; |
		INY							; |
		..samerow						;/
		LDA !PaletteRGB,x					;\
		AND #$001F*$20 : STA $2253				; |
		NOP : BRA $00						; |
		LDA $2307						; |
		AND #$001F*$20						; |
		CMP #$001F*$20						; | calc G
		BCC $03 : LDA #$001F*$20				; |
		ORA !PaletteBuffer,x					; |
		STA !PaletteBuffer,x					; |
		INX #2							; |
		CPX #$0200 : BCC ..loop					;/

		.CalcB							;\
		LDX #$0000						; | init loop
		LDY #$0000						; |
		LDA !LightG : STA $2251					;/
		..loop							;\
		TXA							; |
		AND #$001E : BNE ..samerow				; |
		LDA !LightList,y					; |
		AND #$00FF : BEQ ..goodrow				; |
		TXA							; |
		CLC : ADC #$0020					; | check for shader row disable on new row
		TAX							; |
		INY							; |
		BRA ..loop						; |
		..goodrow						; |
		INY							; |
		..samerow						;/
		LDA !PaletteRGB,x					;\
		AND #$001F*$20*$20 : STA $2253				; |
		NOP : BRA $00						; |
		LDA $2307						; |
		AND #$001F*$20*$20					; |
		CMP #$001F*$20*$20					; | calc B
		BCC $03 : LDA #$001F*$20*$20				; |
		ORA !PaletteBuffer,x					; |
		STA !PaletteBuffer,x					; |
		INX #2							; |
		CPX #$0200 : BCC ..loop					;/

		PLP
		PLB
		RTL






