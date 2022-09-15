
macro addchecksum(source)
	LDA <source> : STA !SRAM_block,x
	CLC : ADC $00
	STA $00
	BCC $02 : INC $01
	INX
endmacro

macro addtable(source, dest)
	LDA <source>,y : STA <dest>,x
	CLC : ADC $00
	STA $00
	BCC $02 : INC $01
endmacro

macro addtableW(source)
	LDA.w <source>,y : STA.w !SRAM_block,x
	CLC : ADC $00
	STA $00
	BCC $02 : INC $01
endmacro

macro countbit()
	LSR A : BCC $01 : INX
endmacro

macro countbits(number)
	rep <number> : %countbit()
endmacro


macro loadbyte(dest)
	LDA !SRAM_block,x : STA <dest>
	INX
endmacro

macro loadtable(source, dest)
	LDA <source>,x : STA <dest>,y
endmacro

macro loadtableW(dest)
	LDA.w !SRAM_block,x : STA.w <dest>,y
endmacro

macro checksum()
	LDA.w !SRAM_block,x
	CLC : ADC $00
	STA $00
	BCC $02 : INC $01
	INX
	INY
endmacro



; check init function
	CheckInitSRAM:
		REP #$20
		LDA.w #.SA1 : STA $3180				;\ set SA-1 pointer
		LDA.w #.SA1>>8 : STA $3181			;/

		LDA #$8008 : STA $4300				;\
		LDA.w #.some00 : STA $4302			; |
		LDA.w #.some00>>8 : STA $4303			; |
		LDA #$1E80 : STA $4305				; | clear $7E0000-$7E1E7F
		STZ $2181					; |
		STZ $2182					; |
		LDX #$01 : STX $420B				;/

		LDA #$E000 : STA $4305				;\
		LDA #$2000 : STA $2181				; | clear $7E2000-$7EFFFF
		STX $420B					;/

		STZ $4305					;\
		STZ $2181					; | clear $7F0000-$7FFFFF
		STX $2183					; |
		STX $420B					;/
		SEP #$20

		JSR $1E80
		RTL

	.some00
		db $00

		.SA1
		PHB
		PHP
		REP #$30

		LDA #$0000					;\
		STA $6000					; |
		STA $410000					; |
		LDA #$FFFF					; | always clear $400000-$40FFFF
		LDX #$0000					; |
		LDY #$0001					; |
		MVN $40,$40					;/
		LDA !SaveINIT+0					;\
		CMP #$4E49 : BNE .Invalid			; | check if SRAM was initialized
		LDA !SaveINIT+2					; |
		CMP #$5449 : BEQ .Valid				;/

		.Invalid
		LDA #$FFFF					;\
		LDX #$0000					; |
		LDY #$0001					; | if SRAM was not initialized, fully clear bank $41
		MVN $41,$41					; |
		LDA #$4E49 : STA !SaveINIT+0			; |
		LDA #$5449 : STA !SaveINIT+2			; |
		LDA #$00FF					; |
		STA !SRAM_block					; | > header = 0xFF (new file)
		STA !SRAM_block+$2FC				; | > checksum = 0xFF
		STA !SRAM_block+!SaveFileSize			; |
		STA !SRAM_block+!SaveFileSize+$2FC		; |
		STA !SRAM_block+(!SaveFileSize*2)		; |
		STA !SRAM_block+(!SaveFileSize*2)+$2FC		; |
		LDA.w #!ChecksumComplement-$FF			; |
		STA !SRAM_block+$2FE				; | > checksum complement = 0x6969-FF
		STA !SRAM_block+!SaveFileSize+$2FE		; |
		STA !SRAM_block+(!SaveFileSize*2)+$2FE		; |
		LDA #$0008					; |
		STA !SRAM_block+$2FA				; | > bit count = 8
		STA !SRAM_block+!SaveFileSize+$2FA		; |
		STA !SRAM_block+(!SaveFileSize*2)+$2FA		; |
		PLP						; |
		PLB						; |
		RTL						;/

		.Valid
		LDA #$AFFE					;\
		LDX #$0000					; | clear $410000-$41AFFF
		LDY #$0001					; |
		MVN $41,$41					;/
		LDA #$0000 : STA $41C000			;\
		LDA #$3FFE					; |
		LDX #$C000					; | clear $41C000-$41FFFF
		LDY #$C001					; |
		MVN $41,$41					;/
		LDA #$0000					;\
		STA !SRAM_buffer				; |
		LDA.w #!SaveFileSize-1				; |
		LDX.w #!SRAM_buffer				; |
		LDY.w #!SRAM_buffer+1				; | clear SRAM buffer
		MVN $41,$41					; |
		PLP						; |
		PLB						; |
		RTL						;/


