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

	incsrc "Defines.asm"				; Include standard defines


	!NumColumnHeight	= $4A			; base Y position of numbers column on the right (does not affect %)




if !LockROM = 0
print "ROM NAME: SUPER MARIOWORLD     "
print "ROM has not been locked"
	org $00FFC0
	ROMNAME:
	db "SUPER MARIOWORLD     "
	warnpc $00FFD5
else
print "ROM NAME: Extra Mario World    "
print "ROM has been locked"
	org $00FFC0
	ROMNAME:
	db "Extra Mario World    "
	warnpc $00FFD5
endif


	incsrc "MSG/TextCommands.asm"
	cleartable
	table "MSG/MessageTable.txt"




;==========;
;STATUS BAR;
;==========;

	org $0084E2
	;	dl !FreeBNK*$10000+!FreeRAM		; Location of 1/2 player select stripe

	org $008C81					; Status bar tilemap
	;CUSTOM_BAR:
	;	dw $2814,$2414,$2414,$2414,$2414,$2414	; > P1 coins
	;	dw $2014,$2014,$2014,$2014,$2014	; > P1 hearts
	;	dw $2814,$2814,$2814,$2814,$2814	;\ Yoshi coins
	;	dw $2814,$2814,$2814,$2814,$2814	;/
	;	dw $2014,$2014,$2014,$2014,$2014	; > P2 hearts
	;	dw $2814,$2814,$2414,$2414,$2414,$2414	; > P2 coins

; org $008CC1
	;	dw $2814,$2814,$2814,$2814		; default status bar to empty space
	;	dw $2814,$2814,$2814,$2814
	;	dw $2814,$2814,$2814,$2814
	;	dw $2814,$2814,$2814,$2814
	;	dw $2814,$2814,$2814,$2814
	;	dw $2814,$2814,$2814,$2814
	;	dw $2814,$2814,$2814,$2814
	;	dw $2814,$2814,$2814


; $0FFE7E

	org $0096CB
		LDA #$C7				; which level number is used for title screen


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


	org $00A5D5
		JSR STATUS_BAR_Coins

	org $008E1A					; Code that handles the status bar
	STATUS_BAR:
		PHB : PHK : PLB
		JSR .Main
		PLB
		RTL

	.Main
		LDA !Difficulty				;\ see if timer is enabled
		AND.b #!TimeMode : BEQ .NoTimer		;/

		LDA !TimerSeconds+1 : BMI .NoTimer	; don't process if negative

		LDA !Mosaic				;\ not during level fades
		AND #$F0 : BNE .NoTimer			;/
		LDA !MsgTrigger				;\
		ORA !MsgTrigger+1			; | skip this stuff when a text box is open
		BNE .NoTimer				;/

		INC !TimeElapsedFrames			; 1 more frame has passed
		DEC !TimerFrames : BNE .DrawTimer	;\ timer (frames per second)
		LDA.b #60 : STA !TimerFrames		;/
		STZ !TimeElapsedFrames			;\
		LDA !TimeElapsedSeconds			; |
		INC A					; |
		CMP #60					; |
		BCC $02 : LDA #$00			; | on a new second tick, clear frames elapsed and tick up seconds/minutes
		STA !TimeElapsedSeconds			; |
		BNE .UpCountDone			; |
		INC !TimeElapsedMinutes			; |
		.UpCountDone				;/

		REP #$20				;\
		LDA !TimerSeconds			; |
		CMP.w #100 : BNE +			; |
		LDX #$80 : STX !SPC1			; > speed up music tempo
		LDX #$1D : STX !SPC4			; > running out of time SFX
	+	LDA !TimerSeconds : BEQ .DrawTimer	; |
		DEC !TimerSeconds			; | timer (seconds)
		SEP #$20				; |
		BNE .TimerUpdate			;/
		LDA #$01				;\
		LDY !P2Status-$80			; |
		BNE $03 : STA !P2Status-$80		; | kill players when timer hits 0
		LDY !P2Status				; |
		BNE $03 : STA !P2Status			;/

		.TimerUpdate
		JSL UPDATE_TIMER

		.DrawTimer
		JSL DRAW_TIMER
		.NoTimer




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
		BCS $03 : STA !P1Coins			; | cap coins at 9999
		CMP !P2Coins				; |
		BCS $03 : STA !P2Coins			;/

		LDA !P1Coins				;\
		JSR Thousands				; |
		STY !StatusBar+$01			; |
		STX !StatusBar+$02			; | Run coin counter for player 1
		JSR HexToDec				; |
		STX !StatusBar+$03			; |
		STA !StatusBar+$04			;/

		LDA !MultiPlayer : BEQ .SinglePlayer	;\
		LDA !StatusX				; | see which type of P2 counter should be used (if any)
		REP #$20				; |
		BEQ ..megalevel				;/
		..normallevel				;\
		LDA !P2Coins				; |
		JSR Thousands				; |
		STY !StatusBar+$1B			; |
		STX !StatusBar+$1C			; |
		JSR HexToDec				; | P2 coin counter on normal levels
		STX !StatusBar+$1D			; |
		STA !StatusBar+$1E			; |
		SEP #$20				; |
		LDA #$14 : STA !StatusBar+$1F		; > empty space
		LDA #$0A : STA !StatusBar+$1A		; > P2 coin symbol
		BRA .MultiPlayer			;/
		..megalevel				;\
		LDA !P2Coins				; |
		JSR Thousands				; |
		STY !StatusBar+$1C			; |
		STX !StatusBar+$1D			; |
		JSR HexToDec				; | P2 coin counter on mega levels
		STX !StatusBar+$1E			; |
		STA !StatusBar+$1F			; |
		SEP #$20				; |
		LDA #$14 : STA !StatusBar+$1A		; |
		LDA #$0A : STA !StatusBar+$1B		; > P2 coin symbol
		BRA .MultiPlayer			;/

		.SinglePlayer				;\
		REP #$20				; |
		LDA #$1414				; | empty space on single player
		STA !StatusBar+$1A			; |
		STA !StatusBar+$1C			; |
		STA !StatusBar+$1E			;/

		.MultiPlayer				;\
		REP #$20				; |
		LDA #$1414				; |
		STA !StatusBar+$05			; |
		STA !StatusBar+$07			; |
		STA !StatusBar+$09			; |
		STA !StatusBar+$0B			; |
		STA !StatusBar+$0D			; | empty space
		STA !StatusBar+$0F			; |
		STA !StatusBar+$11			; |
		STA !StatusBar+$13			; |
		STA !StatusBar+$15			; |
		STA !StatusBar+$17			; |
		STA !StatusBar+$18			; |
		SEP #$20				;/
		LDA #$0A : STA !StatusBar+$00		; P1 coin symbols

.YoshiCoins	LDA !Translevel : BEQ .Player1HP	; no yoshi coins on index 0
		LDA !MegaLevelID : BEQ +		; check for mega level
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


.Player1HP	LDA !P2Status-$80 : BNE .Player2HP	; don't write player 1 HP if player 1 is dead

		LDA !Difficulty				;\
		AND.b #!CriticalMode : BEQ ..notcrit	; |
		LDA #$0F : STA !StatusBar+$07		; | skull icon on critical mode
		BRA .Player2HP				; |
		..notcrit				;/
		LDX !P2HP-$80				;\
		CPX !P2MaxHP-$80			; |
		BCC $03 : LDX !P2MaxHP-$80		; |
		BEQ .Player2HP				; | write player 1 HP
		DEX					; |
		PHX					; > push
		LDA #$0D				; |
	-	STA !StatusBar+$06,x			; |
		DEX : BPL -				;/
		PLX					; > pull
		LDA !P2TempHP-$80 : BEQ .Player2HP	;\ player 1 temp HP icon
		LDA #$0E : STA !StatusBar+$06,x		;/


.Player2HP	LDA !P2Status : BNE .Return		; don't write player 2 HP if player 2 is dead
		LDA !MultiPlayer : BEQ .Return		; don't write player 2 HP on singleplayer
		LDA !Difficulty				;\
		AND.b #!CriticalMode : BEQ ..notcrit	; |
		LDA #$0F : STA !StatusBar+$18		; | skull icon on critical mode
		BRA .Return				; |
		..notcrit				;/

		LDY #$18				; > index on normal levels = 0x16
		LDA !StatusX				;\ index on mega levels = 0x17
		BNE $02 : LDY #$19			;/

		LDX !P2HP				;\
		CPX !P2MaxHP				; |
		BCC $03 : LDX !P2MaxHP			; |
		BEQ .Return				; | write player 2 HP
		DEX					; |
		LDA #$0D				; |
	-	STA !StatusBar,y			; |
		DEY					; |
		DEX : BPL -				;/	
		LDA !P2TempHP : BEQ .Return		;\
		INY					; | player 2 temp HP icon
		LDA #$0E : STA !StatusBar,y		;/

.Return		RTS					; > Return


.YoshiCoinGFX:	db $0C,$0B				; Not collected, collected

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
		RTS

	HexToDec:
		LDX #$00
	.10	CMP #$0A : BCC .1
		INX
		SBC #$0A
		BRA .10
	.1	RTS

	CoinSound:
		LDX !CoinSound : BNE .ManyCoins
		LDX #$01 : STX !SPC4
		LDX #$04 : STX !CoinSound
		.ManyCoins
		RTS
warnpc $009078


