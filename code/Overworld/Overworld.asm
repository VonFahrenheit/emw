
print "OVERWORLD INSERTED AT $", pc, "!"

	namespace Overworld



; For game mode 0C (the OW loader)
;	3 bytes inserted at $00A0B3 by AMK
;	4 bytes inserted at $00A140 by Lunar Magic
;	4 bytes inserted at $00A149 by unknown source, probably Lunar Magic
;	4 bytes inserted at $00A153 by Lunar Magic
;	5 bytes inserted at $00A1A8 by unknown source, probably SA-1 patch or Lunar Magic





	pushpc
	org $008779
		NOP #3			; org: STA $420B (prevent layer 3 garbage)
	org $0087A7
		NOP #3			; org: STA $420B

	org $03BB20
		RTL			; org: STA $02
		NOP			; This messes with LM, so I'd better be careful

	org $05DBF2
		RTL			; org: PHB (prevent lives from showing on OW)


	org $05DDA0	; All levels start clear of initial flags
		db $01,$01,$01,$01,$01,$01,$01,$01	; 00-07
		db $01,$01,$01,$01,$01,$01,$01,$01	; 08-0F
		db $01,$01,$01,$01,$01,$01,$01,$01	; 10-17
		db $01,$01,$01,$01,$01,$01,$01,$01	; 18-1F
		db $01,$01,$01,$01,$01,$01,$01,$01	; 20-27
		db $01,$01,$01,$01,$01,$01,$01,$01	; 28-2F
		db $01,$01,$01,$01,$01,$01,$01,$01	; 30-37
		db $01,$01,$01,$01,$01,$01,$01,$01	; 38-3F
		db $01,$01,$01,$01,$01,$01,$01,$01	; 40-47
		db $01,$01,$01,$01,$01,$01,$01,$01	; 48-4F
		db $01,$01,$01,$01,$01,$01,$01,$01	; 50-57
		db $01,$01,$01,$01,$01,$01,$01,$01	; 58-5F

	pullpc


	; insert new code here
	incsrc "Data/LevelList.asm"
	incsrc "Data/MapLightPoints.asm"
	incsrc "Data/Events.asm"

	incsrc "Zip.asm"
	incsrc "RenderHUD.asm"
	incsrc "RenderName.asm"
	incsrc "RenderCircle.asm"
	incsrc "Load.asm"
	incsrc "Player.asm"
	incsrc "CharMenu.asm"
	incsrc "OverworldSprites.asm"
	incsrc "Lighting.asm"
	incsrc "Sort_OAM.asm"




; VRAM map:
; 0x0000 / $0000	16 KiB BG1 GFX		256 8bpp characters (128x128 px)
; 0x4000 / $2000	16 KiB BG2 GFX		512 4bpp characters (128x256 px)
; 0x8000 / $4000	4 KiB BG1 tilemap	2 tilemaps, 64x32 tiles
; 0x9000 / $4800	4 KiB BG2 tilemap	2 tilemaps, 64x32 tiles, main part
; 0xA000 / $5000	2 KiB BG2 tilemap	1 tilemap, 32x32 tiles, HUD part
; 0xA800 / $5400	6 KiB tilemap cache	total 3 tilemaps
; 0xC000 / $6000	16 KiB sprite GFX	512 4bpp characters (128x512 px)



; HDMA:
; channel 0 - used for DMA during NMI
; channel 1 - FREE
; channel 2 - window
; channel 3 - main screen
; channel 4 - BG2 tilemap
; channel 5 - BG2 coordinates
; channel 6 - circle window
; channel 7 - FREE