; load function
	LoadFileSRAM:
		PHB : PHK : PLB						; bank wrapper start
		PHP							; push P
		SEP #$30						; all regs 8-bit
		LDX $610A						;\
		CPX #$03						; |
		BCC $02 : LDX #$00					; | get index to file (default to file 1 if invalid index)
		LDA SaveFileIndexHi,x : XBA				; |
		LDA SaveFileIndexLo,x					;/
		REP #$30						; all regs 16-bit
		TAX							; X = file index
		SEP #$20						; A 8-bit

		; load a bunch of variables from file
		%loadbyte(!SRAM_Difficulty)
		%loadbyte(!CoinHoard)
		%loadbyte(!CoinHoard+1)
		%loadbyte(!CoinHoard+2)
		%loadbyte(!YoshiCoinCount)
		%loadbyte(!YoshiCoinCount+1)
		%loadbyte(!Playtime)
		%loadbyte(!Playtime+1)
		%loadbyte(!Playtime+2)
		%loadbyte(!Playtime+3)
		%loadbyte(!Playtime+4)
		%loadbyte(!Characters)
		%loadbyte(!P1DeathCounter)
		%loadbyte(!P1DeathCounter+1)
		%loadbyte(!P2DeathCounter)
		%loadbyte(!P2DeathCounter+1)

		; loop to load all 5 level tables from file
		LDY #$0000
	.LevelLoop
		%loadtable(!SRAM_block+$000, !LevelTable1)
		%loadtable(!SRAM_block+$060, !LevelTable2)
		%loadtable(!SRAM_block+$0C0, !LevelTable3)
		%loadtable(!SRAM_block+$120, !LevelTable4)
		%loadtable(!SRAM_block+$180, !LevelTable5)
		INX
		INY
		CPY #$0060 : BCC .LevelLoop
		REP #$20						;\
		TXA							; |
		CLC : ADC #$0180					; | update file index past level tables 2-5
		TAX							; |
		SEP #$20						;/

		LDA.b #!SRAM_block>>16
		PHA : PLB

		; loop to add database table to file
		LDY #$0000
	.DatabaseLoop
		%loadtableW(!Database)
		INX
		INY
		CPY #$0040 : BCC .DatabaseLoop

		; loop to add character data to file
		LDY #$0000
	.CharacterLoop
		%loadtableW(!CharacterData)
		INX
		INY
		CPY #$003C : BCC .CharacterLoop


		; load overworld coords
		%loadbyte(!SRAM_overworldX)
		%loadbyte(!SRAM_overworldX+1)
		%loadbyte(!SRAM_overworldY)
		%loadbyte(!SRAM_overworldY+1)

		; load levels beaten
		%loadbyte(!LevelsBeaten)

		; loop to add story flags to file
		LDY #$0000
	.StoryFlagsLoop
		%loadtableW(!StoryFlags)
		INX
		INY
		CPY #$0089 : BCC .StoryFlagsLoop

		PLP							; pull P
		PLB							; bank wrapper end
		RTL							; return


