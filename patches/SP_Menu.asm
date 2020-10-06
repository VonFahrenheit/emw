header
sa1rom

;
;
; to do...
; - replace the nintendo presents screen, maybe use a mode7 logo or something
; - have a little animation for the title screen appearing (can be skipped by pushing any button)
; - upon pushing a button, you're taken to the file select
; - upon choosing a new file, you pick a difficulty (2 columns, 1 for primary difficulty 1 for challenge modes)
; - upon choosing an existing file, you get to see a little spreadsheet with info on your progress
; - upon starting a new file, the camera pans up into the starry sky and seamlessly transitions into the game's intro
; - upon loading an existing file, you're taken to the realm select


DO NOT PATCH THIS YET


; better save function:
	SaveGame:
		PHB : PHK : PLB
		LDX $610A
		LDA .IndexHi,x : XBA
		LDA .IndexLo,x
		REP #$10
		TAX
		PHX
		LDY #$0000
	-	LDA $7F49,y : STA $41C213,x
		INX
		INY
		CPY #$008D : BCC -
		PLX
		LDA #$40 : PHA : PLB
		LDY #$0000
	-	LDA.w !SRAM_buffer,y : STA $41C000,x
		INX
		INY
		CPY #$0100 : BCC -
		PLB
		RTL
	.IndexLo
		db $00,$A0,$40
	.IndexHi
		db $00,$02,$05
	; 32 bytes at the end of the SRAM area are reserved for special use



	!FreeRAM		= $4100			; Assume !FreeBNK (Indexed by Y so it has to be 16-bit)
	!FreeBNK		= $40
	!DataLength		= DataEnd-DataStart
	!RAM_buffer		= $4000			; Same thing here, assume !FreeBNK so I can index with Y
	!FreeSRAM		= $41C400
	!DifficultySize		= DataEnd-Difficulty
	!CustomSize		= CustomStripeEnd-CustomStripe


	!Permanent		= $41C7FC


	incsrc "Defines.asm"				; Include standard defines


;====================;
;MENUS AND STATUS BAR;
;====================;

	org $0084E2

		dl !FreeBNK*$10000+!FreeRAM		; Location of 1/2 player select stripe

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


	org $009F19					; prevent level data from resetting
		BRA $02 : NOP #2			; Source: JSL $05DD80 (inserted by Lunar Magic)


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
		AND #$10				; | Only use timer during Timed Mode
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
	+



;		LDA $6F36				;\
;		STA $00					; |
;		STZ $01					; |
;		REP #$20				; |
;		LDA $6F34				; |
;		SEC : SBC #$423F			; |
;		LDA $00					; |
;		SBC #$000F				; |
;		BCC +					; | Handle score overflow, the maximum is 999999 (0x0F423F)
;		SEP #$20				; |
;		LDA #$0F				; |
;		STA $6F36				; |
;		LDA #$42				; |
;		STA $6F35				; |
;		LDA #$3F				; |
;		STA $6F34				; |
;	+	SEP #$20				;/
;		LDA $6F36
;		STA $00
;		STZ $01
;		LDA $6F35
;		STA $03
;		LDA $6F34
;		STA $02
;		LDX #$14
;		LDY #$00
;	--	SEP #$20
;		STZ.w $6F12-$14,x
;	-	REP #$20
;		LDA $02
;		SEC : SBC.w .ScoreData+$02,y
;		STA $06
;		LDA $00
;		SBC.w .ScoreData,y
;		STA $04
;		BCC +
;		LDA $06
;		STA $02
;		LDA $04
;		STA $00
;		SEP #$20
;		INC.w $6F12-$14,x
;		BRA -
;	+	INX
;		INY #4
;		CPY #$18
;		BNE --
;		SEP #$20
;		STZ $6F18				; > Last digit is zero
;		LDX #$00				;\
;	-	LDA $6F12,x				; |
;		BNE .CoinIncrease			; |
;		LDA #$FC				; | Wipe leading zeroes from score
;		STA $6F12,x				; |
;		INX					; |
;		CPX #$06				; |
;		BNE -					;/
;.CoinIncrease	LDA $73CC				;\
;		BEQ .Lives				; |
;		DEC $73CC				; |
;		INC $6DBF				; |
;		LDA $6DBF				; | Handle coin increase
;		CMP #$64				; |
;		BCC .Lives				; |
;		SEC : SBC #$64				; |
;		STA $6DBF				; |
;		INC $78E4				;/
;.Lives		LDA #$3A				;\
;		STA $6F07				; |
;		INC A					; | Write "1UP X"
;		STA $6F08				; |
;		LDA #$26				; |
;		STA $6F09				;/
;		LDA !Difficulty				;\
;		AND #$03				; |
;		TAX					; |
;		LDA $6DBE				; |
;		BMI +					; |
;		CMP .1UpLimit,x				; |
;		BCC +					; | Write lives (limit depends on difficulty)
;		LDA .1UpLimit,x				; |
;		STA $6DBE				; |
;	+	INC A					; |
;		JSR $9045				; |
;		TXY					; |
;		BNE +					; |
;		LDX #$FC				; |
;	+	STX $6F0A				; |
;		STA $6F0B				;/
;		LDA #$FC				;\ Empty space
;		STA $6F0C				;/
;.Coins		LDA #$2E				;\
;		STA $6F0D				; | Write "[Coin Symbol] X"
;		LDA #$26				; |
;		STA $6F0E				;/
;		LDA $6DBF				;\
;		JSR $9045				; |
;		TXY					; |
;		BNE +					; | Write coins
;		LDX #$FC				; |
;	+	STX $6F0F				; |
;		STA $6F10				;/
;		LDA #$FC				;\ Empty space
;		STA $6F11				;/

		REP #$20
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

	..Start	LDA $40400B,x				; Load Yoshi Coins collected table
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


		LDA !MultiPlayer			;\
		BNE .Player1HP				; |
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
		LDA #$4A				; | Write player 2 HP
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
		LDX !CoinSound
		BNE .ManyCoins
		LDX #$01 : STX !SPC4
		LDX #$04 : STX !CoinSound

		.ManyCoins
		RTS


