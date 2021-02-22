header
sa1rom

;
;
; to do...
; - remove SMW's SRAM system (including the RAM buffer in the $1Fxx block)
; - replace the nintendo presents screen, maybe use a mode7 logo or something
; - have a little animation for the title screen appearing (can be skipped by pushing any button)
; - upon pushing a button, you're taken to the file select
; - upon choosing a new file, you pick a difficulty (2 columns, 1 for primary difficulty 1 for challenge modes)
; - upon choosing an existing file, you get to see a little spreadsheet with info on your progress
; - upon starting a new file, the camera pans up into the starry sky and seamlessly transitions into the game's intro
; - upon loading an existing file, you're taken to the realm select



; SRAM:
; $41B000-$41BFFF

; file map:
; $000		- difficulty
; $001-$003	- money in coin hoard (0-999999)
; $004-$005	- number of yoshi coins
; $006		- playtime (frames, 0-59)
; $007		- playtime (seconds, 0-59)
; $008		- playtime (minutes, 0-59)
; $009-$00A	- playtime (hours, 0-9999)
; $00B		- characters (hi nybble = P1, lo nybble = P2)
; $00C-$00D	- player 1 deaths
; $00E-$00F	- player 2 deaths

; $010-$06F	- level data byte 1
; $070-$0CF	- level data byte 2
; $0D0-$12F	- level data byte 3
; $130-$18F	- level data byte 4
; $190-$1EF	- level data byte 5
;			no frame version:
;			-- 5 --  -- 4 --  -- 3 --  -- 2 --  -- 1 --
;			--mmmmmm --ssssss -rrrrrrr cccccccc BCH54321
;			frame version:
;			-- 5 --  -- 4 --  -- 3 --  -- 2 --  -- 1 --
;			mmmmmmss ssssffff ffrrrrrr rHcccccc ccB54321
;			m - best time, minutes
;			s - best time, seconds
;			r - best rank score
;			c - checkpoint level, lo byte
;			B - level beaten
;			C - checkpoint flag
;			H - checkpoint level, hi byte
;			1-5 - yoshi coins 1-5
;			(indexed by translevel number, that's why each one is 96 bytes)
; $1F0-$22F	- database (includes bestiary)
; $230-$26B	- character data
;		for each character:
;		1 B	unlock status (for mario lo nybble = powerup, hi nybble = item box)
;		1 B	upgrades
;		5 B	playtime (frames, seconds, minutes)
;		1 B	levels beaten
;		2 B	deaths
;		order is:
;			mario
;			luigi
;			kadaal
;			leeway
;			alter
;			peach
; $26C-$2F9	- story flags
; $2FA-$2FB	- bit count
; $2FC-$2FD	- checksum
; $2FE-$2FF	- checksum complement

;-shared block-
; $000-$05F	- level data byte 1
; $060-$0BF	- level data byte 2
; $0C0-$11F	- level data byte 3
;		-- 3 --  -- 2 --  -- 1 --
;		--mmmmmm --ssssss V-ffffff
;			m - best time, minutes (0-63, 60+ is displayed as "greater than 1 hour")
;			s - best time, seconds (0-59)
;			f - best time, frames (0-59)
;			V - visible (0 = this level is unlisted, 1 = this level shows up)
; $120-$129	- achievement data (1 bit per achievement)
; $12A-$12B	- bit count
; $12C-$12D	- checksum
; $12E-$12F	- checksum complement
; $130-$133	- init check

; total:
;	$272 * 3 = $756 bytes for all 3 files
;	+ $134 for shared block = $88A bytes total

; method:
;	- see if SRAM is initialized
;	if not:
;		- check if there is at least 1 file with good checksum + complement and bit count
;		if yes:
;			- "save data appears to have been corrupted"
;			- ask player if they want to reset SRAM (erase all data)
;			- if they say yes, go to step below, otherwise just write "INIT" to last 4 bytes
;		if not:
;			- clear all BWRAM
;			- set the first byte of each file data to $FF to mark them as new
;			- write "INIT" to last 4 bytes to mark SRAM as initialized
;	- check file integrity (checksum + complement, bit count)
;	if not:
;		- write "HACKED" in ugly red text next to the file
;	- loading:
;		- store file index
;		- copy file data into RAM
;	- saving:
;		- load file index
;		- copy RAM to file data
;		- create checksum + complement
;		- count number of set bits (bit count)
;		  (integrity markers are not counted by themselves or each other)
;	- erasing:
;		- load file index
;		- write $00 to the entire file
;		- write $FF to the first byte of file data to mark it as new
;	- creating new:
;		- load file index
;		- write $00 to the entire file
;		- write difficulty + challenge mode flags to first byte


; example achievements:
;	main game
;	- defeat kingking and free rex island
;	- destroy the lab and free realm 3
;	- uncover the ancient evil lurking under realm 4
;	- defeat the realm 5 boss
;	- defeat the realm 6 boss
;	- defeat the ultimate koopa (realm 7)
;	- save the world (realm 8)
;	- free all the realms, then save the world
;	- uncover the secrets of the abyssal cult (4 temples)
;	- collect every yoshi coin
;	- 100% completion

;	choices
;	- kill/recruit lakitu lords

;	characters
;	- recruit leeway
;	- recruit alter
;	- recruit peach
;	- get an upgrade
;	- unlock an ultimate upgrade
;	- fully upgrade a character
;	- fully upgrade all characters
;	- buy a new palette
;	- buy a palette for each character

;	challenge modes
;	- beat the game on insane
;	- beat the game on time mode
;	- beat the game on critical mode
;	- beat the game on hardcore mode
;	- hardcore 100%
;	- critical hardcore
;	- beat the game with an overall rank of B or higher
;	- beat the game with an overall rank of S
;	- beat the game with a perfect rank score of 100
;	- insane difficulty, all challenge modes, S rank

;	"outside" the game itself
;	- get an S rank on every level
;	- speedrun 1
;	- speedrun 2
;	- speedrun 100%
;	- speedrun segmented (individual levels total)

;	secrets
;	- find the dreamy colosseum
;	- defeat every dream boss on the first floor of the dreamy colosseum
;	- defeat the nightmare bosses in the dreamy colosseum
;	- attain enlightenment and defeat the masters in the dreamy colosseum
;	- find all 8 bits


; frames to seconds/1000
; 000
; 017
; 034
; 050
; 067
; 084
; 100
; 217
; 234
; 250
; 267
; 284
; 300
; 317
; 334
; 350
; 367
; 384
; 400
; 417
; 434
; 450
; 467
; 484
; 500
; 517
; 534
; 550
; 567
; 584
; 600
; 617
; 634
; 650
; 667
; 684
; 717
; 734
; 750
; 767
; 784
; 800
; 817
; 834
; 850
; 867
; 884
; 900
; 917
; 934
; 950
; 967
; 984



print "-- SP_MENU --"



; legacy stuff
;	!FreeRAM		= $4100			; Assume !FreeBNK (Indexed by Y so it has to be 16-bit)
;	!FreeBNK		= $40
;	!DataLength		= DataEnd-DataStart
;	!RAM_buffer		= $4000			; Same thing here, assume !FreeBNK so I can index with Y
;	!FreeSRAM		= $41C400
;	!DifficultySize		= DataEnd-Difficulty
;	!CustomSize		= CustomStripeEnd-CustomStripe
;	!Permanent		= $41C7FC


	incsrc "Defines.asm"				; Include standard defines


;==========;
;STATUS BAR;
;==========;

	org $0084E2
	;	dl !FreeBNK*$10000+!FreeRAM		; Location of 1/2 player select stripe

	org $008C81					; Status bar tilemap
	CUSTOM_BAR:
		dw $28FC,$24FC,$24FC,$24FC,$24FC	; > P1 coins
		dw $20FC,$20FC,$20FC,$20FC,$20FC,$20FC	; > P1 hearts
		dw $28FC,$28FC,$28FC,$28FC,$28FC	;\ Yoshi coins
		dw $28FC,$28FC,$28FC,$28FC,$28FC	;/
		dw $20FC,$20FC,$20FC,$20FC,$20FC,$20FC	; > P2 hearts
		dw $28FC,$24FC,$24FC,$24FC,$24FC	; > P2 coins

; org $008CC1
		dw $28FC,$28FC,$28FC,$28FC		; default status bar to empty space
		dw $28FC,$28FC,$28FC,$28FC
		dw $28FC,$28FC,$28FC,$28FC
		dw $28FC,$28FC,$28FC,$28FC
		dw $28FC,$28FC,$28FC,$28FC
		dw $28FC,$28FC,$28FC,$28FC
		dw $28FC,$28FC,$28FC,$28FC
		dw $28FC,$28FC,$28FC


; $0FFE7E


	org $009CB5					; prevent routine from being called
		BRA $01 : NOP				; org: JSR $9F06
	org $009F06					; block this entire "load OW level tables" routine
		RTS					;\ org: LDX #$8D
		RTS					;/
;	org $009F19					; prevent level data from resetting
;		BRA $02 : NOP #2			; Source: JSL $05DD80 (inserted by Lunar Magic)


	org $008CFF
		RTS					; Source: LDA #$80
		NOP					; prevent BG3 from being clipped at level load


	org $008D04					; Set lo byte of dest VRAM for status bar tilemap
		LDA #$00				; Source: LDA #$2E
	org $008D19					;\
		BRA +					; | Skip past SMW's BG3 transfers
	org $008D76					; |
		+					;/
	org $008D7B
		LDA #$28				;\
		STA $6F30				; | Source: LDX #$36 : LDY #$6C : LDA.w $8C89,y
		RTS					;/
		NOP

	org $008D90
		db $01,$18,$81,$8C,$00,$40,$00		; DMA settings for status bar upload


; this conflicts with VR3
;	if read1($0081E2) == $5C
;	!TempAddr = read3($0081E3)
;	org $0081CE
;		LDA $40
;		AND #$FB
;		STA $2131
;		LDA #$09
;		STA $2105
;		LDA $10
;		BEQ $09
;		LDA $6D9B
;		LSR A
;		JML !TempAddr
;		NOP
;		INC $10
;		JSR $A488
;		LDA $6D9B
;		LSR A
;		BNE $30
;		BRA $03
;		NOP #3
;		LDA $73C6
;		CMP #$08
;		BNE $0B
;		LDA $7FFE
;		BEQ $17
;	endif


	org $008DAC					; Code that uploads the status bar
		RTS					; > Return
	warnpc $008DFE


	org $008E1A					; Code that handles the status bar
	STATUS_BAR:
		LDA !Difficulty				;\
		AND #$10				; | Only use timer during Time Mode
		BEQ .Coins				;/
		LDA $7493				;\
		ORA $9D					; | Don't decrement timer if level is ending or sprites are locked
		BNE .NoTimer				;/
		LDA $6D9B
		CMP #$C1
		BEQ .NoTimer
		DEC $6F30
		BPL .NoTimer
		LDA #$28
		STA $6F30
		LDA $6F31
		ORA $6F32
		ORA $6F33
		BEQ .NoTimer
		LDX #$02				;\
	-	DEC $6F31,x				; |
		BPL +					; |
		LDA #$09				; | Decrement timer
		STA $6F31,x				; |
		DEX					; |
		BPL -					;/
	+	LDA $6F31
		BNE +
		LDA $6F32				;\
		AND $6F33				; |
		CMP #$09				; | Speed up music when time is 99
		BNE +					; |
		LDA #$1D				; |
		STA !SPC1				;/
	+	LDA $6F31				;\
		ORA $6F32				; |
		ORA $6F33				; | Kill Mario when time is zero
		BNE .NoTimer				; |
		JSL $00F606				;/
		LDA #$01				;\
		STA !P2Status-$80			; | Kill PCE characters
		STA !P2Status				;/

.NoTimer	; TIMER WRITE TO OAM GOES HERE

.Coins		LDA !CoinSound
		BEQ $03 : DEC !CoinSound
		REP #$20				; > A 16 bit
		LDX !P1CoinIncrease
		BEQ .Next
	.P1	DEC !P1CoinIncrease
		INC !P1Coins
		JSR CoinSound
	.Next	LDX !P2CoinIncrease
		BEQ .Nope
	.P2	DEC !P2CoinIncrease
		INC !P2Coins
		JSR CoinSound
	.Nope	LDA #$270F				;\
		CMP !P1Coins				; |
		BCS $03 : STA !P1Coins			; | Cap coins at 9999
		CMP !P2Coins				; |
		BCS $03 : STA !P2Coins			;/
		LDA !P1Coins				;\
		JSL Thousands				; |
		STY !StatusBar+$01			; |
		STX !StatusBar+$02			; | Run coin counter for player 1
		JSL HexToDec				; |
		STX !StatusBar+$03			; |
		STA !StatusBar+$04			;/
		LDA !MultiPlayer : BEQ +		;\
		REP #$20				; |
		LDA !P2Coins				; | Run coin counter for player 2
		JSL Thousands				; |
		STY !StatusBar+$1C			; |
		STX !StatusBar+$1D			; |
		JSL HexToDec				; |
		STX !StatusBar+$1E			; |
		STA !StatusBar+$1F			;/
	+	REP #$20
		LDA #$FCFC				;\
		STA !StatusBar+$05			; |
		STA !StatusBar+$07			; |
		STA !StatusBar+$09			; |
		STA !StatusBar+$0B			; |
		STA !StatusBar+$12			; | Empty space
		STA !StatusBar+$14			; |
		STA !StatusBar+$16			; |
		STA !StatusBar+$18			; |
		SEP #$20				; |
		STA !StatusBar+$1A			;/
		LDA #$0B				;\
		STA !StatusBar+$00			; | Coin symbols
		STA !StatusBar+$1B			;/

.YoshiCoins	LDA !MegaLevelID : BEQ +		; Check for mega level
		TAX
		LDA #$0A : STA $01
		LDY #$05
		BRA ..Start

	+	LDX !Translevel
		LDA #$07 : STA $01
		LDY #$02

	..Start	LDA !LevelTable1,x			; Load Yoshi Coins collected table
		STA $00
	-	LDX #$00				;\
		ROR $00					; | Proper index
		BCC $01 : INX				;/
		LDA.w .YoshiCoinGFX,x			; Load tile to use
		STA !StatusBar+$0B,y			; Base address of Yoshi Coins on status bar

		INY
		CPY $01 : BNE -				; Loop
		CPY #$0A : BNE +
		LDX !Translevel
		LDA #$05 : STA $01
		LDY #$00
		BRA ..Start
		+


		LDA !MultiPlayer : BNE .Player1HP	;\
		LDA #$FC				; |
		STA !StatusBar+$1B			; | Wipe player 2 coin counter during singleplayer
		STA !StatusBar+$1C			; |
		STA !StatusBar+$1D			; |
		STA !StatusBar+$1E			; |
		STA !StatusBar+$1F			;/

.Player1HP	LDA !P2Status-$80			;\ Don't write player 1 HP if player 1 is dead
		BNE .Player2HP				;/
		LDX !P2HP-$80				;\
		CPX !P2MaxHP-$80			; |
		BCC $03 : LDX !P2MaxHP-$80		; |
		BEQ .Player2HP				; |
		DEX					; |
		LDA #$0A				; | Write player 1 HP
	-	STA !StatusBar+$06,x			; |
		DEX					; |
		BPL -					;/
.Player2HP	LDA !P2Status				;\ Don't write player 2 HP if player 2 is dead
		BNE .MarioCheck				;/
		LDX !P2HP				;\
		CPX !P2MaxHP				; |
		BCC $03 : LDX !P2MaxHP			; |
		BEQ .MarioCheck				; |
		DEX					; |
		LDA #$0A				; | Write player 2 HP
	-	STA !StatusBar+$17,x			; |
		DEX					; |
		BPL -					;/	
.MarioCheck	LDA !CurrentMario : BEQ .Return		; > If no one is playing Mario, return
		TAY					;\ X = Index to status bar
		LDX.w .MarioIndex-1,y			;/
		LDY $6DC2				;\ Load Mario's item
		LDA.w .MarioItem,y			;/
		STA !StatusBar,x			; > Write to status bar
.Return		RTS					; > Return


.MarioIndex	db $07,$18				; > Mario's index to status bar
.MarioItem	db $FC,$0D,$0E,$0F,$FC			; Nothing, mushroom, flower, star, feather (nothing)


.ScoreData	db $01,$00,$A0,$86,$00,$00,$10,$27
		db $00,$00,$E8,$03,$00,$00,$64,$00
		db $00,$00,$0A,$00,$00,$00,$01,$00

.YoshiCoinGFX:	db $0C,$0B				; Not collected, collected

;.1UpLimit	db $09,$04,$02

		Thousands:
		LDX #$00
		LDY #$00
	.1000	CMP #$03E8 : BCC .100
		SBC #$03E8
		INY
		BRA .1000
	.100	CMP #$0064 : BCC .10
		SBC #$0064
		INX
		BRA .100
	.10	SEP #$20
		RTL

		HexToDec:
		LDX #$00
	.10	CMP #$0A : BCC .1
		INX
		SBC #$0A
		BRA .10
	.1	RTL

		CoinSound:
		LDX !CoinSound : BNE .ManyCoins
		LDX #$01 : STX !SPC4
		LDX #$04 : STX !CoinSound

		.ManyCoins
		RTS
warnpc $009045


;=================================;
;OLD MENU CODE, KEEP FOR REFERENCE;
;=================================;

	org $00905B
		SBC.w STATUS_BAR_ScoreData+$02,y	; Fix this offset

	org $00940F					; Hijack Game Mode 01 routine
	;	JML INIT				;\ Source: DEC $1DF5 : BNE $06 ($00941A)
	;	NOP					;/
		DEC $7DF5
		BNE $06


	org $009AEA
	;	JML CURSOR_GFX				; Hijack the code that handles the menu position
		PLA
		PLA
		LDA $16

	org $009AF9
	;	JML CURSOR_SFX				; Hijack the code that handles the menu cursor SFX
	;	NOP
		LDY #$06 : STY !SPC4

	org $009B3D					; The code that erases save files
	;	JML ERASE				; Source: CPX #$03 : BNE CODE_009B6D (2C)
		CPX #$03 : BNE $2C

	org $009BCB					; Hijack save game routine
	;	JML SAVE				; Source: PLB : LDX $010A
		PLB
		LDX $610A

	org $009D22					; Hijack load save file routine
	;	JSL LOAD				; Source: SEP #$10 : LDY #$12
		SEP #$10
		LDY #$12

	org $009D29					; The code that activates 1/2 player select
	;	JSL CUSTOM_MENU				; Source: STY $12 : LDX #$00
		STY $12
		LDX #$00

	org $009D55					; Code that determines the base address for yellow numbers
	;	JSL FIX_OFFSET_Base			; Fix base address for yellow numbers
		LDA #$84 : STA $00

	org $009DA8					; Code that updates yellow numbers for each file
	;	JSL FIX_OFFSET				;\ Source: LDA $00 : SEC : SBC #$24
	;	NOP					;/
		LDA $00
		SEC : SBC #$24

	org $009E0D					; The code that sets SMW's 2 player mode
	;	JML SET_DIFFICULTY			; Hijack 2 player mode routine
	;	NOP : NOP				; Source: STX $0DB2 : JSR $A195
		STX $6DB2
		JSR $A195

	org $009E6E					; Number of options during 1/2 player select
	;	db $03					; Enable 3 options



;=======================;
;POWERUPS AND ANIMATIONS;
;=======================;

	org $00F37A					; Code that updates number of Yoshi Coins collected
		JSL YOSHI_COIN				; Source: INC $1420 : CLC

	org $00F5F8
		BRA $02 : NOP #2			; prevent item in item box from automatically falling

	org $00F620
		STZ $9D					; prevent game from pausing when Mario gets hurt

	org $01C563
		INC $19					; remove grow animation

	org $01C56A
		STZ $9D					; prevent game from pausing when Mario gets a mushroom

	org $01C5A3
		BRA $02 : NOP #2			; prevent some infinite score exploit

	org $01C5AB
		STZ $9D					; prevent game from pausing when Mario gets a cape

	org $01C5B6
		STZ $71					; remove get cape animation

	org $01C5F1
		STZ $9D					; prevent game from pausing when Mario gets a flower

	org $01C5F3
		STZ $7407				; remove get fire animation
		NOP

	org $028008
	ItemBox:
		PHX					; preserve X
		LDX $6DC2				;\
		LDA.w .Status,x				; |
		LDY !MarioPowerUp			; | swap powerups
		STA !MarioPowerUp			; |
		LDA.w .Box,y : STA $6DC2		;/
		BNE .NoSFX				;\
		LDA !MarioPowerUp : BEQ .NoSFX		; | powerup sound when going small -> big
		LDA #$0A : STA !SPC1			;/
		.NoSFX

		LDA !MarioClimb : BEQ .Return		;\
		LDA !MarioPowerUp			; |
		BEQ $02 : LDA #$01			; |
		STA $00					; | return if no climb or if size is unchanged
		TYA					; |
		BEQ $02 : LDA #$01			; |
		TAY					; |
		EOR $00 : BEQ .Return			;/
		LDA !MarioYPosLo			;\
		CLC : ADC .YCoord,y			; | adjust Mario Ycoord
		STA !MarioYPosLo			;/

	.Return	PLX					; restore X
		RTL					; return

		.Status
		db $00,$01,$03,$01,$01,$01

		.Box
		db $00,$01,$01,$02

		.YCoord
		db $FE,$02

	warnpc $028072


;================;
;DELETE DATA MENU;
;================;

	org $05B6FE					; Stripe image data of delete data menu
	DataStart:
		db $51,$E5,$40,$2E			; RLE header (24 tiles)
		db $FC,$38				; empty space
		db $52,$08,$40,$1C			; RLE header (14 tiles)
		db $FC,$38				; empty space
		db $52,$25,$40,$2E			; RLE header (24 tiles)
		db $FC,$38				; empty space
		db $52,$48,$40,$1C			; RLE header (14 tiles)
		db $FC,$38				; empty space
		db $52,$65,$40,$2E			; RLE header (24 tiles)
		db $FC,$38				; empty space
		db $52,$A5,$40,$1C			; RLE header (14 tiles)
		db $FC,$38				; empty space

		; Clear "DATA 1", "DATA 2", "DATA 3", "ERASE DATA" and arrow graphics from the screen
		db $51,$ED,$00,$1F			; Stripe image header (15 tiles)
		db $7C,$30				; D
		db $71,$31				; A
		db $2F,$31				; T
		db $71,$31				; A
		db $FC,$38				; empty space
		db $6D,$31				; 1
		db $FC,$38				;\
		db $FC,$38				; |
		db $FC,$38				; |
		db $FC,$38				; |
		db $FC,$38				; | empty space
		db $FC,$38				; |
		db $FC,$38				; |
		db $FC,$38				; |
		db $FC,$38				; |
		db $FC,$38				;/

		; Put "DATA 1 " on the screen
		db $52,$2D,$00,$1F			; Stripe image header (16 tiles)
		db $7C,$30				; D
		db $71,$31				; A
		db $2F,$31				; T
		db $71,$31				; A
		db $FC,$38				; empty space
		db $6E,$31				; 2
		db $FC,$38				;\
		db $FC,$38				; |
		db $FC,$38				; |
		db $FC,$38				; |
		db $FC,$38				; | empty space
		db $FC,$38				; |
		db $FC,$38				; |
		db $FC,$38				; |
		db $FC,$38				; |
		db $FC,$38				;/

		; Put "DATA 2" on the screen
		db $52,$6D,$00,$1F			; Stripe image header (16 tiles)
		db $7C,$30				; D
		db $71,$31				; A
		db $2F,$31				; T
		db $71,$31				; A
		db $FC,$38				; empty space
		db $4E,$30				; 3
		db $FC,$38				;\
		db $FC,$38				; |
		db $FC,$38				; |
		db $FC,$38				; |
		db $FC,$38				; | empty space
		db $FC,$38				; |
		db $FC,$38				; |
		db $FC,$38				; |
		db $FC,$38				; |
		db $FC,$38				;/

		; Put "DATA 3" on the screen
		db $51,$E7,$00,$0B			; Stripe image header (6 tiles)
		db $73,$31				; E
		db $74,$31				; R
		db $71,$31				; A
		db $31,$31				; S
		db $73,$31				; E
		db $FC,$38				; empty space

		; Put "ERASE" in front of "DATA 1"
		db $52,$27,$00,$0B			; Stripe image header (6 tiles)
		db $73,$31				; E
		db $74,$31				; R
		db $71,$31				; A
		db $31,$31				; S
		db $73,$31				; E
		db $FC,$38				; empty space

		; Put "ERASE" in front of "DATA 2"
		db $52,$67,$00,$0B			; Stripe image header (6 tiles)
		db $73,$31				; E
		db $74,$31				; R
		db $71,$31				; A
		db $31,$31				; S
		db $73,$31				; E
		db $FC,$38				; empty space

		; Put "ERASE" in front of "DATA 3"
		db $52,$A7,$00,$05			; Stripe image header (6 tiles)
		db $73,$31				; E
		db $30,$31				; N
		db $7C,$30				; D

		; Put "END" on the screen
		db $FF					; End DMA read


;================;
;FILE SELECT MENU;
;================;

	org $05B7C9					; Stripe image data of file select menu
		db $51,$E5,$40,$2F			; RLE header (24 tiles)
		db $FC,$38				; empty space
		db $52,$08,$40,$1C			; RLE header (14 tiles)
		db $FC,$38				; empty space
		db $52,$25,$40,$2E			; RLE header (24 tiles)
		db $FC,$38				; empty space
		db $52,$48,$40,$1C			; RLE header (14 tiles)
		db $FC,$38				; empty space
		db $52,$65,$40,$2E			; RLE header (24 tiles)
		db $FC,$38				; empty space
		db $52,$A5,$40,$1C			; RLE header (14 tiles)
		db $FC,$38				; empty space
		db $52,$88,$40,$20			; RLE header (14 tiles)
		db $FC,$38				; empty space

		; Clear "EASY", "NORMAL", "INSANE" and arrow graphics from the screen
		db $51,$EA,$00,$1D			; Stripe image header (15 tiles)
		db $7C,$30				; D
		db $71,$31				; A
		db $2F,$31				; T
		db $71,$31				; A
		db $FC,$38				; empty space
		db $6D,$31				; 1
		db $FC,$38				;\
		db $FC,$38				; |
		db $FC,$38				; |
		db $FC,$38				; <
		db $FC,$38				; | empty space
		db $FC,$38				; |
		db $FC,$38				; |
		db $FC,$38				; |
		db $FC,$38				;/

		; Put "DATA 1" on the screen
		db $52,$2A,$00,$1D			; Stripe image header (16 tiles)
		db $7C,$30				; D
		db $71,$31				; A
		db $2F,$31				; T
		db $71,$31				; A
		db $FC,$38				; empty space
		db $6E,$31				; 2
		db $FC,$38				;\
		db $FC,$38				; |
		db $FC,$38				; |
		db $FC,$38				; |
		db $FC,$38				; < empty space
		db $FC,$38				; |
		db $FC,$38				; |
		db $FC,$38				; |
		db $FC,$38				;/

		; Put "DATA 2" on the screen
		db $52,$6A,$00,$1D			; Stripe image header (16 tiles)
		db $7C,$30				; D
		db $71,$31				; A
		db $2F,$31				; T
		db $71,$31				; A
		db $FC,$38				; empty space
		db $4E,$30				; 3
		db $FC,$38				;\
		db $FC,$38				; |
		db $FC,$38				; |
		db $FC,$38				; |
		db $FC,$38				; | empty space
		db $FC,$38				; <
		db $FC,$38				; |
		db $FC,$38				; |
		db $FC,$38				;/

		; Put "DATA 3" on the screen
		db $52,$AA,$00,$13			; Stripe image header (12 tiles)
		db $73,$31				; E
		db $74,$31				; R
		db $71,$31				; A
		db $31,$31				; S
		db $73,$31				; E
		db $FC,$38				; empty space
		db $7C,$30				; D
		db $71,$31				; A
		db $2F,$31				; T
		db $71,$31				; A

		; Put "ERASE DATA" on the screen
		db $FF					; End DMA read

		; My data recquires an extra RLE write (to clear "INSANE" from the screen).
		; That made it necessary for the save file names to each be one character shorter.


;=========================;
;DIFFICULTY SELECTION MENU;
;=========================;

	org $05B872					; Stripe image data of 1/2 player select
	Difficulty:
		db $51,$E5,$40,$2F			; RLE header (24 tiles)
		db $FC,$38				; empty space
		db $52,$25,$40,$2F			; RLE header (24 tiles)
		db $FC,$38				; empty space
		db $52,$65,$40,$2F			; RLE header (24 tiles)
		db $FC,$38				; empty space
		db $52,$A6,$40,$1C			; RLE header (14 tiles)
		db $FC,$38				; empty space

		; Clear the "DATA 1", "DATA 2", "DATA 3", "ERASE DATA" and arrow graphics from the screen.
		db $52,$0B,$00,$07			; Stripe image header (4 tiles)
		db $73,$31				; E
		db $71,$31				; A
		db $31,$31				; S
		db $72,$31				; Y

		; Put "EASY" on the screen.
		db $52,$4B,$00,$0B			; Stripe image header (6 tiles)
		db $30,$31				; N
		db $7A,$30				; O
		db $74,$31				; R
		db $76,$31				; M
		db $71,$31				; A
		db $70,$31				; L

		; Put "NORMAL" on the screen.
		db $52,$8B,$00,$0B			; Stripe image header (6 tiles)
		db $82,$30				; I
		db $30,$31				; N
		db $31,$31				; S
		db $71,$31				; A
		db $30,$31				; N
		db $73,$31				; E

		; Put "INSANSE" on the screen.
		db $FF					; End DMA read

		; My data is 4 bytes smaller than the original so there are 4 bytes of freespace here.
	DataEnd:


;=============;
;DISABLE SCORE;
;=============;
; see FusionCore.asm for score sprites

org $028766		;\
	BRA +		; |
	NOP #11		; | disable score from breaking blocks
warnpc $028773		; |
org $028773		; |
	+		;/

org $02AE21		;\
	BRA +		; |
	NOP #18		; | disable score from score sprites
warnpc $02AE35		; |
org $02AE35		; |
	+		;/

org $05CEF9		;\
	BRA +		; |
	NOP #10		; | disable score from beating a level
warnpc $05CF05		; |
org $05CF05		; |
	+		;/

org $05B333
	ADC !P1CoinIncrease
	STA !P1CoinIncrease

org $05B34A		; This routine gives coins from blocks and such
	JSL BetterCoins	;\
	BRA $02		; | Source: INC $73CC : LDA #$01 : STA !SPC4
	NOP #2		;/


org $02ADBD		; Disable score sprites
	JML DisableScore









org $128000

db $53,$54,$41,$52		;\
dw $7FF7			; | Claim this bank
dw $8008			;/


;===============;
;PRESENTS SCREEN;
;===============;
; hijacked below, just search for the label
Mode7Presents:
		%ResetTracker()

		PHP

		REP #$30
		LDX #$00FE
		LDA #$0000
	-	STA $400000+!MsgRAM,x
		DEX #2 : BPL -

		SEP #$30

	-	BIT $4212 : BPL -			; wait for v-blank to avoid tearing
		LDA #$80 : STA $2100			; f-blank baybeee
		STZ $2115				; lo byte only first to upload tilemap

		REP #$20
		LDA.w #!DecompBuffer : STA $00
		LDA.w #!DecompBuffer>>8 : STA $01
		LDA.w #$B00
		JSL !DecompressFile
		LDA #$1800 : STA $4300
		LDA.w #!DecompBuffer : STA $4302
		LDA.w #!DecompBuffer>>8 : STA $4303
		LDA #$4000 : STA $4305
		STZ $2116
		LDX #$01 : STX $420B

		LDX #$80 : STX $2115			; hi byte only to upload GFX
		LDA.w #!DecompBuffer : STA $00
		LDA.w #!DecompBuffer>>8 : STA $01
		LDA.w #$D00
		JSL !DecompressFile
		LDA #$1900 : STA $4300
		LDA.w #!DecompBuffer : STA $4302
		LDA.w #!DecompBuffer>>8 : STA $4303
		LDA #$4000 : STA $4305
		STZ $2116
		LDX #$01 : STX $420B

		LDX #$01 : STX $2121			; CGRAM color 1
		LDA #$2202 : STA $4300			; 2122 write twice
		LDA.w #.SourcePal : STA $4302
		LDA.w #.SourcePal>>8 : STA $4303
		LDA #$003E : STA $4305
		LDX #$01 : STX $420B	

		LDX #$07 : STX $2105			; mode 7
		STX $3E
		LDX #$00 : STX $211B
		LDX #$01 : STX $211B
		LDX #$00 : STX $211C
		LDX #$00 : STX $211C
		LDX #$00 : STX $211D
		LDX #$00 : STX $211D
		LDX #$00 : STX $211E
		LDX #$01 : STX $211E
		LDX #$C0 : STX $211A			; mode 7 settings: large playfield, char 0 fill, no mirroring

		SEP #$20
		LDA #$01 : STA $212C
		STA !MainScreen

		STZ $7DF5

		PLP
		RTL
.SourcePal
incbin "PresentsScreenPalette.mw3"


	pushpc
	org $00940F
		JML DisplayPresentsScreen		;\ org: DEC $7DF5 : BNE $06 ($00941A)
		NOP					;/
	pullpc

	DisplayPresentsScreen:
		LDA $16					;\
		ORA $18					; | skip animation with any button press
		AND #$F0 : BEQ +			; | (but not d-pad)
		LDA #$01 : STA $7DF5			;/
	+	DEC $7DF5				; decrement timer
	-	BIT $4212 : BPL -			; somehow doing this during h-blank makes snes9x go absolutely crazy... so we're waiting for v-blank
		LDA $7DF5 : STA $211B
		LDA #$01 : STA $211B
		LDA $7DF5 : STA $211E
		LDA #$01 : STA $211E
		LDA #$80 : STA $211F
		STZ $211F
		LDA #$70 : STA $2120
		STZ $2120
		LDA $7DF5 : BEQ .NextGameMode
		JML $00941A

		.NextGameMode
		JML $009414


; $1F49 referenced at:
;	- $009BDE (save game routine, buffer -> SRAM)
;	- $009D18 (load game routine, SRAM -> buffer)
;	- $009F16 (load overworld routine, ROM -> buffer)
;	- $00A19A (load game routine, buffer -> main table)
;	- $049046 (overworld routine, main table -> buffer)

; $40B000 - permanent data
; /\
; ||
; \/
; various RAM tables - current data

; game modes:
;	07	title screen (animation, run level code)
;	08	main menu (hijack this mode and run all the menu codes from here)
;	09	REMOVED
;	0A	REMOVED
;	0B	load realm select


	!MenuTemp	= 0
	!MenuRAM	= $0C80		; up to 128 bytes

macro menuRAM(name, size)
	!Menu<name> := !MenuRAM+!MenuTemp
	!MenuTemp := !MenuTemp+<size>
endmacro

	%menuRAM(State, 1)
	%menuRAM(BG1_X, 2)		; X of menu item
	%menuRAM(BG1_Y, 2)		; Y of menu item
	%menuRAM(BG3_X_1, 2)		; X of file 1
	%menuRAM(BG3_X_2, 2)		; X of file 2
	%menuRAM(BG3_X_3, 2)		; X of file 3
	%menuRAM(BG3_Y_1, 2)		; Y of file 1
	%menuRAM(BG3_Y_2, 2)		; Y of file 2
	%menuRAM(BG3_Y_3, 2)		; Y of file 3
	%menuRAM(ChallengeSelect, 1)	; which challenge mode the cursor is currently on
	%menuRAM(Integrity_1, 1)	; integrity check for files (for bits 0-2, 0 = good, 1 = bad)
	%menuRAM(Integrity_2, 1)	; bit 0 = checksum, bit 1 = checksum complement, bit 2 = bit count
	%menuRAM(Integrity_3, 1)	;
	%menuRAM(EraseTimer, 1)		; counts up while L + R are held, used to erase a file



;
; RAM usage for menu:
; $400-$BFF:	buffer for loading layer 1 tilemap from map16
; $C00-$C1F:	2 tables for layer 1 HDMA (mode 3)
; $D00-$D1F:	2 tables for layer 3 HDMA (mode 3)
;
;

;=========;
;MAIN MENU;
;=========;
MAIN_MENU:
	pushpc
	org $009CA3
		BRA 16 : NOP #16	; remove some writes to PPU regs when menu is loaded
	warnpc $009CB5

	org $009329+(8*2)
		dw .Repoint
	org $009CD1
		; FUCK YOU LUNAR MAGIC I WIN!!
	org $009CD8
	.Repoint
		JML .Main		;\ org: JSR $9D30 : LDY #$02
		NOP			;/
	pullpc

	.Main
		PHB : PHK : PLB
		PHP
		SEP #$30

		LDA #$5F : STA !Translevel			; use final slot to index text
		LDA !MsgTrigger : BEQ .NoText
		LDA #$10 : TRB !HDMA				; disable BG3 HDMA
		%CallMSG()
		.NoText

		JSL !KillOAM

		LDA !MenuEraseTimer : BEQ .RestoreWindow
		LDY $610A
		LDA $13
		AND #$01
		BEQ $02 : LDA #$10
		STA !HDMA5source
		CLC : ADC .WindowIndex,y
		TAX
		LDA !MenuEraseTimer
		CLC : ADC .WindowOffset,y
		STA $0E02,x
		LDA .WindowOffset,y : STA $0E01,x
		BRA .NoWindow

		.RestoreWindow
		LDA $13
		AND #$01
		BEQ $02 : LDA #$10
		TAX
		LDA #$FF
		STA $0E01,x
		STZ $0E02,x
		STA $0E04,x
		STZ $0E05,x
		STA $0E07,x
		STZ $0E08,x
		STA $0E0A,x
		STZ $0E0B,x
		STX !HDMA5source
		.NoWindow


		LDA !MenuState
		ASL A
		CMP.b #.Ptr_End-.Ptr
		BCC $02 : LDA #$00
		TAX
		JSR (.Ptr,x)

		PLP
		PLB
		JML $008494		; this routine is in bank 00 and ends in RTS so this is fine (build OAM btw)


		.Ptr
		dw .FilesAppear		; 00
		dw .HandleFiles		; 01
		dw .ChooseDifficulty	; 02
		dw .ChallengeModes	; 03
		dw .PreviewFile		; 04
		dw .EraseFile		; 05
		dw .LoadFile		; 06
		..End

		.WindowIndex
		db $00,$03,$06
		.WindowOffset
		db $0F,$3F,$6F

	.FilesAppear
	; INIT:
	; do any loading / processing that has to be done before we can proceed
	; we probably load layer 3 + tilemap and initialized HDMA here
	; MAIN:
	; use HDMA to move each file independently of the others
	; this state is just here for animation purposes
		LDA !MenuState : BPL ..init
		JMP ..main
		..init
		ORA #$80
		STA !MenuState
		LDX.b #!MenuTemp-2
	-	STZ !MenuRAM+1,x
		DEX : BPL -

		LDA #$02 : STA $610A
	-	JSL IntegrityCheckSRAM
		LDX $610A
		TXY
		LDA SaveFileIndexHi,x : XBA
		LDA SaveFileIndexLo,x
		REP #$30
		TAX
		LDA $00
		CMP !SRAM_block+$2FC,x : BEQ ..goodchecksum
		..badchecksum
		LDA !MenuIntegrity_1,y
		ORA #$0001
		STA !MenuIntegrity_1,y
		..goodchecksum
		LDA #!ChecksumComplement
		SEC : SBC $00
		CMP !SRAM_block+$2FE,x : BEQ ..goodcomplement
		..badcomplement
		LDA !MenuIntegrity_1,y
		ORA #$0002
		STA !MenuIntegrity_1,y
		..goodcomplement
		LDA $02
		CMP !SRAM_block+$2FA,x : BEQ ..goodbitcount
		..badbitcount
		LDA !MenuIntegrity_1,y
		ORA #$0004
		STA !MenuIntegrity_1,y
		..goodbitcount
		SEP #$30
		DEC $610A : BPL -

		STZ $610A



		STZ $4334							;\
		STZ $4344							; | HDMA banks
		STZ $4354							;/

		LDA #$58 : STA $0C00 : STA $0C10				;\
		LDA #$58 : STA $0C05 : STA $0C15				; |
		LDA #$01 : STA $0C0A : STA $0C1A				; |
		STZ $0C0F : STZ $0C1F						; |
		LDA #$38 : STA !HDMA						; |
		REP #$20							; |
		LDA #$0D03 : STA $4330						; | set up layer 1 HDMA table
		LDA #$0C00 : STA !HDMA3source					; |
		STZ $0C01 : STZ $0C11						; |
		STZ $0C03 : STZ $0C13						; |
		STZ $0C06 : STZ $0C16						; |
		STZ $0C08 : STZ $0C18						; |
		STZ $0C0B : STZ $0C1B						; |
		STZ $0C0D : STZ $0C1D						;/

		LDA #$003C : STA $0D00 : STA $0D20				;\
		LDA #$003C : STA $0D05 : STA $0D25				; |
		LDA #$003C : STA $0D0A : STA $0D2A				; | layer 3 HDMA
		STZ $0D0E : STZ $0D2E						; |
		; --
		LDA #$0000 : STA !MenuBG3_X_1					; | > file 1 X
		LDA #$00F0 : STA !MenuBG3_Y_1					; | > file 1 Y
		LDA #$0000 : STA !MenuBG3_X_2					; | > file 2 X
		LDA #$00C0 : STA !MenuBG3_Y_2					; | > file 2 Y
		LDA #$0000 : STA !MenuBG3_X_3					; | > file 3 X
		LDA #$0090 : STA !MenuBG3_Y_3					; | > file 3 Y
		; --
		LDA #$1103 : STA $4340						; |
		LDA #$0D00 : STA !HDMA4source					;/


		LDA #$2601 : STA $4350						;\
		LDA #$0E00 : STA !HDMA5source					; |
		LDA #$0030 : STA $0E00 : STA $0E10				; |
		LDA #$0030 : STA $0E03 : STA $0E13				; |
		LDA #$0030 : STA $0E06 : STA $0E16				; |
		LDA #$0001 : STA $0E09 : STA $0E19				; | window 1 HDMA table
		STZ $0E0C : STZ $0E1C						; |
		LDA #$00FF							; |
		STA $0E01 : STA $0E11						; |
		STA $0E04 : STA $0E14						; |
		STA $0E07 : STA $0E17						; |
		STA $0E0A : STA $0E1A						;/


		LDA.w #!DecompBuffer : STA $00					;\
		LDA.w #!DecompBuffer>>8 : STA $01				; |
		LDA.w #$B01							; |
		JSL !DecompressFile						; |
		JSL !GetVRAM							; | decompress file $C00 and upload it to VRAM
		LDA #$2000 : STA !VRAMbase+!VRAMtable+$00,x			; |
		LDA.w #!DecompBuffer : STA !VRAMbase+!VRAMtable+$02,x		; |
		LDA.w #!DecompBuffer>>8 : STA !VRAMbase+!VRAMtable+$03,x	; |
		LDA #$5000 : STA !VRAMbase+!VRAMtable+$05,x			; |
		SEP #$20							;/

		STZ $41								; disable window 1 on BG1 and BG2
		LDA #$02 : STA $42						; enable window 1 on BG3
		LDA #$02 : STA $43						; enable window 1 on sprites
		LDA #$02 : STA $44						; disable "clip to black" and fixed color shenanigans


		..main

		REP #$20
		LDY #$04
	-	;LDA !MenuBG3_X_1,x : BEQ +
		;CLC : ADC #$0004
		;STA !MenuBG3_X_1,x
	+	LDA !MenuBG3_Y_1,y : BEQ +
		SEC : SBC #$0004
		STA !MenuBG3_Y_1,y
	+	DEY #2 : BPL -
		SEP #$20

		JSR HandleBG3Files

		..end
		LDA !MenuBG3_Y_1
		ORA !MenuBG3_Y_1+1
		BEQ ..next
		RTS

		..next
		LDA #$01 : STA !MenuState
		RTS


	.HandleFiles
	; MAIN:
	; read player input to select files
	; also handle L + R erase command here

		REP #$20
		STZ !MenuBG3_Y_1
		STZ !MenuBG3_Y_2
		STZ !MenuBG3_Y_3
		SEP #$20
		JSR HandleBG3Files


		LDA $17
		AND #$30
		CMP #$30 : BEQ +
		STZ !MenuEraseTimer
		BRA ..noerase
	+	INC !MenuEraseTimer
		LDA !MenuEraseTimer : BPL ..nochoice
		LDA #$05 : STA !MenuState
		..noerase

		LDA $16
		AND #$0C : BEQ ..noinput
		CMP #$0C : BEQ ..noinput
		CMP #$04 : BEQ ..d
	..u	LDA $610A
		DEC A
		BPL ..w
		LDA #$02
		BRA ..w
	..d	LDA $610A
		INC A
		CMP #$03
		BCC $02 : LDA #$00
	..w	STA $610A
		LDA #$06 : STA !SPC4
		..noinput

		LDA $16 : BPL ..nochoice
		LDX $610A
		LDA SaveFileIndexHi,x : XBA
		LDA SaveFileIndexLo,x
		REP #$10
		TAX
		LDA !SRAM_block,x
		SEP #$10
		CMP #$FF : BEQ ..makenewfile
		..previewoldfile
		LDA #$04 : STA !MenuState
		BRA ..nochoice
		..makenewfile
		LDA #$02 : STA !MenuState
		..nochoice

		REP #$20
		LDA.w #.SmallStarTilemap : STA $02
		SEP #$20
		STZ $0E
		LDA #$04 : STA $0F
		LDA !SRAM_block
		CMP #$FF : BEQ ..nostar1
		LDA #$20 : STA $00
		LDA #$14 : STA $01
		JSL !SpriteHUD
		..nostar1
		LDA !SRAM_block+!SaveFileSize
		CMP #$FF : BEQ ..nostar2
		LDA #$50 : STA $00
		LDA #$44 : STA $01
		JSL !SpriteHUD
		..nostar2
		LDA !SRAM_block+(!SaveFileSize*2)
		CMP #$FF : BEQ ..nostar3
		LDA #$80 : STA $00
		LDA #$74 : STA $01
		JSL !SpriteHUD
		..nostar3

		REP #$20
		LDA.w #.HackMarkTilemap : STA $02
		LDA #$0402 : STA $0E
		SEP #$20
		LDA !MenuIntegrity_1 : BEQ ..nohack1
		LDA #$30 : STA $00
		LDA #$14 : STA $01
		JSL !SpriteHUD
		..nohack1
		LDA !MenuIntegrity_2 : BEQ ..nohack2
		LDA #$60 : STA $00
		LDA #$44 : STA $01
		JSL !SpriteHUD
		..nohack2
		LDA !MenuIntegrity_3 : BEQ ..nohack3
		LDA #$90 : STA $00
		LDA #$74 : STA $01
		JSL !SpriteHUD
		..nohack3


		REP #$20
		STZ $00
		LDA.w #.TooltipTilemap : STA $02
		SEP #$20
		LDA #$02 : STA $0E
		LDA #$14 : STA $0F
		JSL !SpriteHUD


		LDA $13
		AND #$18 : BEQ ..blink

		LDX $610A

		LDA .OutlineDispX,x : STA $00
		LDA .OutlineDispY,x : STA $01
		REP #$20
		LDA.w #.OutlineTilemap : STA $02
		SEP #$20
		LDA #$02 : STA $0E
		LDA #$50 : STA $0F
		JSL !SpriteHUD

		..blink

		RTS

	.ChooseDifficulty
	; INIT:
	; load layer 1 tilemap
	; MAIN:
	; step 1 of making a new file, the player chooses easy / normal / insane

		LDA !MenuState : BMI ..main
		..init
		ORA #$80
		STA !MenuState
		STZ !MenuBG1_X
		STZ !MenuBG1_X+1
		REP #$10
		LDX #$01C0 : JSR LoadScreen


		..main
		REP #$20
		LDY #$04
	-	LDA !MenuBG3_Y_1,y
		CMP #$0100 : BEQ +
		CLC : ADC #$0004
		STA !MenuBG3_Y_1,y
	+	DEY #2 : BPL -
		SEP #$20
		JSR HandleBG3Files

		LDA $13
		AND #$01
		BEQ $02 : LDA #$10
		TAX
		REP #$20
		LDA !MenuBG1_X
		CMP #$0100 : BEQ +
		CLC : ADC #$0004
		STA !MenuBG1_X
	+	LDA !MenuBG1_X
		STA $0C01,x
		STA $0C06,x
		STX !HDMA3source			; always double buffer baby!
		SEP #$20

		LDA $0C02,x : BNE ..choose
		RTS

		..choose
		LDA $16
		AND #$0C : BEQ ..nochange
		CMP #$0C : BEQ ..nochange
		CMP #$04 : BEQ ..d
	..u	LDA !Difficulty
		DEC A
		BPL ..w
		LDA #$02
		BRA ..w
	..d	LDA !Difficulty
		INC A
		CMP #$03
		BCC $02 : LDA #$00
	..w	STA !Difficulty
		LDA #$06 : STA !SPC4
		..nochange
		BIT $16 : BPL ..nochoice
		LDA #$03 : STA !MenuState
		RTS
		..nochoice
		BVC ..noback
		STZ !MenuState
		RTS
		..noback

		LDA !Difficulty
		AND #$03
		INC A
		CMP !MsgTrigger : BEQ ..notextupdate
		STA !MsgTrigger
		LDA #$00
		STA $400000+!MsgIndex
		STA $400000+!MsgIndexHi
		STA $400000+!MsgX
		STA $400000+!MsgRow
		STA $400000+!MsgWordLength
		STA $400000+!MsgCharCount
		STA $400000+!MsgEnd
		..notextupdate


		; draw hand
		LDA $13
		LSR #3
		AND #$07
		SEC : SBC #$04
		BPL $03 : EOR #$FF : INC A
		CLC : ADC #$20
		STA $00
		LDA !Difficulty
		ASL #4
		CLC : ADC #$4C
		STA $01
		LDA #$02 : STA $0E
		REP #$20
		LDA.w #.HandTilemap : STA $02
		SEP #$20
		LDA #$14 : STA $0F
		JSL !SpriteHUD
		RTS

	.ChallengeModes
	; INIT:
	; reset cursor
	; MAIN:
	; step 2 of making a new file, the player checks the challenge modes they want, if any
		LDA !MenuState : BMI ..main
		..init
		ORA #$80
		STA !MenuState
		STZ !MenuChallengeSelect

		..main
		LDA $16
		AND #$0C : BEQ ..nochange
		CMP #$0C : BEQ ..nochange
		CMP #$04 : BEQ ..d
	..u	LDA !MenuChallengeSelect
		DEC A
		BPL ..w
		LDA #$03
		BRA ..w
	..d	LDA !MenuChallengeSelect
		INC A
		CMP #$04
		BCC $02 : LDA #$00
	..w	STA !MenuChallengeSelect
		LDA #$06 : STA !SPC4
		..nochange

		BIT $16 : BPL ..nochoice
		LDX !MenuChallengeSelect
		LDA .ChallengeModeOrder,x
		EOR !Difficulty
		STA !Difficulty
		..nochoice

		BIT $16 : BVC ..noback
		LDA #$82 : STA !MenuState
		LDA !Difficulty
		AND #$03
		STA !Difficulty
		..noback

		LDA $16
		AND #$10 : BEQ ..nostart
		LDA !Difficulty
		JSL NewFileSRAM
	LDX #$0F				;\
	LDA #$80				; | DEBUG: instantly unlock levels 00-0F
-	STA !LevelTable4,x			; |
	DEX : BPL -				;/
		JSL SaveFileSRAM
		LDA #$0B : STA !GameMode
		LDA #$EA : STA $6109
		STZ !HDMA
		..nostart


		LDA !MenuChallengeSelect
		CLC : ADC #$04
		CMP !MsgTrigger : BEQ ..notextupdate
		STA !MsgTrigger
		LDA #$00
		STA $400000+!MsgIndex
		STA $400000+!MsgIndexHi
		STA $400000+!MsgX
		STA $400000+!MsgRow
		STA $400000+!MsgWordLength
		STA $400000+!MsgCharCount
		STA $400000+!MsgEnd
		..notextupdate


		; draw hand
		LDA $13
		LSR #3
		AND #$07
		SEC : SBC #$04
		BPL $03 : EOR #$FF : INC A
		CLC : ADC #$70
		STA $00
		LDA !MenuChallengeSelect
		ASL #4
		CLC : ADC #$4C
		STA $01
		LDA #$02 : STA $0E
		REP #$20
		LDA.w #.HandTilemap : STA $02
		SEP #$20
		LDA #$14 : STA $0F
		JSL !SpriteHUD

		; challenge markers
		LDA !Difficulty
		AND.b #$03^$FF
		STA $08
		LDX #$05
		LDA #$9E : STA $00
		LDA #$2D-$10 : STA $01
		REP #$20
		LDA.w #.MarkTilemap : STA $02
		SEP #$20
		LDA #$02 : STA $0E
		LDA #$04 : STA $0F
	-	LDA $01
		CLC : ADC #$10
		STA $01
		LSR $08 : BCC +
		PHX
		JSL !SpriteHUD
		PLX
	+	DEX : BPL -

		; underscore
		LDA #$4C : STA $00
		LDA !Difficulty
		AND #$03
		ASL #4
		CLC : ADC #$57
		STA $01
		REP #$20
		LDA.w #.UnderscoreTilemap : STA $02
		SEP #$20
		STZ $0E
		LDA #$10 : STA $0F
		JSL !SpriteHUD

		; start
		REP #$20
		STZ $00
		LDA.w #.StartTilemap : STA $02
		SEP #$20
		LDA #$02 : STA $0E
		LDA #$08 : STA $0F
		JSL !SpriteHUD

		RTS

		.ChallengeModeOrder
		db $04,$08,$10,$20,$40,$80



	.PreviewFile
	; INIT:
	; load layer 1 tilemap
	; when loading a new file, its stats are previewed for the player to see (A/B confirm, X/Y cancel)
		LDA !MenuState : BMI ..main
		..init
		ORA #$80
		STA !MenuState
		REP #$10
		LDX #$0380 : JSR LoadScreen

		..main
		REP #$20
		LDY #$04
	-	LDA !MenuBG3_Y_1,y
		CMP #$0100 : BEQ +
		CLC : ADC #$0004
		STA !MenuBG3_Y_1,y
	+	DEY #2 : BPL -
		SEP #$20
		JSR HandleBG3Files

		LDA $13
		AND #$01
		BEQ $02 : LDA #$10
		TAX
		REP #$20
		LDA !MenuBG1_X
		CMP #$0100 : BEQ +
		CLC : ADC #$0004
		STA !MenuBG1_X
	+	LDA !MenuBG1_X
		STA $0C01,x
		STA $0C06,x
		STX !HDMA3source			; always double buffer baby!
		SEP #$20
		LDA $0C02,x : BNE ..choose
		RTS

		..choose
		BIT $16 : BPL ..nochoice
		JSL LoadFileSRAM
		STZ $6109
		LDA #$0B : STA !GameMode
		STZ !HDMA
		RTS

		..nochoice
		BVC ..noback
		STZ !MenuState


		..noback
		RTS



	.EraseFile
	; MAIN:
	; ask if player is sure they want to erase the file
	; if yes, erase it and go back to state 1
		JSL EraseFileSRAM
		STZ !MenuState
		RTS


	.LoadFile
	; INIT:
	; call load SRAM routine, then set game mode to 0B
		JSL LoadFileSRAM
		STZ $6109				; go directly to realm select
		LDA #$0B : STA !GameMode
		RTS



		.MarioTilemap
		db $38,$B0,$00,$30
		db $38,$C0,$02,$30

		.HandTilemap
		db $00,$00,$80,$3F
		db $10,$00,$82,$3F
		db $18,$00,$83,$3F
		db $00,$08,$90,$3F
		db $10,$08,$92,$3F

		.MarkTilemap
		db $00,$00,$A4,$3F

		.UnderscoreTilemap
		db $00,$00,$B0,$3F
		db $08,$00,$B1,$3F
		db $10,$00,$B1,$3F
		db $18,$00,$B0,$7F

		.OutlineTilemap
		; top line
		db $00,$00,$C0,$1F
		db $08,$00,$C1,$1F
		db $18,$00,$C1,$1F
		db $28,$00,$C1,$1F
		db $38,$00,$C1,$1F
		db $48,$00,$C1,$1F
		db $58,$00,$C1,$1F
		db $68,$00,$C1,$1F
		db $72,$00,$C0,$5F
		; left line
		db $00,$08,$D0,$1F
		; right line
		db $72,$08,$D0,$5F
		; bottom line
		db $00,$12,$C0,$9F
		db $08,$12,$C1,$9F
		db $18,$12,$C1,$9F
		db $28,$12,$C1,$9F
		db $38,$12,$C1,$9F
		db $48,$12,$C1,$9F
		db $58,$12,$C1,$9F
		db $68,$12,$C1,$9F
		db $72,$12,$C0,$DF

		.OutlineDispX
		db $0F,$3F,$6F
		.OutlineDispY
		db $06,$36,$66

		.TooltipTilemap
		db $08,$B0,$00,$3D		; A button
		db $08,$C0,$40,$3D
		db $18,$C0,$42,$3D
		db $28,$C0,$60,$3D
		db $38,$C0,$62,$3D

		.StartTilemap
		db $60,$B8,$04,$3D
		db $68,$B8,$05,$3D

		.SmallStarTilemap
		db $00,$00,$86,$3F

		.HackMarkTilemap
		db $00,$00,$A4,$3F



	LoadScreen:
		LDY #$0000
	-	LDA $41C800,x : XBA
		LDA $40C800,x
		INX
		STX $00
		REP #$20
		ASL A
		PHX
		PHY
		PHP
		JSL $06F540			; how the fuck did i find this?
		PLP
		PLX				; get "Y" in X
		STA $0A
		LDY #$0000
		LDA [$0A],y : STA $0400,x
		INY #2
		LDA [$0A],y : STA $0440,x
		INY #2
		LDA [$0A],y : STA $0402,x
		INY #2
		LDA [$0A],y : STA $0442,x
		TXY
		PLX

		TYA
		CLC : ADC #$0004
		AND #$003F : BNE .Same
	.New	TYA
		CLC : ADC #$0040
		TAY
	.Same	INY #4
		CPY #$0800 : BEQ .Done
		SEP #$20
		LDX $00
		BRA -

	.Done	JSL !GetVRAM
		REP #$20
		LDA #$0400 : STA !VRAMbase+!VRAMtable+$02,x
		LDA #$0000 : STA !VRAMbase+!VRAMtable+$04,x
		LDA #$3400 : STA !VRAMbase+!VRAMtable+$05,x
		LDA #$0800 : STA !VRAMbase+!VRAMtable+$00,x
		SEP #$30
		RTS


	HandleBG3Files:
		LDA $13
		AND #$01
		BEQ $02 : LDA #$20
		TAX
		REP #$20

		; scanline counts
		LDA #$0027
		SEC : SBC !MenuBG3_Y_1
		STA $0D00,x			; chunk 1
		LDA #$0010
		CLC : ADC !MenuBG3_Y_1
		SEC : SBC !MenuBG3_Y_2
		STA $0D05,x			; space 1
		LDA #$0020 : STA $0D0A,x	; chunk 2
		LDA #$0010
		CLC : ADC !MenuBG3_Y_2
		SEC : SBC !MenuBG3_Y_3
		STA $0D0F,x			; space 2
		LDA #$0001 : STA $0D14,x	; chunk 3
		STZ $0D19,x

		; scroll values
		LDA !MenuBG3_X_1 : STA $0D01,x
		LDA !MenuBG3_Y_1 : STA $0D03,x
		LDA #$0100 : STA $0D06,x
		LDA !MenuBG3_X_2 : STA $0D0B,x
		LDA !MenuBG3_Y_2 : STA $0D0D,x
		LDA #$0100 : STA $0D10,x
		LDA !MenuBG3_X_3 : STA $0D15,x
		LDA !MenuBG3_Y_3 : STA $0D17,x

		; (screen-relative)
		; Y of...
		; chunk 1	0 - Y1
		; space 1	28 - Y1
		; chunk 2	38 - Y2
		; space 2	58 - Y2
		; chunk 3	68 - Y3
		; use this to determine which chunk has to be chopped due to clipping the top of the screen
		LDY #$00
		LDA !MenuBG3_Y_1
		CMP #$0027 : BCC .Go
		LDY #$05
		LDA !MenuBG3_Y_2
		CMP #$0037 : BCC .Space1
		LDY #$0A
		CMP #$0057 : BCC .Chunk2
		LDY #$0F
		LDA !MenuBG3_Y_3
		CMP #$0067 : BCC .Space2
		LDY #$14
		BRA .Go

		.Space1
		LDA #$0027
		SEC : SBC !MenuBG3_Y_1
		SEP #$20
		CLC : ADC $0D05,x
		STA $0D05,x
		BRA .Go

		.Chunk2
		LDA #$0037
		SEC : SBC !MenuBG3_Y_2
		SEP #$20
		CLC : ADC $0D0A,x
		STA $0D0A,x
		BRA .Go

		.Space2
		LDA #$0057
		SEC : SBC !MenuBG3_Y_2
		SEP #$20
		CLC : ADC $0D0F,x
		STA $0D0F,x

		.Go
		SEP #$20
		STY $00
		TXA
		CLC : ADC $00
		STA !HDMA4source
		RTS


;===========;
;SRAM ENGINE;
;===========;
	pushpc
	org $00939A
		JSL CheckInitSRAM	;\
		JSL Mode7Presents	; | gamemode 00 routine that displays nintendo presents
		BRA +			;/
	warnpc $0093CA
	org $0093CA
		+
	org $0093E0
		BRA $01 : NOP		; org: JSR $922F (patch out presents screen palette update)
	org $009BC0
		BRA $02 : NOP #2	; don't call save routine
	org $0498F6
		RTS : NOP #3		; don't call save routine
	org $009BC9
		RTL			; kill vanilla save game routine (org: PHB)
	pullpc


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
		LDA !SaveINIT+0
		CMP #$4E49 : BNE .Invalid
		LDA !SaveINIT+2
		CMP #$5449 : BEQ .Valid

		.Invalid
		LDA #$0000					;\
		STA $6000					; |
		STA $410000					; |
		LDA #$FFFF					; |
		LDX #$0000					; |
		LDY #$0001					; |
		MVN $40,$40					; |
		LDA #$FFFF					; |
		LDX #$0000					; | have SA-1 clear all BWRAM and initialize SRAM
		LDY #$0001					; |
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
		LDA #$0000					;\
		STA !SRAM_buffer				; |
		LDA.w #!SaveFileSize-1				; |
		LDX.w #!SRAM_buffer				; |
		LDY.w #!SRAM_buffer				; | have SA-1 clear SRAM buffer
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
		LDA SaveFileIndexHi,x : XBA				; | get index to file
		LDA SaveFileIndexLo,x					;/
		REP #$30						; all regs 16-bit
		TAX							; X = file index
		SEP #$20						; A 8-bit

		; load a bunch of variables from file
		%loadbyte(!Difficulty)
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

		; loop to add story flags to file
		LDY #$0000
	.StoryFlagsLoop
		%loadtableW(!StoryFlags)
		INX
		INY
		CPY #$008E : BCC .StoryFlagsLoop

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
		PLP							; pull P
		PLB							; bank wrapper end
		RTL							; return


; save function
	SaveFileSRAM:
		PHB : PHK : PLB						; bank wrapper start
		PHP							; push P
		SEP #$30						; all regs 8-bit
		LDX $610A						;\
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
		%addchecksum(!Difficulty)
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

		; loop to add story flags to file
		LDY #$0000
	.StoryFlagsLoop
		%addtableW(!StoryFlags)
		INX
		INY
		CPY #$008E : BCC .StoryFlagsLoop

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



;
; THIS IS LEGACY CODE KEPT FOR REFERENCE 
;
;	CUSTOM_MENU:
;		LDA !GameMode
;		CMP #$0E : BNE .Menu
;		JMP .Overworld
;
;		.Menu
;		LDA $610A				; Load save file number
;		XBA
;		LDA #$00
;		REP #$10				; Index 16 bit
;		TAX					; X = start of SRAM index
;		LDA !FreeSRAM,x
;		CMP #$01
;		BEQ .UpdateStripe
;		JMP .CleanFile				; Don't update stripe if selecting a clean file
;
;.UpdateStripe	PHB					;\
;		PHK					; | Bank wrapper
;		PLB					;/
;
;		LDX #!CustomSize			;\
;.LoopC		LDA CustomStripe,x			; | Upload custom stripe image table to RAM
;		STA !FreeBNK*$10000+!FreeRAM,x		; |
;		DEX					; |
;		BPL .LoopC				;/
;
;		LDA $610A				;\
;		BEQ .Data1				; |
;		DEC A					; |
;		BEQ .Data2				; |
;.Data3		LDA #$4E				; | Update file number graphic
;		STA !FreeBNK*$10000+!FreeRAM+$26	; |
;		LDA #$30				; |
;		STA !FreeBNK*$10000+!FreeRAM+$27	; |
;		BRA .Data1				; |
;.Data2		LDA #$6E				; |
;		STA !FreeBNK*$10000+!FreeRAM+$26	;/
;
;.Data1		LDA $610A				;\
;		XBA					; |
;		LDA #$00				; |
;		REP #$10				; |
;		TAX					; |
;		LDA !FreeSRAM+$01,x			; |
;		SEP #$10				; |
;		AND #$03				; | Update difficulty graphic
;		BEQ .EASY				; |
;		DEC A					; |
;		BEQ .NORMAL				; |
;.INSANE		LDX #$0F				; |
;.LoopI		LDA Custom_INSANE,x			; |
;		STA !FreeBNK*$10000+!FreeRAM+$28,x	; |
;		DEX					; |
;		BPL .LoopI				; |
;		BRA .EASY				; |
;.NORMAL		LDX #$0F				; |
;.LoopN		LDA Custom_NORMAL,x			; |
;		STA !FreeBNK*$10000+!FreeRAM+$28,x	; |
;		DEX					; |
;		BPL .LoopN				;/
;
;.EASY		LDA $610A
;		SEP #$10
;		TAX
;		LDA $009CCB,x
;		XBA
;		LDA $009CCE,x
;		REP #$10
;		TAX					; X = SMW SRAM index
;		LDA $41C08C,x				; Load number of exits found
;		SEP #$10
;
;		LDX #$00				;\
;.HexToDec8a	CMP #$0A				; |
;		BCC .WriteExits				; | Convert to Dec (8 bit)
;		SBC #$0A				; |
;		INX					; |
;		BRA .HexToDec8a				;/
;
;.WriteExits	PHA					; Preserve 1s digit
;		TXA					;\
;		AND #$0F				; |
;		BEQ .Digit1				; | Update number of exits found, shown on screen
;		STA !FreeBNK*$10000+!FreeRAM+$44	; |
;.Digit1		PLA					; |
;		STA !FreeBNK*$10000+!FreeRAM+$46	;/
;
;		LDA $610A				;\ Get save file number in hi byte
;		XBA					;/
;		LDA #$05				; Get Yoshi Coin address in lo byte
;		REP #$10
;		TAX
;		LDA !FreeSRAM+$01,x			;\
;		XBA					; | Load number of Yoshi Coins collected
;		LDA !FreeSRAM+$00,x			; |
;		REP #$20				;/
;
;		LDX #$0000				;\
;.HexToDec16	CMP #$000A				; |
;		BCC .WriteYC1				; | Convert to Dec (16 bit)
;		SBC #$000A				; |
;		INX					; |
;		BRA .HexToDec16				;/
;
;.WriteYC1	SEP #$30				; A and index 8 bit
;		STA !FreeBNK*$10000+!FreeRAM+$56	; Write 1s digit of Yoshi Coin
;
;		TXA					;\
;		LDX #$00				; |
;.HexToDec8b	CMP #$0A				; |
;		BCC .WriteYC2				; | Convert to Dec (8 bit)
;		SBC #$0A				; |
;		INX					; |
;		BRA .HexToDec8b				;/
;
;.WriteYC2	PHX					;\
;		TAX					; | Swap A and X, so that A = 100s, X = 10s
;		PLA					;/
;		BEQ .WriteYC3
;		STA !FreeBNK*$10000+!FreeRAM+$52	; Write 100s digit of Yoshi Coin
;.WriteYC3	TXA
;		BEQ .CoinHoard
;		STA !FreeBNK*$10000+!FreeRAM+$54	; Write 10s digit of Yoshi Coin
;
;.CoinHoard	LDA.l $00610A : XBA
;		LDA #!FreeBNK				;\ Switch to bank 0x40
;		PHA : PLB				;/
;		LDA #$00
;		REP #$30
;		TAX
;		PHY
;		PHP
;
;		PEI ($00)				;\ Back these up since I don't know if they're important
;		PEI ($02)				;/
;
;		LDA.l !FreeSRAM+$93,x			;\
;		STA $00					; |
;		LDA.l !FreeSRAM+$95,x			; | Store hoard as a 32-bit number in $00-$03
;		AND #$00FF				; |
;		STA $02					;/
;		SEP #$10				; > Index 8 bit
;
;		LDY #$00				; > Base number in 100000 slot
;	-	CMP #$0001 : BNE +			;\
;		LDA $00					; |
;		CMP #$86A0				; |
;	+	BCC .100000done				; |
;		SBC #$86A0				; | 32-bit math to count 100000s
;		STA $00					; |
;		LDA $02					; |
;		SBC #$0001				; |
;		STA $02					;/
;		INY					;\ Add 100000 and loop
;		BRA -					;/
;
;		.100000done
;		STY.w !FreeRAM+$5C			; > Store 100000 digit
;		LDA $00					;\
;		LDY #$00				; | Count 10000s
;	-	CMP #$2710 : BCC .10000done		; |
;		SBC #$2710				;/
;		INY					;\ Add 10000 and loop
;		BRA -					;/
;
;		.10000done
;		STY.w !FreeRAM+$5E			; > Store 10000 digit
;		JSL Thousands				; > Calculate 1000s and 100s
;		SEP #$20				; > A 8 bit
;		STY.w !FreeRAM+$60			; > Store 1000 digit
;		STX.w !FreeRAM+$62			; > Store 100 digit
;		JSL HexToDec				; > Calculate last two digits
;		STX.w !FreeRAM+$64			; > Store 10 digit
;		STA.w !FreeRAM+$66			; > Store 1 digit
;		REP #$20				;\
;		PLA : STA $02				; | Restore these probably useless numbers
;		PLA : STA $00				;/
;		PLP					; > Restore processor
;		PLY					; > Restore Y
;		SEP #$20				; > A 8 bit
;
;
;.Return		PLB					; Restore bank
;		SEP #$10				; Index 8 bit
;.Overworld	STY $12					; Load difficulty select stripe
;		LDX #$00				; Overwritten code
;		RTL
;
;.CleanFile	LDX #!DifficultySize			;\
;.Loop		LDA Difficulty,x			; |
;		STA !FreeBNK*$10000+!FreeRAM,x		; | Upload stripe image table to RAM
;		DEX					; |
;		BPL .Loop				;/
;
;		SEP #$10				; Index 8 bit
;		STY $12					; Load difficulty select stripe
;		LDX #$00				; Overwritten code
;		RTL


;==================;
;YOSHI COIN ROUTINE;
;==================;
	YOSHI_COIN:
		PHX
		PHA				; Preserve A
		LDA !YoshiCoinCount		; Load lo byte of number of Yoshi Coins collected
		INC A				; Increment
		STA !YoshiCoinCount		; Store back
		BNE .Return			;\
		LDA !YoshiCoinCount+1		; | Handle overflow
		INC A				; |
		STA !YoshiCoinCount+1		;/

.Return		LDA !CurrentMario
		DEC A
		TAX
		LDA !P1CoinIncrease,x		;\
		CLC : ADC #$C7			; | Only add 199 since the Yoshi coin already gave 1 naturally
		STA !P1CoinIncrease,x		;/
		PLA				; Restore A
		PLX
		INC $7420 : CLC			; Overwritten code
		RTL
;=============;
;DISABLE SCORE;
;=============;
	DisableScore:
		LDA $76E1,x
		CMP #$0D : BCC +
		JML $02ADC2
	+	JML $02ADC5


	BetterCoins:
		PHX
		LDX !CoinOwner			;\
		BNE .NotMario			; | If !CoinOwner = 0x00, then it belongs to Mario
		LDA !CurrentMario		; |
		TAX				;/

		.NotMario
		DEX
		INC !P1CoinIncrease,x
		STZ !CoinOwner
		PLX
		RTL



print "Patch ends at $", pc, "."