;=================================;
;OLD MENU CODE, KEEP FOR REFERENCE;
;=================================;

	org $00B888
		RTS					;\ kill this routine
		NOP					;/ (all it does is decompress GFX32/33 and store them to RAM)

	org $00905B
	;	SBC.w STATUS_BAR_ScoreData+$02,y	; Fix this offset

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
	;	JSL YOSHI_COIN				; Source: INC $1420 : CLC

	org $00F5F8
	;	BRA $02 : NOP #2			; prevent item in item box from automatically falling

	org $00F620
	;	STZ $9D					; prevent game from pausing when Mario gets hurt

	org $01C563
	;	INC $19					; remove grow animation

	org $01C565
	;	JSL MarioMushAnim
	;	NOP

	org $01C5A3
	;	BRA $02 : NOP #2			; prevent some infinite score exploit

	org $01C5AB
	;	STZ $9D					; prevent game from pausing when Mario gets a cape

	org $01C5B6
	;	STZ $71					; remove get cape animation

	org $01C5F1
	;	STZ $9D					; prevent game from pausing when Mario gets a flower

	org $01C5F3
	;	STZ $7407				; remove get fire animation
	;	NOP



	; run from mario's PCE code
	org $028008
	ItemBox:
		LDX $6DC2				;\
		LDA.w .Status,x				; |
		LDY !MarioPowerUp			; | swap powerups
		STA !MarioPowerUp			; |
		LDA.w .Box,y : STA $6DC2		;/
		BNE .NoSFX				;\
		LDA !MarioPowerUp : BEQ .NoSFX		; | powerup SFX when going small -> big
		LDA #$0A : STA !SPC1			;/
		LDA #$14 : STA !P2FlashPal		; flash white
		.NoSFX

		LDA !P2HangFromLedge : BEQ .Return	; check if mario is hanging from ledge
		LDA !MarioPowerUp			;\
		BEQ $02 : LDA #$01			; |
		STA $00					; |
		TYA					; | see if mario's position has to be shifted
		BEQ $02 : LDA #$01			; |
		TAY					; |
		EOR $00 : BEQ .Return			;/
		LDA !MarioYPosLo			;\
		CLC : ADC .YCoord,y			; | adjust Mario Ycoord
		STA !MarioYPosLo			;/

	.Return	RTL					; return

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
		%LockROM(ROMNAME, #$45)
		%ResetTracker()

		PHP

		REP #$30
		LDX #$00FE
		LDA #$0000
	-	STA $400000+!MsgRAM,x
		DEX #2 : BPL -
		STA !OAMindex_p0
		STA !OAMindex_p1
		STA !OAMindex_p2
		STA !OAMindex_p3
		STA !HDMAptr+0
		STA !HDMAptr+1
		%ReloadOAMData()

		SEP #$20
		REP #$10

		LDX #$00FF						;\
		LDA #$FF						; | extra clear on map16remap for title screen
	-	STA !Map16Remap,x					; |
		DEX : BPL -						;/


		LDX #$8000 : STX $4300					;\
		LDX.w #.MPU_wait : STX $4302				; |
		LDA.b #.MPU_wait>>16 : STA $4304			; |
		LDX.w #.MPU_wait_end-.MPU_wait : STX $4305		; | DMA !MPU_wait routine into place
		LDX.w #!MPU_wait : STX $2181				; |
		STZ $2183						; |
		LDA #$01 : STA $420B					;/
		LDX.w #.MPU_light : STX $4302				;\
		LDX.w #.MPU_light_end-.MPU_light : STX $4305		; |
		LDX.w #!MPU_light : STX $2181				; | DMA !MPU_light routine into place
		STZ $2183						; |
		STA $420B						;/

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
		LDA #$0050 : STA $4305
		LDX #$01 : STX $420B
		LDA.l .SourcePal+$40 : STA !Color0

		LDX #$07 : STX $2105			; mode 7
		STX $3E

		LDA #$FFC0
		STA $1A
		STA $1C

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

		.PriorityData
		dw $0000,$0002,$0004,$0006		; holds the index to the current OAM index reg
		dw $0000,$0200,$0400,$0600		; holds the offset to the current OAM index


	.MPU_wait							;\
		STA !MPU_SNES						; |
		STA !MPU_phase						; |
		LDA !MPU_phase						; | RAM code that waits for SA-1 handshake
	-	CMP !MPU_SA1 : BNE -					; |
		RTS							; |
	..end								;/





; buffer = 0: work on buffer 0
; buffer = 1: work on buffer 1

	.MPU_light
		PHB							;\
		PHP							; |
		PHD							; |
		REP #$30						; |
		LDA #$0000 : TCD					;\
		LDX !LightIndex_SNES					; |
		LDA !LightBuffer-1					; |
		AND #$0100						; |
		ASL A							; |
		STA $22							; > start wrap value
		ADC #$0200						; |
		STA $20							; > end wrap value
		SEP #$20						; |

	..wait	LDA $3189 : BEQ $03 : BRL ..break			; > detect SA-1 being done with its thread
		LDA !ProcessLight					; |
		AND #$03 : BEQ ..init					; | (0 = start new, 1 = continue, 2 = wait for signal)
		CMP #$02 : BCS ..wait					; |
		REP #$20						; |
		BRA ..loop						;/

	..init	BIT !ProcessLight : BMI ..wait				; > if SA-1 is currently writing to !ShaderInput, wait
		INC !ProcessLight					;\
		REP #$10						; | this code runs once at the start of a new shading operation
		LDX #$8000 : STX $4300					; |
		LDX.w #!ShaderInput : STX $4302				; | use DMA to copy the data (fuck version 1.1.1)
		LDA.b #!ShaderInput>>16 : STA $4304			; | (i guess i'm not worried about the DMA + HDMA crash...?)
		LDX #$0200 : STX $4305					; |
		STZ $2183						; |
		LDX.w #!LightData_SNES					; |
		LDA !LightBuffer					; |
		AND #$01						; |
		BEQ $03 : LDX.w #!LightData_SNES+$200			; |
		STX $2181						; |
		LDA #$01 : STA $420B					; |
		REP #$30						; > all regs 16-bit
		LDA !LightIndexStart : STA !LightIndexStart_SNES	; |
		LDA !LightIndexEnd : STA !LightIndexEnd_SNES		; |
		LDA !LightBuffer-1					; |
		AND #$0100						; > add 512 to access second buffer
		ASL A							; |
		TSB !LightIndexStart_SNES				; |
		TSB !LightIndexEnd_SNES					; | copy operation parameters to SNES RAM
		LDA !LightR : STA !LightR_SNES				; | (this way SA-1 can freely queue new shading ops with different parameters)
		LDA !LightG : STA !LightG_SNES				; |
		LDA !LightB : STA !LightB_SNES				; |
		LDX #$000E						; |
	-	LDA !LightList,x : STA !LightList_SNES,x		; |
		DEX #2 : BPL -						; |
		LDX !LightIndexStart_SNES				;/

		..loop							;\
		LDA $3189						; > check for SA-1 being done with its thread
		AND #$00FF : BNE ..break				; | this is the main loop controller
		CPX !LightIndexEnd_SNES : BNE ..shade			;/

		..done							;\
		LDA !LightBuffer					; |
		EOR #$0001						; | flip buffer
		ORA #$0080						; > mark as finished
		STA !LightBuffer					;/
		INC !ProcessLight					; mark as finished
		PLD							;\
		PLP							; | pull stuff
		PLB							;/
		JMP $1E85						; > go wait for SA-1

		..break							;\
		SEP #$20						; |
		STZ $3189						; |
		STX !LightIndex_SNES					; > save current index in WRAM
		PLD							; | if SA-1 finishes its thread, this routine must end
		PLP							; |
		PLB							; |
		RTS							;/

		..shade
		TXA							;\
		ASL #3							; |
		XBA							; |
		AND #$000F						; |
		TAY							; | check exclude list
		LDA !LightList_SNES,y					; |
		AND #$00FF : BEQ ..include				; |
		BRL ..next						; |
		..include						;/

		LDA.l !LightData_SNES,x : STA $0E			;\
		AND #$001F						; |
		STA $00							; |
		LDA $0E							; |
		LSR #5							; |
		STA $0E							; | unpack color
		AND #$001F						; |
		STA $02							; |
		LDA $0E							; |
		LSR #5							; |
		AND #$001F						; |
		STA $04							;/
		SEP #$20						;\
		LDA $00 : STA $4202					; |
		LDA !LightR_SNES : STA $4203				; |
		NOP #3							; |
		REP #$20						; |
		LDA $4216 : STA $10					; |
		LDA !LightR_SNES+1 : STA $4203				; | calculate red
		LDA $10							; |
		CMP #$0F80						; |
		XBA							; |
		AND #$00FF						; |
		ADC $4216						; |
		CMP #$001F						; |
		BCC $03 : LDA #$001F					; |
		STA $00							;/
		SEP #$20						;\
		LDA $02 : STA $4202					; |
		LDA !LightG_SNES : STA $4203				; |
		NOP #3							; |
		REP #$20						; |
		LDA $4216 : STA $10					; |
		LDA !LightG_SNES+1 : STA $4203				; | calculate green
		LDA $10							; |
		CMP #$0F80						; |
		XBA							; |
		AND #$00FF						; |
		ADC $4216						; |
		CMP #$001F						; |
		BCC $03 : LDA #$001F					; |
		STA $02							;/
		SEP #$20						;\
		LDA $04 : STA $4202					; |
		LDA !LightB_SNES : STA $4203				; |
		NOP #3							; |
		REP #$20						; |
		LDA $4216 : STA $10					; |
		LDA !LightB_SNES+1 : STA $4203				; | calculate blue
		LDA $10							; |
		CMP #$0F80						; |
		XBA							; |
		AND #$00FF						; |
		ADC $4216						; |
		CMP #$001F						; |
		BCC $03 : LDA #$001F					;/
		ASL #5							;\
		ORA $02							; |
		ASL #5							; | assemble color
		ORA $00							; |
		STA.l !LightData_SNES,x					;/
		CPX #$0002 : BCC ..next					;\
		CPX #$0010 : BCC ..BG3					; |
		CPX #$0202 : BCC ..next					; | BG3 palette mirrors
		CPX #$0210 : BCS ..next					; |
		STA $FEA0-2,x						; > does this work???
		BRA ..next						; | it does! it just wraps to the next bank, which is fine with this mirroring (that's probably why STA addr,x and STA long,x both use the same amount of cycles)
	..BG3	STA $A0-2,x						;/
	..next	INX #2							;\
		CPX $20							; | loop
		BCC $02 : LDX $22					; |
		BRL ..loop						;/
	..end

print "Shader RAM code is $", hex(..end-.MPU_light), " bytes long"
warnpc .MPU_light+$200

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
		LDA $7DF5
		ASL A
		STA $211B
		LDA #$00
		ROL A
		STA $211B
		LDA $7DF5
		ASL A
		STA $211E
		LDA #$00
		ROL A
		STA $211E
		LDA #$40 : STA $211F
		STZ $211F
		LDA #$40 : STA $2120
		STZ $2120
		LDA $7DF5 : BEQ .NextGameMode
		LDA.l Mode7Presents_SourcePal+$40 : STA !Color0
		LDA.l Mode7Presents_SourcePal+$41 : STA !Color0+1
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



;================;
;UPDATE TIMER GFX;
;================;
	UPDATE_TIMER:
		REP #$20				; A 16-bit
		STZ $00					; 100s
		STZ $02					; 10s
		STZ $04					; 1s

		.GetDigits				;\
		LDA !TimerSeconds			; |
	..100s	CMP.w #100 : BCC ..10s			; |
		SBC.w #100				; |
		INC $00					; |
		BRA ..100s				; | get digits
	..10s	CMP.w #10 : BCC ..1s			; |
		SBC.w #10				; |
		INC $02					; |
		BRA ..10s				; |
	..1s	STA $04					;/

		LDY.b #!File_Sprite_BG_1		;\ file: sprite BG 1
		JSL !GetFileAddress			;/
		JSL !GetVRAM				; get VRAM table index
		PHB					; push bank
		LDY.b #!VRAMbank			;\ VRAM table bank
		PHY : PLB				;/
		LDA #$0020				;\
		STA !VRAMtable+$00,x			; | upload size
		STA !VRAMtable+$07,x			; |
		STA !VRAMtable+$0E,x			;/
		LDA !FileAddress+2			;\
		STA !VRAMtable+$04,x			; | source bank
		STA !VRAMtable+$0B,x			; |
		STA !VRAMtable+$12,x			;/
		LDA $00					;\
		BNE $03 : LDA #$000A			; |
		ASL #5					; | 100s source address
		ADC.w #$60*$20				; |
		ADC !FileAddress			; |
		STA !VRAMtable+$02,x			;/
		LDA $02					;\
		BNE +					; |
		LDY $00 : BNE +				; |
		LDA #$000A				; | 10s source address
	+	ASL #5					; |
		ADC.w #$60*$20				; |
		ADC !FileAddress			; |
		STA !VRAMtable+$09,x			;/
		LDA $04					;\
		ASL #5					; |
		ADC.w #$60*$20				; | 1s source address
		ADC !FileAddress			; |
		STA !VRAMtable+$10,x			;/

		LDA #$6420 : STA !VRAMtable+$05,x	;\
		LDA #$6430 : STA !VRAMtable+$0C,x	; | dest VRAM
		LDA #$6520 : STA !VRAMtable+$13,x	;/

		PLB					; restore bank
		RTL					; return

	DRAW_TIMER:
		SEP #$20
		LDA !MegaLevelID : BNE .MegaLevel

	;	.NormalLevel
	;	REP #$20				; A 16-bit
	;	LDA #$CE6C : STA !OAM_p3+$00C		;\ timer tile 0
	;	LDA #$3453 : STA !OAM_p3+$00E		;/
	;	LDA #$CE74 : STA !OAM_p3+$008		;\ timer tile 1
	;	LDA #$3442 : STA !OAM_p3+$00A		;/
	;	LDA #$CE7C : STA !OAM_p3+$004		;\ timer tile 2
	;	LDA #$3443 : STA !OAM_p3+$006		;/
	;	LDA #$CE84 : STA !OAM_p3+$000		;\ timer tile 3
	;	LDA #$3452 : STA !OAM_p3+$002		;/
	;	LDA #$0010 : STA !OAMindex_p3		; OAM index
	;	LDA #$0000				;\
	;	STA !OAMhi_p3+$000			; | tile size (8x8)
	;	STA !OAMhi_p3+$002			;/
	;	SEP #$20				; A 8-bit
	;	RTL

		.MegaLevel
		REP #$20				; A 16-bit
		LDA #$CE70 : STA !OAM_p3+$00C		;\ timer tile 0
		LDA #$3453 : STA !OAM_p3+$00E		;/
		LDA #$CE78 : STA !OAM_p3+$008		;\ timer tile 1
		LDA #$3442 : STA !OAM_p3+$00A		;/
		LDA #$CE80 : STA !OAM_p3+$004		;\ timer tile 2
		LDA #$3443 : STA !OAM_p3+$006		;/
		LDA #$CE88 : STA !OAM_p3+$000		;\ timer tile 3
		LDA #$3452 : STA !OAM_p3+$002		;/
		LDA #$0010 : STA !OAMindex_p3		; OAM index
		LDA #$0000				;\
		STA !OAMhi_p3+$000			; | tile size (8x8)
		STA !OAMhi_p3+$002			;/
		SEP #$20				; A 8-bit
		RTL


;
; RAM usage for menu:
; $400-$5FF:	scrolling gradient table
; $600-$BFF:	----
; $C00-$C1F:	2 tables for layer 1 HDMA (mode 3)
; $D00-$D1F:	2 tables for layer 3 HDMA (mode 3)
; $D80-$D9F:	2 tables for window HDMA (mode 1)
;
;

;=========;
;MAIN MENU;
;=========;
MAIN_MENU:
	pushpc
	org $00941B
		JSR $9A74
		JSR $9CBE

	org $009329+($07*2)
		dw .Repoint		; i don't care, we're merging game mode 07 into game mode 08

	org $009C64
		JSR $9A74
		JSR $9CBE

	org $009C9F
		NOP #4
	org $009CA3
		BRA 22 : NOP #22	; remove some writes to PPU regs when menu is loaded
	warnpc $009CBB

	org $009329+(8*2)
		dw .Repoint
	org $009CD1
		; FUCK YOU LUNAR MAGIC I WIN!! XD
	org $009CD8
	.Repoint
		JML .Main		;\ org: JSR $9D30 : LDY #$02
		NOP			;/
	pullpc


	.Main
		PHB : PHK : PLB
		PHP
		SEP #$30



		REP #$30
		LDA .SkyGradient+0
		AND #$00FF
		STA $04

		LDA $1C
		SEC : SBC #$0400
		STA $0C
		BPL $03 : LDA #$0000
		CMP #$0800
		BCC $03 : LDA #$0800
		LSR #2
		; boundary: 000-200

		LDX #$0000
	-	BIT .SkyGradient_r,x : BPL +
		DEX #2 : BRA -
	+	CMP .SkyGradient_r,x : BCC +
		SBC .SkyGradient_r,x
		INC $04
		BRA -

	+	TXY
		; Y = source table index
		STA $0E
		; $0E = scanline data for first chunk
		LDA $0C
		EOR #$FFFF
		BPL $03 : LDA #$0000
		LSR #2
		STA $0C
		; $0C = scanline boost for first chunk

		LDA .SkyGradient+1
		AND #$00FF
		STA $06
		LDA $04
		BPL $03 : LDA #$0000
		CMP $06
		BCC $02 : LDA $06
		STA $04

		LDA $13
		AND #$0001
		BEQ $03 : LDA #$0080
		TAX
		; X = double buffer index

		STZ $02
	-	LDA .SkyGradient_r,y : BPL +
		DEY #2 : BRA -
	+	SEC : SBC $0E
		STZ $0E
		CLC : ADC $0C
		STZ $0C
		CMP #$0080 : BCC +
		LSR A
		STA $0400,x
		BCC $01 : INC A
		STA $0402,x
		LDA $04
		ORA #$0020
		SEP #$20
		STA $0401,x
		STA $0403,x
		REP #$20
		INX #2
		BRA ++

	+	STA $0400,x
		LDA $04
		ORA #$0020
		STA $0401,x
	++	AND #$001F
		CMP $06
		BEQ $02 : INC $04
		LDA $02
		CLC : ADC .SkyGradient_r,y
		STA $02
		INX #2
		INY #2
		CMP #$0100 : BCC -
		STZ $0400,x



		REP #$30
		LDA .SkyGradient+2
		AND #$00FF
		STA $04

		LDA $1C
		SEC : SBC #$0400
		STA $0C
		BPL $03 : LDA #$0000
		CMP #$0800
		BCC $03 : LDA #$0800
		LSR #2
		; boundary: 000-200

		LDX #$0000
	-	BIT .SkyGradient_g,x : BPL +
		DEX #2 : BRA -
	+	CMP .SkyGradient_g,x : BCC +
		SBC .SkyGradient_g,x
		INC $04
		BRA -

	+	TXY
		; Y = source table index
		STA $0E
		; $0E = scanline data for first chunk
		LDA $0C
		EOR #$FFFF
		BPL $03 : LDA #$0000
		LSR #2
		STA $0C
		; $0C = scanline boost for first chunk


		LDA .SkyGradient+3
		AND #$00FF
		STA $06
		LDA $04
		BPL $03 : LDA #$0000
		CMP $06
		BCC $02 : LDA $06
		STA $04

		LDA $13
		AND #$0001
		BEQ $03 : LDA #$0080
		TAX
		; X = double buffer index

		STZ $02
	-	LDA .SkyGradient_g,y : BPL +
		DEY #2 : BRA -
	+	SEC : SBC $0E
		STZ $0E
		CLC : ADC $0C
		STZ $0C
		CMP #$0080 : BCC +
		LSR A
		STA $0500,x
		BCC $01 : INC A
		STA $0502,x
		LDA $04
		ORA #$0040
		SEP #$20
		STA $0501,x
		STA $0503,x
		REP #$20
		INX #2
		BRA ++

	+	STA $0500,x
		LDA $04
		ORA #$0040
		STA $0501,x
	++	AND #$001F
		CMP $06
		BEQ $02 : INC $04
		LDA $02
		CLC : ADC .SkyGradient_g,y
		STA $02
		INX #2
		INY #2
		CMP #$0100 : BCC -
		STZ $0500,x






		SEP #$30
		LDA $13
		AND #$01
		BEQ $02 : LDA #$80
		STA !HDMA6source
		STA !HDMA7source
		LDA #$04 : STA !HDMA6source+1
		LDA #$05 : STA !HDMA7source+1
		STZ $4364
		STZ $4374
		REP #$20
		LDA #$3200 : STA $4360
		LDA #$3200 : STA $4370
		SEP #$20






		LDA !GameMode
		CMP #$07 : BNE ..go
		..pressstart
		STZ $0D
		REP #$20
		LDA.w #.PressAnyButton : STA $02
		LDA.w #.PressAnyButton_end-.PressAnyButton : STA $0E
		SEP #$20
		LDA #$4C : STA $00

		LDA $13
		LSR #3
		AND #$07
		SEC : SBC #$04
		BPL $03 : EOR #$FF : INC A
		CLC : ADC #$80
		STA $01
		JSL !SpriteHUD
		..nodraw
		LDA $16
		ORA $18
		AND #$F0 : BEQ ..return
		LDA #$30 : STA !TimerFrames
		INC !GameMode
		..return
		PLP
		PLB
		JML $008494		; this routine is in bank 00 and ends in RTS so this is fine (build OAM btw)


		..go
		STZ $4200					; make sure no sprites get killed by lag frames by disabling NMI

		LDA #$5F : STA !Translevel			; use final slot to index text
		LDA !MsgTrigger : BEQ .NoText

		REP #$20
		LDA #$6600 : STA $400000+!MsgVRAM3
		SEP #$20
		LDA #$10 : TRB !HDMA				; disable BG3 HDMA
		LDA #$1C : STA !TextPal


		STZ $6DA8					;\
		LDA !MenuState					; |
		AND #$7F					; |
		CMP #$03 : BEQ +				; | input hax to prevent MSG from closing the box when it shouldn't
		LDA #$BF : TRB $6DA6				; |
		BRA ++						; |
	+	LDA #$EF : TRB $6DA6				; |
		++						;/

		%CallMSG()					; full MSG call

		REP #$20					;\
		LDA #$00FF					; |
		LDX #$09*2					; | cut out the top of the window
	-	STA $0336,x					; |
		DEX #2 : BPL -					; |
		SEP #$20					;/

		.NoText						;

		JSL !KillOAM

		LDA !MenuEraseTimer : BEQ .RestoreWindow
		LDY $610A
		LDA $13
		AND #$01
		BEQ $02 : LDA #$10
		ORA #$80
		STA !HDMA5source
		AND #$7F
		CLC : ADC .WindowIndex,y
		TAX
		LDA !MenuEraseTimer
		CLC : ADC .WindowOffset,y
		STA $0D82,x
		LDA .WindowOffset,y : STA $0D81,x
		BRA .NoWindow

		.RestoreWindow
		LDA $13
		AND #$01
		BEQ $02 : LDA #$10
		TAX
		LDA #$FF
		STA $0D81,x
		STZ $0D82,x
		STA $0D84,x
		STZ $0D85,x
		STA $0D87,x
		STZ $0D88,x
		STA $0D8A,x
		STZ $0D8B,x
		TXA
		ORA #$80
		STA !HDMA5source
		.NoWindow



		LDA $6DA2 : PHA					;\
		LDA $6DA4 : PHA					; | preserve input
		LDA $6DA6 : PHA					; |
		LDA $6DA8 : PHA					;/

		LDA !MenuState					;\
		ASL A						; |
		CMP.b #.Ptr_end-.Ptr				; | execute menu code
		BCC $02 : LDA #$00				; |
		TAX						; |
		JSR (.Ptr,x)					;/
		LDA !GameMode
		CMP #$0B : BNE ..playerstuff
		REP #$20
		LDA !OAMindex_p0_prev : STA !OAMindex_p0
		LDA !OAMindex_p1_prev : STA !OAMindex_p1
		LDA !OAMindex_p2_prev : STA !OAMindex_p2
		LDA !OAMindex_p3_prev : STA !OAMindex_p3
		SEP #$20
		BRA ..done


		..playerstuff
		STZ !P2Entrance-$80				; > no entrance anim
		LDA #$00 : STA !MultiPlayer			;\
		LDA #$02 : STA !MarioBehind			; |
		LDA !GameMode : PHA				; |
		LDA !TimerFrames : BNE ..restore		; > for mailbox rise animation
		LDA #$14 : STA !GameMode			; |
		LDA #$08 : STA $3180				; |
		LDA #$80 : STA $3181				; |
		LDA #$15 : STA $3182				; |
		LDA !P2ExternalAnimTimer-$80 : BEQ ..noforward	; |
		LDA !MenuState					; |
		AND #$7F : BEQ ..noforward			; |
		CMP #$08 : BEQ ..noforward			; |
		LDA !MarioXPosLo : PHA				; | scuffed PCE call for mario
		CLC : ADC #$08					; |
		STA !MarioXPosLo				; |
		JSR $1E80					; |
		PLA : STA !MarioXPosLo				; |
		BRA ..restore					; |
		..noforward					; |
		JSR $1E80					; |
		..restore					; |
		PLA : STA !GameMode				;/

		JSL .Mailbox
		; p is unknown here
		SEP #$20

		..done
		PLA : STA $6DA8					;\
		PLA : STA $6DA6					; | restore input
		PLA : STA $6DA4					; |
		PLA : STA $6DA2					;/

		LDA #$81 : STA $4200			; re-enable NMI + auto joypad

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
		dw .FileAway		; 07
		dw IntroText		; 08
		..end

		.Mailbox
		LDA !TimerFrames : BEQ +
		DEC !TimerFrames
		+
		STZ $00
		LDA #$02 : STA $0D
		REP #$20
		LDA #$0D10
		LDX $1D
		CPX #$0D
		BEQ $03 : LDA #$0C10
		SEC : SBC $1C
		CMP #$0050 : BCC ..draw
		SEP #$20
		JMP ..done
		..draw
		CLC : ADC !TimerFrames
		STA $01
		AND #$00FF
		CMP #$0030 : BCC ..0C
		CMP #$0040 : BCC ..08
		..04
		LDA #$0004 : BRA ..setsize
		..08
		LDA #$0008 : BRA ..setsize
		..0C
		LDA #$000C
		..setsize
		STA $0E
		..go
		LDX !P2ExternalAnimTimer-$80 : BEQ ..1closed
		LDX !P2ExternalAnim-$80
		CPX #$49 : BNE ..1closed
		LDX $610A : BNE ..1closed
		LDA.w #.Mailbox1TilemapOpen : BRA +
		..1closed
		LDA.w #.Mailbox1TilemapClosed
	+	STA $02
		JSR .DrawMailbox
		LDX !P2ExternalAnimTimer-$80 : BEQ ..2closed
		LDX !P2ExternalAnim-$80
		CPX #$49 : BNE ..2closed
		LDX $610A
		CPX #$01 : BNE ..2closed
		LDA.w #.Mailbox2TilemapOpen : BRA +
		..2closed
		LDA.w #.Mailbox2TilemapClosed
	+	STA $02
		JSR .DrawMailbox
		LDX !P2ExternalAnimTimer-$80 : BEQ ..3closed
		LDX !P2ExternalAnim-$80
		CPX #$49 : BNE ..3closed
		LDX $610A
		CPX #$02 : BNE ..3closed
		LDA.w #.Mailbox3TilemapOpen : BRA +
		..3closed
		LDA.w #.Mailbox3TilemapClosed
	+	STA $02
		JSR .DrawMailbox
		..done
		RTL

	.DrawMailbox
		PHP
		SEP #$20
		STZ $0F
		REP #$30
		LDY #$0000
		LDA !OAMindex_p0 : TAX
		..loop
		LDA ($02),y
		CLC : ADC $00				; this works as long as X coord doesn't overflow
		BCC ..draw				; only draw if there's no overflow on Y
		INY #4
		BRA ..next
		..draw
		STA !OAM_p0+$000,x
		INY #2
		LDA ($02),y : STA !OAM_p0+$002,x
		INY #2
		PHX
		TXA
		LSR #2
		TAX
		LDA $0D
		AND #$0002
		STA !OAMhi_p0+$00,x
		PLX
		INX #4
		..next
		CPY $0E : BCC ..loop
		TXA : STA !OAMindex_p0
		PLP
		RTS


		.PressAnyButton
		db $00,$00,$C3,$3D
		db $08,$00,$C4,$3D
		db $10,$00,$C5,$3D
		db $18,$00,$C6,$3D

		db $26,$00,$D3,$3D
		db $2E,$00,$D4,$3D
		db $36,$00,$D5,$3D

		db $43,$00,$E3,$3D
		db $4B,$00,$E4,$3D
		db $53,$00,$E5,$3D
		db $5B,$00,$E6,$3D
		db $63,$00,$E7,$3D
		..end



		.WindowIndex
		db $00,$03,$06
		.WindowOffset
		db $2F,$4F,$6F



		.SkyGradient
		; R min and R max
		db $06
		db $10

		; G min and G max
		db $05
		db $1B

		; B min and B max
		db $1D
		db $1F

		..r
		dw $29
		dw $FFFF	; repeat last byte

		..g
		dw $17
		dw $FFFF	; repeat last byte


		..b
		dw $40
		dw $FFFF	; repeat last byte






	.FilesAppear
	; INIT:
	; do any loading / processing that has to be done before we can proceed
	; we probably load layer 3 + tilemap and initialized HDMA here
	; MAIN:
	; use HDMA to move each file independently of the others
	; this state is just here for animation purposes

		LDA !TimerFrames : BEQ ..process
		RTS
		..process

		LDA !MenuState : BPL ..init
		JMP ..main
		..init
		ORA #$80 : STA !MenuState
		LDX.b #!MenuTemp-2
	-	STZ !MenuRAM+1,x
		DEX : BPL -


		LDA !MarioXPosLo : BNE +
		REP #$20
		LDA #$0110 : STA !MarioXPosLo
		SEP #$20
		LDA #$C0
		STA !MarioYSpeed
		STA !P2YSpeed-$80
		LDA #$D0
		STA !MarioXSpeed
		STA !P2XSpeed-$80
		STZ !MarioBlocked
		STZ !MarioDirection
		+


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



		STZ $41
		STZ $42
		STZ $43


		STZ $4334							;\
		STZ $4344							; | HDMA banks
		STZ $4354							;/

		LDA #$58 : STA $0C00 : STA $0C10				;\
		LDA #$58 : STA $0C05 : STA $0C15				; |
		LDA #$01 : STA $0C0A : STA $0C1A				; |
		STZ $0C0F : STZ $0C1F						; |
		REP #$20							; |
		LDA #$0D03 : STA $4330						; | set up layer 1 HDMA table
		LDA #$0C00 : STA !HDMA3source					; |
		LDA $1C								; > X = 0
		STZ $0C01 : STZ $0C11						; > Y = camera Y
		STA $0C03 : STA $0C13						; |
		STZ $0C06 : STZ $0C16						; |
		STA $0C08 : STA $0C18						; |
		STZ $0C0B : STZ $0C1B						; |
		STA $0C0D : STA $0C1D						;/
		LDA #$000C : STA !MenuBG1_Y


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
		LDA #$0D80 : STA !HDMA5source					; |
		LDA #$0030 : STA $0D80 : STA $0D90				; |
		LDA #$0030 : STA $0D83 : STA $0D93				; |
		LDA #$0030 : STA $0D86 : STA $0D96				; |
		LDA #$0001 : STA $0D89 : STA $0D99				; | window 1 HDMA table
		STZ $0D8C : STZ $0D9C						; |
		LDA #$00FF							; |
		STA $0D81 : STA $0D91						; |
		STA $0D84 : STA $0D94						; |
		STA $0D87 : STA $0D97						; |
		STA $0D8A : STA $0D9A						;/


		LDA.w #!DecompBuffer : STA $00					;\
		LDA.w #!DecompBuffer>>8 : STA $01				; |
		LDA.w #$B01							; |
		JSL !DecompressFile						; |
		JSL !GetVRAM							; | decompress file $B01 and upload it to VRAM
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
		LDA #$80 : STA $6DA2
		STZ $6DA4
		STZ $6DA6
		STZ $6DA8
		LDA !MarioYSpeed : BPL +
		LDA #$02 : STA !P2ExternalAnimTimer-$80
		LDA #$0B : STA !P2ExternalAnim-$80
		+


		LDA #$38 : STA !HDMA						; |

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
		JSR .DrawMovingFiles

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
		AND #$03
		ASL #2
		ORA $16
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
		LDA #$02 : STA !MenuState		;\
		LDA #$00 : STA !Difficulty		; | create a new file
		JSL NewFileSRAM				;/ (this prevents storage from previews)
		..nochoice


; fetch for each file:
;	- playtime hours ($009) + playtime minutes ($008)
;	- completion % ($004 + $270)
;	- realms beaten (1:$010,5; 2+:----)

		REP #$10
		LDY #$0002
	-	SEP #$20
		LDA SaveFileIndexHi,y : XBA
		LDA SaveFileIndexLo,y
		TAX
		LDA !SRAM_block+$00,x
		CMP #$FF : BEQ ..loopfile
		LDA .FileDispX,y : STA $04
		LDA .FileDispY,y : STA $05
		JSR .DrawFile
		..loopfile
		DEY : BPL -
		SEP #$30

		REP #$20
		LDA.w #.HackMarkTilemap : STA $02
		LDA #$0002 : STA $0D
		LDA #$0004 : STA $0E
		SEP #$20
		LDA !MenuIntegrity_1 : BEQ ..nohack1
		LDA #$50 : STA $00
		LDA #$14 : STA $01
		JSL !SpriteHUD
		..nohack1
		LDA !MenuIntegrity_2 : BEQ ..nohack2
		LDA #$70 : STA $00
		LDA #$44 : STA $01
		JSL !SpriteHUD
		..nohack2
		LDA !MenuIntegrity_3 : BEQ ..nohack3
		LDA #$90 : STA $00
		LDA #$74 : STA $01
		JSL !SpriteHUD
		..nohack3


		JSR .MoveMario
		LDA !MarioBlocked
		AND #$04 : BNE +
		STZ !P2Stasis-$80
		+


		LDX $610A
		LDA $13
		LSR #3
		AND #$07
		SEC : SBC #$04
		BPL $03 : EOR #$FF : INC A
		CLC : ADC .FileDispX,x
		SEC : SBC #$2C
		STA $00
		LDA .FileDispY,x
		CLC : ADC #$08
		STA $01
		REP #$20
		LDA.w #.HandTilemap : STA $02
		LDA #$0008 : STA $0E
		SEP #$20
		LDA #$02 : STA $0D
		JSL !SpriteHUD




	;	LDX $610A
	;	LDA .OutlineDispX,x : STA $00
	;	LDA .OutlineDispY,x : STA $01
	;	LDA $13
	;	AND #$18 : BEQ ..blink
	;	REP #$20
	;	LDA.w #.OutlineTilemap : STA $02
	;	LDA #$0050 : STA $0E
	;	SEP #$20
	;	LDA #$02 : STA $0D
	;	JSL !SpriteHUD
	;	..blink

		REP #$20
		LDA #$C820 : STA $00
		LDA.w #.ButtonsTilemap : STA $02
		LDA #$0002 : STA $0D
		LDA #$0004 : STA $0E
		SEP #$20
		JSL !SpriteHUD
		REP #$20
		LDA.w #.TooltipsTilemap : STA $02
		STZ $0D
		LDA #$0014 : STA $0E
		SEP #$20
		JSL !SpriteHUD


		LDX $610A
		LDA SaveFileIndexHi,x : XBA
		LDA SaveFileIndexLo,x
		REP #$10
		TAX
		LDA !SRAM_block,x
		SEP #$10
		CMP #$FF : BEQ +
		REP #$20
		LDA #$C570 : STA $00
		LDA.w #.EraseTilemap1 : STA $02
		LDA #$0002 : STA $0D
		LDA #$0010 : STA $0E
		SEP #$20
		JSL !SpriteHUD
		REP #$20
		LDA.w #.EraseTilemap2 : STA $02
		STZ $0D
		LDA #$0010 : STA $0E
		SEP #$20
		JSL !SpriteHUD
		+

		RTS



	.DrawMovingFiles
		REP #$10
		LDY #$0002
	-	LDA #$00 : XBA				; B = 0
		TYA
		ASL A
		TAX
		LDA !MenuBG3_Y_1,x
		CMP ..limit,y : BCS +
		EOR #$FF : INC A
		CLC : ADC .FileDispY,y
		CLC : ADC #$20
		STA $05
		LDA !MenuBG3_X_1,x
		EOR #$FF : INC A
		CLC : ADC .FileDispX,y
		STA $04
		LDA SaveFileIndexHi,y : XBA
		LDA SaveFileIndexLo,y
		TAX
		LDA !SRAM_block+$00,x
		CMP #$FF : BEQ +
		JSR .DrawFile
		SEP #$20
	+	DEY : BPL -

		LDA .FileDispY+2
		SEC : SBC !MenuBG3_Y_3
		CLC : ADC #$20
		STA $00
		LDX #$01FC
	-	LDA !OAM_p3+$003,x
		AND.b #$30^$FF
		STA !OAM_p3+$003,x
		LDA !OAM_p3+$001,x
		CMP #$F0 : BEQ +
		SEC : SBC #$20
		STA !OAM_p3+$001,x
		CMP #$F0 : BCS +
		CMP $00 : BCC +
		LDA #$F0 : STA !OAM_p3+$001,x
	+	DEX #4 : BPL -
		SEP #$10
		RTS

		..limit
		db $60,$60,$88


; input:
;	Y = file index
;	index 16-bit
;	A 8-bit
;	$04 = Xdisp
;	$05 = Ydisp
; output:
;	draws that file's info
	.DrawFile
		LDA $04
		CLC : ADC #$3A
		STA $00
		STZ $01
		LDA $05
		CLC : ADC #$14
		STA $02
		REP #$20
		LDA !SRAM_block+$008,x : STA !PlaytimeMinutes
		LDA !SRAM_block+$009,x : STA !PlaytimeHours
		LDA !SRAM_block+$004,x
		CLC : ADC !SRAM_block+$270,x
		ASL A
		AND #$00FF : PHA
		LDA !SRAM_block+$010+$005,x
		AND #$0080 : STA !BigRAM			; castle rex beaten flag
		PHY
		PHP
		JSR .DrawPlaytime
		PLP
		PLY
		LDA $04
		AND #$00FF
		CLC : ADC #$003E
		STA $00
		LDA $05
		CLC : ADC #$0004
		AND #$00FF : STA $02
		PLA
		PHY
		PHP
		JSR .DrawPercent_main
		PLP
		PLY
		LDA $04
		CLC : ADC #$0060
		STA $00
		LDA $05
		INC A
		STA $01
		LDA.w #.RealmPortraitTilemap : STA $02
		LDA #$0002 : STA $0D
		LDA #$0010 : STA $0E
		PHP
		PHY
		JSL !SpriteHUD
		PLY
		PLP
		LDA !BigRAM : BEQ ..done
		LDA $04
		CLC : ADC #$0010
		STA $00
		LDA $05
		CLC : ADC #$0010
		STA $01
		LDA.w #.SmallStarTilemap : STA $02
		STZ $0D
		LDA #$0004 : STA $0E
		PHP
		PHY
		JSL !SpriteHUD
		PLY
		PLP
		..done
		RTS



	.ChooseDifficulty
	; INIT:
	; load layer 1 tilemap
	; MAIN:
	; step 1 of making a new file, the player chooses easy / normal / insane

		LDA !MenuState : BMI ..main
		..init
		ORA #$80 : STA !MenuState
		STZ !MenuBG1_X
		STZ !MenuBG1_X+1
		REP #$10
		LDX !LevelHeight : JSR LoadScreen

		..main
		JSR .MoveMario

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
		LDA !MenuBG1_Y
		STA $0C03,x
		STA $0C08,x
		STX !HDMA3source			; always double buffer, baby!
		SEP #$20

		; remains of small previews
		LDA $0C02,x : BNE +
		PHX
		JSR .DrawMovingFiles
		PLX
		+

		; challenge mode icons (sprites)
		LDA $0C01,x
		EOR #$FF : INC A
		STA !BigRAM
		PHX
		JSR .DrawChallengeModes
		JSR .DrawDifficulty_all
		PLX

		LDA $0C02,x : BNE ..choose
		RTS

		..choose
		LDA #$30 : TRB !HDMA			; disable BG3 HDMA and window HDMA
		LDA $16
		AND #$0C : BEQ ..nochange
		CMP #$0C : BEQ ..nochange
		CMP #$04 : BEQ ..d
	..u	LDA !Difficulty
		DEC A : BPL ..w
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
		LDA #$06 : STA !SPC4
		BRA ..notextupdate
		..nochoice
		BVC ..noback
		LDA !WindowDir : BEQ ..waitfortext
		STZ !MenuState
		LDA #$06 : STA !SPC4
		..waitfortext
		RTS
		..noback

		LDA !Difficulty
		AND #$03
		INC A
		CMP !MsgTrigger : BEQ ..notextupdate
		STA !MsgTrigger
		LDA #$80 : STA !MsgTrigger+1
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
		CLC : ADC #$10
		STA $00
		LDA !Difficulty
		AND #$03 : STA $0F
		ASL #2
		ADC $0F
		ASL #2
		ADC #$50
		STA $01
		LDA #$02 : STA $0D
		REP #$20
		LDA.w #.HandTilemap : STA $02
		SEP #$20
		LDA #$08 : STA $0E
		JSL !SpriteHUD

		; tooltips
		REP #$20
		LDA #$0128 : STA $00
		LDA.w #.ButtonsTilemap : STA $02
		SEP #$20
		LDA #$02 : STA $0D
		LDA #$08 : STA $0E
		JSL !SpriteHUD
		REP #$20
		LDA.w #.TooltipsTilemap : STA $02
		SEP #$20
		STZ $0D
		LDA #$20 : STA $0E
		JSL !SpriteHUD

		RTS



	.ChallengeModes
	; INIT:
	; reset cursor
	; MAIN:
	; step 2 of making a new file, the player checks the challenge modes they want, if any
		LDA !MenuState : BMI ..main
		..init
		ORA #$80 : STA !MenuState
		STZ !MenuChallengeSelect

		..main
		JSR .MoveMario

		LDA $16
		AND #$0C : BEQ ..nochange
		CMP #$0C : BEQ ..nochange
		CMP #$04 : BEQ ..d
	..u	LDA !MenuChallengeSelect
		DEC A : BPL ..w
		LDA #$02 : BRA ..w
	..d	LDA !MenuChallengeSelect
		INC A
		CMP #$03
		BCC $02 : LDA #$00
	..w	STA !MenuChallengeSelect
		LDA #$06 : STA !SPC4
		..nochange


		BIT $16 : BPL ..nochoice
		LDX !MenuChallengeSelect
		LDA .ChallengeModeOrder,x
		EOR !Difficulty : STA !Difficulty
		AND .ChallengeModeOrder,x : BNE +
		LDA #$13 : STA !SPC4
		BRA ..nochoice
	+	LDA #$1F : STA !SPC4
		..nochoice

		BIT $16 : BVC ..noback
		LDA #$06 : STA !SPC4
		LDA #$82 : STA !MenuState
		LDA !Difficulty
		AND #$03
		STA !Difficulty
		JMP ..nostart
		..noback

		LDA $16
		AND #$10 : BNE ..createnewfile
		JMP ..nostart

		..createnewfile
		LDA !Difficulty : JSL NewFileSRAM	; new file (store difficulty only)
		PHB					;\
		LDA.b #!SRAM_block>>16			; |
		PHA : PLB				; |
		REP #$30				; |
		LDX #$02FC				; | kill SRAM buffer
	-	STZ.w !SRAM_buffer+2,x			; |
		DEX #2 : BPL -				; |
		SEP #$30				; |
		STZ.w !SRAM_buffer+1			; > lo byte of coin hoard
		PLB					;/
		LDA #$01 : STA !MarioStatus		; start with mario only
		REP #$20				;\
		LDA #$00B8 : STA !SRAM_overworldX	; | starting overworld coords
		LDA #$0370 : STA !SRAM_overworldY	; |
		SEP #$20				;/

	if !Debug = 1				;\
	LDA $17					; |
	AND #$10 : BEQ +			; |
	LDA #$01				; |
	STA !KadaalStatus			; |
	STA !LeewayStatus			; | debug: hold R to start with all chars + skip intro level
	STA !AlterStatus			; |
	STA !PeachStatus			; |
	LDA #$80 : STA !LevelTable1+$00		; |
	LDA #$81 : STA !StoryFlags+$00		; |
	STZ $6109				; |
	+					; |
	endif					;/
	if !Debug = 1				;\
	LDA $17					; |
	AND #$20 : BEQ +			; |
	LDA #$FF				; |
	STA !MarioUpgrades			; |
	STA !LuigiUpgrades			; |
	STA !KadaalUpgrades			; |
	STA !LeewayUpgrades			; | debug: hold L to start with all upgrades + skip intro level
	STA !AlterUpgrades			; |
	STA !PeachUpgrades			; |
	LDA #$80 : STA !LevelTable1+$00		; |
	LDA #$81 : STA !StoryFlags+$00		; |
	STZ $6109				; |
	+					; |
	endif					;/
		JSL SaveFileSRAM
	;	LDA #$0B : STA !GameMode
	;	LDA #$EA : STA $6109
		LDA #$07 : STA !MenuState
		RTS
		..nostart


		LDA !MenuChallengeSelect
		CLC : ADC #$04
		CMP !MsgTrigger : BEQ ..notextupdate
		STA !MsgTrigger
		LDA #$80 : STA !MsgTrigger+1
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
		ADC #$58
		STA $01
		LDA #$02 : STA $0D
		REP #$20
		LDA.w #.HandTilemap : STA $02
		SEP #$20
		LDA #$08 : STA $0E
		JSL !SpriteHUD

		; challenge markers
		LDA !Difficulty
		AND.b #$03^$FF
		STA $08
		LDX #$05
		LDA #$9E : STA $00
		LDA #$31-$8 : STA $01
		REP #$20
		LDA.w #.MarkTilemap : STA $02
		SEP #$20
		LDA #$02 : STA $0D
		LDA #$04 : STA $0E
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
		ASL A
		TAX
		REP #$20
		STZ $00
		LDA .UnderscorePointer,x : STA $02
		LDA ($02) : STA $0E
		INC $02
		INC $02
		SEP #$20
		STZ $0D
		JSL !SpriteHUD

		; tooltips
		REP #$20
		LDA #$0128 : STA $00
		LDA.w #.ButtonsTilemap : STA $02
		SEP #$20
		LDA #$02 : STA $0D
		LDA #$08 : STA $0E
		JSL !SpriteHUD
		REP #$20
		LDA.w #.TooltipsTilemap : STA $02
		SEP #$20
		STZ $0D
		LDA #$20 : STA $0E
		JSL !SpriteHUD
		REP #$20
		LDA #$01A4 : STA $00
		LDA.w #.StartTilemap1 : STA $02
		SEP #$20
		LDA #$02 : STA $0D
		LDA #$08 : STA $0E
		JSL !SpriteHUD
		REP #$20
		LDA.w #.StartTilemap2 : STA $02
		SEP #$20
		STZ $0D
		LDA #$10 : STA $0E
		JSL !SpriteHUD

		; challenge mode icons (sprites)
		STZ !BigRAM
		JSR .DrawChallengeModes
		JSR .DrawDifficulty_all

		RTS

		.ChallengeModeOrder
		db !TimeMode,!CriticalMode,!IronmanMode,!HardcoreMode



	.PreviewFile
	; INIT:
	; load layer 1 tilemap
	; when loading a new file, its stats are previewed for the player to see (A/B confirm, X/Y cancel)
		LDA !MenuState : BMI ..main
		..init
		ORA #$80 : STA !MenuState
		STZ !TimerSeconds
		STZ !TimerSeconds+1
		REP #$30
		LDA !LevelHeight
		ASL A
		TAX
		SEP #$20
		JSR LoadScreen
		JSL LoadFileSRAM
		LDA #$00
		STA !Characters
		STA !MarioUpgrades

		..main
		LDA !P2Stasis-$80 : BEQ +
		LDA !TimerSeconds+1
		CMP.b #.OpenCoords_end-.OpenCoords-1 : BCS +
		INC !TimerSeconds+1
	+	JSR .MoveMario
		LDA !P2Stasis-$80 : BEQ ..noopen
		STA !P2ExternalAnimTimer-$80
		LDX !TimerSeconds+1
		LDA .OpenCoords,x : STA !MarioYPosLo
		LDA .OpenImg,x : STA !P2ExternalAnim-$80
		..noopen

		REP #$20
		LDY #$04
	-	LDA !MenuBG3_Y_1,y
		CMP #$0100 : BEQ +
		CLC : ADC #$0004
		STA !MenuBG3_Y_1,y
	+	DEY #2 : BPL -

		..rendertext
		LDA !MenuBG3_Y_1
		CMP #$00FC : BNE +
		JSR .DrawChapterTitle
		LDA #$0100 : STA !MenuBG3_Y_1
		+

		LDA !MenuBG3_Y_1
		CMP #$0100
		SEP #$20
		BEQ +


		JSR HandleBG3Files
		JSR .DrawMovingFiles
		LDA !TimerSeconds : BNE +
		LDA !P2ExternalAnim-$80
		CMP #$26 : BEQ ++
		RTS

	++	INC !TimerSeconds

	+	LDA $13
		AND #$01
		BEQ $02 : LDA #$10
		TAX
		REP #$20
		LDA !MenuBG1_X
		CMP #$0100 : BEQ +
		CLC : ADC #$0008
		STA !MenuBG1_X
	+	LDA !MenuBG1_X
		STA $0C01,x
		STA $0C06,x
		CLC : ADC #$00E0
		STA $22
		LDA !MenuBG1_Y
		STA $0C03,x
		STA $0C08,x
		CLC : ADC #$FFF8
		STA $24
		STX !HDMA3source			; always double buffer, baby!
		LDA !MenuBG1_X
		EOR #$FFFF : INC A
		EOR #$0100
		STA !BigRAM
		SEP #$20
		LDA !MenuBG1_X+1 : BNE ..choose
		..draw
		JSR .DrawDifficulty
		JSR .DrawChallengeModes
		JSR .DrawRealmStars
		JSR .DrawCounterIcons
		REP #$30				;\
		LDA !BigRAM				; |
		CLC : ADC #$00C0			; | playtime
		STA $00					; |
		LDA.w #!NumColumnHeight+$00 : STA $02	; |
		JSR .DrawPlaytime			;/
		JSR .DrawCoins
		JSR .DrawDeaths
		REP #$30				;\
		LDA !BigRAM				; |
		CLC : ADC #$00C8			; |
		STA $00					; |
		LDA #$0084 : STA $02			; |
		LDA !LevelsBeaten			; |
		ASL A					; | completion %
		STA $0A					; |
		LDA !YoshiCoinCount			; |
		ASL A					; |
		ADC $0A					; |
		AND #$00FF				; |
		JSR .DrawPercent_main			; |
		JSR .DrawPercent_underscore		;/


		LDA !MenuBG1_X+1 : BEQ ..noback

		; tooltips
		REP #$20
		LDA #$0128 : STA $00
		LDA.w #.ButtonsTilemap : STA $02
		SEP #$20
		LDA #$02 : STA $0D
		LDA #$08 : STA $0E
		JSL !SpriteHUD
		REP #$20
		LDA.w #.TooltipsTilemap : STA $02
		SEP #$20
		STZ $0D
		LDA #$20 : STA $0E
		JSL !SpriteHUD
		RTS

		..choose
		BIT $16
		BVS ..back
		BMI $03 : JMP ..draw
		JSL LoadFileSRAM
		STZ $6109
		LDA #$80 : STA !SPC3
		LDA #$0B : STA !GameMode
		RTS
		..back
		STZ !MenuState
		STZ $22
		LDA #$01 : STA $23
		STZ !HDMA
		..noback
		RTS



		.OpenCoords
		db $B0,$AB,$A7,$A3,$9F,$9C,$99,$96
		db $94,$92,$91,$90,$8F,$8F,$8F,$8F
		db $90,$91,$93,$95,$97,$9A

		db $9B,$9B,$9B,$9B,$9B,$9B,$9B,$9B
		db $9B,$9B,$9B,$9B,$9B,$9B,$9B,$9B
		db $9B,$9B,$9B,$9B,$9B,$9B,$9B,$9B
		db $9B,$9B,$9B,$9B,$9B,$9B,$9B,$9B
		db $9B,$9B,$9B,$9B,$9B,$9B,$9B,$9B
		db $9B,$9B,$9B,$9B,$9B,$9B,$9B,$9B

		db $9C,$9D,$9F,$A0,$A2,$A4,$A7,$A9
		db $AC,$B0
		..end



		.OpenImg
		db $0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B
		db $0B,$0B,$0B,$0B,$0B,$24,$24,$24
		db $24,$24,$24,$24,$24,$24

		db $49,$49,$49,$49,$49,$49,$49,$49
		db $49,$49,$49,$49,$49,$49,$49,$49
		db $49,$49,$49,$49,$49,$49,$49,$49
		db $49,$49,$49,$49,$49,$49,$49,$49
		db $49,$49,$49,$49,$49,$49,$49,$49
		db $49,$49,$49,$49,$49,$49,$49,$49

		db $24,$24,$24,$24,$24,$24,$24,$24
		db $24,$26




	.DrawChapterTitle
		PHP
		; get chapter num here
		LDX #$00	; placeholder
		REP #$20
		LDA.w #IntroText_SA1 : STA $3180
		LDA ..ptr,x : STA $BE
		SEP #$20
		LDA.b #IntroText_SA1>>16 : STA $3182
		LDA.b #..ptr>>16 : STA $BE+2
		JSR $1E80
		LDA #$10 : TRB !HDMA
		PLP
		RTS

		..ptr
		dw ..chapter0

		..chapter0
		db "Chapter 1:"
		%linebreak()
		db "  An Island's Dark Fate"
		%endmessage()
		dw $0800			; size
		dw $0800			; VRAM offset


	.DrawRealmStars
		REP #$20				;\
		LDA.w #..tilemap : STA $02		; |
		STZ $0D					; | setup
		LDA #$0004 : STA $0E			; |
		SEP #$20				;/

		LDX #$07				;\
		..loop					; |
		LDY ..levels,x				; | check if respective levels are beaten
		CPY #$60 : BCS ..next			; |
		LDA !LevelTable1,y : BPL ..next		;/
		TXA					;\
		ASL A					; |
		TAY					; |
		LDA ..coords+0,y			; |
		EOR #$FF : INC A			; | get coords
		CMP !BigRAM : BCC ..next		; |
		LDA ..coords+0,y			; |
		CLC : ADC !BigRAM			; |
		STA $00					; |
		LDA ..coords+1,y : STA $01		;/
		PHX					;\
		JSL !SpriteHUD				; | draw star
		PLX					;/
		..next					;\ loop
		DEX : BPL ..loop			;/
		RTS					; return


		..levels
		db $05			; realm 1
		db $FF			; realm 2
		db $FF			; realm 3
		db $FF			; realm 4
		db $FF			; realm 5
		db $FF			; realm 6
		db $FF			; realm 7
		db $FF			; realm 8

		..coords
		db $46,$84		; realm 1
		db $00,$00		; realm 2
		db $00,$00		; realm 3
		db $00,$00		; realm 4
		db $00,$00		; realm 5
		db $00,$00		; realm 6
		db $00,$00		; realm 7
		db $00,$00		; realm 8

		..tilemap
		db $00,$00,$83,$3F


	.DrawCounterIcons
		LDA !BigRAM
		CMP #$4C : BCS ..fail
		ADC #$B4
		STA $00
		LDA.b #!NumColumnHeight+$00 : STA $01
		REP #$20
		LDA.w #..icons : STA $02
		STZ $0D
		LDA #$0018 : STA $0E
		JSL !SpriteHUD
		SEP #$20
		..fail
		RTS

		..icons
		db $00,$00,$8F,$3F	; clock
		db $00,$0C-2,$9F,$3F	;\ yoshi coin
		db $00,$14-2,$AF,$3F	;/
		db $00,$18,$BF,$3F	; coin
		db $00,$24-1,$CF,$3F	;\ skull
		db $00,$2C-1,$DF,$3F	;/


	.DrawDifficulty
		LDA !Difficulty
		AND #$03
		ASL A
		TAX
		LDA !BigRAM
		CMP #$E0 : BCS ..fail
		CLC : ADC #$20
		STA $00
		LDA #$20 : STA $01
		REP #$20
		LDA ..ptr,x
		..draw
		STA $02
		LDA ($02) : STA $0E
		INC $02
		INC $02
		SEP #$20
		LDA #$02 : STA $0D
		JSL !SpriteHUD
		..fail
		RTS

		..ptr
		dw ..easy
		dw ..normal
		dw ..insane

		..easy
		dw $0008
		db $00,$00,$86,$3F
		db $10,$08,$88,$3F
		..normal
		dw $0010
		db $00,$00,$8A,$3F
		db $10,$00,$8C,$3F
		db $18,$00,$8D,$3F
		db $28,$00,$A6,$3F
		..insane
		dw $000C
		db $00,$00,$D9,$3F
		db $10,$00,$DB,$3F
		db $20,$00,$DD,$3F


		..all
		LDA !BigRAM
		CMP #$C0 : BCS ..fail
		ADC #$40
		STA $00
		LDA #$4C : STA $01
		REP #$20
		LDA.w #..easy : JSR ..draw
		LDA #$60 : STA $01
		REP #$20
		LDA.w #..normal : JSR ..draw
		LDA #$74 : STA $01
		REP #$20
		LDA.w #..insane : BRA ..draw



	.DrawChallengeModes
		LDA !Difficulty
		LSR #2
		STA $04
		LDA #$02 : STA $0D
		LDA #$24 : STA $01
		LDX #$00
		..loop
		REP #$20
		LDA !MenuState
		AND #$007F
		CMP #$0004 : BEQ ..preview
		LDA !BigRAM
		AND #$00FF : STA $00
		TXA
		AND #$00FF
		LSR A
		TAY
		LDA !Difficulty
		AND #$00FF
		AND .ChallengeModeOrder,y : BNE ..chosen
		..grey
		LDA ..ptrgrey,x : BRA ..draw
		..chosen
		LDA ..ptrchosen,x : BRA ..draw
		..preview
		LSR $04 : BCC ..next
		LDA ..ptrpreview,x
		..draw
		STA $02
		LDA #$0004 : STA $0E
		SEP #$20
		LDA ($02)
		EOR #$FF : INC A
		CMP !BigRAM : BCC ..next
		LDA !BigRAM : STA $00
		PHX
		JSL !SpriteHUD
		PLX
		..next
		INX #2
		CPX.b #..end-..ptrpreview : BCC ..loop
		SEP #$20
		RTS



		..ptrpreview
		dw ..timepreview
		dw ..criticalpreview
		dw ..ironmanpreview
		..end

		..timepreview
		db $70,$00,$B8,$3F
		..criticalpreview
		db $84,$00,$BA,$3F
		..ironmanpreview
		db $98,$00,$BC,$3F

		..ptrgrey
		dw ..timegrey
		dw ..criticalgrey
		dw ..ironmangrey

		..timegrey
		db $B0,$54,$B8,$39
		..criticalgrey
		db $B0,$65,$BA,$39
		..ironmangrey
		db $B0,$78,$BC,$39

		..ptrchosen
		dw ..timechosen
		dw ..criticalchosen
		dw ..ironmanchosen

		..timechosen
		db $B0,$54,$B8,$3F
		..criticalchosen
		db $B0,$65,$BA,$3F
		..ironmanchosen
		db $B0,$78,$BC,$3F



; input:
;	$00 = Xdisp
;	$02 = Ydisp
	.DrawPlaytime
	; hours
		STZ $0E
		LDA !PlaytimeHours : STA $0A
		LDX #$0000						;\
		CMP #$03E8 : BCC ..skipfirst				; |
	-	CMP #$03E8 : BCC ..draw1000s				; |
		SBC #$03E8						; |
		INX : BRA -						; | 1000s
		..draw1000s						; |
		STA $0A							; |
		TXA : JSR DrawDigit					; |
		..skipfirst						;/
		LDX #$0000						;\
		LDA $0A							; |
		BIT $0E : BMI ..calcsecond				; |
		CMP #$0064 : BCC ..skipsecond				; |
		..calcsecond						; |
	-	CMP #$0064 : BCC ..draw100s				; | 100s
		SBC #$0064						; |
		INX : BRA -						; |
		..draw100s						; |
		STA $0A							; |
		TXA : JSR DrawDigit					; |
		..skipsecond						;/
		LDX #$0000						;\
		LDA $0A							; |
		BIT $0E : BMI ..calcthird				; |
		CMP #$000A : BCC ..skipthird				; |
		..calcthird						; |
	-	CMP #$000A : BCC ..draw10s				; | 10s
		SBC #$000A						; |
		INX : BRA -						; |
		..draw10s						; |
		STA $0A							; |
		TXA : JSR DrawDigit					; |
		..skipthird						;/
		LDA $0A : JSR DrawDigit					; 1s

	; minutes
		.DrawMinutes
		LDA #$000B : JSR DrawDigit

		LDA !PlaytimeMinutes
		AND #$00FF : STA $0A
		LDX #$0000						;\
	-	CMP #$000A : BCC ..draw10s				; |
		SBC #$000A						; |
		INX : BRA -						; | 10s
		..draw10s						; |
		STA $0A							; |
		TXA : JSR DrawDigit					;/
		LDA $0A : JSR DrawDigit					; 1s
		SEP #$30
		RTS

; simple hex -> dec converter in 2 steps (hours + minutes)

	.DrawCoins
		REP #$30
		LDA !BigRAM
		CLC : ADC #$00C0
		STA $00
		LDA.w #!NumColumnHeight+$18 : STA $02
		STZ $0E							; has not yet drawn anything

		LDA !CoinHoard : STA $0A				;\
		LDA !CoinHoard+2					; | setup
		AND #$00FF : STA $0C					; |
		TAY							;/
		BEQ ..skipfirst						;\
		LDX #$0000						; |
		LDA $0A							; |
	-	CPY #$0002 : BCS +					; |
		CMP #$86A0 : BCS +					; | calculate 100000s digit
		CPY #$0001 : BEQ ..draw100000s				; |
	+	SBC #$86A0						; |
		INX							; |
		DEY : BNE -						;/
		..draw100000s						;\
		STA $0A							; |
		STY $0C							; | draw 100000s digit
		TXA : JSR DrawDigit					; |
		LDY $0C							; |
		..skipfirst						;/

		LDX #$0000						;\
		LDA $0A							; |
		LDY $0C : BNE ..calcsecond				; |
		BIT $0E : BMI ..calcsecond				; |
		CMP #$2710 : BCC ..skipsecond				; |
		..calcsecond						; | calculate 10000s digit
	-	CMP #$2710 : BCS +					; |
		CPY #$0001 : BCC ..draw10000s				; |
	+	SBC #$2710						; |
		BCS $01 : DEY						; |
		INX							; |
		BRA -							;/
		..draw10000s						;\
		STA $0A							; | draw 10000s digit
		TXA : JSR DrawDigit					; |
		..skipsecond						;/

		LDX #$0000						;\
		LDA $0A							; |
		BIT $0E : BMI ..calcthird				; |
		CMP #$03E8 : BCC ..skipthird				; |
		..calcthird						; | calculate 1000s digit
	-	CMP #$03E8 : BCC ..draw1000s				; |
		SBC #$03E8						; |
		INX							; |
		BRA -							;/
		..draw1000s						;\
		STA $0A							; | draw 1000s digit
		TXA : JSR DrawDigit					; |
		..skipthird						;/

		LDX #$0000						;\
		LDA $0A							; |
		BIT $0E : BMI ..calcfourth				; |
		CMP #$0064 : BCC ..skipfourth				; |
		..calcfourth						; | calculate 100s digit
	-	CMP #$0064 : BCC ..draw100s				; |
		SBC #$0064						; |
		INX							; |
		BRA -							;/
		..draw100s						;\
		STA $0A							; | draw 100s digit
		TXA : JSR DrawDigit					; |
		..skipfourth						;/

		LDX #$0000						;\
		LDA $0A							; |
		BIT $0E : BMI ..calcfifth				; |
		CMP #$000A : BCC ..skipfifth				; |
		..calcfifth						; | calculate 10s digit
	-	CMP #$000A : BCC ..draw10s				; |
		SBC #$000A						; |
		INX							; |
		BRA -							;/
		..draw10s						;\
		STA $0A							; | draw 10s digit
		TXA : JSR DrawDigit					; |
		..skipfifth						;/
		LDA $0A : JSR DrawDigit					; draw 1s digit

		.DrawYoshiCoinCounter
		LDA !BigRAM
		CLC : ADC #$00C0
		STA $00
		LDA.w #!NumColumnHeight+$0C : STA $02
		LDA !YoshiCoinCount : STA $0A				;/
		STZ $0E
		LDX #$0000						;\
		CMP #$03E8 : BCC ..skipfirst				; |
	-	CMP #$03E8 : BCC ..draw1000s				; |
		SBC #$03E8						; |
		INX : BRA -						; | 1000s
		..draw1000s						; |
		STA $0A							; |
		TXA : JSR DrawDigit					; |
		..skipfirst						;/
		LDX #$0000						;\
		LDA $0A							; |
		BIT $0E : BMI ..calcsecond				; |
		CMP #$0064 : BCC ..skipsecond				; |
		..calcsecond						; |
	-	CMP #$0064 : BCC ..draw100s				; | 100s
		SBC #$0064						; |
		INX : BRA -						; |
		..draw100s						; |
		STA $0A							; |
		TXA : JSR DrawDigit					; |
		..skipsecond						;/
		LDX #$0000						;\
		LDA $0A							; |
		BIT $0E : BMI ..calcthird				; |
		CMP #$000A : BCC ..skipthird				; |
		..calcthird						; |
	-	CMP #$000A : BCC ..draw10s				; | 10s
		SBC #$000A						; |
		INX : BRA -						; |
		..draw10s						; |
		STA $0A							; |
		TXA : JSR DrawDigit					; |
		..skipthird						;/
		LDA $0A : JSR DrawDigit					; 1s
		SEP #$30
		RTS


	.DrawDeaths
		REP #$30
		LDA !BigRAM
		CLC : ADC #$00C0
		STA $00
		LDA.w #!NumColumnHeight+$24 : STA $02
		STZ $0E
		LDA !P1DeathCounter
		CLC : ADC !P2DeathCounter
		STA $0A
		LDX #$0000						;\
		CMP #$03E8 : BCC ..skipfirst				; |
	-	CMP #$03E8 : BCC ..draw1000s				; |
		SBC #$03E8						; |
		INX : BRA -						; | 1000s
		..draw1000s						; |
		STA $0A							; |
		TXA : JSR DrawDigit					; |
		..skipfirst						;/
		LDX #$0000						;\
		LDA $0A							; |
		BIT $0E : BMI ..calcsecond				; |
		CMP #$0064 : BCC ..skipsecond				; |
		..calcsecond						; |
	-	CMP #$0064 : BCC ..draw100s				; | 100s
		SBC #$0064						; |
		INX : BRA -						; |
		..draw100s						; |
		STA $0A							; |
		TXA : JSR DrawDigit					; |
		..skipsecond						;/
		LDX #$0000						;\
		LDA $0A							; |
		BIT $0E : BMI ..calcthird				; |
		CMP #$000A : BCC ..skipthird				; |
		..calcthird						; |
	-	CMP #$000A : BCC ..draw10s				; | 10s
		SBC #$000A						; |
		INX : BRA -						; |
		..draw10s						; |
		STA $0A							; |
		TXA : JSR DrawDigit					; |
		..skipthird						;/
		LDA $0A : JSR DrawDigit					; 1s
		SEP #$30
		RTS



; input:
;	A = completion %
;	$00 = Xdisp
;	$02 = Ydisp
	.DrawPercent

		..main
		STA $0A
		CMP #$0064 : BCC ++
		LDX #$0000
	-	CMP #$0064 : BCC +
		SBC #$0064
		INX : BRA -
	+	STA $0A
		TXA : JSR DrawDigit
	++	LDA $0A
		LDX #$0000
	-	CMP #$000A : BCC +
		SBC #$000A
		INX : BRA -
	+	STA $0A
		TXA : JSR DrawDigit
		LDA $0A : JSR DrawDigit
		LDA #$000A : JSR DrawDigit
		SEP #$30
		RTS

		..underscore
		REP #$30
		LDA !BigRAM
		AND #$00FF
		CMP #$003A : BCS ..return
		ADC #$00C6
		STA $00
		LDA #$008D : STA $01
		LDA.w #..underscoretilemap : STA $02
		STZ $0D
		LDA #$000C : STA $0E
		JSL !SpriteHUD
		..return
		SEP #$30
		RTS


		..underscoretilemap
		db $00,$00,$B0,$3F
		db $08,$00,$B1,$3F
		db $10,$00,$B0,$7F


; what counts as %?
;	- level clears
;	- yoshi coins
;	- certain story flags
;
;	demo:
;	- total 3 playable characters		4% each, total 12%	sum 12%
;	- total 8 levels (including intro)	6% each, total 48%	sum 60%
;	- total 40 yoshi coins			1% each, total 40%	sum 100%
;
;	these calculations will be completely different later, but for demo this is fine

;	- 8 levels 2% each total 16
;	- 40 coins 2% each total 80
;	- shopkeeper 4%





	.EraseFile
	; MAIN:
	; ask if player is sure they want to erase the file
	; if yes, erase it and go back to state 1


		LDA #$02 : STA !P2Stasis-$80

		JSL EraseFileSRAM
		STZ !MenuState
		RTS


	.LoadFile
	; INIT:
	; call load SRAM routine, then set game mode to 0B

		LDA #$02 : STA !P2Stasis-$80

		JSL LoadFileSRAM
		STZ $6109				; go directly to realm select
		LDA #$80 : STA !SPC3
		LDA #$0B : STA !GameMode
		RTS




	.MoveMario
		LDX $610A
		LDA !MarioXPosHi : BPL ..process
		LDA #$C1 : STA $6DA2
		BRA ..clear
		..process
		LDA .MarioX,x
		CMP !MarioXPosLo : BEQ ..good
		BCC ..left
		..right
		LDA #$41 : STA $6DA2
		BRA ..clear
		..left
		LDA #$42 : STA $6DA2
		BRA ..clear
		..good
		STZ $6DA2
		LDA #$02 : STA !P2Stasis-$80
		LDA #$01 : STA !MarioDirection
		..clear
		STZ $6DA4
		STZ $6DA6
		STZ $6DA8
		..done
		RTS




		.Mailbox1TilemapClosed
		db $30,$90,$60,$0A
		db $30,$A0,$68,$0A
		db $30,$B0,$6A,$0A
		.Mailbox1TilemapOpen
		db $30,$90,$66,$0A
		db $30,$A0,$68,$0A
		db $30,$B0,$6A,$0A

		.Mailbox2TilemapClosed
		db $70,$90,$62,$0A
		db $70,$A0,$68,$0A
		db $70,$B0,$6A,$0A
		.Mailbox2TilemapOpen
		db $70,$90,$66,$0A
		db $70,$A0,$68,$0A
		db $70,$B0,$6A,$0A

		.Mailbox3TilemapClosed
		db $B0,$90,$64,$0A
		db $B0,$A0,$68,$0A
		db $B0,$B0,$6A,$0A
		.Mailbox3TilemapOpen
		db $B0,$90,$66,$0A
		db $B0,$A0,$68,$0A
		db $B0,$B0,$6A,$0A

		.MarioX
		db $20,$60,$A0



		.MarioTilemap
		db $38,$B0,$00,$30
		db $38,$C0,$02,$30

		.HandTilemap
		db $10,$00,$80,$3F
		db $18,$00,$81,$3F
	;	db $18,$00,$83,$3F
	;	db $00,$08,$90,$3F
	;	db $10,$08,$92,$3F

		.MarkTilemap
		db $00,$00,$84,$3F

		.UnderscoreTilemap
		db $00,$00,$B0,$3F
		db $08,$00,$B1,$3F
		db $10,$00,$B1,$3F
		db $18,$00,$B0,$7F

		.UnderscorePointer
		dw ..easy
		dw ..normal
		dw ..insane

		..easy
		dw $0014
		db $3C,$5E,$B0,$3F
		db $44,$5E,$B1,$3F
		db $4C,$5E,$B1,$3F
		db $54,$5E,$B1,$3F
		db $5C,$5E,$B0,$7F
		..normal
		dw $0020
		db $3C,$72,$B0,$3F
		db $44,$72,$B1,$3F
		db $4C,$72,$B1,$3F
		db $54,$72,$B1,$3F
		db $5C,$72,$B1,$3F
		db $64,$72,$B1,$3F
		db $6C,$72,$B1,$3F
		db $74,$72,$B0,$7F
		..insane
		dw $001C
		db $3C,$86,$B0,$3F
		db $44,$86,$B1,$3F
		db $4C,$86,$B1,$3F
		db $54,$86,$B1,$3F
		db $5C,$86,$B1,$3F
		db $64,$86,$B1,$3F
		db $6C,$86,$B0,$7F


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

		.FileDispX
		db $2F,$4F,$6F
		.FileDispY
		db $06,$36,$66

		.EraseTilemap1
		db $04,$07,$60,$3D	;\
		db $14,$07,$62,$3D	; | buttons
		db $00,$00,$40,$3D	; |
		db $10,$00,$42,$3D	;/
		.EraseTilemap2
		db $20,$07,$A0,$3F	;\
		db $28,$07,$A1,$3F	; | "ERASE" text
		db $30,$07,$A2,$3F	; |
		db $38,$07,$A3,$3F	;/

		.ButtonsTilemap
		db $00,$00,$02,$3D
		db $3C,$00,$22,$3D

		.TooltipsTilemap
		db $14,$04,$A8,$3F	;\
		db $1C,$04,$A9,$3F	; |
		db $24,$04,$AA,$3F	; | CHOOSE
		db $2C,$04,$AB,$3F	; |
		db $34,$04,$AC,$3F	;/
		db $50,$04,$D6,$3F	;\
		db $58,$04,$D7,$3F	; | BACK
		db $60,$04,$D8,$3F	;/

		.StartTilemap1
		db $00,$FE,$04,$3D	;\ button
		db $08,$FE,$05,$3D	;/
		.StartTilemap2
		db $1C,$04,$FC,$3F	;\
		db $24,$04,$FD,$3F	; | "START" text
		db $2C,$04,$FE,$3F	; |
		db $34,$04,$FF,$3F	;/


		.SmallStarTilemap
		db $00,$00,$83,$3F

		.RealmPortraitTilemap
		db $00,$00,$C0,$3E
		db $10,$00,$C2,$3E
		db $00,$10,$E0,$3E
		db $10,$10,$E2,$3E

		.HackMarkTilemap
		db $00,$00,$84,$3F




	.FileAway
		LDA !MsgTrigger
		ORA !MsgTrigger+1
		BEQ ..process
		RTS
		..process

		LDA !MenuState : BMI ..main
		..init
		ORA #$80 : STA !MenuState
		STZ $41								; disable window 1 on BG1 and BG2
		STZ $42								; disable window 1 on BG3
		STZ $43								; disable window 1 on sprites

		..main
		LDA #$41 : STA $6DA2
		STZ $6DA4
		STZ $6DA6
		STZ $6DA8
		LDA $13
		AND #$01
		BEQ $02 : LDA #$10
		TAX
		REP #$20
		LDA !MenuBG1_X : BEQ ..done
		SEC : SBC #$0002
		STA !MenuBG1_X
		STA $0C01,x
		STA $0C06,x
		LDA !MenuBG1_Y
		STA $0C03,x
		STA $0C08,x
		STX !HDMA3source
		SEP #$20
		RTS


		..done
		SEP #$20
		LDA #$08 : STA !MenuState
		STZ !HDMA
		RTS



	DrawDigit:
		; A = digit
		TAY
		LDA !OAMindex_p3 : TAX
		TYA
		CLC : ADC #$3FF0
		STA !OAM_p3+$002,x
		SEP #$20
		LDA $00 : STA !OAM_p3+$000,x
		LDA $02 : STA !OAM_p3+$001,x
		REP #$20

		DEC $0E				; n flag set

		TXA
		LSR #2
		TAX
		LDA $01
		AND #$0001 : STA !OAMhi_p3,x
		INX
		TXA
		ASL #2
		STA !OAMindex_p3

		LDA .Width,y
		AND #$00FF
		CLC : ADC $00
		STA $00

		RTS


		.Width
		db $06	; 0
		db $06	; 1
		db $07	; 2
		db $07	; 3
		db $07	; 4
		db $06	; 5
		db $06	; 6
		db $06	; 7
		db $06	; 8
		db $06	; 9
		db $08	; %
		db $05	; :



; cloud sprite data:
; $3200 - type
; $3210 - Y
; $3220 - X
; $3240 - layer (lo byte of pointer, hi byte is always 30)
; $3250 - scroll rate
	IntroText:
		LDA #$02 : STA !P2Stasis-$80
		LDA !MenuState : BMI .Main

		.Init
		ORA #$80 : STA !MenuState

	;	LDA #$10 : TSB !2131
		LDA #$C0 : TSB !HDMA

		STZ !AnimToggle			; make sure CCDMA doesn't black bar by putting limit at 2KB/frame

		REP #$20
		LDA !BG2BaseV
		DEC A
		STA $20
		SEP #$20
		LDA #$01 : STA !Mode7Scale+1
		STZ !Mode7Scale
		LDA #$17
		TSB !MainScreen
		TRB !SubScreen
		STZ !TimerSeconds
		STZ !TimerSeconds+1
		LDA #$03
		TRB !2107
		TRB !2108
		LDA #$02
		TSB !2107
		TSB !2108
		LDA #$01 : TRB $1D
		LDA #$18 : STA $24
		LDA #$01 : STA $25
		LDX #$0F
	-	STZ $3200,x
		DEX : BPL -
		LDA.b #.SA1_textdata : STA $BE
		LDA.b #.SA1_textdata>>8 : STA $BE+1
		LDA.b #.SA1_textdata>>16 : STA $BE+2
		LDA.b #.SA1 : STA $3180
		LDA.b #.SA1>>8 : STA $3181
		LDA.b #.SA1>>16 : STA $3182
		JMP $1E80



		.Main
		LDA #$02 : STA !P2ExternalAnimTimer-$80
		LDA #$0C : STA !P2ExternalAnim-$80

		REP #$20
		INC !TimerSeconds
		DEC $1C
		LDA $13
		LSR A
		BCC $02 : DEC $20


		LDA !MarioYPosLo
		CMP #$04A0 : BCC +
		LDA #$04A0 : STA !MarioYPosLo
		LDA #$0108 : STA !MarioXPosLo
		+

		LDA $1C
		CMP #$0400 : BCS ..skipmario
		SEC : SBC #$0080
		SEP #$20
		ASL A
		ORA #$80
		STA !MarioYSpeed
		LDA #$C0 : STA !MarioXSpeed
		STZ !MarioDirection
		STZ !P2Stasis-$80
		REP #$20
		..skipmario

		LDA $1C
		CMP #$0380 : BCS ..skipsmall
		CMP #$0320 : BCC ..skipsmall
		SEC : SBC #$0040
		SEP #$20
		EOR #$FF
		CLC : ADC #$31
		STA $01
		LDA $1C
		SEC : SBC #$40
		EOR #$FF
		SEC : SBC #$5F
		LSR A
		STA $00
		REP #$20
		LDA.w #.SmallMarioTM : STA $02
		LDA #$0002 : STA $0D
		LDA #$0004 : STA $0E
		SEP #$20
		JSL !SpriteHUD
		REP #$20
		..skipsmall





		.HandleClouds
		SEP #$20
		LDA.b #.ProcessClouds : STA $3180
		LDA.b #.ProcessClouds>>8 : STA $3181
		LDA.b #.ProcessClouds>>16 : STA $3182
		JSR $1E80
		REP #$20

		.Layer2
		LDA $20
		CMP #$FF20
		SEP #$20
		BCS ..done
		LDA #$02
		TRB !MainScreen
		TRB !SubScreen
		..done

		.Layer1
		REP #$20
		LDA $1C
		CMP #$0BF0 : BEQ ..clear
		CMP #$0800 : BEQ ..loadairship
		JMP ..done
		..clear
		JSL !GetVRAM
		LDA #$5000 : STA !VRAMbase+!VRAMtable+$00,x
		LDA.w #.BG1Clear : STA !VRAMbase+!VRAMtable+$02,x
		LDA.w #.BG1Clear>>16 : STA !VRAMbase+!VRAMtable+$04,x
		LDA !2107
		AND #$00FC
		XBA
		STA !VRAMbase+!VRAMtable+$05,x
		BRA ..done
		..loadairship
		REP #$30
		LDA #$0003 : TRB !2107
		LDA #$0001 : TSB !2107
		REP #$20							;\
		LDA.w #!DecompBuffer : STA $00					; |
		LDA.w #!DecompBuffer>>8 : STA $01				; |
		LDA.w #$D03							; |
		JSL !DecompressFile						; |
		JSL !GetVRAM							; | decompress file $D03 and upload it to VRAM
		LDA #$3FFE : STA !VRAMbase+!VRAMtable+$00,x			; |
		LDA.w #!DecompBuffer : STA !VRAMbase+!VRAMtable+$02,x		; |
		LDA.w #!DecompBuffer>>8 : STA !VRAMbase+!VRAMtable+$03,x	; |
		LDA #$0000 : STA !VRAMbase+!VRAMtable+$05,x			; |
		SEP #$20							;/
		..done
		SEP #$30

		.Layer3
		LDA $13
		AND #$03 : BNE ..done
		LDA !MainScreen
		ORA !SubScreen
		AND #$02 : BNE ..done
		REP #$20
		LDA #$FFF0 : STA $22
		INC $24
		SEP #$20
		..done

		.FinalTimer
		..doublebuffer
		REP #$30
		LDA #$0040
		STA !Mode7CenterX
		STA !Mode7CenterY
		LDA !TimerSeconds
		CMP #$0980 : BEQ ..kill
		CMP #$0780 : BCS ..move
		SEP #$30
		RTS

		..move
		SBC #$0780
		STA $00
		LSR #4
		EOR #$FFFF
		CLC : ADC #$0010
		STA !Mode7Rotation
		LDA $00
		CMP #$0180 : BCC ..0100
		AND #$007F
		EOR #$007F
		ASL A
		BRA +
		..0100
		LDA #$0100 : BRA +
	+	STA !Mode7Scale
		SEP #$20
		LDA #$07 : STA !2105
		LDA #$08 : STA !Mode7Settings
		REP #$20
		LDA $00
		CMP #$0180 : BCC ++
		LDA #$FFC0 : BRA +
	++	LSR A
		EOR #$FFFF
		AND #$01FF
		CMP #$0100
		BCC $03 : ORA #$FF00
		CLC : ADC #$0080
	+	STA !Mode7X
		LDA $00
		CMP #$0180 : BCS +
		LSR A
		EOR #$FFFF
		CLC : ADC #$00A0
		AND #$01FF
		CMP #$0100
		BCC $03 : ORA #$FF00
		STA !Mode7Y
	+	BRA ..done
		..kill
		SEP #$20
		LDA #$80 : STA !SPC3
		LDA #$0B : STA !GameMode
		..done
		SEP #$30
		RTS



		.BG1Clear
		dw $38F8



		.ProcessClouds
		PHB : PHK : PLB			;\ wrapper start
		PHP				;/

		STZ $2250				; prepare multiplication

		REP #$30				; all regs 16-bit
		LDX #$0000				;\ set up loop regs
		LDY #$0000				;/
		..spawnloop				;\
		LDA .CloudData+$04,y			; | check for spawnable cloud
		CMP !TimerSeconds : BNE ..nospawn	; |
		..spawn					;/

		LDA .CloudData+$02,y			;\
		AND #$00FF				; |
		ORA #$3000				; |
		STA $00					; |
		LDA ($00)				; |
		EOR #$FFFF				; |
		STA $2251				; |
		LDA .CloudData+$03,y			; |
		AND #$00FF				; | calculate initial y offset
		CMP #$00FF				; |
		BNE $03 : LDA #$0100			; |
		ASL A					; |
		STA $2253				; |
		SEP #$20				; |
		LDA #$E0				; |
		SEC : SBC $2307				; |
		STA $3210,x				;/
		LDA .CloudData+$00,y : STA $3200,x	;\
		LDA .CloudData+$01,y : STA $3220,x	; | get static data
		LDA .CloudData+$02,y : STA $3240,x	; |
		LDA .CloudData+$03,y : STA $3250,x	;/
		REP #$20				; A 16-bit
		..nospawn				;\
		INX					; |
		TYA					; | loop
		CLC : ADC #$0006			; |
		TAY					; |
		CPX #$0006 : BCC ..spawnloop		;/
		SEP #$30				; all regs 8-bit

		LDX #$0F				; 16 entries
		..loop					;\ check num
		LDA $3200,x : BEQ ..next		;/
		DEC A					;\
		ASL A					; |
		TAY					; | tilemap pointer
		LDA .CloudPtr,y : STA $04		; |
		LDA .CloudPtr+1,y : STA $05		;/
		LDA $3240,x : STA $00			;\
		LDA #$30 : STA $01			; |
		REP #$20				; |
		LDA ($00)				; |
		EOR #$FFFF				; |
		STA $2251				; | ratio x layer coord
		LDA $3250,x				; |
		AND #$00FF				; |
		CMP #$00FF				; |
		BNE $03 : LDA #$0100			; > 0xFF = 0x100
		ASL A					; |
		STA $2253				;/
		LDA ($04) : STA $0E			;\
		INC $04					; | byte count + increment pointer past header
		INC $04					;/
		LDA $3220,x				;\
		AND #$00FF				; | X
		STA $00					;/
		LDA $3210,x				;\
		AND #$00FF				; |
		CLC : ADC $2307				; |
		AND #$00FF				; | Y
		CMP #$00E0				; |
		BCC $03 : ORA #$FF00			; > loop screen at 224px
		STA $02					;/
		SEP #$20				; A 8-bit
		LDA #$02 : STA $0D			; size bit

		JSR ..scale				; offset caused by mode 7 camera

		PHX					;\
		JSR ..draw				; | draw cloud
		PLX					;/
		..next					;\ loop
		DEX : BPL ..loop			;/

		PLP					;\ wrapper end
		PLB					;/
		RTL					; return


		..scale
		REP #$30
		LDA $00
		SEC : SBC !Mode7CenterX
		CLC : ADC !Mode7X
		STA $2251
		LDA !Mode7Scale
		LSR A
		CLC : ADC #$0080
		JSL !GetReciprocal : STA $2253
		LDA !Mode7CenterX
		SEC : SBC !Mode7X
		CLC : ADC $2307
		STA $00
		LDA $02
		SEC : SBC !Mode7CenterY
		CLC : ADC !Mode7Y
		STA $2251
		LDA !Mode7Scale
		LSR A
		CLC : ADC #$0080
		JSL !GetReciprocal : STA $2253
		LDA !Mode7CenterY
		SEC : SBC !Mode7Y
		CLC : ADC $2307
		STA $02
		SEP #$30
		RTS

		..draw
		PHP
		SEP #$20
		STZ $0F
		REP #$30
		LDY #$0000
		LDA !OAMindex_p3 : TAX
	-	LDA ($04),y
		AND #$00FF
		CLC : ADC $00
		CMP #$FFF0 : BCS +
		CMP #$0100 : BCC +
		INY #4
		BRA ++
	+	STA !OAM_p3+$000,x
		STA $06
		INY
		LDA ($04),y
		AND #$00FF
		CLC : ADC $02
		CMP #$FFF0 : BCS +
		CMP #$00E0 : BCC +
		INY #3
		BRA ++
	+	STA !OAM_p3+$001,x
		INY
		LDA ($04),y : STA !OAM_p3+$002,x
		INY #2
		PHX
		TXA
		LSR #2
		TAX
		LDA $07
		AND #$0001
		ORA $0D
		STA !OAMhi_p3+$00,x
		PLX
		INX #4
	++	CPY $0E : BCC -
		TXA : STA !OAMindex_p3
		PLP
		RTS





		.SmallMarioTM
		db $00,$00,$8E,$40


; format:
; 00	type
; 01	X offset
; 02	layer
; 03	ratio
; 04-05	spawn time

		.CloudData

		..0
		db $04		; type
		db $70		; x offset
		db $20		; layer
		db $60		; ratio
		dw $0080	; spawn time
		..1
		db $01		; type
		db $10		; x offset
		db $1C		; layer
		db $80		; ratio
		dw $00A0	; spawn time
		..2
		db $01		; type
		db $30		; x offset
		db $1C		; layer
		db $60		; ratio
		dw $00E0	; spawn time
		..3
		db $03		; type
		db $50		; x offset
		db $20		; layer
		db $80		; ratio
		dw $0100	; spawn time
		..4
		db $04		; type
		db $A0		; x offset
		db $1C		; layer
		db $60		; ratio
		dw $0120	; spawn time
		..5
		db $03		; type
		db $D4		; x offset
		db $1C		; layer
		db $80		; ratio
		dw $00C0	; spawn time



		.CloudPtr
		dw .CloudTM1
		dw .CloudTM2
		dw .CloudTM3
		dw .CloudTM4



		.CloudTM1
		dw $0010
		db $00,$00,$80,$08
		db $10,$00,$82,$08
		db $00,$10,$A0,$08
		db $10,$10,$A2,$08

		.CloudTM2
		dw $0020
		db $00,$00,$84,$08
		db $10,$00,$86,$08
		db $00,$10,$A4,$08
		db $10,$10,$A6,$08
		db $00,$20,$C4,$08
		db $10,$20,$C6,$08
		db $00,$30,$E4,$08
		db $10,$30,$E6,$08

		.CloudTM3
		dw $0010
		db $00,$00,$88,$08
		db $10,$00,$8A,$08
		db $00,$10,$A8,$08
		db $10,$10,$AA,$08

		.CloudTM4
		dw $0020
		db $00,$00,$C8,$08
		db $10,$00,$CA,$08
		db $20,$00,$CC,$08
		db $30,$00,$CE,$08
		db $00,$10,$E8,$08
		db $10,$10,$EA,$08
		db $20,$10,$EC,$08
		db $30,$10,$EE,$08



;
; $00 - 24-bit pointer to font GFX
; $03 - 24-bit pointer to font data
; $06 - index to source text
; $08 - index to rendering buffer
; $0A - loop counter for character cache
; $0C - used for calculating address for character
; $0E - holds character data from font
;
; $0200 - virtual !BigRAM

		.SA1
		PHB							;\ wrapper start
		PHP							;/
		REP #$30						;\
		LDY.w #read2(!TextFontGFX)				; |
		JSL !GetFileAddress					; | set up font pointer
		LDA !FileAddress+0 : STA $00				; |
		LDA !FileAddress+1 : STA $01				;/
		SEP #$20						;\ 2bpp
		LDA #$80 : STA $223F					;/
		LDA.b #!ImageCache>>16					;\
		PHA : PLB						; |
		REP #$20						; | clear rendering buffer
		LDY #$1FFE						; |
		LDA #$0000						; |
	-	STA.w !GFX_buffer,y					; |
		DEY #2 : BPL -						;/

		LDA.w #read2(!TextFontData)				;\
		CLC : ADC.w #!TextFontData				; | set up pointer to font data
		STA $03							; |
		LDA.w #!TextFontData>>16 : STA $05			;/
		STZ $06							; starting read index
		STZ $08							; starting rendering index
		SEP #$20						; A 8-bit
		LDA.b #!V_buffer>>16					;\ go into bank 0x60
		PHA : PLB						;/


	..loop
		REP #$20
		LDX $06
		..readnext
		TXY
		LDA [$BE],y
		INX
		AND #$00FF
		CMP #$007F : BEQ ..space
		CMP #$00FE : BEQ ..newline
		CMP #$00FF : BNE ..rendertext
		JMP ..endmessage

		..newline
		LDA $08							;\
		AND #$FF00						; | clear X, then add 16 to Y
		CLC : ADC #$1000					; |
		STA $08							;/
		BRA ..readnext						; go to next

		..space
		LDA $08							;\
		CLC : ADC #$0006					; | add 6 to X
		STA $08							;/
		BRA ..readnext						; go to next

		..rendertext
		ASL A							;\
		TAY							; |
		LDA [$03],y : STA $0E					; |
		AND #$000F						; |
		ASL A							; | Y = index to character in cached font
		STA $0C							; | ($0F = width of character)
		LDA $0E							; |
		AND #$00F0						; |
		ASL #4							; |
		TSB $0C							;/

		STX $06							; store source index
		LDA $0F							;\
		AND #$00FF						; |
		LSR #2							; | reg setup for cache
		STA $0A							; |
		LDX #$0000						;/

	-	LDY $0C							;\
		LDA [$00],y : STA.l !BigRAM+$00,x			; |
		LDA $0C							; |
		CLC : ADC #$0020					; |
		TAY							; |
		LDA [$00],y : STA.l !BigRAM+$08,x			; |
		LDA $0C							; |
		CLC : ADC #$0040					; |
		TAY							; |
		LDA [$00],y : STA.l !BigRAM+$10,x			; |
		LDA $0C							; |
		CLC : ADC #$0060					; |
		TAY							; |
		LDA [$00],y : STA.l !BigRAM+$18,x			; |
		LDA $0C							; |
		CLC : ADC #$0080					; |
		TAY							; |
		LDA [$00],y : STA.l !BigRAM+$20,x			; |
		LDA $0C							; |
		CLC : ADC #$00A0					; | cache character
		TAY							; |
		LDA [$00],y : STA.l !BigRAM+$28,x			; |
		LDA $0C							; |
		CLC : ADC #$00C0					; |
		TAY							; |
		LDA [$00],y : STA.l !BigRAM+$30,x			; |
		LDA $0C							; |
		CLC : ADC #$00E0					; |
		TAY							; |
		LDA [$00],y : STA.l !BigRAM+$38,x			; |
		LDA $0C							; |
		CLC : ADC #$0100					; |
		TAY							; |
		LDA [$00],y : STA.l !BigRAM+$40,x			; |
		INC $0C							; |
		INC $0C							; |
		INX #2							; |
		CPX $0A : BCS $03 : JMP -				;/


		LDY #$0000						;\
		LDX $08							; | reg setup for render
		SEP #$20						;/
	-	LDA.w $0200,y : STA.w !V_buffer*2+$000,x		;\
		LDA.w $0220,y : STA.w !V_buffer*2+$100,x		; |
		LDA.w $0240,y : STA.w !V_buffer*2+$200,x		; |
		LDA.w $0260,y : STA.w !V_buffer*2+$300,x		; |
		LDA.w $0280,y : STA.w !V_buffer*2+$400,x		; |
		LDA.w $02A0,y : STA.w !V_buffer*2+$500,x		; | render character
		LDA.w $02C0,y : STA.w !V_buffer*2+$600,x		; |
		LDA.w $02E0,y : STA.w !V_buffer*2+$700,x		; |
		LDA.w $0300,y : STA.w !V_buffer*2+$800,x		; |
		INX							; |
		INY							; |
		DEC $0F : BNE -						;/
		STX $08							; store new rendering index
		JMP ..loop						; go to loop


		..endmessage
		TYA							;\
		SEC : ADC $BE						; | get pointer to upload data (SEC : ADC for +1)
		STA $BE							;/
		SEP #$30
		LDA #$40 : PHA : PLB
		JSL !GetBigCCDMA					; X = index to CCDMA table
		LDA #$16 : STA !CCDMAtable+$07,x			; > width = 256px, bit depth = 2bpp
		LDA.b #!GFX_buffer>>16 : STA !CCDMAtable+$04,x		;\
		REP #$20						; | source adddress
		LDA.w #!GFX_buffer : STA !CCDMAtable+$02,x		;/
		LDA [$BE] : STA !CCDMAtable+$00,x			; upload size
		INC $BE							;\ pointer +2
		INC $BE							;/
		LDA.l !210C						;\
		AND #$000F						; |
		XBA							; | dest VRAM
		ASL #4							; |
		ADC [$BE]						; > +offset
		STA !CCDMAtable+$05,x					;/

		REP #$30						; all regs 16-bit
		LDX #$0000						; X = 0
		LDA [$BE] : BEQ +					;\
		LSR #2							; | number of bytes to skip (empty)
		STA $00							;/
		LDA #$39FF						;\
	-	STA.w !DecompBuffer,x					; | skip tiles
		INX #2							; |
		CPX $00 : BCC -						;/
	+	TXA							;\
		LSR A							; |
		ORA #$2400						; |
	-	STA.w !DecompBuffer,x					; |
		INC A							; |
		INX #2							; | generate tilemap
		CPX #$0400 : BCC -					; |
		LDA #$39FF						; |
	-	STA.w !DecompBuffer,x					; |
		INX #2							; |
		CPX #$0800 : BCC -					;/


		SEP #$30						;\
		JSL !GetVRAM						; |
		REP #$20						; |
		LDA #$0800 : STA !VRAMtable+$00,x			; |
		LDA.w #!DecompBuffer : STA !VRAMtable+$02,x		; | upload tilemap
		LDA.w #!DecompBuffer>>16 : STA !VRAMtable+$04,x		; |
		LDA.l !2109						; |
		AND #$00FC						; |
		XBA							; |
		STA !VRAMtable+$05,x					;/

		PLP							;\ wrapper end
		PLB							;/
		RTL							; return


		..textdata
		db "The Mushroom Kingdom is at peace"
		%linebreak()
		db "but in the distant Dinosaur Land"
		%linebreak()
		db "trouble is brewing!"
		%linebreak()
		db "Who could be behind these dastardly deeds?"
		%linebreak()
		db "The Mario Bros. set out"
		%linebreak()
		db "in order to find the truth."
		%linebreak()
		db "What awaits our heroes"
		%linebreak()
		db "in this unknown land?"
		%endmessage()
		dw $2000						; size (8KiB)
		dw $0000						; offset






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
		JSL $06F540			; how in the world did i find this?
		PLP
		PLX				; get "Y" in X
		STA $0A
		LDY #$0000
		LDA [$0A],y : STA $410000,x
		INY #2
		LDA [$0A],y : STA $410040,x
		INY #2
		LDA [$0A],y : STA $410002,x
		INY #2
		LDA [$0A],y : STA $410042,x
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
		LDA #$0000 : STA !VRAMbase+!VRAMtable+$02,x
		LDA #$0041 : STA !VRAMbase+!VRAMtable+$04,x
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
		JML SaveFileSRAM	;\
		JML EraseFileSRAM	; | org: PHB : PHK : PLB : LDX $610A : LDA.w $9CCB,x
		NOP			;/
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