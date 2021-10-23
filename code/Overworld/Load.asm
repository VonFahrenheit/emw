




	; $00A087 - start of game mode 0C (load overworld)
	LOAD:
		STZ $4200				;\
		STZ $420C				; | JSR $937D ("TurnOffIO" in all.log)
		LDA #$80 : STA $2100			;/
		; warp pipe/star check (always 0)
		REP #$10				; index 16-bit
		LDX #$03FF				;\
	-	STZ $3200,x				; | from SA-1 patch
		DEX : BPL -				;/
		LDX #$008D				;\
	-	STZ $1A,x				; | from JSR $A1A6 ("Clear_1A_13D3" in all.log)
		DEX : BPL -				;/
		LDX #$0564				;\
	-	STZ $73D3,x				; |
		DEX : BPL -				; | from SP_Patch
		LDX #$0209				; |
	-	STZ $7998,x				; |
		DEX : BPL -				;/
		LDX #$01BE				;\
		LDA #$FF				; |
	-	STZ $64A0,x				; | wipe this table too
		STA $64A1,x				; |
		DEX #2 : BPL -				;/
		LDX #$03FF				;\
	-	LDA #$00				; | wipe VR3 tables
		STA !VRAMbase+!VRAMtable,x		; |
		DEX : BPL -				;/
		SEP #$10				; index 8-bit
		LDX #$3F				;\
	-	STZ !LevelSelectBase,x			; | wipe level select data
		DEX : BPL -				;/

		LDA #$00				;\
		LDX #$00				; |
	-	STA $400000+!MsgRAM,x			; | clear MSG RAM
		INX					; |
		CPX #$C0 : BCC -			;/

		LDA.b #!SaveGame : STA $3180		;\
		LDA.b #!SaveGame>>8 : STA $3181		; | call SA-1 to save game when loading overworld
		LDA.b #!SaveGame>>16 : STA $3182	; |
		JSR $1E80				;/


		; check whether intro level should be loaded!
		LDA !LevelTable1+$5E : BMI .LoadOverworld
		.LoadIntroLevel
		LDA #$F0 : STA $6DB0
		LDA #$10 : STA !GameMode
		LDA.b #!IntroLevel : STA $6109		; intro level (translevel num... but only kind of...)
		LDA.b #!IntroLevel>>8 : STA $7F11	; set hi bit of intro level num
		LDA #$5E : STA !Translevel		;
		LDA #$81 : STA $4200			; enable joypad but keep interrupts disabled
		JML ReturnLoad				; return



	; $00A0B0 is the actual load overworld code in all.log
		.LoadOverworld
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
	;	LDA #$53					;\
	;	STA !2109					; | BG3 tilemap: address $5000 (0xA000), size 64x64
	;	STA $2109					;/
	;	LDA #$04					;\
	;	STA !210C					; | BG3 GFX: address $4000 (0x8000)
	;	STA $210C					;/


		LDA #$80 : STA !ProcessLight			; stop this

		PHB						;\ make sure these don't mess up
		PHP						;/

		PHB						;\
		LDA #$41 : PHA					; |
		JSR KillVR3					; > kill VR3 residuals
		PLB						; |
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
		STZ.w !initzipcount
		PLB						;/


		REP #$20					; A 16-bit
		SEP #$10					; index 8-bit
		STZ $2116					; VRAM address = 0
		LDX #$80 : STX $2115				; word uploads
		LDX #$02					; X = DMA bit
		LDA #$1801 : STA $4310				; word writes to 2118-2119

	;	LDA.w #!DecompBuffer : STA $00			;\ decompression location
	;	LDA.w #!DecompBuffer>>8 : STA $01		;/
	;	LDA.w #$D01 : JSL !DecompressFile		;\
	;	LDA #$1801 : STA $4310				; |
	;	LDA.w #!DecompBuffer : STA $4312		; | upload file D01
	;	LDA.w #!DecompBuffer>>8 : STA $4313		; |
	;	LDA #$6000 : STA $4315				; |
	;	STX $420B					;/
	;	LDA #$001C					;\
	;	JSL !DecompressFile				; |
	;	LDA #$1801 : STA $4310				; |
	;	LDA.w #!DecompBuffer : STA $4312		; | upload file 01C
	;	LDA.w #!DecompBuffer>>8 : STA $4313		; |
	;	LDA #$1000 : STA $4315				; |
	;	STX $420B					;/
	;	LDA #$001D					;\
	;	JSL !DecompressFile				; |
	;	LDA #$1801 : STA $4310				; |
	;	LDA.w #!DecompBuffer : STA $4312		; | upload file 01D
	;	LDA.w #!DecompBuffer>>8 : STA $4313		; |
	;	LDA #$1000 : STA $4315				; |
	;	STX $420B					;/
	;	LDA #$0008					;\
	;	JSL !DecompressFile				; |
	;	LDA #$1801 : STA $4310				; |
	;	LDA.w #!DecompBuffer : STA $4312		; | upload file 008
	;	LDA.w #!DecompBuffer>>8 : STA $4313		; |
	;	LDA #$1000 : STA $4315				; |
	;	STX $420B					;/




		; upload BG2 GFX to 0x4000/$2000 here

		REP #$20
		LDA.w #!DecompBuffer : STA $00
		LDA.w #!DecompBuffer>>8 : STA $01
		LDA.w #$4FF : JSL !DecompressFile
		LDA #$1801 : STA $4310
		LDA.w #!DecompBuffer : STA $4312
		LDA.w #!DecompBuffer>>8 : STA $4313
		LDA #$1000 : STA $4315
		LDA #$2000 : STA $2116
		LDX #$02 : STX $420B


		REP #$10
		LDX #$0000
		LDA #$3E00
	-	STA !DecompBuffer+$00,x
		ORA #$0010 : STA !DecompBuffer+$40,x
		CLC : ADC #$0010
		STA !DecompBuffer+$80,x
		ORA #$0010 : STA !DecompBuffer+$C0,x
		INC A
		AND #$FF0F
		INX #2
		CPX #$0020
		BCC $03 : ORA #$0040
		CPX #$0040 : BCC -

		SEP #$10
		LDA #$1801 : STA $4310
		LDA.w #!DecompBuffer : STA $4312
		LDA.w #!DecompBuffer>>8 : STA $4313
		LDA #$0100 : STA $4315
		LDA #$5000 : STA $2116
		LDX #$02 : STX $420B


		; upload BG2 tilemap to 0x9000/$4800 here



		LDA.w #!DecompBuffer : STA $00			;\ decompression destination
		LDA.w #!DecompBuffer>>8 : STA $01		;/
		LDA #$6000 : STA $2116				; prepare to upload sprite GFX
		LDA #$000F					;\
		JSL !DecompressFile				; |
		LDA #$1801 : STA $4310				; |
		LDA.w #!DecompBuffer : STA $4312		; | upload file 00F
		LDA.w #!DecompBuffer>>8 : STA $4313		; |
		LDA #$1000 : STA $4315				; |
		STX $420B					;/
		LDA #$0010					;\
		JSL !DecompressFile				; |
		LDA #$1801 : STA $4310				; |
		LDA.w #!DecompBuffer : STA $4312		; | upload file 010
		LDA.w #!DecompBuffer>>8 : STA $4313		; |
		LDA #$1000 : STA $4315				; |
		STX $420B					;/
		LDA #$001C					;\
		JSL !DecompressFile				; |
		LDA #$1801 : STA $4310				; |
		LDA.w #!DecompBuffer : STA $4312		; | upload file 01C
		LDA.w #!DecompBuffer>>8 : STA $4313		; |
		LDA #$1000 : STA $4315				; |
		STX $420B					;/
		LDA #$001D					;\
		JSL !DecompressFile				; |
		LDA #$1801 : STA $4310				; |
		LDA.w #!DecompBuffer : STA $4312		; | upload file 01D
		LDA.w #!DecompBuffer>>8 : STA $4313		; |
		LDA #$1000 : STA $4315				; |
		STX $420B					;/

		LDA #$0014					;\
		JSL !DecompressFile				; |
		LDA #$8000 : STA $4310				; |
		LDA.w #!DecompBuffer : STA $4312		; |
		LDA.w #!DecompBuffer>>8 : STA $4313		; | use file 014 as AN2
		LDA #$1B00 : STA $3415				; |
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
		LDA !SRAM_overworldX
		STA !P1MapX
		STA !P2MapX
		SEC : SBC #$0078
		STA $1A
		LDA !SRAM_overworldY
		STA !P1MapY
		STA !P2MapY
		SEC : SBC #$0078
		STA $1C
		STZ !P1MapXSpeed
		STZ !P1MapAnim

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


	.InitBG1
		PHP

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

		..loopfull
		SEP #$30
		LDA !initzipcount
		CMP #$24 : BCS ..done
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



		LDY #$33 : STY !SPC3				; overworld music


		LDY #$00					;\
		STY $2121					; | CGRAM address = 0
		STY $2121					;/
		LDA #$2202 : STA $4310				;\
		LDA.w #Palette : STA $4312			; |
		LDA.w #Palette>>8 : STA $4313			; | upload palette to CGRAM
		LDA #$0200 : STA $4315				; |
		LDX #$02 : STX $420B				;/

		LDX #$01
		STX !LightList+$7
		STX !LightList+$F
		STZ !LightList+8				; clear 8 + 9


		REP #$10					;\
		LDX #$01FE					; |
	-	LDA.l Palette,x					; | copy palette to RAM
		STA !PaletteRGB,x				; |
		STA !ShaderInput,x				; |
		DEX #2 : BPL -					;/
		STA !Color0					; store color 0

		LDA !PaletteRGB+$02 : STA $00A0			;\
		LDA !PaletteRGB+$04 : STA $00A2			; |
		LDA !PaletteRGB+$06 : STA $00A4			; |
		LDA !PaletteRGB+$08 : STA $00A6			; |
		LDA !PaletteRGB+$0A : STA $00A8			; |
		LDA !PaletteRGB+$0C : STA $00AA			; | BG3 color mirrors
		LDA !PaletteRGB+$0E : STA $00AC			; |
		LDA !PaletteRGB+$10 : STA $00AE			; |
		LDA !PaletteRGB+$12 : STA $00B0			; |
		LDA !PaletteRGB+$14 : STA $00B2			; |
		LDA !PaletteRGB+$16 : STA $00B4			;/

		JSL Window_SNES					; set up windowing

		PLP						;\ restore stuff
		PLB						;/

		LDA.b #Render_Cache : STA $3180
		LDA.b #Render_Cache>>8 : STA $3181
		LDA.b #Render_Cache>>16 : STA $3182
		JSR $1E80


		STZ $73D9					; some OW flag
		LDA #$01 : STA $6DB1				; from JSR $9F29 ("KeepModeActive" in all.log)
		LDA #$02 : STA $6D9B				; disable level IRQ
		STZ !HDMA					; enable HDMA??? for window???
		INC !GameMode					; go to game mode 0D
		LDA #$81 : STA $4200				; enable NMI and joypad
		JML ReturnLoad					; return



	.Tilemap
		dw $1869	; first half of BG2 (16 rows)
		dw $1C69	; second half of BG2(16 rows)
		dw $009F	; BG1 (invisible)



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