warnpc $009045

	org $00905B
		SBC.w STATUS_BAR_ScoreData+$02,y	; Fix this offset

	org $00940F					; Hijack Game Mode 01 routine
		JML INIT				;\ Source: DEC $1DF5 : BNE $06 ($00941A)
		NOP					;/

	org $009AEA
		JML CURSOR_GFX		; Hijack the code that handles the menu position

	org $009AF9
		JML CURSOR_SFX		; Hijack the code that handles the menu cursor SFX

	org $009B3D					; The code that erases save files
		JML ERASE			; Source: CPX #$03 : BNE CODE_009B6D (2C)

	org $009BCB					; Hijack save game routine
		JML SAVE			; Source: PLB : LDX $010A

	org $009D22					; Hijack load save file routine
		JSL LOAD			; Source: SEP #$10 : LDY #$12

	org $009D29					; The code that activates 1/2 player select
		JSL CUSTOM_MENU		; Source: STY $12 : LDX #$00

	org $009D55					; Code that determines the base address for yellow numbers
		JSL FIX_OFFSET_Base		; Fix base address for yellow numbers

	org $009DA8					; Code that updates yellow numbers for each file
		JSL FIX_OFFSET		;\ Source: LDA $00 : SEC : SBC #$24
		NOP					;/

	org $009E0D					; The code that sets SMW's 2 player mode
		JML SET_DIFFICULTY		; Hijack 2 player mode routine
		NOP : NOP				; Source: STX $0DB2 : JSR $A195

	org $009E6E					; Number of options during 1/2 player select
		db $03					; Enable 3 options

	org $00F37A					; Code that updates number of Yoshi Coins collected
		JSL YOSHI_COIN		; Source: INC $1420 : CLC


;=======================;
;POWERUPS AND ANIMATIONS;
;=======================;

	org $00F5F8

		BRA +					;\
		NOP					; | Prevent item in item box from automatically falling
		NOP					;/
	+

	org $00F620

		STZ $9D					; Prevent game from pausing when Mario gets hurt

	org $01C563

		INC $19					; Remove grow animation

	org $01C56A

		STZ $9D					; Prevent game from pausing when Mario gets a mushroom

	org $01C5A3

		BRA +					;\
		NOP					; | Prevent infinite score exploit
		NOP					;/
	+

	org $01C5AB

		STZ $9D					; Prevent game from pausing when Mario gets a cape

	org $01C5B6

		STZ $71					; Remove get cape animation

	org $01C5F1

		STZ $9D					; Prevent game from pausing when Mario gets a flower

	org $01C5F3

		STZ $7407				; Remove get fire animation
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