; erase function
	EraseFileSRAM:
		PHB : PHK : PLB						; bank wrapper start
		PHP							; push P
		SEP #$30						; all regs 8-bit
		LDA.b #!SRAM_block>>16 : PHA				; push bank of SRAM area
		LDX $610A						;\
		CPX #$03 : BCS .Fail					; > must be valid index (otherwise we won't erase anything)
		LDA SaveFileIndexHi,x : XBA				; |
		LDA SaveFileIndexLo,x					; | index 16-bit and get file index
		REP #$10						; |
		TAX							;/
		PLB							; set B
		PHX							; push X

		; loop to clear bytes
		LDY #$0000
	.Loop	STZ.w !SRAM_block,x
		INX
		INY
		CPY.w #!SaveFileSize : BCC .Loop

		PLX							; pull X
		REP #$20
		LDA #$00FF : STA.w !SRAM_block,x			; mark as new file
		STA.w !SRAM_block+$2FC,x				; checksum
		LDA #!ChecksumComplement-$FF : STA.w !SRAM_block+$2FE,x	; complement
		LDA #$0008 : STA !SRAM_block+$2FA,x			; bit count

		.Fail
		PLP							; pull P
		PLB							; bank wrapper end
		RTL							; return


; new file function
; input: A = difficulty byte
	NewFileSRAM:
		STA $00
		PHB : PHK : PLB						; bank wrapper start
		PHP							; push P
		SEP #$30						; all regs 8-bit
		LDX #$5F						;\
	-	STZ !LevelTable1,x					; |
		STZ !LevelTable2,x					; |
		STZ !LevelTable3,x					; | initialize all level data to 00
		STZ !LevelTable4,x					; | (primary SRAM buffer was already cleared at bootup)
		STZ !LevelTable5,x					; |
		DEX : BPL -						;/
		LDA.b #!SRAM_block>>8 : PHA				; push bank of file
		LDX $610A						;\
		CPX #$03 : BCS .Fail					; > do nothing if invalid index
		LDA SaveFileIndexHi,x : XBA				; | get index to file
		LDA SaveFileIndexLo,x					;/
		REP #$10
		TAX
		PLB
		PHX
		LDY #$0000
	.Loop	STZ.w !SRAM_block,x
		INX
		INY
		CPY.w #!SaveFileSize : BCC .Loop
		PLX
		LDA $00 : STA.w !SRAM_block,x
		REP #$20
		LDA #!ChecksumComplement : STA.w !SRAM_block+$2FE,x

		.Fail
		PLP							; pull P
		PLB							; bank wrapper end
		RTL							; return