; $0200
;	+0	main screen
;	+10	BG2 tilemap
;	+20	BG2 coordinates
;	+80	double buffer mirrors



	MAIN:
		INC $14

		; overworld RNG: no need to use full algorithm here
		LDA $14						;\
		AND #$1F					; |
		TAY						; | index RNG table
		DEC A						; |
		AND #$1F					; |
		TAX						;/
		LDA !RNGtable,x : STA !RNG_Seed3		; update seed 3
		BIT #$01 : BEQ +				;\
		ASL A : ADC !RNG_Seed3				; | apply 3N+1 on previous RN
		STA !RNG_Seed3 : BRA ++				; |
	+	LSR !RNG_Seed3					;/
	++	ADC $13						; add true frame counter
		ADC $15						;\
		ADC $16						; | add player 1 controller inputs
		ADC $17						; |
		ADC $18						;/
		ADC !P1MapXSpeed				;\ add player 1 speed
		ADC !P1MapYSpeed				;/
		ADC !P1MapX					;\ add player 1 position
		ADC !P1MapY					;/
		STA !RNGtable,y					; store new RN
		STA !RNG					; most recently generated


		REP #$20					;\
		LDA #$2C04 : STA $4330				; |
		LDA #$0800 : STA $4340				; |
		LDA #$0F03 : STA $4350				; |
		SEP #$20					; | set up HDMA
		STZ $4334					; |
		STZ $4344					; |
		STZ $4354					; |
		LDA #$78 : STA !HDMA				;/

		LDA #$33 : STA !2123
		LDA #$33 : STA !2125


		LDA #$40 : STA !AnimToggle


		LDA.b #.SA1 : STA $3180
		LDA.b #.SA1>>8 : STA $3181
		LDA.b #.SA1>>16 : STA $3182
		LDA !GameMode
		CMP #$0E : BEQ .Light
		JSR $1E80
		BRA .Shared

		.Light
		LDA #$80 : STA $2200
		JSR !MPU_light

		.Shared
		REP #$30
		LDA !CircleTimer
		AND #$0001
		BEQ $03 : LDA #$0080
		TAX
		SEP #$20

; $0200 -> adjust scanline (MainScreen + SubScreen)
; $0210 -> adjust scanline (BG2 Tilemap address)
; $0220 -> expand (BG2 coordinates)

		LDA !CharMenuTimer : STA $00
		LDA !CharMenu : BEQ ..20
		CMP #$01 : BEQ ..dynamic
		CMP #$05 : BNE ..40
		..inversedynamic
		LDA #$20
		SEC : SBC $00
		STA $00

		..dynamic
		LDA #$40
		SEC : SBC $00
		STA $0200,x
		STA $0210,x
		SBC #$20
		STA $0225,x
		LDA #$20 : STA $0220,x
		LDA #$01 : STA $022A,x
		STZ $022F,x
		REP #$20
		STZ $0226,x
		LDA $00
		AND #$00FF
		DEC A
		STA $0228,x
		LDA $1E : STA $022B,x				;\ map part of BG2
		LDA $20 : STA $022D,x				;/
		BRA ..updatemirrors

		..40						;\
		LDA #$40					; |
		STA $0200,x					; | all initial scanline counts 0x40
		STA $0210,x					; |
		STA $0220,x					;/
		BRA ..setmain
		..20						;\
		LDA #$20					; |
		STA $0200,x					; | all initial scanline counts 0x20
		STA $0210,x					; |
		STA $0220,x					;/
		..setmain					;\ set scanline count for BG2 coords (map part of screen)
		LDA #$01 : STA $0225,x				;/
		STZ $022A,x					; end BG2 coords table
		REP #$20					;\
		LDA $1E : STA $0226,x				; | make sure map part has the correct BG2 coords
		LDA $20 : STA $0228,x				;/

		..updatemirrors
		TXA
		ORA #$0200
		STA !HDMA3source
		CLC : ADC #$0010
		STA !HDMA4source
		CLC : ADC #$0010
		STA !HDMA5source

		SEP #$30					; all regs 8-bit

		JSL BuildOAM
		RTL


		.SA1
		PHB						;\ wrapper start
		PHP						;/

		STZ !RAMcode_offset
		STZ !RAMcode_offset+1
		STZ !RAMcode_flag
		STZ !RAMcode_flag+1
		STZ !MapOAMindex
		STZ !MapOAMindex+1
		STZ !MapOAMcount
		STZ !MapOAMcount+1



; light intensity = L / d ^ 2
; L = light constant
; d = distance to camera center