org $028766		;\
	BRA +		; |
	NOP #11		; | Disable score from breaking blocks
warnpc $028773		; |
org $028773		; |
	+		;/

org $02AE21		;\
	BRA +		; |
	NOP #18		; | Disable score from score sprites
warnpc $02AE35		; |
org $02AE35		; |
	+		;/

org $05CEF9		;\
	BRA +		; |
	NOP #10		; | Disable score from beating a level
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




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;				      ;;
;; ALL THAT FOLLOWS GOES IN FREESPACE ;;
;;				      ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

org $128000

db $53,$54,$41,$52		;\
dw $7FF7			; | Claim this bank
dw $8008			;/





;==============;
;SET DIFFICULTY;
;==============;

	SET_DIFFICULTY:

		PHX
		LDA $610A
		XBA
		LDA #$00
		REP #$10
		TAX
		LDA !FreeSRAM,x
		SEP #$10
		CMP #$01
		BNE .Clear
		PLX
		BRA .Copy

.Clear		PLX
		TXA					;\ Store difficulty to RAM_buffer
		STA $404001				;/
		STZ $6DB2				; Force "1 PLAYER GAME"
		LDX #$FD				;\
		LDA #$00				; |
.LoopC		STA $404002,x				; | Clear extra RAM buffer
		DEX					; |
		BPL .LoopC				;/

.Copy		LDX #$5F				;\
.Loop		LDA $7F49,x				; |
		AND.b #$40^$FF				; |
		STA !LevelTable,x			; | Copy SMW's RAM buffer to RAM
		DEX : BPL .Loop				; |
		LDX #$2C				; |
.Loop2		LDA $7F49+$60,x : STA !LevelTable+$60,x	; |
		DEX : BPL .Loop2			;/

		JML $009E13				; Return to original code

;================;
;CUSTOM MENU CODE;
;================;

	CUSTOM_MENU:

		LDA !GameMode
		CMP #$0E : BNE .Menu
		JMP .Overworld

		.Menu
		LDA $610A				; Load save file number
		XBA
		LDA #$00
		REP #$10				; Index 16 bit
		TAX					; X = start of SRAM index
		LDA !FreeSRAM,x
		CMP #$01
		BEQ .UpdateStripe
		JMP .CleanFile				; Don't update stripe if selecting a clean file

.UpdateStripe	PHB					;\
		PHK					; | Bank wrapper
		PLB					;/

		LDX #!CustomSize			;\
.LoopC		LDA CustomStripe,x			; | Upload custom stripe image table to RAM
		STA !FreeBNK*$10000+!FreeRAM,x		; |
		DEX					; |
		BPL .LoopC				;/

		LDA $610A				;\
		BEQ .Data1				; |
		DEC A					; |
		BEQ .Data2				; |
.Data3		LDA #$4E				; | Update file number graphic
		STA !FreeBNK*$10000+!FreeRAM+$26	; |
		LDA #$30				; |
		STA !FreeBNK*$10000+!FreeRAM+$27	; |
		BRA .Data1				; |
.Data2		LDA #$6E				; |
		STA !FreeBNK*$10000+!FreeRAM+$26	;/

.Data1		LDA $610A				;\
		XBA					; |
		LDA #$00				; |
		REP #$10				; |
		TAX					; |
		LDA !FreeSRAM+$01,x			; |
		SEP #$10				; |
		AND #$03				; | Update difficulty graphic
		BEQ .EASY				; |
		DEC A					; |
		BEQ .NORMAL				; |
.INSANE		LDX #$0F				; |
.LoopI		LDA Custom_INSANE,x			; |
		STA !FreeBNK*$10000+!FreeRAM+$28,x	; |
		DEX					; |
		BPL .LoopI				; |
		BRA .EASY				; |
.NORMAL		LDX #$0F				; |
.LoopN		LDA Custom_NORMAL,x			; |
		STA !FreeBNK*$10000+!FreeRAM+$28,x	; |
		DEX					; |
		BPL .LoopN				;/

.EASY		LDA $610A
		SEP #$10
		TAX
		LDA $009CCB,x
		XBA
		LDA $009CCE,x
		REP #$10
		TAX					; X = SMW SRAM index
		LDA $41C08C,x				; Load number of exits found
		SEP #$10

		LDX #$00				;\
.HexToDec8a	CMP #$0A				; |
		BCC .WriteExits				; | Convert to Dec (8 bit)
		SBC #$0A				; |
		INX					; |
		BRA .HexToDec8a				;/