; save function
	SaveFileSRAM:
		PHB : PHK : PLB						; bank wrapper start
		PHP							; push P
		SEP #$30						; all regs 8-bit
		LDX $610A						;\
		CPX #$03						; |
		BCC $02 : LDX #$00					; > default to file 1 if invalid index
		LDA SaveFileIndexHi,x : XBA				; | get index to file
		LDA SaveFileIndexLo,x					;/
		REP #$30						; all regs 16-bit
		STZ $00							; clear accumulating checksum
		TAX							;\
		CLC : ADC.w #!SRAM_block				; | pointer to file (lo + hi bytes)
		STA $0D							;/
		SEP #$20						; A 8-bit
		LDA.b #!SRAM_block>>16 : STA $0F			; bank byte of pointer to file

		; add a bunch of variables to file
		%addchecksum(!SRAM_Difficulty)
		%addchecksum(!CoinHoard)
		%addchecksum(!CoinHoard+1)
		%addchecksum(!CoinHoard+2)
		%addchecksum(!YoshiCoinCount)
		%addchecksum(!YoshiCoinCount+1)
		%addchecksum(!Playtime)
		%addchecksum(!Playtime+1)
		%addchecksum(!Playtime+2)
		%addchecksum(!Playtime+3)
		%addchecksum(!Playtime+4)
		%addchecksum(!Characters)
		%addchecksum(!P1DeathCounter)
		%addchecksum(!P1DeathCounter+1)
		%addchecksum(!P2DeathCounter)
		%addchecksum(!P2DeathCounter+1)

		; loop to add all 5 level tables to file
		LDY #$0000
	.LevelLoop
		%addtable(!LevelTable1, !SRAM_block+$000)
		%addtable(!LevelTable2, !SRAM_block+$060)
		%addtable(!LevelTable3, !SRAM_block+$0C0)
		%addtable(!LevelTable4, !SRAM_block+$120)
		%addtable(!LevelTable5, !SRAM_block+$180)
		INX
		INY
		CPY #$0060 : BCC .LevelLoop
		REP #$20					;\
		TXA						; |
		CLC : ADC #$0180				; | update file index past level tables 2-5
		TAX						; |
		SEP #$20					;/

		LDA.b #!SRAM_block>>16				;\ swap bank
		PHA : PLB					;/

		; loop to add database table to file
		LDY #$0000
	.DatabaseLoop
		%addtableW(!Database)
		INX
		INY
		CPY #$0040 : BCC .DatabaseLoop

		; loop to add character data to file
		LDY #$0000
	.CharacterLoop
		%addtableW(!CharacterData)
		INX
		INY
		CPY #$003C : BCC .CharacterLoop

		; add overworld coords to file
		%addchecksum(!SRAM_overworldX)
		%addchecksum(!SRAM_overworldX+1)
		%addchecksum(!SRAM_overworldY)
		%addchecksum(!SRAM_overworldY+1)

		; add levels beaten to file
		%addchecksum(!LevelsBeaten)

		; loop to add story flags to file
		LDY #$0000
	.StoryFlagsLoop
		%addtableW(!StoryFlags)
		INX
		INY
		CPY #$0089 : BCC .StoryFlagsLoop

		; finally, perform integrity checks
		REP #$20					; A 16-bit
		LDA $00 : STA.w !SRAM_block+2,x			; store checksum
		LDA #!ChecksumComplement			;\
		SEC : SBC $00					; | store complement
		STA.w !SRAM_block+4,x				;/

		PHX						; push SRAM index
		LDX #$0000					; X = bit count
		LDY.w #!SaveFileSize-8				; Y = number of bytes to read bits from -2
	-	LDA [$0D],y					;\
		%countbits(16)					; | loop to count bits
		DEY #2 : BPL -					;/
		CPY #$FFFE : BEQ +				;\
		LDA [$0D]					; | in case file size byte count is odd, make sure they're all included
		%countbits(8)					;/
	+	TXA						;\
		PLX						; | pull SRAM index and store bit count
		STA.w !SRAM_block,x				;/

		PLP						; pull P
		PLB						; bank wrapper end
		RTL						; return

	SaveFileIndexLo:
		db $00,!SaveFileSize,!SaveFileSize*2
	SaveFileIndexHi:
		db $00,!SaveFileSize>>8,(!SaveFileSize*2)>>8

; integrity check
; returns actual checksum in $00-$01
; returns actual bit count in $02-$03
; these have to be compared to the values stored at the end of the file
	IntegrityCheckSRAM:
		PHB : PHK : PLB
		PHP
		SEP #$30
		LDX $610A
		LDA SaveFileIndexHi,x : XBA
		LDA SaveFileIndexLo,x
		REP #$30
		TAX
		CLC : ADC.w #!SRAM_block
		STA $02
		SEP #$20
		LDA.b #!SRAM_block>>16
		PHA : PLB
		LDY #$0000
		STZ $00
		STZ $01
	-	%checksum()
		CPY.w #!SaveFileSize-6 : BCC -
		REP #$20
		LDX #$0000
		LDY #$0000
	-	LDA ($02),y
		%countbits(16)
		INY #2
		CPY.w #!SaveFileSize-6 : BCC -
		STX $02
		PLP
		PLB
		RTL