; for each light source point, multiply its RGB values with light intensity for that point
; then add all RGB values together and set light values to that
; (make sure to exclude the HUD)


		JSR KillVR3

		JSL HandleZips

		PHK : PLB				; get bank
		SEP #$20
		LDA !WarpPipe : BEQ .RenderName
		REP #$30
		%LoadHUD(SelectPressed)
		JSR RenderHUD
		SEP #$30
		BRA .UpdateHUD

		.RenderName
		JSR RenderName

		.UpdateHUD
		LDA !MapUpdateHUD+0
		ORA !MapUpdateHUD+1
		ORA !MapUpdateHUD+2
		ORA !MapUpdateHUD+3 : BEQ +
		JSR ReloadP1Color
		JSR ReloadP2Color
		+
		%UpdateHUD(0)
		%UpdateHUD(1)
		%UpdateHUD(2)
		%UpdateHUD(3)
		REP #$30




		JSR CalcLightPoints


	; draw coin hoard counter on HUD
		.DrawCoinHoardCounter
		LDA #$0314 : STA $00
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
		TXA : JSR DrawCoinDigit					; |
		LDY $0C							; |
		..skipfirst						;/
		LDA $00							;\
		CLC : ADC #$0005					; | X+5
		STA $00							;/

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
		TXA : JSR DrawCoinDigit					; |
		..skipsecond						;/
		LDA $00							;\
		CLC : ADC #$0005					; | X+5
		STA $00							;/

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
		TXA : JSR DrawCoinDigit					; |
		..skipthird						;/
		LDA $00							;\
		CLC : ADC #$0005					; | X+5
		STA $00							;/

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
		TXA : JSR DrawCoinDigit					; |
		..skipfourth						;/
		LDA $00							;\
		CLC : ADC #$0005					; | X+5
		STA $00							;/

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
		TXA : JSR DrawCoinDigit					; |
		..skipfifth						;/
		LDA $00							;\
		CLC : ADC #$0005					; | X+5
		STA $00							;/
		LDA $0A : JSR DrawCoinDigit				; draw 1s digit


	; draw yoshi coin counter on HUD
		.DrawYoshiCoinCounter
		LDA #$101E : STA $00					;\ setup
		LDA !YoshiCoinCount : STA $0A				;/
		STZ $0E
		LDX #$0000						;\
		CMP #$03E8 : BCC ..skipfirst				; |
	-	CMP #$03E8 : BCC ..draw1000s				; |
		SBC #$03E8						; |
		INX : BRA -						; | 1000s
		..draw1000s						; |
		STA $0A							; |
		TXA : JSR DrawCoinDigit					; |
		..skipfirst						;/
		LDA $00							;\
		CLC : ADC #$0005					; | X+5
		STA $00							;/
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
		TXA : JSR DrawCoinDigit					; |
		..skipsecond						;/
		LDA $00							;\
		CLC : ADC #$0005					; | X+5
		STA $00							;/
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
		TXA : JSR DrawCoinDigit					; |
		..skipthird						;/
		LDA $00							;\
		CLC : ADC #$0005					; | X+5
		STA $00							;/
		LDA $0A : JSR DrawCoinDigit				; 1s


	.Objects
		LDA !CharMenu
		AND #$00FF : BNE ..done

		..cameraspeed
		LDA !MapEvent : BEQ ..speed4
		..speed2
		LDA #$0002
		STA !MapCameraSpeedX
		STA !MapCameraSpeedY
		BRA +
		..speed4
		LDA #$0004
		STA !MapCameraSpeedX
		STA !MapCameraSpeedY
		+

		LDA !WarpPipe						;\
		AND #$00FF : BEQ ..nowarppipe				; |
		JSR Player						; | players are processed first when a warp pipe is on-screen
		JSR OverworldSprites					; |
		BRA ..drawstuff						;/

		..nowarppipe						;\
		JSR OverworldSprites					; | otherwise, sprites first to let them control the camera during events
		JSR Player						;/
		..drawstuff
		PHP
		SEP #$20
		STZ !P1MapGhost
		STZ !P2MapGhost
		STZ !MapLockCamera		; KEEP THIS ONE WHEN YOU REMOVE GHOST ZONES
		PLP
		JSR DrawSprites			; separate call to let sprites control the camera
		JSR Sort_OAM
		..done


	.Circle
		JSL RenderCircle
		JSL RenderCircle_Cutscene


		SEP #$10				;\ regs: A 16-bit, index 8-bit
		REP #$20				;/

		LDA $14
		AND #$0003 : BNE +
		INC !MapBG2X				; scroll BG2
		+

		LDA $1A					;\
		CLC : ADC !MapBG2X			; |
		STA $1E					; | layer 2 positions
		LDA $1C					; |
		CLC : ADC !MapBG2Y			; |
		STA $20					;/

		SEP #$20				; 8-bit A

		LDA #$00 : STA !DizzyEffect		; cancel dizzy
		LDA #$08 : TRB !2105
	;	LDA #$1D : STA !MainScreen
	;	STZ !SubScreen

		LDX #$7F
		LDA #$00
	-	STA $400000+!MsgRAM,x
		DEX : BPL -

		LDA !GameMode				;\
		CMP #$0E : BEQ +			; |
		STZ $15					; |
		STZ $16					; |
		STZ $17					; |
		STZ $18					; |
		STZ $6DA2				; | only accept input in game mode 0E
		STZ $6DA3				; |
		STZ $6DA4				; |
		STZ $6DA5				; |
		STZ $6DA6				; |
		STZ $6DA7				; |
		STZ $6DA8				; |
		STZ $6DA9				; |
		+					;/





	Controls:
		LDA !CharMenu : BEQ .NoCharMenu
		JMP CharMenu
		.NoCharMenu

		LDA !WarpPipe : BEQ $03 : JMP .Return
		LDX !Translevel : BNE .Level
		LDA #$14
		STA !MapCheckpointX
		STA !MapCheckpointTargetX
		BRA .CheckPipe


	; X = translevel num / index
		.Level
		LDA !MapCheckpointX
		CMP !MapCheckpointTargetX
		BEQ ..same
		BCS ..dec
	..inc	CLC : ADC #$04
	..dec	DEC #2
		STA !MapCheckpointX
		..same


		LDA $6DA8
		AND #$30 : BEQ ..noLR
		LDA !MapCheckpointTargetX : BNE ..0
		LDA #$14 : STA !MapCheckpointTargetX
		BRA ..noLR
	..0	STZ !MapCheckpointTargetX
		..noLR

		LDA $6DA6 : BPL .CheckPipe
		BRA .LoadLevel

		.CheckPipe
		LDA $6DA6
		AND #$20 : BNE ..openpipe
		JMP .P1OpenMenu
		..openpipe
		LDA #$03 : STA !SPC4
		REP #$10
		JSR GetSpriteIndex
		JSR ResetSprite
		LDA #$01 : STA !OW_sprite_Num,x
		SEP #$10
		LDA #$30 : STA !P1MapZSpeed
		LDA #$38 : STA !P2MapZSpeed
		LDA !P2MapX : STA !WarpPipeP2X
		LDA !P2MapX+1 : STA !WarpPipeP2X+1
		LDA !P2MapY : STA !WarpPipeP2Y
		LDA !P2MapY+1 : STA !WarpPipeP2Y+1
		STZ !WarpPipeTimer
		BRA .P1OpenMenu

	; X still has to be translevel num here
		.LoadLevel
		LDA #$15 : STA !GameMode
		LDA #$02 : STA !SPC1
		LDA #$80 : STA !SPC3
		REP #$20
		LDA !P1MapX : STA !SRAM_overworldX
		LDA !P1MapY : STA !SRAM_overworldY
		SEP #$20
		BIT !LevelTable1,x : BVC ..nocheckpoint
		LDA !MapCheckpointTargetX : BEQ ..nocheckpoint
		..checkpoint
		LDA #$01 : BRA ..w
		..nocheckpoint
	;	LDA !LevelTable1,x
	;	AND.b #$40^$FF : STA !LevelTable1,x
		LDA #$00
	..w	STA !LoadCheckpoint
		STA $73CE

		JSL !SaveGame

		.Return
		PLP
		PLB
		RTL

		.P1OpenMenu
		LDA $6DA6
		AND #$10 : BEQ ..done
		LDA !CharMenu : BNE ..done
		INC !CharMenu
		LDX #$00 : BRA .OpenMenu
		..done

		.P2OpenMenu
		LDA $6DA7
		AND #$10 : BEQ ..done
		LDA !CharMenu : BNE ..done
		INC !CharMenu
		LDX.b #(!P2MapX)-(!P1MapX) : BRA .OpenMenu
		..done

		PLP
		PLB
		RTL


		.OpenMenu
		STX !SelectingPlayer
		LDA !P1MapX,x
		SEC : SBC $1A
		STA !CharMenuCurrentPlayerX
		LDA !P1MapY,x
		SEC : SBC $1C
		STA !CharMenuCurrentPlayerY
		TXA
		EOR.b #(!P2MapX)-(!P1MapX)
		TAY
		LDA !P1MapX,y
		SEC : SBC $1A
		STA !CharMenuOtherPlayerX
		LDA !P1MapY,y
		SEC : SBC $1C
		STA !CharMenuOtherPlayerY
		LDA !P1MapDirection,y
		AND #$01
		BEQ $02 : LDA #$40
		STA !CharMenuOtherPlayerP
		LDA !P1MapChar,x : STA !CharMenuCursor
		JSR ReloadStartButtons
		JSR InitCharMenu
		PLP
		PLB
		RTL




	RemoveP2:
		PHP
		SEP #$20
		LDA #$00 : STA !MultiPlayer
		REP #$30
		%LoadHUD(NameP2)
		JSR ResetHUD
		%LoadHUD(PortraitP2)
		JSR ResetHUD
		%LoadHUD(SwitchP2)
		JSR ResetHUD
		%LoadHUD(JoinP2)
		JSR RenderHUD
		PHB
		SEP #$10
		LDY.b #!VRAMbank
		PHY : PLB
		JSL GetCGRAM
		LDA #$0002 : STA !CGRAMtable+$00,y
		LDA.w #Palette+($79*2) : STA !CGRAMtable+$02,y
		LDA.w #Palette>>16 : STA !CGRAMtable+$04,y
		SEP #$20
		LDA #$79 : STA !CGRAMtable+$05,y
		PLB
		PLP
		RTS

	AddP2:
		PHP
		SEP #$20
		LDA #$01 : STA !MultiPlayer
		REP #$30
		%LoadHUD(NameP2)
		LDA !Characters
		AND #$000F
		ASL A
		TAX
		LDA NameOffset,x : STA $00
		JSR RenderP2Name
		%LoadHUD(PortraitP2)
		LDA !Characters
		AND #$000F
		ASL #3
		ADC $00
		STA $00
		JSR RenderHUD
		%LoadHUD(SwitchP2)
		JSR RenderHUD
		JSR ReloadP2Color
		PLP
		RTS

	ReloadStartButtons:
		PHP
		REP #$20
		SEP #$10
		.P1
		%LoadHUD(StartSolidP1)
		LDX !CharMenu
		CPX #$01 : BNE ..load
		LDX !SelectingPlayer : BNE ..load
		LDA $00
		CLC : ADC #$000C
		STA $00
		..load
		JSR RenderHUD
		.P2
		%LoadHUD(StartSolidP2)
		LDX !CharMenu
		CPX #$01 : BNE ..load
		LDX !SelectingPlayer : BEQ ..load
		LDA $00
		CLC : ADC #$000C
		STA $00
		..load
		JSR RenderHUD
		PLP
		RTS

	ReloadSelectArea:
		%LoadHUD(WarpPipe)
		JSR RenderHUD
		%LoadHUD(HomeText)
		JSR RenderHUD
		%LoadHUD(SelectSolid)
		JSR RenderHUD
		RTS

	ReloadP1Name:
		%LoadHUD(NameP1)
		LDA !P1MapChar
		AND #$000F
		ASL A
		TAX
		LDA NameOffset,x : STA $00
		JSR RenderHUD
		RTS

	ReloadP1Color:
		PHB
		PHP
		SEP #$10
		LDY.b #!VRAMbank
		PHY : PLB
		REP #$20
		JSL GetCGRAM
		LDA #$0002 : STA !CGRAMtable+$00,y
		LDA.l !P1MapChar
		AND #$000F
		ASL A
		ADC.w #Palette_CharName
		STA !CGRAMtable+$02,y
		LDA.w #Palette_CharName>>16 : STA !CGRAMtable+$04,y
		SEP #$20
		LDA #$78 : STA !CGRAMtable+$05,y
		REP #$20
		PLP
		PLB
		RTS

	ReloadP1Portrait:
		%LoadHUD(PortraitP1)
		LDA !P1MapChar
		AND #$000F
		ASL #3
		ADC $00
		STA $00
		JSR RenderHUD
		RTS

	ReloadP2Color:
		PHB
		PHP
		SEP #$10
		LDY.b #!VRAMbank
		PHY : PLB
		REP #$20
		JSL GetCGRAM
		LDA #$0002 : STA !CGRAMtable+$00,y
		LDA.l !MultiPlayer
		AND #$00FF : BNE .CharColor
		LDA.w #Palette+($79*2) : STA !CGRAMtable+$02,y
		LDA.w #Palette>>16 : BRA .Write

		.CharColor
		LDA.l !P2MapChar
		AND #$000F
		ASL A
		ADC.w #Palette_CharName
		STA !CGRAMtable+$02,y
		LDA.w #Palette_CharName>>16
		.Write
		STA !CGRAMtable+$04,y
		SEP #$20
		LDA #$79 : STA !CGRAMtable+$05,y
		PLP
		PLB
		RTS

	NameOffset:
		dw $0098/2,$00B8/2,$00D8/2
		dw $0898/2,$08B8/2,$08D8/2




	KillVR3:
		LDA #$00 : STA !VRAMbase+!VRAMtable+$2FF
		REP #$30
		LDA.w #$02FE
		LDX.w #!VRAMtable+$2FF
		LDY.w #!VRAMtable+$2FE
		MVP $40,$40
		RTS



	DrawCoinDigit:
		; A = digit
		TAY
		LDA !OAMindex_p3 : TAX
		TYA
		CLC : ADC #$3E20
		STA !OAM_p3+$002,x
		LDA $00 : STA !OAM_p3+$000,x
		DEC $0E				; n flag set
		CPY #$0001			;\ "1" digit is 1px slimmer
		BNE $02 : DEC $00		;/

		TXA
		LSR #2
		TAX
		LDA #$0000 : STA !OAMhi_p3,x
		INX
		TXA
		ASL #2
		STA !OAMindex_p3
		RTS