.WriteExits	PHA					; Preserve 1s digit
		TXA					;\
		AND #$0F				; |
		BEQ .Digit1				; | Update number of exits found, shown on screen
		STA !FreeBNK*$10000+!FreeRAM+$44	; |
.Digit1		PLA					; |
		STA !FreeBNK*$10000+!FreeRAM+$46	;/

		LDA $610A				;\ Get save file number in hi byte
		XBA					;/
		LDA #$05				; Get Yoshi Coin address in lo byte
		REP #$10
		TAX
		LDA !FreeSRAM+$01,x			;\
		XBA					; | Load number of Yoshi Coins collected
		LDA !FreeSRAM+$00,x			; |
		REP #$20				;/

		LDX #$0000				;\
.HexToDec16	CMP #$000A				; |
		BCC .WriteYC1				; | Convert to Dec (16 bit)
		SBC #$000A				; |
		INX					; |
		BRA .HexToDec16				;/

.WriteYC1	SEP #$30				; A and index 8 bit
		STA !FreeBNK*$10000+!FreeRAM+$56	; Write 1s digit of Yoshi Coin

		TXA					;\
		LDX #$00				; |
.HexToDec8b	CMP #$0A				; |
		BCC .WriteYC2				; | Convert to Dec (8 bit)
		SBC #$0A				; |
		INX					; |
		BRA .HexToDec8b				;/

.WriteYC2	PHX					;\
		TAX					; | Swap A and X, so that A = 100s, X = 10s
		PLA					;/
		BEQ .WriteYC3
		STA !FreeBNK*$10000+!FreeRAM+$52	; Write 100s digit of Yoshi Coin
.WriteYC3	TXA
		BEQ .CoinHoard
		STA !FreeBNK*$10000+!FreeRAM+$54	; Write 10s digit of Yoshi Coin

.CoinHoard	LDA.l $00610A : XBA
		LDA #!FreeBNK				;\ Switch to bank 0x40
		PHA : PLB				;/
		LDA #$00
		REP #$30
		TAX
		PHY
		PHP

		PEI ($00)				;\ Back these up since I don't know if they're important
		PEI ($02)				;/

		LDA.l !FreeSRAM+$93,x			;\
		STA $00					; |
		LDA.l !FreeSRAM+$95,x			; | Store hoard as a 32-bit number in $00-$03
		AND #$00FF				; |
		STA $02					;/
		SEP #$10				; > Index 8 bit

		LDY #$00				; > Base number in 100000 slot
	-	CMP #$0001 : BNE +			;\
		LDA $00					; |
		CMP #$86A0				; |
	+	BCC .100000done				; |
		SBC #$86A0				; | 32-bit math to count 100000s
		STA $00					; |
		LDA $02					; |
		SBC #$0001				; |
		STA $02					;/
		INY					;\ Add 100000 and loop
		BRA -					;/

		.100000done
		STY.w !FreeRAM+$5C			; > Store 100000 digit
		LDA $00					;\
		LDY #$00				; | Count 10000s
	-	CMP #$2710 : BCC .10000done		; |
		SBC #$2710				;/
		INY					;\ Add 10000 and loop
		BRA -					;/

		.10000done
		STY.w !FreeRAM+$5E			; > Store 10000 digit
		JSL Thousands				; > Calculate 1000s and 100s
		SEP #$20				; > A 8 bit
		STY.w !FreeRAM+$60			; > Store 1000 digit
		STX.w !FreeRAM+$62			; > Store 100 digit
		JSL HexToDec				; > Calculate last two digits
		STX.w !FreeRAM+$64			; > Store 10 digit
		STA.w !FreeRAM+$66			; > Store 1 digit
		REP #$20				;\
		PLA : STA $02				; | Restore these probably useless numbers
		PLA : STA $00				;/
		PLP					; > Restore processor
		PLY					; > Restore Y
		SEP #$20				; > A 8 bit


.Return		PLB					; Restore bank
		SEP #$10				; Index 8 bit
.Overworld	STY $12					; Load difficulty select stripe
		LDX #$00				; Overwritten code
		RTL

.CleanFile	LDX #!DifficultySize			;\
.Loop		LDA Difficulty,x			; |
		STA !FreeBNK*$10000+!FreeRAM,x		; | Upload stripe image table to RAM
		DEX					; |
		BPL .Loop				;/

		SEP #$10				; Index 8 bit
		STY $12					; Load difficulty select stripe
		LDX #$00				; Overwritten code
		RTL

CustomStripe:

		db $51,$E5,$40,$2F			; RLE header (24 tiles)
		db $FC,$38				; empty space

		db $52,$25,$40,$2F			; RLE header (24 tiles)
		db $FC,$38				; empty space

		db $52,$65,$40,$2F			; RLE header (24 tiles)
		db $FC,$38				; empty space

		db $52,$A6,$40,$1C			; RLE header (14 tiles)
		db $FC,$38				; empty space

		; Clear the "DATA 1", "DATA 2", "DATA 3", "ERASE DATA" and arrow graphics from the screen.

		db $51,$EC,$00,$0B			; Stripe image header (6 tiles)
		db $7C,$30				; D
		db $71,$31				; A
		db $2F,$31				; T
		db $71,$31				; A
		db $FC,$38				; empty space
		db $6D,$31				; 1		; Possibly overwritten by selected file number

		db $52,$2C,$00,$0B			; Stripe image header (6 tiles)
		db $73,$31				; E		;\
		db $71,$31				; A		; |
		db $31,$31				; S		; | Possibly overwritten by selected difficulty
		db $72,$31				; Y		; |
		db $FC,$38				; empty space	; |
		db $FC,$38				; empty space	;/

		db $52,$6C,$00,$0B			; Stripe image header (6 tiles)
		db $87,$38				; star
		db $FC,$38				; empty space
		db $FC,$38				; empty space
		db $FC,$38				; empty space
		db $FC,$38				; empty space	;\ Overwritten by number of exits found
		db $FC,$38				; empty space	;/

		db $52,$8C,$00,$0B			; Stripe image header (6 tiles)
		db $2E,$38				; coin
		db $FC,$38				; empty space
		db $FC,$38				; empty space
		db $FC,$38				; empty space	;\
		db $FC,$38				; empty space	; | Overwritten by number of Yoshi Coins found
		db $FC,$38				; empty space	;/

		db $52,$AC,$00,$0B			; Stripe image header (6 tiles)
		db $FC,$38				; empty space	;\
		db $FC,$38				; empty space	; |
		db $FC,$38				; empty space	; | Overwritten by coin hoard
		db $FC,$38				; empty space	; |
		db $FC,$38				; empty space	; |
		db $FC,$38				; empty space	;/

		db $FF					; End DMA read

CustomStripeEnd:

Custom_NORMAL:

		db $52,$2C,$00,$0B			; Stripe image header (6 tiles)
		db $30,$31				; N
		db $7A,$30				; O
		db $74,$31				; R
		db $76,$31				; M
		db $71,$31				; A
		db $70,$31				; L

Custom_INSANE:

		db $52,$2C,$00,$0B			; Stripe image header (6 tiles)
		db $82,$30				; I
		db $30,$31				; N
		db $31,$31				; S
		db $71,$31				; A
		db $30,$31				; N
		db $73,$31				; E