; input:
;	$00 = target X
;	$02 = target Y
; output:
;	BEQ -> camera at target, BNE -> camera not at target

	UpdateCamera:
		LDA $00
		BPL $02 : STZ $00
		LDA $02
		BPL $02 : STZ $02
		LDA !MapCameraSpeedX
		ASL A : STA $04
		LDA !MapCameraSpeedY
		ASL A : STA $06

		.MoveX
		LDA $1A
		SEC : SBC $00
		CLC : ADC !MapCameraSpeedX
		CMP $04 : BCC ..snapX
		LDA $1A
		CMP $00 : BCS ..decX
		..incX
		CLC : ADC !MapCameraSpeedX
		BRA ..storeX
		..decX
		SEC : SBC !MapCameraSpeedX
		BRA ..storeX
		..snapX
		LDA $00
		..storeX
		STA $1A

		.MoveY
		LDA $1C
		SEC : SBC $02
		CLC : ADC !MapCameraSpeedY
		CMP $06 : BCC ..snapY
		LDA $1C
		CMP $02 : BCS ..decY
		..incY
		CLC : ADC !MapCameraSpeedY
		BRA ..storeY
		..decY
		SEC : SBC !MapCameraSpeedY
		BRA ..storeY
		..snapY
		LDA $02
		..storeY
		STA $1C

		.CapCameraX
		LDA $1A : BPL ..pos
		LDA #$0000 : STA $1A
	..pos	CMP #$0500 : BCC ..done
		LDA #$0500 : STA $1A
		..done

		.CapCameraY
		LDA $1C : BPL ..pos
		LDA #$0000 : STA $1C
	..pos	CMP #$031F : BCC ..done
		LDA #$031F : STA $1C
		..done

		LDA $1A
		SEC : SBC $00
		BNE .Return
		LDA $1C
		SEC : SBC $02

		.Return
		RTS



macro CharDyn(file, tiles, source, dest)
	dw <tiles>*$20
	db <file>
	dw <source>*$20
	dw <dest>*$10+$6000
endmacro


	DropoutTilemap:
		db $20,$57,$83,$31	; D
		db $28,$57,$91,$31	; R
		db $30,$57,$8E,$31	; O
		db $38,$57,$8F,$31	; P
		db $48,$57,$8E,$31	; O
		db $50,$57,$94,$31	; U
		db $58,$57,$93,$31	; T
		.End





	namespace off