;===========;
;CUSTOM SRAM;
;===========;
; --Free SRAM Map--
;
; It's divided into 3 identical blocks.
; File 1 uses $41C400-$41C4FF.
; File 2 uses $41C500-$41C5FF.
; File 3 uses $41C600-$41C6FF.
; X = File number + 0x03
; This stuff is also mirrored in $404000.
;
; $41CX00:	1 byte		Save file header. 0x01 = used slot, 0x00 = free slot.
; $41CX01:	1 byte		Difficulty setting flags. Format: ihscn-dd.
;				i is Iron Man Mode. While enabled it kills both players if one of them dies.
;				h is Hardcore Mode. While enabled it triggers game over after every death.
;				s is Super Enemy Mode. While enabled it causes the players to die in one hit.
;				c is Crisis Mode. While enabled it drastically reduces the time limit.
;				n is Nightmare Mode. While enabled the entire campaign is altered.
;				dd is difficulty setting. 0x00 is EASY, 0x01 is NORMAL, 0x02 is INSANE.
; $41CX02:	1 byte		Amount of lives (why was this not in SMW?). I should set the maximum to something low.
; $41CX03:	1 byte		Player 1 power-up. Lo nybble is current powerup, hi nybble is reserve powerup.
; $41CX04:	1 byte		Player 2 power-up.
; $41CX05:	2 bytes		Number of Yoshi Coins, 16 bit.
; $41CX07:	2 bytes		Player 1 death counter, 16 bit.
; $41CX09:	2 bytes		Player 2 death counter, 16 bit.
; $41CX0B:	96 bytes	Yoshi Coins collected table. Indexed by translevel number.
;				Each byte uses 5 bits, one for each Yoshi Coin. If it's set, the coin won't spawn.
; $41CX6B:	32 bytes	Bestiary. Whenever you see a new type of enemy it's saved here.
;				Each enemy uses one bit. If you've seen an enemy its bit is set, otherwise, it's clear.
;				When you've seen an enemy you can get info on it from a Yoshi at YOSHI'S HIDEOUT.
; $41CX8B:	1 byte		Characters in play.
; $41CX8C:	16 bytes	Dialogue and cutscene progression.
; $41CX9C:


	INIT:
		LDA !Permanent+$0			;\
		CMP #$49 : BNE .INIT			; |
		LDA !Permanent+$1			; |
		CMP #$4E : BNE .INIT			; | Check if game is initialized
		LDA !Permanent+$2			; |
		CMP #$49 : BNE .INIT			; |
		LDA !Permanent+$3			; |
		CMP #$54 : BEQ .Return			;/

		.INIT
		PHP					;\
		REP #$30				; |
		LDA #$0000				; |
		LDX #$02FE				; | Completely wipe extra SRAM
	-	STA !FreeSRAM,x				; |
		DEX #2					; |
		BPL -					; |
		LDX #$00FE				; |
	-	STA !FreeBNK*$10000+!RAM_buffer,x	; |
		DEX #2					; |
		BPL -					; |
		PLP					;/
		LDA #$49 : STA !Permanent+$0		;\
		LDA #$4E : STA !Permanent+$1		; | Mark game as initialized
		LDA #$49 : STA !Permanent+$2		; |
		LDA #$54 : STA !Permanent+$3		;/


		.Return
		DEC $7DF5 : BNE .00941A			;\
.009414		JML $009414				; | Overwritten code
.00941A		JML $00941A				;/


	SAVE:
		LDA $610A
		XBA
		LDA #$FF
		REP #$10			; Index 16 bit
		TAX				; X = FreeSRAM index
		LDY #$00FF			; Y = RAM_buffer index

		LDA #!FreeBNK
		PHA
		PLB				; Set bank to 7F so I can use Y for indexing

	; Some extra stuff

		LDA $006DBE			;\ Save number of lives
		STA !RAM_buffer+$02		;/
		LDA $19				;\
		STA $00				; |
		LDA $006DC2			; | Save player 1 powerup and item box content
		ASL #4				; |
		ORA $00				; |
		STA !RAM_buffer+$03		;/
		LDA $006D9C			;\ Save player 2 powerup
		STA !RAM_buffer+$04		;/

	.Loop	LDA !RAM_buffer,y
		STA !FreeSRAM,x
		DEX
		DEY
		BPL .Loop			; Loop until the entire table is copied

		SEP #$10			; Index 8 bit
		PLB : LDX $610A			; Overwritten code
		JML $009BCF			; Execute regular save game routine

	LOAD:

		PHB				;\
		LDA #!FreeBNK			; | Bank wrapper
		PHA				; |
		PLB				;/

		LDA $00610A
		XBA
		LDA #$00
		TAX				; X = index to start of FreeSRAM
		LDA !FreeSRAM,x
		CMP #$01 : BNE .Clear

		LDA #$FF
		TAX				; X = FreeSRAM index
		LDY #$00FF			; Y = RAM_buffer index
	.Loop	LDA !FreeSRAM,x
		STA !RAM_buffer,y
		DEX
		DEY
		BPL .Loop			; Loop until entire save file is copied

		LDA #$01
		STA !RAM_buffer			; Set save file header in buffer
		PLB				; Restore bank

		LDY #$008C			;\
	-	LDA $7F49,y			; |
		AND.b #$40^$FF			; | load level data without checkpoints from SRAM buffer
		STA !LevelTable,y		; |
		DEY : BPL -			;/


		SEP #$10			; Index 8 bit
		LDY #$12			; Overwritten code, loads the 1/2 player select stripe
		RTL

	.Clear	LDX #$00FC
		LDY #$00FC			;\
		REP #$20			; |
		LDA #$0000			; |
	.LoopC	STA !FreeSRAM+$02,x		; |
		STA !RAM_buffer+$02,y		; | Clear RAM buffer and SRAM slot
		DEX				; |
		DEX				; |
		DEY				; |
		DEY				; |
		BPL .LoopC			;/
		SEP #$30			; > All registers 8 bit
		LDA #$01			;\ Set save file header in buffer
		STA !RAM_buffer			;/

		JSL $05DD80			; load initial level data

		LDY #$12			; Overwritten code, loads the 1/2 player select stripe
		PLB				; Restore bank
		RTL

	ERASE:

		CPX #$03
		BNE .Return
		PHX				; Preserve X
		LDA $6DDE			;\ Preserve SMW files to delete
		PHA				;/

		LDY #$02
	.LoopY	LSR $6DDE
		BCC .DecY

		PHY				; Preserve loop count
		TYA
		XBA
		LDA #$FF
		TAY				; Y = amount of bytes to erase
		REP #$10			; Index 16 bit
		TAX				; X = SRAM index for file to be deleted
		LDA #$00
	.LoopX	STA !FreeSRAM,x			;\
		DEX				; | Clear extra data
		DEY				; |
		BPL .LoopX			;/
		SEP #$10			; Index 8 bit
		PLY				; Restore loop count

	.DecY	DEY
		BPL .LoopY

		PLA				;\ Restore SMW files to delete
		STA $6DDE			;/
		PLX				; Restore X
		JML $009B41			; Erase data
	.Return	JML $009B6D			; Update cursor position

;===================;
;MENU CURSOR ROUTINE;
;===================;

	CURSOR_GFX:

		PHX				; Preserve X
		LDA !GameMode			;\
		CMP #$0A			; |
		BNE .Return			; |
		LDA $610A			; |
		XBA				; | Return if starting an empty file (Game Mode 0A, no file header)
		LDA #$00			; |
		REP #$10			; |
		TAX				; |
		LDA !FreeSRAM,x			; |
		SEP #$10			; |
		CMP #$01			; |
		BNE .Return			;/

		LDA #$18			;\ Make cursor invisible
		STA $7B91			;/

.Return		PLX				; Restore X
		PLA : PLA : LDA $16		; Overwritten code
		JML $009AEE			; Execute the rest of the code

	CURSOR_SFX:

		PHA				; Preserve A
		PHX				; Preserve X
		LDA !GameMode			;\
		CMP #$0A			; |
		BNE .Return			; |
		LDA $610A			; |
		XBA				; | Return unless starting an empty file (Game Mode 0A, no file header)
		LDA #$00			; |
		REP #$10			; |
		TAX				; |
		LDA !FreeSRAM,x			; |
		SEP #$10			; |
		CMP #$01			; |
		BNE .Return			;/

		PLX				; Restore X
		PLA				; Restore A
		JML $009B01			; Execute the rest of the code without playing the SFX

.Return		LDY #$06 : STY !SPC4		; Overwritten code
		PLX				; Restore X
		PLA				; Restore A
		JML $009AFE			; Execute the rest of the code


;==================;
;YOSHI COIN ROUTINE;
;==================;

	YOSHI_COIN:

		PHX
		PHA				; Preserve A
		LDA $404005			; Load lo byte of number of Yoshi Coins collected
		INC A				; Increment
		STA $404005			; Store back
		BNE .Return			;\
		LDA $404006			; | Handle overflow
		INC A				; |
		STA $404006			;/

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

;==================;
;FIX OFFSET ROUTINE;
;==================;

	FIX_OFFSET:

		LDA !GameMode			; Check game mode
		CMP #$09			; Check if erase file
		BNE +				; Branch if not equal (which means it's file select)

; I would do CMP #$08 : BEQ +, but it seems the stripe image is not updated during game mode 8.

		LDA $00				;\
		SEC				; | Original code
		SBC #$24			;/
		RTL

	+	LDA $00				;\
		SEC				; | Fix offset bug
		SBC #$22			;/
		RTL

.Base		LDA !GameMode			; Check game mode
		CMP #$09			; Check if erase file
		BNE +				; Branch if not equal (which means it's file select)

		LDA #$7E			;\ Original code
		STA $00				;/
		RTL

	+	LDA #$80			;\ Fix offset bug
		STA $00				;/
		RTL


ExtraGFX29:	;incbin "GFX29.bin"		; Some extra GFX for the status bar
ItemGFX:	db $02,$10,$11,$02,$12		; What tile to use for what powerup



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